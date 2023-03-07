COLOR STRUCT
 r db ?
 g db ?
 b db ?
COLOR ENDS

RandomColor MACRO index:REQ
	invoke Random, 0, 255
	mov color[index].r, al
	invoke Random, 0, 255
	mov color[index].g, al
	invoke Random, 0, 255
	mov color[index].b, al
ENDM