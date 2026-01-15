#!/usr/bin/env python3
"""
RIFTECH SECURITY SYSTEM - Web Version
"""

import os
import sys
import cv2
import numpy as np
import threading
import time
from datetime import datetime
from flask import Flask, render_template, Response, jsonify, request, session, redirect, url_for
from flask_socketio import SocketIO, emit
from pathlib import Path
from functools import wraps

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS'] = '0'

# Login credentials
LOGIN_USERNAME = 'admin'
LOGIN_PASSWORD = 'riftech2025'

# Initialize Flask app first
app = Flask(__name__)
app.secret_key = 'riftech-security-secret-key-v2'

# Then import and initialize other components
try:
    from system_config import Config, AlertType
    from data_storage import DatabaseManager
except Exception as e:
    print(f"[ERROR] Failed to import config/database: {e}")
    sys.exit(1)
from detection_engine import (
    PersonDetector, FaceRecognitionEngine, MotionDetector, DetectionThread,
    FACE_RECOGNITION_AVAILABLE, download_manager, PersonDetection
)
from comms_telemetry import TelegramBot
from alert_audio import TTSEngine, WavAlarm
from helper_utilities import MultiZoneManager

# Initialize SocketIO
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

# Login decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('logged_in'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# Initialize components with error handling
try:
    config = Config()
    db = DatabaseManager(config)
    telegram = TelegramBot(config)
    tts = TTSEngine()
    alarm = WavAlarm(config)
    zone_manager = MultiZoneManager()
    print("[INIT] Components initialized successfully")
except Exception as e:
    print(f"[ERROR] Failed to initialize components: {e}")

# Detection components
person_detector = None
face_engine = None
motion_detector = None
detection_thread = None
_models_loaded = False

# Camera
camera_thread = None
camera_lock = threading.Lock()
current_frame = None
display_frame = None
frame_lock = threading.Lock()

# System state
system_state = {
    'armed': False,
    'recording': False,
    'muted': False,
    'breach_active': False,
    'breach_start_time': 0,
    'persons_detected': 0,
    'fps': 0,
    'alerts_count': 0
}

# Breach tracking
breach_active = False
breach_start_time = 0
photo_sent_this_breach = False
last_telegram_update = 0

# Trusted faces
trusted_detected = False
trusted_name = ""
trusted_timeout = 0
greeted_persons = set()


class WebCameraThread(threading.Thread):
    def __init__(self, camera_id=0):
        super().__init__()
        self.camera_id = camera_id
        self.running = False
        self.cap = None
        self.paused = False
    
    def run(self):
        global current_frame, display_frame
        
        for backend in [cv2.CAP_DSHOW, cv2.CAP_MSMF, cv2.CAP_ANY]:
            try:
                self.cap = cv2.VideoCapture(self.camera_id, backend)
                if self.cap.isOpened():
                    ret, _ = self.cap.read()
                    if ret:
                        break
                    self.cap.release()
            except:
                pass
        
        if not self.cap or not self.cap.isOpened():
            print(f"[Camera] Cannot open camera {self.camera_id}")
            return
        
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, config.FRAME_WIDTH)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, config.FRAME_HEIGHT)
        self.cap.set(cv2.CAP_PROP_FPS, 30)
        self.cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
        
        self.running = True
        print(f"[Camera] Started - Camera {self.camera_id}")
        
        count = 0
        start = time.time()
        
        while self.running:
            if self.paused:
                time.sleep(0.05)
                continue
            
            ret, frame = self.cap.read()
            if ret and frame is not None:
                with frame_lock:
                    current_frame = frame.copy()
                
                count += 1
                if time.time() - start >= 1.0:
                    system_state['fps'] = count / (time.time() - start)
                    count = 0
                    start = time.time()
            else:
                time.sleep(0.01)
        
        if self.cap:
            self.cap.release()
        print("[Camera] Stopped")
    
    def stop(self):
        self.running = False
        self.join(3000)


def generate_video():
    """Generate MJPEG video stream"""
    global display_frame
    
    while True:
        with frame_lock:
            frame = display_frame
        
        if frame is not None:
            ret, jpeg = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
            frame_bytes = jpeg.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
        else:
            time.sleep(0.01)


