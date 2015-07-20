@echo off
setlocal
cmdwiz showcursor 0
cmdwiz getconsoledim sx
set W=%ERRORLEVEL%
set /a WB=-(%W%+2)
set /a WF=%W%/2
set /a WF2=-%W%/2
set /a WF3=%WF%+1
cmdwiz getconsoledim cy
set YCURR=%ERRORLEVEL%
cmdwiz getconsoledim sy
set H=%ERRORLEVEL%
set /a H1=%H%/2
set /a H1C=%H1%+%YCURR%
cmdwiz saveblock tempblock 0 %YCURR% %W% %H%

if "%1" == "" for /L %%i in (0,-1,%WF2%) do cmdwiz moveblock 0 %YCURR% %WF% %H% -1 %YCURR% & cmdwiz moveblock %WF% %YCURR% %WF% %H% %WF3% %YCURR%
if "%1" == "1" for /L %%i in (0,-1,%WB%) do cmdwiz moveblock 0 %YCURR% %W% %H1% -1 %YCURR% & cmdwiz moveblock 0 %H1C% %W% %H1% 1 %H1C%
cmdwiz delay 500
cmdwiz showcursor 1
if not "%2" == "" cls
if "%2" == "" gotoxy 0 %YCURR% tempblock.gxy 0 0 r
del /Q tempblock.gxy
endlocal
