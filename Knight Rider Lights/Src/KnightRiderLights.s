// Josh Grant
// CE2801 Section 11
// 9/20/2022
//
//	KnightRiderLights.c
//	Interacts with the GPIO peripheral to produce knight rider lights effect

.syntax unified
.cpu cortex-m4
.thumb
.section .text

//Flash all of lights

//0. Initialize Lights as outputs

//1. Turn on left light

//2. Shift the light to the right

//3. Loop step 2 until light is on the right

//4. Shift the light to the left

//5. Loop step 4 until light is on the left

//6. Loop back to step 2


//What resources

//Lights are PB5-PB10, PB12-PB15

	.equ RCC_BASE, 0x40023800
	.equ RCC_AHB1ENR, 0x30
	.equ GPIOBEN, (1<<1)


	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_MODER, 0x00
	.equ GPIO_ODR, 0x14

.global main

main:

//R1 - Address
//R2 - Scratch register
//R3 - Mask register Clear
//R4 - Mask register Set
//R12 - Loop counter register

	//0. Initialize Lights as outputs
	//Turn on clock
	ldr r1, =RCC_BASE
	ldr r2, [r1,#RCC_AHB1ENR]
	orr r2, r2, #GPIOBEN
	str r2, [r1,#RCC_AHB1ENR]

	//Set all led pins to outputs
	ldr r1, =GPIOB_BASE			//Load
	ldr r2, [r1, #GPIO_MODER]
	movw r3, #0xFC00			 	//Clear mask
	movt r3, #0xFF3F
	movw r4, #0x5400				//Set mask
	movt r4, #0x5515
	bic r2, r2, r3				//Clear
	orr r2, r2, r4				//Set
	str r2, [r1, #GPIO_MODER]	//Store

	//Mask to clear bit for output:  (PB5-PB10,PB12-PB15)

start:
	//1. Turn on left light
	ldr r2, [r1, #GPIO_ODR] 	//Load
	mov r3, #0xF7E0				//Clear mask
	mov r4, #0x8000				//Set mask
	bic r2, r2, r3				//Clear
	orr r2, r2, r4				//Set
	str r2, [r1, #GPIO_ODR]		//Store


shiftRight:
	//3. Shift light to the right
	movw r12, #0x0000			//Initialize timer value
	movt r12, #0x0004
1:	subs r12, r12, 1			//Count down and branch until timer is zero
	bne 1b

2:	mov r4, r3					//Clear mask
	lsr r3, r3, 1				//Set mask
	bic r2, r2, r4				//Clear
	orr r2, r2, r3				//Set
	cmp r3, #0x0800				//Check and shift again if we are on empty light
	beq 2b
	str r2, [r1, #GPIO_ODR]		//Store
	cmp r3, #0x0020				//Check if light on the right and branch back if not
	bne shiftRight

shiftLeft:
	//3. Shift light to the left
	movw r12, #0x0000			//Initialize timer value
	movt r12, #0x0004
1:	subs r12, r12, 1			//Count down and branch until timer is zero
	bne 1b

2:	mov r4, r3					//Clear mask
	lsl r3, r3, 1				//Set mask
	bic r2, r2, r4				//Clear
	orr r2, r2, r3				//Set
	cmp r3, 0x0800				//Check and shift again if we are on empty light
	beq 2b
	str r2, [r1, #GPIO_ODR]		//Store
	cmp r3, 0x8000				//Check if light on the left and branch back if not
	bne shiftLeft
	bal shiftRight				//Branch back to shifting right if we reach the end
