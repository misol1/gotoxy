@echo off
setlocal ENABLEDELAYEDEXPANSION
if "%~1" == "" gotoxy k k "Usage: writebig [text] [fontIndex] [xp] [yp] [col1] [x_edge] [y_edge] [col2|-1] [col3|-1] [bInsideShade] [char1] [char2]\n\\ for newline, ;/$ to increase/decrease x, {/} to increase/decrease y\n" v 0 csw&goto :eof
set fontIndex=3&if not "%2"=="" set /a fontIndex=%2&(if !fontIndex! lss 0 set fontIndex=3)&(if !fontIndex! gtr 9 set fontIndex=3)
call font!fontIndex!.bat
cmdwiz stringlen "%~1"&set /A SL=!ERRORLEVEL!
set XP=0&if not "%3"=="" set XP=%3
set YP=0&if not "%4"=="" set YP=%4
set COL1=9&if not "%5"=="" set COL1=%5
set EDGE=0&if not "%6"=="" set EDGE=%6
set EDGE2=0&if not "%7"=="" set EDGE2=%7
set COL2=-1&if not "%8"=="" set COL2=%8
set COL3=-1&if not "%9"=="" set COL3=%9
if not %COL3%==-1 set /A XP+=1&set /A YP+=1
set OX=%XP%
set /A CHARW+=%EDGE%
set /A CHARH+=%EDGE2%
set /A SPACEW=%CHARW%/2
set TEXT="%~1"
shift
set IS=0&if "%9"=="1" set IS=1
shift
set CHAR1=db
if not "%9"=="" set CHAR1=%9
shift
set CHAR2=b1
if not "%9"=="" set CHAR2=%9
for /L %%a in (1,1,%SL%) do call :PRINTLETTER %%a
set /A YP+=%CHARH%
shift
rem if "%9"=="" gotoxy 0 %YP%
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
set CC=!CC: #= \g%CHAR2%!
set CC=!CC:# =\g%CHAR2% !
set CC=!CC:#=\g%CHAR1%!
set SX=1&set SY=1&if not %COL3%==-1 set SX=2&set SY=2
if not %COL2%==-1 set /A XPT=%XP%+%SX%&set /A YPT=%YP%+%SY%&set OUT="%OUT:~1,-1%\%COL2%0\p!XPT!;!YPT!;\T20k01%CC:~1,-1%"
if not %COL3%==-1 for %%a in (1,-1,10,-10) do set /A XPT=%XP%+%%a%%10&set /A YPT=%YP%+%%a/10&&set OUT="!OUT:~1,-1!\%COL3%0\p!XPT!;!YPT!;\T20k01%CC:~1,-1%"
if %IS%==0 set CC=!CS%INDEX%!&set CC=!CC:#=\g%CHAR1%!
set OUT="!OUT:~1,-1!\%COL1%0\p!XP!;!YP!;\T20k01%CC:~1,-1%"
gotoxy !XP! !YP! %OUT% 0 0 r
if "!SCT!"==" " set /A XP+=%SPACEW% 
if not "!SCT!"==" " set /A XP+=%CHARW%
goto :eof
