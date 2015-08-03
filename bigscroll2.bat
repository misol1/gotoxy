@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

set XW=80
set YH=40

mode con COLS=%XW% lines=%YH%
cmdwiz setbuffersize 100 80

set ANIM0="\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\F1\70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n\70\F1          \70          \F1          \70          \F1          \70          \F1          \70          \F1          \70          \n"
set ANIM0=%ANIM0:\F1 =\F9 \F1%
gotoxy 0 0 "\N\p0;40%ANIM0:~1,-1%" r
set ANIM0=

call font3.bat

call sintable.bat
for /L %%a in (361,1,720) do set SIN%%a=
set CNT=0&for /L %%a in (0,12,359) do set MSIN!CNT!=!SIN%%a!&set /A CNT+=1
for /L %%a in (0,12,159) do set MSIN!CNT!=!SIN%%a!&set /A CNT+=1
for /L %%a in (0,1,360) do set SIN%%a=
set SC=0

set SCROLLTEXT="Trying out a big font for the scroller..."
set SCROLLTEXT="      %SCROLLTEXT:~1,-1%      "
set DELAY=
set BXP=20

call util.bat strlen SCROLL_LEN %SCROLLTEXT%
call util.bat strlen CHARS_LEN %CHARSET%
set CNT=0
for /L %%a in (1,1,%SCROLL_LEN%) do set SCT=!SCROLLTEXT:~%%a,1!& for /L %%b in (1,1,%CHARS_LEN%) do set CST=!CHARSET:~%%b,1!&if "!SCT!"=="!CST!" set /a INDEX=%%b-1 & set T!CNT!=!INDEX!& set /a CNT+=1 & set USED!INDEX!=1
set PSCR_LEN=%CNT%

for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:#=\gdb!

for /L %%a in (0,1,%NOFCHARS%) do if "!USED%%a!" == "" set CS%%a=
for /L %%a in (0,1,%NOFCHARS%) do set USED%%a=

call util.bat strlen SCROLL_LEN %SCROLLTEXT%
set /a SCROLL_LEN=0-(SCROLL_LEN-%XW%)

set XPROG=%XW%
set /a XMAX=%CHARW%*(%PSCR_LEN%-6)+%CHARW%*(%XW%/%CHARW%+1)
set BGD=-1
set SYD=1
set DMODE=1
set XPD=1


:LOOP
set OUT=""
set KEY=0
set /a PREPC=(%XPROG%-%XW%-%CHARW%)/%CHARW%
if %PREPC% lss 1 set PREPC=0

set OSC=%SC%
for /L %%a in (%PREPC%,1,%PSCR_LEN%) do set /a XP=%XW%+%%a*(%CHARW%-0)-%XPROG% & set SCI=!T%%a!& for %%b in (!SCI!) do set CHAR=!CS%%b!& for %%c in (!SC!) do set /a YP=28-(!MSIN%%c!*25^>^>14) & set /a SC+=%SYD% & set OUT="!OUT:~1,-1!\p!XP!;!YP!!CHAR:~1,-1!"& if !XP! geq %XW% goto BIGSKIP
:BIGSKIP

if %DMODE%==1 gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\vV%OUT:~1,-1%\o0;0%DELAY%"
if %DMODE%==0 gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\t20kk\f0%OUT:~1,-1%\o0;0%DELAY%" r

set /a XPROG+=%XPD%
if %XPROG% gtr %XMAX% set XPROG=%XW%

set SC=%OSC%
set /a SC+=1 & if !SC! geq 30 set /A SC=0

set /a BXP+=%BGD%
if %BXP% leq 0 set BXP=20&goto SKIP
if %BXP% geq 20 set BXP=0
:SKIP

set /a CCNT = %XPROG% %% 20
if %CCNT% == 0 cmdwiz getch nowait & set KEY=!ERRORLEVEL!
if %KEY% == 333 set /a BGD-=1&if !BGD! lss -2 set BGD=-2
if %KEY% == 331 set /a BGD+=1&if !BGD! gtr 2 set BGD=2
if %KEY% == 336 set /a XPD-=1&if !XPD! lss 0 set XPD=0
if %KEY% == 328 set /a XPD+=1&if !XPD! gtr 3 set XPD=3
if %KEY% == 32 set /A DMODE=1-%DMODE%
if %KEY% == 13 set /A SYD=1-%SYD%
if %KEY% == 49 for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:\gdb=:!&set CS%%a=!CS%%a:\g01=:!
if %KEY% == 50 for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:\gdb=\g01!&set CS%%a=!CS%%a::=\g01!
if %KEY% == 51 for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:\g01=\gdb!&set CS%%a=!CS%%a::=\gdb!
if %KEY% == 27 goto OUT

goto LOOP
:OUT


mode con lines=50 cols=80
cls
endlocal
cmdwiz showcursor 1
