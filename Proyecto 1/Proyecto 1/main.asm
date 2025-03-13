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

.org OVF2addr           ; Vector de interrupción por overflow del Timer2
    JMP     TMR2_ISR    ; Saltar a la rutina de interrupción del Timer2

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
.def	CALEDS = R22
.def	CTIMERS = R23
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
MDISP: .byte 1         ; Guardado en RAM (0x111)
ACTISUM: .byte 1         ; Guardado en RAM (0x112)
ACTIRES: .byte 1         ; Guardado en RAM (0x113)
MODOQ: .byte 1			; Guardado en RAM (0x114)

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
	STS     D_DIA, R16  ; Inicializar D_DIA en 0
    STS     D_MES, R16  ; Inicializar U_MES en 0
	STS     MDISP, R16  ; Inicializar MDISP en 0
	STS     ACTISUM, R16  ; Inicializar ACTISUM en 0
	STS     ACTIRES, R16  ; Inicializar ACTIRES en 0
	STS     MODOQ, R16  ; Inicializar MODOQ en 0
	LDI     R16, 1
    STS     U_DIA, R16  ; Inicializar U_DIA en 1
    STS     U_MES, R16  ; Inicializar U_MES en 1
    

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

    LDI     R16, (1<<CS00) //| (1<<CS01)  
    OUT     TCCR0B, R16
	LDS		R16, TIEMPOR
    OUT     TCNT0, R16

	LDI     R16, (1<<CS21) 
    STS     TCCR2B, R16
	LDS		R16, TIEMPOR
    STS     TCNT2, R16

	LDI     R16, (1<<TOIE0)
    STS     TIMSK0, R16

    LDI     R16, (1<<TOIE2)
    STS     TIMSK2, R16

	LDI		R16, (1 << PCIE1)	// Habilita interrupciones en PC 
	STS		PCICR, R16

	LDI		R16, (1 << PCINT8) | (1 << PCINT9) | (1 << PCINT10) | (1 << PCINT11) // Habilita interrupciones en PC0 , PC1 , PC2 ,PC3
	STS		PCMSK1, R16

// DISPLAY
	LDI		R16, 0xFF
	OUT		DDRD, R16
	LDI		R16, 0x00
	OUT		PORTD, R16


// LED RGB
	SBI		DDRC, PC4
	CBI		PORTC, PC4
	SBI		DDRC, PC5
	CBI		PORTC, PC5

// BOTONES
	CBI		DDRC, PC0 ; AUMENTAR VALOR
	SBI		PORTC, PC0 ; PULL-UP
	CBI		DDRC, PC1 ; DISMINUIR VALOR
	SBI		PORTC, PC1 ; PULL-UP
	CBI		DDRC, PC2 ; SELECCIONADOR DE DISPLAYS
	SBI		PORTC, PC2 ; PULL-UP
	CBI		DDRC, PC3 ; CAMBIO DE MODO
	SBI		PORTC, PC3 ; PULL-UP

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
	SBI		DDRB, PB5
	CBI		PORTB, PB5

// INICIALIZAR DISPLAY
	LPM		R16, Z
	OUT		PORTD, R16

SEI				// Habilitar interrupciones

MAIN_LOOP:
	CPI		CALEDS, 125
	BREQ	LEDC1
LED1:
	CPI		CALEDS, 250
	BREQ	LEDC2
LED2:
	CPI		MODO, 0
	BREQ	HORA_MIN
	CPI		MODO, 1
	BREQ	SETHORA
	CPI		MODO, 2
	BREQ	LFECHA
	CPI		MODO, 3
	BREQ	LSETFECHA
	CPI		MODO, 4
	BREQ	LALARMA
	RJMP    MAIN_LOOP

LFECHA:
	RJMP	FECHA

LSETFECHA:
	RJMP	SETFECHA

LALARMA:
	RJMP	ALARMA

LEDC1:
	SBI		PORTB, PB1
	RJMP	LED1

LEDC2:
	CBI		PORTB, PB1
	RJMP	LED2


HORA_MIN:
	CBI		PORTC, PC4
	SBI		PORTC, PC5
	LDI		SLIDER, 0 
CER:
	CPI		CAMBIADOR, 0
	BREQ	LSU_MIN
PRI:
	CPI		CAMBIADOR, 1
	BREQ	LSD_MIN
SEG:
	CPI		CAMBIADOR, 2
	BREQ	LSU_HORA
