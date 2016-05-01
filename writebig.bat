@echo off
setlocal ENABLEDELAYEDEXPANSION
if "%~1" == "" gotoxy k k "Usage: writebig [text] [xp] [yp] [col1] [x_edge] [y_edge] [col2|-1] [col3|-1] [bInsideShade]\n\\ for newline, ;/$ to increase/decrease x, {/} to increase/decrease y\n" v 0 csw&goto :eof
call font3.bat
cmdwiz stringlen "%~1"&set /A SL=!ERRORLEVEL!
set XP=0&if not "%2"=="" set XP=%2
set YP=0&if not "%3"=="" set YP=%3
set COL1=9&if not "%4"=="" set COL1=%4
set EDGE=0&if not "%5"=="" set EDGE=%5
set EDGE2=0&if not "%6"=="" set EDGE2=%6
set COL2=-1&if not "%7"=="" set COL2=%7
set COL3=-1&if not "%8"=="" set COL3=%8
set IS=0&if "%9"=="1" set IS=1
if not %COL3%==-1 set /A XP+=1&set /A YP+=1
set OX=%XP%
set /A CHARW+=%EDGE%
set /A CHARH+=%EDGE2%
set /A SPACEW=%CHARW%/2
set TEXT="%~1"
for /L %%a in (1,1,%SL%) do call :PRINTLETTER %%a
set /A YP+=%CHARH%
shift
if "%9"=="" gotoxy 0 %YP%
::gotoxy 0 100&gotoxy 0 /1
endlocal
goto :eof

:PRINTLETTER
set OUT=""
set SCT=!TEXT:~%1,1!
if "%SCT%"=="\" set XP=%OX%&set /A YP+=%CHARH%&goto :eof
if "%SCT%"==";" set /A XP+=1&goto :eof
if "%SCT%"=="$" set /A XP-=1&goto :eof
if "%SCT%"=="{" set /A YP+=1&goto :eof
if "%SCT%"=="}" set /A YP-=1&goto :eof
for /L %%b in (1,1,%NOFCHARS%) do set CST=!CHARSET:~%%b,1!&if "!SCT!"=="!CST!" set /a INDEX=%%b-1
set CC=!CS%INDEX%!
set CC=%CC: #= \gb1%
set CC=%CC:# =\gb1 %
set CC=%CC:#=\gdb%
set SX=1&set SY=1&if not %COL3%==-1 set SX=2&set SY=2
if not %COL2%==-1 set /A XPT=%XP%+%SX%&set /A YPT=%YP%+%SY%&set OUT="%OUT:~1,-1%\%COL2%0\p!XPT!;!YPT!;\T20k0%CC:~1,-1%"
if not %COL3%==-1 for %%a in (1,-1,10,-10) do set /A XPT=%XP%+%%a%%10&set /A YPT=%YP%+%%a/10&&set OUT="!OUT:~1,-1!\%COL3%0\p!XPT!;!YPT!;\T20k0%CC:~1,-1%"
if %IS%==0 set CC=!CS%INDEX%!&set CC=!CC:#=\gdb!
set OUT="!OUT:~1,-1!\%COL1%0\p!XP!;!YP!;\T20k0%CC:~1,-1%"
gotoxy !XP! !YP! %OUT% 0 0 r
if "!SCT!"==" " set /A XP+=%SPACEW% 
if not "!SCT!"==" " set /A XP+=%CHARW%
goto :eof
