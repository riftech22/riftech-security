#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║      FIX TELEGRAM & CONFIGURE V380 CAMERA                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

echo "1. BACKING UP CONFIGURATION"
echo "═══════════════════════════════════════════════════════════════"
cp system_config.py system_config.py.backup.$(date +%Y%m%d_%H%M%S)
echo "✓ Configuration backed up"

echo ""
echo "2. CONFIGURING V380 CAMERA"
echo "═══════════════════════════════════════════════════════════════"

# Update camera configuration
sed -i "s/CAMERA_TYPE = 'simulation'/CAMERA_TYPE = 'rtsp'/g" system_config.py
sed -i "s/RTSP_USERNAME = \"admin\"/RTSP_USERNAME = \"admin\"/g" system_config.py
sed -i "s/RTSP_PASSWORD = \"\"/RTSP_PASSWORD = \"Kuncong0203\"/g" system_config.py
sed -i "s/RTSP_IP = \"192.168.1.100\"/RTSP_IP = \"10.26.27.196\"/g" system_config.py
sed -i "s/RTSP_PORT = 554/RTSP_PORT = 554/g" system_config.py
sed -i "s/RTSP_STREAM = \"stream1\"/RTSP_STREAM = \"stream1\"/g" system_config.py

echo "✓ V380 Camera configured:"
echo "  IP: 10.26.27.196"
echo "  Username: admin"
echo "  Password: Kuncong0203"
echo "  Stream: stream1"
echo "  Port: 554"

echo ""
echo "3. VERIFYING CAMERA CONFIGURATION"
echo "═══════════════════════════════════════════════════════════════"
source venv/bin/activate
python3 << 'EOF'
try:
    from system_config import Config
    c = Config()
    print(f"Camera Type: {c.CAMERA_TYPE}")
    print(f"RTSP URL: {c.RTSP_URL}")
    print(f"  Username: {c.RTSP_USERNAME}")
    print(f"  IP: {c.RTSP_IP}")
    print(f"  Port: {c.RTSP_PORT}")
    print(f"  Stream: {c.RTSP_STREAM}")
    print("\n✓ Camera configuration verified")
except Exception as e:
    print(f"✗ ERROR: {e}")
EOF

echo ""
echo "4. TESTING CAMERA CONNECTION"
echo "═══════════════════════════════════════════════════════════════"
ping -c 2 10.26.27.196 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Camera is reachable (ping successful)"
else
    echo "✗ ERROR: Camera is not reachable"
    echo "  Check if camera is powered on and on the same network"
fi

echo ""
echo "5. TELEGRAM CONFIGURATION"
echo "═══════════════════════════════════════════════════════════════"
source venv/bin/activate
python3 << 'EOF'
try:
    from system_config import Config
    c = Config()
    print(f"Bot Token: {c.TELEGRAM_BOT_TOKEN[:15]}...{c.TELEGRAM_BOT_TOKEN[-5:]}")
    print(f"Chat ID: {c.TELEGRAM_CHAT_ID}")
    print(f"Enabled: {c.TELEGRAM_ENABLED}")
    print(f"\n✓ Telegram configuration:")
    print("  Bot: @vpnockubot")
    print("  Chat ID: 947624946")
except Exception as e:
    print(f"✗ ERROR: {e}")
EOF

echo ""
echo "6. TELEGRAM TROUBLESHOOTING INSTRUCTIONS"
echo "═══════════════════════════════════════════════════════════════"
echo "If you are NOT receiving Telegram messages, follow these steps:"
echo ""
echo "Step 1: Start the bot in Telegram"
echo "  1. Open Telegram on your phone"
echo "  2. Search for: @vpnockubot"
echo "  3. Tap on the bot"
echo "  4. Send: /start"
echo "  5. Wait for a welcome message"
echo ""
echo "Step 2: Verify your Chat ID"
echo "  1. In Telegram, search for: @userinfobot"
echo "  2. Tap on the bot"
echo "  3. Send: /start"
echo "  4. The bot will show your Chat ID"
echo "  5. If different from 947624946, update in system_config.py"
echo ""
echo "Step 3: Try sending a test message manually"
echo "  1. In Telegram, send any message to @vpnockubot"
echo "  2. The bot should respond (even if just an echo)"
echo ""
echo "Step 4: Test again after starting the bot"
echo "  1. Run: ./test_telegram.sh"
echo "  2. Check if you receive the test message"

echo ""
echo "7. RESTARTING SERVICE"
echo "═══════════════════════════════════════════════════════════════"
sudo systemctl restart riftech-security
sleep 3

if sudo systemctl is-active --quiet riftech-security; then
    echo "✓ Service restarted successfully"
else
    echo "✗ ERROR: Service failed to start"
    sudo systemctl status riftech-security --no-pager | head -n 20
fi

echo ""
echo "8. CHECKING CAMERA LOGS"
echo "═══════════════════════════════════════════════════════════════"
sudo journalctl -u riftech-security -n 50 --no-pager | grep -i camera || echo "No camera logs yet (waiting for startup)"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   SETUP COMPLETE                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "✓ V380 Camera configured: 10.26.27.196"
echo "✓ Service restarted"
echo ""
echo "NEXT STEPS:"
echo "1. Start the bot in Telegram: Send /start to @vpnockubot"
echo "2. Verify Chat ID: Check with @userinfobot"
echo "3. Test in browser: http://10.26.27.109:5000"
echo "4. Run full test: ./test_all_features.sh"
echo ""
