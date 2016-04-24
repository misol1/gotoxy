@echo off
set TEXT=""&if not "%~1" == "" set TEXT="%~1"
set COL=9&if not "%2" == "" set COL=%2
if "%3"=="" gotoxy_extended k k %TEXT% %2 0 csF
if not "%3"=="" gotoxy_extended 0 0 "%TEXT%" %2 0 F
