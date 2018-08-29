@echo off
set W=80
set H=50
if not "%~1" == "" set W=%~1
if not "%~2" == "" set H=%~2
mode con cols=%W% lines=%H%
if not "%~3" == "" cmdwiz setbuffersize %W% %3
set W=&set H=
echo on