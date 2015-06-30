:: LISTb : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
set COLS=81&if not "%2" == "" set COLS=%2&if !COLS! lss 80 set COLS=80
set LINES=50&if not "%3" == "" set LINES=%3&if !LINES! lss 20 set LINES=20
cls
mode con lines=%LINES% cols=%COLS%
set BAR=""
for /L %%a in (1,1,%COLS%) do set BAR="!BAR:~1,-1! "
set /a BARPOS=%LINES%-1
set MYTEMP=
if not "%TMP%" == "" set MYTEMP=%TMP%\
if not "%TEMP%" == "" set MYTEMP=%TEMP%\
set UPDATEBOTTOM=0
set DIR1="%CD%"
if not "%1" == "" cd /D %1 2>nul
set DIR0="%CD%"
set DIRP=0
set DIROP=1
set FCOUNTSUB=0
set SORT=N
set COLSPERSCR=3
set EXTEND=""&if not "%~4" == "" set EXTEND="%~4"

set BARCOL=3
set BARTEXTCOL=F
set BARINFOCOL=0
set CURRCOL=1
set FILECOL=7
set DIRCOL=B
set SELCOL=4
set PATHNOFCOL=B
set SELCHAR=\g07
set HLPC1=\B0
set HLPC2=\70

set VIEWCMD=less -f
set EDITCMD=b
set EDITCMD2=npp
set NEWWINDOWCMD=start dosgo.bat

call :MAKEDIRLIST
call :SHOWLIST

:MAINLOOP
cmdwiz getch
set KEY=%ERRORLEVEL%
if %KEY% == 336 set OLDPOS=%CURRPOS%&set /a CURRPOS+=1 & call :UPDATELIST & goto MAINLOOP & rem DOWN
if %KEY% == 328 set OLDPOS=%CURRPOS%&set /a CURRPOS-=1 & call :UPDATELIST & goto MAINLOOP & rem UP
if %KEY% == 331 set OLDPOS=%CURRPOS%&set /a CURRPOS-=%LH% & call :UPDATELIST & goto MAINLOOP & rem LEFT
if %KEY% == 333 set OLDPOS=%CURRPOS%&set /a CURRPOS+=%LH% & call :UPDATELIST & goto MAINLOOP & rem RIGHT
if %KEY% == 327 set OLDPOS=%CURRPOS%&set CURRPOS=0& call :UPDATELIST & goto MAINLOOP & rem HOME
if %KEY% == 335 set OLDPOS=%CURRPOS%&set CURRPOS=%FCOUNT%& call :UPDATELIST & goto MAINLOOP & rem END
if %KEY% == 337 set OLDPOS=%CURRPOS%&set /a CURRPOS+=%LH%*3 & call :UPDATELIST & goto MAINLOOP & rem PAGEDOWN
if %KEY% == 329 set OLDPOS=%CURRPOS%&set /a CURRPOS-=%LH%*3 & call :UPDATELIST & goto MAINLOOP & rem PAGEUP
if %UPDATEBOTTOM%==1 set UPDATEBOTTOM=0&call :SHOWBOTTOMBAR

cmdwiz getkeystate alt
set /a TR = %ERRORLEVEL% ^& 1& if !TR! == 0 goto NOALTPRESSED
if %KEY% gtr 255 goto NOALTPRESSED
call :dectohex result %KEY%
gotoxy 0 %BARPOS% "\g%result%" %BARCOL% %BARCOL%
cmdwiz saveblock %MYTEMP%keytemp 0 %BARPOS% 1 1 nocode
for /F "tokens=*" %%a in (%MYTEMP%keytemp.gxy) do set CHAR="%%a"&set CHAR=!CHAR:~4,1!
set /a TC=%CURRPOS%+1
for /L %%a in (%TC%,1,%FCOUNTSUB%) do set FTP=!FO%%a!&set FTP=!FTP:~1,1!&if !FTP!==%CHAR% set OLDPOS=%CURRPOS%& set CURRPOS=%%a& call :UPDATELIST & goto MAINLOOP
for /L %%a in (0,1,%FCOUNTSUB%) do set FTP=!FO%%a!&set FTP=!FTP:~1,1!&if !FTP!==%CHAR% set OLDPOS=%CURRPOS%& set CURRPOS=%%a& call :UPDATELIST & goto MAINLOOP
goto MAINLOOP
:NOALTPRESSED

