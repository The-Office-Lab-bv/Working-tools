function Start-TolStayAwake {
    <#
    .SYNOPSIS
        Keeps a Windows PC or laptop awake: prevents sleep, display-off, and idle lock.

    .DESCRIPTION
        Stops a machine from sleeping or locking while you need it available. Handy
        when a long-running script, build, render, or download is in progress, when
        working across several machines at once, or while presenting.

        Uses the Windows SetThreadExecutionState API (the mechanism behind PowerToys
        Awake and Caffeine) to mark the system and display as required. By default it
        also issues a harmless F15 key signal each interval to reset the user idle
        timer. F15 is a phantom key with no visible side effect. Normal power
        behaviour returns when the command stops.

    .PARAMETER Minutes
        Run for this many minutes, then stop.

    .PARAMETER Till
        Run until a clock time such as "14:30" or "2:30 PM".

    .PARAMETER IntervalSeconds
        Seconds between idle-timer refresh signals. Default 60.

    .PARAMETER NoInput
        Hold the sleep/display lock only; do not send the F15 idle-reset signal.

    .EXAMPLE
        Start-TolStayAwake
        Keeps the PC awake until you press Ctrl+C.

    .EXAMPLE
        Start-TolStayAwake -Minutes 90

    .EXAMPLE
        Start-TolStayAwake -Till "18:00"

    .NOTES
        Windows only.
    #>
    [CmdletBinding()]
    param(
        [int]$Minutes = 0,
        [string]$Till = "",
        [int]$IntervalSeconds = 60,
        [switch]$NoInput
    )

    if (-not ([System.Management.Automation.PSTypeName]'TolStayAwakeNative').Type) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class TolStayAwakeNative {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);
    public const uint ES_CONTINUOUS       = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED  = 0x00000001;
    public const uint ES_DISPLAY_REQUIRED = 0x00000002;
    public const byte VK_F15              = 0x7E;
    public const uint KEYEVENTF_KEYUP     = 0x02;
}
"@
    }

    $setLock = {
        [void][TolStayAwakeNative]::SetThreadExecutionState(
            [TolStayAwakeNative]::ES_CONTINUOUS -bor `
            [TolStayAwakeNative]::ES_SYSTEM_REQUIRED -bor `
            [TolStayAwakeNative]::ES_DISPLAY_REQUIRED)
    }
    $clearLock = {
        [void][TolStayAwakeNative]::SetThreadExecutionState([TolStayAwakeNative]::ES_CONTINUOUS)
    }
    $idleReset = {
        [TolStayAwakeNative]::keybd_event([TolStayAwakeNative]::VK_F15, 0, 0, 0)
        Start-Sleep -Milliseconds 40
        [TolStayAwakeNative]::keybd_event([TolStayAwakeNative]::VK_F15, 0, [TolStayAwakeNative]::KEYEVENTF_KEYUP, 0)
    }

    if ($IntervalSeconds -lt 1) { $IntervalSeconds = 60 }

    $endTime = $null
    if ($Minutes -gt 0) {
        $endTime = (Get-Date).AddMinutes($Minutes)
    }
    elseif ($Till -ne "") {
        try { $endTime = [DateTime]::Parse($Till) }
        catch { throw "Invalid -Till value. Use a clock time such as '14:30' or '2:30 PM'." }
    }

    Write-Host "StayAwake started" -ForegroundColor Green
    if ($endTime) {
        Write-Host ("Running until {0}" -f $endTime.ToString('yyyy-MM-dd HH:mm:ss')) -ForegroundColor Yellow
    } else {
        Write-Host "Running until you press Ctrl+C" -ForegroundColor Yellow
    }

    try {
        & $setLock
        $iteration = 0
        while ($true) {
            if ($endTime -and (Get-Date) -ge $endTime) {
                Write-Host ("`nReached end time, stopping at {0}" -f (Get-Date -Format 'HH:mm:ss')) -ForegroundColor Green
                break
            }
            & $setLock
            if (-not $NoInput) { & $idleReset }

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
        & $clearLock
        Write-Host "StayAwake stopped. Normal power settings restored." -ForegroundColor Green
    }
}
