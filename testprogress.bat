@echo off

for /L %%a in (1,1,100) do cmdwiz delay 80 & call util.bat setprogress %%a
goto :eof

echo Hahahah....
cmdwiz delay 1000
call util.bat setprogress 20

echo Apnasson..
cmdwiz delay 1500
call util.bat setprogress 60

echo Beppe Wolgers!
cmdwiz delay 1500
call util.bat setprogress 110
