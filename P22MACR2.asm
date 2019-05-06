	page	60,132
TITLE	P22MACR2 (EXE) Uso de parámetros
;-----------------------------------------------------------------------
INITZ	MACRO		;Define macro
	MOV	AX,@data	;Inicializar registros
	MOV	DS,AX	; de segmento
	MOV	ES,AX
	ENDM		; Termina macro
	
PROMPT	MACRO	MESSGE	;Define macro
	MOV	AH,09H	;Pide mostrar display
	LEA	DX,MESSGE
	INT	21H
	ENDM		;Termina macro
	
FINISH	MACRO		;Define macro
	MOV	AX,4C00H	;Terminar proceso
	INT	21H
	ENDM		;Termina macro
;-----------------------------------------------------------------------
	.MODEL	SMALL
	.STACK	64
;-----------------------------------------------------------------------
	.DATA
MESSG1	DB	'Nombre del cliente?', '$'
MESSG2	DB	'Direccion del cliente?', '$'
;-----------------------------------------------------------------------
	.CODE
BEGIN	PROC	FAR
	INITZ
	PROMPT	MESSG2
	FINISH
BEGIN	ENDP
	END BEGIN
	
