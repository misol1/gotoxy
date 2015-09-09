@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0

set XW=80
set YH=40

set TREENOF=140

set WSW=200
set WSH=100
set /a WSY=%WSH% + %YH%

mode con COLS=%XW% lines=%YH%
cmdwiz setbuffersize %WSW% %WSY%

for /F "tokens=*" %%i in (tree.gxy) do set TREE="%%i"
for /F "tokens=*" %%i in (hero.gxy) do set HERO="%%i"

for /L %%i in (1,1,%TREENOF%) do set /a XP=!RANDOM! %% (WSW-7)+1 & set /a YP=!RANDOM! %% (WSH-8) + %YH%+2& gotoxy !XP! !YP! %TREE% 0 0 r

set /a XP = %WSW% / 2 - (%XW%/2)
set /a YP = %WSH% / 2 - (%YH%/2) + %YH%

set /a HXP = %XW%/2-2
set /a HYP = %YH%/2-2

set /a XB1 = %HXP% - 20
set /a XB2 = %HXP% + 20
set /a XL1 = %WSW% - %XW%
set /a XL2 = %XW% - 7

set /a YB1 = %HYP% - 10
set /a YB2 = %HYP% + 10
set /a YL1 = %WSH%
set /a YL2 = %YH% - 4
set /a YL3 = %YH% + 1


:LOOP
gotoxy.exe 0 0 "\o%XP%;%YP%;%XW%;%YH%\p%HXP%;%HYP%%HERO%\o0;0"

set COLL=0
::LEFT RIGHT UP DOWN ESCAPE
cmdwiz getkeystate 25h 27h 26h 28h 27
set VKEYS=%ERRORLEVEL%
set /a KS=%VKEYS% ^& 1 & if !KS! geq 1 call :COLLISION -1 0 0 3&if !COLL!==0 set /a HXP-=1&if !HXP! leq %XB1% set /a XP-=1 & set /a HXP+=1& if !XP! lss 0 set XP=0& set /a HXP-=1&if !HXP! lss 1 set HXP=1
set /a KS=%VKEYS% ^& 2 & if !KS! geq 1 call :COLLISION 6 0 0 3 &if !COLL!==0 set /a HXP+=1&if !HXP! geq %XB2% set /a XP+=1 & set /a HXP-=1& if !XP! gtr %XL1% set XP=%XL1%& set /a HXP+=1&if !HXP! geq %XL2% set HXP=%XL2%
set /a KS=%VKEYS% ^& 4 & if !KS! geq 1 call :COLLISION 0 -1 6 0&if !COLL!==0 set /a HYP-=1&if !HYP! leq %YB1% set /a YP-=1 & set /a HYP+=1& if !YP! lss %YL3% set YP=%YL3%& set /a HYP-=1&if !HYP! lss 1 set HYP=1
set /a KS=%VKEYS% ^& 8 & if !KS! geq 1 call :COLLISION 0 3 6 0 &if !COLL!==0 set /a HYP+=1&if !HYP! geq %YB2% set /a YP+=1 & set /a HYP-=1& if !YP! gtr %YL1% set YP=%YL1%& set /a HYP+=1&if !HYP! geq %YL2% set HYP=%YL2%
set /a KS=%VKEYS% ^& 16
if !KS! == 0 goto LOOP


mode con lines=50 cols=80
cls
endlocal
cmdwiz showcursor 1
goto :eof


:COLLISION
set /a SXP=%HXP%+%1
set /a SYP=%HYP%+%2
if %3 gtr 0 set /a SXP-=1&for /L %%a in (1,1,%3) do set /a SXP+=1&cmdwiz getcharat !SXP! !SYP!&if not !ERRORLEVEL!==32 set COLL=1&goto :eof
if %4 gtr 0 set /a SYP-=1&for /L %%a in (1,1,%4) do set /a SYP+=1&cmdwiz getcharat !SXP! !SYP!&if not !ERRORLEVEL!==32 set COLL=1&goto :eof
goto :eof
