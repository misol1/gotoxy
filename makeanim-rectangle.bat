@echo off
setlocal ENABLEDELAYEDEXPANSION
set NOFLINES=40
set FRAMES=16
set ANIMINDEX=1

echo @echo off>animdata%ANIMINDEX%.bat
echo cmdwiz showcursor 0 >>animdata%ANIMINDEX%.bat
echo mode con lines=%NOFLINES%>>animdata%ANIMINDEX%.bat
echo cls>>animdata%ANIMINDEX%.bat
echo set "FRAMES=%FRAMES%">>animdata%ANIMINDEX%.bat

set CNT=0
set EXPCNT=2
:LOOP
set SCR1=""
call :PREPLINES %CNT%
for /L %%b in (1,1,%NOFLINES%) do call :MAKELINE %%b
echo set ANIM%CNT%=%SCR1%>>animdata%ANIMINDEX%.bat
set /a CNT+=1
set /a EXPCNT+=1
if %CNT% lss %FRAMES% goto LOOP

endlocal
goto :eof

:MAKELINE
set /a LTMP=%NOFLINES%/2-%EXPCNT%
if %1 lss %LTMP% set SCR1="!SCR1:~1,-1!!EMPTY:~1,-1!\n"&goto :eof
if %1 == %LTMP% set SCR1="!SCR1:~1,-1!!TOPB:~1,-1!\n"&goto :eof
set /a LTMP=%NOFLINES%/2+%EXPCNT%
if %1 gtr %LTMP% set SCR1="!SCR1:~1,-1!!EMPTY:~1,-1!\n"&goto :eof
if %1 == %LTMP% set SCR1="!SCR1:~1,-1!!TOPB:~1,-1!\n"&goto :eof
set SCR1="!SCR1:~1,-1!!SIDES:~1,-1!\n"
goto :eof

:PREPLINES
set EMPTY="                                                                                "

set /a LTMP=%FRAMES%/3
set TMP2=0
if %CNT% geq %TMP2% set COL=\C0
set /a TMP2+=%LTMP%
if %CNT% geq %TMP2% set COL=\E0
set /a TMP2+=%LTMP%
if %CNT% geq %TMP2% set COL=\F0

set SIDES="%COL%"
set /a LTMP=80/2-%EXPCNT%+%1*0-0
for /L %%a in (1,1,%LTMP%) do set SIDES="!SIDES:~1,-1! "
set SIDES="!SIDES:~1,-1!:#"
set /a TMP2=%EXPCNT%*2-2
for /L %%a in (1,1,%TMP2%) do set SIDES="!SIDES:~1,-1! "
set SIDES="!SIDES:~1,-1!#:"
for /L %%a in (1,1,%LTMP%) do set SIDES="!SIDES:~1,-1! "

set TOPB="%COL%"
for /L %%a in (1,1,%LTMP%) do set TOPB="!TOPB:~1,-1! "
set TOPB="!TOPB:~1,-1! "
set /a TMP2+=2
for /L %%a in (1,1,%TMP2%) do set TOPB="!TOPB:~1,-1!o"
set TOPB="!TOPB:~1,-1! "
for /L %%a in (1,1,%LTMP%) do set TOPB="!TOPB:~1,-1! "
