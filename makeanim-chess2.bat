@echo off
setlocal ENABLEDELAYEDEXPANSION
set NOFLINES=40
set ANIMINDEX=4
set SQUARESIZEY=10
set /a SQUARESIZEX=%SQUARESIZEY%*2-4
set /a FRAMES=%SQUARESIZEY%*2
set COL1=\09
set COL2=\0F

echo @echo off>animdata%ANIMINDEX%.bat
echo cmdwiz showcursor 0 >>animdata%ANIMINDEX%.bat
echo mode con lines=%NOFLINES%>>animdata%ANIMINDEX%.bat
echo cls>>animdata%ANIMINDEX%.bat
echo set "FRAMES=%FRAMES%">>animdata%ANIMINDEX%.bat

call :PREPLINES1

set CNT=0
:LOOP
set SCR1=""
for /L %%b in (1,1,%NOFLINES%) do call :MAKELINE %%b
echo set ANIM%CNT%=%SCR1%>>animdata%ANIMINDEX%.bat
set /a CNT+=1
if %CNT% lss %FRAMES% goto LOOP

endlocal
goto :eof

:MAKELINE
set /a LTMP=(%1+%CNT%)/%SQUARESIZEY%
set /a LTMP=%LTMP% %% 2
if %LTMP% == 0 set SCR1="!SCR1:~1,-1!!SIDES:~1,-1!\n"
if %LTMP% == 1 set SCR1="!SCR1:~1,-1!!SIDES2:~1,-1!\n"
goto :eof

:PREPLINES1
set /a TIMES=80/(%SQUARESIZEX%*2)+1

set A=0
set SIDES=""
:PREPLOOP
set SIDES="!SIDES:~1,-1!%COL1%"
for /L %%a in (1,1,%SQUARESIZEX%) do set SIDES="!SIDES:~1,-1! "
set SIDES="!SIDES:~1,-1!%COL2%"
for /L %%a in (1,1,%SQUARESIZEX%) do set SIDES="!SIDES:~1,-1! "
set /a A+=1
if %A% lss %TIMES% goto PREPLOOP

set A=0
set SIDES2=""
:PREPLOOP2
set SIDES2="!SIDES2:~1,-1!%COL2%"
for /L %%a in (1,1,%SQUARESIZEX%) do set SIDES2="!SIDES2:~1,-1! "
set SIDES2="!SIDES2:~1,-1!%COL1%"
for /L %%a in (1,1,%SQUARESIZEX%) do set SIDES2="!SIDES2:~1,-1! "
set /a A+=1
if %A% lss %TIMES% goto PREPLOOP2
