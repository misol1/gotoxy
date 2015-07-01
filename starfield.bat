@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
cls
set NOF=20
set XSIZE=140
set YSIZE=50
set XDELAY=2

if not "%1" == "" set NOF=%1
if not "%2" == "" set XSIZE=%2
if not "%3" == "" set YSIZE=%3
if not "%4" == "" set XDELAY=%4

mode con lines=%YSIZE% cols=%XSIZE%

set /a XMAX=%XSIZE%*%XDELAY%

for /L %%b in (0,1,%NOF%) do call :MAKESTAR %%b
set CNT=0

:LOOP
set FIELD=
for /L %%b in (0,1,%NOF%) do set /a XTMP=!STARX%%b!/%XDELAY%&set FIELD=!FIELD!\p!XTMP!;!STARY%%b!!STARC%%b!   .&set /a STARX%%b+=!STARS%%b!&if !STARX%%b! geq %XMAX% set /a STARX%%b=-3-(!RANDOM! %% %XSIZE%)&set /a STARY%%b=!RANDOM! %% %YSIZE%
gotoxy.exe 0 0 "%FIELD%" 7 0

set /a CNT+=1
set /a KTMP=%CNT% %% 100
if %KTMP% == 0 cmdwiz getch nowait
if not %ERRORLEVEL% == 27 goto LOOP

mode con lines=50 cols=80
cls
cmdwiz showcursor 1
endlocal
goto :eof

:MAKESTAR
set /a STARY%1=%RANDOM% %% %YSIZE%
set /a STARX%1=%RANDOM% %% %XMAX%
if not "%2" == "" set STARX%1=%2
set /a STARS%1=%RANDOM% %% 3 + 1
if !STARS%1! == 1 set STARC%1=\80
if !STARS%1! == 2 set STARC%1=\70
if !STARS%1! == 3 set STARC%1=\F0
