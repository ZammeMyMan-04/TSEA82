
; MINIPROJEKT

	; r16 used for reading
	; r17 is number 0-9
	.equ	MAX_NUM = 10		; global konstant

	ldi		r16,HIGH(RAMEND)	; stack för subrutiner
	out		SPH,r16				; 
	ldi		r16,LOW(RAMEND)		;
	out		SPL,r16				;
	call	INIT				; initiera portriktningar
	clr		r17					; börja från 0
	; -- MAIN
LOOP:	
	call	KEY			; vänta på knapp
	inc		r17			; öka med ett
	cpi		r17,MAX_NUM ; framme än?
	brne	NOT_MAX		; nej, forsätt
	clr		r17			; ... annars nollställ
NOT_MAX:
	call	PRINT		; knapp tryckt, skriv ut
	jmp		LOOP

; INITIERA PORTAR
	
INIT:
	ldi		r16,$00		; $00 = 00_00_00_00
	out		DDRA,r16	; hela PINA ingångar
	ldi		r16,$0F		; 00_00_11_11
	out		DDRB,r16	; PROTB bit3..0 utgång (övriga ingång)
	ret

; LÄS FRÅN PORT

READ_BIT0:
	in		r16,PINA	; läs in hela porten
	andi	r16,$01		; maska ut bit0, flaggor påverkas
	ret					; läst bits värde signaleras i z-flaggan
KEY:
	call	READ_BIT0
	brne	KEY			; vänta på att den släpps
KEY_WAIT:				; (här måste den vara släpt)
	call	READ_BIT0
	breq	KEY_WAIT	; vänta på tryck
	ret					; nu är den tryckt, returnera

; SKRIV TILL PORT

PRINT:
	andi	r17,$0F		; nollställ registrets övre halva, bevara lägre halvan
	out		PORTB,r17	; skriv ut hela registret
	ret					; returnera till anroparen
