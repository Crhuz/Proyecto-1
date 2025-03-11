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

.def	MODO = R17
.def	TIEMPO = R18
.def	COUNTER = R19
.def	SLIDER = R20
.def	CAMBIADOR = R21
.dseg    
             
.org SRAM_START         

; Definir variables en RAM
U_SEG:  .byte 1         ; Guardado en RAM (0x100)
D_SEG:  .byte 1         ; Guardado en RAM (0x101)
U_MIN:  .byte 1         ; Guardado en RAM (0x102)
D_MIN:  .byte 1         ; Guardado en RAM (0x103)
U_HORA: .byte 1         ; Guardado en RAM (0x104)
D_HORA: .byte 1         ; Guardado en RAM (0x105)
U_DIA: .byte 1         ; Guardado en RAM (0x106)
D_DIA: .byte 1         ; Guardado en RAM (0x107)
U_MES: .byte 1         ; Guardado en RAM (0x108)
D_MES: .byte 1         ; Guardado en RAM (0x109)
TIEMPOR: .byte 1         ; Guardado en RAM (0x110)

.cseg                   ; Volver a la sección de código

CLI             // Quitar interrupciones para evitar problemas

SETUP:
	// Inicializando todas las variables de RAM
	LDI     R16, 0 
	STS     U_SEG, R16  ; Inicializar U_SEG en 0
    STS     D_SEG, R16  ; Inicializar D_SEG en 0
    STS     U_MIN, R16  ; Inicializar U_MIN en 0
    STS     D_MIN, R16  ; Inicializar D_MIN en 0
    STS     U_HORA, R16 ; Inicializar U_HORA en 0
    STS     D_HORA, R16 ; Inicializar D_HORA en 0
    STS     U_DIA, R16  ; Inicializar U_DIA en 0
    STS     D_DIA, R16  ; Inicializar D_DIA en 0
    STS     U_MES, R16  ; Inicializar U_MES en 0
    STS     D_MES, R16  ; Inicializar D_MES en 0

	//	Cargar valor inicial de la tabla
	LDI     ZL, LOW(DISPLAY << 1)   ; Cargar el byte bajo de la dirección de la tabla
    LDI     ZH, HIGH(DISPLAY << 1)  ; Cargar el byte alto de la dirección de la tabla

	// CARGAR VALORES A REGISTROS

    LDI     R16, 100
	STS		TIEMPOR, R16

	LDI		MODO, 0				// INICIAR EL VALOR DEL MODO EN 0
	LDI		TIEMPO, 0			// INICIAR EL VALOR DE TIEMPO EN 0
	LDI		CAMBIADOR, 0


	// Habilitar interrupciones

	LDI     R16, (1 << CLKPCE)
	STS     CLKPR, R16
    LDI     R16, 0b00000100
    STS     CLKPR, R16

    LDI     R16, (1<<CS00) | (1<<CS00)  
    OUT     TCCR0B, R16
	LDS		R16, TIEMPOR
    OUT     TCNT0, R16

    LDI     R16, (1<<TOIE0)
    STS     TIMSK0, R16

	LDI		R16, (1 << PCIE1) | (1 << PCIE0)	// Habilita interrupciones en PC y PB
	STS		PCICR, R16

	LDI		R16, (1 << PCINT8) | (1 << PCINT9) | (1 << PCINT10) // Habilita interrupciones en PC0 , PC1 , PC3
	STS		PCMSK1, R16

	LDI		R16, (1 << PCINT5)  // Habilita interrupciones en PB5
	STS		PCMSK0, R16


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
	SBI		PORTB, PB0
	SBI		DDRB, PB2
	SBI		PORTB, PB2
	SBI		DDRB, PB3
	SBI		PORTB, PB3
	SBI		DDRB, PB4
	SBI		PORTB, PB4

// LEDS SEPARADORES DE DISPLAY
	SBI		DDRB, PB1
	CBI		PORTB, PB1

