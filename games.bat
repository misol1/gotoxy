:: (Games) Menu : Mikael Sollenborn 2015
@echo off
setlocal ENABLEDELAYEDEXPANSION
mode con lines=50 cols=80
color 07
cls
if "%PRESEL%" == "" set PRESEL=0
set FRAMECOL=1&set SELBGCOL=9&set UNSELFGCOL=3&set FRAMETEXTCOL=7&set SHADOWCOL=8&set SELFGCOL=15&set UNSELBGCOL=0
if "%1"=="1" set FRAMECOL=12&set SELBGCOL=9&set UNSELFGCOL=7&set FRAMETEXTCOL=14&set SHADOWCOL=128&set SELFGCOL=15&set UNSELBGCOL=1
if not "%6" == "" set PRESEL=0

set MENUTEXT=gamesmenu.dat& if not "%2" == "" set MENUTEXT=%2
set MENUCMDS=gamescmds.dat& if not "%3" == "" set MENUCMDS=%3
set MENULABEL="GAMES"& if not "%~4" == "" set MENULABEL="%~4"
set WIDTH=42& if not "%5" == "" set WIDTH=%5
cmdwiz showcursor 0

set COUNT=0&for /F %%a in (%MENUTEXT%) do set /a COUNT+=1
set /a YPOS=50/2-%COUNT%-3
set /a XPOS=80/2-%WIDTH%/2+1
set TOPBOT=""& for /L %%a in (1,1,%WIDTH%) do set TOPBOT="!TOPBOT:~1,-1! "
set /a WT=%WIDTH%-2&set SHADE=""& for /L %%a in (1,1,!WT!) do set SHADE="!SHADE:~1,-1!:"
gotoxy %XPOS% %YPOS% %TOPBOT% 7 %FRAMECOL% 1
call util.bat strlen RESULT %MENULABEL%
set /a XT=80/2-%RESULT%/2+1
gotoxy %XT% %YPOS% %MENULABEL% %FRAMETEXTCOL% %FRAMECOL% 1
set /a YT=%YPOS% + %COUNT%*2 + 2
gotoxy %XPOS% %YT% %TOPBOT% 7 %FRAMECOL% 1
set /a YT+=1
set /a XT=%XPOS%+1
gotoxy %XT% %YT% %SHADE% %SHADOWCOL% 0 1
set /a YT=%YPOS%+1
set /a COUNT=%COUNT%*2+1
set SIDE=""& for /L %%a in (1,1,%COUNT%) do set SIDE="!SIDE:~1,-1! "
gotoxy %XPOS% %YT% %SIDE% 7 %FRAMECOL% W %XPOS%
set /a XT=%XPOS%+%WIDTH%-1
gotoxy %XT% %YT% %SIDE% 7 %FRAMECOL% W %XT%
set /a YT=%YPOS%+2
set /a XT=%XPOS%+2
call getchmenu %MENUTEXT% %MENUCMDS% %XT% %YT% %SELFGCOL% %SELBGCOL% %UNSELFGCOL% %UNSELBGCOL% %PRESEL% 1
set PRESEL=
cmdwiz showcursor 1
