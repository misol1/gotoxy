:: TaskMon (adaptation of Listb.bat) : Mikael Sollenborn 2017
@echo off
if "%~1"=="_YESNO" call :YESNO %2&goto :eof
if "%~1"=="_GETANSWER" call :GETANSWER %2 %3&goto :eof
if "%~1"=="_SHOWBOTTOMBAR" call :SHOWBOTTOMBAR %2&goto :eof
if "%~1"=="_COUNTITEMS" call :c %2 %3&goto :eof

if "%~1"=="/?" echo. & echo Usage: taskmon [width] [height] [+^|-] [[-]sortcolumn 0-9] [extendfile] & goto :eof

cls & cmdwiz showcursor 0

if defined __ goto :START
set __=.
set /a COLS=210 & if not "%1" == "" set /A COLS=%1
set /a LINES=50 & if not "%2" == "" set /A LINES=%2
set /a EXTINFO=0 & if "%~3" == "+" set /a EXTINFO=1
if %COLS% lss 80 set /a COLS=80
if %LINES% lss 20 set /a LINES=20
cls
if %EXTINFO%==0 mode 80,%LINES%
if %EXTINFO%==1 mode %COLS%,%LINES%

cmdgfx_input.exe m0W10x | call %0 %* | cmdgfx.exe "fbox u U 20 0,0,!COLS!,!LINES!" eSf:0,0,%COLS%,%LINES%

set __=
cls
cmdwiz showcursor 1 & mode 80,50
set COLS=&set LINES=&set CNT=&set UFG=&set UBG=&set EL=&set EXTINFO=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a ADAPTCPS=0 & set MAXCPS=0
set /a COLSPERSCR=1
if %MAXCPS%==0 set /a MAXCPS=%COLSPERSCR%
set OLDCOLSPERSCR=%COLSPERSCR%
set OLDCOLS=%COLS%
set BAR=""
for /L %%a in (1,1,%COLS%) do set BAR="!BAR:~1,-1! "
set /a BARPOS=%LINES%-1
set MYTEMP=
if not "%TMP%" == "" set MYTEMP=%TMP%\
if not "%TEMP%" == "" set MYTEMP=%TEMP%\
set UPDATEBOTTOM=0
set DIR1="%CD%"
set DIR0="%CD%"
set /a DIRP=0
set /a DIROP=1
set FCOUNTSUB=0
set /a REVSORT=0
set /a SORT=1 & if not "%~4" == "" set /a SORT=%~4 & (if !SORT! lss 0 set /a SORT=-!SORT!,REVSORT=1) & (if !SORT! gtr 9 set SORT=1)
call :SETSORTINDEX
set EXTEND=""&if not "%~5" == "" set EXTEND="%~5"
set CLIPB=
set HDIV=1
set DETAILS=0

set BARCOL=3
set BARTEXTCOL=F
set BARINFOCOL=0
set CURRCOL=1\F1
set FILECOL=u
set SCRBGCOL=U
set DIRCOL=b
set SELCOL=e
set PATHNOFCOL=B
set SELCHAR=\g07
set HLPC1=\B%SCRBGCOL%
set HLPC2=\7%SCRBGCOL%
set SEPBARCOL=7
if not %EXTEND% == "" if exist %EXTEND% call %EXTEND% _SET_COLORS

set SCHR="()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\] _ abcdefghijklmnopqrstuvwxyz{|}~"

set MOUSESUPPORT=1
if %MOUSESUPPORT%==1 cmdwiz getquickedit & set QE=!errorlevel!&cmdwiz setquickedit 0

set VIEWCMD="more"
set EDITCMD=start notepad
set NEWCMDWINDOW=start
if not %EXTEND% == "" if exist %EXTEND% call %EXTEND% _SET_VIEWERS

call :MAKEDIRLIST
call :SHOWLIST

:MAINLOOP
set /a KEY=0
set /p INPUT=
for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D,  M_EVENT=%%E, MX=%%F, MY=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L 2>nul ) 

if %MOUSESUPPORT%==1 if !M_EVENT! == 1 call :PROCESS_MOUSE & (if not !OLDCP! == !CURRPOS! set OLDPOS=!OLDCP!& call :UPDATELIST) & if !DBLCL!==0 if !KEY!==0 goto MAINLOOP

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

