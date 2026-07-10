# Hyper-V Network Setup Runbook

## Purpose

This runbook describes how to create the Hyper-V internal NAT network used by the Enterprise Automation Lab.

The network provides stable private IP addresses for Linux virtual machines managed by Ansible from Kali WSL.

## Network Design

The lab uses a dedicated Hyper-V internal switch with NAT.

This design provides:

- stable private IP addresses
- isolation from the physical home network
- predictable Ansible inventory
- internet access for virtual machines through Windows NAT
- a realistic private infrastructure network

## Network Parameters

| Parameter | Value |
|---|---|
| Hyper-V Switch Name | EA-LAB-Internal |
| Switch Type | Internal |
| NAT Name | EA-LAB-NAT |
| Subnet | 192.168.100.0/24 |
| Gateway IP | 192.168.100.1 |
| Prefix Length | 24 |

## IP Address Plan

| Hostname | IP Address | Role |
|---|---:|---|
| Windows Host Gateway | 192.168.100.1 | NAT gateway |
| web-01 | 192.168.100.11 | Web server |
| web-02 | 192.168.100.12 | Web server |
| db-01 | 192.168.100.21 | Database server |
| monitor-01 | 192.168.100.31 | Monitoring server |

## PowerShell Commands

Run PowerShell as Administrator on the Windows host.

### 1. Create Internal Hyper-V Switch

```powershell
New-VMSwitch -SwitchName "EA-LAB-Internal" -SwitchType Internal
```

### 2. Assign Gateway IP Address

```powershell
New-NetIPAddress `
  -IPAddress 192.168.100.1 `
  -PrefixLength 24 `
  -InterfaceAlias "vEthernet (EA-LAB-Internal)"
```

### 3. Create NAT Network

```powershell
New-NetNat `
  -Name "EA-LAB-NAT" `
  -InternalIPInterfaceAddressPrefix 192.168.100.0/24
```

## Validation Commands

### Show Hyper-V Switches

```powershell
Get-VMSwitch
```

### Show Hyper-V Lab Adapter

```powershell
Get-NetAdapter | Where-Object {$_.Name -like "*EA-LAB*"}
```

### Show Gateway IP Address

```powershell
Get-NetIPAddress -InterfaceAlias "vEthernet (EA-LAB-Internal)"
```

### Show NAT Configuration

```powershell
Get-NetNat
```

## Expected Result

The Windows host should have a Hyper-V internal adapter with:

```text
192.168.100.1/24
```

The NAT network should use:

```text
192.168.100.0/24
```

## VM Network Settings

Each VM connected to this switch should use:

```text
Gateway: 192.168.100.1
DNS:     1.1.1.1 or 8.8.8.8
```

## Notes

This network is dedicated to the Enterprise Automation Lab.

The switch and NAT configuration are created on the Windows host, not inside WSL.
