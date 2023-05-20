@windres rc\cmdwiz.rc rc\cmdwiz.o
@windres rc\cmdwiz-ascii.rc rc\cmdwiz-ascii.o
@windres rc\gotoxy-extended.rc rc\gotoxy-extended.o
@windres rc\gotoxy.rc rc\gotoxy.o
@set WARN=-Wall -Wextra -Werror -Wpedantic -Wformat=2 -Wno-unused-parameter -Wshadow -Wwrite-strings -Wstrict-prototypes -Wold-style-definition -Wredundant-decls -Wnested-externs -Wmissing-include-dirs
gcc %WARN% -o cmdwiz.exe cmdwizU.c -O2 rc\cmdwiz.o -luser32 -lwinmm -lgdi32
@if exist cmdwiz.exe strip cmdwiz.exe
@echo.
gcc -o cmdwiz-ascii.exe cmdwiz.c -O2 rc\cmdwiz-ascii.o -luser32 -lwinmm -lgdi32
@echo.
gcc %WARN% -o gotoxy.exe -O2 rc\gotoxy.o gotoxy.c
@echo.
gcc %WARN% -DSUPPORT_EXTENDED -O2 rc\gotoxy-extended.o -lshell32 -lwinmm -luser32 -o gotoxy_extended.exe gotoxy.c
@set WARN=
@echo.
@if exist cmdwiz.exe strip -s cmdwiz.exe
@if exist cmdwiz-ascii.exe strip -s cmdwiz-ascii.exe
@if exist gotoxy.exe strip -s gotoxy.exe
@if exist gotoxy_extended.exe strip -s gotoxy_extended.exe
