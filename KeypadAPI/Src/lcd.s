// Josh Grant
// CE2801 Section 11
// 10/18/2022
//
// lcd.s
// A file containing subroutines to interact with the LCD Screen
.syntax unified
.cpu cortex-m4
.thumb
.section .text

// GCC/GPIO Addresses
	.equ RCC_BASE, 0x40023800
    .equ RCC_AHB1ENR, 0x30
    .equ RCC_GPIOAEN, (1<<0)
    .equ RCC_GPIOCEN, (1<<2)

    .equ GPIOA_BASE, 0x40020000
    .equ GPIOC_BASE, 0x40020800
    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
    .equ GPIO_BSRR, 0x18

// LCD Control Pins
	.equ RS, (1<<8)
	.equ RW, (1<<9)
	.equ E, (1<<10)

// Set/Clear masks
	.equ LCD_MODER_CLEAR_OUTPUT, 0x00FFFF00
	.equ LCD_MODER_SET_OUTPUT, 0x00555500
	.equ LCD_RSRWE_CLEAR_OUTPUT, 0x003F0000
	.equ LCD_RSRWE_SET_OUTPUT, 0x00150000

// LCD Data Constants
	.equ GPIOA_ODR_LCD_PIN_SHIFT, 4
	.equ LCD_DATA_WIDTH, 8
	.equ LCD_DIMENSION_WIDTH, 7
	.equ LCD_ROW_TWO, 0x40

// Num to ASCII Constants
	.equ FIRST_ASCII_NUM, 24
	.equ SECOND_ASCII_NUM, 16
	.equ THIRD_ASCII_NUM, 8
	.equ FOURTH_ASCII_NUM, 0
	.equ ASCII_NUM_WIDTH, 8
	.equ FIRST_DEC_NUM, 12
	.equ SECOND_DEC_NUM, 8
	.equ THIRD_DEC_NUM, 4
	.equ FOURTH_DEC_NUM, 0
	.equ DEC_NUM_WIDTH, 4
	.equ ASCII_ZERO, 48
	.equ INT_ERR_THRESH, 9999
	.equ ASCII_NULL, 0

// Instruction Constants
	.equ FUNCTION_SET, 0x38
	.equ DISPLAY_ONOFF, 0x0F
	.equ DISPLAY_CLEAR, 0x01
	.equ RETURN_HOME, 0x02
	.equ ENTRY_MODE_SET, 0x06

// Delay Constants
	.equ SHORT_DELAY, 37
	.equ LONG_DELAY, 1520

//////////////////////////////
//Globally exposed functions//
//////////////////////////////

// Code to intialize the lcd
.global LcdInit
LcdInit:
// r0 - Instruction register

	//Preserve registers
	push {r0, lr}

    //Set up Ports
	bl portSetup

    //Wait 40ms
	mov r0, #40000
	bl DelayUs

    //Write Function Set (0x38)
	mov r0, #FUNCTION_SET
	bl writeInstruction

    //Write Function Set (0x38)
	mov r0, #FUNCTION_SET
	bl writeInstruction

    //Write Display On/Off(0x0F)
	mov r0, #DISPLAY_ONOFF
	bl writeInstruction

    //Write Display Clear (0x01)
	mov r0, #DISPLAY_CLEAR
	bl writeInstruction

    //Write Entry Mode Set (0x06)
	mov r0, #ENTRY_MODE_SET
	bl writeInstruction

	//Branch back
	pop {r0, pc}


// A subroutine to clear the LCD screen
// Return - nothing
.global LcdClear
LcdClear:
// r0 - Instruction register

	//Preserve registers
	push {r0, lr}

	//Execute the clear instruction
	mov r0, #DISPLAY_CLEAR
	bl writeInstruction

	//Branch back
	pop {r0, pc}


// A subroutine to return the pointer on the LCD screen to the home position
// Return - nothing
.global LcdHome
LcdHome:
// r0 - Instruction register

	//Preserve registers
	push {r0, lr}

	//Execute the home instruction
	mov r0, #RETURN_HOME
	bl writeInstruction

	//Branch back
	pop {r0, pc}


