/**
  ******************************************************************************
  * @file    roundRobin.c
  * @author  Josh Grant
  * @course  CE2812
  * @assign	 Lab 9: Round Robin Processing
  * @brief   This file contains methods to setup round robin processing
  ******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include "roundRobin.h"

//Method prototypes
void PendSV_Handler(void) __attribute__((naked));

//Static variables for keeping track of all the tasks and the currently
//executing task
volatile static uint32_t current_task = 0;
volatile static uint32_t next_task = 1;
volatile static uint32_t num_tasks = 0;
volatile static task* tasks;
volatile static uint32_t* scb_icsr = SCB_ICSR;

/*
 * method to count down the task ticks and to call the task switcher when it is
 * out of ticks
 * input: void
 * output: void
 */
void tasker_tick() {
	// decrement tick
	tasks[current_task].ticks_remaining--;
	// hit zero?
	if(tasks[current_task].ticks_remaining==0) {
		// find next active task
		uint32_t i = 1;
		while(tasks[(next_task=(current_task+i)%num_tasks)].state!=ACTIVE) {
			i++;
		}
		// have a new task in next_task
		tasks[next_task].ticks_remaining = tasks[next_task].ticks_starting;
		// trigger swap
		*scb_icsr |= 1<<PENDSVSET;
	}
}

/*
 * method to initialize the main task as well as callocing the stacks for all
 * the tasks
 * total_tasks: the number of tasks. Used to determine how much memory to calloc
 * main_ticks: the number of ticks (ms) that the main task should be allocated
 * output: void
 */
void init_tasker(uint32_t total_tasks, uint32_t main_ticks) {
	num_tasks = total_tasks;
	// using calloc to init to 0
	tasks = calloc(total_tasks,sizeof(task));
	// task 0 will be the "main" task
	tasks[0].state = ACTIVE;
	tasks[0].ticks_starting = main_ticks;
	tasks[0].ticks_remaining = main_ticks;
	// no need to set stack pointer for task 0 as it will
	// be running at time of first swap
	current_task = 0;
}

/*
 * method to initialize an additional task
 * task_num: the number of the task
 * stacksize: the number of words that should be allocated for the task's stack
 * entry_point: the executing function for the task
 * ticks: the number of ticks (ms) that the task should be allocated
 * output: void
 */
void init_task(uint32_t task_num, uint32_t stacksize, void(*entry_point)(void), uint32_t ticks) {
	tasks[task_num].stack_pointer = (uint32_t*)malloc(stacksize*sizeof(uint32_t));
	// need to point to top of block, not bottom
	tasks[task_num].stack_pointer += stacksize;
	// fill stack with appropriate frame
	*(--tasks[task_num].stack_pointer)=0x01000000; // PSR - must have Thumb state bit set
	*(--tasks[task_num].stack_pointer)=((uint32_t)entry_point); // PC
	*(--tasks[task_num].stack_pointer)=0xFFFFFFFF; // LR
	*(--tasks[task_num].stack_pointer)=0; // R12
	*(--tasks[task_num].stack_pointer)=0; // R3
	*(--tasks[task_num].stack_pointer)=0; // R2
	*(--tasks[task_num].stack_pointer)=0; // R1
	*(--tasks[task_num].stack_pointer)=0; // R0
	*(--tasks[task_num].stack_pointer)=0xFFFFFFF9; // ISR LR
	*(--tasks[task_num].stack_pointer)=0; // R11
	*(--tasks[task_num].stack_pointer)=0; // R10
	*(--tasks[task_num].stack_pointer)=0; // R9
	*(--tasks[task_num].stack_pointer)=0; // R8
	*(--tasks[task_num].stack_pointer)=0; // R7
	*(--tasks[task_num].stack_pointer)=0; // R6
	*(--tasks[task_num].stack_pointer)=0; // R5
	*(--tasks[task_num].stack_pointer)=0; // R4
	tasks[task_num].state = ACTIVE;
	tasks[task_num].ticks_starting = ticks;
	tasks[task_num].ticks_remaining = 0;
}

/*
 * PendSV handler to handle swapping tasks
 */
void PendSV_Handler(void)
{
	//Backs up registers, swaps the task, then restores the registers
	register uint32_t* stack_pointer asm("r13");
	asm volatile("push {r4-r11,lr}");
	tasks[current_task].stack_pointer = stack_pointer;
	current_task = next_task;
	stack_pointer = tasks[current_task].stack_pointer;
	asm volatile("pop {r4-r11,lr}\n\tbx lr");
}
