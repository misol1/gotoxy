@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=50 cols=160
cmdwiz setbuffersize 160 500
cmdwiz showcursor 0
color 07
cls

call writebig.bat "  ;;;;Here is\;an example\of a scroll\;going up.$$$$.$$$$.\\  ;;I guess\that's all\ ;;there is\    to it,\   folks.$$$$.$$$$." 1 155 f 0 4 1 8 0 no

set YPOS=155
:LOOP
set /A YPOS+=1&if !YPOS! geq 350 gotoxy 0 0&set YPOS=153
gotoxy 0 %YPOS% "\W30\i"
if not !ERRORLEVEL! == 27 goto LOOP

::set YPOS=100
::LOOP
::set /A YPOS+=1&if !YPOS! geq 290 set YPOS=100
::gotoxy 0 0 "\o0;%YPOS%;160;50;\o0;0;\W30\i"
::if not !ERRORLEVEL! == 27 goto LOOP

mode con lines=50 cols=80
cmdwiz showcursor 1
endlocal