// A subroutine to set the position of the pointer on the LCD screen
// r0 - the zero-indexed row of the cursor
// r1 - the zero-indexed column of the cursor
// Return - nothing
.global LcdSetPosition
LcdSetPosition:
// r0 - Input row register/Instruction register
// r1 - Input col register/Address formation register
// r2 - Bottom row instruction offset constant

	//Preserve registers
	push {r0-r2, lr}

	//Determine address offset for the row
	mov r2, #LCD_ROW_TWO
	mul r0, r0, r2
	add r1, r0, r1
	//Setup instruction and move in address
	mov r0, (1<<7)
	bfi r0, r1, #0, #LCD_DIMENSION_WIDTH
	//Write the instruction
	bl writeInstruction

	//Branch back
	pop {r0-r2, pc}


// A subroutine to print a null terminated string to the LCD screen
// r0 - the address of the input string
// Return - the length of the string
.global LcdPrintString
LcdPrintString:
// r0 - Input string address register
// r1 - Character load register
// r2 - String length counter register

	//Preserve registers
	push {r1-r2, lr}

	//Loop, printing each character until it reaches the null character
	mov r1, r0
	mov r2, #0
1:	ldrb r0, [r1, r2]
	cmp r0, #ASCII_NULL
	beq 2f
	bl writeData
	add r2, r2, #1
	bal 1b

	//Branch back
2:	pop {r1-r2, pc}


// A subroutine to print a char to the LCD screen
// r0 - the ascii value of the char to write
// Return - character written
.global LcdPrintChar
LcdPrintChar:
// r0 - Char input register

	//Preserve link register
	push {lr}

	//Print the char
	bl writeData

	//Branch back
2:	pop {pc}

// A subroutine to print a 4 digit number to the Lcd Screen. Prints "Err." if the number is too big
// r0 - input number
// Return - nothing
.global LcdPrintNum
LcdPrintNum:
// r0 - Number input register/digit extraction register
// r1 - Number temp storage register

	//Preserve registers
	push {r0-r1, lr}

	//Convert the num to ASCII
	bl numToAscii
	mov r1, r0
	//Print the 4 digits in a row
	ubfx r0, r1, #FIRST_ASCII_NUM, #ASCII_NUM_WIDTH
	bl writeData
	ubfx r0, r1, #SECOND_ASCII_NUM, #ASCII_NUM_WIDTH
	bl writeData
	ubfx r0, r1, #THIRD_ASCII_NUM, #ASCII_NUM_WIDTH
	bl writeData
	ubfx r0, r1, #FOURTH_ASCII_NUM, #ASCII_NUM_WIDTH
	bl writeData

	//Branch back
	pop {r0-r1, pc}

////////////////////////////
//Private helper functions//
////////////////////////////

