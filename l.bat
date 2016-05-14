@echo off
set L_PATH=.
if not "%~1" == "" set L_PATH=%1

set L_W=80
::cmdwiz getconsoledim sw&set L_W=!ERRORLEVEL!&if !L_W! lss 80 set L_W=80
if not "%~2" == "" set L_W=%~2&if !L_W! lss 80 set L_W=80

set L_H=50
::cmdwiz getconsoledim sh&set L_H=!ERRORLEVEL!
if not "%~3" == "" set L_H=%~3

set L_COLUMNS=4
::set /a L_COLUMNS=%L_W%/25&(if !L_COLUMNS! lss 1 set L_COLUMNS=1)&if !L_COLUMNS! gtr 9 set L_COLUMNS=9
if not "%~4" == "" set L_COLUMNS=%~4

set L_MOUSE=Y
if not "%~5" == "" set L_MOUSE=

call listb.bat %L_PATH% %L_W% %L_H% %L_COLUMNS% C:\Dos\DJGPP\github\gotoxy\extendlistb.bat %L_MOUSE%
set L_PATH=&set L_W=&set L_H=&set L_MOUSE=
