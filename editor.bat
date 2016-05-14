:: Editor : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
set COLS=80
set ROWS=52
set LOADNAME=
set FGCOL=7
set BGCOL=0
set CKEY=176
call :DECTOHEX %CKEY% CHAR
set CCHAR=\g%CHAR%
set SAVEPX=-1
set SAVEPY=-1
set FILLPX=-1
set FILLPY=-1
set DL=0
set DR=0
set DRAWSTATE=1
set INS=
set INSV=0
set DRAWINSTANT=0
call :TOGGLEINS
set MFUNC1=1
set MFUNC2=1
set OLDMX=-1&set OLDMY=-1
if not "%~1" == "" set LOADNAME=%~1
if not "%2" == "" set COLS=%2
if not "%3" == "" set ROWS=%3
mode con lines=%ROWS% cols=%COLS%
set /a YBOUND=%ROWS%-2
color 07
cls
if "%LOADNAME%" == "" goto NOFILE
if not exist "%LOADNAME%" goto NOFILE
for /F "tokens=* usebackq" %%i in ("%LOADNAME%") do set inf="%%i"
if n%inf%==n gotoxy 0 0 "%LOADNAME%"&goto :NOFILE & rem Apparently too big to put in env var 
set inf=%inf:\-=\A1x\r%
gotoxy 0 0 %inf%
:NOFILE
call :PRINTSEPARATOR
call :PRINTSTATUS
cmdwiz quickedit 0
cmdwiz showcursor 1

