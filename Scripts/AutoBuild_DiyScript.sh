#!/bin/bash
# https://github.com/nieningproj/AutoBuild_Openwrt

Diy_Core() {
	Author=CodeTiger
	Default_Device=d-team_newifi-d2

	ChangeLanIp=true
	INCLUDE_AutoUpdate=true
	INCLUDE_AutoBuild_Tools=false
	INCLUDE_SSR_Plus=true
	INCLUDE_Passwall=true
	INCLUDE_Keep_Latest_Xray=false
	INCLUDE_mt7621_OC1000MHz=true
	INCLUDE_Enable_FirewallPort_53=false
	INCLUDE_VSSR=true
}

Diy-Part1() {
	Diy_Part1_Base
	
	Replace_File Customize/mac80211.sh package/kernel/mac80211/files/lib/wifi
	if [ "${Default_Device}" == "d-team_newifi-d2" ];then
		Replace_File Customize/system_newifi-d2 package/base-files/files/etc/config system
	else
		Replace_File Customize/system_common package/base-files/files/etc/config system
	fi
	Replace_File Customize/banner package/base-files/files/etc
	
	Update_Makefile exfat package/kernel/exfat

	# ExtraPackages svn network/services dnsmasq https://github.com/openwrt/openwrt/trunk/package/network/services
	# ExtraPackages svn network/services dropbear https://github.com/openwrt/openwrt/trunk/package/network/services
	# ExtraPackages svn network/services ppp https://github.com/openwrt/openwrt/trunk/package/network/services
	# ExtraPackages svn network/services hostapd https://github.com/openwrt/openwrt/trunk/package/network/services
	ExtraPackages svn kernel mt76 https://github.com/openwrt/openwrt/trunk/package/kernel

	ExtraPackages git lean helloworld https://github.com/fw876 master
	ExtraPackages git lean luci-theme-argon https://github.com/jerrykuku 18.06
	ExtraPackages git other luci-app-argon-config https://github.com/jerrykuku master
	ExtraPackages svn other luci-app-openclash https://github.com/vernesong/OpenClash/trunk
	ExtraPackages git other luci-app-serverchan https://github.com/tty228 master
	ExtraPackages svn other luci-app-socat https://github.com/Lienol/openwrt-package/trunk
	ExtraPackages svn other luci-app-usb3disable https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw
}

Diy-Part2() {
	Diy_Part2_Base
	Replace_File Customize/mwan3.config package/feeds/packages/mwan3/files/etc/config mwan3
	# ExtraPackages svn feeds/packages mwan3 https://github.com/openwrt/packages/trunk/net
}

Diy-Part3() {
	Diy_Part3_Base
}
