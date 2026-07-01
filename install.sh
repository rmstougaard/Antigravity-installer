#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Color Palettes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}         ANTIGRAVITY COMMUNITY INSTALLER          ${NC}"
echo -e "${BLUE}==================================================${NC}"

# --- Helper Functions ---
confirm() {
    echo -ne "${YELLOW}${1}${NC} [y/N]: "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) true ;;
        *) false ;;
    esac
}

# --- Phase 1: Pure Purge / Wipe System ---
if confirm "Do you want to completely wipe and purge old Antigravity installations/configs?"; then
    echo -e "${YELLOW}[*] Scrubbing system...${NC}"
    
    sudo apt-get purge antigravity -y || true
    sudo rm -f /etc/apt/sources.list.d/antigravity.list
    sudo rm -f /etc/apt/keyrings/antigravity-repo-key.gpg
    
    sudo rm -rf /opt/antigravity
    sudo rm -rf /opt/antigravity2
    sudo rm -rf /opt/Antigravity-x64
    
    rm -f "$HOME/.local/share/applications/"*antigravity*
    sudo rm -f /usr/share/applications/*antigravity*
    
    rm -rf "$HOME/.config/Antigravity"
    rm -rf "$HOME/.config/antigravity"
    rm -rf "$HOME/.cache/antigravity"
    
    sudo update-desktop-database || true
    echo -e "${GREEN}[✓] System successfully cleaned of legacy components.${NC}\n"
fi

# --- Phase 2: Select Major Version ---
echo -e "${BLUE}Which major version of Antigravity do you want to deploy?${NC}"
echo -e "1) Antigravity Version 1 (Legacy IDE Engine)"
echo -e "2) Antigravity Version 2 (Modern Product Suite)"
echo -ne "Enter choice [1-2]: "
read -r version_choice

if [ "$version_choice" -eq 1 ]; then
    # ==================== VERSION 1 FLOW ====================
    echo -e "\n${BLUE}[*] Setting up Antigravity Version 1...${NC}"
    
    echo -e "${YELLOW}[*] Auto-detecting archive in ~/Downloads...${NC}"
    tar_path=$(find "$HOME/Downloads" -maxdepth 1 -name "Antigravity*.tar.gz" -print -quit)
    
    if [ -z "$tar_path" ]; then
        echo -e "${RED}[X] Error: Could not automatically find 'Antigravity.tar.gz' in $HOME/Downloads.${NC}"
        echo -e "${RED}Please ensure you have downloaded it via your authenticated Google account first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[✓] Found archive at: $tar_path${NC}"
    echo -e "${YELLOW}[*] Extracting package...${NC}"
    
    sudo mkdir -p /opt/antigravity
    sudo tar -xzf "$tar_path" -C /opt/
    
    if [ -d "/opt/Antigravity-x64" ]; then
        sudo cp -a --remove-destination /opt/Antigravity-x64/. /opt/antigravity/
        sudo rm -rf /opt/Antigravity-x64
    fi
    
    sudo chmod -R 755 /opt/antigravity
    sudo chmod 4755 /opt/antigravity/chrome-sandbox 2>/dev/null || true
    
    cat << EOF > "$HOME/.local/share/applications/antigravity.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity IDE V1
Exec=/opt/antigravity/antigravity %U
Icon=antigravity
Terminal=false
Categories=Development;
EOF
    chmod +x "$HOME/.local/share/applications/antigravity.desktop"
    update-desktop-database "$HOME/.local/share/applications/" || true
    
    echo -e "${GREEN}[✓] Antigravity Version 1 successfully deployed!${NC}"

elif [ "$version_choice" -eq 2 ]; then
    # ==================== VERSION 2 FLOW WITH ARROW KEYS ====================
    options=(
        "Antigravity IDE (2.0 Code Engine)"
        "Agent Manager (Standalone Control Panel)"
        "CLI Engine (agy tool)"
    )
    choices=(false false false)
    current_selection=0

    # Hide cursor safely using correct terminfo capability
    tput civis
    trap 'tput cnorm; exit 1' INT TERM

    while true; do
        clear
        echo -e "${BLUE}==================================================${NC}"
        echo -e "${BLUE}       SELECT VERSION 2 COMPONENTS TO DEPLOY      ${NC}"
        echo -e "${BLUE}==================================================${NC}"
        echo -e "Use ${YELLOW}Arrow Keys${NC} to navigate, ${YELLOW}Spacebar${NC} to toggle, ${YELLOW}Enter${NC} to confirm and install. Press ${YELLOW}Ctrl+C${NC} to cancel.\n"
        
        for i in "${!options[@]}"; do
            if [ "$i" -eq "$current_selection" ]; then
                prefix=" --> "
            else
                prefix="     "
            fi
            
            if [ "${choices[$i]}" = true ]; then
                echo -e "${prefix}[${GREEN}X${NC}] ${options[$i]}"
            else
                echo -e "${prefix}[ ] ${options[$i]}"
            fi
        done
        echo -e "\n${BLUE}==================================================${NC}"

        IFS= read -r -s -n1 key
        
        if [[ $key == $'\e' ]]; then
            read -r -s -n2 key
            if [[ $key == "[A" ]]; then # Up Arrow
                current_selection=$((current_selection - 1))
                [ $current_selection -lt 0 ] && current_selection=$((${#options[@]} - 1))
            elif [[ $key == "[B" ]]; then # Down Arrow
                current_selection=$((current_selection + 1))
                [ $current_selection -ge ${#options[@]} ] && current_selection=0
            fi
        elif [[ $key == " " ]]; then # Spacebar
            if [ "$current_selection" -lt 3 ]; then
                if [ "${choices[$current_selection]}" = true ]; then
                    choices[$current_selection]=false
                else
                    choices[$current_selection]=true
                fi
            fi
        elif [[ $key == "" ]]; then # Enter Key
            break
        fi
    done

    # Restore the cursor visibility
    tput cnorm

    CH_IDE=${choices[0]}
    CH_MANAGER=${choices[1]}
    CH_CLI=${choices[2]}

    echo -e "\n${BLUE}[*] Running execution scripts for selected components...${NC}"

    TMP_DIR="/tmp/ag_installer_tmp"
    mkdir -p "$TMP_DIR"

    if [ "$CH_MANAGER" = true ]; then
        echo -e "${YELLOW}[*] Fetching latest Agent Manager...${NC}"
        download_url=$(curl -s "https://antigravity-auto-updater-974169037036.us-central1.run.app/api/update/linux-x64/stable/latest" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
        if [ -z "$download_url" ]; then
            echo -e "${RED}[X] Error: Could not fetch Agent Manager download URL.${NC}"
            exit 1
        fi
        tar_path_manager="$TMP_DIR/Antigravity.tar.gz"
        curl -# -L -o "$tar_path_manager" "$download_url"
        echo -e "${GREEN}[✓] Download complete.${NC}"
        echo -e "${YELLOW}[*] Stopping any running Agent Manager instances...${NC}"
        pkill -f /opt/antigravity2/antigravity || true

        echo -e "${YELLOW}[*] Extracting Agent Manager platform...${NC}"
        
        sudo mkdir -p /opt/antigravity2
        sudo tar -xzf "$tar_path_manager" -C /opt/
        
        if [ -d "/opt/Antigravity-x64" ]; then
            sudo cp -a --remove-destination /opt/Antigravity-x64/. /opt/antigravity2/
            sudo rm -rf /opt/Antigravity-x64
        fi
        
        sudo chmod -R 755 /opt/antigravity2
        sudo chmod 4755 /opt/antigravity2/chrome-sandbox 2>/dev/null || true
        rm -f "$tar_path_manager"
    fi

    if [ "$CH_IDE" = true ]; then
        echo -e "${YELLOW}[*] Fetching latest Antigravity IDE...${NC}"
        download_url=$(curl -s "https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/api/update/linux-x64/stable/latest" | grep -o '"url":"[^"]*"' | cut -d'"' -f4 | sed 's/ /%20/g')
        if [ -z "$download_url" ]; then
            echo -e "${RED}[X] Error: Could not fetch IDE download URL.${NC}"
            exit 1
        fi
        tar_path_ide="$TMP_DIR/Antigravity-IDE.tar.gz"
        curl -# -L -o "$tar_path_ide" "$download_url"
        echo -e "${GREEN}[✓] Download complete.${NC}"
        echo -e "${YELLOW}[*] Stopping any running Antigravity IDE instances...${NC}"
        pkill -f /opt/antigravity-ide/antigravity-ide || true

        echo -e "${YELLOW}[*] Extracting IDE platform...${NC}"
        
        sudo mkdir -p /opt/antigravity-ide
        sudo tar -xzf "$tar_path_ide" -C /opt/
        
        # Normalize extraction folder if it extracts to a different name
        extracted_ide_dir=$(find /opt -maxdepth 1 -iname "*antigravity*ide*" ! -path "/opt/antigravity-ide" -type d -print -quit)
        if [ -n "$extracted_ide_dir" ] && [ -d "$extracted_ide_dir" ]; then
            sudo cp -a --remove-destination "$extracted_ide_dir"/. /opt/antigravity-ide/
            sudo rm -rf "$extracted_ide_dir"
        fi
        
        sudo chmod -R 755 /opt/antigravity-ide
        sudo chmod 4755 /opt/antigravity-ide/chrome-sandbox 2>/dev/null || true
        rm -f "$tar_path_ide"
    fi

    if [ "$CH_IDE" = true ]; then
        echo -e "${YELLOW}[*] Deploying V2 IDE components...${NC}"
        cat << EOF > "$HOME/.local/share/applications/antigravity-ide-v2.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity IDE 2.0
Exec=/opt/antigravity-ide/antigravity-ide %U
Icon=antigravity
Terminal=false
Categories=Development;
EOF
        chmod +x "$HOME/.local/share/applications/antigravity-ide-v2.desktop"
    fi

    if [ "$CH_MANAGER" = true ]; then
        echo -e "${YELLOW}[*] Deploying Standalone Agent Manager panel...${NC}"
        cat << EOF > "$HOME/.local/share/applications/antigravity-agent-manager.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity Agent Manager
Exec=/opt/antigravity2/antigravity %U
Icon=antigravity
Terminal=false
Categories=Utility;
EOF
        chmod +x "$HOME/.local/share/applications/antigravity-agent-manager.desktop"
    fi

    # Update system applications database to register the new icons
    if [ "$CH_IDE" = true ] || [ "$CH_MANAGER" = true ]; then
        update-desktop-database "$HOME/.local/share/applications/" || true
    fi

    if [ "$CH_CLI" = true ]; then
        echo -e "${YELLOW}[*] Fetching and linking CLI Engine (agy)...${NC}"
        # Force a fresh install by wiping the old binary exactly as the notice requested
        rm -f "$HOME/.local/bin/agy"
        curl -fsSL https://antigravity.google/cli/install.sh | bash || echo -e "${RED}[X] CLI setup returned a script failure.${NC}"
    fi

    # Clean up the tmp directory
    rm -rf "$TMP_DIR"

    echo -e "\n${GREEN}[✓] All selected Version 2 components deployed successfully!${NC}"
else
    echo -e "${RED}[X] Invalid option selected. Exiting.${NC}"
    exit 1
fi
