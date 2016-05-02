@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=45 cols=80
cmdwiz setbuffersize 119 280
cmdwiz showcursor 0
color 07
cls

call sintable.bat

for /F "tokens=*" %%i in (circles_p1.gxy) do set CIRC="%%i"
for /F "tokens=*" %%i in (circles_p2.gxy) do set CIRC2="%%i"

if not "%~4"=="" set CIRC=!CIRC: =%~4!&set CIRC2=!CIRC2: =%~4!

set CIRC3=%CIRC%
set CIRC4=%CIRC2%
if not "%~1"=="" set CIRC3=!CIRC:\01=\0%~1!&set CIRC4=!CIRC2:\01=\0%~1!

gotoxy 0 190 %CIRC3% 0 0 r
gotoxy 0 227 %CIRC4% 0 0 r
set CIRC3=&set CIRC4=

if not "%~2"=="" set CIRC=!CIRC:\01=\0%~2!&set CIRC2=!CIRC2:\01=\0%~2!

set FX=X&if not "%~3"=="" set FX=%~3 

set XMID=-18
set YMID=86
set XMUL=19
set YMUL=15

set XMUL2=11
set YMUL2=10

set SC=0
set CC=180
set SC2=0
set CC2=30

:LOOP
set /a CX1=%XMID%+(!SIN%SC%!*%XMUL%^>^>14)+40
set /a CY1=%YMID%+(!SIN%CC%!*%YMUL%^>^>14)
set /a SC+=11 & if !SC! geq 720 set /A SC=!SC!-720
set /a CC+=15 & if !CC! geq 720 set /A CC=!CC!-720

set /a CX2=%XMID%+(!SIN%SC2%!*%XMUL2%^>^>14)
set /a CY2=%YMID%+(!SIN%CC2%!*%YMUL2%^>^>14)
set /a SC2+=6 & if !SC2! geq 720 set /A SC2=!SC2!-720
set /a CC2+=9 & if !CC2! geq 720 set /A CC2=!CC2!-720

gotoxy 0 0 "\o%CX1%;190;80;80;\o0;%CY1%;\R\p%CX2%;%CY2%;%CIRC:~1,-1%" 0 -%FX% r
set /A CY22=%CY2%+37
gotoxy %CX2% %CY22% "\R%CIRC2:~1,-1%\o0;100;80;50;\o0;0" 0 -%FX% rk

if not !ERRORLEVEL! == 27 goto LOOP

mode con lines=50 cols=80&cls
cmdwiz showcursor 1
endlocal
