#!/bin/bash
# Smart RAM + CPU/GPU Cooler for Ubuntu with zram support
# by Tharin Fernando 🐧

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NC="\e[0m"

echo -e "${GREEN}=== Smart RAM and CPU/GPU Cooler ===${NC}"

# 1. Read CPU temperature (integer)
CPU_TEMP=$(sensors | awk '/Package id 0:/ {gsub(/\+|\.0°C/,"",$4); print $4}')

# 2. Show CPU usage & temp
echo -e "\n${YELLOW}CPU usage & temperature:${NC}"
top -bn1 | head -n 10
sensors | grep -E 'Package id 0|Core '

# 3. Downclock CPU & limit NVIDIA GPU if CPU is hot
GPU_POWER_LIMIT=20  # watts
CPU_DOWNCLOCK=2.0   # GHz

if [ "$CPU_TEMP" -ge 95 ]; then
    echo -e "${RED}⚠ CPU is hot ($CPU_TEMP°C). Downclocking CPU and limiting NVIDIA GPU power...${NC}"
    
    # CPU downclock
    sudo cpupower frequency-set -u ${CPU_DOWNCLOCK}GHz
    
    # NVIDIA MX230 power limit
    if command -v nvidia-smi &>/dev/null; then
        sudo nvidia-smi -i 0 -pl $GPU_POWER_LIMIT
    fi

elif [ "$CPU_TEMP" -le 90 ]; then
    echo -e "${GREEN}✅ CPU cooled ($CPU_TEMP°C). Restoring CPU and GPU performance...${NC}"
    
    # Restore CPU
    sudo cpupower frequency-set -g performance
    
    # Restore NVIDIA GPU power limit (default ~30W)
    if command -v nvidia-smi &>/dev/null; then
        sudo nvidia-smi -i 0 -pl 30
    fi
fi

# 4. Show memory before cleanup
echo -e "\n${YELLOW}Memory usage BEFORE:${NC}"
free -h

# 5. Drop caches (pagecache, dentries, inodes)
echo -e "\n${GREEN}→ Dropping caches...${NC}"
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"

# 6. Reset zram if it exists
ZRAM_DEVICE=$(lsblk -d -o NAME | grep "^zram")
if [ -n "$ZRAM_DEVICE" ]; then
    echo -e "${GREEN}→ Resetting zram device /dev/$ZRAM_DEVICE...${NC}"
    sudo swapoff /dev/$ZRAM_DEVICE
    sudo mkswap /dev/$ZRAM_DEVICE
    sudo swapon /dev/$ZRAM_DEVICE
else
    echo -e "${YELLOW}No zram device found. Skipping zram reset.${NC}"
fi

# 7. Show memory after cleanup
echo -e "\n${YELLOW}Memory usage AFTER:${NC}"
free -h

# 8. Detect known memory hogs
echo -e "\n${YELLOW}Checking for heavy apps...${NC}"

# Docker Desktop (QEMU)
if pgrep -f "qemu-system-x86_64.*docker" > /dev/null; then
    echo -e "${RED}⚠ Docker Desktop VM is running (~3–4 GB).${NC}"
fi

# Chrome
if pgrep -x "chrome" > /dev/null; then
    CHROME_MEM=$(ps aux | grep "[c]hrome" | awk '{sum+=$6} END {print sum/1024 " MB"}')
    echo -e "${RED}⚠ Chrome is active (≈ $CHROME_MEM).${NC}"
fi

# VSCode
if pgrep -x "code" > /dev/null; then
    VSCODE_MEM=$(ps aux | grep "[c]ode" | awk '{sum+=$6} END {print sum/1024 " MB"}')
    echo -e "${RED}⚠ VSCode is active (≈ $VSCODE_MEM).${NC}"
fi

echo -e "\n${GREEN}✅ Done!${NC}"
