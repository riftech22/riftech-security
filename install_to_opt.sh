#!/bin/bash
# ============================================
# RIFTECH SECURITY SYSTEM - INSTALLATION SCRIPT
# Install to /opt/riftech-security
# ============================================

set -e  # Exit on error

COLOR_GREEN='\033[0;32m'
COLOR_CYAN='\033[0;36m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
NC='\033[0m' # No Color

INSTALL_DIR="/opt/riftech-security"
SERVICE_NAME="riftech-security"

echo -e "${COLOR_CYAN}========================================${NC}"
echo -e "${COLOR_GREEN}RIFTECH SECURITY SYSTEM INSTALLER${NC}"
echo -e "${COLOR_CYAN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${COLOR_RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Check if directory exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${COLOR_YELLOW}Directory $INSTALL_DIR already exists${NC}"
    read -p "Continue and overwrite? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

# Create installation directory
echo -e "${COLOR_YELLOW}[1/7] Creating installation directory...${NC}"
mkdir -p "$INSTALL_DIR"
echo -e "${COLOR_GREEN}✓ Created $INSTALL_DIR${NC}"

# Copy project files
echo -e "${COLOR_YELLOW}[2/7] Copying project files...${NC}"
cp -r * "$INSTALL_DIR/"
cp -r .* "$INSTALL_DIR/" 2>/dev/null || true
echo -e "${COLOR_GREEN}✓ Files copied${NC}"

# Set permissions
echo -e "${COLOR_YELLOW}[3/7] Setting permissions...${NC}"
chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
echo -e "${COLOR_GREEN}✓ Permissions set${NC}"

# Create required directories
echo -e "${COLOR_YELLOW}[4/7] Creating required directories...${NC}"
mkdir -p "$INSTALL_DIR"/{trusted_faces,recordings,snapshots,alerts,audio,logs}
echo -e "${COLOR_GREEN}✓ Directories created${NC}"

# Create virtual environment
echo -e "${COLOR_YELLOW}[5/7] Creating virtual environment...${NC}"
cd "$INSTALL_DIR"
python3 -m venv venv
echo -e "${COLOR_GREEN}✓ Virtual environment created${NC}"

# Install dependencies
echo -e "${COLOR_YELLOW}[6/7] Installing Python dependencies...${NC}"
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo -e "${COLOR_GREEN}✓ Dependencies installed${NC}"

# Create systemd service
echo -e "${COLOR_YELLOW}[7/7] Creating systemd service...${NC}"
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
echo -e "${COLOR_GREEN}✓ Service created${NC}"

# Enable service
echo -e "${COLOR_YELLOW}Enabling service...${NC}"
systemctl enable $SERVICE_NAME
echo -e "${COLOR_GREEN}✓ Service enabled${NC}"

echo ""
echo -e "${COLOR_CYAN}========================================${NC}"
echo -e "${COLOR_GREEN}INSTALLATION COMPLETED SUCCESSFULLY!${NC}"
echo -e "${COLOR_CYAN}========================================${NC}"
echo ""
echo -e "Installation directory: ${COLOR_GREEN}$INSTALL_DIR${NC}"
echo -e "Service name: ${COLOR_GREEN}$SERVICE_NAME${NC}"
echo ""
echo -e "To start the service:"
echo -e "  ${COLOR_CYAN}sudo systemctl start $SERVICE_NAME${NC}"
echo ""
echo -e "To check status:"
echo -e "  ${COLOR_CYAN}sudo systemctl status $SERVICE_NAME${NC}"
echo ""
echo -e "To view logs:"
echo -e "  ${COLOR_CYAN}sudo journalctl -u $SERVICE_NAME -f${NC}"
echo ""
echo -e "Access the dashboard:"
echo -e "  ${COLOR_CYAN}http://localhost:5000${NC}"
echo ""
echo -e "Default login:"
echo -e "  Username: ${COLOR_GREEN}admin${NC}"
echo -e "  Password: ${COLOR_GREEN}riftech2025${NC}"
echo ""
echo -e "To edit configuration:"
echo -e "  ${COLOR_CYAN}$INSTALL_DIR/system_config.py${NC} (Telegram settings)"
echo -e "  ${COLOR_CYAN}$INSTALL_DIR/web_server.py${NC} (Login credentials)"
echo ""
