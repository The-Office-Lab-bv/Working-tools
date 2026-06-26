# Get-TolPublicIP

Returns the machine's public IP address.

## Why

A one-liner for "what is my outbound IP", handy when configuring firewall allow-lists,
checking a VPN, or noting an address for support.

## How it works

Queries a public lookup service over HTTPS. No API key needed. With `-Detailed` it
returns the full lookup object (city, region, country, org) when the service provides
it.

## Usage

```powershell
Get-TolPublicIP             # -> 203.0.113.42
Get-TolPublicIP -Detailed   # -> object with ip, city, region, country, org
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Detailed` | switch | off | Return the full geo/org object instead of just the IP string. |

## Notes

Cross-platform. Requires internet access. Relies on a third-party lookup endpoint, so
treat the result as best-effort.
