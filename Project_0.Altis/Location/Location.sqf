#define OOP_INFO
#define OOP_WARNING
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Location.hpp"
#include "..\MessageTypes.hpp"

#ifndef RELEASE_BUILD
#define DEBUG_LOCATION_MARKERS
#endif

#ifdef _SQF_VM
#undef DEBUG_LOCATION_MARKERS
#endif

/*
Class: Location
Location has garrisons at a static place and spawns units.

Author: Sparker 28.07.2018
*/
#ifdef DEBUG_LOCATION_MARKERS
#define UPDATE_DEBUG_MARKER T_CALLM("updateMarker", [])
#else
#define UPDATE_DEBUG_MARKER
#endif

#define pr private

CLASS("Location", "MessageReceiverEx")

	VARIABLE("type");
	VARIABLE("side");
	VARIABLE("debugName");
	
	VARIABLE("garrisons");
	/*
	VARIABLE("garrisonCiv");
	VARIABLE("garrisonMilAA");
	VARIABLE("garrisonMilMain");
	*/	
	VARIABLE("boundingRadius"); // _radius for a circle border, sqrt(a^2 + b^2) for a rectangular border
	VARIABLE("border"); // _radius for circle or [_a, _b, _dir] for rectangle
	VARIABLE("borderPatrolWaypoints"); // Array for patrol waypoints along the border
	VARIABLE("allowedAreas"); // Array with allowed areas
	VARIABLE("pos"); // Position of this location
	VARIABLE("spawnPosTypes"); // Array with spawn positions types
	VARIABLE("spawned"); // Is this location spawned or not
	VARIABLE("timer"); // Timer object which generates messages for this location
	VARIABLE("capacityInf"); // Infantry capacity
	VARIABLE("capacityCiv"); // Infantry capacity
	VARIABLE("cpModule"); // civilian module, might be replaced by custom script

	STATIC_VARIABLE("all");


	// |                 S E T   D E B U G   N A M E
	/*
	Method: setDebugName
	Sets debug name of this MessageLoop.

	Parameters: _debugName

	_debugName - String

	Returns: nil
	*/
	METHOD("setDebugName") {
		params [P_THISOBJECT, ["_debugName", "", [""]]];
		T_SETV("debugName", _debugName);
	} ENDMETHOD;

	METHOD("setCapacityInf") {
		params [P_THISOBJECT, ["_capacityInf", 0, [0]]];
		T_SETV("capacityInf", _capacityInf);
	} ENDMETHOD;

	METHOD("setCapacityCiv") {
		params [P_THISOBJECT, ["_capacityCiv", 0, [0]]];
		T_SETV("capacityCiv", _capacityCiv);
		if(T_GETV("type") isEqualTo "city")then{
			private _cpModule = [T_GETV("pos"),T_GETV("border")] call CivPresence_fnc_init;
			T_SETV("cpModule",_cpModule);
		};

	} ENDMETHOD;

	METHOD("setSide") {
		params [P_THISOBJECT, ["_side", EAST, [EAST]]];
		T_SETV("side", _side);
	} ENDMETHOD;

	// |                              N E W
	/*
	Method: new

	Parameters: _pos

	_pos - position of this location
	*/
	METHOD("new") {
		params [P_THISOBJECT, ["_pos", [0,0,0], [[]]] ];

		// Check existance of neccessary global objects
		if (isNil "gTimerServiceMain") exitWith {"[MessageLoop] Error: global timer service doesn't exist!";};
		if (isNil "gMessageLoopLocation") exitWith {"[MessageLoop] Error: global location message loop doesn't exist!";};
		if (isNil "gLUAP") exitWith {"[MessageLoop] Error: global location unit array provider doesn't exist!";};

		T_SETV("side", CIVILIAN);
		T_SETV("debugName", "noname");
		T_SETV("garrisons", []);
		SET_VAR_PUBLIC(_thisObject, "boundingRadius", 50);
		SET_VAR_PUBLIC(_thisObject, "border", 50);
		T_SETV("borderPatrolWaypoints", []);
		SET_VAR_PUBLIC(_thisObject, "pos", _pos);
		T_SETV("spawnPosTypes", []);
		T_SETV("spawned", false);
		T_SETV("capacityInf", 0);
		T_SETV("capacityCiv", 0);
		T_SETV("cpModule",objnull);


		SET_VAR_PUBLIC(_thisObject, "allowedAreas", []);
		SET_VAR_PUBLIC(_thisObject, "type", LOCATION_TYPE_UNKNOWN);

		// Setup basic border
		CALLM2(_thisObject, "setBorder", "circle", [20]);

		// Create timer object
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, 0];
		_msg set [MESSAGE_ID_TYPE, LOCATION_MESSAGE_PROCESS];
		private _args = [_thisObject, 1, _msg, gTimerServiceMain]; //["_messageReceiver", "", [""]], ["_interval", 1, [1]], ["_message", [], [[]]], ["_timerService", "", [""]]
		private _timer = NEW("Timer", _args);
		SET_VAR(_thisObject, "timer", _timer);

		//Push the new object into the array with all locations
		private _allArray = GET_STATIC_VAR("Location", "all");
		_allArray pushBack _thisObject;
		PUBLIC_STATIC_VAR("Location", "all");

		UPDATE_DEBUG_MARKER;
	} ENDMETHOD;

	#ifdef DEBUG_LOCATION_MARKERS
	METHOD("updateMarker") {
		params [P_THISOBJECT];
		deleteMarker _thisObject;
		deleteMarker (_thisObject + "_label");
		T_PRVAR(pos);
		if(count _pos > 0) then {
			private _mrk = createmarker [_thisObject, _pos];
			_mrk setMarkerType "mil_box";
			_mrk setMarkerColor "ColorYellow";
			_mrk setMarkerAlpha 1;
			_mrk setMarkerText "";
			_mrk = createmarker [_thisObject + "_label", _pos vectorAdd [-200, -200, 0]];
			_mrk setMarkerType "Empty";
			_mrk setMarkerColor "ColorYellow";
			_mrk setMarkerAlpha 1;
			T_PRVAR(debugName);
			T_PRVAR(type);
			_mrk setMarkerText format ["%1 (%2)(%3)", _thisObject, _debugName, _type];
		};
	} ENDMETHOD;
	#endif
	
	// |                            D E L E T E                             |
	/*
	Method: delete
	*/
	METHOD("delete") {
		params [P_THISOBJECT];

		T_SETV("debugName", nil);
		T_SETV("garrisonCiv", nil);
		T_SETV("garrisonMilAA", nil);
		T_SETV("garrisonMilMain", nil);
		T_SETV("boundingRadius", nil);
		T_SETV("border", nil);
		T_SETV("borderPatrolWaypoints", nil);
		T_SETV("pos", nil);
		T_SETV("spawnPosTypes", nil);
		T_SETV("capacityInf", nil);
		T_SETV("capacityCiv", nil);
		T_SETV("cpModule", nil);

		// Remove the timer
		private _timer = GET_VAR(_thisObject, "timer");
		DELETE(_timer);
		T_SETV("timer", nil);

		//Remove this unit from array with all units
		private _allArray = GET_STATIC_VAR("Location", "all");
		_allArray deleteAt (_allArray find _thisObject);
		PUBLIC_STATIC_VAR("Location", "all");

		#ifdef DEBUG_LOCATION_MARKERS
		deleteMarker _thisObject;
		deleteMarker _thisObject + "_label";
		#endif
	} ENDMETHOD;


	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               G E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	// |                            G E T   A L L
	/*
	Method: (static)getAll
	Returns an array of all locations.

	Returns: Array of location objects
	*/
	STATIC_METHOD("getAll") {
		private _all = GET_STATIC_VAR("Location", "all");
		private _return = +_all;
		_return
	} ENDMETHOD;


	// |                            G E T   P O S                           |
	/*
	Method: getPos
	Returns position of this location

	Returns: Array, position
	*/
	METHOD("getPos") {
		params [ P_THISOBJECT ];
		GETV(_thisObject, "pos")
	} ENDMETHOD;



	// |               G E T   P A T R O L   W A Y P O I N T S
	/*
	Method: getPatrolWaypoints
	Returns array with positions for patrol waypoints.

	Returns: Array of positions
	*/
	METHOD("getPatrolWaypoints") {
		params [ P_THISOBJECT ];
		GETV(_thisObject, "borderPatrolWaypoints")
	} ENDMETHOD;

	// |                  G E T   M E S S A G E   L O O P
	METHOD("getMessageLoop") { //Derived classes must implement this method
		gMessageLoopLocation
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               S E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	
	
	
	
	// Old useless crap, delete it!11
	
	/*
	Method: setGarrisonMilitaryMain
	Sets the main military garrison located at this location

	Parameters: _garrison

	_garrison - <Garrison> object

	Returns: nil
	*/
	/*
	METHOD("setGarrisonMilitaryMain") {
		params [P_THISOBJECT, ["_garrison", "", [""]] ];

		OOP_INFO_1("setGarrisonMilitaryMain: %1", _garrison);

		SET_VAR(_thisObject, "garrisonMilMain", _garrison);
		if (_garrison != "") then {
			CALLM2(_garrison, "postMethodAsync", "setLocation", [_thisObject]);
		};
	} ENDMETHOD;
	*/

	/*
	Method: getGarrisonMilitaryMain
	Gets the main military garrison located at this location

	Returns: <Garrison> or "" if there is no garrison there
	*/
	/*
	METHOD("getGarrisonMilitaryMain") {
		params [P_THISOBJECT, ["_garrison", "", [""]] ];
		GET_VAR(_thisObject, "garrisonMilMain")
	} ENDMETHOD;
	*/
	/*
	Method: getGarrisonMilAA
	Gets the main military garrison located at this location

	Returns: <Garrison> or "" if there is no garrison there
	*/
	/*
	METHOD("getGarrisonMilAA") {
		params [P_THISOBJECT, ["_garrison", "", [""]] ];
		GET_VAR(_thisObject, "garrisonMilAA")
	} ENDMETHOD;
	*/
	
	
	METHOD("registerGarrison") {
		params ["_thisObject", ["_gar", "", [""]]];
		
		pr _gars = T_GETV("garrisons");
		if (! (_gar in _gars)) then {
			_gars pushBack _gar;
			CALLM2(_gar, "postMethodAsync", "ref", []);
		};
		
	} ENDMETHOD;
	
	METHOD("unregisterGarrison") {
		params ["_thisObject", ["_gar", "", [""]]];
		
		pr _gars = T_GETV("garrisons");
		if (_gar in _gars) then {
			_gars deleteAt (_gars find _gar);
			CALLM2(_gar, "postMethodAsync", "unref", []);
		};
	} ENDMETHOD;
	
	
	METHOD("getGarrisons") {
		params ["_thisObject", ["_side", CIVILIAN, [CIVILIAN]]];
		
		if (_side == CIVILIAN) then {
			T_GETV("garrisons")
		} else {
			T_GETV("garrisons") select {CALLM0(_x, "getSide") == _side}
		};
	} ENDMETHOD;
	
	/*
	Method: setType
	Set the Type.

	Parameters: _type

	_type - String

	Returns: nil
	*/
	METHOD("setType") {
		params [P_THISOBJECT, ["_type", "", [""]]];
		SET_VAR_PUBLIC(_thisObject, "type", _type);
		UPDATE_DEBUG_MARKER;
	} ENDMETHOD;

	/*
	Method: getType
	Returns type of this location

	Returns: String
	*/
	METHOD("getType") {
		params [ P_THISOBJECT ];
		GET_VAR(_thisObject, "type")
	} ENDMETHOD;
	
	/*
	Method: getSide
	Returns side of the garrison that controls this location.

	Returns: Side, or Civilian if there is no garrison
	*/
	/*
	METHOD("getSide") {
		params [ "_thisObject" ];
		pr _gar = T_GETV("garrisonMilMain");
		if (_gar == "") then {
			CIVILIAN
		} else {
			CALLM0(_gar, "getSide");
		};
	} ENDMETHOD;
	*/

	/*
	Method: getCapacityInf
	Returns type of this location

	Returns: Integer
	*/
	METHOD("getCapacityInf") {
		params [ P_THISOBJECT ];
		GET_VAR(_thisObject, "capacityInf")
	} ENDMETHOD;

	STATIC_METHOD("findRoadblocks") {
		params [P_THISCLASS, P_POSITION("_pos")];

		//private _pos = T_CALLM("getPos", []);

		private _roadblocksPosDir = [];
		// Get near roads and sort them far to near.
		private _roads_remaining = (_pos nearRoads 1000) apply { [position _x distance _pos, _x] };
		_roads_remaining sort DESCENDING;
		private _itr = 0;
		while {count _roads_remaining > 0 and _itr < 4} do {
			(_roads_remaining#0) params ["_dist", "_road"];
			private _roadscon = (roadsConnectedto _road) apply { [position _x distance _pos, _x] };
			_roadscon sort DESCENDING;
			if (count _roadscon > 0) then {
				private _roadcon = _roadscon#0#1; 
				private _dir = _roadcon getDir _road;

				//private _offs = [7, -7];
				//{
					//_grupo = createGroup _lado;
					//_grupos pushBack _grupo;
				
					private _roadblock_pos = getPos _road; //[getPos _road, _x, _dir] call BIS_Fnc_relPos;
// #ifdef DEBUG_LOCATION_MARKERS
// 					private _mrk = createMarker [format ["roadblock_%1_%2", _thisObject, _itr], _roadblock_pos];
// 					_mrk setMarkerType "mil_triangle";
// 					_mrk setMarkerDir _dir;
// 					_mrk setMarkerColor "ColorWhite";
// 					_mrk setMarkerPos _roadblock_pos;
// 					_mrk setMarkerAlpha 1;
// 					_mrk setMarkerText _mrk;
// #endif
					_roadblocksPosDir pushBack [_roadblock_pos, _dir];
					//_bunker = (selectRandom ["Land_BagBunker_Small_F", "Land_BagFence_Round_F"]) createVehicle _pos;
					// _bunker createVehicle _pos;
					//_vehiculos pushBack _bunker;
					//_bunker setDir _dirveh;
					//_pos = getPosATL _bunker;
					//_tipoVeh =
					//	if (_lado == malos) then {
					//		selectRandom [staticATmalos, NATOMG]
					//	} else {
					//		selectRandom [staticATmuyMalos, CSATMG]
					//	};
					//_veh = _tipoVeh createVehicle _pos;
					//_vehiculos pushBack _veh;
					//_veh setPos _pos;
					//_veh setDir _dirVeh + 180;
					//_tipoUnit =
					//	if (_lado == malos) then {
					//		staticCrewmalos
					//	} else {
					//		staticCrewMuyMalos
					//	};
					//_unit = _grupo createUnit[_tipoUnit, _pos, [], 0, "NONE"];
					//[_unit, _marcador] call A3A_fnc_NATOinit;
					//[_veh] call A3A_fnc_AIVEHinit;
					//_unit moveInGunner _veh;
					//_soldados pushBack _unit;

				//} forEach _offs;
			};
			_roads_remaining = _roads_remaining select {
				((getPos _road) vectorDiff _pos) vectorCos ((getPos (_x select 1)) vectorDiff _pos) < 0.3 and 
				getPos _road distance getPos (_x select 1) > 400
			};
			_itr = _itr + 1;
		};
		_roadblocksPosDir
	} ENDMETHOD;

	// /*
	// Method: getCurrentGarrison
	// Returns the current garrison attached to this location

	// Returns: <Garrison> or "" if there is no current garrison
	// */
	// METHOD("getCurrentGarrison") {
	// 	params [ P_THISOBJECT ];

	// 	private _garrison = GETV(_thisObject, "garrisonMilAA");
	// 	if (_garrison == "") then { _garrison = GETV(_thisObject, "garrisonMilMain"); };
	// 	if (_garrison == "") then { OOP_WARNING_1("No garrison found for location %1", _thisObject); };
	// 	_garrison
	// } ENDMETHOD;

	/*
	Method: (static)findSafePosOnRoad
	Finds an empty position for a vehicle class name on road close to specified position.

	Parameters: _startPos 
	_startPos - start position ATL where to start searching for a position.

	Returns: Array, [_pos, _dir]
	*/
	STATIC_METHOD("findSafePosOnRoad") {
		params ["_thisClass", ["_startPos", [], [[]]], ["_className", "", [""]] ];

		// Try to find a safe position on a road for this vehicle
		private _found = false;
		private _searchRadius = 100;
		pr _return = [];
		while {!_found} do {
			private _roads = _startPos nearRoads _searchRadius;
			if (count _roads < 3) then {
				// Search for more roads at the next iteration
				_searchRadius = _searchRadius * 2;
			} else {
				_roads = _roads apply {[_x distance2D _startPos, _x]};
				_roads sort true; // Ascending
				private _i = 0;
				while {_i < count _roads && !_found} do {
					(_roads select _i) params ["_dist", "_road"];
					private _rct = roadsConnectedTo _road;
					if (count _rct >= 2) then { // We better don't use terminal road pieces
						// Check position if it's safe
						private _dir = _road getDir (_rct select 0);
						// Get Z component of ATL height from two nearest road pieces
						private _z0 = (getPosASL (_rct select 0)) select 2;
						private _z1 = (getPosASL (_rct select 1)) select 2;
						private _posRoad = getPosASL _road;
						_posRoad set [2, 0.5*(_z0 + _z1)];
						_posRoad = ASLToATL _posRoad;

						//diag_log format ["--- road: %1, pos atl: %2", _road, getPosATL _road];
						if (CALLSM3("Location", "isPosSafe", _posRoad, _dir, _className)) then {
							_return = [getPos _road, _dir];
							_found = true;
						};
					};
					_i = _i + 1;
				};
				if (!_found) then {
					// Failed to find a position here, increase the radius
					_searchRadius = _searchRadius * 3;
				};
			};			
		};

		_return
	} ENDMETHOD;

	/*
	Method: (static)findSafePos
	Finds a safe spawn position for a vehicle with given class name.


	Parameters: _className, _pos

	_className - String, vehicle class name
	_startPos - position where to start searching from

	Returns: [_pos, _dir]
	*/
	STATIC_METHOD("findSafeSpawnPos") {
		params ["_thisObject", ["_className", "", [""]], ["_startPos", [], [[]]]];

		private _found = false;
		private _searchRadius = 50;
		pr _posAndDir = [];
		while {!_found} do {
			for "_i" from 0 to 16 do {
				pr _pos = _startPos vectorAdd [-_searchRadius + random(2*_searchRadius), -_searchRadius + random(2*_searchRadius), 0];
				if (CALLSM3("Location", "isPosSafe", _pos, 0, _className) && ! (surfaceIsWater _pos)) exitWith {
					_posAndDir = [_pos, 0];
					_found = true;
				};
			};
			
			if (!_found) then {
				// Search in a larger area at the next iteration
				_searchRadius = _searchRadius * 2;
			};			
		};

		_posAndDir
	} ENDMETHOD;


	/*
	Method: countAvailableUnits
	Returns an number of current units of this location

	Returns: Integer
	*/
	METHOD("countAvailableUnits") {
		params [ P_THISOBJECT, P_SIDE("_side") ];

		// TODO: Yeah we need mutex here!
		private _garrisons = T_CALLM("getGarrisons", [_side]);
		if (count _garrisons == 0) exitWith { 0 };
		private _sum = 0;
		{
			_sum = _sum + CALLM0(_x, "countAllUnits");
		} forEach _garrisons;
		_sum
	} ENDMETHOD;

	// File-based methods

	// Handles messages
	METHOD_FILE("handleMessageEx", "Location\handleMessageEx.sqf");

	// Sets border parameters
	METHOD_FILE("setBorder", "Location\setBorder.sqf");

	// Checks if given position is inside the border
	METHOD_FILE("isInBorder", "Location\isInBorder.sqf");

	// Initializes the location from editor-plased objects
	METHOD_FILE("initFromEditor", "Location\initFromEditor.sqf");

	// Adds a spawn position
	METHOD_FILE("addSpawnPos", "Location\addSpawnPos.sqf");

	// Adds multiple spawn positions from a building
	METHOD_FILE("addSpawnPosFromBuilding", "Location\addSpawnposFromBuilding.sqf");

	// Calculates infantry capacity based on buildings at this location
	METHOD_FILE("calculateInfantryCapacity", "Location\calculateInfantryCapacity.sqf");

	// Gets a spawn position to spawn some unit
	METHOD_FILE("getSpawnPos", "Location\getSpawnPos.sqf");

	// Returns a random position within border
	METHOD_FILE("getRandomPos", "Location\getRandomPos.sqf");

	// Returns how many units of this type and group type this location can hold
	METHOD_FILE("getUnitCapacity", "Location\getUnitCapacity.sqf");

	// Checks if given position is safe to spawn a vehicle here
	STATIC_METHOD_FILE("isPosSafe", "Location\isPosSafe.sqf");

	// Returns the nearest location to given position and distance to it
	STATIC_METHOD_FILE("getNearestLocation", "Location\getNearestLocation.sqf");

	// Returns location that has its border overlapping given position
	STATIC_METHOD_FILE("getLocationAtPos", "Location\getLocationAtPos.sqf");

	// Adds an allowed area
	METHOD_FILE("addAllowedArea", "Location\addAllowedArea.sqf");

	// Checks if player is in any of the allowed areas
	METHOD_FILE("isInAllowedArea", "Location\isInAllowedArea.sqf");

	// Handle PROCESS message
	METHOD_FILE("process", "Location\process.sqf");

	// Spawns the location
	METHOD_FILE("spawn", "Location\spawn.sqf");

	// Despawns the location
	METHOD_FILE("despawn", "Location\despawn.sqf");

ENDCLASS;

SET_STATIC_VAR("Location", "all", []);

// Initialize arrays with building types
call compile preprocessFileLineNumbers "Location\initBuildingTypes.sqf";
