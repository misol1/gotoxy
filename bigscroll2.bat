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

set YM=28
set YMUL=25
if %CHARH% gtr 8 set /a YM-=(%CHARH%-9)/2

call sintable.bat
for /L %%a in (361,1,720) do set SIN%%a=
set CNT=0&for /L %%a in (0,12,359) do set MSIN!CNT!=!SIN%%a!&set /A CNT+=1
for /L %%a in (0,12,359) do set MSIN!CNT!=!SIN%%a!&set /A CNT+=1
for /L %%a in (0,1,360) do set SIN%%a=
set SC=0

set SCROLLTEXT="Trying out a big font for the scroller..."
set /a BEGC=%XW%/%CHARW%+1
for /L %%a in (1,1,%BEGC%) do set SCROLLTEXT=" !SCROLLTEXT:~1,-1!"
set SCROLLTEXT="%SCROLLTEXT:~1,-1%      "
set DELAY=0
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
set DMODE=0
set XPD=1
set CNT=0
set BORD=0

:LOOP
set OUT=""
set /a PREPC=(%XPROG%-%XW%-%CHARW%)/%CHARW%
if %PREPC% lss 1 set PREPC=0

set OSC=%SC%
for /L %%a in (%PREPC%,1,%PSCR_LEN%) do set /a XP=%XW%+%%a*(%CHARW%-0)-%XPROG% & set SCI=!T%%a!& for %%b in (!SCI!) do set CHAR=!CS%%b!& for %%c in (!SC!) do set /a YP=%YM%-(!MSIN%%c!*%YMUL%^>^>14) & set /a SC+=%SYD% & set OUT="!OUT:~1,-1!\p!XP!;!YP!!CHAR:~1,-1!"& if !XP! geq %XW% goto BIGSKIP
:BIGSKIP
if %BORD%==1 set OUT="!OUT:~1,-1!\t00kk\p0;0\02\Xz                                                                                 \p0;39                                                                                 "

if %DMODE%==0 gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\R\vV%OUT:~1,-1%\o0;0\W%DELAY%"
if %DMODE%==1 gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\t20kk\f0%OUT:~1,-1%\o0;0\W%DELAY%"
if %DMODE%==2 gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\f4%OUT:~1,-1%\o0;0\W%DELAY%"
if %DMODE%==3 gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\R\04\Xz%OUT:~1,-1%\o0;0\W%DELAY%"		
if %DMODE%==4 gotoxy.exe 0 0 "\o%BXP%;40;%XW%;%YH%\R\82\zz%OUT:~1,-1%\o0;0\W%DELAY%"		

set /a XPROG+=%XPD%
if %XPROG% gtr %XMAX% set XPROG=%XW%
if %XPROG% lss %XW% set XPROG=%XMAX%

set SC=%OSC%
set /a SC+=1 & if !SC! geq 30 set /A SC=0

set /a BXP+=%BGD%
if %BXP% leq 0 set BXP=20&goto SKIP
if %BXP% geq 20 set BXP=0
:SKIP

set /a CCNT = %CNT% %% 10
set /A CNT+=1
if not %CCNT% == 0 goto LOOP
cmdwiz getch nowait & set KEY=!ERRORLEVEL!
if %KEY% == 336 set /a BGD-=1&if !BGD! lss -2 set BGD=-2
if %KEY% == 328 set /a BGD+=1&if !BGD! gtr 2 set BGD=2
if %KEY% == 333 set /a XPD-=1&if !XPD! lss -3 set XPD=-3
if %KEY% == 331 set /a XPD+=1&if !XPD! gtr 3 set XPD=3
if %KEY% == 32 set /A DMODE+=1&if !DMODE! gtr 4 set DMODE=0
if %KEY% == 13 set /A SYD=1-%SYD%
if %KEY% == 98 set /A BORD=1-%BORD%
if %KEY% == 112 cmdwiz getch
if %KEY% == 72 set /a YMUL+=2&set /a YM+=1
if %KEY% == 104 set /a YMUL-=2&set /a YM-=1&if !YMUL! lss 0 set YMUL=0&set /a YM+=1
if %KEY% == 49 for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:\gdb=:!&set CS%%a=!CS%%a:\g01=:!
if %KEY% == 50 for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:\gdb=\g01!&set CS%%a=!CS%%a::=\g01!
if %KEY% == 51 for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:\g01=\gdb!&set CS%%a=!CS%%a::=\gdb!
if %KEY% == 43 set /a DELAY+=5
if %KEY% == 45 set /a DELAY-=5&if !DELAY! lss 0 set DELAY=0
if %KEY% == 27 goto OUT

goto LOOP
:OUT


mode con lines=50 cols=80
cls
endlocal
cmdwiz showcursor 1
