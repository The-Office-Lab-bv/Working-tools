# Backup-TolItem

Makes a timestamped `.zip` backup of a file or folder.

## Why

A quick safety copy before you change something. Each backup is named after the item
plus a date-time stamp, so snapshots are unique and sort in order.

## Usage

```powershell
Backup-TolItem -Path .\report.xlsx                          # zip next to the file
Backup-TolItem -Path C:\work\project -Destination D:\backups # zip into a folder
```

A run produces, for example, `report_20260626_174500.zip`.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Path` | string | required | File or folder to back up. |
| `-Destination` | string | item's folder | Where to write the `.zip`. |

## Notes

Cross-platform. Returns the path of the created archive so you can pipe it onward.
