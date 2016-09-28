/* CmdWiz (c) 2015-16 Mikael Sollenborn */

#ifndef WINVER
#define WINVER 0x0502
#endif
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0502
#endif

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <conio.h>
#include <shellapi.h>

// Compilation with gcc: gcc -o cmdwiz.exe cmdwiz.c -lwinmm -luser32 -lgdi32

// TODO: 1. Move: possible to specify "empty" character
//		  (maybe not: 2. getwindowbounds, client area
//		  (         : 3. showwindow (normal, minimize, maximize, alwaysontop, foreground, background)
//      (         : 4. getwindowhandle "title" + setwindowpos/getwindowbounds/setwindowtransparency + new setwindowsize WITH that handle?)
//			5. setmousecursorpos (support right d/u, middle click, mouse wheel) ?
//       6. Support UNICODE
//			7. AsyncKeyState catches key presses even if console is not the active window. Use ReadConsoleInput instead?

#define BUFW 0
#define BUFH 1
#define SCRW 2
#define SCRH 3
#define CURRX 4
#define CURRY 5

#define INVALID_COORDINATE -999

// Undocumented functions and structures
// BEGIN
DWORD WINAPI GetNumberOfConsoleFonts(VOID);
DWORD WINAPI GetConsoleFontInfo(HANDLE hConsoleOutput,
				BOOL bMaximumWindow,
				DWORD nLength,
				PCONSOLE_FONT_INFO lpConsoleFontInfo);
BOOL WINAPI SetConsoleFont(HANDLE hConsoleOutput, DWORD nFont);
// END

/* // no longer needed since defined in more current MinGw headers
typedef struct _CONSOLE_FONT_INFOEX {
	ULONG cbSize;
	DWORD nFont;
	COORD dwFontSize;
	UINT FontFamily;
	UINT FontWeight;
	WCHAR FaceName[LF_FACESIZE];
} CONSOLE_FONT_INFOEX, *PCONSOLE_FONT_INFOEX;
*/

//BOOL WINAPI SetCurrentConsoleFontEx(HANDLE, BOOL, PCONSOLE_FONT_INFOEX);
typedef BOOL(WINAPI * Func_SetCurrentConsoleFontEx) (HANDLE, BOOL, PCONSOLE_FONT_INFOEX);
//COORD WINAPI GetConsoleFontSize(HANDLE, DWORD);
//BOOL WINAPI GetCurrentConsoleFontEx(HANDLE, BOOL, PCONSOLE_FONT_INFOEX);
typedef BOOL(WINAPI * Func_GetCurrentConsoleFontEx) (HANDLE, BOOL, PCONSOLE_FONT_INFOEX);


int GetDim(int dim) {
	int retVal;
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);

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
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbInfo);
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

	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
	if (y > screenBufferInfo.dwSize.Y || y < 0) return INVALID_COORDINATE;
	if (x > screenBufferInfo.dwSize.X || x < 0) return INVALID_COORDINATE;

	r.Left = x;
	r.Top = y;
	r.Right = x + 1;
	r.Bottom = y + 1;
	ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str, a, b, &r);

	switch(eProperty) {
		case CHARPROP_FGCOL: return str[0].Attributes % 16;
		case CHARPROP_BGCOL: return (str[0].Attributes&255) / 16;
		default: return str[0].Char.AsciiChar;
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

int SaveBlock(char *filename, int x, int y, int w, int h, int bEncode, int transpChar, int transpBg, int transpFg) {
	COORD a = { 1, 1 };
	COORD b = { 0, 0 };
	SMALL_RECT r;
	CHAR_INFO *str;
	char *output, attribS[16], charS[8];
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	WORD oldAttrib = 6666;
	FILE *ofp = NULL;
	int i, j;
	unsigned char ch;
	char fName[512];

	if (bEncode == 3)
		sprintf(fName, "%s.txt", filename);
	else
		sprintf(fName, "%s.gxy", filename);
	ofp = fopen(fName, "w");
	if (!ofp) return 1;

	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
	if (y > screenBufferInfo.dwSize.Y || y < 0) return 2;
	if (x > screenBufferInfo.dwSize.X || x < 0) return 2;
	if (y+h > screenBufferInfo.dwSize.Y || h < 1) return 2;
	if (x+w > screenBufferInfo.dwSize.X || w < 1) return 2;

	output = (char*) malloc(10 * w*h);
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
	ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str, a, b, &r);
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
			ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str+j*l*w, a, b, &r);
		}
	}	
	
	for (j=0; j < h; j++) {
		output[0]=0;
		for (i=0; i < w; i++) {
			ch = str[i + j*w].Char.AsciiChar;
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

	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
	if (y > screenBufferInfo.dwSize.Y || y < 0) return 2;
	if (x > screenBufferInfo.dwSize.X || x < 0) return 2;
	if (y+h > screenBufferInfo.dwSize.Y || h < 1) return 2;
	if (x+w > screenBufferInfo.dwSize.X || w < 1) return 2;

	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * STR_SIZE);
	if (!str)
		return 3;

	b.X = 0;
	b.Y = 0;

	a.X = w;
	a.Y = h;

	r.Left = x;
	r.Top = y;
	r.Right = x + w;
	r.Bottom = y + h;
	ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str, a, b, &r);

	r.Left = dx;
	r.Top = dy;
	r.Right = dx + w;
	r.Bottom = dy + h;  
	WriteConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str, a, b, &r);

	free(str);
	return 0;
}


