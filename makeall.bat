@windres rc\cmdwiz.rc rc\cmdwiz.o
@windres rc\cmdwiz-ascii.rc rc\cmdwiz-ascii.o
@windres rc\gotoxy-extended.rc rc\gotoxy-extended.o
@windres rc\gotoxy.rc rc\gotoxy.o
@set WARN=-Wall -Wextra -Werror -Wpedantic -Wformat=2 -Wno-unused-parameter -Wshadow -Wwrite-strings -Wredundant-decls -Wnested-externs -Wstrict-prototypes -Wold-style-definition -Wmissing-include-dirs
gcc %WARN% -Wl,-e,__main -nostartfiles -s -o cmdwiz.exe cmdwizU.c -Os rc\cmdwiz.o -luser32 -lwinmm -lgdi32
@if exist cmdwiz.exe strip cmdwiz.exe
@echo.
gcc -s -o cmdwiz-ascii.exe cmdwiz.c -O2 rc\cmdwiz-ascii.o -luser32 -lwinmm -lgdi32
@echo.
gcc %WARN% -s -Wl,-e,__main -nostartfiles -o gotoxy.exe -O2 rc\gotoxy.o gotoxy.c
@echo.
gcc %WARN% -s -DSUPPORT_EXTENDED -Wl,-e,__main -nostartfiles -O2 rc\gotoxy-extended.o -lshell32 -lwinmm -luser32 -o gotoxy_extended.exe gotoxy.c
@set WARN=
@echo.
@rem gcc -s -o gotoxyU.exe -O2 gotoxyU.c
