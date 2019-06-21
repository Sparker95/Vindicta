#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

//#define NAMESPACE uiNamespace

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Location\Location.hpp"

#include "..\Resources\MapUI\MapUI_Macros.h"
#include "..\Resources\ClientMapUI\ClientMapUI_Macros.h"

/*
Class: MapMarkerLocation
That's how we draw locations
*/

#define pr private

#define CLASS_NAME "MapMarkerLocation"

#define RADIUS_MARKER_SUFFIX "_rad"
#define MARKER_SUFFIX "_mrk"
#define NOTIFICATION_SUFFIX "_not"

CLASS(CLASS_NAME, "MapMarker")

	VARIABLE("angle");
	VARIABLE("selected");
	VARIABLE("intel"); // Intel object associated with this
	VARIABLE("radius"); // The accuracy radius
	VARIABLE("type");
	VARIABLE("notification"); // Bool

	STATIC_VARIABLE("selectedLocationMarkers");

	STATIC_VARIABLE("all");

	METHOD("new") {
		params ["_thisObject", ["_intel", "", [""]]];
		CALLM2(_thisObject, "setEventSize", 20, 20);
		T_SETV("angle", 0);
		T_SETV("selected", false);
		T_SETV("intel", _intel);
		T_SETV("radius", 0);

		// Create marker
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		createMarkerLocal [_mrkName, T_GETV("pos")+[0]];
		_mrkName setMarkerShapeLocal "ICON";
		_mrkName setMarkerColorLocal "colorCivilian";
		_mrkName setMarkerPosLocal (T_GETV("pos")+[0]);
		_mrkName setMarkerAlphaLocal 1.0;

		// Create notification marker
		pr _mrkName = _thisObject+NOTIFICATION_SUFFIX;
		createMarkerLocal [_mrkName, T_GETV("pos")+[0]];
		_mrkName setMarkerShapeLocal "ICON";
		_mrkName setMarkerColorLocal "ColorRed";
		_mrkName setMarkerPosLocal (T_GETV("pos")+[0]);
		_mrkName setMarkerAlphaLocal 1.0;
		_mrkName setMarkerType "p0_notification_top_right";

		GET_STATIC_VAR(CLASS_NAME, "all") pushBack _thisObject;

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

		// Delete markers
		{
			deleteMarkerLocal (_thisObject + _x);
		} forEach [MARKER_SUFFIX, RADIUS_MARKER_SUFFIX, NOTIFICATION_SUFFIX];

		// Delete from 'all' array
		pr _all = GET_STATIC_VAR(CLASS_NAME, "all");
		_all deleteAt (_all find _thisObject);

	} ENDMETHOD;

	// Overwrite the base class method
	METHOD("setPos") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]]];

		// Call base class method
		CALL_CLASS_METHOD("MapMarker", _thisObject, "setPos", [_pos]);

		// Update the accuracy marker
		CALLM0(_thisObject, "updateAccuracyRadiusMarker");

		// Set marker position
		{
			(_thisObject+_x) setMarkerPosLocal (T_GETV("pos")+[0]);
		} forEach [MARKER_SUFFIX, NOTIFICATION_SUFFIX];

	} ENDMETHOD;

	// Same as setColor but gets both an array and string
	METHOD("setColorEx") {
		params ["_thisObject", ["_colorRGBA", [], [[]]], ["_colorString", "", [""]]];
		T_SETV("color", _colorRGBA);

		// Set color of the associated marker
		_mrkName = _thisObject+MARKER_SUFFIX;
		_mrkName setMarkerColorLocal _colorString;
	} ENDMETHOD;

	METHOD("setAccuracyRadius") {
		params ["_thisObject", "_radius"];

		T_SETV("radius", _radius);
		CALLM0(_thisObject, "updateAccuracyRadiusMarker");
	} ENDMETHOD;

	// One of location types defined in location.hpp
	METHOD("setType") {
		params ["_thisObject", ["_type", "", [""]]];

		pr _mrkName = _thisObject+MARKER_SUFFIX;

		pr _type0 = "mil_destroy";
		pr _size = 1;

		switch (_type) do {
			case LOCATION_TYPE_CITY: {
				_type0 = "loc_Tourism";
				_size = 2;
			};

			case LOCATION_TYPE_UNKNOWN: {
				_type0 = "mil_unknown";
			};

			// The rest are military places
			default {
				_type0 = "n_unknown";
			};
		};

		_mrkName setMarkerTypeLocal _type0;
		_mrkName setMarkerSizeLocal [_size, _size];
	} ENDMETHOD;

	METHOD("setNotification") {
		params ["_thisObject", ["_enable", false, [false]]];

		(_thisObject + NOTIFICATION_SUFFIX) setMarkerAlpha ([0, 1] select _enable);
	} ENDMETHOD;

	METHOD("updateAccuracyRadiusMarker") {
		params ["_thisObject"];

		pr _radius = T_GETV("radius");
		if (_radius == 0) then {
			deleteMarkerLocal _thisObject;
		} else {
			// Check if marker doesn't exist yet
			pr _mrkName = _thisObject+RADIUS_MARKER_SUFFIX;
			if (markerColor _thisObject == "") then {
				createMarkerLocal [_mrkName, T_GETV("pos")+[0]];
				_mrkName setMarkerSizeLocal [_radius, _radius];
				_mrkName setMarkerShapeLocal "ELLIPSE";
				_mrkName setMarkerBrushLocal "SolidBorder";
				_mrkName setMarkerColorLocal "colorCivilian";
			};
			_mrkName setMarkerPosLocal (T_GETV("pos")+[0]);
			pr _alpha = [0.3, 0.8] select T_GETV("selected");
			_mrkName setMarkerAlphaLocal _alpha;
		};
	} ENDMETHOD;

	METHOD("onDraw") {
		params ["_thisObject", "_control"];

		//pr _pos = T_GETV("pos");

		//_control drawEllipse [_pos, 40, 40, 0, [0.8,0,0,1], "#(rgb,1,1,1)color(0,1,0,0.1)"];

		/*
		// Main icon
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
		*/

		if (T_GETV("selected")) then {
			pr _angle = T_GETV("angle");
			pr _pos = T_GETV("pos");

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
				[1.0, 0, 0, 1], //Color
				_pos, // Pos
				41, // Width
				41, // Height
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

				// Disable the notification
				CALLM1(_thisObject, "setNotification", false);
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
				CALL_STATIC_METHOD("ClientMapUI", "onMapMarkerMouseButtonDown", [_thisObject ARG _intel]);
			} else {
				// Deselect everything
				CALL_STATIC_METHOD("ClientMapUI", "onMapMarkerMouseButtonDown", ["" ARG ""]);
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

	// Enables/disabled notification dots on all icons
	STATIC_METHOD("setAllNotifications") {
		params ["_thisClass", ["_enable", false, [false]]];
		{
			CALLM1(_x, "setNotification", _enable);
		} forEach GET_STATIC_VAR(_thisClass, "all");
	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR(CLASS_NAME, "selectedLocationMarkers", []);
SET_STATIC_VAR(CLASS_NAME, "all", []);

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