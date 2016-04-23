@echo off
:LAB
cmdwiz getch w
set KEY=%ERRORLEVEL%
if not "%KEY%" == "0" echo %KEY%
if "%KEY%" == "27" goto OUT
goto LAB
set KEY=
:OUT
