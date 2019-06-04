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
	VARIABLE("name");

	VARIABLE("children"); // Children of this location if it has any (e.g. police stations are children of cities)
	VARIABLE("parent"); // Parent of the Location if it has one (e.g. parent of police station is its containing city location)

	VARIABLE("garrisons");

	VARIABLE("boundingRadius"); // _radius for a circle border, sqrt(a^2 + b^2) for a rectangular border
	VARIABLE("border"); // _radius for circle or [_a, _b, _dir] for rectangle
	VARIABLE("borderPatrolWaypoints"); // Array for patrol waypoints along the border
	VARIABLE("useParentPatrolWaypoints"); // If true then use the parents patrol waypoints instead
	VARIABLE("allowedAreas"); // Array with allowed areas
	VARIABLE("pos"); // Position of this location
	VARIABLE("spawnPosTypes"); // Array with spawn positions types
	VARIABLE("spawned"); // Is this location spawned or not
	VARIABLE("timer"); // Timer object which generates messages for this location
	VARIABLE("capacityInf"); // Infantry capacity
	VARIABLE("capacityCiv"); // Civilian capacity
	VARIABLE("cpModule"); // civilian module, might be replaced by custom script

	VARIABLE("isBuilt"); // true if this location has been build (used for roadblocks)
	VARIABLE("buildObjects"); // Array with objects we have built
	
	VARIABLE("gameModeData"); // Custom object that the game mode can use to store info about this location

	STATIC_VARIABLE("all");

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
		if (isNil "gMessageLoopMain") exitWith {"[MessageLoop] Error: global location message loop doesn't exist!";};
		if (isNil "gLUAP") exitWith {"[MessageLoop] Error: global location unit array provider doesn't exist!";};

		T_SETV("side", CIVILIAN);
		T_SETV("name", "noname");
		T_SETV("garrisons", []);
		SET_VAR_PUBLIC(_thisObject, "boundingRadius", 50);
		SET_VAR_PUBLIC(_thisObject, "border", 50);
		T_SETV("borderPatrolWaypoints", []);
		T_SETV("useParentPatrolWaypoints", false);
		SET_VAR_PUBLIC(_thisObject, "pos", _pos);
		T_SETV("spawnPosTypes", []);
		T_SETV("spawned", false);
		T_SETV("capacityInf", 0);
		T_SETV("capacityCiv", 0);
		T_SETV("cpModule",objnull);
		T_SETV("isBuilt", false);
		T_SETV("buildObjects", []);
		T_SETV("children", []);
		T_SETV("parent", NULL_OBJECT);

		SET_VAR_PUBLIC(_thisObject, "allowedAreas", []);
		SET_VAR_PUBLIC(_thisObject, "type", LOCATION_TYPE_UNKNOWN);

		// Setup basic border
		CALLM2(_thisObject, "setBorder", "circle", [20]);
		
		T_SETV("timer", "");


		//Push the new object into the array with all locations
		private _allArray = GET_STATIC_VAR("Location", "all");
		_allArray pushBack _thisObject;
		PUBLIC_STATIC_VAR("Location", "all");

		UPDATE_DEBUG_MARKER;
	} ENDMETHOD;

	// |                 S E T   D E B U G   N A M E
	/*
	Method: setName
	Sets debug name of this MessageLoop.

	Parameters: _name

	_name - String

	Returns: nil
	*/
	METHOD("setName") {
		params [P_THISOBJECT, ["_name", "", [""]]];
		T_SETV("name", _name);
	} ENDMETHOD;

	METHOD("setCapacityInf") {
		params [P_THISOBJECT, ["_capacityInf", 0, [0]]];
		T_SETV("capacityInf", _capacityInf);
	} ENDMETHOD;

	METHOD("setCapacityCiv") {
		params [P_THISOBJECT, ["_capacityCiv", 0, [0]]];
		T_SETV("capacityCiv", _capacityCiv);
		if(T_GETV("type") isEqualTo LOCATION_TYPE_CITY)then{
			private _cpModule = [T_GETV("pos"),T_GETV("border")] call CivPresence_fnc_init;
			T_SETV("cpModule",_cpModule);
		};

	} ENDMETHOD;

	METHOD("setSide") {
		params [P_THISOBJECT, ["_side", EAST, [EAST]]];
		T_SETV("side", _side);
	} ENDMETHOD;

	/*
	Method: addChild
	Adds a child location to this location (also sets the childs parent).
	Child must not belong to another location already.
	*/
	METHOD("addChild") {
		params [P_THISOBJECT, P_OOP_OBJECT("_childLocation")];
		ASSERT_OBJECT_CLASS(_childLocation, "Location");
		ASSERT_MSG(IS_NULL_OBJECT(GETV(_childLocation, "parent")), "Location is already assigned to another parent");
		T_GETV("children") pushBack _childLocation;
		SETV(_childLocation, "parent", _thisObject);
		nil
	} ENDMETHOD;


	#ifdef DEBUG_LOCATION_MARKERS
	METHOD("updateMarker") {
		params [P_THISOBJECT];

		T_PRVAR(type);
		deleteMarker _thisObject;
		deleteMarker (_thisObject + "_label");
		T_PRVAR(pos);

		if(count _pos > 0) then {

			private _mrk = createmarker [_thisObject, _pos];
			_mrk setMarkerType (switch T_GETV("type") do {
				case LOCATION_TYPE_ROADBLOCK: { "mil_triangle" };
				case LOCATION_TYPE_BASE: { "mil_circle" };
				case LOCATION_TYPE_OUTPOST: { "mil_box" };
				default { "mil_dot" };
			});
			_mrk setMarkerColor "ColorYellow";
			_mrk setMarkerAlpha 1;
			_mrk setMarkerText "";

			T_PRVAR(border);
			if(_border isEqualType []) then {
				_mrk setMarkerDir _border#2;
			};
			
			if(not (_type in [LOCATION_TYPE_ROADBLOCK, LOCATION_TYPE_CITY, LOCATION_TYPE_POLICE_STATION])) then {
				_mrk = createmarker [_thisObject + "_label", _pos vectorAdd [-200, -200, 0]];
				_mrk setMarkerType "Empty";
				_mrk setMarkerColor "ColorYellow";
				_mrk setMarkerAlpha 1;
				T_PRVAR(name);
				T_PRVAR(type);
				_mrk setMarkerText format ["%1 (%2)(%3)", _thisObject, _name, _type];
			};
		};
	} ENDMETHOD;
	#endif
	
	// |                            D E L E T E                             |
	/*
	Method: delete
	*/
	METHOD("delete") {
		params [P_THISOBJECT];

		T_SETV("name", nil);
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
		if(T_GETV("useParentPatrolWaypoints")) then {
			private _parent = T_GETV("parent");
			CALLM0(_parent, "getPatrolWaypoints");
		} else {
			T_GETV("borderPatrolWaypoints");
		}
	} ENDMETHOD;

	// |                  G E T   M E S S A G E   L O O P
	METHOD("getMessageLoop") { //Derived classes must implement this method
		gMessageLoopMain
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               S E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	METHOD("registerGarrison") {
		params ["_thisObject", ["_gar", "", [""]]];
		
		pr _gars = T_GETV("garrisons");
		if (! (_gar in _gars)) then {
			_gars pushBack _gar;
			CALLM2(_gar, "postMethodAsync", "ref", []);

			// TODO: work out how this should work properly? This isn't terrible but we will
			// have resource constraints etc. Probably it should be in Garrison.process to build
			// at location when they have resources?
			iF(!T_GETV("isBuilt")) then {
				T_CALLM("build", []);
			};
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
			+T_GETV("garrisons")
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

		// Create a timer object if the type of the location is a city or a roadblock
		if (_type in [LOCATION_TYPE_CITY, LOCATION_TYPE_ROADBLOCK]) then {
			
			// Delete previous timer if we had it
			pr _timer = T_GETV("timer");
			if (_timer != "") then {
				DELETE(_timer);
			};

			// Create timer object
			private _msg = MESSAGE_NEW();
			_msg set [MESSAGE_ID_DESTINATION, _thisObject];
			_msg set [MESSAGE_ID_SOURCE, ""];
			_msg set [MESSAGE_ID_DATA, 0];
			_msg set [MESSAGE_ID_TYPE, LOCATION_MESSAGE_PROCESS];
			private _args = [_thisObject, 1, _msg, gTimerServiceMain]; //["_messageReceiver", "", [""]], ["_interval", 1, [1]], ["_message", [], [[]]], ["_timerService", "", [""]]
			private _timer = NEW("Timer", _args);
			SET_VAR(_thisObject, "timer", _timer);
		};

		T_CALLM("updateWaypoints", []);

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
				_roads = _roads apply { [_x distance2D _startPos, _x] };
				_roads sort ASCENDING;
				private _i = 0;
				while {_i < count _roads && !_found} do {
					(_roads select _i) params ["_dist", "_road"];
					private _rct = roadsConnectedTo _road;
					// TODO: we can preprocess spawn locations better than this probably.
					// Need a connected road (this is guaranteed probably?)
					if (count _rct == 2 and 
						// Avoid spawning too close to a junction
						{{ count (roadsConnectedTo _x) > 2} count ((getPos _road) nearRoads 15) == 0}) then {
						// Check position if it's safe
						private _dir = _road getDir (_rct select 0);

						private _width = [_road, 1, 8] call misc_fnc_getRoadWidth;
						private _pos = [getPos _road, _width - 3, _dir + 90] call BIS_Fnc_relPos;
						if(CALLSM3("Location", "isPosSafe", _pos, _dir, _className)) then {
							_return = [_pos, _dir];
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
		params ["_thisClass", ["_className", "", [""]], ["_startPos", [], [[]]]];

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

	/*
	Method: setBorder
	Sets border parameters for this location

	Arguments:
	_type - "circle" or "rectange"
	_data	- for "circle":
		_radius
			- for "rectangle":
		[_a, _b, _dir] - rectangle dimensions and direction

	*/
	METHOD("setBorder") {
		params [P_THISOBJECT, P_STRING("_type"), ["_data", [50], [0, []]] ];

		switch (_type) do {
			case "circle" : {
				_data params [ ["_radius", 0, [0] ] ];
				SET_VAR_PUBLIC(_thisObject, "boundingRadius", _radius);
				SET_VAR_PUBLIC(_thisObject, "border", _radius);
			};
			
			case "rectangle" : {
				_data params ["_a", "_b", "_dir"];
				private _radius = sqrt(_a*_a + _b*_b);
				SET_VAR_PUBLIC(_thisObject, "border", _data);
				SET_VAR_PUBLIC(_thisObject, "boundingRadius", _radius);
			};
			
			default {
				diag_log format ["[Location::setBorder] Error: wrong border type: %1, location: %2", _type, GET_VAR(_thisObject, "name")];
			};
		};

		T_CALLM("updateWaypoints", []);
	} ENDMETHOD;
	

	// File-based methods

	// Handles messages
	METHOD_FILE("handleMessageEx", "Location\handleMessageEx.sqf");

	// Sets border parameters
	METHOD_FILE("updateWaypoints", "Location\updateWaypoints.sqf");

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

	// Builds the location
	METHOD_FILE("build", "Location\build.sqf");

ENDCLASS;

SET_STATIC_VAR("Location", "all", []);

// Initialize arrays with building types
call compile preprocessFileLineNumbers "Location\initBuildingTypes.sqf";