if %KEY% == 13 if "!FT%CURRPOS%!"=="/" cd !FO%CURRPOS%!&call :MAKEDIRLIST&call :SHOWLIST & rem RETURN (folder)
if %KEY% == 13 if not "!FT%CURRPOS%!"=="/" cls&%VIEWCMD% !FO%CURRPOS%!&call :SHOWLIST R & rem RETURN (files)
if %KEY% == 60 cd ..&call :MAKEDIRLIST&call :SHOWLIST & rem <
if %KEY% == 120 goto EXITLIST & rem x
if %KEY% == 113 goto EXITLIST & rem q
if %KEY% == 27 goto EXITLIST & rem ESC
if %KEY% == 121 set DIR%DIRP%="%CD%"&set /a DIRP=1-%DIRP% & cd /D !DIR%DIROP%! &set /a DIROP=1-!DIRP!&call :MAKEDIRLIST&call :SHOWLIST & rem y
if %KEY% == 115 call :GETANSWER "Command:"& if not "!ANSWER!"=="" cls&cmd /C "!ANSWER!"&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&call :MAKEDIRLIST R&call :SHOWLIST & rem s
if %KEY% == 83 call :GETANSWER "Command:"& if not "!ANSWER!"=="" cls&cmdwiz showcursor 0&cmd /C "!ANSWER!"&call :PAUSE \n&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&call :MAKEDIRLIST R&call :SHOWLIST & rem S
if %KEY% == 6 call :GETANSWER "Search for:" STRIPQUOTES& if not "!ANSWER!"=="" call :FINDOP & rem ^F
if %KEY% == 111 call :SORTOP & rem o
if %KEY% == 63 call :SHOWHELP & rem ?
if %KEY% == 571 call :SHOWHELP & rem F1
if %KEY% == 112 %NEWWINDOWCMD% & rem p
if %KEY% geq 49 if %KEY% leq 53 set /a COLSPERSCR=%KEY%-48 & call :SHOWLIST R & rem 1-5

