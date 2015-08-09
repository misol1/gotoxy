/* GotoXY (c) 2015 Mikael Sollenborn */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <ctype.h>

// Compilation with tcc(32 bit version) : tcc -lshell32 -o gotoxy.exe gotoxy.c

//#define SUPPORT_EXTENDED_ASCII_ON_CMD_LINE 1

// Constants
#define UNKNOWN -999999
#define HIGH_NUMBER 1000000
#define MAX_STR_SIZE 32000
#define MAX_BUF_SIZE 64000

// Flags
#define F_WRAP 1
#define F_WRAPSPRITE 2
#define F_IGNORECODES 4
#define F_YSCROLL 8
#define F_RESTORECURSOR 16
#define F_FOLLOWCURSOR 32

#define USE_EXISTING_FG 32
#define USE_EXISTING_BG 64
#define XOR_EXISTING_COL 128
#define AND_EXISTING_COL 512
#define OR_EXISTING_COL 2048
#define ADD_EXISTING_COL 8192

void GotoXY(HANDLE h, int x, int y) {
	COORD coord;
	coord.X = x;
	coord.Y = y;
	SetConsoleCursorPosition(h, coord);
}

void GetXY(HANDLE h, int *x, int *y) {
	CONSOLE_SCREEN_BUFFER_INFO	csbInfo;
	GetConsoleScreenBufferInfo(h, &csbInfo);
	*x = csbInfo.dwCursorPosition.X;
	*y = csbInfo.dwCursorPosition.Y;
}

int GetDim(HANDLE h, int bY) {
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	GetConsoleScreenBufferInfo(h, &screenBufferInfo);
	return bY? screenBufferInfo.dwSize.Y : screenBufferInfo.dwSize.X;
}

void ClrScr(HANDLE h, int attrib) {
	COORD a = {0,0};
	DWORD nwrite;
	FillConsoleOutputAttribute(h, attrib, GetDim(h,0)*GetDim(h,1), a, &nwrite);
	FillConsoleOutputCharacter(h, 0x20, GetDim(h,0)*GetDim(h,1), a, &nwrite);
}

int GetCol(char c, int oldc, int orgConsoleCol) {
	int pc = c -'0';
	if (pc > 9 || pc < 0) pc=oldc;
	switch(c) {
	case 'a':case 'A': pc=10; break;
	case 'b':case 'B': pc=11; break;
	case 'c':case 'C': pc=12; break;
	case 'd':case 'D': pc=13; break;
	case 'e':case 'E': pc=14; break;
	case 'f':case 'F': pc=15; break;
	case 'u': pc=orgConsoleCol & 0xf; break;
	case 'U': pc=(orgConsoleCol>>4) & 0xf; break;
	case 'v': pc=USE_EXISTING_FG; break;
	case 'V': pc=USE_EXISTING_BG; break;
	case 'X': pc=XOR_EXISTING_COL+oldc; break;
	case 'Y': pc=AND_EXISTING_COL+oldc; break;
	case 'Z': pc=OR_EXISTING_COL+oldc; break;
	case 'z': pc=ADD_EXISTING_COL+oldc; break;
	}
	return pc;
}

void CopyBuffer(HANDLE hSrc, HANDLE hDest, int ox, int oy, int w, int h, int nx, int ny) {
	COORD a, b = {0,0};
	SMALL_RECT r;
	CHAR_INFO *str;
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;

	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * MAX_STR_SIZE);
	if (!str)
		return;

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


