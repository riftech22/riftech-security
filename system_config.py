#!/usr/bin/env python3
"""Configuration with proper timing constants."""

from pathlib import Path
from enum import Enum
from dataclasses import dataclass
from typing import Dict, Any
import os


class AlertType(Enum):
    MOTION = "motion"
    PERSON = "person"
    ZONE_BREACH = "zone_breach"
    FACE_DETECTED = "face_detected"
    SYSTEM = "system"


class Sensitivity(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


@dataclass
class PerformanceSettings:
    use_gpu: bool = True
    use_half_precision: bool = True
    enable_skeleton: bool = False
    enable_motion: bool = True
    enable_heatmap: bool = False
    enable_face_detection: bool = True
    face_interval: int = 60
    skeleton_interval: int = 3
    yolo_model: str = 'yolov8n.pt'


class Config:
    BASE_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
    RECORDINGS_DIR = BASE_DIR / "recordings"
    SNAPSHOTS_DIR = BASE_DIR / "snapshots"
    ALERTS_DIR = BASE_DIR / "alerts"
    TRUSTED_FACES_DIR = BASE_DIR / "trusted_faces"
    FIXED_IMAGES_DIR = BASE_DIR / "fixed_images"
    LOGS_DIR = BASE_DIR / "logs"
    DB_PATH = BASE_DIR / "security.db"
    
    for d in [RECORDINGS_DIR, SNAPSHOTS_DIR, ALERTS_DIR, TRUSTED_FACES_DIR, FIXED_IMAGES_DIR, LOGS_DIR]:
        d.mkdir(exist_ok=True)
    
    FRAME_WIDTH = 1280
    FRAME_HEIGHT = 720
    TARGET_FPS = 30
    
    # Detection confidence - lower for better coverage
    YOLO_CONFIDENCE = 0.25
    SKELETON_CONFIDENCE = 0.5
    
    FACE_MATCH_TOLERANCE = 0.6
    FACE_DETECTION_SCALE = 0.25
    
    MOTION_THRESHOLD = 20
    MOTION_MIN_AREA = 300
    
    # CRITICAL TIMING CONSTANTS
    INTRUDER_UPDATE_INTERVAL = 6.0  # Send "still in zone" every 6 seconds
    ZONE_CLEAR_DELAY = 5.0          # Wait 5 seconds before declaring zone clear
    
    # ========================================
    # CAMERA CONFIGURATION
    # ========================================
    # Camera Type: 'usb' (USB camera), 'rtsp' (IP Camera), 'http' (HTTP stream), 'simulation' (no camera)
    CAMERA_TYPE = 'simulation'
    
    # USB Camera Configuration
    CAMERA_ID = 0  # USB camera device ID (0, 1, 2, ...)
    
    # RTSP Camera Configuration (IP Camera like V380)
    # Format: rtsp://username:password@camera_ip:port/stream_path
    # V380 Example: rtsp://admin:password123@192.168.1.100:554/stream1
    RTSP_URL = "rtsp://username:password@camera-ip:554/stream1"
    RTSP_USERNAME = ""
    RTSP_PASSWORD = ""
    RTSP_IP = ""
    RTSP_PORT = 554
    RTSP_STREAM = "stream1"  # stream1, stream2, live, main, sub, etc.
    
    # HTTP Camera Configuration
    # Format: http://username:password@camera_ip:port/videostream.cgi
    HTTP_URL = "http://username:password@camera-ip:port/videostream.cgi"
    
    # V380 Camera Specific Settings
    V380_IP = "192.168.1.100"
    V380_PORT = 80  # or 554 for RTSP
    V380_USERNAME = "admin"
    V380_PASSWORD = ""
    V380_CHANNEL = 1  # Channel 1, 2, 3, etc.
    V380_USE_RTSP = True  # True for RTSP, False for HTTP
    
    # ========================================
    # TELEGRAM BOT CONFIGURATION
    # ========================================
    TELEGRAM_BOT_TOKEN = "8560050150:AAH4Dzk0TfE0xezzNsdZFhta1svOLPOvs4k"
    TELEGRAM_CHAT_ID = "7456977789"
    TELEGRAM_ENABLED = True  # Enable/disable Telegram notifications
    
    # ========================================
    # ALARM & TTS CONFIGURATION
    # ========================================
    ALARM_FREQUENCY = 880
    TTS_RATE = 150
    TTS_VOLUME = 0.9
    
    TRUSTED_FACES_CHECK_INTERVAL = 60
    
    performance = PerformanceSettings()
    
    CONFIDENCE_LEVELS: Dict[str, float] = {
        "15%": 0.15,
        "20%": 0.20,
        "25%": 0.25,
        "30%": 0.30,
        "40%": 0.40,
        "50%": 0.50,
        "60%": 0.60,
    }
    
    AVAILABLE_MODELS: Dict[str, str] = {
        'YOLOv8 Nano (Fast)': 'yolov8n.pt',
        'YOLOv8 Small (Balanced)': 'yolov8s.pt',
        'YOLOv8 Medium (Accurate)': 'yolov8m.pt',
    }
    
    @staticmethod
    def get_sensitivity_settings(sensitivity: Sensitivity) -> Dict[str, Any]:
        presets = {
            Sensitivity.LOW: {
                'yolo_confidence': 0.50,
                'skeleton_confidence': 0.6,
                'motion_threshold': 30,
                'motion_min_area': 800,
            },
            Sensitivity.MEDIUM: {
                'yolo_confidence': 0.30,
                'skeleton_confidence': 0.5,
                'motion_threshold': 20,
                'motion_min_area': 400,
            },
            Sensitivity.HIGH: {
                'yolo_confidence': 0.15,
                'skeleton_confidence': 0.3,
                'motion_threshold': 12,
                'motion_min_area': 150,
            }
        }
        return presets.get(sensitivity, presets[Sensitivity.MEDIUM])
