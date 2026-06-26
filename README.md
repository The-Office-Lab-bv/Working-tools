# Working-tools

A small set of practical PowerShell tools for daily work, by
**[The Office Lab](https://theofficelab.eu)**.

The tools ship as a PowerShell module, **`Tol.PowerShell`**. Every command uses the
`Tol` noun prefix (the same idea as `PnP.PowerShell` with its `PnP` prefix), so they
are easy to discover and never clash with built-ins:

```powershell
Get-Command -Module Tol.PowerShell
```

Each tool lives in its own folder under [`tools/`](tools/) with a focused how-to.

## Commands

| Command | Platform | What it does |
|---------|----------|--------------|
| [`Start-TolStayAwake`](tools/Start-TolStayAwake) | Windows | Keeps a PC awake: no sleep, no display-off, no idle lock. |
| [`New-TolProject`](tools/New-TolProject) | Cross-platform | Run-once project scaffolder: folders, README, .gitignore, optional git init. |
| [`Get-TolFolderSize`](tools/Get-TolFolderSize) | Cross-platform | Shows which subfolders use the most disk space, largest first. |
| [`Backup-TolItem`](tools/Backup-TolItem) | Cross-platform | Makes a timestamped .zip backup of a file or folder. |
| [`Get-TolPublicIP`](tools/Get-TolPublicIP) | Cross-platform | Returns your public IP address (with `-Detailed`, the full geo lookup). |
| [`Find-TolDuplicateFile`](tools/Find-TolDuplicateFile) | Cross-platform | Finds duplicate files by content hash (read-only, never deletes). |
| [`Merge-TolCsv`](tools/Merge-TolCsv) | Cross-platform | Combines many CSV files into one. |
| [`Test-TolEndpoint`](tools/Test-TolEndpoint) | Cross-platform | Ping + TCP port check for a list of hosts. |
| [`Write-TolLog`](tools/Write-TolLog) | Cross-platform | Timestamped, leveled logging to console and file. |
| [`Get-TolAIToSolve`](tools/Get-TolAIToSolve) | Cross-platform | Ask Claude, ChatGPT, Gemini, Mistral, or local Ollama. Cloud APIs cost money. |

Every command also has full built-in help: `Get-Help Start-TolStayAwake -Full`.

## Install

### Option 1: install the module

Download or clone the repo, then import it by manifest:

```powershell
# From the repo folder
Import-Module .\Tol.PowerShell.psd1
```

To load it automatically in every session, copy the repo into a folder named
`Tol.PowerShell` on one of your module paths (see `$env:PSModulePath`):

```powershell
$dest = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules\Tol.PowerShell'
Copy-Item . $dest -Recurse -Force
Import-Module Tol.PowerShell
```

If PowerShell blocks the files on first run (common with downloads), unblock them:

```powershell
Get-ChildItem . -Recurse | Unblock-File
```

### Option 2: just grab one script

If all you want is the keep-awake tool and you would rather not install anything,
download the standalone [`StayAwake.ps1`](StayAwake.ps1) from the repo root and run it
directly. See [Standalone StayAwake](#standalone-stayawake) below.

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
```

See each tool's folder for the full how-to and parameters.

## Standalone StayAwake

`StayAwake.ps1` in the repo root is a self-contained copy of the keep-awake tool. It
needs no module install: download it, run it, done.

1. Open [`StayAwake.ps1`](StayAwake.ps1), click **Raw**, and press **Ctrl+S** to save it.
2. Right-click the saved file, choose **Properties**, tick **Unblock**, then **OK**.
3. In its folder, hold **Shift**, right-click, choose **Open PowerShell window here**.
4. Run `.\StayAwake.ps1` and leave the window open. Press **Ctrl+C** to stop.

```powershell
.\StayAwake.ps1                 # until Ctrl+C
.\StayAwake.ps1 -Minutes 90     # for 90 minutes
.\StayAwake.ps1 -Till "18:00"   # until 18:00
.\StayAwake.ps1 -NoInput        # prevent sleep/display-off only
```

## Repository layout

```
Working-tools/
├── Tol.PowerShell.psd1     # module manifest
├── Tol.PowerShell.psm1     # loads tools/*/*.ps1 + private/*
├── private/                # internal helpers (not exported)
├── tools/                  # one folder per command: script + README
├── StayAwake.ps1           # standalone, no-install copy
├── README.md
├── SECURITY.md
├── CONTRIBUTING.md
└── CHANGELOG.md
```

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+ (Core)
- No external modules, no admin rights
- `Start-TolStayAwake` / `StayAwake.ps1` are Windows only; the rest run anywhere

## Contributing & security

- New tools: see [CONTRIBUTING.md](CONTRIBUTING.md).
- Reporting a vulnerability: see [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE) (c) The Office Lab BV. Use freely, no warranty.