:LOOP
set KEY=0
cmdwiz getch_or_mouse>nul
set MR=%ERRORLEVEL%
if %MR%==-1 goto SKIP
set /a MT=%MR% ^& 1 &if !MT! == 0 goto MOUSEINPUT
set /a KEY=%MR%/2
goto NOMOUSE
:MOUSEINPUT
set /a MX=(%MR%^>^>10) ^& 255
set /a MY=%MR%^>^>19
set /a MT=%MR% ^& 2 &if !MT! geq 1 set DL=1
set /a MT=%MR% ^& 2 &if !MT! equ 0 set DL=0
set /a MT=%MR% ^& 4 &if !MT! geq 1 set DR=1
set /a MT=%MR% ^& 4 &if !MT! equ 0 set DR=0
set /a MT=%MR% ^& 32 &if !MT! geq 1 call :ROLL -1&call :PRINTSTATUS&goto :SKIP
set /a MT=%MR% ^& 64 &if !MT! geq 1 call :ROLL 1&call :PRINTSTATUS&goto :SKIP
if %MY% geq %YBOUND% goto SKIP
if %DR% == 0 if %DL% == 0 set OR=0&(if %MX% neq %OLDMX% set OR=1)&(if %MY% neq %OLDMY% set OR=1)& if !OR!==1 gotoxy %MX% %MY%&set OLDMX=%MX%&set OLDMY=%MY%
if %DR% == 0 goto NORIGHTMB
if %MFUNC2% == 1 gotoxy %MX% %MY% " " 7 0
if %MFUNC2% == 2 gotoxy %MX% %MY% "x" 10 1
if %MFUNC2% == 3 call :PICKUP 1
if %MFUNC2% == 4 call :PICKUP 2
:NORIGHTMB
if %DL% geq 1 if %DRAWSTATE%==1 gotoxy %MX% %MY% %CCHAR% %FGCOL% %BGCOL%
if %DL% geq 1 if %DRAWSTATE%==2 gotoxy %MX% %MY% %CCHAR% v V
if %DL% geq 1 if %DRAWSTATE%==3 gotoxy %MX% %MY% \G %FGCOL% %BGCOL%
if %DL% geq 1 if %DRAWSTATE%==4 gotoxy %MX% %MY% %CCHAR% %FGCOL% V
goto SKIP
:NOMOUSE
if %KEY% == 8 cmdwiz getkeystate shift>nul&if !ERRORLEVEL!==1 gotoxy k k "x" 10 1 & set KEY=331 & rem BACKSPACE + shift
if %KEY% == 8 cmdwiz getkeystate shift>nul&if !ERRORLEVEL!==0 gotoxy k k " " %FGCOL% %BGCOL% & set KEY=331 & rem BACKSPACE
if %KEY% == 328 cmdwiz getcursorpos y&set /a NY=!ERRORLEVEL!-1&gotoxy k !NY!&goto SKIP & rem UP
if %KEY% == 336 cmdwiz getcursorpos y&set /a NY=!ERRORLEVEL!+1&set KEY=-1&if !NY! lss %YBOUND% gotoxy k !NY! & rem DOWN
if %KEY% == 331 cmdwiz getcursorpos x&set /a NX=!ERRORLEVEL!-1&gotoxy !NX! k&goto SKIP & rem LEFT
if %KEY% == 333 cmdwiz getcursorpos x&set /a NX=!ERRORLEVEL!+1&gotoxy !NX! k&goto SKIP & rem RIGHT
if %KEY% == 13 set KEY=%CKEY% & rem RETURN
if %KEY% == 339 cmdwiz getkeystate shift>nul&if !ERRORLEVEL!==1 gotoxy k k "x" 10 1 %INS%& goto SKIP & rem shift+DEL
if %KEY% == 339 cmdwiz getkeystate shift>nul&if !ERRORLEVEL!==0 gotoxy k k " " 7 0 %INS%& goto SKIP & rem DEL
if %KEY% == 338 call :TOGGLEINS & goto SKIP & rem INS
if %KEY% == 9 call :PICKUP 1 & goto SKIP & rem TAB
if %KEY% == 327 call :PICKUP 2 & goto SKIP & rem HOME
if %KEY% == 329 call :PICKUP 4 & goto SKIP & rem PGUP
if %KEY% == 337 call :PICKUP 5 & goto SKIP & rem PGDN
if %KEY% == 335 call :PICKUP 3 & goto SKIP & rem END
if %KEY% == 315 call :LOAD & goto SKIP & rem F1
if %KEY% == 340 call :LOAD 1& goto SKIP & rem shift-F1
if %KEY% == 316 call :SAVE & goto SKIP & rem F2
if %KEY% == 317 set /a FGCOL+=1&call :PRINTSTATUS&goto SKIP & rem F3
if %KEY% == 318 set /a BGCOL+=1&call :PRINTSTATUS&goto SKIP & rem F4
if %KEY% == 319 set DRAWSTATE=1&goto SKIP & rem F5
if %KEY% == 320 set DRAWSTATE=2&goto SKIP & rem F6
if %KEY% == 321 set DRAWSTATE=3&goto SKIP & rem F7
if %KEY% == 322 set DRAWSTATE=4&goto SKIP & rem F8
if %KEY% == 342 set /a FGCOL-=1&call :PRINTSTATUS&goto SKIP & rem shift-F3
if %KEY% == 343 set /a BGCOL-=1&call :PRINTSTATUS&goto SKIP & rem shift-F4
if %KEY% == 345 call :FILL&goto SKIP & rem shift-F6
if %KEY% == 346 call :SAVE edcpp& goto SKIP & rem shift-F7
if %KEY% == 347 if exist edcpp.gxy call :LOAD 1 edcpp.gxy& goto SKIP & rem shift-F8
if %KEY% == 367 if exist edcpp.gxy call :LOAD 0 edcpp.gxy& goto SKIP & rem alt-F8
if %KEY% == 348 set /A DRAWINSTANT=1-%DRAWINSTANT%&goto SKIP & rem shift-F9
if %KEY% == 350 set CKEY=219&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F1
if %KEY% == 351 set CKEY=178&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F2
if %KEY% == 352 set CKEY=177&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F3
if %KEY% == 353 set CKEY=176&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F4
if %KEY% == 354 set CKEY=220&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F5
if %KEY% == 355 set CKEY=223&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F6
if %KEY% == 356 set CKEY=254&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F7
if %KEY% == 357 set CKEY=7&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F8
if %KEY% == 358 set CKEY=1&call :MODCHAR 0 &set KEY=!CKEY!&if %DRAWINSTANT%==0 goto SKIP & rem ctrl-F9
if %KEY% == 359 call :SELCHAR&goto SKIP & rem ctrl-F10

