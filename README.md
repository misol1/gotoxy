# gotoxy
Windows command line input/output tools, for text based games/utils by Mikael Sollenborn (2015).

Sorry about the current lack of documentation; have a look at the example files and all will be clear :)

Notable examples: Listb(file manager), Editor, Snake, Flappy, Freecell, Solitaire, Yahtzee


gotoxy.exe
----------
```
Usage: gotoxy x|keep y|keep [text|file.gxy] [fgcol] [bgcol]
              [resetCursor|cursorFollow|default] [wrap|spritewrap] [wrapxpos]

Cols: 0=Black 1=Blue 2=Green 3=Aqua 4=Red 5=Purple 6=Yellow 7=LGray(default)
      8=Gray 9=LBlue 10=LGreen 11=LAqua 12=LRed 13=LPurple 14=LYellow 15=White

[text] supports control codes:
     \px;y: cursor position x y
       \xx: fgcol and bgcol in hex, eg \A0
 \ox;y;w;h: write to offscreen buffer, copy back at end of command or \o
        \r: restore old color
      \gxx: ascii character in hex
        \n: newline
        \N: clear screen
        \-: skip character (transparent)
        \\: print \
       \wx: delay x ms
       \Wx: delay up to x ms
```

cmdwiz.exe
----------
```
Usage: cmdwiz [getconsoledim setbuffersize getch getkeystate quickedit getmouse
               getch_or_mouse getch_and_mouse getcharat getcolorat showcursor
               getcursorpos saveblock copyblock moveblock playsound delay gettime
               await] [params]
```
