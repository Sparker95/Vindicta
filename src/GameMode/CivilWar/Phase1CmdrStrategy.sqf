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

		//T_SETV("takeLocOutpostPriority", 			0);
		//T_SETV("takeLocOutpostCoeff", 			0);

		//T_SETV("takeLocBasePriority", 			0);
		//T_SETV("takeLocBaseCoeff", 				0);

		T_SETV("takeLocAirportPriority", 			6);		// We want them very much since we bring reinforcements through them
		//T_SETV("takeLocAirportCoeff", 			0);

		T_SETV("takeLocDynamicEnemyPriority", 		0);		// Leave player locations alone to start with -- cmdr isn't sure what is going on yet
		
		//T_SETV("takeLocRoadBlockPriority", 		0);
		T_SETV("takeLocRoadBlockCoeff", 			2);		// Take enemy roadblocks

		T_SETV("takeLocCityPriority", 				-1);	// Take cities with high enemy activity only
		T_SETV("takeLocCityCoeff", 					0.01);	// Allow cities with activity to be taken

		T_SETV("constructLocRoadblockPriority", 	0);
		T_SETV("constructLocRoadblockCoeff", 		0);

	ENDMETHOD;
ENDCLASS;