if %KEY% == 323 call :PRINTCOORDS & goto SKIP & rem F9
if %KEY% == 324 call :SHOWHELP&goto SKIP & rem F10
if %KEY% == 393 call :MODCHAR -1 & goto SKIP & rem ctrl-F11
if %KEY% == 394 call :MODCHAR 1 & goto SKIP & rem ctrl-F12
if %KEY% == 389 set KEY=-1 & set /a MFUNC1+=1&if !MFUNC1! geq 4 set MFUNC1=1 & rem F11
if %KEY% == 390 set KEY=-1 & set /a MFUNC2+=1&if !MFUNC2! geq 5 set MFUNC2=1 & rem F12
if %KEY% geq 48 if %KEY% leq 57 cmdwiz getkeystate alt>nul&if !ERRORLEVEL!==1 set /a FGCOL=%KEY%-48&call :PRINTSTATUS& goto SKIP & rem 0-9 with alt
if %KEY% geq 97 if %KEY% leq 102 cmdwiz getkeystate alt>nul&if !ERRORLEVEL!==1 set /a FGCOL=%KEY%-97+10&call :PRINTSTATUS& goto SKIP & rem a-f with alt
if %KEY% geq 65 if %KEY% leq 70 cmdwiz getkeystate alt>nul&if !ERRORLEVEL!==1 set /a BGCOL=%KEY%-65+10&call :PRINTSTATUS& goto SKIP & rem A-F with alt
if %KEY% geq 33 if %KEY% leq 41 cmdwiz getkeystate alt>nul&if !ERRORLEVEL!==1 set /a BGCOL=%KEY%-32&call :PRINTSTATUS& goto SKIP & rem 0-9 with shift+alt
if %KEY% == 61 cmdwiz getkeystate alt>nul&if !ERRORLEVEL!==1 set /a BGCOL=0&call :PRINTSTATUS& goto SKIP & rem 0 with shift+alt
if %KEY% == 207 cmdwiz getkeystate alt>nul&if !ERRORLEVEL!==1 set /a BGCOL=4&call :PRINTSTATUS& goto SKIP & rem 4 with shift+alt
if %KEY% == 47 cmdwiz getkeystate alt>nul&if !ERRORLEVEL!==1 set /a BGCOL=7&call :PRINTSTATUS& goto SKIP & rem 7 with shift+alt

if %KEY% lss 0 goto SKIP
if %KEY% gtr 255 goto SKIP
if %KEY% == 27 goto SKIP

call :DECTOHEX %KEY% CHAR
if %DRAWSTATE%==1 gotoxy k k \g%CHAR% %FGCOL% %BGCOL% %INS%
if %DRAWSTATE%==2 gotoxy k k \g%CHAR% v V %INS%
if %DRAWSTATE%==3 gotoxy k k \G %FGCOL% %BGCOL% %INS%
if %DRAWSTATE%==4 gotoxy k k \g%CHAR% %FGCOL% V %INS%
set SAVEPX=-1
set SAVEPY=-1

:SKIP
if not %KEY% == 27 goto LOOP

cls
endlocal
if exist edcpp.gxy del /Q edcpp.gxy>nul
cmdwiz quickedit 1
goto :eof

:DECTOHEX <in> <out> <noTrailZero>
if "%~2"=="" goto :eof
if "%D2H%"=="" set D2H=0123456789ABCDEF
set /A HB=%1/16
set /A LB=%1%%16
set OR=0&(if %HB% geq 16 set OR=1)&(if %HB% lss 0 set OR=1)&(if %LB% lss 0 set OR=1)&if !OR!==1 set %2=0&goto :eof
if not "%~3"=="" if %HB%==0 set %2=!D2H:~%LB%,1!&goto :eof
set %2=!D2H:~%HB%,1!!D2H:~%LB%,1!
goto :eof

:PRINTSEPARATOR
gotoxy 0 %YBOUND% "\M%COLS%{-}" 7 0 rx
goto :eof

