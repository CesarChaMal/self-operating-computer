#!/bin/bash

# Upgrade pip
python -m pip install --upgrade pip

# Install virtualenv if not installed
pip install virtualenv

# Create and activate virtual environment
python -m venv venv

# Detect OS for activation
if [[ "$OSTYPE" == "msys" ]]; then
    # Git Bash on Windows
    source venv/Scripts/activate
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    source venv/bin/activate
elif [[ "$OSTYPE" == "win32" ]]; then
    # Native Windows CMD (not bash)
    venv\Scripts\activate
else
    echo "Unsupported OS. Please activate the venv manually."
    exit 1
fi

# Install dependencies
pip install -r requirements.txt
pip install .

# Run the application
if [[ "$OSTYPE" == "msys" ]]; then
    winpty operate
else
    operate
fi
