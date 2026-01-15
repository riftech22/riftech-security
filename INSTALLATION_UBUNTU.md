<div align="center">

# 🐧 PANDUAN INSTALASI UBUNTU 🐧

## RIFTECH SECURITY SYSTEM

</div>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📋 PRASYARAT SISTEM 📋

</div>

<br>

### Hardware Minimum

| Komponen | Spesifikasi Minimum |
|:---------|:------------------|
| CPU | Intel i3 / AMD Ryzen 3 atau lebih tinggi |
| RAM | 4 GB (rekomendasi 8 GB) |
| Storage | 10 GB free space |
| Kamera | Webcam USB atau IP Camera yang support RTSP |
| OS | Ubuntu 20.04 LTS atau lebih baru |

### Software Prasyarat

- Python 3.10 atau lebih tinggi
- pip (Python package manager)
- Virtual environment (venv)
- Git (untuk clone repository)

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📦 LANGKAH 1: UPDATE SYSTEM 📦

</div>

<br>

Buka terminal dan jalankan:

```bash
# Update package list
sudo apt update

# Upgrade installed packages
sudo apt upgrade -y

# Install system dependencies
sudo apt install -y python3 python3-pip python3-venv git curl wget
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🔧 LANGKAH 2: INSTALL SYSTEM DEPENDENCIES 🔧

</div>

<br>

### Install untuk Desktop Version (GUI)

```bash
# Install GUI dependencies
sudo apt install -y libqt6gui6 libqt6widgets6 libqt6core6

# Install OpenCV dependencies
sudo apt install -y libopencv-dev python3-opencv

# Install audio dependencies
sudo apt install -y portaudio19-dev python3-pyaudio

# Install face recognition dependencies
sudo apt install -y cmake build-essential

# Install dlib dependencies
sudo apt install -y libx11-dev libgtk-3-dev
```

### Install untuk Web Version (Headless Server)

```bash
# Install headless OpenCV
sudo apt install -y libopencv-dev python3-opencv

# Install build tools (untuk face recognition)
sudo apt install -y cmake build-essential

# Install dlib dependencies
sudo apt install -y libx11-dev libgtk-3-dev libboost-all-dev
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📥 LANGKAH 3: CLONE REPOSITORY 📥

</div>

<br>

```bash
# Clone repository
git clone https://github.com/Binivert/Security-System.git
cd Security-System

# Atau jika sudah ada file-file di folder saat ini
cd /path/to/riftech-security-system
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🐍 LANGKAH 4: SETUP VIRTUAL ENVIRONMENT 🐍

</div>

<br>

```bash
# Buat virtual environment
python3 -m venv venv

# Aktifkan virtual environment
source venv/bin/activate

# Cek Python version (harus 3.10+)
python --version
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📚 LANGKAH 5: INSTALL PYTHON DEPENDENCIES 📚

</div>

<br>

### Install dari requirements.txt

```bash
# Upgrade pip terlebih dahulu
pip install --upgrade pip

# Install semua dependencies
pip install -r requirements.txt
```

### Jika ada error saat install, install secara terpisah:

```bash
# Install PyQt6 (hanya untuk desktop version)
pip install PyQt6

# Install OpenCV
pip install opencv-python numpy

# Install face recognition dependencies
pip install face-recognition
# Note: Face recognition butuh waktu install lebih lama

# Install MediaPipe
pip install mediapipe

# Install web dependencies
pip install Flask Flask-SocketIO python-socketio

# Install text-to-speech
pip install pyttsx3

# Install audio playback
pip install pygame

# Install HTTP requests
pip install requests
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📁 LANGKAH 6: SETUP FOLDER YANG DIPERLUKAN 📁

</div>

<br>

```bash
# Buat semua folder yang diperlukan
mkdir -p trusted_faces recordings snapshots alerts audio

# Cek folder yang sudah dibuat
ls -la

# Hasil harus menampilkan:
# trusted_faces/
# recordings/
# snapshots/
# alerts/
# audio/
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🔑 LANGKAH 7: KONFIGURASI TELEGRAM (OPTIONAL) 🔑

</div>

<br>

Jika ingin menggunakan notifikasi Telegram:

