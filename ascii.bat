@echo off
set TEXT=""&if not "%~1" == "" set TEXT="%~1"
set COL=u&if not "%2" == "" set COL=%2
if "%3"=="" gotoxy_extended k k %TEXT% %COL% 0 csF
if not "%3"=="" gotoxy_extended 0 0 "%TEXT%" %COL% 0 F
set TEXT=&set COL=