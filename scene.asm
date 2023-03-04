include ..\..\..\..\..\masm32\include\masm32rt.inc
include ..\..\..\..\..\masm32\include\opengl32.inc

public DrawGLScene

extern mouseCoords :POINT
extern w :dword
extern h :dword

glPrint proto c :dword, :VARARG
TitleScreen proto
BuildFont proto :DWORD, :DWORD, :DWORD

.code
	;╭⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮
	;│			DrawGLScene				│ 
	;┝━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┥
	;│	Draws The Scene On the Window	│   
	;╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯
DrawGLScene proc
invoke TitleScreen
DrawGLScene endp


TitleScreen proc
	local _width :QWORD 
	local _height :QWORD

	;╭⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮
	;│		same as doing		│
	;├⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┤
	;│ push ebp					│
	;│ mov ebp,esp				│
	;│ _width equ 4				│
	;│ _height equ 8			│
	;│ sub esp,	_height			│
	;╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯

invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
invoke glLoadIdentity

; change projection mode to 2d pixel grid
invoke glMatrixMode, GL_PROJECTION
invoke glLoadIdentity

cvtsi2sd xmm0, w
cvtsi2sd xmm1, h
movsd _width, xmm0
movsd _height, xmm1
invoke glOrtho, FP8(0.0), _width, _height, FP8(0.0) ,FP8(-1.0), FP8(1.0)

invoke glMatrixMode, GL_MODELVIEW
invoke glLoadIdentity

invoke glRasterPos2i, 100, 100
invoke glPrint, chr$("Welcome")

invoke glRasterPos2i, 200, 200
invoke BuildFont, chr$("sans-serif"), 100, 900
invoke glPrint, chr$("TEST")

ret
TitleScreen endp
end