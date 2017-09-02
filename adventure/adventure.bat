:: Adventure : Mikael Sollenborn 2016

:: REMAINING:
:: 1. Allow several items per room (advroom.dat links to items/blockers? Need separate repr. for each room to support dropping)
:: 2. "Blockers" are retarded, since they block in every direction

@echo off
setlocal ENABLEDELAYEDEXPANSION
doskey /MACROS>oldmacros.txt
for %%a in (a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) do echo %%a=>>macroclear.txt
doskey /MACROFILE=macroclear.txt
mode con lines=52 cols=80
if not "%~2"=="" set LOADARG=%~2
color 07

:GAMERESTART
set NEWROOM=1
set DORESTART=0
set RESCOMP=0
cls

set FPATH=".\"
if not "%~1"=="" if exist "%~1\." set FPATH="%~1\"

set F_WORLD="advworld.dat"
if not exist %FPATH:~1,-1%%F_WORLD:~1,-1% echo Error: Missing %F_WORLD%. Bailing out.&goto OUTOF
set CNT=0&set WORLD=&FOR /F "tokens=1 delims=" %%i in (%FPATH:~1,-1%%F_WORLD:~1,-1%) do @set WORLD=!WORLD!%%i&set MYTMP=%%i&set /A CNT+=1
set MYTMP="%MYTMP%"
call :strLen MYTMP STRINGLEN&set WORLDWIDTH=!STRINGLEN!
set WORLDH=%CNT%
set /A WORLDGRIDSIZE=%WORLDH%*%WORLDWIDTH%

set ROOMNOF=0
set F_ROOM="advroom.dat"
if not exist %FPATH:~1,-1%%F_ROOM:~1,-1% goto NOROOMDESC
set CNT=0&set RWORLD=&FOR /F "tokens=1 delims=" %%i in (%FPATH:~1,-1%%F_ROOM:~1,-1%) do @if !CNT! lss %WORLDH% set RWORLD=!RWORLD!%%i&set /A CNT+=1
set CNT=0&FOR /F "eol=; skip=%WORLDH% tokens=1,2,3,4,5 delims=@" %%i in (%FPATH:~1,-1%%F_ROOM:~1,-1%) do @set ROOMKEY!CNT!=%%i&set ROOMNAME!CNT!=%%j&set ROOMDESC!CNT!=%%k&set ROOMEFFECT!CNT!=%%l&if not "%%j"=="" set /A CNT+=1
set /A ROOMNOF=%CNT%-1
for /L %%a in (0,1,%WORLDGRIDSIZE%) do set ROOMSEEN%%a=
:NOROOMDESC

set F_OBJ="advobject.dat"
if not exist %FPATH:~1,-1%%F_OBJ:~1,-1% echo Error: Missing %F_OBJ%. Bailing out.&goto OUTOF
set CNT=0&FOR /F "eol=; tokens=1,2,3,4,5,6,7 delims=@" %%i in (%FPATH:~1,-1%%F_OBJ:~1,-1%) do @set OBJKEY!CNT!=%%i&set OBJDESC!CNT!=%%j&set OBJNAME!CNT!=%%k&set OBJACTION!CNT!=%%l&set OBJREQS!CNT!=%%m&set OBJDETAILS!CNT!=%%n&set OBJPRES!CNT!=%%o&set OBJCOUNT!CNT!=0&if not "%%j"=="" set /A CNT+=1
set /A OBJNOF=%CNT%-1
for /L %%a in (0,1,%OBJNOF%) do if "!OBJREQS%%a!"==" " set OBJREQS%%a=
for /L %%a in (0,1,%OBJNOF%) do set MTMP=!OBJDESC%%a!&if "!MTMP:~0,1!"=="#" set OBJN%%a=n&set OBJDESC%%a=!MTMP:~1!
for /L %%a in (0,1,%OBJNOF%) do call :SEPARATE !OBJREQS%%a!& for /L %%b in (0,1,!ACTIONPNOF!) do set OBJREQS%%a_%%b=!ACTIONP%%b!
call :RESETCOUNTERS

set SCORE=0&set MAXSCORE=
set F_MSG="advmsg.dat"
if exist %FPATH:~1,-1%%F_MSG:~1,-1% set CNT=0&for /F "eol=; tokens=* delims=" %%i in (%FPATH:~1,-1%%F_MSG:~1,-1%) do set MSG!CNT!=%%i&if not "%%i"=="" if not "%%i"==" " set /A CNT+=1
if "%MSG1%"=="" set MSG1=Welcome to the \E0dungeon\r. Find the exit and leave.
if "%MSG2%"=="" set MSG2=You did it... Well done.
if "%MSG3%"=="" set MSG3=But you cannot do that...
if "%MSG4%"=="" set MSG4=You see: #
if "%MSG5%"=="" set MSG5=Exits: 
if "%MSG6%"=="" set MSG6=Action: 
if "%MSG7%"=="" set MSG7=A+ # blocks your way to the ?
if "%MSG8%"=="" set MSG8=You are carrying...
if "%MSG9%"=="" set MSG9=\n\c0Score: 
if "%MSG10%"=="" set MSG10=Which one? Be more specific please...
if "%MSG11%"=="" set MSG11=\n\n************************\n    YOU HAVE DIED\g21\g21\n************************\n
call :SETCOLS %MSG0%
cmdwiz stringfind "%MSG1%" "#"&set /A IX=!ERRORLEVEL!&set /A IX2=!ERRORLEVEL!+1
if not %IX%==-1 set ARTW=%FPATH:~1,-1%!MSG1:~0,%IX%!& gotoxy 0 0 !ARTW! 0 0 cs&set MSG1=!MSG1:~%IX2%!
call :PRINTCOL "%MSG1%"


