@echo off
setlocal ENABLEDELAYEDEXPANSION
set W=80
set H=50
mode con lines=%H% cols=%W%
cls

call :SETDELIMITS 12 30 %H%

set CNT=0
set CNT2=0&for /F "tokens=*" %%i in (fxcmds.dat) do set SRC!CNT2!=%%i&set /A CNT2+=1
set /A NOFL=%CNT2%&set CNT2=0
set CNT3=0&for /F "tokens=*" %%i in (gamescmds.dat) do set BSRC!CNT3!=%%i&set /A CNT3+=1
set /A NOFL2=%CNT3%&set CNT3=0

:REP
gotoxy 0 %Y1% "\S0;0;%W%;%H1%;\f0%CNT3% \70:\90 !BSRC%CNT3%!\n\S0;%Y1P%;%W%;%H2%;\p0;%Y2%;\c0%CNT% \70:\80 !RANDOM!\n\S0;%Y2P%;%W%;%H3%;\p0;%Y3%;\a0%CNT2% \u0: !SRC%CNT2%!\n" 0 0 csk
set KEY=!ERRORLEVEL!
set /A CNT+=1
set /A CNT2+=1&if !CNT2!==%NOFL% set CNT2=0
set /A CNT3+=1&if !CNT3!==%NOFL2% set CNT3=0
if %KEY%==97 set /A VTMP=%Y2%-3&if %Y1% lss !VTMP! set /A Y1M=%Y1%+1&call :SETDELIMITS !Y1M! !Y2! !Y3!
if %KEY%==65 if %Y1% gtr 2 set /A Y1M=%Y1%-1&call :SETDELIMITS !Y1M! !Y2! !Y3!
if %KEY%==115 set /A VTMP=%Y3%-3&if %Y2% lss !VTMP! set /A Y2M=%Y2%+1&call :SETDELIMITS !Y1! !Y2M! !Y3!
if %KEY%==83 set /A VTMP=%Y1%+3&if %Y2% gtr !VTMP! set /A Y2M=%Y2%-1&call :SETDELIMITS !Y1! !Y2M! !Y3!
if not %KEY%==27 goto REP

mode con lines=50 cols=80
cls
endlocal
goto :eof

:SETDELIMITS
set Y1O=%Y1%
set Y2O=%Y2%

set Y1=%1
set /A H1=%Y1%

set Y2=%2
set /A Y1P=%Y1%+1
set /A H2=%Y2%-%Y1%-1

set Y3=%3
set /A Y2P=%Y2%+1
set /A H3=%Y3%-%Y2%-1

gotoxy 0 0 "\p0;%Y1O%;\M%W%{ }\p0;%Y2O%;\M%W%{ }\p0;%Y1%;\M%W%{\gcd}\p0;%Y2%;\M%W%{\gcd}" b 0 x
goto :eof
