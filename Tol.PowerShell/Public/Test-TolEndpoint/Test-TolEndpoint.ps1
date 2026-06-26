function Test-TolEndpoint {
    <#
    .SYNOPSIS
        Checks whether hosts respond to ping and, optionally, on specific TCP ports.

    .DESCRIPTION
        Takes one or more host names or IP addresses and reports an up/down result for
        each. With -Port it also tries a TCP connection to each port and reports open or
        closed. Uses .NET directly so it behaves the same on Windows PowerShell 5.1 and
        PowerShell 7+.

    .PARAMETER ComputerName
        One or more hosts to test.

    .PARAMETER Port
        One or more TCP ports to check on each host.

    .PARAMETER TimeoutMs
        Per-check timeout in milliseconds. Default 1000.

    .EXAMPLE
        Test-TolEndpoint -ComputerName server01, 8.8.8.8

    .EXAMPLE
        Test-TolEndpoint -ComputerName intranet -Port 80, 443
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string[]]$ComputerName,
        [int[]]$Port,
        [int]$TimeoutMs = 1000
    )

    $results = foreach ($target in $ComputerName) {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $online = $false
        try {
            $reply = $ping.Send($target, $TimeoutMs)
            $online = ($reply.Status -eq 'Success')
        } catch { $online = $false }

        $portText = $null
        if ($Port) {
            $parts = foreach ($p in $Port) {
                $open = $false
                $client = New-Object System.Net.Sockets.TcpClient
                try {
                    $iar = $client.BeginConnect($target, $p, $null, $null)
                    if ($iar.AsyncWaitHandle.WaitOne($TimeoutMs)) {
                        $client.EndConnect($iar)
                        $open = $client.Connected
                    }
                } catch { $open = $false }
                finally { $client.Close() }
                "{0}:{1}" -f $p, $(if ($open) { "open" } else { "closed" })
            }
            $portText = $parts -join "  "
        }

        [pscustomobject]@{
            Host   = $target
            Online = $online
            Ports  = $portText
        }
    }

    $results | Format-Table -AutoSize | Out-Host
    return $results
}