TER:
	CPI		CAMBIADOR, 3
	BREQ	LSD_HORA
CUAR:
	LDS		R16, MODOQ
	CPI		R16, 1
	BREQ	LMAIN_LOOP
	CPI		TIEMPO, 2
	BRNE	LMAIN_LOOP
	CLR		TIEMPO
	RJMP	AUMENTAR_VALOR
	RJMP	MAIN_LOOP

LSU_MIN:
	RJMP	SU_MIN
LSD_MIN:
	RJMP	SD_MIN
LSU_HORA:
	RJMP	SU_HORA
LSD_HORA:
	RJMP	SD_HORA
LMAIN_LOOP:
	RJMP	MAIN_LOOP

SETHORA:
	CBI		PORTC, PC4
	SBI		PORTC, PC5

	LDS		R16, MODOQ		; Deshabilitar Suma
	LDI		R16, 1			;
	STS		MODOQ, R16		;

	LDS		R16, ACTISUM
	SBRC	R16, 0
	RJMP	MAINSD1
REGS:
	LDS		R16, ACTIRES
	SBRC	R16, 0
	RJMP	MAINRD1
	RJMP	CER

MAINSD1:
	LDS		R16, ACTISUM	;REINICIAR ACTIVADOR DE SUMA	
	CLR		R16
	STS		ACTISUM, R16

	CPI		SLIDER, 0
	BREQ	COMSH
	//CPI	SLIDER, 1
	//BREQ	COMSM
	RJMP    MAIN_LOOP

MAINRD1:
	LDS		R16, ACTIRES	;REINICIAR ACTIVADOR DE RESTA
	CLR		R16				
	STS		ACTIRES, R16

	CPI		SLIDER, 0
	BREQ	COMRH
	//CPI		SLIDER, 1
	//BREQ	COMRM
	RJMP    MAIN_LOOP

COMSH:
	LDS		R16, MDISP
	SBRS	R16, 0
	RJMP	SUMMIN
	SBRC	R16, 0
	RJMP	SUMHORA

COMRH:
	LDS		R16, MDISP
	SBRS	R16, 0
	RJMP	RESMIN
	SBRC	R16, 0
	RJMP	RESHORA

	//	PENDIENTE 
//COMSM:
//	LDS		R16, MDISP
//	SBRS	MDISPLAY, 0
//	RJMP	SUMMES
//	SBRC	MDISPLAY, 0
//	RJMP	SUMDIA
//COMRM:
//	LDS		R16, MDISP
//	SBRS	MDISPLAY, 0
//	RJMP	RESMES
//	SBRC	MDISPLAY, 0
//	RJMP	RESDIA

SUMMIN:
	LDS		R16, U_MIN
	INC		R16
	CPI		R16, 10
	BREQ	CDMIN
	STS		U_MIN, R16
	RJMP	REGS

CDMIN:
	CLR		R16
	STS		U_MIN, R16
	LDS		R16, D_MIN
	INC		R16
	CPI		R16, 6
	BREQ	REMIN
	STS		D_MIN, R16
	RJMP	REGS

REMIN:
	CLR		R16
	STS		D_MIN, R16
	RJMP	REGS

SUMHORA:
	LDS		R16, D_HORA
	CPI		R16, 2
	BREQ	CONTCUA
	LDS		R16, U_HORA
	INC		R16
	CPI		R16, 10
	BREQ	CDHORA
	STS		U_HORA, R16
	RJMP	REGS

CONTCUA:
	LDS		R16, U_HORA
	INC		R16
	CPI		R16, 5
	BREQ	REHORA
	STS		U_HORA, R16
	RJMP	REGS

CDHORA:
	CLR		R16
	STS		U_HORA, R16
	LDS		R16, D_HORA
	INC		R16
	STS		D_HORA, R16
	RJMP	REGS

REHORA:
	CLR		R16
	STS		D_HORA, R16
	STS		U_HORA, R16
	RJMP	REGS

RESMIN:
	LDS		R16, U_MIN
	DEC		R16
	CPI		R16, 0xFF
	BREQ	RCDMIN
	STS		U_MIN, R16
	RJMP	CER

RCDMIN:
	LDI		R16, 9
	STS		U_MIN, R16
	LDS		R16, D_MIN
	DEC		R16
	CPI		R16, 0xFF
	BREQ	RREMIN
	STS		D_MIN, R16
	RJMP	CER

