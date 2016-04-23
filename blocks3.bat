@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
cmdwiz getconsoledim sx
set XSIZE=%ERRORLEVEL%
cmdwiz getconsoledim sy
set YSIZE=%ERRORLEVEL%
cmdwiz getconsoledim cy
set YCURRENT=%ERRORLEVEL%
set FX=fQ
if not "%1" == "" set FX=%1
call :MAKE_SQ
call :MAKE_SQ2
set CNT=0
set /a YMAX=%YSIZE%
set /a XMAX=%XSIZE%
set MODE=1

cmdwiz saveblock tempblock 0 %YCURRENT% %XSIZE% %YSIZE% encode -1 0
for /F "tokens=*" %%i in (tempblock.gxy) do set BLOCK="%%i"

:LOOP
if %MODE%==0 gotoxy 0 0 "\O0;%YCURRENT%;%XSIZE%;%YSIZE%\R%BLOCK:~1,-1%\R\p%XP%;%YP%%SQ:~1,-1%\R\p%XP2%;%YP2%%SQ2:~1,-1%\O0;%YCURRENT%\i" 0 0 r
if %MODE%==1 gotoxy 0 0 "\O0;%YCURRENT%;%XSIZE%;%YSIZE%\R\p%XP%;%YP%%SQ:~1,-1%\R\p%XP2%;%YP2%%SQ2:~1,-1%\p0;0\R%BLOCK:~1,-1%\O0;%YCURRENT%\i" 0 0 r
if %ERRORLEVEL% == 27 goto ENDLOOP

set /a YP += 1
if %YP% gtr %YMAX% call :MAKE_SQ

set /a XP2 += 1
if %XP2% gtr %XMAX% call :MAKE_SQ2

goto LOOP
:ENDLOOP

del /Q tempblock.gxy
cmdwiz showcursor 1
endlocal
goto :eof


:MAKE_SQ
set /a YS=8+%RANDOM% %% 16
set /a XS=16+%RANDOM% %% 8
set /a YP=0-%YS%
set /a XP=%RANDOM% %% (%XSIZE% - %XS% + 6) - 3
set /a SC=9+%RANDOM% %% 6
call :DECTOHEX %SC%

set SQ=""
set SQ="!SQ:~1,-1!\f%P%\%FX%"
for /L %%b in (1,1,%YS%) do set SQ="!SQ:~1,-1!\n"& for /L %%a in (1,1,%XS%) do set SQ="!SQ:~1,-1!\G"
goto :eof

:MAKE_SQ2
set /a YS2=8+%RANDOM% %% 16
set /a XS2=16+%RANDOM% %% 8
set /a XP2=0-%XS2%
set /a YP2=%RANDOM% %% (%YSIZE% - %YS2% + 6) - 3
set /a SC2=9+%RANDOM% %% 6
call :DECTOHEX %SC2%

set SQ2=""
set SQ2="!SQ2:~1,-1!\f%P%\%FX%"
for /L %%b in (1,1,%YS2%) do set SQ2="!SQ2:~1,-1!\n"& for /L %%a in (1,1,%XS2%) do set SQ2="!SQ2:~1,-1!\G"
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
