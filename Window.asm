include ..\..\..\..\..\masm32\include\masm32rt.inc
include ..\..\..\..\..\masm32\include\opengl32.inc


includelib \masm32\lib\opengl32.lib

; macro for string uses in functions like a high level programing language
; USAGE: invoke printf, chr$("hello")
chr$ MACRO any_text:VARARG
LOCAL txtname
.data
    IFDEF __UNICODE__
    WSTR txtname,any_text
    align 4
    .code
    EXITM <OFFSET txtname>
    ENDIF

    txtname db any_text,0
    align 4
    .code
    EXITM <OFFSET txtname>
ENDM

; function defines
WinMain proto :HINSTANCE, :HINSTANCE, :LPSTR, :DWORD
WndProc proto :HWND, :UINT, :WPARAM, :LPARAM
DrawGLScene proto

public mouseCoords, w, h

.data 
; data for opengl and win32
hRC HGLRC ?
hDC HDC ?
hWnd HWND ?
hInstance HINSTANCE ?

lpzCmdLine dd ? ; get cmd line args to call winMain

mouseCoords POINT {} ; mouseCoords struct

w dword 1280 ; window height
h dword 720 ; window width

isActive BOOLEAN ? ; isActive - true if window is selected 

keys BOOLEAN 256 dup(?) ; an arrray for key presses
.code

start:
invoke GetModuleHandle, null
mov hInstance, eax

invoke GetCommandLine
mov lpzCmdLine, eax

invoke WinMain, hInstance, null, lpzCmdLine, SW_SHOWDEFAULT 
invoke ExitProcess, eax

;╔══════════════════════════════════════════╗
;║				ReSizeGLScene				║
;║			changes the viewport			║
;║ @param _width the width of the window	║
;║ @param _height the height of the window	║
;║ @return void								║
;╚══════════════════════════════════════════╝
ReSizeGLScene proc _width :dword, _height: dword
;╭⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮
;│		same as doing		│
;├⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┤
;│ push ebp					│
;│ mov ebp,esp				│
;│ _width equ 8				│
;│ _height equ 12			│
;│ sub esp,	0				│
;╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯
.if _height == 0 
	mov _height, 1
.endif

invoke glViewport, 0, 0, _width, _height 
ret
ReSizeGLScene endp

;╔══════════════════════════════════════════╗
;║					InitGL					║
;║  initialsing all the stuff for open gl	║	
;╚══════════════════════════════════════════╝
InitGL proc

invoke glShadeModel, GL_SMOOTH

invoke glClearColor, FP4(0.0), FP4(0.0), FP4(0.0), FP4(0.0)
invoke glClearDepth, FP8(1.0)

invoke glEnable, GL_DEPTH_TEST
invoke glDepthFunc, GL_LEQUAL

invoke glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST

mov eax, true
ret
InitGL endp


;╔══════════════════════════════════════════╗
;║				KillGLWindow				║
;║		trys to kill the rendering conext	║
;╚══════════════════════════════════════════╝

KillGLWindow proc

.if hRC
	invoke wglMakeCurrent, null, null
	.if !eax
		invoke MessageBox, null, chr$("Release Of DC and RC Failed."), chr$("SHUTDOWN ERROR"),MB_OK or MB_ICONINFORMATION
	.endif
	
	invoke wglDeleteContext, hRC
	.if !eax
		invoke MessageBox, null, chr$("Release Rendering Context Failed."), chr$("SHUTDOWN ERROR"), MB_OK or MB_ICONINFORMATION
	.endif
	mov hRC, null
	
	invoke ReleaseDC, hWnd, hDC
	.if !eax && hDC
		invoke MessageBox, null, chr$("Release Device Context Failed."), chr$("SHUTDOWN ERROR"), MB_OK or MB_ICONINFORMATION
		mov hDC, null
	.endif

	invoke DestroyWindow, hWnd
	.if hWnd && !eax
		invoke MessageBox, null, chr$("Could Not Release hWnd."), chr$("SHUTDOWN ERROR"), MB_OK or MB_ICONINFORMATION
		mov hWnd, null
	.endif

	invoke UnregisterClass, chr$("OpenGL"), hInstance
	.if !eax
		invoke MessageBox, null, chr$("Could Not Unregister Class."), chr$("SHUTDOWN ERROR"), MB_OK or MB_ICONINFORMATION
		mov hInstance, null
	.endif
