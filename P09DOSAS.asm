	page 60,132
TITLE	P09DOSAS (COM) Exhibe los caracteres ASCII 00H-FFH
	.MODEL SMALL
	.CODE
	ORG	100H
BEGIN:	JMP	SHORT MAIN
CHAR	DB	00,'$'
;	Procedimiento principal:
;	----------------------------------
MAIN	PROC	NEAR
	CALL	B10CLR	;Limpiar pantalla
	CALL	C10SET	;Fijar cursor
	CALL	D10DISP	;Exhibir caracteres
	MOV	AX,4C00H	;Salir a DOS
	INT	21H
MAIN	ENDP
;	Despejar pantalla:
;	--------------------
B10CLR	PROC	NEAR
	MOV	AX,0600H	;Recorrer toda la pantalla
	MOV	BH,07	;Atributo: blanco sobre negro
	MOV	CX,0000	;Posición izquierda superior
	MOV	DX,184FH	;Posición derecha inferior
	INT	10H
	RET
B10CLR	ENDP
;	Fijar cursor en 00,00:
;	-----------------------
C10SET	PROC	NEAR
	MOV	AH,02H	;Petición de fijar cursor
	MOV	BH,00	;Página No. 0
	MOV	DX,0000	;Hilera 0, columna 0
	INT	10H
	RET
C10SET	ENDP
;	Exhibir caracteres ASCII:
;	--------------------------
D10DISP	PROC
	MOV	CX,256	;Iniciar 256 iteraciones
	LEA	DX,CHAR	;Iniciar dirección de carácter
D20:
	CMP	CHAR,08H	;Se salta a 08H y a 0DH
	JE	LP
	CMP	CHAR,0DH
	JE	LP
	MOV	AH,09H	;Exhibir carácter ASCII
	INT	21H
LP:
	INC	CHAR	;Incrementar para el sigiente carácter
	LOOP	D20	;Decrementar CX,ciclo diferente de cero
	RET
D10DISP	ENDP
	END	BEGIN