// BUZZER
	SBI		DDRC, PC5
	CBI		PORTC, PC5

// INICIALIZAR DISPLAY
	LPM		R16, Z
	OUT		PORTD, R16

SEI				// Habilitar interrupciones

MAIN_LOOP:
	CPI		TIEMPO, 50
	BREQ	LEDC1
LED1:
	CPI		TIEMPO, 100
	BREQ	LEDC2
LED2:
	CPI		MODO, 0
	BREQ	HORA_MIN
	CPI		MODO, 1
	BREQ	SETHORA
	CPI		MODO, 2
	BREQ	FECHA
	CPI		MODO, 3
	BREQ	SETFECHA
	CPI		MODO, 4
	BREQ	ALARMA
	
HORA_MIN:
	CBI		PORTC, PC4
	SBI		PORTC, PC3
	CPI		CAMBIADOR, 0
	BREQ	SU_MIN
PRI:
	CPI		CAMBIADOR, 1
	BREQ	SD_MIN
SEG:
	CPI		CAMBIADOR, 2
	BREQ	SU_HORA
TER:
	CPI		CAMBIADOR, 3
	BREQ	SD_HORA
CUAR:
	CPI		CAMBIADOR, 4
	BREQ	REINI
CINC:
	CPI		TIEMPO, 2
	BRNE	MAIN_LOOP
	CLR		TIEMPO
	RJMP	AUMENTAR_VALOR
	RJMP	MAIN_LOOP

SETHORA:

	RJMP	MAIN_LOOP

FECHA:
	SBI		PORTC, PC4
	CBI		PORTC, PC3
	RJMP	MAIN_LOOP

SETFECHA:
	RJMP	MAIN_LOOP

ALARMA: 
	SBI		PORTC, PC3
	RJMP	MAIN_LOOP

REINI:
	LDI		CAMBIADOR, 0
	RJMP	CINC

LEDC1:
	SBI		PORTB, PB1
	RJMP	LED1

LEDC2:
	CBI		PORTB, PB1
	RJMP	LED2

RDISP:
	LDI     ZL, LOW(DISPLAY << 1)   ; Cargar el byte bajo de la dirección de la tabla
    LDI     ZH, HIGH(DISPLAY << 1)  ; Cargar el byte alto de la dirección de la tabla
	RET

SU_MIN:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB0
	LDS		R16, U_MIN
	CALL	CAR_DISP
	RJMP	PRI

SD_MIN:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB2
	LDS		R16, D_MIN
	CALL	CAR_DISP
	RJMP	SEG
SU_HORA:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB3
	LDS		R16, U_HORA
	CALL	CAR_DISP
	RJMP	CUAR
SD_HORA:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB4
	LDS		R16, D_HORA
	CALL	CAR_DISP
	RJMP	MAIN_LOOP

// CARGAR EL VALOR DEL DISPLAY
CAR_DISP:
	// Sumar la posición al registro Z
    ADD     ZL, R16      ; Sumar la posición al byte bajo de Z
    LDI     R16, 0       ; Cargar 0 en R16
    ADC     ZH, R16      ; Sumar el acarreo al byte alto de Z (si hay desbordamiento)
    // Cargar el valor de la tabla en R16 usando LPM
    LPM     R16, Z       ; Cargar el valor de la tabla en R16
    // Enviar el valor al display (PORTB)
    OUT     PORTD, R16   ; Mostrar el valor en el display
	CALL	RDISP
	RET

// AUMENTAR EL VALOR DE LA CUENTA
AUMENTAR_VALOR:
    LDS     R16, U_SEG      
    CPI     R16, 9         
    BREQ    RUSEG           
    INC     R16             
    STS     U_SEG, R16      
    RJMP    MAIN_LOOP       

RUSEG:
    CLR     R16             
    STS     U_SEG, R16      
    LDS     R16, D_SEG      
    CPI     R16, 5          
    BREQ    RDSEG           
    INC     R16             
    STS     D_SEG, R16      
    RJMP    MAIN_LOOP       

