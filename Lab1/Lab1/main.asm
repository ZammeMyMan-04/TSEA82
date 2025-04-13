
	.equ	T = 20	; Global konstant, använd för delay, ladda r16 med T för att få delay i 2ms, T/2 för 1ms

	ldi     r16, high(RAMEND)    ; Init stackpekaren
    out     SPH, r16
    ldi     r16, low(RAMEND)
    out     SPL, r16

	.org	0x003F
	jmp		MAIN

; Subrutiner
;==========================================================================================
DELAY:
	ret
	sbi		PORTB,7			; skvallersignal på
delayYttreLoop:
	ldi		r17,$1F			; for-loop i for-loop liknande modell
delayInreLoop:
	dec		r17				; minska r17
	brne	delayInreLoop	; om r17 != 0, forstätt inre loopen
	dec		r16				; ... annars minska r16
	brne	delayYttreLoop	; om r16 != 0, fortsätt med yttre loop
	cbi		PORTB,7			; ... annars skvallersignal av och returnera
	ret

INIT:
	; init PORTA
	ldi		r16,0b00000000	; Sätt hela PORTA till ingångar
	out		DDRA,r16		; Skriv till Data Direction Register A
	; init PORTB
	ldi		r16,0b10001111	; Ställ in PORTB0-3 och 7 som utgångar (1), och resten som ingångar (0)
	out		DDRB,r16		; Skriv till Data Direction Register B
	ret

STARTBIT:
	sbis	PINA,0		; Läs in pin A bit 0, hoppa över nästa om 1
	jmp		STARTBIT	; Om den var 0, fortsätt leta efter 1
delay_t_halva:
	ldi		r16, T		; r16 = T	(2ms)
	lsr		r16			; r16 = T/2 (1ms)
	call	DELAY		; Delay med T/2 (1ms)
checkbit:
	sbis	PINA,0		; Läs in pin A bit 0, hoppa över nästa om 1
	jmp		STARTBIT
EXIT_STARTBIT:
	ret

DATA:
	ldi		r18,4	; Antalet bitar att läsa
	clr		r19		; Nollställ r19 (förbered för att lagra datan)
data_loop:
	ldi		r16,T	
	call	DELAY
	lsr		r19			; Skifta r19 åt vänster, förbered för nästa bit
	sbic	PINA,0		; Om pin A0 = 1 ...
	sbr		r19,0b1000
	dec		r18			; Räkna ner antal bitar
	brne	data_loop	; Om inte klar, fortsätt loopen
	ret

SKRIV_UT:
	andi	r19,$0F		; Nollställ r19 övre halva
	out		PORTB,r19	; Skriv ut till port B
	ret

; Main program
;==========================================================================================
MAIN:
	call	INIT
main_loop:
	call	STARTBIT
	call	DATA
	call	SKRIV_UT
	ldi		r16,T
	call	DELAY		; Vänta 2ms
	jmp		main_loop