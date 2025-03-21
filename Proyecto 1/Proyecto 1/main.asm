;
; Proyecto 1.asm
;
; Created: 3/9/2025 3:30:11 PM
; Author : super
;
.include "m328Pdef.inc"  
.cseg                   ; Comienza la secci�n de c�digo
.org 0x0000             
    JMP     START       

.org PCI1addr           ; Vector de interrupci�n de PCINT
    JMP     PCINT_ISR   ; Saltar a la rutina de interrupci�n de PCINT

.org OVF2addr           ; Vector de interrupci�n por overflow del Timer2
    JMP     TMR2_ISR    ; Saltar a la rutina de interrupci�n del Timer2

.org OVF0addr           ; Vector de interrupci�n por overflow del Timer0
    JMP     TMR0_ISR    ; Saltar a la rutina de interrupci�n del Timer0

START:
    ; Configuraci�n de la pila
    LDI     R16, LOW(RAMEND)    ; Cargar el byte bajo de RAMEND en R16
    OUT     SPL, R16            ; Cargar R16 en SPL (Stack Pointer Low)
    LDI     R16, HIGH(RAMEND)   ; Cargar el byte alto de RAMEND en R16
    OUT     SPH, R16            ; Cargar R16 en SPH (Stack Pointer High)

; Tabla de valores para el display de 7 segmentos (0-9)
DISPLAY: 
    .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
.def	CALEDS = R10
.def	COMPARAR2 = R11
.def	STOPALAR = R12
.def	ALAREN = R13
.def	COMPARAR = R14
.def	CLEDS = R15
.def	MODO = R17
.def	TIEMPO = R18
.def	COUNTER = R19
.def	SLIDER = R20
.def	CAMBIADOR = R21
.def	CTIMERS = R22
.def	CTMES = R23
.def	CVALARM = R24
.def	HDALARM = R25
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
U_AMIN:  .byte 1         ; Guardado en RAM (0x115)
D_AMIN:  .byte 1         ; Guardado en RAM (0x116)
U_AHORA: .byte 1         ; Guardado en RAM (0x117)
D_AHORA: .byte 1         ; Guardado en RAM (0x118)

.cseg                   ; Volver a la secci�n de c�digo

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
	STS     U_AMIN, R16  ; Inicializar U_AMIN en 0
    STS     D_AMIN, R16  ; Inicializar D_AMIN en 0
    STS     U_AHORA, R16 ; Inicializar U_AHORA en 0
    STS     D_AHORA, R16 ; Inicializar D_AHORA en 0
	STS     MDISP, R16  ; Inicializar MDISP en 0
	STS     ACTISUM, R16  ; Inicializar ACTISUM en 0
	STS     ACTIRES, R16  ; Inicializar ACTIRES en 0
	STS     MODOQ, R16  ; Inicializar MODOQ en 0
	LDI     R16, 1
    STS     U_DIA, R16  ; Inicializar U_DIA en 1
    STS     U_MES, R16  ; Inicializar U_MES en 1
    

	//	Cargar valor inicial de la tabla
	LDI     ZL, LOW(DISPLAY << 1)   ; Cargar el byte bajo de la direcci�n de la tabla
    LDI     ZH, HIGH(DISPLAY << 1)  ; Cargar el byte alto de la direcci�n de la tabla

	// CARGAR VALORES A REGISTROS
	CLR		R16
	MOV		STOPALAR, R16 
	MOV		ALAREN, R16 
	MOV		COMPARAR, R16
	MOV		COMPARAR2, R16  
	MOV		CLEDS, R16 
	MOV		CALEDS, R16 
    LDI     R16, 100
	STS		TIEMPOR, R16

	LDI		MODO, 0				// INICIAR EL VALOR DEL MODO EN 0
	LDI		TIEMPO, 0			// INICIAR EL VALOR DE TIEMPO EN 0
	LDI		CAMBIADOR, 0		// INICIAR EL VALOR DE CAMBIADOR EN 0
	LDI		CTMES, 0			// INICIAR EL VALOR DE CTMES EN 0
	LDI		HDALARM, 0			// INICIAR EL VALOR DE HDALARM EN 0

// Habilitar interrupciones
	LDI     R16, (1 << CLKPCE)
	STS     CLKPR, R16
    LDI     R16, 0b00000100
    STS     CLKPR, R16

    LDI     R16, (1<<CS00) | (1<<CS01)  
    OUT     TCCR0B, R16
	LDS		R16, TIEMPOR
    OUT     TCNT0, R16

	LDI     R16, (1<<CS21) 
    STS     TCCR2B, R16

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

// MAIN LOOP
MAIN_LOOP:
	CALL	LEDC
	CPI		MODO, 0
	BREQ	HORA_MIN
	CPI		MODO, 1
	BREQ	LSETHORA
	CPI		MODO, 2
	BREQ	LFECHA
	CPI		MODO, 3
	BREQ	LSETFECHA
	CPI		MODO, 4
	BREQ	LALARMA
	RJMP    MAIN_LOOP

