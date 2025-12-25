@echo off
REM Start komorebi tiling window manager with all components

REM Start komorebi daemon
start "" /B "C:\Program Files\komorebi\bin\komorebi.exe" --config "%USERPROFILE%\komorebi.json"

REM Wait for komorebi to initialize
timeout /t 2 /nobreak >nul

REM Start the bar
start "" /B "C:\Program Files\komorebi\bin\komorebi-bar.exe"

REM Start whkd (hotkey daemon)
start "" /B "C:\Program Files\whkd\bin\whkd.exe"

REM Start masir (focus follows mouse)
start "" /B "C:\Program Files\masir\bin\masir.exe"
