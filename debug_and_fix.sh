#!/bin/bash
# ============================================
# RIFTECH SECURITY SYSTEM - DEBUG AND FIX SCRIPT
# ============================================

COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR_GREEN}║     RIFTECH SECURITY - DEBUG AND FIX SCRIPT               ║${NC}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check current directory
echo -e "${COLOR_YELLOW}[1/10] Checking current directory...${NC}"
pwd
cd /opt/riftech-security
echo -e "${COLOR_GREEN}✓ In correct directory${NC}"
echo ""

# Check Python version
echo -e "${COLOR_YELLOW}[2/10] Checking Python version...${NC}"
python3 --version
echo -e "${COLOR_GREEN}✓ Python OK${NC}"
echo ""

# Check virtual environment
echo -e "${COLOR_YELLOW}[3/10] Checking virtual environment...${NC}"
if [ -d "venv" ]; then
    echo -e "${COLOR_GREEN}✓ Virtual environment exists${NC}"
    source venv/bin/activate
else
    echo -e "${COLOR_RED}✗ Virtual environment not found${NC}"
    echo -e "${COLOR_YELLOW}Creating virtual environment...${NC}"
    python3 -m venv venv
    source venv/bin/activate
    echo -e "${COLOR_GREEN}✓ Virtual environment created${NC}"
fi
echo ""

# Check key Python packages
echo -e "${COLOR_YELLOW}[4/10] Checking Python packages...${NC}"
pip list | grep -E "flask|flask-socketio|opencv|numpy"
echo ""

# Install/upgrade dependencies
echo -e "${COLOR_YELLOW}[5/10] Installing/Upgrading dependencies...${NC}"
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo -e "${COLOR_GREEN}✓ Dependencies installed${NC}"
echo ""

# Check directories
echo -e "${COLOR_YELLOW}[6/10] Checking directories...${NC}"
for dir in trusted_faces recordings snapshots alerts audio logs; do
    if [ -d "$dir" ]; then
        echo -e "${COLOR_GREEN}✓ $dir exists${NC}"
    else
        echo -e "${COLOR_YELLOW}Creating $dir...${NC}"
        mkdir -p "$dir"
        echo -e "${COLOR_GREEN}✓ $dir created${NC}"
    fi
done
echo ""

# Check files
echo -e "${COLOR_YELLOW}[7/10] Checking key files...${NC}"
for file in web_server.py system_config.py data_storage.py detection_engine.py; do
    if [ -f "$file" ]; then
        echo -e "${COLOR_GREEN}✓ $file exists${NC}"
    else
        echo -e "${COLOR_RED}✗ $file missing${NC}"
    fi
done
echo ""

# Test Python imports
echo -e "${COLOR_YELLOW}[8/10] Testing Python imports...${NC}"
python3 << 'EOF'
import sys
try:
    import flask
    print(f"✓ Flask: {flask.__version__}")
except Exception as e:
    print(f"✗ Flask error: {e}")

try:
    from flask_socketio import SocketIO
    print("✓ Flask-SocketIO: OK")
except Exception as e:
    print(f"✗ SocketIO error: {e}")

try:
    import cv2
    print(f"✓ OpenCV: {cv2.__version__}")
except Exception as e:
    print(f"✗ OpenCV error: {e}")

try:
    import numpy as np
    print(f"✓ NumPy: {np.__version__}")
except Exception as e:
    print(f"✗ NumPy error: {e}")

try:
    from system_config import Config
    config = Config()
    print(f"✓ System config OK")
except Exception as e:
    print(f"✗ Config error: {e}")

try:
    from data_storage import DatabaseManager
    print(f"✓ Database module OK")
except Exception as e:
    print(f"✗ Database error: {e}")
EOF
echo ""

# Test web server startup
echo -e "${COLOR_YELLOW}[9/10] Testing web server startup...${NC}"
timeout 5 python3 web_server.py > /tmp/web_test.log 2>&1 &
sleep 3
if grep -q "RIFTECH SECURITY WEB SERVER STARTED" /tmp/web_test.log; then
    echo -e "${COLOR_GREEN}✓ Web server started successfully${NC}"
    pkill -f "python3 web_server.py"
else
    echo -e "${COLOR_RED}✗ Web server startup failed${NC}"
    echo -e "${COLOR_YELLOW}Error output:${NC}"
    cat /tmp/web_test.log
fi
echo ""

# Check service
echo -e "${COLOR_YELLOW}[10/10] Checking systemd service...${NC}"
systemctl status riftech-security --no-pager | head -10
echo ""

# Summary
echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR_GREEN}║                    DEBUG COMPLETE                             ║${NC}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${COLOR_YELLOW}Next steps:${NC}"
echo -e "1. Restart service: ${COLOR_CYAN}sudo systemctl restart riftech-security${NC}"
echo -e "2. Check status: ${COLOR_CYAN}sudo systemctl status riftech-security${NC}"
echo -e "3. Check logs: ${COLOR_CYAN}sudo journalctl -u riftech-security -f${NC}"
echo -e "4. Access dashboard: ${COLOR_CYAN}http://$(hostname -I | awk '{print $1}'):5000${NC}"
echo ""
