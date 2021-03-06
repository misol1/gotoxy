:: LISTb : Mikael Sollenborn 2015-16
@echo off
if "%~1"=="_YESNO" call :YESNO %2&goto :eof
if "%~1"=="_GETANSWER" call :GETANSWER %2 %3&goto :eof
if "%~1"=="_SHOWBOTTOMBAR" call :SHOWBOTTOMBAR %2&goto :eof
if "%~1"=="_COUNTITEMS" call :COUNTITEMS %2 %3&goto :eof

setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
set COLS=80&if not "%2" == "" set /A COLS=%2&if !COLS! lss 80 set COLS=80
set LINES=50&if not "%3" == "" set /A LINES=%3&if !LINES! lss 20 set LINES=20
set ADAPTCPS=0&set MAXCPS=0
set COLSPERSCR=4&if not "%4" == "" set COLSPERSCR=%4&(if !COLSPERSCR! lss 0 set ADAPTCPS=1&set /A MAXCPS=-!COLSPERSCR!&set /A COLSPERSCR=-!COLSPERSCR!)&(if !COLSPERSCR! gtr 9 set COLSPERSCR=9)&if !COLSPERSCR! lss 1 set COLSPERSCR=1
if %MAXCPS%==0 set MAXCPS=%COLSPERSCR%
set OLDCOLSPERSCR=%COLSPERSCR%
cls
mode con lines=%LINES% cols=%COLS%
set OLDCOLS=%COLS%
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
set EXTEND=""&if not "%~5" == "" set EXTEND="%~5"
set CLIPB=
set HDIV=1
set DETAILS=0

set BARCOL=3
set BARTEXTCOL=F
set BARINFOCOL=0
set CURRCOL=1
cmdwiz getconsolecolor bg
if "%CURRCOL%" == "!ERRORLEVEL!" (if not "%CURRCOL%"=="0" set CURRCOL=0)&(if "%CURRCOL%"=="0" set CURRCOL=1)
set FILECOL=u
set DIRCOL=B
set SELCOL=4
set PATHNOFCOL=B
set SELCHAR=\g07
set HLPC1=\BU
set HLPC2=\7U
if not %EXTEND% == "" if exist %EXTEND% call %EXTEND% _SET_COLORS

set SCHR="()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\] _ abcdefghijklmnopqrstuvwxyz{|}~"

set MOUSESUPPORT=0
if /I "%~6" == "Y" set MOUSESUPPORT=1
if %MOUSESUPPORT%==1 cmdwiz getquickedit & set QE=!errorlevel!&cmdwiz setquickedit 0

set VIEWCMD="more # ^&cmdwiz getch"
set EDITCMD=start notepad
set NEWCMDWINDOW=start
if not %EXTEND% == "" if exist %EXTEND% call %EXTEND% _SET_VIEWERS

call :MAKEDIRLIST
call :SHOWLIST

:MAINLOOP
cmdwiz getch_and_mouse>nul
set MR=%ERRORLEVEL%
if %MR% == -1 goto MAINLOOP
set /a KEY=(%MR%^>^>22)
if %MOUSESUPPORT%==1 set /a MT=%MR% ^& 1 &if !MT! == 1 call :PROCESS_MOUSE & if !DBLCL!==0 if !KEY!==0 goto MAINLOOP

if %KEY% == 336 set OLDPOS=%CURRPOS%&set /a CURRPOS+=1 & call :UPDATELIST & goto MAINLOOP & rem DOWN
if %KEY% == 328 set OLDPOS=%CURRPOS%&set /a CURRPOS-=1 & call :UPDATELIST & goto MAINLOOP & rem UP
if %KEY% == 331 set OLDPOS=%CURRPOS%&set /a CURRPOS-=%LH% & call :UPDATELIST & goto MAINLOOP & rem LEFT
if %KEY% == 333 set OLDPOS=%CURRPOS%&set /a CURRPOS+=%LH% & call :UPDATELIST & goto MAINLOOP & rem RIGHT
if %KEY% == 327 set OLDPOS=%CURRPOS%&set CURRPOS=0& call :UPDATELIST & goto MAINLOOP & rem HOME
if %KEY% == 335 set OLDPOS=%CURRPOS%&set CURRPOS=%FCOUNT%& call :UPDATELIST & goto MAINLOOP & rem END
if %KEY% == 337 set OLDPOS=%CURRPOS%&set /a CURRPOS+=%LH%*%COLSPERSCR% & call :UPDATELIST & goto MAINLOOP & rem PAGEDOWN
if %KEY% == 329 set OLDPOS=%CURRPOS%&set /a CURRPOS-=%LH%*%COLSPERSCR% & call :UPDATELIST & goto MAINLOOP & rem PAGEUP
if %UPDATEBOTTOM%==1 set UPDATEBOTTOM=0&call :SHOWBOTTOMBAR

