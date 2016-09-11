@echo off
setlocal ENABLEDELAYEDEXPANSION

cls
cmdwiz savefont oldfont.fnt
cmdwiz setfont Consolas72.cmdfnt
cmdwiz showcursor 1 100
mode 30,8

cmdwiz getwindowbounds w&set PIXELW=!errorlevel!
cmdwiz getwindowbounds h&set PIXELH=!errorlevel!

cmdwiz getdisplaydim w&set SW=!errorlevel!
cmdwiz getdisplaydim h&set SH=!errorlevel!
set /a WPX=%SW%/2-%PIXELW%/2,WPY=%SH%/2-%PIXELH%/2-20
cmdwiz setwindowpos %WPX% %WPY%
set /a YPOS=%PIXELH%/2-20, BMPHEIGHT=1
cmdwiz setcursorpos 9 3
cmdwiz print "CONSOLAS 72"
cmdwiz delay 3000
cmdwiz showcursor 0

for /L %%a in (1,2,%PIXELH%) do cmdwiz insertbmp 123.bmp 0 !YPOS! %PIXELW% !BMPHEIGHT! & set /a YPOS-=2,BMPHEIGHT+=4

set /a MPX = %WPX% + %PIXELW%/2, MPY = %WPY% + 15
cmdwiz setmousecursorpos %MPX% %MPY%

for /L %%a in (0,1,100) do set /a MPX+=2&cmdwiz setmousecursorpos !MPX! %MPY% d
for /L %%a in (0,1,98) do set /a MPX-=2&cmdwiz setmousecursorpos !MPX! %MPY% d
cmdwiz setmousecursorpos !MPX! %MPY% u

cmdwiz setwindowpos 0 0
cmdwiz setfont oldfont.fnt
del /Q oldfont.fnt>nul
mode 80,50 & cmdwiz showcursor 1 & cls
endlocal
