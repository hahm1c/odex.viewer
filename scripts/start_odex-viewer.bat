@echo off

echo odex.viewer has been extracted to:
echo %~dp0
echo.
choice /M "Do you want to start odex.viewer now?"
if errorlevel 2 exit /b 0

set PATH=%~dp0python;%PATH%

start cmd.exe /k "%~dp0python\Scripts\odex_viewer.exe"

echo Waiting for odex.viewer backend to start...
timeout 10

start http://localhost:8080