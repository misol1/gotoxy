:: GetchMenu : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
if "%2" == "" echo Usage: getchmenu menufile commandfile [X] [Y] [SELCOL] [SELBGCOL] [COL] [BGCOL] [SELECTEDITEM] [BNOCLS]&goto :eof
if not exist %1 echo Menu file does not exist!&goto :eof
if not exist %2 echo Command file does not exist!&goto :eof
set FMENU=%1
set FCMDS=%2
set XP=0& if not "%3" == "" set XP=%3
set YPS=0& if not "%4" == "" set YPS=%4
set SCFG=f& if not "%5" == "" set SCFG=%5
set SCBG=c& if not "%6" == "" set SCBG=%6
set SELCOLS=%SCFG%%SCBG%
set CFG=8& if not "%7" == "" set CFG=%7
set CBG=0& if not "%8" == "" set CBG=%8
set TCOLS=%CFG%%CBG%
set SEL=0& if not "%9" == "" set SEL=%9
set NOF=-1
for /F "delims=" %%a in (%FMENU%) do set /a NOF+=1&set IT!NOF!=%%a
shift & if "%9" == "" cls 
set FOUNDEXE=0
call :PREPCOL

:KEYLOOP
set YP=%YPS%
set MENUDAT=""
for /L %%a in (0,1,%NOF%) do set MENUDAT="!MENUDAT:~1,-1!\!COLS%%a!\p!XP!;!YP!!IT%%a!"&set /a YP+=2
gotoxy.exe 0 0 "%MENUDAT:~1,-1%\I" 7 0
if %ERRORLEVEL% == 27 goto CLEANUP
if %ERRORLEVEL% == 336 set /A SEL+=1 &call :PREPCOL & if %SEL% GEQ %NOF% set SEL=0&call :PREPCOL
if %ERRORLEVEL% == 328 set /A SEL-=1 &call :PREPCOL & if %SEL% LSS 1 set SEL=%NOF%&call :PREPCOL
if %ERRORLEVEL% == 13 goto EXECUTE
goto KEYLOOP
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

:PREPCOL
for /L %%a in (0,1,%NOF%) do set COLS%%a=%TCOLS%&if %SEL%==%%a set COLS%%a=%SELCOLS%
goto :eof

:CSUB
set PRESEL=%SEL%
if %FOUNDEXE% == 1 goto :eof
if %SEL%==%CNT% %~1&set FOUNDEXE=1
set /a CNT+=1
goto :eof
