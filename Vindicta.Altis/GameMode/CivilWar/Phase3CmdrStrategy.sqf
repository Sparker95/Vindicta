#include "common.hpp"

/*
Class: Phase3CmdrStrategy
Strategy for commander to use during phase 3 gameplay.
Sends QRFs, deploys roadblocks, captures everything it needs.
*/
CLASS("Phase3CmdrStrategy", "CmdrStrategy")
	METHOD("new") {
		params [P_THISOBJECT];

		// Don't override anything, leave default values
	} ENDMETHOD;

ENDCLASS;
