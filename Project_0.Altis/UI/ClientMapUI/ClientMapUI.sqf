#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG
//#define NAMESPACE uiNamespace
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\Resources\ClientMapUI\ClientMapUI_Macros.h"
#include "..\..\Location\Location.hpp"


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
CMUI_ColorUnknown = [0.4,0,0.5,1];

CLASS(CLASS_NAME, "")

	// Arrays of LOCATION_DATA structures
	STATIC_VARIABLE("locationDataWest"); // What client's side knows about West knowledge about locations
	STATIC_VARIABLE("locationDataEast");
	STATIC_VARIABLE("locationDataInd");

	STATIC_METHOD("updateLocationData") {
		params [["_thisObject", "", [""]], ["_locationData", [], [[]]], ["_side", CIVILIAN]];

	} ENDMETHOD;

	// Sets text, color, position, and other properties of a marker attached to certain location
	STATIC_METHOD("setLocationMarkerProperties") {
		params ["_thisClass", ["_mapMarker", "", [""]], ["_cld", [], [[]]]];


	} ENDMETHOD;

	STATIC_METHOD("getLocationData") {
		params ["_thisClass", ["_pos", [], [[]]], ["_side", CIVILIAN]];

	} ENDMETHOD;

	// Formats location data and shows it on the location data panel
	STATIC_METHOD("updateLocationDataPanel") {
		params ["_thisClass", ["_pos", [], [[]]]];

		
	} ENDMETHOD;

	STATIC_METHOD("showLocationDataPanel") {
		params ["_thisClass", ["_show", true]];

	} ENDMETHOD;

	// Returns marker text of closest marker
	STATIC_METHOD("getNearestLocationName") {
		params ["_thisClass", "_pos"];
		pr _return = "";

		{
     		if(((getPos _x) distance _pos) < 100) exitWith {
          		_return =  _x getVariable ["Name", ""];
     		};
		} forEach entities "Project_0_LocationSector";

		_return
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