set F_ACT="advaction.dat"
if not exist %FPATH:~1,-1%%F_ACT:~1,-1% echo Error: Missing %F_ACT%. Bailing out.&goto OUTOF
set CNT=0&FOR /F "eol=; tokens=1,2,3,4,5,6,7 delims=@" %%i in (%FPATH:~1,-1%%F_ACT:~1,-1%) do @set ACTKEY!CNT!=%%i&set ACTNAME!CNT!=%%j&set ACTSHORT!CNT!=%%k&set MYTMP="%%j"&call :strLen MYTMP STRINGLEN&set ACTNAMELEN!CNT!=!STRINGLEN!&set ACTNAME=%%j&set ACTSUCCESS!CNT!=%%l&set ACTSUCCESSEFFECT!CNT!=%%m&set ACTFAIL!CNT!=%%n&set ACTFAILEFFECT!CNT!=%%o&set ACTSIMPLE!CNT!=0&if not "%%j"=="" set /A CNT+=1&if "!ACTNAME:~0,1!"=="#" set /A CNT2=!CNT!-1&set ACTNAME!CNT2!=!ACTNAME:~1!&set /A ACTNAMELEN!CNT2!-=1&set ACTSIMPLE!CNT2!=1
set /A ACTNOF=%CNT%-1

set F_EFFECT="adveffect.dat"
if not exist %FPATH:~1,-1%%F_EFFECT:~1,-1% echo Error: Missing %F_EFFECT%. Bailing out.&goto OUTOF
set CNT=0&FOR /F "eol=; tokens=1,2,3,4,5,6 delims=@" %%i in (%FPATH:~1,-1%%F_EFFECT:~1,-1%) do @set EFFOBJECT!CNT!=%%i&set EFFACTS!CNT!=%%j&set EFFSUCCESS!CNT!=%%k&set EFFSUCCESSEFFECT!CNT!=%%l&set EFFFAIL!CNT!=%%m&set EFFFAILEFFECT!CNT!=%%n&if not "%%j"=="" set /A CNT+=1
set /A EFFNOF=%CNT%-1

set CNT=0&for %%a in (e,w,s,n) do set DIRN!CNT!=%%a&set /A CNT+=1
set CNT=0&for %%a in (east,west,south,north) do set DIRLN!CNT!=%%a&set /A CNT+=1
set CNT=0&for %%a in (1,-1,%WORLDWIDTH%,-%WORLDWIDTH%,0) do set DIRMOD!CNT!=%%a&set /A CNT+=1

cmdwiz stringfind "%WORLD%" "o"&set PP=!ERRORLEVEL!
call :REMOVEOBJECT %PP%
set INV=
set OLDACT=l
set ISDEAD=0
call :SETINIT %MSG0%

if not "%LOADARG%" == "" call :LOADSTATE %LOADARG% 
set LOADARG=

:GAMELOOP
set DEF=0
set SUCCESS=0
if "!WORLD:~%PP%,1!"=="x" call :PRINTCOL "\n%MSG2%"&goto OUTOF
echo.
::echo %WORLD%
call :CHECKROOMDESC
set TMPMSG=
if "%ROOM_EFFECT%"==" " goto SKIPRFX
if "%ROOM_EFFECT%"=="" goto SKIPRFX
set ROOM_EFFECT=%ROOM_EFFECT: =_%
set ROOM_EFFECTSPL=%ROOM_EFFECT:/=" "%
set MC=!WORLD:~%PP%,1!
call :SEPARATE "%ROOM_EFFECTSPL%"
call :CAUSEEFFECT %PP% %PP%
if "%ISDEAD%"=="1" call :PRINTCOL "%MSG11%" %TEXT_DEF_COL%&goto HASDIED
:SKIPRFX
call :CHECKOBJS
call :CHECKEXITS
:REP
call :PRINTCOL "%MSG6%" %TEXT_DEF_COL% no
set ACTION=&set /P ACTION=
:AGAIN
if "%ACTION%"=="" goto REP
call :LOCASE ACTION
set ACTION=%ACTION:the =%
call :SEPARATE %ACTION%
set ACTINDEX=-1
set ACTREST=
set PROCESSED=0

for /L %%a in (0,1,%ACTNOF%) do if "!ACTSHORT%%a!"=="!ACTIONP1!" set ACTINDEX=%%a&set ACTREST=&for /L %%b in (2,1,%ACTIONPNOF%) do set ACTREST=!ACTREST! !ACTIONP%%b!
if %ACTINDEX%==-1 for /L %%a in (0,1,%ACTNOF%) do if "%ACTIONP1:~0,1%"=="!ACTNAME%%a:~0,1!" call :CHECKACTION %%a&if not !ACTINDEX!==-1 goto ACTFOUND
if %ACTINDEX%==-1 goto INVALIDACT
:ACTFOUND

if not "%ACTREST%"=="" set ACTJUNK=%ACTREST: =%&if "!ACTSIMPLE%ACTINDEX%!"=="1" if not "!ACTJUNK!"=="" set ACTINDEX=-1& goto INVALIDACT
set OLDPP=%PP%
for /L %%a in (0,1,3) do if "!ACTSHORT%ACTINDEX%!"=="!DIRN%%a!" call :MOVE %%a&goto ACTDONE
if "!ACTKEY%ACTINDEX%!"=="I" call :INV&goto ACTDONE
if "!ACTKEY%ACTINDEX%!"=="L" set ROOMSEEN%PP%=&set NEWROOM=1&goto ACTDONE
if "!ACTKEY%ACTINDEX%!"=="E" call :EXAMINE&set PROCESSED=1&if !ACTINDEX!==-1 set PROCESSED=0&goto ACTDONE
if "!ACTKEY%ACTINDEX%!"=="G" call :PRINTCOL "{%OLDACT%}" %TEXT_DEF_COL%&set ACTION=%OLDACT%&goto :AGAIN
if "!ACTKEY%ACTINDEX%!"=="Q" goto OUTOF
if "!ACTKEY%ACTINDEX%!"=="q" gotoxy k k "Are you sure(y/n)?\K\p0;k;                         " f 0 C&set DORESTART=!ERRORLEVEL!&goto ACTDONE
if "!ACTKEY%ACTINDEX%!"=="s" call :SAVESTATE "%ACTREST%"&goto ACTDONE
if "!ACTKEY%ACTINDEX%!"=="l" call :LOADSTATE "%ACTREST%"&goto ACTDONE

