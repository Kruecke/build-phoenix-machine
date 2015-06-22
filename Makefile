.PHONY: all
all: sysinstall build-ubuntu

.PHONY: sysinstall
sysinstall:
	sudo apt-get -y update
	sudo apt-get -y install virtualbox virtualbox-dkms

.PHONY: build-ubuntu
build-ubuntu: ubuntu.iso
	VBoxManage createvm --name ubuntu-phoenix --ostype Ubuntu_64 --register
	VBoxManage modifyvm ubuntu-phoenix --memory 512
	VBoxManage createhd --filename ubuntu-phoenix-hd --size 10240
	VBoxManage storagectl ubuntu-phoenix --name satactl --add sata --bootable on
	VBoxManage storageattach ubuntu-phoenix --storagectl satactl --port 0 --type hdd --medium ubuntu-phoenix-hd.vdi
	VBoxManage storageattach ubuntu-phoenix --storagectl satactl --port 1 --type dvddrive --medium ubuntu.iso
	VBoxManage startvm ubuntu-phoenix

ubuntu.iso: mini.iso
	# Extract ISO
	mkdir -p mnt_iso ubuntu
	sudo mount -o loop mini.iso mnt_iso
	cp -rT mnt_iso ubuntu
	chmod -R +w ubuntu
	sudo umount mnt_iso
	# Prepare Image
	cp ubuntu-preseed.cfg ubuntu/preseed.cfg
	echo "totaltimeout 1" >> ubuntu/isolinux.cfg
	sed -i "/\tappend vga=788 initrd=initrd.gz --- quiet/c\\\tappend vga=788 initrd=initrd.gz preseed/file=/cdrom/preseed.cfg preseed/file/checksum=$(shell md5sum ubuntu-preseed.cfg | grep -Eo '^[^ ]+') debian-installer/locale=en_US netcfg/choose_interface=auto debconf/priority=critical ---" ubuntu/txt.cfg
	# Build new ISO
	mkisofs -o ubuntu.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table ubuntu
	# Clean up
	rm -rf ubuntu mnt_iso

mini.iso:
	wget http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-amd64/current/images/netboot/mini.iso

.PHONY: clean
clean:
	VBoxManage unregistervm ubuntu-phoenix --delete
	rm -rf *.vdi
	rm -rf ubuntu.iso
