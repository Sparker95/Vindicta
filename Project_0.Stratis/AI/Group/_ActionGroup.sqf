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
Class: ActionGroup
Group action.
*/

#define pr private

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionGroup", "Action")

	
	VARIABLE("hG");
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		
		ASSERT_OBJECT_CLASS(_AI, "AIGroup");
		
		pr _agent = GETV(_AI, "agent");
		pr _hG = CALLM0(_agent, "getGroupHandle"); // Group handle
		SETV(_thisObject, "hG", _hG);
	} ENDMETHOD;

	/*
	Method: handleUnitRemoved
	Handles what happened when a unit gets removed from its group while the group has some action operational.
	By default it does nothing.
	
	How it gets called: called by <AIGroup> directly.
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/
	
	METHOD("handleUnitRemoved") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		
	} ENDMETHOD;
	
ENDCLASS;