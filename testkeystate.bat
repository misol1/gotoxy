@echo off
::https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
setlocal ENABLEDELAYEDEXPANSION

goto LOP2

:LOP
cmdwiz getkeystate ctrl>nul
if %ERRORLEVEL% == 1 echo Control pressed
cmdwiz getkeystate alt>nul
if %ERRORLEVEL% == 1 echo Alt pressed
cmdwiz getkeystate shift>nul
if %ERRORLEVEL% == 1 echo Shift pressed
cmdwiz getkeystate rshift>nul
if %ERRORLEVEL% == 1 echo Right shift pressed
cmdwiz getkeystate 65>nul
if %ERRORLEVEL% == 1 echo A pressed
cmdwiz getkeystate 27>nul
if %ERRORLEVEL% == 0 goto LOP
goto :eof

:LOP2
cmdwiz getkeystate all>nul
set VKEYS=%ERRORLEVEL%
set /a KS=%VKEYS% ^& 1 & if !KS! geq 1 echo RAlt PRESSED...
set /a KS=%VKEYS% ^& 2 & if !KS! geq 1 echo LAlt PRESSED...
set /a KS=%VKEYS% ^& 4 & if !KS! geq 1 echo Alt PRESSED...
set /a KS=%VKEYS% ^& 8 & if !KS! geq 1 echo RCtrl PRESSED...
set /a KS=%VKEYS% ^& 16 & if !KS! geq 1 echo LCtrl PRESSED...
set /a KS=%VKEYS% ^& 32 & if !KS! geq 1 echo Ctrl PRESSED...
set /a KS=%VKEYS% ^& 64 & if !KS! geq 1 echo RShift PRESSED...
set /a KS=%VKEYS% ^& 128 & if !KS! geq 1 echo LShift PRESSED...
set /a KS=%VKEYS% ^& 256 & if !KS! geq 1 echo Shift PRESSED...

cmdwiz getkeystate 25h 26h 27h 28h>nul
set VKEYS=%ERRORLEVEL%
set /a KS=%VKEYS% ^& 1 & if !KS! geq 1 echo Left PRESSED...
set /a KS=%VKEYS% ^& 2 & if !KS! geq 1 echo Up PRESSED...
set /a KS=%VKEYS% ^& 4 & if !KS! geq 1 echo Right PRESSED...
set /a KS=%VKEYS% ^& 8 & if !KS! geq 1 echo Down PRESSED...

cmdwiz getkeystate 27>nul
if %ERRORLEVEL% == 0 goto LOP2
set VKEYS=&set KS=
endlocal