@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

if not "%2" == "" mode con lines=40 cols=80 & gotoxy 0 0 "\N\M4{\M6{\M5{\F1          \70          \\}\n\}\M6{\M5{\70          \F1          \\}\n\}}" 0 0 rx
if not "%3" == "" gotoxy 32 12 goomba.gxy 0 -V 

cmdwiz getconsoledim sx
set XSIZE=%ERRORLEVEL%
cmdwiz getconsoledim sy
set YSIZE=%ERRORLEVEL%
cmdwiz getconsoledim cy
set YCURRENT=%ERRORLEVEL%
set FX=fX
if not "%1" == "" set FX=%1
for /L %%a in (1,1,150) do set BL=!BL!\G
call :MAKE_SQ
call :MAKE_SQ2
set CNT=0
set /a YMAX=%YSIZE%
set /a XMAX=%XSIZE%
set MODE=0

cmdwiz saveblock tempblock 0 %YCURRENT% %XSIZE% %YSIZE% encode -1 0
for /F "tokens=*" %%i in (tempblock.gxy) do set BLOCK="%%i"

:LOOP
if %MODE%==0 gotoxy 0 0 "\O0;%YCURRENT%;%XSIZE%;%YSIZE%\R%BLOCK:~1,-1%\R\p%XP%;%YP%%SQ:~1,-1%\R\p%XP2%;%YP2%%SQ2:~1,-1%\O0;%YCURRENT%\i" 0 0 rx
if %MODE%==1 gotoxy 0 0 "\O0;%YCURRENT%;%XSIZE%;%YSIZE%\R\p%XP%;%YP%%SQ:~1,-1%\R\p%XP2%;%YP2%%SQ2:~1,-1%\p0;0\R%BLOCK:~1,-1%\O0;%YCURRENT%\i" 0 0 rx
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
set /a YS=24+%RANDOM% %% 40
set /a XS=16+%RANDOM% %% 35
set /a YP=0-%YS%
set /a XP=%RANDOM% %% (%XSIZE% - %XS% + 6) - 3
set /a SC=9+%RANDOM% %% 6
call :DECTOHEX %SC%
::set SQ="\f%P%\%FX%\M%YS%{\M%XS%{\G\}\n}"
set /a XW=%XS%*2
set SQ="\f%P%\%FX%\M%YS%{!BL:~0,%XW%!\n}"
goto :eof

:MAKE_SQ2
set /a YS2=16+%RANDOM% %% 25
set /a XS2=40+%RANDOM% %% 60
set /a XP2=-1-%XS2%
set /a YP2=%RANDOM% %% (%YSIZE% - %YS2% + 6) - 3
set /a SC2=9+%RANDOM% %% 6
call :DECTOHEX %SC2%
::set SQ2="\f%P%\%FX%\M%YS2%{\M%XS2%{\G\}\n}"
set /a XW=%XS2%*2
set SQ2="\f%P%\%FX%\M%YS2%{!BL:~0,%XW%!\n}"
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
