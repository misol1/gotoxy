::Echo with color
@echo off
setlocal ENABLEDELAYEDEXPANSION
set TEXT=""&if not "%~1" == "" set TEXT="%~1"
set CC=i&if not "%~4" == "" set CC=
set CW=w
cmdwiz stringlen %TEXT%&if !ERRORLEVEL! geq 5 call :CHECKGXY
set FG=u&if not "%~2" == "" set FG=%2
set BG=U&if not "%~3" == "" set BG=%3
gotoxy k k %TEXT% %FG% %BG% cs%CW%%CC%
if not "%CW%"=="" echo.
endlocal
goto :eof
:CHECKGXY
if "%TEXT:~-5%==".gxy" set CC=&set CW=
