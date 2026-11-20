# TechPowerUp owns NVCleanstall. This script operates its English 1.19.0 wizard.
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Installer,
    [switch]$PrepareOnly
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

function Find-Control($Window, $Property, [string]$Value) {
    $condition = [Windows.Automation.PropertyCondition]::new($Property, $Value)
    $Window.FindFirst([Windows.Automation.TreeScope]::Descendants, $condition)
}

function Wait-Control([string]$Value, [switch]$ByName, [int]$Seconds = 90) {
    $property = [Windows.Automation.AutomationElement]::AutomationIdProperty
    if ($ByName) { $property = [Windows.Automation.AutomationElement]::NameProperty }
    $timer = [Diagnostics.Stopwatch]::StartNew()
    do {
        $wizard.Refresh()
        if ($wizard.HasExited) { throw 'NVCleanstall was closed.' }
        if ($wizard.MainWindowHandle -ne [IntPtr]::Zero) {
            try {
                $window = [Windows.Automation.AutomationElement]::FromHandle($wizard.MainWindowHandle)
                $element = Find-Control $window $property $Value
                if ($element -and $element.Current.IsEnabled -and !$element.Current.IsOffscreen) {
                    return $element
                }
            } catch [Windows.Automation.ElementNotAvailableException] {
                # WPF replaces its page while moving between steps.
            }
        }
        Start-Sleep -Milliseconds 300
    } while ($timer.Elapsed.TotalSeconds -lt $Seconds)
    throw "NVCleanstall did not reach '$Value'. Check its visible window for a download or compatibility error."
}

function Invoke-Button($Element) {
    $Element.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
}

function Set-Check($Element, [bool]$On) {
    $toggle = $Element.GetCurrentPattern([Windows.Automation.TogglePattern]::Pattern)
    $wanted = if ($On) { 'On' } else { 'Off' }
    if ($toggle.Current.ToggleState.ToString() -ne $wanted) { $toggle.Toggle() }
    if ($toggle.Current.ToggleState.ToString() -ne $wanted) {
        throw "Could not set '$($Element.Current.Name)' to $wanted."
    }
}

function Get-TweakBoxes {
    $frame = Wait-Control 'frame'
    $condition = [Windows.Automation.PropertyCondition]::new(
        [Windows.Automation.AutomationElement]::ControlTypeProperty, [Windows.Automation.ControlType]::CheckBox)
    $frame.FindAll([Windows.Automation.TreeScope]::Descendants, $condition)
}

$expected = '9DD36EF956AF927CF41FA441F91B329A7973E13965E4E7D70E6FA9C1DF1CADE6'
if ((Get-FileHash -LiteralPath $Installer -Algorithm SHA256).Hash -ne $expected) { throw 'NVCleanstall hash mismatch.' }
if (Get-Process 'NVCleanstall*' -ErrorAction SilentlyContinue) { throw 'Close the existing NVCleanstall window and retry the NVIDIA stage.' }
$wizard = Start-Process -FilePath $Installer -PassThru
$auto = Wait-Control 'RadioAutodetect'
$auto.GetCurrentPattern([Windows.Automation.SelectionItemPattern]::Pattern).Select()
$next = Wait-Control 'ButtonNext' -Seconds 180
Invoke-Button $next
Invoke-Button (Wait-Control 'ButtonRecommended')
Write-Host 'Selected TechPowerUp Recommended for the detected GPU. Preparing driver files...'
Invoke-Button (Wait-Control 'ButtonNext')
$telemetryLabel = 'Disable Installer Telemetry & Advertising'
$cleanLabel = 'Perform a Clean Installation'
$expertLabel = 'Show Expert Tweaks'
$null = Wait-Control $telemetryLabel -ByName -Seconds 1800
# Look inside the wizard frame. Enabling the expert display exposes saved options
# from a previous run on this PC. Clear unrelated options before proceeding.
$boxes = @(Get-TweakBoxes)
$expert = @($boxes | Where-Object { $_.Current.Name -eq $expertLabel })
if ($expert.Count -ne 1) { throw 'Cannot identify the expert-options control. Review the wizard.' }
Set-Check $expert[0] $true
$targets = @($telemetryLabel, $cleanLabel, $expertLabel)
$boxes = @(Get-TweakBoxes)
foreach ($label in $targets) {
    $matches = @($boxes | Where-Object { $_.Current.Name -eq $label })
    if ($matches.Count -ne 1) { throw "Cannot identify '$label' in the installation tweaks." }
    Set-Check $matches[0] $true
}
foreach ($box in $boxes) {
    if ($box.Current.Name -notin $targets -and $box.Current.IsEnabled) {
        Set-Check $box $false
    }
}
foreach ($box in @(Get-TweakBoxes)) {
    if (!$box.Current.IsEnabled) { continue }
    $expectedState = if ($box.Current.Name -in $targets) { 'On' } else { 'Off' }
    $state = $box.GetCurrentPattern([Windows.Automation.TogglePattern]::Pattern).Current.ToggleState
    if ($state.ToString() -ne $expectedState) { throw "Unexpected saved selection: $($box.Current.Name). Review the wizard." }
}
Write-Host 'Verified installer telemetry disabled, clean installation selected, and interactive NVIDIA setup.'
Invoke-Button (Wait-Control 'ButtonNext')
$install = Wait-Control 'Install' -ByName -Seconds 600
if ($install.Current.ControlType -ne [Windows.Automation.ControlType]::Button) { throw 'Cannot identify the final Install button.' }
if ($PrepareOnly) {
    Write-Host 'Package prepared. Stopped before Install. Close the wizard when finished reviewing.'
    return
}
Invoke-Button $install
Write-Host 'NVIDIA installer launched. Finish the prompts in its window and restart if requested.'
