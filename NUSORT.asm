TITLE	NUSORT (EXE) Ordenador de tres numeros
	.MODEL	SMALL
	.STACK	64
; --------------------------------------------------------------------------
	.DATA
ENDCDE	DB	00	; END PROCESS INDICATOR
HANDLE	DW	?
NUMLEN	DW	666
IOAREA	DB	10, 666 DUP(' '), '$'
NUM1	DB	667 DUP('0'), '$'
NUM2	DB	667 DUP('0'), '$'
NUM3	DB	667 DUP('0'), '$'
OPENMSG	DB	'*** Open error ***', 0DH, 0AH
PATHNAM	DB	'.\numeros.txt',0
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
	CALL	F10READ	;Lee registro en disco
	CMP	ENDCDE,00	;Lectura normal?
	JNZ	A90	; no, salir
	LEA	SI,IOAREA	
	ADD	SI,NUMLEN	;Carga la ultima pos de IOA
	LEA	DI,NUM3
	CALL	W20RPL
	LEA	DI,NUM2	;;Carga numeros de IOA a RAM
	CALL	W20RPL
	LEA	DI,NUM1
	CALL	W20RPL
	LEA	SI,NUM1	;; Compara numeros y deja
	LEA	DI,NUM2	;; el menor en NUM1
	CALL	W30MIN
	LEA	SI,NUM2
	LEA	DI,NUM3
	CALL	W30MIN
	LEA	SI,NUM1
	LEA	DI,NUM2	;;Hacer eso como se muestra debería dejarlos ordenados
	CALL	W30MIN
	LEA	SI,NUM1	;Imprime los nums
	CALL	G10DISP
	LEA	SI,NUM2
	CALL	G10DISP
	LEA	SI,NUM3
	CALL	G10DISP
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
	MOV	CX,NUMLEN	;lee NUMLEN weas
	LEA	DX,IOAREA+1
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
;              Despliega string (utiliza el registro SI):
;              ------------------
G10DISP	PROC	NEAR
	CALL	W40ZS	;Mueve SI hasta no 0's a la izq
	CALL	Q20CURS
	MOV	AH,09H
	MOV	DX,SI
	INT	21H
	INC	ROW
	RET
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
;              Busca el primer caracter numérico (SI der a izq)
;              ------------------
W10SRX	PROC	NEAR
LOOPBNM:	MOV	AL,[SI]
	CMP	AL,30H
	JL	W10CNT
	CMP	AL,39H
	JLE	W10SAL
W10CNT:	DEC	SI
	JMP	LOOPBNM
W10SAL:
	RET
W10SRX	ENDP
;              Copia todos los numericos de der a izq de SI a DI
;              ------------------
W20RPL	PROC	NEAR
	CALL	W10SRX	;Busca el primero num
	ADD	DI,NUMLEN
LOOWATR:	MOV	AL,[SI]	;Va copiando mientras sean caracteres numéricos de SI a DI
	CMP	AL,30H
	JL	W20EXIT
	CMP	AL,39H
	JG	W20EXIT
	MOV	AH,BYTE PTR [SI]
	MOV	BYTE PTR [DI],AH
	DEC	DI
	DEC	SI
	JMP	LOOWATR
W20EXIT:
	RET
W20RPL	ENDP
;	Compara los strings en SI y DI y deja el menor en SI
;	------------------------------------------------------------
W30MIN	PROC	NEAR
	MOV	DX,SI
	MOV	BX,DI
	MOV	CX,NUMLEN
	INC	CX
	REP	CMPSB
	JL	PTA
	MOV	CX,NUMLEN
	INC	CX
	MOV	SI,DX
	MOV	DI,BX
SWPLP:	MOV	DL,BYTE PTR[DI]
	MOV	DH,BYTE PTR[SI]
	MOV	BYTE PTR[DI],DH
	MOV	BYTE PTR[SI],DL
	INC	SI
	INC	DI
	LOOP	SWPLP
PTA:	RET
W30MIN	ENDP
;	Mueve SI hasta encontrar algo distinto de 0's a la izquierda
;	------------------------------------------------------------
W40ZS	PROC	NEAR
Z40L:	CMP	BYTE PTR [SI],30H
	JNE	Z40E
	INC	SI
	JMP	Z40L
Z40E:	RET
W40ZS	ENDP
	END	BEGIN