int MouseEventProc(MOUSE_EVENT_RECORD mer, int bKeyAndMouse, char *output) {
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
	
	sprintf(output, "MOUSE_EVENT 1 MOUSE_X %d MOUSE_Y %d LEFT_BUTTON %d RIGHT_BUTTON %d LEFT_DOUBLE_CLICK %d RIGHT_DOUBLE_CLICK %d MOUSE_WHEEL %d",
							mer.dwMousePosition.X, mer.dwMousePosition.Y, (res & 2)>0, (res & 4)>0, (res & 8)>0, (res & 16)>0, (res & 32)>0? 1: (res & 64)>0? -1 : 0);

	return res;
}

/* void ResizeEventProc(WINDOW_BUFFER_SIZE_RECORD wbsr) {
	printf("Resized. Console screen buffer is %d columns by %d rows.\n", wbsr.dwSize.X, wbsr.dwSize.Y);
}*/

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

// Functions "f_SetConsoleTransparency" and "Fn_LoadBmp" borrowed from user "aGerman" at dostips.com

BOOL f_SetConsoleTransparency(long percentage)
{
	HWND hWnd = NULL;
	BYTE bAlpha = 0;
	LONG lNewLong = 0;
	hWnd = GetConsoleWindow();
	if (hWnd && percentage > -1 && percentage < 101)
	{
		bAlpha = (BYTE)(2.55 * (100 - percentage) + 0.5);
		lNewLong = GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED;
		if (!SetWindowLong(hWnd, GWL_EXSTYLE, lNewLong)) return FALSE;
		return SetLayeredWindowAttributes(hWnd, 0, bAlpha, LWA_ALPHA);
	}
	return FALSE;
}

int Fn_LoadBmp(char *szBmpPath, long x, long y, long z, long w, long h)
{
	HWND hWnd = NULL;
	HDC hDc = NULL, hDcBmp = NULL;
	HBITMAP hBmp1 = NULL, hBmp2 = NULL;
	HGDIOBJ hGdiObj = NULL;
	BITMAP bmp = {0};
	int iRet = EXIT_FAILURE;

	if ((hWnd = GetConsoleWindow()))
	{
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
								if (BitBlt(hDc, (int)x, (int)y, (int)w, (int)h, hDcBmp, 0, 0, SRCCOPY))
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
		}
	}
	return iRet;
}

// Function SetFont borrowed from user "carlos" at dostips.com

#define MAX_TERMINAL_FONT_SIZES 127
#define TERMINAL_FONTS 10
int SetFont(int selected) {
	CONSOLE_FONT_INFO font[MAX_TERMINAL_FONT_SIZES];
	HANDLE hOut;
	int fonts_count;
	int index;

	COORD terminal_font[TERMINAL_FONTS] = { {4, 6}, {6, 8}, {8, 8}, {16, 8}, {5, 12}, {7, 12}, {8, 12}, {16, 12}, {12, 16}, {10, 18}};

	if ((selected < 0) || (selected >= TERMINAL_FONTS)) {
		return 1;
	}

	fonts_count = GetNumberOfConsoleFonts();

	if (fonts_count > MAX_TERMINAL_FONT_SIZES) {
		fonts_count = MAX_TERMINAL_FONT_SIZES;
	}

	hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	GetConsoleFontInfo(hOut, FALSE, fonts_count, font);

	for (index = 0; index < fonts_count; ++index) {
		font[index].dwFontSize =
		GetConsoleFontSize(hOut, font[index].nFont);

		if ((font[index].dwFontSize.X != terminal_font[selected].X) || (font[index].dwFontSize.Y != terminal_font[selected].Y)) {
			continue;	//Index not found
	   }

		//Index found
		HINSTANCE dllHandle = LoadLibraryW(L"KERNEL32.DLL");

		if (NULL != dllHandle) {
			Func_SetCurrentConsoleFontEx SetCurrentConsoleFontEx_Ptr = (Func_SetCurrentConsoleFontEx) GetProcAddress(dllHandle, "SetCurrentConsoleFontEx");

			if (NULL != SetCurrentConsoleFontEx_Ptr) {	//vista
				CONSOLE_FONT_INFOEX font_info;

				font_info.cbSize = sizeof(CONSOLE_FONT_INFOEX);
				font_info.nFont = index;
				font_info.dwFontSize.X = terminal_font[selected].X;
				font_info.dwFontSize.Y = terminal_font[selected].Y;
				font_info.FontFamily = 48;
				font_info.FontWeight = 400;
				wcscpy(font_info.FaceName, L"Terminal");

				SetCurrentConsoleFontEx_Ptr(hOut, FALSE, &font_info);
			}

			FreeLibrary(dllHandle);
	   }

		SetConsoleFont(hOut, index);
		break; //done
	}
	return 0;
}


