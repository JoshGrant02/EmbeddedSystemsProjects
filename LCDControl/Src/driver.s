// Josh Grant
// CE2801 Section 11
// 10/11/2022
//
// test.s
// A file containing a driver program to print a countdown timer to the LCD Screen
.syntax unified
.cpu cortex-m4
.thumb
.section .text

// The main driver method that prints a countdown timer to the LCD Screen
.global main
main:
// r0 - Subroutine 1st parameter register
// r0 - Subroutine 2nd parameter register
// r11 - Countdown loop register


	bl LcdInit					//Initialize the LCD Screen
	bl LcdHome

	ldr r0, =IntroStr			//Print the intro string
	bl LcdPrintString

	mov r0, #2000				//Delay 2000ms
	bl delayMs

	bl LcdClear					//Clear the LCD Screen

	mov r11, #150				//Begin counting down from 150
1:	mov r0, r11
	bl LcdPrintNum
	mov r0, #100				//100ms delay between each number
	bl delayMs
	bl LcdClear
	subs r11, #1
	bne 1b

	mov r0, #1					//Shift the pointer to the 4th position in the bottom row
	mov r1, #4
	bl LcdSetPosition

	//Print the outro string
	ldr r0, =OutroStr
	bl LcdPrintString

	//End loop
end:bal end


// A subroutine to delay by a given amount of Ms
// r0 - The amount of ms to delay
delayMs:
// r0 - MS input register
// r1 - Multiplication loop register
// r2 - Immediate storage register

	push {r1-r2}

	mov r1, r0
	mov r2, #4000
	mul r1, r1, r2

1:	//4 cycle loop, 4000 loops is 1ms for a 16Mhz clock
	subs r1, r1, #1
	mov r1, r1 					//no-op for more precise timing
	bne 1b

	pop {r1-r2}					//Pop back registers r1-r2
	bx lr						//Branch out of subroutine

.section .data

IntroStr:
	.asciz "Counting Time!"

OutroStr:
	.asciz "Good Job!"
