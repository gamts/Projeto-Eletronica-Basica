NAME	TECLADO

;-----------------------------------------------------------------------
EXTRN 	BIT	(refresh_minute,refresh_hour)
PUBLIC 	teclas,refresh_key

;-----------------------------------------------------------------------
?BI?var_bit 	SEGMENT BIT
				RSEG 	?BI?var_bit
refresh_key:	DBIT	1		;Indica que a rotina (tarefa) teclas 
								;deve ser executada.

hour			SET		R0				;não alterar 
minute			SET		R1				;não alterar 
key_hour		SET		P2.4
key_minute		SET		P2.3
;-----------------------------------------------------------------------
?CD?code_key	SEGMENT CODE
		RSEG	?CD?code_key
		USING	3

teclas:
		PUSH	PSW
		MOV 	PSW,#24
		JB		P2.4,pulo1
		INC		minute
	SETB	refresh_minute
		CJNE	minute,#60,pulo1
		MOV 	minute,#00
pulo1:	JB		P2.3,pulo2
		INC		hour
	SETB	refresh_hour
		CJNE	hour,#24,pulo2
		MOV 	hour,#00
pulo2:

		CLR		refresh_key
		POP 	PSW
		RET
;-----------------------------------------------------------------------				
		END 		;End of File 