call :ACTPROCESS !ACTKEY%ACTINDEX%! "!ACTSUCCESS%ACTINDEX%!" "!ACTFAIL%ACTINDEX%!" !ACTSUCCESSEFFECT%ACTINDEX%! !ACTFAILEFFECT%ACTINDEX%!

:ACTDONE
if "%ISDEAD%"=="1"  call :PRINTCOL "%MSG11%" %TEXT_DEF_COL%&goto HASDIED
if "%DORESTART%"=="121" goto GAMERESTART
if not %PP%==%OLDPP% set NEWROOM=1
set OLDACT=%ACTION%

:INVALIDACT
if %ACTINDEX%==-1 if "%SUCCESS%"=="0" if "%PROCESSED%"=="0" for /L %%a in (0,1,%ACTNOF%) do if "%ACTIONP1:~0,1%"=="!ACTNAME%%a:~0,1!" call :CHECKTOFROM %%a&if not !ACTINDEX!==-1 set SUCCESS=1&goto INVALIDACT
if %ACTINDEX%==-1 if "%SUCCESS%"=="0" if "%PROCESSED%"=="0" call :PRINTCOL "%MSG3%" %TEXT_RESPONSE_COL%&goto GAMELOOP
goto GAMELOOP

:HASDIED
call :PRINTCOL "Press R to restart, Q to quit, 1-9 to load saved state." f
:DEADLOOP
cmdwiz getch
set KEY=!ERRORLEVEL!
if %KEY% geq 49 if %KEY% leq 57 set /A LS=%KEY%-48&call :LOADSTATE "!LS!"&if !LOADOK!==1 set ISDEAD=0&set NEWROOM=1&goto ACTDONE
if %KEY% geq 49 if %KEY% leq 57 call :PRINTCOL "\nPress R to restart, Q to quit, 1-9 to load saved state." f
if %KEY% == 114 goto GAMERESTART
if %KEY% == 82 goto GAMERESTART
if not %KEY%==113 if not %KEY%==81 goto DEADLOOP

:OUTOF
endlocal
doskey /MACROFILE=oldmacros.txt
del /Q oldmacros.txt macroclear.txt>nul
goto :eof


:ACTPROCESS
::echo %1 . %2 . %3 . %4 . %5
set A_ACTKEY=%1&set A_ACTSUCC=%2&set A_ACTFAIL=%3&set A_ACTSUCCFX=%4&set A_ACTFAILFX=%5
set SUCCESS=0
set OBJI=-1
call :PICKUP

if %SUCCESS%==0 call :OPEN
if %SUCCESS%==0 call :USE
if %SUCCESS%==0 call :REACT
goto :eof


:EXPANDCOUNTERS
for %%i in (a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,_) do set COUNT=!OBJCOUNT%%i!&if not "!COUNT!"=="" for %%j in (!COUNT!) do set PMSG=!PMSG:$%%i=%%j!
for /L %%i in (0,1,%OBJNOF%) do set COUNT=!OBJCOUNT%%i!&if not "!COUNT!"=="" for %%j in (!COUNT!) do set PMSG=!PMSG:$%%i=%%j!
set PMSG=%PMSG:$$=$%
goto :eof