.endif
ret
KillGLWindow endp
;╔══════════════════════════════════════════════════════╗
;║					CreateGlWindow						║
;║	Creates a Window with OpenGL rendering context		║
;║		@param _title a string for the title			║
;║		@param _width the width of the window			║
;║		@param _height the height of the window			║
;║		@param bits the bit depth of the window			║
;║		@returns true if window creation was succsusful	║
;╚══════════════════════════════════════════════════════╝
CreateGLWindow proc _title :DWORD,
					_width :DWORD,
					_height :DWORD,
					bits :DWORD
	
	local PixelFormat :GLuint
	local wc :WNDCLASS
	local dwExStyle :DWORD
	local dwStyle :DWORD
	local pfd :PIXELFORMATDESCRIPTOR

	local rect :RECT

	;╭⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮
	;│		same as doing								│
	;├⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┤
	;│ push ebp											│
	;│ mov ebp,esp										│
	;│ _title equ 8										│
	;│ _width equ 12									│
	;│ _height equ 16									│
	;│ bits equ 20										│
	;│ PixelFormat equ 4								│
	;│ wc equ PixelFormat + SIZEOF WNDCLASS				│
	;│ dwExStyle equ wc + 4								│
	;│ dwStyle equ dwExStyle + 4						│
	;│ pfd equ dwStyle + SIZEOF PIXELFORMATDESCRIPTOR	│
	;│ rect equ pfd + SIZEOF RECT						│
	;│ sub esp,	rect									│
	;╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯

	mov rect.left, 50 ;starting pos x
	mov eax, rect.left 
	add eax, _width
	mov rect.right,eax ; width
	mov rect.top, 50
	mov eax, rect.top ; startnig pos y
	add eax, _height
	mov rect.bottom, eax ; height

	invoke GetModuleHandle, null
	mov hInstance, eax
	mov wc.style, CS_HREDRAW or CS_VREDRAW or CS_OWNDC
	mov wc.lpfnWndProc, WndProc
	mov wc.cbClsExtra, 0
	mov wc.cbWndExtra, 0
	mov eax, hInstance
	mov wc.hInstance, eax

	invoke LoadIcon, null, IDI_WINLOGO
	mov wc.hIcon, eax

	invoke LoadCursor, null, IDC_ARROW
	mov wc.hCursor, eax

	mov wc.hbrBackground, null
	mov wc.lpszMenuName, null
	mov wc.lpszClassName, chr$("OpenGL")

	invoke RegisterClass, addr wc
	.if !eax
		invoke MessageBox, null, chr$("Failed To Register The Window Class."), chr$("ERROR"), MB_OK or MB_ICONEXCLAMATION
		mov eax, false
		ret
	.endif

	mov dwExStyle, WS_EX_APPWINDOW or WS_EX_WINDOWEDGE
	mov dwStyle, WS_OVERLAPPEDWINDOW

	invoke AdjustWindowRectEx, addr rect, dwStyle, false, dwExStyle ; adjust the window for the specified width / height

	mov eax, rect.right
	sub eax, rect.left

	mov ebx, rect.bottom
	sub ebx, rect.
	or dwStyle, WS_CLIPSIBLINGS or WS_CLIPCHILDREN
	; create the window
	invoke CreateWindowEx, dwExStyle, chr$("OpenGL"), _title, dwStyle,
						   rect.left, rect.top, eax, ebx,
						   null, null, hInstance, null 
	mov hWnd, eax
	.if !hWnd ; if wasent succssful kill it
		invoke KillGLWindow
		invoke MessageBox, null, chr$("Window Creation Error."), chr$("ERROR"), MB_OK or MB_ICONEXCLAMATION
		mov eax, false
		ret
	.endif

	; change the pixel format
	mov pfd.nSize, SIZEOF PIXELFORMATDESCRIPTOR
	mov pfd.nVersion, 1
	mov pfd.dwFlags, PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER
	mov pfd.iPixelType, PFD_TYPE_RGBA
	mov eax, bits
	mov pfd.cColorBits, al
	mov pfd.cRedBits, 0
	mov pfd.cRedShift, 0
	mov pfd.cGreenBits, 0
	mov pfd.cGreenShift, 0
	mov pfd.cBlueBits, 0
	mov pfd.cBlueShift, 0
	mov pfd.cAlphaBits, 0
	mov pfd.cAlphaShift, 0
	mov pfd.cAccumBits, 0
	mov pfd.cAccumRedBits, 0
	mov pfd.cAccumGreenBits, 0
	mov pfd.cAccumBlueBits, 0
	mov pfd.cAccumAlphaBits, 0
	mov pfd.cDepthBits, 16
	mov pfd.cStencilBits, 0
	mov pfd.cAuxBuffers, 0
	mov pfd.iLayerType, PFD_MAIN_PLANE
	mov pfd.bReserved, 0
	mov pfd.dwLayerMask, 0
	mov pfd.dwVisibleMask, 0
	mov pfd.dwDamageMask, 0

	; create and set the pixel format and openGL context
	invoke GetDC, hWnd
	mov hDC, eax
	.if !hDC
		invoke KillGLWindow
		invoke MessageBox, null, chr$("Can't Create A GL Device Context."), chr$("ERROR"), MB_OK or MB_ICONEXCLAMATION
		mov eax, false
		ret
	.endif

	invoke ChoosePixelFormat, hDC, addr pfd
	mov PixelFormat, eax
	.if !PixelFormat
		invoke KillGLWindow
		invoke MessageBox, null, chr$("Can't Find A Suitable PixelFormat."), chr$("ERROR"), MB_OK or MB_ICONEXCLAMATION
		mov eax, false
		ret
	.endif

	invoke SetPixelFormat, hDC, PixelFormat, addr pfd
	.if !eax
		invoke KillGLWindow
		invoke MessageBox, null, chr$("Can't Set The PixelFormat."), chr$("ERROR"), MB_OK or MB_ICONEXCLAMATION
		mov eax, false
		ret
	.endif

	invoke wglCreateContext, hDC
	mov hRC, eax
	.if !hRC
		invoke KillGLWindow
		invoke MessageBox, null, chr$("Can't Create A GL Rendering Context."), chr$("ERROR"), MB_OK or MB_ICONEXCLAMATION
		mov eax, false
		ret
	.endif

	invoke wglMakeCurrent, hDC, hRC
	.if !eax
		invoke KillGLWindow
		invoke MessageBox, null, chr$("Can't Activate The GL Rendering Context"), chr$("ERROR"), MB_OK or MB_ICONEXCLAMATION
		mov eax, false
		ret
	.endif

	; show the window
	invoke ShowWindow, hWnd, SW_SHOW
	invoke SetForegroundWindow, hWnd
	invoke SetFocus, hWnd
	invoke ReSizeGLScene, _width, _height

	invoke InitGL
	.if !eax
		invoke KillGLWindow
		invoke MessageBox, null, chr$("Initialization Failed."), chr$("ERROR"), MB_OK or MB_ICONEXCLAMATION
		mov eax, false
		ret
	.endif

	mov eax, true
	ret