// LAUNCHERS A FUNCIONES DEMASIADO LEJOS PARA BREQ
LSETHORA:
	RJMP	SETHORA
LFECHA:
	RJMP	FECHA

LSETFECHA:
	RJMP	SETFECHA

LALARMA:
	RJMP	ALARMA

// CAMBIADORES DE LEDS DE DISPLAYS
LEDC:
	SBRC	HDALARM, 0				; revisamos que modo queremos usar
	CALL	LE1
	SBRS	HDALARM, 0				; Si Hdalarm es 1 los leds trabajaran mas rapido y se podra entrar a la interrupcion de alarma
	CALL	LE2
	RET

LE1:
	SBRS	CALEDS, 7
	RJMP	ON
	SBRC	CALEDS, 7
	RJMP	OFF
	RET

LE2:
	SBRS	CLEDS, 6
	RJMP	ON
	SBRC	CLEDS, 6
	RJMP	OFF
	RET

ON:
	SBI		PORTB, PB1
	RET
OFF:
	CBI		PORTB, PB1
	RET

// PRIMER MODO, ENSE�AR HORA/MIN
HORA_MIN:
	CBI		PORTC, PC4
	SBI		PORTC, PC5
	LDS		R16, MODOQ
	CLR		R16
	STS		MODOQ, R16
	LDI		SLIDER, 0				; slider en 0 para indicar que vamos a horas
	LDI		CVALARM, 0				; apagamos alarma para evitar problemas al cambiar
CER:								; Tiene separaciones para que cada revision se haga sin ningun problema y no se conflicte
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
	CPI		HDALARM, 1				; revisamos si alarma esta encendida para revisar si tenemos que activarla
	BREQ	RUALARM
RTIEMP:
	CPI		TIEMPO, 100				 ;esperamos que tiempo sea 100 para cumplir un segundo y despues reiniciarlo
	BRNE	LMAIN_LOOP
	CLR		TIEMPO
	RJMP	AUMENTAR_VALOR

// MAS LAUNCHERS PARA ENSE�AR DISPLAY
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

// COMPROBAR SI LA HORA DE LA ALARMA LLEGO
RUALARM:
	LDS		COMPARAR2, D_HORA				// COMPROBAR SI LA DECENA DE HORA ES LA CORRECTA
	LDS		COMPARAR, D_AHORA
	CP		COMPARAR2, COMPARAR
	BREQ	PRICOI
	RJMP	RTIEMP
PRICOI:
	LDS		COMPARAR2, U_HORA				// COMPROBAR SI LA UNIDAD DE HORA ES LA CORRECTA
	LDS		COMPARAR, U_AHORA
	CP		COMPARAR2, COMPARAR
	BREQ	SEGCOI
	RJMP	RTIEMP
SEGCOI:
	LDS		COMPARAR2, D_MIN			// COMPROBAR SI LA DECENA DE MINUTO ES LA CORRECTA
	LDS		COMPARAR, D_AMIN
	CP		COMPARAR2, COMPARAR
	BREQ	TERCOI
	RJMP	RTIEMP
TERCOI:
	LDS		COMPARAR2, U_MIN			// COMPROBAR SI LA UNIDAD DE MINUTO ES LA CORRECTA
	LDS		COMPARAR, U_AMIN
	CP		COMPARAR2, COMPARAR
	BREQ	CUARCOI
	RJMP	RTIEMP
CUARCOI:
	LDS		COMPARAR2, U_MIN			// COMPROBAR SI LA UNIDAD DE MINUTO ES LA CORRECTA
	LDS		COMPARAR, U_AMIN
	CP		COMPARAR2, COMPARAR
	BREQ	PARAR
	RJMP	RTIEMP

PARAR:
	SBI		PORTB, PB5			// NOS QUEDAMOS AQUI HASTA QUE SE PRESIONE EL BOTON
	LDI		R16, 1
	MOV		ALAREN, R16
	MOV		R16, STOPALAR
	CPI		R16, 1
	BREQ	SALIR
	RJMP	PARAR

SALIR:
	CLR		R16					// SE PRESIONO EL BOTON Y REGRESAMOS A LA NORMALIDAD
	MOV		STOPALAR, R16
	CLR		HDALARM
	CBI		PORTB, PB5
	CLR		R16
	MOV		ALAREN, R16
	RJMP	RTIEMP

// SEGUNDO MODO DE FUNCIONAMIENTO, CAMBIAR HORA Y FECHA
SETHORA:
	CBI		PORTC, PC4		; ACTIVAR LEDS Y QUE EL RGB TITILE
	SBRC	CALEDS, 7
	SBI		PORTC, PC5
	SBRS	CALEDS, 7
	CBI		PORTC, PC5
	LDI		SLIDER, 0 
	LDI		CVALARM, 0		; Desactivar guardar registros en alarma
	CLR		HDALARM     	; Apagara el modo encendido de la alarma

