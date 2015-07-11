/* CmdWiz (c) 2015 Mikael Sollenborn */

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <conio.h>

// Compilation with tcc: tcc -lwinmm -luser32 -o cmdwiz.exe cmdwiz.c

#define BUFW 0
#define BUFH 1
#define SCRW 2
#define SCRH 3
#define CURRX 4
#define CURRY 5

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
  *x = csbInfo.dwCursorPosition.X;
  *y = csbInfo.dwCursorPosition.Y;
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
  COORD b;
  SMALL_RECT r;
  CHAR_INFO str[81];
  CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;

  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
  if (y > screenBufferInfo.dwSize.Y || y < 0) return 0;
  if (x > screenBufferInfo.dwSize.X || x < 0) return 0;

  b.X = 0;
  b.Y = 0;

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

char DecToHex(int i) {
  switch(i) {
    case 0:case 1:case 2:case 3:case 4:case 5:case 6:case 7:case 8:case 9: i=i+'0'; break;
    case 10:case 11:case 12:case 13:case 14:case 15: i = 'A'+(i-10); break;
	default: i = '0';
  }
  return i;
}

char *GetAttribs(WORD attributes, char *utp) {
  utp[0] = '\\';
  utp[1] = DecToHex(attributes & 0xf);
  utp[2] = DecToHex((attributes >> 4) & 0xf);
  utp[3] = 0;
  return utp;
}

#define BUF_SIZE 64000
#define STR_SIZE 12000

int SaveBlock(char *filename, int x, int y, int w, int h, int bEncode, int transpChar, int transpBg, int transpFg) {
  COORD a = { 1, 1 };
  COORD b;
  SMALL_RECT r;
  CHAR_INFO *str;
  char *output, attribS[8], charS[4];
  CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
  WORD oldAttrib = 6666;
  FILE *ofp = NULL;
  int i, j;
  unsigned char ch;
  char fName[512];

  sprintf(fName, "%s.gxy", filename);
  ofp = fopen(fName, "w");
  if (!ofp) return 1;

  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
  if (y > screenBufferInfo.dwSize.Y || y < 0) return 2;
  if (x > screenBufferInfo.dwSize.X || x < 0) return 2;
  if (y+h > screenBufferInfo.dwSize.Y || h < 1) return 2;
  if (x+w > screenBufferInfo.dwSize.X || w < 1) return 2;

  output = (char*) malloc(BUF_SIZE);
  if (!output) return 3;
  output[0] = 0;
  str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * STR_SIZE);
	if (!str) {
	  free(output);
	  return 3;
  }

  b.X = 0;
  b.Y = 0;

  a.X = w;
  a.Y = h;

  r.Left = x;
  r.Top = y;
  r.Right = x + w;
  r.Bottom = y + h;
  ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str, a, b, &r);

  for (j=0; j < h; j++) {
    output[0]=0;
	for (i=0; i < w; i++) {
	    ch = str[i + j*w].Char.AsciiChar;
		if ((ch==transpChar && transpChar >-1) && (transpFg == -1 || transpFg == (str[i + j*w].Attributes & 0xf))  && (transpBg == -1 || transpBg == ((str[i + j*w].Attributes>>4) & 0xf)) ) {
		    charS[0] = '\\'; charS[1]='-'; charS[2]=0;
		}
		else if (bEncode || ch=='\\') {
		  if (bEncode > 1 || !(ch ==32 || (ch >='0' && ch <='9') || (ch >='A' && ch <='Z') || (ch >='a' && ch <='z'))) {
			int v;
		    charS[0] = '\\'; charS[1] = 'g';
		    v = ch / 16; charS[2]=DecToHex(v);
		    v = ch % 16; charS[3]=DecToHex(v);
            charS[4]=0;
		  } else {
		    charS[0] = ch; charS[1]=0;
		  }
		} else {
		  charS[0] = ch; charS[1]=0;
		}

		if (oldAttrib == str[i + j*w].Attributes)
   			sprintf(output, "%s%s", output, charS);
		else
			sprintf(output, "%s%s%s", output, GetAttribs(str[i + j*w].Attributes, attribS), charS);
		oldAttrib = str[i + j*w].Attributes;
	}
	fprintf(ofp, "%s\\n", output);
  }
  
  free(str);
  free(output);
  
  fclose(ofp);
  return 0;
}


