::Echo with color
@echo off
set TEXT=""&if not "%~1" == "" set TEXT=%1
set CC=i&if not "%~4" == "" set CC=
set FG=u&if not "%~2" == "" set FG=%2
set BG=U&if not "%~3" == "" set BG=%3
gotoxy k k %TEXT% %FG% %BG% csw%CC%
set TEXT=&set FG=&set BG=&set CC=
