#include "common.hpp"

/*
Class: Phase1CmdrStrategy
Strategy for commander to use during phase 1 gameplay.
Sends QRFs, doesn't deploy roadblocks, doesn't capture anything.
*/
#define OOP_CLASS_NAME Phase1CmdrStrategy
CLASS("Phase1CmdrStrategy", "CmdrStrategy")			// FROM START
	METHOD(new)
		params [P_THISOBJECT];
		
		T_SETV("takeLocDynamicEnemyPriority", 		1);

		T_SETV("takeLocOutpostPriority", 			-1);		// Low priority to take outposts in general
		T_SETV("takeLocOutpostCoeff", 				2);
		
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

/*
Class: Phase1CmdrStrategy
Strategy for commander to use during phase 2 gameplay.
Sends QRFs, deploys roadblocks, doesn't capture anything.
*/
#define OOP_CLASS_NAME Phase2CmdrStrategy
CLASS("Phase2CmdrStrategy", "CmdrStrategy")		// Aggression > 0.1
	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("takeLocDynamicEnemyPriority", 		4);		// Big priority for everything created by players or enemies dynamicly

		T_SETV("takeLocOutpostPriority", 			-0.2);		// Low priority to take outposts in general
		T_SETV("takeLocOutpostCoeff", 				4);
		
		T_SETV("takeLocBasePriority", 				2);
		T_SETV("takeLocBaseCoeff", 					1);

		T_SETV("takeLocAirportPriority", 			6);		// We want them very much since we bring reinforcements through them
		T_SETV("takeLocAirportCoeff", 				10);	// Activity will make cmdr even more keen to take airports


		T_SETV("takeLocRoadBlockPriority", 			2);		// Need to clear roadblocks always
		T_SETV("takeLocRoadBlockCoeff", 			2);

		T_SETV("takeLocCityPriority", 				-0.5);		// Take cities with high enemy activity only
		T_SETV("takeLocCityCoeff", 					1);		// Allow cities with activity to be taken

		T_SETV("constructLocRoadblockPriority", 	-2);	// Construct roadblocks when enemy activity in the area is highish (the coeff is applied to activity before the priority)
		T_SETV("constructLocRoadblockCoeff", 		5);		// Construct roadblocks with highish priority when required

	ENDMETHOD;
ENDCLASS;

/*
Class: Phase3CmdrStrategy
Strategy for commander to use during phase 3 gameplay.
Sends QRFs, deploys roadblocks, captures everything it needs.
*/
#define OOP_CLASS_NAME Phase3CmdrStrategy
CLASS("Phase3CmdrStrategy", "CmdrStrategy")		// Aggression > 0.65
	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("takeLocDynamicEnemyPriority", 		20);	// We must take out all player-made places on first sight

		T_SETV("takeLocOutpostPriority", 			1);		// Low priority to take outposts in general
		T_SETV("takeLocOutpostCoeff", 				4);
		
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
