# Architecture

## 1. Project Overview

**Enterprise Automation Lab** is a local infrastructure automation project designed to simulate a small enterprise-style Linux environment.

The project uses:

- **Kali Linux WSL** as the automation control workstation
- **Hyper-V** as the local virtualization platform
- **Ansible** for configuration management and orchestration
- **Terraform** for Infrastructure as Code concepts and future cloud provisioning
- **AWS CloudFormation** for AWS-native IaC practice
- **GitHub** for version control, documentation and CI/CD validation

The main goal of this project is to build infrastructure automation skills step by step: from basic Ansible usage to more advanced automation patterns used in real infrastructure and DevOps environments.

---

## 2. High-Level Architecture

```text
Windows 11 Host
│
├── Kali Linux WSL
│   └── Automation Control Workstation
│       ├── Git
│       ├── SSH Client
│       ├── Python 3
│       ├── Ansible
│       ├── ansible-lint
│       ├── yamllint
│       └── Terraform later
│
└── Hyper-V
    └── Internal NAT Network: 192.168.100.0/24
        │
        ├── web-01
        │   └── Web server / Application node
        │
        ├── web-02
        │   └── Second web server / Application node
        │
        ├── db-01
        │   └── PostgreSQL database server
        │
        └── monitor-01
            └── Monitoring server
```

---

## 3. Main Components

### 3.1 Windows 11 Host

The Windows host provides the physical resources for the whole lab.

Responsibilities:

- Runs Hyper-V
- Runs Kali Linux through WSL
- Provides CPU, RAM and disk resources
- Provides the internal NAT network for the lab
- Acts as the gateway for Hyper-V virtual machines

---

### 3.2 Kali Linux WSL

Kali Linux WSL is used as the **automation control workstation**.

It is responsible for running automation tools and connecting to managed servers through SSH.

Main tools:

| Tool | Purpose |
|---|---|
| Git | Version control and GitHub integration |
| SSH Client | Remote access to Linux virtual machines |
| Python 3 | Required by Ansible and automation tools |
| Ansible | Configuration management and orchestration |
| ansible-lint | Static analysis for Ansible code |
| yamllint | YAML validation |
| Terraform | Infrastructure as Code practice |
| jq | JSON parsing |
| tree | Repository structure visualization |

Although Kali Linux is mainly designed for security and penetration testing workflows, in this project it is used as a Linux-based automation workstation.

---

### 3.3 Hyper-V

Hyper-V is used as the local virtualization platform.

It provides the virtual machines that simulate a small enterprise Linux infrastructure.

The Hyper-V environment will contain:

- web servers
- database server
- monitoring server
- private internal network
- NAT access to the internet

---

### 3.4 Managed Linux Nodes

The managed nodes are Linux virtual machines running inside Hyper-V.

They will be configured and managed from Kali WSL using Ansible over SSH.

Planned virtual machines:

| Hostname | Role |
|---|---|
| web-01 | First web/application server |
| web-02 | Second web/application server |
| db-01 | PostgreSQL database server |
| monitor-01 | Monitoring server |

---

## 4. Network Architecture

The lab uses a dedicated Hyper-V internal NAT network.

This provides stable private IP addresses for all virtual machines and keeps the lab isolated from the physical home network.

### Network Parameters

| Parameter | Value |
|---|---|
| Hyper-V Switch Name | EA-LAB-Internal |
| Switch Type | Internal |
| NAT Name | EA-LAB-NAT |
| Subnet | 192.168.100.0/24 |
| Gateway | 192.168.100.1 |
| DNS Servers | 1.1.1.1, 8.8.8.8 |

### IP Address Plan

| Hostname | IP Address | Purpose |
|---|---:|---|
| Windows Host Gateway | 192.168.100.1 | NAT gateway |
| web-01 | 192.168.100.11 | First web server |
| web-02 | 192.168.100.12 | Second web server |
| db-01 | 192.168.100.21 | Database server |
| monitor-01 | 192.168.100.31 | Monitoring server |

---

## 5. Network Flow

```text
Kali Linux WSL
     |
     | SSH
     v
Hyper-V Internal NAT Network
     |
     ├── web-01
     ├── web-02
     ├── db-01
     └── monitor-01
```

The automation control workstation connects to managed nodes using SSH.

Example:

```bash
ssh automation@192.168.100.11
```

Ansible will use the same SSH-based connection model.

Example:

```bash
ansible web -m ping
```

---

## 6. VM Resource Plan

The lab is designed for a laptop with **32 GB RAM**.

The resource allocation is intentionally conservative to keep the Windows host responsive.

| VM | RAM | vCPU | Purpose |
|---|---:|---:|---|
| web-01 | 2 GB | 2 | Web/application server |
| web-02 | 2 GB | 2 | Second web/application server |
| db-01 | 3 GB | 2 | PostgreSQL database server |
| monitor-01 | 3 GB | 2 | Monitoring server |

Total planned VM memory usage:

```text
2 GB + 2 GB + 3 GB + 3 GB = 10 GB
```

This leaves enough memory for:

- Windows 11
- Kali WSL
- browser
- documentation work
- Git and terminal sessions

---

## 7. Automation Design

The project follows a layered automation model.

