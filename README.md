# gotoxy
Windows command line input/output tools, for text based games/utils by Mikael Sollenborn (2015-2020)

Sorry about the current lack of documentation; have a look at the example files and all will be (kind of) clear...

Notable examples: Editor, Freecell, Solitaire, Flappy, Snake, Yahtzee, World, Bigscroll3, Blocks6, Adventure(Kings of Steam)


gotoxy.exe
----------
```
GotoXY v1.2 : Mikael Sollenborn 2015-2020

Usage: gotoxy x(1) y(1) [text|file.gxy] [fgcol(2)] [bgcol(2)] [flags(3)] [wrapxpos]

Cols: 0=Black 1=Blue 2=Green 3=Aqua 4=Red 5=Purple 6=Yellow 7=LGray
      8=Gray 9=LBlue 10=LGreen 11=LAqua 12=LRed 13=LPurple 14=LYellow 15=White

[text] supports control codes:
    \px;y;: cursor position x y (1)
       \xx: fgcol and bgcol in hex, eg \A0 (4)
        \r: restore old color
      \gxx: ascii character in hex
   \TxxXXm: set character xx with col XX as transparent with mode m (5)
        \n: newline
      \Nxx: fill screen with hex character xx
        \-: skip character (transparent)
        \\: print \
        \G: print existing character at position
  \I:file;: insert contents of file
      \wx;: delay x ms
      \Wx;: delay up to x ms
        \K: wait for key press; last key value is returned
        \R: read/refresh buffer for v/V/Z/z/Y/X/\G (faster but not updated)
\ox;y;w;h;: copy/write to offscreen buffer, copy back at end or next \o
\Ox;y;w;h;: clear/write to offscreen buffer, copy back at end or next \O
   \\Mx{T}: repeat T x times (only if 'x' flag set). Use \} to produce } for next run
\Sx;y;w;h;: set active scroll zone (only if 's' flag set)
 
(1)   Use 'k' to keep current. Precede with '+' or '/' to move from current position
(2)   Use 'u/U' for console fgcol/bgcol, 'v/V' to use existing fgcol/bgcol at current
      position. 'x/y/z/q' and 'X/Y/Z/Q' to xor/and/or/add with fgcol/bgcol at current
      position. Precede with '-' to force color and ignore color codes in [text]
(3)   One or more of: 'r/c/C' to restore/follow/visibly-follow cursor position,
      'w/W/z' to wrap/wordwrap/wrap-0 text, 'i' to ignore all control codes,
      's' to enable vertical scrolling, 'x' to enable support for expressions,
      'n' to ignore newline characters, 'k' to check for key press(es) and return last
      key value, 'S' to enable (and disable) server mode
(4)   Same as (2) for both values, but '-' to force is not supported. In addition, use
      'k' to keep current color, 'H/h' to start/stop forcing current color, '+' for
      next color, '/' for previous color
(5)   Use 'k' to ignore color, 'u/U' for console fgcol/bgcol. Mode 0 skips characters,
      (same as \-), mode 1 writes them back (faster if using \R)
```

gotoxy_extended.exe
-------------------
```
Separate executable due to lower speed. There are currently two extensions:

1. Control code \L[:xx..;]: check for key xx, yy etc, don't wait; return keystate(s)

2. Correctly prints extended ascii characters as input when written as-is

```

cmdwiz.exe
----------
```
CmdWiz (Unicode) v1.8 : Mikael Sollenborn 2015-2020
With contributions from Steffen Ilhardt and Carlos Montiers Aguilera

Usage: cmdwiz operation [arguments]


Console window: fullscreen getconsoledim getfullscreen getpalette setbuffersize setpalette

Window and display: getdisplaydim getdisplayscale getwindowbounds getwindowstyle setwindowpos 
setwindowsize setwindowstyle setwindowtransparency showwindow windowlist

Input: flushkeys getch getch_and_mouse getch_or_mouse getkeystate getmouse getquickedit setquickedit

Fonts and buffer: getcharat getcolorat getconsolecolor setfont savefont

Cursor and printing: getcursorpos print setcursorpos showcursor

String and delay: await delay gettime stringfind stringlen

Mouse and keyboard: getmousecursorpos sendkey setmousecursorpos showmousecursor

Block: copyblock inspectblock moveblock saveblock

Misc: cache getexetype gettaskbarinfo gettitle gxyinfo insertbmp playsound server


Use "cmdwiz operation /?" for info on an operation's arguments and return values, for example cmdwiz delay /?

See https://www.dostips.com/forum/viewtopic.php?t=7402 for full documentation.```

```
