::Does not support all codes, i,e. \p, \w, \W, \o, \O, \T, \g
@echo off
if "%~1"=="" echo Usage: typewrite-code [message] [speed] [color] [xstart] [xend]&goto :eof
setlocal
set TWMSG=""
set OMSG=%~1
set WF=w
set SPEED=50&if not "%~2"=="" set SPEED=%~2
set COL=10&if not "%~3"=="" set COL=%~3
set XBEG=k&if not "%~4"=="" set XBEG=%~4&set WF=W
set XEND=&if not "%~5"=="" set XEND=%~5
cmdwiz stringlen "%OMSG%"
set /A SLEN=%ERRORLEVEL%-1
set CNT=0
set CODE=0&cmdwiz stringfind "%OMSG%" "\\"&if not !ERRORLEVEL!==-1 set CODE=1
if %CODE%==1 goto REP
for /L %%a in (0,1,%SLEN%) do set TWMSG="!TWMSG:~1,-1!!OMSG:~%%a,1!\w%SPEED%"
gotoxy %XBEG% k !TWMSG! %COL% 0 Cs%WF% %XEND%
endlocal
goto :eof
:REP
call :CODE %CNT%
set TWMSG="!TWMSG:~1,-1!%CH%\w%SPEED%"
set /A CNT+=1
if %CNT% leq %SLEN% goto REP
gotoxy %XBEG% k !TWMSG! %COL% 0 Cs%WF% %XEND%
endlocal
goto :eof

:CODE
set CH=!OMSG:~%CNT%,1!
if not "%CH%"=="\" goto :eof
set TWMSG="!TWMSG:~1,-1!\"
set /A CNT+=1
set CH=!OMSG:~%CNT%,1!
set NEXTOK=1
set CODEFOUND=0
set TWMSG="!TWMSG:~1,-1!%CH%"
for %%a in (r,N,n,-,R,\,G) do if "%CH%"=="%%a" call :NEXT
if %NEXTOK%==0 goto CODE
if %CODEFOUND%==1 goto :eof
call :NEXT
set TWMSG="!TWMSG:~1,-1!%CH%"
set NEXTOK=1
call :NEXT
if %NEXTOK%==0 goto CODE
goto :eof
:NEXT
set CODEFOUND=1
set /A CNT+=1
set CH=!OMSG:~%CNT%,1!
if "%CH%"=="\" set NEXTOK=0
goto :eof
