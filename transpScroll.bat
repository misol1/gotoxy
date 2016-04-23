@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0
mode con cols=80 lines=40
gotoxy 0 0 "\N\M5{\M6{\M8{\01          \00          \\}\n\}\M6{\M8{\00          \01          \\}\n\}}" 0 0 x

set COLOR=B
set SCROLLTEXT="Trying out the \E0\QVtransparent\%COLOR%V color effect...                                                                                       "
set DELAY=\W20
set YP=19
set SCROLLPOS=80
cmdwiz stringlen %SCROLLTEXT%&set SCROLL_LEN=!ERRORLEVEL!
set /a SCROLL_LEN=0-(SCROLL_LEN-80)

:LOOP
set /a SCROLLPOS-=1
if %SCROLLPOS% == %SCROLL_LEN% set SCROLLPOS=81 & set /a YP = 5 + %RANDOM% %% 30
gotoxy.exe %SCROLLPOS% %YP% "%SCROLLTEXT:~1,-1%%DELAY%\i" %COLOR% V
if not %ERRORLEVEL% == 27 goto LOOP

endlocal
cmdwiz showcursor 1