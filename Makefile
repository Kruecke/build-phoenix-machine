.PHONY: all
all: sysinstall ubuntu-vm

.PHONY: sysinstall
sysinstall:
	sudo apt-get -y update
	sudo apt-get -y install virtualbox virtualbox-dkms
	sudo apt-get -y install virtualbox-qt # for now, maybe headless later

.PHONY: build-ubuntu
ubuntu-vm: unattended.iso
	VBoxManage createvm --name ubuntu-phoenix --ostype Ubuntu_64 --register
	VBoxManage modifyvm ubuntu-phoenix --memory 512
	VBoxManage createhd --filename ubuntu-phoenix-hd --size 10240
	VBoxManage storagectl ubuntu-phoenix --name satactl --add sata --bootable on
	VBoxManage storageattach ubuntu-phoenix --storagectl satactl --port 0 --type hdd --medium ubuntu-phoenix-hd.vdi
	VBoxManage storageattach ubuntu-phoenix --storagectl satactl --port 1 --type dvddrive --medium unattended.iso
	VBoxManage startvm ubuntu-phoenix

unattended.iso: ubuntu.iso ks.cfg
	# Extract ISO
	mkdir -p mnt_iso ubuntu
	sudo mount -o loop ubuntu.iso mnt_iso
	cp -rT mnt_iso ubuntu
	chmod -R +w ubuntu
	sudo umount mnt_iso
	# Prepare Image
	echo en > ubuntu/isolinux/langlist # does this do anything?
	sed -i "/timeout/c\timeout 10" ubuntu/isolinux/isolinux.cfg
	cp ks.cfg ubuntu/ks.cfg
	echo "d-i user-setup/allow-password-weak boolean true" >> ubuntu/preseed/ubuntu-server-minimalvm.seed
	#debian-installer/locale=en_US
	sed -i "/append.*preseed/c\  append file=/cdrom/preseed/ubuntu-server-minimalvm.seed initrd=/install/initrd.gz ks=cdrom:/ks.cfg" ubuntu/isolinux/txt.cfg
	# Build new ISO
	mkisofs -D -r -cache-inodes -J -l -o unattended.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table ubuntu

ubuntu.iso:
	# Download current Ubuntu 14.04 server image
	wget -O ubuntu.iso http://releases.ubuntu.com/14.04.2/ubuntu-14.04.2-server-amd64.iso

.PHONY: purge-vm
purge-vm: clean
	-VBoxManage unregistervm ubuntu-phoenix --delete
	rm -rf *.vdi

.PHONY: purge-iso
purge-iso: clean
	rm -rf *.iso

.PHONY: clean
clean:
	rm -rf ubuntu mnt_iso
