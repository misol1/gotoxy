:: Flappy : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
call hiscore.bat flappyscore.dat create "Birdman" 1
mode con lines=52 cols=120
color 07
cls
set DDY=10
set DY=0
set /a MID=26*256
set OY=0
set DELAY=\W12&if not "%1" == "" set DELAY=\W%1
set BARH=49

set SCORE=-1
set CNT=1
set BAR=""
:BARLOOP
set BAR="\01      \00   \n%BAR:~1,-1%"
set /a CNT+=1
if %CNT% lss %BARH% goto BARLOOP

call :SETBAR

:LOOP
set /a DDY+=9
set /a DY+=%DDY%
set /a Y=(%MID%+%DY%)/256

gotoxy_extended.exe 5 %OY% " \p5;%Y%O\p%BARX%;%BAR1Y%%BAR:~1,-1%\p%BARX%;%BAR2Y%%BAR:~1,-1%\L:111b;%DELAY%" 14
set VKEYS=%ERRORLEVEL%
set OY=%Y%

if %Y% lss -18 goto ESC
if %Y% gtr 72 goto ESC

if %BARX% geq 6 goto NOHIT
if %BARX% lss -1 goto NOHIT
set /a TY1=%BAR1Y%+%BARH%-1
if %Y% geq %TY1% if %Y% lss %BAR2Y% goto NOHIT
goto ESC

:NOHIT
set /a BARX-=2
if %BARX% lss -10 call :SETBAR

set /a KS=%VKEYS% ^& 1 & if !KS! geq 1 set /a DDY-=18
set /a KS=%VKEYS% ^& 2 & if !KS! geq 1 goto REALESC
goto LOOP


:ESC
call hiscore.bat flappyscore.dat check %SCORE%
if %ERRORLEVEL% == 0 goto REALESC

cmdwiz showcursor 1
gotoxy 10 1 "New Hiscore. Your Name: " 11 0 c
set /P NEWNAME=""
if "%NEWNAME%" == "" goto REALESC

call hiscore.bat flappyscore.dat insert "%NEWNAME%" %SCORE%
set NEWPOS=%ERRORLEVEL%
set LINE=3
for /L %%a in (1,1,10) do gotoxy 10 !LINE! "%%a. !HIN%%a!" 14 & set /A LINE=!LINE!+1
set /A HIYPOS=%NEWPOS%+2
gotoxy 10 %HIYPOS% "%NEWPOS%. !HIN%NEWPOS%!" 15
set LINE=3
for /L %%a in (1,1,10) do gotoxy 35 !LINE! "!HI%%a!" 15 & set /A LINE=!LINE!+1
echo.
cmdwiz showcursor 0
cmdwiz getch

:REALESC
call hiscore.bat flappyscore.dat clean
cmdwiz showcursor 1
mode con lines=50 cols=80
cls
endlocal
goto :eof

:SETBAR
set BARX=130
set /a BAR1Y=0 - %RANDOM% %% %BARH%
set /a DIST=8-%SCORE%/9
if %DIST% lss 3 set DIST=3
set /a BAR2Y=%BAR1Y% + %BARH% + %DIST%
set /a SCORE+=1
gotoxy 1 1 %SCORE% 12
goto :eof
