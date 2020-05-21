#include "common.hpp"



/*
Class: AmbientMission
A base class for simple missions that are only active when a location is spawned. 
They should be created in GameMode.locationSpawned and deleted in GameMode.locationDespawned.
*/
#define OOP_CLASS_NAME AmbientMission
CLASS("AmbientMission", "")
	VARIABLE("states");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_city"), P_ARRAY("_states")];
		T_SETV("states", _states);
	ENDMETHOD;

	/*
	Method: isActive
	Whether the mission should be active. Active means generating new missions of this type.

	Parameters: _city
	
	_city - Location, the city we want to evaluate if this mission should be active for.
	
	Returns: Boolean, whether the mission should be active for the city specified.
	*/
	METHOD(isActive)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		private _states = T_GETV("states");
		private _cityData = GETV(_city, "gameModeData");
		GETV(_cityData, "state") in _states
	ENDMETHOD;
	
	/*
	Method: update
	Called while the location is spawned.

	Parameters: _city
	
	_city - Location, the city we want to update for.
	*/
	METHOD(update)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];

		private _active = T_CALLM("isActive", [_city]);
		T_CALLM("updateExisting", [_city ARG _active]);

		if(_active) then {
			T_CALLM("spawnNew", [_city]);
		}
	ENDMETHOD;

	/*
	Method: (protected virtual) updateExisting
	Override this to provide behaviour for updating existing missions of this type. Do NOT create new missions in this 
	function.

	Parameters: _city
	
	_city - Location, the city we want to update for.
	*/
	/* protected virtual */ METHOD(updateExisting)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
	ENDMETHOD;

	/*
	Method: (protected virtual) spawnNew
	Override this to provide behaviour for spawning new missions of this type. This is only called if this mission type 
	is active, as specified in the isActive function.

	Parameters: _city
	
	_city - Location, the city we want to (maybe) spawn new missions for.
	*/
	/* protected virtual */ METHOD(spawnNew)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
	ENDMETHOD;
	
ENDCLASS;