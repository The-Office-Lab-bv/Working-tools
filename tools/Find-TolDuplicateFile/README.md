# Find-TolDuplicateFile

Finds duplicate files under a path by comparing content hashes. Read-only: it reports
duplicates, it never deletes anything.

## Why

Track down wasted space from copies of the same file scattered across a folder tree.

## How it works

Scans recursively, groups files by size first (cheap), then confirms true matches with
a SHA-256 hash, so large trees stay fast. Only files that share both size and hash are
reported as duplicates.

## Usage

```powershell
Find-TolDuplicateFile -Path C:\Users\me\Pictures
$dupes = Find-TolDuplicateFile -Path .   # capture the sets for further processing
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Path` | string | `.` | Folder to scan (recursive). |
| `-MinBytes` | long | `1` | Ignore files smaller than this (default skips empty files). |

## Output

One object per duplicate set: `Hash`, `Count`, `Size`, `Files` (the full paths).

## Notes

Cross-platform. Deliberately does not delete: review the reported sets and remove
copies yourself.
