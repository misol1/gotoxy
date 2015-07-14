@echo off
set UTILOP="%~1"
call :LoCase UTILOP
if %UTILOP% == "" echo Error: No operation& goto :EOF
if %UTILOP% == "strlen" call :strlen %2 %3& goto OPFIN
if %UTILOP% == "setprogress" call :setprogress %2& goto OPFIN
if %UTILOP% == "dectohex" call :dectohex_simple %2 %3 %4& goto OPFIN
if %UTILOP% == "locase" call :LoCase %2& goto OPFIN
if %UTILOP% == "upcase" call :UpCase %2& goto OPFIN
if %UTILOP% == "tcase" call :TCase %2& goto OPFIN
echo Error: Unknown operation
:OPFIN
set UTILOP=
goto :eof


:strlen <resultVar> <stringVar>
(
  echo "%~2">tmpLen.dat
  for %%? in (tmpLen.dat) do set /A %1=%%~z? - 4
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


:LoCase
for %%i in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") do call set "%1=%%%1:%%~i%%"
goto :eof

:UpCase
for %%i in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") do call set "%1=%%%1:%%~i%%"
goto :eof

:TCase
for %%i in (" a= A" " b= B" " c= C" " d= D" " e= E" " f= F" " g= G" " h= H" " i= I" " j= J" " k= K" " l= L" " m= M" " n= N" " o= O" " p= P" " q= Q" " r= R" " s= S" " t= T" " u= U" " v= V" " w= W" " x= X" " y= Y" " z= Z") do call set "%1=%%%1:%%~i%%"
goto :eof
