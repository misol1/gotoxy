@echo off
setlocal
if "%~1" == "?" call :EXAMPLES&goto :eof
if "%~7" == "" echo. & echo Usage: checkers repeatx width repeaty height indent pattern1 pattern2 [bordercolor^|-] [altpattern1^|-] [altpattern2^|-] [borderWidthMulHack]& echo. & echo Write checkers ? for examples&goto :eof
set /a GECHO=0, ARG1=%1, ARG2=%2 & shift & shift
call :MAKECHECKERS %ARG1% %ARG2% %1 %2 %3 %4 %5 %6 %7 %8 %9 
endlocal
goto :eof

:EXAMPLES
set GECHO=1
call :MAKECHECKERS 2 20 1 8 1 \0e\g20 \04\g20 \e0
call :MAKECHECKERS 8 6 8 2 6 \0f\g20 \00\g20 \70
call :MAKECHECKERS 4 6 4 2 6 \02\g20 \0a\g20 \76
call :MAKECHECKERS 3 12 3 6 4 \01\g20 \0b\g20 \80
call :MAKECHECKERS 5 10 4 5 2 \e4\gdd \c2\gb2 \74 \c2\gdd \e4\gb2
call :MAKECHECKERS 4 9 4 4 1 \1f\gb0 \26\gb1 \10 \62\gb0 \f1\gb1
call :MAKECHECKERS 20 1 8 1 20 \f1\g0f \0e\gc5 \22 \0e\g0f \f1\gc5
call :MAKECHECKERS 3 11 3 5 1 \fa\gdc \c4\gdc \22
call :MAKECHECKERS 20 2 20 1 2 \05\g20 \0e\g20 \e2
call :MAKECHECKERS 3 9 3 4 1 \0e\gb0 \e0\gc5 \ee \e0\gb0 \1e\gc5
call :MAKECHECKERS 10 5 10 2 1 \ea\gb2 \38\gb0 \00 \83\gb0 \ae\gb2
:: New examples
call :MAKECHECKERS 76 1 40 1 1 \f7\gb2 \b1\gb1 \c0
call :MAKECHECKERS 16 1 12 3 5 \f7Y0L0 \b1$wAG -
call :MAKECHECKERS 12 1 12 3 3 \00\01\gb2\gb1\gb0\g20\91\gb0\g20 \00\04\gb2\gb1\gb0\g20\c4\gb0\g20 \f0 \00\02\gb2\gb1\gb0\g20\e2\gb0\g20 \00\05\gb2\gb1\gb0\g20\d5\gb0\g20 6
call :MAKECHECKERS 9 1 7 3 10 \00\01\gb2\gb1\gb0\g20\91\gb0\g20 \00\04\gb2\gb1\gb0\g20\c4\gb0\g20 \70 - - 6
call :MAKECHECKERS 12 6 8 4 3 \g20 \0+\gdb \f1
call :MAKECHECKERS 7 5 5 6 4 \gdc\//\gdf \+0\g07\++\g07 \50 - - 2
set GECHO=0
call :MAKECHECKERS 19 4 12 3 0 \01\g20 \00\g20 - & gotoxy 0 /36 & call :MAKECHECKERS 11 7 7 5 0 \09\g20 \- \70 & pause
call :MAKECHECKERS 20 4 12 3 0 \21\gb0 \00\g20 - & gotoxy 0 /36 & call :MAKECHECKERS 5 16 4 9 0 \09\0q\g20 \- \70 & pause
goto :eof

:MAKECHECKERS
setlocal
set /a ARGTEMP=%1, ARGTEMP2=%2, ACROSS=%1/2, WIDTH=%2, DOWN=%3/2, HEIGHT=%4, AREST=%1 %% 2, DREST=%3 %% 2, BORDERW=%1*%2, BORDERH=%3*%4, SPC=%5
set PATT1=%6&set PATT2=%7&set PATT3=%7&set PATT4=%6
set BK=\78&if not "%~8" == "" set BK=%8
if not "%~9" == "" if not "%~9" == "-" set PATT3=%9
shift & shift
if not "%~8" == "" set XP=%8& if not "%~8" == "-" set PATT4=%8
if not "%~9" == "" set /a BORDERW*=%9&set XP2=%9
if not %BK%==x if not %BK%==xx if not %BK%==- set UBORDER=%BK%\gDA\M%BORDERW%{\gC4}%BK%\gBF\n& set DBORDER=%BK%\gC0\M%BORDERW%{\gC4}%BK%\gD9\n& set HBORDER=%BK%\gB3

if %AREST%==1 set ODDHP1=\M%WIDTH%{%PATT1%\\}&set ODDHP2=\M%WIDTH%{%PATT3%\\}
set PATTERN1=\M%HEIGHT%{%HBORDER%\M%ACROSS%{\M%WIDTH%{%PATT1%\\\}\M%WIDTH%{%PATT2%\\\}\\}%ODDHP1%%HBORDER%\n\}
set PATTERN2=\M%HEIGHT%{%HBORDER%\M%ACROSS%{\M%WIDTH%{%PATT3%\\\}\M%WIDTH%{%PATT4%\\\}\\}%ODDHP2%%HBORDER%\n\}
set PATTERN=%UBORDER%\M%DOWN%{%PATTERN1%%PATTERN2%}
if %DREST%==1 set PATTERN=%PATTERN%\M1{%PATTERN1%}
if %GECHO% == 1 gotoxy k k "%ARGTEMP% %ARGTEMP2% %1 %2 %3 %4 %5 %6 %7 %XP% %XP2%" f 0 csiw& echo. & echo.&set PAUSE=pause
gotoxy %SPC% k "%PATTERN%%DBORDER%\p0;k" 0 0 csx & %PAUSE%
endlocal
