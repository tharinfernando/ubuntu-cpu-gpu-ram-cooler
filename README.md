# Ubuntu CPU/GPU/RAM Cooler 🐧

A smart Ubuntu script to help keep your system cool and optimize memory usage.  
It monitors CPU temperature, downclocks CPU and limits NVIDIA GPU if needed, drops caches, and resets zram.

## Features

- Monitor CPU temperature and usage  
- Downclock CPU & limit NVIDIA GPU when hot  
- Clear memory caches (pagecache, dentries, inodes)  
- Reset zram swap if available  
- Detect heavy applications (Chrome, VSCode, Docker Desktop)  

## Requirements

- Ubuntu (tested on Ubuntu 24.04.3 LTS)  
- `lm-sensors` for CPU temperature readings  
- `cpupower` for CPU frequency management  
- NVIDIA drivers for GPU power control (optional)

## Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/ubuntu-cpu-gpu-ram-cooler.git
cd ubuntu-cpu-gpu-ram-cooler
chmod +x ubuntu-cpu-gpu-ram-cooler.sh