COMUN:
	LDS		R16, MODOQ		; Deshabilitar Suma
	LDI		R16, 1			;
	STS		MODOQ, R16		;

	LDS		R16, ACTISUM	; REVISAR SI BANDERA DE SUMA ESTA ACTIVA
	SBRC	R16, 0
	RJMP	MAINSD1
REGS:
	LDS		R16, ACTIRES	; REVISAR SI BANDERA DE RESTA ESTA ACTIVA
	SBRC	R16, 0
	RJMP	MAINRD1
	RJMP	CER				; SALTO PARA ENSE�AR VALOR A DISPLAYS

MAINSD1:
	LDS		R16, ACTISUM	; REINICIAR ACTIVADOR DE SUMA	
	CLR		R16
	STS		ACTISUM, R16

	CPI		SLIDER, 0		; REVISAR DE DONDE VENIMOS Y SI QUEREMOS ENCENCER MES O HORA
	BREQ	COMSH
	CPI		SLIDER, 1
	BREQ	COMSM
	CPI		SLIDER, 2		; REVISAR DE DONDE VENIMOS Y SI QUEREMOS ENCENCER MES O HORA
	BREQ	COMSH
	RJMP    MAIN_LOOP

MAINRD1:
	LDS		R16, ACTIRES	; REINICIAR ACTIVADOR DE RESTA
	CLR		R16				
	STS		ACTIRES, R16

	CPI		SLIDER, 0		; con ayuda del slider sabremos si venimos de fecha o hora para cambiar el respectivo de cada uno
	BREQ	COMRH
	CPI		SLIDER, 1
	BREQ	COMRM
	CPI		SLIDER, 2
	BREQ	COMRH
	RJMP    MAIN_LOOP

COMSH:
	LDS		R16, MDISP		; SUMA O RESTA DE HORA
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

COMSM:
	LDS		R16, MDISP		; SUMA O RESTA DE MES
	SBRS	R16, 0
	RJMP	SUMMES
	SBRC	R16, 0
	RJMP	SUMDIA

COMRM:
	LDS		R16, MDISP
	SBRS	R16, 0
	RJMP	RESMES
	SBRC	R16, 0
	RJMP	RESDIA

// FUNCIONAMIENTO DE SUMA PARA MINUTOS
SUMMIN:
    SBRS    CVALARM, 0
    LDS     R16, U_MIN
    SBRC    CVALARM, 0
    LDS     R16, U_AMIN
    INC     R16
    CPI     R16, 10
    BREQ    CDMIN
    SBRC    CVALARM, 0
    STS     U_AMIN, R16
    SBRS    CVALARM, 0
    STS     U_MIN, R16
    RJMP    REGS

CDMIN:
    CLR     R16
    SBRC    CVALARM, 0
    STS     U_AMIN, R16
    SBRS    CVALARM, 0
    STS     U_MIN, R16
    SBRS    CVALARM, 0
    LDS     R16, D_MIN
    SBRC    CVALARM, 0
    LDS     R16, D_AMIN
    INC     R16
    CPI     R16, 6
    BREQ    REMIN
    SBRC    CVALARM, 0
    STS     D_AMIN, R16
    SBRS    CVALARM, 0
    STS     D_MIN, R16
    RJMP    REGS

REMIN:
    CLR     R16
    SBRC    CVALARM, 0
    STS     D_AMIN, R16
    SBRS    CVALARM, 0
    STS     D_MIN, R16
    RJMP    REGS

// FUNCIONAMIENTO DE SUMA PARA HORA
SUMHORA:
    SBRS    CVALARM, 0
    LDS     R16, D_HORA
    SBRC    CVALARM, 0
    LDS     R16, D_AHORA
    CPI     R16, 2
    BREQ    CONTCUA
    SBRS    CVALARM, 0
    LDS     R16, U_HORA
    SBRC    CVALARM, 0
    LDS     R16, U_AHORA
    INC     R16
    CPI     R16, 10
    BREQ    CDHORA
    SBRC    CVALARM, 0
    STS     U_AHORA, R16
    SBRS    CVALARM, 0
    STS     U_HORA, R16
    RJMP    REGS

CONTCUA:
    SBRS    CVALARM, 0
    LDS     R16, U_HORA
    SBRC    CVALARM, 0
    LDS     R16, U_AHORA
    INC     R16
    CPI     R16, 4
    BREQ    REHORA
    SBRC    CVALARM, 0
    STS     U_AHORA, R16
    SBRS    CVALARM, 0
    STS     U_HORA, R16
    RJMP    REGS

