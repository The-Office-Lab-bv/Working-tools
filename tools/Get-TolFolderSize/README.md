# Get-TolFolderSize

Shows how much disk space each subfolder uses, largest first, in human-readable units.

## Why

The fast way to find what is filling a drive, without opening a GUI disk analyser.

## Usage

```powershell
Get-TolFolderSize                                            # current directory
Get-TolFolderSize -Path C:\Users\me\Downloads -Top 10 -Files # 10 biggest, files too
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Path` | string | `.` | Folder to scan. |
| `-Top` | int | `0` | Show only the largest N entries (`0` = all). |
| `-Files` | switch | off | Include loose files, not just subfolders. |

## Example output

```
    1.2 GB  node_modules\
  340.5 MB  assets\
   12.0 MB  docs\
------------------------------------------------
    1.5 GB  (3 items shown)
```

## Notes

Cross-platform. Sizes are summed recursively per top-level entry.
