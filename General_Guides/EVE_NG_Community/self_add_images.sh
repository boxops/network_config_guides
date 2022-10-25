#!/bin/bash

# Upload the downloaded images to the EVE "/opt/unetlab/addons/qemu/" folder.
# Example: scp <image.qcow2> root@eve.local:/opt/unetlab/addons/qemu/

# Usage: Call a function by passing its name as an argument to the script when executing it
# e.g ./self_add_images.sh cisco_vios

juniper_vsrx () {
    # https://www.eve-ng.net/index.php/documentation/howtos/howto-add-juniper-vsrx-ng-15-x-and-later/
    FOLDER='vsrxng-20.1R1.11'
    IMAGE='junos-vsrx3-x86-64-20.1R1.11.qcow2'
    # Create the image folder
    mkdir /opt/unetlab/addons/qemu/$FOLDER/
    # Move the image to the folder and rename the original filename to virtioa.qcow2
    mv /opt/unetlab/addons/qemu/$IMAGE /opt/unetlab/addons/qemu/$FOLDER/virtioa.qcow2
    # Fix permissions
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
    # Readd exe permissions
    readd_exe_perm
}

juniper_vmx () {
    # https://www.eve-ng.net/index.php/documentation/howtos/howto-add-juniper-vmx-16-x-17-x/
    # Copy over the extracted vmx folder to the eve path /opt/unetlab/addons/qemu/
    # scp -r vmx root@eve.local:/opt/unetlab/addons/qemu/
    FOLDER_VCP='vmxvcp-18.2R1.9-domestic-VCP'
    IMAGE_VCP_A='junos-vmx-x86-64-18.2R1.9.qcow2'
    IMAGE_VCP_B='vmxhdd.img'
    IMAGE_VCP_C='metadata-usb-re.img'

    FOLDER_VFP='vmxvfp-18.2R1.9-domestic-VFP'
    IMAGE_VFP='vFPC-20180605.img'

    # Create VCP image folder
    mkdir /opt/unetlab/addons/qemu/$FOLDER_VCP/
    # Move the images to VCP image folder
    # virtioa.qcow2 (e.g. junos-vmx-x86-64-17.1R1.8.qcow2)
    cp /opt/unetlab/addons/qemu/vmx/images/$IMAGE_VCP_A /opt/unetlab/addons/qemu/$FOLDER_VCP/virtioa.qcow2
    # virtiob.qcow2 (vmxhdd.img)
    cp /opt/unetlab/addons/qemu/vmx/images/$IMAGE_VCP_B /opt/unetlab/addons/qemu/$FOLDER_VCP/virtiob.qcow2
    # virtioc.qcow2 (metadata-usb-re.img)
    cp /opt/unetlab/addons/qemu/vmx/images/$IMAGE_VCP_C /opt/unetlab/addons/qemu/$FOLDER_VCP/virtioc.qcow2

    # Create VPF image folder
    mkdir /opt/unetlab/addons/qemu/$FOLDER_VFP/
    # Copy the images to VPF image folder
    # virtioa.qcow2 (e.g. vFPC-20170216.img)
    cp /opt/unetlab/addons/qemu/vmx/images/$IMAGE_VFP /opt/unetlab/addons/qemu/$FOLDER_VFP/virtioa.qcow2

    # Fix permissions
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions

    # Readd exe permissions
    readd_exe_perm

    # Clean up the vmx folder
    # rm -rf /opt/unetlab/addons/qemu/vmx

    # Notes: Add VCP and VFP nodes on the topology and connect them with em1 interfaces. em1 interface is communication port between VCP and VFP. This setup will be one vMX 17 node (set of 2). Use VFP to connect your lab element to the ports.
    # Start VCP and VFP set and wait till it is fully boots. Once VCP will be fully booted it will automatically start communicate with VFP. WAIT till on VFP cli appears that interfaces are UP. When VFP will say interfaces are UP, on the VCP appears ge-0/0/X interfaces and node is ready for work.
    # Default username is admin without password.
}

