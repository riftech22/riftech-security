#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         RIFTECH SECURITY - TELEGRAM DEBUG SCRIPT              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"
source venv/bin/activate

echo "1. Checking Telegram Configuration..."
echo "═══════════════════════════════════════════════════════════════"

python3 << 'EOF'
import sys
try:
    from system_config import Config
    
    config = Config()
    
    print(f"TELEGRAM_BOT_TOKEN: {config.TELEGRAM_BOT_TOKEN[:20]}...{config.TELEGRAM_BOT_TOKEN[-5:]}" if config.TELEGRAM_BOT_TOKEN else "TELEGRAM_BOT_TOKEN: (empty)")
    print(f"TELEGRAM_CHAT_ID: {config.TELEGRAM_CHAT_ID}")
    print(f"TELEGRAM_ENABLED: {config.TELEGRAM_ENABLED}")
    
    if not config.TELEGRAM_BOT_TOKEN:
        print("\n✗ ERROR: TELEGRAM_BOT_TOKEN is empty!")
        print("  Please set TELEGRAM_BOT_TOKEN in system_config.py")
        sys.exit(1)
    
    if not config.TELEGRAM_CHAT_ID:
        print("\n✗ ERROR: TELEGRAM_CHAT_ID is empty!")
        print("  Please set TELEGRAM_CHAT_ID in system_config.py")
        sys.exit(1)
    
    print("\n✓ Telegram configuration looks good")
except Exception as e:
    print(f"\n✗ ERROR loading config: {e}")
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    echo ""
    echo "Please fix configuration issues above and try again."
    exit 1
fi

echo ""
echo "2. Testing Telegram Bot API Connection..."
echo "═══════════════════════════════════════════════════════════════"

python3 << 'EOF'
import sys
try:
    from system_config import Config
    
    config = Config()
    token = config.TELEGRAM_BOT_TOKEN
    
    # Test getMe API
    import urllib.request
    import json
    
    url = f"https://api.telegram.org/bot{token}/getMe"
    
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            data = json.loads(response.read())
            
            if data.get('ok'):
                bot_info = data['result']
                print(f"Bot Name: {bot_info.get('first_name')}")
                print(f"Bot Username: @{bot_info.get('username')}")
                print(f"Bot ID: {bot_info.get('id')}")
                print("\n✓ Bot is valid and accessible")
            else:
                print(f"\n✗ ERROR: Bot API returned error")
                print(f"  Description: {data.get('description')}")
                sys.exit(1)
    except urllib.error.URLError as e:
        print(f"\n✗ ERROR: Cannot connect to Telegram API")
        print(f"  {e}")
        print("\n  Possible causes:")
        print("  - No internet connection")
        print("  - Firewall blocking Telegram API")
        print("  - Invalid bot token")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ ERROR: {e}")
        sys.exit(1)
        
except Exception as e:
    print(f"\n✗ ERROR: {e}")
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    echo ""
    echo "Please fix connection issues above and try again."
    exit 1
fi

echo ""
echo "3. Testing Telegram Bot Module..."
echo "═══════════════════════════════════════════════════════════════"

python3 << 'EOF'
import sys
try:
    from system_config import Config
    from comms_telemetry import TelegramBot
    
    config = Config()
    telegram = TelegramBot(config)
    
    print("✓ TelegramBot initialized successfully")
    print(f"  Thread running: {telegram.is_alive()}")
    
except Exception as e:
    print(f"\n✗ ERROR initializing TelegramBot: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    echo ""
    echo "Please fix TelegramBot initialization issues above."
    exit 1
fi

echo ""
echo "4. Testing Telegram Message Send..."
echo "═══════════════════════════════════════════════════════════════"

python3 << 'EOF'
import sys
try:
    from system_config import Config
    from comms_telemetry import TelegramBot
    from datetime import datetime
    
    config = Config()
    telegram = TelegramBot(config)
    
    # Wait a moment for thread to start
    import time
    time.sleep(2)
    
    # Test message
    test_message = f"🔔 Test from RIFTECH Security System\n\nTime: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\nIf you receive this, Telegram is working!"
    
    print("Sending test message...")
    telegram.send_message(test_message)
    
    print("\n✓ Test message sent successfully")
    print("\n⚠️  Please check your Telegram to confirm you received the message!")
    print("   If you didn't receive it, check:")
    print("   - You started the bot with /start")
    print("   - Chat ID is correct")
    print("   - Bot token is valid")
    print("   - Internet connection is working")
    
except Exception as e:
    print(f"\n✗ ERROR sending message: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    echo ""
    echo "Please fix message sending issues above."
    exit 1
fi

echo ""
echo "5. Checking System Logs for Telegram Errors..."
echo "═══════════════════════════════════════════════════════════════"

sudo journalctl -u riftech-security -n 50 --no-pager | grep -i telegram

echo ""
echo "6. Summary"
echo "═══════════════════════════════════════════════════════════════"

echo ""
echo "If all tests passed above, Telegram should be working."
echo ""
echo "Common issues:"
echo "1. You need to send /start to the bot in Telegram first"
echo "2. Chat ID must be correct (check with @userinfobot)"
echo "3. Bot token must be valid (check with @BotFather)"
echo "4. Internet connection must be working"
echo "5. No firewall blocking telegram.org"
echo ""
echo "To test manually:"
echo "  source venv/bin/activate"
echo "  python3 -c \"from system_config import Config; from comms_telemetry import TelegramBot; c = Config(); t = TelegramBot(c); t.send_message('Test!')\""
echo ""

echo "✓ Telegram debug complete"
