function Get-TolPublicIP {
    <#
    .SYNOPSIS
        Returns the machine's public IP address.

    .DESCRIPTION
        Queries a public IP lookup service and returns your outbound IP. With -Detailed
        it returns the full lookup object (city, region, country, org) when available.
        No API key required.

    .PARAMETER Detailed
        Return the full lookup object instead of just the IP string.

    .EXAMPLE
        Get-TolPublicIP

    .EXAMPLE
        Get-TolPublicIP -Detailed
    #>
    [CmdletBinding()]
    param(
        [switch]$Detailed
    )

    try {
        if ($Detailed) {
            return Invoke-RestMethod -Uri 'https://ipinfo.io/json' -TimeoutSec 10
        }
        else {
            $result = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json' -TimeoutSec 10
            return $result.ip
        }
    }
    catch {
        throw "Could not retrieve public IP: $($_.Exception.Message)"
    }
}