if %KEY% == 32 call :MARKITEM & goto MAINLOOP & rem SPACE

set LKEY=""
set OR=0&(if %KEY% gtr 126 set OR=1)&(if %KEY% lss 40 set OR=1)&if !OR!==1 goto NOALTPRESSED
set /A MKEY=%KEY%-40+1
set LKEY="!SCHR:~%MKEY%,1!"

cmdwiz getkeystate alt>nul
set /a TR = %ERRORLEVEL% ^& 1& if !TR! == 0 goto NOALTPRESSED
set /a TC=%CURRPOS%+1
for /L %%a in (%TC%,1,%FCOUNTSUB%) do set FTP=!FO%%a!&set FTP=!FTP:~1,1!&if "!FTP!"==%LKEY% set OLDPOS=%CURRPOS%& set CURRPOS=%%a& call :UPDATELIST & goto MAINLOOP
for /L %%a in (0,1,%FCOUNTSUB%) do set FTP=!FO%%a!&set FTP=!FTP:~1,1!&if "!FTP!"==%LKEY% set OLDPOS=%CURRPOS%& set CURRPOS=%%a& call :UPDATELIST & goto MAINLOOP
goto MAINLOOP
:NOALTPRESSED

if %KEY% == 13 if "!FT%CURRPOS%!"=="/" cd !FO%CURRPOS%!&call :MAKEDIRLIST&call :SHOWLIST & rem RETURN/^M (folder)
if %KEY% == 13 if not "!FT%CURRPOS%!"=="/" cls&set ANSWER=%VIEWCMD%&call :SPLITANSWER &cmd /C !ANSWER! !FO%CURRPOS%! !ANSWER2!&call :SHOWLIST R & rem RETURN/^M (file)

if %KEY% == 315 call :SHOWHELP & rem F1
if %KEY% == 27 goto EXITLIST & rem ESC
if %KEY% == 6 call :GETANSWER "Search for:" STRIPQUOTES& if not "!ANSWER!"=="" call :FINDOP & rem ^F
if %LKEY% == "?" call :SHOWHELP
if %LKEY% == "+" (if !DETAILS!==1 for /L %%a in (0,1,%FCOUNTSUB%) do set FL%%a=) & set /a DETAILS=1-%DETAILS% & (if !DETAILS!==1 set OLDCOLSPERSCR=%COLSPERSCR%) & (if !DETAILS!==0 set COLSPERSCR=%OLDCOLSPERSCR%) & call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "x" goto EXITLIST
if %LKEY% == "q" goto EXITLIST
if %LKEY% == "y"  set DIR%DIRP%="%CD%"&set /a DIRP=1-%DIRP% & cd /D !DIR%DIROP%! &set /a DIROP=1-!DIRP!&call :MAKEDIRLIST&call :SHOWLIST
if %LKEY% == "s" call :GETANSWER "Command:"& if not "!ANSWER!"=="" cls&cmdwiz showcursor 1&cmd /C "!ANSWER!"&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "S" call :GETANSWER "Command:"& if not "!ANSWER!"=="" cls&cmdwiz showcursor 1&cmd /C "!ANSWER!"&call :PAUSE \n&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "o" call :SORTOP
if %LKEY% == "p" %NEWCMDWINDOW%
if %LKEY% == "<" call :GOTOPARENT
if %KEY% == 8 call :GOTOPARENT & rem BACKSPACE/^H
if %KEY% geq 49 if %KEY% leq 57 set /a COLSPERSCR=%KEY%-48 & (if %DETAILS%==1 set DETAILS=0&for /L %%a in (0,1,%FCOUNTSUB%) do set FL%%a=) & call :SHOWLIST R & rem 1-9
if %LKEY% == "0" set /A ADAPTCPS=1-%ADAPTCPS%&if %DETAILS%==0 call :CALCNOFCOLUMNS&call :SHOWLIST

