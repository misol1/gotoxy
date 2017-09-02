@echo off
setlocal ENABLEDELAYEDEXPANSION
mode 160,50 & cls
cmdwiz setbuffersize 160 500
cmdwiz showcursor 0
color 07

call writebig.bat "  ;;;;Here is\;an example\of a scroll\;going up.$$$$.$$$$.\\  ;;I guess\that's all\ ;;there is\    to it,\   folks.$$$$.$$$$." 7 1 155 f 0 4 1 8 0

set YPOS=155
:LOOP
set /A YPOS+=1&if !YPOS! geq 350 gotoxy 0 0&set YPOS=153
gotoxy 0 %YPOS% "\W30" 0 0 k
if not !ERRORLEVEL! == 27 goto LOOP

::set YPOS=100
::LOOP
::set /A YPOS+=1&if !YPOS! geq 290 set YPOS=100
::gotoxy 0 0 "\o0;%YPOS%;160;50;\o0;0;\W30" 0 0 k
::if not !ERRORLEVEL! == 27 goto LOOP

mode 80,50
cmdwiz showcursor 1
endlocal
