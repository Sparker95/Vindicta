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
Class: ActionGarrison
Garrison action.
*/

#define pr private

CLASS("ActionGarrison", "Action")

	VARIABLE("gar");
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		
		ASSERT_OBJECT_CLASS(_AI, "AIGarrison");
		
		pr _gar = GETV(_AI, "agent");
		SETV(_thisObject, "gar", _gar);
	} ENDMETHOD;



	/*
	Method: handleGroupsAdded
	Override in your action to perform special handling of what happens when groups are added while your action is running.
	By default it doesn't do anything.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD("handleGroupsAdded") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		nil
	} ENDMETHOD;


	/*
	Method: handleGroupsRemoved
	Override in your action to perform special handling of what happens when groups are removed while your action is running.
	By default it doesn't do anything.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD("handleGroupsRemoved") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		nil
	} ENDMETHOD;
	
ENDCLASS;