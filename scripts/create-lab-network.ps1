# Enterprise Automation Lab - Hyper-V Network Setup
# Run this script in PowerShell as Administrator on the Windows host.

$SwitchName = "EA-LAB-Internal"
$NatName = "EA-LAB-NAT"
$GatewayIp = "192.168.100.1"
$PrefixLength = 24
$NatPrefix = "192.168.100.0/24"
$AdapterAlias = "vEthernet ($SwitchName)"

Write-Host "=== Enterprise Automation Lab: Hyper-V Network Setup ==="

Write-Host "Checking Hyper-V internal switch: $SwitchName"

if (-not (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue)) {
    New-VMSwitch -SwitchName $SwitchName -SwitchType Internal
    Write-Host "Switch created: $SwitchName"
} else {
    Write-Host "Switch already exists: $SwitchName"
}

Write-Host "Checking gateway IP address: $GatewayIp/$PrefixLength"

$ExistingIp = Get-NetIPAddress `
    -InterfaceAlias $AdapterAlias `
    -IPAddress $GatewayIp `
    -ErrorAction SilentlyContinue

if (-not $ExistingIp) {
    New-NetIPAddress `
        -IPAddress $GatewayIp `
        -PrefixLength $PrefixLength `
        -InterfaceAlias $AdapterAlias

    Write-Host "Gateway IP configured: $GatewayIp/$PrefixLength"
} else {
    Write-Host "Gateway IP already configured: $GatewayIp/$PrefixLength"
}

Write-Host "Checking NAT network: $NatName"

if (-not (Get-NetNat -Name $NatName -ErrorAction SilentlyContinue)) {
    New-NetNat `
        -Name $NatName `
        -InternalIPInterfaceAddressPrefix $NatPrefix

    Write-Host "NAT network created: $NatName"
} else {
    Write-Host "NAT network already exists: $NatName"
}

Write-Host "=== Hyper-V lab network setup completed ==="
Write-Host ""
Write-Host "Validation commands:"
Write-Host "Get-VMSwitch"
Write-Host "Get-NetIPAddress -InterfaceAlias '$AdapterAlias'"
Write-Host "Get-NetNat"
