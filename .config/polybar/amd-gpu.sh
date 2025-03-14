#!/usr/bin/env bash

# Base path for AMD GPU sysfs
GPU_BASE_PATH="/sys/class/drm/card1/device"

# Check if AMD GPU sysfs exists
if [ ! -d "$GPU_BASE_PATH" ]; then
    echo "---"
    exit 1
fi

# Get GPU usage
GPU_UTIL=$(cat "$GPU_BASE_PATH/gpu_busy_percent" 2>/dev/null || echo "N/A")

# Base path for hwmon (temperature and power readings)
HWMON_PATH="$GPU_BASE_PATH/hwmon/hwmon0"

# Get GPU temperature
TEMP_PATH="$HWMON_PATH/temp1_input"
if [ -f "$TEMP_PATH" ]; then
    GPU_TEMP=$(($(cat "$TEMP_PATH") / 1000)) # Convert from millidegrees to degrees
else
    GPU_TEMP="N/A"
fi

# Get GPU power usage
POWER_PATH="$HWMON_PATH/power1_average"
if [ -f "$POWER_PATH" ]; then
    GPU_POWER=$(($(cat "$POWER_PATH") / 1000000)) # Convert from microwatts to watts
else
    GPU_POWER="N/A"
fi

echo "GPU ${GPU_UTIL}%, ${GPU_TEMP}°C, ${GPU_POWER}W"
