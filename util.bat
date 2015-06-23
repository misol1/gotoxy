@echo off
if "%~1" == "" echo Error: No operation& goto :EOF
if "%~1" == "strlen" call :strlen %2 %3& goto OPFIN
if "%~1" == "setprogress" call :setprogress %2& goto OPFIN
if "%~1" == "dectohex" call :dectohex_simple %2 %3 %4& goto OPFIN
echo Error: Unknown operation
:OPFIN
goto :eof


:strlen <resultVar> <stringVar>
(
  echo %~2>tmpLen.dat
  for %%? in (tmpLen.dat) do set /A %1=%%~z? - 2
  del /Q tmpLen.dat
  goto :eof
)

:setprogress <progress>
if "%1" == "" goto :eof
set MYTEMP=
if not "%TMP%" == "" set MYTEMP=%TMP%\
if not "%TEMP%" == "" set MYTEMP=%TEMP%\
echo %1 >%MYTEMP%progressval.dat
set MYTEMP=
goto :eof



:dectohex_simple <result> <value>
if "%2" == "" goto :eof
set P1=
if %2 lss 16 if "%3" == "" goto BELOW16
set /a P1=%2 / 16
call :DECTOHEX2 %P1%
set P1=%P%
:BELOW16
set /a P2=%2 %% 16
call :DECTOHEX2 %P2%
set P2=%P%

set %1=%P1%%P2%
set P1=&set P2=&set P=
goto :eof

:DECTOHEX2
if %1 geq 16 set P=0&goto :eof
if %1 lss 0 set P=0&goto :eof
if %1 leq 9 set P=%1&goto :eof
if %1 == 10 set P=A&goto :eof
if %1 == 11 set P=B&goto :eof
if %1 == 12 set P=C&goto :eof
if %1 == 13 set P=D&goto :eof
if %1 == 14 set P=E&goto :eof
if %1 == 15 set P=F&goto :eof
goto :eof
