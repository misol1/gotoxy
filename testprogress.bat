@echo off

for /L %%a in (1,1,100) do cmdwiz delay 80 & call util.bat setprogress %%a
goto :eof

echo Test1...
cmdwiz delay 1000
call util.bat setprogress 20

echo Test2...
cmdwiz delay 1500
call util.bat setprogress 60

echo Test3...
cmdwiz delay 1500
call util.bat setprogress 110
