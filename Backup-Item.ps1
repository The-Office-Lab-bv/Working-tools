<#
.SYNOPSIS
    Makes a timestamped .zip backup of a file or folder.

.DESCRIPTION
    Backup-Item compresses a file or folder into a .zip named after the item plus
    a date-time stamp, so each backup is unique and easy to sort. A quick way to
    snapshot something before you change it.

.PARAMETER Path
    The file or folder to back up. Required.

.PARAMETER Destination
    Folder to write the .zip into. Default: same folder as the item.

.EXAMPLE
    .\Backup-Item.ps1 -Path .\report.xlsx
    Creates report_20260626_174500.zip next to the file.

.EXAMPLE
    .\Backup-Item.ps1 -Path C:\work\project -Destination D:\backups
    Zips the project folder into D:\backups with a timestamped name.

.NOTES
    Windows, macOS, Linux. Windows PowerShell 5.1 or PowerShell 7+.
    MIT License. The Office Lab BV.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$Destination
)

if (-not (Test-Path $Path)) {
    Write-Host "Not found: $Path" -ForegroundColor Red
    exit 1
}

$item = Get-Item -LiteralPath $Path
if ([string]::IsNullOrWhiteSpace($Destination)) {
    $Destination = $item.PSParentPath -replace '^.*::', ''
}
if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

$stamp    = Get-Date -Format "yyyyMMdd_HHmmss"
$baseName = if ($item.PSIsContainer) { $item.Name } else { $item.BaseName }
$zipPath  = Join-Path $Destination ("{0}_{1}.zip" -f $baseName, $stamp)

Write-Host "Backing up $($item.FullName)" -ForegroundColor Cyan
try {
    Compress-Archive -Path $item.FullName -DestinationPath $zipPath -Force -ErrorAction Stop
    $size = (Get-Item $zipPath).Length
    Write-Host ("Done: {0} ({1:N0} bytes)" -f $zipPath, $size) -ForegroundColor Green
}
catch {
    Write-Host "Backup failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
