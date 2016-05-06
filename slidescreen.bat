@echo off
setlocal
cmdwiz showcursor 0
cmdwiz getconsoledim sw
set W=%ERRORLEVEL%
set /a WB=-(%W%+2)
set /a WF=(%W%+2)
cmdwiz getconsoledim cy
set YCURR=%ERRORLEVEL%
cmdwiz getconsoledim sh
set H=%ERRORLEVEL%
if %H% geq 60 set H=60
cmdwiz saveblock tempblock 0 %YCURR% %W% %H%

if not "%1" == "" for /L %%i in (0,-1,%WB%) do cmdwiz moveblock 0 %YCURR% %W% %H% -1 %YCURR%
if "%1" == "" for /L %%i in (0,1,%WF%) do cmdwiz moveblock 0 %YCURR% %W% %H% 1 %YCURR%
cmdwiz delay 500
cmdwiz showcursor 1
if not "%2" == "" cls
if "%2" == "" gotoxy 0 %YCURR% tempblock.gxy 0 0 r
del /Q tempblock.gxy
endlocal
