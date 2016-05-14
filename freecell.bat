:: Freecell : Mikael Sollenborn 2015
@echo off
cmdwiz showcursor 0
color 07
cls
mode con lines=54 cols=81
setlocal ENABLEDELAYEDEXPANSION
set CNT=1
set YCNT=1
set XPOS=2
set YPOS=13
set SHADOW=0
set FLIP=12
call cardstack.bat shuffle

gotoxy 4 1 "1-8 selects/moves to column, S moves to stack, A to cell, A-D from cell." 3 0

set XTMP=3
for /L %%a in (1,1,4) do call playcard !XTMP! 4 0 1 1 1 & set /a XTMP+=9 

set XTMP=44
for /L %%a in (1,1,4) do call playcard !XTMP! 4 0 8 1 1 & set /a XTMP+=9 
set FLIP=0
set TEMPCNT=0

:OUTERLOOP
set ORGXPOS=%XPOS%

:DEALLOOP

call cardstack.bat deal

set COLUMN%CNT%_%YCNT%_SUIT=%CARDSUIT%
set COLUMN%CNT%_%YCNT%_VALUE=%CARDVALUE%

call playcard %XPOS% %YPOS% %SHADOW% %FLIP% %CARDVALUE% %CARDSUIT% 1

set /a XPOS+=10
set /a CNT+=1
set /a TEMPCNT+=1

if %TEMPCNT% geq 52 goto OUT

if %CNT% leq 8 goto DEALLOOP

:OUT
set /a YCNT+=1
set /a YPOS+=2

set XPOS=%ORGXPOS%
set CNT=1
set FLIP=0

if %YCNT% leq 7 goto OUTERLOOP

set CNT=7
for /L %%a in (1,1,4) do set COLUMNCOUNT%%a=7&set COLUMNVISIBLE%%a=6
for /L %%a in (5,1,8) do set COLUMNCOUNT%%a=6&set COLUMNVISIBLE%%a=5
for /L %%a in (9,1,12) do set COLUMNCOUNT%%a=0&set COLUMNVISIBLE%%a=0

set STASHCNT=1
set SELECTED=0

for /L %%a in (1,1,4) do set STACK%%aVALUE=0& set STACK%%aSUIT=%%a

rem For testing
goto GAMELOOP
set TEST=1
set COLUMN7_1_VALUE=3
set COLUMN7_1_SUIT=3


:GAMELOOP
cmdwiz getch
set KEY=%ERRORLEVEL%
if %KEY% == 27 goto GAME_ESCAPED

if %KEY% geq 49 if %KEY% leq 56 set /a KTMP=%KEY%-48& call :MARKSELECTED !KTMP!
if %KEY% == 115 if %SELECTED% geq 1 call :MOVETOSTACK %SELECTED%
if %KEY% == 83 if %SELECTED% geq 1 call :MOVETOSTACK %SELECTED%

if %SELECTED% == 0 if %KEY% geq 97 if %KEY% leq 100 set /a KTMP=%KEY%-97+9& call :MARKSELECTED !KTMP! &goto SKIP1
if %SELECTED% geq 9 if %KEY% geq 97 if %KEY% leq 100 set /a KTMP=%KEY%-97+9& call :MARKSELECTED !KTMP! &goto SKIP1
if %SELECTED% geq 1 if %SELECTED% leq 8 if %KEY% == 97 call :MOVETOCELLS %SELECTED%
:SKIP1

::if %KEY% geq 101 if %KEY% leq 112 set /a KTMP=%KEY%-100& call :PRINTCOLUMN !KTMP!

set GAMEOVER=1
rem All 8 columns have no "inbetween" cards and are in one series?
for /L %%a in (1,1,8) do set ISOK=0& call :CHECKVALIDROW 1 %%a&if !ISOK!==0 set GAMEOVER=0
rem Everything on stack?
rem for /L %%a in (1,1,4) do if !STACK%%aVALUE! lss 13 set GAMEOVER=0
if %GAMEOVER% == 1 goto GAMEOVER

goto GAMELOOP


