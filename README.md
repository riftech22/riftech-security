<div align="center">

# 🔒 RIFTECH SECURITY SYSTEM 🔒

### Sistem Keamanan AI-Powered dengan Tema Cyber Hacker

</div>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## ⚡ SYSTEM OVERVIEW ⚡

</div>

<br>

**RIFTECH SECURITY** adalah platform pengawasan canggih bertenaga AI yang mengubah kamera manapun menjadi stasiun pemantauan cerdas. Dibangun dengan teknologi visi komputer terkini, sistem ini menyediakan deteksi orang, pengenalan wajah, analisis gerakan, dan peringatan instan—semua dapat dikontrol dari aplikasi Telegram Anda atau browser web.

Sistem ini menggabungkan **YOLOv8** untuk deteksi orang yang akurat, **MediaPipe** untuk pelacakan kerangka, dan **face_recognition** untuk identifikasi orang terpercaya. Ketika penyusup memasuki zona keamanan yang ditentukan, sistem segera memicu alarm, menangkap bukti, dan mengirim notifikasi ke ponsel atau dashboard web Anda.

🌐 **Repository GitHub:** https://github.com/riftech22/riftech-security.git

**Tersedia dalam Dua Versi:**
- 🔓 **Versi Desktop** — PyQt6 GUI dengan fitur lengkap
- 🌐 **Versi Web** — Interface berbasis browser, berjalan di server tanpa GUI

**Kemampuan Utama:**
- ✅ **Zero false positives** dengan deteksi neural network YOLOv8
- ✅ **Pelacakan kerangka lengkap** mendeteksi intrusi parsial (tangan, kaki, dll)
- ✅ **Pengenalan orang terpercaya** secara otomatis menonaktifkan alarm untuk wajah yang dikenal
- ✅ **Kontrol Telegram lengkap** dengan tombol inline dan status real-time
- ✅ **Dashboard web** dapat diakses dari browser manapun dengan tema cyber hacker
- ✅ **Peta panas gerakan** memvisualisasikan pola aktivitas dari waktu ke waktu
- ✅ **Interface profesional** dengan visi malam, perekaman, dan penggambaran zona

</div>

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🎯 FITUR UTAMA 🎯

</div>

<br><br>

| Fitur | Deskripsi |
|:-----:|:---------|
| **Deteksi YOLOv8** | Neural network canggih untuk deteksi orang yang akurat dengan sensitivitas yang dapat disesuaikan (Low/Medium/High) |
| **Pelacakan Kerangka** | Estimasi pose MediaPipe melacak 33 titik sendi untuk deteksi intrusi komprehensif |
| **Pengenalan Wajah** | Mengidentifikasi orang terpercaya dan secara otomatis menekan alarm palsu dengan sapaan yang dipersonalisasi |
| **Zona Keamanan 3D** | Menggambar zona poligonal kustom dengan visualisasi animasi dan deteksi intrusi real-time |
| **Peta Panas Gerakan** | Memvisualisasikan pola gerakan dengan overlay intensitas berkode warna |
| **Integrasi Telegram** | Kontrol penuh dengan tombol inline, snapshot langsung, dan peringatan instan |
| **Dashboard Web** | Interface berbasis browser dengan tema cyber hacker, update real-time via WebSocket |
| **Sistem Alarm Cerdas** | Peringatan audio dengan pengumuman text-to-speech dan kontrol mute |
| **Input Multi-Sumber** | Mendukung kamera langsung dan pemutaran file video dengan kontrol transport lengkap |
| **Operasi Headless** | Versi web berjalan di Ubuntu Server tanpa persyaratan GUI |

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🖥️ VERSI YANG TERSEDIA 🖥️

</div>

<br>

### 🔓 Versi Desktop (GUI)
- **Entry Point:** `core_entry.py`
- **GUI Framework:** PyQt6
- **Fitur:** Set fitur lengkap termasuk semua kontrol visual
- **Persyaratan:** OS Desktop (Windows/Linux/Mac) dengan dukungan GUI
- **Kasus Penggunaan:** Pemantauan langsung di mesin lokal

### 🌐 Versi Web (Browser)
- **Entry Point:** `web_server.py`
- **Web Framework:** Flask + Socket.IO
- **Fitur:** Semua fitur utama dapat diakses melalui browser
- **Persyaratan:** OS apapun termasuk server tanpa GUI
- **Kasus Penggunaan:** Pemantauan jarak jauh, deployment cloud, server headless
- **Akses:** `http://localhost:5000` (atau IP server Anda)

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📸 DASHBOARD CYBER HACKER 📸

</div>

<br>

<div align="center">

<pre style="background: #000; color: #00ff00; font-family: 'Courier New', monospace; padding: 20px; border: 2px solid #00ff00; box-shadow: 0 0 20px #00ff00;">

