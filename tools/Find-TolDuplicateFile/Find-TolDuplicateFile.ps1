function Find-TolDuplicateFile {
    <#
    .SYNOPSIS
        Finds duplicate files under a path by comparing content hashes.

    .DESCRIPTION
        Scans a folder recursively and reports sets of files with identical content.
        It first groups by file size (cheap), then confirms matches with a SHA-256 hash,
        so large trees stay fast. Read-only: it reports duplicates, it never deletes.

    .PARAMETER Path
        Folder to scan. Default: current directory.

    .PARAMETER MinBytes
        Ignore files smaller than this. Default 1 (skips empty files).

    .EXAMPLE
        Find-TolDuplicateFile -Path C:\Users\me\Pictures

    .OUTPUTS
        One object per duplicate set: Hash, Count, Size, Files.
    #>
    [CmdletBinding()]
    param(
        [string]$Path = ".",
        [long]$MinBytes = 1
    )

    if (-not (Test-Path $Path)) { throw "Path not found: $Path" }
    $base = (Resolve-Path $Path).Path
    Write-Host "Scanning $base for duplicates ..." -ForegroundColor Cyan

    $files = Get-ChildItem -LiteralPath $base -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Length -ge $MinBytes }

    $sets = @()
    # Only files that share a size can be duplicates; hash just those.
    $files | Group-Object Length | Where-Object { $_.Count -gt 1 } | ForEach-Object {
        $_.Group |
            Group-Object { (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash } |
            Where-Object { $_.Count -gt 1 } |
            ForEach-Object {
                $sets += [pscustomobject]@{
                    Hash  = $_.Name
                    Count = $_.Count
                    Size  = Format-TolSize ($_.Group[0].Length)
                    Files = $_.Group.FullName
                }
            }
    }

    if (-not $sets) {
        Write-Host "No duplicates found." -ForegroundColor Green
        return
    }

    Write-Host ("Found {0} duplicate set(s):" -f $sets.Count) -ForegroundColor Yellow
    foreach ($s in $sets) {
        Write-Host ("`n[{0} copies, {1} each]" -f $s.Count, $s.Size.Trim()) -ForegroundColor White
        $s.Files | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    }
    return $sets
}
