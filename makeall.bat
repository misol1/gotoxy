::Please use tcc 32 bit version, currently not compatible with 64 bit
tcc -lwinmm -luser32 -o cmdwiz.exe cmdwiz.c
@echo.
tcc -o gotoxy.exe gotoxy.c
@echo.
tcc -DSUPPORT_EXTENDED -lshell32 -lwinmm -luser32 -o gotoxy_extended.exe gotoxy.c
