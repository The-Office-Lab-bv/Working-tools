function Write-TolLog {
    <#
    .SYNOPSIS
        Writes a timestamped, leveled log line to the console and optionally to a file.

    .DESCRIPTION
        A small, consistent logger so scripts do not each reinvent log formatting. Each
        line is "yyyy-MM-dd HH:mm:ss [LEVEL] message", colour-coded on the console by
        level. Give -Path to also append to a log file (the folder is created if needed).
        Accepts pipeline input, so you can log a stream of messages.

    .PARAMETER Message
        The text to log. Accepts pipeline input.

    .PARAMETER Level
        Information, Warning, Error, Success, or Debug. Default Information.

    .PARAMETER Path
        Optional log file to append to. Created along with its folder if missing.

    .PARAMETER NoConsole
        Do not write to the console, only to the file.

    .EXAMPLE
        Write-TolLog "Job started"

    .EXAMPLE
        Write-TolLog "Disk almost full" -Level Warn -Path .\logs\run.log

    .EXAMPLE
        "step one","step two" | Write-TolLog -Level Success -Path .\logs\run.log
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Message,
        [ValidateSet('Information', 'Warning', 'Error', 'Success', 'Debug')]
        [string]$Level = 'Information',
        [string]$Path,
        [switch]$NoConsole
    )
    begin {
        $colors = @{
            Information = 'Gray'
            Warning     = 'Yellow'
            Error       = 'Red'
            Success     = 'Green'
            Debug       = 'DarkGray'
        }
    }
    process {
        $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $tag   = $Level.ToUpper().PadRight(11)
        $line  = "$stamp [$tag] $Message"

        if (-not $NoConsole) {
            Write-Host $line -ForegroundColor $colors[$Level]
        }
        if ($Path) {
            $dir = Split-Path -Parent $Path
            if ($dir -and -not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            Add-Content -LiteralPath $Path -Value $line -Encoding UTF8
        }
    }
}
