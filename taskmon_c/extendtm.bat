:: Used in this file: F f t T ^T C P

@echo off
if "%~1" == "_GET_EXTENDED_HELP" goto GETHELP
if "%~1" == "_SET_COLORS" goto SETCOLORS
if "%~1" == "_SET_VIEWERS" goto SETVIEWERS

if %LKEY% == "F" call :GET_TARGET !FO%CURRPOS%! 2 & nircmdc.exe win activate process /!TARGET! & exit /b 0

:: ^T
if %KEY% == 20 call :GETANSWER "Transparency [1-255]:" & (if "!ANSWER!"=="" exit /b 0) & set /a NUMA="!ANSWER!" & (if !NUMA! geq 1 if !NUMA! leq 255 call :GET_TARGET !FO%CURRPOS%! 2 & nircmdc.exe win activate process /!TARGET! & nircmdc.exe win trans process /!TARGET! !NUMA! ) & exit /b 0

if %LKEY% == "t" call :GET_TARGET !FO%CURRPOS%! 2 & nircmdc.exe win settopmost process /!TARGET! 0 & exit /b 0
if %LKEY% == "T" call :GET_TARGET !FO%CURRPOS%! 2 & nircmdc.exe win settopmost process /!TARGET! 1 & exit /b 0

if %LKEY% == "C" call :GETANSWER "Window title:" & (if "!ANSWER!"=="" exit /b 0) & call :GET_TARGET !FO%CURRPOS%! 2 & nircmdc.exe win activate process /!TARGET! & nircmdc.exe win settext process /!TARGET! "!ANSWER!" & exit /b 0

::set PSHELLPATH=%SystemRoot%\system32\WindowsPowerShell\v1.0\
set PSHELLPATH=
if %LKEY% == "f" set TARGET=&call :GET_TARGET !FO%CURRPOS%! 1 & set TARGET2=!TARGET:.exe=!& %PSHELLPATH%powershell.exe Get-Process !TARGET2! ^| Format-List Path | find "!TARGET2!">%MYTEMP%out.dat & set /p EXEPATH=<%MYTEMP%out.dat&set EXEPATH=!EXEPATH:~7!&(for %%a in (!TARGET!) do set EXEPATH=!EXEPATH:%%a=!& start "" "!EXEPATH!" )& exit /b 0

if %LKEY% == "P" call :GETANSWER "Priority [normal, low, belownormal, abovenormal, high, realtime]:" & (if "!ANSWER!"=="" exit /b 0) & call :GET_TARGET !FO%CURRPOS%! 2 & nircmdc.exe setprocesspriority /!TARGET! !ANSWER! & exit /b 0

exit /b -1
goto :eof


:GETANSWER
start "Input" /WAIT taskmon.bat _GETANSWER "%~1" %COLS%>nul 2>nul <nul 2<nul
set ANSWER=
if exist %MYTEMP%answer.dat set /p ANSWER=<%MYTEMP%answer.dat
goto :eof


:GET_TARGET
for /f "tokens=%2" %%a in (%1) do set TARGET=%%a
goto :eof


:GETHELP
set EXTHLPC1=%HLPC1%
set EXTHLPC2=%HLPC2%
set EXTHELPTEXT="\n\n%EXTHLPC1%F: %EXTHLPC2%activate window\n%EXTHLPC1%t/T: %EXTHLPC2%disable/enable window as top-most\n%EXTHLPC1%^T: %EXTHLPC2%set transparency of window\n%EXTHLPC1%C: %EXTHLPC2%set title of window\n%EXTHLPC1%f: %EXTHLPC2%open start folder of executable (not for Services)\n%EXTHLPC1%P: %EXTHLPC2%set task priority\n"
goto :eof


:SETCOLORS
set CURRCOL=1\F1
::set BARCOL=4
::set BARTEXTCOL=F
::set BARINFOCOL=0
::set CURRCOL=C\FC
::set FILECOL=7
::set SCRBGCOL=2
::set DIRCOL=C
::set SELCOL=E
::set PATHNOFCOL=E
::set SELCHAR=\g07
::set HLPC1=\C0
::set HLPC2=\70
::set SEPBARCOL=7
goto :eof


:SETVIEWERS
::set VIEWCMD=less -f
::set NEWCMDWINDOW=start dosgo.bat
goto :eof
