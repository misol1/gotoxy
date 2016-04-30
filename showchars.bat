@echo off
setlocal ENABLEDELAYEDEXPANSION
cls
set UT=&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set UT=!UT!%%a\g20\g20\g20\g20
gotoxy 3 0 "%UT%\n\n" 9 0
set UT=&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set UT=!UT!%%a\n\n
gotoxy 0 2 "%UT%\n\n" 9 0
set UT=&set D2H=0123456789abcdef
for /L %%a in (0,1,255) do set /A HB=%%a/16&set /A LB=%%a%%16&for %%b in (!HB!) do for %%c in (!LB!) do set HEXV=!D2H:~%%b,1!!D2H:~%%c,1!&set UT=!UT!\g!HEXV!\g20\g20\g20\g20&set /A DIV=(%%a+1)%%16&if !DIV!==0 set UT=!UT!\n\n
gotoxy 3 2 "%UT%" 15 0 c
set UT=&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set UT=!UT!\gdb\g20\g20\g20\g20\+0
gotoxy 3 k "\n%UT%\n\n" 0 0 c
endlocal