:PRINTSTATUS
set /a Y=%ROWS%-1
if %FGCOL% geq 16 set FGCOL=0
if %BGCOL% geq 16 set BGCOL=0
if %FGCOL% lss 0 set FGCOL=15
if %BGCOL% lss 0 set BGCOL=15
set CNT=-1&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set /A CNT+=1&if %FGCOL%==!CNT! set FGCH=%%a
set CNT=-1&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set /A CNT+=1&if %BGCOL%==!CNT! set BGCH=%%a
set /A TMPX=%COLS%-10
gotoxy 1 %Y% "Current:[\0%FGCH% \0%BGCH% \70] [\%FGCH%%BGCH%%CCHAR%\70 %CCHAR%] \M140{ }\p%TMPX%;k;F10: help" 7 0 rx
goto :eof

:PRINTCOORDS
cmdwiz getcursorpos x
set X=!ERRORLEVEL!
cmdwiz getcursorpos y
set Y=!ERRORLEVEL!

set /a YP=%ROWS%-1
gotoxy 69 %YP% " X:%X% Y:%Y%      " 7 0 r
cmdwiz getch
set /A TMPX=%COLS%-10
set /a TMPY=%ROWS%-1
gotoxy %TMPX% %TMPY% "F10: help" 7 0 r
goto :eof

:SELCHAR
cmdwiz saveblock edittmp 0 0 %COLS% %ROWS%
gotoxy 0 0 "\M36{\M160{ \}\n}" u U x
set CNT=-1&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set /A CNT+=1&set HX!CNT!=%%a
set UT=&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set UT=!UT!%%a\g20\g20\g20\g20
gotoxy 3 0 "%UT%\n\n" 9 0
set UT=&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set UT=!UT!%%a\n\n
gotoxy 0 2 "%UT%\n\n" 9 0
set UT=&for /L %%a in (0,1,255) do set /A HB=%%a/16&set /A LB=%%a%%16&for %%b in (!HB!) do for %%c in (!LB!) do set HEXV=!HX%%b!!HX%%c!&set UT=!UT!\g!HEXV!\g20\g20\g20\g20&set /A DIV=(%%a+1)%%16&if !DIV!==0 set UT=!UT!\n\n
gotoxy 3 2 "%UT%" 15 0 c
gotoxy 0 k&set CHAR=&set /P CHAR=? 
if "%CHAR%"=="" goto SKIPSELCH
set CCHAR=\g%CHAR%
set CH1=%CHAR:~0,1%
set CH2=%CHAR:~1,1%
set CNT=-1&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set /A CNT+=1&if "%CH1%"=="%%a" set /A CKEY=!CNT!*16
set CNT=-1&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set /A CNT+=1&if "%CH2%"=="%%a" set /A CKEY=!CKEY!+!CNT!
:SKIPSELCH
gotoxy 0 0 edittmp.gxy
del /Q edittmp.gxy
call :PRINTSTATUS
goto :eof

:PICKUP
cmdwiz getcursorpos x
set X=!ERRORLEVEL!
cmdwiz getcursorpos y
set Y=!ERRORLEVEL!

if %1 geq 3 goto SKIP_PCHAR
cmdwiz getcharat %X% %Y%
set CKEY=!ERRORLEVEL!
call :DECTOHEX %CKEY% CHAR
set CCHAR=\g%CHAR%
if %1 == 1 goto FINPICKUP

:SKIP_PCHAR
if %1 == 5 goto SKIP_PFG
cmdwiz getcolorat f %X% %Y%
set FGCOL=!ERRORLEVEL!

:SKIP_PFG
if %1 == 4 goto FINPICKUP
cmdwiz getcolorat b %X% %Y%
set BGCOL=!ERRORLEVEL!

:FINPICKUP
call :PRINTSTATUS
goto :eof


:MODCHAR
set /a CKEY+=%1
if %CKEY% gtr 255 set CKEY=1
if %CKEY% lss 1 set CKEY=255
call :DECTOHEX %CKEY% CHAR
set CCHAR=\g%CHAR%
call :PRINTSTATUS
goto :eof


