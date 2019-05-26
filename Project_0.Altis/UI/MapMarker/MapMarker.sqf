#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
//#define NAMESPACE uiNamespace
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Resources\MapUI\MapUI_Macros.h"

/*
Class: MapMarker
It's much like a local map marker, but allows to attach events to them like you can do with controls.
*/

#define pr private

#define CLASS_NAME "MapMarker"

CLASS(CLASS_NAME, "")

	// All map marker objects
	STATIC_VARIABLE("all");
	STATIC_VARIABLE("markerUnderCursor");
	STATIC_VARIABLE("timePrevButtonDown");

	// 2D position
	VARIABLE("pos");

	// Text
	VARIABLE("text");

	// Color
	VARIABLE("color");

	// Width and height in UI units used for mouse events
	VARIABLE("eWidthUI");
	VARIABLE("eHeightUI");

	/*
	Method: new
	Creates a new MapMarker
	*/

	METHOD("new") {
		params ["_thisObject"];

		pr _args = [0, 0];
		T_SETV("pos", _args);
		T_SETV("eWidthUI", 20);
		T_SETV("eHeightUI", 20);

		// T_SETV("text", "");
		// T_SETV("color", )

		// Add to the array
		pr _all = GET_STATIC_VAR(CLASS_NAME, "all");
		_all pushBack _thisObject;
	} ENDMETHOD;

	METHOD("delete") {
		params ["_thisObject"];

		// Remove from the all array
		pr _all = GET_STATIC_VAR(CLASS_NAME, "all");
		_all deleteAt (_all find _thisObject);
	} ENDMETHOD;





	// = = = = = = = O V E R R I D A B L E   E V E N T   H A N D L E R S = = = = = = = =

	/*
	Method: onDraw
	Overwrite to perform drawing of your marker. You should use commands like drawIcon.

	Parameters: _control

	_control - the map control where you must draw

	Returns: nil
	*/

	METHOD("onDraw") {
		params ["_thisObject", "_control"];

		pr _pos = T_GETV("pos");

		_control drawIcon
		[
			"#(rgb,1,1,1)color(1,1,1,0.5)", // Texture
			[0,1,0,1], //Color
			_pos, // Pos
			T_GETV("eWidthUI"), // Width
			T_GETV("eHeightUI"), // Height
			0, // Angle
			_thisObject // Text
		];

	} ENDMETHOD;


	/*
	Method: onMouseEnter
	Gets called when the mouse pointer enters the marker area.

	Returns: nil
	*/
	METHOD("onMouseEnter") {
		params ["_thisObject"];
		OOP_INFO_0("ENTER");
	} ENDMETHOD;

	/*
	Method: onMouseLeave
	Gets called when the mouse pointer leaves the marker area.

	Returns: nil
	*/
	METHOD("onMouseLeave") {
		params ["_thisObject"];
		OOP_INFO_0("LEAVE");
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
		OOP_INFO_4("UP Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);
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
		OOP_INFO_3("CLICK Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);
	} ENDMETHOD;


	// ==== Setting properties ====
	/*
	Method: setPos
	Sets position of the marker in world coordinates

	Parameters: _pos

	_pos - Array, [x, y]

	Returns: nil
	*/
	METHOD("setPos") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]]];

		T_SETV("pos", _pos);
	} ENDMETHOD;

	/*
	Method: setText
	Sets "text" variable of this marker object.
	You can use the text variable however you like.
	However you are free not to use the text variable in your inherited classes.

	Parameters: _text

	_text - String

	Returns: nil
	*/
	METHOD("setText") {
		params [["_thisObject", "", [""]], ["_string", "", [""]]];

		T_SETV("text", _text);
	} ENDMETHOD;

	METHOD("setColor") {
		params [["_thisObject", "", [""]], "_color"];
		T_SETV("color", _color);
	} ENDMETHOD;

	/*
	Method: setEventSize
	Mouse events are activated based on 'event size'.
	This is done so that we can detach drawing from event detection.
	Event size units are compatible with drawIcon width and height units.

	Parameters: _width, _height

	_width - Number
	_height - Number

	Returns: nil
	*/

	METHOD("setEventSize") {
		params [["_thisObject", "", [""]], ["_width", 0, [0]], ["_height", 0, [0]] ];

		T_SETV("eWidthUI", _width);
		T_SETV("eHeightUI", _height);
	} ENDMETHOD;











	// === Static methods ====
	/*
	Method: (static)getMarkerUnderCursor
	Returns MapMarker object which is currently under the cursor, or "" if there is none.

	Parameters: _mapControl, _xCursorPosUI, _yCursorPosUI

	_mapControl - the map control
	_xCursorPosUI - X position of the cursor in global UI coordinates (compatible with Ctrl event handler coordinates)
	_yCursorPosUI - Y position of the cursor in global UI coordinates (compatible with Ctrl event handler coordinates)

	Returns: <MapMarker> or ""
	*/
	STATIC_METHOD("getMarkerUnderCursor") {
		params ["_thisClass", "_mapControl", "_xCursorPosUI", "_yCursorPosUI"];
			pr _all = GET_STATIC_VAR(CLASS_NAME, "all");

			// Loop through all markers and find if the cursor is hovering over any of them
			pr _index = _all findIf {
				// Get UI pos of the marker
				pr _mrkPosWorld = GETV(_x, "pos");
				pr _mrkPosUI = _mapControl ctrlMapWorldToScreen _mrkPosWorld;

				// Get event width in UI coordinates
				pr _eWidthUI = 0.5*(GETV(_x, "eWidthUI"))/640;
				pr _eHeightUI = 0.5*(GETV(_x, "eHeightUI"))/480;

				// Check if the cursor position is inside marker
				_mrkPosUI params ["_mrkPosUIX", "_mrkPosUIY"];
				if ((_xCursorPosUI > (_mrkPosUIX - _eWidthUI)) && (_xCursorPosUI < (_mrkPosUIX + _eWidthUI))) then {
					if ((_yCursorPosUI > (_mrkPosUIY - _eHeightUI)) && (_yCursorPosUI < (_mrkPosUIY + _eHeightUI))) then {
						true
					} else {
						false
					};
				} else {
					false
				};
			};

			if (_index == -1) then {
				""
			} else {
				_all select _index;
			};
		} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR(CLASS_NAME, "all", []);
