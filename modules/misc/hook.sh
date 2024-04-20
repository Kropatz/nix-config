exec 19>>/home/kopatz/Desktop/stoplogfile
BASH_XTRACEFD=19
set -x
set +o errexit
set +o nounset
set +o pipefail
GUEST_NAME="$1"
HOOK_NAME="$2"
STATE_NAME="$3"
GPU_PCI="pci_0000_2B_00_0"
GPU_AUDIO_PCI="pci_0000_2B_00_1"
GPU_MODULES="nvidia_drm nvidia_modeset nvidia_uvm nvidia"

if [ "$GUEST_NAME" != "gpu_passthrough" ]; then
    exit 0
fi

if [ "$HOOK_NAME" == "prepare" ] && [ "$STATE_NAME" == "begin" ]; then
    # Unbind VTconsoles
    echo 0 > /sys/class/vtconsole/vtcon0/bind
    echo 0 > /sys/class/vtconsole/vtcon1/bind

    # Unbind EFI Framebuffer
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

    # Stop plasma
    systemctl --user --machine=kopatz@ stop plasma-\*
    systemctl stop display-manager.service

    sleep 2

    # Start default network
    virsh net-start default

    # Unload AMDGPU kernel module
    modprobe -r $GPU_MODULES

    # Detach GPU from host
    virsh nodedev-detach $GPU_PCI
    virsh nodedev-detach $GPU_AUDIO_PCI

    sleep 10

    # Load VFIO kernel modules
    modprobe vfio_pci
    exit 0
elif [ "$HOOK_NAME" == "release" ] && [ "$STATE_NAME" == "end" ]; then
    # Stop default network
    virsh net-destroy default

    # Unload VFIO kernel modules
    modprobe -r vfio-pci

    # Reattach GPU TO host
    virsh nodedev-reattach $GPU_PCI
    virsh nodedev-reattach $GPU_AUDIO_PCI

    sleep 5

    # Load NVIDIA kernel modules
    modprobe $GPU_MODULES

    sleep 2

    # Bind EFI Framebuffer
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind


    # Bind VTconsoles
    echo 1 > /sys/class/vtconsole/vtcon0/bind
    echo 1 > /sys/class/vtconsole/vtcon1/bind

    # Start DM
    systemctl start display-manager.service
fi
