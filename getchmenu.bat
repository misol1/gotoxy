:: GetchMenu : Mikael Sollenborn 2015
@echo off
setlocal
if "%2" == "" echo Usage: getchmenu menufile commandfile [X] [Y] [SELCOL] [SELBGCOL] [COL] [BGCOL] [SELECTEDITEM] [BNOCLS]
if "%2" == "" goto :eof
if not exist %1 echo Menu file does not exist!
if not exist %1 goto :eof
if not exist %2 echo Command file does not exist!
if not exist %2 goto :eof
set FMENU=%1
set FCMDS=%2
set XP=0
if not "%3" == "" set XP=%3
set YPS=0
if not "%4" == "" set YPS=%4
set SCFG=15
if not "%5" == "" set SCFG=%5
set SCBG=12
if not "%6" == "" set SCBG=%6
set /a TMP=%SCFG%*16+%SCBG%
call util dectohex SELCOLS %TMP% 0
set CFG=8
if not "%7" == "" set CFG=%7
set CBG=0
if not "%8" == "" set CBG=%8
set /a TMP=%CFG%*16+%CBG%
call util dectohex TCOLS %TMP% 0
set SEL=0
if not "%9" == "" set SEL=%9
set NOF=-1
for /F "delims=" %%a in (%FMENU%) do call :BSUB
shift
if "%9" == "" cls 
set FOUNDEXE=0

:KEYLOOP
set CNT=0
set YP=%YPS%
call :PRINTMENU %FMENU%
cmdwiz getch
if %ERRORLEVEL% == 27 goto CLEANUP
if %ERRORLEVEL% == 336 set /A SEL=%SEL%+1 & if %SEL% GEQ %NOF% set SEL=0
if %ERRORLEVEL% == 328 set /A SEL=%SEL%-1 & if %SEL% LSS 1 set SEL=%NOF%
if %ERRORLEVEL% == 13 goto EXECUTE
goto KEYLOOP
goto :eof

:PRINTMENU
set MENUDAT=""
for /F "delims=" %%a in (%1) do call :ASUB "%%a"
gotoxy.exe 0 0 %MENUDAT% 7 0
goto :eof

:EXECUTE
if "%9" == "" cls 
set CNT=0
for /F "delims=" %%a in (%FCMDS%) do call :CSUB "%%a"
goto EXIT
:CLEANUP
if "%9" == "" cls 
:EXIT
endlocal
goto :eof

:ASUB
set COLS=%TCOLS%
if %SEL%==%CNT% set COLS=%SELCOLS%
set /a CNT+=1
set MENUDAT="%MENUDAT:~1,-1%\%COLS%\p%XP%;%YP%%~1"
set /a YP+=2
goto :eof

:BSUB
set /a NOF+=1
goto :eof

:CSUB
set PRESEL=%SEL%
if %FOUNDEXE% == 1 goto :eof
if %SEL%==%CNT% %~1&set FOUNDEXE=1
set /a CNT+=1
goto :eof
