// Josh Grant
// CE2801 Section 11
// 10/18/2022
//
// main.s
// A file containing a program that counts the number of number characters in a string
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ ASCII_0, 0x30
	.equ ASCII_9, 0x39

// The main driver method that calls out to the subroutine
.global main
main:
// r0 - Num count output register
// r1 - Str address input register

	//Load the address of the string to check
	ldr r1, =Str1
	//Count the amount of numeric characters in the string
	bl countNums

	//End loop
end:bal end


// A subroutine to count the number of numeric characters in a string
// r1 - The address of the string
// Return - the number of numeric characters in the string
countNums:
// r0 - Num count output register
// r1 - Str address input register
// r2 - Current char register
// r3 - Current char address offset register

	//Preserve registers
	push {r2-r3, lr}

	//Initialize num count register and char offset register
	mov r0, #0
	mov r3, #0

	//Load the current char to check
1:	ldrb r2, [r1, r3]

	//Add to char address offset
	add r3, r3, #1

	//Check if ascii null character, then branch to end
	cmp r2, #0
	beq 2f

	//Skip to next char if less than ascii 0
	cmp r2, #ASCII_0
	blt 1b

	//Skip to next char if greater than ascii 9
	cmp r2, #ASCII_9
	bgt 1b

	//Add 1 to the count if within num range
	add r0, r0, #1
	bal 1b

	//Branch out
2:	pop {r2-r3, pc}


.section .data

Str1:
	.asciz "ABC0123456789:?>=!"
