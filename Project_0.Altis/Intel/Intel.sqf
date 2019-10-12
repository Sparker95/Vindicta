#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Location\Location.hpp"

/*
Classes of intel items
Author: Sparker 05.05.2019
*/

#define pr private

/*
	Class: Intel
	Intel base class. It stores variables that describe intel. It is a base class for more intel types.
*/
CLASS("Intel", "")

	/* variable: dateCreated 
	Date when this intel was created initially in format returned by date command*/
	VARIABLE_ATTR("dateCreated", [ATTR_SERIALIZABLE]); 

	/* variable: dateUpdated 
	Date when this intel was updated in format returned by date command*/
	VARIABLE_ATTR("dateUpdated", []); /*ATTR_SERIALIZABLE*/

	/* variable: pos
	Position*/
	VARIABLE_ATTR("pos", [ATTR_SERIALIZABLE]); // Position

	/* variable: location
	Reference to the <Location> object */
	VARIABLE_ATTR("location", [ATTR_SERIALIZABLE]); // Location

	/* variable: method
	Method of how we have got this Intel (from radio, surveilance, etc)*/
	VARIABLE_ATTR("method", [ATTR_SERIALIZABLE]);

	/* variable: source
	Reference to the source <Intel> item this object is linked with.*/
	VARIABLE_ATTR("source", [ATTR_SERIALIZABLE]);

	/* variable: accuracy
	Can have arbitrary value. Represents how accurate the intel is.*/
	VARIABLE_ATTR("accuracy", [ATTR_SERIALIZABLE]);

	/* variable: dbEntry
	Reference to the dbEntry copy of this intel item. This is filled in by 
	the intelDb when the item is added via addIntelClone, and used in 
	subsequent updateIntelClone operations. */
	VARIABLE("dbEntry");

	/* variable: db
	Reference to the intel database that owns this intel. This is set in
	addIntelClone, and enables the updateInDb function. */
	VARIABLE("db");

	/*
	Method: new
	Constructor. Takes no arguments.
	*/
	METHOD("new") {
		params ["_thisObject"];

		//OOP_INFO_0("NEW");
	} ENDMETHOD;

	/*
	Method: delete
	Destructor. Takes no arguments. Will remove item from associated intelDb if it was created using addIntelClone.
	*/
	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;
	

	/*
	Method: isCreated
	Returns: Bool, true if this Intel object has been created already (assigned dateCreated and initialized by owner).
	*/
	METHOD("isCreated") {
		params [P_THISOBJECT];
		private _dateCreated = T_GETV("dateCreated");
		!(isNil "_dateCreated")
	} ENDMETHOD;
	
	/*
	Method: create
	Set dateCreated to now to indicate that this object is valid.
	*/
	METHOD("create") {
		params [P_THISOBJECT];
		T_SETV("dateCreated", date);
	} ENDMETHOD;

	/*
	Method: updateInDb
	Valid only for intel created using addIntelClone. This will updateIntelFromClone directly
	to the database that owns this intel.
	*/
	METHOD("updateInDb") {
		params [P_THISOBJECT];
		private _db = T_GETV("db");
		ASSERT_MSG(!isNil "_db", "This intel wasn't created using addIntelClone so you can't use updateInDb.");
		CALLM(_db, "updateIntelFromClone", [_thisObject]);
	} ENDMETHOD;
	

	/*
	Method: clientAdd
	Gets called on client when this intel item is created.
	It should add itself to UI, map, other systems.

	Returns: nil
	*/
	/* virtual */ METHOD("clientAdd") {
		params [P_THISOBJECT];
	} ENDMETHOD;

	/*
	Method: clientUpdate
	Gets called on client when this intel item is updated. It should update data in UI, map, other systems.
	!! You don't need to copy member variables here manually !! They will be copied automatically by database methods.
	Just update necessary data of map markers and other things if you need.

	Parameters: _intelSrc

	_intelSrc - the the <Intel> item where values will be copied from

	Returns: nil
	*/
	// 
	// _intelSrc - the source <Intel> item where values will be retrieved from
	/* virtual */ METHOD("clientUpdate") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intelSrc")];
	} ENDMETHOD;

	/*
	Method: clientRemove
	Gets called on client before this intel item is deleted.
	It should unregister itself from UI, map, other systems.

	Returns: nil
	*/
	/* virtual */ METHOD("clientRemove") {

	} ENDMETHOD;

	METHOD("getShortName") {
		"name"
	} ENDMETHOD;

	/*
	Method: addToDatabaseIndex
	Gets called after this intel item was added to a database.
	Here we should add this item to index for specific variable names.

	Returns: nil
	*/
	METHOD("addToDatabaseIndex") {
		params [P_THISOBJECT, P_OOP_OBJECT("_db")];
	} ENDMETHOD;

	/*
	Method: remofeFromDatabaseIndex
	Gets called after this intel item was added to a database.
	Here we should remove this item from the index of specific variable names.

	Returns: nil
	*/
	METHOD("removeFromDatabaseIndex") {
		params [P_THISOBJECT, P_OOP_OBJECT("_db")];
	} ENDMETHOD;

	METHOD("updateDatabaseIndex") {
		params [P_THISOBJECT, P_OOP_OBJECT("_db"), P_OOP_OBJECT("_itemSrc")];
	} ENDMETHOD;