if %KEY% == 315 call :SHOWHELP & rem F1
if %KEY% == 27 goto EXITLIST & rem ESC
if %LKEY% == "?" call :SHOWHELP
if %LKEY% == "q" goto EXITLIST
if %LKEY% == "s" call :SORTOP
if %LKEY% == "p" %NEWCMDWINDOW%
if %LKEY% == "+" set /a EXTINFO=1-%EXTINFO% & echo "cmdgfx: fbox %FILECOL% %SCRBGCOL% 20 0,0,!COLS!,!LINES!" & (if !EXTINFO!==0 mode 80,%LINES%) & (if !EXTINFO!==1 mode %COLS%,%LINES%) & call :MAKEDIRLIST R& call :SHOWLIST

if %LKEY% == "x" call :KILL !FO%CURRPOS%! 2 U
if %LKEY% == "X" call :KILL !FO%CURRPOS%! 2 U Y
if %LKEY% == "a" call :KILL !FO%CURRPOS%! 1 U
if %LKEY% == "A" call :KILL !FO%CURRPOS%! 1 U Y

if %LKEY% == "m" start "Modules" cmd /C "cls & tasklist /M | %VIEWCMD%"
if %LKEY% == "l" start "Services" cmd /C "cls & tasklist /SVC | %VIEWCMD%"

if %KEY% == 24 call :MULTIDELOP & rem ^X

if not %EXTEND% == "" if exist %EXTEND% call :EXTENDOP

if %LKEY% == "u" call :MAKEDIRLIST&call :SHOWLIST

goto MAINLOOP

:EXITLIST
cmdwiz showcursor 1
if %MOUSESUPPORT%==1 cmdwiz setquickedit %QE%
endlocal
echo "cmdgfx: quit"
echo Q>inputflags.dat
goto :eof


:EXTENDOP
call %EXTEND% !FO%CURRPOS%!
set RESULT=%ERRORLEVEL%
if %RESULT% equ 1 call :SHOWLIST
if %RESULT% equ 2 call :MAKEDIRLIST&call :SHOWLIST
if %RESULT% equ 3 call :MAKEDIRLIST R&call :SHOWLIST
if %RESULT% equ 0 call :SHOWTOPBAR
goto :eof


:KILL
set TARGET=
for /f "tokens=%2" %%a in (%1) do set TARGET=%%a

set FORCE=&if "%~4" == "Y" set FORCE=/F

set METHOD=/PID&if "%~2" == "1" set METHOD=/IM

if not "%TARGET%" == "" taskkill %METHOD% %TARGET% %FORCE%>%MYTEMP%files.dat 2>&1 & if not !ERRORLEVEL! == 0 echo "cmdgfx: fbox %FILECOL% %SCRBGCOL% 20 0,0,!COLS!,!LINES!" & cmdwiz delay 100 & type %MYTEMP%files.dat & echo. & call :PAUSE

if "%~3" == "U" call :MAKEDIRLIST R & call :SHOWLIST
goto :eof



:PAUSE
echo Press a key to continue...
cmdwiz getch
goto :eof


:MULTIDELOP
call :COUNTITEMS CNT & if !CNT! lss 1 call :SHOWBOTTOMBAR "No items selected."&goto :eof
call :YESNO "Really force kill ALL selected items?(y/n) " 
if "!ANSWER!"=="N" goto :eof
for /L %%a in (0,1,%FCOUNTSUB%) do if not "!FS%%a!"=="" call :KILL !FO%%a! 2 - Y
call :MAKEDIRLIST R
call :SHOWLIST
goto :eof


:MARKITEM
:: cmdwiz getkeystate ctrl>nul
:: set /a TR = %ERRORLEVEL% ^& 1& if !TR! == 0 goto NOCTRLPRESSED
:: call :CLEARSELECTED
:: call :SHOWLIST
:: goto :eof
:NOCTRLPRESSED
if !FO%CURRPOS%!==".." goto SKIPITEM
set TC=!FS%CURRPOS%!
if "%TC%" == "" set FS%CURRPOS%=\%SELCOL%%SCRBGCOL%%SELCHAR%
if not "%TC%" == "" set FS%CURRPOS%=
:SKIPITEM
set OLDPOS=%CURRPOS%&set /a CURRPOS+=1 & call :UPDATELIST
goto :eof

:CLEARSELECTED
for /L %%a in (0,1,%FCOUNTSUB%) do set FS%%a=
goto :eof



:SORTOP
set /a NOFCH=9,MAXKEY=57 & if not %EXTINFO% == 1 set /a NOFCH=5,MAXKEY=53

