@echo off
setlocal ENABLEDELAYEDEXPANSION
set COL=a
if not "%~1"=="" set COL=%~1
set PATTE=3
if not "%~2"=="" set /A PATTE=%~2
if not "%~2"=="" if "%~2"=="0" set PATTE=6
if %PATTE% lss 0 set PATTE=3
if %PATTE% gtr 6 set PATTE=3
if %PATTE%==1 set INP=\gb9\gba\gbb\gbc\gc8\gc9\gca\gcb\gcc\gcd\gce
if %PATTE%==2 set INP=\gb0\gb1\gb2\gdb\gdc\gdf
if %PATTE%==3 set INP=\gdb\gdc\gdf\gfe
if %PATTE%==4 set INP=\gb3\gb4\gbf\gc0\gc1\gc2\gc3\gc4\gc5
if %PATTE%==5 set INP=\gf9\gfa\gf7\g2e
if %PATTE%==6 set INP=\g2f\g5c
if %PATTE%==0 set INP=%~2
if not "%~3"=="" for /L %%a in (1,1,%3) do set INP=!INP!\g20
cmdwiz stringlen %INP%&set /A NOFC=!ERRORLEVEL!/4
:REP
for /L %%i in (1,1,200) do set /A R=(!RANDOM! %% %NOFC%)*4&for %%a in (!R!) do gotoxy k k "!INP:~%%a,4!" %COL% 0 cszk & if !ERRORLEVEL!==27 endlocal&goto :eof
goto REP