ENDCLASS;

#define COLOR_WEST		[0,0.3,0.6,1]
#define COLOR_EAST		[0.5,0,0,1]
#define COLOR_IND		[0,0.5,0,1]
#define COLOR_UNKNOWN	[0.4,0,0.5,1]

/*
	Class: Intel.IntelLocation
	Represents Intel about some location. What faction controls it, how many units there are, and other such things.
*/
CLASS("IntelLocation", "Intel")

	/* variable: side
	Side that controls this location */
	VARIABLE_ATTR("side", [ATTR_SERIALIZABLE]);

	/* variable: type
	Type of this location */
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);

	/* variable: unitData

	Array with subarrays which hold how many units of specific types/subtypes are there.

	Structure of the array: [infantry, vehicles, drones]

	infantry - [amount of subcategory 0, 1, 2, ...]

	vehicles - [amount of subcategory 0, 1, 2, ...]

	drones - [amount of subcategory 0, 1, 2, ...]

	If this variable is equal to [], it means unit amounts are not known
	*/
	VARIABLE_ATTR("unitData", [ATTR_SERIALIZABLE]);

	
	/* variable: accuracyRadius
	Number, radius in meters that specifies how accurate is the intel.
	The actual location should be somewhere within this radius.
	0 means absolutely accurate coordinates.
	*/
	VARIABLE_ATTR("accuracyRadius", [ATTR_SERIALIZABLE]);

	/* variable: allMapMarker
	<MapMarker> associated with this intel*/
	VARIABLE("mapMarker"); // NOT SERIALIZABLE! Each machine has its own mapMarker

	METHOD("clientAdd") {
		params [P_THISOBJECT];

		private _mrk = NEW("MapMarkerLocation", [_thisObject]);
		T_SETV("mapMarker", _mrk);

		// Set/update marker properties
		CALLSM1("IntelLocation", "setLocationMarkerProperties", _thisObject);

		pr _loc = T_GETV("location");
		pr _pos = T_GETV("pos");
		OOP_INFO_2("Added location intel to client: %1, %2", _loc, _pos);

		pr _type = T_GETV("type");
		pr _typeStr = switch (_type) do {
			case LOCATION_TYPE_POLICE_STATION: {"police station"};
			case LOCATION_TYPE_OBSERVATION_POST: {"observation post"};
			default {_type};
		};

		systemChat format ["Added location intel: %1 at %2.", _typeStr, mapGridPosition _pos];
	} ENDMETHOD;

	METHOD("clientUpdate") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intelSrc")];

		OOP_INFO_2("Updating %1 from %2", _thisObject, _intelSrc);

		CALLSM1("IntelLocation", "setLocationMarkerProperties", _intelSrc);

		pr _loc = T_GETV("location");
		pr _pos = T_GETV("pos");
		pr _type = T_GETV("type");
		pr _typeStr = switch (_type) do {
			case LOCATION_TYPE_POLICE_STATION: {"police station"};
			case LOCATION_TYPE_OBSERVATION_POST: {"observation post"};
			default {_type};
		};
		pr _string = format ["Updated location intel: %1 at %2.", _typeStr, mapGridPosition _pos];

		// Hint
		// Check what variables were updated
		if (! (T_GETV("type") isEqualTo GETV(_intelSrc, "type"))) then {
			_string = _string + " Updated type.";
		};
		if (! (T_GETV("side") isEqualTo GETV(_intelSrc, "side"))) then {
			_string = _string + " Updated side.";
		};
		if (! (T_GETV("unitData") isEqualTo GETV(_intelSrc, "unitData"))) then {
			_string = _string + " Updated unit data.";
		};
		
		systemChat _string;
	} ENDMETHOD;

	STATIC_METHOD("setLocationMarkerProperties") {
		params [P_THISCLASS, P_OOP_OBJECT("_intel")];

		//diag_log format ["--- setLocationMarkerProperties: %1", _intel];
		//[_intel] call oop_dumpAllVariables;


		pr _mapMarker = GETV(_thisObject, "mapMarker"); // Get map marker from this object, not from source object, because source object doesn't have a marker connected to it
		pr _type = GETV(_intel, "type");
		pr _pos = GETV(_intel, "pos");
		pr _side = GETV(_intel, "side");
		pr _mrkType = "unknown";
		pr _text = "??";
		if (_type != LOCATION_TYPE_UNKNOWN) then {
			pr _t = CALL_STATIC_METHOD("ClientMapUI", "getNearestLocationName", [_pos]);
			if (_t == "") then { // Check if we have got an empty string
				_text = format ["%1 %2", _side, _type]
			} else {
				_text = _t;
			};
		};

		pr _color = switch(_side) do { // See colors defined right above the class
			case WEST: {[COLOR_WEST, "ColorWEST"]};
			case EAST: {[COLOR_EAST, "ColorEAST"]};
			case INDEPENDENT: {[COLOR_IND, "ColorGUER"]};
			default {[COLOR_UNKNOWN, "ColorUNKNOWN"]}; // Purple color
		};

		//diag_log format ["--- Setting color: %1", _color];

		pr _radius = GETV(_intel, "accuracyRadius");
		if (isNil "_radius") then {_radius = 0; };

		CALLM1(_mapMarker, "setPos", _pos);
		//CALLM1(_mapMarker, "setText", _text); // Let's not do this for now, not even sure if we want marker text anywhere
		CALLM(_mapMarker, "setColorEx", _color);
		CALLM1(_mapMarker, "setAccuracyRadius", _radius);
		CALLM1(_mapMarker, "setType", _type);

		// Enable notification marker (the red circle)
		CALLM1(_mapMarker, "setNotification", true);
	} ENDMETHOD;

	// 0.1 WIP: dont rely on this
	METHOD("getShortName") {
		"IntelLocation"
	} ENDMETHOD;


	METHOD("addToDatabaseIndex") {
		params [P_THISOBJECT, P_OOP_OBJECT("_db")];
		CALLM3(_db, "addToIndex", _thisObject, OOP_PARENT_STR,	"IntelLocation"); // Item, varName, varValue
		CALLM3(_db, "addToIndex", _thisObject, "location",		T_GETV("location")); // Item, varName, varValue
	} ENDMETHOD;

	METHOD("removeFromDatabaseIndex") {
		params [P_THISOBJECT, P_OOP_OBJECT("_db")];

		CALLM2(_db, "removeFromIndex", _thisObject, OOP_PARENT_STR); // Item, varName
		CALLM2(_db, "removeFromIndex", _thisObject, "location"); // Item, varName
	} ENDMETHOD;

	METHOD("updateDatabaseIndex") {
		params [P_THISOBJECT, P_OOP_OBJECT("_db"), P_OOP_OBJECT("_itemSrc")];

		/*
		// We know that location never changes so we don't update it
		CALLM2(_db, "removeFromIndex", _thisObject, "location"); // Item, varName
		CALLM3(_db, "addToIndex", _thisObject, "location",		T_GETV("location")); // Item, varName, varValue
		*/

	} ENDMETHOD;