// Setup the GPIO ports
// Return - nothing
portSetup:
// r1 - RCC/GPIO base addresses
// r2 - ODR read/modify/write register
// r3 - Mask register

	//Preserve registers
    push {r1-r3}

    //Turn on Ports in RCC
	ldr r1, =RCC_BASE
	ldr r2, [r1, #RCC_AHB1ENR]
	orr r2, r2, #RCC_GPIOAEN
	orr r2, r2, #RCC_GPIOCEN
	str r2, [r1, #RCC_AHB1ENR]

    //Set DB Pins to Outputs
    ldr r1, =GPIOA_BASE
    ldr r2, [r1, #GPIO_MODER]
    ldr r3, =LCD_MODER_CLEAR_OUTPUT
    bic r2, r2, r3
    ldr r3, =LCD_MODER_SET_OUTPUT
    orr r2, r2, r3
    str r2, [r1, #GPIO_MODER]

    //Set RS RW E Pins to Outputs
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_MODER]
    ldr r3, =LCD_RSRWE_CLEAR_OUTPUT
    bic r2, r2, r3
    ldr r3, =LCD_RSRWE_SET_OUTPUT
    orr r2, r2, r3
    str r2, [r1, #GPIO_MODER]

	//Branch back
	pop {r1-r3}
    bx lr

// Writes instruction
// r0 - instruction to write
// Return - nothing
writeInstruction:
// r0 - Instruction to write
// r1 - GPIO base addresses
// r2 - ODR read/modify/write register

	//Preserve registers
	push {r0-r2, lr}

	//Set RS=0,RW=0,E=0
	ldr r1, =GPIOC_BASE
	ldr r2, [r1, #GPIO_ODR]
	bic r2, #RS
	bic r2, #RW
	bic r2, #E
	str r2, [r1, #GPIO_ODR]

	//Set E=1
	ldr r2, [r1, #GPIO_ODR]
	orr r2, #E
	str r2, [r1, #GPIO_ODR]

	//Set r0 -> DataBus
	ldr r1, =GPIOA_BASE
	ldr r2, [r1, #GPIO_ODR]
	bfi r2, r0, #GPIOA_ODR_LCD_PIN_SHIFT, #LCD_DATA_WIDTH
	str r2, [r1, #GPIO_ODR]

	//Set E=0
	ldr r1, =GPIOC_BASE
	ldr r2, [r1, #GPIO_ODR]
	bic r2, #E
	str r2, [r1, #GPIO_ODR]

	//Wait for a short or long delay depending on the instruction
	mov r1, r0
	mov r0, #SHORT_DELAY
	cmp r1, #3
	bgt 1f
	mov r0, #LONG_DELAY
1:	bl DelayUs

	//Branch back
	pop {r0-r2, pc}


// Writes data
// r0 - data to write
// Return - data written
writeData:
// r0 - Data to write
// r1 - GPIO base addresses
// r2 - ODR read/modify/write register

	//Preserve registers
	push {r0-r2, lr}

	//Set RS=1,RW=0,E=0
	ldr r1, =GPIOC_BASE
	ldr r2, [r1, #GPIO_ODR]
	orr r2, #RS
	bic r2, #RW
	bic r2, #E
	str r2, [r1, #GPIO_ODR]

	//Set E=1
	ldr r2, [r1, #GPIO_ODR]
	orr r2, #E
	str r2, [r1, #GPIO_ODR]

	//Set r0 -> DataBus
	ldr r1, =GPIOA_BASE
	ldr r2, [r1, #GPIO_ODR]
	bfi r2, r0, #GPIOA_ODR_LCD_PIN_SHIFT, #LCD_DATA_WIDTH
	str r2, [r1, #GPIO_ODR]

	//Set E=0
	ldr r1, =GPIOC_BASE
	ldr r2, [r1, #GPIO_ODR]
	bic r2, #E
	str r2, [r1, #GPIO_ODR]

	//All data operations are short, so wait for a short delay
	mov r0, #SHORT_DELAY
	bl DelayUs

	//Branch back
	pop {r0-r2, pc}


// A subroutine to convert a binary number (<= 9999) to Ascii
// r0 - the number to convert
// Return - the ascii representation of the inputted number
numToAscii:
// r0 - Input/Output register
// r1 - Digit handling register
// r2 - Decimal digit position pointer & BCD value storage register
// r3 - Mask register Set
// r4 - Loop counter register

	push {r1-r5}				//Preserve registers r1-r5

	ldr r5, =INT_ERR_THRESH		//Load in the value 9999
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

	//Extract fourth decimal num into ASCII
	ubfx r1, r2, #FOURTH_DEC_NUM, #DEC_NUM_WIDTH
	add r1, r1, #ASCII_ZERO
	bfi r0, r1, #FOURTH_ASCII_NUM, #ASCII_NUM_WIDTH

	//Extract third decimal num into ASCII
	ubfx r1, r2, #THIRD_DEC_NUM, #DEC_NUM_WIDTH
	add r1, r1, #ASCII_ZERO
	bfi r0, r1, #THIRD_ASCII_NUM, #ASCII_NUM_WIDTH

	//Extract second decimal num into ASCII
	ubfx r1, r2, #SECOND_DEC_NUM, #DEC_NUM_WIDTH
	add r1, r1, #ASCII_ZERO
	bfi r0, r1, #SECOND_ASCII_NUM, #ASCII_NUM_WIDTH

	//Extract first decimal num into ASCII
	ubfx r1, r2, #FIRST_DEC_NUM, #DEC_NUM_WIDTH
	add r1, r1, #ASCII_ZERO
	bfi r0, r1, #FIRST_ASCII_NUM, #ASCII_NUM_WIDTH

exitNumToAscii:
	pop {r1-r5}					//Pop back registers r1-r2
	bx lr						//Branch out of subroutine

numToAsciiErr:
	movw r0, 0x722E				//ASCII "r."
	movt r0, 0x4572				//ASCII "Er"
	bal exitNumToAscii			//Branch to exit statements

