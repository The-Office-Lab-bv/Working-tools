# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] - 2026-06-26

### Added

- `Tol.PowerShell` module with a `Tol` noun prefix on every command.
- Folder-per-tool layout under `tools/`, each with its own README.
- Commands:
  - `Start-TolStayAwake` - keep a Windows PC awake (no sleep, display-off, idle lock).
  - `New-TolProject` - run-once project scaffolder.
  - `Get-TolFolderSize` - subfolder disk usage, largest first.
  - `Backup-TolItem` - timestamped zip backup.
  - `Get-TolPublicIP` - return the public IP address.
  - `Find-TolDuplicateFile` - find duplicate files by hash (read-only).
  - `Merge-TolCsv` - combine many CSV files into one.
  - `Test-TolEndpoint` - ping and TCP port check for a list of hosts.
  - `Write-TolLog` - timestamped, leveled logging to console and file.
  - `Get-TolAIToSolve` - query Claude, ChatGPT, Gemini, Mistral/Le Chat, or local Ollama.
- Standalone `StayAwake.ps1` at the repo root for no-install use.
- Project docs: README, SECURITY, CONTRIBUTING, and issue/PR templates.
