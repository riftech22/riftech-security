// RIFTECH SECURITY SYSTEM - Web JavaScript

// Socket.IO connection
const socket = io();

// Video and canvas elements
const videoElement = document.getElementById('video-feed');
const canvas = document.getElementById('zone-canvas');
const ctx = canvas.getContext('2d');

// Status elements
const armedStatus = document.getElementById('armed-status');
const breachStatus = document.getElementById('breach-status-text');
const alarmStatus = document.getElementById('alarm-status');
const breachBadge = document.getElementById('breach-status');
const fpsDisplay = document.getElementById('fps-display');
const personsDisplay = document.getElementById('persons-display');
const zonesDisplay = document.getElementById('zones-display');
const alertsDisplay = document.getElementById('alerts-display');
const zonePointsDisplay = document.getElementById('zone-points');

// Button elements
const armBtn = document.getElementById('arm-btn');
const recordBtn = document.getElementById('record-btn');
const muteBtn = document.getElementById('mute-btn');

// Checkboxes
const drawModeCheckbox = document.getElementById('draw-mode');

// Zone drawing state
let isDrawingMode = false;
let zonePoints = [];
let videoWidth = 0;
let videoHeight = 0;

// Initialize canvas when video loads
videoElement.onload = function() {
    videoWidth = videoElement.videoWidth;
    videoHeight = videoElement.videoHeight;
    canvas.width = videoWidth;
    canvas.height = videoHeight;
    
    // Redraw zones on video load
    drawZones();
};

// Socket.IO event handlers
socket.on('connect', function() {
    console.log('[Socket] Connected');
});

socket.on('system_update', function(state) {
    console.log('[Socket] System update:', state);
    
    // Update armed status
    armedStatus.textContent = state.armed ? 'TRUE' : 'FALSE';
    
    // Update breach status
    if (state.breach_active) {
        breachStatus.textContent = 'DETECTED';
        breachStatus.style.color = '#ff0000';
        breachBadge.className = 'badge bg-danger';
        breachBadge.textContent = '⚠️ BREACH DETECTED';
    } else {
        breachStatus.textContent = 'NONE';
        breachStatus.style.color = '#00ff00';
        breachBadge.className = 'badge bg-success';
        breachBadge.textContent = 'SYSTEM ARMED';
    }
    
    // Update alarm status
    if (state.muted) {
        alarmStatus.textContent = 'MUTED';
        alarmStatus.style.color = '#ffaa00';
    } else {
        alarmStatus.textContent = state.armed ? 'READY' : 'OFF';
        alarmStatus.style.color = state.armed ? '#00ff00' : '#00ff00';
    }
    
    // Update fps
    fpsDisplay.textContent = state.fps ? state.fps.toFixed(0) : '--';
    
    // Update persons
    personsDisplay.textContent = state.persons_detected;
    
    // Update zones
    zonesDisplay.textContent = state.zone_count;
    
    // Update alerts
    alertsDisplay.textContent = state.alerts_count;
    
    // Update arm button
    if (state.armed) {
        armBtn.textContent = '[DISARM]';
        armBtn.className = 'btn cyber-btn cyber-btn-danger cyber-btn-active';
    } else {
        armBtn.textContent = '[ARM] SYSTEM';
        armBtn.className = 'btn cyber-btn cyber-btn-danger';
    }
    
    // Update record button
    if (state.recording) {
        recordBtn.textContent = '[STOP]';
        recordBtn.className = 'btn cyber-btn cyber-btn-blue cyber-btn-active';
    } else {
        recordBtn.textContent = '[REC]';
        recordBtn.className = 'btn cyber-btn cyber-btn-blue';
    }
    
    // Update mute button
    if (state.muted) {
        muteBtn.textContent = '[UNMUTE]';
        muteBtn.className = 'btn cyber-btn cyber-btn-yellow cyber-btn-active';
    } else {
        muteBtn.textContent = '[MUTE] ALARM';
        muteBtn.className = 'btn cyber-btn cyber-btn-yellow';
    }
});

socket.on('detection_update', function(data) {
    console.log('[Socket] Detection update:', data);
    
    // Update persons
    personsDisplay.textContent = data.persons;
    
    // Update breach status
    if (data.breach) {
        breachStatus.textContent = 'DETECTED';
        breachStatus.style.color = '#ff0000';
        breachBadge.className = 'badge bg-danger';
        breachBadge.textContent = '⚠️ BREACH DETECTED';
    } else {
        breachStatus.textContent = 'NONE';
        breachStatus.style.color = '#00ff00';
        breachBadge.className = 'badge bg-success';
        breachBadge.textContent = 'SYSTEM ARMED';
    }
});

socket.on('zone_update', function(data) {
    console.log('[Socket] Zone update:', data);
    
    // Update zone count
    zonesDisplay.textContent = data.count;
    zonePointsDisplay.textContent = data.points;
    
    // Redraw zones
    zonePoints = []; // Clear and will be updated from server
});

// System control functions
async function toggleArm() {
    try {
        const response = await fetch('/api/system', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ action: armBtn.textContent.includes('[ARM]') ? 'arm' : 'disarm' })
        });
        const result = await response.json();
        console.log('[API] Toggle arm:', result);
    } catch (error) {
        console.error('[Error] Toggle arm:', error);
    }
}