:LOAD
cmdwiz getcursorpos x
set X=!ERRORLEVEL!
cmdwiz getcursorpos y
set Y=!ERRORLEVEL!
if not "%2"=="" set FNAME=%2&goto GOTNAME
gotoxy 1 %YBOUND% "                                                                                                                                      "
gotoxy 1 %YBOUND%
set FNAME=&set /P FNAME=Load file(omit .gxy): 
gotoxy %X% %Y%
for %%a in (%FNAME%) do set FNAME="%%~da%%~pa%%~na.gxy"&if not exist !FNAME! call :PRINTSEPARATOR&goto :eof
goto :eof
:GOTNAME
set inf=
for /F "tokens=* usebackq" %%i in (%FNAME%) do set inf="%%i"
if n%inf%==n gotoxy %X% %Y% "%FNAME%" 0 0 r&goto :SKIPENV & rem Apparently too big to put in env var 
if not "%1"=="1" set inf=!inf:\-=\A1x\r!
gotoxy %X% %Y% %inf% 0 0 r
:SKIPENV
call :PRINTSEPARATOR
call :PRINTSTATUS
goto :eof


:FILL
cmdwiz getcursorpos x
set X=!ERRORLEVEL!
cmdwiz getcursorpos y
set Y=!ERRORLEVEL!

if %FILLPX%==-1 set FILLPX=%X%&set FILLPY=%Y%& goto :eof

if %X% lss %FILLPX% goto SKIPFILL
if %Y% lss %FILLPY% goto SKIPFILL
set FILLPX2=%X%
set FILLPY2=%Y%

set /A W=%FILLPX2%-%FILLPX%+1
set /A H=%FILLPY2%-%FILLPY%+1

if %DRAWSTATE%==1 gotoxy %FILLPX% %FILLPY% "\M%H%{\M%W%{\g%CHAR%\}\n}" %FGCOL% %BGCOL% x
if %DRAWSTATE%==2 gotoxy %FILLPX% %FILLPY% "\M%H%{\M%W%{\g%CHAR%\}\n}" v V x
if %DRAWSTATE%==3 gotoxy %FILLPX% %FILLPY% "\M%H%{\M%W%{\G\}\n}" %FGCOL% %BGCOL% x
if %DRAWSTATE%==4 gotoxy %FILLPX% %FILLPY% "\M%H%{\M%W%{\g%CHAR%\}\n}" %FGCOL% V x

:SKIPFILL
set FILLPX=-1
set FILLPY=-1
gotoxy %X% %Y%
goto :eof


:SAVE
cmdwiz getcursorpos x
set X=!ERRORLEVEL!
cmdwiz getcursorpos y
set Y=!ERRORLEVEL!

if %SAVEPX%==-1 set SAVEPX=%X%&set SAVEPY=%Y%& goto :eof

if %SAVEPX%==%X% if %SAVEPY%==%Y% set SAVEPX2=%SAVEPX%&set SAVEPY2=%SAVEPY%&set SAVEPX=0&set SAVEPY=0&goto PREPSAVE
if %X% lss %SAVEPX% goto SKIPSAVE
if %Y% lss %SAVEPY% goto SKIPSAVE
set SAVEPX2=%X%
set SAVEPY2=%Y%

:PREPSAVE
set /a BX=%SAVEPX2%-%SAVEPX%+1
set /a BY=%SAVEPY2%-%SAVEPY%+1

gotoxy 1 %YBOUND% "                                                                                                                                      "
gotoxy 1 %YBOUND%
set FNAME=%1
if "%1"=="" set FNAME=&set /P FNAME=Filename(omit .gxy): 
if not "%1"=="" goto NEWFILE

if "%FNAME%"=="" goto NONAME
if not exist "%FNAME%.gxy" goto NEWFILE
gotoxy 1 %YBOUND% " File exists.(O)verwrite, (A)ppend, or (C)ancel?                                                                                      "
gotoxy 50 %YBOUND%
:ASKLOOP
cmdwiz getch
set DECISION=%ERRORLEVEL%
if %DECISION% == 111 goto NEWFILE
if %DECISION% == 99 goto NONAME
if %DECISION% == 97 cmdwiz saveblock edtemp %SAVEPX% %SAVEPY% %BX% %BY% e x 1 10&echo.>>"%FNAME%.gxy"
if %DECISION% == 97 type edtemp.gxy>>"%FNAME%.gxy"
if %DECISION% == 97 del /Q edtemp.gxy&goto NONAME
goto ASKLOOP

