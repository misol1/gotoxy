@echo off
setlocal ENABLEDELAYEDEXPANSION
if "%~1" == "" echo Usage: sequence file.seq [x] [y] [color] [delay] [bcol] [norep]&goto :eof
cmdwiz showcursor 0

set COL=u&if not "%4"=="" set COL=%4
set BCOL=U&if not "%6"=="" set BCOL=%6
set REP=1&if not "%7"=="" set REP=2
set DELAY=10&if not "%5"=="" set DELAY=%5
set XP=0&if not "%2"=="" set XP=%2
set YP=0&if not "%3"=="" set YP=%3
set FNAME=%~1

if not exist "%~1" echo Error: file not found.&goto :OUTOF
set CNT=0&for /F "tokens=* delims=" %%a in (%~1) do set FNAME!CNT!="%%a"&set /A CNT+=1
set NOF=%CNT%&set CNT=0
cls

:LOOP
gotoxy_extended %XP% %YP% !FNAME%CNT%! %COL% %BCOL% F
cmdwiz getch nowait
if %ERRORLEVEL% == 27 goto OUTOF
cmdwiz delay %DELAY%
set /A CNT+=1
if %CNT% geq %NOF% set CNT=0&if %REP%==2 set REP=0
if %REP% gtr 0 goto LOOP

:OUTOF
cmdwiz showcursor 1
endlocal
