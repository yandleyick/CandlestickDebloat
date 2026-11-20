# CandlestickDebloat | Serpentine FPS Guide
# Windows tweaks: Chris Titus Tech and the WinUtil contributors.
# GPU package customization: TechPowerUp NVCleanstall. Inspiration: Kephrii.
[CmdletBinding()]
param(
    [ValidateSet('All','Windows','Nvidia','PrepareDriver')][string]$Mode = 'All',
    [switch]$Preview
)
$ErrorActionPreference = 'Stop'

$profile = [ordered]@{
    'WPFTweaksRestorePoint' = 'Restore Point - Create'
    'WPFTweaksActivity' = 'Activity History - Disable'
    'WPFTweaksConsumerFeatures' = 'ConsumerFeatures - Disable'
    'WPFTweaksDisableExplorerAutoDiscovery' = 'File Explorer Automatic Folder Discovery - Disable'
    'WPFTweaksWPBT' = 'Windows Platform Binary Table (WPBT) - Disable'
    'WPFTweaksLocation' = 'Location Tracking - Disable'
    'WPFTweaksServices' = 'Services - Set to Manual'
    'WPFTweaksTelemetry' = 'Telemetry - Disable'
    'WPFTweaksDeliveryOptimization' = 'Delivery Optimization - Disable'
    'WPFTweaksDeleteTempFiles' = 'Temporary Files - Remove'
    'WPFTweaksEndTaskOnTaskbar' = 'End Task With Right Click - Enable'
    'WPFTweaksDisableStoreSearch' = 'Microsoft Store Recommended Search Results - Disable'
    'WPFTweaksRevertStartMenu' = 'Start Menu Previous Layout - Enable'
    'WPFTweaksWidget' = 'Widgets - Remove'
    'WPFTweaksRemoveOneDrive' = 'Microsoft OneDrive - Remove'
    'WPFTweaksWindowsAI' = 'Windows AI - Disable And Remove'
    'WPFTweaksRightClickMenu' = 'Right-Click Menu Previous Layout - Enable'
    'WPFTweaksRazerBlock' = 'Razer Software Auto-Install - Disable'
    'WPFTweaksDisableWarningForUnsignedRdp' = 'RDP Unsigned File Warnings - Disable'
    'WPFTweaksRemoveEdge' = 'Microsoft Edge - Remove'
    'WPFTweaksEdgeDebloat' = 'Microsoft Edge - Debloat'
    'WPFTweaksLogiBlock' = 'Logitech Download Assistant Auto-Install - Disable'
    'WPFTweaksRemoveHomeAndGallery' = 'File Explorer Home and Gallery - Disable'
    'WPFTweaksBraveDebloat' = 'Brave Browser - Debloat'
    'WPFTweaksDisableBGapps' = 'Background Apps - Disable'
    'WPFTweaksBlockAdobeNet' = 'Adobe URL Block List - Enable'
    'WPFTweaksDisableSearchIndexing' = 'Windows Search Indexing - Disable'
    'WPFTweaksDisplay' = 'Visual Effects - Set to Best Performance'
    'WPFTweaksDisableNotifications' = 'System Tray Notifications & Calendar - Disable'
    'WPFTweaksSvcHostSplitting' = 'svchost.exe Splitting - Disable'
    'WPFTweaksStorage' = 'Storage Sense - Disable'
    'WPFTweaksHiber' = 'Hibernation - Disable'
    'WPFTweaksDisableBitLocker' = 'BitLocker - Disable'
    'WPFTweaksPreventDeviceMetadataFromNetwork' = 'Prevent Device Companion Apps'
    'WPFTweaksDiskCleanup' = 'Disk Cleanup - Run'
}
$windowsStage = $Mode -in @('All','Windows')
$nvidiaStage = $Mode -in @('All','Nvidia','PrepareDriver')
Write-Host 'CANDLESTICK / SERPENTINE FPS GUIDE' -ForegroundColor Green
if ($windowsStage) {
    Write-Host ("Chris Titus Tech WinUtil 26.11.13 | {0} selected tweaks" -f $profile.Count)
    $profile.Values | ForEach-Object { Write-Host "  - $_" }
    Write-Host 'This preset can decrypt your Windows drive, removes OneDrive and Edge, blocks Adobe domains, and suppresses unsigned RDP file warnings.' -ForegroundColor Yellow
    Write-Host 'It also disables the tray calendar and notifications. The UTC clock tweak is excluded.'
    Write-Host 'Back up important files and finish syncing OneDrive before applying.'
}
if ($nvidiaStage) {
    Write-Host 'TechPowerUp NVCleanstall 1.19.0 | Hardware-specific Recommended components'
    Write-Host 'Installer telemetry and advertising disabled | Clean installation resets driver profiles'
    Write-Host 'NVIDIA setup stays interactive. Save custom graphics settings before continuing.'
}
if ($Preview) { return }
if ($env:OS -ne 'Windows_NT' -or ![Environment]::Is64BitProcess) {
    throw 'Open 64-bit PowerShell on Windows to apply this preset.'
}
$principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Open PowerShell as administrator and run the same command to apply.'
}
if ($nvidiaStage) {
    $gpus = @(Get-CimInstance Win32_VideoController | Where-Object { $_.PNPDeviceID -like 'PCI\VEN_10DE&*' })
    if (!$gpus.Count) {
        if (!$windowsStage) { throw 'No NVIDIA PCI display adapter was detected.' }
        Write-Host 'No NVIDIA PCI display adapter detected. Running the Windows stage only.'
        $nvidiaStage = $false
    } elseif (Get-Process 'NVCleanstall*' -ErrorAction SilentlyContinue) {
        throw 'Close the open NVCleanstall wizard and run the launcher again.'
    }
}
$reply = Read-Host 'Type APPLY to start the displayed stages, or press Enter to exit'
if ($reply -cne 'APPLY') { Write-Host 'Cancelled.'; return }

