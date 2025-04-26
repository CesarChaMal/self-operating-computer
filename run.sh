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
    source venv/Scripts/activate
elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$(uname -r)" == *"WSL"* ]]; then
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

# If in WSL or Git Bash, set DISPLAY and auto-start VcXsrv if needed
if grep -qi microsoft /proc/version 2>/dev/null || [[ "$OSTYPE" == "msys" ]]; then
    echo "Detected WSL or Git Bash - setting DISPLAY=:0"
    export DISPLAY=:0

    echo "🔍 Checking for VcXsrv process..."
    if ! tasklist.exe | grep -i "vcxsrv.exe" >/dev/null; then
        echo "⚡ VcXsrv is not running. Attempting to start it..."

        "/c/Program Files/VcXsrv/vcxsrv.exe" :0 -multiwindow -clipboard -wgl -ac &
        sleep 5
    else
        echo "✅ VcXsrv is already running."
    fi

    sleep 2
fi

# Run the application
if [[ "$OSTYPE" == "msys" ]]; then
    winpty operate
else
    operate
fi
