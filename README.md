# gotoxy
Windows command line input/output tools, for text based games/utils by Mikael Sollenborn (2015)

Sorry about the current lack of documentation; have a look at the example files and all will be (kind of) clear...

Notable examples: Listb(file manager), Editor, Snake, Flappy, Freecell, Solitaire, Yahtzee


gotoxy.exe
----------
```
Usage: gotoxy x|keep y|keep [text|file.gxy] [fgcol(**)] [bgcol(**)] [flags(***)] [wrapxpos]

Cols: 0=Black 1=Blue 2=Green 3=Aqua 4=Red 5=Purple 6=Yellow 7=LGray(default)
      8=Gray 9=LBlue 10=LGreen 11=LAqua 12=LRed 13=LPurple 14=LYellow 15=White

[text] supports control codes:
     \px;y: cursor position x y ('k' keeps current)
       \xx: fgcol and bgcol in hex, eg \A0 (*)
        \r: restore old color
      \gxx: ascii character in hex
    \txxXX: set character xx with col XX as transparent (*)
        \n: newline
        \N: clear screen
        \-: skip character (transparent)
        \\: print \
       \wx: delay x ms
       \Wx: delay up to x ms
 \ox;y;w;h: copy/write to offscreen buffer, copy back at end or at \o
 \Ox;y;w;h: clear/write to offscreen buffer, copy back at end or at \O

(*)   Use 'k' to keep current color, 'u/U' for console fgcol/bgcol, 'v/V' to use
      existing fgcol/bgcol at position where text is put
(**)  Same as (*), but precede with '-' to force color and ignore color control codes.
(***) One or more of: 'c/r' to follow/restore cursor position, 'w/W' to wrap/spritewrap
      text, 'i' to ignore control codes, 's' to scroll up when writing below buffer
```

cmdwiz.exe
----------
```
Usage: cmdwiz [getconsoledim setbuffersize getch getkeystate quickedit getmouse
               getch_or_mouse getch_and_mouse getcharat getcolorat showcursor
               getcursorpos saveblock copyblock moveblock playsound delay gettime
               await] [params]
```
