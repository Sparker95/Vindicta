//#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\parameterTags.hpp"

/*
Class: ActionGroup.ActionGroupMoveGroundVehicles
Handles moving of a group with multiple or single ground vehicles.
*/

#define pr private

CLASS("ActionGroupMoveGroundVehicles", "ActionGroup")
	
	VARIABLE("pos");
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _hG = T_GETV("hG");
		pr _pos = T_GETV("pos");
		
		// Delete all previous waypoints
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };
		
		// Set group behaviour
		_hG setBehaviour "SAFE";
		_hG setFormation "COLUMNG";
		_hG setCombatMode "GREEN"; // Hold fire, defend only
		
		// Give a waypoint to move
		pr _wp = _hG addWaypoint [_pos, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointFormation "COLUMN";
		_wp setWaypointBehaviour "SAFE";
		_wp setWaypointCombatMode "GREEN";
		_hG setCurrentWaypoint _wp; 
		
		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// Logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		_state
	} ENDMETHOD;
	
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]] ];
		
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Stop the group
		pr _hG = T_GETV("hG");
		// Delete waypoints
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };
		// Add a move waypoint at the current position of the leader
		pr _wp = _hG addWaypoint [getPos leader _hG, 0];
		_wp setWaypointType "MOVE";
		_hG setCurrentWaypoint _wp;
		
	} ENDMETHOD;

ENDCLASS;