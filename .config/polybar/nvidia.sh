#!/usr/bin/env bash
nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader | xargs -I {} echo "GPU: {}°C"
