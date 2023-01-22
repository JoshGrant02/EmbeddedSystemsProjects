// Josh Grant
// CE2801 Section 11
// 10/04/2022
//
// delayMs.s
//
// Delays for ~N MS using a busy loop
// Input: 		r0 - number of MS
// Outputs:		none
// Dependancies:none

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global delayMs

delayMs:
// r0 - MS input register
// r1 - Multiplication loop register
// r2 - Immediate storage register

	push {r1-r2}				//Preserve registers r1-r2
	
	mov r1, r0
	mov r2, #4000
	mul r1, r1, r2
	
1:	//4 cycle loop, 4000 loops is 1ms for a 16Mhz clock
	subs r1, r1, #1
	mov r1, r1 					//no-op for more precise timing
	bne 1b
	
	pop {r1-r2}					//Pop back registers r1-r2
	bx lr						//Branch out of subroutine
