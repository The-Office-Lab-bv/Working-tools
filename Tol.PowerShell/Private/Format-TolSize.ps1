function Format-TolSize {
    # Internal helper: turn a byte count into a padded human-readable string.
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][long]$Bytes)

    $units = "B", "KB", "MB", "GB", "TB", "PB"
    $size = [double]$Bytes
    $i = 0
    while ($size -ge 1024 -and $i -lt $units.Count - 1) {
        $size /= 1024
        $i++
    }
    return ("{0,8:N1} {1}" -f $size, $units[$i])
}
