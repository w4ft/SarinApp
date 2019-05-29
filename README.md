# SarinApp - Work in Progress
Sarin for MacOS: Beginner's Network Penetration Testing GUI (Dsniff)

![Dark Mode](https://imgur.com/a/opj2DQe)
![Light Mode](https://imgur.com/a/gcEA2yf)

## Features:
- Scan LAN for devices
- ARP poison devices
  - Cut off any device's conenction to the router
  - Conduct MITM attacks
- DNS spoofing
  - Redirect victim's to your locally hosted website
 - Website cloning with httrack
- TCP dumping
  - Password sniffing
- Change your MAC address
- Help tips for beginners and experts alike

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
