#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\..\AI\Commander\CmdrAction\CmdrActionStates.hpp"
#include "..\Resources\MapUI\MapUI_Macros.h"
#include "ClientMapUI_Macros.h"
#include "..\..\Location\Location.hpp"
#include "..\Resources\UIProfileColors.h"
#include "..\..\PlayerDatabase\PlayerDatabase.hpp"

#define CLASS_NAME "ClientMapUI"
#define pr private

/*
	Class: ClientMapUI
	Singleton class that performs things related to map user interface
*/
CLASS(CLASS_NAME, "")

	// Array with markers which are currently under cursor, gets updated on mouse moving event handler
	VARIABLE("markersUnderCursor");
	
	VARIABLE("selectedGarrisonMarkers");
	VARIABLE("selectedLocationMarkers");

	// todo maybe redo THIS_ACTION_NAME
	STATIC_VARIABLE("campAllowed");

	// Position where the action listbox is going to be attached to
	VARIABLE("garActionPos");
	// True if the garrison action listbox is shown
	VARIABLE("garActionLBShown");
	VARIABLE("garActionGarRef");
	VARIABLE("garActionTargetType");
	VARIABLE("garActionTarget");

	// GarrisonSplitDialog OOP object
	VARIABLE("garSplitDialog");
	METHOD("onGarrisonSplitDialogDeleted") {
		params [P_THISOBJECT];
		T_SETV("garSplitDialog", "");
		T_CALLM0("updateHintTextFromContext");
	} ENDMETHOD;

	// Currently selected garrisons

	// Current garrison record which is selected. There can be many garrisons selected, but only one will have the manu under it drawn.
	VARIABLE("garSelMenuEnabled");
	VARIABLE("garRecordCurrent"); // Don't just set it manually, it's being set through funcs and event handlers
	VARIABLE("givingOrder"); // Bool, if true it means that we are giving order to a garrison. Current garrison record is garRecordCurrent

	// Bool, state of the intel button
	VARIABLE("showAllIntel");
	// Defines if we are sorting intel inversed or not
	VARIABLE("intelPanelSortInverse");
	// By which category we're going to sort the intel panel
	VARIABLE("intelPanelSortCategory");

	// Int, IDC of the control under the cursor, or -1
	VARIABLE("currentControlIDC");

	// initialize UI event handlers
	STATIC_METHOD("new") {
		params [["_thisObject", "", [""]]];

		// Markers under cursor
		T_SETV("markersUnderCursor", []);

		// Selected markers
		T_SETV("selectedGarrisonMarkers", []);
		T_SETV("selectedLocationMarkers", []);

		// garrison action variables
		T_SETV("garActionPos", [0 ARG 0 ARG 0]);
		T_SETV("garActionLBShown", false);
		T_SETV("garActionGarRef", "");
		T_SETV("garActionTargetType", 0);
		T_SETV("garActionTarget", 0);

		// garrison split dialog
		T_SETV("garSplitDialog", "");

		// Currently selected garrisons
		T_SETV("garRecordCurrent", "");
		T_SETV("garSelMenuEnabled", false);
		T_SETV("givingOrder", false);

		T_SETV("showAllIntel", false);
		T_SETV("intelPanelSortInverse", false);
		T_SETV("intelPanelSortCategory", "side");
		T_SETV("currentControlIDC", -1);

		pr _mapDisplay = findDisplay 12;

		// open map EH
		addMissionEventHandler ["Map", { 
		params ["_mapIsOpened", "_mapIsForced"]; if !(visibleMap) then { CALLM0(gClientMapUI, "onMapOpen"); }; }];
		
		//listbox events
		(_mapDisplay displayCtrl IDC_LOCP_LISTNBOX) ctrlAddEventHandler ["LBSelChanged", { CALLM(gClientMapUI, "intelPanelOnSelChanged", _this); }];
		(_mapDisplay displayCtrl IDC_LOCP_LISTNBOX) ctrlAddEventHandler ["LBDblClick", { CALLM(gClientMapUI, "intelPanelOnDblClick", _this); }];

		// = = = = = = Add event handlers = = = = = =

		// Map OnDraw
		// Gets called on each frame, only when the map is open
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["Draw", {CALLM0(gClientMapUI, "onMapDraw");} ]; // Mind this sh1t: https://feedback.bistudio.com/T123355

		// Map OnMouseMoving
		// Fires continuously while moving the mouse with a certain interval
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseMoving", {CALLM(gClientMapUI, "onMapMouseMoving", _this);} ]; // Mind this sh1t: https://feedback.bistudio.com/T123355


		// bottom panel
		// MouseEnter / MouseExit event handlers
		{
			(_mapDisplay displayCtrl _x) ctrlAddEventHandler ["MouseEnter", {CALLM(gClientMapUI, "onMouseEnter", _this); }];
			(_mapDisplay displayCtrl _x) ctrlAddEventHandler ["MouseExit", {CALLM(gClientMapUI, "onMouseExit", _this); }];
		} forEach [IDC_BPANEL_BUTTON_1, IDC_BPANEL_BUTTON_2, IDC_BPANEL_BUTTON_3, IDC_BPANEL_BUTTON_SHOW_INTEL, IDC_BPANEL_BUTTON_CLEAR_NOTIFICATIONS];

		// Button clicks
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_SHOW_INTEL) ctrlAddEventHandler ["ButtonClick", { CALLM(gClientMapUI, "onButtonClickShowIntel", _this); }];
		(_mapDisplay displayCtrl IDC_BPANEL_BUTTON_CLEAR_NOTIFICATIONS) ctrlAddEventHandler ["ButtonClick", { CALLM(gClientMapUI, "onButtonClickClearNotifications", _this); }];

		// location panel
		(_mapDisplay displayCtrl IDC_LOCP_TAB1) ctrlAddEventHandler ["MouseEnter", { CALLM(gClientMapUI, "onMouseEnter", _this); }];
		(_mapDisplay displayCtrl IDC_LOCP_TAB1) ctrlAddEventHandler ["MouseExit", { CALLM(gClientMapUI, "onMouseExit", _this); }];

		(_mapDisplay displayCtrl IDC_LOCP_TAB2) ctrlAddEventHandler ["MouseEnter", { CALLM(gClientMapUI, "onMouseEnter", _this); }];
		(_mapDisplay displayCtrl IDC_LOCP_TAB2) ctrlAddEventHandler ["MouseExit", { CALLM(gClientMapUI, "onMouseExit", _this); }];

		(_mapDisplay displayCtrl IDC_LOCP_TAB3) ctrlAddEventHandler ["MouseEnter", { CALLM(gClientMapUI, "onMouseEnter",_this); }];
		(_mapDisplay displayCtrl IDC_LOCP_TAB3) ctrlAddEventHandler ["MouseExit", { CALLM(gClientMapUI, "onMouseExit", _this); }];


		// = = = = = = Initialize default text = = = = = =

		// init headline text and color
		(_mapDisplay displayCtrl IDC_LOCP_HEADLINE) ctrlSetText format ["%1", (toUpper worldName)];
		(_mapDisplay displayCtrl IDC_LOCP_HEADLINE) ctrlSetBackgroundColor MUIC_COLOR_BLACK;

		// set some properties that didn't work right in control classes
		(_mapDisplay displayCtrl IDC_LOCP_TABCAT) ctrlSetFont "PuristaSemiBold";


		//  = = = = = = = = Add event handlers to the map = = = = = = = = 

		// Mouse button down
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonDown", {
			//params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			CALLM(gClientMapUI, "onMouseButtonDown", _this);
		}];

		// Mouse button up
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonUp", {
			//params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			CALLM(gClientMapUI, "onMouseButtonUp", _this);
		}];

		// Mouse button click
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonClick", {
			//params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			CALLM(gClientMapUI, "onMouseButtonClick", _this);
		}];


		//  = = = = = = = = Create garrison action list box = = = = = = = =

		// Appears when we are about to give an order to a garrison
		// delete prev controls
		ctrlDelete ((finddisplay 12) displayCtrl IDC_GCOM_ACTION_MENU_GROUP);
		pr _bg = ((finddisplay 12)) ctrlCreate ["CMUI_GCOM_ACTION_LISTBOX_BG", IDC_GCOM_ACTION_MENU_GROUP]; // Background
		T_CALLM1("garActionMenuEnable", false);

		// Just a macro to give event handlers to buttons cause I'm LZ AF
		#define __GAR_ACTION_BUTTON_CLICK_EH(idc, buttonStr) ((findDisplay 12) displayCtrl idc) ctrlAddEventHandler ["ButtonClick", { \
				_thisObject = gClientMapUI; \
				CALLM1(_thisObject, "garActionLBOnButtonClick", buttonStr); \
			}]

		__GAR_ACTION_BUTTON_CLICK_EH(IDC_GCOM_ACTION_MENU_BUTTON_MOVE, "move");
		__GAR_ACTION_BUTTON_CLICK_EH(IDC_GCOM_ACTION_MENU_BUTTON_ATTACK, "attack");
		__GAR_ACTION_BUTTON_CLICK_EH(IDC_GCOM_ACTION_MENU_BUTTON_REINFORCE, "reinforce");
		__GAR_ACTION_BUTTON_CLICK_EH(IDC_GCOM_ACTION_MENU_BUTTON_CLOSE, "close");

		// = = = = = = = = = = = = = = = Create the selected garrison menu = = = = = = = = = = = 
		// It appears when we have selected a garrison
		// Delete prev controls
		ctrlDelete ((findDisplay 12) displayCtrl IDC_GSELECT_GROUP);
		(findDisplay 12) ctrlCreate ["CMUI_GSELECTED_MENU", IDC_GSELECT_GROUP];
		T_CALLM1("garSelMenuEnable", false);

		// Another lazy macro to give event handlers to buttons
		#define __GAR_SELECT_BUTTON_CLICK_EH(idc, buttonStr) ((findDisplay 12) displayCtrl idc) ctrlAddEventHandler ["ButtonClick", { \
				_thisObject = gClientMapUI; \
				CALLM1(_thisObject, "garSelMenuOnButtonClick", buttonStr); \
			}]

		__GAR_SELECT_BUTTON_CLICK_EH(IDC_GSELECT_BUTTON_SPLIT, "split");
		__GAR_SELECT_BUTTON_CLICK_EH(IDC_GSELECT_BUTTON_GIVE_ORDER, "order");
		__GAR_SELECT_BUTTON_CLICK_EH(IDC_GSELECT_BUTTON_CANCEL_ORDER, "cancelOrder");
		__GAR_SELECT_BUTTON_CLICK_EH(IDC_GSELECT_BUTTON_MERGE, "merge");
		
		// = = = = = = = = = = = = = = = Create the listbox buttons = = = = = = = = = = = = = = =
		pr _ctrlGroup = _mapDisplay displayCtrl IDC_LOCP_LISTNBOX_BUTTONS_GROUP; 
		pr _btns = [_mapDisplay, "MUI_BUTTON_TXT", IDC_LOCP_LISTNBOX_BUTTONS_0, _ctrlGroup, [0.0, 0.25, 0.75], true] call ui_fnc_createButtonsInGroup;
		_btns#0 ctrlSetText "Side";
		_btns#1 ctrlSetText "Type";
		_btns#2 ctrlSetText "Time";

		_btns#0 ctrlAddEventHandler ["ButtonClick", {
			CALLM1(gClientMapUI, "intelPanelOnSortButtonClick", "side");
		}];
		_btns#1 ctrlAddEventHandler ["ButtonClick", {
			CALLM1(gClientMapUI, "intelPanelOnSortButtonClick", "type");
		}];
		_btns#2 ctrlAddEventHandler ["ButtonClick", {
			CALLM1(gClientMapUI, "intelPanelOnSortButtonClick", "time");
		}];


		// Mouse moving
		// Probably we don't need it now
		/*
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

	} ENDMETHOD;

	/*                                           
88b           d88  88   ad88888ba     ,ad8888ba,   
888b         d888  88  d8"     "8b   d8"'    `"8b  
88`8b       d8'88  88  Y8,          d8'            
88 `8b     d8' 88  88  `Y8aaaaa,    88             
88  `8b   d8'  88  88    `"""""8b,  88             
88   `8b d8'   88  88          `8b  Y8,            
88    `888'    88  88  Y8a     a8P   Y8a.    .a8P  
88     `8'     88  88   "Y88888P"     `"Y8888Y"'   
http://patorjk.com/software/taag/#p=display&f=Univers&t=MISC
	*/

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

	// Shows/hides all map representations of intel
	METHOD("mapShowAllIntel") {
		params [P_THISOBJECT, P_BOOL("_show")];
		private _allIntels = CALLM0(gIntelDatabaseClient, "getAllIntel");
		// forEach _allIntels;
		{
			private _className = GET_OBJECT_CLASS(_x);
			if (_className != "IntelLocation") then { // Add all non-location intel classes
				CALLM1(_x, "showOnMap", _show);
			};
		} forEach _allIntels;
	} ENDMETHOD;

