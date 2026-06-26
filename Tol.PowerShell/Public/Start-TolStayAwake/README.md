# Start-TolStayAwake

Keeps a Windows PC or laptop awake: no sleep, no display-off, no idle lock.

## Why

- A long-running script, build, render, or download needs to finish unattended.
- You work across several machines at once and do not want the idle ones to drop off.
- You are presenting or reading and do not want the screen to dim.

## How it works

Calls the Windows `SetThreadExecutionState` API (the mechanism behind PowerToys
Awake and Caffeine) to mark the system and display as required, so neither sleeps.
By default it also issues a single **F15** key signal on each interval to reset the
user idle timer. F15 is a phantom key that no physical keyboard sends, so it has no
visible side effect. Normal power behaviour returns automatically when the command
stops.

## Usage

```powershell
Start-TolStayAwake                 # until Ctrl+C
Start-TolStayAwake -Minutes 90     # for 90 minutes
Start-TolStayAwake -Till "18:00"   # until 18:00
Start-TolStayAwake -NoInput        # prevent sleep/display-off only
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Minutes` | int | `0` | Run for this many minutes, then stop. |
| `-Till` | string | `""` | Run until a clock time, e.g. `"14:30"` or `"2:30 PM"`. |
| `-IntervalSeconds` | int | `60` | Seconds between idle-timer refresh signals. |
| `-NoInput` | switch | off | Hold the sleep/display lock only; do not touch the idle timer. |

If both `-Minutes` and `-Till` are given, `-Minutes` wins. With neither, it runs
until you press Ctrl+C.

## Notes

Windows only.