ENDCLASS;


/*
	Class: Intel.IntelCommanderAction
	Base class for all intel about commander actions.
*/
CLASS("IntelCommanderAction", "Intel")

	METHOD("new") {
		params [P_THISOBJECT];
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		// If it's deleted on client, make sure we clear the map, although it must be also cleared on clientRemove method
		if (! isNil {T_GETV("shownOnMap")}) then {
			T_CALLM1("showOnMap", false);
		};
	} ENDMETHOD;

	/* 
		variable: side
		Side of the faction that has planned to do this
	*/
	VARIABLE_ATTR("side", [ATTR_SERIALIZABLE]);

	/* 
		variable: posSrc
		Source position
	*/
	VARIABLE_ATTR("posSrc", [ATTR_SERIALIZABLE]);

	/* 
		variable: posTgt
		Target position
	*/
	VARIABLE_ATTR("posTgt", [ATTR_SERIALIZABLE]);

	/* 
		variable: garrison
		Garrison undertaking the action, if any 
	*/
	VARIABLE_ATTR("garrison", [ATTR_SERIALIZABLE]);

	/* 
		variable: posCurrent
		Current position of the garrison that is executing this action. Commander should update it periodycally. 
	*/
	VARIABLE_ATTR("posCurrent", [ATTR_SERIALIZABLE]);

	/* 
		variable: route
		The route that the vehicles or troops will follow. Format is yet unknown.
	*/
	VARIABLE_ATTR("route", [ATTR_SERIALIZABLE]);

	/* 
		variable: transportMethod
		Transport method (ground/air/water). Format is yet unknown.
	*/
	VARIABLE_ATTR("transportMethod", [ATTR_SERIALIZABLE]);

	/* 
		variable: dateDeparture
		Departure date
	*/
	VARIABLE_ATTR("dateDeparture", [ATTR_SERIALIZABLE]);

	/* 
		variable: strength
		Strength of the units allocated for this job. Format is yet unknown.
	*/
	VARIABLE_ATTR("strength", [ATTR_SERIALIZABLE]);

	// Bool, only makes sense on client
	VARIABLE("shownOnMap");

	/* virtual override */ METHOD("clientAdd") {
		params [P_THISOBJECT];

		systemChat format ["Added intel: %1", _thisObject];

		T_SETV("shownOnMap", false);

		// Hint
		hint format ["Added intel: %1", _thisObject];

		// Notify ClientMapUI
		CALLM1(gClientMapUI, "onIntelAdded", _thisObject);
	} ENDMETHOD;

	/* virtual override */ METHOD("clientRemove") {
		params [P_THISOBJECT];

		systemChat format ["Removed intel: %1", _thisObject];

		// Notify ClientMapUI
		CALLM1(gClientMapUI, "onIntelRemoved", _thisObject);

		// Remove map markers
		T_CALLM1("showOnMap", false);
	} ENDMETHOD;

	// 0.1 WIP: dont rely on this
	METHOD("getShortName") {
		"Action"
	} ENDMETHOD;


	/*
	Method: showOnMap
	This method is only relevant to commander actions.
	Here we have logic to show this intel on the map or hide it.
	*/
	/* virtual */ METHOD("showOnMap") {
		params [P_THISOBJECT, P_BOOL("_show")];

		OOP_INFO_1("SHOW ON MAP: %1", _show);

		// Variable might be not initialized
		if (isNil {T_GETV("shownOnMap")}) exitWith {
			OOP_ERROR_0("showOnMap: shownOnMap is nil!");
		};

		if (_show) then {
			if(!T_GETV("shownOnMap")) then {
				pr _args = [[T_GETV("posSrc"), T_GETV("posTgt")],
							_thisObject, // Unique string
							true, // Enable
							false, // Cycle
							true]; // Draw src and dest markers
				CALLSM("ClientMapUI", "drawRoute", _args);
				T_SETV("shownOnMap", true);
			};
			// params ["_thisClass", ["_posArray", [], [[]]], "_uniqueString", ["_enable", false, [false]], ["_cycle", false, [false]], ["_drawSrcDest", false, [false]] ];
		

		} else {
			// Delete the markers
			if(T_GETV("shownOnMap")) then {
				pr _args = [[],
							_thisObject, // Unique string
							false, // Enable
							false, // Cycle
							false]; // Draw src and dest markers
				CALLSM("ClientMapUI", "drawRoute", _args);
				T_SETV("shownOnMap", false);
			};
		};
	} ENDMETHOD;

	/*
	Method: getMapZoomPos
	It's meant to return where the map will zoom into on client
	*/
	METHOD("getMapZoomPos") {
		params [P_THISOBJECT];
		pr _pos0 = +T_GETV("posSrc");
		pr _pos1 = T_GETV("posTgt");
		pr _ret = (_pos0 vectorAdd _pos1) vectorMultiply 0.5;
		_ret
	} ENDMETHOD;

