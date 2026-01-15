#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         TELEGRAM TEST SCRIPT                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"
source venv/bin/activate

echo "Sending test message to Telegram..."
echo ""

python3 << 'EOF'
from system_config import Config
from comms_telemetry import TelegramBot
from datetime import datetime
import time

try:
    config = Config()
    telegram = TelegramBot(config)
    
    # Wait for thread to start
    time.sleep(2)
    
    # Test message
    message = f"""🔔 TEST MESSAGE FROM RIFTECH SECURITY SYSTEM

Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Status: Telegram is working!

If you receive this message, Telegram notifications are fully functional!"""

    telegram.send_message(message)
    
    print("✓ Test message sent successfully!")
    print("")
    print("⚠️  CHECK YOUR TELEGRAM NOW!")
    print("")
    print("You should receive a message from @vpnockubot")
    print("")
    print("If you DO NOT receive it:")
    echo "  1. Make sure you sent /start to @vpnockubot"
    echo "  2. Check your Chat ID with @userinfobot"
    echo "  3. Verify Chat ID is 947624946 in system_config.py"
    
except Exception as e:
    print(f"✗ ERROR: {e}")
    import traceback
    traceback.print_exc()
EOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
