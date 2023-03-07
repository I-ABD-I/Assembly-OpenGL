include ..\..\..\..\..\masm32\include\masm32rt.inc
include ..\..\..\..\..\masm32\include\opengl32.inc
include ..\..\..\..\..\masm32\include\glu32.inc
include myStuff.inc

public DrawDiamond

extern w :DWORD, h :DWORD, mouseCoords :POINT, mousePressed :BOOLEAN, mode :BYTE,
	   xRotation :REAL4, yRotation :REAL4, xSpeed :REAL4, ySpeed :REAL4, color :COLOR
Barrier proto :BYTE, :BYTE, :BYTE, :DWORD, :DWORD, :DWORD, :DWORD
glPrint proto c :DWORD, :VARARG
Random proto :DWORD, :DWORD

.code 

DrawDiamond proc

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


	invoke glBegin, GL_TRIANGLES

	; face 1
	invoke glColor3ub,  255, 0, 0 ;red
	invoke glVertex3f,  FP4(0.0), FP4(1.0), FP4(0.0) ; top point
	invoke glColor3ub,  0, 255, 0; green
	invoke glVertex3f,  FP4(-0.5),FP4(0.0), FP4(0.5)
	invoke glColor3ub,  0, 0, 255 ; blue
	invoke glVertex3f,  FP4(0.5), FP4(0.0), FP4(0.5)

	; face 2
	invoke glColor3ub,  255, 0, 0 ;red 
	invoke glVertex3f,  FP4(0.0), FP4(1.0), FP4(0.0)
	invoke glColor3ub,  0, 0, 255 ; blue 
	invoke glVertex3f,  FP4(0.5), FP4(0.0), FP4(0.5)
	invoke glColor3ub,  0, 255, 0 ;green
	invoke glVertex3f,  FP4(0.5), FP4(0.0), FP4(-0.5)

	; face 3
	invoke glColor3ub,  255, 0, 0 ; red
	invoke glVertex3f,  FP4(0.0), FP4(1.0), FP4(0.0)
	invoke glColor3ub,  0, 255, 0 ;green
	invoke glVertex3f,  FP4(0.5), FP4(0.0), FP4(-0.5)
	invoke glColor3ub,  0, 0, 255 ; blue
	invoke glVertex3f,  FP4(-0.5), FP4(0.0), FP4(-0.5)

	; face 4
	invoke glColor3ub,  255, 0, 0 ; red
	invoke glVertex3f,  FP4(0.0), FP4(1.0), FP4(0.0)
	invoke glColor3ub,  0, 0, 255 ; blue
	invoke glVertex3f,  FP4(-0.5), FP4(0.0), FP4(-0.5)
	invoke glColor3ub,  0, 255, 0 ; green
	invoke glVertex3f,  FP4(-0.5), FP4(0.0), FP4(0.5)

	; face 5
	invoke glColor3ub,  255, 0, 0 ;red
	invoke glVertex3f,  FP4(0.0), FP4(-1.0), FP4(0.0) ; top point
	invoke glColor3ub,  0, 255, 0; green
	invoke glVertex3f,  FP4(-0.5), FP4(0.0), FP4(0.5)
	invoke glColor3ub,  0, 0, 255 ; blue
	invoke glVertex3f,  FP4(0.5), FP4(0.0), FP4(0.5)

	; face 6
	invoke glColor3ub,  255, 0, 0 ;red 
	invoke glVertex3f,  FP4(0.0), FP4(-1.0), FP4(0.0)
	invoke glColor3ub,  0, 0, 255 ; blue 
	invoke glVertex3f,  FP4(0.5), FP4(0.0), FP4(0.5)
	invoke glColor3ub,  0, 255, 0 ;green
	invoke glVertex3f,  FP4(0.5), FP4(0.0), FP4(-0.5)
  
  
	; face 7
	invoke glColor3ub,  255, 0, 0 ; red
	invoke glVertex3f,  FP4(0.0), FP4(-1.0), FP4(0.0)
	invoke glColor3ub,  0, 255, 0 ;green
	invoke glVertex3f,  FP4(0.5), FP4(0.0), FP4(-0.5)
	invoke glColor3ub,  0, 0, 255 ; blue
	invoke glVertex3f,  FP4(-0.5), FP4(0.0), FP4(-0.5)

	; face 8
	invoke glColor3ub,  255, 0, 0 ; red
	invoke glVertex3f,  FP4(0.0), FP4(-1.0), FP4(0.0)
	invoke glColor3ub,  0, 0, 255 ; blue
	invoke glVertex3f,  FP4(-0.5), FP4(0.0), FP4(-0.5)
	invoke glColor3ub,  0, 255, 0 ; green
	invoke glVertex3f,  FP4(-0.5), FP4(0.0), FP4(0.5)

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
	sub edi, 45
	add esi, 115
	push edi
	invoke glRasterPos2i, esi, edi
	invoke glPrint, chr$("Box")
	pop edi
	sub edi, 5
	add esi,420
	invoke glRasterPos2i, esi, edi
	invoke glPrint, chr$("Pyramid")

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
			invoke Barrier, 255, 0, 0, buttonsX, esi, 400, 110 ; box
			.if mousePressed
				RandomColor 0
				RandomColor 1
				RandomColor 2
				RandomColor 3
				RandomColor 4
				RandomColor 5
				mov mode, 2
			.endif

		.elseif mouseCoords.x > eax && mouseCoords.x < ebx ; pyramid
			add buttonsX, 500
			invoke Barrier, 255, 0, 0, buttonsX, esi, 400, 110
			sub buttonsX, 500
			.if mousePressed
				mov mode, 1
			.endif

		.endif
	.endif
ret
DrawDiamond endp

end