void CopyBlock(int x, int y, int w, int h, int dx, int dy) {
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


int MouseEventProc(MOUSE_EVENT_RECORD mer, int bKeyAndMouse) {
    int res = 0;
	if (bKeyAndMouse)
      res = (mer.dwMousePosition.X << 7) | (mer.dwMousePosition.Y << 14);
	else
      res = (mer.dwMousePosition.X << 10) | (mer.dwMousePosition.Y << 19);

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
	return res;
}

/* void ResizeEventProc(WINDOW_BUFFER_SIZE_RECORD wbsr) {
    printf("Resized. Console screen buffer is %d columns by %d rows.\n", wbsr.dwSize.X, wbsr.dwSize.Y);
}*/

int main(int argc, char **argv) {
  int delayVal = 0;

  if (argc < 2) { printf("\nUsage: cmdwiz [getconsoledim setbuffersize getch getkeystate quickedit getmouse getch_or_mouse getch_and_mouse getcharat getcolorat showcursor getcursorpos saveblock copyblock moveblock playsound delay gettime await] [params]\n"); return 0; }
  
  if (stricmp(argv[1],"delay") == 0) {
	if (argc < 3) { printf("\nUsage: cmdwiz delay [ms]\n"); return 0; }

	delayVal=atoi(argv[2]);
	if (delayVal < 1) return 0;
	Sleep(delayVal);
  }
  else if (stricmp(argv[1],"getconsoledim") == 0) {
	int dim = BUFW;
	if (argc < 3) { printf("\nUsage: cmdwiz getconsoledim [x|y|sx|sy|cx|cy]\n"); return 0; }
    if (argv[2][0] == 'x') dim = BUFW;
    if (argv[2][0] == 'y') dim = BUFH;
    if (argv[2][0] == 's') if (argv[2][1] == 'x') dim = SCRW;
    if (argv[2][0] == 's') if (argv[2][1] == 'y') dim = SCRH;
    if (argv[2][0] == 'c') if (argv[2][1] == 'x') dim = CURRX;
    if (argv[2][0] == 'c') if (argv[2][1] == 'y') dim = CURRY;
	return GetDim(dim);
  }
  else if (stricmp(argv[1],"setbuffersize") == 0) {
    COORD nb;

	if (argc < 4) { printf("\nUsage: cmdwiz setbuffersize [width height]\n"); return 0; }
    nb.X = atoi(argv[2]);
    nb.Y = atoi(argv[3]);
	SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), nb);
	return 0;
  }
  else if (stricmp(argv[1],"getch") == 0) {
	int k;
	if (argc > 2) if (!kbhit()) return 255;
	k = getch();

	if (k == 224) k = 256+getch();
	if (k == 0) k = 512+getch();
	return k;
  }
  else if (stricmp(argv[1],"getkeystate") == 0) {
    // https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
	int i, j, k = 0;
	char buf[128];
	if (argc < 3) { printf("\nUsage: cmdwiz getkeystate [all|[l|r]ctrl|[l|r]alt|[l|r]shift|VKEY1[h]] ...\n"); return 0; }

	if (stricmp(argv[2],"all") == 0) {
	  int vKeys[16] = { VK_SHIFT, VK_LSHIFT, VK_RSHIFT, VK_CONTROL, VK_LCONTROL, VK_RCONTROL, VK_MENU, VK_LMENU, VK_RMENU }; 
	  for (i = 0; i < 9; i++) {
	     j = GetAsyncKeyState(vKeys[i]);
		 k = (k<<1) | ((j & 0x8000)? 1:0 );
      }
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
	return k;
  }
  else if (stricmp(argv[1],"playsound") == 0) {
	if (argc < 3) { printf("\nUsage: cmdwiz playsound [filename]\n"); return 0; }
    PlaySound(argv[2], NULL, 0x00020000L|0x0002); // SND_FILENAME | SND_NODEFAULT
    return 0;
  }
  else if (stricmp(argv[1],"getcharat") == 0) {
	int x, y;
	int ox, oy;
	int i;
	// printf("\nUsage: cmdwiz getcharat [x|k] [y|k]");
	GetXY(&ox, &oy);
  
	if (argc > 2) { if (argv[2][0]!='k') x=atoi(argv[2]); else x=ox; } else x=ox;
	if (argc > 3) { if (argv[3][0]!='k') y=atoi(argv[3]); else y=oy; } else y=oy;

	i = ReadCharProperty(x,y,CHARPROP_CHAR);
	if (i<0) i = 256+i;
	return i;
  }
  else if (stricmp(argv[1],"getcolorat") == 0) {
	int x, y;
	int ox, oy;
	int i;
	
	if (argc < 3) { printf("\nUsage: cmdwiz getcolorat [fg|bg] [x|k] [y|k]\n"); return 0; }

	GetXY(&ox, &oy);
  
	if (argc > 3) { if (argv[3][0]!='k') x=atoi(argv[3]); else x=ox; } else x=ox;
	if (argc > 4) { if (argv[4][0]!='k') y=atoi(argv[4]); else y=oy; } else y=oy;

	i = ReadCharProperty(x,y,argv[2][0]=='f'? CHARPROP_FGCOL : CHARPROP_BGCOL);
	return i;
  }
  else if (stricmp(argv[1],"getcursorpos") == 0) {
	int ox, oy;

	if (argc < 3) { printf("\nUsage: cmdwiz getcursorpos [x|y]\n"); return 0; }
	GetXY(&ox, &oy);

	return argv[2][0]=='x'? ox : oy;
  }
  else if (stricmp(argv[1],"gettime") == 0) {
	return GetTickCount();
  }
  else if (stricmp(argv[1],"quickedit") == 0) {
    DWORD fdwMode;
	int i;
	if (argc < 3) { printf("\nUsage: cmdwiz quickedit [0|1]\n"); return 0; }
	i = atoi(argv[2]);
	
    GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &fdwMode);

	fdwMode = fdwMode | ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT; 
    if (i == 0)
      fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
	else
      fdwMode = fdwMode | ENABLE_QUICK_EDIT_MODE;

    SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), fdwMode);
  }
  else if (stricmp(argv[1],"getmouse") == 0 || stricmp(argv[1],"getch_or_mouse") == 0 || stricmp(argv[1],"getch_and_mouse") == 0) {
    DWORD fdwMode, oldfdwMode, cNumRead, j; 
    INPUT_RECORD irInBuf[128]; 
	int wtime = -1, i, res, res2, bReadKeys = 0, bWroteKey = 0, bKeyAndMouse = 0, k = 0;

    if (!(stricmp(argv[1],"getmouse") == 0))
	  bReadKeys = 1;
    if (stricmp(argv[1],"getch_and_mouse") == 0)
	  bKeyAndMouse = 1;
	
	// if (argc < 3) { printf("\nUsage: cmdwiz getmouse [maxWait]\n"); return -1; }
	if (argc > 2) wtime = atoi(argv[2]);
	
    GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &oldfdwMode);

	fdwMode = oldfdwMode | ENABLE_EXTENDED_FLAGS  | ENABLE_MOUSE_INPUT;
    fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
    SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), fdwMode);

	if (wtime > -1) {
	  res = WaitForSingleObject(GetStdHandle(STD_INPUT_HANDLE), wtime);
	  if (res & WAIT_TIMEOUT) return -1;
	}

	res = -1;
    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), irInBuf, 128, &cNumRead);
    for (i = 0; i < cNumRead; i++) {
      switch(irInBuf[i].EventType) { 
        case MOUSE_EVENT:
          res = MouseEventProc(irInBuf[i].Event.MouseEvent, bKeyAndMouse);
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
	
	if (bWroteKey) {
	  k = -1;
	  if (kbhit()) {
	    k=getch();
	    if (k == 224) k = 256+getch();
	    if (k == 0) k = 512+getch();
   	  }
	  res2 = WaitForSingleObject(GetStdHandle(STD_INPUT_HANDLE), 1);
	  if (!(res2 & WAIT_TIMEOUT))
	    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), irInBuf, 128, &cNumRead);
		
	  if (k!=-1) {
		if (bKeyAndMouse)
 	      res = (res > 0? res : 0) | (k<<21);
		else
 	      res = 1|(k<<1);
	  }
	}
	
    SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), oldfdwMode);
	return res;
  }
  else if (stricmp(argv[1],"moveblock") == 0) {
    COORD np;
	SMALL_RECT r;
	SMALL_RECT cl;
    CHAR_INFO chiFill;
	int w, h;

	if (argc < 8) { printf("\nUsage: cmdwiz moveblock [x y width height newX newY]\n"); return 0; }
	r.Left = atoi(argv[2]);
	r.Top = atoi(argv[3]);
	w = atoi(argv[4]);
	h = atoi(argv[5]);
	if (r.Right < 0 || r.Bottom < 0) return 1;
	r.Right = r.Left + w-1;
	r.Bottom = r.Top + h-1;
    np.X = atoi(argv[6]);
    np.Y = atoi(argv[7]);
    chiFill.Attributes = FOREGROUND_RED; chiFill.Char.AsciiChar = ' ';
	cl.Left=np.X; cl.Top=np.Y; cl.Right=np.X+w; cl.Bottom=np.Y+h; //not working (tried to copy instead of moving). Hence the NULL below.
	
    ScrollConsoleScreenBuffer(GetStdHandle(STD_OUTPUT_HANDLE), &r, NULL, np, &chiFill);
	return 0;
  }
  else if (stricmp(argv[1],"copyblock") == 0) {
	if (argc < 8) { printf("\nUsage: cmdwiz copyblock [x y width height newX newY]\n"); return 0; }
	CopyBlock(atoi(argv[2]),atoi(argv[3]),atoi(argv[4]),atoi(argv[5]),atoi(argv[6]),atoi(argv[7]));
	return 0;
  }
  else if (stricmp(argv[1],"await") == 0) {
	int startT, waitT;
	if (argc < 4) { printf("\nUsage: cmdwiz await [oldtime] [waittime]\n"); return 0; }
	startT = atoi(argv[2]);
	waitT = atoi(argv[3]);
    
	while (GetTickCount() < startT+waitT) {
		Sleep(1);
	}
  }
  else if (stricmp(argv[1],"showcursor") == 0) {
	CONSOLE_CURSOR_INFO c;

	if (argc < 3) { printf("\nUsage: cmdwiz showcursor [0|1] [show percentage 0-100 (default 25)]\n"); return 0; }

	c.bVisible = argv[2][0] == '0'? FALSE : TRUE;
	c.dwSize = 25;
	if (argc > 3)
		c.dwSize = atoi(argv[3]);
	SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), &c);
  }
  else if (stricmp(argv[1],"saveblock") == 0) {
    int result;
	int encodeMode = 1;
    int transpChar = -1, transpFg = -1, transpBg = -1;
	
	if (argc < 7) { printf("\nUsage: cmdwiz saveblock [filename x y width height] [encode|forcecode|nocode] [transparent char] [transparent bgcolor] [transparent fgcolor]\n"); return 0; }
    if (argc>7) {
	  if (argv[7][0]=='n') encodeMode = 0;
	  if (argv[7][0]=='f') encodeMode = 2;
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
  else {
	printf("Error: unknown operation\n");
	return 0;
  }
 
  return 0; 
}
