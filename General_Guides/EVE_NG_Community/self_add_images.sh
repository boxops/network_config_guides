#!/bin/bash

# Upload the downloaded images to the EVE "/opt/unetlab/addons/qemu/" folder.
# Example: scp <image.qcow2> root@eve.local:/opt/unetlab/addons/qemu/

# Load Juniper vSRX
# https://www.eve-ng.net/index.php/documentation/howtos/howto-add-juniper-vsrx-ng-15-x-and-later/
juniper_vsrx () {
    FOLDER='vsrxng-20.1R1.11'
    IMAGE='junos-vsrx3-x86-64-20.1R1.11.qcow2'
    # Create the image folder
    mkdir /opt/unetlab/addons/qemu/$FOLDER/
    # Move the image to the folder and rename the original filename to virtioa.qcow2
    mv /opt/unetlab/addons/qemu/$IMAGE /opt/unetlab/addons/qemu/$FOLDER/virtioa.qcow2
    # Fix permissions
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
}

# Load Juniper vMX
# https://www.eve-ng.net/index.php/documentation/howtos/howto-add-juniper-vmx-16-x-17-x/
juniper_vmx () {
    FOLDER_VCP='vmxvcp-18.2R1.9-domestic-VCP'
    IMAGE_VCP_A='junos-vmx-x86-64-18.2R1.9.qcow2'
    IMAGE_VCP_B='vmxhdd.img'
    IMAGE_VCP_C='metadata-usb-re.img'

    FOLDER_VFP='vmxvcp-18.2R1.9-domestic-VFP'
    IMAGE_VFP='vFPC-20180605.img'

    # Create VCP image folder
    mkdir /opt/unetlab/addons/qemu/$FOLDER_VCP/
    # Move the images to VCP image folder
    # virtioa.qcow2 (e.g. junos-vmx-x86-64-17.1R1.8.qcow2)
    mv /opt/unetlab/addons/qemu/$IMAGE_VCP_A /opt/unetlab/addons/qemu/$FOLDER_VCP/virtioa.qcow2
    # virtiob.qcow2 (vmxhdd.img)
    mv /opt/unetlab/addons/qemu/$IMAGE_VCP_B /opt/unetlab/addons/qemu/$FOLDER_VCP/virtiob.qcow2
    # virtioc.qcow2 (metadata-usb-re.img)
    mv /opt/unetlab/addons/qemu/$IMAGE_VCP_C /opt/unetlab/addons/qemu/$FOLDER_VCP/virtioc.qcow2

    # Create VPF image folder
    mkdir /opt/unetlab/addons/qemu/$FOLDER_VFP/
    # Copy the images to VPF image folder
    # virtioa.qcow2 (e.g. vFPC-20170216.img)
    mv /opt/unetlab/addons/qemu/$IMAGE_VFP /opt/unetlab/addons/qemu/$FOLDER_VFP/virtioa.qcow2

    # Fix permissions
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions

    # Notes: Add VCP and VFP nodes on the topology and connect them with em1 interfaces. em1 interface is communication port between VCP and VFP. This setup will be one vMX 17 node (set of 2). Use VFP to connect your lab element to the ports.
    # Start VCP and VFP set and wait till it is fully boots. Once VCP will be fully booted it will automatically start communicate with VFP. WAIT till on VFP cli appears that interfaces are UP. When VFP will say interfaces are UP, on the VCP appears ge-0/0/X interfaces and node is ready for work.
    # Default username is admin without password.
}
