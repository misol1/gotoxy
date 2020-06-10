/*

CmdWiz (c) 2015-20 Mikael Sollenborn (UNICODE VERSION)

Contributions:

Steffen Ilhardt: windowlist function, finding non-console windows for other window operations, original insertbmp function, original setwindowtransparency function, getexetype function

Carlos Montiers Aguilera : Original setfont function, original (legacy) fullscreen function, showmousecursor function

*/

#ifndef WINVER
#define WINVER 0x600
#endif
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x600
#endif

#define UNICODE

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <conio.h>
#include <shellapi.h>
#include <string.h>

#include <stdint.h>
#include <tchar.h>
#include <errno.h>
#include <tlhelp32.h>

// Compilation with gcc: gcc -o cmdwiz.exe cmdwizU.c -lwinmm -luser32 -lgdi32

// Known issues/bugs:
//			1. Showmousecursor hide does not work on Win10 (unless legacy console is used).
//			2. Setbuffersize has scroll bar cut off a number of character columns. Only Win10?
//			3. AsyncKeyState catches key presses even if console is not the active window. Use ReadConsoleInput instead?
//			4. getmouse etc does not report mouse wheel on Window10. Seems API related. Also on Win7 it is odd, because mouse wheel is reported but affects the coordinates too (bit overflow?)
//			5. Saveblock, copyblock/moveblock does not work with Unicode chars and/or extended Ascii chars. Even if saveblock worked with Unicode, gxy format does not currently support Unicode anyway.
//			6. utf-8 arguments are not supported
//			7. only way for fullscreen op to know if it supports Alt-enter, is to run fullscreen 1. Leads to annoying behavior when running fullscreen 0 on non-legacy console since fullscreen 1 is run first, then 0

#define BUFW 0
#define BUFH 1
#define SCRW 2
#define SCRH 3
#define CURRX 4
#define CURRY 5

#define INVALID_COORDINATE -999

// Undocumented functions and structures
// BEGIN
BOOL WINAPI SetConsoleFont(HANDLE hConsoleOutput, DWORD nFont);
// END

typedef BOOL(WINAPI * Func_SetCurrentConsoleFontEx) (HANDLE, BOOL, PCONSOLE_FONT_INFOEX);
typedef BOOL(WINAPI * Func_GetCurrentConsoleFontEx) (HANDLE, BOOL, PCONSOLE_FONT_INFOEX);

int WINAPI ShowConsoleCursor(HANDLE hConsoleOutput, BOOL bShow);

HANDLE g_conin, g_conout;

HANDLE GetInputHandle() {
	return CreateFile(L"CONIN$", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
}

HANDLE GetOutputHandle() {
	return CreateFile(L"CONOUT$", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
}

				
int GetDim(int dim) {
	int retVal;
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	GetConsoleScreenBufferInfo(g_conout, &screenBufferInfo);

	switch(dim) {
		case BUFW: retVal = screenBufferInfo.dwSize.X; break;
		case BUFH: retVal = screenBufferInfo.dwSize.Y; break;
		case SCRW: retVal = screenBufferInfo.srWindow.Right - screenBufferInfo.srWindow.Left + 1; break;
		case SCRH: retVal = screenBufferInfo.srWindow.Bottom - screenBufferInfo.srWindow.Top + 1; break;
		case CURRX: retVal = screenBufferInfo.srWindow.Left; break;
		case CURRY: retVal = screenBufferInfo.srWindow.Top; break;
	}
	return retVal;
}

void GetXY(int *x, int *y) {
	CONSOLE_SCREEN_BUFFER_INFO  csbInfo;
	GetConsoleScreenBufferInfo(g_conout, &csbInfo);
	if (x) *x = csbInfo.dwCursorPosition.X;
	if (y) *y = csbInfo.dwCursorPosition.Y;
}

#define CHARPROP_CHAR 1
#define CHARPROP_FGCOL 2
#define CHARPROP_BGCOL 3

#ifndef ENABLE_QUICK_EDIT_MODE
#define ENABLE_QUICK_EDIT_MODE 0x0040
#endif
#ifndef ENABLE_EXTENDED_FLAGS
#define ENABLE_EXTENDED_FLAGS 0x0080
#endif

int ReadCharProperty(int x, int y, int eProperty) {
	COORD a = { 1, 1 };
	COORD b = { 0, 0 };
	SMALL_RECT r;
	CHAR_INFO str[81];
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	char u8buf[8];

	GetConsoleScreenBufferInfo(g_conout, &screenBufferInfo);
	if (y > screenBufferInfo.dwSize.Y || y < 0) return INVALID_COORDINATE;
	if (x > screenBufferInfo.dwSize.X || x < 0) return INVALID_COORDINATE;

	r.Left = x;
	r.Top = y;
	r.Right = x + 1;
	r.Bottom = y + 1;
	ReadConsoleOutput(g_conout, str, a, b, &r);

	switch(eProperty) {
		case CHARPROP_FGCOL: return str[0].Attributes % 16;
		case CHARPROP_BGCOL: return (str[0].Attributes&255) / 16;
		default: 
			// with Unicode enabled, the ascii value for extended Ascii above 127 is incorrect unless converted
			WideCharToMultiByte( 
				CP_OEMCP,          // convert to ("extended AscII")
				0,
				&str[0].Char.UnicodeChar, // source UTF-16 string
				1,   // total source string length, in WCHAR’s, including end-of-string (so, should this be 2? seems to work fine with 1)
				u8buf,
				8,
				NULL, NULL
			);
		
			return u8buf[0];
		break;
	}
}

int InspectBuffer(HANDLE hSrc, int x, int y, int w, int h, int bExclusive, unsigned char *glyphs) {
	COORD a, b = {0,0};
	SMALL_RECT r;
	CHAR_INFO *str;
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
   int retVal = 0, i, j, k, l;

	GetConsoleScreenBufferInfo(hSrc, &screenBufferInfo);
	if (y > screenBufferInfo.dwSize.Y || y < 0) return -1;
	if (x > screenBufferInfo.dwSize.X || x < 0) return -1;
	if (y+h > screenBufferInfo.dwSize.Y || h < 1) return -1;
	if (x+w > screenBufferInfo.dwSize.X || w < 1) return -1;
	
	if (w == 0 || h == 0)
		return -1;
	
	if (bExclusive)
		retVal = 1;
	
	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * w*h);
	if (!str)
		return -1;

	a.X = w;
	a.Y = h;

	r.Left = x;
	r.Top = y;
	r.Right = x + w;
	r.Bottom = y + h;
	ReadConsoleOutput(hSrc, str, a, b, &r);

	for (i = 0; i < h; i++)
		for (j = 0; j < w; j++) {
			if (bExclusive) {
				l = 0; k = 0;
				while(glyphs[k] != 0) {
					if (glyphs[k] == str[i*w+j].Char.AsciiChar) {
						l = 1;
						break;
					}
					k++;
				}
				if (l==0) {
					free(str);
					return 0;
				}
			} else {
				k = 0; l = 1;
				while(glyphs[k] != 0) {
					if (glyphs[k] == str[i*w+j].Char.AsciiChar) {
						retVal |= l;
					}
					l = l << 1;
					k++;
				}
			}
		}	
	
	free(str);
	return retVal;
}

char DecToHex(int i) {
	switch(i) {
	case 0:case 1:case 2:case 3:case 4:case 5:case 6:case 7:case 8:case 9: i=i+'0'; break;
	case 10:case 11:case 12:case 13:case 14:case 15: i = 'A'+(i-10); break;
	default: i = '0';
	}
	return i;
}


/* Windows ns high-precision sleep */
BOOLEAN nanosleep(LONGLONG ns){
    HANDLE timer;
    LARGE_INTEGER li;

    if(!(timer = CreateWaitableTimer(NULL, TRUE, NULL)))
        return FALSE;
    li.QuadPart = -ns;
    if(!SetWaitableTimer(timer, &li, 0, NULL, NULL, FALSE)){
        CloseHandle(timer);
        return FALSE;
    }
    WaitForSingleObject(timer, INFINITE);
    CloseHandle(timer);
    return TRUE;
}

BOOLEAN millisleep(LONGLONG ms){
	return nanosleep(ms * 10000);
}

long long milliseconds_now(void) {
	static LARGE_INTEGER s_frequency;
	static BOOL s_use_qpc;

	s_use_qpc = QueryPerformanceFrequency(&s_frequency);
	if (s_use_qpc) {
		LARGE_INTEGER now;
		QueryPerformanceCounter(&now);
		return (1000LL * now.QuadPart) / s_frequency.QuadPart;
	} else {
		return GetTickCount();
	}
}


void GotoXY(HANDLE h, int x, int y) {
	COORD coord;
	BOOL res;
	if (x < 0) x = 0;
	if (y < 0) y = 0;
	coord.X = x;
	coord.Y = y;
	res = SetConsoleCursorPosition(h, coord);
	if (res == 0) {
		int mX, mY;
		mX = GetDim(BUFW);
		if (coord.X >= mX) coord.X = mX-1;
		mY = GetDim(BUFH);
		if (coord.Y >= mY) coord.Y = mY-1;
		SetConsoleCursorPosition(h, coord);
	}
}

char *GetAttribs(WORD attributes, char *utp, int transpChar, int transpBg, int transpFg) {
	int i;
	utp[0] = '\\';
	utp[1] = DecToHex(attributes & 0xf); if ((attributes & 0xf)==transpFg && transpChar < 0) utp[1]='v';
	utp[2] = DecToHex((attributes >> 4) & 0xf); if (((attributes>>4) & 0xf)==transpBg && transpChar < 0) utp[2]='V';
	utp[3] = 0;
	return utp;
}

#define BUF_SIZE 64000
#define STR_SIZE 12000

int SaveBlock(TCHAR *filename, int x, int y, int w, int h, int bEncode, int transpChar, int transpBg, int transpFg) {
	COORD a = { 1, 1 };
	COORD b = { 0, 0 };
	SMALL_RECT r;
	CHAR_INFO *str;
	char *output;
	char attribS[16], charS[8];
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	WORD oldAttrib = 6666;
	FILE *ofp = NULL;
	int i, j;
	unsigned char ch;
	TCHAR fName[512];
	int outSize;
	char u8buf[8];
	
	if (bEncode == 3)
		swprintf(fName, 500, L"%s.txt", filename);
	else
		swprintf(fName, 500, L"%s.gxy", filename);
	ofp = _wfopen(fName, L"w");
	if (!ofp) return 1;

	GetConsoleScreenBufferInfo(g_conout, &screenBufferInfo);
	if (y > screenBufferInfo.dwSize.Y || y < 0) return 2;
	if (x > screenBufferInfo.dwSize.X || x < 0) return 2;
	if (y+h > screenBufferInfo.dwSize.Y || h < 1) return 2;
	if (x+w > screenBufferInfo.dwSize.X || w < 1) return 2;

	outSize = 10 * w*h;
	output = (char*) malloc(outSize);
	if (!output) return 3;
	output[0] = 0;
	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * w*h);
	if (!str) {
		free(output);
		return 3;
	}

	a.X = w;
	a.Y = h;
/*
	r.Left = x;
	r.Top = y;
	r.Right = x + w;
	r.Bottom = y + h;
	ReadConsoleOutput(g_conout, str, a, b, &r);
*/
	
	// Stupid bug in ReadConsoleOutput doesn't seem to read more than ~15680 chars, then it's all garbled characters!! Have to read in smaller blocks
	{
		int i, j, k, l;
		l = 15000 / w;
		i = h / l;
		for (j = 0; j <= i; j++) {
			r.Left = x;
			r.Top = j*l+y;
			r.Right = w+x;
			if (i == j) k = h % l; else k = l;
			r.Bottom = j*l+k+y;
			a.X = w;
			a.Y = k;
			ReadConsoleOutput(g_conout, str+j*l*w, a, b, &r);
		}
	}	
	
	for (j=0; j < h; j++) {
		output[0]=0;
		for (i=0; i < w; i++) {
			
			// ch = str[i + j*w].Char.AsciiChar; // this character is NOT correct due to compiling with UNICODE.
			
				// Instead, we need to call WideCharToMultiByte *for every char* :(
			WideCharToMultiByte( 
				CP_OEMCP,	// convert to IBM437 ("extended AscII")
				0,			// conversion behavior
				&str[i + j*w].Char.UnicodeChar, // source UTF-16 string
				1,       // total source string length, in WCHAR’s, including end-of-string (so, should this be 2? seems to work fine with 1)
				u8buf,
				8,
				NULL, NULL
			);
			ch = u8buf[0];
			
			if ((ch==transpChar && transpChar >-1) && (transpFg == -1 || transpFg == (str[i + j*w].Attributes & 0xf))  && (transpBg == -1 || transpBg == ((str[i + j*w].Attributes>>4) & 0xf)) ) {
				charS[0] = '\\'; charS[1]='-'; charS[2]=0;
			} else if (bEncode == 3) {
				charS[0] = ch; charS[1]=0;
			}
			else if (bEncode || ch=='\\') {
				if (bEncode > 1 || !(ch ==32 || (ch >='0' && ch <='9') || (ch >='A' && ch <='Z') || (ch >='a' && ch <='z'))) {
					int v;
					charS[0] = '\\'; charS[1] = 'g';
					v = ch / 16; charS[2]=DecToHex(v);
					v = ch % 16; charS[3]=DecToHex(v);
					charS[4]=0;
				}else {
					charS[0] = ch; charS[1]=0;
				}
			} else {
				charS[0] = ch; charS[1]=0;
			}
			if (oldAttrib == str[i + j*w].Attributes || bEncode == 3)
				sprintf(output, "%s%s", output, charS);
			else
				sprintf(output, "%s%s%s", output, GetAttribs(str[i + j*w].Attributes, attribS, transpChar, transpBg, transpFg), charS);
			oldAttrib = str[i + j*w].Attributes;
		}
		if (bEncode == 3) fprintf(ofp, "%s\n", output); else fprintf(ofp, "%s\\n", output);
	}

	free(str);
	free(output);

	fclose(ofp);
	return 0;
}


