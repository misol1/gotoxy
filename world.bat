@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

set XW=80
set YH=40

set TREENOF=140

set WSW=200
set WSH=100
set /a WSY=%WSH% + %YH%

mode con COLS=%XW% lines=%YH%&cls
cmdwiz setbuffersize %WSW% %WSY%

for /F "tokens=*" %%i in (tree.gxy) do set TREE="%%i"
for /F "tokens=*" %%i in (hero.gxy) do set HERO="%%i"
for /F "tokens=*" %%i in (hero2.gxy) do set HEROATTACK="%%i"
for /F "tokens=*" %%i in (monster.gxy) do set MONSTER="%%i"

for /L %%i in (1,1,%TREENOF%) do set /a XP=!RANDOM! %% (WSW-7)+1 & set /a YP=!RANDOM! %% (WSH-8) + %YH%+2& gotoxy !XP! !YP! %TREE% 0 0 r

set /a XP = %WSW% / 2 - (%XW%/2)
set /a YP = %WSH% / 2 - (%YH%/2) + %YH%

set /a HXP = %XW%/2-2
set /a HYP = %YH%/2-2

set /a XB1 = %HXP% - 20
set /a XB2 = %HXP% + 20
set /a XL1 = %WSW% - %XW%
set /a XL2 = %XW% - 7
set /a XL3 = %WSW% - 6

set /a YB1 = %HYP% - 10
set /a YB2 = %HYP% + 10
set /a YL1 = %WSH%
set /a YL2 = %YH% - 4	
set /a YL3 = %YH% + 1
set /a YL4 = %WSH%+%YH% - 5
set /a YL5 = %YH% + 2

set LIVES=3
set SCORE=0

set ENEMYNOF=4
for /L %%i in (1,1,%ENEMYNOF%) do set /a EXP%%i=!RANDOM! %% (WSW-7)+1 & set /a EYP%%i=!RANDOM! %% (WSH-8) + %YH%+2 & set /A EDIR%%i =!RANDOM! %% 4&set /A ENEW%%i =!RANDOM! %% 5+1

set FLASH=0
set ATTACK=0
set ATTACKRELEASE=1

:LOOP
set HEROC=%HERO%
set FORCEFLASH=
if %FLASH% gtr 0 set /a FLASH-=1&set /a CP=%FLASH% %% 7&if !CP! lss 4 set FORCEFLASH=\F0\HH
if %ATTACK% gtr 0 set /a ATTACK-=1&if !ATTACK! gtr 5 set HEROC=%HEROATTACK%
set WRLD="\o%XP%;%YP%;%XW%;%YH%\p%HXP%;%HYP%%FORCEFLASH%%HEROC%\hh"

set CNT=%ENEMYNOF%
set /a ML1=%XP%-4
set /a ML2=%XP%+%XW%
set /a ML3=%YP%-3
set /a ML4=%YP%+%YH%

set /a HITX1=%HXP%-5
set /a HITX2=%HXP%+6
set /a HITY1=%HYP%-4
set /a HITY2=%HYP%+3

:ELOOP
set /a CP=!RANDOM! %% !ENEW%CNT%!&if !CP!==0 set /A EDIR%CNT%=!RANDOM! %% 4
set INSIDE=0
if !EXP%CNT%! gtr %ML1% if !EXP%CNT%! lss %ML2% if !EYP%CNT%! gtr %ML3% if !EYP%CNT%! lss %ML4% set INSIDE=1
if %INSIDE%==0 goto ESKIP
if !EDIR%CNT%!==0 set /a CP=!EXP%CNT%!-1&cmdwiz inspectblock !CP! !EYP%CNT%! 1 4 exclusive 32&if !ERRORLEVEL! gtr 0 set /a EXP%CNT%-=1&if !EXP%CNT%! lss 1 set EXP%CNT%=1
if !EDIR%CNT%!==1 set /a CP=!EXP%CNT%!+5&cmdwiz inspectblock !CP! !EYP%CNT%! 1 4 exclusive 32&if !ERRORLEVEL! gtr 0 set /a EXP%CNT%+=1&if !EXP%CNT%! geq %XL3% set EXP%CNT%=%XL3%
if !EDIR%CNT%!==2 set /a CP=!EYP%CNT%!-1&cmdwiz inspectblock !EXP%CNT%! !CP! 5 1 exclusive 32&if !ERRORLEVEL! gtr 0 set /a EYP%CNT%-=1&if !EYP%CNT%! lss %YL5% set EYP%CNT%=%YL5%
if !EDIR%CNT%!==3 set /a CP=!EYP%CNT%!+4&cmdwiz inspectblock !EXP%CNT%! !CP! 5 1 exclusive 32&if !ERRORLEVEL! gtr 0 set /a EYP%CNT%+=1&if !EYP%CNT%! geq %YL4% set EYP%CNT%=%YL4%
set /a MX=!EXP%CNT%!-%XP%&set /a MY=!EYP%CNT%!-%YP%&set WRLD="%WRLD:~1,-1%\p!MX!;!MY!%MONSTER%"&if !MX! gtr !HITX1! if !MY! gtr !HITY1! if !MX! lss !HITX2! if !MY! lss !HITY2! call :PLYHIT %CNT%&if !LIVES! lss 1 goto OUT
:ESKIP
set /a CNT-=1
if %CNT% gtr 0 goto ELOOP

