@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=50 cols=80
cmdwiz showcursor 0
cmdwiz quickedit 0
color 07
cls

set CNT=0&for %%a in (00,10,10,10,10,10,80,80,80,80,b0,b0,f0) do set TRAILCOL!CNT!=%%a&set /A CNT+=1
set /a TRAIL_LEN=%CNT%
set /a TRAIL_LEN_M=%CNT%-1
for /L %%a in (0,1,%TRAIL_LEN%) do set TRAILPX%%a=-1&set TRAILPY%%a=-100
set TRAIL_I=0
set STRING=\kk    \gB2\gB0\gDB\gB2\gB0    \n  \gB0\gB0     \gB0\gB0  \n \gB0         \gB0 \n\gB0           \gB2\n\gB2           \gDB\n\gB2           \gB1\n \gB0         \gB0 \n  \gB0\gB2     \gB2\gB0  \n    \gB0\gB2\gB2\gDB\gB0    \n
::set STRING=This string has got a tail...
::set STRING=\kk   ####    \n  #    #  \n  #    #  \n   ####   \n

set DL=0
set DR=0
set KEY=0
set MX=-1&set MY=-100

:LOOP
cmdwiz getch_and_mouse 20
set MR=%ERRORLEVEL%
if %MR%==-1 goto NOINPUT
set SI=0
set /a KEY=(%MR%^>^>21)
set /a MT=%MR% ^& 1 &if !MT! == 0 goto NOINPUT
set /a MT=%MR% ^& 2 &if !MT! geq 1 set DL=1
set /a MT=%MR% ^& 2 &if !MT! equ 0 set DL=0
set /a MT=%MR% ^& 4 &if !MT! geq 1 set DR=1
set /a MT=%MR% ^& 4 &if !MT! equ 0 set DR=0
set /a MT=%MR% ^& 32 &if !MT! geq 1 goto LOOP
set /a MT=%MR% ^& 64 &if !MT! geq 1 goto LOOP
set /a MX=(%MR%^>^>7) ^& 127
set /a MY=(%MR%^>^>14) ^& 127
if %DL% geq 1 rem
if %DR% geq 1 rem

:NOINPUT
set OUT="\O0;0;80;50;\T20kk"
set /a TRAILPX%TRAIL_I%=%MX%-6
set /a TRAILPY%TRAIL_I%=%MY%-4

set TCNT=%TRAIL_I%
set /A TCNT+=1&if !TCNT! geq %TRAIL_LEN% set TCNT=0
for /L %%a in (0,1,%TRAIL_LEN_M%) do for %%b in (!TCNT!) do set OUT="!OUT:~1,-1!\!TRAILCOL%%a!\p!TRAILPX%%b!;!TRAILPY%%b!;%STRING%"&set /A TCNT+=1&if !TCNT! geq %TRAIL_LEN% set TCNT=0

gotoxy 0 0 %OUT% 9 0

set /a TRAIL_I+=1
if %TRAIL_I% geq %TRAIL_LEN% set /a TRAIL_I=0

if not %KEY% == 27 goto LOOP

setlocal
cmdwiz quickedit 1
cmdwiz showcursor 1
