@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
set NOF=15
gotoxy 0 0
cmdwiz getconsoledim sx
set XSIZE=%ERRORLEVEL%
cmdwiz getconsoledim sy
set YSIZE=%ERRORLEVEL%

set XDELAY=2

if not "%1" == "" set NOF=%1
if not "%2" == "" set XDELAY=%2

set /a XMAX=%XSIZE%*%XDELAY%

for /L %%b in (0,1,%NOF%) do call :MAKESTAR %%b
set CNT=0

::cmdwiz saveblock tempblock 0 0 %XSIZE% %YSIZE% e " "
cmdwiz saveblock tempblock 0 0 %XSIZE% %YSIZE%
for /F "tokens=*" %%i in (tempblock.gxy) do set BLOCK="%%i"

:LOOP
set FIELD=
::for /L %%b in (0,1,%NOF%) do set /a XTMP=!STARX%%b!/%XDELAY%&set FIELD=!FIELD!\p!XTMP!;!STARY%%b!!STARC%%b!\g07&set /a STARX%%b+=!STARS%%b!&if !STARX%%b! geq %XMAX% set /a STARX%%b=-3-(!RANDOM! %% %XSIZE%)&set /a STARY%%b=!RANDOM! %% %YSIZE%
::gotoxy.exe 0 0 "\o0;0;%XSIZE%;%YSIZE%%BLOCK:~1,-1%%FIELD%" 7 0

for /L %%b in (0,1,%NOF%) do set /a XTMP=!STARX%%b!/%XDELAY%&set FIELD=!FIELD!\p!XTMP!;!STARY%%b!!STARC%%b!.&set /a STARX%%b+=!STARS%%b!&if !STARX%%b! geq %XMAX% set /a STARX%%b=-3-(!RANDOM! %% %XSIZE%)&set /a STARY%%b=!RANDOM! %% %YSIZE%
gotoxy.exe 0 0 "\O0;0;%XSIZE%;%YSIZE%%FIELD%\p0;0\t20k0%BLOCK:~1,-1%" 7 0

set /a CNT+=1
set /a TMP=%CNT% %% 30
if %TMP% == 0 cmdwiz getch nowait
if not %ERRORLEVEL% == 27 goto LOOP

gotoxy 0 0 tempblock.gxy
del /Q tempblock.gxy
cmdwiz showcursor 1
endlocal
goto :eof

:MAKESTAR
set /a STARY%1=%RANDOM% %% %YSIZE%
set /a STARX%1=%RANDOM% %% %XSIZE%
if not "%2" == "" set STARX%1=%2
set /a STARS%1=%RANDOM% %% 3 + 1
if !STARS%1! == 1 set STARC%1=\80
if !STARS%1! == 2 set STARC%1=\70
if !STARS%1! == 3 set STARC%1=\F0