if %KEY% == 105 if not "!FT%CURRPOS%!"=="/" cls&cmdwiz showcursor 1&cmd /C "!FO%CURRPOS%!"&call :PAUSE \n&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&call :SHOWLIST & rem i
if %KEY% == 106 if not "!FT%CURRPOS%!"=="/" cls&cmdwiz showcursor 1&cmd /C !FO%CURRPOS%!&call :PAUSE \n&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&call :MAKEDIRLIST R&call :SHOWLIST & rem j
if %KEY% == 73 call :GETANSWER "Action, # inserts filename:"& if not "!ANSWER!"=="" call :SPLITANSWER &cls&cmd /C !ANSWER! !FO%CURRPOS%! !ANSWER2!&call :PAUSE \n&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&call :MAKEDIRLIST R&call :SHOWLIST & rem I
if %KEY% == 110 if not "!FT%CURRPOS%!"=="/" cmd /C %EDITCMD2% !FO%CURRPOS%! & rem n
if %KEY% == 78 call :GETANSWER "Edit file:"& if not "!ANSWER!"=="" cmd /C %EDITCMD2% !ANSWER! & rem N
if %KEY% == 101 if not "!FT%CURRPOS%!"=="/" cmd /C %EDITCMD% !FO%CURRPOS%! & rem e
if %KEY% == 69 call :GETANSWER "Edit file:"& if not "!ANSWER!"=="" cmd /C %EDITCMD% !ANSWER! & call :MAKEDIRLIST R&call :SHOWLIST & rem E
if %KEY% == 102 if not "!FT%CURRPOS%!"=="/" cmd /C dir /-C !FO%CURRPOS%!|find !FO%CURRPOS%!>%MYTEMP%out.dat&for /F "tokens=*" %%a in (%MYTEMP%out.dat) do set INF="%%a "&call :SHOWBOTTOMBAR !INF!& rem f
if %KEY% == 102 if "!FT%CURRPOS%!"=="/" set KEY=70& rem f for folder
if %KEY% == 70 call :SHOWBOTTOMBAR !FO%CURRPOS%! & rem F
if %KEY% == 100 if not "!FT%CURRPOS%!"=="/" call :YESNO "Really delete?(y/n) " & if "!ANSWER!"=="Y" cmd /C del !FO%CURRPOS%!&call :MAKEDIRLIST R&call :SHOWLIST & rem d
if %KEY% == 114 call :GETANSWER "Rename to:"& if not "!ANSWER!"=="" rename !FO%CURRPOS%! "!ANSWER!"&call :MAKEDIRLIST R&call :SHOWLIST & rem r
if %KEY% == 99 if not "!FT%CURRPOS%!"=="/" call :GETANSWER "Copy file to:" STRIPQUOTES& if not "!ANSWER!"=="" call :COPYOP %CURRPOS% "!ANSWER!" copy Copied " to !ANSWER!."& call :MAKEDIRLIST R&call :SHOWLIST & rem c
if %KEY% == 109 if not !FO%CURRPOS%!==".." call :GETANSWER "Move file/folder to:" STRIPQUOTES& if not "!ANSWER!"=="" if exist "!ANSWER!\" call :COPYOP %CURRPOS% "!ANSWER!" move Moved " to !ANSWER!."& call :MAKEDIRLIST R&call :SHOWLIST & rem m
if %KEY% == 89 if not "!FT%CURRPOS%!"=="/" if not !DIR%DIROP%!=="%CD%" call :COPYOP %CURRPOS% !DIR%DIROP%! copy Copied " to alternate path." & rem Y
if %KEY% == 25 if not !FO%CURRPOS%!==".." if not !DIR%DIROP%!=="%CD%" call :COPYOP %CURRPOS% !DIR%DIROP%! move Moved " to alternate path." & call :MAKEDIRLIST R&call :SHOWLIST & rem ^Y
if %KEY% == 107 call :GETANSWER "New folder:"& if not "!ANSWER!"=="" cmd /C mkdir !ANSWER! & call :MAKEDIRLIST R&call :SHOWLIST & rem k
if %KEY% == 47 call :GETANSWER "Go to path:" STRIPQUOTES& if not "!ANSWER!"=="" call :SETPATHOP "!ANSWER!" & rem /

if %KEY% == 32 call :MARKITEM & rem SPACE
if %KEY% == 9 call :MULTIOP & rem ^I
if %KEY% == 68 call :MULTIDELOP & rem D
if %KEY% == 84 if not !DIR%DIROP%!=="%CD%" call :MULTICOPYOP copy !DIR%DIROP%!& rem T
if %KEY% == 20 if not !DIR%DIROP%!=="%CD%" call :MULTICOPYOP move !DIR%DIROP%!& rem ^T
if %KEY% == 67 call :COUNTITEMS CNT& if !CNT! geq 1 call :GETANSWER "Copy selected files to:" STRIPQUOTES& if not "!ANSWER!"=="" if exist "!ANSWER!\" call :MULTICOPYOP copy "!ANSWER!" SKIPYN & rem C
if %KEY% == 77 call :COUNTITEMS CNT Y& if !CNT! geq 1 call :GETANSWER "Move selected files to:" STRIPQUOTES& if not "!ANSWER!"=="" if exist "!ANSWER!\" call :MULTICOPYOP move "!ANSWER!" SKIPYN & rem M

if not %EXTEND% == "" if exist %EXTEND% call :EXTENDOP

if %KEY% == 85 call :MAKEDIRLIST&call :SHOWLIST & rem U

goto MAINLOOP

:EXITLIST
cmdwiz showcursor 1
set /a LINES-=1
gotoxy 0 !LINES!
endlocal&if %KEY%==120 cd "%CD%"
goto :eof


:EXTENDOP
call %EXTEND% !FO%CURRPOS%!
set RESULT=%ERRORLEVEL%
if %RESULT% equ 1 call :SHOWLIST
if %RESULT% equ 2 call :MAKEDIRLIST&call :SHOWLIST
if %RESULT% equ 3 call :MAKEDIRLIST R&call :SHOWLIST
call :SHOWTOPBAR
goto :eof


