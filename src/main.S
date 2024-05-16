;
;  Program: Simple_Blink.S
;  Description: Blink a LED connected to the pin PB5 of the ATmega328P (Arduino Uno pin 13)
;  Author: Carlos Azaustre
;  Created: 06/05/2024
;

#include <avr/io.h>

.org 0      ; Dirección de reset del microcontrolador (0x0000)
rjmp setup  ; Salta a la función setup

setup:
.global main ; Indica que la función main es global y puede ser llamada desde C

main:
  ; Configura el bit 5 (PB5) del puerto B como salida
  ldi r16, (1 << PB5)
  out _SFR_IO_ADDR(DDRB), r16

  ; Inicializa el puerto B a 0
  ldi r17, 0x00
  out _SFR_IO_ADDR(PORTB), r17

loop:
  ; Enciende el LED conectado a PB5 (Pin 13 de Arduino UNO)
  ldi r18, (1 << PB5)
  out _SFR_IO_ADDR(PORTB), r18
  call delay_1s
  ; Apaga el LED conectado a PB5
  out _SFR_IO_ADDR(PORTB), r17
  call delay_1s
  ; Salta a la etiqueta loop y vuelve a ejecutar el bucle
  rjmp loop

delay_1s:
  ; Assembly code auto-generated
  ; by utility from Bret Mulvey
  ; Delay 8 000 000 cycles
  ; 1s at 8.0 MHz

  ldi r20, 41
  ldi r21, 21
  ldi r22, 0
L1: dec r22
  brne L1
  dec r21
  brne L1
  dec r20
  brne L1
  lpm
  nop
  ret