function Test-FileDigest([string]$Path, [string]$Expected) {
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $Expected) {
        throw "SHA-256 verification failed for $([IO.Path]::GetFileName($Path))."
    }
}
function Get-VerifiedFile([string]$Uri, [string]$Path, [string]$Expected) {
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $Path -TimeoutSec 120
    Test-FileDigest $Path $Expected
    Unblock-File -LiteralPath $Path
}
function Get-DriverUtility([string]$Destination) {
    $digest = '9DD36EF956AF927CF41FA441F91B329A7973E13965E4E7D70E6FA9C1DF1CADE6'
    $vendor = 'https://www.techpowerup.com/download/techpowerup-nvcleanstall/'
    $local = Join-Path $env:USERPROFILE 'Downloads\NVCleanstall_1.19.0.exe'
    if ((Test-Path -LiteralPath $local -PathType Leaf) -and (Get-FileHash -LiteralPath $local).Hash -eq $digest) {
        Copy-Item -LiteralPath $local -Destination $Destination
    } else {
        $mirrors = Invoke-WebRequest -UseBasicParsing -Uri $vendor -Method Post -Body @{id='2849'} -TimeoutSec 40
        $servers = @([regex]::Matches($mirrors.Content, 'name="server_id"\s+value="(\d+)"') |
            ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique -First 4)
        $ok = $false
        foreach ($server in $servers) {
            try {
                Invoke-WebRequest -UseBasicParsing -Uri $vendor -Method Post -Body @{id='2849';server_id=$server} -OutFile $Destination -TimeoutSec 90
                Test-FileDigest $Destination $digest
                $ok = $true
                break
            } catch { Write-Warning "TechPowerUp mirror $server could not supply the verified release." }
        }
        if (!$ok) { throw "Download NVCleanstall 1.19.0 from $vendor into Downloads and retry." }
    }
    Test-FileDigest $Destination $digest
    Unblock-File -LiteralPath $Destination
}

$gate = [Threading.Mutex]::new($false,'Global\CandlestickDebloat-Run')
$held = $false
try {
    try { $held = $gate.WaitOne(0) } catch [Threading.AbandonedMutexException] { $held = $true }
    if (!$held) { throw 'A CandlestickDebloat run is already active.' }
    # WinUtil clears TEMP. Keep verified inputs outside its cleanup paths.
    $run = Join-Path $env:ProgramFiles ('CandlestickDebloat\Runs\' + [guid]::NewGuid().ToString('N'))
    $null = New-Item -ItemType Directory -Path $run -Force
    $winps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $upstream = Join-Path $run 'winutil.ps1'
    $config = Join-Path $run 'winutil.json'
    $driverHelper = Join-Path $run 'nvidia.ps1'
    $utility = Join-Path $run 'NVCleanstall_1.19.0.exe'
    if ($windowsStage) {
        @($profile.Keys) | ConvertTo-Json | Set-Content -LiteralPath $config -Encoding ASCII
        Get-VerifiedFile 'https://github.com/ChrisTitusTech/winutil/releases/download/26.11.13/winutil.ps1' $upstream 'E9D05A59D564B4FBB61FCFA1A594504A0F81E8D27C787119E72A99B57DDBE66D'
    }
    if ($nvidiaStage) {
        Get-VerifiedFile 'https://raw.githubusercontent.com/yandleyick/CandlestickDebloat/1a46c707df2d760ad049eae483cb64413cbc3e28/nvidia.ps1' $driverHelper '71F7585B20C13D35DAA32F9BDE92723A383A79C3EBE2465093623A885A5A9837'
        Get-DriverUtility $utility
    }
    $winutilIssue = $null
    if ($windowsStage) {
        Write-Host 'Running WinUtil. Its own log records each tweak and any errors.'
        & $winps -NoProfile -ExecutionPolicy RemoteSigned -File $upstream -Config $config
        if ($LASTEXITCODE -ne 0) {
            $winutilIssue = "WinUtil exited with code $LASTEXITCODE. Some tweaks may already be applied. Inspect $env:LOCALAPPDATA\WinUtil\logs before retrying."
            Write-Warning $winutilIssue
        }
    }
    if ($nvidiaStage) {
        $extra = @()
        if ($Mode -eq 'PrepareDriver') { $extra += '-PrepareOnly' }
        & $winps -NoProfile -STA -ExecutionPolicy RemoteSigned -File $driverHelper -Installer $utility @extra
        if ($LASTEXITCODE -ne 0) { throw "NVCleanstall automation stopped. Read its last message. To retry just this stage, use -Mode Nvidia." }
    }
    Write-Host "Verified run files: $run"
    if ($winutilIssue) { throw $winutilIssue }
} finally {
    if ($held) { $gate.ReleaseMutex() }
    $gate.Dispose()
}