:SETPATHOP
set BS=\
if "%~1" == "\" set BS=
if "%~1" == "/" set BS=
set NEWPATH="%~1"
set NEWPATH=%NEWPATH:/=\%
if not exist "%NEWPATH:~1,-1%%BS%" call :SHOWBOTTOMBAR "No such path" & goto :eof
cd /D %NEWPATH%
call :MAKEDIRLIST R
call :SHOWLIST
goto :eof


:PAUSE
gotoxy k k "%1Press a key to continue..." 7 0 c
cmdwiz getch
goto :eof


:MULTIOP
call :COUNTITEMS CNT & if !CNT! lss 1 call :SHOWBOTTOMBAR "No files selected."&goto :eof
call :GETANSWER "Action on selected files, # inserts filename:"
if "!ANSWER!"=="" goto :eof
call :SPLITANSWER
cls
for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" if not "!FT%%a!"=="/" cmd /C !ANSWER! !FO%%a! !ANSWER2!
call :PAUSE \n
mode con lines=%LINES% cols=%COLS%
cmdwiz showcursor 0
call :MAKEDIRLIST R
call :SHOWLIST
goto :eof

:SPLITANSWER
set SPLITPOS=-1
set ANSWER2=
call :strlen LEN "%ANSWER%"
for /L %%a in (0,1,%LEN%) do if "!ANSWER:~%%a,1!"=="#" set SPLITPOS=%%a
set /a A2=%SPLITPOS%+1
if not %SPLITPOS%==-1 set ANSWER2=!ANSWER:~%A2%!&set ANSWER=!ANSWER:~0,%SPLITPOS%!
goto :eof


:MULTIDELOP
call :COUNTITEMS CNT & if !CNT! lss 1 call :SHOWBOTTOMBAR "No files selected."&goto :eof
call :YESNO "Really delete ALL selected files?(y/n) " 
if "!ANSWER!"=="N" goto :eof
for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" if not "!FT%%a!"=="/" cmd /C del /Q !FO%%a!
call :MAKEDIRLIST R
call :SHOWLIST
goto :eof


:MULTICOPYOP
if not "%3"=="" goto SKIPYN
set ALLOWFOLDERS=&if "%1"=="move" set ALLOWFOLDERS=Y
call :COUNTITEMS CNT %ALLOWFOLDERS%& if !CNT! lss 1 call :SHOWBOTTOMBAR "No items selected."&goto :eof
if "%1"=="copy" call :YESNO "Really %1 ALL selected files to second path?(y/n) " 
if "%1"=="move" call :YESNO "Really %1 ALL selected files/folders to second path?(y/n) " 
if "!ANSWER!"=="N" goto :eof
:SKIPYN
if "%1"=="copy" for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" if not "!FT%%a!"=="/" call :COPYOP %%a %2 copy Copied "."
if "%1"=="move" for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" call :COPYOP %%a %2 move Moved "."
if "%1"=="move" call :MAKEDIRLIST R
if "%1"=="copy" call :CLEARSELECTED
call :SHOWLIST
goto :eof


:MARKITEM
cmdwiz getkeystate ctrl
set /a TR = %ERRORLEVEL% ^& 1& if !TR! == 0 goto NOCTRLPRESSED
call :CLEARSELECTED
call :SHOWLIST
goto :eof
:NOCTRLPRESSED
if !FO%CURRPOS%!==".." goto SKIPITEM
set TC=!FS%CURRPOS%!
if "%TC%" == "" set FS%CURRPOS%=\%SELCOL%0%SELCHAR%
if not "%TC%" == "" set FS%CURRPOS%=
:SKIPITEM
set OLDPOS=%CURRPOS%&set /a CURRPOS+=1 & call :UPDATELIST
goto :eof

:CLEARSELECTED
for /L %%a in (0,1,%FCOUNTSUB%) do set FS%%a=
goto :eof


