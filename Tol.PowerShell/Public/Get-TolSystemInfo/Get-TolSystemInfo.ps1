function Get-TolSystemInfo {
    <#
    .SYNOPSIS
        Collects machine and current-session details into one object.

    .DESCRIPTION
        A quick "who and where am I" snapshot of the machine you are running on:
        computer name, fully qualified name, the logged-in user and domain, the OS,
        whether you are elevated, PowerShell version, uptime, and the active network
        adapters with their IPv4 and MAC addresses. Returns one object; use -AsJson to
        get it as a JSON string.

        It reads only local, non-secret information about the current machine and
        session. It does not touch other users or remote systems.

    .PARAMETER AsJson
        Return the result as a JSON string instead of an object.

    .PARAMETER NoNetwork
        Skip enumerating network adapters (faster, less output).

    .EXAMPLE
        Get-TolSystemInfo

    .EXAMPLE
        Get-TolSystemInfo -AsJson | Out-File systeminfo.json

    .EXAMPLE
        (Get-TolSystemInfo).Network
    #>
    [CmdletBinding()]
    param(
        [switch]$AsJson,
        [switch]$NoNetwork
    )

    # Detect Windows in a way that works on both Windows PowerShell 5.1 and PS 7+.
    $onWindows = $true
    if (Test-Path Variable:IsWindows) { $onWindows = $IsWindows }

    # Elevation / admin.
    $isElevated = $null
    try {
        if ($onWindows) {
            $id = [Security.Principal.WindowsIdentity]::GetCurrent()
            $isElevated = (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
                [Security.Principal.WindowsBuiltinRole]::Administrator)
        }
        else {
            $isElevated = ((id -u) -eq '0')
        }
    }
    catch { $isElevated = $null }

    # Fully qualified domain name (best effort).
    $hostName = [System.Net.Dns]::GetHostName()
    $fqdn = $hostName
    try { $fqdn = [System.Net.Dns]::GetHostEntry($hostName).HostName } catch { }

    # Uptime / last boot (best effort across platforms).
    $bootTime = $null
    $uptime = $null
    try {
        if ($onWindows) {
            $bootTime = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
        }
        elseif (Test-Path /proc/uptime) {
            $secs = [double](((Get-Content /proc/uptime) -split '\s+')[0])
            $bootTime = (Get-Date).AddSeconds(-$secs)
        }
        if ($bootTime) { $uptime = ((Get-Date) - $bootTime).ToString('dd\.hh\:mm\:ss') }
    }
    catch { }

    # Network adapters (active, non-loopback).
    $network = @()
    if (-not $NoNetwork) {
        try {
            $nics = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
                Where-Object {
                    $_.OperationalStatus -eq 'Up' -and
                    $_.NetworkInterfaceType -ne 'Loopback'
                }
            foreach ($nic in $nics) {
                $ipv4 = ($nic.GetIPProperties().UnicastAddresses |
                    Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' }).Address.IPAddressToString
                $mac = ($nic.GetPhysicalAddress().ToString() -replace '(..)(?=.)', '$1:')
                $network += [pscustomobject]@{
                    Name = $nic.Name
                    Type = $nic.NetworkInterfaceType.ToString()
                    IPv4 = @($ipv4) -join ', '
                    MAC  = $mac
                }
            }
        }
        catch { }
    }

    $info = [ordered]@{
        ComputerName  = $hostName
        Fqdn          = $fqdn
        UserName      = [Environment]::UserName
        UserDomain    = [Environment]::UserDomainName
        WhoAmI        = "{0}\{1}" -f [Environment]::UserDomainName, [Environment]::UserName
        IsElevated    = $isElevated
        OS            = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription.Trim()
        Architecture  = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        PSVersion     = $PSVersionTable.PSVersion.ToString()
        PSEdition     = $PSVersionTable.PSEdition
        BootTime      = $bootTime
        Uptime        = $uptime
        Network       = $network
        CapturedAt    = (Get-Date).ToString('s')
    }

    $obj = [pscustomobject]$info
    if ($AsJson) { return ($obj | ConvertTo-Json -Depth 5) }
    return $obj
}
