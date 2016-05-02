@echo off
if "%~1" == "" echo Usage: scrolltext [text] [delay] [ypos] [color] &goto :eof
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

set SCROLLTEXT="%~1 "
set DELAY=&if not "%2" == "" set DELAY=\W%2
set YP=0&if not "%3" == "" set YP=%3
set COLOR=u&if not "%4" == "" set COLOR=%4

set SCROLLPOS=80
cmdwiz stringlen %SCROLLTEXT%&set SCROLL_LEN=!ERRORLEVEL!
set /a SCROLL_LEN=0-SCROLL_LEN
set CNT=0

:LOOP
gotoxy.exe %SCROLLPOS% %YP% %SCROLLTEXT%%DELAY% %COLOR% U k
set /A SCROLLPOS-=1
if %SCROLLPOS% == %SCROLL_LEN% set SCROLLPOS=81
if not !ERRORLEVEL!==27 goto LOOP

endlocal
cmdwiz showcursor 1
