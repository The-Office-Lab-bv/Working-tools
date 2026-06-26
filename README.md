# Working-tools

A small set of practical PowerShell tools for daily work, by
**[The Office Lab](https://theofficelab.eu)**.

The tools ship as a PowerShell module, **`Tol.PowerShell`**. Every command uses the
`Tol` noun prefix (the same idea as `PnP.PowerShell` with its `PnP` prefix), so they
are easy to discover and never clash with built-ins:

```powershell
Get-Command -Module Tol.PowerShell
```

Each command lives in its own folder under [`Tol.PowerShell/Public/`](Tol.PowerShell/Public/) with a focused how-to.

## Commands

| Command | Platform | What it does |
|---------|----------|--------------|
| [`Start-TolStayAwake`](Tol.PowerShell/Public/Start-TolStayAwake) | Windows | Keeps a PC awake: no sleep, no display-off, no idle lock. |
| [`New-TolProject`](Tol.PowerShell/Public/New-TolProject) | Cross-platform | Run-once project scaffolder: folders, README, .gitignore, optional git init. |
| [`Get-TolFolderSize`](Tol.PowerShell/Public/Get-TolFolderSize) | Cross-platform | Shows which subfolders use the most disk space, largest first. |
| [`Backup-TolItem`](Tol.PowerShell/Public/Backup-TolItem) | Cross-platform | Makes a timestamped .zip backup of a file or folder. |
| [`Get-TolPublicIP`](Tol.PowerShell/Public/Get-TolPublicIP) | Cross-platform | Returns your public IP address (with `-Detailed`, the full geo lookup). |
| [`Find-TolDuplicateFile`](Tol.PowerShell/Public/Find-TolDuplicateFile) | Cross-platform | Finds duplicate files by content hash (read-only, never deletes). |
| [`Merge-TolCsv`](Tol.PowerShell/Public/Merge-TolCsv) | Cross-platform | Combines many CSV files into one. |
| [`Test-TolEndpoint`](Tol.PowerShell/Public/Test-TolEndpoint) | Cross-platform | Ping + TCP port check for a list of hosts. |
| [`Write-TolLog`](Tol.PowerShell/Public/Write-TolLog) | Cross-platform | Timestamped, leveled logging to console and file. |
| [`Get-TolAIToSolve`](Tol.PowerShell/Public/Get-TolAIToSolve) | Cross-platform | Ask Claude, ChatGPT, Gemini, Mistral, or local Ollama. Cloud APIs cost money. |
| [`Get-TolSystemInfo`](Tol.PowerShell/Public/Get-TolSystemInfo) | Cross-platform | One-shot machine + session snapshot: host, user, domain, OS, IPs, uptime. |

Every command also has full built-in help: `Get-Help Start-TolStayAwake -Full`.

## Install

Download or clone the repo, then import the module by its manifest:

```powershell
# From the repo folder
Import-Module .\Tol.PowerShell\Tol.PowerShell.psd1
```

To load it automatically in every session, copy the `Tol.PowerShell` folder onto one
of your module paths (see `$env:PSModulePath`):

```powershell
$dest = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules'
Copy-Item .\Tol.PowerShell $dest -Recurse -Force
Import-Module Tol.PowerShell
```

If PowerShell blocks the files on first run (common with downloads), unblock them:

```powershell
Get-ChildItem .\Tol.PowerShell -Recurse | Unblock-File
```

## Usage at a glance

```powershell
Start-TolStayAwake -Minutes 90
New-TolProject -Name "invoice-tool"
Get-TolFolderSize -Path C:\Users\me\Downloads -Top 10 -Files
Backup-TolItem -Path .\report.xlsx
Get-TolPublicIP
Find-TolDuplicateFile -Path C:\Users\me\Pictures
Merge-TolCsv -Path .\exports -OutFile .\all.csv -AddSourceColumn
Test-TolEndpoint -ComputerName server01, 8.8.8.8 -Port 80, 443
Write-TolLog "Job done" -Level Success -Path .\logs\run.log
Get-TolAIToSolve -Provider Ollama "Explain DNS in one sentence."   # cloud providers cost money
Get-TolSystemInfo
```

See each command's folder for the full how-to and parameters.

## Repository layout

```
Working-tools/
├── Tol.PowerShell/             # the installable module
│   ├── Tol.PowerShell.psd1     # manifest
│   ├── Tol.PowerShell.psm1     # loads Public/**/*.ps1 + Private/*
│   ├── Private/                # internal helpers (not exported)
│   └── Public/                 # one folder per command: script + README
├── README.md
├── SECURITY.md
├── CONTRIBUTING.md
└── CHANGELOG.md
```

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+ (Core)
- No external modules, no admin rights
- `Start-TolStayAwake` is Windows only; the rest run anywhere

## Contributing & security

- New tools: see [CONTRIBUTING.md](CONTRIBUTING.md).
- Reporting a vulnerability: see [SECURITY.md](SECURITY.md).

## Support

If these tools save you time, you can say thanks:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-The%20Office%20Lab-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/theofficelab)

☕ [buymeacoffee.com/theofficelab](https://buymeacoffee.com/theofficelab)

## License

[MIT](LICENSE) (c) The Office Lab BV. Use freely, no warranty.
