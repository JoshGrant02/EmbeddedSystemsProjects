// Josh Grant
// CE2801 Section 11
// 11/08/2022
//
// driver.s
// A file containing a driver program that emulates a hex game
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
	.equ AFTER_READY, 7
	.equ AFTER_SET, 12
	.equ HEX_NUM_POS, 12

	//Miscellanious constants
	.equ RANDOM_NUM_MAX_VALUE, 15
	.equ HEX_VALUE_ADDRESS_OFFSET_MUL, 5
	.equ HEX_ANSWER_ADDRESS_OFFSET_MUL, 2
	.equ NUM_ROUNDS, 5
	.equ MAX_TIME, 0x7FFFFFFF
	.equ TEN_S_IN_MS, 10000
	.equ CORRECT, 1
	.equ WRONG, 0

	//Keypad position constants
	.equ ASCII_F, 70

	//Buzzer constants
	.equ SUCCESS_FREQUENCY, 880
	.equ FAIL_FREQUENCY, 277
	.equ SHORT_TONE, 2000000

.global main
main:
// r0 - Subroutine first param register
// r1 - Subroutine second param register
// r2 - Timer current round time
// r3 - Timer fastest time
// r4 - Random number register
// r5 - Hex strs address register
// r6 - Hex decode address register
// r7 - Correct/Wrong register
// r8 - Num correct counter register
// r9 - Round counter register

	//Initialize all the components
	bl TimerInit
	bl LcdInit
	bl LedInit
	bl KeypadInit
	bl InterruptKeypadInit
	bl BuzzerInit
	bl LcdClear
	mov r0, #RANDOM_NUM_MAX_VALUE
	bl RandomNumberInit
	bl GeneralTimerInit

	//Print "Epic Hex" centered on top row
	mov r0, #FIRST_ROW
	mov r1, #EIGHT_CHAR_CENTER
	bl LcdSetPosition
	ldr r0, =IntroTopStr
	bl LcdPrintString

	//Print "Extreme!" centered on bottom row
	mov r0, #SECOND_ROW
	mov r1, #EIGHT_CHAR_CENTER
	bl LcdSetPosition
	ldr r0, =IntroBottomStr
	bl LcdPrintString

	//Hide the cursor
	bl hideCursor

	//Wait 3 sec
	mov r0, #3
	bl DelayS

	//Clear the screen
	bl LcdClear

	//Print begin prompt
	ldr r0, =BeginPrompt
	bl LcdPrintString

	//Clear unread button flag
	ldr r1, =HasUnreadButton
	mov r0, #0
	strb r0, [r1]

	//Poll until we have an unread button
1:	ldr r1, =HasUnreadButton
 	ldrb r0, [r1]
	cmp r0, #0
	beq 1b

	//Clear unread button flag
	mov r0, #0
	strb r0, [r1]

	//Grab key value
	ldr r0, =RecentPressedButton
	ldrb r1, [r0]

	//If it is not # key (ASCII F with the keymap), wait again
	cmp r1, #ASCII_F
	bne 1b

	//Clear the screen
	bl LcdClear

	//Move cursor to bottom row
	mov r0, #SECOND_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition

	//Print "Ready.."
	ldr r0, =Ready
	bl LcdPrintString

	//Hide the cursor
	bl hideCursor

	//Wait 1 sec
	mov r0, #1
	bl DelayS

	//Move cursor to bottom row
	mov r0, #SECOND_ROW
	mov r1, #AFTER_READY
	bl LcdSetPosition

	//Print "Set.."
	ldr r0, =Set
	bl LcdPrintString

	//Hide the cursor
	bl hideCursor

	//Wait 1 sec
	mov r0, #1
	bl DelayS

	//Return the Cursor
	mov r0, #SECOND_ROW
	mov r1, #AFTER_SET
	bl LcdSetPosition

	//Print "Go!"
	ldr r0, =Go
	bl LcdPrintString

	//Initialize game variables/constants
	ldr r2, =MAX_TIME
	ldr r3, =MAX_TIME
	ldr r5, =HexValues
	ldr r6, =HexDecode
	mov r8, #0
	mov r9, #1

	//Return the Cursor
	mov r0, #FIRST_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition

_playOneRound:
	//Print round num on left side
	mov r0, #FIRST_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition
	mov r0, r9
	bl LcdPrintNum

	//Print the total round count
	ldr r0, =RoundCount
	bl LcdPrintString

	//Print hex num on right side
	mov r0, #FIRST_ROW
	mov r1, #HEX_NUM_POS
	bl LcdSetPosition

	//Grab number to print
	bl GetRandomNumber
	bl LedDisplayNum
	mov r4, r0
	mov r1, #HEX_VALUE_ADDRESS_OFFSET_MUL
	mul r0, r4, r1

	//Compute the address of the number then print the number
	add r0, r5, r0
	bl LcdPrintString

	//Clear unread button flag
	ldr r1, =HasUnreadButton
	mov r0, #0
	strb r0, [r1]

	//Start the general timer
	bl RestartGeneralTimer

	//Poll until we have an unread button
