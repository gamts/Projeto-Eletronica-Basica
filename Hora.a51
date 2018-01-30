NAME Conta_Hora

;-----------------------------------------------------------------------
EXTRN 	BIT	(refresh_minute,refresh_hour,refresh_display)

PUBLIC 	time,refresh_time

;-----------------------------------------------------------------------
?BI?var_bit 	SEGMENT BIT
				RSEG 	?BI?var_bit
refresh_time:	DBIT	1		;Indica que a rotina (tarefa) time 
								;deve ser executada.

;-----------------------------------------------------------------------
hour		SET		R0				;hora 0..23
minute		SET		R1				;minuto 0..59
second		SET		R2				;segundo 0..59
sec100		SET		R3				;centesimo de segundo 0..99
auxiliar	SET		R4				;Devodo a frequencia do clock 
									;que é de 11.0592 MHz 0..2

/*---------------------------------------------------------------------
 Realiza a contagem das horas
---------------------------------------------------------------------*/
?CD?code_time 	SEGMENT CODE
		RSEG	?CD?code_time
		USING	3				;Indica que será usado o banco 3
time:
		PUSH	PSW				;Armazena o banco anterior
		MOV 	PSW,#24			;Altera para o banco 3

		;INC 	auxiliar
		;CJNE	auxiliar,#3,pulo
		;MOV  	auxiliar,#00
		INC		sec100
		CJNE	sec100,#100,pulo
		MOV 	sec100,#00
		INC		second
cpl p2.5
		CJNE	second,#60,pulo
		MOV 	second,#00
		INC		minute
		SETB	refresh_minute
		CJNE	minute,#60,pulo
		MOV 	minute,#00
		INC		hour
		SETB	refresh_hour
		CJNE	hour,#24,pulo
		MOV 	hour,#00
		
pulo:
		CLR		refresh_time
		POP		PSW				;Retorna o banco anterior
		RET
;-----------------------------------------------------------------------
		END		;End of File