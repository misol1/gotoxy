:: Mastermind : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
cls
mode con lines=50
cmdwiz showcursor 0
gotoxy 33 1 " MASTERMIND " 11 1
for /L %%a in (1,1,10) do call :PRINTROW %%a xxxxxx 8

set TURN=1
for /L %%a in (1,1,6) do set /A COLUMN=1+%%a*2 & set /A COLOR=8+%%a & gotoxy !COLUMN! 3 %%a 0 !COLOR!
call :CREATEANSWER

:GAMELOOP

gotoxy 3 5
cmdwiz showcursor 1
set INPUT=&set /P INPUT="Input: "
cmdwiz showcursor 0
if "%INPUT%" == "" goto EXIT
gotoxy 9 5 "                   "

set ISOK=1
set INPUTTMP=%INPUT%xxxxxxx
for /L %%a in (0,1,5) do call :CHECKDIGIT !INPUTTMP:~%%a,1!
if %ISOK% == 0 goto :GAMELOOP

call :PRINTROW %TURN% %INPUT% 8

call :EVALUATE
call :PRINTEVALUATION %TURN%
if %CORRECTPOS% == 6 goto ENDGAME

set /A TURN+=1
if %TURN% == 11 goto ENDGAME
goto GAMELOOP


:ENDGAME
if %CORRECTPOS% == 6 gotoxy 3 3 "Congratulations^!^!^!" 15
if not %CORRECTPOS% == 6 gotoxy 3 3 "You have failed..." 15

:EXIT
gotoxy 3 5 "Press a key...           " 7
call :PRINTROW 11 %ANSWER% 0
cmdwiz getch
cmdwiz showcursor 1
endlocal
goto:eof


:PRINTROW
set /A ROW=%1*2 + 1
gotoxy 30 %ROW% "                  " 0 %3
set ROWDATA=%2
for /L %%a in (0,1,5) do call :PUTDOT !ROWDATA:~%%a,1! %%a
goto:eof

:PUTDOT
set /A COLUMN=31 + %2*3
if not "%1" == "x" set /A COLOR=8+%1 & gotoxy %COLUMN% %ROW% %1 0 !COLOR!
goto:eof


:CHECKDIGIT
set OK=0
for /L %%a in (1,1,6) do if %%a == %1 set OK=1
if %OK% == 0 set ISOK=0
goto:eof


:CREATEANSWER
set ANSWER=
for /L %%a in (1,1,6) do set /A DIGIT=!RANDOM! %% 6 + 1 & set ANSWER=!ANSWER!!DIGIT!
goto :eof


:EVALUATE
set CORRECTPOS=0
set CORRECTCOL=0
set MODANSWER=
set MODINPUT=
for /L %%a in (0,1,5) do call :POSCOMPAREDIGIT !ANSWER:~%%a,1! !INPUT:~%%a,1!
for /L %%a in (0,1,5) do set INP=!MODINPUT:~%%a,1!& for /L %%b in (0,1,5) do call :COLCOMPAREDIGIT !MODANSWER:~%%b,1! !INP! %%b
goto :eof

:POSCOMPAREDIGIT
if not %1 == %2 set MODANSWER=%MODANSWER%%1& set MODINPUT=%MODINPUT%%2& goto :eof
set /A CORRECTPOS+=1
set MODANSWER=%MODANSWER%-
set MODINPUT=%MODINPUT%-
goto :eof

:COLCOMPAREDIGIT
if "%1" == "-" goto :eof
if "%2" == "-" goto :eof
if not %1 == %2 goto :eof
set /A CORRECTCOL+=1
set /A CUT2=%3+1
set PART1=!MODANSWER:~0,%3!
set PART2=!MODANSWER:~%CUT2%!
set MODANSWER=%PART1%-%PART2%
set INP=-
goto :eof


:PRINTEVALUATION
set COLUMN=76
set /A ROW=%1*2 + 1
for /L %%a in (1,1,%CORRECTCOL%) do gotoxy !COLUMN! %ROW% " " 0 15 & set /A COLUMN=!COLUMN! - 2
for /L %%a in (1,1,%CORRECTPOS%) do gotoxy !COLUMN! %ROW% " " 0 8 & set /A COLUMN=!COLUMN! - 2
goto :eof