set /a REVSORT=0
call :SHOWBOTTOMBAR "Sort using (n)ame, (u)nsorted, or (1-%NOFCH%) for column 1-%NOFCH% (- for reversed) ? "
:SORTLOOP
cmdwiz getch
set YNKEY=%ERRORLEVEL%
if %YNKEY% == 45 set /a REVSORT=1-%REVSORT%
if %YNKEY% == 110 set /a SORT=1, YNKEY=-1
if %YNKEY% == 117 set /a SORT=0, YNKEY=-1
if %YNKEY% geq 49 if %YNKEY% leq %MAXKEY% set /a SORT=%YNKEY%-49 + 1, YNKEY=-1
if not %YNKEY%==-1 goto SORTLOOP
call :SETSORTINDEX
call :MAKEDIRLIST
call :SHOWLIST
goto :eof


:SETSORTINDEX
if %SORT% lss 1 goto :eof
set /a CNT=0
for %%a in (1 27 36 53 65 78 94 145 158) do set /a CNT+=1 & if !CNT!==%SORT% set /a SORTINDEX=%%a
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
set REVS=
if not %REVSORT% == 0 set REVS=/R

del /Q tasks.dat>nul 2>nul
if %EXTINFO% == 1 tasklist -v>%MYTEMP%files.dat 2>nul
if not %EXTINFO% == 1 tasklist >%MYTEMP%files.dat 2>nul

set CNT=1
for /F "tokens=*" %%a in (%MYTEMP%files.dat) do set TEMP="%%a"& set TEMP=!TEMP:\=/!& (if !CNT! leq 2 set HEAD!CNT!=!TEMP!)&set /a CNT+=1
:: echo !HEAD1! & echo !HEAD2! & pause

set CNT=0
if not %SORT% == 0 more +3 %MYTEMP%files.dat|sort /+%SORTINDEX% %REVS% >%MYTEMP%tasks.dat
if %SORT% == 0 more +3 %MYTEMP%files.dat>%MYTEMP%tasks.dat
for /F "tokens=*" %%a in (%MYTEMP%tasks.dat) do set TEMP="%%a"& set TEMP=!TEMP:\=/!& set FO!CNT!=!TEMP!&set FT!CNT!=&set /a CNT+=1

set DIRCMD=%OLDDIRCMD%
set OLDDIRCMD=

set /a FCOUNT=%CNT%
set /a FCOUNTSUB=%CNT%-1
set /a LH=%LINES%-2 - 2

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
set X=1
set Y=1
set /a CX=%COLS%/%COLSPERSCR%
set /a CXM=%CX%-1-%HDIV%
set /a CXMM=%CXM%-1
set /a CNT=%PAGE%*(%COLSPERSCR%*%LH%)
set CC=0
set SHOWS=" %HEAD1:~1,-1%\n\%SEPBARCOL%%SCRBGCOL% %HEAD2:~1,-1%\n"
set /a ENDPRINT=%LH% + 1

set /a PARTPRINT=30

set /A FMCOUNT=%FCOUNT%-1
set /a CX=0

set /A BLH=%LINES%-2
echo "cmdgfx: fbox %FILECOL% %SCRBGCOL% 20 0,0,!COLS!,!LINES!"
call :SHOWBOTTOMBAR
call :SHOWTOPBAR

set /a OLDY=1
set X=0&for /L %%a in (%CNT%,1,%FMCOUNT%) do set BGCOL=%SCRBGCOL%&(if %%a==%CURRPOS% set BGCOL=%CURRCOL%)&set FGCOL=%FILECOL%&(if "!FT%%a!"=="/" set FGCOL=%DIRCOL%)&set SEL=\%FILECOL%%SCRBGCOL% &(if not "!FS%%a!"=="" set SEL=\%FILECOL%%SCRBGCOL%!FS%%a!)&set FNAME=!FO%%a!&(if %DETAILS%==1 set FNAME=!FL%%a!)&set FNAME=!FNAME:~1,-1!!FT%%a!&set OUTF=!FNAME:~0,%CXM%!&(if not "!OUTF!"=="!FNAME!" set OUTF=!FNAME:~0,%CXMM%!~)&set SHOWS="!SHOWS:~1,-1!!SEL!\!FGCOL!!BGCOL!!OUTF!\n"&set /a Y+=1&set /a PTEMP=!Y! %% %PARTPRINT%,PTEMP2=!Y! %% %ENDPRINT%&(if !PTEMP!==0 set SHOWS=!SHOWS: =_!& echo "cmdgfx: text !DIRCOL! %SCRBGCOL% 0 !SHOWS:~1,-1! 0,!OLDY!"& set /a OLDY=!Y!+2&set SHOWS="")&(set /a YP=!Y!+2&set SHOWS="!SHOWS:~1,-1!")&(if !PTEMP2!==0 goto OUTLOOP)&set /a CNT+=1

