@echo off
if not defined _ (
	set _=.
	cmdgfx_input.exe knW10 | call %0 %* | cmdwiz.exe server
	set _=
	goto :eof
)

setlocal EnableDelayedExpansion
for /l %%1 in (1,3,1000) do (
	set /p INPUT=
	for /f "tokens=6" %%A in ("!INPUT!") do ( set /a KEY=%%A 2>nul )
	
	echo "cmdwiz: setwindowpos %%1 300"
)

echo "cmdwiz: server quit"
title input:q
endlocal
