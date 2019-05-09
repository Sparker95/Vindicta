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

	/* variable: timeCreated 
	Time when this intel was created initially*/
	VARIABLE_ATTR("timeCreated", [ATTR_SERIALIZABLE]); 

	/* variable: timeUpdated 
	Time when this intel was updated*/
	VARIABLE_ATTR("timeUpdated", [ATTR_SERIALIZABLE]);

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

	/*
	Method: new
	Constructor. Takes no arguments.
	*/
	METHOD("new") {
		params ["_thisObject"];
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

	/* variable: allMapMarker
	<MapMarker> associated with this intel*/
	VARIABLE("mapMarker"); // NOT SERIALIZABLE! Each machine has its own mapMarker

	METHOD("clientAdd") {
		params [P_THISOBJECT];

		private _mrk = NEW("MapMarkerLocation", [_thisObject]);
		T_SETV("mapMarker", _mrk);

		// Set/update marker properties
		CALL_STATIC_METHOD("IntelLocation", "setLocationMarkerProperties", [_mrk ARG _thisObject]);

		pr _loc = T_GETV("location");
		pr _pos = T_GETV("pos");
		OOP_INFO_2("Added location intel to client: %1, %2", _loc, _pos);

		// Hint
		hint "Location data was added";
	} ENDMETHOD;

	METHOD("clientUpdate") {
		params [P_THISOBJECT];

		private _mrk = T_GETV("mapMarker");
		CALL_STATIC_METHOD("IntelLocation", "setLocationMarkerProperties", [_mrk ARG _thisObject]);

		// Hint
		hint "Location data was updated";
	} ENDMETHOD;

	STATIC_METHOD("setLocationMarkerProperties") {
		params ["_thisClass", ["_mapMarker", "", [""]], ["_intel", "", [""]]];
		pr _type = GETV(_intel, "type");
		pr _pos = GETV(_intel, "pos");
		pr _side = GETV(_intel, "side");
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

		CALLM1(_mapMarker, "setPos", _pos);
		CALLM1(_mapMarker, "setText", _text);
		CALLM1(_mapMarker, "setColor", _color);
	} ENDMETHOD;

ENDCLASS;