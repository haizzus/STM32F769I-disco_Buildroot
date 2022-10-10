TOPDIR=$(PWD)
url_buildroot = https://buildroot.org/downloads/buildroot-2018.02.tar.gz
archive_buildroot = buildroot.tar.gz
dir_download = downloads
dir_configs = configs
dir_buildroot = buildroot
dir_publish = $(TOPDIR)/srv/tftp/stm32f769

bootstrap:
	mkdir -p $(dir_download)
	mkdir -p $(dir_buildroot)
	wget -O $(dir_download)/$(archive_buildroot) $(url_buildroot)
	tar zxvf $(dir_download)/$(archive_buildroot) -C $(dir_buildroot) --strip-components=1
	cp $(dir_configs)/buildroot $(dir_buildroot)/.config
	# workaround for m4 build error, upgrade form 1.4.18 -> 1.4.19
	cp -f $(TOPDIR)/patches/buildroot/package/m4/* $(TOPDIR)/buildroot/package/m4

build:
	mkdir -p $(dir_publish)
	make -j10 -C $(dir_buildroot)
	cp $(dir_buildroot)/output/images/stm32f769-disco.dtb ${dir_publish}/
	cp $(dir_buildroot)/output/images/zImage ${dir_publish}/

flash_bootloader:
	cd $(dir_buildroot)/output/build/host-openocd-0.10.0/tcl && ../../../host/usr/bin/openocd \
		-f board/stm32f7discovery.cfg \
		-c "program ../../../images/u-boot-spl.bin 0x08000000" \
		-c "program ../../../images/u-boot.bin 0x08008000" \
		-c "reset run" -c shutdown

clean:
	rm -rf $(dir_buildroot) $(dir_download)