:OUTLOOP
set SHOWS=!SHOWS: =_!
echo "cmdgfx: text !DIRCOL! %SCRBGCOL% 0 !SHOWS:~1,-1! 0,!OLDY!"
set SHOWS=

goto :eof


:UPDATELIST
if %CURRPOS% lss 0 set CURRPOS=0
if %CURRPOS% gtr %FCOUNTSUB% set CURRPOS=%FCOUNTSUB%
set /a PAGE=%CURRPOS%/(%COLSPERSCR%*%LH%)
if not %PAGE% == %OLDPAGE% set OLDPAGE=%PAGE%&call :SHOWLIST&goto :eof
if %UPDATEBOTTOM%==1 set UPDATEBOTTOM=0&call :SHOWBOTTOMBAR

set /a CNT=%PAGE%*(%COLSPERSCR%*%LH%)
set CX=%COLS%/%COLSPERSCR%
set /a CXM=%CX%-1-%HDIV%
set /a CXMM=%CXM%-1
set CC=0
set SHOWS=""

set /a CURRTMP=%CURRPOS%+1
set BARINFO="Item_%CURRTMP%/%FCOUNT%"
echo "cmdgfx: line %BARINFOCOL% %BARCOL% 20 0,0,400,0 & text %BARTEXTCOL% %BARCOL% %SCRBGCOL% %BARINFO:~1,-1% 1,0" n

set /a N=%OLDPOS%-%CNT%
set /a NX=(%N%/%LH%)
set /a NX*=%CX%
set /a NY=(%N% %% %LH%)+3

set FGCOL=%FILECOL%%SCRBGCOL%&if "!FT%OLDPOS%!"=="/" set FGCOL=%DIRCOL%%SCRBGCOL%
set SEL=\%FILECOL%%SCRBGCOL% &if not "!FS%OLDPOS%!"=="" set SEL=\%FILECOL%%SCRBGCOL%!FS%OLDPOS%!
for %%a in (%OLDPOS%) do set FNAME=!FO%%a!&(if %DETAILS%==1 set FNAME=!FL%%a!)&set FNAME=!FNAME:~1,-1!!FT%%a!&set OUTF=!FNAME:~0,%CXM%!&(if not "!OUTF!"=="!FNAME!" set OUTF=!FNAME:~0,%CXMM%!~)

set SEL=%SEL: =_%
set OUTF=%OUTF: =_%
echo "cmdgfx: text %FILECOL% %SCRBGCOL% 0 %SEL%\%FGCOL%%OUTF% %NX%,%NY%" n

set /a N=%CURRPOS%-%CNT%
set /a NX=(%N%/%LH%)
set /a NX*=%CX%
set /a NY=(%N% %% %LH%)+3

set FGCOL=%FILECOL%%CURRCOL%&if "!FT%CURRPOS%!"=="/" set FGCOL=%DIRCOL%%CURRCOL%
set SEL=\%FILECOL%%SCRBGCOL% &if not "!FS%CURRPOS%!"=="" set SEL=\%FILECOL%%SCRBGCOL%!FS%CURRPOS%!
for %%a in (%CURRPOS%) do set FNAME=!FO%%a!&(if %DETAILS%==1 set FNAME=!FL%%a!)&set FNAME=!FNAME:~1,-1!!FT%%a!&set OUTF=!FNAME:~0,%CXM%!&(if not "!OUTF!"=="!FNAME!" set OUTF=!FNAME:~0,%CXMM%!~)

set SEL=%SEL: =_%
set OUTF=%OUTF: =_%
echo "cmdgfx: text %FILECOL% %SCRBGCOL% 0 %SEL%\%FGCOL%%OUTF% %NX%,%NY%" F
set SHOWS=
goto :eof


:SHOWTOPBAR
set /a CURRTMP=%CURRPOS%+1
set BARINFO="Item_%CURRTMP%/%FCOUNT%"
echo "cmdgfx: line %BARINFOCOL% %BARCOL% 20 0,0,400,0 & text %BARTEXTCOL% %BARCOL% %SCRBGCOL% %BARINFO:~1,-1% 1,0"
goto :eof


:SHOWBOTTOMBAR
set MSG="%~1"
set MSG=%MSG:\=/%
set MSG=%MSG: =_%
if not "%~1"=="" echo "cmdgfx: line %BARINFOCOL% %BARCOL% 20 0,%BARPOS%,400,%BARPOS% & text f %BARCOL% 0 %MSG:~1,-1% 1,%BARPOS%" & set UPDATEBOTTOM=1
if "%~1"=="" echo "cmdgfx: line %BARINFOCOL% %BARCOL% 20 0,%BARPOS%,400,%BARPOS% & text f %BARCOL% 0 F1/?_for_help__x=kill_+=extended_u=refresh 1,%BARPOS%"
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
mode 100,1
rem cmdwiz setwindowstyle clear standard 00C00000L
rem cmdwiz setwindowstyle set standard 08000000L