:CAUSEEFFECT
set CNT=1
set OLDSCORE=%SCORE%
:REPEATEFF
set EFFE=!ACTIONP%CNT%!
::echo %EFFE%
if "%EFFE%"=="" goto SKIPPER
if "%EFFE%"=="A" set INV=%INV%%MC%&call :REMOVEOBJECT %2
if "%EFFE:~0,1%"=="G" set COND=%EFFE:~1,1%&cmdwiz stringfind "%INV%" !COND!&if !ERRORLEVEL!==-1 set INV=%INV%!COND!
if "%EFFE:~0,1%"=="g" set INV=%INV%%EFFE:~1%
if "%EFFE:~0,1%"=="U" set INV=!INV:%EFFE:~1%=!
if "%EFFE:~0,1%"=="R" call :REMOVEOBJECT %2 %EFFE:~1% %1
if "%EFFE:~0,1%"=="X" call :REMOVEOBJECT %2 %EFFE:~1% %2
if "%EFFE:~0,1%"=="P" set PMSG="%EFFE:~1%"&set PMSG=!PMSG:_= !&call :PRINTCOL !PMSG! %TEXT_RESPONSE_COL%
if "%EFFE:~0,1%"=="p" set PMSG="%EFFE:~1%"&set PMSG=!PMSG:_= !&call :PRINTCOL !PMSG! %TEXT_RESPONSE_COL%&set TMPMSG=
if "%EFFE:~0,1%"=="d" set PMSG="%EFFE:~1%"&call :EXPANDCOUNTERS&set PMSG=!PMSG:_= !&call :PRINTCOL !PMSG! %TEXT_RESPONSE_COL%
if "%EFFE:~0,1%"=="M" cmdwiz stringfind "%RWORLD%" "%EFFE:~1%"&if !ERRORLEVEL! geq 0 set PP=!ERRORLEVEL!
if "%EFFE:~0,1%"=="m" for /L %%a in (0,1,3) do if "%EFFE:~1%"=="!DIRN%%a!" call :MOVE %%a
if "%EFFE:~0,1%"=="S" set /A SCORE+=%EFFE:~1%
if "%EFFE:~0,1%"=="D" set ISDEAD=1
if "%EFFE:~0,1%"=="e" set FROM_O=%EFFE:~1,1%&set TO_O=%EFFE:~2,1%&for %%v in (!FROM_O!) do for %%w in (!TO_O!) do set WORLD=!WORLD:%%v=%%w!
if "%EFFE:~0,1%"=="E" set FROM_O=%EFFE:~1,1%&set TO_O=%EFFE:~2,1%&cmdwiz stringfind "%WORLD%" !FROM_O!&set TMPRES=!ERRORLEVEL!&if not !TMPRES!==-1 call :REMOVEOBJECT !TMPRES! !TO_O! !TMPRES!
if "%EFFE:~0,1%"=="C" call :OBJCOUNT %OBJI% "%EFFE:~1,1%" "%EFFE:~2%"
if "%EFFE:~0,1%"=="c" call :OBJCOUNT %EFFE:~1,1% "%EFFE:~2,1%" "%EFFE:~3%"
if "%EFFE:~0,1%"=="V" call :COMPARECOUNT %OBJI% "%EFFE:~1,1%" %EFFE:~2,1% &if !RESCOMP! == 1 set ACTIONP%CNT%=%EFFE:~3%&set /A CNT-=1
if "%EFFE:~0,1%"=="v" call :COMPARECOUNT %EFFE:~1,1% "%EFFE:~2,1%" %EFFE:~3,1% &if !RESCOMP! == 1 set ACTIONP%CNT%=%EFFE:~4%&set /A CNT-=1
if "%EFFE:~0,1%"=="I" set COND=%EFFE:~1,1%&cmdwiz stringfind "%INV%" !COND!&if not !ERRORLEVEL!==-1 set ACTIONP%CNT%=%EFFE:~2%&set /A CNT-=1
if "%EFFE:~0,1%"=="i" set COND=%EFFE:~1,1%&cmdwiz stringfind "%INV%" !COND!&if !ERRORLEVEL!==-1 set ACTIONP%CNT%=%EFFE:~2%&set /A CNT-=1
if "%EFFE:~0,1%"=="L" set COND=!RWORLD:~%PP%,1!&if "%EFFE:~1,1%"=="!COND!" set ACTIONP%CNT%=%EFFE:~2%&set /A CNT-=1
if "%EFFE:~0,1%"=="l" set COND=!RWORLD:~%PP%,1!&if not "%EFFE:~1,1%"=="!COND!" set ACTIONP%CNT%=%EFFE:~2%&set /A CNT-=1
set /A CNT+=1
if %CNT% leq %ACTIONPNOF% goto REPEATEFF
:SKIPPER
call :PRINTCOL "%TMPMSG%" %TEXT_RESPONSE_COL%
if not %SCORE%==%OLDSCORE% call :PRINTCOL "%MSG9%!SCORE!/%MAXSCORE%" %TEXT_DESC_COL%
goto :eof

:HANDLEFAIL
if "%~1" == "" if "%A_ACTFAILFX%"=="" set ACTINDEX=-1&goto :eof
if "%~1" == " " if "%A_ACTFAILFX%"=="" set ACTINDEX=-1&goto :eof
set A_ACTFAILFX=%A_ACTFAILFX: =_%
set A_ACTFAILFXSPL=%A_ACTFAILFX:/=" "%
call :SEPARATE "%A_ACTFAILFXSPL%"
call :CAUSEEFFECT %2 %3
goto :eof

:PICKUP
set MC=!WORLD:~%PP%,1!
for /L %%a in (0,1,%OBJNOF%) do if " !OBJNAME%%a!"=="%ACTREST%" if "!OBJKEY%%a!"=="%MC%" set OBJI=%%a
for /L %%a in (0,1,%OBJNOF%) do if " !OBJDESC%%a! !OBJNAME%%a!"=="%ACTREST%" if "!OBJKEY%%a!"=="%MC%" set OBJI=%%a
if %OBJI%==-1 set ACTINDEX=-1&goto :eof
cmdwiz stringfind "!OBJACTION%OBJI%!" %A_ACTKEY%&if !ERRORLEVEL!==-1 set ACTINDEX=-1&goto :eof
set PROCESSED=1
call :PREPARESPECIALFX %A_ACTKEY% %MC%
call :CHECKREQ %A_ACTKEY%&if !OKREQ!==0 call :PREPAREMSG %A_ACTFAIL% & call :HANDLEFAIL "!TMPMSG!" %PP% %PP%& set SUCCESS=-1&goto :eof
call :PREPAREMSG %A_ACTSUCC%
set A_ACTSUCCFX=%A_ACTSUCCFX: =_%
set A_ACTSUCCFXSPL=%A_ACTSUCCFX:/=" "%
call :SEPARATE "%A_ACTSUCCFXSPL%"
call :CAUSEEFFECT %PP% %PP%
set SUCCESS=1
goto :eof