1. Buat bot melalui [@BotFather](https://t.me/botfather) di Telegram
2. Copy token bot Anda
3. Dapatkan chat ID Anda dari [@userinfobot](https://t.me/userinfobot)
4. Edit file `system_config.py`:

```python
# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN = "your_bot_token_here"
TELEGRAM_CHAT_ID = "your_chat_id_here"
```

Jika TIDAK ingin menggunakan Telegram:

```python
# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN = ""
TELEGRAM_CHAT_ID = ""
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🔑 LANGKAH 8: KONFIGURASI WEB LOGIN (OPTIONAL) 🔑

</div>

<br>

Untuk mengubah username dan password login web server, edit file `web_server.py`:

```python
# Login credentials (baris 18-19)
LOGIN_USERNAME = 'admin'      # Ganti dengan username baru
LOGIN_PASSWORD = 'riftech2025'  # Ganti dengan password baru
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🎯 LANGKAH 9: MENJALANKAN SISTEM 🎯

</div>

<br>

### Versi Desktop (GUI)

```bash
# Pastikan virtual environment aktif
source venv/bin/activate

# Jalankan desktop version
python core_entry.py
```

### Versi Web (Browser)

```bash
# Pastikan virtual environment aktif
source venv/bin/activate

# Jalankan web server
python web_server.py
```

Akses dashboard di browser: `http://localhost:5000` atau `http://IP_SERVER:5000`

**Default Login:**
- Username: `admin`
- Password: `riftech2025`

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🛠️ TROUBLESHOOTING UMUM 🛠️

</div>

<br>

### Error: ModuleNotFoundError

**Solusi:**
```bash
# Install modul yang missing
pip install nama_modul

# Contoh:
pip install opencv-python
pip install PyQt6
```

### Error: Qt platform plugin

**Solusi (Desktop Version):**
```bash
# Install Qt dependencies
sudo apt install -y libqt6gui6 libqt6widgets6 libqt6core6

# Set QT_QPA_PLATFORM
export QT_QPA_PLATFORM=xcb
```

### Error: Cannot import face_recognition

**Solusi:**
```bash
# Install build tools
sudo apt install -y cmake build-essential

# Install dlib dari source
pip install dlib

# Install face recognition
pip install face-recognition
```

### Error: Camera tidak bisa diakses

**Solusi:**
```bash
# Cek permission kamera
ls -l /dev/video*

# Tambah user ke video group
sudo usermod -a -G video $USER

# Logout dan login lagi
# Atau
newgrp video
```

### Error: Port 5000 sudah digunakan

**Solusi:**
```bash
# Kill process di port 5000
sudo lsof -ti:5000 | xargs kill -9

# Atau ubah port di web_server.py
socketio.run(app, host='0.0.0.0', port=8080, ...)
```

### Error: Memory Error / Out of Memory

**Solusi:**
```bash
# Edit system_config.py
# Kurangi frame resolution
FRAME_WIDTH = 640   # Default 1280
FRAME_HEIGHT = 480  # Default 720

# Kurangi interval deteksi
DETECTION_INTERVAL = 5  # Cek setiap 5 frame

# Nonaktifkan fitur yang tidak diperlukan
FACE_RECOGNITION_ENABLED = False
```

### Error: TensorFlow / CUDA Issues

**Solusi:**
```bash
# Gunakan OpenCV tanpa CUDA
export OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS=0

# Set TF log level
export TF_CPP_MIN_LOG_LEVEL=3
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🚀 AUTO-START PADA BOOT (OPTIONAL) 🚀

</div>

<br>

### Create systemd service untuk Web Version

```bash
# Buat service file
sudo nano /etc/systemd/system/riftech-security.service
```

Paste konfigurasi berikut:

```ini
[Unit]
Description=RIFTECH Security System Web Server
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/path/to/riftech-security-system
Environment="PATH=/path/to/riftech-security-system/venv/bin"
ExecStart=/path/to/riftech-security-system/venv/bin/python web_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Ganti:**
- `your_username` dengan username Anda
- `/path/to/riftech-security-system` dengan path absolut project Anda

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service (auto-start on boot)
sudo systemctl enable riftech-security.service

# Start service sekarang
sudo systemctl start riftech-security.service

# Cek status
sudo systemctl status riftech-security.service

# View logs
sudo journalctl -u riftech-security.service -f
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📋 CEKLIST INSTALASI SUKSES 📋

</div>

<br>

Setelah instalasi selesai, ceklist berikut:

- [ ] Python 3.10+ terinstall
- [ ] Virtual environment aktif
- [ ] Semua dependencies di `requirements.txt` terinstall
- [ ] Folder `trusted_faces`, `recordings`, `snapshots`, `alerts`, `audio` ada
- [ ] File `audio/alarm.wav` ada
- [ ] Kamera bisa diakses (tes dengan `ls /dev/video*`)
- [ ] Bisa menjalankan `python core_entry.py` (desktop) atau `python web_server.py` (web)
- [ ] Login ke web server berhasil (username: admin, password: riftech2025)
- [ ] Dashboard bisa diakses via browser
- [ ] Telegram bot bekerja (jika dikonfigurasi)

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📞 BANTUAN & DOKUMENTASI 📞

</div>

<br>

**Dokumentasi Lengkap:**
- `README.md` - Dokumentasi utama (bahasa Indonesia)
- `README_WEB.md` - Panduan khusus versi web
- `README_ASSETS.md` - Info asset SVG dan diagram
- `ANIMATED_ASSETS.md` - Info animasi dan web dashboard
- `INSTALLATION_UBUNTU.md` - Panduan instalasi ini

**Masalah?** Cek dokumentasi atau buat issue di GitHub repository.

<br>

<div align="center">

---

**⚡ INSTALASI SELESAI! RIFTECH SECURITY SYSTEM SIAP DIGUNAKAN! ⚡**

---

</div>

</div>
