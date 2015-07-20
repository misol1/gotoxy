@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
color 07
cls
set NOF=20
set XSIZE=140
set YSIZE=50
set XDELAY=2

set DIR=1

if not "%1" == "" set DIR=%1
if not "%2" == "" set NOF=%2
if not "%3" == "" set XSIZE=%3
if not "%4" == "" set YSIZE=%4
if not "%5" == "" set XDELAY=%5

mode con lines=%YSIZE% cols=%XSIZE%

set /a XMAX=%XSIZE%*%XDELAY%
set /a YMAX=%YSIZE%*%XDELAY%

for /L %%b in (0,1,%NOF%) do call :MAKESTAR %%b
set CNT=0

:LOOP
set FIELD=
if %DIR%==1 for /L %%b in (0,1,%NOF%) do set /a XTMP=!STARX%%b!/%XDELAY%&set FIELD=!FIELD!\p!XTMP!;!STARY%%b!!STARC%%b!   .&set /a STARX%%b+=!STARS%%b!&if !STARX%%b! geq %XMAX% set /a STARX%%b=-3-(!RANDOM! %% %XSIZE%)&set /a STARY%%b=!RANDOM! %% %YSIZE%
if %DIR%==2 for /L %%b in (0,1,%NOF%) do set /a XTMP=!STARX%%b!/%XDELAY%&set FIELD=!FIELD!\p!XTMP!;!STARY%%b!!STARC%%b!.   &set /a STARX%%b-=!STARS%%b!&if !STARX%%b! lss -4 set /a STARX%%b=%XMAX%+3+(!RANDOM! %% %XSIZE%)&set /a STARY%%b=!RANDOM! %% %YSIZE%
if %DIR%==3 for /L %%b in (0,1,%NOF%) do set /a YTMP=!STARY%%b!/%XDELAY%&set FIELD=!FIELD!\p!STARX%%b!;!YTMP!!STARC%%b! \n \n \n.&set /a STARY%%b+=!STARS%%b!&if !STARY%%b! geq %YMAX% set /a STARY%%b=-3-(!RANDOM! %% %YSIZE%)&set /a STARX%%b=!RANDOM! %% %XMAX%
if %DIR%==4 for /L %%b in (0,1,%NOF%) do set /a YTMP=!STARY%%b!/%XDELAY%&set FIELD=!FIELD!\p!STARX%%b!;!YTMP!!STARC%%b!. \n \n \n&set /a STARY%%b-=!STARS%%b!&if !STARY%%b! lss -4 set /a STARY%%b=%YMAX%+3+(!RANDOM! %% %YSIZE%)&set /a STARX%%b=!RANDOM! %% %XMAX%
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
