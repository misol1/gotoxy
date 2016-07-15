::Use tcc 32 bit version, currently not compatible with 64 bit
gcc -o cmdwiz.exe cmdwiz.c -O2 -luser32 -lwinmm 
::tcc -o cmdwiz.exe cmdwiz.c -luser32 -lwinmm 
@echo.
tcc -o gotoxy.exe gotoxy.c
@echo.
tcc -DSUPPORT_EXTENDED -lshell32 -lwinmm -luser32 -o gotoxy_extended.exe gotoxy.c
