@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=50 cols=80
cmdwiz showcursor 0
color 07
cls

call sintable.bat

set BALL0=\C1   \70       \C1   \n \70  \74 \C4\gB0\gB0\gB0\gB0\gB0\74 \70  \C1 \n\70  \C4\gB0\7C       \74  \70 \n \C4\gB0\7C  \7F  \CF\gB1\7C    \74 \70 \n \C4\gB0\7C  \CF\gB1\gB1\gB2\7C    \74 \70 \n \C4\gB0\7C        \C4\gB0\74 \70 \n  \C4\gB0\7C      \C4\gB0\74 \70  \n\C1 \70  \74 \C4\gB0\gB0\gB0\74   \70  \C1 \n   \70       \C1   
set BALL1=%BALL0:4=2%&set BALL1=!BALL1:c=a!
set BALL2=%BALL0:4=5%&set BALL2=!BALL2:c=d!
set BALL3=%BALL0:4=6%&set BALL3=!BALL3:c=e!
set BALL4=%BALL0:4=8%&set BALL4=!BALL4:c=7!

set XMUL=4
set YMUL=8
set SC=0
set CC=180
if "%~1"=="0" set CC=180
if "%~1"=="1" set CC=90
if "%~1"=="2" set CC=290

set XP=5
set YP=3
set XW=5
set YW=3

set ADDER=16
set /A NOFPOS=720/%ADDER%

set XRADD=4
set YRADD=6

set CNT=0
:LOOP
set /a CX%CNT%=(!SIN%SC%!*%XMUL%^>^>14)
set /a CY%CNT%=(!SIN%CC%!*%YMUL%^>^>14)
set /a SC+=%ADDER% & if !SC! geq 720 set /A SC=!SC!-720
set /a CC+=%ADDER% & if !CC! geq 720 set /A CC=!CC!-720
set /A CNT+=1
if %CNT% lss %NOFPOS% goto LOOP

for /L %%a in (0,1,720) do set SIN%%a=&set COS%%a=

set CNT=0
:LOOP2
set /A CNT+=1
if %CNT% geq %NOFPOS% set CNT=0

set CNO=%CNT%
set YPP=%YP%
set UT=\O0;0;80;50;\T20k1\01\N
set BALLCOLCNT=0
for /L %%c in (0,1,%YW%) do set CN=!CNO!&set /A CNO+=%YRADD%&(if !CNO! geq %NOFPOS% set /A CNO=!CNO!-%NOFPOS%)&set /A YPP+=7&set XPP=%XP%&for /L %%a in (0,1,%XW%) do for %%b in (!CN!) do set /A XT=!XPP!+!CX%%b!&set /A YT=!YPP!+!CY%%b!&set UT=!UT!\p!XT!;!YT!;BALL!BALLCOLCNT!&set /A XPP+=12&(set /A BALLCOLCNT+=1&if !BALLCOLCNT! geq 5 set /A BALLCOLCNT=0)&set /A CN+=%XRADD%&if !CN! geq %NOFPOS% set /A CN=!CN!-%NOFPOS%
set UT=!UT:BALL0=%BALL0%!
set UT=!UT:BALL1=%BALL1%!
set UT=!UT:BALL2=%BALL2%!
set UT=!UT:BALL3=%BALL3%!
set UT=!UT:BALL4=%BALL4%!

gotoxy %XPP% %YPP% "%UT%\i" 9 0

if !ERRORLEVEL!==328 set /A XRADD+=1
if !ERRORLEVEL!==336 set /A XRADD-=1&if !XRADD! lss 1 set XRADD=1
if !ERRORLEVEL!==333 set /A YRADD+=1
if !ERRORLEVEL!==331 set /A YRADD-=1&if !YRADD! lss 1 set YRADD=1
if not !ERRORLEVEL! == 27 goto LOOP2

cmdwiz showcursor 1
endlocal