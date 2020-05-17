#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\common.h"
#include "..\Location\Location.hpp"
#include "Intel.hpp"

/*
Classes of intel items
Author: Sparker 05.05.2019
*/

#define pr private

/*
	Class: Intel
	Intel base class. It stores variables that describe intel. It is a base class for more intel types.
*/
#define OOP_CLASS_NAME Intel
CLASS("Intel", "Storable")

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
	Method of how we have got this Intel (from radio, surveilance, etc)
	Not initialized on own intel, only relevant for stolen intel.
	*/
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
	METHOD(new)
		params [P_THISOBJECT];

		OOP_INFO_0("NEW");
	ENDMETHOD;

	/*
	Method: delete
	Destructor. Takes no arguments. Will remove item from associated intelDb if it was created using addIntelClone.
	*/
	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");
	ENDMETHOD;
	

	/*
	Method: isCreated
	Returns: Bool, true if this Intel object has been created already (assigned dateCreated and initialized by owner).
	*/
	METHOD(isCreated)
		params [P_THISOBJECT];
		private _dateCreated = T_GETV("dateCreated");
		!(isNil "_dateCreated")
	ENDMETHOD;
	
	/*
	Method: create
	Set dateCreated to now to indicate that this object is valid.
	*/
	METHOD(create)
		params [P_THISOBJECT];
		T_SETV("dateCreated", date);
		T_SETV("state", INTEL_ACTION_STATE_INACTIVE);
	ENDMETHOD;

	/*
	Method: updateInDb
	Valid only for intel created using addIntelClone. This will updateIntelFromClone directly
	to the database that owns this intel.
	*/
	METHOD(updateInDb)
		params [P_THISOBJECT];
		private _db = T_GETV("db");
		ASSERT_MSG(!isNil "_db", "This intel wasn't created using addIntelClone so you can't use updateInDb.");
		CALLM(_db, "updateIntelFromClone", [_thisObject]);
	ENDMETHOD;

	/*
	Method: getDBEntry
	Returns the db entry of the intel if it associated with its clone.
	*/
	METHOD(getDbEntry)
		params [P_THISOBJECT];
		T_GETV("dbEntry")
	ENDMETHOD;
	

	/*
	Method: clientAdd
	Gets called on client when this intel item is created.
	It should add itself to UI, map, other systems.

	Returns: nil
	*/
	/* virtual */ METHOD(clientAdd)
		params [P_THISOBJECT];
	ENDMETHOD;

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
	/* virtual */ METHOD(clientUpdate)
		params [P_THISOBJECT, P_OOP_OBJECT("_intelSrc")];
	ENDMETHOD;

	/*
	Method: clientRemove
	Gets called on client before this intel item is deleted.
	It should unregister itself from UI, map, other systems.

	Returns: nil
	*/
	/* virtual */ METHOD(clientRemove)

	ENDMETHOD;

	METHOD(getShortName)
		"name"
	ENDMETHOD;

	METHOD(getInfo)
		text ""
	ENDMETHOD;
	

	/*
	Method: addToDatabaseIndex
	Gets called after this intel item was added to a database.
	Here we should add this item to index for specific variable names.

	Returns: nil
	*/
	METHOD(addToDatabaseIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_db")];
	ENDMETHOD;

	/*
	Method: remofeFromDatabaseIndex
	Gets called after this intel item was added to a database.
	Here we should remove this item from the index of specific variable names.

	Returns: nil
	*/
	METHOD(removeFromDatabaseIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_db")];
	ENDMETHOD;

	METHOD(updateDatabaseIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_db"), P_OOP_OBJECT("_itemSrc")];
	ENDMETHOD;

	// - - - - - STORAGE - - - - - -

	/*
	Intel objects are very basic.
	So we just serialize/deserialize all their variables for saving.
	*/

	/* override */ METHOD(serializeForStorage)
		params [P_THISOBJECT];
		SERIALIZE_ALL(_thisObject);
	ENDMETHOD;

	/* override */ METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial")];
		DESERIALIZE_ALL(_thisObject, _serial);
		true
	ENDMETHOD;

ENDCLASS;

#define COLOR_WEST		[0,0.3,0.6,1]
#define COLOR_EAST		[0.5,0,0,1]
#define COLOR_IND		[0,0.5,0,1]
#define COLOR_UNKNOWN	[0.4,0,0.5,1]

/*
	Class: Intel.IntelLocation
	Represents Intel about some location. What faction controls it, how many units there are, and other such things.
*/
#define OOP_CLASS_NAME IntelLocation
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

	/* variable: efficiency
	Efficiency vector, only useful for commander */
	VARIABLE("efficiency");

	/* variable: allMapMarker
	<MapMarker> associated with this intel*/
	VARIABLE("mapMarker"); // NOT SERIALIZABLE! Each machine has its own mapMarker

	METHOD(clientAdd)
		params [P_THISOBJECT];

		private _mrk = NEW("MapMarkerLocation", [_thisObject]);
		T_SETV("mapMarker", _mrk);

		// Set/update marker properties
		T_CALLM1("setLocationMarkerProperties", _thisObject);

		pr _loc = T_GETV("location");
		pr _pos = T_GETV("pos");
		OOP_INFO_2("Added location intel to client: %1, %2", _loc, _pos);

		// Add notification
		if (! isRemoteExecutedJIP && (time > 60) ) then {
			pr _type = T_GETV("type");
			pr _typeStr = CALLSM1("Location", "getTypeString", _type);
			pr _text = if (_type == LOCATION_TYPE_UNKNOWN) then {
				format ["%1 at %2.", _typeStr, mapGridPosition _pos];
			} else {
				format ["%1 at %2.", CALLM0(_loc, "getDisplayName"), mapGridPosition _pos];
			};
			pr _args = ["LOCATION DISCOVERED", _text, ""];
			CALLSM("NotificationFactory", "createIntelLocation", _args);
		};
	ENDMETHOD;

	METHOD(clientUpdate)
		params [P_THISOBJECT, P_OOP_OBJECT("_intelSrc")];

		OOP_INFO_2("Updating %1 from %2", _thisObject, _intelSrc);

		T_CALLM1("setLocationMarkerProperties", _intelSrc);

		pr _loc = T_GETV("location");
		pr _pos = T_GETV("pos");
		pr _type = T_GETV("type");

		// Hint
		// Check what variables were updated
		pr _needNotify = false;
		if (! (T_GETV("type") isEqualTo GETV(_intelSrc, "type"))) then {
			_needNotify = true;
		};
		if (! (T_GETV("side") isEqualTo GETV(_intelSrc, "side"))) then {
			_needNotify = true;
		};
		/*if (! (T_GETV("unitData") isEqualTo GETV(_intelSrc, "unitData"))) then {
			_string = _string + " Updated unit data.";
		};*/

		// Add notification
		if (_needNotify && (! isRemoteExecutedJIP) && (time > 60) ) then {
			pr _typeStr = CALLSM1("Location", "getTypeString", _type);
			pr _text = format ["%1 at %2.", CALLM0(_loc, "getDisplayName"), mapGridPosition _pos];
			pr _args = ["LOCATION INTEL UPDATED", _text, ""];
			CALLSM("NotificationFactory", "createIntelLocation", _args);
		};

	ENDMETHOD;

	METHOD(setLocationMarkerProperties)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];

		//diag_log format ["--- setLocationMarkerProperties: %1", _intel];
		//[_intel] call oop_dumpAllVariables;


		pr _mapMarker = T_GETV("mapMarker"); // Get map marker from this object, not from source object, because source object doesn't have a marker connected to it
		pr _type = GETV(_intel, "type");
		pr _pos = GETV(_intel, "pos");
		pr _side = GETV(_intel, "side");
		pr _mrkType = "unknown";
		/*
		pr _text = "??";
		if (_type != LOCATION_TYPE_UNKNOWN) then {
			pr _t = CALL_STATIC_METHOD("ClientMapUI", "getNearestLocationName", [_pos]);
			if (_t == "") then { // Check if we have got an empty string
				_text = format ["%1 %2", _side, _type]
			} else {
				_text = _t;
			};
		};
		*/

		pr _color = if (_type == LOCATION_TYPE_RESPAWN) then {	// Override for respawn marker, it must be very visible
			[[0.3, 0.3, 1], "ColorOrange"]
		} else {
			switch(_side) do { // See colors defined right above the class
				case WEST: {[COLOR_WEST, "ColorWEST"]};
				case EAST: {[COLOR_EAST, "ColorEAST"]};
				case INDEPENDENT: {[COLOR_IND, "ColorGUER"]};
				default {[COLOR_UNKNOWN, "ColorUNKNOWN"]}; // Purple color
			};
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
		// Don't enable notification for JIP
		pr _enable = ! isRemoteExecutedJIP && (time > 60);
		CALLM1(_mapMarker, "setNotification", _enable);
	ENDMETHOD;

	//  
	METHOD(getShortName)
		"IntelLocation"
	ENDMETHOD;


	METHOD(addToDatabaseIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_db")];
		CALLM3(_db, "addToIndex", _thisObject, OOP_PARENT_STR,	"IntelLocation"); // Item, varName, varValue
		CALLM3(_db, "addToIndex", _thisObject, "location", T_GETV("location")); // Item, varName, varValue
	ENDMETHOD;

	METHOD(removeFromDatabaseIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_db")];

		CALLM2(_db, "removeFromIndex", _thisObject, OOP_PARENT_STR); // Item, varName
		CALLM2(_db, "removeFromIndex", _thisObject, "location"); // Item, varName
	ENDMETHOD;

	METHOD(updateDatabaseIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_db"), P_OOP_OBJECT("_itemSrc")];

		/*
		// We know that location never changes so we don't update it
		CALLM2(_db, "removeFromIndex", _thisObject, "location"); // Item, varName
		CALLM3(_db, "addToIndex", _thisObject, "location",		T_GETV("location")); // Item, varName, varValue
		*/

	ENDMETHOD;

ENDCLASS;


/*
	Class: Intel.IntelCommanderAction
	Base class for all intel about commander actions.
*/
#define OOP_CLASS_NAME IntelCommanderAction
CLASS("IntelCommanderAction", "Intel")

	METHOD(new)
		params [P_THISOBJECT];
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// If it's deleted on client, make sure we clear the map, although it must be also cleared on clientRemove method
		if (! isNil {T_GETV("shownOnMap")}) then {
			T_CALLM1("showOnMap", false);
		};
	ENDMETHOD;

	// State of this commander action (inactive, active, complete, failed, etc), see Intel.hpp for states
	VARIABLE_ATTR("state", [ATTR_SERIALIZABLE]);

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

	/* virtual override */ METHOD(clientAdd)
		params [P_THISOBJECT];

		//OOP_INFO_0("CLIENT ADD");

		T_SETV("shownOnMap", false);

		// Create notification
		if (! isRemoteExecutedJIP) then { // Only if not JIP
			pr _intel = _thisObject;
			pr _actionName = CALLM0(_intel, "getShortName");

			CALLM0(_intel, "getHoursMinutes") params ["_t", "_h", "_m", "_future"];

			OOP_INFO_2("  Intel: %1, T:%2m", _intel, _t);

			// Make a string representation of time difference
			pr _timeDiffStr = if (_h > 0) then {
				format ["%1h %2m", _h, _m]
			} else {
				format ["%1m", _m]
			};
			pr _timeStr = if (_future) then {
				format ["will start in %1", _timeDiffStr];
			} else {
				format ["started %1 ago", _timeDiffStr];
			};

			pr _method = GETV(_intel, "method");
			pr _categoryText = if (_method == INTEL_METHOD_INVENTORY_ITEM) then {
				"INTEL FOUND IN TABLET"
			} else {
				"INTEL INTERCEPTED BY RADIO"
			};
			pr _text = format ["%1 %2", _actionName, _timeStr];
			pr _args = [_categoryText, _text];
			CALLSM("NotificationFactory", "createIntelCommanderAction", _args);
		};


		// Notify ClientMapUI
		CALLM1(gClientMapUI, "onIntelAdded", _thisObject);
	ENDMETHOD;

	/* virtual override */ METHOD(clientRemove)
		params [P_THISOBJECT];

		//OOP_INFO_0("CLIENT REMOVE");

		systemChat format ["Removed intel: %1", _thisObject];

		// Notify ClientMapUI
		CALLM1(gClientMapUI, "onIntelRemoved", _thisObject);

		// Remove map markers
		T_CALLM1("showOnMap", false);
	ENDMETHOD;

	//  
	METHOD(getShortName)
		"Action"
	ENDMETHOD;

	
	/*
	Method: getTMinutes
	Gets the mission time in minutes relative to its start (like spaceship launch)

	Returns: float
	*/
	METHOD(getTMinutes)
		params [P_THISOBJECT];
		[T_GETV("dateDeparture"), date] call pr0_fnc_getTMinutesDiff
	ENDMETHOD;

	METHOD(getHoursMinutes)
		params [P_THISOBJECT];
		T_CALLM0("getTMinutes") call pr0_fnc_getHoursMinutes
	ENDMETHOD;

	/*
	Method: isEnded
	Returns true if state of this action is END
	*/
	METHOD(isEnded)
		params [P_THISOBJECT];
		pr _state = T_GETV("state");
		if (!isNil "_state") then {
			_state != INTEL_ACTION_STATE_END
		} else {
			false
		};
	ENDMETHOD;

	/*
	Method: showOnMap
	This method is only relevant to commander actions.
	Here we have logic to show this intel on the map or hide it.
	*/
	/* virtual */ METHOD(showOnMap)
		params [P_THISOBJECT, P_BOOL("_show")];

		//OOP_INFO_1("SHOW ON MAP: %1", _show);

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
							true, // Draw src and dest markers
							[T_GETV("side"), true] call BIS_fnc_sideColor
							];
				CALLSM("ClientMapUI", "drawRoute", _args);
				T_SETV("shownOnMap", true);
			};
			// params ["_thisClass", P_ARRAY("_posArray"), "_uniqueString", ["_enable", false, [false]], ["_cycle", false, [false]], ["_drawSrcDest", false, [false]] ];
		

		} else {
			// Delete the markers
			if(T_GETV("shownOnMap")) then {
				pr _args = [[],
							_thisObject, // Unique string
							false, // Enable
							false, // Cycle
							false, // Draw src and dest markers
							[T_GETV("side"), true] call BIS_fnc_sideColor
							];
				CALLSM("ClientMapUI", "drawRoute", _args);
				T_SETV("shownOnMap", false);
			};
		};
	ENDMETHOD;

	/*
	Method: getMapZoomPos
	It's meant to return where the map will zoom into on client
	*/
	METHOD(getMapZoomPos)
		params [P_THISOBJECT];
		pr _pos0 = +T_GETV("posSrc");
		pr _pos1 = T_GETV("posTgt");
		pr _ret = (_pos0 vectorAdd _pos1) vectorMultiply 0.5;
		_ret
	ENDMETHOD;

ENDCLASS;

/*
	Class: Intel.IntelCommanderActionReinforce
	Intel about reinforcement commander action.
*/
#define OOP_CLASS_NAME IntelCommanderActionReinforce
CLASS("IntelCommanderActionReinforce", "IntelCommanderAction")

	/*
		variable: type
		type of reinforcement?
	*/
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);

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

	//  
	METHOD(getShortName)
		params [P_THISOBJECT];
		T_GETV("type");
	ENDMETHOD;
ENDCLASS;


/*
	Class: Intel.IntelCommanderActionSupply
*/
#define OOP_CLASS_NAME IntelCommanderActionSupply
CLASS("IntelCommanderActionSupply", "IntelCommanderAction")

	// Type of supplies
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);

	// How much supplies
	VARIABLE_ATTR("amount", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("srcGarrison", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("tgtGarrison", [ATTR_SERIALIZABLE]);

	METHOD(getShortName)
		params [P_THISOBJECT];
		T_GETV("type");
	ENDMETHOD;
ENDCLASS;


/*
Class: Intel.IntelCommanderActionSupplyConvoy
*/
#define OOP_CLASS_NAME IntelCommanderActionSupplyConvoy
CLASS("IntelCommanderActionSupplyConvoy", "IntelCommanderAction")
	/* variable: waypoints
	Waypoints (as positions) that the patrol will visit. */
	VARIABLE_ATTR("waypoints", [ATTR_SERIALIZABLE]);
	/* variable: locations
	Locations of the waypoints will visit. */
	VARIABLE_ATTR("locations", [ATTR_SERIALIZABLE]);
	// Type of supplies
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);
	// How much supplies
	VARIABLE_ATTR("amount", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("schedule", [ATTR_SERIALIZABLE]);

	/*
	Method: showOnMap
	This method is only relevant to commander actions.
	Here we have logic to show this intel on the map or hide it.
	*/
	/* virtual override */ METHOD(showOnMap)
		params [P_THISOBJECT, P_BOOL("_show")];

		//OOP_INFO_1("SHOW ON MAP: %1", _show);

		// Variable might be not initialized
		if (isNil {T_GETV("shownOnMap")}) exitWith {
			OOP_ERROR_0("showOnMap: shownOnMap is nil!");
		};

		if (_show) then {
			if(!T_GETV("shownOnMap")) then {
				private _labels = T_GETV("schedule") apply {
					[[_x] call pr0_fnc_formatDate, "ColorWhite"]
				};
				// Remove the start departure time
				_labels deleteAt 0;

				pr _args = [T_GETV("waypoints"),
							_thisObject, // Unique string
							true, // Enable
							true, // Cycle
							false, // Draw src and dest markers
							[T_GETV("side"), true] call BIS_fnc_sideColor,
							_labels
							];
				CALLSM("ClientMapUI", "drawRoute", _args);
				// params ["_thisClass", P_ARRAY("_posArray"), "_uniqueString", ["_enable", false, [false]], ["_cycle", false, [false]], ["_drawSrcDest", false, [false]] ];
				T_SETV("shownOnMap", true);
			};
		} else {
			if(T_GETV("shownOnMap")) then {
				// Delete the markers
				pr _args = [[],
							_thisObject, // Unique string
							false // Enable
						];
				CALLSM("ClientMapUI", "drawRoute", _args);
				T_SETV("shownOnMap", false);
			};
		};
	ENDMETHOD;

	METHOD(getMapZoomPos)
		params [P_THISOBJECT];
		selectRandom T_GETV("waypoints")
	ENDMETHOD;

	METHOD(getShortName)
		params [P_THISOBJECT];
		T_GETV("type");
	ENDMETHOD;

	METHOD(getInfo)
		params [P_THISOBJECT];
		private _info = "<br/><t color='#FFFFFF' font='EtelkaMonospaceProBold'>Schedule</t><br/>";
		// private _locations = [T_GETV("srcLocation")] + T_GETV("locations") + [T_GETV("tgtLocation")];
		private _schedule = +T_GETV("schedule");
		{
			private _locName = CALLM0(_x, "getName");
			_info = _info + format ["<t color='#FFFFFF'>%1 </t><t color='#AAAAFF'>%2<br/></t>", _forEachIndex + 1, _locName];
			if(_forEachIndex < count _schedule) then {
				private _date = _schedule#_forEachIndex;
				_info = _info + format ["<t>  </t><t color='#AAAAAA' size='0.7'>depart %1</t><br/>", [_date] call pr0_fnc_formatDate];
			};
		} forEach T_GETV("locations");

		_info
	ENDMETHOD;
ENDCLASS;


/*
	Class: Intel.IntelCommanderActionConstructLocation
	Intel about action to build something.
*/
#define OOP_CLASS_NAME IntelCommanderActionConstructLocation
CLASS("IntelCommanderActionConstructLocation", "IntelCommanderAction")
	/* 
		variable: type
		The type of location that will be built. See location types.
	*/
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);

	/* 
		variable: srcGarrison
		The source garrison that sent the reinforcements. Probably players have no use to this.
	*/
	VARIABLE_ATTR("srcGarrison", [ATTR_SERIALIZABLE]);

	//  
	METHOD(getShortName)
		params [P_THISOBJECT];
		pr _type = T_GETV("type");
		// pr _typeStr = CALLSM1("Location", "getTypeString", _type);
		"Construct Roadblock" // Temp, since we only deploy roadblocks now anyway
	ENDMETHOD;
ENDCLASS;

/*
	Class: Intel.IntelCommanderActionAttack
	Intel about action to attack something.
*/
#define OOP_CLASS_NAME IntelCommanderActionAttack
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

	//  
	METHOD(getShortName)
		"Attack"
	ENDMETHOD;
ENDCLASS;

/*
Class: Intel.IntelCommanderActionPatrol
Intel about action to patrol a route.
*/
#define OOP_CLASS_NAME IntelCommanderActionPatrol
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
	/* virtual override */ METHOD(showOnMap)
		params [P_THISOBJECT, P_BOOL("_show")];

		//OOP_INFO_1("SHOW ON MAP: %1", _show);

		// Variable might be not initialized
		if (isNil {T_GETV("shownOnMap")}) exitWith {
			OOP_WARNING_0("showOnMap: shownOnMap is nil!");
		};

		if (_show) then {
			if(!T_GETV("shownOnMap")) then {
				pr _args = [T_GETV("waypoints"),
							_thisObject, // Unique string
							true, // Enable
							true, // Cycle
							false, // Draw src and dest markers
							[T_GETV("side"), true] call BIS_fnc_sideColor
							];
				CALLSM("ClientMapUI", "drawRoute", _args);
				// params ["_thisClass", P_ARRAY("_posArray"), "_uniqueString", ["_enable", false, [false]], ["_cycle", false, [false]], ["_drawSrcDest", false, [false]] ];
				T_SETV("shownOnMap", true);
			};
		} else {
			if(T_GETV("shownOnMap")) then {
				// Delete the markers
				pr _args = [[],
							_thisObject, // Unique string
							false, // Enable
							false, // Cycle
							false, // Draw src and dest markers
							[T_GETV("side"), true] call BIS_fnc_sideColor
							];
				CALLSM("ClientMapUI", "drawRoute", _args);
				T_SETV("shownOnMap", false);
			};
		};
	ENDMETHOD;

	METHOD(getMapZoomPos)
		params [P_THISOBJECT];
		selectRandom T_GETV("waypoints")
	ENDMETHOD;

	METHOD(getShortName)
		"Patrol"
	ENDMETHOD;
ENDCLASS;

/*
Class: Intel.IntelCommanderActionRetreat
Intel about action to retreat from a location.
*/
#define OOP_CLASS_NAME IntelCommanderActionRetreat
CLASS("IntelCommanderActionRetreat", "IntelCommanderAction")
	// Garrison being retreated to.
	VARIABLE_ATTR("tgtGarrison", [ATTR_SERIALIZABLE]);
	// Location being retreated to.
	VARIABLE_ATTR("tgtLocation", [ATTR_SERIALIZABLE]);

	METHOD(getShortName)
		"Retreat"
	ENDMETHOD;
ENDCLASS;

/*
Class: Intel.IntelCommanderActionRecon
The commander is planning something so he sends some recon squads!
*/
#define OOP_CLASS_NAME IntelCommanderActionRecon
CLASS("IntelCommanderActionRecon", "IntelCommanderAction")
	//  
	METHOD(getShortName)
		"Recon"
	ENDMETHOD;
ENDCLASS;


/*
Class: Intel.IntelCluster
Intel about cluster with spotted enemies
*/
#define OOP_CLASS_NAME IntelCluster
CLASS("IntelCluster", "Intel")

	/* variable: efficiency
	Efficiency vector, only useful for commander */
	VARIABLE_ATTR("efficiency", [ATTR_SERIALIZABLE]);

	/* variable: dateNumberLastSpotted
	(dateToNumber date) when any unit from this cluster was seen last time */
	VARIABLE_ATTR("dateNumberLastSpotted", [ATTR_SERIALIZABLE]);

	/* variable: pos1
	Bottom-left pos of the cluster*/
	VARIABLE_ATTR("pos1", [ATTR_SERIALIZABLE]);

	/* variable: pos2
	Top-right pos of the cluster*/
	VARIABLE_ATTR("pos2", [ATTR_SERIALIZABLE]);

	METHOD(clientAdd)
		params [P_THISOBJECT];

		// Create map marker
		pr _mrkName = _thisObject + "_mrk";
		pr _mrkAreaName = _thisObject + "_mrkArea";

		// Create center marker
		createMarkerLocal [_mrkName, [0, 0, 0]];
		_mrkName setMarkerShapeLocal "ICON";
		_mrkName setMarkerColorLocal "colorRed";
		_mrkName setMarkerAlphaLocal 1.0;
		_mrkName setMarkerTypeLocal "mil_warning";

		// Create area marker
		createMarkerLocal [_mrkAreaName, [0, 0, 0]];
		_mrkAreaName setMarkerSizeLocal [50, 50];
		_mrkAreaName setMarkerShapeLocal "ELLIPSE";
		_mrkAreaName setMarkerBrushLocal "SolidBorder";
		_mrkAreaName setMarkerColorLocal "colorRed";
		_mrkAreaName setMarkerAlphaLocal 0.3;

		T_CALLM1("setMarkerProperties", _thisObject);

		// Create notification
		// Get center position from border positions
		pr _pos1 = T_GETV("pos1");
		pr _pos2 = T_GETV("pos2");
		pr _pos = [0.5*(_pos1#0 + _pos2#0), 0.5*(_pos1#1 + _pos2#1), 0];
		CALLSM1("NotificationFactory", "createSpottedTargets", _pos);
	ENDMETHOD;

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
	METHOD(clientUpdate)
		params [P_THISOBJECT, P_OOP_OBJECT("_intelSrc")];

		T_CALLM1("setMarkerProperties", _intelSrc);
	ENDMETHOD;

	/*
	Method: clientRemove
	Gets called on client before this intel item is deleted.
	It should unregister itself from UI, map, other systems.

	Returns: nil
	*/
	METHOD(clientRemove)
		params [P_THISOBJECT];

		// Delete area and central marker
		pr _mrkName = _thisObject + "_mrk";
		pr _mrkAreaName = _thisObject + "_mrkArea";
		deleteMarkerLocal _mrkName;
		deleteMarkerLocal _mrkAreaName;

	ENDMETHOD;

	// _intelSrc - the intel object where to take values from
	METHOD(setMarkerProperties)
		params [P_THISOBJECT, P_OOP_OBJECT("_intelSrc")];

		pr _mrkName = _thisObject + "_mrk";
		pr _mrkAreaName = _thisObject + "_mrkArea";

		// Get center position from border positions
		pr _pos1 = GETV(_intelSrc, "pos1");
		pr _pos2 = GETV(_intelSrc, "pos2");
		pr _pos = [0.5*(_pos1#0 + _pos2#0), 0.5*(_pos1#1 + _pos2#1), 0];

		pr _eff = GETV(_intelSrc, "efficiency");
		pr _text = "  Enemy ";
		if (_eff#T_EFF_crew > 0) then {_text = _text + "Infantry "};
		if ((_eff#T_EFF_medium > 0) || (_eff#T_EFF_armor > 0)) then {_text = _text + "Armor "};
		if (_eff#T_EFF_air > 0) then {_text = _text + "Air "};
		if (_eff#T_EFF_water > 0) then {_text = _text + "Water "};

		pr _dateNumberLastSpotted = GETV(_intelSrc, "dateNumberLastSpotted");
		pr _dateNumberDiff = (dateToNumber date) - _dateNumberLastSpotted;
		pr _dateDiff = numberToDate [date#0, _dateNumberDiff];
		pr _minutes = (_dateDiff#4) + 60*(_dateDiff#3);

		// Add age text
		_text = _text + (format [", %1 min. ago", _minutes]);

		// Set center marker properties
		_mrkName setMarkerPosLocal _pos;
		_mrkName setMarkerTextLocal _text;
		
		// Get width and height of marker
		pr _a = 0.5*(_pos2#0 - _pos1#0);
		pr _b = 0.5*(_pos2#1 - _pos1#1);

		// Set area marker properties
		_mrkAreaName setMarkerPosLocal _pos;
		_mrkAreaName setMarkerSizeLocal [_a + 50, _b + 50];

	ENDMETHOD;

ENDCLASS;

// - - - - TESTS - - - - 
#ifdef _SQF_VM

["Intel.save and load", {
	private _intel = NEW("Intel", []);
	SETV(_intel, "source", "123123");

	pr _storage = NEW("StorageProfileNamespace", []);
	CALLM1(_storage, "open", "testRecordIntel");
	CALLM1(_storage, "save", _intel);
	DELETE(_intel);
	CALLM1(_storage, "load", _intel);

	["Object loaded", GETV(_intel, "source") == "123123" ] call test_Assert;

	true
}] call test_AddTest;

#endif