:OPEN
for /L %%a in (0,1,%OBJNOF%) do if " !OBJNAME%%a!"=="%ACTREST%" cmdwiz stringfind %EXITS% "!OBJKEY%%a!"&if not !ERRORLEVEL!==-1 set OBJI=%%a
for /L %%a in (0,1,%OBJNOF%) do if " !OBJDESC%%a! !OBJNAME%%a!"=="%ACTREST%" set OBJI=%%a
set MC=!OBJKEY%OBJI%!
set TMC=%MC%&call :UPCASE TMC
if not "%TMC%"=="%MC%" set ACTINDEX=-1&goto :eof
cmdwiz stringfind %EXITS% "%MC%"&set FND=!ERRORLEVEL!&if !FND!==-1 set ACTINDEX=-1&goto :eof
set /A PPO=%PP%+!DIRMOD%FND%!
if %OBJI%==-1 set ACTINDEX=-1&goto :eof
cmdwiz stringfind "!OBJACTION%OBJI%!" %A_ACTKEY%&if !ERRORLEVEL!==-1 set ACTINDEX=-1&goto :eof
set PROCESSED=1
call :PREPARESPECIALFX %A_ACTKEY% %MC%
call :CHECKREQ %A_ACTKEY%&if !OKREQ!==0 call :PREPAREMSG %A_ACTFAIL% & call :HANDLEFAIL "!TMPMSG!" %PP% %PPO%& set SUCCESS=-1&goto :eof
call :PREPAREMSG %A_ACTSUCC%
set A_ACTSUCCFX=%A_ACTSUCCFX: =_%
set A_ACTSUCCFXSPL=%A_ACTSUCCFX:/=" "%
call :SEPARATE "%A_ACTSUCCFXSPL%"
call :CAUSEEFFECT %PP% %PPO%
set SUCCESS=1
goto :eof

:USE
for /L %%a in (0,1,%OBJNOF%) do if " !OBJNAME%%a!"=="%ACTREST%" cmdwiz stringfind " %INV%" "!OBJKEY%%a!"&if not !ERRORLEVEL!==-1 set OBJI=%%a
for /L %%a in (0,1,%OBJNOF%) do if " !OBJDESC%%a! !OBJNAME%%a!"=="%ACTREST%" set OBJI=%%a
set MC=!OBJKEY%OBJI%!
cmdwiz stringfind " %INV%" "%MC%"&set FND=!ERRORLEVEL!&if !FND!==-1 set ACTINDEX=-1&goto :eof
if %OBJI%==-1 set ACTINDEX=-1&goto :eof
cmdwiz stringfind "!OBJACTION%OBJI%!" %A_ACTKEY%&if !ERRORLEVEL!==-1 set ACTINDEX=-1&goto :eof
if "%A_ACTKEY%"=="T" set ACTINDEX=-1&goto :eof& rem HACK to disable "taking" stuff in inventory
set PROCESSED=1
call :PREPARESPECIALFX %A_ACTKEY% %MC%
call :CHECKREQ %A_ACTKEY%&if !OKREQ!==0 call :PREPAREMSG %A_ACTFAIL% & call :HANDLEFAIL "!TMPMSG!" %PP% %PP%& set SUCCESS=-1&goto :eof
call :PREPAREMSG %A_ACTSUCC%
set A_ACTSUCCFX=%A_ACTSUCCFX: =_%
set A_ACTSUCCFXSPL=%A_ACTSUCCFX:/=" "%
call :SEPARATE "%A_ACTSUCCFXSPL%"
call :CAUSEEFFECT %PP% %PP%
set SUCCESS=1
goto :eof


:REACT
set RC=!RWORLD:~%PP%,1!
call :PREPARESPECIALFX_ROOM %A_ACTKEY% %RC%
if %SFXI%==-1 goto :eof
call :PREPAREMSG %A_ACTSUCC%
set A_ACTSUCCFX=%A_ACTSUCCFX: =_%
set A_ACTSUCCFXSPL=%A_ACTSUCCFX:/=" "%
call :SEPARATE "%A_ACTSUCCFXSPL%"
call :CAUSEEFFECT %PP% %PP%
set SUCCESS=1
goto :eof


:PREPARESPECIALFX
set SFXI=-1
for /L %%a in (0,1,%EFFNOF%) do if "!EFFOBJECT%%a!"=="%2" cmdwiz stringfind "!EFFACTS%%a!" "%1"&if not !ERRORLEVEL!==-1 set SFXI=%%a
if %SFXI%==-1 goto :eof
set A_ACTSUCC="!EFFSUCCESS%SFXI%!"
set A_ACTFAIL="!EFFFAIL%SFXI%!"
set A_ACTSUCCFX=!EFFSUCCESSEFFECT%SFXI%!
set A_ACTFAILFX=!EFFFAILEFFECT%SFXI%!
goto :eof

:PREPARESPECIALFX_ROOM
set SFXI=-1
for /L %%a in (0,1,%EFFNOF%) do if "!EFFOBJECT%%a!"=="#%2" cmdwiz stringfind "!EFFACTS%%a!" "%1"&if not !ERRORLEVEL!==-1 set SFXI=%%a
::this too slow??
::if %SFXI%==-1 for /L %%a in (0,1,%EFFNOF%) do if "!EFFOBJECT%%a!"=="#?" cmdwiz stringfind "!EFFACTS%%a!" "%1"&if not !ERRORLEVEL!==-1 set SFXI=%%a
if %SFXI%==-1 for /L %%a in (0,1,%EFFNOF%) do if "!EFFOBJECT%%a!"=="#?" if "!EFFACTS%%a!"=="%1" set SFXI=%%a
if %SFXI%==-1 goto :eof
set A_ACTSUCC="!EFFSUCCESS%SFXI%!"
set A_ACTFAIL="!EFFFAIL%SFXI%!"
set A_ACTSUCCFX=!EFFSUCCESSEFFECT%SFXI%!
set A_ACTFAILFX=!EFFFAILEFFECT%SFXI%!
goto :eof

