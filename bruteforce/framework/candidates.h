#ifndef CANDIDATES_H
#define CANDIDATES_H

#define STATE_INCLUDE <bruteforce/modules/MODULE_PATH/state.h>

#define STR1(x) #x
#define STR2(x) STR1(x)
#define MODULE_PATH_STR STR2(MODULE_PATH)

#include "bruteforce/framework/m64.h"
#include <PR/ultratypes.h>
#include <stdio.h>
#include STATE_INCLUDE


extern u8 desynced;

void desync(char *message);

typedef struct Candidate_s {
	InputSequence *sequence;
	struct Candidate_s *children;
	f64 score;
	CandidateStats stats;
} Candidate;

void initCandidates(InputSequence *original_inputs, Candidate **survivors);
void updateSurvivors(Candidate *survivors);
void updateBest(Candidate *best, Candidate *survivors);
void mergeCandidates(Candidate *survivors, Candidate **externalSurvivors, u32 externalSurvivorsCount);

#endif //CANDIDATES_H