if %LKEY% == "i" if not "!FT%CURRPOS%!"=="/" call :LAUNCHFILE !FO%CURRPOS%!
if %LKEY% == "j" if not "!FT%CURRPOS%!"=="/" call :LAUNCHFILE !FO%CURRPOS%! 1
if %LKEY% == "I" call :GETANSWER "Action, # inserts filename:"& if not "!ANSWER!"=="" call :SPLITANSWER &cls&cmd /C !ANSWER! !FO%CURRPOS%! !ANSWER2!&call :PAUSE \n&mode con lines=%LINES% cols=%COLS%&cmdwiz showcursor 0&call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "e" if not "!FT%CURRPOS%!"=="/" cmd /C %EDITCMD% !FO%CURRPOS%!
if %LKEY% == "E" call :GETANSWER "Edit file:"& if not "!ANSWER!"=="" cmd /C %EDITCMD% !ANSWER! & call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "f" if not "!FT%CURRPOS%!"=="/" set OLDDIRCMD=%DIRCMD%& set DIRCMD=& cmd /C dir /-C /A !FO%CURRPOS%!|find !FO%CURRPOS%!>%MYTEMP%out.dat&set DIRCMD=!OLDDIRCMD!&set OLDDIRCMD=&for /F "tokens=*" %%a in (%MYTEMP%out.dat) do set INF="%%a "&call :SHOWBOTTOMBAR !INF!
if %LKEY% == "f" if "!FT%CURRPOS%!"=="/" if not !FO%CURRPOS%!==".." set OLDDIRCMD=%DIRCMD%& set DIRCMD=&cmd /C dir /A /-C>%MYTEMP%out.dat&set DIRCMD=!OLDDIRCMD!&set OLDDIRCMD=&for /F "tokens=1,2,3*" %%a in (%MYTEMP%out.dat) do if "%%d"==!FO%CURRPOS%! set INF="%%a  %%b    %%c          %%d"&call :SHOWBOTTOMBAR !INF!& rem f for folder (a hack)
if %LKEY% == "F" call :SHOWBOTTOMBAR !FO%CURRPOS%!
if %LKEY% == "d" if not "!FT%CURRPOS%!"=="/" call :YESNO "Really delete?(y/n) " & if "!ANSWER!"=="Y" cmd /C del !FO%CURRPOS%!&call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "r" call :GETANSWER "Rename to:"& if not "!ANSWER!"=="" rename !FO%CURRPOS%! "!ANSWER!"&call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "c" if not "!FT%CURRPOS%!"=="/" call :GETANSWER "Copy file to:" STRIPQUOTES& if not "!ANSWER!"=="" call :COPYOP !FO%CURRPOS%! "!ANSWER!" copy Copied " to !ANSWER!."& call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "m" if not !FO%CURRPOS%!==".." call :GETANSWER "Move file/folder to:" STRIPQUOTES& if not "!ANSWER!"=="" if exist "!ANSWER!\" call :COPYOP !FO%CURRPOS%! "!ANSWER!" move Moved " to !ANSWER!."& call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "k" call :GETANSWER "New folder:"& if not "!ANSWER!"=="" cmd /C mkdir !ANSWER! & call :MAKEDIRLIST R&call :SHOWLIST
if %LKEY% == "/" call :GETANSWER "Go to path:" STRIPQUOTES& if not "!ANSWER!"=="" call :SETPATHOP "!ANSWER!"
if %LKEY% == "Y" if not "!FT%CURRPOS%!"=="/" if not !DIR%DIROP%!=="%CD%" call :COPYOP !FO%CURRPOS%! !DIR%DIROP%! copy Copied " to alternate path."
if %KEY% == 25 if not !FO%CURRPOS%!==".." if not !DIR%DIROP%!=="%CD%" call :COPYOP !FO%CURRPOS%! !DIR%DIROP%! move Moved " to alternate path." & call :MAKEDIRLIST R&call :SHOWLIST & rem ^Y