:COPYOP
set FPATH=%2
set FFILE=!FO%1!
if exist "%FPATH:~1,-1%\%FFILE:~1,-1%" call :YESNO "Overwrite?(y/n) (%FFILE:~1,-1%)" & if "!ANSWER!"=="N" goto :eof
if not exist "%FPATH:~1,-1%\" if exist %FPATH% call :YESNO "Overwrite?(y/n) (%FPATH:~1,-1%)" & if "!ANSWER!"=="N" goto :eof
%3 /Y %FFILE% %FPATH%>nul
call :SHOWBOTTOMBAR "%~4 file%~5"
goto :eof


:SORTOP
call :SHOWBOTTOMBAR "Sort using (n)ame, (e)xtension, (s)ize, or (d)date? "
:SORTLOOP
cmdwiz getch
set YNKEY=%ERRORLEVEL%
if %YNKEY% == 110 set SORT=N&set YNKEY=-1
if %YNKEY% == 101 set SORT=EN&set YNKEY=-1
if %YNKEY% == 115 set SORT=SN&set YNKEY=-1
if %YNKEY% == 100 set SORT=DN&set YNKEY=-1
if not %YNKEY%==-1 goto SORTLOOP
call :MAKEDIRLIST
call :SHOWLIST
goto :eof


:FINDOP
call :strlen LEN !ANSWER!
for /L %%a in (0,1,%FCOUNTSUB%) do set FTP=!FO%%a!&set FTP=!FTP:~1,%LEN%!&if !FTP!==!ANSWER! set OLDPOS=%CURRPOS%& set CURRPOS=%%a& call :UPDATELIST& goto :eof
goto :eof


:MAKEDIRLIST
for /L %%a in (0,1,%FCOUNTSUB%) do set FO%%a=&set F%%a=&set FT%%a=&set FS%%a=
if not "%1"=="R" set CURRPOS=0&set OLDPOS=0&set OLDPAGE=0
dir /-p /b /ad  >%MYTEMP%folders.dat
set CNT=0
call :strlenIncludeCitation LEN "%CD%"
if %LEN% geq 6 set F!CNT!=".."&set FO!CNT!=".."&set FT!CNT!=/&set /a CNT+=1
for /F "tokens=*" %%a in (%MYTEMP%folders.dat) do set FNAME="%%a"&set FO!CNT!=!FNAME!&set F!CNT!=!FNAME:^&=^^^&!&set FT!CNT!=/&set /a CNT+=1
dir /-p /b /a-d /O%SORT%>%MYTEMP%files.dat
for /F "tokens=*" %%a in (%MYTEMP%files.dat) do set FNAME="%%a"&set FO!CNT!=!FNAME!&set F!CNT!=!FNAME:^&=^^^&!&set /a CNT+=1

set /a FCOUNT=%CNT%
set /a FCOUNTSUB=%CNT%-1
set /a LH=%LINES%-2
goto :eof


:SHOWLIST
if %CURRPOS% lss 0 set CURRPOS=0
if %CURRPOS% gtr %FCOUNTSUB% set CURRPOS=%FCOUNTSUB%
set /a PAGE=%CURRPOS%/(%COLSPERSCR%*%LH%)
if not %PAGE% == %OLDPAGE% set MODE=&set OLDPAGE=%PAGE%
cls
call :SHOWBOTTOMBAR
call :SHOWTOPBAR
set X=0
set Y=1
set CX=%COLS%/%COLSPERSCR%
set /a CXM=%CX%-1
set /a CNT=%PAGE%*(%COLSPERSCR%*%LH%)
set CC=0
set SHOWS=""
set /a PARTPRINT=%LH%+1
:SHOWLOOP
set BGCOL=0&if %CNT%==%CURRPOS% set BGCOL=%CURRCOL%
set FGCOL=%FILECOL%&if "!FT%CNT%!"=="/" set FGCOL=%DIRCOL%
set SEL= &if not "!FS%CNT%!"=="" set SEL=!FS%CNT%!
set FNAME=!F%CNT%!
set FNAME=%FNAME:~1,-1%!FT%CNT%!
set SHOWS="%SHOWS:~1,-1%\%FGCOL%%BGCOL%!FNAME:~0,%CXM%!%SEL%\n"
set /a Y+=1
set /a PTEMP=%Y% %% %PARTPRINT%& if !PTEMP!==0 gotoxy 0 1 %SHOWS% %DIRCOL% 0&set SHOWS=""

