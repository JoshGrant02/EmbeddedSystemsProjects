// Josh Grant
// CE2801 Section 11
// 10/25/2022
//
// lock.s
// A file containing a driver program that emulates an electric lock
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	//LCD constants
	.equ LCD_WIDTH, 16
	.equ LCD_CLEAR_SIZE, 32
	.equ ASCII_CHAR_WIDTH, 8

	//Cursor pos constants
	.equ FIRST_ROW, 0
	.equ SECOND_ROW, 1
	.equ POS_ZERO, 0
	.equ SIX_CHAR_CENTER, 5
	.equ EIGHT_CHAR_CENTER, 4
	.equ TEN_CHAR_CENTER, 3
	.equ CODE_INDEX, 11
	.equ OFFSCREEN, 16

	//Miscellanious constants
	.equ MAX_NUM_FAILS, 3
	.equ EMPTY_REGISTER, 0
	.equ NUM_DIGITS_TO_COLLECT, 4

// The main driver method that prints a countdown timer to the LCD Screen
.global main
main:
// r0 - Subroutine first param register
// r1 - Subroutine second param register
// r2 - User input password storage register
// r3 - Attempt num register
// r12 - Num digits to collect register

	//Initialize all the components
	bl TimerInit
	bl LcdInit
	bl KeypadInit
	bl LedInit
	bl LcdClear

	//Print "Ultra Lock" centered on bottom row
	mov r0, #FIRST_ROW
	mov r1, #TEN_CHAR_CENTER
	bl LcdSetPosition
	ldr r0, =IntroTopStr
	bl LcdPrintString

	//Print "Extreme!" centered on bottom row
	mov r0, #SECOND_ROW
	mov r1, #EIGHT_CHAR_CENTER
	bl LcdSetPosition
	ldr r0, =IntroBottomStr
	bl LcdPrintString

	//Hide Cursor
	bl hideCursor

	//Wait 3 seconds then clear the screen
	mov r0, #3
	bl DelayS
	bl LcdClear

	//Initialize attempt counter to 1
	mov r3, #1

2:	//Print "Enter Code:" on first line
	ldr r0, =EnterCode
	bl LcdPrintString

	//Move cursor to second line
	mov r0, #SECOND_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition

	//Print "Try #:" on the second line
	ldr r0, =AttemptNum
	bl LcdPrintString
	mov r0, r3
	bl LcdPrintNum

	//Move to after colon on first line
	mov r0, #FIRST_ROW
	mov r1, #CODE_INDEX
	bl LcdSetPosition

	//Initialize password storage register and digit counting register
	mov r2, #EMPTY_REGISTER
	mov r12, #NUM_DIGITS_TO_COLLECT

	//Collect 4 digits
1:	bl collectDigit
	lsl r2, r2, #ASCII_CHAR_WIDTH
	bfi r2, r0, #0, #ASCII_CHAR_WIDTH
	subs r12, r12, #1
	bne 1b

	//Wait 1/2 second then clear the screen
	mov r0, #500
	bl DelayMs
	bl LcdClear

	//Compare value to password
	ldr r0, =SuperSecretPassword
	ldr r1, [r0]
	cmp r1, r2
	beq _correct

_wrong:
	//If this is the 3rd fail, branch to the intruder alert loop
	cmp r3, #MAX_NUM_FAILS
	beq _intruder

	//Print Fail!!
	mov r0, #FIRST_ROW
	mov r1, #SIX_CHAR_CENTER
	bl LcdSetPosition
	ldr r0, =Wrong
	bl LcdPrintString

	//Hide Cursor
	bl hideCursor

	//Wait 3 seconds then clear the screen
	mov r0, #3
	bl DelayS
	bl LcdClear

	add r3, r3, #1
	bal 2b

_intruder:
	//Print "Intruder"
	mov r0, #FIRST_ROW
	mov r1, #EIGHT_CHAR_CENTER
	bl LcdSetPosition
	ldr r0, =Intruder
	bl LcdPrintString

	//Print "Alert"
	mov r0, #SECOND_ROW
	mov r1, #SIX_CHAR_CENTER
	bl LcdSetPosition
	ldr r0, =Alert
	bl LcdPrintString
	bl hideCursor

	//Wait a second
	mov r0, #1
	bl DelayS

	//Clear the screen
	bl LcdClear
	bl hideCursor

	//Wait a quater second
	mov r0, #250
	bl DelayMs

	//Repeat
	bal _intruder

_correct:
	//Print Success!
	mov r0, #FIRST_ROW
	mov r1, #EIGHT_CHAR_CENTER
	bl LcdSetPosition
	ldr r0, =Correct
	bl LcdPrintString

	//Turn on all the LEDs
	bl AllLedsOn

	//Hide Cursor
	bl hideCursor

	//End loop
end:bal end


// A private helper method to collect a digit from the keypad and print it
// Return - the ASCII value of the digit collected
collectDigit:
// r0 - digit storage register

	//Preserve registers
	push {lr}

	//Wait until a button is pressed and retrieve the char
	bl KeyGetChar

	//Print the current char
	bl LcdPrintChar

	//Branch back
	pop {pc}


// A private helper method to move the cursor off the screen
// Return - nothing
hideCursor:
// r0 - Cursor row pos
// r1 - Cursor col pos (offscreen)

	//Preserve registers
	push {r0-r1, lr}

	//Hide cursor
	mov r0, #FIRST_ROW
	mov r1, #OFFSCREEN
	bl LcdSetPosition

	//Branch back
	pop {r0-r1, pc}


.section .data

SuperSecretPassword://Password is 1234 after accounting for little endian
	.ascii "4321"

IntroTopStr:
	.asciz "Ultra Lock"

IntroBottomStr:
	.asciz "Extreme!"

EnterCode:
	.asciz "Enter Code:"

AttemptNum:
	.asciz "Attempt #"

Correct:
	.asciz "Success!"

Wrong:
	.asciz "FAIL!!"

Intruder:
	.asciz "Intruder"

Alert:
	.asciz "Alert!"