:PREPAREMSG
set TMPMSG=%~1
if "%TMPMSG%"==" " goto :eof	
if "%TMPMSG%"=="" goto :eof	
echo %TMPMSG%>advtmp.dat
for /F "eol=; tokens=1,2,3,4,5,6,7,8,9 delims=/" %%i in (advtmp.dat) do call :SPLITPRES "%%i" "%%j" "%%k" "%%l" "%%m" "%%n" "%%o" "%%p" "%%q"
del /Q advtmp.dat>nul
set TMPMSG2=!OBJDESC%OBJI%! !OBJNAME%OBJI%!
set TMPMSG=!TMPMSG:#=%TMPMSG2%!
goto :eof
:SPLITPRES
if not "%~1"=="" set NOF=1
if not "%~2"=="" set NOF=2
if not "%~3"=="" set NOF=3
if not "%~4"=="" set NOF=4
if not "%~5"=="" set NOF=5
if not "%~6"=="" set NOF=6
if not "%~7"=="" set NOF=7
if not "%~8"=="" set NOF=8
if not "%~9"=="" set NOF=9
set TK=!OBJKEY%OBJI%!
if "!MC%TK%!"=="" set MC%TK%=0
if !MC%TK%! geq %NOF% set MC%TK%=0
::set /A CHC=!RANDOM! %% %NOF%
set /A CHC=!MC%TK%!
for /L %%a in (1,1,%CHC%) do shift
set /A MC%TK%+=1
if !MC%TK%! geq %NOF% set MC%TK%=0
set TMPMSG=%~1
goto :eof


:OBJCOUNT
set VAL=1
if not "%~3"=="" set VAL=%~3
if "%~2"=="+" set /A OBJCOUNT%1+=%VAL%&goto :eof
if "%~2"=="-" set /A OBJCOUNT%1-=%VAL%&goto :eof
set VAL=%~2%~3
set /A OBJCOUNT%1=%VAL%
goto :eof

:COMPARECOUNT
set RESCOMP=0
set VAL=%3
for %%a in (a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,_) do if "%VAL%"=="%%a" set VAL=!OBJCOUNT%%a!
if "%~2"=="=" if !OBJCOUNT%1! == %VAL% set RESCOMP=1
if "%~2"=="~" if not !OBJCOUNT%1! == %VAL% set RESCOMP=1
if "%~2"=="L" if !OBJCOUNT%1! lss %VAL% set RESCOMP=1
if "%~2"=="G" if !OBJCOUNT%1! gtr %VAL% set RESCOMP=1
goto :eof

:RESETCOUNTERS
for /L %%a in (0,1,%OBJNOF%) do set OBJCOUNT%%a=
for %%a in (a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,_) do set OBJCOUNT%%a=
goto :eof

:CHECKREQ
cmdwiz stringfind "!OBJACTION%OBJI%!" "%1"&set REQI=!ERRORLEVEL!&if !REQI!==-1 set OKREQ=0&goto :eof
set /A REQI+=1
set REQ=!OBJREQS%OBJI%_%REQI%!
set OKREQ=1
if "%REQ%"=="" goto :eof
set MYTMP="%REQ%"
call :strLen MYTMP STRINGLEN
set /a RL=!STRINGLEN!-1
for /L %%a in (0,1,%RL%) do cmdwiz stringfind "%INV%" "!REQ:~%%a,1!"&if !ERRORLEVEL!==-1 set OKREQ=0
goto :eof


:EXAMINE
set SUCCESS=0
set OBJI=-1
set NOFF=0
for /L %%a in (0,1,%OBJNOF%) do if " !OBJNAME%%a!"=="%ACTREST%" cmdwiz stringfind %EXITS% "!OBJKEY%%a!"&if not !ERRORLEVEL!==-1 set OBJI=%%a&for %%i in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do if !OBJKEY%%a!==%%i set /A NOFF+=1
for /L %%a in (0,1,%OBJNOF%) do if " !OBJNAME%%a!"=="%ACTREST%" cmdwiz stringfind "%INV% " "!OBJKEY%%a!"&if not !ERRORLEVEL!==-1 set OBJI=%%a&set /A NOFF+=1
for /L %%a in (0,1,%OBJNOF%) do if " !OBJNAME%%a!"=="%ACTREST%" if "!OBJKEY%%a!"=="!WORLD:~%PP%,1!" set OBJI=%%a&set /A NOFF+=1
for /L %%a in (0,1,%OBJNOF%) do if " !OBJDESC%%a! !OBJNAME%%a!"=="%ACTREST%" set OBJI=%%a
if %OBJI%==-1 set ACTINDEX=-1&goto :eof
set MC=!OBJKEY%OBJI%!
set ISB=0&for %%i in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do if "%MC%"=="%%i" set ISB=1&if !ISB!==1 cmdwiz stringfind %EXITS% %MC%&if not !ERRORLEVEL!==-1 set SUCCESS=1
cmdwiz stringfind "%INV%" %MC%&if not !ERRORLEVEL!==-1 set SUCCESS=1
if "%MC%"=="!WORLD:~%PP%,1!" set SUCCESS=1
if %NOFF% gtr 1 call :PRINTCOL "%MSG10%" %TEXT_RESPONSE_COL%&set SUCCESS=1&goto :eof
call :PREPAREMSG "!OBJDETAILS%OBJI%!"
if %SUCCESS%==1 call :PRINTCOL "%TMPMSG%" %TEXT_RESPONSE_COL%
if %SUCCESS%==0 set ACTINDEX=-1
goto :eof


:INV
call :PRINTCOL "%MSG8%" %TEXT_RESPONSE_COL%
set MYTMP="%INV%"
call :strLen MYTMP STRINGLEN
set IL=%STRINGLEN%
::echo %INV%
for /L %%a in (0,1,%IL%) do call :PRINTOBJ !INV:~%%a,1!
goto :eof
:PRINTOBJ
for /L %%a in (0,1,%OBJNOF%) do if "!OBJKEY%%a!"=="%1" call :PRINTCOL "!OBJDESC%%a! !OBJNAME%%a!" %TEXT_RESPONSE_COL%
goto :eof


