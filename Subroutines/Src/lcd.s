// Josh Grant
// CE2801 Section 11
// 10/04/2022
//
// lcd.s
// A file containing subroutines to interact with the LCD Screen

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ ERR_THRESH, 0x270f		//Decimal 9999

// A subroutine to convert a binary number (<= 9999) to Ascii
// Input:		r0 - the number to convert
// Output:		r0 - the ascii representation of the inputted number
// Dependencies:none
.global numToAscii

numToAscii:
// r0 - Input/Output register
// r1 - Digit handling register
// r2 - Decimal digit position pointer & BCD value storage register
// r3 - Mask register Set
// r4 - Loop counter register

	push {r1-r5}				//Preserve registers r1-r5

	ldr r5, =ERR_THRESH			//Load in the value 9999
	cmp r0, r5					//Check if our input is above 9999
	bgt numToAsciiErr			//Branch to return error if so
	mov r4, #12					//Set counter register for 12 shifts
								//(n-1 shifts because last one is redundant
								//because we shift right at the end)
shift:
	lsl r0, r0, #1				//Shift the input 1 to the left
	cmp r4, #0					//Check if we are done shifting
	beq convertDecToAscii		//Convert Value to Ascii if so

	mov r2, #13					//Set r3 to the position of the first decimal digit
	mov r3, (3<<13)				//Set r3 to the value 3 shifted to the digit pos

1:	lsr r1, r0, r2				//Grab the value at the pos of the decimal digit
	and r1, r1, #0b1111			//And mask it down to only have 4 bits
	cmp r1, #5					//Check the value against 5
	blt 2f						//If it is less than 5, skip forward
	add r0, r0, r3				//If not add 3 at the position of the digit in r0
2:	add r2, r2, #4				//Add 4 to r2 to point to the next digit
	lsl r3, r3, #4				//Shift the value of 3 to begin with the next digit
	cmp r2, #29					//Check our digit pointer against 29
									//(This will happen after checking 4 digits [13+4*4])
	blt 1b						//If it is less than 29, branch back to check the
								//next digit

	sub r4, r4, #0x1			//Subtract 1 from the shifting loop counter
	bal shift					//Branch back to the begginning of the shift

convertDecToAscii:
	lsr r2, r0, #13				//Shift the value right so it begins at pos 0
	and r0, r0, #0				//Clear the output register

	ubfx r1, r2, #0, #4			//Extract the first 4 bits
	add r1, r1, #48				//Add 48 (ASCII 0)
	bfi r0, r1, #0, #8			//Instert the resulting ASCII value into r0

	ubfx r1, r2, #4, #4			//Extract the second 4 bits
	add r1, r1, #48				//Add 48 (ASCII 0)
	bfi r0, r1, #8, #8			//Instert the resulting ASCII value into r0

	ubfx r1, r2, #8, #4			//Extract the third 4 bits
	add r1, r1, #48				//Add 48 (ASCII 0)
	bfi r0, r1, #16, #8			//Instert the resulting ASCII value into r0

	ubfx r1, r2, #12, #4		//Extract the last 4 bits
	add r1, r1, #48				//Add 48 (ASCII 0)
	bfi r0, r1, #24, #8			//Instert the resulting ASCII value into r0

exitNumToAscii:
	pop {r1-r4}					//Pop back registers r1-r2
	bx lr						//Branch out of subroutine

numToAsciiErr:
	movw r0, 0x722E				//ASCII "r."
	movt r0, 0x4572				//ASCII "Er"
	bal exitNumToAscii			//Branch to exit statements
