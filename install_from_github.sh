#!/bin/bash
# ============================================
# RIFTECH SECURITY SYSTEM - GITHUB INSTALLER
# Download from GitHub and install to /opt
# Cara mudah instalasi: 1 command, 2 menit, jalan!
# ============================================

set -e  # Exit on error

COLOR_GREEN='\033[0;32m'
COLOR_CYAN='\033[0;36m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
NC='\033[0m' # No Color

REPO_URL="https://github.com/riftech22/riftech-security.git"
INSTALL_DIR="/opt/riftech-security"
SERVICE_NAME="riftech-security"

echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR_GREEN}║     RIFTECH SECURITY SYSTEM - GITHUB INSTALLER v1.0         ║${NC}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${COLOR_YELLOW}📦 Installasi Otomatis dari GitHub ke /opt/riftech-security${NC}"
echo -e "${COLOR_YELLOW}⏱️  Waktu: Sekitar 2-5 menit (tergantung internet)${NC}"
echo ""

# Cek apakah running sebagai root
if [ "$EUID" -ne 0 ]; then
    echo -e "${COLOR_RED}❌ Error: Script ini harus dijalankan sebagai root${NC}"
    echo -e "${COLOR_YELLOW}Gunakan: sudo bash install_from_github.sh${NC}"
    exit 1
fi

# Cek apakah git terinstall
if ! command -v git &> /dev/null; then
    echo -e "${COLOR_YELLOW}[1/9] Git tidak ditemukan. Menginstall git...${NC}"
    apt update && apt install -y git
    echo -e "${COLOR_GREEN}✓ Git terinstall${NC}"
else
    echo -e "${COLOR_YELLOW}[1/9] Git sudah terinstall ✓${NC}"
fi

# Cek apakah directory sudah ada
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${COLOR_YELLOW}[2/9] Directory $INSTALL_DIR sudah ada${NC}"
    echo -e "${COLOR_RED}⚠️  PERINGATAN: Ini akan menghapus instalasi yang ada!${NC}"
    read -p "Lanjutkan dan install ulang? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Instalasi dibatalkan"
        exit 0
    fi
    echo -e "${COLOR_YELLOW}Menghapus instalasi lama...${NC}"
    systemctl stop $SERVICE_NAME 2>/dev/null || true
    systemctl disable $SERVICE_NAME 2>/dev/null || true
    rm -rf "$INSTALL_DIR"
    echo -e "${COLOR_GREEN}✓ Instalasi lama dihapus${NC}"
else
    echo -e "${COLOR_YELLOW}[2/9] Directory $INSTALL_DIR kosong ✓${NC}"
fi

# Clone dari GitHub
echo -e "${COLOR_YELLOW}[3/9] Mendownload dari GitHub...${NC}"
echo -e "${COLOR_CYAN}Repository: $REPO_URL${NC}"
cd /tmp
rm -rf "$REPO_NAME"
git clone "$REPO_URL" "$REPO_NAME"
echo -e "${COLOR_GREEN}✓ Repository berhasil didownload${NC}"

