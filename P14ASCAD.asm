TITLE	P14ASCAD (COM) Suma de números ASCII
	.MODEL SMALL
	.CODE
	ORG	100H
BEGIN:	JMP	SHORT MAIN
;_______________________________________________________________
ASC1	DB	'578'	;Datos
ASC2	DB	'694'
ASCSUM	DB	'0000','$'
;_______________________________________________________________
MAIN	PROC	NEAR
	CLC
	LEA	SI,ASC1+2
	LEA	DI,ASC2+2
	LEA	BX,ASCSUM+3
	MOV	CX,03
A20:
	MOV	AH,00
	MOV	AL,[SI]
	ADC	AL,[DI]
	AAA
	MOV	[BX],AL
	DEC	SI
	DEC	DI
	DEC	BX
	LOOP	A20
	MOV	[BX],AH
	LEA	BX,ASCSUM+3
	MOV	CX,04
A30:
	OR	BYTE PTR[BX],30H
	DEC	BX
	LOOP	A30
	MOV	AH,09H
	LEA	DX,ASCSUM
	INT	21H
	MOV	AX,4C00H
	INT	21H
MAIN	ENDP
	END	BEGIN