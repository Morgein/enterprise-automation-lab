# Enterprise Automation Lab

Enterprise-style infrastructure automation lab built with Ansible, Terraform, AWS CloudFormation, WSL and Hyper-V.

## Project Goal

The goal of this project is to build a realistic infrastructure automation environment step by step, starting from junior-level Ansible basics and gradually moving toward senior-level automation practices.

This lab demonstrates:

- Infrastructure automation with Ansible
- Configuration management
- Infrastructure as Code with Terraform
- AWS-native IaC concepts with CloudFormation
- Hyper-V based local infrastructure
- WSL as an automation control environment
- Linux server provisioning
- SSH-based management
- CI/CD validation for automation code
- Documentation, runbooks and troubleshooting practices

## Lab Architecture

The project uses WSL as the automation control environment and Hyper-V virtual machines as managed infrastructure nodes.

```text
Windows 11 Host
│
├── WSL Ubuntu
│   └── Ansible / Terraform / Git environment
│
└── Hyper-V
    ├── web-01
    ├── web-02
    ├── db-01
    └── monitor-01
