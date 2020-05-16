#include "common.hpp"
FIX_LINE_NUMBERS()
/*
Class: GarrisonRecord
Client-side representation of a garrison.

Author: Sparker 23 August 2019
*/

#define pr private

#define OOP_CLASS_NAME GarrisonRecord
CLASS("GarrisonRecord", "")

	// Ref to the actual garrison, which exists only on the server
	VARIABLE_ATTR("garRef", [ATTR_SERIALIZABLE]);

	// Generic properties
	VARIABLE_ATTR("type", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("side", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("pos", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("location", [ATTR_SERIALIZABLE]);

	// Amount of build resources (number)
	VARIABLE_ATTR("buildResources", [ATTR_SERIALIZABLE]);

	// Serialized CmdrActionRecord object
	VARIABLE_ATTR("cmdrActionRecordSerial", [ATTR_SERIALIZABLE]);

	// Array with composition (like Garrison.compositionClassNames)
	VARIABLE_ATTR("composition", [ATTR_SERIALIZABLE]);

	// Ref to the map marker object, local on client side
	VARIABLE("mapMarker");

	// The actual commander action, deserialized on client side
	VARIABLE("cmdrActionRecord");
	

	// What else did I forget?
	
	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("cmdrActionRecord", "");
	ENDMETHOD;

	METHOD(delete)

	ENDMETHOD;

	// Returns the garrison reference of the actual garrison
	METHOD(getGarrison)
		params [P_THISOBJECT];
		T_GETV("garRef")
	ENDMETHOD;

	// Returns location's position when attached to location
	// returns pure garrison position otherwise
	METHOD(getPos)
		params [P_THISOBJECT];
		pr _loc = T_GETV("location");
		pr _attachedToLocation = (_loc != "");

		if (_attachedToLocation && !(IS_NULL_OBJECT(_loc))) then {
			pr _locPos = CALLM0(_loc, "getPos");
			_locPos
		} else {
			T_GETV("pos")
		};
	ENDMETHOD;

	METHOD(getComposition)
		params [P_THISOBJECT];
		T_GETV("composition")
	ENDMETHOD;

	METHOD(getBuildResources)
		params [P_THISOBJECT];
		T_GETV("buildResources")
	ENDMETHOD;

	// Fills data fields from a garrison object
	METHOD(initFromGarrison)
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		T_SETV("garRef", _gar);

		// Accessing data without proper interfaces now
		// This is probably not so bad??
		// todo need to rethink it probably...
		pr _AI = GETV(_gar, "AI");
		T_SETV("pos", CALLM0(_AI, "getPos"));
		T_SETV("type", GETV(_gar, "type"));
		T_SETV("side", GETV(_gar, "side"));
		T_SETV("composition", GETV(_gar, "compositionClassNames"));
		T_SETV("cmdrActionRecordSerial", GETV(_AI, "cmdrActionRecordSerial"));
		T_SETV("buildResources", CALLM0(_gar, "getBuildResources"));
		T_SETV("location", GETV(_gar, "location"));
	ENDMETHOD;


	// - - - - Client-side functions - - - -

	// Updates the main map marker at the position of the garrison
	METHOD(_updateMapMarker)
		params [P_THISOBJECT];

		pr _mapMarker = T_GETV("mapMarker");
		pr _pos = T_CALLM0("getPos"); // !! Returns location position if attached to a location

		// Set properties...
		CALLM1(_mapMarker, "setSide", T_GETV("side"));
		CALLM1(_mapMarker, "setText", "");
		CALLM1(_mapMarker, "setPos", _pos);

		// Show if NOT attached to a location
		CALLM1(_mapMarker, "show", T_GETV("location") == "");
	ENDMETHOD;

	// Updates the map markers of the action (line, pointer, etc)
	#define __MRK_LINE "_line"
	#define __MRK_END "_end"
	METHOD(_updateActionMapMarkers)
		params [P_THISOBJECT];

		// Delete previous map markers
		pr _mrkLine = _thisObject + __MRK_LINE;
		pr _mrkEnd = _thisObject + __MRK_END;
		deleteMarkerLocal _mrkLine;
		deleteMarkerLocal _mrkEnd;

		// Create them again if needed
		pr _record = T_GETV("cmdrActionRecord");
		if (_record != "") then {
			// Create line
			pr _posStart = T_GETV("pos");
			pr _recordClass = GET_OBJECT_CLASS(_record);
			
			pr _actionText = CALLSM0(_recordClass, "getText"); // A friendly text of this action: "Attack", "Patrol", etc

			if (_recordClass in ["MoveCmdrActionRecord", "TakeLocationCmdrActionRecord", "AttackCmdrActionRecord", "ReinforceCmdrActionRecord"]) then {
				// Draw a line
				pr _posEnd = CALLM0(_record, "getPos"); // It will resolve position of position, location or garrison

				if (count _posEnd == 0) then {
					// Print an error? CmdrActionRecord already prints an error
				} else {
					pr _color = "colorRed"; // [T_GETV("side"), true] call BIS_fnc_sideColor;
					[_posStart, _posEnd, _color, 8, _mrkLine] call misc_fnc_mapDrawLineLocal;
					_mrkLine setMarkerBrushLocal "SolidFull";
					_mrkLine setMarkerAlphaLocal 1.0;

					// Draw one marker at destination
					createMarkerLocal [_mrkEnd, _posEnd];
					_mrkEnd setMarkerShapeLocal "ICON";
					//_mrkEnd setMarkerPosLocal ([100, 100, 0]);
					_mrkEnd setMarkerTypeLocal "mil_dot";
					//_mrkEnd setMarkerTextLocal _actionText;
					_mrkEnd setMarkerColorLocal "colorRed";
					_mrkEnd setMarkerAlphaLocal 1.0;
					_mrkEnd setMarkerSizeLocal [1.5, 1.5];
				};
			} else {
				// NYI, patrols are not supported yet
			};

			// Set text of the garrison marker
			CALLM1(T_GETV("mapMarker"), "setText", format ["%1" ARG _actionText]);
		};
	ENDMETHOD;

	METHOD(_removeActionMapMarkers)
		params [P_THISOBJECT];
		pr _mrkLine = _thisObject + __MRK_LINE;
		pr _mrkEnd = _thisObject + __MRK_END;
		deleteMarkerLocal _mrkLine;
		deleteMarkerLocal _mrkEnd;
	ENDMETHOD;



	// Initializes this object on the client side 
	METHOD(clientAdd)
		params [P_THISOBJECT];

		// Deserialize the commander action record
		pr _actionRecordSerial = T_GETV("cmdrActionRecordSerial");
		if (count _actionRecordSerial == 0) then {
			// [] means there is no current action
			T_SETV("cmdrActionRecord", "");
		} else {
			pr _actionRecordClass = SERIALIZED_CLASS_NAME(_actionRecordSerial);
			pr _actionRecord = NEW(_actionRecordClass, []);
			DESERIALIZE(_actionRecord, _actionRecordSerial);
			T_SETV("cmdrActionRecord", _actionRecord);
		};

		// Create the map marker
		pr _mapMarker = NEW("MapMarkerGarrison", [_thisObject]);
		T_SETV("mapMarker", _mapMarker);
		T_CALLM0("_updateMapMarker");
		T_CALLM0("_updateActionMapMarkers");

		// Update linked records if something was pointing at this garrison record
		T_CALLM0("_updateLinkedRecords");
	ENDMETHOD;

	// Check if any linked garrison records were pointing at this and update them too
	METHOD(_updateLinkedRecords)
		params [P_THISOBJECT];

		pr _linkedRecords = CALLM1(gGarrisonDBClient, "getLinkedGarrisonRecords", T_GETV("garRef"));
		{
			CALLM0(_x, "_updateMapMarker");
			CALLM0(_x, "_updateActionMapMarkers");
		} forEach _linkedRecords;
	ENDMETHOD;

	// Updates data in this object from another garrison record
	#define __TCOPYVAR(objNameStr, varNameStr) T_SETV(varNameStr, GETV(objNameStr, varNameStr)) // I love the preprocessor :3
	METHOD(clientUpdate)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		pr _posChanged = ! (T_GETV("pos") isEqualTo GETV(_garRecord, "pos") );

		__TCOPYVAR(_garRecord, "pos");
		__TCOPYVAR(_garRecord, "type");
		__TCOPYVAR(_garRecord, "side");
		__TCOPYVAR(_garRecord, "location");
		__TCOPYVAR(_garRecord, "composition");
		__TCOPYVAR(_garRecord, "cmdrActionRecordSerial");
		__TCOPYVAR(_garRecord, "buildResources");

		// Delete the old commander action record, if it existed
		pr _record = T_GETV("cmdrActionRecord");
		if (_record != "") then {DELETE(_record);};

		// Deserialize the commander action record
		pr _actionRecordSerial = T_GETV("cmdrActionRecordSerial");
		if (count _actionRecordSerial == 0) then {
			// [] means there is no current action
			T_SETV("cmdrActionRecord", "");
		} else {
			pr _actionRecordClass = SERIALIZED_CLASS_NAME(_actionRecordSerial);
			pr _actionRecord = NEW(_actionRecordClass, []);
			DESERIALIZE(_actionRecord, _actionRecordSerial);
			T_SETV("cmdrActionRecord", _actionRecord);
		};

		// Update map markers
		T_CALLM0("_updateMapMarker");
		T_CALLM0("_updateActionMapMarkers");

		// Update linked records if position has changed
		if (_posChanged) then {
			T_CALLM0("_updateLinkedRecords");
		};
		
	ENDMETHOD;

	// Must be called before deleting this on client
	METHOD(clientRemove)
		params [P_THISOBJECT];

		// Delete the map marker
		pr _mapMarker = T_GETV("mapMarker");
		DELETE(_mapMarker);

		// Clear up the map markers
		T_CALLM0("_removeActionMapMarkers");

		// Delete the action record
		pr _actionRecord = T_GETV("cmdrActionRecord");
		if (!isNil "_actionRecord") then {
			if (_actionRecord != "") then {
				DELETE(_actionRecord);
			};
		};

		// Notify the UI?
	ENDMETHOD;



ENDCLASS;