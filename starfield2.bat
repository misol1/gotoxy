@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
set NOF=15
::gotoxy 0 0
cmdwiz getconsoledim sx
set XSIZE=%ERRORLEVEL%
cmdwiz getconsoledim sy
set YSIZE=%ERRORLEVEL%
cmdwiz getconsoledim cy
set YCURRENT=%ERRORLEVEL%

set XDELAY=2
set DIR=1

if not "%1" == "" set DIR=%1
if not "%2" == "" set NOF=%2
if not "%3" == "" set XDELAY=%3

set /a XMAX=%XSIZE%*%XDELAY%
set /a YMAX=%YSIZE%*%XDELAY%

for /L %%b in (0,1,%NOF%) do call :MAKESTAR %%b

cmdwiz saveblock tempblock 0 %YCURRENT% %XSIZE% %YSIZE%
for /F "tokens=*" %%i in (tempblock.gxy) do set BLOCK="%%i"

:LOOP
set FIELD=
if %DIR%==1 for /L %%b in (0,1,%NOF%) do set /a XTMP=!STARX%%b!/%XDELAY%&set FIELD=!FIELD!\p!XTMP!;!STARY%%b!!STARC%%b!.&set /a STARX%%b+=!STARS%%b!&if !STARX%%b! geq %XMAX% set /a STARX%%b=-3-(!RANDOM! %% %XSIZE%)&set /a STARY%%b=!RANDOM! %% %YSIZE%
if %DIR%==2 for /L %%b in (0,1,%NOF%) do set /a XTMP=!STARX%%b!/%XDELAY%&set FIELD=!FIELD!\p!XTMP!;!STARY%%b!!STARC%%b!.&set /a STARX%%b-=!STARS%%b!&if !STARX%%b! lss -4 set /a STARX%%b=%XMAX%+3+(!RANDOM! %% %XSIZE%)&set /a STARY%%b=!RANDOM! %% %YSIZE%
if %DIR%==3 for /L %%b in (0,1,%NOF%) do set /a YTMP=!STARY%%b!/%XDELAY%&set FIELD=!FIELD!\p!STARX%%b!;!YTMP!!STARC%%b!.&set /a STARY%%b+=!STARS%%b!&if !STARY%%b! geq %YMAX% set /a STARY%%b=-3-(!RANDOM! %% %YSIZE%)&set /a STARX%%b=!RANDOM! %% %XMAX%
if %DIR%==4 for /L %%b in (0,1,%NOF%) do set /a YTMP=!STARY%%b!/%XDELAY%&set FIELD=!FIELD!\p!STARX%%b!;!YTMP!!STARC%%b!.&set /a STARY%%b-=!STARS%%b!&if !STARY%%b! lss -4 set /a STARY%%b=%YMAX%+3+(!RANDOM! %% %YSIZE%)&set /a STARX%%b=!RANDOM! %% %XMAX%

gotoxy.exe 0 %YCURRENT% "\O0;%YCURRENT%;%XSIZE%;%YSIZE%%FIELD%\p0;0\T20kU%BLOCK:~1,-1%" 7 0 rk
if not %ERRORLEVEL% == 27 goto LOOP

gotoxy 0 %YCURRENT% tempblock.gxy 0 0 r
del /Q tempblock.gxy
cmdwiz showcursor 1
endlocal
goto :eof

:MAKESTAR
set /a STARY%1=%RANDOM% %% %YSIZE%
set /a STARX%1=%RANDOM% %% %XSIZE%
if not "%2" == "" set STARX%1=%2
set /a STARS%1=%RANDOM% %% 3 + 1
if !STARS%1! == 1 set STARC%1=\8U
if !STARS%1! == 2 set STARC%1=\7U
if !STARS%1! == 3 set STARC%1=\FU