:SEPARATE
set SCNT=1
:SREP
if "%~1"=="" set /A ACTIONPNOF=%SCNT%-1&goto :eof
set ACTIONP%SCNT%=%~1
set /A SCNT+=1
shift
goto SREP

:CHECKACTION
set ACT_T=&set SPC=
set TMPACTNAME=!ACTNAME%1!
set TMPACTNAME=!TMPACTNAME:#=%ACTIONP2%!
set TMPACTINDEX=%ACTINDEX%
for /L %%a in (1,1,%ACTIONPNOF%) do set ACT_T=!ACT_T!!SPC!!ACTIONP%%a!&set SPC= &if "%TMPACTNAME%"=="!ACT_T!" set ACTINDEX=%1&set ACTREST=&set /A SI=%%a+1&for /L %%b in (!SI!,1,%ACTIONPNOF%) do set ACTREST=!ACTREST! !ACTIONP%%b!
if not %ACTINDEX%==%TMPACTINDEX% if not "%TMPACTNAME%"=="!ACTNAME%1!" set ACTIONP%ACTIONPNOF%=%ACTIONP2%&set /A ACTIONPNOF+=1&set ACTREST=!ACTREST! !ACTIONP2!
goto :eof

:CHECKTOFROM
set ACT_T=&set SPC=
set TMPACTNAME=!ACTNAME%1!
set TMPACTNAME=!TMPACTNAME:#=%ACTIONP2%!
set TMPACTINDEX=%ACTINDEX%
for /L %%a in (1,1,%ACTIONPNOF%) do set ACT_T=!ACT_T!!SPC!!ACTIONP%%a!&set SPC= 
for %%a in (on,from,to,for,at,with,of) do if "%TMPACTNAME%"=="%ACT_T% %%a" set QUES=%%a&set QUESB=!QUES:~0,1!&call :UPCASE QUESB&call :PRINTCOL  "!QUESB!!QUES:~1!?" %TEXT_RESPONSE_COL%&set ACTINDEX=dummy
goto :eof


:REMOVEOBJECT
set /A RI=%1+1
set WORLD=!WORLD:~0,%1! !WORLD:~%RI%!
if "%3"=="" goto :eof
set /A RI=%3+1
set WORLD=!WORLD:~0,%3!%2!WORLD:~%RI%!
goto :eof

