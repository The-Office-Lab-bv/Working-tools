# Get-TolSystemInfo

A quick "who and where am I" snapshot of the machine you are running on, gathered
into one object: computer name, fully qualified name, the logged-in user and domain,
the OS, whether you are elevated, PowerShell version, uptime, and the active network
adapters with their IPv4 and MAC addresses.

## Why

Handy at the start of a script or support call: one command tells you exactly which
machine, which user, and which environment you are in, without stitching together
`$env:COMPUTERNAME`, `whoami`, OS lookups, and `ipconfig` by hand.

## What it reports

| Field | Meaning |
|-------|---------|
| `ComputerName` / `Fqdn` | Host name and fully qualified name |
| `UserName` / `UserDomain` / `WhoAmI` | The current user and domain |
| `IsElevated` | Whether the session is running as admin / root |
| `OS` / `Architecture` | Operating system description and CPU architecture |
| `PSVersion` / `PSEdition` | PowerShell version and edition |
| `BootTime` / `Uptime` | Last boot time and how long the machine has been up |
| `Network` | Active adapters with their IPv4 and MAC addresses |
| `CapturedAt` | When the snapshot was taken |

It reads only **local, non-secret** information about the current machine and session.
It does not touch other users or remote systems.

## Usage

```powershell
# Show the snapshot
Get-TolSystemInfo

# Save it as JSON (e.g. to attach to a support ticket)
Get-TolSystemInfo -AsJson | Out-File systeminfo.json

# Just the network adapters
(Get-TolSystemInfo).Network

# Skip network enumeration for a faster result
Get-TolSystemInfo -NoNetwork
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-AsJson` | switch | off | Return a JSON string instead of an object. |
| `-NoNetwork` | switch | off | Skip enumerating network adapters. |

## Notes

Cross-platform. Some fields are richer on Windows (domain, elevation); on macOS and
Linux they fall back gracefully or report `root` elevation via `id -u`.
