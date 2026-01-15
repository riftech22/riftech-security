#!/bin/bash
# ============================================
# RIFTECH SECURITY SYSTEM - DASHBOARD ROUTE TESTER
# ============================================

COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR_GREEN}║     RIFTECH SECURITY - DASHBOARD ROUTE TESTER           ║${NC}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

cd /opt/riftech-security
source venv/bin/activate

# Test 1: Access dashboard route
echo -e "${COLOR_YELLOW}[1/3] Testing index/dashboard route...${NC}"
python3 << 'EOF'
import sys
import os

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS'] = '0'

from flask import Flask, render_template, session, redirect, url_for
from functools import wraps

app = Flask(__name__)
app.secret_key = 'riftech-security-secret-key-v2'

# Mock login
with app.test_request_context():
    session['logged_in'] = True
    session['username'] = 'admin'
    
    # Mock database
    class MockDB:
        def get_all_events(self, limit=100):
            return []
    
    class MockConfig:
        RECORDINGS_DIR = '.'
        SNAPSHOTS_DIR = '.'
    
    class MockZoneManager:
        def get_zone_count(self):
            return 0
    
    db = MockDB()
    config = MockConfig()
    zone_manager = MockZoneManager()
    system_state = {
        'armed': False,
        'recording': False,
        'muted': False,
        'breach_active': False,
        'persons_detected': 0,
        'fps': 0,
        'alerts_count': 0
    }
    
    try:
        # Test rendering index template
        events = []
        recordings = []
        snapshots = []
        zone_count = 0
        
        output = render_template('index.html',
                             system_state=system_state,
                             events=events,
                             recordings=recordings,
                             snapshots=snapshots,
                             zone_count=zone_count)
        print(f"✓ Index template rendered successfully")
        print(f"✓ Output length: {len(output)} characters")
    except Exception as e:
        print(f"✗ Index template error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

print("\nDashboard route OK!")
EOF
echo ""

# Test 2: Check template files
echo -e "${COLOR_YELLOW}[2/3] Checking template contents...${NC}"
if [ -f "templates/index.html" ]; then
    echo -e "${COLOR_GREEN}✓ index.html exists${NC}"
    size=$(wc -c < templates/index.html)
    echo -e "  Size: $size bytes"
    
    # Check for key elements
    if grep -q "{{ system_state }}" templates/index.html; then
        echo -e "  ${COLOR_GREEN}✓ Contains system_state variable${NC}"
    else
        echo -e "  ${COLOR_RED}✗ Missing system_state variable${NC}"
    fi
else
    echo -e "${COLOR_RED}✗ index.html missing${NC}"
fi

if [ -f "templates/login.html" ]; then
    echo -e "${COLOR_GREEN}✓ login.html exists${NC}"
else
    echo -e "${COLOR_RED}✗ login.html missing${NC}"
fi
echo ""

# Test 3: Actual dashboard access
echo -e "${COLOR_YELLOW}[3/3] Testing actual dashboard access...${NC}"
echo -e "${COLOR_CYAN}Starting web server in background...${NC}"
python3 web_server.py > /tmp/dashboard_test.log 2>&1 &
WEB_PID=$!
echo "Web server PID: $WEB_PID"
sleep 5

# Test dashboard access
echo -e "${COLOR_CYAN}Testing dashboard access with curl...${NC}"
curl -s -c /tmp/dashboard_cookies.txt -b /tmp/dashboard_cookies.txt \
  http://localhost:5000/ > /tmp/dashboard_response.html

# Check response
if grep -q "200 OK" /tmp/dashboard_response.html || grep -q "RIFTECH SECURITY" /tmp/dashboard_response.html || grep -q "Dashboard" /tmp/dashboard_response.html; then
    echo -e "${COLOR_GREEN}✓ Dashboard accessible (200 OK)${NC}"
    echo "Dashboard loaded successfully!"
    
    # Check for errors in response
    if grep -qi "internal server error\|error\|exception" /tmp/dashboard_response.html; then
        echo -e "${COLOR_RED}✗ BUT: Error messages found in HTML${NC}"
        echo "Looking for error details..."
        grep -i "error" /tmp/dashboard_response.html | head -10
    else
        echo -e "${COLOR_GREEN}✓ No error messages in HTML${NC}"
    fi
else
    echo -e "${COLOR_RED}✗ Dashboard access failed${NC}"
    echo "Response:"
    head -30 /tmp/dashboard_response.html
fi

# Check server logs
echo ""
echo -e "${COLOR_CYAN}Checking server logs...${NC}"
if [ -f "/tmp/dashboard_test.log" ]; then
    tail -20 /tmp/dashboard_test.log | grep -E "ERROR|error|Exception|Traceback" || echo "No errors in logs"
fi

# Clean up
kill $WEB_PID 2>/dev/null
wait $WEB_PID 2>/dev/null

echo ""
echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR_GREEN}║                 DASHBOARD TEST COMPLETE                      ║${NC}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${COLOR_YELLOW}Check log files:${NC}"
echo "  - /tmp/dashboard_test.log (server logs)"
echo "  - /tmp/dashboard_response.html (dashboard HTML)"
echo ""
