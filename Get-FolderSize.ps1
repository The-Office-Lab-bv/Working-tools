<#
.SYNOPSIS
    Shows how much disk space each subfolder uses, largest first.

.DESCRIPTION
    Get-FolderSize scans a path and reports the total size of each immediate
    subfolder (and optionally the loose files), sorted from largest to smallest,
    in human-readable units. Handy for tracking down what is filling a drive.

.PARAMETER Path
    Folder to scan. Default: current directory.

.PARAMETER Top
    Show only the largest N entries. Default 0 = show all.

.PARAMETER Files
    Also include loose files in the listed folder, not just subfolders.

.EXAMPLE
    .\Get-FolderSize.ps1
    Sizes of the subfolders in the current directory.

.EXAMPLE
    .\Get-FolderSize.ps1 -Path C:\Users\me\Downloads -Top 10
    The ten biggest items in Downloads.

.NOTES
    Windows, macOS, Linux. Windows PowerShell 5.1 or PowerShell 7+.
    MIT License. The Office Lab BV.
#>

[CmdletBinding()]
param(
    [string]$Path = ".",
    [int]$Top = 0,
    [switch]$Files
)

function Format-Size {
    param([long]$Bytes)
    $units = "B", "KB", "MB", "GB", "TB"
    $size = [double]$Bytes
    $i = 0
    while ($size -ge 1024 -and $i -lt $units.Count - 1) {
        $size /= 1024
        $i++
    }
    return ("{0,8:N1} {1}" -f $size, $units[$i])
}

if (-not (Test-Path $Path)) {
    Write-Host "Path not found: $Path" -ForegroundColor Red
    exit 1
}

$base = (Resolve-Path $Path).Path
Write-Host "Scanning $base ..." -ForegroundColor Cyan

$items = Get-ChildItem -LiteralPath $base -Force -ErrorAction SilentlyContinue |
    Where-Object { $Files -or $_.PSIsContainer }

$results = foreach ($item in $items) {
    if ($item.PSIsContainer) {
        $bytes = (Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
    } else {
        $bytes = $item.Length
    }
    [pscustomobject]@{
        Name  = $item.Name + $(if ($item.PSIsContainer) { "\" } else { "" })
        Bytes = [long]($bytes | ForEach-Object { if ($_) { $_ } else { 0 } })
    }
}

$sorted = $results | Sort-Object Bytes -Descending
if ($Top -gt 0) { $sorted = $sorted | Select-Object -First $Top }

Write-Host "------------------------------------------------" -ForegroundColor Cyan
$total = 0
foreach ($r in $sorted) {
    $total += $r.Bytes
    Write-Host ("{0}  {1}" -f (Format-Size $r.Bytes), $r.Name)
}
Write-Host "------------------------------------------------" -ForegroundColor Cyan
Write-Host ("{0}  ({1} items shown)" -f (Format-Size $total), $sorted.Count) -ForegroundColor Green
