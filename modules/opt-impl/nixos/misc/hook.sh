#exec 19>>/home/kopatz/Desktop/stoplogfile
#BASH_XTRACEFD=19
#set -x
#set +o errexit
#set +o nounset
#set +o pipefail
GUEST_NAME="$1"
HOOK_NAME="$2"
STATE_NAME="$3"
GPU_PCI="pci_0000_2b_00_0"
GPU_AUDIO_PCI="pci_0000_2b_00_1"
#GPU_MODULES="nvidia_uvm nvidia_drm nvidia_modeset nvidia"
set -x

if [[ ! "$GUEST_NAME" =~ ^gpu_passthrough ]]; then
    exit 0
fi

if [ "$HOOK_NAME" == "prepare" ] && [ "$STATE_NAME" == "begin" ]; then
    # Stop plasma
    systemctl stop display-manager.service

    echo 0 > /sys/class/vtconsole/vtcon0/bind
    echo 0 > /sys/class/vtconsole/vtcon1/bind
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
    
    sleep 2

    # Unload kernel module
    rmmod nvidia_uvm
    rmmod nvidia_drm
    rmmod nvidia_modeset
    rmmod nvidia

    # Detach GPU from host
    virsh nodedev-detach $GPU_PCI
    virsh nodedev-detach $GPU_AUDIO_PCI

    # Load VFIO kernel modules
    modprobe vfio-pci
elif [ "$HOOK_NAME" == "release" ] && [ "$STATE_NAME" == "end" ]; then
    # Unload VFIO kernel modules
    #modprobe -r vfio-pci

    # Reattach GPU TO host
    virsh nodedev-reattach $GPU_PCI
    virsh nodedev-reattach $GPU_AUDIO_PCI


    # Load NVIDIA kernel modules
    modprobe nvidia
    modprobe nvidia_modeset
    modprobe nvidia_drm
    modprobe nvidia_uvm

    echo 1 > /sys/class/vtconsole/vtcon0/bind
    echo 1 > /sys/class/vtconsole/vtcon1/bind
    echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
    # Start DM
    systemctl start display-manager.service
fi
