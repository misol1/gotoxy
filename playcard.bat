@echo off
setlocal
set /A VALUE=%RANDOM% %% 13 + 1
set /A SUIT=%RANDOM% %% 4 + 1
set SHADOW=1
set FLIP=0
set XPOS=0
set YPOS=0
set BKGCOLOR=15
set EXTRASUIT=0
if NOT "%1" == "" set XPOS=%1
if NOT "%2" == "" set YPOS=%2
if NOT "%3" == "" set SHADOW=%3
if NOT "%4" == "" set FLIP=%4
if NOT %FLIP% == 0 set BKGCOLOR=%4
if NOT "%5" == "" set VALUE=%5
if NOT "%6" == "" set SUIT=%6
if NOT "%7" == "" set EXTRASUIT=1

if %FLIP% geq 0 goto NOERASE
set /a YPOS+=6
if %SHADOW% == 1 set /a YPOS+=1 & set /a VALUE+=1
if %VALUE% gtr 8 set VALUE=8
set CSPR="\00"
for /L %%a in (1,1,%VALUE%) do set CSPR="!CSPR:~1,-1!\n        "
set /a YPOS-=%VALUE%
gotoxy.exe %XPOS% %YPOS% "%CSPR:~1,-1%" 0

endlocal
goto :eof

:NOERASE
set ORGVALUE=%VALUE%
if %VALUE% == 1 set VALUE=A
::if %VALUE% == 10 set VALUE=X
if %VALUE% == 11 set VALUE=J
if %VALUE% == 12 set VALUE=Q
if %VALUE% == 13 set VALUE=K

set BACKCOL=\0%BKGCOLOR%
if %BKGCOLOR%==10 set BACKCOL=\0A
if %BKGCOLOR%==11 set BACKCOL=\0B
if %BKGCOLOR%==12 set BACKCOL=\0C
if %BKGCOLOR%==13 set BACKCOL=\0D
if %BKGCOLOR%==14 set BACKCOL=\0E
if %BKGCOLOR%==15 set BACKCOL=\0F

set /A YTEMP=%YPOS%+1
set CSPR=".-----."

set COLOR=0&set COLOR2=8
if %SUIT% geq 3 set COLOR=C& set COLOR2=4

if %FLIP% == 0 set CSPR="%CSPR:~1,-1%\n|POS1 POS3 POS2|"
if not %FLIP% == 0 set CSPR="%CSPR:~1,-1%\n|     |"
if not %SHADOW% == 0 set CSPR="%CSPR:~1,-1%\80#%BACKCOL%"
set CSPR=!CSPR:POS1=\%COLOR%F%VALUE%\0F!
if not %VALUE% == 10 set CSPR=!CSPR:POS3= !
if %VALUE% == 10 set CSPR=!CSPR:POS3=!

if %EXTRASUIT% == 0 set CSPR=%CSPR:POS2= %& goto NOEXTRASUIT
set /a XDIGITPOS=%XPOS%+5
set /a YDIGITPOS=%YPOS%+1
if %SUIT%==1 set ES=S
if %SUIT%==2 set ES=C
if %SUIT%==3 set ES=H
if %SUIT%==4 set ES=D
set CSPR=!CSPR:POS2=\7F%ES%\0F!
:NOEXTRASUIT

::if %SUIT%==1 set ES=\g06
::if %SUIT%==2 set ES=\g05
::if %SUIT%==3 set ES=\g03
::if %SUIT%==4 set ES=\g04
set ES=@

if not %FLIP% == 0 set FP="\n|     |"
if %FLIP% == 0 set FP="\n| P1 |"
if not %SHADOW% == 0 set FP="%FP:~1,-1%\80#%BACKCOL%"

REM 1=spades 2=clubs 3=hearts 4=diamonds
set CSPR="%CSPR:~1,-1%%FP:~1,-1%"
if not %FLIP% == 0 goto ISFLIP1
if %SUIT%==1 set FACE= %ES% 
if %SUIT%==2 set FACE= %ES% 
if %SUIT%==3 set FACE=%ES% %ES%
if %SUIT%==4 set FACE= %ES% 
set CSPR=!CSPR:P1=\%COLOR2%F%FACE%\0F!
:ISFLIP1

set CSPR="%CSPR:~1,-1%%FP:~1,-1%"
if not %FLIP% == 0 goto ISFLIP2
set FACE=%ES%%ES%%ES%
set CSPR=!CSPR:P1=\%COLOR2%F%FACE%\0F!
:ISFLIP2

set CSPR="%CSPR:~1,-1%%FP:~1,-1%"
if not %FLIP% == 0 goto ISFLIP3
if %SUIT%==1 set FACE=%ES% %ES%
if %SUIT%==2 set FACE= %ES% 
if %SUIT%==3 set FACE= %ES% 
if %SUIT%==4 set FACE= %ES% 
set CSPR=!CSPR:P1=\%COLOR2%F%FACE%\0F!
:ISFLIP3

if %FLIP% == 0 set CSPR="%CSPR:~1,-1%\n|   POS1|"
if not %FLIP% == 0 set CSPR="%CSPR:~1,-1%\n|     |"
if not %SHADOW% == 0 set CSPR="%CSPR:~1,-1%\80#%BACKCOL%"
if not %VALUE% == 10 set CSPR=!CSPR:POS1= \%COLOR%F%VALUE%\0F!
if %VALUE% == 10 set CSPR=!CSPR:POS1=\%COLOR%F%VALUE%\0F!

set CSPR="%CSPR:~1,-1%\n -----'"
if not %SHADOW% == 0 set CSPR="%CSPR:~1,-1%\80#%BACKCOL%"

if %SHADOW% == 0 goto NOSHADOW
set /A YTEMP+=1
set /A XTEMP=%XPOS%+1
set CSPR="%CSPR:~1,-1%\n\80 """"""""""""""""""""""
:NOSHADOW

gotoxy.exe %XPOS% %YPOS% "%CSPR:~1,-1%" 0 %BKGCOLOR% c

set /a EXITVAL=%SUIT%*100+%ORGVALUE%
exit /b %EXITVAL%
endlocal
goto :EOF
