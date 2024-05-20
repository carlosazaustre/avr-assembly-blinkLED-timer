#include <avr/io.h>

.global main
.global INT0_ISR

; Configuración inicial
.org 0x00
rjmp main

.org 0x02
rjmp INT0_ISR


main:
		; configuración del puntero de pila
		; SPH:SPL = 0x08FF (La parte final de la memoria SRAM)
		; ATMega328P tiene 2KB de SRAM (del 0x0800 al 0x08FF)
		ldi r20, 0xFF
		sts _SFR_MEM_ADDR(SPL), r20
		ldi r20, 0x08
		sts _SFR_MEM_ADDR(SPH), r20

    ; Se configura INT0 en flanco de bajada (falling edge)
    ldi r20, 0x02
    sts _SFR_MEM_ADDR(EICRA), r20
    
    ; Activamos INT0 - 0b 0000 0001
    ldi r20, 0x01
    out _SFR_MEM_ADDR(EIMSK), r20 ; Máscara de Interrupción
    
    ; Activamos de forma glboal las interrupciones
    sei
    
    ; Se activa el Pull-up interno en el Pin2 del Puerto D (PD2)
    sbi _SFR_IO_ADDR(PORTD), 2
    
    ; PortB como Salida
    ldi r17, 0xFF
    out  _SFR_IO_ADDR(DDRB), r17
    
    ; Pone un LED conectado PB3 encendido siempre
    repeat:
    sbi  _SFR_IO_ADDR(PORTB), 3
    jmp repeat

INT0_ISR:
    ; Manejo de la interrupción
    ; in r16,  _SFR_IO_ADDR(PORTB) ; Lee el puerto B
    ; ldi r17, 0x04 ; PB3 - 0000 0100
    ; eor r16, r17
    ldi r16, 0xFF
    out  _SFR_IO_ADDR(PORTB), r16
    reti