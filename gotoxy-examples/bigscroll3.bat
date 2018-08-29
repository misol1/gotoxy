@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

set XW=80
set YH=40

cls
mode con COLS=%XW% lines=%YH%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==YH if not %%v==XW set "%%v="
set /A YHA=%YH%+1

::set CHESS=\M4{\M6{\M8{\F9 \F1         \70          \\}\n\}\M6{\M8{\70          \F9 \F1         \\}\n\}}
set CHESS=\M4{\M6{\F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \n\}\M6{\70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \70          \F9 \F1         \n\}}
set /A YHA=%YH%+1

call font3.bat
set /a ADDW=%CHARW%-0

set YM=28
set YMUL=25
if %CHARH% gtr 8 set /a YM-=(%CHARH%-9)/2

call sintable.bat
for /L %%a in (361,1,720) do set SIN%%a=
set CNT=0&for /L %%a in (0,12,359) do set MSIN!CNT!=!SIN%%a!&set /A CNT+=1
for /L %%a in (0,12,359) do set MSIN!CNT!=!SIN%%a!&set /A CNT+=1
for /L %%a in (0,1,360) do set SIN%%a=
set SC=0

set SCROLLTEXT="Trying out a big font for the scroller... Check out these keys: Space, RETURN, Cursor LEFT/RIGHT/UP/DOWN, H/h,b,p,1,2,3..."
set /a BEGC=%XW%/%ADDW%+2
for /L %%a in (1,1,%BEGC%) do set SCROLLTEXT=" !SCROLLTEXT:~1,-1!"
set SCROLLTEXT="%SCROLLTEXT:~1,-1%      "
set DELAY=0
set BXP=20

cmdwiz stringlen %SCROLLTEXT%&set SCROLL_LEN=!ERRORLEVEL!
cmdwiz stringlen %CHARSET%&set CHARS_LEN=!ERRORLEVEL!
set CNT=0
for /L %%a in (1,1,%SCROLL_LEN%) do set SCT=!SCROLLTEXT:~%%a,1!& for /L %%b in (1,1,%CHARS_LEN%) do set CST=!CHARSET:~%%b,1!&if "!SCT!"=="!CST!" set /a INDEX=%%b-1 & set T!CNT!=!INDEX!& set /a CNT+=1 & set USED!INDEX!=1
set PSCR_LEN=%CNT%

::for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a: #=\gb0!
for /L %%a in (0,1,%NOFCHARS%) do set CS%%a=!CS%%a:#=\gdb!

for /L %%a in (0,1,%NOFCHARS%) do if "!USED%%a!" == "" set CS%%a=
for /L %%a in (0,1,%NOFCHARS%) do set USED%%a=

set XPROG=%XW%
set /a XMAX=%ADDW%*(%PSCR_LEN%-6)+%ADDW%*(%XW%/%ADDW%+1)
set BGD=-1
set SYD=1
set DMODE=0
call :SETMODE
set XPD=1
set BORD=0

set SCROLLTEXT=&set CHARSET=&set BEGC=&set SCROLL_LEN=&set INDEX=&set SCT=&set CST=

:LOOP
set OUT=""
set /a PREPC=(%XPROG%-%XW%-%ADDW%)/%ADDW%+1
if %PREPC% lss 2 set PREPC=0

set OSC=%SC%
set /a XP=%XW%+%PREPC%*%ADDW%-%XPROG%
set /a ENDC=%PREPC% + (%XW%-%XP%)/%ADDW%

for /L %%a in (%PREPC%,1,%ENDC%) do set SCI=!T%%a!& for %%b in (!SCI!) do for %%c in (!SC!) do set /a YP=%YM%-(!MSIN%%c!*%YMUL%^>^>14) & set /a SC+=%SYD% & set OUT="!OUT:~1,-1!\p!XP!;!YP!!CS%%b:~1,-1!"& set /a XP+=%ADDW%
if %BORD%==1 set OUT="!OUT:~1,-1!\T00kk1\p0;0\02\xQ                                                                                 \p0;39                                                                                 "

gotoxy.exe 0 0 "\O0;0;%XW%;%YHA%\p-%BXP%;-1;%CHESS%%MODECODE%%OUT:~1,-1%\O\W%DELAY%" 0 0 xk
set KEY=!ERRORLEVEL!

set /a XPROG+=%XPD%
if %XPROG% gtr %XMAX% set XPROG=%XW%
if %XPROG% lss %XW% set XPROG=%XMAX%

set SC=%OSC%
set /a SC+=1 & if !SC! geq 30 set /A SC=0

set /a BXP+=%BGD%
if %BXP% leq 0 set BXP=20&goto SKIP
if %BXP% geq 20 set BXP=0
:SKIP

if %KEY% == 0 goto LOOP
if %KEY% == 336 set /a BGD-=1&if !BGD! lss -2 set BGD=-2
if %KEY% == 328 set /a BGD+=1&if !BGD! gtr 2 set BGD=2
if %KEY% == 333 set /a XPD-=1&if !XPD! lss -3 set XPD=-3
if %KEY% == 331 set /a XPD+=1&if !XPD! gtr 3 set XPD=3
if %KEY% == 32 call :SETMODE
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

endlocal
mode con lines=50 cols=80
cls
cmdwiz showcursor 1
goto :eof

:SETMODE
if %DMODE%==0 set MODECODE=\R\vV
if %DMODE%==1 set MODECODE=\T20kk1\R\f0
if %DMODE%==2 set MODECODE=\f4
if %DMODE%==3 set MODECODE=\R\04\xQ
if %DMODE%==4 set MODECODE=\R\82\qQ
set /A DMODE+=1&if !DMODE! gtr 4 set DMODE=0
