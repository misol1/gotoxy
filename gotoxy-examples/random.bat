@setlocal ENABLEDELAYEDEXPANSION
@cmdwiz showcursor 0
@if "%1" == "" mode con lines=50&cls
::@for /L %%a in (1,1,300) do @set /a X=!RANDOM! %% 83-4 &@set /a Y=!RANDOM! %% 53-4 &@call playcard.bat !X! !Y! 0
@for /L %%a in (1,1,300) do @set /a X=!RANDOM! %% 83-4 &@set /a Y=!RANDOM! %% 53-4 &@set /a COL1=!RANDOM! %% 15+1 &@set /a COL2=!RANDOM! %% 15+1 &@call rolldice.bat !X! !Y! !COL1! !COL2!
@cmdwiz showcursor 1
@endlocal
