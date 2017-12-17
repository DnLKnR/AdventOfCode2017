#define __STDC_FORMAT_MACROS
#include <inttypes.h>
#include <stdio.h>


int64_t GetNextValue(int64_t value, int64_t factor, int64_t multiple) {
	int64_t max_signed_32bit = 0x000000007FFFFFFF;
	int64_t max = 2147483647;
	do {
		value = (value * factor) % max_signed_32bit;
	} while ((value % multiple) != 0);
	return value;	
}

void Part2() 
{
	int64_t A = 277;
	int64_t A_Factor = 16807;
	
	int64_t B = 349;
	int64_t B_Factor = 48271;
	
	int64_t mask_16bit = 0x000000000000FFFF;
	
	int64_t pairs = 0;
	int64_t repetitions = 5000000;
	for (int64_t i = 0; i < repetitions; ++i) {
		A = GetNextValue(A, A_Factor, 4);
		B = GetNextValue(B, B_Factor, 8);
		
		int64_t compare_A = mask_16bit & A;
		int64_t compare_B = mask_16bit & B;
		
		if (compare_A == compare_B) {
			++pairs;
		}
	}
	printf("Total Pairs (Part 2): %"PRIu64"\n", pairs);
}

int main(int argc, char* argv[]) {
	int64_t A = 277;
	int64_t A_Factor = 16807;
	
	int64_t B = 349;
	int64_t B_Factor = 48271;
	
	int64_t mask_16bit = 0x000000000000FFFF;
	int64_t max_signed_32bit = 0x000000007FFFFFFF;
	
	int64_t pairs = 0;
	int64_t repetitions = 40000000;
	for (int64_t i = 0; i < repetitions; ++i) {
		A = (A * A_Factor) % max_signed_32bit;
		B = (B * B_Factor) % max_signed_32bit;
		
		int64_t compare_A = mask_16bit & A;
		int64_t compare_B = mask_16bit & B;
		
		if (compare_A == compare_B) {
			++pairs;
		}
	}
	printf("Total Pairs: %"PRIu64"\n", pairs);
	Part2();
	return 0;
}


