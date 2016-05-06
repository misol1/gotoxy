@echo off
setlocal ENABLEDELAYEDEXPANSION
cls
cmdwiz getconsoledim sw&set SW=!ERRORLEVEL!
cmdwiz getconsoledim sh&set SH=!ERRORLEVEL!
set W=14
set H=25
set /A X=%SW%/2-%W%/2
set /A Y=%SH%/2-%H%/2
set /A T1=1+%Y%
set /A T2=%H%+%Y%
set /A T3=%W%-2
set /A T4=%H%-1

set /A S1=%X%+1
set /A S2=%Y%+1

gotoxy %X% %Y% "\gc9\M%T3%{\gcd}\gbb\p%X%;%T2%\gc8\M%T3%{\gcd}\gbc\p%X%;%T1%\M%T4%{\gba\M%T3%{ \}\gba\n}" 4 0 x
set CNT=0

:REP
set /A CNT+=1
gotoxy %S1% k "\S%S1%;%S2%;%T3%;%T4%;%CNT% \70:\80 !RANDOM!\n" f 0 csk
if not %ERRORLEVEL%==27 goto REP
endlocal