CDHORA:
    CLR     R16
    SBRC    CVALARM, 0
    STS     U_AHORA, R16
    SBRS    CVALARM, 0
    STS     U_HORA, R16
    SBRS    CVALARM, 0
    LDS     R16, D_HORA
    SBRC    CVALARM, 0
    LDS     R16, D_AHORA
    INC     R16
	SBRS    CVALARM, 0
    STS     D_HORA, R16
	SBRC    CVALARM, 0
    STS     D_AHORA, R16
    RJMP    REGS

REHORA:
    CLR     R16
    SBRC    CVALARM, 0
    STS     D_AHORA, R16
    SBRS    CVALARM, 0
    STS     D_HORA, R16
    SBRC    CVALARM, 0
    STS     U_AHORA, R16
    SBRS    CVALARM, 0
    STS     U_HORA, R16
    RJMP    REGS

// FUNCIONAMIENTO DE RESTA PARA MINUTO
RESMIN:
    SBRS    CVALARM, 0
    LDS     R16, U_MIN
    SBRC    CVALARM, 0
    LDS     R16, U_AMIN
    DEC     R16
    CPI     R16, 0xFF
    BREQ    RCDMIN
    SBRC    CVALARM, 0
    STS     U_AMIN, R16
    SBRS    CVALARM, 0
    STS     U_MIN, R16
    RJMP    CER

RCDMIN:
    LDI     R16, 9
    SBRC    CVALARM, 0
    STS     U_AMIN, R16
    SBRS    CVALARM, 0
    STS     U_MIN, R16
    SBRS    CVALARM, 0
    LDS     R16, D_MIN
    SBRC    CVALARM, 0
    LDS     R16, D_AMIN
    DEC     R16
    CPI     R16, 0xFF
    BREQ    RREMIN
    SBRC    CVALARM, 0
    STS     D_AMIN, R16
    SBRS    CVALARM, 0
    STS     D_MIN, R16
    RJMP    CER

RREMIN:
    LDI     R16, 5
    SBRC    CVALARM, 0
    STS     D_AMIN, R16
    SBRS    CVALARM, 0
    STS     D_MIN, R16
    RJMP    CER

// FUNCIONAMIENTO DE RESTA PARA HORA
RESHORA:
    SBRS    CVALARM, 0
    LDS     R16, D_HORA
    SBRC    CVALARM, 0
    LDS     R16, D_AHORA
    CPI     R16, 0
    BREQ    RCONTCUA
    SBRS    CVALARM, 0
    LDS     R16, U_HORA
    SBRC    CVALARM, 0
    LDS     R16, U_AHORA
    DEC     R16
    CPI     R16, 0xFF
    BREQ    RCDHORA
    SBRC    CVALARM, 0
    STS     U_AHORA, R16
    SBRS    CVALARM, 0
    STS     U_HORA, R16
    RJMP    CER

RCONTCUA:
    SBRS    CVALARM, 0
    LDS     R16, U_HORA
    SBRC    CVALARM, 0
    LDS     R16, U_AHORA
    DEC     R16
    CPI     R16, 0xFF
    BREQ    RREHORA
    SBRC    CVALARM, 0
    STS     U_AHORA, R16
    SBRS    CVALARM, 0
    STS     U_HORA, R16
    RJMP    CER

RCDHORA:
    LDI     R16, 9
    SBRC    CVALARM, 0
    STS     U_AHORA, R16
    SBRS    CVALARM, 0
    STS     U_HORA, R16
    SBRS    CVALARM, 0
    LDS     R16, D_HORA
    SBRC    CVALARM, 0
    LDS     R16, D_AHORA
    DEC     R16
	SBRS    CVALARM, 0
    STS     D_HORA, R16
	SBRC    CVALARM, 0
    STS     D_AHORA, R16
    RJMP    CER

RREHORA:
    LDI     R16, 2
    SBRC    CVALARM, 0
    STS     D_AHORA, R16
    SBRS    CVALARM, 0
    STS     D_HORA, R16
    LDI     R16, 3
    SBRC    CVALARM, 0
    STS     U_AHORA, R16
    SBRS    CVALARM, 0
    STS     U_HORA, R16
    RJMP    CER

// FUNCIONAMIENTO DE SUMA PARA MES
SUMMES:
	LDS		R16, D_MES
	CPI		R16, 1
	BREQ	MESRR
	LDS		R16, U_MES
	INC		R16
	CPI		R16, 10
	BREQ	CLRMES
	STS		U_MES, R16
	RJMP	REGS

MESRR:
	LDS		R16, U_MES
	INC		R16
	CPI		R16, 3
	BREQ	CLRLMES
	STS		U_MES, R16
	RJMP	REGS

CLRMES:
	CLR		R16
	STS		U_MES, R16
	LDS		R16, D_MES
	INC		R16
	STS		D_MES, R16
	RJMP	REGS

