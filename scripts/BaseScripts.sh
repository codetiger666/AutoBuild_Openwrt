#!/bin/bash
# https://github.com/nieningproj/AutoBuild_Openwrt

Core_Newifi_D2(){
    Author=CodeTiger
    INCLUDE_SSR_Plus=true
    INCLUDE_Passwall=true
    INCLUDE_VSSR=true
    INCLUDE_mt7621_OC1000MHz=true
    INCLUDE_Enable_FirewallPort_53=true
    INCLUDE_Enable_Ipv6=true
    Change_Wifi=true
    INCLUDE_Enable_MWan3=true
    Change_Dhcp=true
}

Core_x86_64(){
    Author=CodeTiger
    INCLUDE_SSR_Plus=true
    INCLUDE_Passwall=true
    INCLUDE_VSSR=true
}

Diy-Part1() {
    if [ "$DRIVE_LABLE" == "newifi_D2" ];then
        Core_Newifi_D2
    fi
    if [ "$DRIVE_LABLE" == "x86_64" ];then
        Core_x86_64
    fi
    Default_File="$GITHUB_WORKSPACE/lede/package/lean/default-settings/files/zzz-default-settings"
    Date=`date "+%Y/%m/%d"`
    Lede_Version="$(egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" ${Default_File})"
    mkdir -p $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config > /dev/null 2>1
    cd $GITHUB_WORKSPACE/lede
    git clone https://github.com/nieningproj/openwrt_dl.git dl
    cd $GITHUB_WORKSPACE
    mv -f Customize/banner $GITHUB_WORKSPACE/lede/package/base-files/files/etc
    cd $GITHUB_WORKSPACE/lede/package/base-files/files/bin
    sed -i "s/192.168.1.1/10.10.1.1/g" config_generate
    sed -i "s/192.168/10.10/g" config_generate
    mkdir -p $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config > /dev/null 2>1
    mkdir -p  $GITHUB_WORKSPACE/lede/package/CodeTiger > /dev/null 2>1
    cd $GITHUB_WORKSPACE/lede/package/CodeTiger
    # svn checkout https://github.com/openwrt/openwrt/trunk/package/kernel/mt76
    git clone https://github.com/jerrykuku/luci-theme-argon.git -b 18.06
    git clone https://github.com/jerrykuku/luci-app-argon-config.git
    if [ "$INCLUDE_SSR_Plus" == "true" ]; then
        cd $GITHUB_WORKSPACE/lede/package/CodeTiger
        git clone https://github.com/fw876/helloworld.git -b master
    fi
    if [ "$INCLUDE_Passwall" == "true" ]; then
        cd $GITHUB_WORKSPACE/lede/package/CodeTiger
        git clone https://github.com/xiaorouji/openwrt-passwall.git -b main
    fi
    if [ "$INCLUDE_VSSR" == "true" ]; then
        cd $GITHUB_WORKSPACE/lede/package/CodeTiger
        git clone https://github.com/jerrykuku/lua-maxminddb.git
        git clone https://github.com/jerrykuku/luci-app-vssr.git 
    fi
    if [ "$INCLUDE_OpenClash" == "true" ]; then
        cd $GITHUB_WORKSPACE/lede/package/CodeTiger
        git clone https://github.com/vernesong/OpenClash.git
    fi
    if [ "$INCLUDE_mt7621_OC1000MHz" == "true" ]; then
        cd $GITHUB_WORKSPACE
        mv -f Customize/102-mt7621-fix-cpu-clk-add-clkdev.patch $GITHUB_WORKSPACE/lede/target/linux/ramips/patches-5.4
    fi
    if [ "$INCLUDE_Enable_FirewallPort_53" == 'true' ]; then
        sed -i "s?iptables?#iptables?g"  $GITHUB_WORKSPACE/lede/package/lean/default-settings/files/zzz-default-settings> /dev/null 2>&1
    fi
    if [ "$Change_Wifi" == 'true' ]; then
        cd $GITHUB_WORKSPACE
        mv -f Customize/wireless $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config
    fi
    if [ "$INCLUDE_Enable_Ipv6" == 'true' ]; then
        cd $GITHUB_WORKSPACE
        mkdir -p $GITHUB_WORKSPACE/lede/package/base-files/files/etc/hotplug.d/iface
        mv -f Customize/90-ipv6 $GITHUB_WORKSPACE/lede/package/base-files/files/etc/hotplug.d/iface
        sed -i '41a\echo "'"ip6tables -t nat -A POSTROUTING -o eth0.2 -j MASQUERADE"'" >> \/etc\/firewall.user' $GITHUB_WORKSPACE/lede/package/lean/default-settings/files/zzz-default-settings 
    fi
    if [ "$INCLUDE_Enable_MWan3" == 'true' ]; then
        cd $GITHUB_WORKSPACE
        mv -f Customize/mwan3 $GITHUB_WORKSPACE/lede/package/feeds/packages/mwan3/files/etc/config
    fi
    sed -i "s?Openwrt?Openwrt Compiled By $Author?g" $GITHUB_WORKSPACE/lede/package/base-files/files/etc/banner
    sed -i "s?${Lede_Version}?${Lede_Version} Compiled by ${Author} [$Date]?g" $Default_File
    if [ "$Change_Dhcp" == 'true' ];then
        mv -f Customize/dhcp $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config
    fi
}

Diy-Part2() {
    Date=`date "+%Y%m%d"`
    ARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
    TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)"
	TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)"
    TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
    Default_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
	AutoBuild_Firmware="AutoBuild-${TARGET_PROFILE}-${Date}.bin"
	AutoBuild_Detail="AutoBuild-${TARGET_PROFILE}-${Date}.detail"
	mkdir bin/Firmware
	mv -f bin/targets/"${TARGET_BOARD}/${TARGET_SUBTARGET}/${Default_Firmware}" bin/Firmware/"${AutoBuild_Firmware}"
	_MD5=$(md5sum bin/Firmware/${AutoBuild_Firmware} | cut -d ' ' -f1)
	_SHA256=$(sha256sum bin/Firmware/${AutoBuild_Firmware} | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > bin/Firmware/"${AutoBuild_Detail}"
}

Diy-Part2_x86_64() {
    Date=`date "+%Y%m%d"`
	mkdir bin/Firmware
	mv -f bin/targets/x86/64/openwrt-x86-64-*-combined-efi.img.gz bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz"
    mv -f bin/targets/x86/64/openwrt-x86-64-*-combined.img.gz bin/Firmware/"openwrt-x86-64-$Date.img.gz"
	_MD5_efi=$(md5sum bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz" | cut -d ' ' -f1)
    _MD5=$(md5sum bin/Firmware/"openwrt-x86-64-$Date.img.gz" | cut -d ' ' -f1)
	_SHA256_efi=$(sha256sum bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz" | cut -d ' ' -f1)
    _SHA256=$(sha256sum bin/Firmware/"openwrt-x86-64-$Date.img.gz" | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > bin/Firmware/"openwrt-x86-64-$Date.detail"
    echo -e "\nMD5:${_MD5_efi}\nSHA256:${_SHA256_efi}" > bin/Firmware/"openwrt-x86-64-efi-$Date.detail"
}