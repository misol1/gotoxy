@echo off

if %KEY% == 74 if not "!FT%CURRPOS%!"=="/" cmd /C !FO%CURRPOS%!&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&exit /b 1 & rem J

if not "%KEY%" == "97" goto NOT_a & rem a
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
if "%XTENSION%"==".c" cls&tcc -o "%XFILE%.exe" %1 & exit /b 3
if "%XTENSION%"==".C" cls&tcc -o "%XFILE%.exe" %1 & exit /b 3
if "%XTENSION%"==".zip" cls&unzip -l %1|less & exit /b 3
cls
less -f %1
exit /b 1

:NOT_a
if not "%KEY%" == "122" goto NOT_z & rem z
set XTENSION=%~x1
if not "%XTENSION%"==".zip" if not "%XTENSION%"==".ZIP" exit /b 0 & goto :eof
cls
unzip %1
exit /b 3

:NOT_z
if not "%KEY%" == "90" goto NOT_SHIFTz & rem Z
call :COUNTITEMS CNT Y& if !CNT! lss 1 call :SHOWBOTTOMBAR "No items selected." & exit /b 0 & goto :eof
call :GETANSWER "Zip archive name:"& if "!ANSWER!"=="" exit /b 0 & goto :eof
cls
set ZCMD=zip -r %ANSWER%
for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"==" " set ZCMD=!ZCMD! !FO%%a!
%ZCMD%
cmdwiz getch
exit /b 3

:NOT_SHIFTz

exit /b 0
goto :eof



:SHOWBOTTOMBAR
gotoxy 0 %BARPOS% %BAR% 0 %BARCOL%
if not "%~1"=="" gotoxy 1 %BARPOS% "%~1" %BARINFOCOL% %BARCOL% & set UPDATEBOTTOM=1
if "%~1"=="" set /a TP=%COLS%-14 & gotoxy !TP! %BARPOS% "F1/? for help" %BARINFOCOL% %BARCOL%
goto :eof

:YESNO
call :SHOWBOTTOMBAR %1
:YNLOOP
cmdwiz getch
set YNKEY=%ERRORLEVEL%
if %YNKEY% == 110 set ANSWER=N&set YNKEY=-1
if %YNKEY% == 121 set ANSWER=Y&set YNKEY=-1
if not %YNKEY%==-1 goto YNLOOP
call :SHOWBOTTOMBAR
goto :eof

:GETANSWER
gotoxy 0 0 %BAR% %BARINFOCOL% %BARCOL%
gotoxy 1 0 %1 %BARTEXTCOL% %BARCOL%
call :strlen LEN %1
set /a LEN+=2
gotoxy %LEN% 0
cmdwiz showcursor 1
set ANSWER=
set /P ANSWER=
cmdwiz showcursor 0
goto :eof

:strlen <resultVar> <stringVar>
(
  echo %~2>%MYTEMP%tmpLen.dat
  for %%? in (%MYTEMP%tmpLen.dat) do set /A %1=%%~z? - 2
  goto :eof
)

:COUNTITEMS <nof> <allowFolders>
set CNTI=0
if "%2" == "" for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"==" " if not "!FT%%a!"=="/" set /a CNTI+=1
if not "%2" == "" for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"==" " set /a CNTI+=1
set %1=%CNTI%
goto :eof
