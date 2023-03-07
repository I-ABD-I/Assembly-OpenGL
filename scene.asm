include ..\..\..\..\..\masm32\include\masm32rt.inc
include ..\..\..\..\..\masm32\include\opengl32.inc
include myStuff.inc

public DrawGLScene, Barrier, xRotation, yRotation, xSpeed, ySpeed

extern mouseCoords :POINT, w :DWORD, h :DWORD, mode :BYTE, mousePressed :BOOLEAN, color :COLOR

glPrint proto c :DWORD, :VARARG
TitleScreen proto
DrawDiamond proto
DrawPyramid proto
DrawBox proto
Barrier proto :BYTE, :BYTE, :BYTE, :DWORD, :DWORD, :DWORD, :DWORD
Random proto :DWORD, :DWORD


.data
xRotation REAL4 ?
yRotation REAL4 ?

xSpeed REAL4 ?
ySpeed REAL4 ?
.code

	;╭⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮
	;│			DrawGLScene				│ 
	;┝━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┥
	;│	Draws The Scene On the Window	│   
	;╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯
DrawGLScene proc
	.if mode == 0
		invoke TitleScreen

	.elseif mode == 1
		invoke DrawPyramid

	.elseif mode == 2
		invoke DrawBox

	.elseif mode == 3
		invoke DrawDiamond

	.endif
ret
DrawGLScene endp


TitleScreen proc
	local _width :QWORD 
	local _height :QWORD
	local buttonsX :DWORD

	;╭⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╮
	;│		same as doing		│
	;├⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┤
	;│ push ebp					│
	;│ mov ebp,esp				│
	;│ _width equ 4				│
	;│ _height equ 8			│
	;│ sub esp,	_height			│
	;╰⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯╯


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

invoke	glLineWidth, FP4(5.0); line width 5px

mov eax, w
mov ebx, 2
xor edx, edx
div ebx
sub eax, 200
mov buttonsX, eax

mov esi, buttonsX

add esi, 15
invoke glColor3ub, 255 ,255 , 255
invoke glRasterPos2i, esi, 100
invoke glPrint, chr$("Welcome")

invoke glColor3ub, 130, 138, 224

invoke glRasterPos2i, esi, 515
invoke glPrint, chr$("Diamond")

add esi, 15
invoke glRasterPos2i, esi, 250
invoke glPrint, chr$("Pyramid")

add esi, 85
invoke glRasterPos2i, esi, 385
invoke glPrint, chr$("Box")



; draw button berriers
invoke Barrier, 255, 255, 255, buttonsX, 170, 400, 110
invoke Barrier, 255, 255, 255, buttonsX, 300, 400, 110
invoke Barrier, 255, 255, 255, buttonsX, 430, 400, 110
mov eax, buttonsX
mov ebx, eax
add ebx, 400
.if mouseCoords.x > eax && mouseCoords.x < ebx ; if its in the x range of any button (all the same)
	.if mouseCoords.y > 170 && mouseCoords.y < 280 ; button 1 - pyramid
		invoke Barrier, 255, 0, 0, buttonsX, 170, 400, 110
		.if mousePressed
			mov mode, 1
		.endif

	.elseif mouseCoords.y > 300 && mouseCoords.y < 410 ; button 2 - box
		invoke Barrier, 255, 0, 0, buttonsX, 300, 400, 110
		.if mousePressed
			RandomColor 0
			RandomColor 1
			RandomColor 2
			RandomColor 3
			RandomColor 4
			RandomColor 5
			mov mode, 2
		.endif

	.elseif mouseCoords.y > 430 && mouseCoords.y < 540 ;button 3 - diamond
		invoke Barrier, 255, 0, 0, buttonsX, 430, 400, 110
		.if mousePressed
			mov mode, 3
		.endif

	.endif
.endif
ret
TitleScreen endp

Barrier proc red :BYTE,
			 green :BYTE,
			 blue :BYTE,
			 x :DWORD,
			 y :DWORD,
			 _width :DWORD,
			 _height :DWORD


	invoke glColor3ub, red, green, blue
	invoke glPolygonMode, GL_FRONT_AND_BACK , GL_LINE 
	invoke glBegin, GL_QUADS
	mov edi, x
	add edi, _width
	mov ebx, y
	add ebx, _height
	invoke glVertex2i, x, y
	invoke glVertex2i, x, ebx
	invoke glVertex2i, edi, ebx
	invoke glVertex2i, edi, y
	invoke glEnd
	invoke glPolygonMode, GL_FRONT_AND_BACK , GL_FILL
	ret
Barrier endp
end