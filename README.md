# Repo for configuring OpenWrt on AX3200 Router

## Usage

```bash
./ansible.sh
```

## Manual things

* Set web ui password http://192.168.1.1/cgi-bin/luci/admin/system/admin/password
* Copy ssh key http://192.168.1.1/cgi-bin/luci/admin/system/admin/sshkeys
* Configure lan network interface 192.168.31.1/24 http://192.168.1.1/cgi-bin/luci/admin/network/network
* Click "Save&Apply".
* Verify SSH access to `root@192.168.31.1`.
* Update lists at <http://192.168.31.1/cgi-bin/luci/admin/system/package-manager>.
* run ansible
* set wireless password in `host_vars/ax3200.yaml` (see example file).

## Install OpenWRT with Xmir-Patcher

Based on <https://openwrt.org/toh/xiaomi/ax3200#installation>.

Tested with <https://github.com/openwrt-xiaomi/xmir-patcher/tree/dc6ec8b715a32220940ca30389ae0f5d59c17310>.

* clone xmir-patcher
* download firmware installation file from <https://toh.openwrt.org/?view=normal>, for example [openwrt-24.10.5-mediatek-mt7622-xiaomi_redmi-router-ax6s-factory.bin](https://downloads.openwrt.org/releases/24.10.5/targets/mediatek/mt7622/openwrt-24.10.5-mediatek-mt7622-xiaomi_redmi-router-ax6s-factory.bin)
* save it to `xmir-patcher/firmware`
* make sure you're connected with router other LAN, you should have DHCP leased IP from 192.168.31.0/24
* run `./run.sh`
  * Select `2 - Connect to device (install exploit)`, it will ask for web UI password
      ```
      device_name = RB01
      rom_version = 1.0.71 release
      mac address = a8:a1:59:5c:ed:dc
      Enter device WEB password: aecha4Cheeng
      Enable smartcontroller scene executor ...
      Wait smartcontroller activation ...
      ___[504]___
      Unlock dropbear service ...
      Unlock SSH server ...
      Set password "root" for root user ...
      Enabling dropbear service ...
      Run SSH server on port 22 ...
      Test SSH connection to port 22 ...

      #### SSH server are activated! ####
      ```
  * Select `7 - Install firmware (from directory "firmware")`
      ```
      Detect valid SSH server on port 22 (auth OK)
      device: "RB01"
      img_write = True
      Image files in directory "firmware/":
        "firmware/openwrt-24.10.5-mediatek-mt7622-xiaomi_redmi-router-ax6s-factory.bin"
      Download file: "/tmp/dmesg.log" ....
      Download file: "/tmp/mtd_list.txt" ....
      Download file: "/tmp/mtd_info.txt" ....
      Download file: "/tmp/mtd_fdt.txt" ....
      Download file: "/tmp/kcmdline.log" ....
      Parse all images...
      FIT size = 0x4A928 (298 KiB)
      FIT: name = "ARM64 OpenWrt FIT (Flattened Image Tree)"
      FIT: def_cfg: "config-1"
      FIT: def_cfg desc = "OpenWrt xiaomi_redmi-router-ax6s"
      FIT: model = "xiaomi,redmi-router-ax6s"
      KRN: desc = "ARM64 OpenWrt Linux-u-boot"
      Linux-u-boot image founded! (detect ubi-loader)
      Footer: UBI offset = 0x80000
      parse_fit = 2
      fw_img: 12160 KiB | kernel: 298 KiB | rootfs: 11648 KiB
      Download file: "/tmp/bl_uboot.bin" ....
      Download file: "/tmp/env_Nvram.bin" ....
      Download file: "/tmp/env_Bdata.bin" ....
      Download file: "/tmp/env_Preloader.bin" ....
      current flag_boot_rootfs = 0
      install_method = 300
      --------- prepare command lines -----------
      fw_img: 12160 KiB | kernel: 298 KiB | rootfs: 11648 KiB
      ------------- flash images -------------
      Upload file: "tmp/fw/fw_img.bin" ....
      Run scripts for change NVRAM params...
      Boot from firmware [0] activated.
      Writing firmware image to addr 0x002C0000 ...
        mtd -e "firmware" write "/tmp/fw_img.bin" "firmware"
      The firmware has been successfully flashed!
      Send command "reboot" via SSH/Telnet ...

      ERROR: SSH execute command timed out! CMD: "reboot -f"
      ```
  * Select `0 - Exit`