/*                                                                      
ooooooooo  oooooooooo       o  oooo     oooo      oooooooooo    ooooooo  ooooo  oooo ooooooooooo ooooooooooo 
 888    88o 888    888     888  88   88  88        888    888 o888   888o 888    88  88  888  88  888    88  
 888    888 888oooo88     8  88  88 888 88         888oooo88  888     888 888    88      888      888ooo8    
 888    888 888  88o     8oooo88  888 888          888  88o   888o   o888 888    88      888      888    oo  
o888ooo88  o888o  88o8 o88o  o888o 8   8          o888o  88o8   88ooo88    888oo88      o888o    o888ooo8888 

http://patorjk.com/software/taag/#p=display&f=O8&t=DRAW%20ROUTE
*/

	#define __MRK_ROUTE "_route_"
	#define __MRK_SOURCE "_src"
	#define __MRK_DEST "_dst"
	// Draws or undraws a route for a given array of positions
	STATIC_METHOD("drawRoute") {
		params ["_thisClass", ["_posArray", [], [[]]], "_uniqueString", ["_enable", false, [false]], ["_cycle", false, [false]], ["_drawSrcDest", false, [false]] ];

		// Delete all previosly created markers
		pr _query = _uniqueString+__MRK_ROUTE;
		{
			deleteMarkerLocal _x;
		} forEach (allMapMarkers select { _x find _query == 0 });

		pr _markers = [];
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
				} forEach [[_uniqueString+__MRK_ROUTE+__MRK_SOURCE, _posSrc, "mil_start", "Source"], [_uniqueString+__MRK_ROUTE+__MRK_DEST, _posDst, "mil_end", "Destination"]];
			};

			// Draw lines
			for "_i" from 0 to (_count - 2) do {
				pr _mrkName = _uniqueString + __MRK_ROUTE + (str _i);
				pr _pos0 = _positions#_i;
				pr _pos1 = _positions#(_i+1);
				[_pos0, _pos1, "ColorRed", 15, _mrkName] call misc_fnc_mapDrawLineLocal;
				_markers pushBack _mrkName;
			};
		};

		_markers
	} ENDMETHOD;


