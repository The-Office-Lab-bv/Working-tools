# Merge-TolCsv

Combines several CSV files into one.

## Why

A constant office chore: many exports, one combined sheet. This does it in a line.

## How it works

Reads every matching CSV in a folder and writes the combined rows to a single output
file. Works best when the files share the same columns. Optionally adds a `SourceFile`
column so you can tell where each row came from. The output file is excluded from its
own input if it sits in the same folder.

## Usage

```powershell
Merge-TolCsv -Path .\exports -OutFile .\all.csv
Merge-TolCsv -Path .\exports -OutFile .\all.csv -Delimiter ";" -AddSourceColumn
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Path` | string | required | Folder containing the CSV files. |
| `-OutFile` | string | required | Path of the combined CSV to write. |
| `-Filter` | string | `*.csv` | Which files to include. |
| `-Delimiter` | string | `,` | Field delimiter used for read and write. |
| `-AddSourceColumn` | switch | off | Add a `SourceFile` column with the originating file name. |

## Notes

Cross-platform. Columns are taken from the data; mixed schemas may produce blank cells.
