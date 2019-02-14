#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "garrisonWorldStateProperties.hpp"
#include "..\parameterTags.hpp"
#include "..\..\Group\Group.hpp"

/*
This action tries to find drivers and turret operators for vehicles in all vehicle groups
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonRebalanceVehicleGroups"

CLASS(THIS_ACTION_NAME, "ActionGarrison")

	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		// Give waypoint to the vehicle group
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		
		// Create a pool of units we can use to fill vehicle slots
		pr _freeUnits = [];
		pr _groupTypes = [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL, GROUP_TYPE_BUILDING_SENTRY];
		pr _freeGroups = CALLM1(_gar, "findGroupsByType", _groupTypes);
		{
			_freeUnits append CALLM0(_x, "getUnits");
		} forEach _freeGroups;
		
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		
		// Try to add drivers to all groups
		{ // foreach _vehGroups
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _nInf = count CALLM0(_x, "getInfantryUnits");
			
			pr _nMoreDriversRequired = _nDrivers - _nInf;
			if (_nMoreDriversRequired > 0) then {
				while {_nMoreDriversRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nMoreDriversRequired = _nMoreDriversRequired - 1;
				};
			};
		} forEach _vehGroups;
		
		// Try to add turret operators to all groups
		{ // foreach _vehGroups
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _nInf = count CALLM0(_x, "getInfantryUnits");
			
			pr _nTurretOperatorsRequired = _nTurrets - _nInf - _nDrivers;
			
			if (_nTurretOperatorsRequired > 0) then {
				while {_nTurretOperatorsRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nTurretOperatorsRequired = _nTurretOperatorsRequired - 1;
				};
			};
		} forEach _vehGroups;
		
		// Call the health sensor again so that it can update the world state properties
		CALLM0(GETV(_AI, "sensorHealth"), "update");
		
		pr _ws = GETV(_AI, "worldState");
		
		pr _state = ACTION_STATE_FAILED;
		if ([_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, true] call ws_propertyExistsAndEquals) then {
			_state = ACTION_STATE_COMPLETED;
		};
				
		// Set state
		SETV(_thisObject, "state", _state);
		
		// Return ACTIVE state
		_state		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;

ENDCLASS;