set WRLD="%WRLD:~1,-1%\p1;1\c4\g03%LIVES%\-\e6\g07%SCORE%\o0;0"
gotoxy.exe 0 0 %WRLD%

::LEFT RIGHT UP DOWN CTRL ESCAPE
cmdwiz getkeystate 25h 27h 26h 28h ctrl 27
set KDIR=0
set VKEYS=%ERRORLEVEL%
set /a FX=%XP%+%HXP%
set /a FY=%YP%+%HYP%
set /a KS=%VKEYS% ^& 1 & if !KS! geq 1 set KDIR=1&set /a CP=%FX%-1&cmdwiz inspectblock !CP! !FY! 1 3 exclusive 32&if !ERRORLEVEL! gtr 0 set /a HXP-=1&if !HXP! leq %XB1% set /a XP-=1 & set /a HXP+=1& if !XP! lss 0 set XP=0& set /a HXP-=1&if !HXP! lss 1 set HXP=1
set /a KS=%VKEYS% ^& 2 & if !KS! geq 1 set KDIR=2&set /a CP=%FX%+6&cmdwiz inspectblock !CP! !FY! 1 3 exclusive 32&if !ERRORLEVEL! gtr 0 set /a HXP+=1&if !HXP! geq %XB2% set /a XP+=1 & set /a HXP-=1& if !XP! gtr %XL1% set XP=%XL1%& set /a HXP+=1&if !HXP! geq %XL2% set HXP=%XL2%
set /a KS=%VKEYS% ^& 4 & if !KS! geq 1 set KDIR=3&set /a CP=%FY%-1&cmdwiz inspectblock !FX! !CP! 6 1 exclusive 32&if !ERRORLEVEL! gtr 0 set /a HYP-=1&if !HYP! leq %YB1% set /a YP-=1 & set /a HYP+=1& if !YP! lss %YL3% set YP=%YL3%& set /a HYP-=1&if !HYP! lss 1 set HYP=1
set /a KS=%VKEYS% ^& 8 & if !KS! geq 1 set KDIR=4&set /a CP=%FY%+3&cmdwiz inspectblock !FX! !CP! 6 1 exclusive 32&if !ERRORLEVEL! gtr 0 set /a HYP+=1&if !HYP! geq %YB2% set /a YP+=1 & set /a HYP-=1& if !YP! gtr %YL1% set YP=%YL1%& set /a HYP+=1&if !HYP! geq %YL2% set HYP=%YL2%
set /a KS=%VKEYS% ^& 16 & if !KS! geq 1 if !ATTACKRELEASE!==1 if !ATTACK!==0 set ATTACK=15&set ATTACKRELEASE=0&if %KDIR% gtr 0 call :ATTACKFOREST
if !KS! == 0 if !ATTACK!==0 set ATTACKRELEASE=1
set /a KS=%VKEYS% ^& 32
if !KS! == 0 goto LOOP

:OUT
mode con lines=50 cols=80
cls
endlocal
cmdwiz showcursor 1
cmdwiz flushkeys
goto :eof

:PLYHIT
if %ATTACK% gtr 5 set /a SCORE+=100&call :PUTENEMY %1&goto :eof
if %FLASH% gtr 0 goto :eof
set /a LIVES-=1
set FLASH=50
goto :eof

:ATTACKFOREST
if %KDIR%==1 set /a FX-=1&gotoxy !FX! !FY! " \n \n " 0 0 r
if %KDIR%==2 set /a FX+=6&gotoxy !FX! !FY! " \n \n " 0 0 r
if %KDIR%==3 set /a FY-=1&gotoxy !FX! !FY! "      " 0 0 r
if %KDIR%==4 set /a FY+=3&gotoxy !FX! !FY! "      " 0 0 r
goto :eof

:PUTENEMY
set /a EXP%1=!RANDOM! %% (WSW-7)+1
set /a EYP%1=!RANDOM! %% (WSH-8) + %YH%+2
set /A EDIR%1 =!RANDOM! %% 4
set /A ENEW%1 =!RANDOM! %% 5+1
if !EXP%1! gtr %ML1% if !EXP%1! lss %ML2% if !EYP%1! gtr %ML3% if !EYP%1! lss %ML4% goto PUTENEMY
goto :eof
