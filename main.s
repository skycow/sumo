; main.s
; Runs on any Cortex M processor
; A very simple first project implementing a random number generator
; Daniel Valvano
; May 4, 2012

;  This example accompanies the book
;  "Embedded Systems: Introduction to Arm Cortex M Microcontrollers",
;  ISBN: 978-1469998749, Jonathan Valvano, copyright (c) 2012
;  Section 3.3.10, Program 3.12
;
;Copyright 2012 by Jonathan W. Valvano, valvano@mail.utexas.edu
;   You may use, edit, run or distribute this file
;   as long as the above copyright notice remains
;THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
;OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
;MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
;VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
;OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;For more information about my classes, my research, and my books, see
;http://users.ece.utexas.edu/~valvano/


       THUMB
       AREA    DATA, ALIGN=2
       ALIGN          
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start
	   ;unlock 0x4C4F434B
	   
	   ;PF4 is SW1
	   ;PF0 is SW2
	   ;PF1 is RGB Red
	   ;Enable Clock RCGCGPIO p338
	   ;Set direction 1 is out 0 is in. GPIODIR
	   ;DEN 
	   ; 0x3FC
	   
	   
Start  


;enable/config

	;1 - enable PB, PD, PE, and PF
	ldr R1,=0x400FE108 ;get addr. of clock
	mov R0,#0x3A ;=0b00111010
	str R0,[R1]
	nop
	nop
	
	;Special PF unlock
	ldr R0, =0x40025000; Base of PF
	ldr R1, =0x4C4F434B; Unlock code
	str R1, [R0,#0x520];GPIO unlock for PF
	mov R1, #0x1F; value to be stored in GPIOCR
	str R1, [R0,#0x524];GPIOCR for PF
	
	;2 - disable A.F.
	ldr r2, =0x40005000;base of PB
	ldr r3, =0x40024000;base of PE
	ldr r9, =0x40007000;base of PD
	
	;PB
	mov r4, #0x0 
	str r4, [r2, #0x420]
	
	;PE
	mov r4, #0xf9 ;bin 11111001
	ldr r5, [r3, #0x420]
	and r5, r4
	str r5, [r3, #0x420]
	
	;PF
	mov r4, #0xef ;bin 11101110
	ldr r5, [r0, #0x420]
	and r5, r4
	str r5, [r0, #0x420]
	
	;PD
	mov r4, #0x39;0b00111001
	ldr r5, [r9, #0x420]
	and r5, r4
	str r5, [r9, #0x420]
	
	;3 - set direction
	
	;PB
	add r5, r2, #0x400 ;get addr of b dir
	mov r6, #0xff ; bin 11111111
	str r6, [r5]
	
	;PE
	ldr r5, [r3, #0x400]
	mov r6, #0x6 ; bin 110
	orr r5, r6
	str r5, [r3, #0x400]
	
	;PF
	ldr r5, [r0, #0x400]
	mov r6, #0xee ; bin 11101110
	and r5, r6
	str r5, [r0, #0x400]
	
	;PD
	ldr r5, [r9, #0x400]
	mov r6, #0x39;0b00111001
	and r5, r6
	str r5, [r9, #0x400]
	
	;4 - physical setup
	;0x50C GPIOODR open drain
	;0x510 GPIOPUR pull up
	
	;set b odrains
	mov r4, #0xff 
	str r4, [r2, #0x50C]
	;set e odrains
	ldr r5, [r3, #0x50C]
	mov r6, #0x6 ; bin 110
	orr r5, r6
	str r5, [r3, #0x50C]
	
	;set b pull-ups
	mov r4, #0xff 
	str r4, [r2, #0x510]
	;set e pull-ups
	ldr r5, [r3, #0x510]
	mov r6, #0x6 ; bin 110
	orr r5, r6
	str r5, [r3, #0x510] 
	;set f pull-ups
	ldr r5, [r0, #0x510]
	mov r6, #0x11 ; bin 10001
	orr r5, r6
	str r5, [r0, #0x510]
	;set d pull-ups
	ldr r5, [r9, #0x510]
	mov r6, #0xC6;0b11000110
	orr r5, r6
	str r5, [r9, #0x510]
	
	;5 - enable
	
	;set b enables
	mov r4, #0xff 
	str r4, [r2, #0x51C]
	;set e enables
	ldr r5, [r3, #0x51C]
	mov r6, #0x6 ; bin 110
	orr r5, r6
	str r5, [r3, #0x51C]
	;set f enables
	ldr r5, [r0, #0x51C]
	mov r6, #0x11 ; bin 10001
	orr r5, r6
	str r5, [r0, #0x51C]
	;set d enables
	ldr r5, [r9, #0x51C]
	mov r6, #0xC6;0b11000110
	orr r5, r6
	str r5, [r9, #0x51C]

;;program start
resetStop
	mov r0, #0x00
	mvn r10, r0
	str r10, [r2, #0x3fc] ;send to led
	str r10, [r3, #0x3fc] ;;;potential problem

stop
loop 
	;when start goes to 0
	ldr r4, =0x40025000 ;port f base
	ldr r1, [r4, #0x3fc] 
	and r1, #0x10 ;10000
	cmp r1, #0x0 ;
	;bne loop
	beq skip	
	
	;checks if reset is pushed
	ldr r1, [r3, #0x3fc]
	and r1, #0x1
	cmp r1, #0x0
	beq resetStop  ;(if rst low)
	bne loop

resetStart
	mov r0, #0x0
	;send to led
	mvn r0, r0
	str r0, [r2, #0x3fc] ;send to led
	str r0, [r3, #0x3fc] ;;;potential problem
	
skip	
cont
	;b resetStart(if rst low)
	ldr r1, [r3, #0x3fc]
	and r1, #0x1
	cmp r1, #0x0
	beq resetStart
	
	;b stop(if stp low)
	ldr r4, =0x40025000 ;port f base
	ldr r1, [r4, #0x3fc] 
	and r1, #0x1 ;1
	cmp r1, #0x0 ;
	beq stop
	
	;delay
	b delayloop
return	
	;b resetStart(if rst low)
	ldr r1, [r3, #0x3fc]
	and r1, #0x1
	cmp r1, #0x0
	beq resetStart
	
	;b stop(if stp low)
	ldr r4, =0x40025000 ;port f base
	ldr r1, [r4, #0x3fc] 
	and r1, #0x1 ;1
	cmp r1, #0x0 ;
	beq stop
	
	add r0, #0x1
	
	;b resetStart(if rst low)
	ldr r1, [r3, #0x3fc]
	and r1, #0x1
	cmp r1, #0x0
	beq resetStart
	
	;send to led
	mvn r6, r0
	str r6, [r2, #0x3fc] ;send to led
		
	and r6, #0x300
	;shift 7 places
	lsr r6, #0x07
		
	mov r8, #0x6 ;00000110
	lsl r8, #0x2
	;ldr r9, [r3, #0x3fc]
	;ldr r6, [r9, r8]
	str r6, [r3, r8]
	
	;and r6, #0x300
	;shift 7 places
	;lsr r6, #0x07
	;orr r6, #0xF9
	;get config
	;ldr r7, [r3, #0x3fc]
	;and r6, r7
	;str r6, [r3, #0x3fc] ;;;potential problem
	
	;b resetStart(if rst low)
	ldr r1, [r3, #0x3fc]
	and r1, #0x1
	cmp r1, #0x0
	beq resetStart
	
	;b stop(if stp low)
	ldr r4, =0x40025000 ;port f base
	ldr r1, [r4, #0x3fc] 
	and r1, #0x1 ;1
	cmp r1, #0x0 ;
	beq stop
	
	b cont

	
	;delay loop
delayloop
	;mov32 r5, #0x1700ac ;loop times
	;mov32 r5, #0x16e360
	;mov32 r5, #0x1E8480 2000000
	;mov32 r5, #0x2ADC9C
	;mov32 r5, #0x1EDC47
	mov32 r5, #0x24DC71
	
delay
	subs r5, #0x1
	bne delay
	beq return

       B   Start

       ALIGN      
       END
