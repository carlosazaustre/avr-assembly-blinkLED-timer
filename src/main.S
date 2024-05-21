;
; Program: Blink LED with Interruptions
; Created: 21/05/24
;
; ATMega328P cuenta con 3 temporizadores
; 1) Timer/Counter 0 (TC0): Temporizador/contador de 8 bits (hasta 255)
; 2) Timer/Counter 1 (TC1): Temporizador/contador de 16 bits (hasta 65535)
; 3) Timer/Counter 2 (TC2): Temporizador/contador de 8 bits con operación asincrónica.

#include <avr/io.h>

; Frecuencia de Reloj del MCU (16 MHz)
.equ F_CLK, 16000000

; Valor de retado (milisegundos)
.equ DELAY, 1500
; Valor de comparación del temporizador
; basado en la frecuencia de reloj, el preescalado
; y el retardo.
; Este valor lo usamos para configurar
; el registro de comparación del temporizador
.equ EOCVAL, F_CLK / 1024 / 2 / 1000 * DELAY

.text ; Iniciamos la sección de código (opcional)

.global TIMER1_COMPA_vect
; Subrutina de Interrupción
TIMER1_COMPA_vect:
    sbis _SFR_IO_ADDR(PORTB), PB5 ; Check si PB5 está configurado
    rjmp set_output
    cbi _SFR_IO_ADDR(PORTB), PB5  ; SI el PB5 está configurado lo borra
    reti
set_output:
    sbi _SFR_IO_ADDR(PORTB), PB5 ; Si no estaba configurado, ponemos PB5 a 1
    reti

.global main
main:
  ; Registros asociados a los Timers:
  ; - Timer/Counter 0 (TC0)
  ;   Estos registros tienen Bits para seleccionar el modo de operación (Waveform),
  ;   comportamiento de la salida de OC0A y salida OC0B
  ;   Bits para seleccionar el preescaler
  ;   Bits para forzar la salida de comparación.
  ;   - TCCR0A: Timer Counter Control Register A
  ;   - TCCR0B: Timer Counter Control Register B

  ;   Registro que contiene el valor actual del contador
  ;   - TCNT0 (Timer/Counter Register)
  ;   Registro para el valor de comparación para la salida a
  ;   - OCR0A (Output Compare Register A)
  ;   Registro para el valor de comparación para la salida b
  ;   - OCR0B (Output Compare Register B)
  ;   Registro de máscara
  ;    - TIMSK0, con bits para facilitar la interrupción por desboramiento y las interrupciones de comparación A y B
  ;   Registro de Flags
  ;   - TIFR0 (Timer/Counter Interrupt Flag Register)
  ;     con bits de bandera para el desbordamiento del temporizador, y de las comparaciones A y B.
  ;
  ; Para los Timer 1 y 2 es igual, cambiando el 0 por 1 o 2


  ; Configura el timer en modo CTC (Clear Timer on Compare Match)
  ; y establece el prescaler a 1024
  ;
  ; CTC: El temporizador se reinicia automáticamente cuando el valor del contador (TCNTn) 
  ; coincide con el valor en el registro de comparación (OCRnA).
  ;
  ; Preescaler 1024: Divide la F_CPU entre 1024
  ; Esto significa que el temporizador cuenta a una velocidad más lenta
  ; que la frecuencia original del reloj del sitema.
  ;
  ; TCCR1B (Timer/Counter 1 Control Register B)
  ; [ ICNC1, ICES1, - , WGM13, WGM13, CS12, CS11, CS10 ]
  ; WGME12: 1 = Modo CTC
  ; CS12,CS10: 1 = clk/1024 de preescaler.
  ldi r16, _BV(WGM12) | _BV(CS12) | _BV(CS10) 
  sts TCCR1B, r16
  ; OCR1A almacena el valor de EOCVAL = F_CLK/ 1024 /2 / 1000 * DELAY
  ; Este registro guarda el valor con el que se comparará el Timer/Counter
  ; OCR1AH es la parte alta
  ; OCR1AL es la parte baja
  ldi r16, hi8(EOCVAL)
  sts OCR1AH, r16
  ldi r16, lo8(EOCVAL)
  sts OCR1AL, r16
  ; Configuramos la máscara TIMSK1 con el valor que habilita la interrupcón
  ; de comparación del temporizador 1A, Bit OCIE1A
  ; TIMSK1 (Timer/Counter 1 Interrupt Mask Register)
  ; [ - , - , ICIE1, - , - , OCIEB, OCIEA, TOIE1 ]
  ldi r16, _BV(OCIE1A)
  sts TIMSK1, r16

  ; Configuramos PB5 como salida
  ldi r16, _BV(PB5)
  out _SFR_IO_ADDR(DDRB), r16
  ; Inicializamos el estado de PB5 a 1
  ldi r16, _BV(PB5)
  out _SFR_IO_ADDR(PORTB), r16

  ; Habilitamos el Sleep Mode
  ldi r16, _BV(SE)
  out _SFR_IO_ADDR(SMCR), r16

  ; Habilitamos las interrupciones globales
  sei

; Bucle infinito que deja al MCU en Sleep Mode.
loop:
  sleep
  rjmp loop
  