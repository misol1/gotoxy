@echo off
setlocal ENABLEDELAYEDEXPANSION
mode 80,45&cls
cmdwiz showcursor 0
color 07

call sintable.bat

set COL1=1&if not "%~1" == "" set COL1=%~1
set COL2=1&if not "%~2" == "" set COL2=%~2
set FX=x&if not "%~3"=="" set FX=%~3 

set /a "XMID=-18, YMID=-15"
set /a "XMUL=19, YMUL=15, XMUL2=11, YMUL2=10"
set /a "SC=0, CC=180, SC2=0, CC2=30"

:LOOP
set /a "CX1=%XMID%+(!SIN%SC%!*%XMUL%^>^>14), CY1=%YMID%+(!SIN%CC%!*%YMUL%^>^>14), SC+=11, CC+=15"
if !SC! geq 720 set /A SC=!SC!-720
if !CC! geq 720 set /A CC=!CC!-720

set /a "CX2=%XMID%+(!SIN%SC2%!*%XMUL2%^>^>14), CY2=%YMID%+(!SIN%CC2%!*%YMUL2%^>^>14), SC2+=6, CC2+=9"
if !SC2! geq 720 set /A SC2=!SC2!-720
if !CC2! geq 720 set /A CC2=!CC2!-720

gotoxy 0 0 "\O0;0;80;45;\00\N20\T20kk1;\p%CX1%;%CY1%;\%COL1%0\R\I:circles3.gxy;\R\p%CX2%;%CY2%;\%COL2%0\%FX%0\I:circles3.gxy;" 0 0 k

if not !ERRORLEVEL! == 27 goto LOOP

mode 80,50&cls
cmdwiz showcursor 1
endlocal
