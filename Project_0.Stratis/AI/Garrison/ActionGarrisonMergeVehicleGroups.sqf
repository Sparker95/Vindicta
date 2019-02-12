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
#include "..\..\Group\Group.hpp"

/*
Merges or splits vehicle group(s)
We need to merge vehicle groups into one group for convoy.

Parameters:
_merge - true to merge, false to split
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMergeVehicleGroups"

CLASS(THIS_ACTION_NAME, "ActionGarrison")
	
	VARIABLE("merge");
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _merge = CALLSM2("Action", "getParameterValue", _parameters, TAG_MERGE);
		T_SETV("merge", _merge);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		pr _gar = T_GETV("gar");
		pr _merge = T_GETV("merge");
		if (_merge) then {
			// Find all vehicle groups
			pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC);
			
			// If there are more than one vehicle groups, merge them into the first group
			if (count _vehGroups > 1) then {
				pr _destGroup = _vehGroups select 0;
				for "_i" from 1 to (count _vehGroups - 1) do {
					pr _group = _vehGroups select _i;
					CALLM1(_destGroup, "addGroup", _group);
					DELETE(_group);
				};
			};
		} else {
			// Find all vehicle groups
			pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC);
			
			// Split every vehicle group
			{
				pr _group = _x;
				pr _groupVehicles = CALLM0(_group, "getUnits") select {CALLM0(_x, "isVehicle")};
				
				// If there are more than one vehicle
				if (count _groupVehicles > 1) then {
					// Temporarily stop the AI object of the group because it can perform vehicle assignments in the other thread
					// Event handlers when units are destroyed are disposed from this thread anyway
					pr _groupAI = CALLM0(_group, "getAI");
					if (_groupAI != "") then {
						CALLM2(_groupAI, "postMethodSync", "stop",  []);
					};
					
					// Create a new group per every vehicle (except for the first one)
					pr _side = CALLM0(_group, "getSide");
					for "_i" from 1 to ((count _groupVehicles) - 1) do {
						pr _vehicle = _groupVehicles select _i;
						pr _vehAI = CALLM0(_vehicle, "getAI");
						
						// Create a group, add it to the garrison
						pr _newGroup = NEW("Group", [_side]);
						CALLM1(_gar, "addGroup", _newGroup);
						
						// Get crew of this vehicle
						pr _vehCrew = CALLM3(_vehAI, "getAssignedUnits", true, true, false) select {
							// We only need units in this vehicle that are also in this group
							CALLM0(_x, "getGroup") == _group
						};
						//OOP_INFO_1("Vehicle crew: %1", _vehCrew);
						
						// Move units to the new group
						{ CALLM1(_newGroup, "addUnit", _x); } forEach _vehCrew;
					};
					
					// Start up the AI object again
					if (_groupAI != "") then {
						CALLM2(_groupAI, "postMethodSync", "start",  []);
					};
				};
			} forEach _vehGroups;
		};
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
		
		// We are done here
		ACTION_STATE_COMPLETED
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		// Return the current state
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;

ENDCLASS;