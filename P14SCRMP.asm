	page	60,132
TITLE	P14SCREMP (EXE) Introduzca horas y sueldo, despl
	.MODEL	SMALL
	.STACK	64
;-----------------------------------------------------------------------
	.DATA
LEFCOL	EQU	28	;Equivalencia para la pantalla
RITCOL	EQU	54
TOPROW	EQU	10
BOTROW	EQU	14

HRSPAR	LABEL	BYTE	;Lista de parámetros de horas
MAXHLEN	DB	6	;----------------------------
ACTHLEN	DB	?
HRSFLD	DB	6 DUP(?)

RATEPAR	LABEL	BYTE	;Lista de parámetros de sueldo por h
MAXRLEN	DB	6
ACTRLEN	DB	?
RATEFLD	DB	6 DUP(?)

MESSG1	DB	'Horas trabajadas ','$'
MESSG2	DB	'Sueldo por hora ','$'
MESSG3	DB	'Salario = '
ASCWAGE	DB	10 DUP(30H),13,10,'$'
MESSG4	DB	'Presione cualquier tecla para continuar o Esc para salir','$'

ADJUST	DW	?	;Datos
BINVAL	DW	00
BINHRS	DW	00
BINRATE	DW	00
COL	DB	00
DECIND	DB	00
MULT10	DW	01
NODEC	DW	00
ROW	DB	00
SHIFT	DW	?
TENWD	DW	10
;-----------------------------------------------------------------------
	.CODE
BEGIN	PROC	FAR
	MOV	AX,@data	;Inicializa los
	MOV	DS,AX	; registros DS y ES
	MOV	ES,AX
A20LOOP:
	CALL	Q10SCR
	CALL	Q15WIN	;Limpia la ventana
	CALL	Q20CURS	;Coloca el cursor
	CALL	B10INPT	;Acepta las horas y el sueldo por hora
	CALL	D10HOUR	;Convierte las horas a binario
	CALL	E10RATE	;Convierte el sueldo a binario
	CALL	F10MULT	;Calcula el salario, redondeado
	CALL	G10WAGE	;Convierte salario a ASCII
	CALL	K10DISP	;Despliega el salario
	CALL	L10PAUS	;Pausa el salario
	CMP	AL,1BH	;¿Presionó Esc?
	JNE	A20LOOP	; no,entonces continuar
			; SI, ENTONCES FIN DE LA ENT
	CALL	Q10SCR	;Limpia la pantalla
	MOV	AX,4C00H	;Sale al DOS
	INT	21H
BEGIN	ENDP
;	Ingreso de horas y sueldo por hora
;	----------------------------------
B10INPT	PROC	NEAR
	MOV	ROW,TOPROW+1	;Coloca el cursor
	MOV	COL,LEFCOL+3
	CALL	Q20CURS
	INC	ROW
	MOV	AH,09H
	LEA	DX,MESSG1	;Indicación del número de horas
	INT	21H
	MOV	AH,0AH
	LEA	DX,HRSPAR	;Acepta el número de horas
	INT	21H
	MOV	COL,LEFCOL+3	;Designa la columna
	CALL	Q20CURS
	INC	ROW
	MOV	AH,09H
	LEA	DX,MESSG2	;Indicación del sueldo por hora
	INT	21H
	MOV	AH,0AH
	LEA	DX,RATEPAR	;Acepta el sueldo por hora
	INT	21H
	RET
B10INPT	ENDP
;	Procesa las horas:
;	------------------
D10HOUR	PROC	NEAR
	MOV	NODEC,00
	MOV	CL,ACTHLEN
	SUB	CH,CH
	LEA	SI,HRSFLD-1	;Designa la posición derecha
	ADD	SI,CX	; de horas
	CALL	M10ASBI	;Convierte a binario
	MOV	AX,BINVAL
	MOV	BINHRS,AX
	RET
D10HOUR	ENDP
;	Procesa el sueldo por hora:
;	---------------------------
E10RATE	PROC	NEAR
	MOV	CL,ACTRLEN
	SUB	CH,CH
	LEA	SI,RATEFLD-1	;Designa la posición derecha
	ADD	SI,CX	; de sueldo por hora
	CALL	M10ASBI	;Convierte a binario
	MOV	AX,BINVAL
	MOV	BINRATE, AX
	RET
E10RATE	ENDP
;	Multiplica, redondea y recorre:
;	-------------------------------
F10MULT	PROC	NEAR
	MOV	CX,05
	LEA	DI,ASCWAGE	;Designa el salario ASCII
	MOV	AX,3030H	; a los 3 0
	CLD
	REP	STOSW
	MOV	SHIFT,10
	MOV	ADJUST,00
	MOV	CX,NODEC
	CMP	CL,06	;Si hay mas de 6
	JA	F40	; decimales, error
	DEC	CX
	DEC	CX
	JLE	F30	;Si hay 0, 1, 2 decimales, saltatr
	MOV	NODEC,02
	MOV	AX,01
