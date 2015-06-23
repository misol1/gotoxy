@echo off
setlocal
mkdir release_%DATE%
set EDATE=release_%DATE%\executables
mkdir %EDATE%
set SDATE=release_%DATE%\src
mkdir %SDATE%
set DDATE=release_%DATE%\docs
mkdir %DDATE%
copy animdata-chess1.bat %EDATE%
copy animdata-chess2.bat %EDATE%
copy animdata-grow.bat %EDATE%
copy animdata-rectangle.bat %EDATE%
copy animplay.bat %EDATE%
copy cardstack.bat %EDATE%
copy cmdwiz.exe %EDATE%
copy editor.bat %EDATE%
copy flappy.bat %EDATE%
copy freecell.bat %EDATE%
copy fx.bat %EDATE%
copy fxcmds.dat %EDATE%
copy fxmenu.dat %EDATE%
copy games.bat %EDATE%
copy gamescmds.dat %EDATE%
copy gamesmenu.dat %EDATE%
copy getchloop.bat %EDATE%
copy getchmenu.bat %EDATE%
copy gotoxy.exe %EDATE%
copy gotoxytest.bat %EDATE%
copy gotoxy_extended.exe %EDATE%
copy gxy2anim.bat %EDATE%
copy hiscore.bat %EDATE%
copy listb.bat %EDATE%
copy makeanim-chess1.bat %EDATE%
copy snake.bat %EDATE%
copy mastermind.bat %EDATE%
copy playcard.bat %EDATE%
copy random.bat %EDATE%
copy rolldice.bat %EDATE%
copy scrolltext.bat %EDATE%
copy slidescreen.bat %EDATE%
copy solitaire.bat %EDATE%
copy spaceinv.bat %EDATE%
copy sprite.bat %EDATE%
copy sprite2.bat %EDATE%
copy sprite3.bat %EDATE%
copy starfield.bat %EDATE%
copy testhiscore.bat %EDATE%
copy testkeystate.bat %EDATE%
copy testmouse.bat %EDATE%
copy util.bat %EDATE%
copy watch.gxy %EDATE%
copy yatzy.bat %EDATE%

copy cmdwiz.c %SDATE%
copy gotoxy.c %SDATE%

endlocal
