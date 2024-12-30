@echo off
setlocal EnableDelayedExpansion
echo Starting browsers with session restoration...

if not exist "%~dp0results\browser_states.json" (
    echo Browser states file not found
    exit /b 1
)

powershell -Command "
    $browsers = Get-Content '%~dp0results\browser_states.json' | ConvertFrom-Json

    # Define browser configurations
    $browserConfigs = @{
        'chrome' = @{
            'registryPath' = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'
        }
        'edge' = @{
            'registryPath' = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe'
        }
    }

    # Common browser arguments
    $commonArgs = @(
        '--restore-last-session',
        '--session-restore-standalone-timeout=60',
        '--disable-session-crashed-bubble',
        '--disable-features=TabGroups',
        '--password-store=basic',
        '--no-first-run'
    )

    # Process each browser that was running
    foreach ($browserName in $browserConfigs.Keys) {
        if ($browsers.$browserName.wasRunning) {
            Write-Host "Starting $browserName..."
            $config = $browserConfigs[$browserName]
            try {
                $path = (Get-ItemProperty $config.registryPath).'(Default)'
                if ($path) {
                    Start-Process $path -ArgumentList $commonArgs
                }
            }
            catch {
                Write-Host "Failed to start $browserName"
            }
        }
    }
"

echo Browser restart process completed.
