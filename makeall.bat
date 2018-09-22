@windres rc\cmdwiz.rc rc\cmdwiz.o
@windres rc\cmdwiz-ascii.rc rc\cmdwiz-ascii.o
@windres rc\gotoxy-extended.rc rc\gotoxy-extended.o
@windres rc\gotoxy.rc rc\gotoxy.o
gcc -o cmdwiz.exe cmdwizU.c -O2 rc\cmdwiz.o -luser32 -lwinmm -lgdi32
@if exist cmdwiz.exe strip cmdwiz.exe
@echo.
gcc -o cmdwiz-ascii.exe cmdwiz.c -O2 rc\cmdwiz-ascii.o -luser32 -lwinmm -lgdi32
@echo.
gcc -o gotoxy.exe -O2 gotoxy.c
@echo.
gcc -DSUPPORT_EXTENDED -O2 rc\gotoxy-extended.o -lshell32 -lwinmm -luser32 -o gotoxy_extended.exe gotoxy.c
@echo.
@rem gcc -o gotoxyU.exe -O2 gotoxyU.c
@if exist cmdwiz.exe strip cmdwiz.exe
@if exist cmdwiz-ascii.exe strip cmdwiz-ascii.exe
@if exist gotoxy.exe strip gotoxy.exe
@if exist gotoxy_extended.exe strip gotoxy_extended.exe
@rem if exist gotoxyU.exe strip gotoxyU.exe
