include ..\..\..\..\..\masm32\include\masm32rt.inc
include ..\..\..\..\..\masm32\include\opengl32.inc
include ..\..\..\..\..\masm32\include\glu32.inc
include myStuff.inc

public DrawBox, color, Random

extern w :DWORD, h :DWORD, mouseCoords :POINT, mousePressed :BOOLEAN, mode :BYTE,
       xRotation :REAL4, yRotation :REAL4, xSpeed :REAL4, ySpeed :REAL4
Barrier proto :BYTE, :BYTE, :BYTE, :DWORD, :DWORD, :DWORD, :DWORD
glPrint proto c :DWORD, :VARARG
Random proto :dword, :dword

.data
color COLOR 6 dup(<>)

.code
DrawBox proc
local aspectRatio :QWORD
	local _width :QWORD
	local _height :QWORD
	local buttonsX :DWORD

	invoke glMatrixMode, GL_PROJECTION
	invoke glLoadIdentity
	
	cvtsi2sd xmm0, w
	cvtsi2sd xmm1, h
	divsd xmm0, xmm1
	movsd aspectRatio, xmm0
	invoke gluPerspective, FP8(45.0), aspectRatio, FP8(0.1), FP8(100.0)
	
	invoke glMatrixMode, GL_MODELVIEW
	invoke glLoadIdentity

	invoke glTranslatef, 0, 0, FP4(-6.0)
	invoke glRotatef, yRotation, FP4(0.1), FP4(0.0), FP4(0.0)
	invoke glRotatef, xRotation, FP4(0.0), FP4(0.1), FP4(0.0)

	invoke glBegin, GL_QUADS
	invoke glColor3ub, color[0].r, color[0].g, color[0].b
	invoke glVertex3f, FP4(-1.0), FP4(-1.0), FP4(1.0)
	invoke glVertex3f, FP4(1.0), FP4(-1.0), FP4(1.0)
	invoke glVertex3f, FP4(1.0), FP4(-1.0), FP4(-1.0)
	invoke glVertex3f, FP4(-1.0), FP4(-1.0), FP4(-1.0)

	invoke glColor3ub, color[1].r, color[1].g, color[1].b
	invoke glVertex3f, FP4(-1.0), FP4(-1.0), FP4(1.0)
	invoke glVertex3f, FP4(-1.0), FP4(-1.0), FP4(-1.0)
	invoke glVertex3f, FP4(-1.0), FP4(1.0), FP4(-1.0)
	invoke glVertex3f, FP4(-1.0), FP4(1.0), FP4(1.0)
	
	invoke glColor3ub, color[2].r, color[2].g, color[2].b
	invoke glVertex3f, FP4(1.0), FP4(-1.0), FP4(1.0)
	invoke glVertex3f, FP4(1.0), FP4(-1.0), FP4(-1.0)
	invoke glVertex3f, FP4(1.0), FP4(1.0), FP4(-1.0)
	invoke glVertex3f, FP4(1.0), FP4(1.0), FP4(1.0)

	invoke glColor3ub, color[3].r, color[3].g, color[3].b
	invoke glVertex3f, FP4(1.0), FP4(-1.0), FP4(1.0)
	invoke glVertex3f, FP4(1.0), FP4(1.0), FP4(1.0)
	invoke glVertex3f, FP4(-1.0), FP4(1.0), FP4(1.0)
	invoke glVertex3f, FP4(-1.0), FP4(-1.0), FP4(1.0)

	invoke glColor3ub, color[4].r, color[4].g, color[4].b
	invoke glVertex3f, FP4(1.0), FP4(-1.0), FP4(-1.0)
	invoke glVertex3f, FP4(1.0), FP4(1.0), FP4(-1.0)
	invoke glVertex3f, FP4(-1.0), FP4(1.0), FP4(-1.0)
	invoke glVertex3f, FP4(-1.0), FP4(-1.0), FP4(-1.0)

	invoke glColor3ub, color[5].r, color[5].g, color[5].b
	invoke glVertex3f, FP4(1.0), FP4(1.0), FP4(-1.0)
	invoke glVertex3f, FP4(1.0), FP4(1.0), FP4(1.0)
	invoke glVertex3f, FP4(-1.0), FP4(1.0), FP4(1.0)
	invoke glVertex3f, FP4(-1.0), FP4(1.0), FP4(-1.0)

	invoke glEnd

	fld xRotation
	fadd xSpeed
	fstp xRotation

	fld yRotation
	fadd ySpeed
	fstp yRotation

	invoke glMatrixMode, GL_PROJECTION
	invoke glLoadIdentity

	cvtsi2sd xmm0, w
	cvtsi2sd xmm1, h
	movsd _width, xmm0
	movsd _height, xmm1
	invoke glOrtho, FP8(0.0), _width, _height, FP8(0.0) ,FP8(-1.0), FP8(1.0)

	invoke glMatrixMode, GL_MODELVIEW
	invoke glLoadIdentity

	mov eax, w
	mov ebx, 2
	xor edx,edx
	div ebx
	sub eax, 450
	mov buttonsX,eax

	mov esi, eax
	invoke glColor3ub, 130, 138, 224

	mov edi, h
	sub edi, 50
	add esi, 30
	invoke glRasterPos2i, esi, edi
	invoke glPrint, chr$("Pyramid")
	add esi, 485
	add edi, 5
	invoke glRasterPos2i, esi, edi
	invoke glPrint, chr$("Diamond")

	mov esi, h
	sub esi, 130
	invoke Barrier, 255, 255, 255, buttonsX, esi, 400, 110
	add buttonsX,500
	invoke Barrier, 255, 255, 255, buttonsX, esi, 400, 110
	sub buttonsX, 500
	mov edi, esi
	add edi, 110
	.if mouseCoords.y > esi && mouseCoords.y < edi
		mov edx, buttonsX
		mov ecx, edx
		add ecx, 400
		mov eax, edx
		mov ebx, ecx
		add eax, 500
		add ebx, 500
		.if mouseCoords.x > edx && mouseCoords.x < ecx
			invoke Barrier, 255, 0, 0, buttonsX, esi, 400, 110 ; pyramid
			.if mousePressed
				mov mode, 1
			.endif

		.elseif mouseCoords.x > eax && mouseCoords.x < ebx ; Diamond
			add buttonsX, 500
			invoke Barrier, 255, 0, 0, buttonsX, esi, 400, 110
			sub buttonsX, 500
			.if mousePressed
				mov mode, 3
			.endif

		.endif
	.endif
	ret
DrawBox endp

Random proc min :DWORD, max :DWORD
rdtsc
shr eax, 2
mov ebx, max
add ebx, 1
sub ebx, min
cdq
idiv ebx
add edx, min
mov eax, edx
ret
Random endp

end