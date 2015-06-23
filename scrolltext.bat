@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

if "%~1" == "" echo Usage: scrolltext [text] [delay] [ypos] [color] &goto OUT
set SCROLLTEXT="%~1 "
set DELAY=&if not "%2" == "" set DELAY=\W%2
set YP=0&if not "%3" == "" set YP=%3
set COLOR=7&if not "%4" == "" set COLOR=%4

set SCROLLPOS=80
call util.bat strlen SCROLL_LEN %SCROLLTEXT%
set /a SCROLL_LEN=0-SCROLL_LEN

:LOOP
cmdwiz getch nowait
if %ERRORLEVEL% == 27 goto OUT

gotoxy.exe %SCROLLPOS% %YP% %SCROLLTEXT%%DELAY% %COLOR% 0
set /a SCROLLPOS-=1
if %SCROLLPOS% == %SCROLL_LEN% set SCROLLPOS=81

goto LOOP
:OUT

endlocal
cmdwiz showcursor 1
