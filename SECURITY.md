# Security Policy

## Supported versions

This project follows a rolling release. Only the latest version on the `main` branch
is supported with fixes.

| Version | Supported |
|---------|-----------|
| latest (`main`) | yes |
| older commits | no |

## Reporting a vulnerability

Please report security issues privately, not in a public issue.

1. Preferred: open a private report through GitHub's
   **Security > Report a vulnerability** (private vulnerability reporting) on this
   repository.
2. Or email **security@theofficelab.eu** with the details.

Please include:

- the tool or file affected,
- a description of the issue and its impact,
- steps to reproduce, if possible.

We aim to acknowledge a report within a few business days and will keep you updated on
the fix. Please give us reasonable time to address the issue before any public
disclosure.

## Scope and good practice

These tools are small PowerShell utilities that run locally with your own permissions.
A few sensible notes:

- Review any script before running it, the source is right here.
- `Start-TolStayAwake` keeps a machine awake; use it in line with your own
  organisation's policies.
- `Get-TolPublicIP` and `Test-TolEndpoint` make outbound network calls. Nothing is sent
  anywhere except the lookup or host you ask for.
- No tool collects telemetry or phones home.
