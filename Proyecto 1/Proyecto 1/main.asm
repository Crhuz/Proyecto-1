;
; Proyecto 1.asm
;
; Created: 3/9/2025 3:30:11 PM
; Author : super
;

.include "m328Pdef.inc"
.cseg

// Configuracion de pila
LDI     R16, LOW(RAMEND)    //Cargar 0xff a r16
OUT     SPL, R16            // CARGAR 0XFF a SPL
LDI     R16, HIGH(RAMEND)   //
OUT     SPH, R16            // Cargar 0x08 a SPH

SBI		DDRC, PC5
CBI		PORTC, PC5
SBI		DDRB, PB5
CBI		PORTB, PB5

MAIN_LOOP:
	SBI		PORTC, PC5
	CALL	DELAY_500MS
	CBI		PORTC, PC5
	CALL	DELAY_500MS
	SBI		PORTB, PB5
	CALL	DELAY_500MS
	CBI		PORTB, PB5
	CALL	DELAY_500MS
	RJMP	MAIN_LOOP


DELAY_500MS:

    LDI     R18, 41      ; Cargar valor en R18 (ajustar según la frecuencia)
OUTER_LOOP:
    LDI     R19, 255     ; Cargar valor en R19
MIDDLE_LOOP:
    LDI     R20, 255     ; Cargar valor en R20
INNER_LOOP:
    DEC     R20          ; Decrementar R20
    BRNE    INNER_LOOP   ; Saltar si R20 no es cero
    DEC     R19          ; Decrementar R19
    BRNE    MIDDLE_LOOP  ; Saltar si R19 no es cero
    DEC     R18          ; Decrementar R18
    BRNE    OUTER_LOOP   ; Saltar si R18 no es cero
    RET                  ; Retornar de la función