del /Q %MYTEMP%answer.dat>nul 2>nul
gotoxy 0 0 %BAR% %BARINFOCOL% 0
gotoxy 1 0 %1 %BARTEXTCOL% 0
cmdwiz stringlen %1
set LEN=%ERRORLEVEL%
set /a LEN+=2
gotoxy %LEN% 0
set ANSWER=
set /P ANSWER=
if not "%3"=="" call :STRIPQUOTES %ANSWER%
if not "%ANSWER%" == "" echo %ANSWER%>%MYTEMP%answer.dat
exit
goto :eof



:STRIPQUOTES
if not "%2"=="" goto :eof
set ANSWER=%~1
goto :eof


:SHOWHELP
echo "cmdgfx: fbox %FILECOL% %SCRBGCOL% 20 0,0,%COLS%,%LINES%" n
echo "cmdgfx: line %BARTEXTCOL% %BARCOL% 20 0,0,400,0 & text %BARTEXTCOL% %BARCOL% 0 TaskMon_Help 1,0"

set HELPTEXT="%HLPC1%Up/Down/Left/Right/Home/End/PageUp/PageDown: %HLPC2%navigate\n%HLPC1%Alt-key: %HLPC2%jump to next item starting with key\n%HLPC1%u: %HLPC2%refresh list/screen\n%HLPC1%s: %HLPC2%specify sorting order\n%HLPC1%+: %HLPC2%extended process info on/off\n%HLPC1%q: %HLPC2%quit\n\n%HLPC1%x: %HLPC2%kill process\n%HLPC1%X: %HLPC2%force kill process\n%HLPC1%a: %HLPC2%kill all processes with this name\n%HLPC1%A: %HLPC2%force kill all processes with this name\n%HLPC1%p: %HLPC2%launch command prompt\n%HLPC1%m: %HLPC2%show used modules for all processes\n%HLPC1%l: %HLPC2%show used services for all processes\n\n%HLPC1%Space: %HLPC2%select/deselect item\n%HLPC1%^X: %HLPC2%Force kill all selected items\n\n%HLPC1%Mouse click: %HLPC2%navigate to item\n%HLPC1%Mouse wheel: %HLPC2%switch page\n%HLPC1%Mouse right double click: %HLPC2%force kill process\n\n\n%HLPC1%Arguments: %HLPC2%taskmon [width] [height] [+|-] [[-]sortcolumn 0-9] [extendfile]\n"

set EXTHELPTEXT=""
if not %EXTEND% == "" if exist %EXTEND% call %EXTEND% _GET_EXTENDED_HELP
set HELPTEXT="%HELPTEXT:~1,-1%%EXTHELPTEXT:~1,-1%"

set HELPTEXT=%HELPTEXT: =_%

echo "cmdgfx: text 0 0 0 %HELPTEXT:~1,-1% 1,2"
set HELPTEXT=

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


:PROCESS_MOUSE
set OLDCP=%CURRPOS%
set DBLCL=0

set /a DL=%M_LB%
set /a DR=%M_RB%
if %M_DBL_LB%==1 set /a DL=2
if %M_DBL_RB%==1 set /a DR=2
if %M_WHEEL% gtr 0 set /a CURRPOS+=%LH%*%COLSPERSCR%
if %M_WHEEL% lss 0 set /a CURRPOS-=%LH%*%COLSPERSCR%

if %DL% == 0 if %DR% == 0 goto :eof
set /a PAGE=%CURRPOS%/(%COLSPERSCR%*%LH%)
set /a CPT=%LINES%-1
if %MY% geq %CPT% goto :eof
if %MY% leq 2 goto :eof
set /a CURRPOS=(%COLSPERSCR%*%LH%)*%PAGE%
set /a CPX=%MY%-3
set /a CURRPOS+=%CPX%
set /a CPT=%OLDCOLS%/%COLSPERSCR%
set /a CPT=%MX%/%CPT%
if %CPT% geq %COLSPERSCR% set /a CPT-=1
set /a CURRPOS+=%CPT%*%LH%
rem if %DL%==2 set KEY=120&set DBLCL=1
if %DR%==2 set KEY=88&set DBLCL=1
