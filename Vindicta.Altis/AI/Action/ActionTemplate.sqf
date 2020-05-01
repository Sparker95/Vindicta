#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\parameterTags.hpp"

/*
Template of an Action class
*/

#define pr private

#define OOP_CLASS_NAME MyAction
CLASS("MyAction", "Action");

	// ------------ N E W ------------

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

	ENDMETHOD;

	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT];

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	ENDMETHOD;

	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];

		T_CALLM0("activateIfInactive");

		// Return the current state
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];
	ENDMETHOD;


	// Calculates cost of this action
	/*
	STATIC_METHOD(P_THISCLASS, "getCost") {
		params [P_OOP_OBJECT("_AI"), P_ARRAY("_wsStart"), P_ARRAY("_wsEnd")];

		// Return cost
		0
	ENDMETHOD;
	*/

ENDCLASS;
