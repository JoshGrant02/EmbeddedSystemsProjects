// Josh Grant
// CE2801 Section 11
// 9/20/2022
//
// interruptKeypad.s
// Interacts with the led

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800
	.equ RCC_AHB1ENR, 0x30
	.equ RCC_APB1ENR, 0x40
	.equ RCC_APB2ENR, 0x44
	.equ GPIOBEN, 1<<1
	.equ GPIOCEN, 1<<2
	.equ SYSCONFIGEN, 1<<14
	.equ TIM3EN, 1<<1

	.equ GPIOB_BASE, 0x40020400
	.equ GPIOC_BASE, 0x40020800
	.equ GPIO_MODER, 0x0
	.equ GPIO_ODR, 0x14
	.equ GPIO_IDR, 0x10
	.equ GPIO_PUPDR, 0x0C
	.equ GPIO_AFRL, 0x20
	.equ AF2, 0b0010
	.equ ALTFUN, 0b10

	.equ SYSCFG_BASE, 0x40013800
	.equ SYSCFG_EXTICR1, 0x08
	.equ SYSCFG_EXTICR2, 0x0C
	.equ SYSCFG_EXTICR3, 0x10
	.equ SYSCFG_EXTICR4, 0x14
	.equ EXTI_PORTC, 0b0010

	.equ EXTI_BASE, 0x40013C00
	.equ EXTI_IMR, 0x00
	.equ EXTI_FTSR, 0x0C
	.equ EXTI_RTSR, 0x08
	.equ EXTI_PR, 0x14

	.equ NVIC_BASE, 0xE000E100
	.equ NVIC_ISER0, 0x00
	.equ NVIC_ISER1, 0x04

	.equ TIM3_BASE, 0x40000400
	.equ TIM_CNT, 0x24
	.equ TIM_ARR, 0x2C
	.equ TIM_CCR1, 0x34

	.equ TIM_CCMR1, 0x18
	.equ OCM1, 4
	.equ TOGGLE, 0b011

	.equ TIM_CCER, 0x20
	.equ CC1E, 1<<0

	.equ TIM_CR1, 0x00
	.equ CEN, 1<<0

	.equ KEYPAD_FIRST_PIN, 0x00
	.equ KEYPAD_NUM_PINS, 0x08
	.equ KEYPAD_INIT_WIDTH, 0x0F

	.equ KEYPAD_MODER_ROW_POS, 0x08
	.equ KEYPAD_MODER_COL_POS, 0x00
	.equ KEYPAD_MODER_RC_WIDTH, 0x08

	.equ KEYPAD_IODR_ROW_POS, 0x04
	.equ KEYPAD_IODR_COL_POS, 0x00
	.equ KEYPAD_IODR_RC_WIDTH, 0x04

	// Set/Clear masks
	.equ KEYPAD_MODER_SET_RC_INPUT, 0x00
	.equ KEYPAD_MODER_SET_RC_OUTPUT, 0x55
	.equ KEYPAD_PUPDR_SET_PULL_UP, 0x5555

	// Miscellanious constants
	.equ ALL_BUTTONS_OFF, 0xF
	.equ BUTTONS_MASK, 0xF
	.equ GPIO_DELAY, 50
	.equ CONTACT_BOUNCE_DELAY, 10

