#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

//#define NAMESPACE uiNamespace

#include "..\..\OOP_Light\OOP_Light.h"

#include "..\Resources\MapUI\MapUI_Macros.h"
#include "..\Resources\ClientMapUI\ClientMapUI_Macros.h"

/*
Class: MapMarkerLocation
That's how we draw locations
*/

#define pr private

#define CLASS_NAME "MapMarkerLocation"

CLASS(CLASS_NAME, "MapMarker")

	VARIABLE("angle");
	VARIABLE("selected");
	VARIABLE("intel"); // Intel object associated with this
	VARIABLE("radius"); // The accuracy radius

	STATIC_VARIABLE("selectedLocationMarkers");

	METHOD("new") {
		params ["_thisObject", ["_intel", "", [""]]];
		CALLM2(_thisObject, "setEventSize", 20, 20);
		T_SETV("angle", 0);
		T_SETV("selected", false);
		T_SETV("intel", _intel);
		T_SETV("radius", 0);

		/*
		pr _radius = GETV(_intel, "accuracyRadius");
		if (isNil "_radius") then { _radius = 0; };
		_radius = 300;
		T_SETV("radius", _radius);
		CALLM0(_thisObject, "updateAccuracyRadiusMarker");
		*/
	} ENDMETHOD;

	METHOD("delete") {
		params ["_thisObject"];

	} ENDMETHOD;

	// Overwrite the base class method
	METHOD("setPos") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]]];

		CALL_CLASS_METHOD("MapMarker", _thisObject, "setPos", [_pos]);
		CALLM0(_thisObject, "updateAccuracyRadiusMarker");
	} ENDMETHOD;

	METHOD("setAccuracyRadius") {
		params ["_thisObject", "_radius"];

		T_SETV("radius", _radius);
		CALLM0(_thisObject, "updateAccuracyRadiusMarker");
	} ENDMETHOD;

	METHOD("updateAccuracyRadiusMarker") {
		params ["_thisObject"];

		pr _radius = T_GETV("radius");
		if (_radius == 0) then {
			deleteMarkerLocal _thisObject;
		} else {
			// Check if marker doesn't exist yet
			if (markerColor _thisObject == "") then {
				createMarkerLocal [_thisObject, T_GETV("pos")+[0]];
				_thisObject setMarkerSizeLocal [_radius, _radius];
				_thisObject setMarkerShapeLocal "ELLIPSE";
				_thisObject setMarkerBrushLocal "SolidBorder";
				_thisObject setMarkerColorLocal "colorCivilian";
			};
			_thisObject setMarkerPosLocal (T_GETV("pos")+[0]);
			pr _alpha = [0.3, 0.8] select T_GETV("selected");
			_thisObject setMarkerAlphaLocal _alpha;
		};
	} ENDMETHOD;

	METHOD("onDraw") {
		params ["_thisObject", "_control"];

		pr _pos = T_GETV("pos");

		//_control drawEllipse [_pos, 40, 40, 0, [0.8,0,0,1], "#(rgb,1,1,1)color(0,1,0,0.1)"];

		_control drawIcon
		[
			"\A3\ui_f\data\map\markers\military\circle_CA.paa",
			//"\A3\ui_f\data\map\mapcontrol\Bunker_CA.paa", // Texture   icon = "";
			T_GETV("color"), //Color
			_pos, // Pos
			20, // Width
			20, // Height
			0, // Angle
			"   " + T_GETV("text") // Text
		];

		if (T_GETV("selected")) then {
			pr _angle = T_GETV("angle");

			/*
			_control drawIcon
			[
				"\A3\ui_f\data\map\groupicons\selector_selectable_ca.paa",
				[1,0,0,1], //Color
				_pos, // Pos
				38, // Width
				38, // Height
				_angle, // Angle
				"" // Text
			];
			*/


			_control drawIcon
			[
				"\A3\ui_f\data\map\groupicons\selector_selectable_ca.paa",
				T_GETV("color"), //Color
				_pos, // Pos
				29, // Width
				29, // Height
				-_angle, // Angle
				"" // Text
			];


			T_SETV("angle", _angle + 20/diag_FPS);
		};

	} ENDMETHOD;

	/*
	Method: onMouseEnter
	Gets called when the mouse pointer enters the marker area.

	Returns: nil
	*/
	METHOD("onMouseEnter") {
		params ["_thisObject"];
		OOP_INFO_0("ENTER");
		//T_SETV("selected", true);
	} ENDMETHOD;

	/*
	Method: onMouseLeave
	Gets called when the mouse pointer leaves the marker area.

	Returns: nil
	*/
	METHOD("onMouseLeave") {
		params ["_thisObject"];
		OOP_INFO_0("LEAVE");
		//T_SETV("selected", false);
	} ENDMETHOD;

	/*
	Method: onMouseButtonDown
	Gets called when user pushes mouse button while over the marker

	Parameters: _button, _shift, _ctrl, _alt

	_button - 0 for LMB, 1 for RMB
	_shift, _ctrl, _alt -  BOOL

	Returns: nil
	*/
	METHOD("onMouseButtonDown") {
		params ["_thisObject", "_button", "_shift", "_ctrl", "_alt"];
		OOP_INFO_4("DOWN Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);

		// We only care about left mouse button events
		if (_button == 0) then {
			// Remove all selections if we push mouse button without Alt key
			if (!_alt) then {
				CALLSM(CLASS_NAME, "deselectAllMarkers", []);
			};

			pr _selectedMarkers = GET_STATIC_VAR(CLASS_NAME, "selectedLocationMarkers");
			_selectedMarkers pushBackUnique _thisObject;
			T_SETV("selected", true);

			// Update the accuracy radius marker's alpha
			if (T_GETV("radius") != 0) then {
				CALLM0(_thisObject, "updateAccuracyRadiusMarker");
			};

			// If only this marker is selected now
			if (count _selectedMarkers == 1) then {
				pr _intel = T_GETV("intel");
				CALL_STATIC_METHOD("ClientMapUI", "updateLocationDataPanel", [_intel]);
			} else {
				// Deselect everything
				CALL_STATIC_METHOD("ClientMapUI", "updateLocationDataPanel", [""]);
			};
		};
	} ENDMETHOD;

	/*
	Method: onMouseButtonUp
	Gets called when user releases mouse button while over the marker

	Parameters: _button, _shift, _ctrl, _alt

	_button - 0 for LMB, 1 for RMB
	_shift, _ctrl, _alt -  BOOL

	Returns: nil
	*/
	METHOD("onMouseButtonUp") {
		params ["_thisObject", "_button", "_shift", "_ctrl", "_alt"];
		// OOP_INFO_4("UP Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);
	} ENDMETHOD;

	/*
	Method: onMouseButtonClick
	Gets called when user clicks left mouse button at the marker

	Parameters: _shift, _ctrl, _alt

	_shift, _ctrl, _alt -  BOOL

	Returns: nil
	*/
	METHOD("onMouseButtonClick") {
		params ["_thisObject", "_shift", "_ctrl", "_alt"];
		// OOP_INFO_3("CLICK Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);

	} ENDMETHOD;

	STATIC_METHOD("deselectAllMarkers") {
		params ["_thisClass"];

		pr _selectedMarkers = GET_STATIC_VAR(CLASS_NAME, "selectedLocationMarkers");
		{
			SETV(_x, "selected", false);
			if (GETV(_x, "radius") != 0) then {
				CALLM0(_x, "updateAccuracyRadiusMarker");
			};
		} forEach _selectedMarkers;

		SET_STATIC_VAR(CLASS_NAME, "selectedLocationMarkers", []);
	} ENDMETHOD;

	STATIC_METHOD("onMouseClickElsewhere") {
		params ["_thisClass", "_button", "_shift", "_ctrl", "_alt"];

		if (_button == 0) then {
			CALLSM0(CLASS_NAME, "deselectAllMarkers");
			CALLSM0("ClientMapUI", "onMouseClickElsewhere");
		};
		
	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR(CLASS_NAME, "selectedLocationMarkers", []);

#ifndef _SQF_VM

[missionNamespace, "MapMarker_MouseButtonDown_none", {
	params ["_button", "_shift", "_ctrl", "_alt"];
	CALL_STATIC_METHOD(CLASS_NAME, "onMouseClickElsewhere", _this);
}] call BIS_fnc_addScriptedEventHandler;

/*
[missionNamespace, "MapMarker_MouseButtonClick_none", {
	params ["_button", "_shift", "_ctrl", "_alt"];
	CALL_STATIC_METHOD(CLASS_NAME, "onMouseClickElsewhere", _this);
}] call BIS_fnc_addScriptedEventHandler;
*/

// Make some test markers
/*
pr _testMarker = NEW("MapMarkerLocation", []);
pr _pos = [333, 333];
CALLM1(_testMarker, "setPos", _pos);
pr _color = [0, 0, 0.8, 1];
CALLM1(_testMarker, "setColor", _color);

pr _testMarker = NEW("MapMarkerLocation", []);
pr _pos = [666, 333];
CALLM1(_testMarker, "setPos", _pos);
pr _color = [0.8, 0, 0.8, 1];
CALLM1(_testMarker, "setColor", _color);

pr _testMarker = NEW("MapMarkerLocation", []);
pr _pos = [666, 666];
CALLM1(_testMarker, "setPos", _pos);
pr _color = [0, 0.8, 0.8, 1];
CALLM1(_testMarker, "setColor", _color);
*/


#endif