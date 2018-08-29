:: Golf : Mikael Sollenborn 2015
@echo off
cmdwiz showcursor 0
color 07
cls
mode con lines=35 cols=80
setlocal ENABLEDELAYEDEXPANSION
set CNT=1
set YCNT=1
set XPOS=4
set YPOS=5
set SHADOW=0
set FLIP=0
call cardstack.bat shuffle
set DECKEND=0
set ALLOWONKING=0
if not "%1" == "" set ALLOWONKING=1
call hiscore.bat golfscore.dat create "Eagle" -20

gotoxy 19 1 "GOLF : <SPACE> deals, 1-7 get card from column" 3 0

:OUTERLOOP
set ORGXPOS=%XPOS%
set CNT=1

:DEALLOOP
call cardstack.bat deal

set COLUMN%CNT%_%YCNT%_SUIT=%CARDSUIT%
set COLUMN%CNT%_%YCNT%_VALUE=%CARDVALUE%

call playcard %XPOS% %YPOS% %SHADOW% %FLIP% %CARDVALUE% %CARDSUIT%

set /a CNT+=1
set /a XPOS+=11

if %CNT% leq 7 goto DEALLOOP

:OUT
set /a YCNT+=1
set /a YPOS+=2
set XPOS=%ORGXPOS%
if %YCNT% leq 5 goto OUTERLOOP

call playcard 32 23 %SHADOW% 1 1 1

for /L %%a in (1,1,7) do set COLUMNCOUNT%%a=5
set COLUMNCOUNT8=0

set STASHCNT=1
call :DEALCARD

:GAMELOOP
cmdwiz getch
set KEY=%ERRORLEVEL%
if %KEY% == 27 goto REALESC
if %KEY% == 32 call :DEALCARD
if %KEY% geq 49 if %KEY% leq 55 set /a KTMP=%KEY%-48& call :MOVESELECTED !KTMP!

if %DECKEND% == 1 goto GAMEOVER
goto GAMELOOP

:GAMEOVER
call :CALC_SCORE
gotoxy 4 1 "          Your final Golf score was %SCORE%. Now have a beer or two.        " 14 0


set /a SCORE=-%SCORE%
call hiscore.bat golfscore.dat check %SCORE%
if %ERRORLEVEL% == 0 goto ESCAPED

cmdwiz showcursor 1
gotoxy 14 3 "New Hiscore. Your Name: " 11 0 c
set /P NEWNAME=""
if "%NEWNAME%" == "" goto REALESC

call hiscore.bat golfscore.dat insert "%NEWNAME%" %SCORE%
set NEWPOS=%ERRORLEVEL%
set LINE=5
for /L %%a in (1,1,10) do gotoxy 14 !LINE! "%%a. !HIN%%a!" 14 & set /A LINE=!LINE!+1
set /A HIYPOS=%NEWPOS%+4
gotoxy 14 %HIYPOS% "%NEWPOS%. !HIN%NEWPOS%!" 15
set LINE=5
for /L %%a in (1,1,10) do set /a TMPSCORE=-!HI%%a! & gotoxy 39 !LINE! "!TMPSCORE!" 15 & set /A LINE=!LINE!+1
echo.
cmdwiz showcursor 0

:ESCAPED
cmdwiz getch
:REALESC

gotoxy 1 32
call cardstack.bat clean
cmdwiz showcursor 1
call hiscore.bat golfscore.dat clean
endlocal
goto :eof


:DEALCARD
if %DECKHEAD% leq %DECKTOE% goto GETCARD
set DECKEND=1
goto :eof

:GETCARD
call cardstack.bat deal
call playcard 43 23 %SHADOW% 0 !CARDVALUE! !CARDSUIT!
set STASHV%STASHCNT%=!CARDVALUE!
set STASHS%STASHCNT%=!CARDSUIT!
set /a STASHCNT+=1
set /a COLUMNCOUNT8+=1
set COLUMN8_%COLUMNCOUNT8%_VALUE=!CARDVALUE!
set COLUMN8_%COLUMNCOUNT8%_SUIT=!CARDSUIT!

if %DECKHEAD% gtr %DECKTOE% call playcard 32 23 %SHADOW% -1 7
goto :eof


:MOVESELECTED
set /a CARDVIS=!COLUMNCOUNT%1!
if %CARDVIS% leq 0 goto FAILMOVE
set DEST_SUIT=!COLUMN%1_%CARDVIS%_SUIT!
set DEST_VALUE=!COLUMN%1_%CARDVIS%_VALUE!

set SRC_VALUE=!COLUMN8_%COLUMNCOUNT8%_VALUE!

set /a TTMP=%DEST_VALUE%-%SRC_VALUE%
if %SRC_VALUE%==13 if %ALLOWONKING% == 0 goto FAILMOVE
if %TTMP%==1 goto OKMOVE
if %TTMP%==-1 goto OKMOVE
goto FAILMOVE

:OKMOVE
set /a COLUMNCOUNT8+=1
set COLUMN8_%COLUMNCOUNT8%_VALUE=%DEST_VALUE%
set COLUMN8_%COLUMNCOUNT8%_SUIT=%DEST_SUIT%
call playcard 43 23 %SHADOW% 0 !DEST_VALUE! !DEST_SUIT!

set /a COLUMNCOUNT%1-=1
call :CALC_SCORE
if %SCORE% lss 1 set DECKEND=1

set /a XPR=4 + (%1-1) * 11
set /a YPR=5 + !COLUMNCOUNT%1! * 2
call playcard %XPR% %YPR% %SHADOW% -1 7
if !COLUMNCOUNT%1! leq 0 goto :eof

set /a CARDVIS=!COLUMNCOUNT%1!
set DEST_SUIT=!COLUMN%1_%CARDVIS%_SUIT!
set DEST_VALUE=!COLUMN%1_%CARDVIS%_VALUE!

set /a YPR-=2
call playcard %XPR% %YPR% %SHADOW% 0 !DEST_VALUE! !DEST_SUIT!

goto :eof

:FAILMOVE
goto :eof


:CALC_SCORE
set SCORE=0
for /L %%a in (1,1,7) do set /a SCORE+=!COLUMNCOUNT%%a!
if %SCORE% geq 1 goto :eof
set /a NOFSTACK=%DECKTOE%-%DECKHEAD%+1
set /a SCORE-=%NOFSTACK%
goto :eof
