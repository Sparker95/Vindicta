#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Group action.
*/

#define pr private

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionGroup", "Action")

	VARIABLE("hG");
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		pr _agent = GETV(_AI, "agent");
		pr _hG = CALLM0(_agent, "getGroupHandle"); // Group handle
		SETV(_thisObject, "hG", _hG);
	} ENDMETHOD;

ENDCLASS;