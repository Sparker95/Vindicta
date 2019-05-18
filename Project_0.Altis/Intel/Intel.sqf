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
	VARIABLE_ATTR("dateUpdated", [ATTR_SERIALIZABLE]);

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

		//OOP_INFO_0("DELETE");

		// If db is valid then we can directly remove our matching intel entry from it.
		private _db = T_GETV("db");
		if(!isNil "_db") then {
			T_PRVAR(dbEntry);
			ASSERT_MSG(_dbEntry != _thisObject, "Circular reference in Intel!");

			OOP_INFO_MSG("cleaning up intel object from db", []);
			CALLM(_db, "removeIntelForClone", [_thisObject]);
			DELETE(T_GETV("dbEntry"));
			OOP_INFO_MSG("cleaned up intel object from db", []);
		};
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

ENDCLASS;

/*
Class: Intel.IntelLocation
Represents Intel about some location. What faction controls it, how many units there are, and other such things.
*/

#define COLOR_WEST		[0,0.3,0.6,1]
#define COLOR_EAST		[0.5,0,0,1]
#define COLOR_IND		[0,0.5,0,1]
#define COLOR_UNKNOWN	[0.4,0,0.5,1]

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
		CALLM0(_thisObject, "setLocationMarkerProperties");

		pr _loc = T_GETV("location");
		pr _pos = T_GETV("pos");
		OOP_INFO_2("Added location intel to client: %1, %2", _loc, _pos);

		// Hint
		hint "Location data was added";
	} ENDMETHOD;

	METHOD("clientUpdate") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intelSrc")];

		OOP_INFO_2("Updating %1 from %2", _thisObject, _intelSrc);

		CALLM0(_thisObject, "setLocationMarkerProperties");

		// Hint
		// Check what variables were updated
		private _string = "Location data was updated.";
		if (! (T_GETV("type") isEqualTo GETV(_intelSrc, "type"))) then {
			_string = _string + " Updated type.";
		};
		if (! (T_GETV("side") isEqualTo GETV(_intelSrc, "side"))) then {
			_string = _string + " Updated side.";
		};
		if (! (T_GETV("unitData") isEqualTo GETV(_intelSrc, "unitData"))) then {
			_string = _string + " Updated unit data.";
		};

		hint _string;
	} ENDMETHOD;

	METHOD("setLocationMarkerProperties") {
		params [P_THISOBJECT];

		pr _mapMarker = T_GETV("mapMarker");
		pr _type = T_GETV("type");
		pr _pos = T_GETV("pos");
		pr _side = T_GETV("side");
		pr _text = if (_type != LOCATION_TYPE_UNKNOWN) then {
			pr _t = CALL_STATIC_METHOD("ClientMapUI", "getNearestLocationName", [_pos]);
			if (_t == "") then { // Check if we have got an empty string
				format ["%1 %2", _side, _type]
			} else {
				_t
			};
		} else {
			"??"
		};

		pr _color = switch(_side) do { // See colors defined right above the class
			case WEST: {COLOR_WEST};
			case EAST: {COLOR_EAST};
			case INDEPENDENT: {COLOR_IND};
			default {COLOR_UNKNOWN};
		};

		pr _radius = T_GETV("accuracyRadius");
		if (isNil "_radius") then {_radius = 0; };

		CALLM1(_mapMarker, "setPos", _pos);
		CALLM1(_mapMarker, "setText", _text);
		CALLM1(_mapMarker, "setColor", _color);
		CALLM1(_mapMarker, "setAccuracyRadius", _radius);
	} ENDMETHOD;

ENDCLASS;



/*
Class: Intel.IntelCommanderAction
Base class for all intel about commander actions.
*/

CLASS("IntelCommanderAction", "Intel")
	/* variable: side
	Side of the faction that has planned to do this*/
	VARIABLE_ATTR("side", [ATTR_SERIALIZABLE]);

	// /* variable: src
	// Where the action starts from */
	// VARIABLE_ATTR("src", [ATTR_SERIALIZABLE]);
	/* variable: posSrc
	Source position*/
	VARIABLE_ATTR("posSrc", [ATTR_SERIALIZABLE]);

	// /* variable: tgt
	// Where the action is going to */
	// VARIABLE_ATTR("tgt", [ATTR_SERIALIZABLE]);
	/* variable: posTgt
	Target position*/
	VARIABLE_ATTR("posTgt", [ATTR_SERIALIZABLE]);

	/* variable: garrison
	Garrison undertaking the action, if any */
	VARIABLE_ATTR("garrison", [ATTR_SERIALIZABLE]);

	/* variable: posCurrent
	Current position of the garrison that is executing this action. Commander should update it periodycally. */
	VARIABLE_ATTR("posCurrent", [ATTR_SERIALIZABLE]);

	/* variable: route
	The route that the vehicles or troops will follow. Format is yet unknown.*/
	VARIABLE_ATTR("route", [ATTR_SERIALIZABLE]);

	/* variable: transportMethod
	Transport method (ground/air/water). Format is yet unknown.*/
	VARIABLE_ATTR("transportMethod", [ATTR_SERIALIZABLE]);

	/* variable: dateDeparture
	Departure date*/
	VARIABLE_ATTR("dateDeparture", [ATTR_SERIALIZABLE]);

	/* variable: strength
	Strength of the units allocated for this job. Format is yet unknown.*/
	VARIABLE_ATTR("strength", [ATTR_SERIALIZABLE]);


	METHOD("clientAdd") {
		params [P_THISOBJECT];

		systemChat format ["Added intel: %1", _thisObject];

		// Hint
		hint format ["Added intel: %1", _thisObject];
	} ENDMETHOD;

ENDCLASS;

/*
Class: Intel.IntelCommanderActionReinforce
Intel about reinforcement commander action
*/
CLASS("IntelCommanderActionReinforce", "IntelCommanderAction")
	/* variable: srcGarrison
	The source garrison that sent the reinforcements. Probably players have no use to this.*/
	VARIABLE_ATTR("srcGarrison", [ATTR_SERIALIZABLE]);
	/* variable: tgtGarrison
	The destination garrison that will be reinforced. Probably players have no use to this.*/
	VARIABLE_ATTR("tgtGarrison", [ATTR_SERIALIZABLE]);
ENDCLASS;

/*
Class: Intel.IntelCommanderActionBuild
Intel about action to build something.
*/
CLASS("IntelCommanderActionBuild", "IntelCommanderAction")
	/* variable: type
	The type of object that will be built. Format is unknown now!*/
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);
ENDCLASS;

/*
Class: Intel.IntelCommanderActionAttack
Intel about action to attack something.
*/
CLASS("IntelCommanderActionAttack", "IntelCommanderAction")
	/* variable: srcGarrison
	The source garrison that sent the attack. Probably players have no use to this.*/
	VARIABLE_ATTR("srcGarrison", [ATTR_SERIALIZABLE]);
	/* variable: type
	The type of attack: QRF, basic attack, something else. IDK the formet of this now!*/
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("tgtGarrison", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("tgtLocation", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("tgtClusterId", [ATTR_SERIALIZABLE]);
ENDCLASS;

/*
Class: Intel.IntelCommanderActionRecon
The commander is planning something so he sends some recon squads!
*/
CLASS("IntelCommanderActionRecon", "IntelCommanderAction")

ENDCLASS;