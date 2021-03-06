@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

set XW=80
set YH=40

set ANIM0="\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n"
set ANIM0=%ANIM0:\F1 =\F9 \F1%
mode con COLS=%XW% lines=%YH%
cls

call font3.bat

call sintable.bat
for /L %%a in (361,1,720) do set SIN%%a=
set CNT=0&for /L %%a in (0,12,359) do set MSIN!CNT!=!SIN%%a!&set /A CNT+=1
for /L %%a in (0,1,360) do set SIN%%a=
set SC=0

set SCROLLTEXT="Trying out a big font for the scroller..."
set SCROLLTEXT="      %SCROLLTEXT:~1,-1%      "
set DELAY=

set BXP=-20

cmdwiz stringlen %SCROLLTEXT%&set SCROLL_LEN=!ERRORLEVEL!
cmdwiz stringlen %CHARSET%&set CHARS_LEN=!ERRORLEVEL!
set CNT=0
for /L %%a in (1,1,%SCROLL_LEN%) do set SCT=!SCROLLTEXT:~%%a,1!& for /L %%b in (1,1,%CHARS_LEN%) do set CST=!CHARSET:~%%b,1!&if "!SCT!"=="!CST!" set /a INDEX=%%b-1 & set T!CNT!=!INDEX!& set /a CNT+=1 & set USED!INDEX!=1
set PSCR_LEN=%CNT%

::for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:#=:!
::for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:#=\gb0!
for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:#=\gdb!

for /L %%a in (0,1,%NOFCHARS%) do if "!USED%%a!" == "" set CS%%a=
for /L %%a in (0,1,%NOFCHARS%) do set USED%%a=
set /a SCROLL_LEN=0-(SCROLL_LEN-%XW%)

set XPROG=%XW%
set /a XMAX=%CHARW%*(%PSCR_LEN%-6)+%CHARW%*(%XW%/%CHARW%+1)


:LOOP
set OUT=""
set /a PREPC=(%XPROG%-%XW%-%CHARW%)/%CHARW%
if %PREPC% lss 1 set PREPC=0

set /a YP=28-(!MSIN%SC%!*25^>^>14)

for /L %%a in (%PREPC%,1,%PSCR_LEN%) do set /a XP=%XW%+%%a*(%CHARW%-0)-%XPROG% & set SCI=!T%%a!& for %%b in (!SCI!) do set CHAR=!CS%%b!& set OUT="!OUT:~1,-1!\p!XP!;!YP!!CHAR:~1,-1!"& if !XP! geq %XW% goto BIGSKIP
:BIGSKIP

gotoxy.exe %BXP% 0 "\O0;0;%XW%;%YH%%ANIM0:~1,-1%\R\vV%OUT:~1,-1%%DELAY%" 0 0 k
if %ERRORLEVEL% == 27 goto OUT

set /a XPROG+=1
if %XPROG% gtr %XMAX% set XPROG=%XW%

set /a SC+=1 & if !SC! geq 30 set /A SC=0

set /a BXP+=1
if %BXP% geq 0 set BXP=-20

goto LOOP
:OUT

mode con lines=50 cols=80
cls
endlocal
cmdwiz showcursor 1
