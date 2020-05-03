#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

//#define NAMESPACE uiNamespace

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"
#include "..\..\Location\Location.hpp"

#include "..\Resources\MapUI\MapUI_Macros.h"
#include "..\ClientMapUI\ClientMapUI_Macros.h"

/*
Class: MapMarkerLocation
That's how we draw locations
*/

#define pr private

#define RADIUS_MARKER_SUFFIX "_rad"
#define MARKER_SUFFIX "_mrk"
#define NOTIFICATION_SUFFIX "_not"
#define BG_SUFFIX "_bg"

#define CLASS_NAME "MapMarkerLocation"
#define OOP_CLASS_NAME MapMarkerLocation
CLASS("MapMarkerLocation", "MapMarker")

	VARIABLE("angle");
	VARIABLE("selected");
	VARIABLE("mouseOver");
	VARIABLE("intel"); // Intel object associated with this
	VARIABLE("radius"); // The accuracy radius
	VARIABLE("type");
	VARIABLE("notification"); // Bool

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];
		T_SETV("angle", 0);
		T_SETV("selected", false);
		T_SETV("mouseOver", false);
		T_SETV("intel", _intel);
		T_SETV("radius", 0);
		T_SETV("notification", false);

		// Create background marker
		// We will colorize it
		pr _mrkName = _thisObject + BG_SUFFIX;
		createMarkerLocal [_mrkName, T_GETV("pos")+[0]];
		_mrkName setMarkerShapeLocal "ICON";
		//_mrkName setMarkerColorLocal "colorCivilian";
		_mrkName setMarkerPosLocal (T_GETV("pos")+[0]);
		_mrkName setMarkerAlphaLocal 1.0;
		_mrkName setMarkerTypeLocal "vin_location_background";

		// Create marker
		// This is the marker with the icon itself
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		createMarkerLocal [_mrkName, T_GETV("pos")+[0]];
		_mrkName setMarkerShapeLocal "ICON";
		_mrkName setMarkerColorLocal "ColorWhite"; // Colorized marker icon on white bg 
		_mrkName setMarkerPosLocal (T_GETV("pos")+[0]);
		//_mrkName setMarkerAlphaLocal ALPHA_NOT_SELECTED;

		// Create notification marker
		pr _mrkName = _thisObject+NOTIFICATION_SUFFIX;
		createMarkerLocal [_mrkName, T_GETV("pos")+[0]];
		_mrkName setMarkerShapeLocal "ICON";
		//_mrkName setMarkerColorLocal "ColorRed";
		_mrkName setMarkerColorLocal "ColorWhite"; // It's colored already
		_mrkName setMarkerPosLocal (T_GETV("pos")+[0]);
		//_mrkName setMarkerAlphaLocal 1.0;
		_mrkName setMarkerTypeLocal "vin_notification_top_right_exclamation";


		T_CALLM1("select", false);
		T_CALLM1("setNotification", false);

		/*
		pr _radius = GETV(_intel, "accuracyRadius");
		if (isNil "_radius") then { _radius = 0; };
		_radius = 300;
		T_SETV("radius", _radius);
		T_CALLM0("updateAccuracyRadiusMarker");
		*/
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// Delete markers
		{
			deleteMarkerLocal (_thisObject + _x);
		} forEach [MARKER_SUFFIX, RADIUS_MARKER_SUFFIX, NOTIFICATION_SUFFIX, BG_SUFFIX];

	ENDMETHOD;

	// Sets the "mouse over" state of this object
	METHOD(setMouseOver)
		params [P_THISOBJECT, P_BOOL("_mouseOver")];

		OOP_INFO_1("SET MOUSE OVER: %1", _mouseOver);

		T_SETV("mouseOver", _mouseOver);
		T_CALLM0("update");
	ENDMETHOD;

	METHOD(select)
		params [P_THISOBJECT, P_BOOL("_selected")];

		// Reset notification if we have selected it
		if (_selected) then {
			T_CALLM1("setNotification", false);
		};

		T_SETV("selected", _selected);
		T_CALLM0("update");

		// Call the base class method
		CALL_CLASS_METHOD("MapMarker", _thisObject, "select", [_selected]);
	ENDMETHOD;

	// Updates markers according to various states
	METHOD(update)
		params [P_THISOBJECT];
		pr _selected = T_GETV("selected");
		pr _mouseOver = T_GETV("mouseOver");
		pr _shown = T_GETV("shown");

		// Overall state of the button
		pr _state = ([0, 2] select _selected) + ([0, 1] select _mouseOver);
		/*
		0 - idle
		1 - mouse is over
		2 - selected
		3 - selected and mouse is over
		*/

		OOP_INFO_1("UPDATE state: %1", _state);

		pr _size = 1;
		pr _alpha = 0.5;
		pr _iconColor = "";
		if (_shown) then {
			switch (_state) do {
				case 0: { // Idle
					_alpha = 0.7;
					_size = 0.7;
					_iconColor = "ColorWhite";
				};
				case 1: { // Mouse is over
					_alpha = 1.0;
					_size = 1.0;
					_iconColor = "ColorWhite";
				};
				case 2: { // Selected
					_alpha = 1.0;
					_size = 1.0;
					_iconColor = "ColorBlack";

				};
				case 3: { // Selected and mouse is over
					_alpha = 1.0;
					_size = 1.0;
					_iconColor = "ColorBlack";
				};
			};
		} else {
			// Marker is not shown
			_alpha = 0;
			_size = 0.7;
			_iconColor = "ColorWhite";
		};

		pr _mrkBG = _thisObject + BG_SUFFIX;
		pr _mrkIcon = _thisObject + MARKER_SUFFIX;

		/*
		! ! ! ! ! ! ! ! ! ! ! !
		Make sure you only use setMarkerSomethingLOCAL commands!
		Make sure you only use setMarkerSomethingLOCAL commands!
		Make sure you only use setMarkerSomethingLOCAL commands!
		! ! ! ! ! ! ! ! ! ! ! ! 
		*/

		// Background
		_mrkBG setMarkerSizeLocal [_size, _size];
		_mrkBG setMarkerAlphaLocal _alpha;

		// Icon
		_mrkIcon setMarkerSizeLocal [_size, _size];
		_mrkIcon setMarkerAlphaLocal _alpha;
		_mrkIcon setMarkerColorLocal _iconColor;

		// Enable/disable the notification
		if (_shown) then {
			(_thisObject + NOTIFICATION_SUFFIX) setMarkerAlphaLocal ([0, 1] select T_GETV("notification"));
		} else {
			(_thisObject + NOTIFICATION_SUFFIX) setMarkerAlphaLocal 0;
		};
	ENDMETHOD;

	// Shows or hides this map marker entirely
	METHOD(show)
		params [P_THISOBJECT, P_BOOL("_show")];

		// Call base class method (it sets the shown variable value)
		CALL_CLASS_METHOD("MapMarker", _thisObject, "show", [_show]);

		// Update marker properties
		T_CALLM0("update");
	ENDMETHOD;

	METHOD(setNotification)
		params [P_THISOBJECT, ["_enable", false, [false]]];

		T_SETV("notification", _enable);
		T_CALLM0("update");
	ENDMETHOD;

	METHOD(getIntel)
		params [P_THISOBJECT];
		T_GETV("intel")
	ENDMETHOD;

	// Overwrite the base class method
	METHOD(setPos)
		params [P_THISOBJECT, P_ARRAY("_pos")];

		// Call base class method
		CALL_CLASS_METHOD("MapMarker", _thisObject, "setPos", [_pos]);

		// Update the accuracy marker
		T_CALLM0("updateAccuracyRadiusMarker");

		// Set marker position
		{
			(_thisObject+_x) setMarkerPosLocal (T_GETV("pos")+[0]);
		} forEach [MARKER_SUFFIX, NOTIFICATION_SUFFIX, BG_SUFFIX];

	ENDMETHOD;

	// Same as setColor but gets both an array and string
	METHOD(setColorEx)
		params [P_THISOBJECT, P_ARRAY("_colorRGBA"), P_STRING("_colorString")];
		T_SETV("color", _colorRGBA);

		// Set color of the associated marker
		_mrkName = _thisObject+BG_SUFFIX;
		_mrkName setMarkerColorLocal _colorString;
	ENDMETHOD;

	METHOD(setAccuracyRadius)
		params [P_THISOBJECT, "_radius"];

		T_SETV("radius", _radius);
		T_CALLM0("updateAccuracyRadiusMarker");
	ENDMETHOD;

	// One of location types defined in location.hpp
	METHOD(setType)
		params [P_THISOBJECT, P_STRING("_type")];

		pr _mrkName = _thisObject+MARKER_SUFFIX;

		//pr _size = 1;

		pr _type0 = switch (_type) do {

			case LOCATION_TYPE_POWER_PLANT:		{ "vin_location_power_plant" };
			case LOCATION_TYPE_DEPOT:			{ "vin_location_depot" };
			case LOCATION_TYPE_POLICE_STATION:	{ "vin_location_police_station" };
			case LOCATION_TYPE_RADIO_STATION:	{ "vin_location_radio_station" };
			case LOCATION_TYPE_CITY:			{ "vin_location_city" };
			case LOCATION_TYPE_AIRPORT:			{ "vin_location_airport" };
			case LOCATION_TYPE_OUTPOST:			{ "vin_location_outpost" };
			case LOCATION_TYPE_ROADBLOCK:		{ "vin_location_roadblock" };
			case LOCATION_TYPE_CAMP:			{ "vin_location_camp" };

			case LOCATION_TYPE_UNKNOWN: 		{ "mil_unknown"; };

			case LOCATION_TYPE_RESPAWN: 		{ "respawn_unknown" };

			// The rest are military places
			default {
				"vin_location_outpost";
			};
		};

		_mrkName setMarkerTypeLocal _type0;

		// Set marker text
		_mrkName = _thisObject + BG_SUFFIX; // We set text on the background marker, not on the front marker, because BG is colorized, front is white/black
		if (_type in [LOCATION_TYPE_UNKNOWN, LOCATION_TYPE_CITY, LOCATION_TYPE_POLICE_STATION]) then {
			_mrkName setMarkerTextLocal "";
		} else {
			pr _loc = GETV(T_GETV("intel"), "location");
			pr _displayName = CALLM0(_loc, "getDisplayName");
			_mrkName setMarkerTextLocal ("  " + _displayName);
		};
		T_SETV("type", _type);
		
	ENDMETHOD;

	METHOD(updateAccuracyRadiusMarker)
		params [P_THISOBJECT];

		pr _radius = T_GETV("radius");
		pr _mrkName = _thisObject+RADIUS_MARKER_SUFFIX;

		if (_radius == 0) then {
			deleteMarkerLocal _mrkName;
		} else {
			// Check if marker doesn't exist yet
			if (markerColor _thisObject == "") then {
				createMarkerLocal [_mrkName, T_GETV("pos")+[0]];
				_mrkName setMarkerSizeLocal [_radius, _radius];
				_mrkName setMarkerShapeLocal "ELLIPSE";
				_mrkName setMarkerBrushLocal "SolidBorder";
				_mrkName setMarkerColorLocal "colorCivilian";
			};
			_mrkName setMarkerPosLocal (T_GETV("pos")+[0]);
			pr _alpha = [0.3, 0.45] select T_GETV("selected");
			_mrkName setMarkerAlphaLocal _alpha;
		};
	ENDMETHOD;

	METHOD(onDraw)
		//if (true) exitWith {};
		params [P_THISOBJECT, "_control"];



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
				"\z\vindicta\addons\ui\markers\MI_marker_selected.paa",
				[0.9, 0.0, 0.0, 1], //Color
				_pos, // Pos
				41, // Width
				41, // Height
				0, //-_angle, // Angle
				"" // Text
			];


			//T_SETV("angle", _angle + 20/diag_FPS);
		};

	ENDMETHOD;

	/*
	Method: onMouseEnter
	Gets called when the mouse pointer enters the marker area.

	Returns: nil
	*/
	METHOD(onMouseEnter)
		params [P_THISOBJECT];
		OOP_INFO_0("ENTER");
		//T_SETV("selected", true);
	ENDMETHOD;

	/*
	Method: onMouseLeave
	Gets called when the mouse pointer leaves the marker area.

	Returns: nil
	*/
	METHOD(onMouseLeave)
		params [P_THISOBJECT];
		OOP_INFO_0("LEAVE");
		//T_SETV("selected", false);
	ENDMETHOD;

	/*
	Method: onMouseButtonDown
	Gets called when user pushes mouse button while over the marker

	Parameters: _button, _shift, _ctrl, _alt

	_button - 0 for LMB, 1 for RMB
	_shift, _ctrl, _alt -  BOOL

	Returns: nil
	*/
	METHOD(onMouseButtonDown)
		params [P_THISOBJECT, "_button", "_shift", "_ctrl", "_alt"];
		OOP_INFO_4("DOWN Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);

		// We only care about left mouse button events
		if (_button == 0) then {
			// Remove all selections if we push mouse button without Alt key
			if (!_alt) then {
				CALLSM(CLASS_NAME, "deselectAllMarkers", []);

				// Disable the notification
				T_CALLM1("setNotification", false);
			};

			pr _selectedMarkers = GET_STATIC_VAR(CLASS_NAME, "selectedMarkers");
			_selectedMarkers pushBackUnique _thisObject;
			T_SETV("selected", true);

			// Update the accuracy radius marker's alpha
			if (T_GETV("radius") != 0) then {
				T_CALLM0("updateAccuracyRadiusMarker");
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
	ENDMETHOD;

	/*
	Method: onMouseButtonUp
	Gets called when user releases mouse button while over the marker

	Parameters: _button, _shift, _ctrl, _alt

	_button - 0 for LMB, 1 for RMB
	_shift, _ctrl, _alt -  BOOL

	Returns: nil
	*/
	METHOD(onMouseButtonUp)
		params [P_THISOBJECT, "_button", "_shift", "_ctrl", "_alt"];
		// OOP_INFO_4("UP Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);
	ENDMETHOD;

	/*
	Method: onMouseButtonClick
	Gets called when user clicks left mouse button at the marker

	Parameters: _shift, _ctrl, _alt

	_shift, _ctrl, _alt -  BOOL

	Returns: nil
	*/
	METHOD(onMouseButtonClick)
		params [P_THISOBJECT, "_shift", "_ctrl", "_alt"];
		// OOP_INFO_3("CLICK Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);

	ENDMETHOD;

	STATIC_METHOD(deselectAllMarkers)
		params ["_thisClass"];

		pr _selectedMarkers = GET_STATIC_VAR(CLASS_NAME, "selectedMarkers");
		{
			SETV(_x, "selected", false);
			if (GETV(_x, "radius") != 0) then {
				CALLM0(_x, "updateAccuracyRadiusMarker");
			};
		} forEach _selectedMarkers;

		SET_STATIC_VAR(CLASS_NAME, "selectedMarkers", []);
	ENDMETHOD;

	STATIC_METHOD(onMouseClickElsewhere)
		params ["_thisClass", "_button", "_shift", "_ctrl", "_alt"];

		if (_button == 0) then {
			CALLSM0(CLASS_NAME, "deselectAllMarkers");
			CALLSM0("ClientMapUI", "onMouseClickElsewhere");
		};
		
	ENDMETHOD;

	// Enables/disabled notification dots on all icons
	STATIC_METHOD(setAllNotifications)
		params ["_thisClass", ["_enable", false, [false]]];
		{
			CALLM1(_x, "setNotification", _enable);
		} forEach GET_STATIC_VAR(_thisClass, "all");
	ENDMETHOD;

ENDCLASS;

if(isNil {GETSV(CLASS_NAME, "all")} ) then {
	SET_STATIC_VAR(CLASS_NAME, "all", []);
	SET_STATIC_VAR(CLASS_NAME, "allSelected", []);
};

#ifndef _SQF_VM

/*
[missionNamespace, "MapMarker_MouseButtonDown_none", {
	params ["_button", "_shift", "_ctrl", "_alt"];
	CALL_STATIC_METHOD(CLASS_NAME, "onMouseClickElsewhere", _this);
}] call BIS_fnc_addScriptedEventHandler;
*/

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