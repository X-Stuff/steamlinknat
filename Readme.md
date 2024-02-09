# SteamLink NAT Forwarding

## Scheme
![img](scheme.svg)

## Overlay modifications

### Ethernet

#### **/etc/init.d/startup/S50EthConfig.sh**
 + Static IP address (192.168.0.110)

#### **/etc/servd.conf**
 * Removed delay for DCHP configuration (we don't need to be client on eth0)

#### **/etc/connman/main.conf**
 * Ethernet disabled as autoconnect technology

#### **/var/lib/connman/ethernet.config**
 * Ethernet disabled DHCP client

### WiFi

#### **/etc/wifi.ap**
 + Put name of access point to connect

#### **/etc/wifi.passwd**
 + Put password for this AP

#### **/etc/wifi.mac**
 + Put mac address of phone (Some time DHCP server on phone may fail, we have to setup ip address and routes manually)

#### **/etc/init.d/startup/S19ConnmanConfig.sh**
 + Creating wifi service configuration file with AP and pass from above (autoconnect without UI)

#### **/etc/init.d/startup/S52ConnectWifi.sh**
 + Script for connecting to AP at startup and (**IMPORTANT**) launching DHCP client after connect to set up correct gateway and DNS. Also launches watchdog version to redo DHCP client.


### NAT

#### **/usr/local/sbin/xtables-multi-armv7-static**
 + iptables [v1.4.21](https://git.netfilter.org/iptables/tag/?h=v1.4.21) built with cross compilation docker image for armv7l with **musl** compiler ([here](https://github.com/dockcross/dockcross/tree/master/linux-armv7l-musl))

    + Some modification to source code applied:
    + Add `-D__GLIBC__=2` to `CFLAGS` in order to compile sources
    + Add `#define u_intXX_t uintXX_t` in order to compile sources


#### **/etc/init.d/startup/S51EnableNat.sh**
 + Several kernel modules has to be loaded (luckily this version of steamlink kernel has it)
 + Standard iptables nat forwarding added


### MISC

#### **/usr/local/sbin/bash**
 + bash armv7, because busybox sucks

#### **/etc/profile**
 + `/var/opt/node/bin` added to `PATH` to get node js work. Download here: [node-v12.20.0-linux-armv7](https://nodejs.org/dist/v12.20.0/node-v12.20.0-linux-armv7l.tar.xz)

#### **/etc/passwd**
 + bash as default terminal for root user (password the same: `steamlink123`)

#### **/etc/init.d/startup/S90MakeLinks.sh**
 + script that makes work `npm` and `npx` work ( nodejs v12 supported, has to be unpacked into `/overlay/var/opt/node` )

## Steamlink config

* Firmware number: 807
* SSH enabled
* No sleep timeout

## Usage

```
mkdir steamlink
cd steamlink
git clone https://github.com/X-Stuff/steamlinknat.git
```