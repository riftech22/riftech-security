<div align="center">

# RIFTECH SECURITY SYSTEM - WEB VERSION

## Quick Start Guide

</div>

<hr style="border: 1px solid #00ff00;">

## Overview

RIFTECH SECURITY WEB VERSION adalah versi browser-based dari sistem keamanan AI yang dapat berjalan tanpa GUI desktop. Versi ini cocok untuk:
- **Ubuntu Server** (headless deployment)
- **Cloud deployment** (AWS, DigitalOcean, VPS)
- **Remote monitoring** dari browser manapun
- **Mobile access** via browser smartphone

<hr style="border: 1px solid #00ff00;">

## Installation

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip python3-opencv

# Python 3.10+ required
python3 --version
```

### Clone Repository

```bash
git clone https://github.com/Binivert/Security-System.git
cd Security-System
```

### Install Dependencies

```bash
pip install -r requirements.txt
```

### Configure Telegram (Optional)

Edit `system_config.py`:

```python
TELEGRAM_BOT_TOKEN = "your_bot_token_here"
TELEGRAM_CHAT_ID = "your_chat_id_here"
```

<hr style="border: 1px solid #00ff00;">

## Usage

### Start Web Server

```bash
python web_server.py
```

### Access Dashboard

Open browser: **http://localhost:5000**

For remote access: **http://YOUR_SERVER_IP:5000**

<hr style="border: 1px solid #00ff00;">

## Features

### Live Monitoring
- Real-time video streaming (MJPEG)
- FPS counter
- System status display
- Arm/Disarm indicator

### Security Zones
- Click-to-draw polygon zones
- Multiple zones support
- Real-time zone visualization
- One-click zone clearing

### System Controls
| Control | Action |
|:--------|:-------|
| [ARM] SYSTEM | Activate monitoring |
| [REC] | Start/stop recording |
| [SNAP] | Capture snapshot |
| [MUTE] ALARM | Silence alarms |

### Keyboard Shortcuts
| Key | Action |
|:----|:-------|
| A | Toggle arm/disarm |
| R | Toggle recording |
| S | Take snapshot |
| M | Mute/Unmute |
| N | New zone |
| C | Clear zones |
| Esc | Cancel drawing |

### Telegram Commands
| Command | Description |
|:--------|:------------|
| /arm | Arm system |
| /disarm | Disarm system |
| /snap | Request snapshot |
| /status | Get system status |
| /stats | View daily stats |

<hr style="border: 1px solid #00ff00;">

## Cyber Hacker Theme

The web dashboard features:
- Neon green (#00ff00) color scheme
- Dark background with grid patterns
- Glowing effects and animations
- Courier New monospace font
- Responsive mobile design

<hr style="border: 1px solid #00ff00;">

## Deployment

### Ubuntu Server

```bash
# Create systemd service
sudo nano /etc/systemd/system/riftech-security.service
```

```ini
[Unit]
Description=RIFTECH Security System
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/path/to/riftech-security-system
ExecStart=/usr/bin/python3 /path/to/riftech-security-system/web_server.py
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start
sudo systemctl enable riftech-security
sudo systemctl start riftech-security
sudo systemctl status riftech-security
```

### Docker Deployment

```dockerfile
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3-opencv \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "web_server.py"]
```

```bash
docker build -t riftech-security .
docker run -p 5000:5000 --device=/dev/video0 riftech-security
```

### Cloud Deployment

1. Deploy to VPS (AWS, DigitalOcean, Linode)
2. Install Python dependencies
3. Configure firewall for port 5000
4. Run `python web_server.py`
5. Access via domain or public IP

<hr style="border: 1px solid #00ff00;">

## Troubleshooting

### Camera Not Accessible

```bash
# Check camera permissions
ls -l /dev/video0

# Add user to video group
sudo usermod -a -G video $USER
# Logout and login again
```

### Port Already in Use

```bash
# Kill process on port 5000
sudo lsof -ti:5000 | xargs kill -9
```

### Models Not Loading

```bash
# Check for YOLO models
ls *.pt

# Download manually if needed
python -c "from detection_engine import download_manager; download_manager.download_yolo('yolov8n.pt')"
```

<hr style="border: 1px solid #00ff00;">

## File Structure

```
riftech-security-system/
├── web_server.py         # Web version entry point
├── system_config.py      # Configuration
├── detection_engine.py   # AI detection
├── comms_telemetry.py   # Telegram bot
├── alert_audio.py        # TTS and alarm
├── data_storage.py       # Database
├── helper_utilities.py    # Zone management
├── templates/           # HTML templates
│   └── index.html     # Dashboard
├── static/             # Static files
│   ├── style.css       # Cyber theme
│   └── app.js         # JavaScript
├── trusted_faces/      # Trusted persons
├── recordings/         # Video recordings
├── snapshots/          # Captured snapshots
├── alerts/            # Alert photos
└── audio/             # Alarm sounds
```

<hr style="border: 1px solid #00ff00;">

## API Endpoints

### System Control

```bash
GET  /api/system        # Get system state
POST /api/system        # Control system
```

**POST Body:**
```json
{
  "action": "arm" | "disarm" | "record" | "stop_record" | "mute" | "unmute" | "snapshot"
}
```

### Zone Management

```bash
POST /api/zone         # Manage zones
```

**POST Body:**
```json
{
  "action": "clear" | "add_point",
  "x": 0,
  "y": 0
}
```

### Data Access

```bash
GET /api/recordings    # Get recordings list
GET /api/snapshots     # Get snapshots list
GET /api/events        # Get detection events
```

### Video Stream

```bash
GET /video_feed        # Live MJPEG stream
```

<hr style="border: 1px solid #00ff00;">

## Security

### Authentication (Optional)

Add to `web_server.py`:

```python
from functools import wraps

def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or auth.password != 'your_password':
            return Response('Unauthorized', 401,
                          {'WWW-Authenticate': 'Basic realm="Login"'})
        return f(*args, **kwargs)
    return decorated

@app.route('/')
@require_auth
def index():
    return render_template('index.html')
```

### HTTPS (Production)

```bash
# Install nginx
sudo apt install nginx certbot python3-certbot-nginx

# Configure nginx reverse proxy
sudo nano /etc/nginx/sites-available/riftech-security
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Enable site and get SSL
sudo ln -s /etc/nginx/sites-available/riftech-security /etc/nginx/sites-enabled/
sudo certbot --nginx -d your-domain.com
```

<hr style="border: 1px solid #00ff00;">

## Performance Tuning

### Reduce CPU Usage

Edit `system_config.py`:

```python
FRAME_WIDTH = 640  # Default 1280
FRAME_HEIGHT = 480  # Default 720
DETECTION_INTERVAL = 5  # Check every 5 frames instead of every frame
```

### Reduce Memory Usage

```python
# Disable face recognition if not needed
FACE_RECOGNITION_ENABLED = False

# Use smaller YOLO model
YOLO_MODEL = 'yolov8n.pt'  # Smallest model
```

### Optimize Video Streaming

```python
# In web_server.py generate_video()
ret, jpeg = cv2.imencode('.jpg', display_frame, 
                        [cv2.IMWRITE_JPEG_QUALITY, 75])  # Lower quality
```

<hr style="border: 1px solid #00ff00;">

## License

RIFTECH SECURITY SYSTEM - AI-Powered Monitoring Solution

Copyright 2025 RIFTECH

</div>
