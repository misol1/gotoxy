@echo off
mode con lines=50 cols=80
color 07
setlocal ENABLEDELAYEDEXPANSION
call sintable.bat
cmdwiz showcursor 0
cmdwiz getcursorpos x&set X=!ERRORLEVEL!
cmdwiz getcursorpos y&set Y=!ERRORLEVEL!
cmdwiz getconsoledim y&set YM=!ERRORLEVEL!
cmdwiz getconsoledim x&set XM=!ERRORLEVEL!
set DELAY=&if not "%1" == "" set DELAY=\W%1

for /F "tokens=*" %%i in (goomba.gxy) do set gom="%%i"

set CNT=0
set SC=0
set CC=180
set SC2=50
set SC3=350
set /a XMID=%XM%/2
set /a XMUL=%XM%/3

set /a YMID=%YM%/2
set /a YMUL=%YM%/3

::STARS
set NOF=6
set XDELAY=2
set /a XMAX=%XM%*%XDELAY%
set /a YMAX=%YM%*%XDELAY%
for /L %%b in (0,1,%NOF%) do call :MAKESTAR %%b

Set "spi0=\-\-\0A \-\-\-\-\- \n"
Set "spi0=%spi0%\-\-\- \-\-\- \n"
Set "spi0=%spi0%\-\-       \n"
Set "spi0=%spi0%\-  \0E \0A   \0E \0A  \n"
Set "spi0=%spi0%           \n"
Set "spi0=%spi0% \-       \- \n"
Set "spi0=%spi0% \- \-\-\-\-\- \- \n"
Set "spi0=%spi0%\-\-\-  \-  "

Set "spi1=%spi0:0E=0C%"
set TOGG=0

Set "spi2=%spi0:0A=0B%"
Set "spi2=%spi2:0E=0F%"
set YPOS2=10
set XPOS3=50

:REP
set /a XPOS=%XMID%-8+(!SIN%SC%!*%XMUL%^>^>14)
set /a YPOS=%YMID%-7+(!SIN%CC%!*%YMUL%^>^>14)
set /a XPOS2=%XMID%-4+(!SIN%SC2%!*%XMUL%^>^>14)
set /a YPOS3=%YMID%-4+(!SIN%SC3%!*18^>^>14)
set FIELD=
for /L %%b in (0,1,%NOF%) do set /a XTMP=!STARX%%b!/%XDELAY%&set FIELD=!FIELD!\p!XTMP!;!STARY%%b!!STARC%%b!.&set /a STARX%%b+=!STARS%%b!&if !STARX%%b! geq %XMAX% set /a STARX%%b=-3-(!RANDOM! %% %XM%)&set /a STARY%%b=!RANDOM! %% %YM%
gotoxy.exe 0 0 "\O0;0;80;%YM%%FIELD%\p%XPOS2%;%YPOS2%!spi%TOGG%!\p%XPOS3%;%YPOS3%%spi2%\p%XPOS%;%YPOS%%gom%%DELAY%"
set /a SC+=6 & if !SC! geq 720 set /A SC=!SC!-720
set /a CC+=6 & if !CC! geq 720 set /A CC=!CC!-720
set /a SC2+=5 & if !SC2! geq 720 set /A SC2=!SC2!-720
set /a SC3+=3 & if !SC3! geq 720 set /A SC3=!SC3!-720
set /a CNT+=1 & set /a CNTEMP=!CNT! %% 20 & if !CNTEMP!==0 cmdwiz getch nowait
set /a TOGG=1-%TOGG%
if not %ERRORLEVEL% == 27 goto REP

cmdwiz showcursor 1
endlocal
cls
goto :eof


:MAKESTAR
set /a STARY%1=%RANDOM% %% %YM%
set /a STARX%1=%RANDOM% %% %XMAX%
if not "%2" == "" set STARX%1=%2
set /a STARS%1=%RANDOM% %% 3 + 1
if !STARS%1! == 1 set STARC%1=\80
if !STARS%1! == 2 set STARC%1=\70
if !STARS%1! == 3 set STARC%1=\F0
