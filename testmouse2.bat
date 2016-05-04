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

set MX=-100&set MY=-100

:LOOP
cmdwiz getch_and_mouse 20>mouse_out.txt

for /F "tokens=1,3,5,7,9,11,13,15,17,19,21 delims= " %%a in (mouse_out.txt) do set EVENT=%%a&set KEY=%%b&set MOUSE_EVENT=%%c&set NEW_MX=%%d&set NEW_MY=%%e&set LMB=%%f&set RMB=%%g&set LDBL=%%h&set RDBL=%%i&set MWHEEL=%%j
if "%EVENT%"=="NO_EVENT" set KEY=0&goto NOINPUT
if "%MOUSE_EVENT%"=="0" goto NOINPUT
if not "%MWHEEL%"=="0" goto LOOP
set MX=%NEW_MX%&set MY=%NEW_MY%

:NOINPUT
set OUT="\O0;0;80;50;\T20kk"
set /a TRAILPX%TRAIL_I%=%MX%-6
set /a TRAILPY%TRAIL_I%=%MY%-4

set TCNT=%TRAIL_I%
set /A TCNT+=1&if !TCNT! geq %TRAIL_LEN% set TCNT=0
for /L %%a in (0,1,%TRAIL_LEN_M%) do for %%b in (!TCNT!) do set OUT="!OUT:~1,-1!\!TRAILCOL%%a!\p!TRAILPX%%b!;!TRAILPY%%b!;%STRING%"&set /A TCNT+=1&if !TCNT! geq %TRAIL_LEN% set TCNT=0

gotoxy 0 0 %OUT%

set /a TRAIL_I+=1
if %TRAIL_I% geq %TRAIL_LEN% set /a TRAIL_I=0

if not %KEY% == 27 goto LOOP

del /Q mouse_out.txt>nul
endlocal
cmdwiz quickedit 1
cmdwiz showcursor 1
