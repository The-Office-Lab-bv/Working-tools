# Working-tools

A small set of practical PowerShell tools for daily work, by
**[The Office Lab](https://theofficelab.eu)**.

The tools ship as a PowerShell module, **`Tol.PowerShell`**. Every command uses the
`Tol` noun prefix (the same idea as `PnP.PowerShell` with its `PnP` prefix), so they
are easy to discover and never clash with built-ins:

```powershell
Get-Command -Module Tol.PowerShell
```

## Commands

| Command | Platform | What it does |
|---------|----------|--------------|
| `Start-TolStayAwake` | Windows | Keeps a PC awake: no sleep, no display-off, no idle lock. |
| `New-TolProject` | Cross-platform | Run-once project scaffolder: folders, README, .gitignore, optional git init. |
| `Get-TolFolderSize` | Cross-platform | Shows which subfolders use the most disk space, largest first. |
| `Backup-TolItem` | Cross-platform | Makes a timestamped .zip backup of a file or folder. |
| `Get-TolPublicIP` | Cross-platform | Returns your public IP address (with `-Detailed`, the full geo lookup). |
| `Find-TolDuplicateFile` | Cross-platform | Finds duplicate files by content hash (read-only, never deletes). |
| `Merge-TolCsv` | Cross-platform | Combines many CSV files into one. |
| `Test-TolEndpoint` | Cross-platform | Ping + TCP port check for a list of hosts. |

Every command has full help: `Get-Help Start-TolStayAwake -Full`.

## Install

### Option 1: install the module

Download or clone the repo, then import the module:

```powershell
# From the repo folder
Import-Module .\Tol.PowerShell\Tol.PowerShell.psd1
```

To have it load automatically in every session, copy the `Tol.PowerShell` folder
into one of your module paths (see `$env:PSModulePath`), for example:

```powershell
# Current user, all sessions
$dest = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules\Tol.PowerShell'
Copy-Item .\Tol.PowerShell $dest -Recurse -Force
Import-Module Tol.PowerShell
```

If PowerShell blocks the files on first run (common with downloads), unblock them:

```powershell
Get-ChildItem .\Tol.PowerShell -Recurse | Unblock-File
```

### Option 2: just grab one script

If all you want is the keep-awake tool and you would rather not install anything,
download the standalone [`StayAwake.ps1`](StayAwake.ps1) from the repo root and run
it directly. See [Standalone StayAwake](#standalone-stayawake) below.

## Usage

```powershell
# Keep the PC awake until Ctrl+C, or for a set time
Start-TolStayAwake
Start-TolStayAwake -Minutes 90
Start-TolStayAwake -Till "18:00"

# Scaffold a new project (interactive, or -Quiet for all defaults)
New-TolProject
New-TolProject -Name "invoice-tool"
New-TolProject -Name "quick-poc" -Quiet

# What is eating my disk
Get-TolFolderSize -Path C:\Users\me\Downloads -Top 10 -Files

# Snapshot before you change something
Backup-TolItem -Path .\report.xlsx
Backup-TolItem -Path C:\work\project -Destination D:\backups

# Public IP
Get-TolPublicIP
Get-TolPublicIP -Detailed

# Find duplicate files (reports only, never deletes)
Find-TolDuplicateFile -Path C:\Users\me\Pictures

# Merge a folder of CSVs into one
Merge-TolCsv -Path .\exports -OutFile .\all.csv -AddSourceColumn

# Are these hosts up, and are those ports open
Test-TolEndpoint -ComputerName server01, 8.8.8.8 -Port 80, 443
```

## Standalone StayAwake

`StayAwake.ps1` in the repo root is a self-contained copy of the keep-awake tool. It
needs no module install: download it, run it, done.

### How it works

It calls the Windows `SetThreadExecutionState` API (the mechanism behind PowerToys
Awake and Caffeine) to mark the system and display as required, so neither sleeps. By
default it also issues a single **F15** key signal on each interval to reset the user
idle timer. F15 is a phantom key that no physical keyboard sends, so it has no visible
side effect. Normal power behaviour returns automatically when the script stops.

### Run it (step by step)

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

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+ (Core)
- No external modules, no admin rights
- `Start-TolStayAwake` / `StayAwake.ps1` are Windows only; the rest run anywhere

## License

[MIT](LICENSE) (c) The Office Lab BV. Use freely, no warranty.

## Contributing

Issues and pull requests welcome. Keep tools small, self-contained, and add new
commands as one file per function under `Tol.PowerShell/Public/`, using an approved
verb and the `Tol` noun prefix.
