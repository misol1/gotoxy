@echo off
if "%1" == "" echo Usage: progress command [PROGRESSTYPE 1-3] [COLOR^|inc] [XPOS^|keep] [YPOS^|keep]& goto :eof
setlocal

set MYTEMP=
if not "%TMP%" == "" set MYTEMP=%TMP%\
if not "%TEMP%" == "" set MYTEMP=%TEMP%\
del /Q %MYTEMP%progressval.dat 2>nul
rem cls

set CTMP=1

set COL=10
set XP=k
set YP=k
set TYPE=1
if not "%2" == "" set /a TYPE=%2
if %TYPE% gtr 3 echo Error: Unknown type %TYPE% & goto :eof
if %TYPE% lss 1 echo Error: Unknown type %TYPE% & goto :eof
if not "%3" == "" set COL=%3
set INC=0&if "%COL%"=="inc" set INC=1 
if not "%4" == "" set XP=%4
if not "%5" == "" set YP=%5

set R1=-&set R2=\&set R3=^|
set R4=/
set RCNT=1

if not %TYPE% == 3 goto NT3
if not %XP:~0,1% == k goto NT3
cmdwiz getcursorpos x
set XP=%ERRORLEVEL%
:NT3

start /MIN cmd /C %1

set PROGRESS=0
set OLDPROGRESS=-1
cmdwiz showcursor 0

:REP

call :C1 2>nul & goto C2
:C1
if exist %MYTEMP%progressval.dat for /F "tokens=1*" %%a in (%MYTEMP%progressval.dat) do set /a PROGRESS=%%a 2>nul
goto :eof
:C2
if %PROGRESS% == %OLDPROGRESS% cmdwiz delay 10 & goto REP
set OLDPROGRESS=%PROGRESS%

if %INC% == 0 goto NOINC
set COL=12
if %PROGRESS% geq 33 set COL=14
if %PROGRESS% geq 66 set COL=10

:NOINC

if %TYPE% == 1 gotoxy %XP% %YP% %PROGRESS%%% %COL% & cmdwiz delay 50


if not %TYPE% == 2 goto NOTTYPE2
gotoxy %XP% %YP% !R%RCNT%! %COL%
set /a RCNT+=1
if %RCNT% == 5 set RCNT=1
cmdwiz delay 50
:NOTTYPE2


if not %TYPE% == 3 goto NOTTYPE3
set /a CTMP=1-%CTMP%
set STATE=[
set STATE=%STATE%]
gotoxy %XP% %YP%
gotoxy k %YP% [ 7 0 c
set /a DIVPROG=%PROGRESS% / 5
set /a DIVPAD=20-%DIVPROG%
for /L %%a in (1,1,%DIVPROG%) do call :INCBAR %%a
for /L %%a in (1,1,%DIVPAD%) do gotoxy k %YP% " " %COL% 0 c
gotoxy k %YP% ] 7 0 c
cmdwiz delay 20
:NOTTYPE3
goto SKIPBAR

:INCBAR
set TCOL=%COL%
if not %COL% == a goto CH1
set TCOL=1
if %1 geq 7 set TCOL=9
if %1 geq 14 set TCOL=15
:CH1
if not %COL% == b goto CH2
set TCOL=12
if %1 geq 7 set TCOL=14
if %1 geq 14 set TCOL=10
:CH2
if not %COL% == c goto CH3
set TCOL=15
set /a TMP1=%DIVPROG%-0
if %1 lss %TMP1% set TCOL=9
:CH3
if not %COL% == d goto CH4
set TCOL=15
set /a TMP2=%1 %% 2
if %TMP2% == %CTMP% set TCOL=9
:CH4

gotoxy k %YP% o %TCOL% 0 c
goto :eof
:SKIPBAR

if %PROGRESS% lss 100 goto REP

del /Q %MYTEMP%progressval.dat 2>nul
cmdwiz showcursor 1

endlocal
echo on
