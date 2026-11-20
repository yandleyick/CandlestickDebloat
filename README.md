# CANDLESTICK / Serpentine FPS Guide

CandlestickDebloat runs my 35 selected tweaks in **Chris Titus Tech’s WinUtil** and prepares a GeForce driver using **TechPowerUp’s NVCleanstall**. Candlestick supplies the preset and PowerShell launcher. The two upstream projects supply the software. [Download the PDF guide](Serpentine-FPS-Guide.pdf).

## Run CandlestickDebloat

Open **64-bit PowerShell as administrator** on Windows and paste this line. The launcher prints the selections first. Type **APPLY** to begin or press Enter to exit.

```powershell
& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/yandleyick/CandlestickDebloat/main/install.ps1')))
```

Append `-Preview` to print the settings without downloading tools or changing the PC. Append `-Mode Windows` for just WinUtil, `-Mode Nvidia` for just the driver, or `-Mode PrepareDriver` to prepare the customized package and stop at NVCleanstall’s **Install** screen.

## Before applying the Windows preset

Back up important files, finish syncing OneDrive, and record any NVIDIA profiles you want to recreate. Run a repeatable game replay or benchmark with your usual settings. Record average FPS and 1% lows if available. Repeat under the same conditions after setup to see the result on your own PC.

**Check these effects before typing APPLY.** This preset can start decrypting the Windows drive with BitLocker. It removes OneDrive and Edge, disables Windows search indexing, blocks listed Adobe activation and telemetry domains, and suppresses warnings when opening unsigned RDP files. It disables notifications and the taskbar calendar flyout. The date, time and time-zone setting is excluded.

WinUtil runs the selected tweaks under release **26.11.13**, including its restore-point action. Some changes, such as file cleanup, need a separate backup for recovery. If WinUtil reports an error, read its log in `%LOCALAPPDATA%\WinUtil\logs` before retrying. Completed changes can persist after a later step fails. [WinUtil release](https://github.com/ChrisTitusTech/winutil/releases/tag/26.11.13) · [WinUtil automation](https://winutil.christitus.com/guides/automation/)

<details>
<summary>All 35 selected WinUtil checkboxes</summary>

- Restore Point - Create
- Activity History - Disable
- ConsumerFeatures - Disable
- File Explorer Automatic Folder Discovery - Disable
- Windows Platform Binary Table (WPBT) - Disable
- Location Tracking - Disable
- Services - Set to Manual
- Telemetry - Disable
- Delivery Optimization - Disable
- Temporary Files - Remove
- End Task With Right Click - Enable
- Microsoft Store Recommended Search Results - Disable
- Start Menu Previous Layout - Enable
- Widgets - Remove
- Microsoft OneDrive - Remove
- Windows AI - Disable And Remove
- Right-Click Menu Previous Layout - Enable
- Razer Software Auto-Install - Disable
- RDP Unsigned File Warnings - Disable
- Microsoft Edge - Remove
- Microsoft Edge - Debloat
- Logitech Download Assistant Auto-Install - Disable
- File Explorer Home and Gallery - Disable
- Brave Browser - Debloat
- Background Apps - Disable
- Adobe URL Block List - Enable
- Windows Search Indexing - Disable
- Visual Effects - Set to Best Performance
- System Tray Notifications & Calendar - Disable
- svchost.exe Splitting - Disable
- Storage Sense - Disable
- Hibernation - Disable
- BitLocker - Disable
- Prevent Device Companion Apps
- Disk Cleanup - Run

</details>

The standalone preset can also be imported into WinUtil 26.11.13. [Download winutil.json](winutil.json)

## NVIDIA driver

1. The launcher checks for an NVIDIA PCI display adapter, downloads **NVCleanstall 1.19.0** from TechPowerUp or reuses a matching copy in Downloads, and verifies its SHA-256. WinUtil and the NVIDIA helper are hash-checked as well.
2. It opens the wizard, selects the best driver for the detected hardware, and clicks **Recommended**. NVCleanstall decides which components go into the package for that desktop or laptop.
3. It selects **Disable Installer Telemetry & Advertising** and **Perform a Clean Installation**. The separate expert driver-telemetry modification stays off, as in my saved settings. A clean installation resets custom NVIDIA profiles.
4. The launcher opens NVIDIA’s interactive installer. Review the license and finish the vendor prompts. Restart if requested. Check your refresh rate, sound output and any capture feature you use, then run the same benchmark again.

If the wizard reports a download error or the launcher cannot recognize a control, read the message in the open wizard. Close it before retrying with `-Mode Nvidia`. On a PC without an NVIDIA display adapter, the combined command runs the Windows stage alone. [TechPowerUp NVCleanstall](https://www.techpowerup.com/nvcleanstall/)

## Credits

**Chris Titus Tech and the WinUtil contributors** built the Windows utility and its tweaks. **TechPowerUp** built NVCleanstall and its hardware-specific Recommended preset. All credit for those tools belongs to their authors. [Chris Titus Tech’s WinUtil](https://github.com/ChrisTitusTech/winutil) · [TechPowerUp’s NVCleanstall](https://www.techpowerup.com/nvcleanstall/)

[kephrii.com/guides](https://kephrii.com/guides)

Huge thank you to Kephrii for the inspo. Seeing you put your own PC tweaks out there made me want to show people exactly what I tick on mine. I appreciate the time you put into writing it all down and sharing it with the community. Much love, man.
