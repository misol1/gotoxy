@echo off
cls
set YP=0
set XT=15

:YLABEL
set XP=0

:XLABEL
gotoxy %XP% %YP% " @" %XT% 0 1
cmdwiz delay 5
set /A XP=%XP%+1
if %XP% lss %XT% goto XLABEL

set /A XT=%XT%-1

set /A YP=%YP%+1
if %YP% lss 15 goto YLABEL

gotoxy 3 14 "FINISHED" 15 12 1
echo.
set XP=&set YP=&set XT=
