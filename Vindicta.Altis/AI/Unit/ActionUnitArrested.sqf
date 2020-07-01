#include "common.hpp"

/*
Unit will do nothing and stay arrested.
Author: Sparker 13.02.2019
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitArrested
CLASS("ActionUnitArrested", "ActionUnit")
	
	// ------------ N E W ------------
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE;
	ENDMETHOD;

ENDCLASS;