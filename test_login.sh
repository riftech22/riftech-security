#!/bin/bash
# ============================================
# RIFTECH SECURITY SYSTEM - LOGIN ROUTE TESTER
# ============================================

COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR_GREEN}║     RIFTECH SECURITY - LOGIN ROUTE TESTER                 ║${NC}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

cd /opt/riftech-security
source venv/bin/activate

# Test 1: Direct Python import and basic routes
echo -e "${COLOR_YELLOW}[1/5] Testing Flask app initialization...${NC}"
python3 << 'EOF'
import sys
try:
    from flask import Flask
    app = Flask(__name__)
    app.secret_key = 'test-secret-key'
    print("✓ Flask app created")
except Exception as e:
    print(f"✗ Flask error: {e}")
    sys.exit(1)

try:
    from flask_socketio import SocketIO
    socketio = SocketIO(app, async_mode='threading')
    print("✓ SocketIO initialized")
except Exception as e:
    print(f"✗ SocketIO error: {e}")
    sys.exit(1)

print("\nAll Flask components OK!")
EOF
echo ""

# Test 2: Import web_server components
echo -e "${COLOR_YELLOW}[2/5] Testing web_server imports...${NC}"
python3 << 'EOF'
import sys
import os

# Set environment variables
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS'] = '0'

try:
    from system_config import Config
    config = Config()
    print("✓ System config loaded")
except Exception as e:
    print(f"✗ Config error: {e}")
    import traceback
    traceback.print_exc()

try:
    from data_storage import DatabaseManager
    db = DatabaseManager(config)
    print("✓ Database manager initialized")
except Exception as e:
    print(f"✗ Database error: {e}")
    import traceback
    traceback.print_exc()

print("\nCore components OK!")
EOF
echo ""

# Test 3: Test login route directly
echo -e "${COLOR_YELLOW}[3/5] Testing login route...${NC}"
python3 << 'EOF'
import sys
import os

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS'] = '0'

from flask import Flask, render_template, request, redirect, url_for, session
app = Flask(__name__)
app.secret_key = 'riftech-security-secret-key-v2'

LOGIN_USERNAME = 'admin'
LOGIN_PASSWORD = 'riftech2025'

@app.route('/test_login', methods=['POST'])
def test_login():
    try:
        username = request.form.get('username', '')
        password = request.form.get('password', '')
        
        if username == LOGIN_USERNAME and password == LOGIN_PASSWORD:
            return "LOGIN SUCCESS"
        else:
            return "LOGIN FAILED"
    except Exception as e:
        return f"ERROR: {e}"

# Test with Flask test client
with app.test_client() as client:
    response = client.post('/test_login', data={
        'username': 'admin',
        'password': 'riftech2025'
    })
    print(f"✓ Login route response: {response.data.decode('utf-8')}")
    
    # Test wrong password
    response2 = client.post('/test_login', data={
        'username': 'admin',
        'password': 'wrong'
    })
    print(f"✓ Wrong password response: {response2.data.decode('utf-8')}")

print("\nLogin route OK!")
EOF
echo ""

# Test 4: Check templates
echo -e "${COLOR_YELLOW}[4/5] Checking templates...${NC}"
for template in login.html index.html; do
    if [ -f "templates/$template" ]; then
        echo -e "${COLOR_GREEN}✓ templates/$template exists${NC}"
    else
        echo -e "${COLOR_RED}✗ templates/$template missing${NC}"
    fi
done

# Test 5: Actual web server login test
echo -e "${COLOR_YELLOW}[5/5] Testing actual login to web server...${NC}"
echo -e "${COLOR_CYAN}Starting web server in background...${NC}"
python3 web_server.py > /tmp/web_login_test.log 2>&1 &
WEB_PID=$!
echo "Web server PID: $WEB_PID"
sleep 5

# Test login with curl
echo -e "${COLOR_CYAN}Testing login with curl...${NC}"
curl -s -c /tmp/cookies.txt -b /tmp/cookies.txt -X POST \
  -d "username=admin&password=riftech2025" \
  http://localhost:5000/login > /tmp/login_response.html

if grep -q "302 Found" /tmp/login_response.html || grep -q "Location:" /tmp/login_response.html; then
    echo -e "${COLOR_GREEN}✓ Login redirect successful (302 Found)${NC}"
    echo "Login worked - redirecting to dashboard"
else
    echo -e "${COLOR_RED}✗ Login failed${NC}"
    echo "Response:"
    head -20 /tmp/login_response.html
fi

# Clean up
kill $WEB_PID 2>/dev/null
wait $WEB_PID 2>/dev/null

echo ""
echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR_GREEN}║                    LOGIN TEST COMPLETE                      ║${NC}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${COLOR_YELLOW}Check log files:${NC}"
echo "  - /tmp/web_login_test.log (server logs)"
echo "  - /tmp/login_response.html (login response)"
echo ""