@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page"""
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        if username == LOGIN_USERNAME and password == LOGIN_PASSWORD:
            session['logged_in'] = True
            session['username'] = username
            return redirect(url_for('index'))
        else:
            return render_template('login.html', error=True)
    
    return render_template('login.html', error=False)


@app.route('/logout')
def logout():
    """Logout"""
    session.clear()
    return redirect(url_for('login'))


@app.route('/')
@login_required
def index():
    """Main dashboard"""
    events = db.get_all_events(limit=100)
    recordings = list(config.RECORDINGS_DIR.glob("*.avi"))
    snapshots = list(config.SNAPSHOTS_DIR.glob("*.jpg"))
    
    return render_template('index.html',
                     system_state=system_state,
                     events=events,
                     recordings=recordings,
                     snapshots=snapshots,
                     zone_count=zone_manager.get_zone_count())


@app.route('/video_feed')
def video_feed():
    """Video streaming route"""
    return Response(generate_video(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


@app.route('/api/system', methods=['GET', 'POST'])
def api_system():
    """System control API"""
    if request.method == 'GET':
        return jsonify(system_state)
    
    data = request.json
    action = data.get('action')
    
    if action == 'arm':
        toggle_arm(True)
    elif action == 'disarm':
        toggle_arm(False)
    elif action == 'record':
        toggle_record(True)
    elif action == 'stop_record':
        toggle_record(False)
    elif action == 'mute':
        toggle_mute(True)
    elif action == 'unmute':
        toggle_mute(False)
    elif action == 'snapshot':
        take_snapshot()
    
    return jsonify({'success': True})


@app.route('/api/zone', methods=['POST'])
def api_zone():
    """Zone management API"""
    data = request.json
    action = data.get('action')
    
    if action == 'clear':
        zone_manager.delete_all_zones()
    elif action == 'add_point':
        x = data.get('x', 0)
        y = data.get('y', 0)
        zone = zone_manager.get_active_zone()
        if zone:
            zone.add_point(x, y)
    
    socketio.emit('zone_update', {
        'count': zone_manager.get_zone_count(),
        'points': len(zone_manager.get_active_zone().points) if zone_manager.get_active_zone() else 0
    })
    
    return jsonify({'success': True})


@app.route('/api/recordings')
def api_recordings():
    """Get recordings list"""
    recordings = []
    for f in config.RECORDINGS_DIR.glob("*.avi"):
        recordings.append({
            'name': f.name,
            'path': str(f),
            'size': f.stat().st_size if f.exists() else 0
        })
    return jsonify(recordings)


@app.route('/api/snapshots')
def api_snapshots():
    """Get snapshots list"""
    snapshots = []
    for f in config.SNAPSHOTS_DIR.glob("*.jpg"):
        snapshots.append({
            'name': f.name,
            'path': str(f)
        })
    return jsonify(snapshots)


@app.route('/api/events')
def api_events():
    """Get detection events"""
    limit = request.args.get('limit', 100, type=int)
    events = db.get_all_events(limit=limit)
    return jsonify(events)


def toggle_arm(armed):
    """Toggle arm/disarm"""
    global breach_active, photo_sent_this_breach
    
    system_state['armed'] = armed
    
    if armed:
        telegram.update_state(True, system_state['recording'], system_state['muted'])
        tts.speak("System armed")
        print("[System] ARMED")
    else:
        telegram.update_state(False, system_state['recording'], system_state['muted'])
        tts.speak("System disarmed")
        alarm.stop()
        breach_active = False
        photo_sent_this_breach = False
        print("[System] DISARMED")
    
    socketio.emit('system_update', system_state)


def toggle_record(recording):
    """Toggle recording"""
    system_state['recording'] = recording
    telegram.update_state(system_state['armed'], recording, system_state['muted'])
    
    if recording:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        path = str(config.RECORDINGS_DIR / f"rec_{ts}.avi")
        fourcc = cv2.VideoWriter_fourcc(*'XVID')
        writer = cv2.VideoWriter(path, fourcc, 25.0, 
                               (config.FRAME_WIDTH, config.FRAME_HEIGHT))
        globals()['video_writer'] = writer
        tts.speak("Recording")
        print(f"[Recording] Started - {path}")
    else:
        if 'video_writer' in globals():
            globals()['video_writer'].release()
            del globals()['video_writer']
        tts.speak("Stopped")
        print("[Recording] Stopped")
    
    socketio.emit('system_update', system_state)


def toggle_mute(muted):
    """Toggle alarm mute"""
    system_state['muted'] = muted
    
    if muted:
        alarm.mute()
        print("[Alarm] Muted")
    else:
        alarm.unmute()
        print("[Alarm] Unmuted")
    
    socketio.emit('system_update', system_state)


def take_snapshot():
    """Take snapshot"""
    global current_frame
    
    with frame_lock:
        if current_frame is not None:
            frame = current_frame.copy()
        else:
            return
    
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    path = str(config.SNAPSHOTS_DIR / f"snap_{ts}.jpg")
    cv2.imwrite(path, frame, [cv2.IMWRITE_JPEG_QUALITY, 95])
    
    # Send to Telegram
    telegram.send_snapshot(path)
    tts.speak("Snapshot")
    print(f"[Snapshot] Saved - {path}")


def process_detection():
    """Process detection in background thread"""
    global display_frame, breach_active, photo_sent_this_breach
    
    global breach_start_time, last_telegram_update
    global trusted_detected, trusted_name, trusted_timeout
    
    if not _models_loaded or detection_thread is None:
        return
    
    while True:
        time.sleep(0.05)
        
        with frame_lock:
            if current_frame is None:
                continue
            frame = current_frame.copy()
        
        # Submit to detection thread
        detection_thread.submit(frame)
        
        # Get results
        results = detection_thread.get_results()
        det_frame = results.get('frame')
        persons = results.get('persons', [])
        has_motion = results.get('motion', False)
        motion_regions = results.get('motion_regions', [])
        
        if det_frame is not None:
            frame = det_frame
        
        # Check zone breach
        global breach_active
        intruder_in_zone = False
        breach_reason = ""
        
        now = time.time()
        
        # Check trusted face timeout
        if trusted_detected and now > trusted_timeout:
            trusted_detected = False
            trusted_name = ""
        
        # Check for intruders
        if system_state['armed'] and zone_manager.get_zone_count() > 0:
            for person in persons:
                # Check if person in zone
                cx, cy = person.center
                if zone_manager.check_all_zones(cx, cy):
                    intruder_in_zone = True
                    breach_reason = "Person detected in zone"
                    break
            
            # Also check motion
            if not intruder_in_zone and has_motion:
                for mx1, my1, mx2, my2 in motion_regions:
                    cx, cy = (mx1 + mx2) // 2, (my1 + my2) // 2
                    if zone_manager.check_all_zones(cx, cy):
                        intruder_in_zone = True
                        breach_reason = "Movement detected in zone"
                        break
        
        # Face recognition
        if FACE_RECOGNITION_AVAILABLE and face_engine and persons:
            for face in face_engine.recognize_faces(frame):
                left, top, right, bottom = face.bbox
                color = (0, 255, 0) if face.is_trusted else (0, 0, 255)
                label = face.name if face.is_trusted else "UNKNOWN"
                cv2.rectangle(frame, (left, top), (right, bottom), color, 2)
                cv2.putText(frame, label, (left, top - 7), 
                          cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
                
                if face.is_trusted and face.confidence > 0.5:
                    trusted_detected = True
                    trusted_name = face.name
                    trusted_timeout = now + 10
                    if face.name not in greeted_persons:
                        greeted_persons.add(face.name)
                        tts.speak(f"Welcome {face.name}")
        
        # Control alarm
        if intruder_in_zone and not trusted_detected:
            # INTRUDER IN ZONE - ALARM ON
            alarm.start()
            
            if not breach_active:
                breach_active = True
                breach_start_time = now
                photo_sent_this_breach = False
                last_telegram_update = now
                
                system_state['alerts_count'] += 1
                system_state['breach_active'] = True
                
                tts.speak("Intruder detected")
                
                # Send photo
                path = str(config.SNAPSHOTS_DIR / f"alert_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg")
                cv2.imwrite(path, frame, [cv2.IMWRITE_JPEG_QUALITY, 95])
                try:
                    db.log_event(AlertType.ZONE_BREACH.value, breach_reason, path, len(persons))
                    telegram.send_alert_with_photo(
                        f"[INTRUDER DETECTED]\n\n{breach_reason}\nPersons: {len(persons)}",
                        path
                    )
                except:
                    pass
                photo_sent_this_breach = True
            else:
                # Update every 30 seconds
                if now - last_telegram_update >= 30:
                    last_telegram_update = now
                    telegram.send_message(f"[INTRUDER STILL IN ZONE] ({int(now - breach_start_time)}s)")
        
        elif trusted_detected and intruder_in_zone:
            # TRUSTED PERSON - NO ALARM
            alarm.stop()
            
            if breach_active:
                telegram.send_message(f"[TRUSTED PERSON] {trusted_name}")
            
            breach_active = False
            photo_sent_this_breach = False
            system_state['breach_active'] = False
        
        else:
            # NO INTRUDER - ALARM OFF
            alarm.stop()
            
            if breach_active:
                duration = int(now - breach_start_time)
                telegram.send_message(f"[ZONE CLEARED] ({duration}s)")
            
            breach_active = False
            photo_sent_this_breach = False
            system_state['breach_active'] = False
        
        # Update state
        system_state['persons_detected'] = len(persons)
        
        # Draw zones
        frame = zone_manager.draw_all(frame, [], system_state['armed'])
        
        # Draw armed indicator
        h, w = frame.shape[:2]
        if system_state['armed']:
            cv2.putText(frame, "ARMED", (w - 85, h - 15), 
                      cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
        
        # Draw recording indicator
        if system_state['recording']:
            cv2.circle(frame, (w - 25, 25), 10, (0, 0, 255), -1)
            cv2.putText(frame, "REC", (w - 65, 30), 
                      cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
        
        # Write to video if recording
        if system_state['recording'] and 'video_writer' in globals():
            try:
                with frame_lock:
                    if current_frame is not None:
                        globals()['video_writer'].write(current_frame)
            except:
                pass
        
        with frame_lock:
            display_frame = frame
        
        # Emit update
        socketio.emit('detection_update', {
            'persons': len(persons),
            'breach': breach_active,
            'armed': system_state['armed']
        })


def load_models():
    """Load AI models in background"""
    global person_detector, face_engine, motion_detector, detection_thread, _models_loaded
    
    try:
        person_detector = PersonDetector(config)
        face_engine = FaceRecognitionEngine(config)
        motion_detector = MotionDetector(config)
        detection_thread = DetectionThread(person_detector, motion_detector)
        detection_thread.start()
        _models_loaded = True
        print("[Models] Loaded successfully")
    except Exception as e:
        print(f"[Models] Error: {e}")
        _models_loaded = True


if __name__ == '__main__':
    print("\n" + "="*60)
    print("\033[92mRIFTECH SECURITY SYSTEM - WEB VERSION\033[0m")
    print("="*60 + "\n")
    
    # Load models
    threading.Thread(target=load_models, daemon=True).start()
    
    # Start camera
    camera_thread = WebCameraThread(camera_id=0)
    camera_thread.start()
    
    # Start detection processing
    threading.Thread(target=process_detection, daemon=True).start()
    
    # Start services
    telegram.start()
    tts.start()
    
    print("\033[92m[SUCCESS] RIFTECH SECURITY WEB SERVER STARTED\033[0m")
    print("\033[96mAccess at: http://localhost:5000\033[0m\n")
    
    try:
        socketio.run(app, host='0.0.0.0', port=5000, debug=False, allow_unsafe_werkzeug=True)
    except KeyboardInterrupt:
        print("\n\033[93m[SHUTDOWN] Stopping...\033[0m")
        
        # Cleanup
        alarm.stop()
        if detection_thread:
            detection_thread.stop()
        if camera_thread:
            camera_thread.stop()
        if 'video_writer' in globals():
            globals()['video_writer'].release()
        
        telegram.stop()
        telegram.wait(2000)
        tts.stop()
        tts.wait(2000)
        
        print("\033[92m[SHUTDOWN] Complete\033[0m")
