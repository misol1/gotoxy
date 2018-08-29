@echo off
setlocal ENABLEDELAYEDEXPANSION
if "%~1" == "" echo Usage: gxy2anim [animframes.gxy]&goto :eof
if not exist "%~1" echo Error: no such file&goto :eof
set FNAME="%~n1.bat"
echo @echo off>%FNAME%
echo cmdwiz showcursor 0 >>%FNAME%
echo rem mode con lines=40>>%FNAME%
echo cls>>%FNAME%
set CNT=0&for /F "tokens=*" %%a in (%1) do set /a CNT+=1
echo set "FRAMES=%CNT%">>%FNAME%
set CNT=-1
for /F "tokens=*" %%a in (%1) do set /a CNT+=1&echo set ANIM!CNT!="%%a">>%FNAME%
endlocal
