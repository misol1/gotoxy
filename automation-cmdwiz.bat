@echo off
setlocal EnableDelayedExpansion
taskkill /F /IM notepad.exe >nul 2>nul
call :WAITWIN notepad.exe 1
start notepad.exe
call :WAITWIN notepad.exe 0

set winTarget=/N:notepad.exe:f

cmdwiz showwindow top %winTarget%
cmdwiz setwindowsize 600 480 %winTarget%
cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w %winTarget% & set WINW=!errorlevel!
cmdwiz getwindowbounds h %winTarget% & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2,WPY=%SH%/2-%WINH%/2
cmdwiz setwindowpos %WPX% %WPY% %winTarget%

cmdwiz delay 500
cmdwiz sendkey "Hello world$1"
cmdwiz delay 1000
cmdwiz setwindowtransparency 10 %winTarget%
cmdwiz delay 1000
if exist gotoxy-examples\123.bmp cmdwiz insertbmp gotoxy-examples\123.bmp 10 50 100 %winTarget%
cmdwiz delay 1000

for /l %%a in (1,1,30) do (
	set /a "X=(!RANDOM! %% !SW!) - 300, Y=(!RANDOM! %% !SH!) - 240"
	cmdwiz setwindowpos !X! !Y! %winTarget%
	cmdwiz delay 100
)
cmdwiz setwindowpos %WPX% %WPY% %winTarget%

cmdwiz delay 1000
cmdwiz sendkey "^a"
cmdwiz delay 1000
cmdwiz sendkey 0x08 p
cmdwiz delay 1000
cmdwiz sendkey "Bye..."
cmdwiz delay 1000
taskkill /F /IM notepad.exe >nul 2>nul

endlocal
goto :eof

:WAITWIN <procName> <findVal>
	cmdwiz windowlist | find "%1">nul
if %errorlevel% neq %2 goto :WAITWIN
