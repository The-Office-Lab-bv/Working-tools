function Merge-TolCsv {
    <#
    .SYNOPSIS
        Combines several CSV files into one.

    .DESCRIPTION
        Reads every matching CSV in a folder and writes the combined rows to a single
        output file. Works best when the files share the same columns. Optionally adds a
        SourceFile column so you can tell where each row came from.

    .PARAMETER Path
        Folder containing the CSV files.

    .PARAMETER OutFile
        Path of the combined CSV to write.

    .PARAMETER Filter
        Which files to include. Default "*.csv".

    .PARAMETER Delimiter
        Field delimiter. Default ",".

    .PARAMETER AddSourceColumn
        Add a SourceFile column recording the originating file name.

    .EXAMPLE
        Merge-TolCsv -Path .\exports -OutFile .\all.csv

    .EXAMPLE
        Merge-TolCsv -Path .\exports -OutFile .\all.csv -Delimiter ";" -AddSourceColumn
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$OutFile,
        [string]$Filter = "*.csv",
        [string]$Delimiter = ",",
        [switch]$AddSourceColumn
    )

    if (-not (Test-Path $Path)) { throw "Path not found: $Path" }

    $files = Get-ChildItem -LiteralPath $Path -Filter $Filter -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -ne (Join-Path (Resolve-Path $Path).Path (Split-Path $OutFile -Leaf)) }

    if (-not $files) { Write-Warning "No files matching '$Filter' in $Path."; return }

    $rows = foreach ($f in $files) {
        $data = Import-Csv -LiteralPath $f.FullName -Delimiter $Delimiter
        if ($AddSourceColumn) {
            $data | ForEach-Object {
                $_ | Add-Member -NotePropertyName SourceFile -NotePropertyValue $f.Name -PassThru
            }
        } else {
            $data
        }
    }

    $rows | Export-Csv -LiteralPath $OutFile -Delimiter $Delimiter -NoTypeInformation -Encoding UTF8
    Write-Host ("Merged {0} file(s), {1} row(s) -> {2}" -f $files.Count, @($rows).Count, $OutFile) -ForegroundColor Green
}
