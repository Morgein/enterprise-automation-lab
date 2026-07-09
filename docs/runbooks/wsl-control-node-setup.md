# WSL Control Node Setup

## Purpose

This document describes how the WSL-based automation control node is prepared for the Enterprise Automation Lab.

The control node is responsible for running automation tools such as Ansible, Terraform and supporting CLI utilities. It connects to managed Linux servers running inside Hyper-V through SSH.

## Control Node Operating System

The control environment uses Kali Linux running inside Windows Subsystem for Linux.

Although Kali Linux is primarily designed for security and penetration testing workflows, it can also be used as a Linux-based automation workstation when properly configured.

## Installed Tools

The following tools are installed on the WSL control node:

| Tool | Purpose |
|---|---|
| Git | Version control and GitHub integration |
| OpenSSH Client | SSH access to managed nodes |
| Python 3 | Required for Ansible and automation tooling |
| pipx | Isolated installation of Python-based CLI tools |
| Ansible | Configuration management and orchestration |
| ansible-lint | Static analysis for Ansible code |
| yamllint | YAML syntax and formatting validation |
| jq | JSON parsing in shell workflows |
| tree | Repository structure visualization |
| curl/wget | Downloading and testing HTTP endpoints |

## Why pipx is used

pipx is used to install Python-based command-line tools in isolated environments.

This approach avoids polluting the system Python installation and makes the workstation easier to maintain.

## Control Node Responsibilities

The WSL control node will be used to:

- manage SSH access to Hyper-V virtual machines
- run Ansible ad-hoc commands
- execute Ansible playbooks
- validate Ansible code
- later run Terraform and other IaC tools
- maintain project documentation
- push infrastructure code to GitHub

## Validation Commands

```bash
git --version
ssh -V
python3 --version
pipx --version
ansible --version
ansible-playbook --version
ansible-lint --version
yamllint --version
tree --version
jq --version
