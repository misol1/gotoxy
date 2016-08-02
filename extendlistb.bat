:: Keys free to extend: aghlnuwz, AGHJKLNOPQRWXZ, all special keys except ^B,^C,^F,^H,^L,^M,^T,^Y, 0-9, <,/,?, Space,^Space, Enter, F1, Up,Down,Left,Right,Home,End,PageUp,PageDown
:: Used in this file: a ^A ^D g J ^L n N w W ^W ^X Z ^Z

@echo off
if "%~1" == "_SHOW_EXTENDED_HELP" goto SHOWHELP
if "%~1" == "_SET_COLORS" goto SETCOLORS
if "%~1" == "_SET_VIEWERS" goto SETVIEWERS

set EDITCMD2=npp.bat
set EXTVIEW=less -f

if %LKEY% == "J" if not "!FT%CURRPOS%!"=="/" cmd /C "!FO%CURRPOS%!"&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&exit /b 1

if %LKEY% == "w" call listb.bat _GETANSWER "Search for file:"& if not "!ANSWER!"=="" set OLDDIRCMD=%DIRCMD%& set DIRCMD=&cls&dir /s /a /b|grep -i -F !ANSWER!|%EXTVIEW%& set DIRCMD=!OLDDIRCMD!&set OLDDIRCMD=&exit /b 1 & goto :eof
if %LKEY% == "W" call listb.bat _GETANSWER "Search for in files:"& if not "!ANSWER!"=="" cls&grep -n -i "!ANSWER!" *.*|%EXTVIEW%& exit /b 1 & goto :eof
:: ^W
if %KEY% == 23 call listb.bat _GETANSWER "Search for in files:"& if not "!ANSWER!"=="" set FANSW=!ANSWER!&call listb.bat _GETANSWER "File types:"& if not "!ANSWER!"=="" cls&grep -n -i "!FANSW!" !ANSWER!|%EXTVIEW%& exit /b 1 & goto :eof

if %LKEY% == "n" if not "!FT%CURRPOS%!"=="/" cmd /C %EDITCMD2% !FO%CURRPOS%!
if %LKEY% == "N" call listb.bat _GETANSWER "Edit file:"& if not "!ANSWER!"=="" cmd /C %EDITCMD2% !ANSWER!

if %LKEY% == "g" call listb.bat _GETANSWER "Go:"& if not "!ANSWER!"=="" set KEY=85&call g.bat !ANSWER!& exit /b 2 & goto :eof

:: ^L
if %KEY% == 12 call listb.bat _GETANSWER "Copy from:"& if not "!ANSWER!"=="" cmd /C copy /Y !ANSWER! .>nul& exit /b 3 & goto :eof

:: ^D
if %KEY% == 4 if "!FT%CURRPOS%!"=="/" if not !FO%CURRPOS%!==".." call listb.bat _YESNO "Really wipe out directory?(y/n) " & if "!ANSWER!"=="Y" cmd /C rd /Q /S !FO%CURRPOS%!& exit /b 3 & goto :eof

:: ^A
if %KEY% == 1 call :SET_ATTRIBS & exit /b 0 & goto :eof

:: ^X
if %KEY% == 24 if "!FT%CURRPOS%!"=="/" if not !FO%CURRPOS%!==".." call listb.bat _GETANSWER "Copy to (# for swap folder):"& if not "!ANSWER!"=="" call :XCOPY "!ANSWER!"& exit /b 3 & goto :eof

if not %LKEY% == "a" goto NOT_a
if "!FT%CURRPOS%!"=="/" goto :eof
set XTENSION=%~x1
set XFILE=%~n1
if /I "%XTENSION%"==".wav" cmdwiz playsound %1 & exit /b 0
if /I "%XTENSION%"==".gxy" cls&gotoxy 0 0 %1 u 0 c & cmdwiz getch & exit /b 1
if /I "%XTENSION%"==".mp3" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if /I "%XTENSION%"==".mod" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if /I "%XTENSION%"==".ans" cls&ansicon -t %1 & cmdwiz getch & exit /b 1
if /I "%XTENSION%"==".zip" cls&unzip -l %1|%EXTVIEW% & exit /b 3
if /I "%XTENSION%"==".jpg" %1 & exit /b 0
if /I "%XTENSION%"==".gif" %1 & exit /b 0
if /I "%XTENSION%"==".png" %1 & exit /b 0
if /I "%XTENSION%"==".pcx" %1 & exit /b 0
if /I "%XTENSION%"==".tga" %1 & exit /b 0
if /I "%XTENSION%"==".bmp" %1 & exit /b 0
cls
%EXTVIEW% %1
exit /b 1
:NOT_a

:: ^Z
if not %KEY% == 26 goto NOT_CTRLz
set XTENSION=%~x1
if not "%XTENSION%"==".zip" if not "%XTENSION%"==".ZIP" exit /b 0 & goto :eof
cls
unzip %1
cmdwiz getch
exit /b 3
:NOT_CTRLz

if not %LKEY% == "Z" goto NOT_Z
call listb.bat _COUNTITEMS CNT Y& if !CNT! lss 1 call listb.bat _SHOWBOTTOMBAR "No items selected." & exit /b 0 & goto :eof
call listb.bat _GETANSWER "Zip archive name:"& if "!ANSWER!"=="" exit /b 0 & goto :eof
cls
set ZCMD=zip -r %ANSWER%
for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" set ZCMD=!ZCMD! !FO%%a!
%ZCMD%
cmdwiz getch
exit /b 3

:NOT_Z

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
gotoxy k k "\n%EXTHLPC1%a: %EXTHLPC2%show file based on extension\n%EXTHLPC1%n/N: %EXTHLPC2%edit current/specified file\n%EXTHLPC1%Z/^Z: %EXTHLPC2%zip selected items / unzip file\n%EXTHLPC1%w: %EXTHLPC2%recursively search for file\n%EXTHLPC1%W/^W: %EXTHLPC2%search for specified text in all/specified files\n%EXTHLPC1%J: %EXTHLPC2%invoke file without clearing screen\n%EXTHLPC1%g: %EXTHLPC2%specify go path\n%EXTHLPC1%^L: %EXTHLPC2%copy specified to current path\n%EXTHLPC1%^D: %EXTHLPC2%recursively delete folder\n%EXTHLPC1%^A: %EXTHLPC2%show/set item attributes\n%EXTHLPC1%^X: %EXTHLPC2%copy (recursively) folder to specified place"
goto :eof


:SETCOLORS
::set HDIV=0
::set DETAILS=1

set CURRCOL=1\F1
::set BARCOL=4
::set BARTEXTCOL=F
::set BARINFOCOL=0
::set CURRCOL=C\FC
::set FILECOL=u
::set DIRCOL=C
::set SELCOL=E
::set PATHNOFCOL=E
::set SELCHAR=\g07
::set HLPC1=\CU
::set HLPC2=\7U
goto :eof


:SETVIEWERS
::set VIEWCMD=less -f
::set EDITCMD=b
::set NEWCMDWINDOW=start dosgo.bat
goto :eof
