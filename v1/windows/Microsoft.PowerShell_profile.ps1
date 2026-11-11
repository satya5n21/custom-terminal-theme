$esc = [char]27

# Gradient text helper (cyan -> purple)
function Write-Gradient($text) {
    $len = $text.Length; $i = 0
    foreach ($c in $text.ToCharArray()) {
        $t = $i / [Math]::Max($len - 1, 1)
        $r = [int](0   + 180 * $t)
        $g = [int](230 - 150 * $t)
        $b = [int](255)
        Write-Host -NoNewline "${esc}[38;2;${r};${g};${b}m$c"
        $i++
    }
    Write-Host "${esc}[0m"
}

Clear-Host

# Time-aware greeting
$hour = (Get-Date).Hour
$greet = if ($hour -lt 12) { "Good morning" } elseif ($hour -lt 18) { "Good afternoon" } else { "Good evening" }

# System info
$boot   = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$up     = (Get-Date) - $boot
$uptime = "{0}d {1}h {2}m" -f $up.Days, $up.Hours, $up.Minutes

Write-Host ""
Write-Gradient "+==============================================+"
Write-Gradient "   >>>  $greet, Satya"
Write-Gradient "+==============================================+"
Write-Host "  ${esc}[90mDATE:${esc}[0m $(Get-Date -Format 'dddd, dd MMM yyyy')   ${esc}[90mTIME:${esc}[0m $(Get-Date -Format 'HH:mm')"
# Write-Host "  ${esc}[90mPC:${esc}[0m $env:COMPUTERNAME   ${esc}[90mUP:${esc}[0m $uptime   ${esc}[90mPS:${esc}[0m $($PSVersionTable.PSVersion)"

# Random dev quote
$quotes = @(
    "Ship it. Then make it better.",
    "Make it work, make it right, make it fast.",
    "Build in public. Learn in public.",
    "Talk is cheap. Show me the code.",
    "Stay curious. Look up."
)
Write-Host "  ${esc}[3m${esc}[35m`"$($quotes | Get-Random)`"${esc}[0m"
Write-Host ""

# Two-line prompt with git branch
function prompt {
    $esc    = [char]27
    $path   = (Get-Location).Path.Replace($HOME, '~')
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    $git    = if ($branch) { " ${esc}[35m(git:$branch)${esc}[0m" } else { "" }
    $time   = Get-Date -Format "HH:mm"
    "${esc}[90m+-- ${esc}[36m$time ${esc}[32m$path$git`n${esc}[90m'-${esc}[96m> ${esc}[0m"
}