int CopyBlock(int x, int y, int w, int h, int dx, int dy) {
	COORD a = { 1, 1 };
	COORD b;
	SMALL_RECT r;
	CHAR_INFO *str;
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;

	GetConsoleScreenBufferInfo(g_conout, &screenBufferInfo);
	if (y > screenBufferInfo.dwSize.Y || y < 0) return -1;
	if (x > screenBufferInfo.dwSize.X || x < 0) return -1;
	if (y+h > screenBufferInfo.dwSize.Y || h < 1) return -1;
	if (x+w > screenBufferInfo.dwSize.X || w < 1) return -1;

	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * STR_SIZE);
	if (!str)
		return -2;

	b.X = 0;
	b.Y = 0;

	a.X = w;
	a.Y = h;

	r.Left = x;
	r.Top = y;
	r.Right = x + w;
	r.Bottom = y + h;
	ReadConsoleOutput(g_conout, str, a, b, &r);

	r.Left = dx;
	r.Top = dy;
	r.Right = dx + w;
	r.Bottom = dy + h;  
	WriteConsoleOutput(g_conout, str, a, b, &r);

	free(str);
	return 0;
}


int MouseEventProc(MOUSE_EVENT_RECORD mer, int bKeyAndMouse, TCHAR *output) {
	int res = 0;
	if (bKeyAndMouse)
		res = (mer.dwMousePosition.X << 7) | (mer.dwMousePosition.Y << 15);
	else
		res = (mer.dwMousePosition.X << 10) | (mer.dwMousePosition.Y << 21);

	switch(mer.dwEventFlags) {
		case 0: case DOUBLE_CLICK: case MOUSE_MOVED:
			//printf("GOT: %d %d\n",mer.dwButtonState, mer.dwEventFlags);
			if(mer.dwButtonState & FROM_LEFT_1ST_BUTTON_PRESSED) {
				res |= 2;
				if (mer.dwEventFlags == DOUBLE_CLICK)
					res |= 8;
			}
			if(mer.dwButtonState & RIGHTMOST_BUTTON_PRESSED) {
				res |= 4;
				if (mer.dwEventFlags == DOUBLE_CLICK)
					res |= 16;
			}
			break;
		case MOUSE_WHEELED:
			if ((int)mer.dwButtonState < 0)
				res |= 32;
			else
				res |= 64;
			break;
		default:
			break;
	}
	
	if (bKeyAndMouse) res |= 1;
	
	swprintf(output, 255, L"MOUSE_EVENT 1 MOUSE_X %d MOUSE_Y %d LEFT_BUTTON %d RIGHT_BUTTON %d LEFT_DOUBLE_CLICK %d RIGHT_DOUBLE_CLICK %d MOUSE_WHEEL %d",
							mer.dwMousePosition.X, mer.dwMousePosition.Y, (res & 2)>0, (res & 4)>0, (res & 8)>0, (res & 16)>0, (res & 32)>0? 1: (res & 64)>0? -1 : 0);

	return res;
}


void printKeystates(int keys, int nofKeys) {
	int i, check = 1;
	char output[1024] = "";
	
	for (i = 0; i < nofKeys; i++) {
		if (keys & check)
			strcat(output, "1 ");
		else
			strcat(output, "0 ");
		check = check << 1;
	}
	
	printf("%s\n", output);
}


#define TERMINAL_FONTS 10
int SetFont(int index) {
	HANDLE hOut;
	COORD terminal_font[TERMINAL_FONTS] = { {4, 6}, {6, 8}, {8, 8}, {16, 8}, {5, 12}, {7, 12}, {8, 12}, {16, 12}, {12, 16}, {10, 18}};

	if ((index < 0) || (index >= TERMINAL_FONTS)) {
		return 1;
	}

	hOut = g_conout;

	HINSTANCE dllHandle = LoadLibraryW(L"KERNEL32.DLL");

	if (NULL != dllHandle) {
		Func_SetCurrentConsoleFontEx
		SetCurrentConsoleFontEx_Ptr =
		(Func_SetCurrentConsoleFontEx)
		GetProcAddress(dllHandle, "SetCurrentConsoleFontEx");

	    if (NULL != SetCurrentConsoleFontEx_Ptr) {	//vista
			CONSOLE_FONT_INFOEX font_info;

			font_info.cbSize = sizeof(CONSOLE_FONT_INFOEX);
			font_info.nFont = index;
			font_info.dwFontSize.X = terminal_font[index].X;
			font_info.dwFontSize.Y = terminal_font[index].Y;
			font_info.FontFamily = 48;
			font_info.FontWeight = 400;
			wcscpy(font_info.FaceName, L"Terminal");

			SetCurrentConsoleFontEx_Ptr(hOut, FALSE, &font_info);
		}
		FreeLibrary(dllHandle);
	}

	COORD c=GetConsoleFontSize(hOut, 0); //printf("%d %d\n",c.X,c.Y);
	if (c.X==1 && c.Y==1) index+=3; // assume pixelfnt.exe has been run and is resident

	SetConsoleFont(hOut, index);
	CloseHandle(hOut);
	
	return 0;
}


int GetFont(PCONSOLE_FONT_INFOEX font_info) {
	int ret = 1;
	HINSTANCE dllHandle = LoadLibraryW(L"KERNEL32.DLL");

	if (NULL != dllHandle) {
		Func_GetCurrentConsoleFontEx GetCurrentConsoleFontEx_Ptr = (Func_GetCurrentConsoleFontEx) GetProcAddress(dllHandle, "GetCurrentConsoleFontEx");

		if (NULL != GetCurrentConsoleFontEx_Ptr) {	//vista
			font_info->cbSize = sizeof(CONSOLE_FONT_INFOEX); // must set this manually, otherwise GetCurrentConsoleFontEx fails with error 87(bad params). Weird.
			ret = GetCurrentConsoleFontEx_Ptr(g_conout, FALSE, font_info);
			ret = 1 - ret;
		}
		FreeLibrary(dllHandle);
	}
		
	return ret;
}

int SetFontFromFile(TCHAR *fname) {
	HINSTANCE dllHandle = LoadLibraryW(L"KERNEL32.DLL");
	CONSOLE_FONT_INFOEX font_info;
	int ret = 1;
	FILE*ifp;
	
	ifp = _wfopen(fname, L"rb");
	if (!ifp) { printf("Error: Could not load font\n"); return ret; }
	fread(&font_info, sizeof(CONSOLE_FONT_INFOEX), 1, ifp);
	fclose(ifp);
	
	if (NULL != dllHandle) {
		Func_SetCurrentConsoleFontEx SetCurrentConsoleFontEx_Ptr = (Func_SetCurrentConsoleFontEx) GetProcAddress(dllHandle, "SetCurrentConsoleFontEx");

		if (NULL != SetCurrentConsoleFontEx_Ptr) {	//vista
			ret = SetCurrentConsoleFontEx_Ptr(g_conout, FALSE, &font_info);
			ret = 1 - ret;
			SetConsoleFont(g_conout, font_info.nFont);
		}
	}
			
	FreeLibrary(dllHandle);
	return ret;
}


void evaluateCol(char ch, int *bUsesColors, int *bUsesExtendedColor, int *bUsesUnknownCode) {
	switch(ch) {
		case '0':case '1':case '2':case '3':case '4':case '5':case '6':case '7':case '8':case '9':case 'u':case 'U': case 'k':
		case 'a':case 'A':case 'b':case 'B':case 'c':case 'C':case 'd':case 'D':case 'e':case 'E':case 'f':case 'F':
		{
			*bUsesColors=1;
			break;
		}
		case 'v':case 'V':case 'x':case 'X':case 'y':case 'Y':case 'z':case 'Z':case 'q':case 'Q':case 'h':case 'H':
		case '+':case '/':
		{
			*bUsesExtendedColor=1;
			break;
		}				
		default: {
			*bUsesUnknownCode=1;
		}	
	}
}

int getFileDim(TCHAR *fname) {
	unsigned long b4;
	unsigned short b2;
	FILE *ifp;
	int w=-1, h=-1;

	ifp=_wfopen(fname, L"rb");
	if (ifp == NULL) {
		wprintf(TEXT("Error: file not found\n"));
		//wprintf(TEXT("Error: file not found: %s\n"), fname);
		return 1;
	}
	
	if (wcsstr(fname, L".bmp") != NULL) {
		fseek(ifp, 18, SEEK_CUR);
		fread(&b4, 4, 1, ifp); w = b4;
		fread(&b4, 4, 1, ifp); h = b4;
	}
	else if (wcsstr(fname, L".bxy") != NULL) {
		fread(&b4, 4, 1, ifp); w = b4;
		fread(&b4, 4, 1, ifp); h = b4;
	}
	else if (wcsstr(fname, L".pcx") != NULL) {
		fseek(ifp, 8, SEEK_CUR);
		fread(&b2, 2, 1, ifp); w = b2+1;
		fread(&b2, 2, 1, ifp); h = b2+1;
	}

	fclose(ifp);
	if (w != -1 && h != -1) {
		printf("\nDimension: %d x %d\n\n", w, h);
		return 0;
	}
	
	return -1;
}


int inspectGxy(TCHAR *fname, int bIgnoreCodes) {
	char ch, *text;
	int fr, i, inlen, maxW=-1, maxH=-1;
	int x=0, y=0;
	int bUsesColors=0, bUsesExtendedCode=0, bUsesExtendedColor=0, bHasTransparency=0, bUsesUnknownCode=0, bUsesCodes=0, bMeaninglessSize=0, bKeyWait=0, bHasDelay=0;
	int bLastNewline=0;
	FILE *ifp;

	ifp=_wfopen(fname, L"r");
	if (ifp == NULL) {
		return 1;
	}
	
	text = (char *)malloc(5000 * 5000);
	if (text == NULL)
		return 2;

	fr = fread(text, 1, 5000 * 5000, ifp);
	text[fr] = 0;
	fclose(ifp);
	
	inlen = strlen(text);
	
	for(i = 0; i < inlen; i++) {
		ch = text[i];
		bLastNewline=0;
		
		if (ch == '\\' && !bIgnoreCodes) {
			i++;
			ch = text[i];
			bUsesCodes = 1;

			switch(ch) {
				case '-': {
					bHasTransparency = 1;
					x++;
					break;
				}
				case 'g': {
					i+=2;
					x++;
					break;
				}
				case '\\': {
					x++;
					break;
				}
				case 'r': {
					break;
				}
				case 'n': {
					if (x > maxW) maxW = x;
					x = 0; y++;
					bLastNewline=1;
					break;
				}
				
				case 'T': {
					i+=5;
					bUsesExtendedCode=1;
					bHasTransparency = 1;
					break;
				}
				
				case 'R': {
					bUsesExtendedCode=1;
					break;
				}
				case 'K': {
					bUsesExtendedCode=1;
					bKeyWait=1;
					break;
				}
				case 'p': case 'N': case 'I': case 'M': case 'o' : case 'O': case 'S': {
					bUsesExtendedCode=1;
					bMeaninglessSize=1;
					break;
				}
				case 'G' : {
					bUsesExtendedCode=1;
					x++;
					break;
				}
				case 'w' : case 'W': {
					bUsesExtendedCode=1;
					bHasDelay=1;
					while(i < inlen && text[i] != ';')
						i++;
					break;
				}
				
				//color
				case '0':case '1':case '2':case '3':case '4':case '5':case '6':case '7':case '8':case '9':case 'u':case 'U': case 'k':
				case 'a':case 'A':case 'b':case 'B':case 'c':case 'C':case 'd':case 'D':case 'e':case 'E':case 'f':case 'F':
				{
					bUsesColors=1;
					i++;
					evaluateCol(text[i], &bUsesColors, &bUsesExtendedColor, &bUsesUnknownCode);
					break;
				}
				
				case 'v':case 'V':case 'x':case 'X':case 'y':case 'Y':case 'z':case 'Z':case 'q':case 'Q':case 'h':case 'H':
				case '+':case '/':
				{
					bUsesExtendedColor=1;
					i++;
					evaluateCol(text[i], &bUsesColors, &bUsesExtendedColor, &bUsesUnknownCode);
					break;
				}				
				
				default: {
					bUsesUnknownCode=1;
					i++;
					evaluateCol(text[i], &bUsesColors, &bUsesExtendedColor, &bUsesUnknownCode);
				}
			}
		} else {
			if (y >= 5000) break;
			
			if (ch == 10) {
				if (x > maxW) maxW = x;
				x = 0; y++;
				bLastNewline=1;
			} else {
				x++;
			}
		}
	}
	
//	if (!bLastNewline || bIgnoreCodes)
		y++;
	maxH = y;
	if (x > maxW) maxW = x;

	printf("\n");
	if (!bMeaninglessSize)
		printf("Dimension: %d x %d\n\n", maxW, maxH);
	else
		printf("Unknown dimensions due to use of one or more of: \\p, \\N, \\I, \\M, \\o, \\O, \\S\n\n");

	if (bUsesUnknownCode)
		printf("! Unknown/faulty control codes: Yes\n");
	if (bUsesCodes)
		printf("Control codes: Yes\n");
	else if (!bIgnoreCodes)
		printf("No control codes (no \\ characters)\n");
	if (bUsesExtendedCode)
		printf("Extended control codes (gotoxy only): Yes\n");
	if (bUsesColors)
		printf("Color codes: Yes\n");
	if (bUsesExtendedColor)
		printf("Extended color codes (gotoxy only): Yes\n");
	if (bHasTransparency)
		printf("Transparency: Yes\n");
	if (bKeyWait)
		printf("Key press(es): Yes\n");
	if (bHasDelay)
		printf("Delay(s): Yes\n");
	
	if (!bIgnoreCodes)
		printf("\n");
	
	free(text);

	return 0;
}