int GetColorTranspCol(HANDLE h, int fgCol, int bgCol, int x, int y, int *bCreateBuffer, CHAR_INFO **currentConsoleOutput) {
	static HANDLE hOldHandle = INVALID_HANDLE_VALUE;
	static int height = 0, width = 0;
	SMALL_RECT r;
	COORD b = { 0, 0 };
	COORD a = { 1, 1 };
	int retChar = 0;

	if (hOldHandle != h) {
		hOldHandle = h;
		height = GetDim(h, 1);
		width = GetDim(h, 0);
		if (*currentConsoleOutput != NULL) {
			free(*currentConsoleOutput);
			*currentConsoleOutput = NULL;
		}		
	}

	if (*bCreateBuffer) {
		if (*currentConsoleOutput != NULL)
			free(*currentConsoleOutput);
		*currentConsoleOutput = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * width*height);
		if (*currentConsoleOutput != NULL) {
			// Stupid bug in ReadConsoleOutput doesn't seem to read more than ~15680 chars, then it's all garbled characters!! Have to read in smaller blocks
			int i, j, k, l;
			l = 15000 / width;
			i = height / l;
			for (j = 0; j <= i; j++) {
				r.Left = 0;
				r.Top = j*l;
				r.Right = width;
				if (i == j) k = height % l; else k = l;
				r.Bottom = j*l+k;
				a.X = r.Right;
				a.Y = k;
				ReadConsoleOutput(h, *currentConsoleOutput+j*l*width, a, b, &r);			
			}
		}
		*bCreateBuffer = 0;
	}
	
	if (y >= 0 && y <= height) {
	   if (*currentConsoleOutput != NULL) {
			int arrayPos = y	* width + x;
			if (fgCol < 0) retChar = (*currentConsoleOutput)[arrayPos].Char.AsciiChar;
			else if (fgCol < USE_EXISTING_FG) ;
			else if (fgCol == USE_EXISTING_FG) fgCol = (*currentConsoleOutput)[arrayPos].Attributes & 0xf;
			else if (fgCol == USE_EXISTING_BG) fgCol = ((*currentConsoleOutput)[arrayPos].Attributes>>4) & 0xf;
			else if (fgCol >= XOR_EXISTING_COL && fgCol < AND_EXISTING_COL) fgCol = ((*currentConsoleOutput)[arrayPos].Attributes & 0xf) ^ (fgCol-XOR_EXISTING_COL);
			else if (fgCol >= AND_EXISTING_COL && fgCol < OR_EXISTING_COL) fgCol = ((*currentConsoleOutput)[arrayPos].Attributes & 0xf) & (fgCol-AND_EXISTING_COL);
			else if (fgCol >= OR_EXISTING_COL && fgCol < ADD_EXISTING_COL) fgCol = ((*currentConsoleOutput)[arrayPos].Attributes & 0xf) | (fgCol-OR_EXISTING_COL);
			else if (fgCol >= ADD_EXISTING_COL) { fgCol = ((*currentConsoleOutput)[arrayPos].Attributes & 0xf) + (fgCol-ADD_EXISTING_COL); if (fgCol > 15) fgCol=15; }
			if (bgCol < USE_EXISTING_FG) ;
			else if (bgCol == USE_EXISTING_FG) bgCol = (*currentConsoleOutput)[arrayPos].Attributes & 0xf;
			else if (bgCol == USE_EXISTING_BG) bgCol = ((*currentConsoleOutput)[arrayPos].Attributes>>4) & 0xf;
			else if (bgCol >= XOR_EXISTING_COL && bgCol < AND_EXISTING_COL) bgCol = (((*currentConsoleOutput)[arrayPos].Attributes>>4) & 0xf) ^ (bgCol-XOR_EXISTING_COL);
			else if (bgCol >= AND_EXISTING_COL && bgCol < OR_EXISTING_COL) bgCol = (((*currentConsoleOutput)[arrayPos].Attributes>>4) & 0xf) & (bgCol-AND_EXISTING_COL);
			else if (bgCol >= OR_EXISTING_COL && bgCol < ADD_EXISTING_COL) bgCol = (((*currentConsoleOutput)[arrayPos].Attributes>>4) & 0xf) | (bgCol-OR_EXISTING_COL);
			else if (bgCol >= ADD_EXISTING_COL) { bgCol = (((*currentConsoleOutput)[arrayPos].Attributes>>4) & 0xf) + (bgCol-ADD_EXISTING_COL); if (bgCol > 15) bgCol=15; }
		} else {
			static CHAR_INFO str[4];
			r.Left = x;
			r.Top = y;
			r.Right = x + 1;
			r.Bottom = y + 1;
			ReadConsoleOutput(h, str, a, b, &r);
			if (fgCol < 0) retChar = str[0].Char.AsciiChar;
			else if (fgCol < USE_EXISTING_FG) ;
			else if (fgCol == USE_EXISTING_FG) fgCol = str[0].Attributes & 0xf;
			else if (fgCol == USE_EXISTING_BG) fgCol = (str[0].Attributes>>4) & 0xf;
			else if (fgCol >= XOR_EXISTING_COL && fgCol < AND_EXISTING_COL) fgCol = (str[0].Attributes & 0xf) ^ (fgCol-XOR_EXISTING_COL);
			else if (fgCol >= AND_EXISTING_COL && fgCol < OR_EXISTING_COL) fgCol = (str[0].Attributes & 0xf) & (fgCol-AND_EXISTING_COL);
			else if (fgCol >= OR_EXISTING_COL && fgCol < ADD_EXISTING_COL) fgCol = (str[0].Attributes & 0xf) | (fgCol-OR_EXISTING_COL);
			else if (fgCol >= ADD_EXISTING_COL) { fgCol = (str[0].Attributes & 0xf) + (fgCol-ADD_EXISTING_COL); if (fgCol > 15) fgCol=15; }
			if (bgCol < USE_EXISTING_FG) ;
			else if (bgCol == USE_EXISTING_FG) bgCol = str[0].Attributes & 0xf;
			else if (bgCol == USE_EXISTING_BG) bgCol = (str[0].Attributes>>4) & 0xf;
			else if (bgCol >= XOR_EXISTING_COL && bgCol < AND_EXISTING_COL) bgCol = ((str[0].Attributes>>4) & 0xf) ^ (bgCol-XOR_EXISTING_COL);
			else if (bgCol >= AND_EXISTING_COL && bgCol < OR_EXISTING_COL) bgCol = ((str[0].Attributes>>4) & 0xf) & (bgCol-AND_EXISTING_COL);
			else if (bgCol >= OR_EXISTING_COL && bgCol < ADD_EXISTING_COL) bgCol = ((str[0].Attributes>>4) & 0xf) | (bgCol-OR_EXISTING_COL);
			else if (bgCol >= ADD_EXISTING_COL) { bgCol = ((str[0].Attributes>>4) & 0xf) + (bgCol-ADD_EXISTING_COL); if (bgCol > 15) bgCol=15; }
		}
	}

	if (fgCol < 0)
		return retChar;
	else
		return fgCol | (bgCol<<4);
}


