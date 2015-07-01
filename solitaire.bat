:: Solitaire : Mikael Sollenborn 2015
@echo off
cmdwiz showcursor 0
cls
mode con lines=54 cols=80
setlocal ENABLEDELAYEDEXPANSION
set CNT=1
set YCNT=1
set XPOS=4
set YPOS=14
set SHADOW=0
set FLIP=12
call cardstack.bat shuffle
set INITCNT=7
set DECKEND=0

set DECKFLIPS=0
set DECKADD=0
set DEALNOF=1
if "%1" == "limit" set DECKADD=1
if "%1" == "3card" set DEALNOF=3

gotoxy 4 1 "<SPACE> deals, <ENTER> selects, 1-7 selects/moves column, S move to stack." 3 0

call playcard %XPOS% 4 %SHADOW% 1 1 1
set XTMP=40
for /L %%a in (1,1,4) do call playcard !XTMP! 4 %SHADOW% 8 1 1 & set /a XTMP+=10 


:OUTERLOOP
set ORGXPOS=%XPOS%
set TEMPCNT=%INITCNT%

:DEALLOOP

call cardstack.bat deal

set FLIP=1
if %TEMPCNT% == 1 set FLIP=0

set COLUMN%CNT%_%YCNT%_SUIT=%CARDSUIT%
set COLUMN%CNT%_%YCNT%_VALUE=%CARDVALUE%

call playcard %XPOS% %YPOS% %SHADOW% %FLIP% %CARDVALUE% %CARDSUIT%

if %TEMPCNT% == 1 goto OUT

set /a XPOS+=11
set /a CNT+=1
set /a TEMPCNT-=1

if %CNT% leq 7 goto DEALLOOP

:OUT
set /a YCNT+=1
set /a YPOS+=2

set XPOS=%ORGXPOS%
set CNT=1
set FLIP=0

set /a INITCNT-=1

if %YCNT% leq 7 goto OUTERLOOP

set CNT=7
for /L %%a in (1,1,7) do set COLUMNCOUNT%%a=!CNT!& set COLUMNVISIBLE%%a=0& set /a CNT-=1 
set COLUMNCOUNT8=0& set COLUMNVISIBLE8=0

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
if %KEY% == 32 for /L %%a in (1,1,%DEALNOF%) do call :DEALCARD %%a
if %KEY% geq 49 if %KEY% leq 55 set /a KTMP=%KEY%-48& call :MARKSELECTED !KTMP!
if %KEY% == 13 call :MARKSELECTED 8
if %KEY% == 115 if %SELECTED% geq 1 call :MOVETOSTACK %SELECTED%
if %KEY% == 83 if %SELECTED% geq 1 call :MOVETOSTACK %SELECTED%
if %KEY% == 65 call :AUTOPLAY

::if %KEY% geq 97 if %KEY% leq 103 set /a KTMP=%KEY%-96& call :PRINTCOLUMN !KTMP!

set GAMEOVER=1
rem No unflipped left?
for /L %%a in (1,1,7) do set /A KTMP=!COLUMNVISIBLE%%a!+1 & if !KTMP! lss !COLUMNCOUNT%%a! set GAMEOVER=0
set /a KTMP=%COLUMNCOUNT8%+%DECKTOE%-%DECKHEAD%+1&if %DEALNOF% == 3 if !KTMP! geq 2 set GAMEOVER=0
rem Everything on stack?
rem for /L %%a in (1,1,4) do if !STACK%%aVALUE! lss 13 set GAMEOVER=0
if %GAMEOVER% == 1 goto GAMEOVER
if %DECKFLIPS% == 3 goto LASTKEY

goto GAMELOOP


:GAMEOVER
for /L %%a in (1,1,8) do set SELECTED=%%a&if !COLUMNCOUNT%%a! geq 1 call :MOVETOSTACK !SELECTED!
set GAMEOVER=1
for /L %%a in (1,1,4) do if !STACK%%aVALUE! lss 13 set GAMEOVER=0
call :DEALCARD 3
if %GAMEOVER% == 0 goto GAMEOVER