CLRLMES:
	CLR		R16
	STS		D_MES, R16
	LDI		R16, 1
	STS		U_MES, R16
	RJMP	REGS

// FUNCIONAMIENTO DE SUMA PARA DIA	
SUMDIA:
	CLR		CTMES
SELMES:
	LDS		R16, D_MES
	CPI		R16, 1
	BREQ	FINA      
	LDS		R16, U_MES		; REVISAMOS EN QUE MES ESTAMOS Y ASI DECIDIMOS CUANTOS DIAS TENDRA
	CPI		R16, 1
	BREQ	TREUNO
	CPI		R16, 2
	BREQ	VEINTE8
	CPI		R16, 3
	BREQ	TREUNO
	CPI		R16, 4
	BREQ	TRECERO
	CPI		R16, 5
	BREQ	TREUNO
	CPI		R16, 6
	BREQ	TRECERO
	CPI		R16, 7
	BREQ	TREUNO
	CPI		R16, 8
	BREQ	TREUNO
	CPI		R16, 9
	BREQ	TRECERO
	RJMP	MAIN_LOOP
FINA:							; revisamos si estamos en meses finales 10, 11 y 12
	LDS		R16, U_MES
	CPI		R16, 0
	BREQ	TREUNO
	CPI		R16, 1
	BREQ	TRECERO
	CPI		R16, 2
	BREQ	TREUNO
	RJMP	MAIN_LOOP

TREUNO:
	SBRS	CTMES, 0
	RJMP	SUMADIL
	SBRC	CTMES, 0
	RJMP	RESTADIL
	RJMP	MAIN_LOOP

TRECERO:
	SBRS	CTMES, 0
	RJMP	SUMADIC
	SBRC	CTMES, 0
	RJMP	RESTADIC
	RJMP	MAIN_LOOP

VEINTE8:
	SBRS	CTMES, 0
	RJMP	SUMADIFEB
	SBRC	CTMES, 0
	RJMP	RESTADIFEB
	RJMP	MAIN_LOOP

// FUNCIONAMIENTO DE SUMA PARA DIA (TANTO LARGOS, CORTOS Y DICIEMBRE)
SUMADIL:
	LDS		R16, D_DIA
	CPI		R16, 3
	BREQ	FIDIAL
	LDS		R16, U_DIA
	INC		R16
	CPI		R16, 10
	BREQ	AUDDIA
	STS		U_DIA, R16
	RJMP	REGS

FIDIAL:
	LDS		R16, U_DIA
	INC		R16
	CPI		R16, 2
	BREQ	TDIA
	STS		U_DIA, R16
	RJMP	REGS

TDIA:
	CLR		R16
	STS		D_DIA, R16
	LDI		R16, 1
	STS		U_DIA, R16
	RJMP	REGS

SUMADIC:
	LDS		R16, D_DIA
	CPI		R16, 3
	BREQ	FIDIAC
	LDS		R16, U_DIA
	INC		R16
	CPI		R16, 10
	BREQ	AUDDIA
	STS		U_DIA, R16
	RJMP	REGS

FIDIAC:
	LDS		R16, U_DIA
	INC		R16
	CPI		R16, 1
	BRSH	TDIA
	STS		U_DIA, R16
	RJMP	REGS

SUMADIFEB:
	LDS		R16, D_DIA
	CPI		R16, 2
	BREQ	FIDIAFE
	CPI		R16, 3
	BREQ	FIDIAL
	LDS		R16, U_DIA
	INC		R16
	CPI		R16, 10
	BREQ	AUDDIA
	STS		U_DIA, R16
	RJMP	REGS

FIDIAFE:
	LDS		R16, U_DIA
	INC		R16
	CPI		R16, 9
	BREQ	TDIA
	STS		U_DIA, R16
	RJMP	REGS

AUDDIA:
	CLR		R16
	STS		U_DIA, R16
	LDS		R16, D_DIA
	INC		R16
	STS		D_DIA, R16
	RJMP	REGS

// FUNCIONAMIENTO DE RESTA PARA DIA (TANTO LARGOS, CORTOS Y DICIEMBRE)	
RESTADIL:					 ;funcion under para meses largos y como se comporta
	LDS		R16, D_DIA
	CPI		R16, 0
	BREQ	INDIAL
	LDS		R16, U_DIA
	DEC		R16
	CPI		R16, 0xFF
	BREQ	LREDDIA
	STS		U_DIA, R16
	RJMP	CER

LREDDIA:
	RJMP	REDDIA

INDIAL:
	LDS		R16, U_DIA
	DEC		R16
	CPI		R16, 0
	BREQ	EDIAL
	STS		U_DIA, R16
	RJMP	CER

EDIAL:
	LDI		R16, 3
	STS		D_DIA, R16
	LDI		R16, 1
	STS		U_DIA, R16
	RJMP	CER