:GAMEOVER
for /L %%a in (1,1,12) do set SELECTED=%%a&if !COLUMNCOUNT%%a! geq 1 call :MOVETOSTACK !SELECTED!
set GAMEOVER=1
for /L %%a in (1,1,4) do if !STACK%%aVALUE! lss 13 set GAMEOVER=0
if %GAMEOVER% == 0 goto GAMEOVER

:CLEANED
gotoxy 4 1 "       Congratulations - you beat Freecell. Now have a beer or two.        " 14 0
cmdwiz getch

:GAME_ESCAPED
gotoxy 1 50
call cardstack.bat clean
cmdwiz showcursor 1
endlocal
goto :eof



:MARKSELECTED
if !COLUMNCOUNT%1! leq 0 if %selected% == 0 goto :eof
set ORGSELECTED=%1
if %SELECTED% == 0 set SELECTED=%1& goto NEWSELECTED
if %SELECTED% == %1 set SELECTED=-%1& goto NEWSELECTED
goto MAKEMOVE
:NEWSELECTED
set /a TMPSELECT=%ORGSELECTED%-8
if %SELECTED% geq 1 if %ORGSELECTED% leq 8 set XPOS=-5& for /L %%a in (1,1,8) do set /a XPOS+=10& if %%a==%SELECTED% gotoxy !XPOS! 12 "^^" 10
if %SELECTED% geq 1 if %ORGSELECTED% geq 9 set XPOS=-3& for /L %%a in (1,1,4) do set /a XPOS+=9& if %%a==%TMPSELECT% gotoxy !XPOS! 3 "^^" 10

if %SELECTED% leq 0 if %ORGSELECTED% leq 8 set XPOS=-5& for /L %%a in (1,1,8) do set /a XPOS+=10& if -%%a==%SELECTED% gotoxy !XPOS! 12 " " 10
set /a TMPSELECT=-%TMPSELECT%
if %SELECTED% leq 0 if %ORGSELECTED% geq 9 set XPOS=-3& for /L %%a in (1,1,4) do set /a XPOS+=9& if -%%a==%TMPSELECT% gotoxy !XPOS! 3 " " 10
if %SELECTED% leq 0 set SELECTED=0
goto :eof


REM 1=spades 2=clubs 3=hearts 4=diamonds
:MAKEMOVE
if %1 geq 9 goto :eof
set /a CARDVIS=!COLUMNCOUNT%1!
set DEST_SUIT=!COLUMN%1_%CARDVIS%_SUIT!
set DEST_VALUE=!COLUMN%1_%CARDVIS%_VALUE!

set SRC_CHECKPOS=!COLUMNVISIBLE%SELECTED%!
:TRYLOOP
set /a CARDVIS=!COLUMNCOUNT%SELECTED%!-%SRC_CHECKPOS%
set SRC_SUIT=!COLUMN%SELECTED%_%CARDVIS%_SUIT!
set SRC_VALUE=!COLUMN%SELECTED%_%CARDVIS%_VALUE!

if !COLUMNCOUNT%1! leq 0 goto OKMOVE
set /a TTMP=%DEST_VALUE%-%SRC_VALUE%
if not %TTMP%==1 goto NEXTTRY
if %DEST_SUIT% leq 2 if %SRC_SUIT% leq 2 goto NEXTTRY
if %DEST_SUIT% geq 3 if %SRC_SUIT% geq 3 goto NEXTTRY
goto OKMOVE

:NEXTTRY
set /a SRC_CHECKPOS-=1
if %SRC_CHECKPOS% geq 0 goto TRYLOOP
goto FAILMOVE

:OKMOVE
set ISOK=0
set /a TTMP=!COLUMNCOUNT%SELECTED%!-%SRC_CHECKPOS%
call :CHECKVALIDROW %TTMP% %SELECTED%
if %ISOK% == 1 goto REALLYOK
set /a SRC_CHECKPOS-=1
if %SRC_CHECKPOS% geq 0 goto TRYLOOP
goto FAILMOVE

