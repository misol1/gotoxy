::Please use tcc 32 bit version, currently not compatible with 64 bit
tcc -lwinmm -luser32 -o cmdwiz.exe cmdwiz.c
@echo.
tcc -o gotoxy.exe gotoxy.c
@echo.
tcc -DSUPPORT_EXTENDED_ASCII_ON_CMD_LINE=1 -lshell32 -o gotoxy_extended.exe gotoxy.c
