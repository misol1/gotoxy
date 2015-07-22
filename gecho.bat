::Echo with color. Works best with single lines.
@echo off
set TEXT=""&if not "%~1" == "" set TEXT=%1
set CC=+&if not "%~4" == "" set CC=
set FG=%CC%u&if not "%~2" == "" set FG=%CC%%2
set BG=U&if not "%~3" == "" set BG=%3
gotoxy k k %TEXT% %FG% %BG% c w&echo.
set TEXT=&set FG=&set BG=&set CC=
