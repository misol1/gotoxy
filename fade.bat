@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
cmdwiz getconsoledim cy&set CY=!ERRORLEVEL!
cmdwiz getconsoledim cx&set CX=!ERRORLEVEL!
cmdwiz getconsoledim sh&set SH=!ERRORLEVEL!
cmdwiz getconsoledim sw&set SW=!ERRORLEVEL!

set NOFCYCLE=0
set COL1=7
set COL2=8
set COL3=1
set COL4=0
set DELAY=50
if not "%1"=="" set DELAY=%1
set CNT=1
shift
:READCOLS
if not "%1"=="" set COL%CNT%=%1&set /A NOFCYCLE+=1&set /A CNT+=1
shift
if not "%1"=="" goto READCOLS 
if %NOFCYCLE%==0 set NOFCYCLE=4
set /A NOFB=%SW%*%SH%
for /L %%a in (1,1,%NOFCYCLE%) do gotoxy !CX! !CY! "\o%CX%;%CY%;%SW%;%SH%\R\M%NOFB%{\G}\o\w%DELAY%" !COL%%a! U rxw
endlocal
cmdwiz showcursor 1