gotoxy 4 1 "      Congratulations - you beat Solitaire. Now have a beer or two.        " 14 0
:LASTKEY
cmdwiz getch

:GAME_ESCAPED
gotoxy 1 50
call cardstack.bat clean
cmdwiz showcursor 1
endlocal
goto :eof


:AUTOPLAY
cmdwiz getch nowait
if %ERRORLEVEL% == 27 goto ESCAPE_AUTO
for /L %%a in (1,1,8) do set SELECTED=%%a&if !COLUMNCOUNT%%a! geq 1 call :MOVETOSTACK !SELECTED!
for /L %%a in (1,1,8) do set MADEMOVE%%a=0
for /L %%a in (1,1,8) do call :REMOVESELECTED&if !MADEMOVE%%a!==0 call :MARKSELECTED %%a&for /L %%b in (1,1,7) do if not %%a==%%b call :MARKSELECTED %%b&if !SELECTED!==0 call :MARKSELECTED %%a&set MADEMOVE%%b=1
set GAMEOVER=1
for /L %%a in (1,1,7) do set /A ATMP=!COLUMNVISIBLE%%a!+1 & if !ATMP! lss !COLUMNCOUNT%%a! set GAMEOVER=0
set /a ATMP=%COLUMNCOUNT8%+%DECKTOE%-%DECKHEAD%+1&if %DEALNOF% == 3 if !ATMP! geq 2 set GAMEOVER=0
for /L %%a in (1,1,%DEALNOF%) do call :DEALCARD %%a
if %DECKFLIPS% == 3 goto ESCAPE_AUTO
if %GAMEOVER% == 0 goto AUTOPLAY
:ESCAPE_AUTO
call :REMOVESELECTED
goto :eof


:DEALCARD
call :REMOVESELECTED
if %DECKEND% == 1 goto :eof

if %DECKHEAD% leq %DECKTOE% goto GETCARD
set /a STASHCNT-=1
set COLUMNCOUNT8=0
for /L %%a in (1,1,%STASHCNT%) do call cardstack.bat pushbottom !STASHV%%a! !STASHS%%a!
if %STASHCNT% leq 0 set DECKEND=1
set /a DECKFLIPS+=%DECKADD%
if %DECKFLIPS% == 3 gotoxy 4 1 "     Sorry mate - only 3 deck flipovers allowed. Have a beer instead.      " 12 0&goto :eof
if %DECKEND% == 1 goto :eof
call playcard 4 4 0 1 1 1
set STASHCNT=1

:GETCARD
call cardstack.bat deal
::if %TEST% leq 4 set CARDVALUE=1&set CARDSUIT=%TEST%& set /a TEST+=1
if %1 geq %DEALNOF% call playcard 14 4 %SHADOW% 0 !CARDVALUE! !CARDSUIT!
set STASHV%STASHCNT%=!CARDVALUE!
set STASHS%STASHCNT%=!CARDSUIT!
set /a STASHCNT+=1
set /a COLUMNCOUNT8+=1
set COLUMN8_%COLUMNCOUNT8%_VALUE=!CARDVALUE!
set COLUMN8_%COLUMNCOUNT8%_SUIT=!CARDSUIT!

if %DECKHEAD% gtr %DECKTOE% call playcard 4 4 %SHADOW% -1 7
goto :eof

:REMOVE_DECKCARD
set /a STASHCNT-=2
if %STASHCNT% leq 0 call playcard 14 4 %SHADOW% -1 7 & goto OUTOFCARDS
call playcard 14 4 %SHADOW% 0 !STASHV%STASHCNT%! !STASHS%STASHCNT%!
:OUTOFCARDS
set /a STASHCNT+=1
goto :eof


