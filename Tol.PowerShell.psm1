# Tol.PowerShell root module
# Loads the private helpers, then every tool function under tools/<Command>/, and
# exports the public commands. Each tool lives in its own folder with a README.

$Private = @(Get-ChildItem -Path (Join-Path $PSScriptRoot 'private') -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue)
$Public  = @(Get-ChildItem -Path (Join-Path $PSScriptRoot 'tools')   -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue)

foreach ($file in @($Private + $Public)) {
    try {
        . $file.FullName
    }
    catch {
        Write-Error "Failed to import $($file.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName
