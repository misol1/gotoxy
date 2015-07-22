@echo off
set L_PATH=.
if not "%~1" == "" set L_PATH=%1
set L_W=81
if not "%~2" == "" set L_W=%~2
set L_H=50
if not "%~3" == "" set L_H=%~3
set L_MOUSE=Y
if not "%~4" == "" set L_MOUSE=
call listb.bat %L_PATH% %L_W% %L_H% C:\Dos\DJGPP\github\gotoxy\extendlistb.bat %L_MOUSE%
set L_PATH=&set L_W=&set L_H=&set L_MOUSE=
