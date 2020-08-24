/* GotoXY (c) 2015-20 Mikael Sollenborn */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <ctype.h>
#include <conio.h>

//#define SUPPORT_EXTENDED
#ifdef SUPPORT_EXTENDED
#define SUPPORT_EXTENDED_ASCII_ON_CMD_LINE
#define SUPPORT_KEYCODES_CHECK
#endif

//#define DEBUG_PRINT
#ifdef DEBUG_PRINT
static void DebugPrint(char * const msg, const int px, const int py, const int waitVal);
static void DebugPrintI(const int v, const int px, const int py, const int waitVal);
static void DebugPrintIS(const int v);
#endif

// Constants
#define UNKNOWN -999999
#define MAX_STR_SIZE 64000
#define MAX_BUF_SIZE 128000

#define DIM_WIDTH  0
#define DIM_HEIGHT 1

// Flags
#define F_WRAP0 1
#define F_WRAPSPRITE 2
#define F_IGNORECODES 4
#define F_YSCROLL 8
#define F_RESTORECURSOR 16
#define F_FOLLOWCURSOR 32
#define F_FOLLOWCURSORVISIBLE 64
#define F_EVALUATEEXPRESSIONS 128
#define F_WORDWRAP 256
#define F_FORCE_FILE_INPUT 512
#define F_FORCE_TEXT_INPUT 1024
#define F_RETURN_KEY_INPUT 2048
#define F_IGNORE_NEWLINE_CHAR 4096

// Bit operations
#define USE_EXISTING_FG 32
#define USE_EXISTING_BG 64
#define XOR_EXISTING_BG 128
#define AND_EXISTING_BG 256
#define OR_EXISTING_BG 512
#define ADD_EXISTING_BG 1024
#define XOR_EXISTING_FG 2048
#define AND_EXISTING_FG 4096
#define OR_EXISTING_FG 8192
#define ADD_EXISTING_FG 16384

// Server
#define MAX_SERVER_STRING_SIZE 128000


static HANDLE g_conout;