RESTADIC:						; funcion under para meses cortos y como se comporta
	LDS		R16, D_DIA
	CPI		R16, 0
	BREQ	INDIAC
	LDS		R16, U_DIA
	DEC		R16
	CPI		R16, 0
	BREQ	REDDIA
	STS		U_DIA, R16
	RJMP	CER

INDIAC:
	LDS		R16, U_DIA
	DEC		R16
	CPI		R16, 0
	BREQ	EDIAC
	STS		U_DIA, R16
	RJMP	CER

EDIAC:
	LDI		R16, 3
	STS		D_DIA, R16
	LDI		R16, 0
	STS		U_DIA, R16
	RJMP	CER

RESTADIFEB:						; funcion under para febrero y como se comporta
	LDS		R16, D_DIA
	CPI		R16, 0
	BREQ	INDIAFE
	LDS		R16, U_DIA
	DEC		R16
	CPI		R16, 0
	BREQ	REDDIA
	STS		U_DIA, R16
	RJMP	CER

INDIAFE:
	LDS		R16, U_DIA
	DEC		R16
	CPI		R16, 0
	BREQ	EDIAFE
	STS		U_DIA, R16
	RJMP	CER

EDIAFE:
	LDI		R16, 2
	STS		D_DIA, R16
	LDI		R16, 8
	STS		U_DIA, R16
	RJMP	CER

REDDIA:
	LDI		R16, 9
	STS		U_DIA, R16
	LDS		R16, D_DIA
	DEC		R16
	STS		D_DIA, R16
	RJMP	CER

// FUNCIONAMIENTO DE RESTA PARA MES 
RESMES:
	LDS		R16, D_MES
	CPI		R16, 0
	BREQ	RMESRR
	LDS		R16, U_MES
	DEC		R16
	CPI		R16, 0
	BREQ	RCLRMES
	STS		U_MES, R16
	RJMP	CER

RMESRR:
	LDS		R16, U_MES
	DEC		R16
	CPI		R16, 0
	BREQ	RCLRLMES
	STS		U_MES, R16
	RJMP	CER

RCLRMES:
	LDI		R16, 9
	STS		U_MES, R16
	LDS		R16, D_MES
	DEC		R16
	STS		D_MES, R16
	RJMP	CER

RCLRLMES:
	LDI		R16, 1
	STS		D_MES, R16
	LDI		R16, 2
	STS		U_MES, R16
	RJMP	CER

RESDIA:
	LDI		CTMES, 1
	RJMP	SELMES

// ENSE�AR MES EN DISPLAYS, AGREGADO CONTROLAR OVERFLOW DE MES Y QUE CONLLEVA
FECHA:
	SBI		PORTC, PC4
	CBI		PORTC, PC5
	LDI		SLIDER, 1
	LDI		CVALARM, 0		; Desactivar guardar registros en alarma
	LDS		R16, MODOQ
	CLR		R16
	STS		MODOQ, R16
	CLR		HDALARM     	; Apagara el modo encendido de la alarma
	RJMP	CER


SETFECHA:
	CBI		PORTC, PC5
	SBRC	CALEDS, 7
	SBI		PORTC, PC4
	SBRS	CALEDS, 7
	CBI		PORTC, PC4
	LDI		SLIDER, 1 
	CLR		HDALARM     	; Apagara el modo encendido de la alarma
	RJMP	COMUN			; PARA AHORRAR LINEAS SE RECICLO EL CODIGO DE SET HORA PERO CON CAMBIO DE PARAMETROS PARA QUE EL CODIGO ENTIENDA QUE SE DEBER SUMINISTRAR MES

// FUNCIONAMIENTO DE ALARMA
ALARMA: 
	SBI		PORTC, PC4
	SBI		PORTC, PC5
	LDI		CVALARM, 1
	LDI		SLIDER, 2 
	CLR		HDALARM     	; Apagara el modo encendido de la alarma
	RJMP	COMUN

// ENSE�AR VALORES EN DISPLAY (ULTIMAS LINEAS Y ES NECESARIO USAR LAUNCHERS
RDISP:
	LDI     ZL, LOW(DISPLAY << 1)   ; Cargar el byte bajo de la direcci�n de la tabla
    LDI     ZH, HIGH(DISPLAY << 1)  ; Cargar el byte alto de la direcci�n de la tabla
	RET

// CAMBIAR DISPLAY DE MIN
SU_MIN:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB0
	SBRC	CVALARM, 0
	LDS		R16, U_AMIN
	SBRS	CVALARM, 0
	CALL	MODNOR1
	CALL	CAR_DISP
	RJMP	PRI