cisco_xrv () {
    # https://www.eve-ng.net/index.php/documentation/howtos/howto-add-cisco-xrv/
    FOLDER='xrv-k9-6.0.1'
    VMDK_IMAGE='iosxrv-demo.vmdk'
    # Convert the disk to the qcow2 format
    # /opt/qemu/bin/qemu-img convert -f vmdk -O qcow2 $VMDK_IMAGE hda.qcow2
    # Create the folder for HDD image
    mkdir /opt/unetlab/addons/qemu/$FOLDER
    # Move image to folder
    mv /opt/unetlab/addons/qemu/hda.qcow2 /opt/unetlab/addons/qemu/$FOLDER/
    # Fix permissions
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
    # Readd exe permissions
    readd_exe_perm
}

cisco_iosvl2 () {
    # https://www.eve-ng.net/index.php/documentation/howtos/howto-add-cisco-vios-from-virl/
    FOLDER='viosl2-adventerprisek9-m.03.2017'
    IMAGE='vios_l2-adventerprisek9-m.03.2017.qcow2'
    # Create image folder
    mkdir /opt/unetlab/addons/qemu/$FOLDER
    # Move and rename image to folder
    mv /opt/unetlab/addons/qemu/$IMAGE /opt/unetlab/addons/qemu/$FOLDER/virtioa.qcow2
    # Fix permissions
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
    # Readd exe permissions
    readd_exe_perm
}

cisco_vios () {
    # https://www.eve-ng.net/index.php/documentation/howtos/howto-add-cisco-vios-from-virl/
    FOLDER='vios-adventerprisek9-m.vmdk.SPA.157-3'
    IMAGE='vios-adventerprisek9-m.vmdk.SPA.157-3.M3'
    # Create image folder
    mkdir /opt/unetlab/addons/qemu/$FOLDER
    # Move and rename original image filename to have .vmdk extension
    mv /opt/unetlab/addons/qemu/$IMAGE /opt/unetlab/addons/qemu/$FOLDER/$IMAGE.vmdk
    # Covert vmdk file to qcow format
    /opt/qemu/bin/qemu-img convert -f vmdk -O qcow2 /opt/unetlab/addons/qemu/$FOLDER/$IMAGE.vmdk /opt/unetlab/addons/qemu/$FOLDER/virtioa.qcow2
    # Delete raw vmdk image file from image folder
    rm /opt/unetlab/addons/qemu/$FOLDER/$IMAGE.vmdk
    # Fix permissions
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
    # Readd exe permissions
    readd_exe_perm
}

linux_new () {
    # https://www.eve-ng.net/index.php/documentation/howtos/howto-create-own-linux-host-image/
    # Install new ubuntu images downloaded from the source
    FOLDER='linux-ubuntu-desktop-22.04.01'
    IMAGE='ubuntu-22.04.1-desktop-amd64.iso'
    # Create new image directory
    mkdir /opt/unetlab/addons/qemu/$FOLDER
    # Move the image to the new directory and rename it to cdrom.iso
    mv /opt/unetlab/addons/qemu/$IMAGE /opt/unetlab/addons/qemu/$FOLDER/cdrom.iso
    # Create new HDD virtioa.qcow2. Example below is HDD 30Gb. Size you can change per your needs.
    /opt/qemu/bin/qemu-img create -f qcow2 /opt/unetlab/addons/qemu/$FOLDER/virtioa.qcow2 30G
    # Create new lab and add newly created node
    # Connect it to your home LAN cloud/internet, this need to get updates from internet
    # Start node in lab and do install of your Linux, customize it as you like, as you have connected it to home LAN and internet this install will be like normal Linux installation.
    # Remove cdrom.iso at the end
    # rm -rf /opt/unetlab/addons/qemu/$FOLDER/cdrom.iso

    # IMPORTANT: Commit the installation to set it as the default image for further use in EVE-NG
    # https://www.eve-ng.net/index.php/documentation/howtos/howto-create-own-linux-host-image/
}

linux_rdy () {
    # https://www.eve-ng.net/index.php/documentation/howtos/howto-create-own-linux-host-image/
    # Install ready to use Linux images supplied by EVE
    IMAGE='linux-ubuntu-22.04-desktop.tar.gz'
    # Unzip the uploaded image file
    tar xzvf /opt/unetlab/addons/qemu/$IMAGE
    # Remove the raw zipped image file
    rm -rf /opt/unetlab/addons/qemu/$IMAGE
    # Fix permissions
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
    # Readd exe permissions
    readd_exe_perm
}

readd_exe_perm () {
    # Readd removed execute permissions to itself
    chmod +x /opt/unetlab/addons/qemu/self_add_images.sh
}

# Expand to the arguments of the command line
"$@"