RREMIN:
	LDI		R16, 5
	STS		D_MIN, R16
	RJMP	CER

RESHORA:
	LDS		R16, D_HORA
	CPI		R16, 0
	BREQ	RCONTCUA
	LDS		R16, U_HORA
	DEC		R16
	CPI		R16, 0xFF
	BREQ	RCDHORA
	STS		U_HORA, R16
	RJMP	CER

RCONTCUA:
	LDS		R16, U_HORA
	DEC		R16
	CPI		R16, 0xFF
	BREQ	RREHORA
	STS		U_HORA, R16
	RJMP	CER

RCDHORA:
	LDI		R16, 9
	STS		U_HORA, R16
	LDS		R16, D_HORA
	DEC		R16
	STS		D_HORA, R16
	RJMP	CER

RREHORA:
	LDI		R16, 2
	STS		D_HORA, R16
	LDI		R16, 4
	STS		U_HORA, R16
	RJMP	CER

FECHA:
	SBI		PORTC, PC4
	CBI		PORTC, PC5
	LDI		SLIDER, 1
	LDS		R16, MODOQ
	CLR		R16
	STS		MODOQ, R16
	RJMP	CER

SETFECHA:
	SBI		PORTC, PC4
	CBI		PORTC, PC5
	LDS		R16, MODOQ
	LDI		R16, 1
	STS		MODOQ, R16
	RJMP	MAIN_LOOP

ALARMA: 
	SBI		PORTC, PC4
	SBI		PORTC, PC5
	LDS		R16, MODOQ
	LDI		R16, 0
	STS		MODOQ, R16
	SBI		PORTC, PC5
	RJMP	MAIN_LOOP

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
	SBRS	SLIDER, 0
	LDS		R16, U_MIN
	SBRC	SLIDER, 0
	LDS		R16, U_MES
	CALL	CAR_DISP
	RJMP	PRI

SD_MIN:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB2
	SBRS	SLIDER, 0
	LDS		R16, D_MIN
	SBRC	SLIDER, 0
	LDS		R16, D_MES
	CALL	CAR_DISP
	RJMP	SEG
SU_HORA:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB3
	SBRS	SLIDER, 0
	LDS		R16, U_HORA
	SBRC	SLIDER, 0
	LDS		R16, U_DIA
	CALL	CAR_DISP
	RJMP	TER

SD_HORA:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB4
	SBRS	SLIDER, 0
	LDS		R16, D_HORA
	SBRC	SLIDER, 0
	LDS		R16, D_DIA
	CALL	CAR_DISP
	RJMP	CUAR


// CARGAR EL VALOR DEL DISPLAY
CAR_DISP:
	// Sumar la posición al registro Z
    ADD     ZL, R16      ; Sumar la posición al byte bajo de Z
    LDI     R16, 0       ; Cargar 0 en R16
    ADC     ZH, R16      ; Sumar el acarreo al byte alto de Z (si hay desbordamiento)
    // Cargar el valor de la tabla en R16 usando LPM
    LPM     R16, Z       ; Cargar el valor de la tabla en R16
    // Enviar el valor al display (PORTD)
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
	LDS		R16, D_MES
	CPI		R16, 1
	BREQ	FINALES       
	LDS		R16, U_MES
	CPI		R16, 1
	BREQ	LARGOS
	CPI		R16, 2
	BREQ	FEB
	CPI		R16, 3
	BREQ	LARGOS
	CPI		R16, 4
	BREQ	CORTOS
	CPI		R16, 5
	BREQ	LARGOS
	CPI		R16, 6
	BREQ	CORTOS
	CPI		R16, 7
	BREQ	LARGOS
	CPI		R16, 8
	BREQ	LARGOS
	CPI		R16, 9
	BREQ	CORTOS
	RJMP	MAIN_LOOP

FINALES:
	LDS		R16, U_MES
	CPI		R16, 0
	BREQ	LARGOS
	CPI		R16, 1
	BREQ	CORTOS
	CPI		R16, 2
	BREQ	DICI
	RJMP	MAIN_LOOP

LARGOS:
	LDS		R16, D_DIA
	CPI		R16, 3
	BREQ	FMESL
	RJMP	COMUN1
CORTOS:
	LDS		R16, D_DIA
	CPI		R16, 3
	BREQ	FMESC
	RJMP	COMUN1
