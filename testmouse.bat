@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=50 cols=80
color 07
cls
cmdwiz quickedit 0

set DL=0
set DR=0
set COL=1
set KEY=0
goto LOOP3

:LOOP
cmdwiz getmouse>nul
set MR=%ERRORLEVEL%
if %MR%==-1 goto NOINPUT
set /a MT=%MR% ^& 2 &if !MT! geq 1 if %DL%==0 set DL=1& echo Left button...
set /a MT=%MR% ^& 2 &if !MT! equ 0 if %DL%==1 set DL=0& echo Left button release...
set /a MT=%MR% ^& 4 &if !MT! geq 1 if %DR%==0 set DR=1& echo Right button...
set /a MT=%MR% ^& 4 &if !MT! equ 0 if %DR%==1 set DR=0& echo Right button release...
set /a MT=%MR% ^& 8 &if !MT! geq 1 echo Left Double click...
set /a MT=%MR% ^& 16 &if !MT! geq 1 echo Right Double click...
set /a MT=%MR% ^& 32 &if !MT! geq 1 echo Wheel down...
set /a MT=%MR% ^& 64 &if !MT! geq 1 echo Wheel up...
set /a MX=(%MR%^>^>10) ^& 511
set /a MY=%MR%^>^>19
echo %MX%,%MY%
:NOINPUT
cmdwiz getkeystate 27>nul
if %ERRORLEVEL% == 0 goto LOOP
goto END


:LOOP2
cmdwiz getch_or_mouse>nul
set MR=%ERRORLEVEL%
if %MR%==-1 goto NOINPUT2
set /a MT=%MR% ^& 1 &if !MT! == 0 goto MOUSEINPUT
set /a KEY=%MR%/2
goto NOINPUT2
:MOUSEINPUT
set /a MT=%MR% ^& 2 &if !MT! geq 1 set DL=1
set /a MT=%MR% ^& 2 &if !MT! equ 0 set DL=0
set /a MT=%MR% ^& 4 &if !MT! geq 1 set DR=1
set /a MT=%MR% ^& 4 &if !MT! equ 0 set DR=0
set /a MT=%MR% ^& 32 &if !MT! geq 1 set /a COL-=1&if !COL! lss 1 set COL=15
set /a MT=%MR% ^& 64 &if !MT! geq 1 set /a COL+=1&if !COL! geq 16 set COL=1
set /a MX=(%MR%^>^>10) ^& 511
set /a MY=%MR%^>^>19
if %DR% geq 1 gotoxy %MX% %MY% " " 0 0
if %DL% geq 1 gotoxy %MX% %MY% " " 0 %COL%
:NOINPUT2
if not %KEY% == 27 goto LOOP2
goto END


:LOOP3
cmdwiz getch_and_mouse>nul
set MR=%ERRORLEVEL%
if %MR%==-1 goto NOINPUT3
set /a KEY=(%MR%^>^>22)
set /a MT=%MR% ^& 1 &if !MT! == 0 goto NOINPUT3
set /a MT=%MR% ^& 2 &if !MT! geq 1 set DL=1
set /a MT=%MR% ^& 2 &if !MT! equ 0 set DL=0
set /a MT=%MR% ^& 4 &if !MT! geq 1 set DR=1
set /a MT=%MR% ^& 4 &if !MT! equ 0 set DR=0
set /a MT=%MR% ^& 32 &if !MT! geq 1 set /a COL-=1&if !COL! lss 1 set COL=15
set /a MT=%MR% ^& 64 &if !MT! geq 1 set /a COL+=1&if !COL! geq 16 set COL=1
set /a MX=(%MR%^>^>7) ^& 255
set /a MY=(%MR%^>^>15) ^& 127
if %DR% geq 1 gotoxy %MX% %MY% " " 0 0
if %DL% geq 1 gotoxy %MX% %MY% "." 15 %COL%
:NOINPUT3
if not %KEY% == 27 goto LOOP3


:END
endlocal
cmdwiz quickedit 1
