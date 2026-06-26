# Write-TolLog

Writes a timestamped, leveled log line to the console and, optionally, to a file. So
scripts do not each reinvent log formatting.

## Why

One consistent log format across all your scripts, with colour on screen and a clean
append-only file when you want a record.

## Format

```
2026-06-26 18:20:00 [INFORMATION] Job started
2026-06-26 18:20:01 [WARNING    ] Disk almost full
2026-06-26 18:20:02 [ERROR      ] Upload failed
2026-06-26 18:20:03 [SUCCESS    ] All done
```

Console output is colour-coded by level (Information gray, Warning yellow, Error red,
Success green, Debug dark gray).

## Usage

```powershell
Write-TolLog "Job started"
Write-TolLog "Disk almost full" -Level Warning -Path .\logs\run.log
Write-TolLog "All done" -Level Success -Path .\logs\run.log

# Pipe a stream of messages
"step one","step two" | Write-TolLog -Level Information -Path .\logs\run.log

# File only, no console
Write-TolLog "background note" -Path .\logs\run.log -NoConsole
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Message` | string | required | Text to log. Accepts pipeline input. |
| `-Level` | string | `Information` | One of `Information`, `Warning`, `Error`, `Success`, `Debug`. |
| `-Path` | string | none | Log file to append to. Folder is created if missing. |
| `-NoConsole` | switch | off | Write only to the file, not the console. |

## Notes

Cross-platform. The log file is plain UTF-8 text, append-only.