MODNOR1:
	SBRS	SLIDER, 0
	LDS		R16, U_MIN		; AQUI SE DECIDE SI SE ENSE�A FECHA, HORA o Alarma CON AYUDA DE "SLIDER" y CVALARM
	SBRC	SLIDER, 0
	LDS		R16, U_MES
	RET


// CAMBIAR DISPLAY DE MIN
SD_MIN:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB2
	SBRC	CVALARM, 0
	LDS		R16, D_AMIN
	SBRS	CVALARM, 0
	CALL	MODNOR2
	CALL	CAR_DISP
	RJMP	SEG

MODNOR2:
	SBRS	SLIDER, 0
	LDS		R16, D_MIN		; AQUI SE DECIDE SI SE ENSE�A FECHA O HORA CON AYUDA DE "SLIDER"
	SBRC	SLIDER, 0
	LDS		R16, D_MES
	RET
	
// CAMBIAR DISPLAY DE HORA
SU_HORA:
	CBI		PORTB, PB0
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB3
	SBRC	CVALARM, 0
	LDS		R16, U_AHORA
	SBRS	CVALARM, 0
	CALL	MODNOR3
	CALL	CAR_DISP
	RJMP	TER
MODNOR3:
	SBRS	SLIDER, 0
	LDS		R16, U_HORA		; AQUI SE DECIDE SI SE ENSE�A FECHA O HORA CON AYUDA DE "SLIDER"
	SBRC	SLIDER, 0
	LDS		R16, U_DIA
	RET

// CAMBIAR DISPLAY DE HORA
SD_HORA:
	CBI		PORTB, PB0				; Apagamos todos los transistores
	CBI		PORTB, PB2
	CBI		PORTB, PB3
	CBI		PORTB, PB4
	SBI		PORTB, PB4				; Encendemos el indicado
	SBRC	CVALARM, 0				; revisamos de que modo venimos y cual se va a cargar al display
	LDS		R16, D_AHORA
	SBRS	CVALARM, 0
	CALL	MODNOR4
	CALL	CAR_DISP				; llamamos a cargar display para mandarlo afuera
	RJMP	CUAR

MODNOR4:
	SBRS	SLIDER, 0
	LDS		R16, D_HORA		; AQUI SE DECIDE SI SE ENSE�A FECHA O HORA CON AYUDA DE "SLIDER"
	SBRC	SLIDER, 0
	LDS		R16, D_DIA
	RET


// CARGAR EL VALOR DEL DISPLAY
CAR_DISP:
	// Sumar la posici�n al registro Z
    ADD     ZL, R16      ; Sumar la posici�n al byte bajo de Z
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

// AUMENTAR VALOR DE UNIDAD DE SEGUNDO
RUSEG:
    CLR     R16             
    STS     U_SEG, R16      
    LDS     R16, D_SEG      
    CPI     R16, 5          
    BREQ    RDSEG           
    INC     R16             
    STS     D_SEG, R16      
    RJMP    MAIN_LOOP       

// AUMENTAR VALOR DE DECENA DE SEGUNDO
RDSEG:
    CLR     R16             
    STS     D_SEG, R16      
    LDS     R16, U_MIN      
    CPI     R16, 9         
    BREQ    RUMIN           
    INC     R16             
    STS     U_MIN, R16      
    RJMP    MAIN_LOOP       

// AUMENTAR VALOR DE UNIDAD DE MINUTO
RUMIN:
    CLR     R16             
    STS     U_MIN, R16      
    LDS     R16, D_MIN      
    CPI     R16, 5          
    BREQ    RDMIN           
    INC     R16             
    STS     D_MIN, R16      
    RJMP    MAIN_LOOP       

// AUMENTAR VALOR DE DECENA DE MINUTO
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

// Si estamos a final de mes se reinicia el contador en 2 osea 31
RRAPIDO:
    LDS     R16, U_HORA     
    CPI     R16, 3          
    BRSH    RDHORA          
    INC     R16             
    STS     U_HORA, R16     
    RJMP    MAIN_LOOP       

// AUMENTAR VALOR DE UNIDAD DE HORA
RUHORA:
    CLR     R16             
    STS     U_HORA, R16     
    LDS     R16, D_HORA     
    INC     R16             
    STS     D_HORA, R16     
    RJMP    MAIN_LOOP       

// AUMENTAR VALOR DE DECENA DE HORA
RDHORA:
    CLR     R16             
    STS     D_HORA, R16 
	STS     U_HORA, R16    
	LDS		R16, D_MES
	CPI		R16, 1				; REVISAMOS EN QUE MES ESTAMOS 
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

FINALES:							; funcion para revisar ultimos meses 10, 11 y 12
	LDS		R16, U_MES
	CPI		R16, 0
	BREQ	LARGOS
	CPI		R16, 1
	BREQ	CORTOS
	CPI		R16, 2
	BREQ	DICI					; diciembre es especial debido que reiniciamos a�o
	RJMP	MAIN_LOOP

	// FUNCIONAMIENTO PARA MESES LARGOS
