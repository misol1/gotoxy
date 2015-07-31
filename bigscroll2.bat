@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

set XW=80
set YH=40

set ANIM0="\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n"
set ANIM0=%ANIM0:\F1 =\F9 \F1%
mode con COLS=%XW% lines=%YH%
cmdwiz setbuffersize 100 80
cls
gotoxy 0 40 %ANIM0% r
gotoxy 0 0
set ANIM0=

call font3.bat

call sintable.bat
for /L %%a in (361,1,720) do set SIN%%a=
set CNT=0&for /L %%a in (0,12,359) do set MSIN!CNT!=!SIN%%a!&set /A CNT+=1
for /L %%a in (0,1,360) do set SIN%%a=
set SC=0

set /a YB=2
set /a YB2=%YH%-%CHARH%-2-2

set SCROLLTEXT="Trying out a big font for the scroller..."
set SCROLLTEXT="      %SCROLLTEXT:~1,-1%      "
set DELAY=
::\W10
set YP=1
set YD=1

set BXP=20

call util.bat strlen SCROLL_LEN %SCROLLTEXT%
call util.bat strlen CHARS_LEN %CHARSET%
set CNT=0
for /L %%a in (1,1,%SCROLL_LEN%) do set SCT=!SCROLLTEXT:~%%a,1!& for /L %%b in (1,1,%CHARS_LEN%) do set CST=!CHARSET:~%%b,1!&if "!SCT!"=="!CST!" set /a INDEX=%%b-1 & set T!CNT!=!INDEX!& set /a CNT+=1 & set USED!INDEX!=1
set PSCR_LEN=%CNT%

::for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:#=:!
::for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:#=\gb0!
for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:#=\gdb!

for /L %%a in (0,1,%NOFCHARS%) do if "!USED%%a!" == "" set CS%%a=
for /L %%a in (0,1,%NOFCHARS%) do set USED%%a=

call util.bat strlen SCROLL_LEN %SCROLLTEXT%
set /a SCROLL_LEN=0-(SCROLL_LEN-%XW%)

set XPROG=%XW%

set /a XLEFT=-%CHARW%
set /a XMAX=%CHARW%*(%PSCR_LEN%-6)+%CHARW%*(%XW%/%CHARW%+1)


:LOOP
set OUT=""
set /a PREPC=(%XPROG%-%XW%-%CHARW%)/%CHARW%
if %PREPC% lss 1 set PREPC=0

set OSC=%SC%

:PREPLOOP
set /a XP=%XW%+%PREPC%*(%CHARW%-0)-%XPROG%
if %XP% geq %XW% goto BIGSKIP
set SCI=!T%PREPC%!
set CHAR=!CS%SCI%!
set /a YP=28-(!MSIN%SC%!*25^>^>14)
set /a SC+=1 & if !SC! geq 30 set /A SC=0
set OUT="%OUT:~1,-1%\p%XP%;%YP%%CHAR:~1,-1%"
set /a PREPC+=1
if %PREPC% lss %PSCR_LEN% goto PREPLOOP
:BIGSKIP

gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\vV%OUT:~1,-1%\o0;0%DELAY%" r
::gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\t20kk\f0%OUT:~1,-1%\o0;0%DELAY%" r

set /a XPROG+=1
if %XPROG% gtr %XMAX% set XPROG=%XW%

::set /a YP+=%YD%
	::if %YP% lss %YB% set YD=1
::if %YP% gtr %YB2% set YD=-1

set SC=%OSC%
set /a SC+=1 & if !SC! geq 30 set /A SC=0

set /a BXP-=1
if %BXP% leq 0 set BXP=20

set /a CCNT = %XPROG% %% 20
if %CCNT% == 0 cmdwiz getch nowait
if %ERRORLEVEL% == 27 goto OUT

goto LOOP
:OUT


mode con lines=50 cols=80
cls
endlocal
cmdwiz showcursor 1
