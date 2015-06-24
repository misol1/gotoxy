/* GotoXY (c) 2015 Mikael Sollenborn */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <ctype.h>

// Compilation with tcc: tcc -lshell32 -o gotoxy.exe gotoxy.c

//#define SUPPORT_EXTENDED_ASCII_ON_CMD_LINE 1

void ClrScr(HANDLE h, int attrib) {
  COORD a = {0,0};
  DWORD nwrite;
  FillConsoleOutputAttribute(h, attrib, 20000, a, &nwrite);
  FillConsoleOutputCharacter(h, 0x20, 20000, a, &nwrite);
}

void GotoXY(int x, int y) {
  COORD coord;
  coord.X = x;
  coord.Y = y;
  SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), coord);
}

int GetDim(int bY) {
  CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
  return bY? screenBufferInfo.dwSize.Y : screenBufferInfo.dwSize.X;
}

void GetXY(int *x, int *y) {
  CONSOLE_SCREEN_BUFFER_INFO  csbInfo;
  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbInfo);
  *x = csbInfo.dwCursorPosition.X;
  *y = csbInfo.dwCursorPosition.Y;
}

int GetCol(char c, int oldc) {
	int pc = c -'0';
	if (pc > 9 || pc < 0) pc=oldc;
	switch(c) {
	case 'a':case 'A': pc=10; break;
	case 'b':case 'B': pc=11; break;
	case 'c':case 'C': pc=12; break;
	case 'd':case 'D': pc=13; break;
	case 'e':case 'E': pc=14; break;
	case 'f':case 'F': pc=15; break;
	}
	return pc;
}

#define UNKNOWN -999999
#define MAX_STR_SIZE 16000
#define WRAP 1
#define WRAPSPRITE 2

void CopyBuffer(HANDLE hSrc, HANDLE hDest, int ox, int oy, int w, int h, int nx, int ny) {
  COORD a, b;
  SMALL_RECT r;
  CHAR_INFO *str;
  CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;

  str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * 12000);
  if (!str)
    return 3;

  b.X = 0;
  b.Y = 0;

  a.X = w;
  a.Y = h;

  r.Left = ox;
  r.Top = oy;
  r.Right = ox + w;
  r.Bottom = oy + h;
  ReadConsoleOutput(hSrc, str, a, b, &r);
  
  r.Left = nx;
  r.Top = ny;
  r.Right = nx + w;
  r.Bottom = ny + h;  
  WriteConsoleOutput(hDest, str, a, b, &r);
  free(str);
}

