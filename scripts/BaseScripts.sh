#!/bin/bash
# https://github.com/nieningproj/AutoBuild_Openwrt

Core(){
    Author=CodeTiger
    INCLUDE_SSR_Plus=true
    INCLUDE_Passwall=true
    INCLUDE_VSSR=true
    INCLUDE_mt7621_OC1000MHz=true
    INCLUDE_Enable_FirewallPort_53=true
    INCLUDE_Enable_Ipv6=true
    Change_Wifi=true
}

Diy-Part1() {
    Core
    Default_File="$GITHUB_WORKSPACE/lede/package/lean/default-settings/files/zzz-default-settings"
    Date=`date "+%Y/%m/%d"`
    Lede_Version="$(egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" ${Default_File})"
    mv -f Customize/banner $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config
    cd $GITHUB_WORKSPACE/lede/package/base-files/files/bin
    sed -i "s/192.168.1.1/10.10.1.1/g" config_generate
    sed -i "s/192.168/10.10/g" config_generate
    mkdir -p $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config
    mkdir -p  $GITHUB_WORKSPACE/lede/package/CodeTiger
    cd $GITHUB_WORKSPACE/lede/package/CodeTiger
    svn checkout https://github.com/openwrt/openwrt/trunk/package/kernel/mt76
    git clone https://github.com/jerrykuku/luci-theme-argon.git -b 18.06
    git clone https://github.com/jerrykuku/luci-app-argon-config.git
    if (( $INCLUDE_SSR_Plus == 'true' )); then
        cd $GITHUB_WORKSPACE/lede/package/CodeTiger
        git clone https://github.com/fw876/helloworld.git -b master
    fi
    if (( $INCLUDE_Passwall == 'true' )); then
        cd $GITHUB_WORKSPACE/lede/package/CodeTiger
        git clone https://github.com/xiaorouji/openwrt-passwall.git -b main
    fi
    if (( $INCLUDE_VSSR == 'true' )); then
        cd $GITHUB_WORKSPACE/lede/package/CodeTiger
        git clone https://github.com/jerrykuku/lua-maxminddb.git
        git clone https://github.com/jerrykuku/luci-app-vssr.git 
    fi
    if (( $INCLUDE_mt7621_OC1000MHz == 'true' )); then
        mv -f Customize/102-mt7621-fix-cpu-clk-add-clkdev.patch $GITHUB_WORKSPACE/lede/target/linux/ramips/patches-5.4
    fi
    if (( $INCLUDE_Enable_FirewallPort_53 == 'true' )); then
        sed -i "s?iptables?#iptables?g"  $GITHUB_WORKSPACE/lede/package/lean/default-settings/files/zzz-default-settings> /dev/null 2>&1
    fi
    if [ $Change_Wifi = 'true' ]; then
        mv -f Customize/wireless $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config
    fi
    mv -f Customize/mwan3 $GITHUB_WORKSPACE/ledepackage/feeds/packages/mwan3/files/etc/config
    sed -i "s?Openwrt?Openwrt Compiled By $Author?g" $GITHUB_WORKSPACE/lede/package/base-files/files/etc/banner
    sed -i "s?${Lede_Version}?${Lede_Version} Compiled by ${Author} [$Date]?g" $Default_File
    mv -f Customize/dhcp $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config
}