@echo off

if not "%KEY%" == "97" goto NOT_A & rem a
if "!FT%CURRPOS%!"=="/" goto :eof
set XTENSION=%~x1
set XFILE=%~n1
if "%XTENSION%"==".wav" cmdwiz playsound %1 & exit /b 0
if "%XTENSION%"==".WAV" cmdwiz playsound %1 & exit /b 0
if "%XTENSION%"==".gxy" cls&gotoxy 0 0 %1 0 0 c & cmdwiz getch & exit /b 1
if "%XTENSION%"==".mp3" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".mod" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".MOD" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".ans" cls&ansicon -t %1 & cmdwiz getch & exit /b 1
if "%XTENSION%"==".ANS" cls&ansicon -t %1 & cmdwiz getch & exit /b 1
if "%XTENSION%"==".c" cls&tcc -o "%XFILE%.exe" %1 & exit /b 3
cls
less -f %1
exit /b 1

:NOT_A
exit /b 0