```text
Infrastructure Layer
    Hyper-V virtual machines and networking

Operating System Layer
    Linux users, SSH, packages, services, firewall

Configuration Layer
    Ansible playbooks, roles, variables and templates

Application Layer
    Nginx, application services, PostgreSQL, monitoring stack

Validation Layer
    ansible-lint, yamllint, GitHub Actions

Documentation Layer
    architecture, runbooks, troubleshooting guides
```

---

## 8. Ansible Architecture

Ansible will be used to configure and manage the Linux virtual machines.

### Ansible Control Node

```text
Kali Linux WSL
```

### Ansible Managed Nodes

```text
web-01
web-02
db-01
monitor-01
```

### Inventory Design

The development inventory is located here:

```text
ansible/inventories/dev/hosts.ini
```

Planned inventory groups:

```ini
[web]
web-01
web-02

[database]
db-01

[monitoring]
monitor-01

[linux:children]
web
database
monitoring
```

### Ansible Connection Model

```text
Ansible Control Node
        |
        | SSH
        v
Managed Linux Nodes
```

Ansible does not require a permanent agent on the managed servers.  
It connects over SSH, runs tasks, and returns the result.

---

## 9. Planned Service Architecture

The final lab will gradually evolve into a small automated infrastructure stack.

```text
User / Browser
      |
      v
web-01 / web-02
      |
      v
db-01
      |
      v
monitor-01
```

Planned services:

| Server | Planned Services |
|---|---|
| web-01 | Nginx, application runtime |
| web-02 | Nginx, application runtime |
| db-01 | PostgreSQL |
| monitor-01 | Prometheus, Grafana, exporters |

---

## 10. Repository Architecture

The repository is organized by automation domain.

```text
enterprise-automation-lab/
│
├── ansible/
│   ├── ansible.cfg
│   ├── inventories/
│   │   ├── dev/
│   │   ├── stage/
│   │   └── prod/
│   ├── playbooks/
│   ├── roles/
│   ├── group_vars/
│   └── host_vars/
│
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   └── modules/
│
├── cloudformation/
│
├── scripts/
│   └── hyperv/
│
├── docs/
│   ├── architecture.md
│   ├── diagrams/
│   ├── runbooks/
│   └── troubleshooting/
│
└── .github/
    └── workflows/
```

---

## 11. Why This Architecture Is Used

### Why WSL is used

WSL provides a Linux automation environment directly on the Windows host.

This avoids the need for an additional control-node virtual machine and saves memory.

### Why Hyper-V is used

Hyper-V allows the project to simulate real Linux servers locally.

It is suitable for:

- infrastructure labs
- network isolation
- repeatable VM testing
- Windows-based home labs

### Why Internal NAT is used

An internal NAT network provides:

- predictable IP addresses
- isolation from the home network
- controlled routing
- easier Ansible inventory management
- enterprise-style private network design

### Why Ansible is used

Ansible is used because it is simple, agentless and widely used for configuration management.

It is suitable for:

- package installation
- service configuration
- user management
- SSH hardening
- firewall configuration
- application deployment
- operational automation

### Why Terraform is included

Terraform will be used later to practice Infrastructure as Code concepts.

It will help demonstrate:

- providers
- resources
- variables
- outputs
- modules
- state management
- environment separation

### Why CloudFormation is included

CloudFormation will be used to understand AWS-native infrastructure automation.

It will help compare:

```text
Terraform = multi-cloud Infrastructure as Code
CloudFormation = AWS-native Infrastructure as Code
Ansible = configuration management and orchestration
```

---

## 12. Project Stages

### Stage 0 - Foundation

- Create GitHub repository
- Prepare project structure
- Configure WSL control node
- Design Hyper-V network
- Document architecture

### Stage 1 - Ansible Basics

- Configure SSH access
- Create first inventory
- Run Ansible ping
- Execute ad-hoc commands
- Write first playbooks

### Stage 2 - Ansible Roles

- Create reusable roles
- Use variables
- Use handlers
- Use templates
- Configure Nginx and Linux services

### Stage 3 - Application Infrastructure

- Deploy web servers
- Deploy PostgreSQL
- Configure application stack
- Configure firewall rules
- Automate backups

### Stage 4 - Advanced Ansible

- Use Ansible Vault
- Add idempotency validation
- Add ansible-lint
- Add Molecule testing basics
- Create operational runbooks

### Stage 5 - Terraform

- Create Terraform project structure
- Learn providers, resources and state
- Create reusable modules
- Prepare cloud-ready examples

### Stage 6 - CloudFormation

- Create AWS-native templates
- Use parameters and outputs
- Understand stacks and change sets
- Compare with Terraform

### Stage 7 - CI/CD and Final Documentation

- Add GitHub Actions
- Validate YAML and Ansible code
- Validate Terraform code
- Create final diagrams
- Prepare final project summary

---

## 13. Current Status

Current project stage:

```text
Stage 0.2 - Architecture and Hyper-V network planning
```

Completed:

- GitHub repository created
- Repository topics added
- Initial project structure created
- Initial commit completed
- Kali WSL selected as the automation control workstation
- Ansible installed and verified
- Ansible configuration file detected correctly
- Development inventory skeleton created

Next steps:

- Create Hyper-V internal NAT network
- Create first Ubuntu Server VM
- Configure SSH access
- Run the first Ansible ping
