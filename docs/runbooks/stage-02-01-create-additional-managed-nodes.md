# Stage 2.1 - Create Additional Hyper-V Managed Nodes

## 1. Purpose

This document describes Stage 2.1 of the Enterprise Automation Lab.

The goal of this stage is to expand the lab from one managed Linux node to multiple managed nodes.

Before this stage, only one managed node existed:

```text
web-01 - 192.168.100.11
```

After this stage, the lab should contain:

```text
web-01      192.168.100.11
web-02      192.168.100.12
db-01       192.168.100.21
monitor-01  192.168.100.31
```

This prepares the project for applying Ansible roles to groups of servers instead of only one host.

---

## 2. Target Architecture

```text
Windows 11 Host
│
├── Kali Linux WSL
│   └── Ansible Control Workstation
│
└── Hyper-V
    └── EA-LAB-Internal Network: 192.168.100.0/24
        │
        ├── web-01      192.168.100.11
        ├── web-02      192.168.100.12
        ├── db-01       192.168.100.21
        └── monitor-01  192.168.100.31
```

---

## 3. VM Resource Plan

The lab is designed for a laptop with 32 GB RAM.

| VM | RAM | vCPU | Disk | Role |
|---|---:|---:|---:|---|
| web-01 | 2 GB | 2 | 30 GB | First web/application server |
| web-02 | 2 GB | 2 | 30 GB | Second web/application server |
| db-01 | 3 GB | 2 | 40 GB | PostgreSQL database server |
| monitor-01 | 3 GB | 2 | 40 GB | Monitoring server |

Total planned VM RAM usage:

```text
2 GB + 2 GB + 3 GB + 3 GB = 10 GB
```

This leaves enough memory for Windows, WSL, browser and development tools.

---

## 4. Network Plan

All VMs must be connected to the Hyper-V internal NAT switch:

```text
EA-LAB-Internal
```

Network parameters:

| Parameter | Value |
|---|---|
| Subnet | 192.168.100.0/24 |
| Gateway | 192.168.100.1 |
| DNS | 1.1.1.1, 8.8.8.8 |
| NAT Name | EA-LAB-NAT |

---

## 5. IP Address Plan

| Hostname | IP Address | Gateway | DNS |
|---|---:|---:|---|
| web-01 | 192.168.100.11 | 192.168.100.1 | 1.1.1.1, 8.8.8.8 |
| web-02 | 192.168.100.12 | 192.168.100.1 | 1.1.1.1, 8.8.8.8 |
| db-01 | 192.168.100.21 | 192.168.100.1 | 1.1.1.1, 8.8.8.8 |
| monitor-01 | 192.168.100.31 | 192.168.100.1 | 1.1.1.1, 8.8.8.8 |

---

## 6. Common VM Installation Settings

Each VM should use the following installation settings:

| Parameter | Value |
|---|---|
| Operating System | Ubuntu Server |
| Hyper-V Generation | Generation 2 |
| Network Switch | EA-LAB-Internal |
| User | automation |
| OpenSSH Server | Enabled |
| Authentication | Password first, SSH key later |

During Ubuntu installation, create the same automation user:

```text
automation
```

This is required because the Ansible inventory uses:

```ini
ansible_user=automation
```

---

## 7. Required Packages on Each VM

After installation, each VM should have:

```bash
sudo apt update
sudo apt install -y openssh-server python3 sudo curl wget vim nano
```

### Why these packages are required

| Package | Purpose |
|---|---|
| openssh-server | Allows SSH access from Kali WSL |
| python3 | Required for Ansible module execution |
| sudo | Required for privilege escalation |
| curl | HTTP/API testing |
| wget | File downloading |
| vim | Text editing |
| nano | Simple text editing |

---

## 8. Static IP Configuration

Ubuntu Server uses Netplan for network configuration.

Example Netplan file path:

```text
/etc/netplan/00-installer-config.yaml
```

