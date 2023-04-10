/**
  ******************************************************************************
  * @file    memoryDefs.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 5: Play a Tune
  * @brief   This file contains macro definitions and structs for all the key
  * 		 components on our board
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef MEMORY_DEFS_H_
#define MEMORY_DEFS_H_

/*
 * RCC Base Locations & Struct
 */

#define GPIOBEN (1<<1)
#define TIM2EN (1<<0)
#define TIM3EN (1<<1)
#define TIM4EN (1<<2)
#define TIM5EN (1<<3)
#define ADCEN (1<<8)

#define ADC1IE (1<<18)

#define NVIC_ISER (uint32_t*)0xE000E100
#define RCC_BASE (volatile RCC*) 0x40023800

typedef struct {
	uint32_t CR;
	uint32_t PLLCFGR;
	uint32_t CFGR;
	uint32_t CIR;
	uint32_t AHB1RSTR;
	uint32_t AHB2RSTR;
	uint32_t AHB3RSTR;
	const uint32_t reserved_1;
	uint32_t APB1RSTR;
	uint32_t APB2RSTR;
	const uint32_t reserved_2;
	const uint32_t reserved_3;
	uint32_t AHB1ENR;
	uint32_t AHB2ENR;
	uint32_t AHB3ENR;
	const uint32_t reserved_4;
	uint32_t APB1ENR;
	uint32_t APB2ENR;
	const uint32_t reserved_5;
	const uint32_t reserved_6;
	uint32_t AHB1LPENR;
	uint32_t AHB2LPENR;
	uint32_t AHB3LPENR;
	const uint32_t reserved_7;
	uint32_t APB1LPENR;
	uint32_t APB2LPENR;
	const uint32_t reserved_8;
	const uint32_t reserved_9;
	uint32_t BDCR;
	uint32_t CSR;
	const uint32_t reserved_10;
	const uint32_t reserved_11;
	uint32_t SSCGR;
	uint32_t PLLI2SCFGR;
	uint32_t PLLSAICFGR;
	uint32_t DCKCFGR;
	uint32_t CKGATENR;
	uint32_t DCKCFGR2;
} RCC;


/*
 * GPIO Base Locations & Struct
 */

#include "gpioDefs.h"

#define GPIOA_BASE (volatile GPIOx*) 0x40020000;
#define GPIOB_BASE (volatile GPIOx*) 0x40020400;
#define GPIOC_BASE (volatile GPIOx*) 0x40020800;
#define GPIOD_BASE (volatile GPIOx*) 0x40020C00;
#define GPIOE_BASE (volatile GPIOx*) 0x40021000;
#define GPIOF_BASE (volatile GPIOx*) 0x40021400;
#define GPIOG_BASE (volatile GPIOx*) 0x40021800;
#define GPIOH_BASE (volatile GPIOx*) 0x40021C00;

typedef struct {
	uint32_t MODER;
	uint32_t OTYPER;
	uint32_t OSPEEDER;
	uint32_t PUPDR;
	uint32_t IDR;
	uint32_t ODR;
	uint32_t BSRR;
	uint32_t LCKR;
	uint32_t AFRL;
	uint32_t AFRH;
} GPIOx;


/*
 * TIM Base Locations & Struct
 */

#define TIM_EN 0b1
#define CC1S_PINS 0
#define OC1M_PINS 4
#define OC4M_PINS 12
#define TIM_CC1E (1<<0)
#define TIM_CC4E (1<<12)
#define OC_TOGGLE 0b011
#define IC_CH1 0b01
#define CC1IE (1<<1)
#define UIF (1<<0)

#define TIM2_BASE (volatile TIMx*) 0x40000000
#define TIM3_BASE (volatile TIMx*) 0x40000400
#define TIM4_BASE (volatile TIMx*) 0x40000800
#define TIM5_BASE (volatile TIMx*) 0x40000C00
#define TIM6_BASE (volatile TIMx*) 0x40001000
#define TIM7_BASE (volatile TIMx*) 0x40001400

typedef struct {
	uint32_t CR1;
	uint32_t CR2;
	uint32_t SMCR;
	uint32_t DIER;
	uint32_t SR;
	uint32_t EGR;
	uint32_t CCMR1;
	uint32_t CCMR2;
	uint32_t CCER;
	uint32_t CNT;
	uint32_t PSC;
	uint32_t ARR;
	uint32_t RCR;
	uint32_t CCR1;
	uint32_t CCR2;
	uint32_t CCR3;
	uint32_t CCR4;
	uint32_t BDTR;
	uint32_t DCR;
	uint32_t DMAR;
} TIMx;


/*
 * ADC Base Locations & Struct
 */

#define ADC_EN 0b1
#define TRIGGER_SRC_PINS 24
#define TRIGGER_EDG_PINS 28
#define TIM4_TRIGGER 0b1001
#define ANY_EDGE 0b11
#define EOCIE (1<<5)

#define ADC1_BASE (volatile ADCx*) 0x40012000
#define ADC2_BASE (volatile ADCx*) 0x40012100
#define ADC3_BASE (volatile ADCx*) 0x40012200

typedef struct {
	uint32_t SR;
	uint32_t CR1;
	uint32_t CR2;
	uint32_t SMPR1;
	uint32_t SMPR2;
	uint32_t JOFR1;
	uint32_t JOFR2;
	uint32_t JOFR3;
	uint32_t JOFR4;
	uint32_t HTR;
	uint32_t LTR;
	uint32_t SQR1;
	uint32_t SQR2;
	uint32_t SQR3;
	uint32_t JSQR;
	uint32_t JDR1;
	uint32_t JDR2;
	uint32_t JDR3;
	uint32_t JDR4;
	uint32_t DR;
	uint32_t CSR;
	uint32_t CCR;
	uint32_t CDR;
} ADCx;

#endif
