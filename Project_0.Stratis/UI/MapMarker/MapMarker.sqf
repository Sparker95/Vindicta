#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"

/*
Class: MapMarker
It's much like a local map marker, but allows to attach events to them like you can do with controls.
*/

#define pr private

CLASS("MapMarker", "")

	// All map marker objects
	STATIC_VARIABLE("all");
	STATIC_VARIABLE("markerUnderCursor");
	
	// 2D position
	VARIABLE("pos");
	
	// Width and height in UI units used for mouse events
	VARIABLE("eWidthUI");
	VARIABLE("eHeightUI");
	
	METHOD("new") {
		params ["_thisObject"];
		
		T_SETV("pos", [0, 0]);
		T_SETV("eWidthUI", 10);
		T_SETV("eHeightUI", 10);
		
		// Add to the array
		pr _all = GET_STATIC_VAR("MapMarker", "all");
		_all pushBack _thisObject;
	} ENDMETHOD;
	
	METHOD("delete") {
		params ["_thisObject"];
		
		// Remove from the all array
		pr _all = GET_STATIC_VAR("MapMarker", "all");
		_all deleteAt (_all find _thisObject);
	} ENDMETHOD;
	
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
	
	METHOD("onMouseEnter") {
		params ["_thisObject"];
		OOP_INFO_3("ENTER");
	} ENDMETHOD;
	
	METHOD("onMouseLeave") {
		params ["_thisObject"];
		OOP_INFO_0("LEAVE");
	} ENDMETHOD;
	
	METHOD("onMouseButtonDown") {
		params ["_thisObject", "_shift", "_ctrl", "_alt"];
		OOP_INFO_3("DOWN Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);
	} ENDMETHOD;
	
	METHOD("onMouseButtonUp") {
		params ["_thisObject", "_shift", "_ctrl", "_alt"];
		OOP_INFO_3("UP Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);
	} ENDMETHOD;
	
	METHOD("onMouseButtonClick") {
		params ["_thisObject", "_shift", "_ctrl", "_alt"];
		OOP_INFO_3("CLICK Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);
	} ENDMETHOD;
	
	// Setting properties
	METHOD("setPos") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]]];
		
		T_SETV("pos", _pos);
	} ENDMETHOD;
	
	METHOD("setEventSize") {
		params [["_thisObject", "", [""]], ["_width", 0, [0]], ["_height", 0, [0]] ];
		
		T_SETV("eWidthUI", _width);
		T_SETV("eHeightUI", _height);
	} ENDMETHOD;

	// Static methods
	STATIC_METHOD("getMarkerUnderCursor") {
		params ["_thisClass", "_mapControl", "_xCursorPosUI", "_yCursorPosUI"];
			pr _all = GET_STATIC_VAR("MapMarker", "all");
			
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

SET_STATIC_VAR("MapMarker", "all", []);
SET_STATIC_VAR("MapMarker", "markerUnderCursor", "");

0 spawn {
	waitUntil {! isNull (findDisplay 12)};
	
	// Add a Draw event handler
	// It will call onDraw of every MapMarker object
	((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw", {
		//OOP_INFO_0("Map OnDraw");
		params ["_control"];
		
		pr _all = GET_STATIC_VAR("MapMarker", "all");
		{
			CALLM1(_x, "onDraw", _control);
		} forEach _all;
	}];
	
	// ==== Add events ====
	
	// Mouse button down
	((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["MouseButtonDown", {
		 params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
		 
		 pr _args = [_displayorcontrol, _xPos, _yPos];
		 pr _marker = CALL_STATIC_METHOD("MapMarker", "getMarkerUnderCursor", _args);

		 // Call event handler
		 if (_marker != "") then {
		 	CALLM3(_marker, "onMouseButtonDown", _shift, _ctrl, _alt);
		 };
	}];
	
	// Mouse button up
	((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["MouseButtonUp", {
		 params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
		 diag_log format ["Map MouseButtonDown: %1 %2", [_xPos, _yPos], _displayorcontrol ctrlMapScreenToWorld [_xPos, _yPos]];
		 
		 pr _args = [_displayorcontrol, _xPos, _yPos];
		 pr _marker = CALL_STATIC_METHOD("MapMarker", "getMarkerUnderCursor", _args);
		 diag_log format ["Marker under cursor: %1", _marker];
		 
		 // Call event handler
		 if (_marker != "") then {
		 	CALLM3(_marker, "onMouseButtonUp", _shift, _ctrl, _alt);
		 };
	}];
	
	// Mouse button click
	((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["MouseButtonClick", {
		 params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

		 pr _args = [_displayorcontrol, _xPos, _yPos];
		 pr _marker = CALL_STATIC_METHOD("MapMarker", "getMarkerUnderCursor", _args);

		 // Call event handler
		 if (_marker != "") then {
		 	CALLM3(_marker, "onMouseButtonClick", _shift, _ctrl, _alt);
		 };
	}];
	
	// Mouse moving
	((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["MouseMoving", {
		params ["_control", "_xPos", "_yPos", "_mouseOver"];

		pr _args = [_control, _xPos, _yPos];
		pr _markerCurrent = CALL_STATIC_METHOD("MapMarker", "getMarkerUnderCursor", _args);
		pr _markerPrev = GET_STATIC_VAR("MapMarker", "markerUnderCursor");
		
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
			SET_STATIC_VAR("MapMarker", "markerUnderCursor", _markerCurrent)
		};
		
		// Call event handler
		if (_marker != "") then {
			CALLM0(_marker, "onMouseButtonClick");
		};
	}];
	
	
	// Make some test textures
	pr _testMarker = NEW("MapMarker", []);
	pr _pos = [4000, 5000];
	CALLM1(_testMarker, "setPos", _pos);
	CALLM2(_testMarker, "setEventSize", 100, 50);
	
	pr _testMarker = NEW("MapMarker", []);
	pr _pos = [5000, 5000];
	CALLM1(_testMarker, "setPos", _pos);
	CALLM2(_testMarker, "setEventSize", 40, 100);
	
	
};