#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
//#define NAMESPACE uiNamespace

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"
#include "..\Resources\MapUI\MapUI_Macros.h"

/*
Class: MapMarker
It's much like a local map marker, but allows to attach events to them like you can do with controls.
*/

#define pr private

#define CLASS_NAME "MapMarker"
#define OOP_CLASS_NAME MapMarker
CLASS("MapMarker", "")

	// All map marker objects
	STATIC_VARIABLE("all"); // Child classes must also implement this
	STATIC_VARIABLE("allSelected"); // Child classes must also implement this

	// Width and height in UI units used for mouse events
	VARIABLE("eWidthUI");
	VARIABLE("eHeightUI");

	// 2D position
	VARIABLE("pos");

	// Text
	VARIABLE("text");

	// Color
	VARIABLE("color");

	// Bool, default true, determines if this map marker is shown
	// Actual show/hide functionality is implementation-specific at derived classes
	VARIABLE("shown"); // Bool

	/*
	Method: new
	Creates a new MapMarker
	*/

	METHOD(new)
		params [P_THISOBJECT];

		pr _args = [0, 0];
		T_SETV("pos", _args);

		T_SETV("eWidthUI", 20);
		T_SETV("eHeightUI", 20);
		T_SETV("shown", true);


		// Add to the "all" array

		// Add it to the array of the final class
		pr _thisClass = GET_OBJECT_CLASS(_thisObject);
		pr _all = GET_STATIC_VAR(_thisClass, "all");
		_all pushBackUnique _thisObject;

		// Add it to the array of base class
		pr _all = GET_STATIC_VAR(CLASS_NAME, "all");
		_all pushBackUnique _thisObject;
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// Remove from the all array of the final class
		pr _thisClass = GET_OBJECT_CLASS(_thisObject);
		pr _all = GET_STATIC_VAR(_thisClass, "all");
		_all deleteAt (_all find _thisObject);

		// Remove from the all array of the base class
		pr _all = GET_STATIC_VAR(CLASS_NAME, "all");
		_all deleteAt (_all find _thisObject);

		pr _allSelected = GET_STATIC_VAR(_thisClass, "allSelected");
		_allSelected deleteAt (_allSelected find _thisObject);
	ENDMETHOD;





	// = = = = = = = O V E R R I D A B L E   E V E N T   H A N D L E R S = = = = = = = =

	/*
	Method: onDraw
	Overwrite to perform drawing of your marker. You should use commands like drawIcon.

	Parameters: _control

	_control - the map control where you must draw

	Returns: nil
	*/

	METHOD(onDraw)
		params [P_THISOBJECT, "_control"];

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

	ENDMETHOD;

	/*
	Method: setPos
	Sets position of the marker in world coordinates.
	You can override this method, but then you must call the base class method for the "getMarkerUnderCursor" to work.
	Parameters: _pos
	_pos - Array, [x, y]
	Returns: nil
	*/
	METHOD(setPos)
		params [P_THISOBJECT, P_ARRAY("_pos")];
		T_SETV("pos", _pos);
	ENDMETHOD;

	/*
	Method: select
	Sets the "selected" property of this map marker.

	params: _select

	_select - bool, default true.

	Returns: nil
	*/
	METHOD(select)
		params [P_THISOBJECT, ["_select", true]];

		OOP_INFO_1("SELECT: %1", _select);

		T_SETV("selected", _select);
		pr _thisClass = GET_OBJECT_CLASS(_thisObject);
		pr _selected = GETSV(_thisClass, "allSelected");
		if (_select) then {
			_selected pushBackUnique _thisObject;
		} else {
			_selected deleteAt (_selected find _thisObject);
		};
	ENDMETHOD;

	/*
	Method: show
	Sets the "shown" property of this map marker.
	Derived classes should call this on overrides.

	params: _show

	_show - bool, default true.

	Returns: nil
	*/
	METHOD(show)
		params [P_THISOBJECT, ["_show", true]];

		T_SETV("shown", _show);
	ENDMETHOD;

	/*
	Method: onMouseEnter
	Gets called when the mouse pointer enters the marker area.

	Returns: nil
	*/
	METHOD(onMouseEnter)
		params [P_THISOBJECT];
		OOP_INFO_0("ENTER");
	ENDMETHOD;

	/*
	Method: onMouseLeave
	Gets called when the mouse pointer leaves the marker area.

	Returns: nil
	*/
	METHOD(onMouseLeave)
		params [P_THISOBJECT];
		OOP_INFO_0("LEAVE");
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
		OOP_INFO_4("UP Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);
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
		OOP_INFO_3("CLICK Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);
	ENDMETHOD;

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
	STATIC_METHOD(getMarkerUnderCursor)
		params ["_thisClass", "_mapControl", "_xCursorPosUI", "_yCursorPosUI"];
		pr _all = GET_STATIC_VAR(_thisClass, "all");

		// Loop through all markers and find if the cursor is hovering over any of them
		pr _index = _all findIf {
			// Get event width in UI coordinates
			pr _eWidthUI = 0.5*(GETV(_x, "eWidthUI"))/640;
			pr _eHeightUI = 0.5*(GETV(_x, "eHeightUI"))/480;

			// Get UI pos of the marker
			pr _mrkPosWorld = GETV(_x, "pos");
			pr _mrkPosUI = _mapControl ctrlMapWorldToScreen _mrkPosWorld;

			// Check if the cursor position is inside marker
			_mrkPosUI params ["_mrkPosUIX", "_mrkPosUIY"];
			[_xCursorPosUI, _yCursorPosUI] inArea [[_mrkPosUIX, _mrkPosUIY], _eWidthUI, _eHeightUI, 0, true, -1]
			&& GETV(_x, "shown")
		};

		if (_index == -1) then {
			""
		} else {
			_all select _index;
		};
	ENDMETHOD;

	/*
	Method: (static)getMarkersUnderCursor
	Returns MapMarker object which is currently under the cursor, or "" if there is none.

	Parameters: _mapControl, _xCursorPosUI, _yCursorPosUI

	_mapControl - the map control
	_xCursorPosUI - X position of the cursor in global UI coordinates (compatible with Ctrl event handler coordinates)
	_yCursorPosUI - Y position of the cursor in global UI coordinates (compatible with Ctrl event handler coordinates)

	Returns: array of MapMarker objects.
	*/
	STATIC_METHOD(getMarkersUnderCursor)
		params ["_thisClass", "_mapControl", "_xCursorPosUI", "_yCursorPosUI"];
		pr _all = GET_STATIC_VAR(_thisClass, "all");

		// Loop through all markers and find if the cursor is hovering over any of them
		_all select {
			// Get event width in UI coordinates
			pr _eWidthUI = 0.5*(GETV(_x, "eWidthUI"))/640;
			pr _eHeightUI = 0.5*(GETV(_x, "eHeightUI"))/480;

			// Get UI pos of the marker
			pr _mrkPosWorld = GETV(_x, "pos");
			pr _mrkPosUI = _mapControl ctrlMapWorldToScreen _mrkPosWorld;

			// Check if the cursor position is inside marker
			_mrkPosUI params ["_mrkPosUIX", "_mrkPosUIY"];
			[_xCursorPosUI, _yCursorPosUI] inArea [[_mrkPosUIX, _mrkPosUIY], _eWidthUI, _eHeightUI, 0, true, -1]
			&& GETV(_x, "shown")
		}
	ENDMETHOD;

	/*
	Method: (static)getAll
	Returns an array of all map markers of this class.
	*/
	STATIC_METHOD(getAll)
		params [P_THISCLASS];
		GETSV(_thisClass, "all");
	ENDMETHOD;

	/*
	Method: (static)getAllSelected
	Returns an array of all selected map markers of this class
	*/
	STATIC_METHOD(getAllSelected)
		params [P_THISCLASS];
		GETSV(_thisClass, "allSelected") select {GETV(_x, "shown")}; // Return only markers which are shown
	ENDMETHOD;


ENDCLASS;

SET_STATIC_VAR(CLASS_NAME, "all", []);
SET_STATIC_VAR(CLASS_NAME, "allSelected", []);

MapMarker_EH_Draw = {
	params ["_control"];
	{
		CALLM1(_x, "onDraw", _control);
	} forEach GET_STATIC_VAR(CLASS_NAME, "all");
};

#ifndef _SQF_VM
if (hasInterface) then {
	0 spawn {
		waitUntil {! isNull (findDisplay 12)};

		// Add a Draw event handler to draw markers
		// It will call onDraw of every MapMarker object
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["Draw", {call MapMarker_EH_Draw}]; // Because of this sh1t: https://feedback.bistudio.com/T123355

		// ==== Add event handlers ====
		/*
		// These are moved into ClientMapUI now, which makes more sense.
		// Mouse button down
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonDown", {
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
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonUp", {
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
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonClick", {
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
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseMoving", {
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
		*/
	};
};
#endif