@echo off
setlocal EnableDelayedExpansion
echo [DEBUG] Script starting execution...
echo [DEBUG] Current directory: %~dp0

echo Starting browsers with session restoration...

REM Check for JSON file
echo [DEBUG] Checking for browser_states.json...
echo [DEBUG] Looking in: %~dp0results\browser_states.json
if not exist "%~dp0results\browser_states.json" (
   echo [ERROR] Browser states file not found at: %~dp0results\browser_states.json
   exit /b 1
) else (
   echo [SUCCESS] Found browser_states.json
)

REM Display JSON content
echo [DEBUG] Current content of browser_states.json:
type "%~dp0results\browser_states.json"
echo.

echo [DEBUG] Starting PowerShell JSON parsing...
echo [DEBUG] Full PowerShell command:
echo powershell -Command "(Get-Content '%~dp0results\browser_states.json' | ConvertFrom-Json).PSObject.Properties | Where-Object { $_.Value.wasRunning -eq $true } | Select-Object -ExpandProperty Name"

REM Parse JSON using PowerShell
for /f "tokens=* usebackq" %%a in (`powershell -Command "(Get-Content '%~dp0results\browser_states.json' | ConvertFrom-Json).PSObject.Properties | Where-Object { $_.Value.wasRunning -eq $true } | Select-Object -ExpandProperty Name"`) do (
   echo [DEBUG] Processing browser: %%a
   set "browser=%%a"
   
   echo [DEBUG] Checking if browser is Chrome...
   if "!browser!"=="chrome" (
       echo [DEBUG] Chrome match found
       echo Starting Chrome...
       echo [DEBUG] Attempting to start Chrome with restore session...
       start "" /B "C:\Program Files\Google\Chrome\Application\chrome.exe" --restore-last-session
       if errorlevel 1 (
           echo [ERROR] Failed to start Chrome
       ) else (
           echo [SUCCESS] Chrome started successfully
       )
   )
   
   echo [DEBUG] Checking if browser is Edge...
   if "!browser!"=="edge" (
       echo [DEBUG] Edge match found
       echo Starting Edge...
       echo [DEBUG] Attempting to start Edge with restore session...
       start "" /B "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --restore-last-session
       if errorlevel 1 (
           echo [ERROR] Failed to start Edge
       ) else (
           echo [SUCCESS] Edge started successfully
       )
   )
   
   echo [DEBUG] Finished processing browser: !browser!
)

echo [DEBUG] Loop completed
echo Browser restart process completed.
echo [DEBUG] Script execution finished
pause
