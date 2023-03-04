include ..\..\..\..\..\masm32\include\masm32rt.inc
include ..\..\..\..\..\masm32\include\opengl32.inc
include ..\..\..\..\..\masm32\include\gdi32.inc



includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\opengl32.lib

extern hDC :HDC

public BuildFont, KillGLFont, glPrint

.data
base GLuint ?

.code
BuildFont proc _font :DWORD, _size :DWORD, weight :DWORD
	local font :HFONT
	local oldFont :HFONT

	invoke glGenLists, 96
	mov base, eax

	invoke  CreateFont, _size, 0, 0, 0, weight, false, false, false,
					  HEBREW_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS,
					  ANTIALIASED_QUALITY, FF_DONTCARE or DEFAULT_PITCH,
					  _font

	mov font, eax

	invoke SelectObject, hDC, font
	mov oldFont, eax

	invoke wglUseFontBitmaps, hDC, 32, 96, base
	invoke SelectObject, hDC, oldFont
	invoke DeleteObject, font
	ret
BuildFont endp

KillGLFont proc

invoke glDeleteLists, base, 96

ret
KillGLFont endp

glPrint proc C fmt :DWORD,
			   args :VARARG

	local text[256] :CHAR

	.if fmt == null
		ret
	.endif

	invoke  wsprintf, addr text, fmt, addr args 
	
	invoke glPushAttrib, GL_LIST_BIT
	mov eax, base
	sub eax, 32
	invoke glListBase, eax

	invoke StrLen, addr text
	mov ebx,  eax
	invoke glCallLists, ebx, GL_UNSIGNED_BYTE, addr text 
	invoke glPopAttrib

	ret
glPrint endp

end
