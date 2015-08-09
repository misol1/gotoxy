@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
cmdwiz getconsoledim sx
set XSIZE=%ERRORLEVEL%
cmdwiz getconsoledim sy
set YSIZE=%ERRORLEVEL%
cmdwiz getconsoledim cy
set YCURRENT=%ERRORLEVEL%
call :MAKE_SQ %1
set CNT=0
set /a YMAX=%YSIZE%

cmdwiz saveblock tempblock 0 %YCURRENT% %XSIZE% %YSIZE%
for /F "tokens=*" %%i in (tempblock.gxy) do set BLOCK="%%i"

:LOOP
gotoxy 0 0 "\O0;%YCURRENT%;%XSIZE%;%YSIZE%%BLOCK:~1,-1%\R\p%XP%;%YP%%SQ:~1,-1%\O0;%YCURRENT%" 0 0 r

set /a YP += 1
if %YP% gtr %YMAX% call :MAKE_SQ %1

set /a CNT+=1
set /a KTMP=%CNT% %% 30
if %KTMP% == 0 cmdwiz getch nowait
if not %ERRORLEVEL% == 27 goto LOOP

cmdwiz showcursor 1
endlocal
goto :eof


:MAKE_SQ
set /a YS=12+%RANDOM% %% 22
set /a XS=12+%RANDOM% %% 22
set /a YP=0-%YS%
set /a XP=%RANDOM% %% (%XSIZE% - %XS% + 6) - 3
set /a SC=9+%RANDOM% %% 6
call :DECTOHEX %SC%

set SQ=""
if "%1" == "" set SQ="!SQ:~1,-1!\f%P%"
if not "%1" == "" set SQ="!SQ:~1,-1!\%P%1"
for /L %%b in (1,1,%YS%) do set SQ="!SQ:~1,-1!\n"& for /L %%a in (1,1,%XS%) do set SQ="!SQ:~1,-1!\G"
goto :eof

:DECTOHEX
if %1 geq 16 set P=0&goto :eof
if %1 lss 0 set P=0&goto :eof
if %1 leq 9 set P=%1&goto :eof
if %1 == 10 set P=A&goto :eof
if %1 == 11 set P=B&goto :eof
if %1 == 12 set P=C&goto :eof
if %1 == 13 set P=D&goto :eof
if %1 == 14 set P=E&goto :eof
if %1 == 15 set P=F&goto :eof
goto :eof
