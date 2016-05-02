@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
set V1=8&set V2=5
set D1=1
set XS=35&set XE=44
set MC1=1&set MC2=
set LOWB=8
cls
:LOOP
gotoxy %XS% 0 "\M100{\0%MC1%\M%V1%{ \}\90\M%V2%{ \}%MC2%}" 9 0 wxk %XE%
set KEY=!ERRORLEVEL!
set /a V1+=%D1%
if %V1% geq 45 set D1=-1
if %V1% lss %LOWB% set D1=1

if %KEY%==331 set /A XS-=1&set /A XE+=1
if %KEY%==333 if %XS% lss 39 cls&set /A XS+=1&set /A XE-=1
if %KEY%==32 call :CHGCOL
if %KEY%==13 call :CHGEND
if not %KEY% == 27 goto LOOP
cmdwiz showcursor 1
endlocal
goto :eof

:CHGCOL
if %MC1%==1 set MC1=+&set MC2=\r&goto :eof
set MC1=1&set MC2=
goto :eof

:CHGEND
if %LOWB%==8 set LOWB=2&goto :eof
set LOWB=8