:REALLYOK
set NFREECELLS=0
set NFREECOLUMNS=0
for /L %%a in (9,1,12) do if !COLUMNCOUNT%%a! leq 0 set /a NFREECELLS+=1
for /L %%a in (1,1,8) do if !COLUMNCOUNT%%a! leq 0 set /a NFREECOLUMNS+=1
if !COLUMNCOUNT%1! leq 0 set /a NFREECOLUMNS-=1& if !NFREECOLUMNS! leq 0 set NFREECOLUMNS=0

:: calculate x^n
SET x=2
SET n=%NFREECOLUMNS%
SET result=1
FOR /L %%i IN (1,1,%n%) DO SET /A result*=x

:: Cards possible to move =(1 + number of empty freecells) * 2 ^ (number of empty columns)
:: Remove one freecolumn if moving cards INTO a free column
set /a RES=1+%NFREECELLS%
set /a RES*=%result%

set /a NEWONES=%SRC_CHECKPOS%+1
if %NEWONES% leq %RES% goto REALLYREALLYOK
set /a SRC_CHECKPOS-=1
if %SRC_CHECKPOS% geq 0 goto TRYLOOP
goto FAILMOVE

:REALLYREALLYOK
call :ADDTOCOLUMN %SELECTED% %1 %SRC_CHECKPOS%
if %SELECTED% geq 9 call :EMPTYCELL %SELECTED%
call :REMOVESELECTED
goto :eof

:FAILMOVE
goto :eof

:CHECKVALIDROW
set INDEX=%1
set OLD_SUIT=!COLUMN%2_%INDEX%_SUIT!
set OLD_VALUE=!COLUMN%2_%INDEX%_VALUE!

:VALIDLOOP
set /a INDEX+=1
if %INDEX% gtr !COLUMNCOUNT%2! set ISOK=1&goto :eof

set NEW_SUIT=!COLUMN%2_%INDEX%_SUIT!
set NEW_VALUE=!COLUMN%2_%INDEX%_VALUE!
set /a TTMP=%OLD_VALUE%-%NEW_VALUE%
if not %TTMP%==1 goto :eof
if %NEW_SUIT% leq 2 if %OLD_SUIT% leq 2 goto :eof
if %NEW_SUIT% geq 3 if %OLD_SUIT% geq 3 goto :eof

set OLD_SUIT=%NEW_SUIT%
set OLD_VALUE=%NEW_VALUE%
goto VALIDLOOP
goto :eof


:MOVETOSTACK
set TMP1=!COLUMNCOUNT%1!
set TMP2=!COLUMN%1_%TMP1%_SUIT!
set /a RES=!COLUMN%1_%TMP1%_VALUE! - !STACK%TMP2%VALUE!
if not %RES% == 1 goto :eof
set /a STACK%TMP2%VALUE+=1
set /a COLUMNCOUNT%1-=1
set /a COLUMNVISIBLE%1-=1
if !COLUMNVISIBLE%1! lss 0 set COLUMNVISIBLE%1=0
if %SELECTED% geq 9 call :EMPTYCELL %SELECTED%
call :REMOVESELECTED
call :SHOWSTACK !STACK%TMP2%VALUE! %TMP2%
set /a TA=!COLUMNCOUNT%1!
call :SHOWCOLUMN %1 1 %TA% 1 1
goto :eof
:SHOWSTACK
if %2==3 set XTMP=44
if %2==2 set XTMP=53
if %2==4 set XTMP=62
if %2==1 set XTMP=71
for /L %%a in (1,1,4) do if %%a == %2 call playcard !XTMP! 4 0 0 %1 %2
goto :eof


:MOVETOCELLS
set SELCOLUMN=0
for /L %%a in (12,-1,9) do if !COLUMNCOUNT%%a! == 0 set SELCOLUMN=%%a
if %SELCOLUMN% == 0 goto :eof
set TTMP=!COLUMNCOUNT%SELECTED%!
set COLUMN%SELCOLUMN%_1_VALUE=!COLUMN%SELECTED%_%TTMP%_VALUE!
set COLUMN%SELCOLUMN%_1_SUIT=!COLUMN%SELECTED%_%TTMP%_SUIT!
set /a COLUMNCOUNT%1-=1
set /a COLUMNVISIBLE%1-=1
set COLUMNCOUNT%SELCOLUMN%=1
set COLUMNVISIBLE%SELCOLUMN%=0
if !COLUMNVISIBLE%1! lss 0 set COLUMNVISIBLE%1=0
call :REMOVESELECTED
call :SHOWCELL %SELCOLUMN%
set /a TA=!COLUMNCOUNT%1!
call :SHOWCOLUMN %1 1 %TA% 1 1
goto :eof
:SHOWCELL
set /a TTMP=%1-9
set /a XTMP=3+9*%TTMP%
call playcard %XTMP% 4 0 0 !COLUMN%1_1_VALUE! !COLUMN%1_1_SUIT!
goto :eof
:EMPTYCELL
set /a TTMP=%1-9
set /a XTMP=3+9*%TTMP%
call playcard %XTMP% 4 0 1 1 1
goto :eof