█████████████████████████████████████████████████████████████████████████████████
█  RIFTECH SECURITY SYSTEM - CYBER DASHBOARD v2.0                    █
█  ─────────────────────────────────────────────────────────────────────────────  █
█                                                                       █
█  ┌─ LIVE CAMERA FEED ────────────────────────────────────────────────┐   █
█  │ ████████████████████████████████████████████████████████████████████ │   █
█  │ ████████████████████████████████████████████████████████████████████ │   █
█  │ ████████ [PERSON DETECTED] ████████████████████████████████████████ │   █
█  │ ████████████████████████████████████████████████████████████████████ │   █
█  │ ████████ BOUNDING BOX █████████████████████████████████████████████ │   █
█  │ ████████████████████████████████████████████████████████████████████ │   █
█  │ ████████████████████████████████████████████████████████████████████ │   █
█  │ ████████████████████████████████████████████████████████████████████ │   █
█  └──────────────────────────────────────────────────────────────────────────┘   █
█                                                                       █
█  ┌─ SYSTEM STATUS ──────────────────────────────────────────────────────────┐   █
█  │ ARMED: [TRUE]  BREACH: [NONE]  ALARM: [READY]                     │   █
█  │ FPS: 30  PERSONS: 2  ZONES: 3  ALERTS: 0                        │   █
█  └──────────────────────────────────────────────────────────────────────────┘   █
█                                                                       █
█  ┌─ SECURITY ZONES ────────────────────────────────────────────────────────┐   █
█  │ ┌────────────────────────────────────────────────────────────────────┐    │   █
█  │ │ ╔════════════════════════════════════════════════════════╗ │    │   █
█  │ │ ║        ████████████████████████████████████████         ║ │    │   █
█  │ │ ║        ████████████████████████████████████████         ║ │    │   █
█  │ │ ║        ████████████████████████████████████████         ║ │    │   █
█  │ │ ╚════════════════════════════════════════════════════════╝ │    │   █
█  │ └────────────────────────────────────────────────────────────────────┘    │   █
█  └──────────────────────────────────────────────────────────────────────────┘   █
█                                                                       █
█  [ARM SYSTEM]  [REC]  [SNAP]  [MUTE]                                █
█                                                                       █
█████████████████████████████████████████████████████████████████████████████████

</pre>

</div>

<br>

**Tema Cyber Hacker mencakup:**
- 🟢 Warna hijau neon (#00ff00) dan cyan (#00ffff)
- ⬛ Background hitam dengan pola grid
- ✨ Efek glow dan animasi berdenyut
- 💻 Font monospace Courier New
- 📱 Desain responsif untuk mobile
- ⚡ Interface real-time dengan WebSocket

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🚀 INSTALASI 🚀

</div>

<br>

**Prasyarat:**
- Python 3.10 atau lebih tinggi
- Webcam atau kamera IP
- Akun Telegram (untuk kontrol jarak jauh)

**Langkah 1: Clone Repository**

```bash
git clone https://github.com/riftech22/riftech-security.git
cd riftech-security
```

**Langkah 2: Buat Virtual Environment**

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

**Langkah 3: Install Dependencies**

```bash
pip install -r requirements.txt
```

**🌟 METODE 1: INSTALASI DARI GITHUB (PALING MUDAH) 🌟**

**Cara Cepat: 1 Command, 2 Menit, Langsung Jalan!**

```bash
# 1. Jalankan script instalasi (PERLU SUDO)
sudo bash install_from_github.sh

# Script akan otomatis:
# ✓ Download dari GitHub
# ✓ Install ke /opt/riftech-security
# ✓ Setup virtual environment
# ✓ Install semua dependencies
# ✓ Setup systemd service
# ✓ Start service langsung
# ✓ Auto-start pada boot

# Selesai dalam 2-5 menit!
```

**📦 Apa yang Akan Dilakukan Script:**

1. **Download dari GitHub** - Clone repository otomatis
2. **Install ke /opt** - Copy semua file ke direktori sistem
3. **Setup Virtual Environment** - Buat Python venv
4. **Install Dependencies** - Install semua Python packages
5. **Setup Systemd Service** - Buat service untuk auto-start
6. **Start Service** - Jalankan web server langsung
7. **Auto-Start** - Enable service untuk boot otomatis

**🎮 Setelah Instalasi Selesai:**

```bash
# Akses dashboard di browser
http://localhost:5000

# Atau gunakan IP server Anda
http://IP_SERVER:5000

# Login dengan kredensial default:
Username: admin
Password: riftech2025
```

**📊 Cek Status Service:**

```bash
# Cek apakah service berjalan
sudo systemctl status riftech-security

# Lihat logs real-time
sudo journalctl -u riftech-security -f

# Lihat logs di file
sudo cat /opt/riftech-security/logs/systemd.log
```

**🎮 Kontrol Service:**

```bash
# Stop service
sudo systemctl stop riftech-security

# Start service
sudo systemctl start riftech-security

# Restart service
sudo systemctl restart riftech-security
```

---

**🔧 METODE 2: INSTALASI MANUAL (Jika script gagal)**

**Langkah 1: Clone Repository**

```bash
git clone https://github.com/riftech22/riftech-security.git
cd riftech-security
```

**Langkah 2: Instalasi Otomatis ke /opt (Linux)**

```bash
# Jalankan script instalasi (perlu sudo)
sudo bash install_to_opt.sh

# Script akan melakukan:
# 1. Copy project ke /opt/riftech-security
# 2. Buat virtual environment
# 3. Install semua dependencies
# 4. Setup systemd service
# 5. Enable auto-start pada boot
```

**Setelah instalasi selesai:**

```bash
# Start service
sudo systemctl start riftech-security

# Cek status
sudo systemctl status riftech-security

# View logs
sudo journalctl -u riftech-security -f

# Stop service
sudo systemctl stop riftech-security

# Restart service
sudo systemctl restart riftech-security
```

**Uninstall:**
```bash
sudo bash uninstall_from_opt.sh
```

**⚙️ KONFIGURASI SISTEM (Opsional)**

**Langkah 5: Konfigurasi Bot Telegram (Opsional)**

1. Buat bot melalui [@BotFather](https://t.me/botfather) di Telegram
2. Copy token bot Anda
3. Dapatkan chat ID Anda dari [@userinfobot](https://t.me/userinfobot)
4. Update `system_config.py` dengan kredensial Anda:

```python
TELEGRAM_BOT_TOKEN = "your_bot_token_here"
TELEGRAM_CHAT_ID = "your_chat_id_here"
```

**Langkah 5: Tambah Wajah Terpercaya (Opsional)**

Letakkan foto orang terpercaya di folder `trusted_faces/`. Sistem akan secara otomatis memprosesnya saat startup.

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 💻 PENGGUNAAN 💻

</div>

<br>

### Versi Desktop

**Memulai Sistem:**

```bash
python core_entry.py
```

### Versi Web

**Memulai Web Server:**

```bash
python web_server.py
```

**Mengakses Dashboard:**

Buka browser dan navigasi ke: `http://localhost:5000`

Untuk akses jarak jauh, ganti `localhost` dengan IP server Anda.

<div align="center">

<br>

<table>
<tr>
<th align="center" style="background: #000; color: #00ff00;">Desktop GUI Controls</th>
<th align="center" style="background: #000; color: #00ff00;">Web Dashboard Controls</th>
<th align="center" style="background: #000; color: #00ff00;">Telegram Commands</th>
</tr>
<tr>
<td valign="top">

| Kontrol | Aksi |
|:--------|:-----|
| `[ARM] SYSTEM` | Aktifkan pemantauan |
| `[REC]` | Mulai/berhenti perekaman |
| `[SNAP]` | Ambil snapshot |
| `[MUTE] ALARM` | Redam alarm |
| `[+] NEW` | Buat zona keamanan |
| `[*] DRAW` | Tambah titik zona |
| `[X] CLEAR` | Hapus zona |

</td>
<td valign="top">

| Kontrol | Aksi |
|:--------|:-----|
| `[ARM] SYSTEM` | Aktifkan pemantauan |
| `[REC]` | Mulai/berhenti perekaman |
| `[SNAP]` | Ambil snapshot |
| `[MUTE] ALARM` | Redam alarm |
| `[+] NEW ZONE` | Buat zona keamanan |
| `[X] CLEAR ALL` | Hapus semua zona |
| `Klik video` | Tambah titik zona |

**Keyboard Shortcuts:**
| Key | Aksi |
|:----|:-----|
| `A` | Toggle arm/disarm |
| `R` | Toggle perekaman |
| `S` | Ambil snapshot |
| `M` | Redam/Hidupkan |
| `N` | Zona baru |
| `C` | Hapus zona |
| `Esc` | Batal menggambar |

</td>
<td valign="top">

| Perintah | Deskripsi |
|:--------|:---------|
| `/arm` | Aktifkan sistem |
| `/disarm` | Nonaktifkan sistem |
| `/snap` | Minta snapshot |
| `/status` | Dapatkan status sistem |
| `/stats` | Lihat statistik harian |
| `/mute` | Redam alarm |
| `/unmute` | Hidupkan alarm |
| `/record` | Mulai perekaman |
| `/stoprecord` | Berhenti perekaman |
| `/sensitivity` | Sesuaikan sensitivitas |

</td>
</tr>
</table>

</div>

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📁 STRUKTUR FILE 📁

</div>

<br>

```
riftech-security-system/
├── core_entry.py          # Entry point versi desktop
├── web_server.py         # Entry point versi web 🆕
├── interface_display.py   # PyQt6 GUI (desktop only)
├── system_config.py      # Pengaturan konfigurasi
├── detection_engine.py   # YOLOv8, MediaPipe, face recognition
├── comms_telemetry.py   # Integrasi bot Telegram
├── alert_audio.py        # Sistem TTS dan alarm
├── data_storage.py       # Logging event SQLite
├── helper_utilities.py    # Utilitas manajemen zona
├── requirements.txt      # Dependensi Python
├── README.md           # Dokumentasi utama
├── README_WEB.md       # Panduan versi web 🆕
├── templates/           # Template HTML (versi web) 🆕
│   └── index.html     # Dashboard utama
├── static/             # File statis (versi web) 🆕
│   ├── style.css       # Tema cyber hacker
│   └── app.js         # Logika JavaScript
├── trusted_faces/      # Foto orang terpercaya
├── recordings/         # Perekaman video tersimpan
├── snapshots/          # Snapshot yang diambil
├── alerts/            # Foto bukti peringatan
└── audio/             # File suara alarm
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🔥 FITUR VERSI WEB 🔥

</div>

<br>

**Pemantauan Real-Time:**
- Streaming video langsung via MJPEG
- Hasil deteksi real-time overlay
- Penghitung FPS dan status sistem
- Indikator Arm/Disarm dengan peringatan visual

**Manajemen Zona Keamanan:**
- Zona poligonal klik-untuk-menggambar
- Dukungan banyak zona
- Visualisasi zona real-time
- Hapus zona dengan satu klik

**Kontrol Sistem:**
- Arm/Disarm sistem
- Mulai/Stop perekaman
- Ambil snapshot
- Redam/Hidupkan alarm
- Toggle fitur (Skeleton, Face, Motion)

**Tema Cyber Hacker:**
- Skema warna hijau neon (#00ff00)
- Background gelap dengan pola grid
- Efek glow dan animasi
- Font monospace Courier New
- Desain responsif untuk mobile

**Update WebSocket:**
- Perubahan status instan
- Update deteksi real-time
- Update zona langsung
- Sinkronisasi status sistem

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🌐 PILIHAN DEPLOYMENT 🌐

</div>

<br>

### Local Desktop
```bash
python core_entry.py
```

### Local Web Server
```bash
python web_server.py
# Akses di http://localhost:5000
```

### Ubuntu Server (Headless)
```bash
# Install Python dependencies
sudo apt update
sudo apt install python3-pip

# Install system packages
sudo apt install python3-opencv

# Run web server
python web_server.py
```

### Cloud Deployment
- Deploy ke VPS (AWS, DigitalOcean, Linode)
- Gunakan systemd untuk auto-restart
- Konfigurasi firewall untuk port 5000
- Akses via domain atau IP publik

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## ⚙️ TUNING KINERJA ⚙️

</div>

<br>

### Kurangi Penggunaan CPU

Edit `system_config.py`:

```python
FRAME_WIDTH = 640   # Default 1280
FRAME_HEIGHT = 480  # Default 720
DETECTION_INTERVAL = 5  # Cek setiap 5 frame bukan setiap frame
```

### Kurangi Penggunaan Memori

```python
# Nonaktifkan face recognition jika tidak diperlukan
FACE_RECOGNITION_ENABLED = False

# Gunakan model YOLO yang lebih kecil
YOLO_MODEL = 'yolov8n.pt'  # Model terkecil
```

### Optimasi Streaming Video

```python
# Di web_server.py generate_video()
ret, jpeg = cv2.imencode('.jpg', display_frame, 
                        [cv2.IMWRITE_JPEG_QUALITY, 75])  # Kualitas lebih rendah
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 🛠️ TROUBLESHOOTING 🛠️

</div>

<br>

### Kamera Tidak Dapat Diakses

```bash
# Cek permission kamera
ls -l /dev/video0

# Tambah user ke video group
sudo usermod -a -G video $USER
# Logout dan login lagi
```

### Port Sudah Digunakan

```bash
# Kill process pada port 5000
sudo lsof -ti:5000 | xargs kill -9
```

### Model Tidak Dimuat

```bash
# Cek model YOLO
ls *.pt

# Download manual jika diperlukan
python -c "from detection_engine import download_manager; download_manager.download_yolo('yolov8n.pt')"
```

<br>

<hr style="border: 2px solid #00ff00; box-shadow: 0 0 10px #00ff00;">

<br>

<div align="center">

## 📄 LISENSI 📄

</div>

<br>

RIFTECH SECURITY SYSTEM - Solusi Pemantauan AI-Powered

Copyright 2025 RIFTECH

<br><br>

<div align="center">

---

**⚡ Dibuat dengan ❤️ oleh RIFTECH ⚡**

---

</div>

</div>
