# New-TolProject

A run-once project scaffolder. Lays down a tidy folder structure, a starter README,
a sensible `.gitignore`, an optional MIT LICENSE, and can run `git init` with a first
commit, all in one go.

## Why

Start working instead of making the same folders by hand every time you spin up a
new project or proof of concept.

## How it works

Asks a few yes/no questions (or takes everything as parameters). Code folders
(`docs`, `functions`, `tests`) keep a `.gitkeep`. Data folders (`input`, `output`,
`logs`) keep a `.gitkeep` too, but their contents are git-ignored so local data does
not get committed by accident.

## Usage

```powershell
New-TolProject                          # interactive, walks the options
New-TolProject -Name "invoice-tool"     # name up front, then the folder questions
New-TolProject -Name "quick-poc" -Quiet # full skeleton, all defaults, no questions
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Name` | string | prompted | Project name (becomes the folder name). |
| `-Path` | string | `.` | Where to create the project folder. |
| `-Quiet` | switch | off | No prompts, accept every default. Requires `-Name`. |

## Example result

```
invoice-tool/
├── README.md
├── .gitignore
├── docs/        (.gitkeep)
├── functions/   (.gitkeep)
├── input/       (.gitkeep, contents ignored)
├── output/      (.gitkeep, contents ignored)
└── logs/        (.gitkeep, contents ignored)
```

## Notes

Cross-platform (Windows, macOS, Linux).
