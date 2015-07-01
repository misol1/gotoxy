:: Yatzy : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=50
cls
cmdwiz showcursor 0
call hiscore.bat yatzyscore.dat create "HighRoller" 100
for /L %%a in (1,1,18) do set RESULT%%a=0
for /L %%a in (1,1,15) do set USED%%a=1
for /L %%a in (16,1,18) do set USED%%a=9
set USEDCOLOR=9
call :PRINTSCORE


:THEBIGLOOP
for /L %%a in (1,1,5) do set sel%%a=0

set TRIES=3
:REP
for /L %%a in (1,1,5) do call :DICEROLL %%a
rem set RES1=2&set RES2=2&set RES3=2&set RES4=2&set RES5=2
rem goto out

set /A TRIES=%TRIES%-1
if %TRIES% == 0 goto OUT

for /L %%a in (1,1,5) do set sel%%a=1
gotoxy 10 18
cmdwiz showcursor 1
set /P saved="Reroll(1..5): "
cmdwiz showcursor 0
gotoxy 23 18 "                   "

for /L %%a in (1,1,10) do call :SELROLL %%a

set REROLL=0
for /L %%a in (1,1,5) do if !sel%%a!==0 set REROLL=1
if %REROLL%==0 goto OUT

goto REP

:OUT
gotoxy 1 18 "                                                         "
call :PRINTSCORE

:KEYLOOP
cmdwiz getch
set KEY=%ERRORLEVEL%
if %KEY% == 27 cmdwiz showcursor 1 & goto :eof
if %KEY% geq 49 if %KEY% leq 54 set /A CHOICE=1+%KEY%-49& goto MADECHOICE
if %KEY% geq 97 if %KEY% leq 105 set /A CHOICE=7+%KEY%-97& goto MADECHOICE
if %KEY% geq 65 if %KEY% leq 73 set /A CHOICE=7+%KEY%-65& goto MADECHOICE
goto KEYLOOP

:MADECHOICE
if !USED%CHOICE%! == %USEDCOLOR% goto KEYLOOP

if %CHOICE% leq 6 for /L %%a in (1,1,5) do if %CHOICE% == !RES%%a! set /A RESULT%CHOICE%+=!RES%%a!
if %CHOICE% == 7 call :CHECKPOINTS 2 %CHOICE%
if %CHOICE% == 8 call :CHECKPOINTS 22 %CHOICE%
if %CHOICE% == 9 call :CHECKPOINTS 3 %CHOICE%
if %CHOICE% == 10 call :CHECKPOINTS 4 %CHOICE%
if %CHOICE% == 11 call :CHECKPOINTS 11111 %CHOICE% 15
if %CHOICE% == 12 call :CHECKPOINTS 11111 %CHOICE% 20
if %CHOICE% == 13 call :CHECKPOINTS 32 %CHOICE%
if %CHOICE% == 14 for /L %%a in (1,1,5) do set /A RESULT%CHOICE%+=!RES%%a!
if %CHOICE% == 15 call :CHECKPOINTS 5 %CHOICE% & if not !RESULT15! == 0 set RESULT15=50 

set USED%CHOICE%=%USEDCOLOR%

call :GETSUMS
call :PRINTSCORE

set EXIT=1
for /L %%a in (1,1,15) do if not !USED%%a! == %USEDCOLOR% set EXIT=0
if %EXIT% == 1 goto GAMEOVER

goto THEBIGLOOP


:GAMEOVER

set SCORE=%RESULT18%
call hiscore.bat yatzyscore.dat check %SCORE%
if %ERRORLEVEL% == 0 goto NOHI

cmdwiz showcursor 1
gotoxy 10 18 "New Hiscore. Your Name: " 11 0 c
set /P NEWNAME=""
if "%NEWNAME%" == "" goto NOHI