:CHECKEXITS
set EXITS=""
set OUTS=%MSG5%
set BLOCKS=""
for /L %%a in (0,1,3) do call :CHECKEXIT %%a
if not %BLOCKS% == "" call :PRINTCOL "%BLOCKS:~1,-1%" %TEXT_DESC_COL% no
call :PRINTCOL "%OUTS%"
goto :eof
:CHECKEXIT
set /A MX=%PP%+!DIRMOD%1!
set MC=!WORLD:~%MX%,1!
set EXITS="%EXITS:~1,-1%%MC%"
call :ISEXIT "%MC%"
if %ISX%==1 set OUTS=%OUTS%!DIRN%1! 
if %ISBLOCK%==1 call :CHECKBLOCK %MC% %1
goto :eof
:ISEXIT
set ISX=1
set ISBLOCK=0
for %%i in (@,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do if %1=="%%i" set ISX=0
for %%i in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do if %1=="%%i" set ISBLOCK=1
goto :eof

:CHECKBLOCK
set MSG=%MSG7%
call :MAKEPRESENTATION %1 %2
if not %FND%==-1 set BLOCKS="%BLOCKS:~1,-1%%MSG%\n"
goto :eof

:CHECKOBJS
set MSG=%MSG4%
set MC=!WORLD:~%PP%,1!
call :MAKEPRESENTATION %MC%
if not %FND%==-1 call :PRINTCOL "%MSG%" %TEXT_DESC_COL%
goto :eof

:CHECKROOMDESC
set MC=!RWORLD:~%PP%,1!
set RDESC=""
set RDESC2=""
set ROOM_EFFECT=
for /L %%a in (0,1,%ROOMNOF%) do if "!ROOMKEY%%a!"=="%MC%" set RDESC="!ROOMNAME%%a!"&set RDESC2="!ROOMDESC%%a!"&set ROOM_EFFECT=!ROOMEFFECT%%a!
if not %RDESC%=="" if "!NEWROOM!"=="1" call :PRINTCOL %RDESC% %TEXT_ROOMNAME_COL%
if not %RDESC2%=="" if not "!ROOMSEEN%PP%!"=="1" call :PRINTCOL %RDESC2% %TEXT_ROOMDESC_COL%
set ROOMSEEN%PP%=1
set NEWROOM=0
goto :eof

:MAKEPRESENTATION
set FND=-1
FOR /L %%a in (0,1,%OBJNOF%) do if "!OBJKEY%%a!"=="%1" set FND=%%a
if %FND%==-1 goto :eof
if not "!OBJPRES%FND%!"=="" if not "!OBJPRES%FND%!"==" " set MSG=!OBJPRES%FND%!
set MTMP=!OBJDESC%FND%!
set MTMP2=!OBJNAME%FND%!
set MSG=!MSG:#=%MTMP% %MTMP2%!
set MTMP=!DIRLN%2!
set MSG=!MSG:?=%MTMP%!
set MTMP=!OBJN%FND%!
set MSG=!MSG:+=%MTMP%!
goto :eof


:MOVE
set /A MX=%1+1
set ET=!EXITS:~%MX%,1!
call :ISEXIT "%ET%"
if %ISX%==0 set ACTINDEX=-1&goto :eof
set CNT=-1
for /L %%a in (0,1,3) do set /A CNT+=1&if !CNT!==%1 set /A PP+=!DIRMOD%1!
goto :eof

:PRINTCOL
if "%~1"==" " goto :eof
if "%~1"=="" goto :eof
set COL=%TEXT_DEF_COL%&if not "%2"=="" set COL=%2
set NL=\n&if not "%3"=="" set NL=
gotoxy 0 k "%~1%NL%" %COL% U CsW
goto :eof

:SETCOLS
set TEXT_DEF_COL=u&if not "%1"=="" set TEXT_DEF_COL=%1
set TEXT_DESC_COL=u&if not "%2"=="" set TEXT_DESC_COL=%2
set TEXT_RESPONSE_COL=u&if not "%3"=="" set TEXT_RESPONSE_COL=%3
set TEXT_ROOMNAME_COL=u&if not "%4"=="" set TEXT_ROOMNAME_COL=%4
set TEXT_ROOMDESC_COL=u&if not "%5"=="" set TEXT_ROOMDESC_COL=%5
goto :eof

:SETINIT
if not "%6" == "" set MAXSCORE=%6 
if "%MAXSCORE%" geq "1" call :PRINTCOL "%MSG9%%SCORE%/%MAXSCORE%" %TEXT_DESC_COL%
set INV=%7
if not "%8" == "" call :REMOVEOBJECT %PP% %8 %PP%
goto :eof

:LOCASE
for %%i in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") do call set "%1=%%%1:%%~i%%"
goto :eof

:UPCASE
for %%i in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") do call set "%1=%%%1:%%~i%%"
goto :eof

:SAVESTATE
if "%~1"=="" set NUMM=0
if not "%~1"=="" set /A NUMM=%1
if %NUMM% gtr 0 if %NUMM% lss 10 goto OKNUM
call :PRINTCOL "Error: Invalid slot, use 1-9" %TEXT_RESPONSE_COL%&call :LISTSLOTS
goto :eof
:OKNUM
SET SNAME="%FPATH:~1,-1%adv-save%NUMM%.dat"
echo %WORLD%>%SNAME%
echo %WORLDWIDTH% >>%SNAME%
echo .%INV%>>%SNAME%
echo %PP% >>%SNAME%
echo %SCORE% >>%SNAME%
call :SAVECOUNTERS
call :PRINTCOL "Saved game to slot number %NUMM%" %TEXT_RESPONSE_COL%
goto :eof

:SAVECOUNTERS
set OUT=.
for /L %%a in (0,1,%OBJNOF%) do if not "!OBJCOUNT%%a!"=="" set OUT=%OUT% %%a !OBJCOUNT%%a!
for %%a in (a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,_) do if not "!OBJCOUNT%%a!"=="" set OUT=%OUT% %%a !OBJCOUNT%%a!
echo %OUT% >>%SNAME%
goto :eof

:LOADSTATE
set LOADOK=0
if "%~1"=="" set NUMM=0
if not "%~1"=="" set /A NUMM=%1
if %NUMM% gtr 0 if %NUMM% lss 10 goto OKNUM
call :PRINTCOL "Error: Invalid slot, use 1-9" %TEXT_RESPONSE_COL%&call :LISTSLOTS
goto :eof
:OKNUM
SET SNAME="%FPATH:~1,-1%adv-save%NUMM%.dat"
if not exist %SNAME% call :PRINTCOL "Error: No game saved in slot %NUMM%" %TEXT_RESPONSE_COL%&call :LISTSLOTS&goto :eof
call :RESETCOUNTERS
set LOADOK=1
set CNT=0&for /F "tokens=* usebackq delims=" %%i in (%SNAME%) do set /A CNT+=1&call :LOADPROCESS !CNT! "%%i"
call :PRINTCOL "Loaded game from slot number %NUMM%" %TEXT_RESPONSE_COL%
for /L %%a in (0,1,%WORLDGRIDSIZE%) do set ROOMSEEN%%a=

if "%MAXSCORE%" geq "1" call :PRINTCOL "%MSG9%%SCORE%/%MAXSCORE%" %TEXT_DESC_COL%
goto :eof

:LOADPROCESS
if %1==1 set WORLD=%~2
if %1==2 set /A WORLDWIDTH=%~2
if %1==3 set INV=%~2&set INV=!INV:~1!
if %1==4 set /A PP=%~2
if %1==5 set /A SCORE=%~2
if %1==6 call :LOADCOUNTERS %~2
goto :eof

:LOADCOUNTERS
shift
:LOADCREP
if "%1"=="" goto :eof
set LKEY=%1
shift
if "%1"=="" goto :eof
set LVAL=%1
set OBJCOUNT%LKEY%=%LVAL%
shift
goto LOADCREP

:LISTSLOTS
set MTMP="Used slots:"
for /L %%a in (1,1,9) do if exist "%FPATH:~1,-1%adv-save%%a.dat" set MTMP="!MTMP:~1,-1! %%a"
call :PRINTCOL %MTMP% %TEXT_RESPONSE_COL%
goto :eof


:strLen -- returns the length of a string via binary search, maximum length 1023
::      -- %~1: in - varible name of a string variable (string MUST start and end with ". These are not counted)
::      -- %~2: out- string length

SETLOCAL
set str=A!%~1!&  rem keep the A up front to ensures we get the length and not the upper bond
                 rem it also avoids trouble in case of empty string
set len=0
set /a n=1024
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
set /a n^>^>=1, len+=n
if !str:~%len%!. == . set /a len-=n
( ENDLOCAL & REM RETURN VALUES
    IF "%~2" NEQ "" SET /a %~2=%len%-2
)