typedef struct tag_CALLBACKDATA
{
  HWND hwnd;
  DWORD pid;
  DWORD tid;
  TCHAR *title;
  TCHAR name[MAX_PATH];
} CALLBACKDATA;

BOOL PnameToPid(CALLBACKDATA *const pData);
BOOL PidToPname(CALLBACKDATA *const pData);
BOOL CALLBACK EnumWindowsListCallback(HWND hwnd, LPARAM lParam);
BOOL CALLBACK EnumWindowsPIDCallback(HWND hwnd, LPARAM lParam);
BOOL CALLBACK EnumWindowsTIDCallback(HWND hwnd, LPARAM lParam);
BOOL CALLBACK EnumWindowsTitleCallback(HWND hwnd, LPARAM lParam);
void PrintData(const CALLBACKDATA *const pData);

int bPrintEmptyTitleWindows = 1;

HWND GetWinHandle(TCHAR *in)
{
  CALLBACKDATA data = {0};
  uint64_t uptr = 0;
  TCHAR *endptr = NULL;

  if (wcslen(in) < 4 || in[0] != '/' || in[2] != ':' )
	  return NULL;
  
  switch((int)_totupper(in[1]))
  {
    case 'H':
      errno = 0;
      uptr = _wcstoui64(&in[3], &endptr, 16);
      if (errno == 0 && *endptr == 0 && (ULONG_PTR)uptr == uptr)
      {
        data.hwnd = (HWND)(ULONG_PTR)uptr;
        data.tid = GetWindowThreadProcessId(data.hwnd, &(data.pid));
        LRESULT length = SendMessage(data.hwnd, WM_GETTEXTLENGTH, 0, 0);
        if (!GetWindow(data.hwnd, GW_OWNER) && PidToPname(&data) && (data.title = (TCHAR*)calloc(length + 1, sizeof(TCHAR))))
        {
			free(data.title);
			return data.hwnd;
        }
      }
      break;	  
    case 'N':
      wcscpy(data.name, &in[3]);
      if (PnameToPid(&data))
      {
        EnumWindows(EnumWindowsPIDCallback, (LPARAM)&data);
        if (data.hwnd)
        {
			free(data.title);
			return data.hwnd;
        }
      }
      break;
    case 'P':
      errno = 0;
      data.pid = wcstoul(&in[3], &endptr, 0);
      if (errno == 0 && *endptr == 0)
      {
        EnumWindows(EnumWindowsPIDCallback, (LPARAM)&data);
        if (data.hwnd && PidToPname(&data))
        {
			free(data.title);
			return data.hwnd;
        }
      }
      break;
    case 'T':
      errno = 0;
      data.tid = wcstoul(&in[3], &endptr, 0);
      if (errno == 0 && *endptr == 0)
      {
        EnumWindows(EnumWindowsTIDCallback, (LPARAM)&data);
        if (data.hwnd && PidToPname(&data))
        {
			free(data.title);
			return data.hwnd;
        }
      }
      break;
    case 'W':
      if (in[3])
      {
        data.title = &in[3];
        EnumWindows(EnumWindowsTitleCallback, (LPARAM)&data);
        if (data.hwnd && PidToPname(&data))
        {
		  return data.hwnd;
        }
      }
      break;
  }

  return NULL;
}

BOOL PnameToPid(CALLBACKDATA *const pData)
{
  HANDLE hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  PROCESSENTRY32 procentry = {0};
  procentry.dwSize = sizeof(PROCESSENTRY32);
  pData->pid = 0;

  if (Process32First(hProcessSnap, &procentry))
  {
    do
    {
      if (wcsicmp(procentry.szExeFile, pData->name) == 0)
      {
        pData->pid = procentry.th32ProcessID;
        wcscpy(pData->name, procentry.szExeFile);
      }
    } while (pData->pid == 0 && Process32Next(hProcessSnap, &procentry));
  }

  if (hProcessSnap != INVALID_HANDLE_VALUE)
    CloseHandle(hProcessSnap);

  if (pData->pid == 0)
    return FALSE;

  return TRUE;
}

BOOL PidToPname(CALLBACKDATA *const pData)
{
  HANDLE hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  PROCESSENTRY32 procentry = {0};
  procentry.dwSize = sizeof(PROCESSENTRY32);
  *(pData->name) = 0;

  if (Process32First(hProcessSnap, &procentry))
  {
    do
    {
      if (pData->pid == procentry.th32ProcessID)
        wcscpy(pData->name, procentry.szExeFile);
    } while (*(pData->name) == 0 && Process32Next(hProcessSnap, &procentry));
  }

  if (hProcessSnap != INVALID_HANDLE_VALUE)
    CloseHandle(hProcessSnap);

  if (*(pData->name) == 0)
    return FALSE;

  return TRUE;
}

BOOL CALLBACK EnumWindowsListCallback(HWND hwnd, LPARAM lParam)
{
  CALLBACKDATA *pData = (CALLBACKDATA*)lParam;
  LRESULT length = 0, lres;
  pData->hwnd = hwnd;
  pData->tid = GetWindowThreadProcessId(hwnd, &(pData->pid));
  lres = SendMessageTimeout(hwnd, WM_GETTEXTLENGTH, 0, 0, SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_ERRORONEXIT, 2000u, &length);
//  LRESULT length = SendMessage(hwnd, WM_GETTEXTLENGTH, 0, 0);
  if (!GetWindow(hwnd, GW_OWNER) && PidToPname(pData) && lres > 0 && (length>0 || bPrintEmptyTitleWindows) && (pData->title = (TCHAR*)calloc(length + 1, sizeof(TCHAR))))
  {
    SendMessageTimeout(hwnd, WM_GETTEXT, length + 1, (LPARAM)pData->title, SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_ERRORONEXIT, 2000u, NULL);
    PrintData(pData);
    free(pData->title);
  }

  return TRUE;
}

BOOL CALLBACK EnumWindowsPIDCallback(HWND hwnd, LPARAM lParam)
{
  CALLBACKDATA *pData = (CALLBACKDATA*)lParam;
  LRESULT length = 0, lres;
  static DWORD process_id = 0;
  pData->tid = GetWindowThreadProcessId(hwnd, &process_id);
  if (pData->pid == process_id && !GetWindow(hwnd, GW_OWNER))
  {
    pData->hwnd = hwnd;
    pData->title = NULL;
	lres = SendMessageTimeout(hwnd, WM_GETTEXTLENGTH, 0, 0, SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_ERRORONEXIT, 2000u, &length);
//    LRESULT length = SendMessage(hwnd, WM_GETTEXTLENGTH, 0, 0);
    if (lres > 0 && (pData->title = (TCHAR*)calloc(length + 1, sizeof(TCHAR))))
      SendMessageTimeout(hwnd, WM_GETTEXT, length + 1, (LPARAM)pData->title, SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_ERRORONEXIT, 2000u, NULL);

    return FALSE;
  }

  return TRUE;
}

BOOL CALLBACK EnumWindowsTIDCallback(HWND hwnd, LPARAM lParam)
{
  CALLBACKDATA *pData = (CALLBACKDATA*)lParam;
  static DWORD thread_id = 0;
  LRESULT length = 0, lres;
  thread_id = GetWindowThreadProcessId(hwnd, &(pData->pid));
  if (pData->tid == thread_id && !GetWindow(hwnd, GW_OWNER))
  {
    pData->hwnd = hwnd;
    pData->title = NULL;
//    LRESULT length = SendMessage(hwnd, WM_GETTEXTLENGTH, 0, 0);
	lres = SendMessageTimeout(hwnd, WM_GETTEXTLENGTH, 0, 0, SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_ERRORONEXIT, 2000u, &length);
    if (lres > 0 && (pData->title = (TCHAR*)calloc(length + 1, sizeof(TCHAR))))
      SendMessageTimeout(hwnd, WM_GETTEXT, length + 1, (LPARAM)pData->title, SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_ERRORONEXIT, 2000u, NULL);

    return FALSE;
  }

  return TRUE;
}

BOOL CALLBACK EnumWindowsTitleCallback(HWND hwnd, LPARAM lParam)
{
  CALLBACKDATA *pData = (CALLBACKDATA*)lParam;
  static TCHAR *tmp = NULL;
  LRESULT length = 0, lres;

//  LRESULT length = SendMessage(hwnd, WM_GETTEXTLENGTH, 0, 0);
  lres = SendMessageTimeout(hwnd, WM_GETTEXTLENGTH, 0, 0, SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_ERRORONEXIT, 2000u, &length);

  if (length && lres > 0 && (tmp = (TCHAR*)malloc((length + 1) * sizeof(TCHAR))))
  {
    if (SendMessageTimeout(hwnd, WM_GETTEXT, length + 1, (LPARAM)tmp, SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_ERRORONEXIT, 2000u, NULL) != 0
        && wcscmp(tmp, pData->title) == 0
        && !GetWindow(hwnd, GW_OWNER))
    {
      pData->hwnd = hwnd;
      pData->tid = GetWindowThreadProcessId(hwnd, &(pData->pid));
      free(tmp);
      return FALSE;
    }
    free(tmp);
  }

  return TRUE;
}

void PrintData(const CALLBACKDATA *const pData)
{
	wprintf(TEXT("%p|%lu|%lu|%s|%s\n"), pData->hwnd, pData->pid, pData->tid, pData->name, pData->title ? pData->title : TEXT(""));
}


BOOL f_SetConsoleTransparency(long percentage, TCHAR *winInfo)
{
	HWND hWnd = NULL;
	BYTE bAlpha = 0;
	LONG lNewLong = 0;
	hWnd = GetConsoleWindow();
	
	if (winInfo) {
		hWnd = GetWinHandle(winInfo);
		if (!hWnd) {
			puts("Error: Could not find specified window");
			return FALSE;
		}
	}
	
	if (hWnd && percentage > -1 && percentage < 101)
	{
		bAlpha = (BYTE)(2.55 * (100 - percentage) + 0.5);
		lNewLong = GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED;
		if (!SetWindowLong(hWnd, GWL_EXSTYLE, lNewLong)) return FALSE;
		return SetLayeredWindowAttributes(hWnd, 0, bAlpha, LWA_ALPHA);
	}
	return FALSE;
}


int Fn_LoadBmp(TCHAR *szBmpPath, long x, long y, long z, long w, long h, DWORD dwRop, HWND hWnd)
{
	HDC hDc = NULL, hDcBmp = NULL;
	HBITMAP hBmp1 = NULL, hBmp2 = NULL;
	HGDIOBJ hGdiObj = NULL;
	BITMAP bmp = {0};
	int iRet = EXIT_FAILURE;

	if ((hDc = GetDC(hWnd)))
	{
		if ((hDcBmp = CreateCompatibleDC(hDc)))
		{
			if ((hBmp1 = (HBITMAP)LoadImage(NULL, szBmpPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE)))
			{
				if (GetObject(hBmp1, sizeof(bmp), &bmp))
				{
					if (w == -1) {
						if ((w = bmp.bmWidth * z / 100.0 + 0.5) <= 0 || (h = bmp.bmHeight * z / 100.0 + 0.5) <= 0)
						{
							w = bmp.bmWidth;
							h = bmp.bmHeight;
						}
					} 
					if ((hBmp2 = (HBITMAP)CopyImage((HANDLE)hBmp1, IMAGE_BITMAP, w, h, LR_COPYDELETEORG)))
					{
						if ((hGdiObj = SelectObject(hDcBmp, hBmp2)) && hGdiObj != HGDI_ERROR)
						{
							if (BitBlt(hDc, (int)x, (int)y, (int)w, (int)h, hDcBmp, 0, 0, dwRop))
								iRet = EXIT_SUCCESS;
							DeleteObject(hGdiObj);
						}
						DeleteObject(hBmp2);
					}
				}
				DeleteObject(hBmp1);
			}
			ReleaseDC(hWnd, hDcBmp);
		}
		ReleaseDC(hWnd, hDc);
		ReleaseDC(hWnd, hDc);
	}
	return iRet;
}

