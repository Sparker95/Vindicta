#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
//#define NAMESPACE uiNamespace
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\AI\Commander\LocationData.hpp"


/*
Class: ClientMapUI
Singleton class that performs things related to map user interface
*/

#define CLASS_NAME "ClientMapUI"
#define pr private

// Common colors
CMUI_ColorWEST = [0,0.3,0.6,1];
CMUI_ColorEAST = [0.5,0,0,1];
CMUI_ColorIND = [0,0.5,0,1];

CLASS(CLASS_NAME, "")

	STATIC_VARIABLE("locationDataWest"); // What client's side knows about West knowledge about locations
	STATIC_VARIABLE("locationDataEast");
	STATIC_VARIABLE("locationDataInd");
	
	STATIC_METHOD("updateLocationData") {
		params [["_thisObject", "", [""]], ["_locationData", [], [[]]], ["_side", CIVILIAN]];
		
		OOP_INFO_0("UPDATE LOCATION DATA");
		OOP_INFO_1("location data: %1", _locationData);
		OOP_INFO_2("side: %1   didJip: %2", _side, didJIP);
		
		
		pr _varName = switch (_side) do {
			case WEST: {"locationDataWest"};
			case EAST: {"locationDataEast"};
			case INDEPENDENT: {"locationDataInd"};
			default {"ERROR_UNKNOWN_SIDE"};
		};
		pr _ldOld = GET_STATIC_VAR(CLASS_NAME, _varName);
		
		//Move references for MapMarkers from old location data to new location data
		{ // foreach _ldOld
			pr _oldPos = _x select CLD_ID_POS;
			pr _index = _locationData findIf {
				pr _newPos = _x select CLD_ID_POS;
				_oldPos isEqualTo _newPos
			};
			// If location exists both in new and old array
			if (_index != -1) then {
				pr _mrk = _x select CLD_ID_MARKER;
				(_locationData select _index) set [CLD_ID_MARKER, _mrk];
			} else {
				// If location doesn't exist in new array, delete its marker
				DELETE(_mrk);
			};
		} forEach _ldOld;
		
		// Now create new markers for locations that are added right now
		{
			pr _mrk = _x select CLD_ID_MARKER;
			if (_mrk == "") then {
				_mrk = NEW("MapMarkerLocation", []);						
				_x set [CLD_ID_MARKER, _mrk];
			};
			
			// Set/update marker properties
			pr _args = [_mrk, _x];
			CALL_STATIC_METHOD(CLASS_NAME, "setLocationMarkerProperties", _args);
		} forEach _locationData;
		
		SET_STATIC_VAR(CLASS_NAME, _varName, _locationData);
	} ENDMETHOD;
	
	// Sets text, color, position, and other properties of a marker attached to certain location
	STATIC_METHOD("setLocationMarkerProperties") {
		params ["_thisClass", ["_mapMarker", "", [""]], ["_cld", [], [[]]]];
		pr _type = _cld select CLD_ID_TYPE;
		pr _pos = _cld select CLD_ID_POS;
		pr _side = _CLD select CLD_ID_SIDE;
		pr _color = switch(_side) do {
			case WEST: {CMUI_ColorWEST};
			case EAST: {CMUI_ColorEAST};
			case INDEPENDENT: {CMUI_ColorInd};
		};
		
		CALLM1(_mapMarker, "setPos", _pos);
		pr _text = format ["%1 outpost", _side];
		CALLM1(_mapMarker, "setText", _text);
		CALLM1(_mapMarker, "setColor", _color);
	} ENDMETHOD;

ENDCLASS;

// Initialize static variable values
{
	// Make sure we don't override a JIP value
	pr _val = GET_STATIC_VAR(CLASS_NAME, _x);
	if (isNil "_val") then {
		SET_STATIC_VAR(CLASS_NAME, _x, []);
	};
} forEach ["locationDataWest", "locationDataEast", "locationDataInd"];