if %LKEY% == "D" call :MULTIDELOP
if %LKEY% == "C" call :COUNTITEMS CNT& (if !CNT! lss 1 call :SHOWBOTTOMBAR "No files selected.") & if !CNT! geq 1 call :GETANSWER "Copy selected files to:" STRIPQUOTES& if not "!ANSWER!"=="" if exist "!ANSWER!\" call :MULTICOPYOP copy "!ANSWER!" SKIPYN
if %LKEY% == "M" call :COUNTITEMS CNT Y& (if !CNT! lss 1 call :SHOWBOTTOMBAR "No files selected.") & if !CNT! geq 1 call :GETANSWER "Move selected files to:" STRIPQUOTES& if not "!ANSWER!"=="" if exist "!ANSWER!\" call :MULTICOPYOP move "!ANSWER!" SKIPYN
if %LKEY% == "T" (if !DIR%DIROP%!=="%CD%" call :SHOWBOTTOMBAR "Both paths are the same.") & if not !DIR%DIROP%!=="%CD%" call :MULTICOPYOP copy !DIR%DIROP%!
if %KEY% == 20 (if !DIR%DIROP%!=="%CD%" call :SHOWBOTTOMBAR "Both paths are the same.") & if not !DIR%DIROP%!=="%CD%" call :MULTICOPYOP move !DIR%DIROP%!& rem ^T
if %KEY% == 9 call :MULTIOP & rem ^I

if %LKEY% == "v" if not !FO%CURRPOS%!==".." call :PUTINCB 3 &call :SHOWBOTTOMBAR "Cleared clipboard and added item."
if %LKEY% == "V" if not !FO%CURRPOS%!==".." call :PUTINCB 4 &call :SHOWBOTTOMBAR "Added item to clipboard."
if %LKEY% == "b" call :COUNTITEMS CNT Y & (if !CNT! lss 1 call :SHOWBOTTOMBAR "No files selected.") & if !CNT! geq 1 call :PUTINCB 1 &call :SHOWBOTTOMBAR "Cleared clipboard and added item(s)."
if %LKEY% == "B" call :CLIPBOARDCOPYOP copy
if %KEY% == 2 call :CLIPBOARDCOPYOP move& rem ^B
::if %KEY% == 22 call :COUNTITEMS CNT Y & (if !CNT! lss 1 call :SHOWBOTTOMBAR "No files selected.") & if !CNT! geq 1 call :PUTINCB 2 &call :SHOWBOTTOMBAR "Added item(s) to clipboard."& rem ^V

if not %EXTEND% == "" if exist %EXTEND% call :EXTENDOP

if %LKEY% == "U" call :MAKEDIRLIST&call :SHOWLIST

goto MAINLOOP

:EXITLIST
cmdwiz showcursor 1
if %MOUSESUPPORT%==1 cmdwiz setquickedit %QE%
set /a LINES-=1
gotoxy 0 !LINES!
endlocal&if %LKEY%=="x" cd "%CD%"
goto :eof


:CLIPBOARDCOPYOP
cmdwiz stringlen "%CLIPB%"
if !ERRORLEVEL! == 0 call :SHOWBOTTOMBAR "No items in clipboard."&goto :eof
if "%1"=="copy" call :YESNO "Really %1 ALL selected files from clipboard?(y/n) " 
if "%1"=="move" call :YESNO "Really %1 ALL selected files/folders from clipboard?(y/n) " 
if "!ANSWER!"=="N" goto :eof
if "%1"=="copy" for /D %%a in (%CLIPB%) do if not exist "%%a\" call :COPYOP %%a "." copy Copied "."
if "%1"=="move" for /D %%a in (%CLIPB%) do call :COPYOP %%a "." move Moved "."
call :MAKEDIRLIST R
call :SHOWLIST
set CLIPB=
goto :eof


:PUTINCB
if not %1 == 2 if not %1 == 4 set CLIPB=
if %1 geq 3 set CLIPB=!CLIPB! "%CD%\!FO%CURRPOS%:~1,-1!"&goto :eof
for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" set CLIPB=!CLIPB! "%CD%\!FO%%a:~1,-1!"
call :CLEARSELECTED
call :SHOWLIST
goto :eof


:GOTOPARENT
echo "%CD%">%MYTEMP%out.dat
set ANSWER=
for /F "delims=\ tokens=*" %%a in (%MYTEMP%out.dat) do set ANSWER=%%~nxa
cd ..&call :MAKEDIRLIST
if not "%ANSWER%" == "" call :FINDOP SKIPSHOW
call :SHOWLIST
goto :eof


