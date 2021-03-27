# Program that lists all devices connected to the Windows network via Ethernet or wifi

This application allows you to find the PC Name, IP and MAC, saving it in a ".txt" file.

## Rationale

There was a need to obtain MACs and IPs for a given situation, with several PCs in the environment,
therefore, facilitating the collection of all information via software.

## Features

* Simple,
* Uses WIndows API,
* Light, <15MB,
* If you have a different network, just change the network via ("VLAN" port) on the Switch;

## Requirements

* In certain cases, you must disable the machine's Firewall.
* Valid TCP / IP connection with valid IP.
* Machines with active connection (connected / connected)
* Works only with Gateway using DHCP (Automatic), that is, with automatic ips assignments.


## Program operation

Network commands are manipulated via the Windows API via CMD

* 1st Step: Generates a NET VIEW command to list all devices (by name).
  Returns me the name of the devices on the network.
* 2nd Step: Do a search for the IP by name, EX: ping -4 localhost, returning me a valid IPV4.
  Returns the IPV4 of the devices on the network.
  
  Example:
`` pascal
  cmd: = 'ping -4' + ip;
``

* 3rd Step: Make a query in the ARP table returning the MAC, EX: arp -a 127.0.0.1, the MAC of the device will return to me
  Returns me the MAC of the devices on the network.
  Example:
`` pascal
 cmd: = 'arp -a' + ip;
``


Make with ❤ @boscobecker
