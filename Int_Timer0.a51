;$NOMOD51		  	  ;Desabilita registradores pré-definidos
;#include <AT89X52.H> ;include CPU definition file

;-----------------------------------------------------------------------
NAME INT_TIMER_0

;-----------------------------------------------------------------------
EXTRN 	CODE 	(time)
EXTRN	BIT		(refresh_time)

PUBLIC 	Timer0int,overflow_timer0

;-----------------------------------------------------------------------
?BI?var_bit 	SEGMENT BIT
				RSEG 	?BI?var_bit
overflow_timer0:DBIT	1		;Flag que indica estouro de contagem

;-----------------------------------------------------------------------
; Vector Interrupt 0Bh - Timer 0
;-----------------------------------------------------------------------
		CSEG 	AT 0Bh
		CLR		TR0
		MOV 	TH0,#HIGH(65535-9216)	;Carrega o Timer0 
		MOV 	TL0,#LOW (65535-9216)	;3063
		NOP
		SETB	TR0
		JMP 	Timer0int

;-----------------------------------------------------------------------
; Segmento de Código
;-----------------------------------------------------------------------
?PR?int_timer0	SEGMENT CODE
		RSEG	?PR?int_timer0

;-----------------------------------------------------------------------
; Tarefas a serem realizadas ou inicadas 
;-----------------------------------------------------------------------
Timer0int:	
		SETB	overflow_timer0

		RETI	
;-----------------------------------------------------------------------				
		END 		;End of File