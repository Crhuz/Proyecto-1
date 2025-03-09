;
; Proyecto 1.asm
;
; Created: 3/9/2025 3:30:11 PM
; Author : super
;

.include "m328Pdef.inc"  

.cseg                   ; Comienza la sección de código
.org 0x0000             
    JMP     START       

.org PCI1addr           ; Vector de interrupción de PCINT
    JMP     PCINT_ISR   ; Saltar a la rutina de interrupción de PCINT

.org OVF0addr           ; Vector de interrupción por overflow del Timer0
    JMP     TMR0_ISR    ; Saltar a la rutina de interrupción del Timer0

START:
    ; Configuración de la pila
    LDI     R16, LOW(RAMEND)    ; Cargar el byte bajo de RAMEND en R16
    OUT     SPL, R16            ; Cargar R16 en SPL (Stack Pointer Low)
    LDI     R16, HIGH(RAMEND)   ; Cargar el byte alto de RAMEND en R16
    OUT     SPH, R16            ; Cargar R16 en SPH (Stack Pointer High)

; Tabla de valores para el display de 7 segmentos (0-9)
DISPLAY: 
    .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

.dseg                 
.org SRAM_START         

; Definir variables en RAM
U_SEG:  .byte 1         ; Guardado en RAM (0x100)
D_SEG:  .byte 1         ; Guardado en RAM (0x101)
U_MIN:  .byte 1         ; Guardado en RAM (0x102)
D_MIN:  .byte 1         ; Guardado en RAM (0x103)
U_HORA: .byte 1         ; Guardado en RAM (0x104)
D_HORA: .byte 1         ; Guardado en RAM (0x105)

.cseg                   ; Volver a la sección de código

// SETUP

// DISPLAY
LDI		R16, 0xFF
OUT		DDRD, R16
LDI		R16, 0x00
OUT		PORTB, R16

// LED RGB
SBI		DDRC, PC3
CBI		PORTC, PC3
SBI		DDRB, PC4
CBI		PORTB, PC3

// BOTONES
CBI		DDRB, PB5 ; CAMBIO DE MODO
SBI		PORTB, PB5 ; PULL-UP
CBI		DDRC, PC0 ; SELECCIONADOR DE DISPLAYS
SBI		PORTC, PC0 ; PULL-UP
CBI		DDRC, PC1 ; AUMENTAR VALOR
SBI		PORTC, PC1 ; PULL-UP
CBI		DDRC, PC2 ; DISMINUIR VALOR
SBI		PORTC, PC2 ; PULL-UP

// TRANSISTORES
SBI		DDRB, PB0
CBI		PORTB, PB0
SBI		DDRB, PB2
CBI		PORTB, PB2
SBI		DDRB, PB3
CBI		PORTB, PB3
SBI		DDRB, PB4
CBI		PORTB, PB4

// LEDS SEPARADORES DE DISPLAY
SBI		DDRB, PB1
CBI		PORTB, PB1

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