if %Y% gtr %LH% set Y=1&set /a X+=%CX%&set SHOWS="%SHOWS:~1,-1%\p!X!;!Y!"& set /a CC+=1&if !CC! geq %COLSPERSCR% goto OUTLOOP
set /a CNT+=1
if %CNT% lss %FCOUNT% goto SHOWLOOP

:OUTLOOP
gotoxy 0 1 %SHOWS% %DIRCOL% 0
goto :eof


:UPDATELIST
if %CURRPOS% lss 0 set CURRPOS=0
if %CURRPOS% gtr %FCOUNTSUB% set CURRPOS=%FCOUNTSUB%
set /a PAGE=%CURRPOS%/(%COLSPERSCR%*%LH%)
if not %PAGE% == %OLDPAGE% set OLDPAGE=%PAGE%&call :SHOWLIST&goto :eof
if %UPDATEBOTTOM%==1 set UPDATEBOTTOM=0&call :SHOWBOTTOMBAR
call :SHOWTOPBAR U
set /a CNT=%PAGE%*(%COLSPERSCR%*%LH%)
set CX=%COLS%/%COLSPERSCR%
set /a CXM=%CX%-1
set CC=0
set SHOWS=""

set /a N=%OLDPOS%-%CNT%
set /a NX=(%N%/%LH%)
set /a NX*=%CX%
set /a NY=(%N% %% %LH%)+1

set FGCOL=%FILECOL%0&if "!FT%OLDPOS%!"=="/" set FGCOL=%DIRCOL%0
set SEL= &if not "!FS%OLDPOS%!"=="" set SEL=!FS%OLDPOS%!
set FNAME=!F%OLDPOS%!
set FNAME=%FNAME:~1,-1%!FT%OLDPOS%!
set SHOWS="%SHOWS:~1,-1%\p%NX%;%NY%\%FGCOL%!FNAME:~0,%CXM%!%SEL%"

set /a N=%CURRPOS%-%CNT%
set /a NX=(%N%/%LH%)
set /a NX*=%CX%
set /a NY=(%N% %% %LH%)+1

set FGCOL=%FILECOL%%CURRCOL%&if "!FT%CURRPOS%!"=="/" set FGCOL=%DIRCOL%%CURRCOL%
set SEL= &if not "!FS%CURRPOS%!"=="" set SEL=!FS%CURRPOS%!
set FNAME=!F%CURRPOS%!
set FNAME=%FNAME:~1,-1%!FT%CURRPOS%!
set SHOWS="%SHOWS:~1,-1%\p%NX%;%NY%\%FGCOL%!FNAME:~0,%CXM%!%SEL%"
 
gotoxy 0 0 %SHOWS% 0 0
goto :eof


:SHOWTOPBAR
set /a CURRTMP=%CURRPOS%+1
if not "%~1"=="U" goto NOUPDTB
set BARINFO="%CURRTMP%/%FCOUNT%"
gotoxy 6 0 "a          \p5;0 %BARINFO:~1,-1%" %BARTEXTCOL% %BARCOL%
goto :eof
:NOUPDTB
set BARINFO="File %CURRTMP%/%FCOUNT%"
set TCD="%CD:\=/%"
gotoxy 0 0 "%BAR:~1,-1%\p1;0%BARINFO:~1,-1%\p18;0%TCD:~1,-1%" %BARTEXTCOL% %BARCOL%
set /a TC=%COLS%-1&set /a TDP=%DIRP%+1&gotoxy !TC! 0 "!TDP!" %PATHNOFCOL% %BARCOL%
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
if not "%2"=="" call :STRIPQUOTES %ANSWER%
call :SHOWTOPBAR
goto :eof

:STRIPQUOTES
if not "%2"=="" goto :eof
set ANSWER=%~1
goto :eof


:strlen <resultVar> <stringVar>
(
  echo %~2>%MYTEMP%tmpLen.dat
  for %%? in (%MYTEMP%tmpLen.dat) do set /A %1=%%~z? - 2
  goto :eof
)

