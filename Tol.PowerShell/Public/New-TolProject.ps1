function New-TolProject {
    <#
    .SYNOPSIS
        Scaffolds a new project folder: structure, README, .gitignore, optional git repo.

    .DESCRIPTION
        Asks a few quick yes/no questions (or takes everything as parameters) and lays
        down a tidy project skeleton. For each optional folder (docs, functions, input,
        output, logs, tests) it asks. It can also add a starter README.md, a sensible
        .gitignore, an MIT LICENSE, and run "git init" with a first commit.

        Empty folders keep a .gitkeep. Data folders (input, output, logs) are git-ignored
        by content while the folder itself stays.

    .PARAMETER Name
        Project name (becomes the folder name). Prompted for if omitted.

    .PARAMETER Path
        Where to create the project folder. Default: current directory.

    .PARAMETER Quiet
        No prompts, accept every default. Requires -Name.

    .EXAMPLE
        New-TolProject

    .EXAMPLE
        New-TolProject -Name "invoice-tool"

    .EXAMPLE
        New-TolProject -Name "quick-poc" -Quiet
    #>
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$Path = ".",
        [switch]$Quiet
    )

    function Read-YesNo {
        param([string]$Question, [bool]$Default = $true)
        if ($Quiet) { return $Default }
        $suffix = if ($Default) { "[Y/n]" } else { "[y/N]" }
        $answer = Read-Host "$Question $suffix"
        if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
        return $answer -match '^(y|yes|j|ja)$'
    }

    if ([string]::IsNullOrWhiteSpace($Name)) {
        if ($Quiet) { throw "A project name is required with -Quiet." }
        $Name = Read-Host "Project name"
        if ([string]::IsNullOrWhiteSpace($Name)) { Write-Warning "No name given, nothing to do."; return }
    }

    $root = Join-Path -Path $Path -ChildPath $Name
    if (Test-Path $root) { throw "Folder '$root' already exists. Pick another name or location." }

    Write-Host ""
    Write-Host "Creating project: $Name" -ForegroundColor Green
    Write-Host "Location:         $((Resolve-Path $Path).Path)" -ForegroundColor Gray
    Write-Host "------------------------------------------------" -ForegroundColor Cyan

    $wantReadme    = Read-YesNo "Add a README.md?"            $true
    $wantGitignore = Read-YesNo "Add a .gitignore?"          $true
    $wantLicense   = Read-YesNo "Add an MIT LICENSE?"        $false
    $wantDocs      = Read-YesNo "Add a docs/ folder?"        $true
    $wantFunctions = Read-YesNo "Add a functions/ folder?"   $true
    $wantInput     = Read-YesNo "Add an input/ folder?"      $true
    $wantOutput    = Read-YesNo "Add an output/ folder?"     $true
    $wantLogs      = Read-YesNo "Add a logs/ folder?"        $true
    $wantTests     = Read-YesNo "Add a tests/ folder?"       $false
    $wantGit       = Read-YesNo "Initialise a git repository?" $false

    New-Item -ItemType Directory -Path $root -Force | Out-Null

    $codeFolders = @()
    if ($wantDocs)      { $codeFolders += "docs" }
    if ($wantFunctions) { $codeFolders += "functions" }
    if ($wantTests)     { $codeFolders += "tests" }

    $dataFolders = @()
    if ($wantInput)  { $dataFolders += "input" }
    if ($wantOutput) { $dataFolders += "output" }
    if ($wantLogs)   { $dataFolders += "logs" }

    foreach ($f in ($codeFolders + $dataFolders)) {
        $dir = Join-Path $root $f
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $dir ".gitkeep") -Force | Out-Null
    }

    if ($wantReadme) {
        $structure = [string]::Join("`n", (($codeFolders + $dataFolders) | ForEach-Object { "- ``$_/``" }))
        $readme = @"
# $Name

> One line about what this project does.

## Getting started

Describe how to install and run it here.

## Structure

$structure
"@
        Set-Content -Path (Join-Path $root "README.md") -Value $readme -Encoding UTF8
    }

    if ($wantGitignore) {
        $lines = @(
            "# Secrets", ".env", "*.key", "*.pem", "",
            "# OS and editor noise", ".DS_Store", "Thumbs.db", ".vscode/", "*.tmp", "*.log"
        )
        foreach ($d in $dataFolders) {
            $lines += ""
            $lines += "# $d data is local, keep the folder only"
            $lines += "$d/*"
            $lines += "!$d/.gitkeep"
        }
        Set-Content -Path (Join-Path $root ".gitignore") -Value ($lines -join "`n") -Encoding UTF8
    }

    if ($wantLicense) {
        $year = (Get-Date).Year
        $license = @"
MIT License

Copyright (c) $year The Office Lab BV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@
        Set-Content -Path (Join-Path $root "LICENSE") -Value $license -Encoding UTF8
    }

    if ($wantGit) {
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Push-Location $root
            git init -q
            git add -A
            git commit -q -m "Initial project scaffold" 2>$null
            Pop-Location
        } else {
            Write-Host "git not found on PATH, skipped repository init." -ForegroundColor Yellow
        }
    }

    Write-Host "------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Done. Project created at:" -ForegroundColor Green
    Write-Host "  $((Resolve-Path $root).Path)" -ForegroundColor White
    Get-ChildItem -Path $root -Force | Sort-Object { -not $_.PSIsContainer }, Name |
        ForEach-Object {
            $tag = if ($_.PSIsContainer) { "[dir] " } else { "      " }
            Write-Host ("  {0}{1}" -f $tag, $_.Name) -ForegroundColor Gray
        }
}
