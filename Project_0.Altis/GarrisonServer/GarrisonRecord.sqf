#include "common.hpp"
/*
Class: GarrisonRecord
Client-side representation of a garrison.

Author: Sparker 23 August 2019
*/

#define pr private

CLASS("GarrisonRecord", "")

	// Ref to the actual garrison, which exists only on the server
	VARIABLE_ATTR("garRef", [ATTR_SERIALIZABLE]); 

	// Generic properties
	VARIABLE_ATTR("pos", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("side", [ATTR_SERIALIZABLE]);

	// Serialized CmdrActionRecord object
	VARIABLE_ATTR("cmdrActionRecordSerial", [ATTR_SERIALIZABLE]);

	// Array with composition
	VARIABLE_ATTR("composition", [ATTR_SERIALIZABLE]);

	// Ref to the map marker object, local on client side
	VARIABLE("mapMarker");

	// The actual commander action, deserialized on client side
	VARIABLE("cmdrActionRecord");

	// What else did I forget?
	
	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("cmdrActionRecord", "");
	} ENDMETHOD;

	METHOD("delete") {

	} ENDMETHOD;

	// Fills data fields from a garrison object
	METHOD("initFromGarrison") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		T_SETV("garRef", _gar);

		// Accessing data without proper interfaces now
		// This is probably not so bad??
		// todo need to rethink it probably...
		pr _AI = GETV(_gar, "AI");
		T_SETV("pos", CALLM0(_AI, "getPos"));
		T_SETV("side", GETV(_gar, "side"));
		T_SETV("composition", GETV(_gar, "composition"));
	} ENDMETHOD;


	// - - - - Client-side functions - - - -

	// Updates the main map marker at the position of the garrison
	METHOD("_updateMapMarker") {
		params [P_THISOBJECT];

		pr _mapMarker = T_GETV("mapMarker");
		CALLM1(_mapMarker, "setPos", T_GETV("pos"));
		CALLM1(_mapMarker, "setSide", T_GETV("side"));

	} ENDMETHOD;

	// Updates the map markers of the action (line, pointer, etc)
	#define __MRK_LINE "_line"
	#define __MRK_END "_ptr"
	METHOD("_updateActionMapMarkers") {
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
			
			if (_recordClass in ["MoveCmdrActionRecord", "TakeLocationCmdrActionRecord", "QRFCmdrActionRecord", "ReinforceCmdrActionRecord"]) then {
				// Draw a line
				pr _posEnd = CALLM0(_record, "getPos"); // It will resolve position of position, location or garrison
				pr _mrkText = CALLSM0(_recordClass, "getText");
				pr _color = "colorRed"; // [T_GETV("side"), true] call BIS_fnc_sideColor;
				[_posStart, _posEnd, _color, 15, _mrkEnd] call misc_fnc_mapDrawLineLocal;

				// Draw one marker at destination
				createMarkerLocal [_mrkEnd, _posEnd];
				_mrkEnd setMarkerShapeLocal "ICON";
				//_mrkEnd setMarkerPosLocal ([100, 100, 0]);
				_mrkEnd setMarkerAlphaLocal 1;
				_mrkEnd setMarkerType "waypoint";
				_mrkEnd setMarkerText _mrkText;

				// 
				private _mrk = CALLM0(T_GETV("mapMarker"), "getMarker");
				_mrk setMarkerTextLocal "<Garrison on patrol>";
			} else {
				// NYI, patrols are not supported yet
				// Just set marker text
				private _mrk = CALLM0(T_GETV("mapMarker"), "getMarker");
				_mrk setMarkerTextLocal "<Garrison on patrol>";
			};

		};
	} ENDMETHOD;

	// Initializes this object on the client side 
	METHOD("clientAdd") {
		params [P_THISOBJECT];

		// Create the map marker
		pr _mapMarker = NEW("MapMarkerGarrison", []);
		T_SETV("mapMarker", _mapMarker);
		T_CALLM0("_updateMapMarker");

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

	} ENDMETHOD;

	// Updates data in this object from another garrison record
	#define __TCOPYVAR(objNameStr, varNameStr) T_SETV(varNameStr, GETV(objNameStr, varNameStr)) // I love the preprocessor :3
	METHOD("clientUpdate") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		__TCOPYVAR(_garRecord, "pos");
		__TCOPYVAR(_garRecord, "side");
		__TCOPYVAR(_garRecord, "composition");

		// Update map marker properties
		T_CALLM0("_updateMapMarker");
		T_CALLM0("_updateActionMapMarkers");
		
	} ENDMETHOD;

	// Must be called before deleting this on client
	METHOD("clientRemove") {
		params [P_THISOBJECT];

		// Delete the map marker
		pr _mapMarker = T_GETV("mapMarker");
		DELETE(_mapMarker);

		// Delete the action record
		pr _actionRecord = T_GETV("cmdrActionRecord");
		if (!isNil "_actionRecord") then {
			DELETE(_actionRecord);
		};

		// Notify the UI?
	} ENDMETHOD;



ENDCLASS;