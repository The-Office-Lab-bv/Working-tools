# Test-TolEndpoint

Checks whether hosts respond to ping and, optionally, on specific TCP ports.

## Why

A quick up/down and port-open table for a list of hosts, without reaching for a heavier
network tool.

## How it works

Takes one or more host names or IP addresses and reports a result for each. With
`-Port` it also opens a TCP connection to each port and reports open or closed. Uses
.NET directly (`System.Net.NetworkInformation.Ping` and `System.Net.Sockets.TcpClient`)
so it behaves the same on Windows PowerShell 5.1 and PowerShell 7+.

## Usage

```powershell
Test-TolEndpoint -ComputerName server01, 8.8.8.8
Test-TolEndpoint -ComputerName intranet -Port 80, 443
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ComputerName` | string[] | required | One or more hosts to test. |
| `-Port` | int[] | none | One or more TCP ports to check on each host. |
| `-TimeoutMs` | int | `1000` | Per-check timeout in milliseconds. |

## Example output

```
Host       Online Ports
----       ------ -----
intranet     True 80:open  443:open
8.8.8.8      True
```

## Notes

Cross-platform. Returns the result objects so you can filter or export them.
