@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
cmdwiz getconsoledim cy&set CY=!ERRORLEVEL!
cmdwiz getconsoledim cx&set CX=!ERRORLEVEL!
cmdwiz getconsoledim sy&set SY=!ERRORLEVEL!
cmdwiz getconsoledim sx&set SX=!ERRORLEVEL!

set COL1=f&if not "%1"=="" set COL1=%1
set BLOCKSIZE=6&if not "%2"=="" set BLOCKSIZE=%2
set DELAY=0&set DELAY2=0&if not "%3"=="" set DELAY=%3
set COL2=%COL1%&if not "%4"=="" set COL2=%4&set DELAY2=%DELAY%&set DELAY=0
set COL2DELAY=40&if not "%5"=="" set COL2DELAY=%5
if %BLOCKSIZE% lss 2 set BLOCKSIZE=2
set PT=
set /A W=(%SX%-1)/%BLOCKSIZE%
set /A H=(%SY%-1)/%BLOCKSIZE%
for /L %%a in (0,1,%H%) do for /L %%b in (0,1,%W%) do set /A XP=10+%%b&set /A YP=10+%%a&set PT=!PT!!XP!!YP!
::echo %PT%&pause
set /A NOFB=(%W%+1)*(%H%+1)
::for /L %%a in (1,1,%NOFB%) do call :SHOWBLOCK
for /L %%a in (1,1,%NOFB%) do set /A CP=(!RANDOM! %% !NOFB!)*4 & for %%b in (!CP!) do set CBX=!PT:~%%b,2!& set /A CPY=!CP!+2 & for %%c in (!CPY!) do set CBY=!PT:~%%c,2!&set /A CPQ=!CP!+4 & set /a CBX=(!CBX!-10)*%BLOCKSIZE%+%CX%& set /a CBY=(!CBY!-10)*%BLOCKSIZE%+%CY% & gotoxy !CBX! !CBY! "\M%BLOCKSIZE%{\M%BLOCKSIZE%{ \}\n}\w%DELAY%" 0 %COL2% rx & for %%d in (!CPQ!) do set PT=!PT:~0,%%b!!PT:~%%d!& set /A NOFB-=1 & if not %COL1%==%COL2% gotoxy !CBX! !CBY! "\w%COL2DELAY%\M%BLOCKSIZE%{\M%BLOCKSIZE%{ \}\n}\w%DELAY2%" 0 %COL1% rx
endlocal
cmdwiz showcursor 1
goto :eof

:SHOWBLOCK
set /A CP=(!RANDOM! %% !NOFB!)*4
set CBX=!PT:~%CP%,2!
set /A CPY=%CP%+2
set CBY=!PT:~%CPY%,2!
set /A CPQ=%CP%+4
set /a CBX=(%CBX%-10)*%BLOCKSIZE%+%CX%
set /a CBY=(%CBY%-10)*%BLOCKSIZE%+%CY%
gotoxy %CBX% %CBY% "\M%BLOCKSIZE%{\M%BLOCKSIZE%{ \}\n}\w%DELAY%" 0 %COL2% rx
set PT=!PT:~0,%CP%!!PT:~%CPQ%!
set /A NOFB-=1
if not %COL1%==%COL2% gotoxy %CBX% %CBY% "\w%COL2DELAY%\M%BLOCKSIZE%{\M%BLOCKSIZE%{ \}\n}\w%DELAY2%" 0 %COL1% rx
