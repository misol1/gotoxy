@echo off
if "%~1" == "SHOW_EXTENDED_HELP" goto SHOWHELP

set EDITCMD2=npp
set NEWWINDOWCMD=start dosgo.bat
set GCMD=g
set EXTVIEW=less -f

if %KEY% == 74 if not "!FT%CURRPOS%!"=="/" cmd /C "!FO%CURRPOS%!"&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&exit /b 1 & rem J

if %KEY% == 119 call listb.bat _GETANSWER "Search for file:"& if not "!ANSWER!"=="" cls&dir /s /-p /b|grep -i -F !ANSWER!|%EXTVIEW%& exit /b 1 & goto :eof & rem w
if %KEY% == 87 call listb.bat _GETANSWER "Search for in files:"& if not "!ANSWER!"=="" cls&grep -n -i "!ANSWER!" *.*|%EXTVIEW%& exit /b 1 & goto :eof & rem W
if %KEY% == 23 call listb.bat _GETANSWER "Search for in files:"& if not "!ANSWER!"=="" set FANSW=!ANSWER!&call listb.bat _GETANSWER "File types:"& if not "!ANSWER!"=="" cls&grep -n -i "!FANSW!" !ANSWER!|%EXTVIEW%& exit /b 1 & goto :eof & rem ^W

if %KEY% == 112 %NEWWINDOWCMD% & rem p

if %KEY% == 110 if not "!FT%CURRPOS%!"=="/" cmd /C %EDITCMD2% !FO%CURRPOS%! & rem n
if %KEY% == 78 call listb.bat _GETANSWER "Edit file:"& if not "!ANSWER!"=="" cmd /C %EDITCMD2% !ANSWER! & rem N

if %KEY% == 103 call listb.bat _GETANSWER "Go:"& if not "!ANSWER!"=="" set KEY=85&%GCMD% !ANSWER!& exit /b 2 & goto :eof & rem g

if %KEY% == 3 call listb.bat _GETANSWER "Copy from:"& if not "!ANSWER!"=="" cmd /C copy /Y !ANSWER! .>nul& exit /b 3 & goto :eof & rem ^C

if %KEY% == 4 if "!FT%CURRPOS%!"=="/" if not !FO%CURRPOS%!==".." call listb.bat _YESNO "Really wipe out directory?(y/n) " & if "!ANSWER!"=="Y" cmd /C rd /Q /S !FO%CURRPOS%!& exit /b 3 & goto :eof & rem ^D

if not %KEY% == 97 goto NOT_a & rem a
if "!FT%CURRPOS%!"=="/" goto :eof
set XTENSION=%~x1
set XFILE=%~n1
if "%XTENSION%"==".wav" cmdwiz playsound %1 & exit /b 0
if "%XTENSION%"==".WAV" cmdwiz playsound %1 & exit /b 0
if "%XTENSION%"==".gxy" cls&gotoxy 0 0 %1 0 0 c & cmdwiz getch & exit /b 1
if "%XTENSION%"==".mp3" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".MP3" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".mod" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".MOD" taskkill.exe /F /IM dlc.exe>nul 2>nul& start /MIN dlc.exe -p %1 0 0 c & exit /b 0
if "%XTENSION%"==".ans" cls&ansicon -t %1 & cmdwiz getch & exit /b 1
if "%XTENSION%"==".ANS" cls&ansicon -t %1 & cmdwiz getch & exit /b 1
if "%XTENSION%"==".zip" cls&unzip -l %1|%EXTVIEW% & exit /b 3
cls
%EXTVIEW% %1
exit /b 1

:NOT_a
if not %KEY% == 122 goto NOT_z & rem z
set XTENSION=%~x1
if not "%XTENSION%"==".zip" if not "%XTENSION%"==".ZIP" exit /b 0 & goto :eof
cls
unzip %1
exit /b 3

:NOT_z
if not %KEY% == 90 goto NOT_SHIFTz & rem Z
call listb.bat _COUNTITEMS CNT Y& if !CNT! lss 1 call listb.bat _SHOWBOTTOMBAR "No items selected." & exit /b 0 & goto :eof
call listb.bat _GETANSWER "Zip archive name:"& if "!ANSWER!"=="" exit /b 0 & goto :eof
cls
set ZCMD=zip -r %ANSWER%
for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" set ZCMD=!ZCMD! !FO%%a!
%ZCMD%
cmdwiz getch
exit /b 3

:NOT_SHIFTz

exit /b 0
goto :eof


:SHOWHELP
set EXTHLPC1=%HLPC1%
::set EXTHLPC1=\A0
gotoxy k k "\n%EXTHLPC1%a: %HLPC2%show file based on extension\n%EXTHLPC1%p: %HLPC2%launch command prompt\n%EXTHLPC1%n/N: %HLPC2%edit current/specified file\n%EXTHLPC1%Z/^Z: %HLPC2%unzip/zip file/selected files\n%EXTHLPC1%w: %HLPC2%recursively search for file\n%EXTHLPC1%W/^W: %HLPC2%search for specified text in all/specified files\n%EXTHLPC1%J: %HLPC2%invoke file without clearing screen\n%EXTHLPC1%g: %HLPC2%specify go path\n%EXTHLPC1%^C: %HLPC2%copy specified to current path\n%EXTHLPC1%^D: %HLPC2%recursively delete folder"
goto :eof