The interface name may be different on each VM.

Check interface name:

```bash
ip link
```

Common names:

```text
eth0
ens160
enp0s3
```

Use the correct interface name in the Netplan configuration.

---

## 9. Netplan Example for web-02

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.100.12/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

Apply configuration:

```bash
sudo netplan apply
```

Validate:

```bash
ip addr
ip route
ping -c 4 192.168.100.1
ping -c 4 1.1.1.1
ping -c 4 google.com
```

---

## 10. Netplan Example for db-01

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.100.21/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

---

## 11. Netplan Example for monitor-01

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.100.31/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

---

## 12. SSH Key Setup

From Kali WSL, copy the existing project public key to each new VM.

```bash
ssh-copy-id -i ~/.ssh/enterprise_automation_lab.pub automation@192.168.100.12
ssh-copy-id -i ~/.ssh/enterprise_automation_lab.pub automation@192.168.100.21
ssh-copy-id -i ~/.ssh/enterprise_automation_lab.pub automation@192.168.100.31
```

Then validate SSH key login:

```bash
ssh -i ~/.ssh/enterprise_automation_lab automation@192.168.100.12
ssh -i ~/.ssh/enterprise_automation_lab automation@192.168.100.21
ssh -i ~/.ssh/enterprise_automation_lab automation@192.168.100.31
```

---

## 13. Passwordless Sudo Setup

On each VM, configure passwordless sudo for the `automation` user:

```bash
echo "automation ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/automation
sudo chmod 440 /etc/sudoers.d/automation
sudo visudo -cf /etc/sudoers.d/automation
```

Expected result:

```text
/etc/sudoers.d/automation: parsed OK
```

This is required because Ansible uses:

```ini
become = True
become_method = sudo
become_ask_pass = False
```

---

## 14. Ansible Inventory

The current inventory already contains all planned nodes:

```ini
[web]
web-01 ansible_host=192.168.100.11
web-02 ansible_host=192.168.100.12

[database]
db-01 ansible_host=192.168.100.21

[monitoring]
monitor-01 ansible_host=192.168.100.31

[linux:children]
web
database
monitoring

[linux:vars]
ansible_user=automation
ansible_ssh_private_key_file=~/.ssh/enterprise_automation_lab
```

After all VMs are created, Ansible can target:

```text
linux
```

instead of only:

```text
web-01
```

---

## 15. Validation From Kali WSL

From Kali WSL:

```bash
ping -c 4 192.168.100.12
ping -c 4 192.168.100.21
ping -c 4 192.168.100.31
```

SSH validation:

```bash
ssh -i ~/.ssh/enterprise_automation_lab automation@192.168.100.12 hostname
ssh -i ~/.ssh/enterprise_automation_lab automation@192.168.100.21 hostname
ssh -i ~/.ssh/enterprise_automation_lab automation@192.168.100.31 hostname
```

Expected result:

```text
web-02
db-01
monitor-01
```

---

## 16. Ansible Ping Validation

From the Ansible directory:

```bash
cd ~/enterprise-automation-lab/ansible
```

Validate each new host:

```bash
ansible web-02 -m ping
ansible db-01 -m ping
ansible monitor-01 -m ping
```

Validate all Linux hosts:

```bash
ansible linux -m ping
```

Expected result:

```text
web-01      pong
web-02      pong
db-01       pong
monitor-01  pong
```

---

## 17. Stage Result

At the end of this stage:

```text
web-02 exists
db-01 exists
monitor-01 exists
all nodes have static IP addresses
all nodes are reachable from Kali WSL
SSH key authentication works
passwordless sudo is configured
Ansible ping works for all Linux nodes
```

---

## 18. Current Status

Current project status:

```text
Stage 2.1 - Additional Hyper-V managed nodes created
```

Next planned stage:

```text
Stage 2.2 - Apply linux_baseline role to all Linux nodes
```
