:: Space Invaders : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=25
color 07
cls
cmdwiz showcursor 0
call hiscore.bat spacescore.dat create "Invader" 50

cmdwiz getconsoledim x
set MAXX=%ERRORLEVEL%
cmdwiz getconsoledim y
set /a MAXY=%ERRORLEVEL%-3
set /a DEADY=%MAXY%-1
set /a PLYMAXX=%MAXX%-7

set NOFENEMY=1
set DELAY=0
if not "%1" == "" set DELAY=%1

set XPOS=20
set /A YPOS=%MAXY%-1
set XD=1
set SCORE=0
set ENDGAME=0

set SHOTBEG=1
set SHOTCNT=1

set ENEMYBEG=1
set ENEMYCNT=1
set XOLD=0
set YOLD=0

call :PRINTSCORE
for /L %%a in (1,1,%NOFENEMY%) do call :ADDENEMY

:PLAYLOOP
gotoxy %XPOS% %YPOS% " \FCooooo\00 " 0 0 1

cmdwiz getch nowait
if %ERRORLEVEL% == 27 set SCORE=-1 & goto CLEANUP
if %ERRORLEVEL% == 122 call :SWITCHDIR1
if %ERRORLEVEL% == 120 call :SWITCHDIR2
if %ERRORLEVEL% == 32 call :ADDSHOT

set /A XPOS=%XPOS%+%XD%
if %XPOS% geq %PLYMAXX% set XPOS=%PLYMAXX%& goto NOX
if %XPOS% leq 0 set XPOS=0 & goto NOX
:NOX

call :PLACEENEMIES
call :PLACESHOTS

if %DELAY% geq 1 cmdwiz delay %DELAY%

if %ENDGAME% == 1 goto CLEANUP
goto PLAYLOOP

:CLEANUP

cmdwiz showcursor 1
call hiscore.bat spacescore.dat check %SCORE%
if %ERRORLEVEL% == 0 goto NOHI

gotoxy 3 1 "New Hiscore. Your Name: " 9 0 c
set /P NEWNAME=""
if "%NEWNAME%" == "" goto NOHI

cmdwiz showcursor 0
call hiscore.bat spacescore.dat insert "%NEWNAME%" %SCORE%
set NEWPOS=%ERRORLEVEL%
set LINE=3
for /L %%a in (1,1,10) do gotoxy 3 !LINE! "%%a. !HIN%%a!" 14 & set /A LINE=!LINE!+1
set /A HIYPOS=%NEWPOS%+2
gotoxy 3 %HIYPOS% "%NEWPOS%. !HIN%NEWPOS%!" 15
set LINE=3
for /L %%a in (1,1,10) do gotoxy 33 !LINE! "!HI%%a!" 15 & set /A LINE=!LINE!+1
cmdwiz getch

:NOHI
call hiscore.bat spacescore.dat clean

ENDLOCAL
cmdwiz showcursor 1
goto :EOF

:SWITCHDIR1
SET XD=-1
goto :EOF
:SWITCHDIR2
SET XD=1
goto :EOF

:PRINTSCORE
set /A TEMP=%MAXY%+1
gotoxy 0 %TEMP% " SCORE: %SCORE%" 3 0 1
goto :EOF

:INCSCORE
set /A SCORE=%SCORE%+25
call :PRINTSCORE
goto :EOF


:ADDENEMY
set /A TEMP=%MAXX%-4
SET /A EX%ENEMYCNT%=%RANDOM% %% %TEMP% + 2
SET /A RX%ENEMYCNT%=%RANDOM% %% 42
set /A TMPX=EX%ENEMYCNT%+RX%ENEMYCNT% + 7
if %TMPX% GEQ %MAXX% goto ADDENEMY
SET CX%ENEMYCNT%=0
SET DX%ENEMYCNT%=1
set /A TEMP=%MAXY%-20
SET /A EY%ENEMYCNT%=%RANDOM% %% %TEMP% + 2

SET CY%ENEMYCNT%=0
SET /A RY%ENEMYCNT%=%RANDOM% %% 15 + 10

SET /A EC%ENEMYCNT%=%RANDOM% %% 6 + 9

set /A ENEMYCNT=%ENEMYCNT%+1
goto :EOF

:ADDSHOT
set /A SHOTTMP=%SHOTCNT%-%SHOTBEG%
if %SHOTTMP% GTR 0 goto :EOF
set /A XSP%SHOTCNT% = %XPOS%+3
set /A YSP%SHOTCNT% = %YPOS%
set /A SHOTCNT=%SHOTCNT%+1
goto :EOF

:PLACESHOTS
set /A TMPSB=%SHOTCNT%-1
for /L %%a in (%SHOTBEG%,1,%TMPSB%) do call :MOVESHOT %%a
goto :EOF

:MOVESHOT
set /A YSP%1-=1
if !YSP%1! LSS 0 set /A SHOTBEG=!SHOTBEG!+1
call :CHECKHIT !XSP%1! !YSP%1! %1
gotoxy !XSP%1! !YSP%1! ".\n " 10 0 1
goto :EOF

:PLACEENEMIES
set /A TMPSB=%ENEMYCNT%-1
for /L %%a in (%ENEMYBEG%,1,%TMPSB%) do call :MOVEENEMY %%a
goto :EOF

:MOVEENEMY
set OLDX=!EX%1!
set /A EX%1=EX%1+DX%1&set /A CX%1=!CX%1!+1
if !CX%1! GEQ !RX%1! set /A DX%1=-!DX%1! & set CX%1=0
set /A CY%1=!CY%1!+1
if !CY%1! GEQ !RY%1! gotoxy %OLDX% !EY%1! "       " 14 0 1&set /A EY%1=!EY%1!+1 & set CY%1=0
if !EY%1! GEQ %DEADY% set ENDGAME=1
gotoxy !EX%1! !EY%1! " @@@@@ " !EC%1! 0 1
goto :EOF

:CHECKHIT
cmdwiz getcharat %1 %2
set HITRES=%ERRORLEVEL%
set /A TMPSC=%ENEMYCNT%-1
set /a OLDY=!YSP%3!+1
if %HITRES% == 64 gotoxy !XSP%3! !OLDY! " " 10 0 1 &for /L %%a in (%ENEMYBEG%,1,%TMPSC%) do gotoxy !EX%%a! !EY%%a! "       " 14 0 1
if %HITRES% == 64 call :ADDENEMY & set YSP%3=-3&set /A ENEMYBEG=%ENEMYBEG%+1 & call :INCSCORE
goto :EOF
