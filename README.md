# Working-tools

Small, practical scripts and functions that make daily work a little smoother.
Maintained by **[The Office Lab](https://theofficelab.eu)**.

Each tool is self-contained, dependency-light, and documented below. Use what you
need, ignore the rest.

## Tools

| Tool | Platform | What it does |
|------|----------|--------------|
| [`StayAwake.ps1`](#stayawakeps1) | Windows / PowerShell | Keeps a PC or laptop awake: no sleep, no display-off, no idle lock. |

---

## StayAwake.ps1

Keeps a Windows machine awake for as long as you need it. It stops the system
from sleeping, the display from switching off, and idle-sensitive apps from
marking you inactive.

### Why

- A long-running script, build, render, or download needs to finish unattended.
- You work across several machines at once and do not want the idle ones to drop
  off or lock.
- You are presenting or reading and do not want the screen to dim.

### How it works

StayAwake calls the Windows `SetThreadExecutionState` API, the same mechanism
used by tools like PowerToys Awake and Caffeine, to tell Windows that the system
and display are required. By default it also issues a single **F15** key signal
on each interval to reset the user idle timer. F15 is a phantom key that no
physical keyboard sends, so it has no visible side effect: it does not type
anything and does not interfere with what you are doing.

Normal power behaviour is restored automatically when the script stops.

### Requirements

- Windows
- Windows PowerShell 5.1 or PowerShell 7+
- No modules, no admin rights

### Getting started (step by step)

No installation. It is a single file you run when you need it.

1. **Download the script.** Open [`StayAwake.ps1`](StayAwake.ps1) here on GitHub,
   click the **Raw** button, then press **Ctrl+S** to save it. Or use the green
   **Code** button at the top of the repo and choose **Download ZIP**.
2. **Put it somewhere easy**, for example your `Downloads` or `Documents` folder.
3. **Unblock it.** Windows flags files that come from the internet. Right-click
   `StayAwake.ps1`, choose **Properties**, tick **Unblock** at the bottom, then
   **OK**. (This is a one-time step.)
4. **Open PowerShell in that folder.** In File Explorer, open the folder where you
   saved the file, hold **Shift**, right-click an empty area, and choose
   **Open PowerShell window here** (or **Open in Terminal**).
5. **Run it.** Type the line below and press Enter:
   ```powershell
   .\StayAwake.ps1
   ```
   You will see a "StayAwake started" message and a ticking counter. Your PC will
   now stay awake.
6. **Stop it.** Press **Ctrl+C** in that window, or just close the window. Your
   normal sleep and lock settings come straight back.

That is the whole thing. The examples below cover the optional timers.

### Usage

```powershell
# Run until you press Ctrl+C
.\StayAwake.ps1

# Run for a fixed number of minutes
.\StayAwake.ps1 -Minutes 90

# Run until a clock time
.\StayAwake.ps1 -Till "18:00"
.\StayAwake.ps1 -Till "2:30 PM"

# Prevent sleep and display-off only, leave the idle timer alone
.\StayAwake.ps1 -NoInput
```

If PowerShell blocks the script on first run, allow it for the current session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Minutes` | int | `0` | Run for this many minutes, then stop. |
| `-Till` | string | `""` | Run until a clock time, e.g. `"14:30"` or `"2:30 PM"`. |
| `-IntervalSeconds` | int | `60` | Seconds between idle-timer refresh signals. |
| `-NoInput` | switch | off | Hold the sleep/display lock only; do not touch the idle timer. |

If both `-Minutes` and `-Till` are given, `-Minutes` wins. With neither, it runs
until you stop it with Ctrl+C.

---

## License

[MIT](LICENSE) (c) The Office Lab BV. Use freely, no warranty.

## Contributing

Issues and pull requests are welcome. Keep tools small, self-contained, and
documented in this README.
