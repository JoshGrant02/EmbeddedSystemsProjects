
//Do not duplicatively define this header file
#ifndef BUZZER_H_
#define BUZZER_H_

#include "memoryDefs.h"

typedef enum {C, Csh, D, Dsh, E, F, Fsh, G, Gsh, A, Ash, B} Note;
typedef enum {Eighth, Quarter, Half, Whole, Double} Duration;

extern void playNote(Note note, uint8_t octave, Duration duration);
extern void playFrequency(uint32_t freqTicks, uint32_t durationTicks);

#endif
