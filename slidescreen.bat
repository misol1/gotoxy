@echo off
setlocal
cmdwiz showcursor 0
cmdwiz getconsoledim x
set W=%ERRORLEVEL%
set /a WB=-(%W%+2)
set /a WF=(%W%+2)
cmdwiz getconsoledim y
set H=%ERRORLEVEL%
if %H% geq 60 set H=60
cmdwiz saveblock tempblock 0 0 %W% %H%

if not "%1" == "" for /L %%i in (0,-1,%WB%) do cmdwiz moveblock 0 0 %W% %H% -1 0
if "%1" == "" for /L %%i in (0,1,%WF%) do cmdwiz moveblock 0 0 %W% %H% 1 0
cmdwiz delay 500
cmdwiz showcursor 1
if not "%2" == "" cls
if "%2" == "" gotoxy 0 0 tempblock.gxy 0 0 r
del /Q tempblock.gxy
endlocal
