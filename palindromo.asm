TITLE   PDMO (EXE)  Checa si alguna cadena es palindromo
;..................................................................
        .MODEL  SMALL
        .STACK  64
;..................................................................
        .DATA
NAMEPAR LABEL   BYTE
MAXNLEN DB      50
NAMELEN DB      ?
NAMEFLD DB      51 DUP (' ')
PROMPT  DB      'NAME? ', '$'
SIES    DB      ' SI es palindromo', '$'
NOES    DB      ' NO es palindromo', '$'
PRESP   DB      51 DUP ('$')
DATL    DB      0
DATR    DB      0
;.......................................................
        .CODE
BEGIN   PROC    FAR
        MOV     AX,@data
        MOV     DS,AX
        MOV     ES,AX
        CALL    Q10CLR
A20LOOP:
        MOV     DX,0000
        CALL    Q20CURS
        CALL    B10PRMP
        CALL    D10INPT
        CALL    Q10CLR
        CMP     NAMELEN,00
        JE      A30
        CALL    E10CODE
        CALL    F10CENT
        JMP     A20LOOP
A30:
        MOV     AX,4C00H
        INT     21H
BEGIN   ENDP

;                EXHIBE INDICADOR:
;.......................................

B10PRMP PROC    NEAR
        MOV     AH,09H
        LEA     DX,PROMPT
        INT     21H
        RET
B10PRMP ENDP

;               ACEPTA ENTRADA DE NOMBRE:
;........................................
D10INPT PROC    NEAR
        MOV     AH,0AH
        LEA     DX,NAMEPAR
        INT     21H
        RET
D10INPT ENDP

;         FIJAR CAMPANA Y DELIMITADOR '$'
;..........................................
E10CODE PROC    NEAR
        MOV     BH,00
        MOV     BL,NAMELEN
        MOV     NAMEFLD [BX+1],'$'
        RET
E10CODE ENDP

;       CENTRAR Y EXHIBIR NOMBRE
;...........................................
F10CENT PROC    NEAR
        ;MOV     DL,NAMELEN
        ;SHR     DL,1
        ;NEG     DL
        ;ADD     DL,40
        MOV     DH,12
        MOV     DL,0
        ;MOV     DH,12
        CALL    Q20CURS
        MOV     AH,09H
        LEA     DX,NAMEFLD
        INT     21H
        ; uwu
        CALL    CHPLND
        ; imprimir respuesta        
        MOV     DL,NAMELEN
        MOV     DH,12
        CALL    Q20CURS
        MOV     AH,09H
        LEA     DX,PRESP
        INT     21H
        RET
F10CENT ENDP

;       DESPEJAR PANTALLA
;.........................................
Q10CLR  PROC    NEAR
        MOV     AX,0600H
        MOV     BH,07
        MOV     CX,0000
        MOV     DX,184FH
        INT     10H
        RET
Q10CLR  ENDP

;       CHECAR SI ES PALINDROMO
;.........................................
CHPLND  PROC    NEAR
        LEA     DX,SIES
        MOV     CH,0
        MOV     CL,NAMELEN
        MOV     AH,0
SHRUGO: MOV     AL,CL
        DEC     AL
        MOV     BX,AX
        MOV     AL,NAMEFLD[BX]
        MOV     DATL,AL
        MOV     AL,NAMELEN
        SUB     AL,CL
        MOV     BX,AX
        MOV     AL,NAMEFLD[BX]
        MOV     BL,DATL
        CMP     AL,BL
        JE      TOBIEN
        LEA     DX,NOES
TOBIEN: LOOP    SHRUGO
        MOV     SI,DX
        MOV     CX,17
        LEA     DI,PRESP
        REP     MOVSB
        RET
CHPLND  ENDP

;       FIJAR HILERA/COLUMNA DE CURSOR
;..........................................
Q20CURS PROC    NEAR
        MOV     AH,02H
        MOV     BH,00
        INT     10H
        RET
Q20CURS ENDP
        END     BEGIN