:REMOVESELECTED
if %SELECTED% leq 8 set XPOS=-5&for /L %%a in (1,1,8) do set /a XPOS+=10& if %%a==%SELECTED% gotoxy !XPOS! 12 " " 10
set /a TMPSELECT=%SELECTED%-8
if %SELECTED% geq 9 set XPOS=-3&for /L %%a in (1,1,4) do set /a XPOS+=9& if %%a==%TMPSELECT% gotoxy !XPOS! 3 " " 10
set SELECTED=0
goto :eof


rem <src> <dest> <source visible index>
:ADDTOCOLUMN
set NOFMOVED=0
set /a NEWONES=%3+1
set /a TA=!COLUMNCOUNT%1!-%3
set /a TB=!COLUMNCOUNT%2!+1

for /L %%a in (1,1,%NEWONES%) do call :ADDONE %1 %2 !TA! !TB!&set /a TA+=1&set /a TB+=1&set /a NOFMOVED+=1
set /a COLUMNCOUNT%1-=%NOFMOVED%
set /a COLUMNVISIBLE%1-=%NOFMOVED%
if !COLUMNVISIBLE%1! lss 0 set COLUMNVISIBLE%1=0

set /a TB=!COLUMNCOUNT%2!+1
call :SHOWCOLUMN %2 %NOFMOVED% %TB% 0 %NOFMOVED%
set /a TA=!COLUMNCOUNT%1!
call :SHOWCOLUMN %1 1 %TA% 1 %NOFMOVED%

if !COLUMNCOUNT%2! == 0 set COLUMNVISIBLE%2=-1
set /a COLUMNCOUNT%2+=%NOFMOVED%
set /a COLUMNVISIBLE%2+=%NOFMOVED%
goto :eof

:ADDONE
set COLUMN%2_%4_SUIT=!COLUMN%1_%3_SUIT!
set COLUMN%2_%4_VALUE=!COLUMN%1_%3_VALUE!
goto :eof


rem <column> <nof new> <start index visible> <0 add/1 remove> <nof moved from/to>
:SHOWCOLUMN
set /a TTMP=%1-1
set /a XPOS=2+10*%TTMP%
set /a TTMP=!COLUMNCOUNT%1!-%4
set /a YPOS=13+2*%TTMP%
if !COLUMNCOUNT%1! leq 0 if %4==1 set /a YPOS+=2 & call playcard %XPOS% !YPOS! %SHADOW% -2 8 1 &goto SKIPPER
set TB=%3
for /L %%a in (1,1,%2) do call :SHOWACARD %1 !TB!& set /a TB+=1&set /a YPOS+=2
:SKIPPER
set /a YPOS=13+2*%TTMP%
if %4==1 for /L %%a in (1,1,%5) do set /a YPOS+=2& call playcard %XPOS% !YPOS! %SHADOW% -2 2 1
goto :eof
:SHOWACARD
call playcard %XPOS% %YPOS% %SHADOW% 0 !COLUMN%1_%2_VALUE! !COLUMN%1_%2_SUIT! 1
goto :eof



:PRINTCOLUMN
gotoxy 1 1
for /L %%a in (1,1,!COLUMNCOUNT%1!) do echo !COLUMN%1_%%a_VALUE! !COLUMN%1_%%a_SUIT!          .
echo NOF:!COLUMNCOUNT%1!
echo NOFVIS:!COLUMNVISIBLE%1!
goto :eof