/*
ooooo ooooo ooooo oooo   oooo ooooooooooo      ooooooooooo ooooooooooo ooooo  oooo ooooooooooo 
 888   888   888   8888o  88  88  888  88      88  888  88  888    88    888  88   88  888  88 
 888ooo888   888   88 888o88      888              888      888ooo8        888         888     
 888   888   888   88   8888      888              888      888    oo     88 888       888     
o888o o888o o888o o88o    88     o888o            o888o    o888ooo8888 o88o  o888o    o888o    

http://patorjk.com/software/taag/#p=display&f=O8&t=HINT%20TEXT
*/

	// Sets hint text at the bottom of the screen
	METHOD("setHintText") {
		params [P_THISOBJECT, P_STRING("_text")];
		((finddisplay 12) displayCtrl IDC_BPANEL_HINTS) ctrlSetText _text; // (localize "STR_CMUI_BUTTON1");
	} ENDMETHOD;

	// Updates the hint text based on the current context
	METHOD("updateHintTextFromContext") {
		params [P_THISOBJECT];

		//pr _markersUnderCursor = 	CALL_STATIC_METHOD("MapMarkerLocation", "getMarkersUnderCursor", [_displayorcontrol ARG _xPos ARG _yPos]) +
		//							CALL_STATIC_METHOD("MapMarkerGarrison", "getMarkersUnderCursor", [_displayorcontrol ARG _xPos ARG _yPos]);

		pr _selectedGarrisons = CALLSM0("MapMarkerGarrison", "getAllSelected");
		pr _selectedLocations = CALLSM0("MapMarkerLocation", "getAllSelected");

		if (T_GETV("garActionLBShown")) exitWith {
			T_CALLM1("setHintText", "Select the order to give to this garrison");
		};

		if (T_GETV("givingOrder")) exitWith {
			T_CALLM1("setHintText", "Left-click on the map to set destination");
		};
		
		if (T_GETV("garSplitDialog") != "") exitWith {
			T_CALLM1("setHintText", "Choose composition of the new garrison on the right column and push the 'Split' button");
		};

		if (count _selectedGarrisons >= 1) exitWith {
			T_CALLM1("setHintText", "Use the menu to perform actions on the selected garrison");
		};

		pr _idc = T_GETV("currentControlIDC");
		if (_idc != -1) exitWith {
			if (ctrlEnabled (_mapDisplay displayCtrl _idc)) then {
				switch (_idc) do {
					// bottom panel
					case IDC_BPANEL_BUTTON_1: { T_CALLM1("setHintText", localize "STR_CMUI_BUTTON1"); };
					case IDC_BPANEL_BUTTON_2: { T_CALLM1("setHintText", localize "STR_CMUI_BUTTON2"); };
					case IDC_BPANEL_BUTTON_3: { T_CALLM1("setHintText", localize "STR_CMUI_BUTTON3"); };

					// location panel
					case IDC_LOCP_TAB1: { T_CALLM1("setHintText", localize "STR_CMUI_TAB1"); };
					case IDC_LOCP_TAB2: { T_CALLM1("setHintText", localize "STR_CMUI_TAB2"); };
					case IDC_LOCP_TAB3: { T_CALLM1("setHintText", localize "STR_CMUI_TAB3"); };
				};
			} else { // hints to display if this control is disabled
				switch (_idc) do {
					// bottom panel
					case IDC_BPANEL_BUTTON_1: { T_CALLM1("setHintText", localize "STR_CMUI_BUTTON1_DISABLED"); };
					case IDC_BPANEL_BUTTON_2: { T_CALLM1("setHintText", localize "STR_CMUI_BUTTON2_DISABLED"); };
					case IDC_BPANEL_BUTTON_3: { T_CALLM1("setHintText", localize "STR_CMUI_BUTTON3_DISABLED"); };

					// location panel
					case IDC_LOCP_TAB1: { T_CALLM1("setHintText", localize "STR_CMUI_TAB1"); };
					case IDC_LOCP_TAB2: { T_CALLM1("setHintText", localize "STR_CMUI_TAB2"); };
					case IDC_LOCP_TAB3: { T_CALLM1("setHintText", localize "STR_CMUI_TAB3"); };
				};
			};
		};

		T_CALLM1("setHintText", "... Hints are displayed here ...");

	} ENDMETHOD;

