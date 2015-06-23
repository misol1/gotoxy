@echo off
setlocal ENABLEDELAYEDEXPANSION
set NOFLINES=27
set FRAMES=16
set ANIMINDEX=-intro4
cls
mode con lines=50

echo @echo off>animdata%ANIMINDEX%.bat
echo cmdwiz showcursor 0 >>animdata%ANIMINDEX%.bat
echo mode con lines=%NOFLINES%>>animdata%ANIMINDEX%.bat
echo cls>>animdata%ANIMINDEX%.bat
echo set "FRAMES=%FRAMES%">>animdata%ANIMINDEX%.bat

set OLDHIT=666
set CNT=0
:LOOP

for /L %%a in (0,1,80) do for /L %%b in (0,1,%NOFLINES%) do call :CHECKME %%a %%b

for /L %%a in (1,1,3) do call :PUTBEG

set SCR1=""
for /L %%b in (0,1,%NOFLINES%) do call :ADDNEWL %%b & for /L %%a in (0,1,80) do call :PRODME %%a %%b

echo set ANIM%CNT%=%SCR1%>>animdata%ANIMINDEX%.bat
set /a CNT+=1

if %CNT% lss %FRAMES% goto LOOP

endlocal
goto :eof

:CHECKME
cmdwiz getcharat %1 %2
set HIT=%ERRORLEVEL%
if %HIT% == 49 set /a X=%1+1&gotoxy !X! %2 "2" 0 7 & set /a X=%1-1&gotoxy !X! %2 "2" 0 7 & set /a Y=%2+1&gotoxy %1 !Y! "2" 0 7 & set /a Y=%2-1&gotoxy %1 !Y! "2" 0 7
::if %HIT% == 50 set /a X=%1+1&gotoxy !X! %2 "3" 0 8&set /a Y=%2+1&gotoxy %1 !Y! "3" 0 8&set /a X=%1-1&gotoxy !X! %2 "3" 0 8& set /a Y=%2-1&gotoxy %1 !Y! "3" 0 8
if %HIT% == 50 call :PUTME %1 %2 1 0&call :PUTME %1 %2 -1 0&call :PUTME %1 %2 0 1&call :PUTME %1 %2 0 -1
if %HIT% == 51 set /a R=!RANDOM!%%10&if !R! leq 0 call :PUTME %1 %2 1 0&call :PUTME %1 %2 -1 0&call :PUTME %1 %2 0 1&call :PUTME %1 %2 0 -1
::if %HIT% == 51 set /a R=!RANDOM!%%10&if !R! leq 0 set /a X=%1+1&gotoxy !X! %2 "3" 0 8&set /a Y=%2+1&gotoxy %1 !Y! "3" 0 8&set /a X=%1-1&gotoxy !X! %2 "3" 0 8& set /a Y=%2-1&gotoxy %1 !Y! "3" 0 8

goto :eof

:PUTME
set /a R=%RANDOM% %% 10
if !R! leq 2 goto :eof

set /a X=%1+%3
set /a Y=%2+%4
cmdwiz getcharat %X% %Y%
if %ERRORLEVEL% == 32 gotoxy !X! !Y! "3" 0 8
goto :eof


:PRODME
cmdwiz getcharat %1 %2
set HIT=%ERRORLEVEL%
if %HIT%==%OLDHIT% set SCR1="!SCR1:~1,-1! "
if %HIT%==%OLDHIT% goto :eof
if %HIT%==49 set SCR1="!SCR1:~1,-1!\0F "
if %HIT%==50 set SCR1="!SCR1:~1,-1!\09 "
if %HIT%==51 set SCR1="!SCR1:~1,-1!\01 "
if %HIT%==32 set SCR1="!SCR1:~1,-1!\00 "
set OLDHIT=%HIT%
goto :eof

:ADDNEWL
if not "%1" == "0" set SCR1="!SCR1:~1,-1!\n"
goto :eof

:PUTBEG
set /a X=!RANDOM! %% 80
set /a Y=!RANDOM! %% %NOFLINES%
cmdwiz getcharat %X% %Y%
if not %ERRORLEVEL%==32 goto PUTBEG
gotoxy %X% %Y% "1" 0 F
goto :eof