FEB:
	LDS		R16, D_DIA
	CPI		R16, 2
	BREQ	FMESFEB
	RJMP	COMUN1
DICI:
	LDS		R16, D_DIA
	CPI		R16, 3
	BREQ	FMESDIC
COMUN1:
	LDS		R16, U_DIA
	CPI		R16, 9
	BREQ	UDIA
	INC		R16
	STS		U_DIA, R16
	RJMP	MAIN_LOOP

FMESL:
	LDS		R16, U_DIA
	CPI		R16, 1
	BREQ	UMESF
	RJMP	COMUN2
FMESC:
	LDS		R16, U_DIA
	CPI		R16, 0
	BREQ	UMESF
	RJMP	COMUN2
FMESFEB:
	LDS		R16, U_DIA
	CPI		R16, 8
	BREQ	UMESF
	RJMP	COMUN2
FMESDIC:
	LDS		R16, U_DIA
	CPI		R16, 1
	BREQ	UMESFD
COMUN2:
	INC		R16
	STS		U_DIA, R16
	RJMP	MAIN_LOOP

UDIA:
	CLR		R16
	STS		U_DIA, R16
	LDS		R16, D_DIA
	INC		R16
	STS		D_DIA, R16
	RJMP	MAIN_LOOP

UMESF:
	LDI		R16, 1
	STS		U_DIA, R16
	CLR		R16
	STS		D_DIA, R16
	LDS		R16, U_MES
	INC		R16
	STS		U_MES, R16
	RJMP	MAIN_LOOP

UMESFD:
	CLR		R16
	STS		D_MES, R16
	STS		D_DIA, R16
	LDI		R16, 1
	STS		U_MES, R16
	STS		U_DIA, R16
	RJMP	MAIN_LOOP
			
			

// SE ACTIVA CON UN OVERFLOW
TMR0_ISR:
	LDS		CTIMERS, TIEMPOR
    OUT     TCNT0, CTIMERS
    INC     TIEMPO
    RETI

TMR2_ISR:
	INC		CAMBIADOR
	CPI		CAMBIADOR, 4
	BREQ	RCAMBIADOR
SIGUE:
	INC		CALEDS
	LDS		CTIMERS, TIEMPOR
	STS     TCNT2, CTIMERS
	RETI

RCAMBIADOR:
	LDI		CAMBIADOR, 0
	RJMP	SIGUE

// SE ACTIVA AL PRECIONAR UN BOTON
PCINT_ISR:
	SBIS    PINC, PC3   
    RJMP    CAMBIO      
    SBIS    PINC, PC2   
    RJMP    BOTON3
	SBIS    PINC, PC1   
    RJMP    BOTON2      
    SBIS    PINC, PC0   
    RJMP    BOTON1   
    RETI                

CAMBIO:
	INC		MODO				;CAMBIO DE MODO
	CPI		MODO, 5
	BREQ	REINICIO
	RETI

REINICIO:
	CLR		MODO				; Si modo llego a 5 se reincia a 5
	RETI

BOTON1:							;Funcionamiento para boton 1
	CPI		MODO, 1				;Se activa si estamos en modo config hora
	BREQ	SUMA
	CPI		MODO, 3				;Se activa si estamos en modo config fecha
	BREQ	SUMA
	CPI		MODO, 4
	BREQ	SUMA			;Se activa si estamos en modo config alarma
	RETI

SUMA:
	LDS		R16, ACTISUM
	INC		R16
	STS		ACTISUM, R16
	RETI 

BOTON2:
	CPI		MODO, 1
	BREQ	RESTA			;Se activa si estamos en modo config hora
	CPI		MODO, 3
	BREQ	RESTA			;Se activa si estamos en modo config fecha
	CPI		MODO, 4
	BREQ	RESTA			;Se activa si estamos en modo config alarma
	RETI

RESTA:
	LDS		R16, ACTIRES
	INC		R16
	STS		ACTIRES, R16
	RETI 

BOTON3:
	CPI		MODO, 1
	BREQ	CAMBIARDISPLAY		;Se activa si estamos en modo config hora
	CPI		MODO, 3
	BREQ	CAMBIARDISPLAY		;Se activa si estamos en modo config fecha
	CPI		MODO, 4
	BREQ	CAMBIARDISPLAY			;Se activa si estamos en modo config alarma
	RETI

CAMBIARDISPLAY:
	LDS		R16, MDISP
	INC		R16
	STS		MDISP, R16
	RETI



