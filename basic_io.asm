TITLE	P17HANRD (EXE) Lectura secuencial de registros en disco
	.MODEL	SMALL
	.STACK	64
; --------------------------------------------------------------------------
	.DATA
ENDCDE	DB	00	; END PROCESS INDICATOR
HANDLE	DW	?
IOAREA	DB	32 DUP(' ')
OPENMSG	DB	'*** Open error ***', 0DH, 0AH
PATHNAM	DB	'.\NAMEFILE.SRT',0
READMSG	DB	'*** Read error ***', 0DH, 0AH
ROW	DB	00
;____________________________________________________________
               .CODE
BEGIN	PROC	FAR
	MOV	AX,@data	;Inicializa
	MOV	DS,AX	; registros de
	MOV	ES,AX	; segmento
	MOV	AX,0600H
	CALL	Q10SCR	;Limpia la pantalla
	CALL	Q20CURS	;Coloca el cursor
	CALL	E10OPEN	;Abre archivo, designa DTA
	CMP	ENDCDE,00	;Apertura válida?
	JNZ	A90	; no, salir
A20LOOP:	CALL	F10READ	;Lee registro en disco
	CMP	ENDCDE,00	;Lectura normal?
	JNZ	A90	; no, salir
	CALL	G10DISP	; si, desplegar nombre,
	JMP	A90
	JMP	A20LOOP	; continuar
A90:			;Fin de procesamiento
	MOV	AX,4C00H	; salir al DOS
	INT	21H
BEGIN	ENDP
;              Open file:
;              ----------
E10OPEN	PROC	NEAR
	MOV	AH,3DH	;Petición para abrir
	MOV	AL,00	;Archivo normal
	LEA	DX,PATHNAM
	INT	21H
	JC	E20	;Error?
	MOV	HANDLE,AX	; no, guardar manejador
	RET
E20:
	MOV	ENDCDE,01	; si,
	LEA	DX,OPENMSG	;  desplegar
	CALL	X10ERR	;  mensaje de error
	RET
E10OPEN	ENDP
;              Lee registro de disco:
;              ------------------------
F10READ	PROC	NEAR
	MOV	AH,3FH	;Petición de lectura
	MOV	BX,HANDLE
	MOV	CX,32	;30 para el nombre + 2 para C
	LEA	DX,IOAREA
	INT	21H
	JC	F20	;Error en la la lectura?
	CMP	AX,00	;Fin del archivo?
	JE	F30
	CMP	IOAREA,1AH	;Marcador EOF?
	JE	F30	; si, salir
	JMP	F90
F20:			;no,
	LEA	DX,READMSG	; lectura no válida
	CALL	X10ERR
F30:
	MOV	ENDCDE,01	;Fuerza la terminación
F90:	RET
F10READ	ENDP
;              Despliega nombre:
;              ------------------
G10DISP	PROC	NEAR
	MOV	AH,40H	;Petición para desplegar
	MOV	BX,01	;Establece el manejador
	MOV	CX,32	; y la longitud
	LEA	DX,IOAREA
	INT	21H
	CMP	ROW,20	;Inferior de la pantalla?
	JAE	G80	; si, pasar
	INC	ROW	; no, incrementar renglón
	JMP	G90
G80:
	MOV	AX,0601H
	CALL	Q10SCR	;Recorrer
	CALL	Q20CURS	;Colocar cursor
G90:	RET
G10DISP	ENDP
;              Recorrido de la pantalla:
;              --------------------------
Q10SCR	PROC	NEAR	;AX se designó antes
	MOV	BH,1EH	;Designa color
	MOV	CX,0000
	MOV	DX,184FH	;Petición para recorrer
	INT	10H
	RET
Q10SCR	ENDP
;              Coloca el cursor:
;              ------------------
Q20CURS	PROC	NEAR
	MOV	AH,02H	;Petición para colocar
	MOV	BH,00	; el cursor
	MOV	DH,ROW	; renglón
	MOV	DL,00	; columna
	INT	10H
	RET
Q20CURS	ENDP
;              Despliega mensaje de error en disco:
;              ---------------------------------------
X10ERR	PROC	NEAR
	MOV	AH,40H	;DX contiene la dirección
	MOV	BX,01	;Manejador
	MOV	CX,20	;Longitud
	INT	21H	; del mensaje
	RET
X10ERR	ENDP
	END	BEGIN
	
	
