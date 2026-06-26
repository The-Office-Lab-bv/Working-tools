# Contributing

Thanks for your interest. These are small, self-contained tools and the bar is simple:
each one should do one useful thing well and be easy to read.

## Adding a tool

1. **Pick a name** using an approved PowerShell verb and the `Tol` noun prefix, for
   example `Get-TolSomething`. Check approved verbs with `Get-Verb`.
2. **Create a folder** under `tools/` named after the command, e.g.
   `tools/Get-TolSomething/`.
3. **Add the function** in `tools/Get-TolSomething/Get-TolSomething.ps1` as a single
   advanced function:
   ```powershell
   function Get-TolSomething {
       [CmdletBinding()]
       param( ... )
       # comment-based help (.SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE)
       ...
   }
   ```
4. **Add a `README.md`** in the same folder: what it does, why, usage, parameters.
5. **Export it**: add the command name to `FunctionsToExport` in
   `Tol.PowerShell.psd1`.
6. **Link it** from the tool table in the root `README.md`.
7. **Update** `CHANGELOG.md`.

Shared helpers that are not meant to be called directly go in `private/` and are not
exported.

## Style

- One function per file, file name matches the function name.
- Use approved verbs only (no import warnings).
- Cross-platform where it makes sense; mark Windows-only tools clearly.
- No external module dependencies, no admin requirement, no telemetry.
- Fail with a clear `throw` message rather than `exit`.

## Testing

Before opening a pull request:

```powershell
# It imports cleanly with no warnings
Import-Module ./Tol.PowerShell.psd1 -Force

# Each file parses
Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
    $e = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$e) | Out-Null
    if ($e) { Write-Warning "$($_.Name): $($e.Message)" }
}
```

Run your tool a few times and confirm it does what the README claims.
