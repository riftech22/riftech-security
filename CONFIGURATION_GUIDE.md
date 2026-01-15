# RIFTECH SECURITY SYSTEM - KONFIGURASI KAMERA & TELEGRAM

## 📋 DAFTAR ISI

1. [Konfigurasi Kamera](#konfigurasi-kamera)
2. [Konfigurasi Kamera V380](#konfigurasi-kamera-v380)
3. [Konfigurasi Telegram Bot](#konfigurasi-telegram-bot)
4. [Langkah-langkah Konfigurasi](#langkah-langkah-konfigurasi)
5. [Troubleshooting](#troubleshooting)

---

## 🎥 KONFIGURASI KAMERA

### Jenis Kamera yang Didukung:

1. **USB Camera** - Kamera USB yang terhubung langsung ke server
2. **RTSP Camera** - Kamera IP dengan protokol RTSP (termasuk V380)
3. **HTTP Camera** - Kamera dengan stream HTTP
4. **Simulation Mode** - Mode tanpa kamera (untuk testing)

---

## 📹 KONFIGURASI KAMERA V380

### Cara 1: Menggunakan RTSP Stream (RECOMMENDED)

#### Step 1: Cari IP Address Kamera V380

1. Buka aplikasi V380 di HP
2. Settings → Network Info
3. Catat IP Address kamera (contoh: `192.168.1.100`)

#### Step 2: Cari Username & Password Kamera

1. Buka aplikasi V380
2. Settings → Device Settings
3. Catat username & password (default biasanya: `admin` / kosong)

#### Step 3: Cari RTSP Stream URL

**Format RTSP V380:**
```
rtsp://username:password@camera_ip:554/stream1
```

**Contoh:**
```
rtsp://admin:123456@192.168.1.100:554/stream1
```

**RTSP Stream yang umum untuk V380:**
- `/stream1` - Stream kualitas standar
- `/stream2` - Stream kualitas rendah
- `/live` - Live stream
- `/main` - Stream utama
- `/sub` - Stream sekunder

#### Step 4: Edit Konfigurasi

Buka file `system_config.py`:

```bash
cd /opt/riftech-security
nano system_config.py
```

Cari bagian ini:

```python
# ========================================
# CAMERA CONFIGURATION
# ========================================
# Camera Type: 'usb', 'rtsp', 'http', 'simulation'
CAMERA_TYPE = 'simulation'  # ← Ganti jadi 'rtsp'

# USB Camera Configuration
CAMERA_ID = 0

# RTSP Camera Configuration (IP Camera like V380)
# Format: rtsp://username:password@camera_ip:554/stream_path
# V380 Example: rtsp://admin:password123@192.168.1.100:554/stream1
RTSP_URL = "rtsp://username:password@camera-ip:554/stream1"  # ← Ganti dengan URL RTSP Anda

# Atau gunakan konfigurasi individual:
RTSP_USERNAME = "admin"        # ← Username kamera
RTSP_PASSWORD = ""             # ← Password kamera
RTSP_IP = "192.168.1.100"     # ← IP kamera
RTSP_PORT = 554                # ← Port RTSP (default 554)
RTSP_STREAM = "stream1"        # ← Stream path
```

**Contoh Konfigurasi V380:**

```python
CAMERA_TYPE = 'rtsp'

RTSP_USERNAME = "admin"
RTSP_PASSWORD = "123456"
RTSP_IP = "192.168.1.100"
RTSP_PORT = 554
RTSP_STREAM = "stream1"

# Atau gunakan URL langsung:
RTSP_URL = "rtsp://admin:123456@192.168.1.100:554/stream1"
```

#### Step 5: Restart Service

```bash
sudo systemctl restart riftech-security
sudo systemctl status riftech-security
```

#### Step 6: Cek Logs

```bash
sudo journalctl -u riftech-security -n 50 --no-pager
```

**Expected Output:**
```
[Camera] Using RTSP camera: rtsp://admin:123456@192.168.1.100:554/stream1
[Camera] Successfully connected to RTSP camera
[Camera] Started - Physical camera 0
```

---

### Cara 2: Menggunakan HTTP Stream

Beberapa kamera V380 juga support HTTP stream:

```python
CAMERA_TYPE = 'http'

HTTP_URL = "http://192.168.1.100:80/videostream.cgi"
```

---

### Cara 3: Menggunakan V380 Cloud

Jika kamera V380 Anda terhubung ke cloud:

1. Buka aplikasi V380 di HP
2. Settings → Share → Copy Cloud URL
3. Gunakan URL tersebut di konfigurasi

---

## 🤖 KONFIGURASI TELEGRAM BOT

### Step 1: Buat Telegram Bot

1. Buka Telegram
2. Cari **@BotFather**
3. Kirim perintah: `/newbot`
4. Beri nama bot (contoh: `RifTech Security Bot`)
5. Beri username (contoh: `RifTechSecBot`)
6. **Copy Bot Token** yang diberikan (format: `1234567890:ABC...`)

### Step 2: Dapatkan Chat ID

**Metode 1: Menggunakan @userinfobot**

1. Buka Telegram
2. Cari **@userinfobot**
3. Klik tombol **Start**
4. Bot akan mengirimkan Chat ID Anda (contoh: `7456977789`)

**Metode 2: Manual via API**

```bash
# Ganti dengan Bot Token Anda
BOT_TOKEN="1234567890:ABC..."

# Kirim pesan ke bot Anda di Telegram (apa saja)
curl "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates"
```

Cari `"chat":{"id":7456977789` di output.

### Step 3: Edit Konfigurasi Telegram

Buka file `system_config.py`:

```python
# ========================================
# TELEGRAM BOT CONFIGURATION
# ========================================
TELEGRAM_BOT_TOKEN = "1234567890:ABCDEF..."  # ← Ganti dengan Bot Token Anda
TELEGRAM_CHAT_ID = "7456977789"               # ← Ganti dengan Chat ID Anda
TELEGRAM_ENABLED = True  # ← True untuk enable, False untuk disable
```

### Step 4: Test Telegram Bot

**Test Kirim Pesan:**

```bash
cd /opt/riftech-security
source venv/bin/activate
python3 << 'EOF'
from system_config import Config
from comms_telemetry import TelegramBot

config = Config()
telegram = TelegramBot(config)

# Test kirim pesan
telegram.send_message("🔔 Test dari RIFTECH Security System\n\nSystem aktif dan siap digunakan!")
print("Pesan dikirim!")
EOF
```

**Cek Telegram Anda - harus menerima pesan!**

---

## 📝 LANGKAH-LANGKAH KONFIGURASI

### Langkah 1: Backup Konfigurasi

```bash
cd /opt/riftech-security
cp system_config.py system_config.py.backup
```

### Langkah 2: Edit Konfigurasi

```bash
nano system_config.py
```

### Langkah 3: Ganti Konfigurasi Kamera

**Untuk V380 RTSP:**

```python
CAMERA_TYPE = 'rtsp'

RTSP_USERNAME = "admin"
RTSP_PASSWORD = "password_anda"
RTSP_IP = "192.168.1.100"
RTSP_PORT = 554
RTSP_STREAM = "stream1"
```

**Atau gunakan URL langsung:**

```python
CAMERA_TYPE = 'rtsp'
RTSP_URL = "rtsp://admin:password_anda@192.168.1.100:554/stream1"
```

### Langkah 4: Ganti Konfigurasi Telegram

```python
TELEGRAM_BOT_TOKEN = "1234567890:ABCDEF..."
TELEGRAM_CHAT_ID = "7456977789"
TELEGRAM_ENABLED = True
```

### Langkah 5: Simpan dan Keluar

- Tekan `Ctrl + O` lalu `Enter` untuk simpan
- Tekan `Ctrl + X` untuk keluar

### Langkah 6: Restart Service

```bash
sudo systemctl restart riftech-security
sudo systemctl status riftech-security
```

### Langkah 7: Cek Logs

```bash
sudo journalctl -u riftech-security -f
```

**Expected Output:**
```
[Camera] Using RTSP camera: rtsp://admin:password@192.168.1.100:554/stream1
[Camera] Successfully connected to RTSP camera
[Camera] Started - Physical camera 0
```

### Langkah 8: Test di Browser

1. Buka: `http://10.26.27.109:5000`
2. Login dengan `admin` / `riftech2025`
3. **Camera feed harus menampilkan video dari kamera V380!**

### Langkah 9: Test Telegram

**ARM System:**
1. Klik **[ARM] SYSTEM** di dashboard
2. Cek Telegram - harus menerima notifikasi

**Buat Zone dan Test Breach:**
1. Centang **DRAW MODE**
2. Gambar zone di video feed
3. Berjalan/gerak di depan kamera
4. Cek Telegram - harus menerima alert!

---

## 🔧 TROUBLESHOOTING

### Problem 1: RTSP Camera Tidak Terhubung

**Error:**
```
[Camera] Failed to connect to RTSP camera
```

**Solusi:**

1. **Cek koneksi:**
```bash
ping 192.168.1.100
```

2. **Cek port RTSP:**
```bash
telnet 192.168.1.100 554
```

3. **Coba stream path berbeda:**
```python
RTSP_STREAM = "stream1"  # Coba stream2, live, main, sub
```

4. **Cek username/password:**
```bash
# Test dengan VLC atau ffplay
ffplay rtsp://admin:password@192.168.1.100:554/stream1
```

### Problem 2: Camera Feed Lambat / Latency Tinggi

**Solusi:**

```python
# Di system_config.py
FRAME_WIDTH = 640   # ← Turunkan resolusi
FRAME_HEIGHT = 480
TARGET_FPS = 15      # ← Turunkan FPS
```

Atau gunakan stream kualitas rendah:
```python
RTSP_STREAM = "stream2"  # Stream kualitas rendah
```

### Problem 3: Telegram Bot Tidak Mengirim Pesan

**Error:**
```
[Telegram] Failed to send message
```

**Solusi:**

1. **Cek Bot Token:**
```bash
curl "https://api.telegram.org/botYOUR_BOT_TOKEN/getMe"
```

2. **Cek Chat ID:**
```bash
curl "https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates"
```

3. **Start bot:**
```bash
# Kirim /start ke bot di Telegram
```

4. **Cek TELEGRAM_ENABLED:**
```python
TELEGRAM_ENABLED = True  # ← Pastikan True
```

### Problem 4: Camera Feed Blank

**Solusi:**

1. **Test kamera dengan VLC:**
   - Buka VLC
   - Media → Open Network Stream
   - Masukkan RTSP URL
   - Jika berhasil, masalah di code
   - Jika gagal, masalah di kamera

2. **Cek logs:**
```bash
sudo journalctl -u riftech-security -n 100 --no-pager | grep -i camera
```

3. **Coba USB camera:**
```python
CAMERA_TYPE = 'usb'
CAMERA_ID = 0
```

---

## 📊 CONTOH KONFIGURASI LENGKAP

### Contoh 1: V380 Camera + Telegram

```python
# Camera Configuration
CAMERA_TYPE = 'rtsp'

RTSP_USERNAME = "admin"
RTSP_PASSWORD = "123456"
RTSP_IP = "192.168.1.100"
RTSP_PORT = 554
RTSP_STREAM = "stream1"

# Telegram Configuration
TELEGRAM_BOT_TOKEN = "1234567890:ABCDEF..."
TELEGRAM_CHAT_ID = "7456977789"
TELEGRAM_ENABLED = True
```

### Contoh 2: USB Camera + Telegram

```python
# Camera Configuration
CAMERA_TYPE = 'usb'
CAMERA_ID = 0

# Telegram Configuration
TELEGRAM_BOT_TOKEN = "1234567890:ABCDEF..."
TELEGRAM_CHAT_ID = "7456977789"
TELEGRAM_ENABLED = True
```

### Contoh 3: Simulation Mode (Tanpa Kamera)

```python
# Camera Configuration
CAMERA_TYPE = 'simulation'

# Telegram Configuration
TELEGRAM_BOT_TOKEN = "1234567890:ABCDEF..."
TELEGRAM_CHAT_ID = "7456977789"
TELEGRAM_ENABLED = True
```

---

## 🎯 CHECKLIST FINAL

### Konfigurasi Kamera:
- [ ] Tentukan jenis kamera (USB/RTSP/HTTP/Simulation)
- [ ] Untuk V380: Dapatkan IP, username, password
- [ ] Edit `CAMERA_TYPE` di `system_config.py`
- [ ] Edit konfigurasi RTSP/USB/HTTP
- [ ] Test koneksi kamera dengan VLC/ffplay
- [ ] Restart service
- [ ] Cek logs untuk verifikasi
- [ ] Test di browser - camera feed muncul

### Konfigurasi Telegram:
- [ ] Buat Telegram bot via @BotFather
- [ ] Dapatkan Bot Token
- [ ] Dapatkan Chat ID via @userinfobot
- [ ] Edit `TELEGRAM_BOT_TOKEN` di `system_config.py`
- [ ] Edit `TELEGRAM_CHAT_ID` di `system_config.py`
- [ ] Pastikan `TELEGRAM_ENABLED = True`
- [ ] Test kirim pesan
- [ ] Test notifikasi ARM/DISARM
- [ ] Test notifikasi breach alert

---

## 📞 BANTUAN

### Dokumentasi Tambahan:
- **README.md** - Dokumentasi utama sistem
- **README_WEB.md** - Dokumentasi web dashboard
- **INSTALLATION_UBUNTU.md** - Panduan instalasi

### Command Penting:
```bash
# Cek logs
sudo journalctl -u riftech-security -f

# Restart service
sudo systemctl restart riftech-security

# Cek status
sudo systemctl status riftech-security

# Edit konfigurasi
nano /opt/riftech-security/system_config.py

# Backup konfigurasi
cp /opt/riftech-security/system_config.py /opt/riftech-security/system_config.py.backup
```

---

## ✅ SELAMAT MENGGUNAKAN RIFTECH SECURITY SYSTEM!

Setelah konfigurasi selesai:
- ✅ Camera feed akan menampilkan video real-time
- ✅ System dapat mendeteksi person dan motion
- ✅ Telegram akan mengirim notifikasi
- ✅ Alert dan recording akan berfungsi

**Siap digunakan! 🚀**
