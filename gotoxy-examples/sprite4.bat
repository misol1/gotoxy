@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
cmdwiz getcursorpos x&set X=!ERRORLEVEL!
cmdwiz getcursorpos y&set Y=!ERRORLEVEL!
cmdwiz getconsoledim w&set W=!ERRORLEVEL!
cmdwiz getconsoledim h&set H=!ERRORLEVEL!
gotoxy 0 0
set YP=2&if not "%1" == "" set YP=%1
set DELAY=\W5&if not "%2" == "" set DELAY=\W%2

for /F "tokens=*" %%i in (goomba.gxy) do set spi="%%i"

cmdwiz saveblock tempblock 0 %YP% %W% 15
for /F "tokens=*" %%i in (tempblock.gxy) do set BLOCK="%%i"

:REP
for /L %%a in (2,1,60) do gotoxy.exe 0 0 "\O0;%YP%;%W%;15%BLOCK:~1,-1%\p%%a;0%spi%%DELAY%" 0 0 r
cmdwiz getch w&if !ERRORLEVEL! == 27 goto OUT
for /L %%a in (60,-1,2) do gotoxy.exe 0 0 "\O0;%YP%;%W%;15%BLOCK:~1,-1%\p%%a;0%spi%%DELAY%" 0 0 r
cmdwiz getch w
if not %ERRORLEVEL% == 27 goto REP

:OUT
gotoxy.exe 0 %YP% %BLOCK%&gotoxy.exe %X% %Y%
del /Q tempblock.gxy
endlocal
cmdwiz showcursor 1