call hiscore.bat yatzyscore.dat insert "%NEWNAME%" %SCORE%
set NEWPOS=%ERRORLEVEL%
set LINE=20
for /L %%a in (1,1,10) do gotoxy 10 !LINE! "%%a. !HIN%%a!" 14 & set /A LINE=!LINE!+1
set /A HIYPOS=%NEWPOS%+19
gotoxy 10 %HIYPOS% "%NEWPOS%. !HIN%NEWPOS%!" 15
set LINE=20
for /L %%a in (1,1,10) do gotoxy 35 !LINE! "!HI%%a!" 15 & set /A LINE=!LINE!+1
echo.
cmdwiz getch

:NOHI
call hiscore.bat yatzyscore.dat clean
cmdwiz showcursor 1

endlocal
goto :eof
echo on



:SELROLL
if "%saved%" == "" goto :eof
set SRTMP=%saved:~-1%
if "%SRTMP%" == "" goto :eof
set saved=%saved:~0,-1%
set sel%SRTMP%=0
goto :eof


:DICEROLL
set YPOS=2
set /A XPOS=6+%1*10
if !sel%1!==1 goto :eof
call rolldice %XPOS% %YPOS% 2 7
set RES%1=%ERRORLEVEL%
goto :eof


:GETSUMS
set RESULT16=0
set RESULT17=0
set RESULT18=0
for /L %%a in (1,1,6) do set /A RESULT16=!RESULT16!+!RESULT%%a!
if %RESULT16% geq 63 set RESULT17=50
for /L %%a in (1,1,17) do set /A RESULT18=!RESULT18!+!RESULT%%a!
set /A RESULT18=%RESULT18%-%RESULT16%
goto :eof


:PRINTSCORE
gotoxy 10 11 "1. Ones:" 
gotoxy 10 12 "2. Twos:" 
gotoxy 10 13 "3. Threes:" 
gotoxy 10 14 "4. Fours:" 
gotoxy 10 15 "5. Fives:" 
gotoxy 10 16 "6. Sixes:" 
set ROW=11
for /L %%a in (1,1,6) do gotoxy 21 !ROW! !RESULT%%a! !USED%%a! & set /A ROW=!ROW!+1

gotoxy 28 11 "A. One pair:" 
gotoxy 28 12 "B. Two pair:" 
gotoxy 28 13 "C. 3 of a kind:" 
gotoxy 28 14 "D. 4 of a kind:" 
gotoxy 28 15 "E. Straight I:" 
gotoxy 28 16 "F. Straight II:" 
set ROW=11
for /L %%a in (7,1,12) do gotoxy 44 !ROW! !RESULT%%a! !USED%%a! & set /A ROW=!ROW!+1

gotoxy 51 11 "G. Full house:" 
gotoxy 51 12 "H. Chance:"
gotoxy 51 13 "I. Yatzy:" 
gotoxy 51 14 "First sum:" 2 
gotoxy 51 15 "Bonus:" 3
gotoxy 51 16 "SUM:" 5
set ROW=11
for /L %%a in (13,1,18) do gotoxy 66 !ROW! !RESULT%%a! !USED%%a! & set /A ROW=!ROW!+1

gotoxy 10 18
goto :eof


:CHECKPOINTS
set MYSUM=0
set INP=%1
for /L %%a in (0,1,5) do call :PCHECK %2 !INP:~%%a,1!
if not "%3" == "" if not "%3" == "%MYSUM%" set RESULT%2=0
goto :eof

:PCHECK
if "%2" == "" set RESULT%1=%MYSUM%& goto :eof
if "%2" == "X" set RESULT%1=%MYSUM%& goto :eof
call :CHECKSCORE %2
if %SUM% == 0 set INP=XXXXXX& set MYSUM=0& goto :eof
set /a MYSUM+=%SUM%
goto :eof

:CHECKSCORE
set SUM=0

for /L %%a in (1,1,6) do set DSUM%%a=0
for /L %%a in (1,1,5) do set /a DSUM!RES%%a!+=1
set FOUND=0 & for /L %%a in (6,-1,1) do if !DSUM%%a! geq %1 if %%a geq !FOUND! set FOUND=%%a

if %FOUND% == 0 goto :eof

for /L %%a in (1,1,5) do if !RES%%a! == %FOUND% set RES%%a=0
set SUM=%FOUND%*%1
goto :eof
