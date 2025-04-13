
; MINIPROJEKT

	; r16 used for reading
	; r17 is number 0-9
	.equ	MAX_NUM = 10		; global konstant

	ldi		r16,HIGH(RAMEND)	; stack f�r subrutiner
	out		SPH,r16				; 
	ldi		r16,LOW(RAMEND)		;
	out		SPL,r16				;
	call	INIT				; initiera portriktningar
	clr		r17					; b�rja fr�n 0
	; -- MAIN
LOOP:	
	call	KEY			; v�nta p� knapp
	inc		r17			; �ka med ett
	cpi		r17,MAX_NUM ; framme �n?
	brne	NOT_MAX		; nej, fors�tt
	clr		r17			; ... annars nollst�ll
NOT_MAX:
	call	PRINT		; knapp tryckt, skriv ut
	jmp		LOOP

; INITIERA PORTAR
	
INIT:
	ldi		r16,$00		; $00 = 00_00_00_00
	out		DDRA,r16	; hela PINA ing�ngar
	ldi		r16,$0F		; 00_00_11_11
	out		DDRB,r16	; PROTB bit3..0 utg�ng (�vriga ing�ng)
	ret

; L�S FR�N PORT

READ_BIT0:
	in		r16,PINA	; l�s in hela porten
	andi	r16,$01		; maska ut bit0, flaggor p�verkas
	ret					; l�st bits v�rde signaleras i z-flaggan
KEY:
	call	READ_BIT0
	brne	KEY			; v�nta p� att den sl�pps
KEY_WAIT:				; (h�r m�ste den vara sl�pt)
	call	READ_BIT0
	breq	KEY_WAIT	; v�nta p� tryck
	ret					; nu �r den tryckt, returnera

; SKRIV TILL PORT

PRINT:
	andi	r17,$0F		; nollst�ll registrets �vre halva, bevara l�gre halvan
	out		PORTB,r17	; skriv ut hela registret
	ret					; returnera till anroparen