F20:
	MUL	TENWD	;Calcula el factor de corrimiento
	LOOP	F20
	MOV	SHIFT,AX
	SHR	AX,1	;Calcula el valor redondeado
	MOV	ADJUST,AX
F30:
	MOV	AX,BINHRS
	MUL	BINRATE	;Calcula el salario
	ADD	AX,ADJUST	;Redondea el salario
	ADC	DX,00
	CMP	DX,SHIFT	;¿El producto es muy grande
	JB	F50	; para DIV?
F40:
	SUB	AX,AX
	JMP	F70
F50:
	CMP	ADJUST,00	;¿Se requiere corrimiento?
	JZ	F80	; no, entonces saltar
	DIV	SHIFT	;Corrimiento de salario
F70:	SUB	DX,DX	;Limpiar el residuo
F80:	RET
F10MULT	ENDP
;	Conversión a ASCII
;	-------------------
G10WAGE	PROC	NEAR
	LEA	SI,ASCWAGE+7	;Fija el punto decimal
	MOV	BYTE PTR[SI],'.'
	ADD	SI,NODEC	;Fija la inicial derecha de inicio
G30:
	CMP	BYTE PTR[SI],'.'
	JNE	G40	;Si está en la posición dec, entonces saltar
	DEC	SI
G40:
	CMP	DX,00	;Si DX:AX < 10
	JNZ	G50
	CMP	AX,0010	; operación terminada
	JB	G60
G50:
	DIV	TENWD	;El residuo es un dígito ASCII
	OR	DL,30H
	MOV	[SI],DL	;Almacenar el carácter ASCII
	DEC	SI
	SUB	DX,DX	;Limpiar el residuo
	JMP	G30
G60:
	OR	AL,30H	;Almacena el último
	MOV	[SI],AL	; carácter ASCII
	RET
G10WAGE	ENDP
;	Despliega el salario:
;	---------------------
K10DISP	PROC	NEAR
	MOV	COL,LEFCOL+3	;Despliega la columna
	CALL	Q20CURS
	MOV	CX,09
	LEA	SI,ASCWAGE
K20:			;Elimina los ceros iniciales
	CMP	BYTE PTR[SI],30H
	JNE	K30	; cambiándolos por blancos
	MOV	BYTE PTR[SI],20H
	INC	SI
	LOOP	K20
K30:
	MOV	AH,09H	;Petición de despliege
	LEA	DX,MESSG3	;Salario
	INT	21H
	RET
K10DISP	ENDP
;	Pausa para el usuario
;	---------------------
L10PAUS	PROC	NEAR
	MOV	COL,20	;Coloca el cursor
	MOV	ROW,22
	CALL	Q20CURS
	MOV	AH,09H
	LEA	DX,MESSG4	;Despliega pausa
	INT	21H
	MOV	AH,10H	;Petición de despliegue
	INT	16H
	RET
L10PAUS	ENDP
;	Convierte ASCII a binario:
;	--------------------------
M10ASBI	PROC	NEAR
	MOV	MULT10,0001
	MOV	BINVAL,00
	MOV	DECIND,00
	SUB	BX,BX
M20:
	MOV	AL,[SI]	;Obtiene el carácter ASCII
	CMP	AL,'.'	;Si es punto decimal, saltar
	JNE	M40
	MOV	DECIND,01
	JMP	M90
M40:
	AND	AX,000FH
	MUL	MULT10	;Multiplica por factor	
	ADD	BINVAL,AX	;Suma al binario
	MOV	AX,MULT10	;Calcula el factor
	MUL	TENWD	; siguiente 10
	MOV	MULT10,AX
	CMP	DECIND,00	;¿Se llegó al punto decimal?
	JNZ	M90
	INC	BX	; sí, entonces sumar a la cuenta
M90:
	DEC	SI
	LOOP	M20
	CMP	DECIND,00	;Fin del ciclo
	JZ	M100	;¿Hay algún punto decimal?
	ADD	NODEC,BX	; si, entonces sumar al total
M100:	RET
M10ASBI	ENDP
;	Recorre toda la pantalla:
;	--------------------------
Q10SCR	PROC	NEAR
	MOV	AX,0600H
	MOV	BH,30H	;Atributo
	SUB	CX,CX
	MOV	DX,184FH
	INT	10H
	RET
Q10SCR	ENDP
;	Recorre la pantalla de despliegue:
;	----------------------------------
Q15WIN	PROC	NEAR
	MOV	AX,0605H	;Cinco renglones
	MOV	BH,16H	; Atributo
	MOV	CH,TOPROW
	MOV	CL,LEFCOL
	MOV	DH,BOTROW
	MOV	DL,RITCOL
	INT	10H
	RET
Q15WIN	ENDP
;	Coloca el cursor:
;	-----------------
Q20CURS	PROC	NEAR
	MOV	AH,02H
	SUB	BH,BH
	MOV	DH,ROW	;Designa el renglón
	MOV	DL,COL	;Designa la columna
	INT	10H
	RET
Q20CURS	ENDP
	END BEGIN
