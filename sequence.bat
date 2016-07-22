@echo off
setlocal ENABLEDELAYEDEXPANSION
if "%~1" == "" echo Usage: sequence file.seq [delay] [x] [y] [color] [bcol] [normal^|reverse^|bounce] [norep]&goto :eof
cmdwiz showcursor 0

set DELAY=10&if not "%2"=="" set DELAY=%2
set XP=0&if not "%3"=="" set XP=%3
set YP=0&if not "%4"=="" set YP=%4
set COL=u&if not "%5"=="" set COL=%5
set BCOL=U&if not "%6"=="" set BCOL=%6
set MODE=normal&if not "%7"=="" set MODE=%~7
set REP=1&if not "%8"=="" set REP=2
set FNAME=%~1

if not exist "%~1" echo Error: file not found.&goto :OUTOF
set CNT=0&for /F "tokens=* delims=" %%a in (%~1) do set FNAME!CNT!="%%a"&set /A CNT+=1&echo "%%a">>cachelist.dat
set NOF=%CNT%&set CNT=0
cmdwiz cache cachelist.dat&del /Q cachelist.dat>nul 2>nul
cls

set DELTA=1&set ENDVAL=%NOF%
if %MODE%==reverse set DELTA=-1&set ENDVAL=-1&set /A CNT=%NOF%-1

:LOOP
gotoxy %XP% %YP% !FNAME%CNT%! %COL% %BCOL% Fk
if %ERRORLEVEL% == 27 goto OUTOF
if %ERRORLEVEL% == 112 cmdwiz getch
if %ERRORLEVEL% == 110 set MODE=normal&set DELTA=1
if %ERRORLEVEL% == 98 set MODE=bounce
if %ERRORLEVEL% == 114 set MODE=reverse&set DELTA=-1
if %DELAY% gtr 0 cmdwiz delay %DELAY%
set /A CNT+=%DELTA%
if %CNT% == %NOF% set CNT=0&(if %MODE%==bounce set /A CNT=%NOF%-1&set DELTA=-1)&if %REP%==2 set REP=0
if %CNT% == -1 set /A CNT=%NOF%-1&(if %MODE%==bounce set /A CNT=0&set DELTA=1)&if %REP%==2 set REP=0
if %REP% gtr 0 goto LOOP

:OUTOF
cmdwiz showcursor 1
endlocal
