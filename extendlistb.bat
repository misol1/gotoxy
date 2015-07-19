@echo off
if "%~1" == "_SHOW_EXTENDED_HELP" goto SHOWHELP

set EDITCMD2=start npp
set NEWWINDOWCMD=start dosgo.bat
set GCMD=g
set EXTVIEW=less -f

if %KEY% == 74 if not "!FT%CURRPOS%!"=="/" cmd /C "!FO%CURRPOS%!"&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&exit /b 1 & rem J

if %KEY% == 119 call listb.bat _GETANSWER "Search for file:"& if not "!ANSWER!"=="" call :CLRSCR&dir /s /-p /b|grep -i -F !ANSWER!|%EXTVIEW%& exit /b 1 & goto :eof & rem w
if %KEY% == 87 call listb.bat _GETANSWER "Search for in files:"& if not "!ANSWER!"=="" call :CLRSCR&grep -n -i "!ANSWER!" *.*|%EXTVIEW%& exit /b 1 & goto :eof & rem W
if %KEY% == 23 call listb.bat _GETANSWER "Search for in files:"& if not "!ANSWER!"=="" set FANSW=!ANSWER!&call listb.bat _GETANSWER "File types:"& if not "!ANSWER!"=="" call :CLRSCR&grep -n -i "!FANSW!" !ANSWER!|%EXTVIEW%& exit /b 1 & goto :eof & rem ^W

if %KEY% == 112 %NEWWINDOWCMD% & rem p

if %KEY% == 110 if not "!FT%CURRPOS%!"=="/" cmd /C %EDITCMD2% !FO%CURRPOS%! & rem n
if %KEY% == 78 call listb.bat _GETANSWER "Edit file:"& if not "!ANSWER!"=="" cmd /C %EDITCMD2% !ANSWER! & rem N

if %KEY% == 103 call listb.bat _GETANSWER "Go:"& if not "!ANSWER!"=="" set KEY=85&%GCMD% !ANSWER!& exit /b 2 & goto :eof & rem g

if %KEY% == 3 call listb.bat _GETANSWER "Copy from:"& if not "!ANSWER!"=="" cmd /C copy /Y !ANSWER! .>nul& exit /b 3 & goto :eof & rem ^C

if %KEY% == 4 if "!FT%CURRPOS%!"=="/" if not !FO%CURRPOS%!==".." call listb.bat _YESNO "Really wipe out directory?(y/n) " & if "!ANSWER!"=="Y" cmd /C rd /Q /S !FO%CURRPOS%!& exit /b 3 & goto :eof & rem ^D

if %KEY% == 1 call :SET_ATTRIBS & exit /b 0 & goto :eof & rem ^A

if %KEY% == 24 if "!FT%CURRPOS%!"=="/" if not !FO%CURRPOS%!==".." call listb.bat _GETANSWER "Copy to (# for swap folder):"& if not "!ANSWER!"=="" call :XCOPY "!ANSWER!"& exit /b 3 & goto :eof & rem ^X

if not %KEY% == 97 goto NOT_a & rem a
if "!FT%CURRPOS%!"=="/" goto :eof
set XTENSION=%~x1
call :LOCASE XTENSION
set XFILE=%~n1
if "%XTENSION%"==".wav" cmdwiz playsound %1 & exit /b 0
if "%XTENSION%"==".gxy" call :CLRSCR&gotoxy 0 0 %1 0 0 c & cmdwiz getch & exit /b 1
if "%XTENSION%"==".mp3" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".mod" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".ans" call :CLRSCR&ansicon -t %1 & cmdwiz getch & exit /b 1
if "%XTENSION%"==".zip" call :CLRSCR&unzip -l %1|%EXTVIEW% & exit /b 3
call :CLRSCR
%EXTVIEW% %1
exit /b 1

:NOT_a
if not %KEY% == 122 goto NOT_z & rem z
set XTENSION=%~x1
if not "%XTENSION%"==".zip" if not "%XTENSION%"==".ZIP" exit /b 0 & goto :eof
call :CLRSCR
unzip %1
exit /b 3

:NOT_z
if not %KEY% == 90 goto NOT_SHIFTz & rem Z
call listb.bat _COUNTITEMS CNT Y& if !CNT! lss 1 call listb.bat _SHOWBOTTOMBAR "No items selected." & exit /b 0 & goto :eof
call listb.bat _GETANSWER "Zip archive name:"& if "!ANSWER!"=="" exit /b 0 & goto :eof
call :CLRSCR
set ZCMD=zip -r %ANSWER%
for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" set ZCMD=!ZCMD! !FO%%a!
%ZCMD%
cmdwiz getch
exit /b 3

:NOT_SHIFTz

exit /b -1
goto :eof


:SET_ATTRIBS
cmd /C attrib !FO%CURRPOS%!>%MYTEMP%out.dat
for /F "tokens=*" %%a in (%MYTEMP%out.dat) do set INF="%%a"
set INF="!INF:~1,9!"
set CTMP=!INF:~2,1!& if "!CTMP!"==":" set INF=""
:NOATTRIBS
call listb.bat _GETANSWER "(%INF:~1,-1%) Set attributes (or ENTER):"
if not "!ANSWER!"=="" cmd /C attrib !ANSWER! !FO%CURRPOS%!>nul
goto :eof


:XCOPY
if not %~1 == # set ANSWER="%~1"
if %~1 == # set ANSWER=!DIR%DIROP%!
if exist "%ANSWER:~1,-1%" if not exist "%ANSWER:~1,-1%\" goto :eof
if not exist "%ANSWER:~1,-1%\" xcopy /Y /I /E "!FO%CURRPOS%:~1,-1!\*.*" "%ANSWER:~1,-1%" >nul & goto :eof
xcopy /Y /I /E !FO%CURRPOS%! "%ANSWER:~1,-1%\!FO%CURRPOS%:~1,-1!" >nul
goto :eof


:SHOWHELP
set EXTHLPC1=%HLPC1%
set EXTHLPC2=%HLPC2%
gotoxy k k "\n%EXTHLPC1%a: %EXTHLPC2%show file based on extension\n%EXTHLPC1%p: %EXTHLPC2%launch command prompt\n%EXTHLPC1%n/N: %EXTHLPC2%edit current/specified file\n%EXTHLPC1%Z/^Z: %EXTHLPC2%zip selected items / unzip file\n%EXTHLPC1%w: %EXTHLPC2%recursively search for file\n%EXTHLPC1%W/^W: %EXTHLPC2%search for specified text in all/specified files\n%EXTHLPC1%J: %EXTHLPC2%invoke file without clearing screen\n%EXTHLPC1%g: %EXTHLPC2%specify go path\n%EXTHLPC1%^C: %EXTHLPC2%copy specified to current path\n%EXTHLPC1%^D: %EXTHLPC2%recursively delete folder\n%EXTHLPC1%^A: %EXTHLPC2%show/set item attributes\n%EXTHLPC1%^X: %EXTHLPC2%copy (recursively) folder to specified place"
goto :eof


:LOCASE
for %%i in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") do call set "%1=%%%1:%%~i%%"
goto :eof

:CLRSCR
gotoxy 0 0 "\N" 7 0
goto :eof
