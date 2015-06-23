:: Cardstack : Mikael Sollenborn 2015
@echo off
if "%1" == "" echo Error: no operation & goto :eof
if "%1" == "new" call :NEW noshuffle %2& goto CLEAR
if "%1" == "shuffle" call :NEW shuffle %2& goto CLEAR
if "%1" == "deal" call :DEAL & goto CLEAR
if "%1" == "reshuffle" call :RESHUFFLE & goto CLEAR
if "%1" == "pushbottom" call :PUSHBOTTOM %2 %3& goto CLEAR
if "%1" == "clean" call :CLEAN & goto :eof 
echo Error: unknown operation
goto :eof

:NEW
set DECKHEAD=1
set DECKTOE=1
set STACKS=1
if not "%2" == "" set STACKS=%2
for /L %%c in (1,1,%STACKS%) do for /L %%a in (1,1,4) do for /L %%b in (1,1,13) do set CV!DECKTOE!=%%b& set CS!DECKTOE!=%%a& set /a DECKTOE+=1
set /a DECKTOE-=1
if "%1" == "shuffle" for /L %%c in (1,1,%STACKS%) do set CNTSHUF=200&call :SHUFFLE1
::set /a NOFCARDS=%DECKTOE%-(%DECKHEAD%-1)-1 & for /L %%a in (0,1,!NOFCARDS!) do call :SHUFFLE2 %%a
goto :eof
:SHUFFLE1
set /a PICK1=%RANDOM% %% (%DECKTOE%-(%DECKHEAD%-1)) + %DECKHEAD%
set /a PICK2=%RANDOM% %% (%DECKTOE%-(%DECKHEAD%-1)) + %DECKHEAD%
set CVTEMP=!CV%PICK1%!
set CSTEMP=!CS%PICK1%!
set CV%PICK1%=!CV%PICK2%!
set CS%PICK1%=!CS%PICK2%!
set CV%PICK2%=%CVTEMP%
set CS%PICK2%=%CSTEMP%
set /a CNTSHUF-=1
if %CNTSHUF% geq 0 goto SHUFFLE1
goto :eof
:SHUFFLE2
set /a PICK1=%1 + %DECKHEAD%
set /a PICK2=%RANDOM% %% (%DECKTOE%-(%DECKHEAD%-1)) + %DECKHEAD%
set CVTEMP=!CV%PICK1%!
set CSTEMP=!CS%PICK1%!
set CV%PICK1%=!CV%PICK2%!
set CS%PICK1%=!CS%PICK2%!
set CV%PICK2%=%CVTEMP%
set CS%PICK2%=%CSTEMP%
goto :eof


:RESHUFFLE
set CNTSHUF=200&call :SHUFFLE1
::set /a NOFCARDS=%DECKTOE%-(%DECKHEAD%-1)-1 & for /L %%a in (0,1,!NOFCARDS!) do call :SHUFFLE2 %%a
goto :eof


:DEAL
if %DECKHEAD% gtr %DECKTOE% set CARDVALUE=-1& set CARDSUIT=-1& goto :eof
set CARDVALUE=!CV%DECKHEAD%!
set CARDSUIT=!CS%DECKHEAD%!

set /a DECKHEAD+=1
goto :eof


:PUSHBOTTOM
if "%2" == "" echo Error: no values & goto :eof
set /a DECKTOE+=1
set CV%DECKTOE%=%1
set CS%DECKTOE%=%2
goto :eof


:CLEAN
for /L %%a in (1,1,%DECKTOE%) do set CV%%a=& set CS%%a=
set DECKHEAD=&set DECKTOE=
set CARDVALUE=&set CARDSUIT=

:CLEAR
set STACKS=&set CVTEMP=&set CSTEMP=