:MARKSELECTED
if !COLUMNCOUNT%1! leq 0 if %selected% == 0 goto :eof
if %SELECTED% == 0 set SELECTED=%1& goto NEWSELECTED
if %SELECTED% == %1 set SELECTED=-%1& goto NEWSELECTED
goto MAKEMOVE
:NEWSELECTED
set XPOS=-4
for /L %%a in (1,1,7) do set /a XPOS+=11& if %%a==%SELECTED% gotoxy !XPOS! 13 "^^" 10
if %SELECTED%==8 gotoxy 17 3 "^" 10
set XPOS=-4
for /L %%a in (1,1,7) do set /a XPOS+=11& if -%%a==%SELECTED% gotoxy !XPOS! 13 " " 10
if %SELECTED%==-8 gotoxy 17 3 " " 10
if %SELECTED% leq 0 set SELECTED=0
goto :eof


REM 1=spades 2=clubs 3=hearts 4=diamonds
:MAKEMOVE
if %1==8 goto :eof
set /a CARDVIS=!COLUMNCOUNT%1!
set DEST_SUIT=!COLUMN%1_%CARDVIS%_SUIT!
set DEST_VALUE=!COLUMN%1_%CARDVIS%_VALUE!

set SRC_CHECKPOS=!COLUMNVISIBLE%SELECTED%!
:TRYLOOP
set /a CARDVIS=!COLUMNCOUNT%SELECTED%!-%SRC_CHECKPOS%
set SRC_SUIT=!COLUMN%SELECTED%_%CARDVIS%_SUIT!
set SRC_VALUE=!COLUMN%SELECTED%_%CARDVIS%_VALUE!

if !COLUMNCOUNT%1! leq 0 if %SRC_VALUE% == 13 goto OKMOVE
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
call :ADDTOCOLUMN %SELECTED% %1 %SRC_CHECKPOS%
if %SELECTED% == 8 call :REMOVE_DECKCARD
call :REMOVESELECTED
goto :eof

:FAILMOVE
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
if %SELECTED% == 8 call :REMOVE_DECKCARD
call :REMOVESELECTED
call :SHOWSTACK !STACK%TMP2%VALUE! %TMP2%
set /a TA=!COLUMNCOUNT%1!
call :SHOWCOLUMN %1 1 %TA% 1 1
goto :eof
:SHOWSTACK
if %2==3 set XTMP=40
if %2==2 set XTMP=50
if %2==4 set XTMP=60
if %2==1 set XTMP=70
for /L %%a in (1,1,4) do if %%a == %2 call playcard !XTMP! 4 %SHADOW% 0 %1 %2 
goto :eof


:REMOVESELECTED
if %SELECTED%==0 goto :eof
set XPOS=-4
for /L %%a in (1,1,7) do set /a XPOS+=11& if %%a==%SELECTED% gotoxy !XPOS! 13 " " 10
if %SELECTED%==8 gotoxy 17 3 " " 10
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


rem <column> <nof new> <start index visible> <0 add/1+ remove> <nof moved from/to>
:SHOWCOLUMN
set /a SCTMP=%1-1
set /a XPOS=4+11*%SCTMP%
set /a SCTMP=!COLUMNCOUNT%1!-%4
set /a YPOS=14+2*%SCTMP%
if !COLUMNCOUNT%1! leq 0 if %4 == 1 set /a YPOS+=2 & call playcard %XPOS% !YPOS! %SHADOW% -2 8 1 &goto SKIPPER
set TB=%3
for /L %%a in (1,1,%2) do call :SHOWACARD %1 !TB!& set /a TB+=1&set /a YPOS+=2
:SKIPPER
set /a YPOS=14+2*%SCTMP%
if %4 == 1 for /L %%a in (1,1,%5) do set /a YPOS+=2& call playcard %XPOS% !YPOS! %SHADOW% -2 2 1
goto :eof
:SHOWACARD
call playcard %XPOS% %YPOS% %SHADOW% 0 !COLUMN%1_%2_VALUE! !COLUMN%1_%2_SUIT!
goto :eof


:PRINTCOLUMN
gotoxy 0 1
for /L %%a in (1,1,!COLUMNCOUNT%1!) do echo !COLUMN%1_%%a_VALUE! !COLUMN%1_%%a_SUIT! 
echo NOF:!COLUMNCOUNT%1!
echo NOFVIS:!COLUMNVISIBLE%1!
goto :eof
