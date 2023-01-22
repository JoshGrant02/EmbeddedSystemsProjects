// Josh Grant
// CE2801 Section 11
// 11/01/2022
//
// buzzer.s
// A file containing subroutines to interact with the buzzer
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	//RCC register locations
	.equ RCC_BASE, 0x40023800
	.equ RCC_AHB1ENR, 0x30
	.equ RCC_APB1ENR, 0x40

	//GPIO register locations
	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_MODER, 0x00
	.equ GPIO_AFRL, 0x20

	//GPIO contol values
	.equ GPIOBEN, 1<<1
	.equ TIM3EN, 1<<1
	.equ ALTFUN, 0b10
	.equ AF2, 0b0010

	//Timer register locations
	.equ TIM3_BASE, 0x40000400
	.equ TIM_CNT, 0x24
	.equ TIM_ARR, 0x2C
	.equ TIM_CCR1, 0x34
	.equ TIM_CCMR1, 0x18
	.equ TIM_CCER, 0x20
	.equ TIM_CR1, 0x00

	//Timer control values
	.equ OCM1, 4
	.equ TOGGLE, 0b011
	.equ CC1E, 1<<0
	.equ CEN, 1<<0

	//Timer base clock frequency
	.equ BASE_CLOCK_FREQ, 16000000

//////////////////////////////
//Globally exposed functions//
//////////////////////////////

// A method to initialize the buzzer
// Return - nothing
.global BuzzerInit
BuzzerInit:
	//Preserve Registers
	push {r0-r2}

	#Set up Clocks
	ldr r0, =RCC_BASE

	#GPOIB
	ldrb r1, [r0,#RCC_AHB1ENR]
	orr r1, #GPIOBEN
	strb r1, [r0,#RCC_AHB1ENR]

	#TIM3
	ldrb r1, [r0,#RCC_APB1ENR]
	orr r1, #TIM3EN
	strb r1, [r0,#RCC_APB1ENR]

	#Configure PB4 to AltFun AF02
	ldr r0, =GPIOB_BASE

	mov r2, #ALTFUN
	ldr r1, [r0, GPIO_MODER]
	bfi r1, r2, #(4*2), #2
	str r1, [r0, GPIO_MODER]

	mov r2, #AF2
	ldr r1, [r0, GPIO_AFRL]
	bfi r1, r2, #(4*4), #4
	str r1, [r0, GPIO_AFRL]

	//Branch back
	pop {r0-r2}
	bx lr


// A method to set the buzzer frequency
// r0 - the frequency of the buzzer
// Return - nothing
.global SetBuzzerFrequency
SetBuzzerFrequency:
// r0 - Input frequency (ARR count divisor) / Timer base address
// r1 - Base clock frequency (ARR count dividend)
// r2 - Half period ARR count tracker
// r3 - Dividing count register

	//Preserve registers
	push {r0-r3}

	//Determine approximate num clock cycles (ARR value) for input frequency via division
	add r0, r0, r0 //Double our dividend because we want the half period to toggle
	ldr r1, =BASE_CLOCK_FREQ //Load 16Mhz for our divisor
	mov r2, #0 //Initialize count tracker to 0
	mov r3, #0 //Initialize value tracker to 0
1:	add r2, #1 //Use r2 to track ARR value
	add r3, r0
	cmp r3, r1
	blt 1b

	//Load Timer Pointer
	ldr r0, =TIM3_BASE

	//Push half period to ARR and CCR1
	str r2, [r0, #TIM_ARR]
	str r2, [r0, #TIM_CCR1]

	//Branch back
	pop {r0-r3}
	bx lr


// A method to enable the buzzer
// Return - nothing
.global EnableBuzzer
EnableBuzzer:
// r0 - Timer base address
// r1 - Enable value register
// r2 - Toggle value register

	//Preserve Registers
	push {r0-r2}

	//Load Timer Pointer
	ldr r0, =TIM3_BASE

	//Set output mode to "Toggle" in CCMR1
	mov r2, #TOGGLE
	ldr r1, [r0, #TIM_CCMR1]
	bfi r1, r2, #OCM1, #3
	str r1, [r0, #TIM_CCMR1]

	//Enable output in CCER
	ldr r1, [r0, #TIM_CCER]
	orr r1, #CC1E
	str r1, [r0, #TIM_CCER]

	//Enable counter
	ldr r1, [r0, #TIM_CR1]
	orr r1, #CEN
	str r1, [r0, #TIM_CR1]

	//Branch back
	pop {r0-r2}
	bx lr


// A method to disable the buzzer
// Return - nothing
.global DisableBuzzer
DisableBuzzer:
// r0 - Timer base address
// r1 - Disable value register

	//Preserve registers
	push {r0-r1}

	//Load Timer Pointer
	ldr r0, =TIM3_BASE

	//Disable counter
	ldr r1, [r0, #TIM_CR1]
	bic r1, #CEN
	str r1, [r0, #TIM_CR1]

	//Branch back
	pop {r0-r1}
	bx lr
