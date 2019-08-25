#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#include "..\..\OOP_Light\OOP_Light.h"

#include "..\Resources\MapUI\MapUI_Macros.h"
#include "..\Resources\ClientMapUI\ClientMapUI_Macros.h"

/*
Class: MapMarkerGarrison
That's how we draw garrisons
*/

#define CLASS_NAME "MapMarkerGarrison"

#define MARKER_SUFFIX "_mrk"

#define pr private

CLASS(CLASS_NAME, "MapMarker")

	VARIABLE("selected");

	STATIC_VARIABLE("selectedMarkers");
	//STATIC_VARIABLE("all");

	METHOD("new") {
		params [P_THISOBJECT];

		// Create marker
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		createMarkerLocal [_mrkName, [100, 100, 0]];
		_mrkName setMarkerShapeLocal "ICON";
		_mrkName setMarkerPosLocal ([100, 100, 0]);
		_mrkName setMarkerAlphaLocal 0.85;
		_mrkName setMarkerTypeLocal "b_unknown";
		_mrkName setMarkerTextLocal "<Garrison>";

	} ENDMETHOD;

	METHOD("delete") {

		deleteMarkerLocal _thisObject+MARKER_SUFFIX;
	} ENDMETHOD;

	METHOD("setSide") {
		params [P_THISOBJECT, P_SIDE("_side")];
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		_mrkName setMarkerColorLocal ([_side, true] call BIS_fnc_sideColor);
	} ENDMETHOD;

	METHOD("setPos") {
		params [P_THISOBJECT, P_POSITION("_pos")];		
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		_mrkName setMarkerPosLocal _pos;

		// Call base class method
		CALL_CLASS_METHOD("MapMarker", _thisObject, "setPos", [_pos]);
	} ENDMETHOD;

	METHOD("onDraw") {
		params ["_thisObject", "_control"];

		// Draw a surrounding icon if selected
		if (T_GETV("selected")) then {
			pr _pos = T_GETV("pos");
			_control drawIcon
			[
				"\A3\ui_f\data\map\groupicons\selector_selectable_ca.paa",
				[1.0, 0.5, 0, 1], //Color
				_pos, // Pos
				41, // Width
				41, // Height
				0, // Angle
				"" // Text
			];
		};
	} ENDMETHOD;

	METHOD("getMarker") {
		params [P_THISOBJECT];
		_thisObject+MARKER_SUFFIX
	} ENDMETHOD;


	// - - - - - - - Event handlers - - - - - - -

	METHOD("onMouseButtonDown") {
		params ["_thisObject", "_button", "_shift", "_ctrl", "_alt"];
		OOP_INFO_4("DOWN Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);

		// We only care about left mouse button events
		if (_button == 0) then {
			// Remove all selections if we push mouse button without Alt key
			if (!_alt) then {
				CALLSM(CLASS_NAME, "deselectAllMarkers", []);
			};

			pr _selectedMarkers = GET_STATIC_VAR(CLASS_NAME, "selectedMarkers");
			_selectedMarkers pushBackUnique _thisObject;
			T_SETV("selected", true);

			// If only this marker is selected now
			if (count _selectedMarkers == 1) then {
				
			} else {

			};
		};
	} ENDMETHOD;

	METHOD("onMouseButtonUp") {
		params ["_thisObject", "_button", "_shift", "_ctrl", "_alt"];
		// OOP_INFO_4("UP Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);
	} ENDMETHOD;

	METHOD("onMouseButtonClick") {
		params ["_thisObject", "_shift", "_ctrl", "_alt"];
		// OOP_INFO_3("CLICK Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);

	} ENDMETHOD;

	STATIC_METHOD("onMouseClickElsewhere") {
		params ["_thisClass", "_button", "_shift", "_ctrl", "_alt"];

		if (_button == 0) then {
			CALLSM0(CLASS_NAME, "deselectAllMarkers");
		};
		
	} ENDMETHOD;

	STATIC_METHOD("deselectAllMarkers") {
		params ["_thisClass"];

		pr _selectedMarkers = GET_STATIC_VAR(_thisClass, "selectedMarkers");
		{
			SETV(_x, "selected", false);
		} forEach _selectedMarkers;

		SET_STATIC_VAR(CLASS_NAME, "selectedMarkers", []);
	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR(CLASS_NAME, "selectedMarkers", []);
//SET_STATIC_VAR(CLASS_NAME, "all", []);

#ifndef _SQF_VM

[missionNamespace, "MapMarker_MouseButtonDown_none", {
	params ["_button", "_shift", "_ctrl", "_alt"];
	CALL_STATIC_METHOD(CLASS_NAME, "onMouseClickElsewhere", _this);
}] call BIS_fnc_addScriptedEventHandler;

#endif