/*
void DrawSemiTransparentBitmap(CDC *pDstDC, int x, int y, int nWidth, int nHeight,
    CDC* pSrcDC, int xSrc, int ySrc)
{
    CDC dcCompatible;
    CBitmap *pBitmapOld;
    CBitmap bm;
    dcCompatible.CreateCompatibleDC(pDstDC);
    bm.CreateCompatibleBitmap(pDstDC, nWidth, nHeight);
    pBitmapOld = dcCompatible.SelectObject(&bm);
    dcCompatible.FillSolidRect(CRect(0, 0, nWidth, nHeight), RGB(0x7F, 0x7F, 0x7F));
    pDstDC->BitBlt(x, y, nWidth, nHeight, &dcCompatible, 0, 0, SRCAND);
    dcCompatible.SelectObject(pBitmapOld);
    pDstDC->BitBlt(x, y, nWidth, nHeight, pSrcDC, 0, 0, SRCPAINT);
}
*/


TCHAR **argv;

int clean(int returnValue) { 
	CloseHandle(g_conin);
	CloseHandle(g_conout);
	LocalFree(argv);
	return returnValue;
}

int main(int oargc, char **oargv) {
	int delayVal = 0, bInfo = 0;
	int argc;
	TCHAR **env;
	STARTUPINFO start_info = { 0 };
	char windowSpecHelp[] = "[/h:HWND|/p:pId|/t:tId|\"/n:processName\"|\"/w:windowTitle\"";

//	TCHAR *argv[128];
//  __wgetmainargs(&argc, &argv, &env, 0, &start_info);
		
	argv = (TCHAR **)CommandLineToArgvW(GetCommandLineW(), &argc);

	// If enabling this, input coming as UTF-8 without BOM will be received correctly, but NOT Utf-16 LE
	/*
	for (int i=0; i < oargc; i++) {
		argv[i] = (TCHAR *)malloc(sizeof(TCHAR) * 1024);
		MultiByteToWideChar(CP_UTF8, 0, oargv[i], -1, argv[i], 1000);
	}
	argc=oargc;
	*/
	
	/*
	for (int i=0; i < argc; i++) {
		for (int j=0; j < wcslen(argv[i]); j++) {
			if (argv[i][j] > 255) 
				printf("%d\n", argv[i][j]);
		}
	} */	
	
	if (argc < 2 || (argc == 2 && wcscmp(argv[1],L"/?")==0) ) { printf("\nCmdWiz (Unicode) v1.5 : Mikael Sollenborn 2015-2020\nWith contributions from Steffen Ilhardt and Carlos Montiers Aguilera\n\nUsage: cmdwiz [getconsoledim setbuffersize getconsolecolor getch getkeystate flushkeys getquickedit setquickedit getmouse getch_or_mouse getch_and_mouse getcharat getcolorat showcursor getcursorpos setcursorpos print saveblock copyblock moveblock inspectblock playsound delay stringfind stringlen gettime await getexetype cache setwindowtransparency getwindowbounds setwindowpos setwindowsize getdisplaydim getmousecursorpos setmousecursorpos showmousecursor insertbmp savefont setfont gettitle getwindowstyle setwindowstyle gxyinfo getpalette setpalette fullscreen getfullscreen showwindow sendkey windowlist gettaskbarinfo] [params]\n\nUse \"cmdwiz operation /?\" for info on arguments and return values\n\nSee https://www.dostips.com/forum/viewtopic.php?t=7402 for full documentation\n"); return 0; }

	if (argc == 3 && wcscmp(argv[2],L"/?")==0) { bInfo = 1; }

	g_conin = GetInputHandle();
	g_conout = GetOutputHandle();

	if (_wcsicmp(argv[1],L"cache") == 0) {
		FILE *ifp, *ifp2;
		TCHAR *dummy, *dummy2, *fch, *dum_p;
		int fmsize = 1048576 * 16, i, firstLine = 1, isUtf16LE=0, count=1;
		char *dumSingle;
		
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz cache [filelist] [reportFailedOpen]\n"); return clean(0); }
		ifp = _wfopen(argv[2], L"r"); // with _wfopen, use "r" to read as char (into wide char buffer), or "rb" to read as wide char
		if (!ifp) { printf("Error: file not found\n"); return clean(-1); }

		dummy = (TCHAR *) malloc(fmsize * sizeof(TCHAR));
		dummy2 = (TCHAR *) malloc(1024 * sizeof(TCHAR));
		dumSingle = (char *) malloc(1024);
		if (!dummy || !dumSingle) { printf("Error: could not allocate memory\n"); fclose(ifp); return clean(-2); }
		
		// BOM UTf-8: 0xEF 0xBB 0xBF
		// BOM Utf-16 LE: 0xFF 0xFE (0xFE 0xFF för BE)

		fch = fgetws(dummy, fmsize, ifp);
		if (dummy[0]==0xFF && dummy[1]==0xFE) { // if Utf-16 LE, then reopen same file in binary to read wide chars (Big Endian not supported, many issues like byte swap + fgetws will read entire file as one line...)
			isUtf16LE=1;
			fclose(ifp);
			ifp = _wfopen(argv[2], L"rb"); // with _wfopen, use "r" to read as char (into wide char buffer), or "rb" to read as wide char
		} else {
			rewind(ifp);
		}
		
		do {
			fch = fgetws(dummy, fmsize, ifp);
			if (fch) {
				int index = wcslen(dummy)-1-isUtf16LE;
				if (dummy[index] == 10 || dummy[index] == 13) { dummy[index] = 0; } // get rid of newline. Weird, seems to be 13+10 for Utf-16 and just 10 for utf-8 ??
				dum_p = dummy;
				if (firstLine) { firstLine = 0; if (isUtf16LE) { dum_p = dum_p + 1; } else if (dum_p[0]==0xEF && dum_p[1]==0xBB && dum_p[2]==0xBF) dum_p = dum_p + 3; }
				if (*dum_p == '"' && dummy[wcslen(dummy)-1]=='"') { dummy[wcslen(dummy)-1] = 0; dum_p++; }

				if (isUtf16LE) {
					//for (i=0; i < wcslen(dum_p); i++) printf("%d%c\n", dum_p[i], dum_p[i]);
					ifp2 = _wfopen(dum_p, L"r"); 
				} else {
					ifp2 = _wfopen(dum_p, L"r");	// First try to open file as Ansi with default Windows Code Page
					if (!ifp2) {  					// Next try Ansi with OEM (console) Code Page
						//for (i=0; i < wcslen(dum_p); i++) printf("%d%c\n", dum_p[i], dum_p[i]);
						for (i=0; i < wcslen(dum_p); i++) dumSingle[i] = dum_p[i]; dumSingle[i]=0;
						MultiByteToWideChar(CP_OEMCP, 0, dumSingle, -1, dummy2, 1000);
						ifp2 = _wfopen(dummy2, L"r");
					}
					if (!ifp2) { 					// Last, try Utf-8
						//for (i=0; i < wcslen(dum_p); i++) printf("%d%c\n", dum_p[i], dum_p[i]);
						for (i=0; i < wcslen(dum_p); i++) dumSingle[i] = dum_p[i]; dumSingle[i]=0;
						MultiByteToWideChar(CP_UTF8, 0, dumSingle, -1, dummy2, 1000);
						ifp2 = _wfopen(dummy2, L"r");
					}
				}

				if (ifp2) {
					fread(dummy, 1, fmsize, ifp2);
					fclose(ifp2);
				} else if (argc > 3)
					printf("Could not read file on line %d\n", count);
				
				count++;
			}
		} while (fch);
		
		free(dummy);
		free(dummy2);
		free(dumSingle);
		fclose(ifp);
	} else if (_wcsicmp(argv[1],L"delay") == 0) {
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz delay [ms]\n"); return clean(0); }

		delayVal=_wtoi(argv[2]);
		if (delayVal < 1) return clean(0);
		millisleep(delayVal);
		//Sleep(delayVal);
	}
	else if (_wcsicmp(argv[1],L"getconsoledim") == 0) {
		int dim = BUFW;
		if (bInfo) { printf("\nUsage: cmdwiz getconsoledim [w|h|sw|sh|cx|cy]\n\nRETURN: Console dimensions in text, or specified dimension value in ERRORLEVEL\n"); return clean(0); }
		if (argc < 3) { printf("WIDTH %d HEIGHT %d SCREEN_WIDTH %d SCREEN_HEIGHT %d SCROLL_X %d SCROLL_Y %d\n", GetDim(BUFW), GetDim(BUFH), GetDim(SCRW), GetDim(SCRH), GetDim(CURRX), GetDim(CURRY)); return clean(0); }
		if (argv[2][0] == 'w') dim = BUFW;
		if (argv[2][0] == 'h') dim = BUFH;
		if (argv[2][0] == 's') if (argv[2][1] == 'w') dim = SCRW;
		if (argv[2][0] == 's') if (argv[2][1] == 'h') dim = SCRH;
		if (argv[2][0] == 'c') if (argv[2][1] == 'x') dim = CURRX;
		if (argv[2][0] == 'c') if (argv[2][1] == 'y') dim = CURRY;
		return clean(GetDim(dim));
	}
	
	else if (_wcsicmp(argv[1],L"setbuffersize") == 0) {
		COORD nb;

		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setbuffersize [width|keep|- height|keep|-]\n"); return clean(0); }
		nb.X = _wtoi(argv[2]);
		nb.Y = _wtoi(argv[3]);
		if (argv[2][0] == 'k') nb.X = GetDim(BUFW);
		if (argv[3][0] == 'k') nb.Y = GetDim(BUFH);
		if (argv[2][0] == '-') nb.X = GetDim(SCRW);
		if (argv[3][0] == '-') nb.Y = GetDim(SCRH);
		SetConsoleScreenBufferSize(g_conout, nb);
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"getch") == 0) {
		int k;
		
		if (bInfo) { printf("\nUsage: cmdwiz getch [noWait]\n\nRETURN: Key scan code\n"); return clean(0); }
		
		if (argc > 2) if (!kbhit()) return clean(0);
		k = getch();

		if (k == 224 || k == 0) k = 256 + getch();
		return clean(k);
	}
	else if (_wcsicmp(argv[1],L"flushkeys") == 0) {
		if (bInfo) { printf("\nUsage: cmdwiz flushkeys\n"); return clean(0); }

		while(kbhit())
			getch();
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"getkeystate") == 0) {
		// https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
		int i, j, k = 0, done=0;
		TCHAR buf[128];
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getkeystate [all|[l|r]ctrl|[l|r]alt|[l|r]shift|[0x]VKEY[h]] [VK2] ...\n\nRETURN: Text output of the form VKEY VKEY2 etc, and in ERRORLEVEL a bit pattern where VKEY1 is bit 1, VKEY2 is bit 2, etc.\n\n[all] equals testing [shift lshift rshift ctrl lctrl rctrl alt lalt ralt]\n\nSee https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%%28v=vs.85%%29.aspx for virtual key codes\n"); return clean(0); }

		if (_wcsicmp(argv[2],L"all") == 0) {
			int vKeys[16] = { VK_SHIFT, VK_LSHIFT, VK_RSHIFT, VK_CONTROL, VK_LCONTROL, VK_RCONTROL, VK_MENU, VK_LMENU, VK_RMENU }; 
			for (i = 0; i < 9; i++) {
				j = GetAsyncKeyState(vKeys[i]);
				k = (k<<1) | ((j & 0x8000)? 1:0 );
			}
			printKeystates(k, 9);
			return clean(k);
		}

		for (i = argc-1; i > 1; i--) {
			if (_wcsicmp(argv[i],L"shift") == 0) j = GetAsyncKeyState(VK_SHIFT);
			else if (_wcsicmp(argv[i],L"lshift") == 0) j = GetAsyncKeyState(VK_LSHIFT);
			else if (_wcsicmp(argv[i],L"rshift") == 0) j = GetAsyncKeyState(VK_RSHIFT);
			else if (_wcsicmp(argv[i],L"ctrl") == 0) j = GetAsyncKeyState(VK_CONTROL);
			else if (_wcsicmp(argv[i],L"lctrl") == 0) j = GetAsyncKeyState(VK_LCONTROL);
			else if (_wcsicmp(argv[i],L"rctrl") == 0) j = GetAsyncKeyState(VK_RCONTROL);
			else if (_wcsicmp(argv[i],L"alt") == 0) j = GetAsyncKeyState(VK_MENU);
			else if (_wcsicmp(argv[i],L"lalt") == 0) j = GetAsyncKeyState(VK_LMENU);
			else if (_wcsicmp(argv[i],L"ralt") == 0) j = GetAsyncKeyState(VK_RMENU);
			else {
				if (argv[i][0] == '0' && argv[i][1] == 'x') {
					wcscpy(buf, &argv[i][2]);
					j = GetAsyncKeyState(wcstol(buf, NULL, 16));
					done = 1;
				} else
					wcscpy(buf, argv[i]);
				if (!done) {
					if (buf[wcslen(buf)-1]=='h') {
						buf[wcslen(buf)-1]=0;
						j = GetAsyncKeyState(wcstol(buf, NULL, 16));
					} else
						j = GetAsyncKeyState(wcstol(buf, NULL, 10));
				}
			}

			k = (k<<1) | ((j & 0x8000)? 1:0 );
		}
		printKeystates(k, argc-2);
		return clean(k);
	}
	else if (_wcsicmp(argv[1],L"playsound") == 0) {
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz playsound [filename.wav]\n"); return clean(0); }
		PlaySound(argv[2], NULL, 0x00020000L|0x0002); // SND_FILENAME | SND_NODEFAULT
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"gxyinfo") == 0) {
		int res, oddres;
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz gxyinfo [filename.gxy|txt|bmp|bxy|pcx] [ignoreCodes]\n\nRETURN: 0 if file could be loaded, -1 on failure\n"); return clean(0); }
	
		oddres = getFileDim(argv[2]);
	
		if (oddres == -1)
			res = inspectGxy(argv[2], argc > 3);
		else {
			res = oddres;
		}
		
		return clean(res > 0? -1 : 0);
	}
	else if (_wcsicmp(argv[1],L"getcharat") == 0) {
		int ox, oy;
		int x, y;
		int i;
		
		if (argc < 4 || bInfo) {
			printf("\nUsage: cmdwiz getcharat [x|keep y|keep]\n\nRETURN: Character ASCII value at position, -1 on failure\n");
			return clean(0);
		}
		
		GetXY(&ox, &oy);

		if (argv[2][0]!='k') x=_wtoi(argv[2]); else x=ox;
		if (argv[3][0]!='k') y=_wtoi(argv[3]); else y=oy;

		i = ReadCharProperty(x,y,CHARPROP_CHAR);
		if (i == INVALID_COORDINATE) return clean(-1);
		if (i < 0) i = 256+i;
		return clean(i);
	}
	else if (_wcsicmp(argv[1],L"getcolorat") == 0) {
		int x, y;
		int ox, oy;
		int i;

		if (argc < 5 || bInfo) { printf("\nUsage: cmdwiz getcolorat [fg|bg x|keep y|keep]\n\nRETURN: Color value at position, -1 on failure\n"); return clean(0); }

		GetXY(&ox, &oy);

		if (argv[3][0]!='k') x=_wtoi(argv[3]); else x=ox;
		if (argv[4][0]!='k') y=_wtoi(argv[4]); else y=oy;

		i = ReadCharProperty(x,y,argv[2][0]=='f'? CHARPROP_FGCOL : CHARPROP_BGCOL);
		if (i == INVALID_COORDINATE) return clean(-1);
		return clean(i);
	}
	else if (_wcsicmp(argv[1],L"getcursorpos") == 0) {
		int ox, oy;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getcursorpos [x|y]\n\nRETURN: Cursor position in x or y\n"); return clean(0); }
		GetXY(&ox, &oy);

		return clean(argv[2][0]=='x'? ox : oy);
	}
	else if (_wcsicmp(argv[1],L"gettime") == 0) {
		if (bInfo) { printf("\nUsage: cmdwiz gettime\n\nRETURN: Time passed since system start, in milliseconds\n"); return clean(0); }
		
		return clean(milliseconds_now());
	}
	else if (_wcsicmp(argv[1],L"setquickedit") == 0) {
		DWORD fdwMode;
		int i;
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz setquickedit [0|1]\n"); return clean(0); }
		i = _wtoi(argv[2]);

		GetConsoleMode(g_conin, &fdwMode);

		fdwMode = fdwMode | ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT; 
		if (i == 0)
			fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
		else
			fdwMode = fdwMode | ENABLE_QUICK_EDIT_MODE;

		SetConsoleMode(g_conin, fdwMode);
	}
	else if (_wcsicmp(argv[1],L"getquickedit") == 0) {
		DWORD fdwMode;
		if (bInfo) { printf("\nUsage: cmdwiz getquickedit\n\nRETURN: 1 if quick edit is enabled, otherwise 0\n"); return clean(0); }
		
		GetConsoleMode(g_conin, &fdwMode);
		return clean(fdwMode & ENABLE_QUICK_EDIT_MODE ? 1 : 0);
	}
	else if (_wcsicmp(argv[1],L"getmouse") == 0 || _wcsicmp(argv[1],L"getch_or_mouse") == 0 || _wcsicmp(argv[1],L"getch_and_mouse") == 0) {
		DWORD fdwMode, oldfdwMode, cNumRead, j; 
		INPUT_RECORD irInBuf[128];
		TCHAR mouse_output[256] = L"NO_EVENT\n";
		int wtime = -1, i, res, res2, bReadKeys = 0, bWroteKey = 0, bKeyAndMouse = 0, k = 0, bMouseEvent = 0;

		if (!(_wcsicmp(argv[1],L"getmouse") == 0))
			bReadKeys = 1;
		if (_wcsicmp(argv[1],L"getch_and_mouse") == 0)
			bKeyAndMouse = 1;

		if (bInfo) {
			if (_wcsicmp(argv[1],L"getmouse") == 0) {
				printf("\nUsage: cmdwiz getmouse [maxWait_ms]\n\nRETURN: Text output regarding mouse event\n\nERRORLEVEL -1 on no input, or bitpattern following yyyyyyyyyyxxxxxxxxxxx---WwRLrl-  where - bits are ignored, l/L is single/double left click, r/R is single/double right click, w/W is mouse wheel up/down, and x/y are mouse coordinates\n");
			} else if (_wcsicmp(argv[1],L"getch_or_mouse") == 0) {
				printf("\nUsage: cmdwiz getch_or_mouse [maxWait_ms]\n\nRETURN: Text output regarding mouse event or key press\n\nERRORLEVEL -1 on no input, or bitpattern following yyyyyyyyyyxxxxxxxxxxx---WwRLrl0 for a MOUSE event where - bits are ignored, l/L is single/double left click, r/R is single/double right click, w/W is mouse wheel up/down, and x/y are mouse coordinates, OR kkkkkkkkkk1 for a KEY event where k is the key pressed\n");
			} else {
				printf("\nUsage: cmdwiz getch_and_mouse [maxWait_ms]\n\nRETURN: Text output regarding mouse event and key press\n\nERRORLEVEL -1 on no input, or bitpattern kkkkkkkkkyyyyyyyxxxxxxxxWwRLrlM where M is set if there was a Mouse event, l/L is single/double left click, r/R is single/double right click, w/W is mouse wheel up/down, x/y are mouse coordinates, and k is the KEY (0 means no key pressed)\n");			
			}
			return clean(0);
		}
		
		if (argc > 2) wtime = _wtoi(argv[2]);

		GetConsoleMode(g_conin, &oldfdwMode);

		fdwMode = oldfdwMode | ENABLE_EXTENDED_FLAGS  | ENABLE_MOUSE_INPUT;
		fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
		SetConsoleMode(g_conin, fdwMode);

		if (wtime > -1) {
			res = WaitForSingleObject(g_conin, wtime);
			if (res & WAIT_TIMEOUT) { wprintf(mouse_output); return clean(-1); }
		}

		res = -1;
		ReadConsoleInput(g_conin, irInBuf, 128, &cNumRead);
		for (i = 0; i < cNumRead; i++) {
			switch(irInBuf[i].EventType) { 
			case MOUSE_EVENT:
				res = MouseEventProc(irInBuf[i].Event.MouseEvent, bKeyAndMouse, mouse_output);
				bMouseEvent = 1;
				break; 
			case KEY_EVENT:
				if (bReadKeys) {
					WriteConsoleInput(g_conin, &irInBuf[i], 1, &j);
					bWroteKey = 1;
				}
				break;
			case WINDOW_BUFFER_SIZE_EVENT:
			case FOCUS_EVENT:
			case MENU_EVENT:
				break;
			}
		}

		k = -1;
		if (bWroteKey) {
			if (kbhit()) {
				k=getch();
				if (k == 224 || k == 0) k = 256 + getch();
			}
			res2 = WaitForSingleObject(g_conin, 1);
			if (!(res2 & WAIT_TIMEOUT))
				ReadConsoleInput(g_conin, irInBuf, 128, &cNumRead);

			if (k!=-1) {
				if (bKeyAndMouse)
					res = (res > 0? res : 0) | (k<<22);
				else
					res = 1|(k<<1);
			}
		}

		if (k == -1) k = 0;
		if (bMouseEvent)
			wprintf(L"EVENT KEY_EVENT %d %s\n", k, mouse_output);
		else
			wprintf(L"EVENT KEY_EVENT %d MOUSE_EVENT 0\n", k);
		
		SetConsoleMode(g_conin, oldfdwMode);
		return clean(res);
	}
	else if (_wcsicmp(argv[1],L"moveblock") == 0) {
		COORD np;
		SMALL_RECT r;
		SMALL_RECT cl;
		CHAR_INFO chiFill;
		CONSOLE_SCREEN_BUFFER_INFO info;
		int w, h;
		UINT oldCP;
		
		if (argc < 8 || bInfo) { printf("\nUsage: cmdwiz moveblock [x y width height newX newY] [char] [fgcol] [bgcol]\n"); return clean(0); }
		r.Left = _wtoi(argv[2]);
		r.Top = _wtoi(argv[3]);
		w = _wtoi(argv[4]);
		h = _wtoi(argv[5]);
		r.Right = r.Left + w-1;
		r.Bottom = r.Top + h-1;
		if (r.Right < 0 || r.Bottom < 0) return clean(-1);
		np.X = _wtoi(argv[6]);
		np.Y = _wtoi(argv[7]);
		chiFill.Attributes = FOREGROUND_RED;
		if (GetConsoleScreenBufferInfo(g_conout, &info))
			chiFill.Attributes = info.wAttributes;
		chiFill.Char.UnicodeChar = ' ';

		oldCP = GetConsoleOutputCP();
		SetConsoleOutputCP(CP_OEMCP);
		
		if (argc > 8) {
			if (wcslen(argv[8]) == 1)
				chiFill.Char.UnicodeChar = argv[8][0];
			else {
				chiFill.Char.UnicodeChar = wcstol(argv[8], NULL, 16);
				if (chiFill.Char.UnicodeChar < 256) { // Need to convert to get right extended ascii chars
					char u8convBuf[4];
					TCHAR convBuf[4];
					u8convBuf[0] = chiFill.Char.UnicodeChar;
					u8convBuf[1] = 0;
					MultiByteToWideChar(CP_OEMCP, 0, u8convBuf, -1, convBuf, 1+1);
					chiFill.Char.UnicodeChar = convBuf[0];
				}
			}
			
			if (argc > 9) {
				chiFill.Attributes = 0;
				if (wcslen(argv[9]) == 1 && wcstol(argv[9], NULL, 16) > 0)
					chiFill.Attributes = wcstol(argv[9], NULL, 16);
				else
					chiFill.Attributes = _wtoi(argv[9]);
				
				if (argc > 10) {
					if (wcslen(argv[10]) == 1 && wcstol(argv[10], NULL, 16) > 0)
						chiFill.Attributes |= wcstol(argv[10], NULL, 16) << 4;
					else
						chiFill.Attributes |= _wtoi(argv[10]) << 4;
				}
			}
		}
		
		cl.Left=np.X; cl.Top=np.Y; cl.Right=np.X+w; cl.Bottom=np.Y+h; //not working (tried to copy instead of moving). Hence NULL below
		ScrollConsoleScreenBuffer(g_conout, &r, NULL, np, &chiFill);
		
		SetConsoleOutputCP(oldCP);
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"copyblock") == 0) {
		if (argc < 8 || bInfo) { printf("\nUsage: cmdwiz copyblock [x y width height newX newY]\n"); return clean(0); }
		return clean(CopyBlock(_wtoi(argv[2]),_wtoi(argv[3]),_wtoi(argv[4]),_wtoi(argv[5]),_wtoi(argv[6]),_wtoi(argv[7])));
	}
	else if (_wcsicmp(argv[1],L"await") == 0) {
		int startT, waitT;
		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz await [oldtime] [waittime]\n"); return clean(0); }
		startT = _wtoi(argv[2]);
		waitT = _wtoi(argv[3]);

		while (milliseconds_now() < startT+waitT) {
//			Sleep(1);
		}
	}
	else if (_wcsicmp(argv[1],L"getconsolecolor") == 0) {
		CONSOLE_SCREEN_BUFFER_INFO info;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getconsolecolor [fg|bg]\n\nRETURN: Console color 0-15, or -1 on error\n"); return clean(0); }

		if (!GetConsoleScreenBufferInfo(g_conout, &info))
			return clean(-1);

		return clean(argv[2][0]=='f'? info.wAttributes & 0xf : (info.wAttributes >> 4) & 0xf);
	}
	else if (_wcsicmp(argv[1],L"showcursor") == 0) {
		CONSOLE_CURSOR_INFO c;
		BOOL result;
		int retVal;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz showcursor [0|1] [show percentage 1-100 (default 25)]\n\nRETURN: 0 if cursor was previously off, otherwise the previous show percentage\n"); return clean(0); }

		result = GetConsoleCursorInfo(g_conout, &c);
		if (!result)
			return clean(-1);
		if (c.bVisible == FALSE)
			retVal = 0;
		else
			retVal = c.dwSize;
		
		c.bVisible = argv[2][0] == '0'? FALSE : TRUE;
		c.dwSize = 25;
		if (argc > 3) {
			c.dwSize = _wtoi(argv[3]);
			if (c.dwSize < 1 || c.dwSize > 100)
				c.dwSize = 25;
		}
		result = SetConsoleCursorInfo(g_conout, &c);
		if (!result)
			return clean(-1);
		return clean(retVal);
	}
	else if (_wcsicmp(argv[1],L"stringfind") == 0) {
		int index = 0;
		TCHAR *cp;

		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz stringfind [orgstring findstring] [startindex] [noCase]\n\nRETURN: Index of findstring in orgstring, or -1 if not found\n"); return clean(0); }
		if (argc > 4) { index = _wtoi(argv[4]); if (index < 0 || index >= wcslen(argv[2])) return clean(-1); }
		if (argc > 5) { 
			int i;
			for (i = 0; i < wcslen(argv[2]); i++) argv[2][i] = toupper(argv[2][i]);
			for (i = 0; i < wcslen(argv[3]); i++) argv[3][i] = toupper(argv[3][i]);
		}

		cp = wcsstr(&(argv[2][index]), argv[3]);		
		if (!cp) return clean(-1);
		return clean((int)(cp - (TCHAR *)argv[2]));
	}
	else if (_wcsicmp(argv[1],L"stringlen") == 0) {
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz stringlen [string]\n\nRETURN: Length of string\n"); return clean(0); }

		return clean(wcslen(argv[2]));
	}
	else if (_wcsicmp(argv[1],L"getexetype") == 0) {
		SHFILEINFO sfi = {0};
		DWORD_PTR ret = 0;
		WORD hi, lo;
		
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getexetype [file]\n\nRETURN: -1 (Error), 0 (Unknown), 1 (Console or .bat), 2 (MS-DOS), 3 (Windows)\n"); return clean(0); }

		ret = SHGetFileInfo(argv[2], 0, &sfi, sizeof(sfi), SHGFI_EXETYPE);

		if (ret == 0) return clean(0);

		hi = HIWORD(ret);
		lo = LOWORD(ret);

		if (lo == 0x4550 && hi == 0)
			return clean(1);
		else if (lo == 0x5A4D && hi == 0)
			return clean(2);
		else if ((lo == 0x4550 || lo == 0x454E) && hi != 0)
			return clean(3);

		return clean(-1);
	}
	else if (_wcsicmp(argv[1],L"inspectblock") == 0) {
		char glyphs[128];
		int i, inspChar;
		
		if (argc < 8 || bInfo) { printf("\nUsage: cmdwiz inspectblock [x y width height inclusive|exclusive char1] [char2] [char3] ...\n\nRETURN: Bit pattern, where char1 is bit 1, char 2 is bit 2, etc. -1 on error.\n"); return clean(0); }
		for (i = 7; i < argc; i++) {
			if (argv[i][1]==0)
				inspChar = argv[i][0];
			else
				inspChar = wcstol(argv[i], NULL, 16);
			glyphs[i-7] = inspChar;
		}
		glyphs[i-7] = 0;
		
		return clean(InspectBuffer(g_conout, _wtoi(argv[2]), _wtoi(argv[3]), _wtoi(argv[4]), _wtoi(argv[5]), argv[6][0]=='e', glyphs));
	}
	else if (_wcsicmp(argv[1],L"saveblock") == 0) {
		int result;
		int encodeMode = 1;
		int transpChar = -1, transpFg = -1, transpBg = -1;

		if (argc < 7 || bInfo) { printf("\nUsage: cmdwiz saveblock [filename x y width height] [encode|forcecode|nocode|txt] [transparent char] [transparent bgcolor] [transparent fgcolor]\n\nRETURN: 0 on success, -1 for file write error, -2 for invalid block\n"); return clean(0); }
		if (argc>7) {
			if (argv[7][0]=='n') encodeMode = 0;
			if (argv[7][0]=='f') encodeMode = 2;
			if (argv[7][0]=='t') encodeMode = 3;
		}
		if (argc>8) {
			if (argv[8][1]==0)
				transpChar = argv[8][0];
			else
				transpChar = wcstol(argv[8], NULL, 16);
		}
		if (argc>9) transpBg = _wtoi(argv[9]);
		if (argc>10) transpFg = _wtoi(argv[10]);

		result = SaveBlock(argv[2], _wtoi(argv[3]), _wtoi(argv[4]), _wtoi(argv[5]), _wtoi(argv[6]), encodeMode, transpChar, transpBg, transpFg);
		result = -result;
		if (result == -1) { printf("Error: Could not write file\n"); }
		if (result == -2) { printf("Error: Invalid block\n"); }
		return clean(result);
	}
	else if (_wcsicmp(argv[1],L"setcursorpos") == 0) {
      int xp, yp;
		
		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setcursorpos [x|keep y|keep]\n"); return clean(0); }
		xp = _wtoi(argv[2]);
		yp = _wtoi(argv[3]);
		if (argv[2][0] == 'k') { GetXY(&xp, NULL); }
		if (argv[3][0] == 'k') { GetXY(NULL, &yp); }
		GotoXY(g_conout, xp, yp);
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"print") == 0) {
		TCHAR *token;
		int i = 0, bFirst = 0, bufferSize;
		UINT oldCP;		
		char *tempOut;
		BOOL cpRes;
		
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz print [\"string\"]\nSupported formatting is \\n \\r \\t \\a \\b \\\\\n"); return clean(0); }
		if (argv[2][0] == '\\') bFirst=1;

		oldCP = GetConsoleOutputCP();
		cpRes = SetConsoleOutputCP(CP_UTF8);

		for (i = 0; i < wcslen(argv[2]); i++) {
			if (argv[2][i] == '\\' && argv[2][i+1] == '\\')
				argv[2][i+1] = 1;
		}
		i = 0;
		token = wcstok(argv[2], L"\\");
		while (token) {
			if (i > 0 || bFirst) {
				switch(token[0]) {
					case 'a': printf("\a"); token++; break;
					case 'b': printf("\b"); token++; break;
					case 'n': printf("\n"); token++; break;
					case 'r': printf("\r"); token++; break;
					case 1: printf("\\"); token++; break;
					case 't': printf("\t"); token++; break;
					case '\"': printf("\""); token++; break;
				}
			}
			
			if (cpRes) {
				bufferSize = WideCharToMultiByte(CP_UTF8, 0, token, -1, NULL, 0, NULL, NULL);
				tempOut = (char *)malloc(bufferSize);
				WideCharToMultiByte(CP_UTF8, 0, token, -1, tempOut, bufferSize, NULL, NULL);
				wprintf(L"%S", tempOut);
				free(tempOut);
			} else
				wprintf(L"%s", token);
			
			token = wcstok(NULL, L"\\");
			i++;
		}

		SetConsoleOutputCP(oldCP);

		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"insertbmp") == 0) {
		
		DWORD bitOp[] = { SRCCOPY, SRCPAINT, SRCAND, SRCINVERT, SRCERASE, NOTSRCCOPY, NOTSRCERASE, MERGECOPY, MERGEPAINT, PATCOPY, PATPAINT, PATINVERT, DSTINVERT, BLACKNESS, WHITENESS, NOMIRRORBITMAP, CAPTUREBLT };
		TCHAR* bitOp_S[] = { L"SRCCOPY", L"SRCPAINT", L"SRCAND", L"SRCINVERT", L"SRCERASE", L"NOTSRCCOPY", L"NOTSRCERASE", L"MERGECOPY", L"MERGEPAINT", L"PATCOPY", L"PATPAINT", L"PATINVERT", L"DSTINVERT", L"BLACKNESS", L"WHITENESS", L"NOMIRRORBITMAP", L"CAPTUREBLT" };
		DWORD selBitOp = SRCCOPY;
		
		int i, x,y,z = 100, w = -1, h = -1;
		HWND hWnd = GetConsoleWindow();
		
		if (argc > 5) {
			TCHAR *winInf = argv[argc - 1];
			
			if (wcslen(winInf) == 2 && winInf[0] == '/' && (winInf[1] == 'D' || winInf[1] == 'd') ) {
				hWnd = NULL;
				argc--;
			} else if (wcslen(winInf) > 3 && winInf[0] == '/' && winInf[2] == ':' ) {
				hWnd = GetWinHandle(winInf);
				if (!hWnd) {
					puts("Error: Could not find specified window");
					return clean(-1);
				}
				argc--;
			}
		}
		
		if (argc < 5 || bInfo) { printf("\nUsage: cmdwiz insertbmp [file.bmp x y] [[z]|[w h]] [bitOp] %s|/D]\n\nBitops are: SRCCOPY (default), SRCPAINT, SRCAND, SRCINVERT, SRCERASE, NOTSRCCOPY, NOTSRCERASE, DSTINVERT, BLACKNESS, WHITENESS\n\nRETURN: 0 on success, -1 if failed to load file\n", windowSpecHelp); return clean(0); }

		x = _wtoi(argv[3]);
		y = _wtoi(argv[4]);
		
		if (argc > 5) {
			for (i = 0; i < wcslen(argv[argc - 1]); i++) argv[argc - 1][i] = toupper(argv[argc - 1][i]);

			for (i = 0;i < 17; i++) {
				if (wcscmp(bitOp_S[i], argv[argc - 1]) == 0) {
					selBitOp = bitOp[i];
					argc--;
					break;
				}
			}
		}

		if (argc > 5) z = _wtoi(argv[5]);
		if (argc > 6) { w = _wtoi(argv[5]); h = _wtoi(argv[6]); }

		if (Fn_LoadBmp(argv[2], x, y, z, w, h, selBitOp, hWnd) == EXIT_SUCCESS) return clean(0); else return clean(-1);
	}
	else if (_wcsicmp(argv[1],L"setwindowtransparency") == 0) {
		int percentage = -1;
		BOOL res;
		
		if (argc > 2) percentage = _wtoi(argv[2]);
		
		if (percentage < 0 || percentage > 100 || bInfo) { printf("\nUsage: cmdwiz setwindowtransparency [0-100] %s]\n", windowSpecHelp); return clean(0); }

		res = f_SetConsoleTransparency(percentage, argc > 3? argv[3] : NULL);
		return clean(res == FALSE? -1 : 0);
	}
	else if (_wcsicmp(argv[1],L"setwindowpos") == 0) {
		RECT bounds;
		int x, y, w, h;
		HWND hWnd = GetConsoleWindow();

		if (argc > 4) {
			hWnd = GetWinHandle(argv[4]);
			if (!hWnd) {
				puts("Error: Could not find specified window");
				return clean(-1);
			}
		}
		
		if (!hWnd) return clean(-1);
		GetWindowRect(hWnd, &bounds);
		
		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setwindowpos [x|keep y|keep] %s]\n", windowSpecHelp); return clean(0); }
		x = _wtoi(argv[2]); if (argv[2][0]=='k') x = bounds.left;
		y = _wtoi(argv[3]); if (argv[3][0]=='k') y = bounds.top;
		w = bounds.right-bounds.left;
		h = bounds.bottom-bounds.top;
		
		SetWindowPos(hWnd, HWND_TOP, x, y, w, h, SWP_ASYNCWINDOWPOS | SWP_NOSIZE | SWP_SHOWWINDOW); // for reasons unclear, SWP_ASYNCWINDOWPOS makes moving more stable
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"setwindowsize") == 0) {
		RECT bounds;
		int x, y, w, h;
		HWND hWnd = GetConsoleWindow();

		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setwindowsize [w|keep h|keep] %s]\n", windowSpecHelp); return clean(0); }

		if (argc > 4) {
			hWnd = GetWinHandle(argv[4]);
			if (!hWnd) {
				puts("Error: Could not find specified window");
				return clean(-1);
			}
		}
		
		if (!hWnd) return clean(-1);
		GetWindowRect(hWnd, &bounds);
		
		x = bounds.left;
		y = bounds.top;
		w = _wtoi(argv[2]); if (argv[2][0]=='k') w = bounds.right-bounds.left;
		h = _wtoi(argv[3]); if (argv[3][0]=='k') h = bounds.bottom-bounds.top;
		
		SetWindowPos(hWnd, HWND_TOP, x, y, w, h, SWP_ASYNCWINDOWPOS | SWP_NOMOVE | SWP_SHOWWINDOW);
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"getwindowbounds") == 0) {
		RECT bounds;
		HWND hWnd;
		int pos = -1;
		hWnd = GetConsoleWindow();
				
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getwindowbounds [x|y|w|h] %s]\n\nRETURN: The requested value in ERRORLEVEL\n", windowSpecHelp); return clean(0); }

		if (argc > 3) {
			hWnd = GetWinHandle(argv[3]);
			if (!hWnd) {
				puts("Error: Could not find specified window");
				return clean(-1);
			}
		}
		
		if (!hWnd) return clean(-1);
		GetWindowRect(hWnd, &bounds);

		if (argv[2][0] == 'y') return clean(bounds.top);
		if (argv[2][0] == 'w') return clean(bounds.right - bounds.left);
		if (argv[2][0] == 'h') return clean(bounds.bottom - bounds.top);
		return clean(bounds.left);
	}
	else if (_wcsicmp(argv[1],L"gettitle") == 0) {
		TCHAR title[1024];
		int bufferSize;
		char *tempOut;
		UINT oldCP;
		BOOL cpRes;
		
		if (bInfo) { printf("\nUsage: cmdwiz gettitle [strip]\n\nRETURN: Prints the title of the console\n"); return clean(0); }		
		
		GetConsoleTitle(title, 1023);

		oldCP = GetConsoleOutputCP();
		cpRes = SetConsoleOutputCP(CP_UTF8);

		if (argc > 2 && argv[2][0] == 's') {
			TCHAR *fnd = wcsstr(title, L" - ");
			if (fnd)
				*fnd = 0;
		}
		
		if (cpRes) {
			bufferSize = WideCharToMultiByte(CP_UTF8, 0, title, -1, NULL, 0, NULL, NULL);
			tempOut = (char *)malloc(bufferSize);
			WideCharToMultiByte(CP_UTF8, 0, title, -1, tempOut, bufferSize, NULL, NULL);
			wprintf(L"%S", tempOut);
			free(tempOut);
		} else
			wprintf(L"%s", title);

		SetConsoleOutputCP(oldCP);

		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"getdisplaydim") == 0) {
		int bW = 0;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getdisplaydim [w|h] [scaled]\n\nSpecify scaled to modify result by display scaling.\n\nRETURN: The requested screen dimension in ERRORLEVEL\n"); return clean(0); }
		if (argv[2][0] == 'w' || argv[2][0] == 'W') bW = 1;

		if (! (argc > 3 && argv[3][0] == 's') ) {
			//SetThreadDpiAwarenessContext(DPI_AWARENESS_UNAWARE); // not available in my gcc header or user32 lib (Win10). The ACTUAL recommended way is to use no call, but a manifest for DPI awareness instead.
			//SetProcessDpiAwareness(DPI_AWARENESS_UNAWARE); // same. SetProcessDpiAwareness is Win8 rec. 
			SetProcessDPIAware(); // works, since Vista
		}

		return clean(GetSystemMetrics(bW ? SM_CXSCREEN : SM_CYSCREEN));
	}
	else if (_wcsicmp(argv[1],L"setmousecursorpos") == 0) {
		int x, y;
		int click = 0, amount = 1;
		INPUT Input = {0};
		POINT pos;

		GetCursorPos(&pos);

		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setmousecursorpos [x|keep y|keep] [l|r|d|u|m|wu|wd|wl|wr] [wheelAmount]\n"); return clean(0); }
		x = _wtoi(argv[2]); if (argv[2][0]=='k') x = pos.x;
		y = _wtoi(argv[3]); if (argv[3][0]=='k') y = pos.y;
		if (argc > 4) { if (argv[4][0]=='l') click = 1; if (argv[4][0]=='r') click = 2; if (argv[4][0]=='d') click = 3; if (argv[4][0]=='u') click = 4; if (argv[4][0]=='m') click = 5; } 
		if (argc > 4) { if (argv[4][0]=='w') { if (argv[4][1]=='u') click = 6; if (argv[4][1]=='d') click = 7; if (argv[4][1]=='l') click = 8; if (argv[4][1]=='r') click = 9; } }
		if (argc > 5) { amount = _wtoi(argv[5]); if (amount < 1) amount=1; }

		SetCursorPos(x,y);

		if (click > 0) {
			if (click < 6) {
				if (click != 4) {
					Input.type = INPUT_MOUSE;
					Input.mi.dwFlags = click==2? MOUSEEVENTF_RIGHTDOWN : click==5? MOUSEEVENTF_MIDDLEDOWN : MOUSEEVENTF_LEFTDOWN;
					SendInput(1,&Input,sizeof(INPUT));
				}

				if (click != 3) {
					ZeroMemory(&Input,sizeof(INPUT));
					Input.type = INPUT_MOUSE;
					Input.mi.dwFlags = click==2? MOUSEEVENTF_RIGHTUP : click==5? MOUSEEVENTF_MIDDLEUP : MOUSEEVENTF_LEFTUP;
					SendInput(1,&Input,sizeof(INPUT));
				}
			} else {
				Input.type = INPUT_MOUSE;
				Input.mi.dwFlags = click==6 || click==7? MOUSEEVENTF_WHEEL : 0x01000; // 0x01000 = MOUSEEVENTF_HWHEEL
				Input.mi.mouseData = click==8 || click==7? -120 * amount : 120 * amount;
				SendInput(1,&Input,sizeof(INPUT));
			}
		}
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"getmousecursorpos") == 0) {
		POINT pos;
		int bX = 0;
				
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getmousecursorpos [x|y]\n\nRETURN: The requested mouse cursor position dimension in ERRORLEVEL\n"); return clean(0); }
		if (argv[2][0] == 'x') bX = 1;
		
		GetCursorPos(&pos);
		return clean(bX ? pos.x : pos.y);
	}
	else if (_wcsicmp(argv[1],L"setfont") == 0) {
		int index = -1;
		
		if (argc > 2 && wcslen(argv[2]) == 1) index = _wtoi(argv[2]);
		if (argc < 3 || (wcslen(argv[2])==1 && (index < 0 || index > 9)) || bInfo) { printf("\nUsage: cmdwiz setfont [0-9|filename]\n"); return clean(0); }

		if (index == -1)
			return clean(SetFontFromFile(argv[2]));
		else
			return clean(SetFont(index));
	}
	else if (_wcsicmp(argv[1],L"savefont") == 0) {
		CONSOLE_FONT_INFOEX fontInfo;
		FILE *ofp;
		int res;
		
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz savefont [filename]\n"); return clean(0); }

		res = GetFont(&fontInfo);
		
		if (res) return clean(-1);
		
		ofp = _wfopen(argv[2], L"wb");
		if (!ofp) { printf("Error: could not save font\n"); return clean(-1); }
		
		fwrite(&fontInfo, sizeof(CONSOLE_FONT_INFOEX),1,ofp);
		fclose(ofp);
		
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"setwindowstyle") == 0) {
		int bExtended, bSet, i,flag;
		long valueFlags;
		HWND hWnd = GetConsoleWindow();

		if (argc > 2) bSet = argv[2][0] == 's' ? 1 : argv[2][0] == 'c'? 0 : -1;
		if (argc > 3) bExtended = argv[3][0] == 'e' ? 1 : argv[3][0] == 's'? 0 : -1;
		
		if (argc < 5 || bInfo || bSet == -1 || bExtended == -1) { printf("\nUsage: cmdwiz setwindowstyle set|clear standard|extended value1 [value2] ... %s]\n\nSee https://msdn.microsoft.com/en-us/library/windows/desktop/ms644898.aspx for style and extended style values\n", windowSpecHelp); return clean(0);
		}
		
		if (argc > 5) {
			TCHAR *winInf = argv[argc - 1];
			if (wcslen(winInf) > 3 && winInf[0] == '/' && winInf[2] == ':' ) {
				hWnd = GetWinHandle(winInf);
				if (!hWnd) {
					puts("Error: Could not find specified window");
					return clean(-1);
				}
				argc--;
			}
		}
		
		valueFlags = GetWindowLongPtr(hWnd, bExtended? GWL_EXSTYLE : GWL_STYLE);
		
		for (i = 4; i < argc; i++) {
			TCHAR *inp = argv[i];
			if (inp[0]=='0' && inp[1]=='x')
				inp+=2;
			int flag = wcstol(inp, NULL, 16);
			if (bSet) valueFlags |= flag; else valueFlags &= ~(flag);
		}
		SetWindowLongPtr(hWnd, bExtended? GWL_EXSTYLE : GWL_STYLE, valueFlags);
		// SetWindowPos(hWnd, HWND_TOP, 0,0,0,0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"getwindowstyle") == 0) {
		int bExtended, flag;
		long valueFlags;
		TCHAR *inp;
		HWND hWnd = GetConsoleWindow();
		
		if (argc > 2) bExtended = argv[2][0] == 'e' ? 1 : argv[2][0] == 's'? 0 : -1;
		
		if (argc < 4 || bInfo || bExtended == -1) { printf("\nUsage: cmdwiz getwindowstyle standard|extended value %s]\n\nSee https://msdn.microsoft.com/en-us/library/windows/desktop/ms644898.aspx for style and extended style values\n\nRETURN: ERRORLEVEL 1 if style set, otherwise 0\n", windowSpecHelp); return clean(0);
		}
		
		if (argc > 4) {
			hWnd = GetWinHandle(argv[4]);
			if (!hWnd) {
				puts("Error: Could not find specified window");
				return clean(-1);
			}
		}
		
		valueFlags = GetWindowLongPtr(hWnd, bExtended? GWL_EXSTYLE : GWL_STYLE);
		
		inp = argv[3];
		if (inp[0]=='0' && inp[1]=='x')
			inp+=2;
		flag = wcstol(inp, NULL, 16);
		
		return clean(valueFlags & flag ? 1 : 0);
	}
	else if (_wcsicmp(argv[1],L"setpalette") == 0) {
		CONSOLE_SCREEN_BUFFER_INFOEX consoleInfo;
		consoleInfo.cbSize = sizeof(CONSOLE_SCREEN_BUFFER_INFOEX);
		int cols[20];
		int nof, i;
		
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz setpalette [RRGGBB[,RRGGBB...]]\n"); return clean(0); }

		GetConsoleScreenBufferInfoEx(g_conout, &consoleInfo);

		nof = swscanf(argv[2], L"%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x", &cols[0], &cols[1], &cols[2], &cols[3], &cols[4], &cols[5], &cols[6], &cols[7], &cols[8], &cols[9], &cols[10], &cols[11], &cols[12], &cols[13], &cols[14], &cols[15]);
		
		if (nof < 1) { printf("\nError: invalid format\n"); return clean(-1); }
		
		for (i = 0; i < nof; i++) {
			consoleInfo.ColorTable[i] = ((cols[i] & 0xff) << 16) | ((cols[i] & 0xff00)) | ((cols[i] & 0xff0000) >> 16);
		}
		
		SetConsoleScreenBufferInfoEx(g_conout, &consoleInfo);
		
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"getpalette") == 0) {
		CONSOLE_SCREEN_BUFFER_INFOEX consoleInfo;
		consoleInfo.cbSize = sizeof(CONSOLE_SCREEN_BUFFER_INFOEX);
		int col, i;
		
		if (bInfo) { printf("\nUsage: cmdwiz getpalette\n\nRETURN:Prints palette string to be used for setpalette\n"); return clean(0); }

		GetConsoleScreenBufferInfoEx(g_conout, &consoleInfo);

		for (i = 0; i < 16; i++) {
			col = consoleInfo.ColorTable[i];
			printf("%06x", ((col & 0xff) << 16) | ((col & 0xff00)) | ((col & 0xff0000) >> 16));
			if (i < 15) printf(",");
		}		
		puts("");
		
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"showmousecursor") == 0) {
		int show, count = 0;
	
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz showmousecursor [0|1]\n"); return clean(0); }
		
		show = _wtoi(argv[2]);
		
		long ref_cnt = ShowConsoleCursor(g_conout, show);
		if (show) {
			if (ref_cnt > 0) {
				while ((ref_cnt = ShowConsoleCursor(g_conout, 0)) > 0 && count++ < 1000);
			}
		} else {
			if (ref_cnt < -1) {
				while ((ref_cnt = ShowConsoleCursor(g_conout, 1)) < -1 && count++ < 1000);
			}
		}
	}
	else if (_wcsicmp(argv[1],L"showwindow") == 0) {
		RECT bounds;
		int show, doPos = 0;
		HWND hWnd = GetConsoleWindow(), hTop;
	
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz showwindow [minimize|maximize|restore|topmost|top|bottom|close|value:n] %s]\n", windowSpecHelp); return clean(0); }

		if (argc > 3) {
			hWnd = GetWinHandle(argv[3]);
			if (!hWnd) {
				puts("Error: Could not find specified window");
				return clean(-1);
			}
		}
		GetWindowRect(hWnd, &bounds);
		
		if (wcsstr(argv[2], L"max") == argv[2]) show = SW_MAXIMIZE;
		else if (wcsstr(argv[2], L"min") == argv[2]) show = SW_MINIMIZE;
		else if (wcsstr(argv[2], L"rest") == argv[2]) show = SW_RESTORE;
		else if (wcsstr(argv[2], L"topmost") == argv[2]) { doPos=1; hTop = HWND_TOPMOST; }
		else if (wcsstr(argv[2], L"top") == argv[2]) { doPos=1; SetWindowPos(hWnd, HWND_NOTOPMOST, bounds.left, bounds.top, bounds.right-bounds.left, bounds.bottom-bounds.top, SWP_ASYNCWINDOWPOS | SWP_NOSIZE | SWP_SHOWWINDOW); hTop = HWND_TOP; SetForegroundWindow(hWnd); }
		else if (wcsstr(argv[2], L"bottom") == argv[2]) { doPos=1; SetWindowPos(hWnd, HWND_NOTOPMOST, bounds.left, bounds.top, bounds.right-bounds.left, bounds.bottom-bounds.top, SWP_ASYNCWINDOWPOS | SWP_NOSIZE | SWP_SHOWWINDOW); hTop = HWND_BOTTOM; }
		else if (wcsstr(argv[2], L"close") == argv[2]) { SendMessageTimeout(hWnd, WM_CLOSE, 0, 0, SMTO_BLOCK | SMTO_NOTIMEOUTIFNOTHUNG, 2000u, NULL); return clean(0); }
		else if (wcsstr(argv[2], L"value:") == argv[2]) show = _wtoi(&argv[2][6]);
		else { printf("\nError: invalid format\n"); return clean(-1); } 
		
		if (doPos)
			SetWindowPos(hWnd, hTop, bounds.left, bounds.top, bounds.right-bounds.left, bounds.bottom-bounds.top, SWP_ASYNCWINDOWPOS | SWP_NOSIZE | SWP_SHOWWINDOW);
		else
			ShowWindow(hWnd, show);
	
		/*
		DWORD currentThreadId = GetCurrentThreadId();
		DWORD otherThreadId = GetWindowThreadProcessId(hWnd, NULL);
		if( otherThreadId == 0 ) { printf("Error: could not attach to window thread\n"); return clean(-1); }
		if( otherThreadId != currentThreadId )
			AttachThreadInput(currentThreadId, otherThreadId, TRUE);

		//SetActiveWindow(hWnd);
		//SetFocus(hWnd);
		SetForegroundWindow(hWnd);
		
		if( otherThreadId != currentThreadId )
			AttachThreadInput(currentThreadId, otherThreadId, FALSE);
		*/
		
		
	} else if (_wcsicmp(argv[1],L"getfullscreen") == 0) {
		int res;
		long unsigned int modeRes;
		RECT rcWorkArea, bounds;
		
		if (bInfo) { printf("\nUsage: cmdwiz getfullscreen\n\nRETURN: -1 if failed to get info, 0 if console is windowed, 1 if fullcreen, 2 if 'fake' (legacy) fullscreen\n"); return clean(0); }
	
		res = GetConsoleDisplayMode(&modeRes);
		
		if (!res || (res && modeRes == 0)) {
			LONG style, ex_style;

			HWND hWnd = GetConsoleWindow();
			SystemParametersInfo(SPI_GETWORKAREA, 0, &rcWorkArea, 0);

			GetWindowRect(hWnd, &bounds);

			style = GetWindowLong(hWnd, GWL_STYLE);
			ex_style = GetWindowLong(hWnd, GWL_EXSTYLE);
		
			if (bounds.left == rcWorkArea.left && bounds.top == rcWorkArea.top && !(style & (WS_CAPTION | WS_THICKFRAME)) && !(ex_style & (WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE |
					 WS_EX_CLIENTEDGE | WS_EX_STATICEDGE)))
				return clean(2);
			else
				return 0;
		}
		
		return clean(modeRes);
		
	} else if (_wcsicmp(argv[1],L"fullscreen") == 0) {
		HWND hWnd;
		HANDLE hOut, hIn;
		COORD screenBufferSize;
		LONG style, ex_style;
		SMALL_RECT windowSize;
		RECT rcWorkArea;
		DWORD mode;
		int fs, fail = 0;
	
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz fullscreen [0|1] [legacy]\n\nRETURN: -1 if normal method failed and had to use legacy method, otherwise 0\n"); return clean(0); }
		
		fs = _wtoi(argv[2]);

		if (!(argc > 3 && argv[3][0] == 'l')) {
			int res = SetConsoleDisplayMode (g_conout, CONSOLE_FULLSCREEN_MODE, NULL);	
			SetConsoleDisplayMode (g_conout, fs? CONSOLE_FULLSCREEN_MODE : CONSOLE_WINDOWED_MODE, NULL);	
			if (res) return clean(0); else fail = -1;
		}

		hWnd = GetConsoleWindow();
				
		if (fs == 0) {
			SetWindowLong(hWnd, GWL_STYLE, 0x14cf0000);
			SetWindowLong(hWnd, GWL_EXSTYLE, 0x40310);
			return clean(fail);
		}

		hOut = g_conout;

		SystemParametersInfo(SPI_GETWORKAREA, 0, &rcWorkArea, 0);

		style = GetWindowLong(hWnd, GWL_STYLE);
		ex_style = GetWindowLong(hWnd, GWL_EXSTYLE);

		//printf("%x %x\n", style, ex_style);getchar();
		
		SetWindowLong(hWnd, GWL_STYLE, style & ~(WS_CAPTION | WS_THICKFRAME));
		SetWindowLong(hWnd, GWL_EXSTYLE,
		  ex_style & ~(WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE |
					 WS_EX_CLIENTEDGE | WS_EX_STATICEDGE));

		SetWindowPos(hWnd, NULL, rcWorkArea.left, rcWorkArea.top,
		 0, 0,
		 SWP_NOZORDER | SWP_NOSIZE | SWP_NOACTIVATE |
		 SWP_FRAMECHANGED);

		screenBufferSize = (COORD) GetLargestConsoleWindowSize(hOut);

		windowSize.Left = (SHORT) 0;
		windowSize.Top = (SHORT) 0;
		windowSize.Right = (SHORT) screenBufferSize.X - 1;
		windowSize.Bottom = (SHORT) screenBufferSize.Y - 1;

		SetConsoleScreenBufferSize(hOut, screenBufferSize);
		SetConsoleWindowInfo(hOut, TRUE, &windowSize);

		return clean(fail);
	}
	else if (_wcsicmp(argv[1],L"sendkey") == 0) {
		int x, y, done = 0, j;
		int click = 0, amount = 1, repeat=1;
		INPUT Input = {0};
		TCHAR buf[128];
		POINT pos;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz sendkey [[0x]VKEY[h] p|d|u [repeatCount]] | \"string\"\n\nSee https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%%28v=vs.85%%29.aspx for virtual key codes\n\nFor use of string, only the following keys are directly supported, the rest are keyboard layout specific: space a-z A-Z 0-9 .,+-*/. Use prefix $ for Shift, ^ for Ctrl, @ for Alt, { for Alt-Gr, [ for Win-key, \\ for Enter, } for Tab key. \nExample: to type a ! on most keyboards, use \"$1\".\n"); return clean(0); }

		if (argc < 4) {
			int shift=0, ctrl=0, alt=0, win=0;
			for (j = 0; j < wcslen(argv[2]); j++) {

				Input.type = INPUT_KEYBOARD;
				
				int key = argv[2][j];
				
				while(key == '$' || key == '^' || key == '@' || key == '{' || key == '[') {
					if (key == '$') shift=1;
					if (key == '^') ctrl=1;
					if (key == '@') alt=1;
					if (key == '{') ctrl=1, alt=1;
					if (key == '[') win=1;
					j++;
					if (j >= wcslen(argv[2]))
						return clean(0);
					key = argv[2][j];
				}
				
				if (key >= 'a' && key <= 'z')
					key = key-'a' + 0x41;
				else if (key >= 'A' && key <= 'Z')
					key = key-'A' + 0x41, shift=1;
				else if (key >= '0' && key <= '9')
					key = key-'0' + 0x30;
				else if (key == '.')
					key = 0xbe;
				else if (key == '-')
					key = 0xbd;
				else if (key == '+')
					key = 0xbb;
				else if (key == ',')
					key = 0xbc;
				else if (key == '*')
					key = 0x6a;
				else if (key == '/')
					key = 0x6f;
				else if (key == '\\')
					key = 0x0D;
				else if (key == '}')
					key = 0x09;
				
				Input.ki.dwFlags = 0;
				if (shift) {
					Input.ki.wVk = 0x10;
					SendInput(1,&Input,sizeof(INPUT));
				}
				if (ctrl) {
					Input.ki.wVk = 0x11;
					SendInput(1,&Input,sizeof(INPUT));
				}
				if (alt) {
					Input.ki.wVk = 0x12;
					SendInput(1,&Input,sizeof(INPUT));
				}
				if (win) {
					Input.ki.wVk = 0x5b;
					SendInput(1,&Input,sizeof(INPUT));
				}
				Input.ki.wVk = key;
				SendInput(1,&Input,sizeof(INPUT));
				Input.ki.dwFlags = KEYEVENTF_KEYUP;
				SendInput(1,&Input,sizeof(INPUT));
				if (shift) {
					Input.ki.wVk = 0x10;
					SendInput(1,&Input,sizeof(INPUT));
					shift=0;
				}
				if (ctrl) {
					Input.ki.wVk = 0x11;
					SendInput(1,&Input,sizeof(INPUT));
					ctrl=0;
				}
				if (alt) {
					Input.ki.wVk = 0x12;
					SendInput(1,&Input,sizeof(INPUT));
					alt=0;
				}
				if (win) {
					Input.ki.wVk = 0x5b;
					SendInput(1,&Input,sizeof(INPUT));
					win=0;
				}
			}
			
		} else {
			if (argv[2][0] == '0' && argv[2][1] == 'x') {
				wcscpy(buf, &argv[2][2]);
				j = wcstol(buf, NULL, 16);
				done = 1;
			} else
				wcscpy(buf, argv[2]);
			if (!done) {
				if (buf[wcslen(buf)-1]=='h') {
					buf[wcslen(buf)-1]=0;
					j = wcstol(buf, NULL, 16);
				} else
					j = wcstol(buf, NULL, 10);
			}
			
			Input.type = INPUT_KEYBOARD;
			Input.ki.wVk = j;

			if (argc > 3) {
				repeat = wcstol(argv[4], NULL, 10);
				if (repeat < 1) repeat=1;
			}
			
			for (j = 0; j < repeat; j++) {	
				if (argv[3][0] == 'p' || argv[3][0] == 'd') {
					Input.ki.dwFlags = 0;
					SendInput(1,&Input,sizeof(INPUT));
				}
				if (argv[3][0] == 'p' || argv[3][0] == 'u') {
					Input.ki.dwFlags = KEYEVENTF_KEYUP;
					SendInput(1,&Input,sizeof(INPUT));
				}
			}
		}
					
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"windowlist") == 0) {
		CALLBACKDATA data = {0};
  
		bPrintEmptyTitleWindows = (argc > 2 && (argv[2][0]=='a' || argv[2][0]=='A'));
		
  		if (bInfo) { printf("\nUsage: cmdwiz windowlist [all]\n\nPrints a list of all (titled) main windows in the format: window handle|process ID|thread ID|process name|window title\n\nUse 'all' to include untitled windows.\n"); return clean(0); }
		
		EnumWindows(EnumWindowsListCallback, (LPARAM)&data);
		return clean(0);
	}
	else if (_wcsicmp(argv[1],L"gettaskbarinfo") == 0) {

		APPBARDATA pabd = {0}, pabd2 = {0};
		int bAutoHide=0, pos=0, res=0;
		BOOL dResult = (BOOL) SHAppBarMessage(ABM_GETTASKBARPOS, &pabd);
		UINT sResult = (UINT) SHAppBarMessage(ABM_GETSTATE, &pabd2);
		if (dResult==FALSE) {
			puts("Error: could not get taskbar info");
			return clean(-1);			
		}
		if (sResult & ABS_AUTOHIDE) bAutoHide=1;
			
		if (bInfo) { printf("\nUsage: cmdwiz gettaskbarinfo [w|h|x|y|a|p]\n\nRETURN: Taskbar info in text, or specified info in ERRORLEVEL\n\nPos: 0=bottom, 1=top, 2=left, 3=right\n"); return clean(0); }

		int x=pabd.rc.left, y=pabd.rc.top, w=pabd.rc.right-pabd.rc.left, h=pabd.rc.bottom-pabd.rc.top;
		
		if (w>h) { pos=0; if (y < 50) pos=1; }
		if (h>w) { pos=3; if (x < 50) pos=2; }
		
		if (argc < 3) { printf("X %d Y %d W %d H %d HIDE %d POS %d\n", x, y, w, h, bAutoHide, pos ); return clean(0); }
		if (argv[2][0] == 'x') res = x;
		if (argv[2][0] == 'y') res = y;
		if (argv[2][0] == 'w') res = w;
		if (argv[2][0] == 'h') res = h;
		if (argv[2][0] == 'a') res = bAutoHide;
		if (argv[2][0] == 'p') res = pos;
		return clean(res);
	}
	else {
		printf("Error: unknown operation\n");
		return clean(-1);
	}

	return clean(0); 
}
