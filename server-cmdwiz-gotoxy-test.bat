@echo off
if defined __ goto :START
cls & title Cmdwiz Server Test
set __=.
cmdgfx_input knW20 | call %0 %* | cmdwiz.exe server | gotoxy k k "" 0 0 S
set __=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 6 & mode 80,50
cmdwiz getconsoledim sw & set /a W=!errorlevel!
cmdwiz getconsoledim sh & set /a H=!errorlevel!
cmdwiz getdisplaydim w & set /a SCRW=!errorlevel!
cmdwiz getdisplaydim h & set /a SCRH=!errorlevel!-25
cmdwiz getwindowbounds w & set /a WINW=!errorlevel!
cmdwiz getwindowbounds h & set /a WINH=!errorlevel!
set /a A1=0, SHR=13, XMUL=W/3, YMUL=H/3, IMGSIZE=12, SIZEDELTA=2 & set STOP=

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="

:REP
for /l %%1 in (1,1,100) do if not defined STOP (
	set /p INPUT=
	for /f "tokens=6" %%A in ("!INPUT!") do ( set /a KEY=%%A 2>nul )
	if !KEY! gtr 0 set STOP=1
	
	set /a A1+=3, A2=A1+90
	
	set /a "X=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!)+W/2"
	set /a "Y=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)+H/2-1"
	echo "cmdwiz: setcursorpos !X! !Y!"

	set /a "WX=(%SINE(x):x=!A1!*31416/180%*!XMUL!*3>>!SHR!)+SCRW/2-WINW/2"
	set /a "WY=(%SINE(x):x=!A2!*31416/180%*!YMUL!*3>>!SHR!)+SCRH/2-WINH/2"
	echo "cmdwiz: setwindowpos !WX! !WY!"

	set /a "MX=(%SINE(x):x=!A2!*31416/180%*!XMUL!*8>>!SHR!)+SCRW/2"
	set /a "MY=(%SINE(x):x=!A1!*31416/180%*!YMUL!*8>>!SHR!)+SCRH/2"
	echo "cmdwiz: setmousecursorpos !MX! !MY!"
	
	set /a IMGSIZE+=SIZEDELTA
	if !IMGSIZE! geq 180 set /a SIZEDELTA=-SIZEDELTA
	if !IMGSIZE! leq 10 set /a SIZEDELTA=-SIZEDELTA
	set /a IMGW=200*!IMGSIZE!/100, IMGH=170*!IMGSIZE!/100
	set /a IX=WINW/2-IMGW/2, IY=WINH/2-IMGH/2-20
	echo cmdwiz: insertbmp gotoxy-examples\123.bmp !IX! !IY! !IMGSIZE!
	
	set /a TRANSP=IMGSIZE/8
	echo cmdwiz: setwindowtransparency !TRANSP!
	
	if !A1! geq 1440 set /a A1-=1440, A2=A1+90
	set GXYT="  "
	if !A1! geq 1080 set GXYT="X\e0Y"
	rem Looks fine in a legacy console, but bitmap image blinks when doing this in a new console
	rem echo "gotoxy: !X! !Y! !GXYT! a 0"
)
if not defined STOP goto REP

echo cmdwiz: setwindowtransparency 0
echo "gotoxy: k k "" 0 0 S"
echo "cmdwiz: server quit"
title input:q
endlocal