/*                                                                                                                                       
     o       oooooooo8 ooooooooooo ooooo  ooooooo  oooo   oooo      oooo     oooo ooooooooooo oooo   oooo ooooo  oooo 
    888    o888     88 88  888  88  888 o888   888o 8888o  88        8888o   888   888    88   8888o  88   888    88  
   8  88   888             888      888 888     888 88 888o88        88 888o8 88   888ooo8     88 888o88   888    88  
  8oooo88  888o     oo     888      888 888o   o888 88   8888        88  888  88   888    oo   88   8888   888    88  
o88o  o888o 888oooo88     o888o    o888o  88ooo88  o88o    88       o88o  8  o88o o888ooo8888 o88o    88    888oo88   
                                                                     
Methods for the action listbox appears when we click on something to send some garrison do something
*/

	// Enables or disables the garrison action listbox
	METHOD("garActionMenuEnable") {
		params [P_THISOBJECT, P_BOOL("_enable")];

		// Move it away if we don't need to see it any more
		pr _ctrl = (findDisplay 12) displayCtrl IDC_GCOM_ACTION_MENU_GROUP;
		_ctrl ctrlShow _enable;

		T_SETV("garActionLBShown", _enable);

		if (_enable) then {
			// Enable or disable certain action buttons depending on the selected target
			pr _idcs = [
							IDC_GCOM_ACTION_MENU_BUTTON_MOVE,
							IDC_GCOM_ACTION_MENU_BUTTON_ATTACK,
							IDC_GCOM_ACTION_MENU_BUTTON_REINFORCE,
							IDC_GCOM_ACTION_MENU_BUTTON_PATROL
						];
			pr _enBools = switch (T_GETV("garActionTargetType")) do {
				case TARGET_TYPE_GARRISON: {
					[	true,
						false,
						true,
						false]
				};
				case TARGET_TYPE_LOCATION: {
					[	true,
						true,
						true,
						false]
				};
				case TARGET_TYPE_POSITION: {
					[	true,
						true,
						false,
						false]
				};
				default {
					[	false,
						false,
						false,
						false]
				};
			};
			{
				((finddisplay 12) displayCtrl (_idcs#_foreachindex)) ctrlEnable _x;
			} forEach _enBools;
		};

		T_CALLM0("updateHintTextFromContext");
	} ENDMETHOD;

	// Sets the position of the garrison action listbox
	METHOD("garActionMenuSetPos") {
		params [P_THISOBJECT, P_POSITION("_pos")];
		T_SETV("garActionPos", _pos);
	} ENDMETHOD;

	METHOD("garActionMenuUpdatePos") {
		params [P_THISOBJECT];
		// Move the garrison action listbox if needed
		if (T_GETV("garActionLBShown")) then {
			pr _posWorld = T_GETV("garActionPos");
			pr _posScreen = ((findDisplay 12) displayCtrl IDC_MAP) posWorldToScreen _posWorld; //[_posWorld#0, _posWorld#1];
			pr _ctrl = (findDisplay 12) displayCtrl IDC_GCOM_ACTION_MENU_GROUP;
			pr _pos = ctrlPosition _ctrl;
			_ctrl ctrlSetPosition [_posScreen#0, _posScreen#1, _pos#2, _pos#3];
			_ctrl ctrlCommit 0;
		};
	} ENDMETHOD;

	// The selection in a listbox is changed.
	METHOD("garActionLBOnButtonClick") {
		params [P_THISOBJECT, "_action"];

		// Sanity checks
		if (!T_GETV("garActionLBShown")) exitWith {};
		if (T_GETV("garActionTargetType") == TARGET_TYPE_INVALID) exitWith {};

		switch (_action) do {
			case "move" : {
				pr _AI = CALLSM("AICommander", "getCommanderAIOfSide", [playerSide]);
				// Although it's on another machine, messageReceiver class will route the message for us
				pr _args = [T_GETV("garActionGarRef"), T_GETV("garActionTargetType"), T_GETV("garActionTarget")];
				CALLM2(_AI, "postMethodAsync", "clientCreateMoveAction", _args);
				systemChat "Giving a MOVE order to garrison";
			};
			case "attack" : {
				pr _AI = CALLSM("AICommander", "getCommanderAIOfSide", [playerSide]);
				// Although it's on another machine, messageReceiver class will route the message for us
				pr _args = [T_GETV("garActionGarRef"), T_GETV("garActionTargetType"), T_GETV("garActionTarget")];
				CALLM2(_AI, "postMethodAsync", "clientCreateAttackAction", _args);
				systemChat "Giving an ATTACK order to garrison";
			};
			case "reinforce" : {
				pr _AI = CALLSM("AICommander", "getCommanderAIOfSide", [playerSide]);
				// Although it's on another machine, messageReceiver class will route the message for us
				pr _args = [T_GETV("garActionGarRef"), T_GETV("garActionTargetType"), T_GETV("garActionTarget")];
				CALLM2(_AI, "postMethodAsync", "clientCreateReinforceAction", _args);
				systemChat "Giving a REINFORCE order to garrison";
			};
			case "patrol" : {
				OOP_INFO_1("  %1 garrison action is not implemented", _lbData);
				systemChat "This garrison order is not yet implemented";
			};
			case "close" : {
				// Do nothing, it will just close itself
			};
			default {
				OOP_ERROR_1("unknown garrison action: %1", _lbData);
			};
		};

		// Close the LB
		T_CALLM1("garActionMenuEnable", false);

		// We are not giving order any more, stop drawing the arrow
		T_SETV("givingOrder", false);

		T_CALLM0("updateHintTextFromContext");
	} ENDMETHOD;










/*                                                                                                  
  ooooooo8      o      oooooooooo  oooooooooo  ooooo  oooooooo8    ooooooo  oooo   oooo       
o888    88     888      888    888  888    888  888  888         o888   888o 8888o  88        
888    oooo   8  88     888oooo88   888oooo88   888   888oooooo  888     888 88 888o88        
888o    88   8oooo88    888  88o    888  88o    888          888 888o   o888 88   8888        
 888ooo888 o88o  o888o o888o  88o8 o888o  88o8 o888o o88oooo888    88ooo88  o88o    88        
                                                                                              
 oooooooo8 ooooooooooo ooooo       ooooooooooo  oooooooo8 ooooooooooo ooooooooooo ooooooooo   
888         888    88   888         888    88 o888     88 88  888  88  888    88   888    88o 
 888oooooo  888ooo8     888         888ooo8   888             888      888ooo8     888    888 
        888 888    oo   888      o  888    oo 888o     oo     888      888    oo   888    888 
o88oooo888 o888ooo8888 o888ooooo88 o888ooo8888 888oooo88     o888o    o888ooo8888 o888ooo88   
                                                                                              
oooo     oooo ooooooooooo oooo   oooo ooooo  oooo                                             
 8888o   888   888    88   8888o  88   888    88                                              
 88 888o8 88   888ooo8     88 888o88   888    88                                              
 88  888  88   888    oo   88   8888   888    88                                              
o88o  8  o88o o888ooo8888 o88o    88    888oo88     

http://patorjk.com/software/taag/#p=author&f=O8&t=GARRISON%0ASELECTED%0AMENU
*/

	METHOD("garSelMenuEnable") {
		params [P_THISOBJECT, P_BOOL("_enable")];

		T_SETV("garSelMenuEnabled", _enable);
		((findDisplay 12) displayCtrl IDC_GSELECT_GROUP) ctrlShow _enable;

		if (!_enable) then {	
			T_SETV("garRecordCurrent", "");
		};

		// Check if we can command garrisons at all
		pr _canCommand = CALLM1(gPlayerDatabaseClient, "get", PDB_KEY_ALLOW_COMMAND_GARRISONS);
		if (isNil "_canCommand") then {_canCommand = false; };
		if (!_canCommand) then {
			{
				((findDisplay 12) displayCtrl _x) ctrlEnable false;
				((findDisplay 12) displayCtrl _x) ctrlSetTooltip "You don't have permissions to command garrisons";
			} forEach [IDC_GSELECT_BUTTON_SPLIT, IDC_GSELECT_BUTTON_MERGE, IDC_GSELECT_BUTTON_GIVE_ORDER, IDC_GSELECT_BUTTON_CANCEL_ORDER];
		} else {
			((findDisplay 12) displayCtrl IDC_GSELECT_BUTTON_MERGE) ctrlEnable false;
			((findDisplay 12) displayCtrl IDC_GSELECT_BUTTON_MERGE) ctrlSetTooltip "NYI";
			{
				((findDisplay 12) displayCtrl _x) ctrlEnable true;
				((findDisplay 12) displayCtrl _x) ctrlSetTooltip "";
			} forEach [IDC_GSELECT_BUTTON_SPLIT, IDC_GSELECT_BUTTON_GIVE_ORDER, IDC_GSELECT_BUTTON_CANCEL_ORDER];
		};

		T_CALLM0("updateHintTextFromContext");
	} ENDMETHOD;

	METHOD("garSelMenuSetGarRecord") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];
		T_SETV("garRecordCurrent", _garRecord);
	} ENDMETHOD;

	// Called on each map draw event to update the position
	METHOD("garSelMenuUpdatePos") {
		params [P_THISOBJECT];

		if (T_GETV("garSelMenuEnabled")) then {
			pr _garRecord = T_GETV("garRecordCurrent");
			
			// Make sure the garrison record is not destroyed
			if (!IS_OOP_OBJECT(_garRecord)) exitWith {
				T_SETV("garRecordCurrent", "");
				T_CALLM1("garSelMenuEnable", false);
			};

			// Update the position of the group control
			pr _posWorld = CALLM0(_garRecord, "getPos");
			
			pr _posScreen = ((findDisplay 12) displayCtrl IDC_MAP) posWorldToScreen _posWorld;
			_posScreen params ["_xScreen", "_yScreen"];
			pr _ctrl = ((findDisplay 12) displayCtrl IDC_GSELECT_GROUP);
			pr _pos = ctrlPosition _ctrl;
			_ctrl ctrlSetPosition [_xScreen - GSELECT_MENU_WIDTH/2, _yScreen + 0.04, _pos#2, _pos#3]; // We offset the control left and down a bit
			_ctrl ctrlCommit 0;
		};

	} ENDMETHOD;

	// Gets called when user clicks on one of these buttons
	METHOD("garSelMenuOnButtonClick") {
		params [P_THISOBJECT, P_STRING("_button")];

		pr _garRecord = T_GETV("garRecordCurrent");
		if (!IS_OOP_OBJECT(_garRecord)) exitWith { // Make sure it's not destroyed
			// Just close everything if there is no such garrison record any more
			T_CALLM1("garSelMenuSetGarRecord", "");
			T_CALLM1("garSelMenuEnable", false);
		};

		// So far _garRecord is valid
		switch(_button) do {

			// Open the 'split garrison' dialog
			case "split" : {
				if (T_GETV("garSplitDialog") == "") then {
					pr _garSplitDialog = CALLSM1("GarrisonSplitDialog", "newInstance", _garRecord);
					T_SETV("garSplitDialog", _garSplitDialog);					
				};
				// Abort giving order if we were giving order
				if (T_GETV("givingOrder")) then {
					T_CALLM1("garActionMenuEnable", false);
					T_SETV("givingOrder", false);
				};
			};

			// Activate the 
			case "order" : {
				// Abort giving order if we were giving order
				// Start giving order if we were not
				pr _givingOrder = T_GETV("givingOrder");
				T_SETV("givingOrder", !_givingOrder);
				if (_givingOrder) then {
					T_CALLM1("garActionMenuEnable", false);
				};
			};
			case "cancelOrder" : {
				pr _AI = CALLSM("AICommander", "getCommanderAIOfSide", [playerSide]);
				// Although it's on another machine, messageReceiver class will route the message for us
				pr _garRef = CALLM0(_garRecord, "getGarrison");
				pr _args = [_garRef];
				CALLM2(_AI, "postMethodAsync", "cancelCurrentAction", [_garRef]);
				systemChat "Cancelling the current order of the garrison";
			};
			default {
				// Do nothing
			};
		};

		T_CALLM0("updateHintTextFromContext");
	} ENDMETHOD;


	/*
	ooooo oooo   oooo ooooooooooo ooooooooooo ooooo            oooooooooo   o      oooo   oooo ooooooooooo ooooo       
	888   8888o  88  88  888  88  888    88   888              888    888 888      8888o  88   888    88   888        
	888   88 888o88      888      888ooo8     888              888oooo88 8  88     88 888o88   888ooo8     888        
	888   88   8888      888      888    oo   888      o       888      8oooo88    88   8888   888    oo   888      o 
	o888o o88o    88     o888o    o888ooo8888 o888ooooo88      o888o   o88o  o888o o88o    88  o888ooo8888 o888ooooo88 

	http://patorjk.com/software/taag/#p=display&f=O8&t=INTEL%20PANEL
	*/

	METHOD("intelPanelUpdateFromGarrisonRecord") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord"), ["_clear", true]];

		OOP_INFO_1("intelPanelUpdateFromGarrisonRecord: %1", _garRecord);

		// Bail if garrison record is destroyed
		if (!IS_OOP_OBJECT(_garRecord)) exitWith {
			OOP_INFO_0("Garrison record is destroyed");
		};

		pr _lnb =(findDisplay 12) displayCtrl IDC_LOCP_LISTNBOX;
		if (_clear) then { T_CALLM0("intelPanelClear"); };
		_lnb lnbSetColumnsPos [0, 0.2];

		pr _comp = CALLM0(_garRecord, "getComposition");
		OOP_INFO_1("Composition: %1", _comp);
		{
			pr _catID = _foreachindex;
			{
				pr _subcatID = _forEachIndex;
				pr _classes = _x; // Array with IDs of classes
				if (count _classes > 0) then {
					pr _name = T_NAMES#_catID#_subcatID;
					_lnb lnbAddRow [str (count _classes), _name];
				};
			} forEach _x;
		} forEach _comp;
	} ENDMETHOD;

	METHOD("intelPanelUpdateFromLocationIntel") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intel"), ["_clear", true], ["_showComposition", true]];

		OOP_INFO_1("intelPanelUpdateFromLocationIntel: %1", _intel);

		// Bail if this intel item is removed for some reason
		if (!CALLM1(gIntelDatabaseClient, "isIntelAdded", _intel)) exitWith {
			OOP_INFO_0("Intel doesn't exist");
		};

		pr _lnb =(findDisplay 12) displayCtrl IDC_LOCP_LISTNBOX;
		if (_clear) then { T_CALLM0("intelPanelClear"); };
		_lnb lnbSetColumnsPos [0, 0.2];

		pr _typeText = "";
		pr _timeText = "";
		pr _sideText = "";
		pr _soldierCount = 0;
		pr _vehList = [];
		
		_typeText = CALLSM1("Location", "getTypeString", GETV(_intel, "type"));
		
		_timeText = str GETV(_intel, "dateUpdated");
		_sideText = str GETV(_intel, "side");

		// Apply new text for GUI elements
		private _mapDisplay = findDisplay 12;
		//(_mapDisplay displayCtrl IDC_LOCP_DETAILTXT) ctrlSetText "";
		_lnb lnbSetCurSelRow -1;
		_lnb lnbAddRow [ "Type:", _typeText];
		_lnb lnbAddRow [ "Side:", _sideText];

		pr _ua = GETV(_intel, "unitData");
		if (count _ua > 0 && _showComposition) then {
			_compositionText = "";
			// Amount of infrantry
			{_soldierCount = _soldierCount + _x;} forEach (_ua select T_INF);
			_lnb lnbAddRow [ str _soldierCount, "Soldiers" ];

			// Count vehicles
			pr _uaveh = _ua select T_VEH;
			{
				// If there are some vehicles of this subcategory
				if (_x > 0) then {
					pr _subcatID = _forEachIndex;
					pr _vehName = T_NAMES select T_VEH select _subcatID;
					_lnb lnbAddRow [str _x, _vehName];
				};
			} forEach _uaveh;
		};
	} ENDMETHOD;

	METHOD("intelPanelClear") {
		params [P_THISOBJECT];
		pr _lnb =(findDisplay 12) displayCtrl IDC_LOCP_LISTNBOX;
		lnbClear _lnb;
	} ENDMETHOD;

	METHOD("intelPanelDeselect") {
		params [P_THISOBJECT];
		pr _lnb =(findDisplay 12) displayCtrl IDC_LOCP_LISTNBOX;
		_lnb lnbSetCurSelRow -1;
	} ENDMETHOD;

	METHOD("intelPanelUpdateFromIntel") {
		params [P_THISOBJECT, ["_clear", true]];
		
		private _allIntels = CALLM0(gIntelDatabaseClient, "getAllIntel");
		OOP_INFO_1("ALL INTEL: %1", _allIntels);
		pr _lnb =(findDisplay 12) displayCtrl IDC_LOCP_LISTNBOX;
		_lnb lnbSetColumnsPos [0, 0.2, 0.7];
		if (_clear) then { T_CALLM0("intelPanelClear"); };
		// forEach _allIntels;
		{
			pr _intel = _x;
			pr _className = GET_OBJECT_CLASS(_intel);
			if (_className != "IntelLocation") then { // Add all non-location intel classes
				pr _shortName = CALLM0(_intel, "getShortName");

				// Calculate time difference between current date and departure date
				pr _dateDeparture = GETV(_intel, "dateDeparture");
				pr _dateNow = date;
				pr _numberDiff = (_dateDeparture call misc_fnc_dateToNumber) - (date call misc_fnc_dateToNumber);
				pr _activeStr = "";
				pr _futureEvent = true;
				if (_numberDiff < 0) then {
					_activeStr = "active ";
					_numberDiff = -_numberDiff;
					_futureEvent = false;
				};
				pr _dateDiff = numberToDate [_dateNow#0, _numberDiff];
				_dateDiff params ["_y", "_m", "_d", "_h", "_m"];
				
				// Make a string representation of time difference
				pr _timeDiffStr = if (_h > 0) then {
					format ["%1H, %2M", _h, _m]
				} else {
					format ["%1M", _m]
				};

				// Make a string representation of side
				pr _side = GETV(_intel, "side");
				_sideStr  = switch (_side) do {
					case WEST: {"WEST"};
					case EAST: {"EAST"};
					case independent: {"IND"};
					default {"ALIEN"};
				};

				pr _rowStr = format ["%1 %2", _shortName, _activeStr];
				pr _rowData = [_sideStr, _rowStr, _timeDiffStr];
				pr _index = _lnb lnbAddRow _rowData;
				_lnb lnbSetData [[_index, 0], _intel];

				// Set values for sorting
				pr _valueSide = [WEST, EAST, INDEPENDENT] find _side; // Enumerate side
				pr _valueType = [	"IntelCommanderActionReinforce",
									"IntelCommanderActionBuild", "IntelCommanderActionAttack",
									"IntelCommanderActionPatrol", "IntelCommanderActionRetreat",
									"IntelCommanderActionRecon"] find _className; // Enumerate class name
				pr _valueTime = _m + _h*60 + _d*24*60 + _m*30*24*60;
				if (!_futureEvent) then {_valueTime = -_valueTime; };

				_lnb lnbSetValue [[_index, 0], _valueSide];
				_lnb lnbSetValue [[_index, 1], _valueType];
				_lnb lnbSetValue [[_index, 2], _valueTime];

				//OOP_INFO_1("ADDED ROW: %1", _rowData);
			};
		} forEach _allIntels;
	} ENDMETHOD;

	/*
		Method: intelPanelOnSelChanged
		Description: Called when the selection inside the listbox has changed.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	METHOD("intelPanelOnSelChanged") {
		params [P_THISOBJECT, "_lnb"];

		// We only care if nothing is selected
		if ( (count T_GETV("selectedLocationMarkers") == 0) && (count T_GETV("selectedGarrisonMarkers") == 0) ) then {
			pr _row = lnbCurSelRow _lnb;
			if (_row >= 0) then {
				pr _intel = _lnb lnbData [_row, 0];
				// Make sure that's a valid intel piece
				if (CALLM1(gIntelDatabaseClient, "isIntelAdded", _intel)) then {
					// Hide all intel on the map, except for this one
					T_CALLM1("mapShowAllIntel", false);
					CALLM1(_intel, "showOnMap", true);
				};
			} else {
				T_CALLM1("mapShowAllIntel", T_GETV("showAllIntel"));
			};
		};

	} ENDMETHOD;

	METHOD("intelPanelOnDblClick") {
		params [P_THISOBJECT, "_lnb", "_index"];

		if (_index != -1) then {
			// Zoom into the area of this intel
			pr _intel = _lnb lnbData [_index, 0];
			pr _zoomPos = CALLM0(_intel, "getMapZoomPos");
			pr _ctrl = ((finddisplay 12) displayCtrl 51);
			_ctrl ctrlMapAnimAdd [0.3, 0.06, _zoomPos];
			ctrlMapAnimCommit _ctrl;
		};
		
	} ENDMETHOD;

	// Hides or shows the sort-by-... buttons
	METHOD("intelPanelShowButtons") {
		params [P_THISOBJECT, P_BOOL("_show")];

		// Show buttons
		{
			((findDisplay 12) displayCtrl _x) ctrlShow _show;
		} forEach [	IDC_LOCP_LISTNBOX_BUTTONS_GROUP,
					IDC_LOCP_LISTNBOX_BUTTONS_0,
					IDC_LOCP_LISTNBOX_BUTTONS_1,
					IDC_LOCP_LISTNBOX_BUTTONS_2];

		// Hide panel behind it or whatever it is
		{
			((findDisplay 12) displayCtrl _x) ctrlShow !_show;
		} forEach [IDC_LOCP_TABCAT];
		
	} ENDMETHOD;

	METHOD("intelPanelSortIntel") {
		params [P_THISOBJECT, P_STRING("_category"), P_BOOL("_inverse")];
		pr _col = ["side", "type", "time"] find _category;
		if (_col != -1) then {
			pr _lnb =(findDisplay 12) displayCtrl IDC_LOCP_LISTNBOX;
			pr _row = lnbCurSelRow _lnb;
			if (_row != -1) then {
				// Try to select the proper row after sorting again
				pr _oldRowData = _lnb lnbData [_row, 0];
				_lnb lnbSortByValue [_col, _inverse];
				(lnbSize _lnb) params ["_nRows", "_nCols"];
				for "_i" from 0 to (_nRows - 1) do {
					if ((_lnb lnbData [_i, 0]) == _oldRowData) exitWith {
						_lnb lnbSetCurSelRow _i;
					};
				};
			}else { 
				_lnb lnbSortByValue [_col, _inverse];
			};
		};
	} ENDMETHOD;

	METHOD("intelPanelOnSortButtonClick") {
		params [P_THISOBJECT, P_STRING("_button")];
		pr _inverse = !T_GETV("intelPanelSortInverse");
		T_CALLM2("intelPanelSortIntel", _button, _inverse); // _button - "side", "type", "time"
		T_SETV("intelPanelSortInverse", _inverse);
		T_SETV("intelPanelSortCategory", _button);
	} ENDMETHOD;

/*                                                                                                        
ooooooooooo ooooo  oooo ooooooooooo oooo   oooo ooooooooooo                                    
 888    88   888    88   888    88   8888o  88  88  888  88                                    
 888ooo8      888  88    888ooo8     88 888o88      888                                        
 888    oo     88888     888    oo   88   8888      888                                        
o888ooo8888     888     o888ooo8888 o88o    88     o888o                                       
                                                                                               
ooooo ooooo      o      oooo   oooo ooooooooo  ooooo       ooooooooooo oooooooooo   oooooooo8  
 888   888      888      8888o  88   888    88o 888         888    88   888    888 888         
 888ooo888     8  88     88 888o88   888    888 888         888ooo8     888oooo88   888oooooo  
 888   888    8oooo88    88   8888   888    888 888      o  888    oo   888  88o           888 
o888o o888o o88o  o888o o88o    88  o888ooo88  o888ooooo88 o888ooo8888 o888o  88o8 o88oooo888  

http://patorjk.com/software/taag/#p=display&f=O8&t=EVENT%0AHANDLERS
*/



	/*
  ooooooo  oooo   oooo      oooo     oooo oooooooooo       ooooooooo     ooooooo  oooo     oooo oooo   oooo 
o888   888o 8888o  88        8888o   888   888    888       888    88o o888   888o 88   88  88   8888o  88  
888     888 88 888o88        88 888o8 88   888oooo88        888    888 888     888  88 888 88    88 888o88  
888o   o888 88   8888        88  888  88   888    888       888    888 888o   o888   888 888     88   8888  
  88ooo88  o88o    88       o88o  8  o88o o888ooo888       o888ooo88     88ooo88      8   8     o88o    88  

	Method: onMouseButtonDown
	Gets called when user clicks on the map. There might be map markers under cursor and it will still be called.

	Returns: nil
	*/
	METHOD("onMouseButtonDown") {
		params [P_THISOBJECT, "_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

		OOP_INFO_1("ON MOUSE BUTTON DOWN: %1", _this);

		// Ignore right clicks for now
		if (_button == 1) exitWith {};

		/*
		Contexts to filter:
		Click anywhere AND givingOrder == true
		Click anywhere AND with an alt AND one garrison marker has been selected before
		We click on a location marker, No location markers have been selected before
		*/

		pr _garrisonsUnderCursor = CALL_STATIC_METHOD("MapMarkerGarrison", "getMarkersUnderCursor", [_displayorcontrol ARG _xPos ARG _yPos]);
		pr _locationsUnderCursor = CALL_STATIC_METHOD("MapMarkerLocation", "getMarkersUnderCursor", [_displayorcontrol ARG _xPos ARG _yPos]);
		pr _markersUnderCursor = _garrisonsUnderCursor + _locationsUnderCursor;
									

		OOP_INFO_1("MARKERS UNDER CURSOR: %1", _markersUnderCursor);

		pr _selectedGarrisons = CALLSM0("MapMarkerGarrison", "getAllSelected");
		pr _selectedLocations = CALLSM0("MapMarkerLocation", "getAllSelected");
		OOP_INFO_1("SELECTED GARRISONS: %1", _selectedGarrisons);
		OOP_INFO_1("SELECTED LOCATIONS: %1", _selectedLocations);

		// Click anywhere AND givingOrder == true
		// We want to give a waypoint/order to this garrison
		if (T_GETV("givingOrder")) exitWith {
			OOP_INFO_0("GIVING ORDER TO GARRISON...");
			// Make sure we have the rights to command garrisons
			pr _garRecord = T_GETV("garRecordCurrent"); // Get GarrisonRecord
			pr _gar = CALLM0(_garRecord, "getGarrison"); // Ref to an actual garrison at the server

			// Get position where to move to, it depends on what we actually click at
			pr _targetType = TARGET_TYPE_INVALID; // Target type and the target where to move to, see CmdrAITarget.sqf
			pr _target = 0;
			pr _targetPos = [0, 0, 0];

			if (count _markersUnderCursor > 0) then {
				pr _destMarker = _markersUnderCursor#0;
				switch (GET_OBJECT_CLASS(_destMarker)) do {
					case "MapMarkerLocation" : {
						_targetType = TARGET_TYPE_LOCATION;
						pr _intel = CALLM0(_destMarker, "getIntel");
						_target = GETV(_intel, "location");
						OOP_INFO_1("	target: location %1", _target);
						_targetPos = +CALLM0(_target, "getPos");
					};
					case "MapMarkerGarrison" : {
						pr _dstGarRecord = CALLM0(_destMarker, "getGarrisonRecord");
						if (_dstGarRecord == _garRecord) then {
							OOP_INFO_0("	target: NONE, clicked on the same garrison");
							// If we click on the same garrison while giving order, abort giving order
							T_SETV("givingOrder", false);
						} else {
							_targetType = TARGET_TYPE_GARRISON;
							_target = CALLM0(_dstGarRecord, "getGarrison");
							OOP_INFO_1("	target: garrison %1", _target);
							_targetPos = +CALLM0(_dstGarRecord, "getPos");
						};
					};
					default {
						OOP_ERROR_1("Unknown map marker class: %1", _destMarker); // What :/
					};
				};
			} else {
				_targetType = TARGET_TYPE_POSITION;
				_target = _displayorcontrol posScreenToWorld [_xPos, _yPos];
				OOP_INFO_1("	target: position %1", _target);
				_targetPos = +_target;
			};

			if (_targetType == TARGET_TYPE_INVALID) then {
				T_SETV("garActionTargetType", TARGET_TYPE_INVALID);
				OOP_ERROR_0("Can't resolve target position");
			} else {
				// We are good to go!

				// Enable the garrison action listbox
				T_CALLM1("garActionMenuSetPos", _targetPos);
				// Store the garrison and target variables
				T_SETV("garActionGarRef", _gar);
				T_SETV("garActionTargetType", _targetType);
				T_SETV("garActionTarget", _target);
				// Enable the menu
				T_CALLM1("garActionMenuEnable", true);
			};
		};

		if (count _markersUnderCursor == 0) then {
			// We are definitely not clicking on any map marker
			T_CALLM0("onMouseClickElsewhere");
		} else {
			// Hey we have clicked on something!

			// Disable the garrison action listbox
			T_CALLM1("garActionMenuEnable", false);

			// Deselect evereything else
			{ CALLM1(_x, "select", false); } forEach (_selectedGarrisons + _selectedLocations);

			// Let's select it
			{ CALLM1(_x, "select", true); } forEach _markersUnderCursor;

			// If there is any garrison under cursor
			if (count _garrisonsUnderCursor > 0) then {
				pr _garRecord = CALLM0(_garrisonsUnderCursor#0, "getGarrisonRecord");
				T_CALLM1("garSelMenuSetGarRecord", _garRecord);
				T_CALLM1("garSelMenuEnable", true);
			};

			//Decide what to do with the panel on the right
			if (count _garrisonsUnderCursor == 1 && count _locationsUnderCursor == 1) then {
				// If we have selected both a garrison and a location
				pr _garRecord = CALLM0(_garrisonsUnderCursor#0, "getGarrisonRecord");
				pr _intel = CALLM0(_locationsUnderCursor#0, "getIntel");
				T_CALLM3("intelPanelUpdateFromLocationIntel", _intel, true, false); // clear
				T_CALLM2("intelPanelUpdateFromGarrisonRecord", _garRecord, false); // don't clear
				T_CALLM1("intelPanelShowButtons", false);
			} else {
				// If one garrison was clicked, update the panel from its record
				if (count _garrisonsUnderCursor == 1) then {
					pr _garRecord = CALLM0(_garrisonsUnderCursor#0, "getGarrisonRecord");
					T_CALLM2("intelPanelUpdateFromGarrisonRecord", _garRecord, true); // clear
					T_CALLM1("intelPanelShowButtons", false);
				} else {
					// If one location was clicked, update panel from the location intel
					if (count _locationsUnderCursor == 1) then {
						pr _intel = CALLM0(_locationsUnderCursor#0, "getIntel");
						T_CALLM2("intelPanelUpdateFromLocationIntel", _intel, true); // clear
						T_CALLM1("intelPanelShowButtons", false);
					};
				};
			};
		};

		T_SETV("selectedGarrisonMarkers", _garrisonsUnderCursor);
		T_SETV("selectedLocationMarkers", _locationsUnderCursor);
		T_CALLM0("updateHintTextFromContext");

		// Launch snek
		pr _posWorld = _displayorcontrol posScreenToWorld [_xPos, _yPos];
		if ((_posWorld distance2D [0, 0, 0]) < 150 ) then {
			if (CALLSM0("Snek", "isRunning")) then {
				CALLSM0("Snek", "stop");
			} else {
				CALLSM0("Snek", "start");
			};
		};

	} ENDMETHOD;


	/*
		Method: onMouseClickElsewhere
		Description: Gets called when user clicks on the map not on a marker.
	*/
	METHOD("onMouseClickElsewhere") {
		params [P_THISOBJECT];

		// Disable the garrison action listbox
		T_CALLM1("garActionMenuEnable", false);

		// Disable the selected garrison menu
		T_CALLM1("garSelMenuEnable", false);

		// Deselect evereything
		pr _selectedGarrisons = CALLSM0("MapMarkerGarrison", "getAllSelected");
		pr _selectedLocations = CALLSM0("MapMarkerLocation", "getAllSelected");
		{ CALLM1(_x, "select", false); } forEach (_selectedGarrisons + _selectedLocations);

		// Clear the intel panel
		//T_CALLM0("intelPanelClear");

		// Fill the intel panel from intel
		T_CALLM1("intelPanelUpdateFromIntel", true);
		T_CALLM0("intelPanelDeselect");
		T_CALLM2("intelPanelSortIntel", T_GETV("intelPanelSortCategory"), T_GETV("intelPanelSortInverse"));

		// Reset the map view
		T_CALLM1("mapShowAllIntel", T_GETV("showAllIntel"));

		// Show the buttons of the listbox
		T_CALLM1("intelPanelShowButtons", true);
	} ENDMETHOD;

	METHOD("onIntelAdded") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];

		// We only care if nothing is selected
		if ( (count T_GETV("selectedLocationMarkers") == 0) && (count T_GETV("selectedGarrisonMarkers") == 0) ) then {
			// todo if we have something currently selected, we should select the old item, etc, etc, probably don't care much for that now ... 

			// Fill the intel panel from intel
			T_CALLM1("intelPanelUpdateFromIntel", true);
			T_CALLM0("intelPanelDeselect");
			T_CALLM2("intelPanelSortIntel", T_GETV("intelPanelSortCategory"), T_GETV("intelPanelSortInverse"));

			// Reset the map view
			T_CALLM1("mapShowAllIntel", T_GETV("showAllIntel"));
		} else {
			// Something must be selected
			// So we want to check if drawing of all intel on the map is enabled or not
			T_CALLM1("mapShowAllIntel", T_GETV("showAllIntel"));
		};
	} ENDMETHOD;

	METHOD("onIntelRemoved") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];

		// They are the same now
		T_CALLM1("onIntelAdded", _intel);
	} ENDMETHOD;


	METHOD("onMouseButtonUp") {
		params [P_THISOBJECT, "_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

	} ENDMETHOD;

	METHOD("onMouseButtonClick") {
		params [P_THISOBJECT, "_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

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

	METHOD("onButtonClickShowIntel") {
		params [P_THISOBJECT];

		pr _checked = T_GETV("showAllIntel");
		pr _ctrl = ((finddisplay 12) displayCtrl IDC_BPANEL_BUTTON_SHOW_INTEL);
		if (_checked) then {
			// Uncheck it
			//_ctrl ctrlSetTextColor MUIC_COLOR_WHITE;
			_ctrl ctrlSetText "[ ] Show intel";
			T_CALLM1("mapShowAllIntel", false);
		} else {
			// Check it
			//_ctrl ctrlSetTextColor [0.13, 0.7, 0.29, 1];
			_ctrl ctrlSetText "[X] Show intel";
			T_CALLM1("mapShowAllIntel", true);
		};
		T_SETV("showAllIntel", !_checked);
	} ENDMETHOD;

	METHOD("onButtonClickClearNotifications") {
		params [P_THISOBJECT];

		CALLSM1("MapMarkerLocation", "setAllNotifications", false);
	} ENDMETHOD;

	/*
		Method: onMapOpen
		Description: Called by user interface event handler each time the map is opened

		No parameters
	*/
	METHOD("onMapOpen") {
		params [P_THISOBJECT];
		pr _mapDisplay = findDisplay 12;

		// Reset the map UI to default state
		T_CALLM0("onMouseClickElsewhere");

		// Check if current player position is valid position to create a Camp
		// todo refactor that
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

	// Not used now
	STATIC_METHOD("onButtonDownAddFriendlyGroup") {
		params ["_thisClass", "_control"];

		/*
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
		*/
	} ENDMETHOD;


	/*
		Method: onMouseEnter
		Description: Called when the mouse cursor enters the control.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	METHOD("onMouseEnter") {
		params [P_THISOBJECT, "_ctrl"];
		pr _mapDisplay = findDisplay 12;
		pr _idc = ctrlIDC _ctrl;
		T_SETV("currentControlIDC", _idc);
		T_CALLM0("updateHintTextFromContext");
		false // Must return false to still make it do the config-defined action
	} ENDMETHOD;

	/*
		Method: onMouseExit
		Description: Called when the mouse cursor exits the control.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	METHOD("onMouseExit") {
		params [P_THISOBJECT, "_ctrl"];
		T_SETV("currentControlIDC", -1);
		T_CALLM0("updateHintTextFromContext");
		false // Must return false to still make it do the config-defined action
	} ENDMETHOD;

	/*
		Method: onMouseDraw
		Description: Gets called each frame if map is open and being redrawn.
	*/
	METHOD("onMapDraw") {
		params [P_THISOBJECT];

		// Garrison action listbox will update its position 
		T_CALLM0("garActionMenuUpdatePos");

		// Selected garrison menu will update its position
		T_CALLM0("garSelMenuUpdatePos");

		// Redraw the drawArrow on the map if we are currently giving order to something
		T_CALLM0("garOrderUpdateArrow");

	} ENDMETHOD;

	/*
		Method: onMouseMoving
		Fires continuously while moving the mouse with a certain interval.
	*/
	METHOD("onMapMouseMoving") {
		params [P_THISOBJECT, "_control", "_xPos", "_yPos", "_mouseOver"];

		//pr _garrisonsUnderCursor = CALL_STATIC_METHOD("MapMarkerGarrison", "getMarkersUnderCursor", [_control ARG _xPos ARG _yPos]); // Let's not do it for garrison markers yet, ok?
		pr _garrisonsUnderCursor = [];
		pr _locationsUnderCursor = CALL_STATIC_METHOD("MapMarkerLocation", "getMarkersUnderCursor", [_control ARG _xPos ARG _yPos]);
		pr _markersUnderCursor = _garrisonsUnderCursor + _locationsUnderCursor;

		// Previous markers under cursor
		pr _markersUnderCursorOld = T_GETV("markersUnderCursor");

		OOP_INFO_1("ON MAP MOUSE MOVING: current: %1", _markersUnderCursor);
		OOP_INFO_1("ON MAP MOUSE MOVING: old: %1", _markersUnderCursorOld);

		// Check if mouse has entered any new markers
		{
			if (!(_x in _markersUnderCursorOld)) then {
				OOP_INFO_1("Entered marker: %1", _x);
				// Mouse has entered this marker
				CALLM1(_x, "setMouseOver", true);
			};
		} forEach _markersUnderCursor;

		// Check if any old markers are not under cursor any more
		{
			if (!(_x in _markersUnderCursor)) then {
				// Mouse has left this marker
				if (IS_OOP_OBJECT(_x)) then {
					OOP_INFO_1("Left marker: %1", _x);
					CALLM1(_x, "setMouseOver", false);
				};
			};
		} forEach _markersUnderCursorOld;

		T_SETV("markersUnderCursor", _markersUnderCursor);

	} ENDMETHOD;


/*
ooooo  oooo oooooooooo ooooooooo      o   ooooooooooo ooooooooooo 
 888    88   888    888 888    88o   888  88  888  88  888    88  
 888    88   888oooo88  888    888  8  88     888      888ooo8    
 888    88   888        888    888 8oooo88    888      888    oo  
  888oo88   o888o      o888ooo88 o88o  o888o o888o    o888ooo8888 
                                                                  
     o      oooooooooo  oooooooooo    ooooooo  oooo     oooo      
    888      888    888  888    888 o888   888o 88   88  88       
   8  88     888oooo88   888oooo88  888     888  88 888 88        
  8oooo88    888  88o    888  88o   888o   o888   888 888         
o88o  o888o o888o  88o8 o888o  88o8   88ooo88      8   8          

http://patorjk.com/software/taag/#p=display&f=O8&t=UPDATE%0AARROW

Redraws the order arrow when we are giving a waypoint
Gets called from "onMapDraw"
*/
	METHOD("garOrderUpdateArrow") {
		params [P_THISOBJECT];

		if (T_GETV("givingOrder")) then {
			pr _garRecord = T_GETV("garRecordCurrent");
			// Make sure it's not destroyed
			if (!IS_OOP_OBJECT(_garRecord)) exitWith {
				T_SETV("givingOrder", false);
			};

			pr _posStartWorld = CALLM0(_garRecord, "getPos");
			pr _ctrl = ((finddisplay 12) displayCtrl IDC_MAP);
			// If the action LB is shown, we will be pointing at its position
			if (T_GETV("garActionLBShown")) then {
				pr _posEndWorld = T_GETV("garActionPos");
				_ctrl drawArrow [_posStartWorld, _posEndWorld, [0, 0, 0, 1]]; 
			} else {
				pr _posEndScreen = getMousePosition;
				pr _posEndWorld = _ctrl posScreenToWorld _posEndScreen;
				_ctrl drawArrow [_posStartWorld, _posEndWorld, [0, 0, 0, 1]]; 
			};
		};
	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR(CLASS_NAME, "campAllowed", true);
PUBLIC_STATIC_VAR(CLASS_NAME, "campAllowed");