1:	ldrb r0, [r1]
	cmp r0, #0
	beq 1b

	//Clear unread button flag
	mov r0, #0
	strb r0, [r1]

	//Grab key value
	ldr r0, =RecentPressedButton
	ldrb r1, [r0]

	//Get the current time on the general timer
	bl GetTimerTime
	mov r2, r0

	//Move key value back into r0
	mov r0, r1

	//Compare the key pressed to the correct value
	mov r1, #HEX_ANSWER_ADDRESS_OFFSET_MUL
	mul r1, r4, r1
	ldrb r1, [r6, r1]
	cmp r0, r1
	bne 1f

	//If we were correct, perform correct actions
	add r8, r8, #1
	mov r0, #SUCCESS_FREQUENCY
	mov r7, #CORRECT
	cmp r2, r3
	IT lt
	movlt r3, r2
	bal 2f

	//If we were wrong, perform incorrect actions
1:	mov r0, #FAIL_FREQUENCY
	mov r7, #WRONG

	//Add to the round counter
2:	add r9, r9, #1

	//Turn on the buzzer with success or fail frequency
	bl SetBuzzerFrequency
	bl EnableBuzzer
	ldr r0, =SHORT_TONE
	bl SysTickDelay

	//Clear the Lcd
	bl LcdClear

	//Print correct value if they were wrong
	cmp r7, #WRONG
	bne 1f
	mov r0, #SECOND_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition
	ldr r0, =PreviousAnswer
	bl LcdPrintString
	mov r1, #HEX_ANSWER_ADDRESS_OFFSET_MUL
	mul r0, r4, r1
	add r0, r6, r0
	bl LcdPrintString

	bal 2f

1:	mov r0, #SECOND_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition
	ldr r0, =PrevTime
	bl LcdPrintString
	mov r0, r2
	bl LcdPrintNum
	ldr r0, =MSLabel
	bl LcdPrintString

	//Clear the Leds
2:	bl LedOff

	//If you have not played 5 rounds, do another round
	cmp r9, #NUM_ROUNDS
	ble _playOneRound

	//Print all done
	mov r0, #FIRST_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition
	ldr r0, =AllDone
	bl LcdPrintString

	//Hide the cursor
	bl hideCursor

	//Wait 2 seconds
	mov r0, #2
	bl DelayS

	//Clear the LCD Screen
	bl LcdClear

	//Print score on top row
	mov r0, #FIRST_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition
	ldr r0, =Score
	bl LcdPrintString
	mov r0, r8
	bl LcdPrintNum
	ldr r0, =RoundCount
	bl LcdPrintString

	//Print best time on botom row
	mov r0, #SECOND_ROW
	mov r1, #POS_ZERO
	bl LcdSetPosition
	ldr r0, =BestTime
	bl LcdPrintString

	//Move best time into r0
	mov r0, r3

	//Check if time is max (meaning they didn't get any correct)
	ldr r1, =MAX_TIME
	cmp r0, r1
	beq _FailAll

	//Check if time is >10s
	ldr r1, =TEN_S_IN_MS
	cmp r0, r1
	bge _GT10S

	bl LcdPrintNum
	ldr r0, =MSLabel
	bl LcdPrintString

	bal end

_FailAll:
	ldr r0, =FailAllTime
	bl LcdPrintString
	bl hideCursor

	bal end

_GT10S:
	ldr r0, =GT10STime
	bl LcdPrintString
	bl hideCursor

end:bal end

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
	.asciz "Epic Hex"

IntroBottomStr:
	.asciz "Extreme!"

BeginPrompt:
	.asciz "Press # to begin"

Ready:
	.asciz "Ready.."

Set:
	.asciz "Set.."

Go:
	.asciz "Go!!"

RoundCount:
	.asciz "/5"

PreviousAnswer:
	.asciz "Prev Ans:"

AllDone:
	.asciz "All Done!"

Score:
	.asciz "Score:"

BestTime:
	.asciz "Best Time:"

PrevTime:
	.asciz "Prev Time:"

MSLabel:
	.asciz "ms"

FailAllTime:
	.asciz "None"

GT10STime:
	.asciz ">10s"

//Each str will have 1 character followed by a null character: 2 bytes per string
HexDecode:
	.asciz "0"
	.asciz "1"
	.asciz "2"
	.asciz "3"
	.asciz "4"
	.asciz "5"
	.asciz "6"
	.asciz "7"
	.asciz "8"
	.asciz "9"
	.asciz "A"
	.asciz "B"
	.asciz "C"
	.asciz "D"
	.asciz "E"
	.asciz "F"

//Each str will have 4 characters followed by a null character: 5 bytes per string
HexValues:
	.asciz "0000"
	.asciz "0001"
	.asciz "0010"
	.asciz "0011"
	.asciz "0100"
	.asciz "0101"
	.asciz "0110"
	.asciz "0111"
	.asciz "1000"
	.asciz "1001"
	.asciz "1010"
	.asciz "1011"
	.asciz "1100"
	.asciz "1101"
	.asciz "1110"
	.asciz "1111"