void WriteText(unsigned char *text, int fgCol, int bgCol, int *x, int *y, int wrap, int wrapxpos) {
    int i = 0, j, inlen;
    COORD a, b;
    SMALL_RECT r;
    CHAR_INFO *str;
	int orgx = *x, yp = 0;
	int oldfc = 7,oldbc = 0;
    HANDLE hNewScreenBuffer = INVALID_HANDLE_VALUE;
	int bufdims[4] = {0,0,80,25}, bNewHandle = 0, bCopyback = 0;
	HANDLE hCurrHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	int newX=UNKNOWN, newY=UNKNOWN, waitValue = -1, awaitValue = -1;
	int transpChar = -1, transpFg = -1, transpBg = -1, fgBgCol;
	char ch;
	unsigned int startT = GetTickCount();
     
    str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * MAX_STR_SIZE);
	if (!str)
	  return;

	fgBgCol = fgCol | (bgCol<<4);
	inlen = strlen(text);

    while (i < inlen) {
		j = 0;
		for(; i < inlen; i++) {
		    ch = text[i];
			if (ch == '\\') {
				i++;
		        ch = text[i];
				if (i < inlen) {
					if (ch == '-') {
						if (wrap && *x+j+1 > wrapxpos && orgx <= wrapxpos) {
							yp = 0; i++; newY = *y+1; newX = (wrap == WRAP)? 0 : orgx; break;
						}
					    if (j == 0)
					      *x += 1;
					    else {
					      yp=0; i++; break;
					    }
					}
					else if (ch == 'g') {
					    int v = 0, v16 = 0;
						i++;
						v16 = GetCol(text[i], 0);
						i++;
						if (i < inlen) {
							v = GetCol(text[i], 0);
						}
						v16 = (v16*16) + v;
				        str[j].Char.AsciiChar = v16;
						str[j].Attributes = fgBgCol;
						j++;
					}
					else if (ch == 'p') {
					    int bY = 0, k = 0;
						char number[1024];
					    i++;
						yp = 0;
						while(i < inlen) {
							if (text[i] == '-' || (text[i]>='0' && text[i]<='9')) {
							  number[k++]=text[i];
							  if (!(i+1 < inlen)) {
							    number[k] = 0;
								if (bY == 0) newX=atoi(number); else if (bY == 1) newY=atoi(number);
							  }
							}
							else if (text[i] == ';') {
							  if (k > 0) {
							    number[k] = 0;
								if (bY == 0) newX=atoi(number); else if (bY == 1) newY=atoi(number);
								k=0;
							  }
							  bY++;
							} else {
							  if (k > 0) {
							    number[k] = 0;
								if (bY == 0) newX=atoi(number); else if (bY == 1) newY=atoi(number);
							  }
							  break;
							}
						    i++;
						}
						if (newX!=UNKNOWN && newY!=UNKNOWN)
						  break;
						else
						  i--;
					}
					else if (ch == '\\') {
						str[j].Char.AsciiChar = text[i];
						str[j].Attributes = fgBgCol;
						j++;
						if (wrap && *x+j > wrapxpos && orgx <= wrapxpos) {
							yp = 0; newY = *y+1; newX = (wrap == WRAP)? 0 : orgx; i++; break;
						}
					}
					else if (ch == 'n') {
						i++;
						yp = 1;
						break;
					}
					else if (ch == 'r') {
					  int tmp1, tmp2;
					  tmp1 = oldfc;
					  tmp2 = oldbc;
					  fgCol = oldfc;
					  bgCol = oldbc;
					  oldfc = tmp1;
					  oldbc = tmp2;
					  fgBgCol = fgCol | (bgCol<<4);
					}
					else if (ch == 'w' || ch == 'W') {
						char number[1024], oldC = text[i];
						int k = 0;
						i++;
						yp = 0;
						while(i < inlen) {
							if (text[i]>='0' && text[i]<='9') {
							  number[k++]=text[i];
							  if (!(i+1 < inlen)) {
							    number[k] = 0; if (oldC=='w') waitValue = atoi(number); else awaitValue = atoi(number);
							  }
							} else {
							  if (k > 0) {
							    number[k] = 0; if (oldC=='w') waitValue = atoi(number); else awaitValue = atoi(number);
							  }
							  break;
							}
						    i++;
						}
						break;
					}
					else if (ch == 'o' || ch == 'O') {
					    int dI = 0, k = 0;
						char number[1024], oldC = text[i];
						
					    if (i+1 >= inlen || !(text[i+1]>='0' && text[i+1]<='9') ) {
						  if (hNewScreenBuffer != INVALID_HANDLE_VALUE)
							  bCopyback = 1;
					      i++;
						  break;
					    }
						
					    i++;
						yp = 0;
						while(i < inlen) {
							if (text[i]>='0' && text[i]<='9') {
							  number[k++]=text[i];
							  if (!(i+1 < inlen)) {
							    number[k] = 0;
								bufdims[dI++] = atoi(number);
								if (dI > 3) dI = 3;
							  }
							}
							else if (text[i] == ';') {
							  if (k > 0) {
							    number[k] = 0;
								bufdims[dI++] = atoi(number);
								if (dI > 3) dI = 3;
								k=0;
							  }
							} else {
							  if (k > 0) {
							    number[k] = 0;
								bufdims[dI++] = atoi(number);
								if (dI > 3) dI = 3;
							  }
							  break;
							}
						    i++;
						}
						if (dI == 3 && hNewScreenBuffer == INVALID_HANDLE_VALUE) {
						  bNewHandle = oldC=='o'? 1 : 2;
						  break;
						}
						else
						  i--;
					}
					else if (ch == 't') {
					    int v = 0, v16 = 0;
						i++;
						v16 = GetCol(text[i], 0);
						i++;
						if (i < inlen) {
							v = GetCol(text[i], 0);
						}
						i++;
						if (i < inlen) {
							transpFg = GetCol(text[i], -1);
						}
						i++;
						if (i < inlen) {
							transpBg = GetCol(text[i], -1);
						}
						v16 = (v16*16) + v;
						transpChar = v16;
					}
					else if (ch == 'N') {
					  ClrScr(hCurrHandle, fgBgCol);
					  newX = newY = 0;
					  j = 0;
					  yp = 0;
					  i++;
					  break;
					}
					else {
						oldfc = fgCol;
						oldbc = bgCol;
						fgCol = GetCol(text[i], fgCol);
						i++;
						if (i < inlen) {
							bgCol = GetCol(text[i], bgCol);
						}
						fgBgCol = fgCol | (bgCol<<4);
					}
				}
			} else {
			    if (ch == transpChar && (transpFg == fgCol || transpFg==-1) && (transpBg == bgCol || transpBg==-1)) {
					if (wrap && *x+j+1 > wrapxpos && orgx <= wrapxpos) {
						yp = 0; i++; newY = *y+1; newX = (wrap == WRAP)? 0 : orgx; break;
					}
					if (j == 0)
					  *x += 1;
					else {
					  yp=0; i++; break;
					}
				} else {
				  str[j].Char.AsciiChar = ch;
				  str[j].Attributes = fgBgCol;
				  j++;
				
				  if (wrap && *x+j > wrapxpos && orgx <= wrapxpos) {
				    yp = 0; newY = *y+1; newX = (wrap == WRAP)? 0 : orgx; i++; break;
				  }
				}
			}
		}

		if (j > 0) {
			a.X = j;
			a.Y = 1;

			b.X = 0;
			b.Y = 0;

			r.Left = *x;
			r.Top = *y;
			r.Right = *x + j;
			r.Bottom = *y + 1;
			WriteConsoleOutput(hCurrHandle, str, a, b, &r);
		}
        if (yp == 1) {
			(*y)++;
			*x = orgx;
			yp = 0;
		} else {
			*x += j + ((waitValue >= 0 || awaitValue >= 0 || bNewHandle > 0)? 0 : 1);
		}
		
		if (newX!=UNKNOWN || newY!=UNKNOWN) {
		  if (newX!=UNKNOWN && newY!=UNKNOWN) {
			*x = newX;
			*y = newY;
			orgx = *x;
			yp = 0;
		  }
          newX = newY = UNKNOWN;
		}
		
		if (waitValue >= 0) {
			if (waitValue > 0)
			  Sleep(waitValue);
			waitValue = -1;
		}
		
		if (awaitValue >= 0) {
			if (awaitValue > 0) {
		      while (GetTickCount() < startT+awaitValue)
		        Sleep(1);
			}
			awaitValue = -1;
          	startT = GetTickCount();
		}

		if (bNewHandle > 0) {
			hNewScreenBuffer = CreateConsoleScreenBuffer( 
			GENERIC_READ | GENERIC_WRITE, 
			FILE_SHARE_READ | FILE_SHARE_WRITE,
			NULL, CONSOLE_TEXTMODE_BUFFER, NULL);
			
			if (hNewScreenBuffer != INVALID_HANDLE_VALUE) {
				hCurrHandle = hNewScreenBuffer;
				if (bNewHandle == 1) {
					CopyBuffer(GetStdHandle(STD_OUTPUT_HANDLE), hNewScreenBuffer, bufdims[0], bufdims[1], bufdims[2], bufdims[3], 0, 0);
				}
			}
			bNewHandle = 0;
		}
		
		if (bCopyback > 0) {
		  hCurrHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	      CopyBuffer(hNewScreenBuffer, hCurrHandle, 0, 0, bufdims[2], bufdims[3], bufdims[0], bufdims[1]);
          CloseHandle(hNewScreenBuffer);
		  hNewScreenBuffer = INVALID_HANDLE_VALUE;
		  bCopyback = 0;
		}
	}

    if (hNewScreenBuffer != INVALID_HANDLE_VALUE){
	  CopyBuffer(hNewScreenBuffer, GetStdHandle(STD_OUTPUT_HANDLE), 0, 0, bufdims[2], bufdims[3], bufdims[0], bufdims[1]);
      CloseHandle(hNewScreenBuffer);
    }

	free(str);
	if (*x!=orgx) (*x)--;
}

