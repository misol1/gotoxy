@echo off
setlocal
set /A DICE=%RANDOM% %% 6 + 1
set XPOS=0
set YPOS=0
set COL=2
set COL2=7
if NOT "%1" == "" set XPOS=%1
if NOT "%2" == "" set YPOS=%2
if NOT "%3" == "" set COL=%3
if NOT "%4" == "" set COL2=%4
if NOT "%5" == "" set DICE=%5

set /A YTEMP=%YPOS%+1
set DSPR=#######\n
set DSPR=%DSPR%#     #\n

call :DECTOHEX %COL% HCOL
call :DECTOHEX %COL2% HCOL2

if %DICE%==1 set DSPR=%DSPR%#     #\n#  \%HCOL2%0#\%HCOL%0  #\n#     #\n
if %DICE%==2 set DSPR=%DSPR%#  \%HCOL2%0#\%HCOL%0  #\n#     #\n#  \%HCOL2%0#\%HCOL%0  #\n
if %DICE%==3 set DSPR=%DSPR%# \%HCOL2%0#\%HCOL%0   #\n#  \%HCOL2%0#\%HCOL%0  #\n#   \%HCOL2%0#\%HCOL%0 #\n
if %DICE%==4 set DSPR=%DSPR%# \%HCOL2%0# #\%HCOL%0 #\n#     #\n# \%HCOL2%0# #\%HCOL%0 #\n
if %DICE%==5 set DSPR=%DSPR%# \%HCOL2%0# #\%HCOL%0 #\n#  \%HCOL2%0#\%HCOL%0  #\n# \%HCOL2%0# #\%HCOL%0 #\n
if %DICE%==6 set DSPR=%DSPR%# \%HCOL2%0# #\%HCOL%0 #\n# \%HCOL2%0# #\%HCOL%0 #\n# \%HCOL2%0# #\%HCOL%0 #\n

set DSPR=%DSPR%#     #\n
set DSPR=%DSPR%#######
gotoxy.exe %XPOS% %YPOS% "%DSPR%" %COL% 0 c

exit /b %DICE%
endlocal
echo on
goto :EOF

:DECTOHEX
set %2=%1
if %1==10 set %2=A
if %1==11 set %2=B
if %1==12 set %2=C
if %1==13 set %2=D
if %1==14 set %2=E
if %1==15 set %2=F
