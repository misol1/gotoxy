::Echo with color. Works best with single lines.
@echo off
set TEXT=""&if not "%~1" == "" set TEXT=%1
set FG=u&if not "%~2" == "" set FG=%2
set BG=U&if not "%~3" == "" set BG=%3
gotoxy k k %TEXT% %FG% %BG% c w&echo.
set TEXT=&set FG=&set BG=