int GetFont(PCONSOLE_FONT_INFOEX font_info) {
	int ret = 1;
	HINSTANCE dllHandle = LoadLibraryW(L"KERNEL32.DLL");

	if (NULL != dllHandle) {
		Func_GetCurrentConsoleFontEx GetCurrentConsoleFontEx_Ptr = (Func_GetCurrentConsoleFontEx) GetProcAddress(dllHandle, "GetCurrentConsoleFontEx");

		if (NULL != GetCurrentConsoleFontEx_Ptr) {	//vista
			font_info->cbSize = sizeof(CONSOLE_FONT_INFOEX); // must set this manually, otherwise GetCurrentConsoleFontEx fails with error 87(bad params). Weird.
			ret = GetCurrentConsoleFontEx_Ptr(GetStdHandle(STD_OUTPUT_HANDLE), FALSE, font_info);
			ret = 1 - ret;
		}
		FreeLibrary(dllHandle);
	}
		
	return ret;
}

int SetFontFromFile(char *fname) {
	HINSTANCE dllHandle = LoadLibraryW(L"KERNEL32.DLL");
	CONSOLE_FONT_INFOEX font_info;
	int ret = 1;
	FILE*ifp;
	
	ifp = fopen(fname, "rb");
	if (!ifp) { printf("Error: Could not load font\n"); return ret; }
	fread(&font_info, sizeof(CONSOLE_FONT_INFOEX), 1, ifp);
	fclose(ifp);
	
	if (NULL != dllHandle) {
		Func_SetCurrentConsoleFontEx SetCurrentConsoleFontEx_Ptr = (Func_SetCurrentConsoleFontEx) GetProcAddress(dllHandle, "SetCurrentConsoleFontEx");

		if (NULL != SetCurrentConsoleFontEx_Ptr) {	//vista
			ret = SetCurrentConsoleFontEx_Ptr(GetStdHandle(STD_OUTPUT_HANDLE), FALSE, &font_info);
			ret = 1 - ret;
			SetConsoleFont(GetStdHandle(STD_OUTPUT_HANDLE), font_info.nFont);
		}
	}
			
	FreeLibrary(dllHandle);
	return ret;
}


