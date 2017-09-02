:: Hiscore : Mikael Sollenborn 2015
@echo off
if "%~1" == "" echo Error: No filename & goto :EOF
if "%~2" == "" echo Error: No operation & goto :EOF
set FNAME=%1
if "%~2" == "create" call :CREATE %3 %4 %5 & goto OPFIN
if "%~2" == "check" call :CHECK %3 & goto OPFIN
if "%~2" == "insert" call :INSERT %3 %4& goto OPFIN
if "%~2" == "retrieve" call :RETRIEVE & goto OPFIN
if "%~2" == "clean" call :CLEAN & goto OPFIN
echo Error: Unknown operation
:OPFIN
goto :CLEARUP

:CREATE
set DEFNAME="John Doe"
if NOT "%~1" == "" set DEFNAME="%~1"
set DEFSCORE=0
if NOT "%~2" == "" set DEFSCORE=%~2
set DEFNOFITEMS=10
if NOT "%~3" == "" set DEFNOFITEMS=%~3
if not exist %FNAME% for /L %%a in (1,1,%DEFNOFITEMS%) do call :ADDNAME %DEFNAME% %DEFSCORE%
set DEFNAME=&set DEFSCORE=&set DEFNOFITEMS=
goto :EOF

:CHECK
if "%1" == "" call :CLEARUP & exit /B 0
call :GETPOS %1
call :CLEARUP & exit /B %HIGHPOS%
goto :EOF

:INSERT
if "%2" == "" call :CLEARUP & exit /B 0
call :GETPOS %2
if %HIGHPOS% == 0 call :CLEARUP & exit /B 0
set /A CNT=%NOFITEMS%+1
for /L %%a in (%NOFITEMS%,-1,%HIGHPOS%) do set HI!CNT!=!HI%%a!& set HIN!CNT!=!HIN%%a!& set /A CNT=!CNT!-1
set HIN%HIGHPOS%=%~1
set HI%HIGHPOS%=%2
del /Q %FNAME%
for /L %%a in (1,1,%NOFITEMS%) do call :ADDNAME "!HIN%%a!" !HI%%a!
call :CLEARUP & exit /B %HIGHPOS%
goto :EOF

:RETRIEVE
set CNT=1
if exist %FNAME% for /F "tokens=1* delims=@" %%a in (%FNAME%) do set HIN!CNT!=%%b& set HI!CNT!=%%a& set /A CNT=!CNT!+1
set /A NOFITEMS=%CNT%-1
goto :EOF


:ADDNAME
echo %2@%~1>>%FNAME%
goto :EOF

:GETPOS
call :RETRIEVE
set HIGHPOS=0
for /L %%a in (%NOFITEMS%,-1,1) do call :CHECKPOS %1 !HI%%a! %%a
goto :EOF
:CHECKPOS
if %1 GTR %2 set HIGHPOS=%3
goto :EOF

:CLEAN
call :RETRIEVE
set /A NOFITEMS=%NOFITEMS%+1
for /L %%a in (1,1,%NOFITEMS%) do set HI%%a=&set HIN%%a=
goto :EOF

:CLEARUP
set FNAME=&set CNT=&set HIGHPOS=&set NOFITEMS=
