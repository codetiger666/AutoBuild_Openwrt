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
    Replace_File Customize/banner $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config
    cd $GITHUB_WORKSPACE/lede/package/base-files/files/bin
    sed -i "s/192.168.1.1/10.10.1.1/g" config_generate
    sed -i "s/192.168/10.10/g" config_generate
    ExtraPackages svn kernel mt76 https://github.com/openwrt/openwrt/trunk/package/kernel
    if (( $INCLUDE_SSR_Plus == 'true' )); then
        cd $GITHUB_WORKSPACE/lede/package
        ExtraPackages git CodeTiger helloworld https://github.com/fw876 master
    fi
    if (( $INCLUDE_Passwall == 'true' )); then
        cd $GITHUB_WORKSPACE/lede/package
        ExtraPackages git CodeTiger openwrt-passwall https://github.com/xiaorouji main
    fi
    if (( $INCLUDE_VSSR == 'true' )); then
        cd $GITHUB_WORKSPACE/lede/package
        ExtraPackages git CodeTiger lua-maxminddb https://github.com/jerrykuku master
        ExtraPackages git CodeTiger luci-app-vssr https://github.com/jerrykuku master
    fi
    if (( $INCLUDE_mt7621_OC1000MHz == 'true' )); then
        Replace_File Customize/102-mt7621-fix-cpu-clk-add-clkdev.patch $GITHUB_WORKSPACE/lede/target/linux/ramips/patches-5.4
    fi
    if (( $INCLUDE_Enable_FirewallPort_53 == 'true' )); then
        sed -i "s?iptables?#iptables?g"  $GITHUB_WORKSPACE/lede/package/lean/default-settings/files/zzz-default-settings> /dev/null 2>&1
    fi
    if [ $Change_Wifi = 'true' ]; then
        Replace_File Customize/wireless $GITHUB_WORKSPACE/lede/package/base-files/files/etc/config
    fi
    Replace_File Customize/mwan3 $GITHUB_WORKSPACE/ledepackage/feeds/packages/mwan3/files/etc/config
    sed -i "s?Openwrt?Openwrt Compiled By $Author?g" $GITHUB_WORKSPACE/lede/package/base-files/files/etc/banner
    sed -i "s?${Lede_Version}?${Lede_Version} Compiled by ${Author} [$Date]?g" $Default_File
    Replace_File Customize/dhcp $GITHUB_WORKSPACE/ledepackage/feeds/packages/mwan3/files/etc/config
}