void ScrollUp(HANDLE h, int maxY, int orgConsoleCol) {
	COORD np = {0,0};
	SMALL_RECT r;
	CHAR_INFO chiFill;

	r.Left = 0;
	r.Top = 1;
	r.Right = GetDim(h,0)-1;
	r.Bottom = maxY;
	chiFill.Attributes = orgConsoleCol;
	chiFill.Char.AsciiChar = ' ';

	ScrollConsoleScreenBuffer(h, &r, NULL, np, &chiFill);
}

void WriteText(unsigned char *text, int fgCol, int bgCol, int *x, int *y, int flags, int wrapxpos, int orgConsoleCol) {
	HANDLE hCurrHandle, hNewScreenBuffer = INVALID_HANDLE_VALUE;
	int bufdims[4] = {0,0,80,25}, bNewHandle = 0, bCopyback = 0;
	int newX=UNKNOWN, newY=UNKNOWN, waitValue = -1, awaitValue = -1;
	int transpChar = -1, transpFg = -1, transpBg = -1, fgBgCol;
	int bForceFg = 0, bForceBg = 0, oldfc, oldbc;
	int maxY = HIGH_NUMBER, bDoScroll = 1, bScrollNow = 0, wrap = 0, bAllowCodes = 1;
	CHAR_INFO *currentConsoleOutput = NULL;
	int bUseCurrentConsoleOutput = 0;
	int i, j, inlen, orgx, yp = 0;
	unsigned int startT;
	SMALL_RECT r;
	CHAR_INFO *str;
	COORD a, b;
	char ch;

	hCurrHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	startT = GetTickCount();		
	oldfc = orgConsoleCol & 0xf;
	oldbc = (orgConsoleCol>>4) & 0xf;
	orgx = *x;

	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * MAX_STR_SIZE);
	if (!str)
		return;

	if (flags & F_YSCROLL) {
		maxY = GetDim(hCurrHandle, 1) - 1;
		if (*y > maxY) *y=maxY;
	}

	if (flags & F_IGNORECODES) {
		bAllowCodes = 0;
	}

	if (flags & F_WRAP) wrap = F_WRAP;
	if (flags & F_WRAPSPRITE) wrap = F_WRAPSPRITE;

	if (fgCol < 0) { bForceFg = 1; fgCol = -fgCol; if (fgCol > 15 && fgCol < USE_EXISTING_FG) fgCol=0; }
	if (bgCol < 0) { bForceBg = 1; bgCol = -bgCol; if (bgCol > 15 && bgCol < USE_EXISTING_FG) bgCol=0; }
	fgBgCol = fgCol | (bgCol<<4);
	if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG) fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
	inlen = strlen(text);

	i = 0;
	while (i < inlen) {
		j = 0;
		for(; i < inlen; i++) {
			ch = text[i];
			if (ch == '\\' && bAllowCodes) {
				i++;
				if (i < inlen) {
					ch = text[i];
					if (ch == '-') {
						if (wrap && *x+j+1 > wrapxpos && orgx <= wrapxpos) {
							yp = 0; i++; newY = *y+1; newX = (wrap == F_WRAP)? 0 : orgx; break;
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
						v16 = GetCol(text[i], 0, orgConsoleCol);
						i++;
						if (i < inlen) {
							v = GetCol(text[i], 0, orgConsoleCol);
						}
						v16 = (v16*16) + v;
						str[j].Char.AsciiChar = v16;
						if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG)
							fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
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
							} else if (text[i] == 'k' && k == 0) {
								if (bY == 0) newX=*x+j; else if (bY == 1) newY=*y;
							} else {
								if (k > 0) {
									number[k] = 0;
									if (bY == 0) newX=atoi(number); else if (bY == 1) newY=atoi(number);
								}
								break;
							}
							i++;
						}
						if (newX!=UNKNOWN && newY!=UNKNOWN) {
							bDoScroll = 0;
							break;
						}
						else
							i--;
					}
					else if (ch == '\\') {
						str[j].Char.AsciiChar = ch;
						if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG)
							fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						str[j].Attributes = fgBgCol;
						j++;
						if (wrap && *x+j > wrapxpos && orgx <= wrapxpos) {
							yp = 0; newY = *y+1; newX = (wrap == F_WRAP)? 0 : orgx; i++; break;
						}
					}
					else if (ch == 'G') {
						str[j].Char.AsciiChar = GetColorTranspCol(hCurrHandle, -1, -1, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG)
							fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						str[j].Attributes = fgBgCol;
						j++;
						if (wrap && *x+j > wrapxpos && orgx <= wrapxpos) {
							yp = 0; newY = *y+1; newX = (wrap == F_WRAP)? 0 : orgx; i++; break;
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
						if (!bForceFg) fgCol = oldfc;
						if (!bForceBg) bgCol = oldbc;
						oldfc = tmp1;
						oldbc = tmp2;
						fgBgCol = fgCol | (bgCol<<4);
					}
					else if (ch == 'w' || ch == 'W') {
						char number[1024], oldC = ch;
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
						char number[1024], oldC = ch;

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
						else if (hNewScreenBuffer != INVALID_HANDLE_VALUE) {
							bCopyback = 1;
							break;
						}
						else
							i--;
					}
					else if (ch == 't') {
						int v = 0, v16 = 0;
						i++;
						v16 = GetCol(text[i], 0, orgConsoleCol);
						i++;
						if (i < inlen) {
							v = GetCol(text[i], 0, orgConsoleCol);
						}
						i++;
						if (i < inlen) {
							transpFg = GetCol(text[i], -1, orgConsoleCol);
						}
						i++;
						if (i < inlen) {
							transpBg = GetCol(text[i], -1, orgConsoleCol);
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
					else if (ch == 'R') {
						bUseCurrentConsoleOutput = 1;
					}
					else {
						oldfc = fgCol;
						oldbc = bgCol;
						if (!bForceFg) fgCol = GetCol(ch, fgCol, orgConsoleCol);
						i++;
						if (i < inlen) {
							if (!bForceBg) bgCol = GetCol(text[i], bgCol, orgConsoleCol);
						}
						fgBgCol = fgCol | (bgCol<<4);
					}
				}
			} else {
				if (ch == transpChar && (transpFg == fgCol || transpFg==-1) && (transpBg == bgCol || transpBg==-1)) {
					if (wrap && *x+j+1 > wrapxpos && orgx <= wrapxpos) {
						yp = 0; i++; newY = *y+1; newX = (wrap == F_WRAP)? 0 : orgx; break;
					}
					if (j == 0)
						*x += 1;
					else {
						yp=0; i++; break;
					}
				} else {
					str[j].Char.AsciiChar = ch;
					if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG)
						fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
					str[j].Attributes = fgBgCol;
					j++;

					if (wrap && *x+j > wrapxpos && orgx <= wrapxpos) {
						yp = 0; newY = *y+1; newX = (wrap == F_WRAP)? 0 : orgx; i++; break;
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
			if (*y > maxY) { *y=maxY; bScrollNow = 1; }
			*x = orgx;
			yp = 0;
		} else {
			*x += j + ((waitValue >= 0 || awaitValue >= 0 || bNewHandle > 0)? 0 : 1);
		}

		if (newX!=UNKNOWN || newY!=UNKNOWN) {
			if (newX!=UNKNOWN && newY!=UNKNOWN) {
				*x = newX;
				*y = newY;
				if (*y > maxY) { *y=maxY; bScrollNow = 1; }
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
					; // Sleep(1); inconsistent/unsmooth results
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

		if (bScrollNow && bDoScroll && (flags & F_YSCROLL)) { 
			ScrollUp(hCurrHandle, maxY, orgConsoleCol);
			bScrollNow = 0;
		}
		bDoScroll = 1;
	}

	if (flags & F_YSCROLL) {
		if (*y >= maxY)
			ScrollUp(hCurrHandle, maxY, orgConsoleCol);
		(*y)++;
		if (*y > maxY) *y=maxY;
	}

	if (hNewScreenBuffer != INVALID_HANDLE_VALUE){
		CopyBuffer(hNewScreenBuffer, GetStdHandle(STD_OUTPUT_HANDLE), 0, 0, bufdims[2], bufdims[3], bufdims[0], bufdims[1]);
		CloseHandle(hNewScreenBuffer);
	}

	if (currentConsoleOutput != NULL)
		free(currentConsoleOutput);
	free(str);
	if (*x!=orgx) (*x)--;
}

int GetConsoleColor(){
	CONSOLE_SCREEN_BUFFER_INFO info;
	if (!GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info))
		return 0x7;
	return info.wAttributes;
}

int main(int argc, char **argv) {
	int ox, oy;
	int x, y;
	int orgConsoleCol = 0x7;
	int fgCol = 7, bgCol = 0, wrap = 0, wrapxpos = 0, bAllowCodes = 1;
	int flags = 0;
	unsigned char *u8buf = NULL;
	HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE);

	if (argc < 3 || argc > 9) {
		printf("\nUsage: gotoxy x|keep y|keep [text|file.gxy] [fgcol(**)] [bgcol(**)] [flags(***)] [wrapxpos]\n");
		printf("\nCols: 0=Black 1=Blue 2=Green 3=Aqua 4=Red 5=Purple 6=Yellow 7=LGray(default)\n      8=Gray 9=LBlue 10=LGreen 11=LAqua 12=LRed 13=LPurple 14=LYellow 15=White\n");
		printf("\n[text] supports control codes:\n     \\px;y: cursor position x y ('k' keeps current)\n       \\xx: fgcol and bgcol in hex, eg \\A0 (*)\n        \\r: restore old color\n      \\gxx: ascii character in hex\n    \\txxXX: set character xx with col XX as transparent (*)\n        \\n: newline\n        \\N: clear screen\n        \\-: skip character (transparent)\n        \\\\: print \\\n        \\G: print existing character at position\n       \\wx: delay x ms\n       \\Wx: delay up to x ms\n        \\R: read/refresh buffer for v/V colors (fast but less accurate)\n \\ox;y;w;h: copy/write to offscreen buffer, copy back at end or at \\o\n \\Ox;y;w;h: clear/write to offscreen buffer, copy back at end or at \\O\n\n(*) Use 'k' to keep current color, 'u/U' for console fgcol/bgcol, 'v/V' to use existing fgcol/bgcol at position where text is put, 'Z/z/Y/X' to or/add/and/xor current color with color at position\n\n(**) Same as (*), precede with '-' to force color and ignore color codes\n\n(***) One or more of: 'c/r' to follow/restore cursor position, 'w/W' to wrap/spritewrap text, 'i' to ignore all control codes, 's' to enable scrolling\n");
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
		       // Downside: exe files become slower (why?), even if not using Extended Ascii characters in the string.
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
						437,          // convert to IBM437 ("extended AscII")
						0,            // conversion behavior
						szArglist[3], // source UTF-16 string
						wlen+1,       // total source string length, in WCHAR’s, including end-of-string
						u8buf,        // destination buffer
						MAX_BUF_SIZE, // destination buffer size, in bytes
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
		GetXY(h, &ox, &oy);

	x = argv[1][0] == 'k'? ox : atoi(argv[1]);
	y = argv[2][0] == 'k'? oy : atoi(argv[2]);

	if (argc > 6) {
		int wxp, i;
		for (i=0; i < strlen(argv[6]); i++) {
			switch(argv[6][i]) {
			case 'w': flags |= F_WRAP; break;
			case 'W': flags |= F_WRAPSPRITE; break;
			case 's': flags |= F_YSCROLL; break;
			case 'i': flags |= F_IGNORECODES; break;
			case 'c': flags |= F_FOLLOWCURSOR; break;
			case 'r': flags |= F_RESTORECURSOR; break;
			}
		}
		wrapxpos = GetDim(h, 0) - 1;
		if (argc > 7) {
			wxp = atoi(argv[7]);
			if (wxp >= x)
				wrapxpos = wxp;
		}
	}

	if (!(flags & F_FOLLOWCURSOR) && !(flags & F_RESTORECURSOR))
		GotoXY(h, x, y);

	orgConsoleCol = GetConsoleColor();
	fgCol = orgConsoleCol & 0xf;
	bgCol = (orgConsoleCol>>4) & 0xf;

	if (argc > 5) {
		int mul = 1;
		char *pfg = argv[5];
		if (*pfg=='-') { mul = -1; pfg++; }
		bgCol = (pfg[1]==0? GetCol(*pfg, bgCol, orgConsoleCol) : atoi(pfg)) * mul;
		if (bgCol == 0 && mul < 1) bgCol = -16;
		if (bgCol > 15 && bgCol != USE_EXISTING_FG && bgCol != USE_EXISTING_BG) bgCol = 0;
	}
	if (argc > 4) {
		int mul = 1;
		char *pfg = argv[4];
		if (*pfg=='-') { mul = -1; pfg++; }
		fgCol = (pfg[1]==0? GetCol(*pfg, fgCol, orgConsoleCol) : atoi(pfg)) * mul;
		if (fgCol == 0 && mul < 1) fgCol = -16;
		if (fgCol > 15 && fgCol != USE_EXISTING_FG && fgCol != USE_EXISTING_BG) fgCol = 0;
	}
	if (argc > 3)
		WriteText(u8buf? u8buf : (unsigned char *)argv[3], fgCol, bgCol, &x, &y, flags, wrapxpos, orgConsoleCol);
		
	if (flags & F_FOLLOWCURSOR) {
		GotoXY(h, x, y);
	}

	if (u8buf)
		free(u8buf);

	return 0;
}
