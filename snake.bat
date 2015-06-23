:: Snake : Mikael Sollenborn 2015
@echo off
mode con lines=50
cls
cmdwiz showcursor 0
setlocal ENABLEDELAYEDEXPANSION
call hiscore.bat snakescore.dat create "Wormhole" 50

cmdwiz getconsoledim x
set MAXX=%ERRORLEVEL%
cmdwiz getconsoledim y
set /a MAXY=%ERRORLEVEL%-2

set WIDTH=%MAXX%
set HEIGHT=30
set NOFAPPLES=1
set DELAY=0
if not "%1" == "" set /a HEIGHT=%1
if %HEIGHT% lss 10 set HEIGHT=30
if %HEIGHT% gtr %MAXY% set HEIGHT=%MAXY%
if not "%2" == "" set /a NOFAPPLES=%2
if %NOFAPPLES% lss 1 set NOFAPPLES=1
if not "%3" == "" set /a DELAY=%3

set SCREEN=#
for /L %%a in (1,1,%WIDTH%) do call :BUILDSCR "*"
gotoxy 0 0 "!SCREEN!" 11 0 1
gotoxy 0 %HEIGHT% "!SCREEN!" 11 0 1

set SCREEN=*
set /A TEMP=%WIDTH%-2
for /L %%a in (1,1,%TEMP%) do call :BUILDSCR " "
set SCREEN=%SCREEN%*
set /A TEMP=%HEIGHT%-1
for /L %%a in (1,1,%TEMP%) do gotoxy 0 %%a "!SCREEN!" 11 0 1

set XPOS=20
set /A YPOS=%HEIGHT%/2
set LEN=5
set DIR=1
set XD=1
set YD=0
set SCORE=0

set OLDI=1
set XO1=0&set XO2=0&set XO3=0&set XO4=0&set XO5=0
set /A YODEF=%HEIGHT%+2
set YO1=%YODEF%&set YO2=%YODEF%&set YO3=%YODEF%&set YO4=%YODEF%&set YO5=%YODEF%

call :PRINTSCORE
for /L %%a in (1,1,%NOFAPPLES%) do call :PUTAPPLE

:PLAYLOOP
gotoxy %XPOS% %YPOS% "o" 15 12 1
gotoxy !XO%OLDI%! !YO%OLDI%! " " 15 0 1

set XO%OLDI%=%XPOS%
set YO%OLDI%=%YPOS%
set /A OLDI=%OLDI%+1
if %OLDI% GTR %LEN% set OLDI=1

cmdwiz getch nowait
if %ERRORLEVEL% == 27 set SCORE=-1 & goto CLEANUP
if %ERRORLEVEL% == 122 call :SWITCHDIR1
if %ERRORLEVEL% == 120 call :SWITCHDIR2

set /A XPOS=%XPOS%+%XD%
set /A YPOS=%YPOS%+%YD%

rem 42=*, 111=o, 64=@  (ASCII)
cmdwiz getcharat %XPOS% %YPOS%
if %ERRORLEVEL% == 42 goto CLEANUP
if %ERRORLEVEL% == 111 goto CLEANUP
if %ERRORLEVEL% == 64 set /A SCORE=%SCORE%+25 & call :INCLEN 3& call :PUTAPPLE & call :PRINTSCORE
if %DELAY% gtr 0 cmdwiz delay %DELAY%
goto PLAYLOOP


:CLEANUP
cmdwiz showcursor 1
call hiscore.bat snakescore.dat check %SCORE%
if %ERRORLEVEL% == 0 goto NOHI

gotoxy 3 2 "New Hiscore. Your Name: " 9 0 c
set /P NEWNAME=""
if "%NEWNAME%" == "" goto NOHI

cmdwiz showcursor 0
call hiscore.bat snakescore.dat insert "%NEWNAME%" %SCORE%
set NEWPOS=%ERRORLEVEL%
set LINE=4
for /L %%a in (1,1,10) do gotoxy 3 !LINE! "%%a. !HIN%%a!" 14 & set /A LINE=!LINE!+1
set /A HIYPOS=%NEWPOS%+3
gotoxy 3 %HIYPOS% "%NEWPOS%. !HIN%NEWPOS%!" 15
set LINE=4
for /L %%a in (1,1,10) do gotoxy 33 !LINE! "!HI%%a!" 15 & set /A LINE=!LINE!+1
cmdwiz getch

:NOHI
call hiscore.bat snakescore.dat clean
cmdwiz showcursor 1
endlocal
goto :EOF

:BUILDSCR
set SCREEN=%SCREEN%%~1
goto :EOF

:SWITCHDIR1
set /A DIR=%DIR%+1
IF %DIR%==5 SET DIR=1
goto UPDATEDIR
:SWITCHDIR2
set /A DIR=%DIR%-1
IF %DIR%==0 SET DIR=4
:UPDATEDIR
if %DIR%==1 SET XD=1&SET YD=0
if %DIR%==2 SET XD=0&SET YD=1
if %DIR%==3 SET XD=-1&SET YD=0
if %DIR%==4 SET XD=0&SET YD=-1
goto :EOF

:PRINTSCORE
set /A TEMP=%HEIGHT%+1
gotoxy 0 %TEMP% "SCORE: %SCORE%  LENGTH: %LEN%" 3 0 1
goto :EOF

:PUTAPPLE
set /A TEMP=%WIDTH%-4
SET /A AX=%RANDOM% %% %TEMP% + 2
set /A TEMP=%HEIGHT%-3
SET /A AY=%RANDOM% %% %TEMP% + 2

cmdwiz getcharat %AX% %AY%
if NOT %ERRORLEVEL% == 32 goto PUTAPPLE

gotoxy %AX% %AY% "@" 10 0 1
goto :EOF

:INCLEN
set /A OLDLEN=%LEN%+1
set /A LEN=%LEN%+%1 
for /L %%a in (%OLDLEN%,1,%LEN%) do set XO%%a=0&set YO%%a=%YODEF%
set OLDLEN=
goto :EOF
