:: Menu : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=50 cols=80
color 07
cls
if "%PRESEL%" == "" set PRESEL=0
set FRAMECOL=1&set SELBGCOL=9&set UNSELFGCOL=3&set FRAMETEXTCOL=7&set SHADOWCOL=8&set SELFGCOL=f&set UNSELBGCOL=0
if "%1"=="1" set FRAMECOL=c&set SELBGCOL=9&set UNSELFGCOL=7&set FRAMETEXTCOL=e&set SHADOWCOL=8&set SELFGCOL=f&set UNSELBGCOL=1
if not "%6" == "" set PRESEL=0

if "%3" == "" echo Usage: menu colorset menufile cmdfile [menulabel] [width] [preselected index]&goto :eof
set MENUTEXT=%2
set MENUCMDS=%3
set MENULABEL=""& if not "%~4" == "" set MENULABEL="%~4"
set WIDTH=42& if not "%5" == "" set WIDTH=%5
cmdwiz showcursor 0

set COUNT=0&for /F %%a in (%MENUTEXT%) do set /a COUNT+=1
set /a YPOS=50/2-%COUNT%-3
set /a XPOS=80/2-%WIDTH%/2+1
set /a WT=%WIDTH%-2
set /a YT=%YPOS% + %COUNT%*2 + 2
cmdwiz stringlen %MENULABEL%&set RESULT=!ERRORLEVEL!
set /a XT=80/2-%RESULT%/2+1
set FRAME="\p%XPOS%;%YPOS%\M%WIDTH%{ }\p%XPOS%;%YT%\M%WIDTH%{ }\p%XT%;%YPOS%%MENULABEL:~1,-1%"
set /a SYT=%YPOS% + %COUNT%*2 + 2 + 1
set /a SXT=%XPOS%+1
set /a YT=%YPOS%+1
set /a COUNT=%COUNT%*2+1
set /a XT=%XPOS%+%WIDTH%-1
set FRAME="%FRAME:~1,-1%\p%XPOS%;%YT%\M%COUNT%{ \n}\p%XT%;%YT%\M%COUNT%{ \n}\p%SXT%;%SYT%\%SHADOWCOL%0\M%WT%{:}"
gotoxy %XPOS% %YPOS% %FRAME% %FRAMETEXTCOL% %FRAMECOL% x
set /a YT=%YPOS%+2
set /a XT=%XPOS%+2
call getchmenu.bat %MENUTEXT% %MENUCMDS% %XT% %YT% %SELFGCOL% %SELBGCOL% %UNSELFGCOL% %UNSELBGCOL% %PRESEL% 1
set PRESEL=
cmdwiz showcursor 1
