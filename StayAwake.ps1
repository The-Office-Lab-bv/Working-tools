<#
.SYNOPSIS
    Keeps a Windows PC or laptop awake: prevents sleep, display-off, and idle lock.

.DESCRIPTION
    StayAwake stops a machine from sleeping or locking while you need it to stay
    available. Handy when a long-running script, build, render, or download is in
    progress, when you are working across several machines at once and do not want
    the idle ones to drop off, or while presenting.

    It uses the Windows SetThreadExecutionState API (the same mechanism behind
    tools such as PowerToys Awake and Caffeine) to tell Windows that the system and
    display are required, so neither goes to sleep. Optionally it also issues a
    harmless F15 key signal on each interval to reset the user idle timer, which
    keeps idle-sensitive apps from marking you inactive. F15 is a phantom key that
    no physical keyboard sends, so it has no visible side effect.

    Normal power behaviour returns automatically when the script ends.

.PARAMETER Minutes
    Run for this many minutes, then stop and release the wake lock.

.PARAMETER Till
    Run until a clock time such as "14:30" or "2:30 PM", then stop.

.PARAMETER IntervalSeconds
    Seconds between idle-timer refresh signals. Default 60.

.PARAMETER NoInput
    Hold only the system and display wake lock; do not send the F15 idle-reset
    signal. Use this if you just want to stop the machine sleeping and do not care
    about the idle timer.

.EXAMPLE
    .\StayAwake.ps1
    Keeps the PC awake until you press Ctrl+C.

.EXAMPLE
    .\StayAwake.ps1 -Minutes 90
    Keeps the PC awake for 90 minutes, e.g. while a script runs unattended.

.EXAMPLE
    .\StayAwake.ps1 -Till "18:00"
    Keeps the PC awake until 18:00.

.EXAMPLE
    .\StayAwake.ps1 -NoInput
    Prevents sleep and display-off only, without touching the idle timer.

.NOTES
    Windows only. Works on Windows PowerShell 5.1 and PowerShell 7+.
    MIT License. The Office Lab BV.
#>

[CmdletBinding()]
param(
    [int]$Minutes = 0,
    [string]$Till = "",
    [int]$IntervalSeconds = 60,
    [switch]$NoInput
)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class StayAwakeNative {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);

    // SetThreadExecutionState flags
    public const uint ES_CONTINUOUS        = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED   = 0x00000001;
    public const uint ES_DISPLAY_REQUIRED  = 0x00000002;

    // Virtual key + key event flags for the idle-reset signal
    public const byte VK_F15           = 0x7E; // phantom key, no side effect
    public const uint KEYEVENTF_KEYUP  = 0x02;
}
"@

function Set-WakeLock {
    # Tell Windows the system and display are required (prevents sleep + screen-off).
    [void][StayAwakeNative]::SetThreadExecutionState(
        [StayAwakeNative]::ES_CONTINUOUS -bor `
        [StayAwakeNative]::ES_SYSTEM_REQUIRED -bor `
        [StayAwakeNative]::ES_DISPLAY_REQUIRED)
}

function Clear-WakeLock {
    # Release the lock so normal power settings resume.
    [void][StayAwakeNative]::SetThreadExecutionState([StayAwakeNative]::ES_CONTINUOUS)
}

function Send-IdleReset {
    # A single F15 down/up to reset the user idle timer. Invisible, no side effect.
    [StayAwakeNative]::keybd_event([StayAwakeNative]::VK_F15, 0, 0, 0)
    Start-Sleep -Milliseconds 40
    [StayAwakeNative]::keybd_event([StayAwakeNative]::VK_F15, 0, [StayAwakeNative]::KEYEVENTF_KEYUP, 0)
}

function Get-EndTime {
    param($Till, $Minutes)
    if ($Minutes -gt 0) {
        return (Get-Date).AddMinutes($Minutes)
    }
    elseif ($Till -ne "") {
        try {
            return [DateTime]::Parse($Till)
        }
        catch {
            Write-Host "Invalid -Till value. Use a clock time such as '14:30' or '2:30 PM'." -ForegroundColor Red
            exit 1
        }
    }
    else {
        return $null
    }
}

if ($IntervalSeconds -lt 1) { $IntervalSeconds = 60 }

$endTime = Get-EndTime -Till $Till -Minutes $Minutes

Write-Host "StayAwake started" -ForegroundColor Green
if ($endTime) {
    Write-Host ("Running until {0}" -f $endTime.ToString('yyyy-MM-dd HH:mm:ss')) -ForegroundColor Yellow
} else {
    Write-Host "Running until you press Ctrl+C" -ForegroundColor Yellow
}
if ($NoInput) {
    Write-Host "Mode: sleep/display lock only (idle timer untouched)" -ForegroundColor Yellow
} else {
    Write-Host ("Mode: sleep/display lock + idle reset every {0}s" -f $IntervalSeconds) -ForegroundColor Yellow
}
Write-Host "----------------------------------------" -ForegroundColor Cyan

try {
    Set-WakeLock
    $iteration = 0
    while ($true) {
        if ($endTime -and (Get-Date) -ge $endTime) {
            Write-Host ("`nReached end time, stopping at {0}" -f (Get-Date -Format 'HH:mm:ss')) -ForegroundColor Green
            break
        }

        # Re-assert the wake lock each loop (cheap and robust).
        Set-WakeLock
        if (-not $NoInput) { Send-IdleReset }

        $iteration++
        $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($endTime) {
            $remaining = $endTime - (Get-Date)
            $remainingText = "{0:D2}:{1:D2}:{2:D2}" -f [int]$remaining.TotalHours, $remaining.Minutes, $remaining.Seconds
            Write-Host ("[{0}] {1}  (remaining {2})" -f $iteration, $now, $remainingText) -ForegroundColor White
        } else {
            Write-Host ("[{0}] {1}" -f $iteration, $now) -ForegroundColor White
        }

        Start-Sleep -Seconds $IntervalSeconds
    }
}
catch {
    Write-Host "`nStopped." -ForegroundColor Red
}
finally {
    Clear-WakeLock
    Write-Host "StayAwake stopped. Normal power settings restored." -ForegroundColor Green
}
