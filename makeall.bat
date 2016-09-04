gcc -o cmdwiz.exe cmdwiz.c -O2 -luser32 -lwinmm -lgdi32
@echo.
gcc -o gotoxy.exe -O2 gotoxy.c
@echo.
gcc -DSUPPORT_EXTENDED -O2 -lshell32 -lwinmm -luser32 -o gotoxy_extended.exe gotoxy.c
