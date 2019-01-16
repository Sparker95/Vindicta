#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\GlobalAssert.hpp"

/*
Class: Garrison
Garrison is an object which holds units and groups and handles their lifecycle (spawning, despawning, destruction).
Garrison is much like a group, it has an <AIGarrison>. But it can have multiple groups of different types.

Author: Sparker 12.07.2018


*/

#define pr private

CLASS("Garrison", "MessageReceiverEx")

	VARIABLE("units");
	VARIABLE("groups");
	VARIABLE("spawned");
	VARIABLE("side");
	VARIABLE("debugName");
	VARIABLE("location");
	VARIABLE("AI"); // The AI brain of this garrison
	
	// ----------------------------------------------------------------------
	// |                 S E T   D E B U G   N A M E                        |
	// ----------------------------------------------------------------------
	
	METHOD("setDebugName") {
		params [["_thisObject", "", [""]], ["_debugName", "", [""]]];
		SET_VAR(_thisObject, "debugName", _debugName);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	/*
	Method: new
	
	Parameters: _side
	
	_side - side of this garrison
	*/
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]]];
		
		// Check existance of neccessary global objects
		ASSERT_GLOBAL_OBJECT(gMessageLoopMain);
		
		SET_VAR(_thisObject, "units", []);
		SET_VAR(_thisObject, "groups", []);
		SET_VAR(_thisObject, "spawned", false);
		SET_VAR(_thisObject, "side", _side);
		SET_VAR(_thisObject, "debugName", "");
		//SET_VAR(_thisObject, "action", "");
		SETV(_thisObject, "AI", "");
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	/*
	Method: delete
	
	*/
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		SET_VAR(_thisObject, "units", nil);
		SET_VAR(_thisObject, "groups", nil);	
		SET_VAR(_thisObject, "spawned", nil);
		SET_VAR(_thisObject, "side", nil);
		SET_VAR(_thisObject, "debugName", nil);
		
		
	} ENDMETHOD;
	
	/*
	Method: getMessageLoop
	See <MessageReceiver.getMessageLoop>
	
	Returns: <MessageLoop>
	*/
	// Returns the message loop this object is attached to
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                           S E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	//                       S E T   L O C A T I O N
	/*
	Method: setLocation
	Sets the location of this garrison
	
	Parameters: _location
	
	_location - <Location>
	*/
	METHOD("setLocation") {
		params [["_thisObject", "", [""]], ["_location", "", [""]] ];
		SET_VAR(_thisObject, "location", _location);
	} ENDMETHOD;
	
	
	
	
	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                           G E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
	
	// Getting values
	
	//                         G E T   S I D E
	/*
	Method: getSide
	Returns side of this garrison.
	
	Returns: Side
	*/
	METHOD("getSide") {
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "side")
	} ENDMETHOD;
	
	
	//                     G E T   L O C A T I O N
	/*
	Method: getLocation
	Returns location this garrison is attached to.
	
	Returns: <Location>
	*/
	METHOD("getLocation") {
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "location");
	} ENDMETHOD;
	
	
	//                      G E T   G R O U P S
	/*
	Method: getGroups
	Returns groups of this garrison.
	
	Returns: Array of <Group> objects.
	*/
	METHOD("getGroups") {
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "groups")
	} ENDMETHOD;
	
	//             F I N D   G R O U P S   B Y   T Y P E
	/*
	Method: findGroupByType
	Finds groups in this garrison that have the same type as _type
	
	Parameters: _type
	
	_type - Number, one of <GROUP_TYPE>
	
	Returns: Array with <Group> objects.
	*/
	METHOD("findGroupsByType") {
		params [["_thisObject", "", [""]], ["_type", 0, [0]]];
		pr _groups = GETV(_thisObject, "groups");
		pr _return = [];
		{
			if (CALLM0(_x, "getType") == _type) then {
				_return pushBack _x;
			};
		} forEach _groups;
		_return
	} ENDMETHOD;
	
	
	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                G O A P 
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		
		
	
	// It should return the goals this garrison might be willing to achieve
	METHOD("getPossibleGoals") {
		["GoalGarrisonRelax",
		"GoalGarrisonRepairAllVehicles",
		"GoalGarrisonDefendPassive"]
	} ENDMETHOD;
	
	METHOD("getPossibleActions") {
		["ActionGarrisonDefendPassive",
		"ActionGarrisonLoadCargo",
		"ActionGarrisonMountCrew",
		"ActionGarrisonMountInfantry",
		"ActionGarrisonMoveDismounted",
		"ActionGarrisonMoveMounted",
		"ActionGarrisonMoveMountedCargo",
		"ActionGarrisonRelax",
		"ActionGarrisonRepairAllVehicles",
		"ActionGarrisonUnloadCurrentCargo"]
	} ENDMETHOD;
	
	
	//            G E T   S U B A G E N T S
	/*
	Method: getSubagents
	Returns subagents of this agent.
	For garrison it returns an empty array, because the subagents of garrison (groups) are processed in a separate thread.

	Access: Used by AI class
	
	Returns: [].
	*/
	METHOD("getSubagents") {
		[] 
		// In case we decide to process groups in the same thread as garrison, we can return the groups here
	} ENDMETHOD;
	
	
	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                E V E N T   H A N D L E R S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
	
	// |                 H A N D L E   U N I T   K I L L E D                |
	/*
	Method: handleUnitKilled
	Called when the unit has been killed.
	
	Must be called inside the garrison thread through postMethodAsync, not inside event handler.
	
	Returns: nil
	*/
	METHOD("handleUnitKilled") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		
		diag_log format ["[Garrison::handleUnitKilled] Info: %1", _unit];
		
		pr _units = GETV(_thisObject, "units");
		
		// Remove the unit from this garrison
		_units deleteAt (_units find _unit);
		
		// Set Garrison of this Unit
		CALLM1(_unit, "setGarrison", "");
		
		// Call handleUnitKilled of the group of this unit
		pr _group = CALLM0(_unit, "getGroup");
		if (_group != "") then {
			CALLM1(_group, "handleUnitKilled", _unit);
		};
		
		// Call handleKilled of the unit
		CALLM0(_unit, "handleKilled");
		
	} ENDMETHOD;	
	
	
	
	
	// ======================================= FILES ==============================================
	
	// Handles incoming messages. Since it's a MessageReceiverEx, we must overwrite handleMessageEx
	METHOD_FILE("handleMessageEx", "Garrison\handleMessageEx.sqf");
	
	// Spawns the whole garrison
	METHOD_FILE("spawn", "Garrison\spawn.sqf");
	
	// Despawns the whole garrison
	METHOD_FILE("despawn", "Garrison\despawn.sqf");
	
	// Adds an existing group into the garrison
	METHOD_FILE("addGroup", "Garrison\addGroup.sqf");
	
	// Adds an existing unit into the garrison
	METHOD_FILE("addUnit", "Garrison\addUnit.sqf");
	
	//Removes an existing unit from this garrison
	METHOD_FILE("removeUnit", "Garrison\removeUnit.sqf");
	
	// Move unit between garrisons
	METHOD_FILE("moveUnit", "Garrison\moveUnit.sqf");
	
	// Find units with specific type
	METHOD_FILE("findUnits", "Garrison\findUnits.sqf");

ENDCLASS;