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

  ; Configura PD2 (INT0) como entrada con resistencial pull-up
  ldi r18, 0x00
  out _SFR_IO_ADDR(DDRD), r18
  ldi r18, (1 << PD2)
  out _SFR_IO_ADDR(PORTD), r18

loop:
  in r19, _SFR_IO_ADDR(PIND)
  sbrc r19, PD2
  rjmp button_not_pressed

  sbi _SFR_IO_ADDR(PORTB), PB5
  rjmp loop

button_not_pressed:
  cbi _SFR_IO_ADDR(PORTB), PB5
  rjmp loop
