# Sarin App - Sarin for MacOS: Beginner's Network Penetration Testing GUI (Dsniff)
![AppIcon](https://i.imgur.com/a5G2x81.png)

## Disclaimer:
Please use Sarin for educational use and/or good intentions. Conducting network attacks on public wifi or on non-consenting devices is illegal and not condoned by Sarin.

## Table of Contents
- [Features](#Features)
- [Screenshots](#Screenshots)
- [How to use](# "How to use")
- [Dependencies and used programs](# Dependencies and used programs)
- [Used Swift Libraries](# Used Swift Libraries)

## Features:
- Automatically installs necesarry programs, dependencies, and scripts.
- Scan LAN for devices
- ARP poison devices
  - Cut off any device's conenction to the router
  - Conduct MITM attacks
- DNS spoofing
  - Redirect victims to your locally hosted website
 - Website cloning with httrack
- TCP dumping
  - Password sniffing
- Change your MAC address
- Help tips for beginners and experts alike

## Screenshots:
### Dark mode
![Dark Mode](https://i.imgur.com/occGO8z.png)
![Dark Mode2](https://i.imgur.com/XVifik0.png)
### Light mode
![Light Mode](https://i.imgur.com/d3kFdJH.png)

## How to use:
- "Scan LAN" to generate list of devices on your current network. Select devices by clicking on them (batch selection allowed)
- "Poison Selected Devices" to conduct an ARP man in the middle attack on the devices. From here, you can specifify a DNS Spoof attack or TCP Dump.
- Select "TCP Dump" and click "Start TCP Dump" to start collecting packets routed from the target, through your device, to the router. Once the user visits a vulnerable site and enters in their login credentials, Sarin will pick it up and display the captured information in the console. Use the cmd+f (search) to look for the keyword "pass", "password", etc. Different sites use different keywords.
- Select "DNS Spoof" and click "Configure" to customize the attack. Under the "configure" menu, the left table is for domain names that, if the user visits, will redirect them to your apache web server. The right column is for cloning a website to host on your web server. After saving your configure options, click "Start DNS Spoof" to start the attack.
- It is in your best interest to stop all attacks before quitting the application. Quitting the application should put a stop to all active processes, but it is recommenced to manually stop the tasks with the "Stop Task" buttons.

## Dependencies and used programs:
- [httrack](https://www.httrack.com)
- [pageres](https://github.com/sindresorhus/pageres-cli)
- [arp-scan](https://github.com/royhills/arp-scan)
- [expect](https://manpages.debian.org/stretch/expect/index.html)
- [dsniff](https://github.com/ggreer/dsniff)
  - berkley-db
  - libnet
  - libnids
  - libpcap 
  - openssl 

## Used Swift Libraries:
- [Keychain Access](https://github.com/kishikawakatsumi/KeychainAccess)


