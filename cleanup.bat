@echo off
setlocal EnableDelayedExpansion
set "processdir=%~1"
echo [DEBUG] Cleanup started...

echo [DEBUG] Cleaning up temporary directory...
rmdir /S /Q "%processdir%" 2>nul

if exist "%processdir%" (
    echo [ERROR] Failed to remove temporary directory
    exit /b 1
) else (
    echo [DEBUG] Cleanup completed successfully
    exit /b 0
)
