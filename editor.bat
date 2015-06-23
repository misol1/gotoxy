:: Editor : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
set COLS=80
set ROWS=52
set LOADNAME=
set FGCOL=7
set BGCOL=0
set CKEY=176
call :DECTOHEX %CKEY%
set CCHAR=%CHAR%
set SAVEPX=-1
set SAVEPY=-1
set DL=0
set DR=0
set INS=
set INSV=0
set MFUNC1=1
set MFUNC2=1
if not "%1" == "" set LOADNAME=%1
if not "%2" == "" set COLS=%2
if not "%3" == "" set ROWS=%3
mode con lines=%ROWS% cols=%COLS%
set /a YBOUND=%ROWS%-2
cls
if "%LOADNAME%" == "" goto NOFILE
if not exist %LOADNAME% goto NOFILE
for /F "tokens=*" %%i in (%LOADNAME%) do set inf="%%i"
set inf=%inf:\-=\A1x\r%
gotoxy 0 0 %inf%&
:NOFILE
call :PRINTSEPARATOR
call :PRINTSTATUS
cmdwiz quickedit 0
cmdwiz showcursor 1

:LOOP
set KEY=0
cmdwiz getch_or_mouse
set MR=%ERRORLEVEL%
if %MR%==-1 goto SKIP
set /a MT=%MR% ^& 1 &if !MT! == 0 goto MOUSEINPUT
set /a KEY=%MR%/2
goto NOMOUSE
:MOUSEINPUT
set /a MT=%MR% ^& 2 &if !MT! geq 1 set DL=1
set /a MT=%MR% ^& 2 &if !MT! equ 0 set DL=0
set /a MT=%MR% ^& 4 &if !MT! geq 1 set DR=1
set /a MT=%MR% ^& 4 &if !MT! equ 0 set DR=0
set /a MT=%MR% ^& 32 &if !MT! geq 1 call :ROLL -1&call :PRINTSTATUS
set /a MT=%MR% ^& 64 &if !MT! geq 1 call :ROLL 1&call :PRINTSTATUS
set /a MX=(%MR%^>^>10) ^& 511
set /a MY=%MR%^>^>19
if %MY% geq %YBOUND% goto SKIP
gotoxy %MX% %MY%
if %DR% == 0 goto NORIGHTMB
if %MFUNC2% == 1 gotoxy %MX% %MY% " " 7 0
if %MFUNC2% == 2 gotoxy %MX% %MY% "x" 10 1
if %MFUNC2% == 3 call :PICKUP 1
if %MFUNC2% == 4 call :PICKUP 2
:NORIGHTMB
if %DL% geq 1 gotoxy %MX% %MY% %CCHAR% %FGCOL% %BGCOL%
goto SKIP
:NOMOUSE
if %KEY% == 8 cmdwiz getkeystate shift&if !ERRORLEVEL!==1 gotoxy k k "x" 10 1 & set KEY=1075 & rem BACKSPACE + shift
if %KEY% == 8 cmdwiz getkeystate shift&if !ERRORLEVEL!==0 gotoxy k k " " %FGCOL% %BGCOL% & set KEY=1075 & rem BACKSPACE
if %KEY% == 328 cmdwiz getcursorpos y&set /a NY=!ERRORLEVEL!-1&gotoxy k !NY!&goto SKIP & rem UP
if %KEY% == 336 cmdwiz getcursorpos y&set /a NY=!ERRORLEVEL!+1&set KEY=-1&if !NY! lss %YBOUND% gotoxy k !NY! & rem DOWN
if %KEY% == 331 cmdwiz getcursorpos x&set /a NX=!ERRORLEVEL!-1&gotoxy !NX! k&goto SKIP & rem LEFT
if %KEY% == 333 cmdwiz getcursorpos x&set /a NX=!ERRORLEVEL!+1&gotoxy !NX! k&goto SKIP & rem RIGHT
if %KEY% == 13 set KEY=%CKEY% & rem RETURN
if %KEY% == 339 cmdwiz getkeystate shift&if !ERRORLEVEL!==1 gotoxy k k "x" 10 1 %INS%& goto SKIP & rem shift+DEL
if %KEY% == 339 cmdwiz getkeystate shift&if !ERRORLEVEL!==0 gotoxy k k " " 7 0 %INS%& goto SKIP & rem DEL
if %KEY% == 338 call :TOGGLEINS & goto SKIP & rem INS
if %KEY% == 9 call :PICKUP 1 & goto SKIP & rem TAB
if %KEY% == 327 call :PICKUP 2 & goto SKIP & rem HOME
if %KEY% == 329 call :PICKUP 3 & goto SKIP & rem PGUP
if %KEY% == 337 call :PICKUP 4 & goto SKIP & rem PGDN
if %KEY% == 335 call :PICKUP 5 & goto SKIP & rem END
if %KEY% == 571 call :PRINTCOORDS & goto SKIP & rem F1
if %KEY% == 572 call :SAVE & goto SKIP & rem F2
if %KEY% == 573 set /a FGCOL+=1&call :PRINTSTATUS&goto SKIP & rem F3
if %KEY% == 574 set /a BGCOL+=1&call :PRINTSTATUS&goto SKIP & rem F4
if %KEY% == 598 set /a FGCOL-=1&call :PRINTSTATUS&goto SKIP & rem shift-F3
if %KEY% == 599 set /a BGCOL-=1&call :PRINTSTATUS&goto SKIP & rem shift-F4
if %KEY% == 576 set CKEY=176&call :MODCHAR 0 &goto SKIP & rem F6
if %KEY% == 577 set CKEY=219&call :MODCHAR 0 &goto SKIP & rem F7
if %KEY% == 578 set CKEY=1&call :MODCHAR 0 &goto SKIP & rem F8
if %KEY% == 579 set CKEY=24&call :MODCHAR 0 &goto SKIP & rem F9
if %KEY% == 389 call :MODCHAR -1 & goto SKIP & rem F11
if %KEY% == 390 call :MODCHAR 1 & goto SKIP & rem F12
if %KEY% == 596 set KEY=-1 & set /a MFUNC1+=1&if !MFUNC1! geq 4 set MFUNC1=1 & rem shift-F1
if %KEY% == 597 set KEY=-1 & set /a MFUNC2+=1&if !MFUNC2! geq 5 set MFUNC2=1 & rem shift-F2
if %KEY% geq 48 if %KEY% leq 57 cmdwiz getkeystate alt&if !ERRORLEVEL!==1 set /a FGCOL=%KEY%-48&call :PRINTSTATUS& goto SKIP & rem 0-9 with alt
if %KEY% geq 97 if %KEY% leq 102 cmdwiz getkeystate alt&if !ERRORLEVEL!==1 set /a FGCOL=%KEY%-97+10&call :PRINTSTATUS& goto SKIP & rem a-f with alt
if %KEY% geq 65 if %KEY% leq 70 cmdwiz getkeystate alt&if !ERRORLEVEL!==1 set /a BGCOL=%KEY%-65+10&call :PRINTSTATUS& goto SKIP & rem A-F with alt
if %KEY% geq 33 if %KEY% leq 41 cmdwiz getkeystate alt&if !ERRORLEVEL!==1 set /a BGCOL=%KEY%-32&call :PRINTSTATUS& goto SKIP & rem 0-9 with shift+alt
if %KEY% == 61 cmdwiz getkeystate alt&if !ERRORLEVEL!==1 set /a BGCOL=0&call :PRINTSTATUS& goto SKIP & rem 0 with shift+alt
if %KEY% == 207 cmdwiz getkeystate alt&if !ERRORLEVEL!==1 set /a BGCOL=4&call :PRINTSTATUS& goto SKIP & rem 4 with shift+alt
if %KEY% == 47 cmdwiz getkeystate alt&if !ERRORLEVEL!==1 set /a BGCOL=7&call :PRINTSTATUS& goto SKIP & rem 7 with shift+alt