:EXTENDOP
call %EXTEND% !FO%CURRPOS%!
set RESULT=%ERRORLEVEL%
if %RESULT% equ 1 call :SHOWLIST
if %RESULT% equ 2 call :MAKEDIRLIST&call :SHOWLIST
if %RESULT% equ 3 call :MAKEDIRLIST R&call :SHOWLIST
if %RESULT% equ 0 call :SHOWTOPBAR
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
gotoxy 0 k "%1Press a key to continue..." u U c
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
set ANSWER=%ANSWER:"=%
cmdwiz stringlen "%ANSWER%"&set LEN=!ERRORLEVEL!
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
if "%1"=="copy" for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" if not "!FT%%a!"=="/" call :COPYOP !FO%%a! %2 copy Copied "."
if "%1"=="move" for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" call :COPYOP !FO%%a! %2 move Moved "."
if "%1"=="move" call :MAKEDIRLIST R
if "%1"=="copy" call :CLEARSELECTED
call :SHOWLIST
goto :eof


:MARKITEM
cmdwiz getkeystate ctrl>nul
set /a TR = %ERRORLEVEL% ^& 1& if !TR! == 0 goto NOCTRLPRESSED
call :CLEARSELECTED
call :SHOWLIST
goto :eof
:NOCTRLPRESSED
if !FO%CURRPOS%!==".." goto SKIPITEM
set TC=!FS%CURRPOS%!
if "%TC%" == "" set FS%CURRPOS%=\%SELCOL%U%SELCHAR%
if not "%TC%" == "" set FS%CURRPOS%=
:SKIPITEM
set OLDPOS=%CURRPOS%&set /a CURRPOS+=1 & call :UPDATELIST
goto :eof

:CLEARSELECTED
for /L %%a in (0,1,%FCOUNTSUB%) do set FS%%a=
goto :eof


:COPYOP
set FPATH=%2
set FFILE=%1
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
if %YNKEY% == 115 set SORT=-SN&set YNKEY=-1
if %YNKEY% == 100 set SORT=-DN&set YNKEY=-1
if not %YNKEY%==-1 goto SORTLOOP
call :MAKEDIRLIST
call :SHOWLIST
goto :eof


:FINDOP
cmdwiz stringlen "%ANSWER%"&set LEN=!ERRORLEVEL!
for /L %%a in (0,1,%FCOUNTSUB%) do set FTP=!FO%%a!&set FTP=!FTP:~1,%LEN%!&if !FTP!==!ANSWER! set OLDPOS=%CURRPOS%& set CURRPOS=%%a& (if "%1"=="" call :UPDATELIST) & goto :eof
goto :eof


:MAKEDIRLIST
for /L %%a in (0,1,%FCOUNTSUB%) do set FO%%a=&set FT%%a=&set FS%%a=
if %DETAILS%==1 for /L %%a in (0,1,%FCOUNTSUB%) do set FL%%a=
if not "%1"=="R" set CURRPOS=0&set OLDPOS=0&set OLDPAGE=0

set OLDDIRCMD=%DIRCMD%
set DIRCMD=

dir /b /ad-l /O%SORT% >%MYTEMP%folders.dat 2>nul
set CNT=0
cmdwiz stringlen "%CD%"&set LEN=!ERRORLEVEL!
if %LEN% geq 4 set FO!CNT!=".."&set FT!CNT!=/&set /a CNT+=1
for /F "tokens=*" %%a in (%MYTEMP%folders.dat) do set FO!CNT!="%%a"&set FT!CNT!=/&set /a CNT+=1
dir /b /a-d-l /O%SORT%>%MYTEMP%files.dat 2>nul
for /F "tokens=*" %%a in (%MYTEMP%files.dat) do set FO!CNT!="%%a"&set FT!CNT!=&set /a CNT+=1

