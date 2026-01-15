#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         RIFTECH SECURITY - QUICK DIAGNOSIS                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

echo "1. TELEGRAM CONFIGURATION"
echo "═══════════════════════════════════════════════════════════════"
source venv/bin/activate
python3 << 'EOF'
try:
    from system_config import Config
    c = Config()
    print(f"Bot Token: {c.TELEGRAM_BOT_TOKEN[:15]}...{c.TELEGRAM_BOT_TOKEN[-5:] if c.TELEGRAM_BOT_TOKEN else '(NOT SET)'}")
    print(f"Chat ID: {c.TELEGRAM_CHAT_ID}")
    print(f"Enabled: {c.TELEGRAM_ENABLED}")
    
    if not c.TELEGRAM_BOT_TOKEN:
        print("\n✗ ERROR: Bot Token NOT SET!")
    if not c.TELEGRAM_CHAT_ID:
        print("✗ ERROR: Chat ID NOT SET!")
    if not c.TELEGRAM_ENABLED:
        print("✗ ERROR: Telegram NOT Enabled!")
        
    if c.TELEGRAM_BOT_TOKEN and c.TELEGRAM_CHAT_ID and c.TELEGRAM_ENABLED:
        print("\n✓ Configuration OK")
except Exception as e:
    print(f"\n✗ ERROR: {e}")
EOF

echo ""
echo "2. TELEGRAM CONNECTION TEST"
echo "═══════════════════════════════════════════════════════════════"
source venv/bin/activate
python3 << 'EOF'
try:
    from system_config import Config
    c = Config()
    import urllib.request
    import json
    
    if not c.TELEGRAM_BOT_TOKEN:
        print("✗ Cannot test - No token configured")
    else:
        url = f"https://api.telegram.org/bot{c.TELEGRAM_BOT_TOKEN}/getMe"
        try:
            with urllib.request.urlopen(url, timeout=10) as response:
                data = json.loads(response.read())
                if data.get('ok'):
                    bot = data['result']
                    print(f"✓ Bot: @{bot.get('username')}")
                else:
                    print(f"✗ ERROR: {data.get('description')}")
        except Exception as e:
            print(f"✗ ERROR: {e}")
except Exception as e:
    print(f"✗ ERROR: {e}")
EOF

echo ""
echo "3. SEND TEST MESSAGE"
echo "═══════════════════════════════════════════════════════════════"
source venv/bin/activate
python3 << 'EOF'
try:
    from system_config import Config
    from comms_telemetry import TelegramBot
    import time
    
    c = Config()
    if not c.TELEGRAM_BOT_TOKEN or not c.TELEGRAM_CHAT_ID:
        print("✗ Cannot test - Configuration incomplete")
    else:
        print("Initializing TelegramBot...")
        t = TelegramBot(c)
        time.sleep(2)
        
        print("Sending test message...")
        t.send_message("🔔 Test from RIFTECH Security System\n\nThis is a test message!")
        
        print("\n✓ Message sent!")
        print("⚠️  CHECK YOUR TELEGRAM - Did you receive it?")
        print("")
        print("If NOT received, check:")
        print("  1. You sent /start to the bot")
        print("  2. Chat ID is correct (check with @userinfobot)")
        print("  3. Bot token is valid")
        
except Exception as e:
    print(f"✗ ERROR: {e}")
    import traceback
    traceback.print_exc()
EOF

echo ""
echo "4. CAMERA CONFIGURATION"
echo "═══════════════════════════════════════════════════════════════"
source venv/bin/activate
python3 << 'EOF'
try:
    from system_config import Config
    c = Config()
    print(f"Camera Type: {c.CAMERA_TYPE}")
    
    if c.CAMERA_TYPE == 'rtsp':
        print(f"RTSP URL: {c.RTSP_URL[:30]}...{c.RTSP_URL[-10:] if len(c.RTSP_URL) > 40 else c.RTSP_URL}")
        print(f"  Username: {c.RTSP_USERNAME}")
        print(f"  IP: {c.RTSP_IP}")
        print(f"  Port: {c.RTSP_PORT}")
        print(f"  Stream: {c.RTSP_STREAM}")
    elif c.CAMERA_TYPE == 'usb':
        print(f"USB Camera ID: {c.CAMERA_ID}")
    else:
        print("Mode: Simulation (no camera)")
except Exception as e:
    print(f"✗ ERROR: {e}")
EOF

echo ""
echo "5. SYSTEM STATUS"
echo "═══════════════════════════════════════════════════════════════"
sudo systemctl status riftech-security.service | head -n 10

echo ""
echo "6. RECENT LOGS (Camera & Telegram)"
echo "═══════════════════════════════════════════════════════════════"
sudo journalctl -u riftech-security -n 30 --no-pager | grep -E "(Camera|Telegram|ERROR)" || echo "No relevant logs found"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   DIAGNOSIS COMPLETE                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "NEXT STEPS:"
echo "1. Review the output above"
echo "2. Fix any errors identified"
echo "3. Test Telegram: Did you receive the message?"
echo "4. Check camera: Is it configured?"
echo "5. Run full test: ./test_all_features.sh"
echo ""