ENDCLASS;

/*
	Class: Intel.IntelCommanderActionReinforce
	Intel about reinforcement commander action.
*/
CLASS("IntelCommanderActionReinforce", "IntelCommanderAction")
	/* 
		variable: srcGarrison
		The source garrison that sent the reinforcements. Probably players have no use to this.
	*/
	VARIABLE_ATTR("srcGarrison", [ATTR_SERIALIZABLE]);
	/* 
		variable: tgtGarrison
		The destination garrison that will be reinforced. Probably players have no use to this.
	*/
	VARIABLE_ATTR("tgtGarrison", [ATTR_SERIALIZABLE]);

	// 0.1 WIP: dont rely on this
	METHOD("getShortName") {
		"Reinforce"
	} ENDMETHOD;
ENDCLASS;

/*
	Class: Intel.IntelCommanderActionBuild
	Intel about action to build something.
*/
CLASS("IntelCommanderActionBuild", "IntelCommanderAction")
	/* 
		variable: type
		The type of object that will be built. Format is unknown now!
	*/
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);

	// 0.1 WIP: dont rely on this
	METHOD("getShortName") {
		"Build"
	} ENDMETHOD;
ENDCLASS;

/*
	Class: Intel.IntelCommanderActionAttack
	Intel about action to attack something.
*/
CLASS("IntelCommanderActionAttack", "IntelCommanderAction")
	/* 
		variable: srcGarrison
		The source garrison that sent the attack. Probably players have no use to this.
	*/
	VARIABLE_ATTR("srcGarrison", [ATTR_SERIALIZABLE]);

	/* 
		variable: type
		The type of attack: QRF, basic attack, something else. IDK the format of this now!
	*/
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("tgtGarrison", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("tgtLocation", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("tgtClusterId", [ATTR_SERIALIZABLE]);

	// 0.1 WIP: dont rely on this
	METHOD("getShortName") {
		"Attack"
	} ENDMETHOD;
ENDCLASS;

/*
Class: Intel.IntelCommanderActionPatrol
Intel about action to patrol a route.
*/
CLASS("IntelCommanderActionPatrol", "IntelCommanderAction")
	/* variable: srcGarrison
	The source garrison that sent the patrol. Probably players have no use to this.*/
	VARIABLE_ATTR("srcGarrison", [ATTR_SERIALIZABLE]);
	/* variable: waypoints
	Waypoints (as positions) that the patrol will visit. */
	VARIABLE_ATTR("waypoints", [ATTR_SERIALIZABLE]);
	/* variable: locations
	Locations that the patrol will visit. */
	VARIABLE_ATTR("locations", [ATTR_SERIALIZABLE]);

	/*
	Method: showOnMap
	This method is only relevant to commander actions.
	Here we have logic to show this intel on the map or hide it.
	*/
	/* virtual override */ METHOD("showOnMap") {
		params [P_THISOBJECT, P_BOOL("_show")];

		// Variable might be not initialized
		if (isNil {T_GETV("shownOnMap")}) exitWith {
			OOP_ERROR_0("showOnMap: shownOnMap is nil!");
		};

		if (_show) then {
			if(!T_GETV("shownOnMap")) then {
				pr _args = [T_GETV("waypoints"),
							_thisObject, // Unique string
							true, // Enable
							true, // Cycle
							false]; // Draw src and dest markers
				CALLSM("ClientMapUI", "drawRoute", _args);
				// params ["_thisClass", ["_posArray", [], [[]]], "_uniqueString", ["_enable", false, [false]], ["_cycle", false, [false]], ["_drawSrcDest", false, [false]] ];
				T_SETV("shownOnMap", true);
			};
		} else {
			if(T_GETV("shownOnMap")) then {
				// Delete the markers
				pr _args = [[],
							_thisObject, // Unique string
							false, // Enable
							false, // Cycle
							false]; // Draw src and dest markers
				CALLSM("ClientMapUI", "drawRoute", _args);
				T_SETV("shownOnMap", false);
			};
		};
	} ENDMETHOD;

	METHOD("getMapZoomPos") {
		params [P_THISOBJECT];
		selectRandom T_GETV("waypoints")
	} ENDMETHOD;

	METHOD("getShortName") {
		"Patrol"
	} ENDMETHOD;
ENDCLASS;

/*
Class: Intel.IntelCommanderActionRetreat
Intel about action to retreat from a location.
*/
CLASS("IntelCommanderActionRetreat", "IntelCommanderAction")
	// Garrison being retreated to.
	VARIABLE_ATTR("tgtGarrison", [ATTR_SERIALIZABLE]);
	// Location being retreated to.
	VARIABLE_ATTR("tgtLocation", [ATTR_SERIALIZABLE]);

	METHOD("getShortName") {
		"Retreat"
	} ENDMETHOD;
ENDCLASS;

/*
Class: Intel.IntelCommanderActionRecon
The commander is planning something so he sends some recon squads!
*/
CLASS("IntelCommanderActionRecon", "IntelCommanderAction")
	// 0.1 WIP: dont rely on this
	METHOD("getShortName") {
		"Recon"
	} ENDMETHOD;
ENDCLASS;