* Open LuCI: http://192.168.1.1

## Debricking

Based on https://openwrt.org/toh/xiaomi/ax3200#debricking

Works on Win11.

* Download http://cdn.awsde0-fusion.fds.api.mi-img.com/xiaoqiang/rom/rb01/miwifi_rb01_firmware_bbc77_1.0.71_INT.bin
* Download and unpack [dhcpsrv2.5.2.zip](https://www.dhcpserver.de/cms/wp-content/plugins/download-attachments/includes/download.php?id=625)
* Copy `miwifi_rb01_firmware_bbc77_1.0.71_INT.bin` to `dhcpsrv2.5.2/wwwroot/C0A82002.img`
* Disable Internet on Win11, to avoid network conflicts
* (may be repeated) Power on with the reset button held. About 10s later, the orange led will blink quickly for some seconds then back to always on. Release the reset button
* Connect ethernet NIC on computer to LAN1 port on router
* Configure ethernet interface with static IP 192.168.32.1/24
* Run DHCPSRV.exe with this ini file (replace full path to `dhcpsrv2.5.2/`):

    ```ini
    [SETTINGS]
    IPPOOL_1=192.168.32.2-2
    IPBIND_1=192.168.32.1
    AssociateBindsToPools=1
    Trace=1
    DeleteOnRelease=0
    ExpiredLeaseTimeout=3600

    [GENERAL]
    LEASETIME=86400
    NODETYPE=8
    SUBNETMASK=255.255.255.0
    NEXTSERVER=192.168.32.1
    ROUTER_0=0.0.0.0

    [DNS-SETTINGS]
    EnableDNS=0

    [TFTP-SETTINGS]
    EnableTFTP=1
    ROOT=C:\Users\...\Downloads\dhcpsrv2.5.2\wwwroot
    WritePermission=0

    [HTTP-SETTINGS]
    EnableHTTP=1
    ROOT=C:\Users\...\Downloads\dhcpsrv2.5.2\wwwroot
    ```
* in DHCPSRV logs at http://192.168.32.1/dhcptrace.txt?s=SERVER_0 you should see smth like:
    ```
    [03/01/2026 10:50:24] Client D4-DA-21-77-7D-3D is configured with the IP address 192.168.32.2
    [03/01/2026 10:50:24] Response: hand out the configured IP address (lease time = 86400)
    [03/01/2026 10:50:24] Sending a broadcast response to the client
    [03/01/2026 10:50:24] Connection 0: sending top queue packet
    [03/01/2026 10:50:24] Adapter 1 has recognized an incoming TFTP request
    [03/01/2026 10:50:24] TFTP RRQ started on port_index=0: C:\Users\...\Downloads\dhcpsrv2.5.2\wwwroot\C0A82002.img
    ```
* After a few seconds the device LED turns BLUE and blinks quickly, reboot the device. If the blink is PURPLE, it indicates the firmware is in the wrong format, or not the expected one, and it´s not flashed. Reboot the device and restart the steps
* Stop and remove DHCPSRV
* Reconfigure NIC back to DHCP
* Open https://router.miwifi.com and follow configuration steps, at some point it should ask for admin password

## Links

https://openwrt.org/toh/xiaomi/ax3200

https://github.com/gekmihesg/ansible-openwrt

https://openwrt.org/docs/guide-user/base-system/uci
https://openwrt.org/docs/guide-user/network/routing/routes_configuration

https://github.com/itdoginfo/domain-routing-openwrt/
https://raw.githubusercontent.com/itdoginfo/domain-routing-openwrt/master/getdomains-install.sh
https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/inside-dnsmasq-nfset.lst

https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/v24.10.2
