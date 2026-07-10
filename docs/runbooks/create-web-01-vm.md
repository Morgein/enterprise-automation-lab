# Create web-01 Virtual Machine Runbook

## Purpose

This runbook describes how to create the first managed Linux node for the Enterprise Automation Lab.

The VM is named `web-01` and will be managed by Ansible from Kali Linux WSL.

## VM Role

`web-01` is the first web/application server in the lab.

It will be used to validate:

- Hyper-V virtual machine provisioning
- network connectivity
- SSH access
- Ansible inventory
- Ansible ad-hoc commands
- first Ansible playbooks

## VM Parameters

| Parameter | Value |
|---|---|
| VM Name | web-01 |
| Operating System | Ubuntu Server |
| Generation | Generation 2 |
| RAM | 2 GB |
| vCPU | 2 |
| Disk Size | 30 GB |
| Network Switch | EA-LAB-Internal |
| Static IP | 192.168.100.11 |
| Gateway | 192.168.100.1 |
| DNS | 1.1.1.1, 8.8.8.8 |
| Ansible User | automation |

## Network Configuration

The VM should be connected to the Hyper-V internal NAT switch:

```text
EA-LAB-Internal
```

The planned static network configuration is:

```text
IP Address: 192.168.100.11
Netmask:    255.255.255.0
Gateway:    192.168.100.1
DNS:        1.1.1.1, 8.8.8.8
```

## User Configuration

Create a Linux user for automation:

```text
Username: automation
```

This user will later be used by Ansible.

During initial installation, password-based login can be used temporarily.  
After SSH key authentication is configured, password login can be restricted.

## Required Packages

The VM should have the following packages installed:

```bash
sudo apt update
sudo apt install -y openssh-server python3 sudo curl wget vim nano
```

## Why Python is Required

Ansible connects to Linux managed nodes over SSH.

Most Ansible modules require Python on the managed node.  
Without Python, Ansible cannot execute many normal automation tasks.

## Why OpenSSH Server is Required

OpenSSH Server allows the control node to connect to the VM remotely.

The control node in this project is Kali Linux WSL.

Connection flow:

```text
Kali WSL → SSH → web-01
```

## Validation Commands

From inside the VM:

```bash
ip addr
ip route
systemctl status ssh
python3 --version
```

From Kali WSL:

```bash
ping 192.168.100.11
ssh automation@192.168.100.11
```

Later, from the Ansible directory:

```bash
ansible web-01 -m ping
```

## Current Status

VM creation is planned.
