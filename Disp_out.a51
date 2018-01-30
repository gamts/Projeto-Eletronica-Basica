;$NOMOD51		  	 ;Desabilita registradores pré-definidos
;#include <AT89X52.H> ;include CPU definition file

NAME disp_out

;-----------------------------------------------------------------------
PUBLIC 		display,refresh_T12,refresh_hour,refresh_minute
PUBLIC 		mostra_hora,led_sec,refresh_display
;-----------------------------------------------------------------------
; 	Reservando Espaços na Memória - Segmentos
;-----------------------------------------------------------------------
?DT?var_byte 	SEGMENT DATA
				RSEG 	?DT?var_byte
out_disp_H:		DS		2
out_disp_M:		DS		2

?BI?var_bit 	SEGMENT BIT
				RSEG 	?BI?var_bit
refresh_T12:	DBIT	1		;Ligar e desligar os transistores T1/2
refresh_hour:	DBIT	1		;Atualiza a codificação da hora
refresh_minute:	DBIT	1		;Atualiza a codificação do minuto
refresh_display:DBIT	1		;Indica que a rotina (tarefa) display 
								;deve ser executada.
mostra_hora:	DBIT	1		;Mostrar a hora quando em 1
led_sec:		DBIT	1		;Controla led dos segundos

;-----------------------------------------------------------------------
hour		SET		R0				;não alterar 
minute		SET		R1				;não alterar 
second		SET		R2				;não alterar 
sec100		SET		R3				;não alterar 
auxiliar	SET		R4				;não alterar 
var			SET		R5

latch_H		SET		P2.6 ;vai para o pino 11 do latch_1 (Latch_enable)
latch_M		SET		P2.7 ;vai para o pino 11 do latch_2 (Latch_enable)
;-----------------------------------------------------------------------
?CD?mostraDisp 	SEGMENT CODE
				RSEG	?CD?mostraDisp
				USING	3		;Indica que será usado o banco 3
display:
		PUSH	ACC
		PUSH	PSW
		MOV 	PSW,#24				;registra banco 3


;-----------------------------------------------------------------------
; Decodifica os valores das horas
;-----------------------------------------------------------------------
;mov hour,#00
;mov minute,00
		JNB		refresh_hour,quit_r_hour 	;Pula se for zero

		MOV		A,hour				;Processo identico ao dos minutos
		MOV		B,#10				;veja: Decodificação dos minutos
		DIV		AB
		MOV 	DPTR,#tabela_H1
		JZ		se_zero				;pula se a DEZENA for 0 e
		ADD		A,#10				;continua para valores <> de 0
		MOV 	var,A				
		MOVC	A,@A+DPTR			;OBS:
		MOV		out_disp_H+1,A		;Devido a deficiencia do display,
		JMP		pulo				;o valor zero (0x:xx) da hora 
se_zero:MOV 	A,#10				;nao aparece.
		MOV 	var,A				;Os únicos valores possiveis são:
		MOVC	A,@A+DPTR			;_x:xx, 1x:xx e 2x:xx.
		MOV		out_disp_H+1,A		;Isso acontece porque está faltando
pulo:	MOV		A,B					;um led para completar o digito 
		MOVC	A,@A+DPTR			;zero.
		ORL		out_disp_H+1,A
		MOV 	DPTR,#tabela_H2
		MOV		A,var
		MOVC	A,@A+DPTR
		MOV		out_disp_H,A
		MOV		A,B
		MOVC	A,@A+DPTR
		ORL		out_disp_H,A
		CLR		refresh_hour
quit_r_hour:

;-----------------------------------------------------------------------
; Decodifica os valores dos minutos
;-----------------------------------------------------------------------
		JNB		refresh_minute,quit_r_minute 	;Pula se for zero

									;Descrição do Processo:
		MOV		A,minute			;move o minuto atual para o ACC
		MOV		B,#10				;mov 10d para o reg B
		DIV		AB					;divide o minuto atual por 10
									;A=dezena e B=unidade
		MOV 	DPTR,#tabela_M1		;carrega o endereço da tabela M1
		ADD		A,#10				;soma 10 ao A (dezena)
		MOV 	var,A				;guarda o valor do A
		MOVC	A,@A+DPTR			;busca na memororia a tradução do 
									;atual valor do A. 
		MOV		out_disp_M+1,A		;armezena na memoria
		MOV		A,B					;mov p/ A o resto da div anterior
		MOVC	A,@A+DPTR			;busca na memororia a tradução do 
									;atual valor do A (unidade)
		ORL		out_disp_M+1,A		;OR logico da dezena que foi 
									;armazenada, com a unidade que 
									;acabou de ser traduzida.(união)
		MOV 	DPTR,#tabela_M2		;o processo é repetido p/ tabela M2
		MOV		A,var
		MOVC	A,@A+DPTR
		MOV		out_disp_M,A
		MOV		A,B
		MOVC	A,@A+DPTR
		ORL		out_disp_M,A
		CLR		refresh_minute
quit_r_minute:

;-----------------------------------------------------------------------
; refresh_T12=0 - Liga transistor 1
; refresh_T12=1 - Liga transistor 2
;-----------------------------------------------------------------------
		JB 		refresh_T12,pulo1	;quando refresh_T12=0
		MOV 	P0,out_disp_H+1
		SETB	latch_H
		CLR		latch_H
		MOV 	P0,out_disp_M+1
		SETB	latch_M
		CLR		latch_M

pulo1:	JNB 	refresh_T12,pulo2	;quando refresh_T12=1
		MOV 	P0,out_disp_M
		SETB	latch_M
		CLR		latch_M
		MOV 	P0,out_disp_H
		SETB	latch_H
		CLR		latch_H


;-----------------------------------------------------------------------
pulo2:
		CLR		refresh_display
		CPL		refresh_T12
		POP		PSW
		POP		ACC

		RET
;-----------------------------------------------------------------------
; Os códigos da tabela a serguir foram colocados em ordem para 
; facilitar a utilização de instruções tipo: 
; MOVC	A,@A+DPTR
;-----------------------------------------------------------------------
?CD?tabela_ SEGMENT CODE
		RSEG 	?CD?tabela_
tabela_H1:		;0	1	2	3	4	5	6	7	8	9	0x	1x	2x
		DB		70h,30h,50h,70h,30h,60h,60h,70h,70h,70h,00h,09h,07h
tabela_H2:		;0	 1	 2	  3		4	5	 6	   7	8	 9	 0x
		DB		0E8h,80h,0B8h,0B0h,0D0h,0F0h,0F8h,0C0h,0F8h,0F0h,80h
				;1x	2x
		DB		80h,86h
tabela_M1:		;0	 1	  2	   3	4	 5	  6	   7	8	 9	  0x
		DB		0F0h,0B0h,0D0h,0F0h,0B0h,0E0h,0E0h,0F0h,0F0h,0F0h,8Dh
				;1x	2x	3x	4x	5x
		DB		80h,8Eh,86h,83h,87h
tabela_M2:		;0	1	2	3	4	5	6	7	8	9	0x	1x	2x
		DB		68h,00h,38h,30h,50h,70h,78h,40h,78h,70h,07h,06h,03h
				;3x	4x	5x
		DB		07h,06h,05h

;-----------------------------------------------------------------------
		END		;End of File

