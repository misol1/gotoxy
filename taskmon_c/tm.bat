@echo off
set /a T_W=210 & if not "%~1" == "" set /a T_W=%~1
set /a T_H=50 & if not "%~2" == "" set /a T_H=%~2
set T_X=-&if not "%~3" == "" set T_X=%~3
set /a T_S=1&if not "%~4" == "" set /a T_S=%~4
call taskmon.bat %T_W% %T_H% %T_X% %T_S% %~dp0extendtm.bat
set T_W=&set T_H=&set T_X=&set T_S=