int main(int argc, char **argv) {
	int delayVal = 0, bInfo = 0;

	if (argc < 2) { printf("\nUsage: cmdwiz [getconsoledim setbuffersize getconsolecolor getch getkeystate flushkeys getquickedit setquickedit getmouse getch_or_mouse getch_and_mouse getcharat getcolorat showcursor getcursorpos setcursorpos print saveblock copyblock moveblock inspectblock playsound delay stringfind stringlen gettime await getexetype cache setwindowtransparency getwindowbounds setwindowpos getdisplaydim getmousecursorpos setmousecursorpos insertbmp savefont setfont gettitle] [params]\n\nUse \"cmdwiz operation /?\" for info on arguments and return values\n"); return 0; }

	if (argc == 3 && strcmp(argv[2],"/?")==0) { bInfo = 1; }
	
	if (stricmp(argv[1],"cache") == 0) {
		FILE *ifp, *ifp2;
		char *dummy, *fch, *dum_p;
		int fmsize = 1048576 * 16;
				
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz cache [filelist]\n"); return 0; }
		ifp = fopen(argv[2], "r");
		if (!ifp) { printf("Error: file not found\n"); return 1; }

		dummy = (char *) malloc(fmsize);
		if (!dummy) { printf("Error: could not allocate memory\n"); fclose(ifp); return 2; }
		
		do {
			fch = fgets(dummy, fmsize, ifp);
			if (fch) {
				dummy[strlen(dummy)-1] = 0; dum_p = dummy;
				if (*dum_p == '"' && dummy[strlen(dummy)-1]=='"') { dummy[strlen(dummy)-1] = 0; dum_p++; }
				ifp2 = fopen(dum_p, "r");
				if (ifp2) {
					fread(dummy, 1, fmsize, ifp2);
					fclose(ifp2);
				}
			}
		} while (fch);
		
		free(dummy);
		fclose(ifp);
	} else if (stricmp(argv[1],"delay") == 0) {
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz delay [ms]\n"); return 0; }

		delayVal=atoi(argv[2]);
		if (delayVal < 1) return 0;
		Sleep(delayVal);
	}
	else if (stricmp(argv[1],"getconsoledim") == 0) {
		int dim = BUFW;
		if (bInfo) { printf("\nUsage: cmdwiz getconsoledim [w|h|sw|sh|cx|cy]\n\nRETURN: Console dimensions in text, or specified dimension value in ERRORLEVEL\n"); return 0; }
		if (argc < 3) { printf("WIDTH %d HEIGHT %d SCREEN_WIDTH %d SCREEN_HEIGHT %d SCROLL_X %d SCROLL_Y %d\n", GetDim(BUFW), GetDim(BUFH), GetDim(SCRW), GetDim(SCRH), GetDim(CURRX), GetDim(CURRY)); return 0; }
		if (argv[2][0] == 'w') dim = BUFW;
		if (argv[2][0] == 'h') dim = BUFH;
		if (argv[2][0] == 's') if (argv[2][1] == 'w') dim = SCRW;
		if (argv[2][0] == 's') if (argv[2][1] == 'h') dim = SCRH;
		if (argv[2][0] == 'c') if (argv[2][1] == 'x') dim = CURRX;
		if (argv[2][0] == 'c') if (argv[2][1] == 'y') dim = CURRY;
		return GetDim(dim);
	}
	else if (stricmp(argv[1],"setbuffersize") == 0) {
		COORD nb;

		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setbuffersize [width|keep height|keep]\n"); return 0; }
		nb.X = atoi(argv[2]);
		nb.Y = atoi(argv[3]);
		if (argv[2][0] == 'k') nb.X = GetDim(BUFW);
		if (argv[3][0] == 'k') nb.Y = GetDim(BUFH);
		SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), nb);
		return 0;
	}
	else if (stricmp(argv[1],"getch") == 0) {
		int k;
		
		if (bInfo) { printf("\nUsage: cmdwiz getch [noWait]\n\nRETURN: Key scan code\n"); return 0; }
		
		if (argc > 2) if (!kbhit()) return 0;
		k = getch();

		if (k == 224 || k == 0) k = 256 + getch();
		return k;
	}
	else if (stricmp(argv[1],"flushkeys") == 0) {
		if (bInfo) { printf("\nUsage: cmdwiz flushkeys\n"); return 0; }

		while(kbhit())
			getch();
		return 0;
	}
	else if (stricmp(argv[1],"getkeystate") == 0) {
		// https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
		int i, j, k = 0;
		char buf[128];
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getkeystate [all|[l|r]ctrl|[l|r]alt|[l|r]shift|VKEY[h]] [VK2] ...\n\nRETURN: Text output of the form VKEY VKEY2 etc, and in ERRORLEVEL a bit pattern where VKEY1 is bit 1, VKEY2 is bit 2, etc.\n\n[all] equals testing [shift lshift rshift ctrl lctrl rctrl alt lalt ralt]\n\nSee https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%%28v=vs.85%%29.aspx for virtual key codes\n"); return 0; }

		if (stricmp(argv[2],"all") == 0) {
			int vKeys[16] = { VK_SHIFT, VK_LSHIFT, VK_RSHIFT, VK_CONTROL, VK_LCONTROL, VK_RCONTROL, VK_MENU, VK_LMENU, VK_RMENU }; 
			for (i = 0; i < 9; i++) {
				j = GetAsyncKeyState(vKeys[i]);
				k = (k<<1) | ((j & 0x8000)? 1:0 );
			}
			printKeystates(k, 9);
			return k;
		}

		for (i = argc-1; i > 1; i--) {
			if (stricmp(argv[i],"shift") == 0) j = GetAsyncKeyState(VK_SHIFT);
			else if (stricmp(argv[i],"lshift") == 0) j = GetAsyncKeyState(VK_LSHIFT);
			else if (stricmp(argv[i],"rshift") == 0) j = GetAsyncKeyState(VK_RSHIFT);
			else if (stricmp(argv[i],"ctrl") == 0) j = GetAsyncKeyState(VK_CONTROL);
			else if (stricmp(argv[i],"lctrl") == 0) j = GetAsyncKeyState(VK_LCONTROL);
			else if (stricmp(argv[i],"rctrl") == 0) j = GetAsyncKeyState(VK_RCONTROL);
			else if (stricmp(argv[i],"alt") == 0) j = GetAsyncKeyState(VK_MENU);
			else if (stricmp(argv[i],"lalt") == 0) j = GetAsyncKeyState(VK_LMENU);
			else if (stricmp(argv[i],"ralt") == 0) j = GetAsyncKeyState(VK_RMENU);
			else {
				strcpy(buf, argv[i]);
				if (buf[strlen(buf)-1]=='h') {
					buf[strlen(buf)-1]=0;
					j = GetAsyncKeyState(strtol(buf, NULL, 16));
				} else
					j = GetAsyncKeyState(strtol(buf, NULL, 10));
			}

			k = (k<<1) | ((j & 0x8000)? 1:0 );
		}
		printKeystates(k, argc-2);
		return k;
	}
	else if (stricmp(argv[1],"playsound") == 0) {
	if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz playsound [filename.wav]\n"); return 0; }
		PlaySound(argv[2], NULL, 0x00020000L|0x0002); // SND_FILENAME | SND_NODEFAULT
		return 0;
	}
	else if (stricmp(argv[1],"getcharat") == 0) {
		int ox, oy;
		int x, y;
		int i;
		
		if (argc < 4 || bInfo) {
			printf("\nUsage: cmdwiz getcharat [x|keep y|keep]\n\nRETURN: Character ASCII value at position, -1 on failure\n");
			return 0;
		}
		
		GetXY(&ox, &oy);

		if (argv[2][0]!='k') x=atoi(argv[2]); else x=ox;
		if (argv[3][0]!='k') y=atoi(argv[3]); else y=oy;

		i = ReadCharProperty(x,y,CHARPROP_CHAR);
		if (i == INVALID_COORDINATE) return -1;
		if (i < 0) i = 256+i;
		return i;
	}
	else if (stricmp(argv[1],"getcolorat") == 0) {
		int x, y;
		int ox, oy;
		int i;

		if (argc < 5 || bInfo) { printf("\nUsage: cmdwiz getcolorat [fg|bg x|keep y|keep]\n\nRETURN: Color value at position, -1 on failure\n"); return 0; }

		GetXY(&ox, &oy);

		if (argv[3][0]!='k') x=atoi(argv[3]); else x=ox;
		if (argv[4][0]!='k') y=atoi(argv[4]); else y=oy;

		i = ReadCharProperty(x,y,argv[2][0]=='f'? CHARPROP_FGCOL : CHARPROP_BGCOL);
		if (i == INVALID_COORDINATE) return -1;
		return i;
	}
	else if (stricmp(argv[1],"getcursorpos") == 0) {
		int ox, oy;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getcursorpos [x|y]\n\nRETURN: Cursor position in x or y\n"); return 0; }
		GetXY(&ox, &oy);

		return argv[2][0]=='x'? ox : oy;
	}
	else if (stricmp(argv[1],"gettime") == 0) {
		if (bInfo) { printf("\nUsage: cmdwiz gettime\n\nRETURN: Time passed since system start, in milliseconds\n"); return 0; }
		
		return GetTickCount();
	}
	else if (stricmp(argv[1],"setquickedit") == 0) {
		DWORD fdwMode;
		int i;
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz setquickedit [0|1]\n"); return 0; }
		i = atoi(argv[2]);

		GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &fdwMode);

		fdwMode = fdwMode | ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT; 
		if (i == 0)
			fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
		else
			fdwMode = fdwMode | ENABLE_QUICK_EDIT_MODE;

		SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), fdwMode);
	}
	else if (stricmp(argv[1],"getquickedit") == 0) {
		DWORD fdwMode;
		if (bInfo) { printf("\nUsage: cmdwiz getquickedit\n\nRETURN: 1 if quick edit is enabled, otherwise 0\n"); return 0; }
		
		GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &fdwMode);
		return fdwMode & ENABLE_QUICK_EDIT_MODE ? 1 : 0;
	}
	else if (stricmp(argv[1],"getmouse") == 0 || stricmp(argv[1],"getch_or_mouse") == 0 || stricmp(argv[1],"getch_and_mouse") == 0) {
		DWORD fdwMode, oldfdwMode, cNumRead, j; 
		INPUT_RECORD irInBuf[128];
		char mouse_output[256] = "NO_EVENT\n";
		int wtime = -1, i, res, res2, bReadKeys = 0, bWroteKey = 0, bKeyAndMouse = 0, k = 0, bMouseEvent = 0;

		if (!(stricmp(argv[1],"getmouse") == 0))
			bReadKeys = 1;
		if (stricmp(argv[1],"getch_and_mouse") == 0)
			bKeyAndMouse = 1;

		if (bInfo) {
			if (stricmp(argv[1],"getmouse") == 0) {
				printf("\nUsage: cmdwiz getmouse [maxWait_ms]\n\nRETURN: Text output regarding mouse event\n\nERRORLEVEL -1 on no input, or bitpattern following yyyyyyyyyyxxxxxxxxxxx---WwRLrl-  where - bits are ignored, l/L is single/double left click, r/R is single/double right click, w/W is mouse wheel up/down, and x/y are mouse coordinates\n");
			} else if (stricmp(argv[1],"getch_or_mouse") == 0) {
				printf("\nUsage: cmdwiz getch_or_mouse [maxWait_ms]\n\nRETURN: Text output regarding mouse event or key press\n\nERRORLEVEL -1 on no input, or bitpattern following yyyyyyyyyyxxxxxxxxxxx---WwRLrl0 for a MOUSE event where - bits are ignored, l/L is single/double left click, r/R is single/double right click, w/W is mouse wheel up/down, and x/y are mouse coordinates, OR kkkkkkkkkk1 for a KEY event where k is the key pressed\n");
			} else {
				printf("\nUsage: cmdwiz getch_and_mouse [maxWait_ms]\n\nRETURN: Text output regarding mouse event and key press\n\nERRORLEVEL -1 on no input, or bitpattern kkkkkkkkkyyyyyyyxxxxxxxxWwRLrlM where M is set if there was a Mouse event, l/L is single/double left click, r/R is single/double right click, w/W is mouse wheel up/down, x/y are mouse coordinates, and k is the KEY (0 means no key pressed)\n");			
			}
			return 0;
		}
		
		if (argc > 2) wtime = atoi(argv[2]);

		GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &oldfdwMode);

		fdwMode = oldfdwMode | ENABLE_EXTENDED_FLAGS  | ENABLE_MOUSE_INPUT;
		fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
		SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), fdwMode);

		if (wtime > -1) {
			res = WaitForSingleObject(GetStdHandle(STD_INPUT_HANDLE), wtime);
			if (res & WAIT_TIMEOUT) { printf(mouse_output); return -1; }
		}

		res = -1;
		ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), irInBuf, 128, &cNumRead);
		for (i = 0; i < cNumRead; i++) {
			switch(irInBuf[i].EventType) { 
			case MOUSE_EVENT:
				res = MouseEventProc(irInBuf[i].Event.MouseEvent, bKeyAndMouse, mouse_output);
				bMouseEvent = 1;
				break; 
			case KEY_EVENT:
				if (bReadKeys) {
					WriteConsoleInput(GetStdHandle(STD_INPUT_HANDLE), &irInBuf[i], 1, &j);
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
			res2 = WaitForSingleObject(GetStdHandle(STD_INPUT_HANDLE), 1);
			if (!(res2 & WAIT_TIMEOUT))
				ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), irInBuf, 128, &cNumRead);

			if (k!=-1) {
				if (bKeyAndMouse)
					res = (res > 0? res : 0) | (k<<22);
				else
					res = 1|(k<<1);
			}
		}

		if (k == -1) k = 0;
		if (bMouseEvent)
			printf("EVENT KEY_EVENT %d %s\n", k, mouse_output);
		else
			printf("EVENT KEY_EVENT %d MOUSE_EVENT 0\n", k);
		
		SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), oldfdwMode);
		return res;
	}
	else if (stricmp(argv[1],"moveblock") == 0) {
		COORD np;
		SMALL_RECT r;
		SMALL_RECT cl;
		CHAR_INFO chiFill;
		CONSOLE_SCREEN_BUFFER_INFO info;
		int w, h;

		if (argc < 8 || bInfo) { printf("\nUsage: cmdwiz moveblock [x y width height newX newY]\n"); return 0; }
		r.Left = atoi(argv[2]);
		r.Top = atoi(argv[3]);
		w = atoi(argv[4]);
		h = atoi(argv[5]);
		r.Right = r.Left + w-1;
		r.Bottom = r.Top + h-1;
		if (r.Right < 0 || r.Bottom < 0) return 1;
		np.X = atoi(argv[6]);
		np.Y = atoi(argv[7]);
		chiFill.Attributes = FOREGROUND_RED;
		if (GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info))
			chiFill.Attributes = info.wAttributes;
		chiFill.Char.AsciiChar = ' ';
		cl.Left=np.X; cl.Top=np.Y; cl.Right=np.X+w; cl.Bottom=np.Y+h; //not working (tried to copy instead of moving). Hence the NULL below.
		ScrollConsoleScreenBuffer(GetStdHandle(STD_OUTPUT_HANDLE), &r, NULL, np, &chiFill);
		return 0;
	}
	else if (stricmp(argv[1],"copyblock") == 0) {
		if (argc < 8 || bInfo) { printf("\nUsage: cmdwiz copyblock [x y width height newX newY]\n"); return 0; }
		return CopyBlock(atoi(argv[2]),atoi(argv[3]),atoi(argv[4]),atoi(argv[5]),atoi(argv[6]),atoi(argv[7]));
	}
	else if (stricmp(argv[1],"await") == 0) {
		int startT, waitT;
		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz await [oldtime] [waittime]\n"); return 0; }
		startT = atoi(argv[2]);
		waitT = atoi(argv[3]);

		while (GetTickCount() < startT+waitT) {
			Sleep(1);
		}
	}
	else if (stricmp(argv[1],"getconsolecolor") == 0) {
		CONSOLE_SCREEN_BUFFER_INFO info;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getconsolecolor [fg|bg]\n\nRETURN: Console color 0-15, or -1 on error\n"); return 0; }

		if (!GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info))
			return -1;

		return argv[2][0]=='f'? info.wAttributes & 0xf : (info.wAttributes >> 4) & 0xf;
	}
	else if (stricmp(argv[1],"showcursor") == 0) {
		CONSOLE_CURSOR_INFO c;
		BOOL result;
		int retVal;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz showcursor [0|1] [show percentage 1-100 (default 25)]\n\nRETURN: 0 if cursor was previously off, otherwise the previous show percentage\n"); return 0; }

		result = GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), &c);
		if (!result)
			return -1;
		if (c.bVisible == FALSE)
			retVal = 0;
		else
			retVal = c.dwSize;
		
		c.bVisible = argv[2][0] == '0'? FALSE : TRUE;
		c.dwSize = 25;
		if (argc > 3) {
			c.dwSize = atoi(argv[3]);
			if (c.dwSize < 1 || c.dwSize > 100)
				c.dwSize = 25;
		}
		result = SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), &c);
		if (!result)
			return -1;
		return retVal;
	}
	else if (stricmp(argv[1],"stringfind") == 0) {
		int index = 0;
		char *cp;

		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz stringfind [orgstring findstring] [startindex] [noCase]\n\nRETURN: Index of findstring in orgstring, or -1 if not found\n"); return 0; }
		if (argc > 4) { index = atoi(argv[4]); if (index < 0 || index >= strlen(argv[2])) return -1; }
		if (argc > 5) { 
			int i;
			for (i = 0; i < strlen(argv[2]); i++) argv[2][i] = toupper(argv[2][i]);
			for (i = 0; i < strlen(argv[3]); i++) argv[3][i] = toupper(argv[3][i]);
		}

		cp = strstr(&(argv[2][index]), argv[3]);		
		if (!cp) return -1;
		return (int)(cp - (char *)argv[2]);
	}
	else if (stricmp(argv[1],"stringlen") == 0) {
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz stringlen [string]\n\nRETURN: Length of string\n"); return 0; }

		return strlen(argv[2]);
	}
	else if (stricmp(argv[1],"getexetype") == 0) {
		SHFILEINFO sfi = {0};
		DWORD_PTR ret = 0;
		WORD hi, lo;
		
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getexetype [file]\n\nRETURN: -1 (Error), 0 (Unknown), 1 (Console or .bat), 2 (MS-DOS), 3 (Windows)\n"); return 0; }

		ret = SHGetFileInfo(argv[2], 0, &sfi, sizeof(sfi), SHGFI_EXETYPE);

		if (ret == 0) return 0;

		hi = HIWORD(ret);
		lo = LOWORD(ret);

		if (lo == 0x4550 && hi == 0)
			return 1;
		else if (lo == 0x5A4D && hi == 0)
			return 2;
		else if ((lo == 0x4550 || lo == 0x454E) && hi != 0)
			return 3;

		return -1;
	}
	else if (stricmp(argv[1],"inspectblock") == 0) {
		char glyphs[128];
		int i, inspChar;
		
		if (argc < 8 || bInfo) { printf("\nUsage: cmdwiz inspectblock [x y width height inclusive|exclusive char1] [char2] [char3] ...\n\nRETURN: Bit pattern, where char1 is bit 1, char 2 is bit 2, etc. -1 on error.\n"); return 0; }
		for (i = 7; i < argc; i++) {
			if (argv[i][1]==0)
				inspChar = argv[i][0];
			else
				inspChar = strtol(argv[i], NULL, 16);
			glyphs[i-7] = inspChar;
		}
		glyphs[i-7] = 0;
		
		return InspectBuffer(GetStdHandle(STD_OUTPUT_HANDLE), atoi(argv[2]), atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), argv[6][0]=='e', glyphs);
	}
	else if (stricmp(argv[1],"saveblock") == 0) {
		int result;
		int encodeMode = 1;
		int transpChar = -1, transpFg = -1, transpBg = -1;

		if (argc < 7 || bInfo) { printf("\nUsage: cmdwiz saveblock [filename x y width height] [encode|forcecode|nocode|txt] [transparent char] [transparent bgcolor] [transparent fgcolor]\n\nRETURN: 0 on success, 1 for file write error, 2 for invalid block\n"); return 0; }
		if (argc>7) {
			if (argv[7][0]=='n') encodeMode = 0;
			if (argv[7][0]=='f') encodeMode = 2;
			if (argv[7][0]=='t') encodeMode = 3;
		}
		if (argc>8) {
			if (argv[8][1]==0)
				transpChar = argv[8][0];
			else
				transpChar = strtol(argv[8], NULL, 16);
		}
		if (argc>9) transpBg = atoi(argv[9]);
		if (argc>10) transpFg = atoi(argv[10]);

		result = SaveBlock(argv[2], atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]), encodeMode, transpChar, transpBg, transpFg);
		if (result == 1) printf("Error: Could not write file\n");
		if (result == 2) printf("Error: Invalid block\n");
		return result;
	}
	else if (stricmp(argv[1],"setcursorpos") == 0) {
      int xp, yp;
		
		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setcursorpos [x|keep y|keep]\n"); return 0; }
		xp = atoi(argv[2]);
		yp = atoi(argv[3]);
		if (argv[2][0] == 'k') { GetXY(&xp, NULL); }
		if (argv[3][0] == 'k') { GetXY(NULL, &yp); }
		GotoXY(GetStdHandle(STD_OUTPUT_HANDLE), xp, yp);
		return 0;
	}
	else if (stricmp(argv[1],"print") == 0) {
		char *token;
		int i = 0, bFirst = 0;
		
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz print [\"string\"]\nSupported formatting is \\n \\r \\t \\a \\b \\\\\n"); return 0; }
		if (argv[2][0] == '\\') bFirst=1;

		for (i = 0; i < strlen(argv[2]); i++) {
			if (argv[2][i] == '\\' && argv[2][i+1] == '\\')
				argv[2][i+1] = 1;
		}
		i = 0;
		token = strtok(argv[2], "\\");
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
			printf("%s", token);
			
			token = strtok(NULL, "\\");
			i++;
		}

		return 0;
	}
	else if (stricmp(argv[1],"insertbmp") == 0) {
		int x,y,z = 100, w = -1, h = -1;
	
		if (argc < 5 || bInfo) { printf("\nUsage: cmdwiz insertbmp [file.bmp x y] [[z]|[w h]]\n\nRETURN: 0 on success, 1 if failed to load file\n"); return 0; }

		x = atoi(argv[3]);
		y = atoi(argv[4]);
		if (argc > 5) z = atoi(argv[5]);
		if (argc > 6) { w = atoi(argv[5]); h = atoi(argv[6]); }

		if (Fn_LoadBmp(argv[2], x, y, z, w, h) == EXIT_SUCCESS) return 0; else return 1;
	}
	else if (stricmp(argv[1],"setwindowtransparency") == 0) {
		int percentage = -1;
		if (argc > 2) percentage = atoi(argv[2]);
		
		if (percentage < 0 || percentage > 100 || bInfo) { printf("\nUsage: cmdwiz setwindowtransparency [0-100]\n"); return 0; }
		
		f_SetConsoleTransparency(percentage);
		return 0;
	}
	else if (stricmp(argv[1],"setwindowpos") == 0) {
		RECT bounds;
		int x, y;
		HWND hWnd = GetConsoleWindow();

		if (!hWnd) return -1;
		GetWindowRect(hWnd, &bounds);
		
		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setwindowpos [x|keep y|keep]\n"); return 0; }
		x = atoi(argv[2]); if (argv[2][0]=='k') x = bounds.left;
		y = atoi(argv[3]); if (argv[3][0]=='k') y = bounds.top;
		
		SetWindowPos(hWnd, HWND_TOP, x, y, bounds.right-bounds.left, bounds.bottom-bounds.top, 0); // HWND_TOPMOST is "always on top"
		return 0;
	}
	else if (stricmp(argv[1],"getwindowbounds") == 0) {
		RECT bounds;
		HWND hWnd;
		int pos = -1;
		hWnd = GetConsoleWindow();
				
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getwindowbounds [x|y|w|h]\n\nRETURN: The requested value in ERRORLEVEL\n"); return 0; }
		GetWindowRect(hWnd, &bounds);

		if (argv[2][0] == 'y') return bounds.top;
		if (argv[2][0] == 'w') return bounds.right - bounds.left;
		if (argv[2][0] == 'h') return bounds.bottom - bounds.top;
		return bounds.left;
	}
	else if (stricmp(argv[1],"gettitle") == 0) {
		char title[1024];

		if (bInfo) { printf("\nUsage: cmdwiz gettitle\n\nRETURN: Prints the title of the console\n"); return 0; }		
		
		GetConsoleTitle(title, 1023);
		printf("%s\n", title);
		return 0;
	}
	else if (stricmp(argv[1],"getdisplaydim") == 0) {
		int bW = 0;

		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getdisplaydim [w|h]\n\nRETURN: The requested screen dimension in ERRORLEVEL\n"); return 0; }
		if (argv[2][0] == 'w') bW = 1;

		return GetSystemMetrics(bW ? SM_CXSCREEN : SM_CYSCREEN);
	}
	else if (stricmp(argv[1],"setmousecursorpos") == 0) {
		int x, y;
		int click = 0;
		INPUT Input = {0};
		POINT pos;

		GetCursorPos(&pos);

		if (argc < 4 || bInfo) { printf("\nUsage: cmdwiz setmousecursorpos [x|keep y|keep] [l|r|d|u]\n"); return 0; }
		x = atoi(argv[2]); if (argv[2][0]=='k') x = pos.x;
		y = atoi(argv[3]); if (argv[3][0]=='k') y = pos.y;
		if (argc > 4) { if (argv[4][0]=='l') click = 1; if (argv[4][0]=='r') click = 2; if (argv[4][0]=='d') click = 3; if (argv[4][0]=='u') click = 4; } 

		SetCursorPos(x,y);

		if (click > 0) {
			if (click != 4) {
				Input.type = INPUT_MOUSE;
				Input.mi.dwFlags = click!=2? MOUSEEVENTF_LEFTDOWN : MOUSEEVENTF_RIGHTDOWN;
				SendInput(1,&Input,sizeof(INPUT));
			}

			if (click != 3) {
				ZeroMemory(&Input,sizeof(INPUT));
				Input.type = INPUT_MOUSE;
				Input.mi.dwFlags = click!=2? MOUSEEVENTF_LEFTUP : MOUSEEVENTF_RIGHTUP;
				SendInput(1,&Input,sizeof(INPUT));
			}
		}
		return 0;
	}
	else if (stricmp(argv[1],"getmousecursorpos") == 0) {
		POINT pos;
		int bX = 0;
				
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz getmousecursorpos [x|y]\n\nRETURN: The requested mouse cursor position dimension in ERRORLEVEL\n"); return 0; }
		if (argv[2][0] == 'x') bX = 1;
		
		GetCursorPos(&pos);
		return bX ? pos.x : pos.y;
	}
	else if (stricmp(argv[1],"setfont") == 0) {
		int index = -1;
		
		if (argc > 2 && strlen(argv[2]) == 1) index = atoi(argv[2]);
		if (argc < 3 || (strlen(argv[2])==1 && (index < 0 || index > 9)) || bInfo) { printf("\nUsage: cmdwiz setfont [0-9|filename]\n"); return 0; }

		if (index == -1)
			return SetFontFromFile(argv[2]);
		else
			return SetFont(index);
	}
	else if (stricmp(argv[1],"savefont") == 0) {
		CONSOLE_FONT_INFOEX fontInfo;
		FILE *ofp;
		int res;
		
		if (argc < 3 || bInfo) { printf("\nUsage: cmdwiz savefont [filename]\n"); return 0; }

		res = GetFont(&fontInfo);
		
		if (res) return 1;
		
		ofp = fopen(argv[2], "wb");
		if (!ofp) { printf("Error: could not save font\n"); return 1; }
		
		fwrite(&fontInfo, sizeof(CONSOLE_FONT_INFOEX),1,ofp);
		fclose(ofp);
		
		return 0;
	}
	// want operation to hide/show mouse cursor, but not possible in console window according to http://stackoverflow.com/questions/16110898/how-can-i-hide-the-mouse-cursor
	else {
		printf("Error: unknown operation\n");
		return 0;
	}

	return 0; 
}
