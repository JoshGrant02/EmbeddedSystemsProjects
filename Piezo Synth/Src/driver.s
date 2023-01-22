// Josh Grant
// CE2801 Section 11
// 11/01/2022
//
// driver.s
// A file containing a driver program that emulates a synth
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
	.equ NOTE_DISPLAY_POS, 13
	.equ LENGTH_DISPLAY_POS, 8

	//Miscellanious constants
	.equ MAX_NUM_FAILS, 3
	.equ EMPTY_REGISTER, 0
	.equ NUM_DIGITS_TO_COLLECT, 4

	//Keypad position constants
	.equ KEYPAD_FIRST_ROW, 1
	.equ KEYPAD_SECOND_ROW, 5
	.equ KEYPAD_THIRD_ROW, 9
	.equ KEYPAD_FOURTH_ROW, 13
	.equ KEYPAD_A, 4
	.equ KEYPAD_B, 8
	.equ KEYPAD_C, 12
	.equ KEYPAD_D, 16
	.equ KEYPAD_POUND, 15

	//Note lengths
	.equ WHOLE_NOTE_COUNT, 0
	.equ HALF_NOTE_COUNT, 1
	.equ QUARTER_NOTE_COUNT, 2
	.equ EIGHTH_NOTE_COUNT, 3
	.equ WHOLE, 16000000
	.equ HALF, 8000000
	.equ QUARTER, 4000000
	.equ EIGHTH, 2000000
	.equ NUM_LENGTH_OPTIONS, 4

.global main
main:
// r0 - Subroutine first param register
// r1 - Subroutine second param register
// r2 - Memory access offset/value register
// r3 - Note length time delay register
// r4 - Note length counter register

	//Initialize all the components
	bl TimerInit
	bl LcdInit
	bl KeypadInit
	bl BuzzerInit
	bl LcdClear
	ldr r3, =WHOLE
	mov r4, #WHOLE_NOTE_COUNT

	//Print "Epic Synth" centered on top row
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

	//Wait 3 seconds
	mov r0, #3
	bl DelayS

	//Clear the screen
	bl LcdClear

	//Print "Play a Note:" centered on top row
	mov r0, #FIRST_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition
	ldr r0, =PlayTone
	bl LcdPrintString

	//Print "Length:" centered on bottom row
	mov r0, #SECOND_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition
	ldr r0, =Length
	bl LcdPrintString

	//Print "Whole" as the note length
	mov r0, #SECOND_ROW
	mov r1, #LENGTH_DISPLAY_POS
	bl LcdSetPosition
	ldr r0, =WholeStr
	bl LcdPrintString

_awaitNextInput:
	//Hide Cursor
	bl hideCursor

	//Collect the digit to be played
	bl KeyGetKey

	//If it is the # key, change the note length
	cmp r0, #KEYPAD_POUND
	beq _configure

	//If it is not the # key but is in the 4th row, ignore the input
	cmp r0, #KEYPAD_FOURTH_ROW
	bge _awaitNextInput

	//Move our key index to r2
	mov r2, r0
	sub r2, r2, #1 //Sub key index by 1 to make it zero-based
	lsl r2, r2, #2 //Multiply index by 4 to get word offset rather than byte offset

	//Clear the currently printed note value
	mov r0, #FIRST_ROW
	mov r1, #NOTE_DISPLAY_POS
	bl LcdSetPosition
	ldr r0, =ClearNote
	bl LcdPrintString

	//Load in the note ascii
	mov r0, #FIRST_ROW
	mov r1, #NOTE_DISPLAY_POS
	bl LcdSetPosition
	ldr r1, =NoteStrs
	add r0, r1, r2 //Base address in r1, word offset in r2, each note str is a word
	bl LcdPrintString

	//Load in the note frequency
	ldr r1, =Notes
	ldr r0, [r1, r2] //Base address in r1, word offset in r2, each note is a word

	//Turn on the buzzer with our frequency
	bl SetBuzzerFrequency
	bl EnableBuzzer
	mov r0, r3
	bl SysTickDelay

	//Wait for the next input
	bal _awaitNextInput

_configure:
	//Add to our note length counter register
	add r4, r4, #1
	cmp r4, #NUM_LENGTH_OPTIONS
	IT EQ
	moveq r4, #WHOLE_NOTE_COUNT

	//Clear the currently printed note length
	mov r0, #SECOND_ROW
	mov r1, #LENGTH_DISPLAY_POS
	bl LcdSetPosition
	ldr r0, =ClearLength
	bl LcdPrintString

	//Load in whole note values if we are on that setting
	cmp r4, #WHOLE_NOTE_COUNT
	ITT EQ
	ldreq r3, =WHOLE
	ldreq r2, =WholeStr

	//Load in half note values if we are on that setting
	cmp r4, #HALF_NOTE_COUNT
	ITT EQ
	ldreq r3, =HALF
	ldreq r2, =HalfStr

	//Load in quarter note values if we are on that setting
	cmp r4, #QUARTER_NOTE_COUNT
	ITT EQ
	ldreq r3, =QUARTER
	ldreq r2, =QuarterStr

	//Load in eighth note values if we are on that setting
	cmp r4, #EIGHTH_NOTE_COUNT
	ITT EQ
	ldreq r3, =EIGHTH
	ldreq r2, =EighthStr

	//Print the new note length
	mov r0, #SECOND_ROW
	mov r1, #LENGTH_DISPLAY_POS
	bl LcdSetPosition
	mov r0, r2
	bl LcdPrintString

	//Call a systick to reset count value in systick
	mov r0, r3
	bl SysTickDelay

	//Wait for the next input
	bal _awaitNextInput


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

IntroTopStr:
	.asciz "Epic Synth"

IntroBottomStr:
	.asciz "Extreme!"

PlayTone:
	.asciz "Play a Note:"

Length:
	.asciz "Length:"

WholeStr:
	.asciz "Whole"

HalfStr:
	.asciz "Half"

QuarterStr:
	.asciz "Quarter"

EighthStr:
	.asciz "Eighth"

//7 spaces to clear out a 7 letter str
ClearLength:
	.asciz "       "

//2 spaces to clear out a 2 letter str
ClearNote:
	.asciz "  "

//Notes are in the 4th octave
Notes:
	.word 262 //C
	.word 277 //C#
	.word 294 //D
	.word 311 //D#
	.word 330 //E
	.word 349 //F
	.word 370 //F#
	.word 392 //G
	.word 415 //G#
	.word 440 //A
	.word 466 //A#
	.word 494 //B

//Each str will have 3 characters followed by a null character: 1 byte per char = one word per str
NoteStrs:
	.asciz "C  "
	.asciz "C# "
	.asciz "D  "
	.asciz "D# "
	.asciz "E  "
	.asciz "F  "
	.asciz "F# "
	.asciz "G  "
	.asciz "G# "
	.asciz "A  "
	.asciz "A# "
	.asciz "B  "
