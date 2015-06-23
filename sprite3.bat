@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
cmdwiz getcursorpos x&set X=!ERRORLEVEL!
cmdwiz getcursorpos y&set Y=!ERRORLEVEL!
cmdwiz getconsoledim y&set YM=!ERRORLEVEL!
gotoxy 0 0
set YP=2&if not "%1" == "" set YP=%1
set DELAY=\W6&if not "%2" == "" set DELAY=\W%2

Set "spi=\-\-\0A \-\-\-\-\- \n"
Set "spi=%spi%\-\-\- \-\-\- \n"
Set "spi=%spi%\-\-       \n"
Set "spi=%spi%\-  \0E \0A   \0E \0A  \n"
Set "spi=%spi%           \n"
Set "spi=%spi% \-       \- \n"
Set "spi=%spi% \- \-\-\-\-\- \- \n"
Set "spi=%spi%\-\-\-  \-  "

cmdwiz saveblock tempblock 0 0 80 50
gotoxy 0 0 tempblock.gxy

cmdwiz saveblock tempblock 0 %YP% 80 8
for /F "tokens=*" %%i in (tempblock.gxy) do set BLOCK="%%i"

:REP
for /L %%a in (3,1,66) do gotoxy.exe 0 0 "\o0;%YP%;80;8%BLOCK:~1,-1%\p%%a;0%spi%%DELAY%" 0 0 r
cmdwiz getch w&if !ERRORLEVEL! == 27 goto OUT
for /L %%a in (66,-1,3) do gotoxy.exe 0 0 "\o0;%YP%;80;8%BLOCK:~1,-1%\p%%a;0%spi%%DELAY%" 0 0 r
cmdwiz getch w
if not %ERRORLEVEL% == 27 goto REP

:OUT
gotoxy.exe 0 %YP% %BLOCK%&gotoxy.exe %X% %Y%
del /Q tempblock.gxy
endlocal
cmdwiz showcursor 1
