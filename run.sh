#!/bin/bash

# Always use python
PYTHON=python

# Upgrade pip
$PYTHON -m pip install --upgrade pip --user

# Install virtualenv if not installed
$PYTHON -m pip install virtualenv --user

# Create and activate virtual environment
$PYTHON -m virtualenv venv

# Detect OS for activation
if [[ "$OSTYPE" == "msys" ]]; then
    # Git Bash on Windows
    source venv/Scripts/activate
elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$(uname -r)" == *"WSL"* ]]; then
    # Linux or WSL
    source venv/bin/activate
elif [[ "$OSTYPE" == "win32" ]]; then
    venv\Scripts\activate
else
    echo "Unsupported OS. Please activate the venv manually."
    exit 1
fi

# Install dependencies
pip install -r requirements.txt
pip install .

# Handle display based on environment
if [[ "$OSTYPE" == "msys" ]]; then
    echo "Detected Git Bash on Windows - setting DISPLAY=:0"
    export DISPLAY=:0

    echo "🔍 Checking for VcXsrv process..."
    if tasklist.exe | grep -i "vcxsrv.exe" >/dev/null; then
        echo "⚠️ Old VcXsrv detected - killing it first..."
        taskkill.exe /IM vcxsrv.exe /F
        sleep 2
    fi

    echo "⚡ Starting fresh VcXsrv..."
    "/c/Program Files/VcXsrv/vcxsrv.exe" :0 -multiwindow -clipboard -wgl -ac &
    sleep 5

elif grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Detected WSL - unsetting DISPLAY."
    unset DISPLAY
    echo "✅ DISPLAY unset for headless WSL mode"

else
    echo "Detected native Linux (e.g., Pop!_OS) - using system's default DISPLAY."
    export DISPLAY=${DISPLAY:-:0}
fi

# Skip checking X server for WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "⚠️ Running in WSL without X server or GUI."
else
    if ! timeout 2 bash -c "</dev/tcp/127.0.0.1/6000" 2>/dev/null; then
        echo "⚠️ Warning: Cannot reach X server at $DISPLAY, continuing anyway without GUI support..."
    fi
fi

# === Patch environment so pyautogui/mouseinfo don't crash ===
export PYAUTOGUI_NO_GUI=1
export MOUSEINFO_NO_DISPLAY=1

# Run the application
if [[ "$OSTYPE" == "msys" ]]; then
    winpty operate
else
    operate
fi
