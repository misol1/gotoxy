@echo off
setlocal ENABLEDELAYEDEXPANSION

set width=80
set height=50

if "%~1" == "" echo Usage: showimg [filename] [width] [height] [bRemove]&goto :eof
set FNAME="%~1"
if not exist %FNAME% echo Error: no such file&goto :eof
if not "%~2" == "" set width=%~2
if not "%~3"=="" set height=%~3
set BREMOVE=0
if not "%~4"=="" set BREMOVE=1

mode %width%,%height%&cls
cmdwiz showcursor 0
color 07
set /a dh=%height%*2
cmdwiz setbuffersize %width% %dh%

set CNT=-1
gotoxy 0 %height% "\I:%fname%;" 9 0 r
set /a hm=%height% - 1

set DELTA=1

:LOOP

set /a CNT+=%DELTA%
if %CNT% geq %height% if %BREMOVE%==0 goto OUT
if %CNT% geq %height% if %BREMOVE%==1 set DELTA=-1&set /a CNT-=1&cmdwiz getch
if %CNT% lss 0 goto OUT

set UT=""

set OY=%height%
for /L %%a in (0,1,%CNT%) do set UT="!UT:~1,-1!\o0;!OY!;%width%;1;\o0;%%a;"&set /A OY+=1
set /A OY-=1
if %CNT% leq %hm% for /L %%a in (%CNT%,1,%hm%) do set UT="!UT:~1,-1!\o0;!OY!;%width%;1;\o0;%%a;"
set UT="!UT:~1,-1!\W15"
gotoxy 0 0 %UT% 0 0 k

if not !ERRORLEVEL! == 27 goto LOOP

:OUT
cmdwiz setbuffersize %width% %height%
if %BREMOVE%==1 cls
cmdwiz showcursor 1
endlocal
