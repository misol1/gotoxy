@echo off
setlocal ENABLEDELAYEDEXPANSION

set /a "width=80, height=50"

if "%~1" == "" echo Usage: showimg [filename] [width] [height] [bRemove]&goto :eof
set FNAME="%~1"
if not exist %FNAME% echo Error: no such file&goto :eof
if not "%~2"=="" set width=%~2
if not "%~3"=="" set height=%~3
set BREMOVE=0
if not "%~4"=="" set BREMOVE=1

mode %width%,%height%&cls
cmdwiz showcursor 0
color 07

set /a dh=%height%*2
cmdwiz setbuffersize %width% %dh%
gotoxy 0 %height% "\I:%fname%;" 9 0 r

set CNT=0
set CNT2=%height%
:PREPLOOP
cmdwiz saveblock tempblock 0 %CNT2% %width% 1
for /F "tokens=*" %%a in (tempblock.gxy) do set LN%CNT%=%%a
set /A CNT+=1
set /A CNT2+=1
if %CNT% lss %height% goto PREPLOOP

cmdwiz setbuffersize %width% %height%
set DELTA=1

set OY=0
:LOOP
if %OY% geq %height% if %BREMOVE%==0 goto OUT
if %OY% geq %height% if %BREMOVE%==1 set DELTA=-1&cmdwiz getch
if %OY% lss 0 goto OUT

set /a NOF=%height%-%oy%
::gotoxy 0 %OY% "\M%NOF%{!LN%OY%!}\W20" 0 0 krx
gotoxy 0 %OY% "\O0;%OY%;%width%;%height%;\p0;0;\M%NOF%{!LN%OY%!}\O;0;%OY%\W20" 0 0 krx
set /a OY+=%DELTA%
if not !ERRORLEVEL! == 27 goto LOOP

:OUT
del /Q tempblock.gxy>nul
if %BREMOVE%==1 cls
cmdwiz showcursor 1
endlocal
