function Get-TolFolderSize {
    <#
    .SYNOPSIS
        Shows how much disk space each subfolder uses, largest first.

    .DESCRIPTION
        Scans a path and reports the total size of each immediate subfolder (and
        optionally loose files), sorted largest to smallest, in human-readable units.
        Handy for tracking down what is filling a drive.

    .PARAMETER Path
        Folder to scan. Default: current directory.

    .PARAMETER Top
        Show only the largest N entries. Default 0 = all.

    .PARAMETER Files
        Also include loose files, not just subfolders.

    .EXAMPLE
        Get-TolFolderSize

    .EXAMPLE
        Get-TolFolderSize -Path C:\Users\me\Downloads -Top 10 -Files
    #>
    [CmdletBinding()]
    param(
        [string]$Path = ".",
        [int]$Top = 0,
        [switch]$Files
    )

    if (-not (Test-Path $Path)) { throw "Path not found: $Path" }

    $base = (Resolve-Path $Path).Path
    Write-Host "Scanning $base ..." -ForegroundColor Cyan

    $items = Get-ChildItem -LiteralPath $base -Force -ErrorAction SilentlyContinue |
        Where-Object { $Files -or $_.PSIsContainer }

    $results = foreach ($item in $items) {
        if ($item.PSIsContainer) {
            $sum = (Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum).Sum
        } else {
            $sum = $item.Length
        }
        $bytes = if ($sum) { [long]$sum } else { [long]0 }
        [pscustomobject]@{
            Name  = $item.Name + $(if ($item.PSIsContainer) { [IO.Path]::DirectorySeparatorChar } else { "" })
            Bytes = $bytes
        }
    }

    $sorted = $results | Sort-Object Bytes -Descending
    if ($Top -gt 0) { $sorted = $sorted | Select-Object -First $Top }

    Write-Host "------------------------------------------------" -ForegroundColor Cyan
    $total = [long]0
    foreach ($r in $sorted) {
        $total += $r.Bytes
        Write-Host ("{0}  {1}" -f (Format-TolSize $r.Bytes), $r.Name)
    }
    Write-Host "------------------------------------------------" -ForegroundColor Cyan
    Write-Host ("{0}  ({1} items shown)" -f (Format-TolSize $total), @($sorted).Count) -ForegroundColor Green
}