LARGOS:
	LDS		R16, D_DIA
	CPI		R16, 3
	BREQ	FMESL
	RJMP	COMUN1
	// FUNCIONAMIENTO PARA MESES CORTOS
CORTOS:
	LDS		R16, D_DIA
	CPI		R16, 3
	BREQ	FMESC
	RJMP	COMUN1
	// FUNCIONAMIENTO PARA FEBRERO
FEB:
	LDS		R16, D_DIA
	CPI		R16, 2
	BREQ	FMESFEB
	RJMP	COMUN1
	// FUNCIONAMIENTO PARA DICIEMBRE (AL AUMENTAR SE TIENE QUE REINICIAR A 1/1)	
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

FMESL:									; funcion para meses largos
	LDS		R16, U_DIA
	CPI		R16, 1
	BREQ	UMESF
	RJMP	COMUN2		
FMESC:
	LDS		R16, U_DIA					; funcion para meses cortos
	CPI		R16, 0
	BREQ	UMESF
	RJMP	COMUN2
FMESFEB:								; funcion para febrero
	LDS		R16, U_DIA
	CPI		R16, 8
	BREQ	UMESF
	RJMP	COMUN2
FMESDIC:								; funcion para diciembre
	LDS		R16, U_DIA
	CPI		R16, 1
	BREQ	UMESFD

COMUN2:										; si no es final de mes todas la funciones de meses caen aca para aumentar r16
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

UMESF:											; funcion para reiniciar mes
	LDI		R16, 1
	STS		U_DIA, R16
	CLR		R16
	STS		D_DIA, R16
	LDS		R16, U_MES
	INC		R16
	STS		U_MES, R16
	RJMP	MAIN_LOOP

UMESFD:											; si es diciembre y estamos cambiando de mes volvemos a 1 de enero
	CLR		R16
	STS		D_MES, R16
	STS		D_DIA, R16
	LDI		R16, 1
	STS		U_MES, R16
	STS		U_DIA, R16
	RJMP	MAIN_LOOP

// FUNCIONAMIENTO DE INTERRUPCIONES			
// SE ACTIVA CON UN OVERFLOW
TMR0_ISR:
	LDS		CTIMERS, TIEMPOR				; cada 10 ms se aumenta tiempo para medir segundos y por consiguiente minutos horas y meses
    OUT     TCNT0, CTIMERS
    INC     TIEMPO
	INC		CLEDS
    RETI

TMR2_ISR:
	INC		CAMBIADOR					; aumentamos el valor de cambiador para cambiar el display que se va a ense�ar
	CPI		CAMBIADOR, 4				
	BREQ	RCAMBIADOR
SIGUE:
	INC		CALEDS
	RETI

RCAMBIADOR:
	LDI		CAMBIADOR, 0
	RJMP	SIGUE

// SE ACTIVA AL PRECIONAR UN BOTON
PCINT_ISR:
	SBIS    PINC, PC3			; revisamos que boton se presiono y en que modo estamos
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
	CPI		MODO, 0				;Se activa para apagar la alarma
	BREQ	APALA
	CPI		MODO, 1				;Se activa si estamos en modo config hora
	BREQ	SUMA
	CPI		MODO, 2				
	BREQ	APALA
	CPI		MODO, 3				;Se activa si estamos en modo config fecha
	BREQ	SUMA
	CPI		MODO, 4
	BREQ	SUMA			;Se activa si estamos en modo config alarma
	RETI

APALA:
	MOV		R16, ALAREN			; cuando la alarma este encendida se presiona este boton para apagarla
	CPI		R16, 1
	BREQ	APAGARALAR
	RETI

APAGARALAR:
	LDI		R16, 1
	MOV		STOPALAR, R16
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
	CPI		MODO, 0				;Se activa si estamos en modo hora
	BREQ	HABIALAR
	CPI		MODO, 1
	BREQ	CAMBIARDISPLAY		;Se activa si estamos en modo config hora
	CPI		MODO, 2				;Se activa si estamos en modo mes
	BREQ	HABIALAR
	CPI		MODO, 3
	BREQ	CAMBIARDISPLAY		;Se activa si estamos en modo config fecha
	CPI		MODO, 4
	BREQ	CAMBIARDISPLAY			;Se activa si estamos en modo config alarma
	RETI

HABIALAR:
	INC		HDALARM				; cuando sea necesario se permite habilitar la alarma
	CPI		HDALARM, 2
	BREQ	REALR				; se lanza una bandera para indicar cuando queremos que suene la alarma
	RETI
REALR:
	CLR		HDALARM
	RETI	

CAMBIARDISPLAY:
	LDS		R16, MDISP			; cambiamos entre los pares de display para los modos de configurar
	INC		R16
	STS		MDISP, R16
	RETI