#define MAX_BUF_SIZE 64000

int main(int argc, char **argv) {
  int ox, oy;
  int x, y;
  int fgCol = 7, bgCol = 0, wrap = 0, wrapxpos = 0;
  unsigned char *u8buf = NULL;
		  
  if (argc < 3 || argc > 9) {
    printf("Usage: gotoxy x|keep y|keep [text|file.gxy] [fgcol] [bgcol] [resetCursor|cursorFollow|default] [wrap|spritewrap] [wrapxpos]\n");
    // Info from "color /?" in dos prompt (but not using hex)
    printf("\nCols: 0=Black 1=Blue 2=Green 3=Aqua 4=Red 5=Purple 6=Yellow 7=LGray(default)\n      8=Gray 9=LBlue 10=LGreen 11=LAqua 12=LRed 13=LPurple 14=LYellow 15=White\n");
    printf("\n[text] supports control codes:\n     \\px;y: cursor position x y\n       \\xx: fgcol and bgcol in hex, eg \\A0\n        \\r: restore old color\n      \\gxx: ascii character in hex\n    \\txxXX: set character xx with col XX as transparent\n        \\n: newline\n        \\N: clear screen\n        \\-: skip character (transparent)\n        \\\\: print \\\n       \\wx: delay x ms\n       \\Wx: delay up to x ms\n \\ox;y;w;h: copy/write to offscreen buffer, copy back at end or at \\o\n \\Ox;y;w;h: clear/write to offscreen buffer, copy back at end or at \\O\n");
    return 0;
  }

  if (argc > 3) {
    int al=strlen(argv[3]);

	if (al > 4 && argv[3][al-4]=='.' && tolower(argv[3][al-3])=='g' && tolower(argv[3][al-2])=='x' && tolower(argv[3][al-1])=='y') {
      FILE *ifp;
      ifp=fopen(argv[3], "r");
	  if (ifp == NULL) {
		printf("Error: gxy file not found.\n");
		return 1;
	  }
	  u8buf = (unsigned char *)malloc(MAX_BUF_SIZE);
	  if (u8buf) {
	    int fr;
        fr=fread(u8buf, 1, MAX_BUF_SIZE, ifp);
		u8buf[fr]=0;
        fclose(ifp);
	  }
    } 
#ifdef SUPPORT_EXTENDED_ASCII_ON_CMD_LINE	
	else { // ASCII characters over 127 (exteded Ascii) come as wrong values. Get/convert Unicode to IBM437 code page if such characters exist in string.
      int i, bExt = 0;

	  for (i=0; i < al; i++)
	    if (argv[3][i] < 0)
		  bExt = 1;

	  if (bExt) {
  	    LPWSTR *szArglist;
        int nArgs, wlen = 0, result = 0;

        szArglist = (LPWSTR *)CommandLineToArgvW(GetCommandLineW(), &nArgs);
        if( NULL == szArglist ) {
        } else if (nArgs < 4) {
		  LocalFree(szArglist);
        } else {

		  while(szArglist[3][wlen] != 0)
            wlen++;

		  u8buf = (unsigned char *)malloc(MAX_BUF_SIZE);
		  if (u8buf)
		    result = WideCharToMultiByte(
            437,                  // convert to IBM437 ("extended AscII")
            0,      			  // conversion behavior
            szArglist[3],         // source UTF-16 string
            wlen+1,   			  // total source string length, in WCHAR’s, including end-of-string
            u8buf,                // destination buffer
            MAX_BUF_SIZE,         // destination buffer size, in bytes
            NULL, NULL
            );
		  if (result == 0 && u8buf) {
		    free(u8buf); u8buf = NULL;
		  }

          LocalFree(szArglist);
	    }
	  }
    }
#endif	
  }

  if (argv[1][0]=='k' || argv[2][0]=='k')
    GetXY(&ox, &oy);

  x = argv[1][0] == 'k'? ox : atoi(argv[1]);
  y = argv[2][0] == 'k'? oy : atoi(argv[2]);
  
  if (!(argc > 6) || (argc > 6 && argv[6][0] == 'd'))
    GotoXY(x, y);

  if (argc > 7) {
    int wxp;
    if (argv[7][0] == 'w')
      wrap = WRAP;
    else if (argv[7][0] == 's')
      wrap = WRAPSPRITE;
	wrapxpos = GetDim(0) - 1;
    if (argc > 8) {
		wxp = atoi(argv[8]);
		if (wxp >= x)
		  wrapxpos = wxp;
	}
  }

  if (argc > 5)
    bgCol = argv[5][1]==0? GetCol(argv[5][0], 0) : atoi(argv[5]);
  if (argc > 4)
    fgCol = argv[4][1]==0? GetCol(argv[4][0], 7) : atoi(argv[4]);
  if (argc > 3)
		WriteText(u8buf? u8buf : (unsigned char *)argv[3], fgCol, bgCol, &x, &y, wrap, wrapxpos);
	
  if (argc > 6) {
    if (argv[6][0] == 'c')
      GotoXY(x, y);
  }

  if (u8buf)
    free(u8buf);
	
  return 0;
}
