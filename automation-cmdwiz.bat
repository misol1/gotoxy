@echo off
setlocal EnableDelayedExpansion
taskkill /F /IM notepad.exe >nul 2>nul
call :WAITWIN notepad.exe 1
start notepad.exe
call :WAITWIN notepad.exe 0

cmdwiz showwindow top /N:notepad.exe
cmdwiz setwindowsize 600 480 /N:notepad.exe
cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w /N:notepad.exe & set WINW=!errorlevel!
cmdwiz getwindowbounds h /N:notepad.exe & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2,WPY=%SH%/2-%WINH%/2
cmdwiz setwindowpos %WPX% %WPY% /N:notepad.exe

cmdwiz delay 500
cmdwiz sendkey 0x10 d & cmdwiz sendkey 0x48 p & cmdwiz sendkey 0x10 u
for %%a in (0x45 0x4C 0x4C 0x4F 0x20 0x57 0x4f 0x52 0x4c 0x44) do cmdwiz sendkey %%a p
cmdwiz sendkey 0x10 d & cmdwiz sendkey 0x31 p & cmdwiz sendkey 0x10 u
cmdwiz delay 1000
cmdwiz setwindowtransparency 10 /N:notepad.exe
cmdwiz delay 1000
if exist gotoxy-examples\123.bmp cmdwiz insertbmp gotoxy-examples\123.bmp 10 50 100 /N:notepad.exe
cmdwiz delay 1000

for /l %%a in (1,1,30) do (
	set /a "X=(!RANDOM! %% !SW!) - 300, Y=(!RANDOM! %% !SH!) - 240"
	cmdwiz setwindowpos !X! !Y! /N:notepad.exe
	cmdwiz delay 100
)
cmdwiz setwindowpos %WPX% %WPY% /N:notepad.exe

cmdwiz delay 1000
cmdwiz sendkey 0x11 d & cmdwiz sendkey 0x41 p & cmdwiz sendkey 0x11 u
cmdwiz delay 1000
cmdwiz sendkey 0x08 p
cmdwiz delay 1000
cmdwiz sendkey 0x10 d & cmdwiz sendkey 0x42 p & cmdwiz sendkey 0x10 u
for %%a in (0x59 0x45 0xbe 0xbe 0xbe) do cmdwiz sendkey %%a p
cmdwiz delay 1000
taskkill /F /IM notepad.exe >nul 2>nul

endlocal
goto :eof

:WAITWIN <procName> <findVal>
	cmdwiz windowlist | find "%1">nul
if %errorlevel% neq %2 goto :WAITWIN