CreateGLWindow endp

WinMain proc hInst :HINSTANCE,
			 hPrevInst :HINSTANCE,
			 szCmdLine :LPSTR,
			 nShowCmd :dword

	local msg :MSG
	local done :BOOLEAN

	;╭⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮
	;│		same as doing		│
	;├⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┤
	;│ push ebp					│
	;│ mov ebp,esp				│
	;│ equ						│
	;│ equ						│
	;│ sub esp,					│
	;╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯
	mov done, false

	invoke CreateGLWindow,chr$("My Window"), 1280, 720, 16
	.if !eax
		xor eax, eax
		ret
	.endif

	.while !done
		invoke PeekMessage, addr msg, null, 0, 0, PM_REMOVE
		.if eax
			.if msg.message == WM_QUIT
				mov done, true
			.else
				invoke TranslateMessage, addr msg
				invoke DispatchMessage, addr msg
			.endif
		.else
			.if isActive
				.if keys + VK_ESCAPE
					mov done, true
				.else
					invoke DrawGLScene
					invoke SwapBuffers, hDC
				.endif
			.endif
		.endif
	.endw
		
	invoke KillGLWindow
	mov eax, msg.wParam
	ret
WinMain endp

WndProc proc hwnd :HWND,
			 uMsg :UINT,
			 wParam :WPARAM,
			 lParam :LPARAM

	local himask :WORD
	local lomask :WORD
	
	;╭⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮
	;│		same as doing		│
	;├⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┤
	;│ push ebp					│
	;│ mov ebp,esp				│
	;│ equ						│
	;│ equ						│
	;│ sub esp,					│
	;╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯

	.if uMsg == WM_CLOSE

		invoke PostQuitMessage, 0

		xor eax,eax
		ret
	.elseif uMsg == WM_LBUTTONDOWN
		
		mov eax, lParam
		mov ebx, eax
		and eax, 0ffffh
		shr ebx, 16

		mov mouseCoords.x, eax
		mov mouseCoords.y, ebx

		printf("x: %d, y: %d\n", mouseCoords.x, mouseCoords.y)
		xor eax, eax
		ret

	.elseif uMsg == WM_ACTIVATE
		mov eax, wParam
		mov lomask, ax
		shr eax, 16
		mov himask, ax
		.if !himask
			mov isActive, true
		.else
			mov isActive, false
		.endif
		xor eax, eax
		ret

	.elseif uMsg == WM_SYSCOMMAND
		.if wParam == SC_SCREENSAVE || wParam == SC_MONITORPOWER
			xor eax, eax
			ret
		.endif
	.elseif uMsg == WM_KEYDOWN
		mov ebx, offset keys
		add ebx, wParam
		mov byte ptr [ebx], true
		xor eax, eax
		ret
	.elseif uMsg == WM_KEYUP
		mov ebx, offset keys
		add ebx, wParam
		mov byte ptr [ebx], false
		xor eax, eax
		ret
	.elseif uMsg == WM_SIZE
		mov eax, lParam
		mov lomask, ax
		shr eax, 16
		mov himask, ax

		xor eax, eax
		mov ax, lomask
		mov w, eax
		mov ax, himask
		mov h, eax
		invoke ReSizeGLScene, lomask, himask
		xor eax, eax
		ret
	.endif

	invoke	DefWindowProc, hwnd, uMsg, wParam, lParam 
	ret
WndProc endp

END start