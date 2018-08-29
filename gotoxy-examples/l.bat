@echo off
set L_PATH=.
if not "%~1" == "" set L_PATH=%1

set DIM_MOD=0
cmdwiz getconsoledim sw
set L_W=%ERRORLEVEL%
set L_OLDW=%L_W%
::set L_W=80&set DIM_MOD=1
if %L_W% lss 80 set L_W=80&set DIM_MOD=1
if not "%~2" == "" set L_W=%~2&set DIM_MOD=1

cmdwiz getconsoledim h
set L_OLDBH=%ERRORLEVEL%

cmdwiz getconsoledim sh
set L_H=%ERRORLEVEL%
set L_OLDH=%L_H%
::set L_H=50&set DIM_MOD=1
if %L_H% lss 50 set L_H=50&set DIM_MOD=1
if not "%~3" == "" set L_H=%~3&set DIM_MOD=1

set /a L_COLUMNS=%L_W%/20
if %L_COLUMNS% lss 1 set L_COLUMNS=1
if %L_COLUMNS% gtr 9 set L_COLUMNS=9
set /A L_COLUMNS=-%L_COLUMNS%
::set L_COLUMNS=4
if not "%~4" == "" set L_COLUMNS=%~4

set L_MOUSE=Y
if not "%~5" == "" set L_MOUSE=

call listb.bat %L_PATH% %L_W% %L_H% %L_COLUMNS% %~dp0extendlistb.bat %L_MOUSE%

if %DIM_MOD%==1 mode con cols=%L_OLDW% lines=%L_OLDH%&cls&cmdwiz setbuffersize %L_OLDW% %L_OLDBH%
if %DIM_MOD%==0 cmdwiz setbuffersize %L_W% %L_OLDBH%

set L_W=&set L_H=&set L_COLUMNS=&set L_MOUSE=&set L_PATH=&set L_OLDBH=&set DIM_MOD=&set L_OLDW=&set L_OLDH=
