# convert a qcow2 vm to a VirtualBox vm format
qemu-img convert -O vdi gnome.qcow2 gnome.vdi

#if its a raw image then:
VBoxManage convertdd opnstk.raw VBox.vdi --format VDI