RDSEG:
    CLR     R16             
    STS     D_SEG, R16      
    LDS     R16, U_MIN      
    CPI     R16, 9         
    BREQ    RUMIN           
    INC     R16             
    STS     U_MIN, R16      
    RJMP    MAIN_LOOP       

RUMIN:
    CLR     R16             
    STS     U_MIN, R16      
    LDS     R16, D_MIN      
    CPI     R16, 5          
    BREQ    RDMIN           
    INC     R16             
    STS     D_MIN, R16      
    RJMP    MAIN_LOOP       

RDMIN:
    CLR     R16             
    STS     D_MIN, R16      
    LDS     R16, D_HORA     
    CPI     R16, 2          
    BREQ    RRAPIDO         
    LDS     R16, U_HORA     
    CPI     R16, 9         
    BREQ    RUHORA          
    INC     R16             
    STS     U_HORA, R16     
    RJMP    MAIN_LOOP       

RRAPIDO:
    LDS     R16, U_HORA     
    CPI     R16, 3          
    BREQ    RDHORA          
    INC     R16             
    STS     U_HORA, R16     
    RJMP    MAIN_LOOP       

RUHORA:
    CLR     R16             
    STS     U_HORA, R16     
    LDS     R16, D_HORA     
    INC     R16             
    STS     D_HORA, R16     
    RJMP    MAIN_LOOP       

RDHORA:
    CLR     R16             
    STS     D_HORA, R16 
	STS     U_HORA, R16     
    RJMP    MAIN_LOOP       

// PENDIENTE
	//STS		U_DIA, R16
	//CPI		R16, 10
	//BREQ		RDHORA
	//INC		R16
	//LDS		R16, D_HORA
	//RJMP		MAIN_LOOP



// SE ACTIVA CON UN OVERFLOW
TMR0_ISR:
	INC		CAMBIADOR
	LDS		R16, TIEMPOR
    OUT     TCNT0, R16
    INC     TIEMPO
    RETI

// SE ACTIVA AL PRECIONAR UN BOTON
PCINT_ISR:

	SBIS    PINB, PB5   
    RJMP    CAMBIO      
    //SBIS    PINC, PC1   
    //RJMP    BOTON1
	//SBIS    PINC, PC0   
    //RJMP    BOTON2      
    //SBIS    PINC, PC3   
    //RJMP    BOTON3   
    RETI                

CAMBIO:
	INC		MODO				;CAMBIO DE MODO
	CPI		MODO, 2
	BREQ	REINICIO
	RETI

REINICIO:
	CLR		MODO				; Si modo llego a 5 se reincia a 5
	RETI

//BOTON1:							;Funcionamiento para boton 1
//	CPI		MODO, 1				;Se activa si estamos en modo config hora
//	BREQ	SUMA_HORA
//	CPI		MODO, 3				;Se activa si estamos en modo config fecha
//	BREQ	SUMA_FECHA
//	CPI		MODO, 4
//	BREQ	RESTA_ALA			;Se activa si estamos en modo config alarma
//	RETI
//
//BOTON2:
//	CPI		MODO, 1
//	BREQ	RESTA_HORA			;Se activa si estamos en modo config hora
//	CPI		MODO, 3
//	BREQ	RESTA_FECHA			;Se activa si estamos en modo config fecha
//	CPI		MODO, 4
//	BREQ	RESTA_ALA			;Se activa si estamos en modo config alarma
//	RETI
//
//BOTON3:
//	CPI		MODO, 1
//	BREQ	CAMBIARDISPLAY		;Se activa si estamos en modo config hora
//	CPI		MODO, 3
//	BREQ	CAMBIARDISPLAY		;Se activa si estamos en modo config fecha
//	CPI		MODO, 4
//	BREQ	RESTA_ALA			;Se activa si estamos en modo config alarma
//	RETI