if %DETAILS%==0 goto SKIPDETAILS
set /a CNT2=0,FND=0
dir /a-l /-C /OG%SORT%>%MYTEMP%longfiles.dat 2>nul
for /F "tokens=*" %%a in (%MYTEMP%longfiles.dat) do (if !FND!==0 cmdwiz stringfind "%%a " " !FO0:~1,-1!" & if not !errorlevel!==-1 set FND=1) & if !FND!==1 set FNAME="%%a"&set FL!CNT2!=!FNAME:\=/!&set /a CNT2+=1
:SKIPDETAILS

set DIRCMD=%OLDDIRCMD%
set OLDDIRCMD=

set /a FCOUNT=%CNT%
set /a FCOUNTSUB=%CNT%-1
set /a LH=%LINES%-2

call :CALCNOFCOLUMNS
if %DETAILS%==1 set COLSPERSCR=1
goto :eof

:CALCNOFCOLUMNS
if %ADAPTCPS%==1 set /A COLSPERSCR=%FCOUNTSUB%/%LH%+1&if !COLSPERSCR! gtr %MAXCPS% set COLSPERSCR=%MAXCPS%
goto :eof


:SHOWLIST
if %CURRPOS% lss 0 set CURRPOS=0
if %CURRPOS% gtr %FCOUNTSUB% set CURRPOS=%FCOUNTSUB%
set /a PAGE=%CURRPOS%/(%COLSPERSCR%*%LH%)
if not %PAGE% == %OLDPAGE% set MODE=&set OLDPAGE=%PAGE%
set X=0
set Y=1
set /a CX=%COLS%/%COLSPERSCR%
set /a CXM=%CX%-1-%HDIV%
set /a CXMM=%CXM%-1
set /a CNT=%PAGE%*(%COLSPERSCR%*%LH%)
set CC=0
set SHOWS=""
set /a PARTPRINT=%LH%+1
set /A FMCOUNT=%FCOUNT%-1

set /A BLH=%LINES%-2&gotoxy 0 0 "\O0;1;%COLS%;!BLH!;"
call :SHOWBOTTOMBAR
call :SHOWTOPBAR

:: b3, ba, 7c, db
if %HDIV%==1 set /A NOFCP=%COLSPERSCR%-1&(if !NOFCP! lss 1 set NOFCP=1)&set BARS=""&for /L %%a in (1,1,!NOFCP!) do set /A X=%%a*%CX%-1 & set BARS="!BARS:~1,-1!\p!X!;1;\M%LH%{\gb3\n}"
if %HDIV%==1 gotoxy 0 0 %BARS% %BARCOL% U x&set BARS=

set X=0&for /L %%a in (%CNT%,1,%FMCOUNT%) do set BGCOL=U&(if %%a==%CURRPOS% set BGCOL=%CURRCOL%)&set FGCOL=%FILECOL%&(if "!FT%%a!"=="/" set FGCOL=%DIRCOL%)&set SEL= &(if not "!FS%%a!"=="" set SEL=!FS%%a!)&set FNAME=!FO%%a!&(if %DETAILS%==1 set FNAME=!FL%%a!)&set FNAME=!FNAME:~1,-1!!FT%%a!&set OUTF=!FNAME:~0,%CXM%!&(if not "!OUTF!"=="!FNAME!" set OUTF=!FNAME:~0,%CXMM%!~)&set SHOWS="!SHOWS:~1,-1!\!FGCOL!!BGCOL!!OUTF!!SEL!\n"&set /a Y+=1&set /a PTEMP=!Y! %% %PARTPRINT%&(if !PTEMP!==0 gotoxy 0 1 !SHOWS! !DIRCOL!&set SHOWS="")&(if !Y! gtr %LH% set Y=1&set /a X+=%CX%&set SHOWS="!SHOWS:~1,-1!\p!X!;!Y!"& set /a CC+=1&if !CC! geq %COLSPERSCR% goto OUTLOOP)&set /a CNT+=1

:OUTLOOP
gotoxy 0 1 %SHOWS% %DIRCOL%

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
set /a CXM=%CX%-1-%HDIV%
set /a CXMM=%CXM%-1
set CC=0
set SHOWS=""

set /a N=%OLDPOS%-%CNT%
set /a NX=(%N%/%LH%)
set /a NX*=%CX%
set /a NY=(%N% %% %LH%)+1