# Copy file-file project
echo -e "${COLOR_YELLOW}[4/9] Menyalin file-file ke /opt...${NC}"
mkdir -p "$INSTALL_DIR"
cp -r "$REPO_NAME"/* "$INSTALL_DIR/"
cp -r "$REPO_NAME"/.* "$INSTALL_DIR/" 2>/dev/null || true
rm -rf "$REPO_NAME"
echo -e "${COLOR_GREEN}✓ File-file berhasil disalin${NC}"

# Set permission
echo -e "${COLOR_YELLOW}[5/9] Mengatur permissions...${NC}"
chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
echo -e "${COLOR_GREEN}✓ Permissions diatur${NC}"

# Buat directory yang diperlukan
echo -e "${COLOR_YELLOW}[6/9] Membuat directory yang diperlukan...${NC}"
mkdir -p "$INSTALL_DIR"/{trusted_faces,recordings,snapshots,alerts,audio,logs}
echo -e "${COLOR_GREEN}✓ Directory dibuat${NC}"

# Buat virtual environment
echo -e "${COLOR_YELLOW}[7/9] Membuat virtual environment Python...${NC}"
cd "$INSTALL_DIR"
python3 -m venv venv
echo -e "${COLOR_GREEN}✓ Virtual environment dibuat${NC}"

# Install dependencies
echo -e "${COLOR_YELLOW}[8/9] Menginstall Python dependencies...${NC}"
echo -e "${COLOR_CYAN}Ini mungkin memakan waktu 2-3 menit...${NC}"
source venv/bin/activate
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo -e "${COLOR_GREEN}✓ Dependencies terinstall${NC}"

# Buat systemd service
echo -e "${COLOR_YELLOW}[9/9] Membuat dan memulai systemd service...${NC}"
cat > /etc/systemd/system/$SERVICE_NAME.service << EOF
[Unit]
Description=RIFTECH Security System Web Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
Environment="PATH=$INSTALL_DIR/venv/bin"
ExecStart=$INSTALL_DIR/venv/bin/python web_server.py
Restart=always
RestartSec=10
StandardOutput=append:$INSTALL_DIR/logs/systemd.log
StandardError=append:$INSTALL_DIR/logs/systemd-error.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
echo -e "${COLOR_GREEN}✓ Systemd service dibuat${NC}"

# Enable dan start service
echo -e "${COLOR_YELLOW}Enabling service (auto-start pada boot)...${NC}"
systemctl enable $SERVICE_NAME
echo -e "${COLOR_GREEN}✓ Service di-enable${NC}"

echo -e "${COLOR_YELLOW}Memulai service...${NC}"
systemctl start $SERVICE_NAME
sleep 3

# Cek status service
echo ""
if systemctl is-active --quiet $SERVICE_NAME; then
    echo -e "${COLOR_GREEN}✅ Service berhasil dimulai!${NC}"
else
    echo -e "${COLOR_RED}❌ Service gagal dimulai!${NC}"
    echo -e "${COLOR_YELLOW}Cek logs untuk error: sudo journalctl -u $SERVICE_NAME -f${NC}"
    exit 1
fi

# Tampilkan hasil
echo ""
echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR_GREEN}║              ✅ INSTALASI BERHASIL! ✅                         ║${NC}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${COLOR_YELLOW}📁 Informasi Instalasi:${NC}"
echo -e "   Repository: ${COLOR_GREEN}$REPO_URL${NC}"
echo -e "   Directory: ${COLOR_GREEN}$INSTALL_DIR${NC}"
echo -e "   Service:   ${COLOR_GREEN}$SERVICE_NAME${NC}"
echo ""
echo -e "${COLOR_YELLOW}📊 Status Service:${NC}"
systemctl status $SERVICE_NAME --no-pager | head -12
echo ""
echo -e "${COLOR_YELLOW}🌐 Akses Dashboard:${NC}"
echo -e "   Localhost:  ${COLOR_CYAN}http://localhost:5000${NC}"
echo -e "   IP Server:  ${COLOR_CYAN}http://$(hostname -I | awk '{print $1}'):5000${NC}"
echo ""
echo -e "${COLOR_YELLOW}🔐 Default Login:${NC}"
echo -e "   Username: ${COLOR_GREEN}admin${NC}"
echo -e "   Password: ${COLOR_GREEN}riftech2025${NC}"
echo ""
echo -e "${COLOR_YELLOW}🎮 Perintah Management Service:${NC}"
echo -e "   Start:     ${COLOR_CYAN}sudo systemctl start $SERVICE_NAME${NC}"
echo -e "   Stop:      ${COLOR_CYAN}sudo systemctl stop $SERVICE_NAME${NC}"
echo -e "   Restart:   ${COLOR_CYAN}sudo systemctl restart $SERVICE_NAME${NC}"
echo -e "   Status:    ${COLOR_CYAN}sudo systemctl status $SERVICE_NAME${NC}"
echo -e "   Logs:      ${COLOR_CYAN}sudo journalctl -u $SERVICE_NAME -f${NC}"
echo ""
echo -e "${COLOR_YELLOW}⚙️  Konfigurasi:${NC}"
echo -e "   Telegram settings: ${COLOR_CYAN}$INSTALL_DIR/system_config.py${NC}"
echo -e "   Login credentials: ${COLOR_CYAN}$INSTALL_DIR/web_server.py${NC}"
echo ""
echo -e "${COLOR_YELLOW}🗑️  Uninstall:${NC}"
echo -e "   ${COLOR_CYAN}sudo bash $INSTALL_DIR/uninstall_from_opt.sh${NC}"
echo ""
echo -e "${COLOR_GREEN}🎉 Selamat! RIFTECH Security System sudah jalan!${NC}"
echo -e "${COLOR_GREEN}🎉 Buka browser dan login untuk memulai pemantauan!${NC}"
echo ""