async function toggleRecord() {
    try {
        const response = await fetch('/api/system', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ action: recordBtn.textContent.includes('[REC]') ? 'record' : 'stop_record' })
        });
        const result = await response.json();
        console.log('[API] Toggle record:', result);
    } catch (error) {
        console.error('[Error] Toggle record:', error);
    }
}

async function toggleMute() {
    try {
        const response = await fetch('/api/system', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ action: muteBtn.textContent.includes('[MUTE]') ? 'mute' : 'unmute' })
        });
        const result = await response.json();
        console.log('[API] Toggle mute:', result);
    } catch (error) {
        console.error('[Error] Toggle mute:', error);
    }
}

async function takeSnapshot() {
    try {
        const response = await fetch('/api/system', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ action: 'snapshot' })
        });
        const result = await response.json();
        console.log('[API] Take snapshot:', result);
    } catch (error) {
        console.error('[Error] Take snapshot:', error);
    }
}

async function newZone() {
    isDrawingMode = true;
    drawModeCheckbox.checked = true;
    zonePoints = [];
    console.log('[Zone] New zone started');
}

async function clearZones() {
    try {
        const response = await fetch('/api/zone', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ action: 'clear' })
        });
        const result = await response.json();
        console.log('[API] Clear zones:', result);
        zonePoints = [];
    } catch (error) {
        console.error('[Error] Clear zones:', error);
    }
}

// Zone drawing functions
function drawZones() {
    // Clear canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw zone lines
    if (zonePoints.length >= 2) {
        ctx.strokeStyle = '#00ff00';
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(zonePoints[0].x, zonePoints[0].y);
        
        for (let i = 1; i < zonePoints.length; i++) {
            ctx.lineTo(zonePoints[i].x, zonePoints[i].y);
        }
        
        ctx.closePath();
        ctx.stroke();
        
        // Fill with semi-transparent green
        ctx.fillStyle = 'rgba(0, 255, 0, 0.2)';
        ctx.fill();
    }
}

// Video click handler for zone drawing
videoElement.addEventListener('click', function(event) {
    if (!isDrawingMode) return;
    
    // Get click position relative to video
    const rect = videoElement.getBoundingClientRect();
    const scaleX = videoWidth / rect.width;
    const scaleY = videoHeight / rect.height;
    
    const x = Math.floor((event.clientX - rect.left) * scaleX);
    const y = Math.floor((event.clientY - rect.top) * scaleY);
    
    console.log(`[Zone] Point added: ${x}, ${y}`);
    
    // Add point
    zonePoints.push({ x, y });
    
    // If we have 4 or more points, submit zone
    if (zonePoints.length >= 4) {
        submitZone();
    } else {
        // Draw current zone
        drawZones();
    }
});

async function submitZone() {
    // Submit last 4 points
    const points = zonePoints.slice(0, 4);
    
    try {
        for (const point of points) {
            await fetch('/api/zone', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 
                    action: 'add_point',
                    x: point.x,
                    y: point.y
                })
            });
        }
        
        console.log('[Zone] Zone submitted with', points.length, 'points');
        
        // Reset
        isDrawingMode = false;
        drawModeCheckbox.checked = false;
        zonePoints = [];
        
    } catch (error) {
        console.error('[Error] Submit zone:', error);
    }
}

// Feature toggles
document.getElementById('skeleton-check').addEventListener('change', function(e) {
    console.log('[Feature] Skeleton:', e.target.checked);
    // TODO: Send to API
});

document.getElementById('face-check').addEventListener('change', function(e) {
    console.log('[Feature] Face recognition:', e.target.checked);
    // TODO: Send to API
});

document.getElementById('motion-check').addEventListener('change', function(e) {
    console.log('[Feature] Motion detection:', e.target.checked);
    // TODO: Send to API
});

document.getElementById('motion-breach-check').addEventListener('change', function(e) {
    console.log('[Feature] Motion triggers breach:', e.target.checked);
    // TODO: Send to API
});

// Double click to finish zone
videoElement.addEventListener('dblclick', function() {
    if (isDrawingMode && zonePoints.length >= 3) {
        submitZone();
    }
});

// Keyboard shortcuts
document.addEventListener('keydown', function(event) {
    // A - Arm/Disarm
    if (event.key === 'a' || event.key === 'A') {
        event.preventDefault();
        toggleArm();
    }
    // R - Record
    else if (event.key === 'r' || event.key === 'R') {
        event.preventDefault();
        toggleRecord();
    }
    // S - Snapshot
    else if (event.key === 's' || event.key === 'S') {
        event.preventDefault();
        takeSnapshot();
    }
    // M - Mute/Unmute
    else if (event.key === 'm' || event.key === 'M') {
        event.preventDefault();
        toggleMute();
    }
    // N - New zone
    else if (event.key === 'n' || event.key === 'N') {
        event.preventDefault();
        newZone();
    }
    // C - Clear zones
    else if (event.key === 'c' || event.key === 'C') {
        event.preventDefault();
        clearZones();
    }
    // Escape - Cancel drawing
    else if (event.key === 'Escape') {
        if (isDrawingMode) {
            isDrawingMode = false;
            drawModeCheckbox.checked = false;
            zonePoints = [];
            console.log('[Zone] Drawing cancelled');
        }
    }
});

console.log('[RIFTECH SECURITY] Web interface loaded');
