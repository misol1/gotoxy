@echo off
setlocal ENABLEDELAYEDEXPANSION
call hiscore.bat hiscore.dat create "Test Player" 5 12
cls
call hiscore.bat hiscore.dat retrieve
call :PRINTSCORES

:MYLOOP
set SCORE=& set /P SCORE="Your score? "
if "%SCORE%" == "" goto ENDIT

call hiscore.bat hiscore.dat check %SCORE%
if %ERRORLEVEL% == 0 goto MYLOOP

set NAME=& set /P NAME="You have a hiscore. Your name? "
if "%NAME%" == "" goto MYLOOP
call hiscore.bat hiscore.dat insert "%NAME%" %SCORE%

call :PRINTSCORES
goto MYLOOP

:ENDIT
call hiscore.bat hiscore.dat clean
endlocal
goto :EOF

:PRINTSCORES
echo.
for /L %%a in (1,1,12) do echo %%a. !HIN%%a! !HI%%a!
echo.