:NEWFILE
cmdwiz saveblock "%FNAME%" %SAVEPX% %SAVEPY% %BX% %BY% e x 1 10
:NONAME
call :PRINTSEPARATOR

:SKIPSAVE
set SAVEPX=-1
set SAVEPY=-1
gotoxy %X% %Y%
goto :eof


:TOGGLEINS
set /a INSV=1-%INSV%
set INS=
if %INSV%==1 set INS=c
goto :eof

:ROLL
if !MFUNC1! == 1 set /a FGCOL+=%1
if !MFUNC1! == 2 set /a BGCOL+=%1
if !MFUNC1! == 3 call :MODCHAR %1
goto :eof


:SHOWHELP
cmdwiz showcursor 0
cmdwiz saveblock edittmp 0 0 %COLS% %ROWS%
cls
set HLPC1=\b0
set HLPC2=\70
set /A YTMP=%ROWS%-2
gotoxy 1 1 "EDITOR HELP" f 0
gotoxy 1 3 "%HLPC1%Up/Down/Left/Right/Mouse move: %HLPC2%move cursor\n%HLPC1%RETURN/Left mouse key: %HLPC2%draw current\n%HLPC1%Right mouse key: %HLPC2%mouse function MF\n%HLPC1%F11: %HLPC2%switch MF (erase, put transparent, pick up char, pick up char+cols)\n%HLPC1%Scroll wheel: %HLPC2%scroll function SF\n%HLPC1%F12: %HLPC2%switch SF (next fgcol, next bgcol, next char)\n%HLPC1%F5-F8: %HLPC2%set drawstate: normal/draw only char/draw only cols/draw char+fgcol\n\n%HLPC1%Tab: %HLPC2%pick up char from cursor pos\n%HLPC1%Home: %HLPC2%pick up char, fgcol and bgcol from cursor pos\n%HLPC1%End: %HLPC2%pick up fgcol and bgcol from cursor pos\n%HLPC1%Pgup/PgDown: %HLPC2%pick up fgcol/bgcol from cursor pos\n\n%HLPC1%F3/Shift-F3: %HLPC2%next/previous fgcol\n%HLPC1%F4/Shift-F4: %HLPC2%next/previous bgcol\n%HLPC1%Alt-1-9 a-f: %HLPC2%set fgcol\n%HLPC1%Shift-Alt-1-9 a-f: %HLPC2%set bgcol\n\n%HLPC1%Ctrl-F1-F9: %HLPC2%quick select of chars \gdb \gb2 \gb1 \gb0 \gdc \gdf \gfe \g07 \g01 \n%HLPC1%Ctrl-F10: %HLPC2%select char from table\n%HLPC1%Ctrl-F11/F12: %HLPC2%previous/next char\n%HLPC1%Shift-F9: %HLPC2%toggle immediate draw for Ctrl-F1-F9\n\n%HLPC1%F1/Shift-F1: %HLPC2%load gxy file at current pos with/without visible transparency\n%HLPC1%F2: %HLPC2%mark first/second save coordinate. If same, save from 0,0 to coordinate\n\n%HLPC1%Del/Shift-Del: %HLPC2%erase with blank/transparent char\n%HLPC1%Backspace/Shift-BS: %HLPC2%delete with blank/transparent char\n%HLPC1%Shift-F6: %HLPC2%mark first/second position to fill with current\n%HLPC1%Shift-F7: %HLPC2%mark first/second position of block to copy\n%HLPC1%Shift-F8: %HLPC2%paste copied block\n%HLPC1%Alt-F8: %HLPC2%paste copied block with visible transparency\n\n%HLPC1%Ins: %HLPC2%toggle insert/overwrite\n%HLPC1%F9: %HLPC2%show current coordinates\n%HLPC1%F10: %HLPC2%show help\n%HLPC1%Esc: %HLPC2%quit\n\n\n%HLPC1%Arguments: %HLPC2%editor [file.gxy] [width] [height]\n\n\n\pk;%YTMP%;\80[ESC to go back]"
:HELPLOOP
cmdwiz getch
if not %ERRORLEVEL% == 27 goto HELPLOOP
gotoxy 0 0 edittmp.gxy
del /Q edittmp.gxy
cmdwiz showcursor 1
goto :eof