// A subroutine to initialize the keypad to be interrupt based
.global InterruptKeypadInit
InterruptKeypadInit:
	push {r0-r2, lr}

	//RCC
	//RCC_AHB1ENR <- GPIOCEN
	ldr r0, =RCC_BASE

	ldr r1, [r0,#RCC_AHB1ENR]
	orr r1, #GPIOCEN
	str r1, [r0,#RCC_AHB1ENR]

	ldr r1, [r0,#RCC_APB2ENR]
	orr r1, #SYSCONFIGEN
	str r1, [r0,#RCC_APB2ENR]

	//GPIOC
	bl configureKeypad

	//Sysconfig EXTI
	ldr r0, =SYSCFG_BASE

	mov r2, #EXTI_PORTC
	ldr r1, [r0,#SYSCFG_EXTICR1]
	bfi r1, r2, #0, #4
	bfi r1, r2, #4, #4
	bfi r1, r2, #8, #4
	bfi r1, r2, #12, #4
	str r1, [r0,#SYSCFG_EXTICR1]

	//EXTI
	ldr r0, =EXTI_BASE

	//Enable the falling trigger status register
	ldr r1, [r0,#EXTI_FTSR]
	orr r1, #0xF
	str r1, [r0,#EXTI_FTSR]

	ldr r1, [r0,#EXTI_IMR]
	orr r1, #0xF
	str r1, [r0,#EXTI_IMR]

	//NVIC
	ldr r0, =NVIC_BASE
	ldr r1, [r0,#NVIC_ISER0]
	orr r1, #0xF<<6
	str r1, [r0,#NVIC_ISER0]

	pop {r0-r2, lr}
	bx lr


//A private helper method to initialize the keypad GPIO ports
configureKeypad:
	push {r0-r3, lr}

	//Set row pins to input & col pins to output
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_MODER]
    mov r3, #KEYPAD_MODER_SET_RC_INPUT
    bfi r2, r3, #KEYPAD_MODER_COL_POS, #KEYPAD_MODER_RC_WIDTH
    mov r3, #KEYPAD_MODER_SET_RC_OUTPUT
    bfi r2, r3, #KEYPAD_MODER_ROW_POS, #KEYPAD_MODER_RC_WIDTH
    str r2, [r1, #GPIO_MODER]

    //Write 0000 to row odr
    ldr r2, [r1, #GPIO_ODR]
    mov r3, #0
    bfi r2, r3, #KEYPAD_IODR_ROW_POS, #KEYPAD_IODR_RC_WIDTH
    str r2, [r1, #GPIO_ODR]

	//Branch back
	pop {r0-r3, lr}
	bx lr


// Interrupt handler for column 0
.global EXTI0_IRQHandler
.thumb_func
EXTI0_IRQHandler:
	push {lr}
	mov r0, #0
	bl clearFlag
	bl handleButtonPress
	bl cleanupInterrupt
	pop {lr}
	bx lr


// Interrupt handler for column 1
.global EXTI1_IRQHandler
.thumb_func
EXTI1_IRQHandler:
	push {lr}
	mov r0, #1
	bl clearFlag
	bl handleButtonPress
	bl cleanupInterrupt
	pop {lr}
	bx lr


// Interrupt handler for column 2
.global EXTI2_IRQHandler
.thumb_func
EXTI2_IRQHandler:
	push {lr}
	mov r0, #2
	bl clearFlag
	bl handleButtonPress
	bl cleanupInterrupt
	pop {lr}
	bx lr


// Interrupt handler for column 3
.global EXTI3_IRQHandler
.thumb_func
EXTI3_IRQHandler:
	push {lr}
	mov r0, #3
	bl clearFlag
	bl handleButtonPress
	bl cleanupInterrupt
	pop {lr}
	bx lr


// Method to clear the interrupt pending flag
clearFlag:
	push {r1-r2}

	#disable keypad irqs
	ldr r2, =EXTI_BASE
	ldr r1, [r2,#EXTI_IMR]
	bic r1, #0xF
	str r1, [r2,#EXTI_IMR]

	#Clear pending flag
	mov r1, #1
	lsl r1, r1, r0
	str r1, [r2,#EXTI_PR]

	pop {r1-r2}
	bx lr


// Method to handle a button press: grab the button and store it in memory
handleButtonPress:
	push {r1, lr}

	//Determine the key
	bl ReadKeys //This is ReadKeys method from Keypad API lab implementing the 2nd algorithm.
	//I know this is not the most efficient way to do it with the interrupts and that the 2nd algorithm
	//should be integrated into this method, but I couldn't get the method working in an integrated fasion
	//so I just did this (my attempt was in determineKeyPressValue)

	//Grab the ascii value with the keymap
	sub r0, r0, #1
	ldr r1, =keyMap1
	ldrb r0, [r1, r0]

	//Store the ascii value in memory
	ldr r1, =RecentPressedButton
	strb r0, [r1]

	//Store in memory that we pressed the button
	ldr r1, =HasUnreadButton
	mov r0, #1
	strb r0, [r1]

	//Add to num button presses
	ldr r1, =NumButtonPresses
	ldr r0, [r1]
	add r0, r0, #1
	str r0, [r1]

    //Branch back
1:	pop {r1, lr}
	bx lr


// Subroutine to re-enable the interrupts once it is finished
cleanupInterrupt:
	push {r0-r1, lr}

	#busy time delay 2-5ms
	mov r1, #5
	bl DelayMs

	#Clean up
	bl configureKeypad

	#Renable Keypad
	ldr r0, =EXTI_BASE
	ldr r1, [r0,#EXTI_IMR]
	orr r1, #0xF
	str r1, [r0,#EXTI_IMR]

	pop {r0-r1, lr}
	bx lr


// Method to determine the key being pressed with the assumption that we know the column from the interrupt
// ALERT: This subroutine is not being used because I could not get it working
// r0 - the column value
determineKeyPressValue:
	push {r1-r5, lr}

	//Mov the col to r5
    ubfx r5, r0, #KEYPAD_IODR_COL_POS, #KEYPAD_IODR_RC_WIDTH

	//Set row pins to input & col pins to output
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_MODER]
    mov r3, #KEYPAD_MODER_SET_RC_INPUT
    bfi r2, r3, #KEYPAD_MODER_ROW_POS, #KEYPAD_MODER_RC_WIDTH
    mov r3, #KEYPAD_MODER_SET_RC_OUTPUT
    bfi r2, r3, #KEYPAD_MODER_COL_POS, #KEYPAD_MODER_RC_WIDTH
    str r2, [r1, #GPIO_MODER]

    //Write col idr to col odr
    ldr r2, [r1, #GPIO_ODR]
    mov r3, #0
    bfi r2, r1, #KEYPAD_IODR_COL_POS, #KEYPAD_IODR_RC_WIDTH
    str r2, [r1, #GPIO_ODR]

	//Delay after write action
	mov r0, #GPIO_DELAY
	bl DelayUs

    //Read row idr
    ldr r2, [r1, #GPIO_IDR]
    ubfx r4, r2, #KEYPAD_IODR_ROW_POS, #KEYPAD_IODR_RC_WIDTH

	//Calculate button num
	mvn r4, r4
	mvn r5, r5

	and r4, r4, #BUTTONS_MASK
	and r5, r5, #BUTTONS_MASK

	sub r4, r4, #1
	sub r5, r5, #1

	cmp r4, #0b0011
	it eq
	biceq r4, r4, #0b0001

	cmp r5, #0b0011
	it eq
	biceq r5, r5, #0b0001

	mov r0, #0
	bfi r0, r5, #0, #2
	bfi r0, r4, #2, #2

	add r0, r0, #1

	pop {r1-r5, lr}
	bx lr

.section .data
	.global RecentPressedButton
	RecentPressedButton:
		.skip 1

	.global HasUnreadButton
	HasUnreadButton:
		.skip 1

	.global NumButtonPresses
	NumButtonPresses:
		.skip 4

	keyMap1:
		.ascii "123A456B789CE0FD"
