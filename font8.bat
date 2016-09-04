@echo off
set CHARSET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 .'*/()[]#@?,-_:;+=&$"
set NOFCHARS=82
set /a CHARW=12 
set /a CHARH=15 
set CS0="     ##     \n    ####    \n    ####    \n    ####    \n   ##  ##   \n   ##  ##   \n   ##  ##   \n  ##    ##  \n  ########  \n  ########  \n ##      ## \n ##      ## \n ##      ## \n            \n            \n"
set CS1=" ########   \n ##    ###  \n ##     ##  \n ##     ##  \n ##    ###  \n ########   \n #########  \n ##     ### \n ##      ## \n ##      ## \n ##     ### \n #########  \n ########   \n            \n            \n"
set CS2="   #######  \n  ###   ### \n  ##     ## \n ##         \n ##         \n ##         \n ##         \n ##         \n ##         \n  ##     ## \n  ###   ### \n   #######  \n    #####   \n            \n            \n"
set CS3=" ########   \n ##    ###  \n ##     ##  \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##     ##  \n ##    ###  \n ########   \n #######    \n            \n            \n"
set CS4=" ########## \n ##         \n ##         \n ##         \n ##         \n ########   \n ########   \n ##         \n ##         \n ##         \n ##         \n ########## \n ########## \n            \n            \n"
set CS5=" ########## \n ##         \n ##         \n ##         \n ##         \n ########   \n ########   \n ##         \n ##         \n ##         \n ##         \n ##         \n ##         \n            \n            \n"
set CS6="   ######## \n  ###    ## \n  ##        \n ##         \n ##         \n ##   ##### \n ##   ##### \n ##      ## \n ##      ## \n  ##     ## \n  ###    ## \n   ######## \n    ####### \n            \n            \n"
set CS7=" ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ########## \n ########## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n            \n            \n"
set CS8="   ######   \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n   ######   \n   ######   \n            \n            \n"
set CS9="         ## \n         ## \n         ## \n         ## \n         ## \n         ## \n         ## \n         ## \n ##      ## \n ##      ## \n ###    ##  \n  ########  \n   ######   \n            \n            \n"
set CS10=" ##     ### \n ##    ###  \n ##   ###   \n ##  ###    \n ## ###     \n #####      \n #####      \n ## ###     \n ##  ###    \n ##   ###   \n ##    ###  \n ##     ### \n ##      ## \n            \n            \n"
set CS11=" ##         \n ##         \n ##         \n ##         \n ##         \n ##         \n ##         \n ##         \n ##         \n ##         \n ##         \n ########## \n ########## \n            \n            \n"
set CS12=" ###    ### \n ###    ### \n ####  #### \n ####  #### \n ## #### ## \n ## #### ## \n ##  ##  ## \n ##  ##  ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n            \n            \n"
set CS13=" ###     ## \n ###     ## \n ####    ## \n ## ##   ## \n ## ##   ## \n ##  ##  ## \n ##  ##  ## \n ##   ## ## \n ##   ## ## \n ##    #### \n ##     ### \n ##     ### \n ##      ## \n            \n            \n"
set CS14="   ######   \n  ###  ###  \n  ##    ##  \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n  ##    ##  \n  ###  ###  \n   ######   \n    ####    \n            \n            \n"
set CS15=" #########  \n ##     ### \n ##      ## \n ##      ## \n ##      ## \n ##     ### \n #########  \n ########   \n ##         \n ##         \n ##         \n ##         \n ##         \n            \n            \n"
set CS16="   ######   \n  ###  ###  \n  ##    ##  \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##   ## ## \n  ##  ####  \n  ###  ###  \n   ######## \n    #### ## \n            \n            \n"
set CS17=" #########  \n ##     ### \n ##      ## \n ##      ## \n ##      ## \n ##     ### \n #########  \n ########   \n ##  ###    \n ##   ###   \n ##    ###  \n ##     ### \n ##      ## \n            \n            \n"
set CS18="  ########  \n ###    ### \n ##      ## \n ##         \n ###        \n  #######   \n   #######  \n        ### \n         ## \n ##      ## \n ###    ### \n  ########  \n   ######   \n            \n            \n"
set CS19="  ########  \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n            \n            \n"
set CS20=" ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n  ##    ##  \n  ########  \n   ######   \n            \n            \n"
set CS21=" ##      ## \n ##      ## \n  ##    ##  \n  ##    ##  \n  ##    ##  \n   ##  ##   \n   ##  ##   \n   ##  ##   \n    ####    \n    ####    \n    ####    \n     ##     \n     ##     \n            \n            \n"
set CS22=" ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##  ##  ## \n ##  ##  ## \n ## #### ## \n ####  #### \n ###    ### \n ###    ### \n ##      ## \n            \n            \n"
set CS23=" ##      ## \n  ##    ##  \n  ##    ##  \n   ##  ##   \n    ####    \n     ##     \n     ##     \n    ####    \n   ##  ##   \n  ##    ##  \n  ##    ##  \n ##      ## \n ##      ## \n            \n            \n"
set CS24=" ##      ## \n  ##    ##  \n  ##    ##  \n   ##  ##   \n   ##  ##   \n    ####    \n    ####    \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n            \n            \n"
set CS25=" ########## \n        ##  \n        ##  \n       ##   \n      ##    \n     ##     \n     ##     \n    ##      \n   ##       \n  ##        \n  ##        \n ########## \n ########## \n            \n            \n"
set CS26="            \n            \n            \n            \n   #######  \n  ######### \n         ## \n   ######## \n  ######### \n ##      ## \n ##      ## \n ########## \n  ######### \n            \n            \n"
set CS27=" ##         \n ##         \n ##         \n ##         \n ## #####   \n #########  \n ###    ### \n ##      ## \n ##      ## \n ##      ## \n ##     ### \n #########  \n ########   \n            \n            \n"
set CS28="            \n            \n            \n            \n   ######   \n  ########  \n ###     ## \n ##         \n ##         \n ##         \n ###     ## \n  ########  \n   ######   \n            \n            \n"
set CS29="         ## \n         ## \n         ## \n         ## \n   ##### ## \n  ######### \n ###   #### \n ##      ## \n ##      ## \n ##      ## \n ###     ## \n  ######### \n   ######## \n            \n            \n"
set CS30="            \n            \n            \n            \n   ######   \n  ########  \n ###     ## \n ########## \n #########  \n ##         \n ###        \n  ########  \n   ######   \n            \n            \n"
set CS31="    #####   \n   ###      \n   ##       \n   ##       \n   ##       \n #######    \n #######    \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n            \n            \n"
set CS32="            \n            \n            \n            \n   ######## \n  ######### \n ###     ## \n ##      ## \n ###    ### \n  ######### \n   ##### ## \n         ## \n        ### \n  ########  \n  #######   \n"
set CS33=" ##         \n ##         \n ##         \n ##         \n ## ####    \n ########   \n ###   ###  \n ##     ##  \n ##     ##  \n ##     ##  \n ##     ##  \n ##     ##  \n ##     ##  \n            \n            \n"
set CS34="            \n     ##     \n     ##     \n            \n    ###     \n    ###     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n   ######   \n   ######   \n            \n            \n"
set CS35="            \n       ##   \n       ##   \n            \n      ###   \n      ###   \n       ##   \n       ##   \n       ##   \n       ##   \n       ##   \n       ##   \n   ##  ##   \n   ######   \n    ####    \n"
set CS36="  ##        \n  ##        \n  ##        \n  ##        \n  ##   ##   \n  ##  ###   \n  ## ###    \n  #####     \n  #####     \n  ## ###    \n  ##  ###   \n  ##   ###  \n  ##    ##  \n            \n            \n"
set CS37="    ###     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n     ##     \n   ######   \n   ######   \n            \n            \n"
set CS38="            \n            \n            \n            \n # ##  ##   \n #########  \n ########## \n ##  ##  ## \n ##  ##  ## \n ##  ##  ## \n ##  ##  ## \n ##  ##  ## \n ##  ##  ## \n            \n            \n"
set CS39="            \n            \n            \n            \n  #######   \n  ########  \n  ##    ### \n  ##     ## \n  ##     ## \n  ##     ## \n  ##     ## \n  ##     ## \n  ##     ## \n            \n            \n"
set CS40="            \n            \n            \n            \n   ######   \n  ########  \n ###    ### \n ##      ## \n ##      ## \n ##      ## \n ###    ### \n  ########  \n   ######   \n            \n            \n"
set CS41="            \n            \n            \n            \n ########   \n #########  \n ##     ### \n ##      ## \n ##      ## \n ###    ### \n #########  \n ## #####   \n ##         \n ##         \n ##         \n"
set CS42="            \n            \n            \n            \n   ######## \n  ######### \n ###     ## \n ##      ## \n ##      ## \n ###    ### \n  ######### \n   ##### ## \n         ## \n         ## \n         ## \n"
set CS43="            \n            \n            \n            \n  ## #####  \n  ######### \n  ###    ## \n  ##        \n  ##        \n  ##        \n  ##        \n  ##        \n  ##        \n            \n            \n"
set CS44="            \n            \n            \n            \n  ######    \n ########   \n ##         \n #######    \n  #######   \n       ##   \n       ##   \n ########   \n  ######    \n            \n            \n"
set CS45="   ##       \n   ##       \n   ##       \n   ##       \n #######    \n #######    \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n   ######   \n    #####   \n            \n            \n"
set CS46="            \n            \n            \n            \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ##      ## \n ###    ### \n  ######### \n   ##### ## \n            \n            \n"
set CS47="            \n            \n            \n            \n ##      ## \n ##      ## \n  ##    ##  \n  ##    ##  \n   ##  ##   \n   ##  ##   \n    ####    \n    ####    \n     ##     \n            \n            \n"
set CS48="            \n            \n            \n            \n ##  ##  ## \n ##  ##  ## \n ##  ##  ## \n ##  ##  ## \n ##  ##  ## \n ## #### ## \n  ########  \n  ###  ###  \n   #    #   \n            \n            \n"
set CS49="            \n            \n            \n            \n ##     ##  \n ###   ###  \n  ### ###   \n   #####    \n    ###     \n   #####    \n  ### ###   \n ###   ###  \n ##     ##  \n            \n            \n"
set CS50="            \n            \n            \n            \n  ##    ##  \n  ##    ##  \n   ##  ##   \n   ##  ##   \n    ####    \n    ####    \n     ##     \n     ##     \n    ##      \n    ##      \n   ##       \n"
set CS51="            \n            \n            \n            \n #########  \n ########   \n      ##    \n     ##     \n    ##      \n   ##       \n  ##        \n #########  \n #########  \n            \n            \n"
set CS52="     ###    \n   #####    \n   #####    \n      ##    \n      ##    \n      ##    \n      ##    \n      ##    \n      ##    \n      ##    \n      ##    \n   ######## \n   ######## \n            \n            \n"
set CS53="  ######### \n ###     ###\n ##       ##\n ##      ###\n        ### \n       ###  \n      ###   \n     ###    \n    ###     \n   ###      \n  ###       \n ###########\n ###########\n            \n            \n"
set CS54="  ######### \n ###     ###\n ##       ##\n          ##\n         ###\n    ####### \n    ######  \n         ## \n          ##\n ##       ##\n ###     ###\n  ######### \n   #######  \n            \n            \n"
set CS55="      ####  \n     #####  \n    ### ##  \n   ###  ##  \n  ###   ##  \n ###    ##  \n ##     ##  \n ###########\n ###########\n        ##  \n        ##  \n        ##  \n        ##  \n            \n            \n"
set CS56=" ###########\n ##         \n ##         \n ##         \n #########  \n  ######### \n         ###\n          ##\n          ##\n ##       ##\n ###     ###\n  ######### \n   #######  \n            \n            \n"
set CS57="     #####  \n    ###     \n   ###      \n  ###       \n  ##        \n #########  \n ########## \n ###     ###\n ##       ##\n ##       ##\n ###     ###\n  ######### \n   #######  \n            \n            \n"
set CS58=" ###########\n         ## \n         ## \n        ##  \n        ##  \n       ##   \n       ##   \n      ##    \n      ##    \n     ##     \n     ##     \n    ##      \n    ##      \n            \n            \n"
set CS59="   #######  \n  ###   ### \n  ##     ## \n  ##     ## \n  ###   ### \n   #######  \n  ######### \n ###     ###\n ##       ##\n ##       ##\n ###     ###\n  ######### \n   #######  \n            \n            \n"
set CS60="  ######### \n ###     ###\n ##       ##\n ##       ##\n ###     ###\n  ##########\n   #########\n         ## \n        ### \n       ###  \n      ###   \n   #####    \n   ####     \n            \n            \n"
set CS61="  ######### \n  ##     ## \n ##      ###\n ##     ####\n ##    ## ##\n ##   ##  ##\n ##  ##   ##\n ## ##    ##\n ####     ##\n ###      ##\n  ##     ## \n  ######### \n    #####   \n            \n            \n"
set CS62="            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n"
set CS63="            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n    ###     \n    ###     \n    ###     \n            \n            \n"
set CS64="    ###     \n    ###     \n     ##     \n     ##     \n    ##      \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n"
set CS65="            \n            \n  ## ## ##  \n  ## ## ##  \n   ######   \n    ####    \n  ########  \n    ####    \n   ######   \n  ## ## ##  \n  ## ## ##  \n            \n            \n            \n            \n"
set CS66="           #\n          ##\n         ###\n        ### \n       ###  \n      ###   \n     ###    \n    ###     \n   ###      \n  ###       \n ###        \n ##         \n            \n            \n            \n"
set CS67="     ##     \n    ###     \n    ##      \n   ###      \n   ###      \n   ###      \n   ###      \n   ###      \n   ###      \n    ##      \n    ###     \n     ##     \n      ###   \n            \n            \n"
set CS68="     ##     \n     ###    \n      ##    \n      ###   \n      ###   \n      ###   \n      ###   \n      ###   \n      ###   \n      ##    \n     ###    \n     ##     \n   ###      \n            \n            \n"
set CS69="   ######   \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n   ##       \n   ######   \n   ######   \n            \n            \n"
set CS70="   ######   \n       ##   \n       ##   \n       ##   \n       ##   \n       ##   \n       ##   \n       ##   \n       ##   \n       ##   \n       ##   \n   ######   \n   ######   \n            \n            \n"
set CS71="     ##  ## \n     ##  ## \n     ##  ## \n  ##########\n    ##  ##  \n    ##  ##  \n   ##  ##   \n   ##  ##   \n #########  \n  ##  ##    \n  ##  ##    \n  ##  ##    \n            \n            \n            \n"
set CS72="  ######### \n  ##     ## \n ##  #### ##\n ## ##### ##\n ## ## ## ##\n ## ## ## ##\n ## ## ## ##\n ## ## ## ##\n ## ####### \n ##  #####  \n ###        \n  ########  \n    ######  \n            \n            \n"
set CS73="  ########  \n ###    ### \n ##      ## \n ##     ### \n       ###  \n      ###   \n     ###    \n     ##     \n     ##     \n     ##     \n            \n     ##     \n     ##     \n            \n            \n"
set CS74="            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n    ###     \n    ###     \n    ###     \n     ##     \n    ##      \n"
set CS75="            \n            \n            \n            \n            \n            \n  ########  \n  ########  \n            \n            \n            \n            \n            \n            \n            \n"
set CS76="            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n ###########\n ###########\n"
set CS77="            \n            \n            \n    ###     \n    ###     \n    ###     \n            \n            \n            \n    ###     \n    ###     \n    ###     \n            \n            \n            \n"
set CS78="            \n            \n            \n    ###     \n    ###     \n    ###     \n            \n            \n            \n    ###     \n    ###     \n    ###     \n     ##     \n     ##     \n    ##      \n"
set CS79="            \n            \n            \n     ##     \n     ##     \n     ##     \n  ########  \n  ########  \n     ##     \n     ##     \n     ##     \n            \n            \n            \n            \n"
set CS80="            \n            \n            \n            \n  ######### \n  ######### \n            \n            \n  ######### \n  ######### \n            \n            \n            \n            \n            \n"
set CS81="     ###    \n    ## ##   \n   ##  ##   \n   ##  ##   \n   ## ##    \n    ###     \n   ####     \n  #####     \n  ##  ## ## \n  ##  ####  \n  ##   ##   \n  ### ####  \n   ####  ## \n            \n            \n"
set CS82="     ##     \n   ######   \n  ########  \n  ## ##     \n  ## ##     \n  #######   \n   #######  \n     ## ##  \n     ## ##  \n  ########  \n   ######   \n     ##     \n     ##     \n            \n            \n"
