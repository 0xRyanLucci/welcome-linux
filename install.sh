#!/bin/bash
# Interactive installer for welcome.sh

echo ""
echo "Welcome Linux Installer"
echo "-----------------------"
echo ""

# Directory selection
echo "Directory to scan:"
echo "  1) ~/code (default)"
echo "  2) ~/projects"
echo "  3) ~/dev"
echo "  4) Custom"
read -p "Choice [1]: " dir_choice
case "$dir_choice" in
    2) WELCOME_DIR="\$HOME/projects" ;;
    3) WELCOME_DIR="\$HOME/dev" ;;
    4) read -p "Enter path: " custom_dir; WELCOME_DIR="$custom_dir" ;;
    *) WELCOME_DIR="\$HOME/code" ;;
esac
echo ""

# Limit selection
echo "How many directories to show?"
echo "  1) 10 (default)"
echo "  2) 5"
echo "  3) 15"
read -p "Choice [1]: " limit_choice
case "$limit_choice" in
    2) WELCOME_LIMIT=5 ;;
    3) WELCOME_LIMIT=15 ;;
    *) WELCOME_LIMIT=10 ;;
esac
echo ""

# Auto-run selection
echo "Auto-run on shell start?"
echo "  1) Yes (default)"
echo "  2) No"
read -p "Choice [1]: " auto_choice
case "$auto_choice" in
    2) WELCOME_AUTO="false" ;;
    *) WELCOME_AUTO="true" ;;
esac
echo ""

# Download welcome.sh
echo "Downloading welcome.sh..."
curl -sL https://raw.githubusercontent.com/0xRyanLucci/welcome-linux/master/welcome.sh > ~/.welcome.sh

# Remove old config block if exists
sed -i '/# WELCOME-CONFIG-START/,/# WELCOME-CONFIG-END/d' ~/.bashrc 2>/dev/null

# Remove old source line if exists
sed -i '/source ~\/.welcome.sh/d' ~/.bashrc 2>/dev/null

# Write new config block + source line
cat >> ~/.bashrc << EOF
# WELCOME-CONFIG-START
export WELCOME_DIR="$WELCOME_DIR"
export WELCOME_LIMIT=$WELCOME_LIMIT
export WELCOME_AUTO=$WELCOME_AUTO
source ~/.welcome.sh
# WELCOME-CONFIG-END
EOF

echo "Installed! Restart shell or: source ~/.bashrc"