set FGCOL=%FILECOL%U&if "!FT%OLDPOS%!"=="/" set FGCOL=%DIRCOL%U
set SEL= &if not "!FS%OLDPOS%!"=="" set SEL=!FS%OLDPOS%!
for %%a in (%OLDPOS%) do set FNAME=!FO%%a!&(if %DETAILS%==1 set FNAME=!FL%%a!)&set FNAME=!FNAME:~1,-1!!FT%%a!&set OUTF=!FNAME:~0,%CXM%!&(if not "!OUTF!"=="!FNAME!" set OUTF=!FNAME:~0,%CXMM%!~)
set SHOWS="%SHOWS:~1,-1%\p%NX%;%NY%\%FGCOL%%OUTF%%SEL%"

set /a N=%CURRPOS%-%CNT%
set /a NX=(%N%/%LH%)
set /a NX*=%CX%
set /a NY=(%N% %% %LH%)+1

set FGCOL=%FILECOL%%CURRCOL%&if "!FT%CURRPOS%!"=="/" set FGCOL=%DIRCOL%%CURRCOL%
set SEL= &if not "!FS%CURRPOS%!"=="" set SEL=!FS%CURRPOS%!
for %%a in (%CURRPOS%) do set FNAME=!FO%%a!&(if %DETAILS%==1 set FNAME=!FL%%a!)&set FNAME=!FNAME:~1,-1!!FT%%a!&set OUTF=!FNAME:~0,%CXM%!&(if not "!OUTF!"=="!FNAME!" set OUTF=!FNAME:~0,%CXMM%!~)
set SHOWS="%SHOWS:~1,-1%\p%NX%;%NY%\%FGCOL%%OUTF%%SEL%"

gotoxy 0 0 %SHOWS% 0 0
goto :eof


:SHOWTOPBAR
set /a CURRTMP=%CURRPOS%+1
if not "%~1"=="U" goto NOUPDTB
set BARINFO="%CURRTMP%/%FCOUNT%"
gotoxy 6 0 "           \p5;0 %BARINFO:~1,-1%" %BARTEXTCOL% %BARCOL%
goto :eof
:NOUPDTB
set BARINFO="Item %CURRTMP%/%FCOUNT%"
set TCD="%CD:\=/%"
gotoxy 0 0 "%BAR:~1,-1%\p1;0%BARINFO:~1,-1%\p18;0%TCD:~1,-1%" %BARTEXTCOL% %BARCOL%
set /a TC=%COLS%-1&set /a TDP=%DIRP%+1&gotoxy !TC! 0 "!TDP!" %PATHNOFCOL% %BARCOL%
goto :eof


:SHOWBOTTOMBAR
set MSG="%~1"
set MSG=%MSG:\=/%
if not "%~1"=="" gotoxy 0 %BARPOS% "%BAR:~1,-1%\p1;%BARPOS%;%MSG:~1,-1%" %BARINFOCOL% %BARCOL%& set UPDATEBOTTOM=1
if "%~1"=="" set /a TP=%COLS%-14 & gotoxy 0 %BARPOS% "%BAR:~1,-1%\p!TP!;%BARPOS%;F1/? for help" %BARINFOCOL% %BARCOL%
set MSG=
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
cmdwiz stringlen %1&set LEN=!ERRORLEVEL!
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


