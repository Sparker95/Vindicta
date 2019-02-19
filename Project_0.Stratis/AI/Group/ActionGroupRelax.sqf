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
Class: ActionGroup.ActionGroupRelax
*/

#define pr private

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionGroupRelax", "ActionGroup")
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		// Set behaviour
		pr _AI = T_GETV("AI");
		pr _hG = GETV(_thisObject, "hG");
		_hG setBehaviour "SAFE";
		{_x doFollow (leader _hG)} forEach (units _hG);
		_hG setFormation "DIAMOND";
		
		// Find some random position at the location and go there
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _gar = CALLM0(_group, "getGarrison");
		pr _loc = CALLM0(_gar, "getLocation");
		pr _pos = CALLM0(_loc, "getRandomPos");
		
		// Delete all waypoints
		while {(count (waypoints _hG)) > 0} do
		{
			deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];
		};
		
		// Add a move waypoint
		pr _wp = _hG addWaypoint [_pos, 20, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointFormation "DIAMOND";
		_wp setWaypointBehaviour "SAFE";
		_hG setCurrentWaypoint _wp;
		
		// Give a goal to units
		pr _units = CALLM0(_group, "getUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitDismountCurrentVehicle", 0, [], _AI);
		} forEach _units;
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Delete the goal to dismount vehicles
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _units = CALLM0(_group, "getUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitDismountCurrentVehicle", "");
		} forEach _units;
	} ENDMETHOD;

ENDCLASS;