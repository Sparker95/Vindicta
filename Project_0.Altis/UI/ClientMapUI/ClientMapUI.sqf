#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\Resources\MapUI\MapUI_Macros.h"
#include "..\Resources\ClientMapUI\ClientMapUI_Macros.h"
#include "..\..\Location\Location.hpp"
#include "..\Resources\UIProfileColors.h"

#define CLASS_NAME "ClientMapUI"
#define pr private

/*
	Class: ClientMapUI
	Singleton class that performs things related to map user interface
*/
CLASS(CLASS_NAME, "")
	STATIC_VARIABLE("currentMapMarker");
	STATIC_VARIABLE("campAllowed");

	// Array with route markers (route segments and source/destination markers)
	STATIC_VARIABLE("routeMarkers");

	// initialize UI event handlers
	STATIC_METHOD("new") {
		params [["_thisObject", "", [""]]];
		pr _mapDisplay = findDisplay 12;

		// open map EH
		addMissionEventHandler ["Map", { 
		params ["_mapIsOpened", "_mapIsForced"]; if !(visibleMap) then { CALLSM0(CLASS_NAME, "onMapOpen") }; }];
		
		//listbox events
		(_mapDisplay displayCtrl IDC_LOCP_LISTNBOX) ctrlAddEventHandler ["LBSelChanged", { params ['_control']; CALLSM(CLASS_NAME, "onLBSelChanged", [_control]) }];

		// bottom panel
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_1) ctrlAddEventHandler ["MouseEnter", { params ['_control']; CALLSM(CLASS_NAME, "onMouseEnter", [_control]) }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_1) ctrlAddEventHandler ["MouseExit", { params ['_control']; CALLSM(CLASS_NAME, "onMouseExit", [_control]) }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_1) ctrlAddEventHandler ["ButtonDown", { params ['_control']; CALLSM(CLASS_NAME, "onButtonDownAddFriendlyGroup", [_control]) }];

		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_2) ctrlAddEventHandler ["MouseEnter", { params ['_control']; CALLSM(CLASS_NAME, "onMouseEnter", [_control]) }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_2) ctrlAddEventHandler ["MouseExit", { params ['_control']; CALLSM(CLASS_NAME, "onMouseExit", [_control]) }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_2) ctrlAddEventHandler ["ButtonDown", { params ['_control']; CALLSM0(CLASS_NAME, "onButtonDownCreateCamp") }];

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

	/*
		Method: toggleButtonEnabled
		Description: Set a button enabled or disabled. Does not use 

		Parameter:
		0: _control - the button to be toggled
		1: _enable - default: true, false to disable
	*/
	STATIC_METHOD("toggleButtonEnabled") {
		params ["_thisClass", "_control", ["_enable", true]];
		
	} ENDMETHOD;


	/*
		Method: onButtonDownCreateCamp
		Description: Creates a camp at the current location if the button is enabled.

		No parameters
	*/
	STATIC_METHOD("onButtonDownCreateCamp") {
		params ["_thisClass"];
		REMOTE_EXEC_STATIC_METHOD("Camp", "newStatic", [getPos player], 2, false);
	} ENDMETHOD;


	/*
		Method: onMapOpen
		Description: Called by user interface event handler each time the map is opened

		No parameters
	*/
	STATIC_METHOD("onMapOpen") {
		params ["_thisClass"];
		pr _mapDisplay = findDisplay 12;

		// Reset the map UI to default state
		CALLSM0(_thisClass, "onMouseClickElsewhere");

		// Check if current player position is valid position to create a Camp
		pr _isPosAllowed = call {
			pr _allLocations = GETSV("Location", "all");
			_isPosAllowed = true;
			pr _pos = getPosWorld player;

			{
				pr _locPos = CALLM0(_x, "getPos");
				pr _type = CALLM0(_x, "getType");
				pr _dist = _pos distance _locPos;
				if (_dist < 500) exitWith {_isPosAllowed = false;};
				// if (_dist < 3000 && _type == "camp") exitWith {_isPosAllowed = false;};
			} forEach _allLocations;

			_isPosAllowed
		};

		// disable or enable create Camp button
		if (_isPosAllowed) then { 
			(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_2) ctrlEnable true;
		} else { 
			(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_2) ctrlEnable false;
		};
	} ENDMETHOD;

	STATIC_METHOD("onButtonDownAddFriendlyGroup") {
		params ["_thisClass", "_control"];

		pr _mapDisplay = findDisplay 12;

		// Get currently selected marker
		pr _mapMarker = GETSV(CLASS_NAME, "currentMapMarker");
		if (_mapMarker == "") exitWith {
			(_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText "You must select a location marker first!";
		};

		// Get location of this map marker
		pr _loc = GETV(GETV(_mapMarker, "intel"), "location");

		if (_loc == "") exitWith {};

		// Post method to commander thread to add a group
		private _AI = CALLSM1("AICommander", "getCommanderAIOfSide", WEST);
		CALLM2(_AI, "postMethodAsync", "addGroupToLocation", [_loc ARG 5]);

		(_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText "A friendly group has been added to the location!";
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

		// hints to display if this control is enabled
		if (ctrlEnabled (_mapDisplay displayCtrl _idc)) then {
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
		} else { // hints to display if this control is disabled
			switch (_idc) do {
				// bottom panel
				case IDC_BPANEL_BUTTON_1: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_BUTTON1_DISABLED"); };
				case IDC_BPANEL_BUTTON_2: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_BUTTON2_DISABLED"); };
				case IDC_BPANEL_BUTTON_3: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_BUTTON3_DISABLED"); };

				// location panel
				case IDC_LOCP_TAB1: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_TAB1"); };
				case IDC_LOCP_TAB2: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_TAB2"); };
				case IDC_LOCP_TAB3: { (_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText (localize "STR_CMUI_TAB3"); };
			};
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
		private _mapDisplay = findDisplay 12;
		(_mapDisplay displayCtrl IDC_LOCP_DETAILTXT) ctrlSetText (localize "STR_CMUI_INTEL_DEFAULT");
		private _currentRow = lnbCurSelRow _control;

		// Bail if current row is -1 - it means nothing is selected
		if (_currentRow == -1) exitWith {
			(_mapDisplay displayCtrl IDC_LOCP_DETAILTXT) ctrlSetText "Nothing is selected";
		};

		// Bail if we have selected a map marker (for now until we figure out what to do with the list box when we have selected a location)
		pr _currentMapMarker = GET_STATIC_VAR("ClientMapUI", "currentMapMarker");
		if (_currentMapMarker != "") exitWith {
			(_mapDisplay displayCtrl IDC_LOCP_DETAILTXT) ctrlSetText "What do we show here? What does it all mean?? Where am I???";
		};

		private _data = _control lnbData [_currentRow, 0];
		private _className = GET_OBJECT_CLASS(_data);
		private _actionName = "Unknown";
		private _text = "";

		// - - - - P A T R O L - - - -
		// The Hell Patrol! https://www.youtube.com/watch?v=om0sp1Srixw
		if (_className == "IntelCommanderActionPatrol") exitWith {

			(_mapDisplay displayCtrl IDC_LOCP_DETAILTXT) ctrlSetText "Enemy patrol route";

			// Draw the route
			pr _waypoints = +GETV(_data, "waypoints");
			pr _args = [_waypoints,		// posArray
						true,	// enable
						true,	// cycle
						false];	// drawSrcDest
			CALLSM("ClientMapUI", "drawRoute", _args); // "_posArray", "_enable", "_cycle", "_drawSrcDest"
		};



		// - - - - - REINFORCE, ATTACK, RECON, BUILD - - - -
		if (_className == "IntelCommanderActionReinforce") then { _actionName = "reinforce"; };
		if (_className == "IntelCommanderActionBuild") then { _actionName = "build"; };
		if (_className == "IntelCommanderActionRecon") then { _actionName = "recon"; };
		if (_className == "IntelCommanderActionAttack") then { _actionName = "attack"; };

		private _from = GETV(_data, "posSrc");
		private _fromName = "Unknown";
		private _to = GETV(_data, "posTgt");
		private _toName = "Unknown";
		private _allIntels = CALLM0(gIntelDatabaseClient, "getAllIntel");

		// Find intel about locations close to _from or _to
		{
			private _className = GET_OBJECT_CLASS(_x);
			if (_className == "IntelLocation") then {
				private _pos = GETV(_x, "pos");
				private _loc = GETV(_x, "location");

				if (_from distance2D _pos < 10) then { _fromName = GETV(_loc, "name"); };
				if (_to distance2D _pos < 10) then { _toName = GETV(_loc, "name"); };
			};
		} forEach _allIntels;

		if (_fromName == "Unknown") then { _fromName = mapGridPosition _from; };
		if (_toName == "Unknown") then { _toName = mapGridPosition _to; };

		_text = format [
			"%1 is going to %2 %3",
			_fromName,
			_actionName,
			_toName
		];

		if (_actionName != "Unknown") then {
			(_mapDisplay displayCtrl IDC_LOCP_DETAILTXT) ctrlSetText _text;
		};

		// Draw the route
		pr _args = [[_from, _to],		// posArray
					true,	// enable
					false,	// cycle
					true];	// drawSrcDest
		CALLSM("ClientMapUI", "drawRoute", _args); // "_posArray", "_enable", "_cycle", "_drawSrcDest"
	} ENDMETHOD;

	/*
		Method: onMouseClickElsewhere
		Description: Gets called when user clicks on the map not on a marker.
	*/
	STATIC_METHOD("onMouseClickElsewhere") {

		// Reset the current marker variable
		SET_STATIC_VAR("ClientMapUI", "currentMapMarker", "");

		CALLSM0(CLASS_NAME, "clearListNBox");
		private _allIntels = CALLM0(gIntelDatabaseClient, "getAllIntel");
		private _mapDisplay = findDisplay 12;
		private _ctrlListnbox = _mapDisplay displayCtrl IDC_LOCP_LISTNBOX;

		{
			private _className = GET_OBJECT_CLASS(_x);
			if (_className != "IntelLocation") then { // Add all non-location intel classes
				private _intel = _x;
				private _shortName = CALLM0(_intel, "getShortName");

				// Calculate time difference between current date and departure date
				private _dateDeparture = GETV(_intel, "dateDeparture");
				private _dateNow = date;
				private _numberDiff = (_dateDeparture call misc_fnc_dateToNumber) - (date call misc_fnc_dateToNumber);
				private _activeStr = "";
				if (_numberDiff < 0) then {
					_activeStr = "active ";
					_numberDiff = -_numberDiff;
				};
				private _dateDiff = numberToDate [_dateNow#0, _numberDiff];
				_dateDiff params ["_y", "_m", "_d", "_h", "_m"];
				
				// Make a string representation of time difference
				private _timeDiffStr = if (_h > 0) then {
					format ["%1H, %2M", _h, _m]
				} else {
					format ["%1M", _m]
				};

				// Make a string representation of side
				private _side = GETV(_intel, "side");
				_sideStr  = switch (_side) do {
					case WEST: {"WEST"};
					case EAST: {"EAST"};
					case independent: {"IND"};
					default {"ALIEN"};
				};

				private _rowStr = format ["%1 %2 %3%4", _sideStr, _shortName, _activeStr, _timeDiffStr];

				private _index = _ctrlListnbox lnbAddRow [_rowStr];
				_ctrlListnbox lnbSetData [[_index, 0], _x];
			};
		} forEach _allIntels;

		// change location panel headline
		(_mapDisplay displayCtrl IDC_LOCP_HEADLINE) ctrlSetText format ["%1", (toUpper worldName)];
		(_mapDisplay displayCtrl IDC_LOCP_HEADLINE) ctrlSetBackgroundColor MUIC_COLOR_BLACK;
	} ENDMETHOD;


	/*
	Method: clearListNBox
	Description

	Returns: nil
	*/
	STATIC_METHOD("clearListNBox") {
		private _mapDisplay = findDisplay 12;
		private _ctrlListnbox = _mapDisplay displayCtrl IDC_LOCP_LISTNBOX;
		lnbClear _ctrlListnbox;
	} ENDMETHOD;

	/*
	Method: onMapMarkerMouseButtonDown
	Gets called when user clicks on a map marker

	Parameters: _mapMarker, _intel

	Returns: nil
	*/
	STATIC_METHOD("onMapMarkerMouseButtonDown") {
		params ["_thisClass", ["_mapMarker", "", []], ["_intel", "", [""]]];

		SET_STATIC_VAR("ClientMapUI", "currentMapMarker", _mapMarker);

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
				case LOCATION_TYPE_CITY: {"City"};
				case LOCATION_TYPE_OBSERVATION_POST: {"Observation post"};
				case LOCATION_TYPE_ROADBLOCK: {"Roadblock"};
				case LOCATION_TYPE_POLICE_STATION: {"Police Station"};
				default {format ["ClientMapUI.sqf line %1", __LINE__]}; // If you see this then you know where to implement this!
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
		(_mapDisplay displayCtrl IDC_LOCP_DETAILTXT) ctrlSetText "";
		private _ctrlListnbox = _mapDisplay displayCtrl IDC_LOCP_LISTNBOX;
		_ctrlListnbox lnbSetCurSelRow -1;
		_ctrlListnbox lnbAddRow [ format ["Type: %1", _typeText] ];
		_ctrlListnbox lnbAddRow [ format ["Side: %1", _sideText] ];
		_ctrlListnbox lnbAddRow [ format ["Soldier Count: %1", str _soldierCount] ];
		{
			_ctrlListnbox lnbAddRow [_x];
		} forEach _vehList;

		// Disable markers showing source and destination on the map
		pr _args = [[],		// posArray
					false,	// enable
					false,	// cycle
					false];	// drawSrcDest
		CALLSM("ClientMapUI", "drawRoute", _args); // "_posArray", "_enable", "_cycle", "_drawSrcDest"
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

	// Draws or undraws a route for a given array of positions
	STATIC_METHOD("drawRoute") {
		params ["_thisClass", ["_posArray", [], [[]]], ["_enable", false, [false]], ["_cycle", false, [false]], ["_drawSrcDest", false, [false]] ];

		// Delete all previosly created markers
		{
			deleteMarkerLocal _x;
		} forEach GETSV(_thisClass, "routeMarkers");
		SETSV(_thisClass, "routeMarkers", []);

		if (_enable) then {

			if (count _posArray < 2) exitWith {
				OOP_ERROR_1("setIntelMarkersParameters: less than two positions were provided: %1", _posArray);
			};

			// If we need to cycle the waypoints, add the source pos to the end too
			pr _positions = _posArray;
			pr _count = count _positions;
			pr _posSrc = _positions#0;
			pr _posDst = _positions#(_count - 1);
			if (_cycle) then { _positions pushBack (_positions#0); _count = _count + 1;};

			pr _markers = GETSV(_thisClass, "routeMarkers");

			// Create source and destination markers
			if (_drawSrcDest) then {
				{
					_x params ["_name", "_pos", "_type", "_text"];
					private _mrk = createMarkerLocal [_name, _pos];
					_mrk setMarkerTypeLocal _type;
					_mrk setMarkerColorLocal "ColorRed";
					_mrk setMarkerAlphaLocal 1;
					_mrk setMarkerTextLocal _text;
					_markers pushBack _name; 
				} forEach [["ClientMapUI_route_source", _posSrc, "mil_start", "Source"], ["ClientMapUI_route_dest", _posDst, "mil_end", "Destination"]];
			};

			// Draw lines
			for "_i" from 0 to (_count - 2) do {
				pr _mrkName = format ["ClientMapUI_route_%1", _i];
				pr _pos0 = _positions#_i;
				pr _pos1 = _positions#(_i+1);
				[_pos0, _pos1, "ColorRed", 66, _mrkName] call misc_fnc_mapDrawLineLocal;
				_markers pushBack _mrkName;
			};
		};
	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR(CLASS_NAME, "currentMapMarker", "");
SET_STATIC_VAR(CLASS_NAME, "campAllowed", true);
SET_STATIC_VAR(CLASS_NAME, "routeMarkers", []);
PUBLIC_STATIC_VAR(CLASS_NAME, "campAllowed");