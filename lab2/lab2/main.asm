.equ N = 200    ; Tid
.equ T = 0      ; Frekvens

ldi     r16, high(RAMEND)    ; Init stackpekaren
out     SPH, r16
ldi     r16, low(RAMEND)
out     SPL, r16

.org 0x1111
jmp MORSE


; Morse-kodtabell i FLASH, A-Z (ASCII $41 - $5A)
MORSE_TABELL:
    .db 0x60 ; A
    .db 0x88 ; B
    .db 0xA8 ; C
    .db 0x90 ; D
    .db 0x40 ; E
    .db 0x28 ; F
    .db 0xD0 ; G
    .db 0x08 ; H
    .db 0x20 ; I
    .db 0x78 ; J
    .db 0xB0 ; K
    .db 0x48 ; L
    .db 0xE0 ; M
    .db 0xA0 ; N
    .db 0xF0 ; O
    .db 0x68 ; P
    .db 0xD8 ; Q
    .db 0x50 ; R
    .db 0x10 ; S
    .db 0xC0 ; T
    .db 0x30 ; U
    .db 0x18 ; V
    .db 0x70 ; W
    .db 0x98 ; X
    .db 0xB8 ; Y
    .db 0xC8 ; Z

; Lägg till meddelandet i FLASH-minnet
MESSAGE:
    .db "DATORTEKNIK", 0x00 ; Strängen avslutas med en null-byte ($00)

; Nödvändig hårdvaruinitiering
INIT:
	; init Z-pekaren att peka p� meddelandet
    ldi ZL, low(MESSAGE*2)   ; << 1 för att få byte-adressen av MESSAGE
    ldi ZH, high(MESSAGE*2)
	; init PORTA
	ldi		r16,0x01	; Ställ in PA0 som utgångar (1), och resten som ingångar (0)
	out		DDRA,r16	; Skriv till Data Direction Register A
	ret

; Hämtar nästa ASCII-tecken ur strängen
GET_CHAR:
    lpm r18, Z+
    cpi r18, 0x00               ; Lyft Z-flaggan om vi nått null-biten
	ret

; Översätter ASCII-tecken till binärkod, ASCII-tecknet lagras i r18
LOOKUP:
    push	ZH
	push	ZL

	ldi		ZL,low(MORSE_TABELL*2)
	ldi		ZH,high(MORSE_TABELL*2)

    subi r18,'A'    ; subtrahera hex-koden för A från hex-koden för den aktuella bokstaven för att få index i databasen
    add ZL, r18     ; addera "index" till databasens start-rad
	clr r0
    adc ZH, r0

    lpm r18, Z      ; Tilldela r18 med Y

	pop		ZL
	pop		ZH
    ret

GET_BIT:
    lsl r18         ; skifta morse-bitarna till vänster
    ret

SEND:
    call GET_BIT    ; Ladda bit till r18
send_bits:
    brcs ld_long    ; Om C-flaggan är satt ...
ld_short:           ; ... ladda r19 med N (skicka . )
    ldi r19,N
    jmp send_bits_rest
ld_long:            ; ... annars ladda r19 med 3N (skicka _ )
    ldi r19,N
    ldi r20,N
    lsl r20
    add r19, r20
send_bits_rest:
    call BEEP
    call NO_BEEP
    call GET_BIT
    brne send_bits_done       ; Om vi har nått slutet av bokstaven 
    jmp send_bits   ; Fortsätt loopen
send_bits_done:
	ret

BEEP:
    ; skicka ett ljud med frekvensen T och längden N (med hjälp av DELAY)
    ret

NO_BEEP:
	ldi	 r19,N
    call BEEP
    ret

BEEP_CHAR:
    call LOOKUP
    call SEND
	ldi r19,N		; 2N
	lsl r19
    call NO_BEEP
	ret

MORSE:
    call INIT

    call GET_CHAR   ; ladda karaktären till r18
    breq done       ; om vi har nått null-biten, avbryt
one_char:           ; Ombesörjer sändandet av ett ASCII-tecken
    call BEEP_CHAR
    call GET_CHAR
    brne one_char   ; hoppa tillbaks till one_char om GET_CHAR inte lyfte Z-flaggan (det finns fler bitar)
done:
    ret
    

    
    

    
