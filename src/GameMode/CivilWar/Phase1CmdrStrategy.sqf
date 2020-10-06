#include "common.hpp"

/*
Class: Phase1CmdrStrategy
Strategy for commander to use during phase 1 gameplay.
Sends QRFs, doesn't deploy roadblocks, doesn't capture anything.
*/
#define OOP_CLASS_NAME Phase1CmdrStrategy
CLASS("Phase1CmdrStrategy", "CmdrStrategy")
	METHOD(new)
		params [P_THISOBJECT];
		
		T_SETV("takeLocDynamicEnemyPriority", 		1);

		T_SETV("takeLocOutpostPriority", 			1);		// Low priority to take outposts in general
		T_SETV("takeLocOutpostCoeff", 				1);
		
		T_SETV("takeLocBasePriority", 				2);
		T_SETV("takeLocBaseCoeff", 					1);

		T_SETV("takeLocAirportPriority", 			6);		// We want them very much since we bring reinforcements through them
		T_SETV("takeLocAirportCoeff", 				10);	// Activity will make cmdr even more keen to take airports

		T_SETV("takeLocCityPriority", 				-0.8);	// Take cities with high enemy influence
		T_SETV("takeLocCityCoeff", 					1);	// Allow cities with activity to be taken

		T_SETV("constructLocRoadblockPriority", 	0);
		T_SETV("constructLocRoadblockCoeff", 		0);

	ENDMETHOD;
ENDCLASS;