if %KEY% lss 0 goto SKIP
if %KEY% gtr 255 goto SKIP
if %KEY% == 27 goto SKIP

call :DECTOHEX %KEY%
gotoxy k k %CHAR% %FGCOL% %BGCOL% %INS%
set SAVEPX=-1
set SAVEPY=-1

:SKIP
if not %KEY% == 27 goto LOOP

cls
endlocal
cmdwiz quickedit 1
goto :eof

:DECTOHEX
set /a P1=%1 / 16
call :DECTOHEX2 %P1%
set P1=%P%

set /a P2=%1 %% 16
call :DECTOHEX2 %P2%
set P2=%P%

set CHAR=\g%P1%%P2%
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

:PRINTSEPARATOR
set LN=-
for /L %%a in (1,1,%COLS%) do set LN=!LN!-
gotoxy 0 %YBOUND% %LN% 7 0 r
goto :eof

:PRINTSTATUS
set /a Y=%ROWS%-1
gotoxy 1 %Y% Current:[ 7 0 r
if %FGCOL% geq 16 set FGCOL=0
if %BGCOL% geq 16 set BGCOL=0
if %FGCOL% lss 0 set FGCOL=15
if %BGCOL% lss 0 set BGCOL=15
gotoxy 10 %Y% \g20 0 %FGCOL% r
gotoxy 11 %Y% \g20 0 %BGCOL% r
gotoxy 12 %Y% "] [" 	7 0 r
gotoxy 15 %Y% %CCHAR% %FGCOL% %BGCOL% r
gotoxy 16 %Y% " %CCHAR%]" 7 0 r
goto :eof

:PRINTCOORDS
cmdwiz getcursorpos x
set X=!ERRORLEVEL!
cmdwiz getcursorpos y
set Y=!ERRORLEVEL!

set /a YP=%ROWS%-1
gotoxy 69 %YP% "X:%X% Y:%Y%      " 7 0 r
cmdwiz getch
gotoxy 69 %YP% "                    " 7 0 r
goto :eof


:PICKUP
cmdwiz getcursorpos x
set X=!ERRORLEVEL!
cmdwiz getcursorpos y
set Y=!ERRORLEVEL!

if %1 geq 3 goto SKIP_PCHAR
cmdwiz getcharat %X% %Y%
set CKEY=!ERRORLEVEL!
call :DECTOHEX %CKEY%
set CCHAR=%CHAR%
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
call :DECTOHEX %CKEY%
set CCHAR=%CHAR%
call :PRINTSTATUS
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
set FNAME=&set /P FNAME=Filename(omit .gxy): 

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
