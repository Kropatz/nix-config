#!/usr/bin/env bash
# if nvidia-smi is not present return nothing
if ! command -v nvidia-smi &> /dev/null; then
    echo "---"
fi
nvidia-smi --query-gpu=utilization.gpu,power.draw,temperature.gpu --format=csv,noheader | xargs -I {} echo "GPU: {}°C"
