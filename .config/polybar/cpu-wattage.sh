#!/usr/bin/env bash
wattage=$(sensors zenpower-pci-00c3 | grep SVI2_P_Core | sed "s/SVI2_P_Core:  //g")

if [ -z "$wattage" ]; then
  wattage=""
fi

echo "$wattage"
