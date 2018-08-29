@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

if not "%2" == "" mode con lines=40 cols=80 & gotoxy 0 0 "\N20\M4{\M6{\M5{\F1          \70          \\}\n\}\M6{\M5{\70          \F1          \\}\n\}}" 0 0 rx

cmdwiz getconsoledim sw
set XSIZE=%ERRORLEVEL%
cmdwiz getconsoledim sh
set YSIZE=%ERRORLEVEL%
cmdwiz getconsoledim h
set YORG=%ERRORLEVEL%
cmdwiz getconsoledim cy
set YCURRENT=%ERRORLEVEL%
set CNT=0
set /a YMAX=%YSIZE%
set /a XMAX=%XSIZE%

cmdwiz saveblock tempblock 0 %YCURRENT% %XSIZE% %YSIZE%
for /F "tokens=*" %%i in (tempblock.gxy) do set BLOCK="%%i"
gotoxy 0 0 %BLOCK% 0 0 r
if %YORG% gtr %YSIZE% mode con lines=%YSIZE% cols=%XSIZE%
set /a YDUBL=%YSIZE%*2
cmdwiz setbuffersize k %YDUBL%
gotoxy 0 %YSIZE% %BLOCK% 0 0 r
set BLOCK=
set DELAY=5
set FX=fX
if not "%1" == "" set FX=%1

for /L %%a in (1,1,50) do set BL=!BL!\G
call :MAKE_SQ
call :MAKE_SQ2


:LOOP
gotoxy 0 0 "\o0;%YSIZE%;%XSIZE%;%YSIZE%\R\p%XP%;%YP%%SQ:~1,-1%\R\p%XP2%;%YP2%%SQ2:~1,-1%\o0;0\w%DELAY%" 0 0 k
if %ERRORLEVEL% == 27 goto ENDLOOP

set /a YP += 1
if %YP% gtr %YMAX% call :MAKE_SQ

set /a XP2 += 1
if %XP2% gtr %XMAX% call :MAKE_SQ2

goto LOOP
:ENDLOOP

cmdwiz showcursor 1
mode con lines=%YSIZE%
if %YORG% gtr %YSIZE% cmdwiz setbuffersize k %YORG%
del /Q tempblock.gxy
endlocal
goto :eof


:MAKE_SQ
set /a YS=16+%RANDOM% %% 25
set /a XS=16+%RANDOM% %% 25
set /a YP=0-%YS%
set /a XP=%RANDOM% %% (%XSIZE% - %XS% + 6) - 3
set /a SC=9+%RANDOM% %% 6
call :DECTOHEX %SC% P

set SQ="\f%P%\%FX%"
set /a XW=%XS%*2
for /L %%b in (1,1,%YS%) do set SQ="!SQ:~1,-1!!BL:~0,%XW%!\n"
goto :eof

:MAKE_SQ2
set /a YS2=16+%RANDOM% %% 25
set /a XS2=16+%RANDOM% %% 25
set /a XP2=-1-%XS2%
set /a YP2=%RANDOM% %% (%YSIZE% - %YS2% + 6) - 3
set /a SC2=9+%RANDOM% %% 6
call :DECTOHEX %SC2% P

set SQ2="\f%P%\%FX%"
set /a XW=%XS2%*2
for /L %%b in (1,1,%YS2%) do set SQ2="!SQ2:~1,-1!!BL:~0,%XW%!\n"
goto :eof

:DECTOHEX <in> <out>
if "%~2"=="" goto :eof
if "%D2H%"=="" set D2H=0123456789abcdef
set /A DECVAL=%~1
set OR=0&(if %DECVAL% geq 16 set OR=1)&(if %DECVAL% lss 0 set OR=1)&if !OR!==1 set %2=0&goto :eof
set %2=!D2H:~%DECVAL%,1!
goto :eof
