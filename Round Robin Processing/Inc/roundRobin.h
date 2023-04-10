/**
  ******************************************************************************
  * @file    roundRobin.h
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 9: Round Robin Processing
  * @brief   This file contains macro definitions and structs for round robin
  * 		 processing
  ******************************************************************************
*/

//Do not duplicatively define this header file
#ifndef ROUND_ROBIN_H_
#define ROUND_ROBIN_H_

typedef enum{PAUSED,ACTIVE} task_state;

#define SCB_ICSR (volatile uint32_t*) 0xE000ED04
#define PENDSVSET 28

typedef struct
{
	uint32_t* stack_pointer;
	task_state state;
	uint32_t ticks_starting;
	uint32_t ticks_remaining;
} task;

void tasker_tick();
void init_tasker(uint32_t total_tasks, uint32_t main_ticks);
void init_task(uint32_t task_num, uint32_t stacksize,
void(*entry_point)(void), uint32_t ticks);

#endif