SET_STATIC_VAR(CLASS_NAME, "markerUnderCursor", "");
SET_STATIC_VAR(CLASS_NAME, "timePrevButtonDown", 0);

MapMarker_EH_Draw = {
	params ["_control"];
	pr _all = GET_STATIC_VAR(CLASS_NAME, "all");
	{
		CALLM1(_x, "onDraw", _control);
	} forEach _all;
};

#ifndef _SQF_VM
0 spawn {
	waitUntil {! isNull (findDisplay 12)};

	// Add a Draw event handler to draw markers
	// It will call onDraw of every MapMarker object
	((findDisplay 12) displayCtrl IDD_MAP) ctrlAddEventHandler ["Draw", {call MapMarker_EH_Draw}]; // Because of this sh1t: https://feedback.bistudio.com/T123355

	// ==== Add event handlers ====

	// Mouse button down
	((findDisplay 12) displayCtrl IDD_MAP) ctrlAddEventHandler ["MouseButtonDown", {
		 params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

		 pr _args = [_displayorcontrol, _xPos, _yPos];
		 pr _marker = CALL_STATIC_METHOD(CLASS_NAME, "getMarkerUnderCursor", _args);

		 // Call event handler
		 if (_marker != "") then {
		 	CALLM4(_marker, "onMouseButtonDown", _button, _shift, _ctrl, _alt);
		 } else {
		 	[missionNamespace, "MapMarker_MouseButtonDown_none", [_button, _shift, _ctrl, _alt]] call BIS_fnc_callScriptedEventHandler;
		 };
	}];

	// Mouse button up
	((findDisplay 12) displayCtrl IDD_MAP) ctrlAddEventHandler ["MouseButtonUp", {
		 params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
		 diag_log format ["Map MouseButtonDown: %1 %2", [_xPos, _yPos], _displayorcontrol ctrlMapScreenToWorld [_xPos, _yPos]];

		 pr _args = [_displayorcontrol, _xPos, _yPos];
		 pr _marker = CALL_STATIC_METHOD(CLASS_NAME, "getMarkerUnderCursor", _args);
		 diag_log format ["Marker under cursor: %1", _marker];

		 // Call event handler
		 if (_marker != "") then {
		 	CALLM4(_marker, "onMouseButtonUp", _button, _shift, _ctrl, _alt);
		 };
	}];

	// Mouse button click
	((findDisplay 12) displayCtrl IDD_MAP) ctrlAddEventHandler ["MouseButtonClick", {
		 params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

		 pr _args = [_displayorcontrol, _xPos, _yPos];
		 pr _marker = CALL_STATIC_METHOD(CLASS_NAME, "getMarkerUnderCursor", _args);

		 // Call event handler
		 if (_marker != "") then {
		 	CALLM3(_marker, "onMouseButtonClick", _shift, _ctrl, _alt);
		 } else {
		 	[missionNamespace, "MapMarker_MouseButtonClick_none", [_button, _shift, _ctrl, _alt]] call BIS_fnc_callScriptedEventHandler;
		 };
	}];

	// Mouse moving
	((findDisplay 12) displayCtrl IDD_MAP) ctrlAddEventHandler ["MouseMoving", {
		params ["_control", "_xPos", "_yPos", "_mouseOver"];

		pr _args = [_control, _xPos, _yPos];
		pr _markerCurrent = CALL_STATIC_METHOD(CLASS_NAME, "getMarkerUnderCursor", _args);
		pr _markerPrev = GET_STATIC_VAR(CLASS_NAME, "markerUnderCursor");

		// Did something change?
		if (_markerPrev != _markerCurrent) then {
			// Did we leave any marker?
			if (_markerPrev != "") then {
				CALLM0(_markerPrev, "onMouseLeave");
			};

			// Did we enter a new marker?
			if (_markerCurrent != "") then {
				CALLM0(_markerCurrent, "onMouseEnter");
			};

			// Update the variable
			SET_STATIC_VAR(CLASS_NAME, "markerUnderCursor", _markerCurrent)
		};
	}];
};
#endif