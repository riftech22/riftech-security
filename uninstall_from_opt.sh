#!/bin/bash
# ============================================
# RIFTECH SECURITY SYSTEM - UNINSTALL SCRIPT
# Remove from /opt/riftech-security
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
echo -e "${COLOR_RED}RIFTECH SECURITY SYSTEM UNINSTALLER${NC}"
echo -e "${COLOR_CYAN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${COLOR_RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Check if directory exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${COLOR_RED}Error: Installation directory not found at $INSTALL_DIR${NC}"
    exit 1
fi

# Warning
echo -e "${COLOR_YELLOW}WARNING: This will completely remove RIFTECH Security System including:${NC}"
echo -e "  - Installation directory: $INSTALL_DIR"
echo -e "  - Systemd service: $SERVICE_NAME"
echo -e "  - All data (recordings, snapshots, alerts, logs)"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Uninstall cancelled"
    exit 0
fi

# Stop service
echo -e "${COLOR_YELLOW}[1/4] Stopping service...${NC}"
if systemctl is-active --quiet $SERVICE_NAME; then
    systemctl stop $SERVICE_NAME
    echo -e "${COLOR_GREEN}✓ Service stopped${NC}"
else
    echo -e "${COLOR_YELLOW}Service not running${NC}"
fi

# Disable service
echo -e "${COLOR_YELLOW}[2/4] Disabling service...${NC}"
if systemctl is-enabled --quiet $SERVICE_NAME; then
    systemctl disable $SERVICE_NAME
    echo -e "${COLOR_GREEN}✓ Service disabled${NC}"
else
    echo -e "${COLOR_YELLOW}Service not enabled${NC}"
fi

# Remove service file
echo -e "${COLOR_YELLOW}[3/4] Removing systemd service...${NC}"
rm -f /etc/systemd/system/$SERVICE_NAME.service
systemctl daemon-reload
echo -e "${COLOR_GREEN}✓ Service removed${NC}"

# Remove installation directory
echo -e "${COLOR_YELLOW}[4/4] Removing installation directory...${NC}"
rm -rf "$INSTALL_DIR"
echo -e "${COLOR_GREEN}✓ Installation directory removed${NC}"

echo ""
echo -e "${COLOR_CYAN}========================================${NC}"
echo -e "${COLOR_GREEN}UNINSTALLATION COMPLETED${NC}"
echo -e "${COLOR_CYAN}========================================${NC}"
echo ""
echo -e "RIFTECH Security System has been successfully removed."
echo -e "To reinstall, run: ${COLOR_CYAN}sudo bash install_to_opt.sh${NC}"
echo ""
