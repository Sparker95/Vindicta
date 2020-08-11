#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#include "..\..\common.h"

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\MapUI\MapUI_Macros.h"
#include "..\ClientMapUI\ClientMapUI_Macros.h"

/*
Class: MapMarkerGarrison
That's how we draw garrisons
*/

#define CLASS_NAME "MapMarkerGarrison"

#define MARKER_SUFFIX "_mrk"

#define pr private
#define OOP_CLASS_NAME MapMarkerGarrison
CLASS("MapMarkerGarrison", "MapMarker")

	VARIABLE("selected");

	VARIABLE("garRecord"); // GarrisonRecord this map marker is attached to

	VARIABLE("microPanel"); // Micro panel with info attached to this marker, managed by ClientMapUI

	STATIC_VARIABLE("selectedMarkers");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		T_SETV("garRecord", _garRecord);
		T_SETV("microPanel", [controlNull]);

		// Create marker
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		OOP_INFO_1("NEW mrkName: %1", _mrkName);
		createMarkerLocal [_mrkName, [100, 100, 0]];
		_mrkName setMarkerShapeLocal "ICON";
		_mrkName setMarkerPosLocal ([100, 100, 0]);
		_mrkName setMarkerAlphaLocal 0.85;
		_mrkName setMarkerTypeLocal "b_unknown";
		_mrkName setMarkerTextLocal "<Garrison>";
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// Delete the marker
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		OOP_INFO_1("DELETE mrkName: %1", _mrkName);
		deleteMarkerLocal _mrkName;

		// Delete micro panel if it exists
		pr _microPanel = T_GETV("microPanel");
		if (!isNull (_microPanel#0)) then {
			ctrlDelete (_microPanel#0);
		};
	ENDMETHOD;

	public METHOD(getGarrisonRecord)
		params [P_THISOBJECT];
		T_GETV("garRecord")
	ENDMETHOD;

	public METHOD(setSide)
		params [P_THISOBJECT, P_SIDE("_side")];
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		_mrkName setMarkerColorLocal ([_side, true] call BIS_fnc_sideColor);
	ENDMETHOD;

	public override METHOD(setPos)
		params [P_THISOBJECT, P_POSITION("_pos")];
		pr _mrkName = _thisObject+MARKER_SUFFIX;
		_mrkName setMarkerPosLocal _pos;

		// Call base class method
		CALLCM("MapMarker", _thisObject, "setPos", [_pos]);
	ENDMETHOD;

	public override event METHOD(onDraw)
		//if (true) exitWith {};

		params [P_THISOBJECT, "_control"];

		// Draw a surrounding icon if selected
		if (T_GETV("selected")) then {
			pr _pos = T_GETV("pos");
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
		};
	ENDMETHOD;

	public METHOD(getMarker)
		params [P_THISOBJECT];
		_thisObject+MARKER_SUFFIX
	ENDMETHOD;

	public METHOD(setText)
		params [P_THISOBJECT, P_STRING("_text")];
		(_thisObject+MARKER_SUFFIX) setMarkerTextLocal _text;
	ENDMETHOD;

	public override METHOD(show)
		params [P_THISOBJECT, P_BOOL("_show")];
		pr _alpha = [0, 0.85] select _show;
		(_thisObject+MARKER_SUFFIX) setMarkerAlphaLocal _alpha;
	ENDMETHOD;


	// - - - - - - - Event handlers - - - - - - -

	public override event METHOD(onMouseButtonDown)
		params [P_THISOBJECT, "_button", "_shift", "_ctrl", "_alt"];
		OOP_INFO_4("DOWN Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);

		// We only care about left mouse button events
		if (_button == 0) then {
			// Remove all selections if we push mouse button without Alt key
			if (!_alt) then {
				CALLSM(CLASS_NAME, "deselectAllMarkers", []);
			};

			pr _selectedMarkers = GETSV(CLASS_NAME, "selectedMarkers");
			_selectedMarkers pushBackUnique _thisObject;
			T_SETV("selected", true);

			// If only this marker is selected now
			if (count _selectedMarkers == 1) then {
				
			} else {

			};
		};
	ENDMETHOD;

	public override event METHOD(onMouseButtonUp)
		params [P_THISOBJECT, "_button", "_shift", "_ctrl", "_alt"];
		// OOP_INFO_4("UP Button: %1, Shift: %2, Ctrl: %3, Alt: %4", _button, _shift, _ctrl, _alt);
	ENDMETHOD;

	public override event METHOD(onMouseButtonClick)
		params [P_THISOBJECT, "_shift", "_ctrl", "_alt"];
		// OOP_INFO_3("CLICK Shift: %1, Ctrl: %2, Alt: %3", _shift, _ctrl, _alt);
	ENDMETHOD;

	public event STATIC_METHOD(onMouseClickElsewhere)
		params ["_thisClass", "_button", "_shift", "_ctrl", "_alt"];

		if (_button == 0) then {
			CALLSM0(CLASS_NAME, "deselectAllMarkers");
		};
		
	ENDMETHOD;

	public STATIC_METHOD(deselectAllMarkers)
		params ["_thisClass"];

		pr _selectedMarkers = GETSV(_thisClass, "selectedMarkers");
		{
			SETV(_x, "selected", false);
		} forEach _selectedMarkers;

		SETSV(CLASS_NAME, "selectedMarkers", []);
	ENDMETHOD;

ENDCLASS;

if (isNil {GETSV(CLASS_NAME, "all")}) then {
	SETSV(CLASS_NAME, "all", []);
	SETSV(CLASS_NAME, "allSelected", []);
};

#ifndef _SQF_VM

/*
[missionNamespace, "MapMarker_MouseButtonDown_none", {
	params ["_button", "_shift", "_ctrl", "_alt"];
	CALLSM(CLASS_NAME, "onMouseClickElsewhere", _this);
}] call BIS_fnc_addScriptedEventHandler;
*/

#endif