static HANDLE GetOutputHandle(void) {
	return CreateFile("CONOUT$", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
}

static int GetDim(const HANDLE h, const int bH) {
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	GetConsoleScreenBufferInfo(h, &screenBufferInfo);
	return bH? screenBufferInfo.dwSize.Y : screenBufferInfo.dwSize.X;
}

static void GotoXY(const HANDLE h, int x, int y) {
	COORD coord;
	BOOL res;
	if (x < 0) x = 0;
	if (y < 0) y = 0;
	coord.X = x;
	coord.Y = y;
	res = SetConsoleCursorPosition(h, coord);
	if (res == 0) {
		int mX, mY;
		mX = GetDim(h, DIM_WIDTH);
		if (coord.X >= mX) coord.X = mX-1;
		mY = GetDim(h, DIM_HEIGHT);
		if (coord.Y >= mY) coord.Y = mY-1;
		SetConsoleCursorPosition(h, coord);
	}
}

static void GetXY(const HANDLE h, int *x, int *y) {
	CONSOLE_SCREEN_BUFFER_INFO	csbInfo;
	GetConsoleScreenBufferInfo(h, &csbInfo);
	*x = csbInfo.dwCursorPosition.X;
	*y = csbInfo.dwCursorPosition.Y;
}

static void ClrScr(const HANDLE h, const int attrib, const int glyph) {
	COORD a = {0,0};
	DWORD nwrite;
	FillConsoleOutputAttribute(h, attrib, GetDim(h,DIM_WIDTH)*GetDim(h,DIM_HEIGHT), a, &nwrite);
	FillConsoleOutputCharacter(h, glyph, GetDim(h,DIM_WIDTH)*GetDim(h,DIM_HEIGHT), a, &nwrite);
}

static int GetHex(const char c) {
	int pc = c -'0';
	if (pc > 9 || pc < 0) pc=0;
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

static int GetCol(const char c, const int oldc, const int orgConsoleCol, int * const forceCol) {
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
	case 'x': pc=XOR_EXISTING_FG+oldc; break;
	case 'y': pc=AND_EXISTING_FG+oldc; break;
	case 'z': pc=OR_EXISTING_FG+oldc; break;
	case 'q': pc=ADD_EXISTING_FG+oldc; break;
	case 'X': pc=XOR_EXISTING_BG+oldc; break;
	case 'Y': pc=AND_EXISTING_BG+oldc; break;
	case 'Z': pc=OR_EXISTING_BG+oldc; break;
	case 'Q': pc=ADD_EXISTING_BG+oldc; break;
	case 'H': *forceCol=1; pc=oldc; break;
	case 'h': *forceCol=0; pc=oldc; break;
	case '+': pc=oldc + 1; if (pc > 15) pc=0; break;
	case '/': pc=oldc - 1; if (pc < 0) pc=15; break;
	}
	if (*forceCol && oldc > USE_EXISTING_BG) {
		if (pc <= 15)
			pc = (oldc & 0xfff0) + pc;
		else
			pc = oldc;
	}
	return pc;
}

static void CopyBuffer(const HANDLE hSrc, const HANDLE hDest, const int ox, const int oy, const int w, const int h, const int nx, const int ny) {
	COORD a, b = {0,0};
	SMALL_RECT r;
	CHAR_INFO *str;

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

#define SETCOL(colType) \
	switch(colType & 0xfff0) { \
		case USE_EXISTING_FG: colType = attribs & 0xf; break; \
		case USE_EXISTING_BG: colType = (attribs>>4) & 0xf; break; \
		case XOR_EXISTING_BG: colType = ((attribs>>4) & 0xf) ^ (colType-XOR_EXISTING_BG); break; \
		case AND_EXISTING_BG: colType = ((attribs>>4) & 0xf) & (colType-AND_EXISTING_BG); break; \
		case OR_EXISTING_BG:  colType = ((attribs>>4) & 0xf) | (colType-OR_EXISTING_BG); break; \
		case ADD_EXISTING_BG: colType = ((attribs>>4) & 0xf) + (colType-ADD_EXISTING_BG); if (colType > 15) colType=15; break; \
		case XOR_EXISTING_FG: colType = (attribs & 0xf) ^ (colType-XOR_EXISTING_FG); break; \
		case AND_EXISTING_FG: colType = (attribs & 0xf) & (colType-AND_EXISTING_FG); break; \
		case OR_EXISTING_FG:  colType = (attribs & 0xf) | (colType-OR_EXISTING_FG); break; \
		case ADD_EXISTING_FG: colType = (attribs & 0xf) + (colType-ADD_EXISTING_FG); if (colType > 15) colType=15; break; \
	}	
		
static int GetColorTranspCol(const HANDLE h, int fgCol, int bgCol, const int x, const int y, int * const bCreateBuffer, CHAR_INFO ** const currentConsoleOutput) {
	static HANDLE hOldHandle = INVALID_HANDLE_VALUE;
	static int height = 0, width = 0;
	SMALL_RECT r;
	COORD b = { 0, 0 };
	COORD a = { 1, 1 };
	int retChar = 0;
	int attribs;

	if (hOldHandle != h) {
		hOldHandle = h;
		height = GetDim(h, DIM_HEIGHT);
		width = GetDim(h, DIM_WIDTH);
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
	
	if (y >= 0 && y < height && x >= 0 && x < width) {
		if (*currentConsoleOutput != NULL) {
			int arrayPos = y * width + x;
			if (fgCol < 0) retChar = (*currentConsoleOutput)[arrayPos].Char.AsciiChar;
			attribs = (*currentConsoleOutput)[arrayPos].Attributes;
		} else {
			static CHAR_INFO str[4];
			r.Left = x;
			r.Top = y;
			r.Right = x + 1;
			r.Bottom = y + 1;
			ReadConsoleOutput(h, str, a, b, &r);
			if (fgCol < 0) retChar = str[0].Char.AsciiChar;
			attribs = str[0].Attributes;
		}

		SETCOL(fgCol)
		SETCOL(bgCol)
	}

	if (fgCol < 0)
		return retChar;
	else
		return fgCol | (bgCol<<4);
}

static void ScrollUp(const HANDLE h, const int * const scrolldims, const int orgConsoleCol) {
	COORD np = {0,0};
	SMALL_RECT r;
	CHAR_INFO chiFill;

	np.X = scrolldims[0];
	np.Y = scrolldims[1];
	
	r.Left = scrolldims[0];
	r.Top = scrolldims[1] + 1;
	r.Right = scrolldims[2];
	r.Bottom = scrolldims[3];
	chiFill.Attributes = orgConsoleCol;
	chiFill.Char.AsciiChar = ' ';

	ScrollConsoleScreenBuffer(h, &r, NULL, np, &chiFill);
}

static int WriteText(unsigned char * const text, int fgCol, int bgCol, int * const x, int * const y, const int flags, const int wrapxpos, const int orgConsoleCol, unsigned int startT) {
	
	#define OFFSCREEN_NEW_COPY   1
	#define OFFSCREEN_NEW_CLEAR  2

	#define KEY_WAIT   1
	#define KEY_CHECK  2

	#define HIGH_NUMBER 1000000
	
	HANDLE hCurrHandle, hNewScreenBuffer = INVALID_HANDLE_VALUE;
	int bufdims[4] = {0,0,80,25}, scrolldims[4] = {0,0,80,25}, newscrolldims[4], bNewHandle = 0, bCopyback = 0, bNewScrollDims = 0, bIgnoreNewline = 0;
	int newX=UNKNOWN, newY=UNKNOWN, waitValue = -1, awaitValue = -1;
	int transpChar = -1, transpFg = -1, transpBg = -1, fgBgCol;
	int bForceFg = 0, bForceBg = 0, oldfc, oldbc;
	int maxY = HIGH_NUMBER, bDoScroll = 1, bScrollNow = 0, wrap = 0, wordwrap = 0, bAllowCodes = 1, lastSep = -1, lastSepj = 0;
	CHAR_INFO *currentConsoleOutput = NULL;
	int j, orgx, yp = 0, keyWait = 0, bUseCurrentConsoleOutput = 0;
	int keyret = 0, bBreakToWrite, bCheckWrap, bHandleTransp;
	int bY, k, v, v16, dI, tmp1, tmp2, relX, relY, bWroteTab = 0, transparentMode = 0;
	unsigned int inlen, i;
	char ch, number[1024];
	SMALL_RECT r;
	CHAR_INFO *str;
	COORD a, b;
	
	hCurrHandle = g_conout;

	oldfc = orgConsoleCol & 0xf;
	oldbc = (orgConsoleCol>>4) & 0xf;
	orgx = *x;

	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * MAX_STR_SIZE);
	if (!str) return keyret;

	if (flags & F_YSCROLL) {
		scrolldims[2] = GetDim(hCurrHandle, DIM_WIDTH) - 1;
		maxY = GetDim(hCurrHandle, DIM_HEIGHT) - 1;
		if (*y > maxY) *y=maxY;
		scrolldims[3] = maxY;
	}

	if (flags & F_IGNORECODES) bAllowCodes = 0;
	
	if (flags & F_WORDWRAP) { wordwrap = F_WORDWRAP; wrap = F_WRAPSPRITE; }
	if (flags & F_WRAP0) wrap = F_WRAP0;
	if (flags & F_WRAPSPRITE) wrap = F_WRAPSPRITE;
	if (flags & F_RETURN_KEY_INPUT) keyWait = KEY_CHECK;
	if (flags & F_IGNORE_NEWLINE_CHAR) bIgnoreNewline = 1;

	if (fgCol < 0) { bForceFg = 1; fgCol = -fgCol; if (fgCol > 15 && fgCol < USE_EXISTING_FG) fgCol=0; }
	if (bgCol < 0) { bForceBg = 1; bgCol = -bgCol; if (bgCol > 15 && bgCol < USE_EXISTING_FG) bgCol=0; }
	fgBgCol = fgCol | (bgCol<<4);
	if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG) fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
	inlen = strlen((char *)text);

	if (flags & F_FOLLOWCURSORVISIBLE)
		GotoXY(hCurrHandle, *x, *y);

	i = 0;
	while (i < inlen) {
		j = 0;
		lastSep = -1;
		bBreakToWrite = bCheckWrap = bHandleTransp = 0;
		for(; i < inlen; i++) {
			ch = text[i];
			if (ch == '\\' && bAllowCodes) {
				i++;
				ch = text[i];

				switch(ch) {
					case '-': {
						bCheckWrap = bHandleTransp = 1;
						break;
					}
					
					case 'g': {
						i++; v16 = GetHex(text[i]);
						i++; v = 0;
						if (i < inlen) {
							v = GetHex(text[i]);
						}
						v16 = (v16*16) + v;
						if (transpChar >= 0) {
							ch = v16;
							goto UGLY_TRANSPARENT_ENCODED_CHAR_FIX_JUMP;
						}
						str[j].Char.AsciiChar = v16;
						if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG)
							fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						str[j].Attributes = fgBgCol;
						j++;
						if (wordwrap && v16 == ' ') {
							lastSep = i; lastSepj = j;
						}
						if (wrap) bCheckWrap = 1;
						break;
					}
					
					case 'p': {
						i++;
						bY = k = relX = relY = 0;
						yp = 0;
						while(i < inlen && bY < 2) {
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
							} else if ((text[i] == '+' || text[i] == '/') && k == 0) {
								if (bY == 0) relX=text[i]=='+'?1:-1; else if (bY == 1) relY=text[i]=='+'?1:-1;
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
							if (relX) newX = *x+j+newX*relX;
							if (relY) newY = *y+newY*relY;
							bDoScroll = 0;
							bBreakToWrite = 1;
						} else
							i--;
						break;
					}
					
					case '\\': {
						str[j].Char.AsciiChar = ch;
						if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG)
							fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						str[j].Attributes = fgBgCol;
						j++;
						if (wrap) bCheckWrap = 1;
						break;
					}
					
					case 'G': {
						str[j].Char.AsciiChar = GetColorTranspCol(hCurrHandle, -1, -1, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG)
							str[j].Attributes = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						else
							str[j].Attributes = fgBgCol;
						j++;
						if (wrap) bCheckWrap = 1;
						break;
					}
					
					case 'J': {
						str[j].Char.AsciiChar = GetColorTranspCol(hCurrHandle, -1, -1, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						str[j].Attributes = GetColorTranspCol(hCurrHandle, USE_EXISTING_FG, USE_EXISTING_BG, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						j++;
						if (wrap) bCheckWrap = 1;
						break;
					}
					
					case 'n': {
						i++;
						yp = 1;
						if (wrap == F_WRAP0) newX = 0;
						bBreakToWrite = 1;
						break;
					}
					
					case 'K': {
						keyWait = KEY_WAIT;
						i++;
						bBreakToWrite = 1;
						break;
					}
					
					case 'L': {
						i++;
						keyWait = KEY_CHECK;
#ifdef SUPPORT_KEYCODES_CHECK
						if (text[i] == ':') { 
							int ks;
							k = 0;
							keyret = 0;
							keyWait = 0;
							i++;
							while (text[i] != 0 && text[i+1] != 0 && text[i] != ';' && text[i+1] != ';') {
								number[0]=text[i]; number[1]=text[i+1]; number[2]=0;	
								ks = GetAsyncKeyState(strtol(number, NULL, 16));		
								keyret = keyret | (((ks & 0x8000)? 1:0 ) << k);
								i+=2;
								k++;
							}
						}
#endif
						break;
					}

/*
					case 't': { // tab support
						tmp1 = 4;
						i++; k = 0;
						while (text[i] != 0) {
							if (text[i]>='0' && text[i]<='9') {
								number[k++] = text[i];
							} else
								break;
							i++;
						}
						number[k] = 0;
						if (k > 0) {
							tmp1 = atoi(number);
							if (text[i] == ';') i++;
						}
						i--;
						newX=*x+j+tmp1;
						newX-=newX%tmp1;
						newY=*y;
						bWroteTab = 1;
						bDoScroll = 0;
						bBreakToWrite = 1;
						i++;
						break;
					}
*/
					case 'r': {
						tmp1 = oldfc;
						tmp2 = oldbc;
						if (!bForceFg) fgCol = oldfc;
						if (!bForceBg) bgCol = oldbc;
						oldfc = tmp1;
						oldbc = tmp2;
						fgBgCol = fgCol | (bgCol<<4);
						break;
					}
					
					case 'w': case 'W': {
						i++;
						k = 0;
						yp = 0;
						while(i < inlen) {
							if (text[i]>='0' && text[i]<='9') {
								number[k++]=text[i];
								if (!(i+1 < inlen)) {
									number[k] = 0; if (ch=='w') waitValue = atoi(number); else awaitValue = atoi(number);
								}
							} else {
								if (k > 0) {
									number[k] = 0; if (ch=='w') waitValue = atoi(number); else awaitValue = atoi(number);
									if (text[i] == ';') i++;
								}
								break;
							}
							i++;
						}
						bBreakToWrite = 1;
						break;
					}
					
					case 'o': case 'O': {
						i++;
						dI = k = 0;
						yp = 0;
						while(i < inlen) {
							if (text[i]>='0' && text[i]<='9') {
								number[k++]=text[i];
								if (!(i+1 < inlen)) {
									number[k] = 0;
									bufdims[dI++] = atoi(number);
									if (dI > 3) break;
								}
							}
							else if (text[i] == ';') {
								if (k > 0) {
									number[k] = 0;
									bufdims[dI++] = atoi(number);
									if (dI > 3) { i++; break; }
									k=0;
								}
							} else {
								if (k > 0) {
									number[k] = 0;
									bufdims[dI++] = atoi(number);
									if (dI > 3) break;
								}
								break;
							}
							i++;
						}
						if (dI >= 3 && hNewScreenBuffer == INVALID_HANDLE_VALUE) {
							bNewHandle = ch=='o'? OFFSCREEN_NEW_COPY : OFFSCREEN_NEW_CLEAR;
							bBreakToWrite = 1;
						}
						else if (hNewScreenBuffer != INVALID_HANDLE_VALUE) {
							bCopyback = 1;
							bBreakToWrite = 1;
						}
						else
							i--;
						break;
					}
					
					case 'S': {
						i++;
						dI = k = 0;
						yp = 0;
						while(i < inlen) {
							if (text[i]>='0' && text[i]<='9') {
								number[k++]=text[i];
								if (!(i+1 < inlen)) {
									number[k] = 0;
									newscrolldims[dI++] = atoi(number);
									if (dI > 3) break;
								}
							}
							else if (text[i] == ';') {
								if (k > 0) {
									number[k] = 0;
									newscrolldims[dI++] = atoi(number);
									if (dI > 3) {i++; break; }
									k=0;
								}
							} else {
								if (k > 0) {
									number[k] = 0;
									newscrolldims[dI++] = atoi(number);
									if (dI > 3) break;
								}
								break;
							}
							i++;
						}
						if (dI >= 3) {
							j--;
							bNewScrollDims = 1;
							bBreakToWrite = 1;
						}
						else
							i--;
						break;
					}
					
					case 'T': {
						i++; v16 = GetHex(text[i]);
						i++; v = 0;
						if (i < inlen) {
							v = GetHex(text[i]);
						}
						i++;
						if (i < inlen) {
							transpFg = GetCol(text[i], -1, orgConsoleCol, &tmp1);
						}
						i++;
						if (i < inlen) {
							transpBg = GetCol(text[i], -1, orgConsoleCol, &tmp1);
						}
						i++;
						if (i < inlen) {
							transparentMode = 0;
							if (text[i] == '1') transparentMode = 1;
						}
						v16 = (v16*16) + v;
						transpChar = v16;
						break;
					}
					
					case 'N': {
						i++; v16 = GetHex(text[i]);
						i++; v = 0;
						if (i < inlen) {
							v = GetHex(text[i]);
						}
						v16 = (v16*16) + v;

						ClrScr(hCurrHandle, fgBgCol, v16);
						newX = newY = 0;
						j = 0;
						yp = 0;
						i++;
						bBreakToWrite = 1;
						break;
					}
					
					case 'R': {
						bUseCurrentConsoleOutput = 1;
						break;
					}
						
					case 0: break;

					default: {
						oldfc = fgCol;
						oldbc = bgCol;
						if (!bForceFg || ch=='h' || fgCol > USE_EXISTING_BG ) fgCol = GetCol(ch, fgCol, orgConsoleCol, &bForceFg);
						i++;
						if (i < inlen) {
							if (!bForceBg || text[i]=='h' || bgCol > USE_EXISTING_BG ) { bgCol = GetCol(text[i], bgCol, orgConsoleCol, &bForceBg); }
						}
						fgBgCol = fgCol | (bgCol<<4);
					}
				}

				if (bBreakToWrite) break;
				
			} else {
UGLY_TRANSPARENT_ENCODED_CHAR_FIX_JUMP:
				if (transparentMode == 0 && ch == transpChar && (transpFg == fgCol || transpFg==-1) && (transpBg == bgCol || transpBg==-1)) {
					bCheckWrap = bHandleTransp = 1;
				} else if (ch == 10) {
					if (!bIgnoreNewline) {
						i++;
						yp = 1;
						if (wrap == F_WRAP0) newX = 0;
						break;
					}
				} else if (ch == 9) {
					newX=*x+j+4;
					newX-=newX%4;
					newY=*y;
					bWroteTab = 1;
					bDoScroll = 0;
					i++;
					break;
				} else {
					if (transparentMode == 1 && ch == transpChar && (transpFg == fgCol || transpFg==-1) && (transpBg == bgCol || transpBg==-1)) {
						str[j].Char.AsciiChar = GetColorTranspCol(hCurrHandle, -1, -1, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						str[j].Attributes = GetColorTranspCol(hCurrHandle, USE_EXISTING_FG, USE_EXISTING_BG, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
					} else {
						str[j].Char.AsciiChar = ch;
						if (fgCol >= USE_EXISTING_FG || bgCol >= USE_EXISTING_FG)
							fgBgCol = GetColorTranspCol(hCurrHandle, fgCol, bgCol, *x+j, *y, &bUseCurrentConsoleOutput, &currentConsoleOutput);
						str[j].Attributes = fgBgCol;
					}
					j++;
			
					if (wordwrap && ch == ' ') {
						lastSep = i; lastSepj = j;
					}
					if (wrap) bCheckWrap = 1;
				}
			}
			
			if (bCheckWrap) {
				if (bHandleTransp) {
					bHandleTransp = 0;
					if (j == 0) {
						*x += 1;
					} else {
						yp=0; i++; break;
					}
				}
				bCheckWrap = 0;
				if (wrap && *x+j > wrapxpos && orgx <= wrapxpos) {
					yp = 0; newY = *y+1; newX = (wrap == F_WRAP0)? 0 : orgx; 
					if (!wordwrap || lastSep == -1) i++; else { i = lastSep + 1; j = lastSepj; }
					break;
				}
			}
		}

		if (j > 0) {
			a.X = j;
			a.Y = 1;
			if (*y >= 0) {
				b.X = b.Y = 0;
				r.Left = *x;
				r.Top = *y;
				r.Right = *x + j;
				r.Bottom = *y + 1;
				WriteConsoleOutput(hCurrHandle, str, a, b, &r);
			}
		}
		if (yp == 1) {
			(*y)++;
			if (*y > maxY) { *y=maxY; bScrollNow = 1; }
			if (newX != UNKNOWN) *x = newX; else *x = orgx;
			yp = 0;
		} else {
			*x += j + ((waitValue >= 0 || awaitValue >= 0 || bNewHandle > 0)? 0 : 1);
		}
		if (newX!=UNKNOWN || newY!=UNKNOWN) {
			if (newX!=UNKNOWN && newY!=UNKNOWN) {
				*x = newX;
				*y = newY;
				if (*y > maxY) { *y=maxY; bScrollNow = 1; }
				if (!bWroteTab) orgx = *x;
				bWroteTab = 0;
				yp = 0;
			}
		}
		newX = newY = UNKNOWN;

		if (flags & F_FOLLOWCURSORVISIBLE)
			GotoXY(hCurrHandle, *x, *y);

		if (waitValue >= 0) {
			if (waitValue > 0)
				Sleep(waitValue);
			waitValue = -1;
		}

		if (awaitValue >= 0) {
			if (awaitValue > 0) {
				int timeLeft = (startT+awaitValue) - GetTickCount();
				if (timeLeft > 0)
					Sleep(timeLeft);
			}
			awaitValue = -1;
			startT = GetTickCount();
		}
		
		if (keyWait == KEY_WAIT || (keyWait == KEY_CHECK && kbhit())) {
			k = getch();
			if (k == 224 || k == 0) k = 256 + getch();
			keyret = k;
			keyWait = 0;
		}

		if (bNewHandle == OFFSCREEN_NEW_COPY || bNewHandle == OFFSCREEN_NEW_CLEAR) {
			hNewScreenBuffer = CreateConsoleScreenBuffer( 
			GENERIC_READ | GENERIC_WRITE, 
			FILE_SHARE_READ | FILE_SHARE_WRITE,
			NULL, CONSOLE_TEXTMODE_BUFFER, NULL);
						
			if (hNewScreenBuffer != INVALID_HANDLE_VALUE) {
				hCurrHandle = hNewScreenBuffer;
				if (bNewHandle == OFFSCREEN_NEW_COPY) {
					CopyBuffer(g_conout, hNewScreenBuffer, bufdims[0], bufdims[1], bufdims[2], bufdims[3], 0, 0);
				}
			}
			bNewHandle = 0;
		}

		if (bCopyback) {
			hCurrHandle = g_conout;
			CopyBuffer(hNewScreenBuffer, hCurrHandle, 0, 0, bufdims[2], bufdims[3], bufdims[0], bufdims[1]);
			CloseHandle(hNewScreenBuffer);
			hNewScreenBuffer = INVALID_HANDLE_VALUE;
			bCopyback = 0;
		}

		if (bScrollNow && bDoScroll && (flags & F_YSCROLL)) { 
			ScrollUp(hCurrHandle, scrolldims, orgConsoleCol);
			bScrollNow = 0;
		}
		bDoScroll = 1;
		
		if (bNewScrollDims && newscrolldims[0] >= 0 && newscrolldims[1] >= 0 && newscrolldims[2] > 1 && newscrolldims[3] > 1) {
			scrolldims[0] = newscrolldims[0];
			scrolldims[1] = newscrolldims[1];
			scrolldims[2] = newscrolldims[0] + newscrolldims[2] - 1;
			scrolldims[3] = newscrolldims[1] + newscrolldims[3] - 1;
			maxY = scrolldims[3];
			if (*y > maxY) *y=maxY;
			if (*y < scrolldims[1]) *y=scrolldims[1];
			if (*x < scrolldims[0]) *x=scrolldims[0];
			if (*x > scrolldims[2]) *x=scrolldims[2];
		}
		bNewScrollDims = 0;
	}

	if (hNewScreenBuffer != INVALID_HANDLE_VALUE){
		CopyBuffer(hNewScreenBuffer, g_conout, 0, 0, bufdims[2], bufdims[3], bufdims[0], bufdims[1]);
		CloseHandle(hNewScreenBuffer);
	}

	if (currentConsoleOutput != NULL)
		free(currentConsoleOutput);
	free(str);
	if (*x!=orgx) (*x)--;
	
	return keyret;
	
	#undef OFFSCREEN_NEW_COPY
	#undef OFFSCREEN_NEW_CLEAR
	#undef KEY_WAIT
	#undef KEY_CHECK
	#undef HIGH_NUMBER
}


#ifdef DEBUG_PRINT
static void DebugPrint(char * const msg, int px, int py, const int waitVal) {
	static int bDebugPrinting = 0;
	if (bDebugPrinting) return;
	bDebugPrinting = 1;
	WriteText((unsigned char *)msg, 15, 0, &px, &py, 0, 0, 7, 0);
	bDebugPrinting = 0;
	if (waitVal > 0)
		Sleep(waitVal);
}

static void DebugPrintI(const int v, const int px, const int py, const int waitVal) {
	char dbuf[64];
	sprintf(dbuf, "%d                ", v);
	DebugPrint(dbuf, px, py, waitVal);
}

// note: inline is to get rid of "unused function" warning 
inline static void DebugPrintIS(const int v) {
	DebugPrintI(v, 66, 0, 0);
}
#endif

static int GetConsoleColor(void){
	CONSOLE_SCREEN_BUFFER_INFO info;
	if (!GetConsoleScreenBufferInfo(g_conout, &info))
		return 0x7;
	return info.wAttributes;
}


static char *InlineGxy(char *inp, __attribute__((unused)) int bAllocated) {
	char *nb = NULL, *nf = NULL, *fnd, *fnd2, fname[256], *currI, *currO, nofile[64] = "[FILE NOT FOUND]";
	FILE *ifp;
	int fr;

	fnd = strstr(inp, "\\I:");
 	if (!fnd) return NULL;

	nb = (char *)malloc(MAX_BUF_SIZE);
	if (!nb) return NULL;
	nf = (char *)malloc(MAX_STR_SIZE);
	if (!nf) { free(nb); return NULL; }
	currI = inp;
	currO = nb;
	
	do {
		fnd2 = strstr((char *)(fnd + 3), ";");
		if (!fnd2 || fnd2 == (char *)(fnd+1) || (fnd2 - fnd) > 250) {
			free(nb); free(nf);
			return NULL;
		}
		memcpy(currO, currI, fnd - currI);
		currO = currO + (fnd - currI);
		
		memcpy(fname, (char *)(fnd + 3), (int)fnd2 - (int)fnd - 2);
		fname[(int)fnd2 - (int)fnd - 3] = 0;

		ifp=fopen(fname, "r");
		if (ifp == NULL) {
			memcpy(currO, nofile, strlen(nofile));
			currO = currO + strlen(nofile);
		} else {
			fr = fread(nf, 1, MAX_STR_SIZE, ifp);
			memcpy(currO, nf, fr);
			currO = currO + fr;
			fclose(ifp);
		}
		
		currI = fnd2 + 1;
		fnd = strstr(currI, "\\I:");
	} while(fnd);

	memcpy(currO, currI, strlen(currI));
	currO[strlen(currI)] = 0;

	free(nf);
	return nb;
}


static char *EvaluateExpression(char *inp, int bAllocated) {
	int i, j, sl, l, reps, bExp, bMoreExp, biggestSl, slen;
	char nofrep[64], *nb = NULL, *oldnb = NULL, *subs, *in=inp;

	subs = malloc(MAX_STR_SIZE);
	if (!subs) return NULL;

	do {
		l=0;
		bExp = 0;
		bMoreExp = 0;
		biggestSl = 0;
		slen = strlen(in);
		for (i=0; i < slen; i++) {
			if (in[i]=='\\' && in[i+1]=='M') {
				bExp = 1;
				i+=2; j=0;
				while(in[i]>='0' && in[i]<='9' && in[i]!=0) {
					nofrep[j]=in[i];
					i++; j++;
				}
				nofrep[j]=0;
				reps = atoi(nofrep);
				if (in[i] == '{') {
					i++; sl=0;
					while(in[i]!='}' && in[i]!=0) {
						if (in[i]=='\\' && in[i+1]=='}')
							i++;
						sl++; i++;
					}
					l+=reps * sl;
					if (sl > biggestSl) biggestSl = sl;
				}			
			} else
				l++;
		}
	
		if (bExp && biggestSl < MAX_STR_SIZE) {
			oldnb = nb;
			nb = malloc(l + 1);
			l = 0;
			if (nb) {
				nb[0] = 0;
				slen = strlen(in);
				for (i=0; i < slen; i++) {
					if (in[i]=='\\' && in[i+1]=='M') {
						i+=2; j=0;
						while(in[i]>='0' && in[i]<='9' && in[i]!=0) {
							nofrep[j]=in[i];
							i++; j++;
						}
						nofrep[j]=0;
						reps = atoi(nofrep);
						if (in[i] == '{') {
							i++; sl=0;
							while(in[i]!='}' && in[i]!=0) {
								if (in[i]=='\\') {
									if (in[i+1]=='}')
										i++;
									if (in[i+1]=='M')
										bMoreExp=1;
								}
								subs[sl] = in[i];
								sl++; i++;
							}
							subs[sl]=0;
							nb[l] = 0;
							for (j=0; j < reps; j++)
								strcat(nb, subs);
							l+=reps * sl;
						}
					} else
						nb[l++] = in[i];
				}
				nb[l] = 0;
			}
			in = nb;
			if (oldnb) {
				free(oldnb);
			}
		}
	} while(bMoreExp && biggestSl < MAX_STR_SIZE);
	
	if (nb && bAllocated)
		free(inp);
	free(subs);
		
	return nb? nb : NULL;
}


typedef struct {
    int newmode;
} _startupinfo;

void __getmainargs(int *_Argc, char ***_Argv, char ***_Env,
		   int _DoWildCard, _startupinfo * _StartInfo);


// int main(int argc, char **oargv) {

int _main(void) {
	int argc;
	char **oargv = NULL;
	char **env;

#ifdef SUPPORT_EXTENDED	
	char verS[16] = " (extended)";
#else
	char verS[16] = "";
#endif
	
#ifdef SUPPORT_KEYCODES_CHECK
	char iH[128] = "\\L[:xx..;]: check for hex key xx,yy etc, don't wait; return keystate(s)\n";
#else
	char iH[128] = "";
#endif
	int ox = UNKNOWN, oy = UNKNOWN;
	int x, y, dummy;
	int orgConsoleCol = 0x7;
	int fgCol = 7, bgCol = 0, wrapxpos = 0;
	int flags = 0;
	unsigned char *u8buf = NULL;
	char ch;
	int keyret = 0;
	unsigned int startT;
	HANDLE h;
	int bServer = 0;
	char *ops = NULL;
	char **argv;
	char *tokArgs[10];

    _startupinfo start_info = { 0 };

    __getmainargs(&argc, &oargv, &env, 0, &start_info);
    if (oargv == NULL) {
		puts("Error getting parameters");
		ExitProcess(-2);
	}

	if (argc < 3 || argc > 8) {
		printf("\nGotoXY%s v1.1 : Mikael Sollenborn 2015-2020\n\nUsage: gotoxy x(1) y(1) [text|in.gxy] [fgcol(2)] [bgcol(2)] [flags(3)] [wrapx]\n" \
			"\nCols: 0=Black 1=Blue 2=Green 3=Aqua 4=Red 5=Purple 6=Yellow 7=LGray\n      8=Gray 9=LBlue 10=LGreen 11=LAqua 12=LRed 13=LPurple 14=LYellow 15=White\n" \
			"\n[text] supports control codes:\n    \\px;y;: cursor position x y (1)\n       \\xx: fgcol and bgcol in hex, eg \\A0 (4)\n        \\r: restore old color\n      \\gxx: ascii character in hex\n   \\TxxXXm: set character xx with col XX as transparent with mode m (5)\n        \\n: newline\n      \\Nxx: fill screen with hex character xx\n        \\-: skip character (transparent)\n        \\\\: print \\\n        \\G: print existing character at position\n  \\I:file;: insert contents of file\n      \\wx;: delay x ms\n      \\Wx;: delay up to x ms\n        \\K: wait for key press; last key value is returned\n%s        \\R: read/refresh buffer for v/V/Z/z/Y/X/\\G (faster but not updated)\n\\ox;y;w;h;: copy/write to offscreen buffer, copy back at end or next \\o\n\\Ox;y;w;h;: clear/write to offscreen buffer, copy back at end or next \\O\n    \\Mx{T}: repeat T x times (only if 'x' flag set)\n\\Sx;y;w;h;: set active scroll zone (only if 's' flag set)\n\n(1) Use 'k' to keep current. Precede with '+' or '/' to move from current\n\n(2) Use 'u/U' for console fgcol/bgcol, 'v/V' to use existing fgcol/bgcol at current position, 'x/y/z/q' and 'X/Y/Z/Q' to xor/and/or/add with fgcol/bgcol at current position. Precede with '-' to force color and ignore color codes in [text]\n\n(3) One or more of: 'r/c/C' to restore/follow/visibly-follow cursor position, 'w/W/z' to wrap/wordwrap/0-wrap text, 'i' to ignore all control codes, 's' to enable vertical scrolling, 'x' to enable support for expressions, F/T' to force input as file/text, 'n' to ignore newline characters, 'k' to check for key press(es) and return last key value, 'S' to enable (and disable) server mode\n\n(4) Same as (2) for both values, but '-' to force is not supported. In addition, use 'k' to keep current color, 'H/h' to start/stop forcing current color, '+' for next color, '/' for previous color\n\n(5) Use 'k' to ignore color, 'u/U' for console fgcol/bgcol. Mode 0 skips characters (same as \\-), mode 1 writes them back (faster if using \\R)\n", verS, iH);
		return keyret;
	}
	
	g_conout = h = GetOutputHandle();	

	argv = oargv;

	do {
		startT = GetTickCount();
		
		orgConsoleCol = 0x7;
		fgCol = 7, bgCol = 0, wrapxpos = 0; flags = 0;
		u8buf = NULL;		
		
		ch = argv[1][0];
		switch(ch) {
			case 'k':case '/':case '+': GetXY(h, &ox, &oy); x = ox; if (ch == '+') x += atoi(&(argv[1][1])); if (ch == '/') x -= atoi(&(argv[1][1])); break;
			default: x = atoi(argv[1]);
		}
		ch = argv[2][0];
		switch(ch) {
			case 'k':case '/':case '+': if (ox == UNKNOWN) GetXY(h, &ox, &oy); y = oy; if (ch == '+') y += atoi(&(argv[2][1])); if (ch == '/') y -= atoi(&(argv[2][1])); break;
			default: y = atoi(argv[2]);
		}
		
		if (argc > 6) {
			unsigned int i;
			int wxp;
			for (i=0; i < strlen(argv[6]); i++) {
				switch(argv[6][i]) {
				case 'w': flags |= F_WRAPSPRITE; break;
				case 'z': flags |= F_WRAP0; break;
				case 'W': flags |= F_WORDWRAP; break;
				case 's': flags |= F_YSCROLL; break;
				case 'i': flags |= F_IGNORECODES; break;
				case 'c': flags |= F_FOLLOWCURSOR; break;
				case 'C': flags |= F_FOLLOWCURSORVISIBLE | F_FOLLOWCURSOR; break;
				case 'r': flags |= F_RESTORECURSOR; break;
				case 'x': flags |= F_EVALUATEEXPRESSIONS; break;
				case 'F': flags |= F_FORCE_FILE_INPUT; break;
				case 'T': flags |= F_FORCE_TEXT_INPUT; break;
				case 'k': flags |= F_RETURN_KEY_INPUT; break;
				case 'n': flags |= F_IGNORE_NEWLINE_CHAR; break;
				case 'S': bServer = 1 - bServer; if (bServer && ops == NULL) { ops = (TCHAR *) malloc(sizeof(TCHAR) * MAX_SERVER_STRING_SIZE); setvbuf ( stdin , NULL , _IOLBF , MAX_SERVER_STRING_SIZE ); } break;
				}
			}
			wrapxpos = GetDim(h, DIM_WIDTH) - 1;
			if (argc > 7) {
				wxp = atoi(argv[7]);
				if (wxp >= x)
					wrapxpos = wxp;
			}
		}
		
		if (argc > 3) {
			int al=strlen(argv[3]);

			if ((flags & F_FORCE_FILE_INPUT) || (!(flags & F_FORCE_TEXT_INPUT) && al > 4 && argv[3][al-4]=='.' && tolower(argv[3][al-3])=='g' && tolower(argv[3][al-2])=='x' && tolower(argv[3][al-1])=='y')) {
				FILE *ifp;
				LPWSTR *szArglist = NULL;
				int nArgs;
				
				if (!bServer)
					szArglist = (LPWSTR *)CommandLineToArgvW(GetCommandLineW(), &nArgs);
				if( NULL == szArglist)
					ifp=fopen(argv[3], "r");
				else
					ifp=_wfopen(szArglist[3], L"r");

				if (ifp == NULL) {
					if (bServer)
						goto SERVER_FAULTY_LINE;
					printf("Error: file not found.\n");
					CloseHandle(g_conout);
					return -1;
				}
				u8buf = (unsigned char *)malloc(MAX_BUF_SIZE);
				if (u8buf) {
					int fr;
					fr=fread(u8buf, 1, MAX_BUF_SIZE, ifp);
					u8buf[fr]=0;
					fclose(ifp);
				}
				if (szArglist)
					LocalFree(szArglist);
			} 
	#ifdef SUPPORT_EXTENDED_ASCII_ON_CMD_LINE
			else { // ASCII characters over 127 (exteded Ascii) come as wrong values. Get/convert Unicode to IBM437 code page if such characters exist in string.
				   // Downside: exe files become slower even if not using Extended Ascii characters in the string (due to having to link extra lib).
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
							(char *)u8buf,
							MAX_BUF_SIZE,
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

		if (!(flags & F_RESTORECURSOR))
			GotoXY(h, x, y);

		orgConsoleCol = GetConsoleColor();
		fgCol = orgConsoleCol & 0xf;
		bgCol = (orgConsoleCol>>4) & 0xf;

		if (argc > 5) {
			int mul = 1;
			char *pfg = argv[5];
			if (*pfg=='-') { mul = -1; pfg++; }
			bgCol = (pfg[1]==0? GetCol(*pfg, bgCol, orgConsoleCol, &dummy) : atoi(pfg)) * mul;
			if (bgCol == 0 && mul < 1) bgCol = -16;
			if (bgCol > 15 && bgCol < USE_EXISTING_FG) bgCol = 0;
		}
		if (argc > 4) {
			int mul = 1;
			char *pfg = argv[4];
			if (*pfg=='-') { mul = -1; pfg++; }
			fgCol = (pfg[1]==0? GetCol(*pfg, fgCol, orgConsoleCol, &dummy) : atoi(pfg)) * mul;
			if (fgCol == 0 && mul < 1) fgCol = -16;
			if (fgCol > 15 && fgCol < USE_EXISTING_FG) fgCol = 0;
		}
		
		if (flags & F_EVALUATEEXPRESSIONS) {
			char *u8tmp = EvaluateExpression(u8buf? (char *)u8buf : (char *)argv[3], u8buf? 1:0);
			if (u8tmp) u8buf = (unsigned char *)u8tmp;
			}

		if (argc > 3) {
			char *u8tmp = InlineGxy(u8buf? (char *)u8buf : (char *)argv[3], u8buf? 1:0);
			if (u8tmp) u8buf = (unsigned char *)u8tmp;

			if (u8tmp && (flags & F_EVALUATEEXPRESSIONS)) {
				u8tmp = EvaluateExpression(u8buf? (char *)u8buf : (char *)argv[3], u8buf? 1:0);
				if (u8tmp) u8buf = (unsigned char *)u8tmp;
			}
		}

		if (argc > 3)
			keyret = WriteText(u8buf? u8buf : (unsigned char *)argv[3], fgCol, bgCol, &x, &y, flags, wrapxpos, orgConsoleCol, startT);
			
		if (flags & F_FOLLOWCURSOR) {
			GotoXY(h, x, y);
		}
		if (u8buf)
			free(u8buf);
		

SERVER_FAULTY_LINE:
		if (bServer) {
			char *input, *fndMe = NULL;

			do {
				input = fgets(ops, MAX_SERVER_STRING_SIZE-1, stdin); // this call blocks if there is no input
				if (input != NULL) {
					fndMe = strstr(input, "gotoxy:");
					if (!fndMe) {
						puts(input);
						fflush(stdout);
					}
				}
			} while (fndMe == NULL && input != NULL);

			if (input != NULL) {
				if (fndMe != NULL) {
					unsigned int i;
					char *token;
					int ast = 0;
					argc = 0;
					
					if (input[strlen(input) - 1] == '\n') input[strlen(input) - 1] = 0;
					if (input[strlen(input) - 1] == '\"') input[strlen(input) - 1] = 0;
					if (input[0] == '\"') input++;


					for (i = 0; i < strlen(input); i++) {
						if (input[i] == ' ' && ast) input[i] = 1;
						if (input[i] == '\"') { ast = 1 - ast; }
					}

					token = strtok(input, " ");
   
					while( token != NULL ) {
						if (token[strlen(token) - 1] == '\"') token[strlen(token) - 1] = 0;
						if (token[0] == '\"') token++;
						tokArgs[argc] = token;

						for (i = 0; i < strlen(token); i++)
							if (token[i] == 1) token[i] = ' ';
						
						token = strtok(NULL, " ");
						argc++;
					}
					argv = tokArgs;
					if (argc < 3 || argc > 8)
						goto SERVER_FAULTY_LINE;
				}
			} else {
				printf("\nGOTOXY: Client appears to have ended prematurely. Use 'S' flag to stop the server.\n\nExit server... Press a key.\n");
				getch();
				bServer = 0;
			}
		}
		
		
	} while (bServer);

	CloseHandle(g_conout);
	if (ops != NULL) free(ops);
	return keyret;
}
