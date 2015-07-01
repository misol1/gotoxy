:: Animplay : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
if "%1" == "" echo Usage: animplay [animdata.bat] [delay] [bounce normal bouncefast reverse] [x] [y] [color] [bgcolor] [replace...]&goto OUT2

if not exist "%1" echo Error: data file does not exist&goto OUT2
call %1
if "%FRAMES%" == "" echo Error: invalid data file&goto OUT2
set /a FTMP=%FRAMES%-1
if "!ANIM%FTMP%!" == "" echo Error: invalid data file&goto OUT2

set CNT=0
set CNT2=0
set DELTA=1
set DELAY=& if not "%2" == "" if not "%2" == "0" set DELAY=\W%2
set XP=0& if not "%4" == "" set XP=%4
set YP=0& if not "%5" == "" set YP=%5
set COLOR=7& if not "%6" == "" set COLOR=%6
set BCOLOR=0& if not "%7" == "" set BCOLOR=%7
set BOUNCE=0
if "%3" == "bounce" set BOUNCE=1
if "%3" == "bouncefast" set BOUNCE=2
if "%3" == "reverse" set DELTA=-1&set /a CNT=%FRAMES%-1
cmdwiz getconsoledim y
set SCRH=%ERRORLEVEL%
cmdwiz getconsoledim x
set SCRW=%ERRORLEVEL%

:REP
if not "%~8" == "" for /L %%a in (0,1,%FTMP%) do set ANIM%%a=!ANIM%%a:%~8!
shift
if not "%~8" == "" goto REP

:LOOP
gotoxy.exe %XP% %YP% \O0;0;%SCRW%;%SCRH%!ANIM%CNT%!%DELAY% %COLOR% %BCOLOR%
set /a CNT2+=1&set /a KTMP=!CNT2! %% 15
if %KTMP% == 0 cmdwiz getch nowait
if %ERRORLEVEL% == 27 goto OUT
set /a CNT+=%DELTA%
if %BOUNCE% == 0 if %CNT% geq %FRAMES% set CNT=0
if %BOUNCE% == 0 if %CNT% lss 0 set /a CNT=%FRAMES%-1
if %BOUNCE% == 1 if %CNT% geq %FRAMES% set DELTA=-1&set /a CNT+=!DELTA!
if %BOUNCE% == 1 if %CNT% lss 0 set DELTA=1&set /a CNT+=!DELTA!
if %BOUNCE% == 2 if %CNT% geq %FRAMES% set DELTA=-1&set /a CNT+=!DELTA!&set /a CNT+=!DELTA!
if %BOUNCE% == 2 if %CNT% lss 0 set DELTA=1&set /a CNT+=!DELTA!&set /a CNT+=!DELTA!
goto LOOP
:OUT

mode con lines=50
cls
:OUT2
endlocal
cmdwiz showcursor 1
