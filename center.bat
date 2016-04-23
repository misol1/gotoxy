::Does not support all codes, i,e. \p, \w, \W, \o, \O, \T, \g
::Does not handle special chars like &,<,> etc 
@echo off
if "%~1"=="" echo Usage: center [message] [col] [ypos] [xpos] [xendpos]&goto :eof
setlocal
set DMSG=%~1
set DMSG=%DMSG:\n=# %
echo %DMSG%>tmplines.dat
set COL=u&if not "%~2"=="" set COL=%~2
for /F "eol=; tokens=1,2,3,4,5,6,7,8,9 delims=#" %%i in (tmplines.dat) do call :PRINTER "%%~i" %COL% %3 %4 %5 %6&if not "%%~j"=="" call :PRINTER "\n%%~j" %COL% k %4 %5 %6&if not "%%~k"=="" call :PRINTER "\n%%~k" %COL% k %4 %5 %6&if not "%%~l"=="" call :PRINTER "\n%%~l" %COL% k %4 %5 %6&if not "%%~m"=="" call :PRINTER "\n%%~m" %COL% k %4 %5 %6&if not "%%~n"=="" call :PRINTER "\n%%~n" %COL% k %4 %5 %6&if not "%%~o"=="" call :PRINTER "\n%%~o" %COL% k %4 %5 %6&if not "%%~p"=="" call :PRINTER "\n%%~p" %COL% k %4 %5 %6&if not "%%~q"=="" call :PRINTER "\n%%~q" %COL% k %4 %5 %6
del /Q tmplines.dat
endlocal
goto :eof

:PRINTER
set OMSG=%~1
set CODE=0&cmdwiz stringfind "%OMSG%" "\\"&if not !ERRORLEVEL!==-1 set CODE=1
set COL=u&if not "%~2"=="" set COL=%~2
set YPOS=k&if not "%~3"=="" set YPOS=%~3
set XBEG=0&if not "%~4"=="" set XBEG=%~4
cmdwiz stringlen "%OMSG%"
set /A SLEN=%ERRORLEVEL%-1
set CNT=0
set RLEN=0
cmdwiz getconsoledim x&set CW=!ERRORLEVEL!
if not "%~5"=="" set CW=%~5
if not %CODE%==1 set RLEN=%SLEN%&goto OUTOF
for /L %%a in (0,1,%SLEN%) do set /A RLEN+=1&if "!OMSG:~%%a,1!"=="\" set /A RLEN-=3&set /A TM=%%a+1&for %%c in (!TM!) do for %%b in (r,N,n,-,R,\,G) do if "!OMSG:~%%c,1!"=="%%b" set /A RLEN+=1
:OUTOF
set /A CW=%CW%-%XBEG%
set /A XB=%CW%/2-%RLEN%/2+%XBEG%
gotoxy %XB% %YPOS% "!OMSG!" %COL% 0 cs