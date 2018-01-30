;-----------------------------------------------------------------------
;	UNIVERSIDADE FEDERAL DE SANTA CATARINA - UFSC 
;	Aluno: Gesiel Antonio Martins
;	Turma: 141 - 2006/2
;	Data : 19/02/07
;-----------------------------------------------------------------------
;$NOMOD51		  	 ;Desabilita registradores pré-definidos
;#include <AT89X52.H> ;include CPU definition file
;-----------------------------------------------------------------------
NAME 	PRINCIPAL

;-----------------------------------------------------------------------
EXTRN 	CODE 	(Timer0int,display,time)
EXTRN	BIT		(refresh_display,overflow_timer0,refresh_hour)
EXTRN	BIT		(refresh_minute,refresh_time)

;-----------------------------------------------------------------------
?STACK	SEGMENT	IDATA
		RSEG	?STACK
		DS		10h		;reserva 16 bytes para a pilha

;-----------------------------------------------------------------------
; Vector Interrupt 00h - Reset
;-----------------------------------------------------------------------
		CSEG 	AT 0
		LJMP 	START

;-----------------------------------------------------------------------
; Segmento de Código
;-----------------------------------------------------------------------
?PR?code_princ 	SEGMENT CODE
		RSEG	?PR?code_princ
	    USING	0				;Determina o banco de regitradores usado

START:	

		MOV		SP,#?STACK-1		;Determina o inicio da pilha
		MOV		TMOD,#00000001b		;Timer Mode Register
		MOV		IE,#10000010b		;Interrupt Enable	
		MOV 	TH0,#HIGH(65535-3063)	;Carrega o Timer0 
		MOV 	TL0,#LOW(65535-3063)
		SETB 	TR0						;Liga Timer0
		
		SETB	refresh_display
		SETB	refresh_hour
		SETB	refresh_minute
		mov p2,#00

				MOV     R0,#1fh
				CLR     A
;mov a,#55h
IDATALOOP:      MOV     @R0,A
                DJNZ    R0,IDATALOOP
;mov p0,#0e8h
;setb p2.6
;clr  p2.6
;mov p0,#06fh
;setb p2.7
;clr  p2.7

;jmp $


;-----------------------------------------------------------------------
; Tarefas a serem Executadas
;-----------------------------------------------------------------------
INICIO:

;-----------------------------------------------------------------------
		; Tarefa 0: Inicia rotinas que dependem do timer0
		JNB		overflow_timer0,quit_tarefa0
		SETB	refresh_time
		SETB	refresh_display
		CLR		overflow_timer0
quit_tarefa0:

;-----------------------------------------------------------------------
; 		Tarefa 1: Atualizar Time
		JNB		refresh_time,quit_tarefa1
		CALL	time
quit_tarefa1:
;-----------------------------------------------------------------------
; 		Tarefa 2: Atualizar Display
		JNB		refresh_display,quit_tarefa2
		CALL	display
quit_tarefa2:
;-----------------------------------------------------------------------
		JMP		INICIO
;-----------------------------------------------------------------------				
		END 		;End of File