:SHOWHELP
cls
gotoxy 0 0 "%BAR:~1,-1%\p1;0LISTb Help" %BARTEXTCOL% %BARCOL%
gotoxy 1 2 "%HLPC1%Up/Down/Left/Right/Home/End/PageUp/PageDown: %HLPC2%navigate\n%HLPC1%Alt-key: %HLPC2%jump to next file/folder starting with key\n%HLPC1%^F: %HLPC2%find file in list starting with specified string\n%HLPC1%1-9/0/+: %HLPC2%columns per screen / adaptive columns on/off / details on/off\n%HLPC1%U: %HLPC2%refresh file listing/screen\n\n%HLPC1%Return: %HLPC2%enter folder/show file\n%HLPC1%</BS: %HLPC2%enter parent folder\n%HLPC1%/: %HLPC2%enter specified path\n%HLPC1%y: %HLPC2%switch beteen paths 1 and 2\n%HLPC1%o: %HLPC2%specify sorting order\n%HLPC1%p: %HLPC2%launch command prompt\n%HLPC1%q/x: %HLPC2%quit in start/current folder\n\n%HLPC1%e/E: %HLPC2%edit current/specified file\n%HLPC1%i/j: %HLPC2%invoke file (j updates file list after)\n%HLPC1%I: %HLPC2%perform action with file/folder\n%HLPC1%f/F: %HLPC2%show file information / show full item name\n%HLPC1%S/s: %HLPC2%execute command with/without waiting for key after\n%HLPC1%r: %HLPC2%rename file/folder\n%HLPC1%k: %HLPC2%create new folder\n%HLPC1%c: %HLPC2%copy file to specified destination\n%HLPC1%m: %HLPC2%move file/folder to specified folder\n%HLPC1%Y/^Y: %HLPC2%copy/move file/folder to second path (see y)\n%HLPC1%v/V: %HLPC2%put item in clipboard with/without clearing clipboard (see B)\n\n%HLPC1%Space/^Space: %HLPC2%select file/folder / deselect all items\n%HLPC1%^I: %HLPC2%perform specified action with selected files\n%HLPC1%D: %HLPC2%delete selected files\n%HLPC1%C/M: %HLPC2%copy/move selected files/folders to specified folder\n%HLPC1%T/^T: %HLPC2%copy/move selected files/folders to second path (see y)\n%HLPC1%b/B/^B: %HLPC2%put selected items in clipboard / copy/move from clipboard\n\n%HLPC1%Arguments: %HLPC2%listb [path] [width] [height] [-][columns] [extendfile] [mouse]\n" 0 0 c
if not %EXTEND% == "" if exist %EXTEND% call %EXTEND% _SHOW_EXTENDED_HELP
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


:LAUNCHFILE
set FND=0&for %%a in (.exe .com .bat .cmd .EXE .COM .BAT .CMD) do cmdwiz stringfind %1 "%%a"&if !ERRORLEVEL! geq 0 set FND=1
::if %FND% == 0 call :SHOWBOTTOMBAR "Launched %~1."
if %FND% == 0 start ^"^" %1 & goto :eof

cmdwiz getexetype %1
if %ERRORLEVEL% == 3 start ^"^" %1 & goto :eof

cls&cmdwiz showcursor 1
cmd /C %1
call :PAUSE \n
mode con lines=%LINES% cols=%COLS%
cmdwiz showcursor 0
if not "%2"=="" call :MAKEDIRLIST R
call :SHOWLIST
goto :eof


:PROCESS_MOUSE
set OLDCP=%CURRPOS%
set DBLCL=0

set /a MT=%MR% ^& 2 &if !MT! geq 1 set DL=1
set /a MT=%MR% ^& 2 &if !MT! equ 0 set DL=0
set /a MT=%MR% ^& 4 &if !MT! geq 1 set DR=1
set /a MT=%MR% ^& 4 &if !MT! equ 0 set DR=0
set /a MT=%MR% ^& 8 &if !MT! geq 1 set DL=2
set /a MT=%MR% ^& 16 &if !MT! geq 1 set DR=2
set /a MT=%MR% ^& 32 &if !MT! geq 1 set /a CURRPOS+=%LH%*%COLSPERSCR%
set /a MT=%MR% ^& 64 &if !MT! geq 1 set /a CURRPOS-=%LH%*%COLSPERSCR%
set /a MX=(%MR%^>^>7) ^& 255
set /a MY=(%MR%^>^>15) ^& 127

if %DL% == 0 if %DR% == 0 goto NOPRESS
set /a PAGE=%CURRPOS%/(%COLSPERSCR%*%LH%)
set /a CPT=%LINES%-1
if %MY% geq %CPT% goto NOPRESS
if %MY% leq 0 goto NOPRESS
set /a CURRPOS=(%COLSPERSCR%*%LH%)*%PAGE%
set /a CPX=%MY%-1
set /a CURRPOS+=%CPX%
set /a CPT=%OLDCOLS%/%COLSPERSCR%
set /a CPT=%MX%/%CPT%
if %CPT% geq %COLSPERSCR% set /a CPT-=1
set /a CURRPOS+=%CPT%*%LH%
if %DL%==2 set KEY=13&set DBLCL=1
if %DR%==2 set KEY=105&set DBLCL=1
:NOPRESS

if not %OLDCP% == %CURRPOS% set OLDPOS=%OLDCP%& call :UPDATELIST
goto :eof
