#include "common.hpp"

/*
Class: Phase3CmdrStrategy
Strategy for commander to use during phase 3 gameplay.
Sends QRFs, deploys roadblocks, captures everything it needs.
*/
#define OOP_CLASS_NAME Phase3CmdrStrategy
CLASS("Phase3CmdrStrategy", "CmdrStrategy")
	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("takeLocDynamicEnemyPriority", 		20);	// We must take out all player-made places on first sight

		T_SETV("takeLocOutpostPriority", 			1);		// Low priority to take outposts in general
		T_SETV("takeLocOutpostCoeff", 				1);
		
		T_SETV("takeLocBasePriority", 				2);
		T_SETV("takeLocBaseCoeff", 					1);

		T_SETV("takeLocAirportPriority", 			6);		// We want them very much since we bring reinforcements through them
		T_SETV("takeLocAirportCoeff", 				10);	// Activity will make cmdr even more keen to take airports

		T_SETV("takeLocRoadBlockPriority", 			2);		// Need to clear roadblocks always
		T_SETV("takeLocRoadBlockCoeff", 			2);

		T_SETV("takeLocCityPriority", 				0.1);   // Take cities always, but other places first of all
		T_SETV("takeLocCityCoeff", 					1);		// Allow cities with activity to be taken

		T_SETV("constructLocRoadblockPriority", 	0.1);	// Pre-emptively create roadblocks everywhere
		T_SETV("constructLocRoadblockCoeff", 		5);		// Construct roadblocks with highish priority when required

	ENDMETHOD;
ENDCLASS;