:strlenIncludeCitation <resultVar> <stringVar>
(
  echo %2>%MYTEMP%tmpLen.dat
  for %%? in (%MYTEMP%tmpLen.dat) do set /A %1=%%~z? - 2
  goto :eof
)

:dectohex <result> <value>
if "%2" == "" goto :eof
set P1=
if %2 lss 16 if "%3" == "" goto BELOW16
set /a P1=%2 / 16
call :DECTOHEX2 %P1%
set P1=%P%
:BELOW16
set /a P2=%2 %% 16
call :DECTOHEX2 %P2%
set P2=%P%

set %1=%P1%%P2%
set P1=&set P2=&set P=
goto :eof

:DECTOHEX2
if %1 geq 16 set P=0&goto :eof
if %1 lss 0 set P=0&goto :eof
if %1 leq 9 set P=%1&goto :eof
if %1 == 10 set P=A&goto :eof
if %1 == 11 set P=B&goto :eof
if %1 == 12 set P=C&goto :eof
if %1 == 13 set P=D&goto :eof
if %1 == 14 set P=E&goto :eof
if %1 == 15 set P=F&goto :eof
goto :eof


:SHOWHELP
cls
gotoxy 0 0 "%BAR:~1,-1%\p1;0LISTb Help" %BARTEXTCOL% %BARCOL%
gotoxy 1 2 "%HLPC1%Up/Down/Left/Right/Home/End/PageUp/PageDown: %HLPC2%navigate\n%HLPC1%Alt-key: %HLPC2%jump to next file/folder starting with key\n%HLPC1%^F: %HLPC2%find file in list starting with specified string\n%HLPC1%1-5: %HLPC2%number of columns per screen\n%HLPC1%U: %HLPC2%refresh file listing/screen\n\n%HLPC1%Return: %HLPC2%enter folder/show file\n%HLPC1%<: %HLPC2%enter parent folder\n%HLPC1%/: %HLPC2%enter specified path\n%HLPC1%y: %HLPC2%switch beteen paths 1 and 2\n%HLPC1%o: %HLPC2%specify sorting order\n%HLPC1%p: %HLPC2%launch command prompt\n%HLPC1%q/x: %HLPC2%quit in start/current folder\n\n%HLPC1%e/E: %HLPC2%edit current/specified file\n%HLPC1%n/N: %HLPC2%edit current/specified file (option2)\n%HLPC1%i: %HLPC2%invoke file\n%HLPC1%j: %HLPC2%invoke file and reread file list after\n%HLPC1%I: %HLPC2%perform action with file/folder\n%HLPC1%f: %HLPC2%show file information\n%HLPC1%F: %HLPC2%show full file/folder name\n%HLPC1%S/s: %HLPC2%execute command with/without waiting for key after\n%HLPC1%r: %HLPC2%rename file/folder\n%HLPC1%k: %HLPC2%create new folder\n%HLPC1%c: %HLPC2%copy file to specified destination\n%HLPC1%m: %HLPC2%move file/folder to specified folder\n%HLPC1%Y/^Y: %HLPC2%copy/move file/folder to second path (see y)\n\n%HLPC1%Space: %HLPC2%select file/folder\n%HLPC1%^Space: %HLPC2%deselect all items\n%HLPC1%^I: %HLPC2%perform specified action with selected files\n%HLPC1%D: %HLPC2%delete selected files\n%HLPC1%C/M: %HLPC2%copy/move selected files/folders to specified folder\n%HLPC1%T/^T: %HLPC2%copy move selected files/folders to second path (see y)\n\n%HLPC1%Arguments: %HLPC2%list [path] [columns] [rows] [extend path\\name]\n"
call :SHOWBOTTOMBAR "Press ESCAPE to go back."
:HELPLOOP
cmdwiz getch
if not %ERRORLEVEL% == 27 goto HELPLOOP
call :SHOWLIST
goto :eof


:COUNTITEMS <nof> <allowFolders>
set CNTI=0
if "%2" == "" for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" if not "!FT%%a!"=="/" set /a CNTI+=1
if not "%2" == "" for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" set /a CNTI+=1
set %1=%CNTI%
goto :eof
