@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=45 cols=80
cmdwiz setbuffersize 80 150
cmdwiz showcursor 0
cmdwiz quickedit 0
color 07
cls

call sintable.bat

for /F "tokens=*" %%i in (circles_p1.gxy) do set CIRC="%%i"
for /F "tokens=*" %%i in (circles_p2.gxy) do set CIRC2="%%i"

::set CIRC3=%CIRC:\01=\02%
::set CIRC4=%CIRC2:\01=\02%

set XMID=-18
set YMID=86
set XMUL=19
set YMUL=15

set SC=0
set CC=180

set SC2=0
set CC2=30

:LOOP
set /a CX1=%XMID%+(!SIN%SC%!*%XMUL%^>^>14)
set /a CY1=%YMID%+(!SIN%CC%!*%YMUL%^>^>14)
set /a SC+=11 & if !SC! geq 720 set /A SC=!SC!-720
set /a CC+=15 & if !CC! geq 720 set /A CC=!CC!-720

set /a CX2=%XMID%+(!SIN%SC2%!*%XMUL%^>^>14)
set /a CY2=%YMID%+(!SIN%CC2%!*%YMUL%^>^>14)
set /a SC2+=6 & if !SC2! geq 720 set /A SC2=!SC2!-720
set /a CC2+=9 & if !CC2! geq 720 set /A CC2=!CC2!-720

gotoxy %CX1% %CY1% "%CIRC:~1,-1%" 0 0 r
set /A CY12=%CY1%+37
gotoxy %CX1% %CY12% "%CIRC2:~1,-1%" 0 0 r

gotoxy %CX2% %CY2% "\R%CIRC:~1,-1%" 0 -X r
set /A CY22=%CY2%+37
gotoxy %CX2% %CY22% "\R%CIRC2:~1,-1%\o0;100;80;50;\o0;0;\i" 0 -X r

if not !ERRORLEVEL! == 27 goto LOOP

setlocal
cmdwiz quickedit 1
cmdwiz showcursor 1
