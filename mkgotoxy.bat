call tc gotoxy -DSUPPORT_EXTENDED
copy /Y gotoxy.exe gotoxy_extended.exe
::call bkp gotoxy_extended.exe
::copy /Y gotoxy_extended.exe ..\..\cmd

::call tc gotoxy -DSUPPORT_KEYCODES_CHECK
::copy /Y gotoxy.exe gotoxy_keystate.exe
::call bkp gotoxy_keystate.exe
::copy /Y gotoxy_keystate.exe ..\..\cmd

call tc gotoxy
::call bkp gotoxy.*
::copy /Y gotoxy.exe ..\..\cmd
