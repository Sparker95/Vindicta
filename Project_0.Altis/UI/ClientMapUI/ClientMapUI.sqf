#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG
//#define NAMESPACE uiNamespace
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\Resources\MapUI\MapUI_Macros.h"
#include "..\Resources\ClientMapUI\ClientMapUI_Macros.h"
#include "..\..\Location\Location.hpp"
#include "..\Resources\UIProfileColors.h"


/*
Class: ClientMapUI
Singleton class that performs things related to map user interface
*/

#define CLASS_NAME "ClientMapUI"
#define pr private

CLASS(CLASS_NAME, "")
	// Arrays of LOCATION_DATA structures
	STATIC_VARIABLE("locationDataWest"); 	// What client's side knows about West knowledge about locations
	STATIC_VARIABLE("locationDataEast");
	STATIC_VARIABLE("locationDataInd");

	// initialize UI event handlers
	STATIC_METHOD("new") {
		params [["_thisObject", "", [""]]];
		pr _mapDisplay = findDisplay 12;

		//listbox events
		(_mapDisplay displayCtrl IDC_LOCP_LISTNBOX) ctrlAddEventHandler ["LBSelChanged", { params ['_control']; CALLSM(CLASS_NAME, "onLBSelChanged", [_control]) }];

		// bottom panel
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_1) ctrlAddEventHandler ["MouseEnter", { params ['_control']; CALLSM(CLASS_NAME, "onMouseEnter", [_control]) }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_1) ctrlAddEventHandler ["MouseExit", { params ['_control']; CALLSM(CLASS_NAME, "onMouseExit", [_control]) }];

		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_2) ctrlAddEventHandler ["MouseEnter", { params ['_control']; CALLSM(CLASS_NAME, "onMouseEnter", [_control]) }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_2) ctrlAddEventHandler ["MouseExit", { params ['_control']; CALLSM(CLASS_NAME, "onMouseExit", [_control]) }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_2) ctrlAddEventHandler ["ButtonDown", { params ['_control']; CALLSM(CLASS_NAME, "onButtonDownCreateCamp", [_control]) }];

		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_3) ctrlAddEventHandler ["MouseEnter", { params ['_control']; CALLSM(CLASS_NAME, "onMouseEnter", [_control]) }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_3) ctrlAddEventHandler ["MouseExit", { params ['_control']; CALLSM(CLASS_NAME, "onMouseExit", [_control]) }];

		// location panel
		(_mapDisplay displayCtrl IDC_LOCP_TAB1) ctrlAddEventHandler ["MouseEnter", { params ['_control']; CALLSM(CLASS_NAME, "onMouseEnter", [_control]) }];
		(_mapDisplay displayCtrl IDC_LOCP_TAB1) ctrlAddEventHandler ["MouseExit", { params ['_control']; CALLSM(CLASS_NAME, "onMouseExit", [_control]) }];

		(_mapDisplay displayCtrl IDC_LOCP_TAB2) ctrlAddEventHandler ["MouseEnter", { params ['_control']; CALLSM(CLASS_NAME, "onMouseEnter", [_control]) }];
		(_mapDisplay displayCtrl IDC_LOCP_TAB2) ctrlAddEventHandler ["MouseExit", { params ['_control']; CALLSM(CLASS_NAME, "onMouseExit", [_control]) }];

		(_mapDisplay displayCtrl IDC_LOCP_TAB3) ctrlAddEventHandler ["MouseEnter", { params ['_control']; CALLSM(CLASS_NAME, "onMouseEnter", [_control]) }];
		(_mapDisplay displayCtrl IDC_LOCP_TAB3) ctrlAddEventHandler ["MouseExit", { params ['_control']; CALLSM(CLASS_NAME, "onMouseExit", [_control]) }];

		// init headline text and color
		(_mapDisplay displayCtrl IDC_LOCP_HEADLINE) ctrlSetText format ["%1", (toUpper worldName)];
		(_mapDisplay displayCtrl IDC_LOCP_HEADLINE) ctrlSetBackgroundColor MUIC_COLOR_BLACK;

		// set some properties that didn't work right in control classes
		(_mapDisplay displayCtrl IDC_LOCP_TABCAT) ctrlSetFont "PuristaSemiBold";

	} ENDMETHOD;

	STATIC_METHOD("onButtonDownCreateCamp") {
		params ["_thisClass", "_control"];
		[player] call fnc_createCamp;
	} ENDMETHOD;

	/*
		Method: onMouseEnter
		Description: Called when the mouse cursor enters the control.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	STATIC_METHOD("onMouseEnter") {
		params ["_thisClass", "_control"];
		pr _mapDisplay = findDisplay 12;
		pr _idc = ctrlIDC _control;
		_control ctrlSetTextColor [0, 0, 0, 1];

		// choose correct hint to display for this control
		switch (_idc) do {
			// bottom panel
			case IDC_BPANEL_BUTTON_1: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_BUTTON1"); };
			case IDC_BPANEL_BUTTON_2: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_BUTTON2"); };
			case IDC_BPANEL_BUTTON_3: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_BUTTON3"); };

			// location panel
			case IDC_LOCP_TAB1: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_TAB1"); };
			case IDC_LOCP_TAB2: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_TAB2"); };
			case IDC_LOCP_TAB3: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_TAB3"); };
		};

	} ENDMETHOD;


	/*
		Method: onMouseExit
		Description: Called when the mouse cursor exits the control.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	STATIC_METHOD("onMouseExit") {
		params ["_thisClass", "_control"];
		pr _mapDisplay = findDisplay 12;
		_control ctrlSetTextColor [1, 1, 1, 1];

		(_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_DEFAULT");

	} ENDMETHOD;

	/*
		Method: onLBSelChanged
		Description: Called when the selection inside the listbox has changed.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	STATIC_METHOD("onLBSelChanged") {
		params ["_thisClass", "_control"];
		pr _mapDisplay = findDisplay 12;
		// TODO: Display different descriptions for intel
		
		(_mapDisplay displayCtrl IDC_LOCP_DETAILTXT) ctrlSetText (localize "STR_CMUI_INTEL_DEFAULT");

	} ENDMETHOD;

	// Formats location data and shows it on the location data panel
	STATIC_METHOD("onMouseClickElsewhere") {
		CALLSM0(CLASS_NAME, "clearListNBox");
		private _allIntels = CALLM0(gIntelDatabaseClient, "getAllIntel");
		private _mapDisplay = findDisplay 12;
		private _ctrlListnbox = _mapDisplay displayCtrl IDC_LOCP_LISTNBOX;

		{
			private _className = GET_OBJECT_CLASS(_x);
			if (_className != "IntelLocation") then {
				_ctrlListnbox lnbAddRow [ format ["%1 \n _className: %1 \n _className: %1 \n", _className] ];
			};

		} forEach _allIntels;

		// change location panel headline
		(_mapDisplay displayCtrl IDC_LOCP_HEADLINE) ctrlSetText format ["%1", (toUpper worldName)];
		(_mapDisplay displayCtrl IDC_LOCP_HEADLINE) ctrlSetBackgroundColor MUIC_COLOR_BLACK;

	} ENDMETHOD;


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
		pr _text = if (_type != LOCATION_TYPE_UNKNOWN) then {
			pr _t = CALL_STATIC_METHOD("ClientMapUI", "getNearestLocationName", [_pos]);
			if (_t == "") then { // Check if we have got an empty string
				format ["%1 %2", _side, _type]
			} else {
				_t
			};
		} else {
			"??"
		};

		pr _color = switch(_side) do {
			case WEST: {MUI_COLOR_BLUFOR};
			case EAST: {MUI_COLOR_OPFOR};
			case INDEPENDENT: {MUI_COLOR_IND};
			default {MUI_COLOR_IND};
		};

		CALLM1(_mapMarker, "setPos", _pos);
		CALLM1(_mapMarker, "setText", _text);
		CALLM1(_mapMarker, "setColor", _color);
	} ENDMETHOD;

	STATIC_METHOD("getLocationData") {
		params ["_thisClass", ["_pos", [], [[]]], ["_side", CIVILIAN]];

		_pos resize 2;

		if (_side == CIVILIAN) then {
			_side = side group player;
		};
		diag_log format ["Searching for location data at pos: %1, side :2", _pos, _side];
		pr _varName = switch (_side) do {
			case WEST: {"locationDataWest"};
			case EAST: {"locationDataEast"};
			case INDEPENDENT: {"locationDataInd"};
		};
		pr _ld = GET_STATIC_VAR(CLASS_NAME, _varName);

		// Find this location in client's database
		pr _index = _ld findif {
			pr _locPos = _x select CLD_ID_POS;

			_pos isEqualTo _locPos;
		};

		if (_index == -1) then {
			diag_log format ["Location data was not found!"];
			[]
		} else {
			diag_log format ["Location data was found: %1", _ld select _index];
			_ld select _index
		};

	} ENDMETHOD;

	STATIC_METHOD("clearListNBox") {
		private _mapDisplay = findDisplay 12;
		private _ctrlListnbox = _mapDisplay displayCtrl IDC_LOCP_LISTNBOX;
		lnbClear _ctrlListnbox;
	} ENDMETHOD;

	STATIC_METHOD("updateLocationDataPanel") {
		params ["_thisClass", ["_intel", "", [""]]];

		pr _typeText = "";
		pr _timeText = "";
		pr _sideText = "";
		pr _soldierCount = 0;
		pr _vehList = [];
		
		// Did we find a location in the database?
		if (CALLM1(gIntelDatabaseClient, "isIntelAdded", _intel)) then {

			_typeText = switch (GETV(_intel, "type")) do {
				case LOCATION_TYPE_OUTPOST: {"Outpost"};
				case LOCATION_TYPE_CAMP: {"Camp"};
				case LOCATION_TYPE_BASE: {"Base"};
				case LOCATION_TYPE_UNKNOWN: {"<Unknown>"};
			};
			
			_timeText = str GETV(_intel, "dateUpdated");
			_sideText = str GETV(_intel, "side");

			pr _ua = GETV(_intel, "unitData");
			if (count _ua > 0) then {
				_compositionText = "";
				// Amount of infrantry
				{_soldierCount = _soldierCount + _x;} forEach (_ua select T_INF);

				// Count vehicles
				pr _uaveh = _ua select T_VEH;
				{
					// If there are some vehicles of this subcategory
					if (_x > 0) then {
						pr _subcatID = _forEachIndex;
						pr _vehName = T_NAMES select T_VEH select _subcatID;
						pr _str = format ["%1: %2", _vehName, _x];
						_vehList pushBack _str;
					};
				} forEach _uaveh;
			};
		};

		// Apply new text for GUI elements
		CALLSM0(CLASS_NAME, "clearListNBox");
		
		private _mapDisplay = findDisplay 12;
		private _ctrlListnbox = _mapDisplay displayCtrl IDC_LOCP_LISTNBOX;
		_ctrlListnbox lnbAddRow [ format ["Type: %1", _typeText] ];
		_ctrlListnbox lnbAddRow [ format ["Side: %1", _sideText] ];
		_ctrlListnbox lnbAddRow [ format ["Soldier Count: %1", str _soldierCount] ];
		{
			_ctrlListnbox lnbAddRow [_x];
		} forEach _vehList;
	} ENDMETHOD;

	STATIC_METHOD("showLocationDataPanel") {
		params ["_thisClass", ["_show", true]];

		pr _idcs = [];
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
