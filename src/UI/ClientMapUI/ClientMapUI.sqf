#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\common.h"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\..\AI\Commander\CmdrAction\CmdrActionStates.hpp"
#include "..\Resources\MapUI\MapUI_Macros.h"
#include "ClientMapUI_Macros.h"
#include "..\..\Location\Location.hpp"
#include "..\Resources\UIProfileColors.h"
#include "..\..\PlayerDatabase\PlayerDatabase.hpp"
#include "..\..\Intel\Intel.hpp"
#include "..\..\GameMode\cityState.hpp"

#define pr private

FIX_LINE_NUMBERS()

/*
	Class: ClientMapUI
	Singleton class that performs things related to map user interface
*/
#define CLASS_NAME "ClientMapUI"
#define OOP_CLASS_NAME ClientMapUI
CLASS("ClientMapUI", "")

	// Array with markers which are currently under cursor, gets updated on mouse moving event handler
	VARIABLE("markersUnderCursor");
	
	VARIABLE("selectedGarrisonMarkers");
	VARIABLE("selectedLocationMarkers");

	// Position where the action listbox is going to be attached to
	VARIABLE("garActionPos");
	// True if the garrison action listbox is shown
	VARIABLE("garActionLBShown");
	VARIABLE("garActionGarRef");
	VARIABLE("garActionTargetType");
	VARIABLE("garActionTarget");

	// Temporary flag used to indicate that the map should perform a zoom to last spawn location when it can
	VARIABLE("doZoom");

	// GarrisonSplitDialog OOP object
	VARIABLE("garSplitDialog");
	METHOD(onGarrisonSplitDialogDeleted)
		params [P_THISOBJECT];
		T_SETV("garSplitDialog", "");
		T_CALLM0("updateHintTextFromContext");
	ENDMETHOD;

	// Currently selected garrisons

	// Current garrison record which is selected. There can be many garrisons selected, but only one will have the manu under it drawn.
	VARIABLE("garSelMenuEnabled");
	VARIABLE("garRecordCurrent"); // Don't just set it manually, it's being set through funcs and event handlers
	VARIABLE("givingOrder"); // Bool, if true it means that we are giving order to a garrison. Current garrison record is garRecordCurrent

	// Currently selected location and the menu shown for it
	VARIABLE("locSelMenuEnabled");
	VARIABLE("locationCurrent");	// Location for which the menu is shown

	// Bool, state of the intel button
	VARIABLE("showIntelInactive");
	VARIABLE("showIntelActive");
	VARIABLE("showIntelEnded");
	VARIABLE("showIntelInactiveList");
	VARIABLE("showIntelActiveList");
	VARIABLE("showIntelEndedList");
	// Defines if we are sorting intel inversed or not
	VARIABLE("intelPanelSortInverse");
	// By which category we're going to sort the intel panel
	VARIABLE("intelPanelSortCategory");

	// Bools, show things on map
	VARIABLE("showLocations");
	VARIABLE("showEnemies");
	VARIABLE("showIntelPanel");
	VARIABLE("showLocationMiniPanels");
	// todo players?

	VARIABLE("sortButtons"); // array of side/type/time sorting buttons

	// Respawn panel
	VARIABLE("respawnPanelEnabled");

	// Last place the player respawned
	VARIABLE("lastRespawnPos");
	VARIABLE("lbSelectionIndices"); // used to keep track of updates of lbSelection array


	// initialize UI event handlers
	METHOD(new)
		params [P_THISOBJECT];

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

		// Currently selected location
		T_SETV("locSelMenuEnabled", false);
		T_SETV("locationCurrent", "");

		T_SETV("showIntelInactive", true); // on map
		T_SETV("showIntelActive", true); // on map
		T_SETV("showIntelEnded", false); // on map
		T_SETV("showIntelInactiveList", true); // in list
		T_SETV("showIntelActiveList", true); // in list
		T_SETV("showIntelEndedList", false); // in list
		T_SETV("showLocationMiniPanels", true); // on map

		T_SETV("showLocations", true);
		T_SETV("showEnemies", true);
		T_SETV("showIntelPanel", true);
		T_SETV("intelPanelSortInverse", false);
		T_SETV("intelPanelSortCategory", "time");

		T_SETV("sortButtons", []);

		// Respawn panel
		T_SETV("respawnPanelEnabled", false);
		T_SETV("lastRespawnPos", []);
		T_SETV("lbSelectionIndices", []);

		T_SETV("doZoom", false);

		pr _mapDisplay = findDisplay 12;

		/*																											
		88888888888  8b           d8  88888888888  888b      88  888888888888                                            
		88           `8b         d8'  88           8888b     88       88                                                 
		88            `8b       d8'   88           88 `8b    88       88                                                 
		88aaaaa        `8b     d8'    88aaaaa      88  `8b   88       88                                                 
		88"""""         `8b   d8'     88"""""      88   `8b  88       88                                                 
		88               `8b d8'      88           88    `8b 88       88                                                 
		88                `888'       88           88     `8888       88                                                 
		88888888888        `8'        88888888888  88      `888       88                                                 

		88        88         db         888b      88  88888888ba,    88           88888888888  88888888ba    ad88888ba   
		88        88        d88b        8888b     88  88      `"8b   88           88           88      "8b  d8"     "8b  
		88        88       d8'`8b       88 `8b    88  88        `8b  88           88           88      ,8P  Y8,          
		88aaaaaaaa88      d8'  `8b      88  `8b   88  88         88  88           88aaaaa      88aaaaaa8P'  `Y8aaaaa,    
		88""""""""88     d8YaaaaY8b     88   `8b  88  88         88  88           88"""""      88""""88'      `"""""8b,  
		88        88    d8""""""""8b    88    `8b 88  88         8P  88           88           88    `8b            `8b  
		88        88   d8'        `8b   88     `8888  88      .a8P   88           88           88     `8b   Y8a     a8P  
		88        88  d8'          `8b  88      `888  88888888Y"'    88888888888  88888888888  88      `8b   "Y88888P"   
		*/

		// open map EH
		addMissionEventHandler ["Map", { 
		params ["_mapIsOpened", "_mapIsForced"]; if !(visibleMap) then { CALLM0(gClientMapUI, "onMapOpen"); }; }];
		
		//listbox events
		([_mapDisplay, "CMUI_INTEL_LISTBOX"] call ui_fnc_findControl) ctrlAddEventHandler ["LBSelChanged", { CALLM(gClientMapUI, "intelPanelOnSelChanged", _this); }];
		([_mapDisplay, "CMUI_INTEL_LISTBOX"] call ui_fnc_findControl) ctrlAddEventHandler ["LBDblClick", { CALLM(gClientMapUI, "intelPanelOnDblClick", _this); }];

		// Map OnDraw
		// Gets called on each frame, only when the map is open
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["Draw", {CALLM0(gClientMapUI, "onMapDraw");} ]; // Mind this sh1t: https://feedback.bistudio.com/T123355

		// Map OnMouseMoving
		// Fires continuously while moving the mouse with a certain interval
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseMoving", {CALLM(gClientMapUI, "onMapMouseMoving", _this);} ]; // Mind this sh1t: https://feedback.bistudio.com/T123355
																 
		// We use a fucked up trick to make a nicely looking checkbox button. It constists of two controls: static background to manage appearence,
		// and transparent foreground button to intercept events. The event handlers must be attached to the button obviously.
		// Use function ui_fnc_findCheckboxButton to find the button control from given static control.

		pr _ctrl = ([_mapDisplay, "CMUI_INTEL_BTN_ACTIVE_MAP"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowIntelActive", _this); }];
		[_ctrl, true, false] call ui_fnc_buttonCheckboxSetState;

		pr _ctrl = ([_mapDisplay, "CMUI_INTEL_BTN_INACTIVE_MAP"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowIntelInactive", _this); }];
		[_ctrl, true, false] call ui_fnc_buttonCheckboxSetState;

		pr _ctrl = ([_mapDisplay, "CMUI_INTEL_BTN_ENDED_MAP"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowIntelEnded", _this); }];
		[_ctrl, false, false] call ui_fnc_buttonCheckboxSetState;

		pr _ctrl = ([_mapDisplay, "CMUI_INTEL_BTN_ACTIVE_LIST"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowIntelActiveList", _this); }];
		[_ctrl, true, false] call ui_fnc_buttonCheckboxSetState;

		pr _ctrl = ([_mapDisplay, "CMUI_INTEL_BTN_INACTIVE_LIST"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowIntelInactiveList", _this); }];
		[_ctrl, true, false] call ui_fnc_buttonCheckboxSetState;

		pr _ctrl = ([_mapDisplay, "CMUI_INTEL_BTN_ENDED_LIST"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowIntelEndedList", _this); }];
		[_ctrl, false, false] call ui_fnc_buttonCheckboxSetState;

		pr _ctrl = ([_mapDisplay, "CMUI_BUTTON_LOC"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowLocations", _this); }];
		[_ctrl, true, false] call ui_fnc_buttonCheckboxSetState;

		pr _ctrl = ([_mapDisplay, "CMUI_BUTTON_LOC_MINI_PANELS"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowLocationMiniPanels", _this); }];
		[_ctrl, true, false] call ui_fnc_buttonCheckboxSetState;

		pr _ctrl = ([_mapDisplay, "CMUI_BUTTON_PLAYERS"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowPlayers", _this); }];
		[_ctrl, true, false] call ui_fnc_buttonCheckboxSetState;
		
		_ctrl = ([_mapDisplay, "CMUI_BUTTON_INTELP"] call ui_fnc_findCheckboxButton);
		_ctrl ctrlAddEventHandler ["ButtonDown", { CALLM(gClientMapUI, "onButtonClickShowIntelPanel", _this); }];
		[_ctrl, true, false] call ui_fnc_buttonCheckboxSetState;

		([_mapDisplay, "CMUI_BUTTON_NOTIF"] call ui_fnc_findControl) ctrlAddEventHandler ["ButtonClick", { CALLM(gClientMapUI, "onButtonClickClearNotifications", _this); }];
		([_mapDisplay, "CMUI_BUTTON_RESPAWN"] call ui_fnc_findControl) ctrlAddEventHandler ["ButtonClick", { CALLM(gClientMapUI, "onButtonClickRespawn", _this); }];

		//  = = = = = = = = Add event handlers to the map = = = = = = = = 
		// Mouse button down
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonDown", {
			//params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			CALLM(gClientMapUI, "onMouseButtonDown", _this);
			false // Not handled
		}];

		// Mouse button up
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonUp", {
			//params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			CALLM(gClientMapUI, "onMouseButtonUp", _this);
			false // Not handled
		}];

		// Mouse button click
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseButtonClick", {
			//params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			CALLM(gClientMapUI, "onMouseButtonClick", _this);
			false // Not handled
		}];


		// init headline text and color
		/*
		([_mapDisplay, "CMUI_INTEL_HEADLINE"] call ui_fnc_findControl) ctrlSetText format ["%1", (toUpper worldName)];
		([_mapDisplay, "CMUI_BUTTON_CONTACTREP"] call ui_fnc_findControl) ctrlEnable false; // TODO
		([_mapDisplay, "CMUI_BUTTON_CONTACTREP"] call ui_fnc_findControl) ctrlSetTooltip "Not yet implemented."; // TODO
		*/

		//  = = = = = = = = Create garrison action list box = = = = = = = =

		// Appears when we are about to give an order to a garrison
		// delete prev controls
		ctrlDelete ((finddisplay 12) displayCtrl IDC_GCOM_ACTION_MENU_GROUP);
		pr _bg = ((finddisplay 12)) ctrlCreate ["CMUI_GCOM_ACTION_LISTBOX_BG", IDC_GCOM_ACTION_MENU_GROUP]; // Background
		T_CALLM1("garActionMenuEnable", false);

		// Just a macro to give event handlers to buttons cause I'm LZ AF
		#define __GAR_ACTION_BUTTON_CLICK_EH(idc, buttonStr) ((findDisplay 12) displayCtrl idc) ctrlAddEventHandler ["ButtonClick", { \
				_thisObject = gClientMapUI; \
				T_CALLM1("garActionLBOnButtonClick", buttonStr); \
			}]

		__GAR_ACTION_BUTTON_CLICK_EH(IDC_GCOM_ACTION_MENU_BUTTON_MOVE, "move");				// This text is not displayed
		__GAR_ACTION_BUTTON_CLICK_EH(IDC_GCOM_ACTION_MENU_BUTTON_ATTACK, "attack");			// It is for another function to check it
		__GAR_ACTION_BUTTON_CLICK_EH(IDC_GCOM_ACTION_MENU_BUTTON_REINFORCE, "reinforce");	// Marvis please don't touch it!
		__GAR_ACTION_BUTTON_CLICK_EH(IDC_GCOM_ACTION_MENU_BUTTON_CLOSE, "close");			// I'm sorry, Sparker

		// = = = = = = = = = = = = = = = Create the selected garrison menu = = = = = = = = = = = 
		// It appears when we have selected a garrison
		// Delete prev controls
		ctrlDelete ((findDisplay 12) displayCtrl IDC_GSELECT_GROUP);
		(findDisplay 12) ctrlCreate ["CMUI_GSELECTED_MENU", IDC_GSELECT_GROUP];
		T_CALLM1("garSelMenuEnable", false);

		// Another lazy macro to give event handlers to buttons
		#define __GAR_SELECT_BUTTON_CLICK_EH(idc, buttonStr) ((findDisplay 12) displayCtrl idc) ctrlAddEventHandler ["ButtonClick", { \
				_thisObject = gClientMapUI; \
				T_CALLM1("garSelMenuOnButtonClick", buttonStr); \
			}]

		__GAR_SELECT_BUTTON_CLICK_EH(IDC_GSELECT_BUTTON_SPLIT, "split");
		__GAR_SELECT_BUTTON_CLICK_EH(IDC_GSELECT_BUTTON_GIVE_ORDER, "order");
		__GAR_SELECT_BUTTON_CLICK_EH(IDC_GSELECT_BUTTON_CANCEL_ORDER, "cancelOrder");
		__GAR_SELECT_BUTTON_CLICK_EH(IDC_GSELECT_BUTTON_MERGE, "merge");


		// = = = = = = = = = = = = = = = Create the selected location menu = = = = = = = = = = = 
		// It appears when we have selected a friendly location
		// Delete previous controls
		pr _ctrl = T_CALLM1("findControl", "CMUI_LSELECTED_MENU");
		ctrlDelete _ctrl;

		(findDisplay 12) ctrlCreate ["CMUI_LSELECTED_MENU", -1];
		T_CALLM1("locSelMenuEnable", false);

		// Give actions to buttons
		#define __LOC_SELECT_BUTTON_CLICK_EH(className, buttonStr) T_CALLM1("findControl", className) ctrlAddEventHandler ["ButtonClick", { \
			_thisObject = gClientMapUI; \
			T_CALLM1("locSelMenuOnButtonClick", buttonStr); \
		}]

		__LOC_SELECT_BUTTON_CLICK_EH("LSELECTED_BUTTON_RECRUIT", "recruit");
		__LOC_SELECT_BUTTON_CLICK_EH("LSELECTED_BUTTON_DISBAND", "disband");

		// = = = = = = = = = = = = = = = Create the listbox sorting buttons = = = = = = = = = = = = = = =
		pr _ctrlGroup = (finddisplay 12) displayCtrl IDC_LOCP_LISTNBOX_BUTTONS_GROUP;

		if (isNull _ctrlGroup) then {
			OOP_ERROR_0("Listbox button group was not found!");
		} else {
			pr _btns = [(finddisplay 12), "MUI_BUTTON_LISTNBOX", IDC_LOCP_LISTNBOX_BUTTONS_0, _ctrlGroup, [0, 0.13, 0.35, 0.78], true] call ui_fnc_createButtonsInGroup;
			_btns#0 ctrlSetText localize "STR_CMUI_B_SIDE";
			_btns#1 ctrlSetText localize "STR_CMUI_B_STATUS";
			_btns#2 ctrlSetText localize "STR_CMUI_B_TYPE";
			_btns#3 ctrlSetText localize "STR_CMUI_B_TIME";

			T_SETV("sortButtons", _btns);

			_btns#0 ctrlAddEventHandler ["ButtonClick", {
				CALLM1(gClientMapUI, "intelPanelOnSortButtonClick", "side");
			}];
			_btns#1 ctrlAddEventHandler ["ButtonClick", {
				CALLM1(gClientMapUI, "intelPanelOnSortButtonClick", "status");
			}];
			_btns#2 ctrlAddEventHandler ["ButtonClick", {
				CALLM1(gClientMapUI, "intelPanelOnSortButtonClick", "type");
			}];
			_btns#3 ctrlAddEventHandler ["ButtonClick", {
				CALLM1(gClientMapUI, "intelPanelOnSortButtonClick", "time");
			}];

			// we use tooltips here 
			_btns#0 ctrlSetTooltip (localize "STR_CMUI_SORTINGBTN_SIDE");
			_btns#1 ctrlSetTooltip (localize "STR_CMUI_SORTINGBTN_STATUS");
			_btns#2 ctrlSetTooltip (localize "STR_CMUI_SORTINGBTN_TYPE");
			_btns#3 ctrlSetTooltip (localize "STR_CMUI_SORTINGBTN_TIME");
		};

		// Disable the respawn panel initially
		T_CALLM1("respawnPanelEnable", false);

		// Mouse moving
		// Probably we don't need it now
		/*
		((findDisplay 12) displayCtrl IDC_MAP) ctrlAddEventHandler ["MouseMoving", {
			params ["_control", "_xPos", "_yPos", "_mouseOver"];

			pr _args = [_control, _xPos, _yPos];
			pr _markerCurrent = CALLSM(CLASS_NAME, "getMarkerUnderCursor", _args);
			pr _markerPrev = GETSV(CLASS_NAME, "markerUnderCursor");

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
				SETSV(CLASS_NAME, "markerUnderCursor", _markerCurrent)
			};
		}];
		*/

	ENDMETHOD; // end "new" METHOD



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

	public STATIC_METHOD(setPlayerRestoreData)
		params ["_thisClass", "_playerRestoreData"];
		gPlayerRestoreData = _playerRestoreData;
	ENDMETHOD;


	/*
		Method: toggleButtonEnabled
		Description: Set a button enabled or disabled. Does not use 

		Parameter:
		0: _control - the button to be toggled
		1: _enable - default: true, false to disable
	*/
	public STATIC_METHOD(toggleButtonEnabled)
		params ["_thisClass", "_control", ["_enable", true]];
		
	ENDMETHOD;


	// Returns marker text of closest marker
	public STATIC_METHOD(getNearestLocationName)
		params ["_thisClass", "_pos"];
		pr _return = "";

		{
			if(((getPos _x) distance _pos) < 100) exitWith {
				_return =  _x getVariable ["Name", ""];
			};
		} forEach entities "Vindicta_LocationSector";

		_return
	ENDMETHOD;


	/*
		Method: mapShowAllIntel
		Description: Shows or hides all map representations of intel, depending on which intel types are selected,
					 or depending on the bools that are passed.

		Parameters: 
		TODO
	*/
	METHOD(mapShowAllIntel)
		params [P_THISOBJECT, P_BOOL("_forceShow"), P_BOOL("_forceHide")];
		private _allIntels = CALLM0(gIntelDatabaseClient, "getAllIntel");

		private _showInactive = T_GETV("showIntelInactive");
		private _showActive = T_GETV("showIntelActive");
		private _showEnded = T_GETV("showIntelEnded");

		// forEach _allIntels;
		{
			pr _intel = _x;
			private _className = GET_OBJECT_CLASS(_x);
			if (!(_className in ["IntelLocation", "IntelCluster"])) then { // Add all non-location intel classes
				pr _state = GETV(_intel, "state");
				pr _show = switch (_state) do {
					case INTEL_ACTION_STATE_INACTIVE: {_showInactive};
					case INTEL_ACTION_STATE_ACTIVE: {_showActive};
					case INTEL_ACTION_STATE_END: {_showEnded};
					default {false};
				};

				pr _show0 = (_show || _forceShow) && (!_forceHide);
				CALLM1(_x, "showOnMap", _show0);
			};
		} forEach _allIntels;
	ENDMETHOD;


	/*
		Method: findControl
		Description: Finds a control by its classname.

		Parameters: 
		0: _className - Class name string

		Returns: control 

	*/
	METHOD(findControl)
		params [P_THISOBJECT, P_STRING("_className")];
		pr _display = findDisplay 12;
		//OOP_INFO_1("FIND CONTROL: %1", _className);
		pr _allControls = allControls _display;
		pr _index = _allControls findIf {(ctrlClassName _x) == _className};
		if (_index != -1) then {
			_allControls select _index
		} else {
			controlNull
		};
	ENDMETHOD;


	/*                                                                      
	ooooooooo  oooooooooo       o  oooo     oooo      oooooooooo    ooooooo  ooooo  oooo ooooooooooo ooooooooooo 
	888    88o 888    888     888  88   88  88        888    888 o888   888o 888    88  88  888  88  888    88  
	888    888 888oooo88     8  88  88 888 88         888oooo88  888     888 888    88      888      888ooo8    
	888    888 888  88o     8oooo88  888 888          888  88o   888o   o888 888    88      888      888    oo  
	o888ooo88  o888o  88o8 o88o  o888o 8   8          o888o  88o8   88ooo88    888oo88      o888o    o888ooo8888 
	http://patorjk.com/software/taag/#p=display&f=O8&t=DRAW%20ROUTE
	*/

	#define __MRK_ROUTE "_route_"
	#define __MRK_LABEL "_label_"
	#define __MRK_SOURCE "_src"
	#define __MRK_DEST "_dst"

	/*
		Method: drawRoute
		Description: Draws a route on the map, for example for attacks, reinforcements...
	*/
	public STATIC_METHOD(drawRoute)
		params [P_THISCLASS, P_ARRAY("_posArray"), P_STRING("_uniqueString"), P_BOOL("_enable"), P_BOOL("_cycle"), P_BOOL("_drawSrcDest"), ["_color", "ColorRed"], P_ARRAY("_labels") ];

		//OOP_INFO_1("DRAW ROUTE: %1", _this);

		// Convert unique string to lowercase to be safe
		_uniqueString = toLower _uniqueString;

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
					_mrk setMarkerColorLocal _color;
					_mrk setMarkerAlphaLocal 1;
					_mrk setMarkerTextLocal _text;
					_markers pushBack _name;

				// no need for source marker label, we already see where it starts and ends
				} forEach [[_uniqueString+__MRK_ROUTE+__MRK_SOURCE, _posSrc, "mil_dot", ""], [_uniqueString+__MRK_ROUTE+__MRK_DEST, _posDst, "mil_dot", localize "STR_CMUI_DESTINATION"]];
			};

			// Draw lines
			for "_i" from 0 to (_count - 1) do {
				pr _pos0 = _positions#_i;
				if(_i < _count - 1) then {
					pr _mrkName = _uniqueString + __MRK_ROUTE + (str _i);
					pr _pos1 = _positions#(_i+1);
					[_pos0, _pos1, _color, 8, _mrkName] call misc_fnc_mapDrawLineLocal;
					// count - 3 due to the ordering of the positions (last one is actually starting pos in a cycle)
					if(_cycle && _i == _count - 3) then {
						_mrkName setMarkerBrushLocal "Grid";
						_mrkName setMarkerAlphaLocal 0.7;
					};
					_markers pushBack _mrkName;
				};
				if(_i < count _labels) then {
					(_labels#_i) params ["_text", "_color"];
					pr _mrkName = _uniqueString + __MRK_ROUTE + __MRK_LABEL + (str _i);
					createMarkerLocal [_mrkName, _pos0];
					_mrkName setMarkerTypeLocal "mil_dot";
					_mrkName setMarkerColorLocal _color;
					_mrkName setMarkerAlphaLocal 1;
					_mrkName setMarkerTextLocal _text;
					_markers pushBack _mrkName;
				};
			};
		};

		_markers
	ENDMETHOD;


	/*
	ooooo ooooo ooooo oooo   oooo ooooooooooo      ooooooooooo ooooooooooo ooooo  oooo ooooooooooo 
	888   888   888   8888o  88  88  888  88      88  888  88  888    88    888  88   88  888  88 
	888ooo888   888   88 888o88      888              888      888ooo8        888         888     
	888   888   888   88   8888      888              888      888    oo     88 888       888     
	o888o o888o o888o o88o    88     o888o            o888o    o888ooo8888 o88o  o888o    o888o    
	http://patorjk.com/software/taag/#p=display&f=O8&t=HINT%20TEXT

	We only use the hint panel for displaying progress now. Normal tooltips are used for everything else.
	*/
	
	/*
		Method: setDescriptionText
		Description: Sets the description text for the currently selected piece of intel.

		Parameters: 
		0: _text - String description 

	*/
	METHOD(setDescriptionText)
		params [P_THISOBJECT, P_STRING("_text")];
		pr _mapDisplay = findDisplay 12;
		pr _ctrl = ([_mapDisplay, "CMUI_INTEL_DESCRIPTION"] call ui_fnc_findControl);
		pr _pos = ctrlPosition _ctrl;
		_ctrl ctrlSetPosition [_pos#0, _pos#1, _pos#2, 1];
		pr _finalText = format["<t size='0.8' font='EtelkaMonospacePro' align='left'>%1</t>", _text];
		pr _parsedText = parseText _finalText;
		_ctrl ctrlSetStructuredText _parsedText;
		pr _height = ctrlTextHeight _ctrl;
		_ctrl ctrlSetPosition [_pos#0, _pos#1, _pos#2, _height];
		_ctrl ctrlCommit 0;
	ENDMETHOD;

	/*
		Method: setHintText
		Description: Called by updateHintTextFromContext to set hint panel text. Do NOT call anywhere else.

		Parameters: 
		0: _text - String that should be set on the hint panel

	*/
	METHOD(setHintText)
		params [P_THISOBJECT, P_STRING("_text")];
		pr _mapDisplay = findDisplay 12;
		([_mapDisplay, "CMUI_HINTS"] call ui_fnc_findControl) ctrlSetText _text;
	ENDMETHOD;


	/*
		Method: updateHintTextFromContext
		Description: Calls setHintText to set hint text on the hint panel.
					 If a control is provided, a hint will be displayed for it.

		Parameters: None

		old code backup:
		//pr _markersUnderCursor = 	CALLSM("MapMarkerLocation", "getMarkersUnderCursor", [_displayorcontrol ARG _xPos ARG _yPos]) +
		//							CALLSM("MapMarkerGarrison", "getMarkersUnderCursor", [_displayorcontrol ARG _xPos ARG _yPos]);

	*/
	METHOD(updateHintTextFromContext)
		params [P_THISOBJECT];

		pr _mapDisplay = findDisplay 12;
		
		pr _gameModeInitialized = if(isNil "gGameManager") then {
			false
		} else {
			CALLM0(gGameManager, "isGameModeInitialized");
		};

		if(_gameModeInitialized && {!isNil "gGameModeServer"}) then {
			pr _progressPercent = floor (100 * CALLM0(gGameModeServer, "getCampaignProgress"));
			pr _aggressionPercent = floor (100 * CALLM0(gGameModeServer, "getAggression"));
			private _progressHint = format[localize "STR_CMUI_CAMPAIGN_PROGRESS", _progressPercent, "%", _aggressionPercent, "%"];
			T_CALLM1("setHintText", _progressHint);
			} else {
				if(call misc_fnc_isAdminLocal) then {
					T_CALLM1("setHintText", localize "STR_CMUI_NOT_INITIALIZED");
				} else {
					T_CALLM1("setHintText", localize "STR_CMUI_NOT_INITIALIZED_ADMIN");
				};
		};

		pr _selectedGarrisons = CALLSM0("MapMarkerGarrison", "getAllSelected");
		pr _selectedLocations = CALLSM0("MapMarkerLocation", "getAllSelected");

		if (T_GETV("garActionLBShown")) exitWith {
			T_CALLM1("setHintText", localize "STR_CMUI_GARRISON_ORDER_HINT");
		};

		if (T_GETV("givingOrder")) exitWith {
			T_CALLM1("setHintText", localize "STR_CMUI_DESTINATION_HINT");
		};
		
		if (T_GETV("garSplitDialog") != "") exitWith {
			T_CALLM1("setHintText", localize "STR_CMUI_SPLIT_HINT");
		};

		if (count _selectedGarrisons >= 1) exitWith {
			T_CALLM1("setHintText", localize "STR_CMUI_GARRISON_ACTION_HINT");
		};

	ENDMETHOD;


	/*                                                                                                                                       
	o       oooooooo8 ooooooooooo ooooo  ooooooo  oooo   oooo      oooo     oooo ooooooooooo oooo   oooo ooooo  oooo 
	888    o888     88 88  888  88  888 o888   888o 8888o  88        8888o   888   888    88   8888o  88   888    88  
	8  88   888             888      888 888     888 88 888o88        88 888o8 88   888ooo8     88 888o88   888    88  
	8oooo88  888o     oo     888      888 888o   o888 88   8888        88  888  88   888    oo   88   8888   888    88  
	o88o  o888o 888oooo88     o888o    o888o  88ooo88  o88o    88       o88o  8  o88o o888ooo8888 o88o    88    888oo88   
																		
	Methods for the action listbox appears when we click on something to send some garrison do something
	*/

	// Enables or disables the garrison action listbox
	METHOD(garActionMenuEnable)
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
	ENDMETHOD;

	// Sets the position of the garrison action listbox
	METHOD(garActionMenuSetPos)
		params [P_THISOBJECT, P_POSITION("_pos")];
		T_SETV("garActionPos", _pos);
	ENDMETHOD;

	METHOD(garActionMenuUpdatePos)
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
	ENDMETHOD;

	// The selection in a listbox is changed.
	METHOD(garActionLBOnButtonClick)
		params [P_THISOBJECT, "_action"];

		// Sanity checks
		if (!T_GETV("garActionLBShown")) exitWith {};
		if (T_GETV("garActionTargetType") == TARGET_TYPE_INVALID) exitWith {};

		switch (toLower _action) do {
			case "move" : {
				pr _AI = CALLSM("AICommander", "getAICommander", [playerSide]);
				// Although it's on another machine, messageReceiver class will route the message for us
				pr _args = [T_GETV("garActionGarRef"), T_GETV("garActionTargetType"), T_GETV("garActionTarget")];
				CALLM2(_AI, "postMethodAsync", "clientCreateMoveAction", _args);
				systemChat localize "STR_CMUI_MOVE_ORDER";
			};
			case "attack" : {
				pr _AI = CALLSM("AICommander", "getAICommander", [playerSide]);
				// Although it's on another machine, messageReceiver class will route the message for us
				pr _args = [T_GETV("garActionGarRef"), T_GETV("garActionTargetType"), T_GETV("garActionTarget")];
				CALLM2(_AI, "postMethodAsync", "clientCreateAttackAction", _args);
				systemChat localize "STR_CMUI_ATTACK_ORDER";
			};
			case "reinforce" : {
				pr _AI = CALLSM("AICommander", "getAICommander", [playerSide]);
				// Although it's on another machine, messageReceiver class will route the message for us
				pr _args = [T_GETV("garActionGarRef"), T_GETV("garActionTargetType"), T_GETV("garActionTarget")];
				CALLM2(_AI, "postMethodAsync", "clientCreateReinforceAction", _args);
				systemChat localize "STR_CMUI_REINFORCE_ORDER";
			};
			case "patrol" : {
				//OOP_INFO_1("  %1 garrison action is not implemented", _action);
				systemChat localize "STR_CMUI_NYI_ORDER";
			};
			case "close" : {
				// Do nothing, it will just close itself
			};
			default {
				OOP_ERROR_1("unknown garrison action: %1", _action);
			};
		};

		// Close the LB
		T_CALLM1("garActionMenuEnable", false);

		// We are not giving order any more, stop drawing the arrow
		T_SETV("givingOrder", false);

		T_CALLM0("updateHintTextFromContext");
	ENDMETHOD;



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

	METHOD(garSelMenuEnable)
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
				((findDisplay 12) displayCtrl _x) ctrlSetTooltip localize "STR_CMUI_NO_PERMISSION_TO_GARRISON";
			} forEach [IDC_GSELECT_BUTTON_SPLIT, IDC_GSELECT_BUTTON_MERGE, IDC_GSELECT_BUTTON_GIVE_ORDER, IDC_GSELECT_BUTTON_CANCEL_ORDER];
		} else {
			((findDisplay 12) displayCtrl IDC_GSELECT_BUTTON_MERGE) ctrlEnable false;
			((findDisplay 12) displayCtrl IDC_GSELECT_BUTTON_MERGE) ctrlSetTooltip localize "STR_CMUI_NYI";
			{
				((findDisplay 12) displayCtrl _x) ctrlEnable true;
				((findDisplay 12) displayCtrl _x) ctrlSetTooltip "";
			} forEach [IDC_GSELECT_BUTTON_SPLIT, IDC_GSELECT_BUTTON_GIVE_ORDER, IDC_GSELECT_BUTTON_CANCEL_ORDER];
		};

		T_CALLM0("updateHintTextFromContext");
	ENDMETHOD;

	METHOD(garSelMenuSetGarRecord)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];
		T_SETV("garRecordCurrent", _garRecord);
	ENDMETHOD;

	// Called on each map draw event to update the position
	METHOD(garSelMenuUpdatePos)
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
			_ctrl ctrlSetPosition [_xScreen /*- GSELECT_MENU_WIDTH/2*/, _yScreen + 0.04, _pos#2, _pos#3];
			_ctrl ctrlCommit 0;
		};

	ENDMETHOD;

	// Gets called when user clicks on one of these buttons
	METHOD(garSelMenuOnButtonClick)
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
				pr _AI = CALLSM("AICommander", "getAICommander", [playerSide]);
				// Although it's on another machine, messageReceiver class will route the message for us
				pr _garRef = CALLM0(_garRecord, "getGarrison");
				pr _args = [_garRef];
				CALLM2(_AI, "postMethodAsync", "cancelCurrentAction", [_garRef]);
				systemChat localize "STR_CMUI_CANCEL_ORDER";
			};
			default {
				// Do nothing
			};
		};

		T_CALLM0("updateHintTextFromContext");
	ENDMETHOD;


	/*
	ooooo         ooooooo     oooooooo8     o   ooooooooooo ooooo  ooooooo  oooo   oooo           
	888        o888   888o o888     88    888  88  888  88  888 o888   888o 8888o  88            
	888        888     888 888           8  88     888      888 888     888 88 888o88            
	888      o 888o   o888 888o     oo  8oooo88    888      888 888o   o888 88   8888            
	o888ooooo88   88ooo88    888oooo88 o88o  o888o o888o    o888o  88ooo88  o88o    88            
																								
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
	*/

	METHOD(locSelMenuEnable)
		params [P_THISOBJECT, P_BOOL("_enable")];

		T_SETV("locSelMenuEnabled", _enable);
		pr _ctrl = T_CALLM1("findControl", "CMUI_LSELECTED_MENU");
		_ctrl ctrlShow _enable;

		/*
		if (!_enable) then {	
			T_SETV("garRecordCurrent", "");
		};
		*/

		// Check if we can command garrisons at all
		pr _canCommand = CALLM1(gPlayerDatabaseClient, "get", PDB_KEY_ALLOW_COMMAND_GARRISONS);
		if (isNil "_canCommand") then {_canCommand = false; };
		if (!_canCommand) then {
			{
				pr _ctrl0 = T_CALLM1("findControl", _x);
				_ctrl0 ctrlEnable false;
				_ctrl0 ctrlSetTooltip localize "STR_CMUI_NO_PERMISSION_TO_GARRISON";
			} forEach ["LSELECTED_BUTTON_RECRUIT"];
		} else {
			{
				pr _ctrl0 = T_CALLM1("findControl", _x);
				_ctrl0 ctrlEnable true;
				_ctrl0 ctrlSetTooltip "";
			} forEach ["LSELECTED_BUTTON_RECRUIT"];
		};

		T_CALLM0("updateHintTextFromContext");
	ENDMETHOD;

	METHOD(locSelMenuSetLocation)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		T_SETV("locationCurrent", _loc);
	ENDMETHOD;

	METHOD(locSelMenuUpdatePos)
		params [P_THISOBJECT];

		if (T_GETV("locSelMenuEnabled")) then {
			pr _loc = T_GETV("locationCurrent");
			
			// Make sure the location exists
			if (!IS_OOP_OBJECT(_loc)) exitWith {
				T_SETV("locationCurrent", "");
				T_CALLM1("locSelMenuEnable", false);
			};

			// Update the position of the group control
			pr _posWorld = CALLM0(_loc, "getPos");
			pr _posScreen = ((findDisplay 12) displayCtrl IDC_MAP) posWorldToScreen _posWorld;
			_posScreen params ["_xScreen", "_yScreen"];
			pr _ctrl = T_CALLM1("findControl", "CMUI_LSELECTED_MENU");
			pr _pos = ctrlPosition _ctrl;
			_ctrl ctrlSetPosition [_xScreen - LSELECT_MENU_WIDTH, _yScreen + 0.04, _pos#2, _pos#3]; // We offset the control left and down a bit
			_ctrl ctrlCommit 0;
		};

	ENDMETHOD;

	METHOD(locSelMenuOnButtonClick)
		params [P_THISOBJECT, P_STRING("_button")];

		pr _loc = T_GETV("locationCurrent");

		// Bail if location doesn't exist any more (why??)
		if (!IS_OOP_OBJECT(_loc)) exitWith {
			T_SETV("locationCurrent", "");
			T_CALLM1("locSelMenuEnable", false);
		};

		// Bail if we don't own this location any more
		// todo ...

		switch (_button) do {
			case "recruit" : {
				pr _args = [clientOwner, _loc, playerSide];

				// Temp solution
				//CALLM2(gGarrisonServer, "postMethodAsync", "recruitUnitAtLocation", _args);
				//systemChat "Recruiting a soldier...";
				// todo implement periodic UI refresh or on incoming update event

				NEW("RecruitDialog", [_loc]);
			};

			case "disband" : {
				systemChat localize "STR_CMUI_NYI_HINT";
			};
		};

	ENDMETHOD;


	/*
	ooooo oooo   oooo ooooooooooo ooooooooooo ooooo            oooooooooo   o      oooo   oooo ooooooooooo ooooo       
	888   8888o  88  88  888  88  888    88   888              888    888 888      8888o  88   888    88   888        
	888   88 888o88      888      888ooo8     888              888oooo88 8  88     88 888o88   888ooo8     888        
	888   88   8888      888      888    oo   888      o       888      8oooo88    88   8888   888    oo   888      o 
	o888o o88o    88     o888o    o888ooo8888 o888ooooo88      o888o   o88o  o888o o88o    88  o888ooo8888 o888ooooo88 
	http://patorjk.com/software/taag/#p=display&f=O8&t=INTEL%20PANEL
	*/

	// Flags for the function behavior use like: [INTEL_PANEL_CLEAR] + [INTEL_PANEL_SHOW_COMPOSITION]
	#define INTEL_PANEL_CLEAR 0
	#define INTEL_PANEL_SHOW_COMPOSITION 1

	METHOD(intelPanelUpdateFromGarrisonRecords)
		params [P_THISOBJECT, P_ARRAY("_garRecords")];

		private _mapDisplay = findDisplay 12;

		OOP_INFO_1("intelPanelUpdateFromGarrisonRecords: %1", _garRecords);

		pr _lnb = ([_mapDisplay, "CMUI_INTEL_LISTBOX"] call ui_fnc_findControl);
		_lnb lnbSetColumnsPos [0, 0.6];
		{
			_lnb lnbAddRow [localize "STR_CMUI_GARRISON", str (_forEachIndex + 1)];
			pr _comp = CALLM0(_x, "getComposition");
			{
				pr _catID = _foreachindex;
				{
					pr _subcatID = _forEachIndex;
					pr _classes = _x; // Array with IDs of classes
					if (count _classes > 0) then {
						pr _name = T_NAMES#_catID#_subcatID;
						_lnb lnbAddRow ["  " + toUpper(localize _name), str (count _classes)];
					};
				} forEach _x;
			} forEach _comp;
		} forEach _garRecords;
	ENDMETHOD;

	METHOD(setIntelPanelForItems)
		params [P_THISOBJECT];
		// set text on sorting buttons, not needed here. It will simply look like a black bar
		pr _btns = T_GETV("sortButtons");
		if !(_btns isEqualTo []) then {
			_btns#0 ctrlSetText "";
			_btns#1 ctrlSetText "";
			_btns#2 ctrlSetText "";
			_btns#3 ctrlSetText "";
		};
		T_CALLM0("intelPanelClear");
	ENDMETHOD;
	
	METHOD(intelPanelUpdateFromLocationIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel"), P_ARRAY("_flags")];

		OOP_INFO_1("intelPanelUpdateFromLocationIntel: %1", _intel);

		// Bail if this intel item is removed for some reason
		if (!CALLM1(gIntelDatabaseClient, "isIntelAdded", _intel)) exitWith {
			OOP_INFO_0("Intel doesn't exist");
		};

		pr _loc = GETV(_intel, "location");
		pr _nameText = localize "STR_LOC_UNKOWN";
		if (GETV(_intel, "accuracyRadius") == 0) then {	// We don't reveal name of location name of which is not known
			_nameText = CALLM0(_loc, "getDisplayName");
		};
		pr _typeText = CALLSM1("Location", "getTypeString", GETV(_intel, "type"));
		pr _timeText = str GETV(_intel, "dateUpdated");
		pr _sideText = str GETV(_intel, "side");
		if (_sideText == "GUER") then { _sideText = "IND"; }; // some people are confused by it being GUERilla

		pr _lnb = [findDisplay 12, "CMUI_INTEL_LISTBOX"] call ui_fnc_findControl;
		// Apply new text for GUI elements
		_lnb lnbSetCurSelRow -1;

		_lnb lnbAddRow [ localize "STR_CMUI_B_NAME", _nameText];
		_lnb lnbAddRow [ localize "STR_CMUI_B_TYPE" , _typeText];
		_lnb lnbAddRow [ localize "STR_CMUI_B_SIDE", _sideText];

		// Add inf capacity
		pr _capinf = CALLM0(_loc, "getCapacityInf");
		//_lnb lnbAddRow [format ["MAX INFANTRY %1", _capInf], "", ""];
		_lnb lnbAddRow [localize "STR_CMUI_MAX_INFANTRY", str _capInf];

		// Add amount of recruits if it's a city
		pr _gameModeData = GETV(_loc, "gameModeData");
		if ( !(IS_NULL_OBJECT(_gameModeData)) && {IS_OOP_OBJECT(_gameModeData)}) then {
			{
				private _rowIdx = _lnb lnbAddRow [_x#0, _x#1];
				if(count _x > 2) then {
					_lnb lnbSetColor [[_rowIdx, 1], _x#2];
				};
			} forEach CALLM0(_gameModeData, "getMapInfoEntries");
		};

		// if (CALLM0(_loc, "getType") == LOCATION_TYPE_CITY) then {
		// } else {
		// 	// Add amount of recruits we can recruit at this place if it's not a city
		// 	pr _pos = CALLM0(_loc, "getPos");
		// 	pr _cities = CALLM1(gGameMode, "getRecruitCities", _pos);
		// 	pr _nRecruits = CALLM1(gGameMode, "getRecruitCount", _cities);
		// 	//_lnb lnbAddRow [format ["AVAILABLE RECRUITS %1", _nRecruits], "", ""];
		// 	_lnb lnbAddRow ["AVAILABLE RECRUITS", str _nRecruits];
		// };

		// Add unit data
		pr _ua = GETV(_intel, "unitData");
		if (count _ua > 0 && {INTEL_PANEL_SHOW_COMPOSITION in _flags}) then {
			_compositionText = "";
			// Amount of infrantry
			pr _soldierCount = 0;
			{_soldierCount = _soldierCount + _x;} forEach (_ua select T_INF);
			_lnb lnbAddRow [localize "STR_CMUI_SOLDIERS", str _soldierCount ];

			// Count vehicles
			pr _uaveh = _ua select T_VEH;
			{
				// If there are some vehicles of this subcategory
				if (_x > 0) then {
					pr _subcatID = _forEachIndex;
					pr _vehName = T_NAMES select T_VEH select _subcatID;
					_lnb lnbAddRow [toUpper(localize _vehName), str _x];
				};
			} forEach _uaveh;
		};

		_lnb lnbSetColumnsPos [0, 0.6];
	ENDMETHOD;

	METHOD(intelPanelClear)
		params [P_THISOBJECT];
		private _mapDisplay = findDisplay 12;
		pr _lnb = ([_mapDisplay, "CMUI_INTEL_LISTBOX"] call ui_fnc_findControl);
		lnbClear _lnb;
	ENDMETHOD;

	METHOD(intelPanelDeselect)
		params [P_THISOBJECT];
		private _mapDisplay = findDisplay 12;
		pr _lnb = ([_mapDisplay, "CMUI_INTEL_LISTBOX"] call ui_fnc_findControl);
		_lnb lnbSetCurSelRow -1;
	ENDMETHOD;

	METHOD(intelPanelUpdateFromIntel)
		params [P_THISOBJECT, P_ARRAY("_flags")];
		
		private _mapDisplay = findDisplay 12;

		private _allIntels = CALLM0(gIntelDatabaseClient, "getAllIntel");
		OOP_INFO_1("ALL INTEL: %1", _allIntels);
		pr _lnb = ([_mapDisplay, "CMUI_INTEL_LISTBOX"] call ui_fnc_findControl);
		_lnb lnbSetColumnsPos [0, 0.13, 0.35, 0.76];
		if (INTEL_PANEL_CLEAR in _flags) then { T_CALLM0("intelPanelClear"); };

		// Read some variables...
		private _showInactive = T_GETV("showIntelInactiveList");
		private _showActive = T_GETV("showIntelActiveList");
		private _showEnded = T_GETV("showIntelEndedList");

		// forEach _allIntels;
		{
			pr _intel = _x;
			pr _className = GET_OBJECT_CLASS(_intel);
			if (!(_className in ["IntelLocation", "IntelCluster"])) then { // Add all non-location intel classes
				pr _shortName = CALLM0(_intel, "getShortName");

				// Check if we need to show intel with this state
				pr _state = GETV(_intel, "state");
				pr _show = switch (_state) do {
					case INTEL_ACTION_STATE_INACTIVE: {_showInactive};
					case INTEL_ACTION_STATE_ACTIVE: {_showActive};
					case INTEL_ACTION_STATE_END: {_showEnded};
					default {false};
				};

				if (_show) then {
					// Calculate time difference between current date and departure date
					pr _intelState = GETV(_intel, "state");
					pr _stateStr = switch (_intelState) do {
						case INTEL_ACTION_STATE_ACTIVE	: {"STR_CMUI_ACTIVE"};
						case INTEL_ACTION_STATE_INACTIVE: {"STR_CMUI_INACTIVE"};
						case INTEL_ACTION_STATE_END		: {"STR_CMUI_ENDED"};
						default {"error"};
					};

					CALLM0(_intel, "getHoursMinutes") params ["_t", "_h", "_m", "_future"];

					OOP_INFO_2("  Intel: %1, T:%2m", _intel, _t);

					// Make a string representation of time difference
					pr _timeDiffStr = if (_h > 0) then {
						format [localize "STR_INT_HR_MIN", _h, _m]
					} else {
						format [localize "STR_INT_MIN", _m]
					};

					if (_future) then { // T-1h 13m
						_timeDiffStr = "T-" + _timeDiffStr;
					} else {
						_timeDiffStr = "T+" + _timeDiffStr;
					};

					// Make a string representation of side
					pr _side = GETV(_intel, "side");
					_sideStr  = switch (_side) do {
						case WEST		:	{localize "STR_CMUI_WEST"};
						case EAST		:	{localize "STR_CMUI_EAST"};
						case independent:	{localize "STR_CMUI_IND"};
						default {localize "STR_CMUI_ALIEN"};
					};

					pr _rowData = [_sideStr, localize _stateStr, localize _shortName, _timeDiffStr];
					pr _index = _lnb lnbAddRow _rowData;
					_lnb lnbSetData [[_index, 0], _intel];

					// Set values for sorting
					pr _valueSide = [WEST, EAST, INDEPENDENT] find _side; // Enumerate side
					pr _valueType = [	"IntelCommanderActionReinforce",
										"IntelCommanderActionBuild", "IntelCommanderActionAttack",
										"IntelCommanderActionPatrol", "IntelCommanderActionRetreat",
										"IntelCommanderActionRecon"] find _className; // Enumerate class name

					//if (!_future) then { _t = -_t; };

					//OOP_INFO_1("  value time: %1", _t);

					_lnb lnbSetValue [[_index, 0], _valueSide];
					// TODO status intel
					_lnb lnbSetValue [[_index, 2], _valueType];
					_lnb lnbSetValue [[_index, 3], _t];

					// set tooltip, SQF-VM doesn't know lnbSetTooltip
					// https://community.bistudio.com/wiki/lnbSetTooltip
#ifndef _SQF_VM
					_lnb lnbSetTooltip [[_index, 0], localize "STR_CMUI_INTEL_TOOLTIP"];
#endif
					FIX_LINE_NUMBERS()

					// grey if ended //Changed variable _stateStr into _intelState for save compatibility
					switch (_intelState) do {
						case INTEL_ACTION_STATE_END: {
							_lnb lnbSetColor [[_index, 0], [0.45, 0.45, 0.45, 1]];
							_lnb lnbSetColor [[_index, 1], [0.45, 0.45, 0.45, 1]];
							_lnb lnbSetColor [[_index, 2], [0.45, 0.45, 0.45, 1]];
							_lnb lnbSetColor [[_index, 3], [0.45, 0.45, 0.45, 1]];
						};
						case INTEL_ACTION_STATE_ACTIVE: {
							_lnb lnbSetColor [[_index, 0], MUIC_COLOR_MISSION];
							_lnb lnbSetColor [[_index, 1], MUIC_COLOR_MISSION];
							_lnb lnbSetColor [[_index, 2], MUIC_COLOR_MISSION];
							_lnb lnbSetColor [[_index, 3], MUIC_COLOR_MISSION];
						};
						case INTEL_ACTION_STATE_INACTIVE: {};
						default {};
					};

					//OOP_INFO_1("ADDED ROW: %1", _rowData);
				};
			};
		} forEach _allIntels;
	ENDMETHOD;

	/*
		Method: intelPanelOnSelChanged
		Description: Called when the selection inside the listbox has changed.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	public METHOD(intelPanelOnSelChanged)
		params [P_THISOBJECT, "_lnb"];

		// We only care if nothing is selected
		if ( (count T_GETV("selectedLocationMarkers") == 0) && (count T_GETV("selectedGarrisonMarkers") == 0) ) then {
			pr _row = lnbCurSelRow _lnb;
			if (_row >= 0) then {

				pr _lnbIndices = lbSelection _lnb;
				T_SETV("lbSelectionIndices", _lnbIndices);
				// if multiple selections were made
				if ((count _lnbIndices) > 1) then {

					T_CALLM2("mapShowAllIntel", false, true); // Force hide

					// show each intel on map
					{
						pr _intel = _lnb lnbData [_x, 0];
						// Make sure that's a valid intel piece
						if (CALLM1(gIntelDatabaseClient, "isIntelAdded", _intel)) then {
							// Hide all intel on the map, except for this one	
							CALLM1(_intel, "showOnMap", true);
						};

					} forEach _lnbIndices;

					// can't show multiple descriptions for intel, need to single select
					T_CALLM1("setDescriptionText", text (localize "STR_CMUI_INTEL_MULTISELECT"));

				} else {
					pr _intel = _lnb lnbData [_row, 0];
					// Make sure that's a valid intel piece
					if (CALLM1(gIntelDatabaseClient, "isIntelAdded", _intel)) then {
						// Hide all intel on the map, except for this one
						T_CALLM2("mapShowAllIntel", false, true); // Force hide
						CALLM1(_intel, "showOnMap", true);

						// Find description for this item
						pr _shortName = CALLM0(_intel, "getShortName");

						// Get extra custom info
						pr _extraInfo = CALLM0(_intel, "getInfo");

						pr _locId = switch toUpper(_shortName) do {
							case "STR_NOTI_ATTACK" 				: 	{ "STR_CMUI_INTEL_ATTACK" };
							case "STR_NOTI_CONSTRUCT_ROADBLOCK" : 	{ "STR_CMUI_INTEL_RB" };
							case "STR_NOTI_REINFORCE_GARRISON"	: 	{ "STR_CMUI_INTEL_REINFORCE" };
							case "STR_NOTI_PATROL" 				:	{ "STR_CMUI_INTEL_PATROL" };
							case "STR_NOTI_ASSIGN_OFFICER" 		:	{ "STR_CMUI_INTEL_OFFICER" };
							case "STR_NOTI_BUILDING_SUPPLIES" 	: 	{ "STR_CMUI_INTEL_CONV_BUILDING" };
							case "STR_NOTI_AMMUNITION" 			:	{ "STR_CMUI_INTEL_CONV_AMMO" };
							case "STR_NOTI_EXPLOSIVES" 			:	{ "STR_CMUI_INTEL_CONV_EXPLOSIVES" };
							case "STR_NOTI_MEDICAL" 			:	{ "STR_CMUI_INTEL_CONV_MEDICAL" };
							case "STR_NOTI_MISC" 				:	{ "STR_CMUI_INTEL_CONV_MISC" };
							default 								{ "STR_CMUI_INTEL_DEFAULT" };
						};
						private _desc = format ["<t color='#AAAAAA'>%1</t><br/>%2", localize _locId, _extraInfo];
						T_CALLM1("setDescriptionText", _desc);
					};
				};
			} else {
				T_CALLM0("mapShowAllIntel");
				// reset selected listbox entries
				T_SETV("lbSelectionIndices", []);
				T_CALLM1("setDescriptionText", localize "STR_CMUI_INTEL_MULTISELECT");
			};
		};

	ENDMETHOD;

	METHOD(intelPanelOnDblClick)
		params [P_THISOBJECT, "_lnb", "_index"];

		if (_index != -1) then {
			// Zoom into the area of this intel
			pr _intel = _lnb lnbData [_index, 0];
			if (IS_OOP_OBJECT(_intel)) then {
				pr _zoomPos = CALLM0(_intel, "getMapZoomPos");
				pr _ctrl = ((finddisplay 12) displayCtrl 51);
				_ctrl ctrlMapAnimAdd [0.3, 0.06, _zoomPos];
				ctrlMapAnimCommit _ctrl;
			};
		};
		
	ENDMETHOD;

	// Hides or shows the sort-by-... buttons
	/*
	METHOD(intelPanelShowButtons)
		params [P_THISOBJECT, P_BOOL("_show")];

		_show = _show && (
			T_GETV("showIntelActive") ||
			T_GETV("showIntelInactive") ||
			T_GETV("showIntelEnded")
		);

		// Show buttons
		{
			((findDisplay 12) displayCtrl _x) ctrlShow _show;
		} forEach [	IDC_LOCP_LISTNBOX_BUTTONS_GROUP,
					IDC_LOCP_LISTNBOX_BUTTONS_0,
					IDC_LOCP_LISTNBOX_BUTTONS_1,
					IDC_LOCP_LISTNBOX_BUTTONS_2];
		
	ENDMETHOD;
	*/

	METHOD(intelPanelSortIntel)
		params [P_THISOBJECT, P_STRING("_category"), P_BOOL("_inverse")];
		pr _col = ["side", "status", "type", "time"] find _category;
		if (_col != -1) then {
			pr _lnb = [(findDisplay 12), "CMUI_INTEL_LISTBOX"] call ui_fnc_findControl;
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
	ENDMETHOD;

	METHOD(intelPanelOnSortButtonClick)
		params [P_THISOBJECT, P_STRING("_button")];
		pr _inverse = !T_GETV("intelPanelSortInverse");
		OOP_INFO_1("INTEL PANEL ON SORT BUTTON CLICK: %1", _button);
		T_CALLM2("intelPanelSortIntel", _button, _inverse); // _button - "side", "status", "type", "time"
		T_SETV("intelPanelSortInverse", _inverse);
		T_SETV("intelPanelSortCategory", _button);
	ENDMETHOD;



	/*                                                                                                        																										
	88888888888  8b           d8  88888888888  888b      88  888888888888                                            
	88           `8b         d8'  88           8888b     88       88                                                 
	88            `8b       d8'   88           88 `8b    88       88                                                 
	88aaaaa        `8b     d8'    88aaaaa      88  `8b   88       88                                                 
	88"""""         `8b   d8'     88"""""      88   `8b  88       88                                                 
	88               `8b d8'      88           88    `8b 88       88                                                 
	88                `888'       88           88     `8888       88                                                 
	88888888888        `8'        88888888888  88      `888       88                                                 

	88        88         db         888b      88  88888888ba,    88           88888888888  88888888ba    ad88888ba   
	88        88        d88b        8888b     88  88      `"8b   88           88           88      "8b  d8"     "8b  
	88        88       d8'`8b       88 `8b    88  88        `8b  88           88           88      ,8P  Y8,          
	88aaaaaaaa88      d8'  `8b      88  `8b   88  88         88  88           88aaaaa      88aaaaaa8P'  `Y8aaaaa,    
	88""""""""88     d8YaaaaY8b     88   `8b  88  88         88  88           88"""""      88""""88'      `"""""8b,  
	88        88    d8""""""""8b    88    `8b 88  88         8P  88           88           88    `8b            `8b  
	88        88   d8'        `8b   88     `8888  88      .a8P   88           88           88     `8b   Y8a     a8P  
	88        88  d8'          `8b  88      `888  88888888Y"'    88888888888  88888888888  88      `8b   "Y88888P"   
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
	public event METHOD(onMouseButtonDown)
		params [P_THISOBJECT, "_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

		OOP_INFO_1("ON MOUSE BUTTON DOWN: %1", _this);

		// Ignore right clicks for now
		if (_button == 1) exitWith {};

		// Exit if game mode isn't initialized
		if (isNil "gGameMode") exitWith {};

		/*
		Contexts to filter:
		Click anywhere AND givingOrder == true
		Click anywhere AND with an alt AND one garrison marker has been selected before
		We click on a location marker, No location markers have been selected before
		*/

		pr _garrisonsUnderCursor = CALLSM("MapMarkerGarrison", "getMarkersUnderCursor", [_displayorcontrol ARG _xPos ARG _yPos]);
		pr _locationsUnderCursor = CALLSM("MapMarkerLocation", "getMarkersUnderCursor", [_displayorcontrol ARG _xPos ARG _yPos]);

		// Try to prioritize location marker
		pr _markersUnderCursor = _locationsUnderCursor + _garrisonsUnderCursor;

		OOP_INFO_1("MARKERS UNDER CURSOR: %1", _markersUnderCursor);

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

			if ((count _markersUnderCursor > 0) && (count _markersUnderCursor <= 2)) then {
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
				OOP_ERROR_0("Cannot resolve target position.");
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

		// Hey we have clicked on something!
		T_CALLM2("_select", _garrisonsUnderCursor, _locationsUnderCursor);

		// Launch snek
		pr _posWorld = _displayorcontrol posScreenToWorld [_xPos, _yPos];
		if ((_posWorld distance2D [0, 0, 0]) < 150 ) then {
			if (CALLSM0("Snek", "isRunning")) then {
				CALLSM0("Snek", "stop");
			} else {
				CALLSM0("Snek", "start");
			};
		};

	ENDMETHOD;

	METHOD(_select)
		params [P_THISOBJECT, P_ARRAY("_garrisons"), P_ARRAY("_locations")];
		
		// Disable the garrison action listbox
		T_CALLM1("garActionMenuEnable", false);

		pr _selectedGarrisons = CALLSM0("MapMarkerGarrison", "getAllSelected");
		pr _selectedLocations = CALLSM0("MapMarkerLocation", "getAllSelected");

		// Deselect evereything else
		{ CALLM1(_x, "select", false); } forEach _selectedGarrisons;
		{
			CALLM1(_x, "select", false);
			pr _intel = CALLM0(_x, "getIntel");
			// Disable the circle marker which shows the recruitment radius
			if (IS_OOP_OBJECT(_intel)) then {
				if (GETV(_intel, "side") == playerSide) then {
					CALLM1(_x, "setAccuracyRadius", 0);
				};
			};
		} forEach _selectedLocations;

		// Select the markers themselves
		{ CALLM1(_x, "select", true); } forEach _markersUnderCursor;

		// If there is any garrison selected then enable its menu
		if (count _garrisons > 0) then {
			pr _garRecord = CALLM0(_garrisons#0, "getGarrisonRecord");
			T_CALLM1("garSelMenuSetGarRecord", _garRecord);
			T_CALLM1("garSelMenuEnable", true);
		};

		// If there is any location selected
		if (count _locations > 0) then {
			pr _locIntel = CALLM0(_locations#0, "getIntel");
			if (GETV(_locIntel, "side") == playerSide) then { // We can only perform things on a friendly location
				T_CALLM1("locSelMenuSetLocation", GETV(_locIntel, "location"));
				T_CALLM1("locSelMenuEnable", true);
				pr _radius = CALLM0(gGameMode, "getRecruitmentRadius");
				CALLM1(_locations#0, "setAccuracyRadius", _radius);
			};
		};

		
		if (count _garrisons == 0 && count _locations == 0) then {
			T_CALLM0("showGlobalIntel");
		} else {
			// Set the intel panel for items
			T_CALLM0("setIntelPanelForItems");
			//Decide what to do with the panel on the right
			if(count _locations > 0) then {
				// If we have selected both a garrison and a location
				pr _locIntel = CALLM0(_locations#0, "getIntel");
				pr _flags = if(count _garrisons == 0) then {
					[INTEL_PANEL_SHOW_COMPOSITION]
				} else {
					[]
				};
				T_CALLM2("intelPanelUpdateFromLocationIntel", _locIntel, _flags);
			};
			if(count _garrisons > 0) then {
				pr _garRecords = _garrisons apply { CALLM0(_x, "getGarrisonRecord") } select { _x != NULL_OBJECT };
				T_CALLM1("intelPanelUpdateFromGarrisonRecords", _garRecords);
			};
		};

		T_SETV("selectedGarrisonMarkers", _garrisons);
		T_SETV("selectedLocationMarkers", _locations);
		T_CALLM0("updateHintTextFromContext");
	ENDMETHOD;

	/*
		Method: showGlobalIntel
	*/
	METHOD(showGlobalIntel)
		params [P_THISOBJECT];

		// set text on sorting buttons
		pr _btns = T_GETV("sortButtons");
		if !(_btns isEqualTo []) then {
			_btns#0 ctrlSetText localize "STR_CMUI_B_SIDE";
			_btns#1 ctrlSetText localize "STR_CMUI_B_STATUS";
			_btns#2 ctrlSetText localize "STR_CMUI_B_TYPE";
			_btns#3 ctrlSetText localize "STR_CMUI_B_TIME";
		};

		// reset selected listbox entries
		T_SETV("lbSelectionIndices", []);
		T_CALLM1("setDescriptionText", localize "STR_CMUI_INTEL_MULTISELECT"); // reset intel description panel

		// Disable the garrison action listbox
		T_CALLM1("garActionMenuEnable", false);

		// Disable the selected garrison menu
		T_CALLM1("garSelMenuEnable", false);

		// Disable the selected location menu
		T_CALLM1("locSelMenuEnable", false);

		// Clear the intel panel
		//T_CALLM0("intelPanelClear");

		// Fill the intel panel from intel
		T_CALLM1("intelPanelUpdateFromIntel", [INTEL_PANEL_CLEAR]);
		T_CALLM0("intelPanelDeselect");
		T_CALLM2("intelPanelSortIntel", T_GETV("intelPanelSortCategory"), T_GETV("intelPanelSortInverse"));

		// Reset the map view
		T_CALLM0("mapShowAllIntel");

		// Show the buttons of the listbox
		//T_CALLM1("intelPanelShowButtons", true);
	ENDMETHOD;


	METHOD(onIntelAdded)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];

		// We only care if nothing is selected
		if ( (count T_GETV("selectedLocationMarkers") == 0) && (count T_GETV("selectedGarrisonMarkers") == 0) ) then {
			// todo if we have something currently selected, we should select the old item, etc, etc, probably don't care much for that now ... 

			// Fill the intel panel from intel
			T_CALLM1("intelPanelUpdateFromIntel", [INTEL_PANEL_CLEAR]);
			T_CALLM0("intelPanelDeselect");
			T_CALLM2("intelPanelSortIntel", T_GETV("intelPanelSortCategory"), T_GETV("intelPanelSortInverse"));

			// Reset the map view
			T_CALLM0("mapShowAllIntel");
		} else {
			// Something must be selected
			// So we want to check if drawing of all intel on the map is enabled or not
			T_CALLM0("mapShowAllIntel");
		};
	ENDMETHOD;


	METHOD(onIntelRemoved)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];

		// They are the same now
		T_CALLM1("onIntelAdded", _intel);
	ENDMETHOD;


	public event METHOD(onMouseButtonUp)
		params [P_THISOBJECT, "_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

	ENDMETHOD;

	public event METHOD(onMouseButtonClick)
		params [P_THISOBJECT, "_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

	ENDMETHOD;

	// Common code for all 'checkboxes' in this UI
	// Checkboxes are buttons with [x] or [ ] at the start of their text
	// Returns the new state of this 'checkbox'
	// Because in arma checkbox is only the checkbox itself, and it has no text, WTF
	public event METHOD(onButtonClickCheckbox)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];

		OOP_INFO_1("onButtonClickCheckbox: %1", _this);

		private _checkedPrev = [_button] call ui_fnc_buttonCheckboxGetCheck;

		// Return the new value
		!_checkedPrev
	ENDMETHOD;

	/*
		Method: onButtonClickShowIntelInactive
		Description: Toggles visibility of inactive intel on the map.

	*/
	public event METHOD(onButtonClickShowIntelInactive)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);
		T_SETV("showIntelInactive", _checked);
		T_CALLM0("mapShowAllIntel");
	ENDMETHOD;

	/*
		Method: onButtonClickShowIntelInactive
		Description: Toggles visibility of inactive intel in the listbox.

	*/
	public event METHOD(onButtonClickShowIntelInactiveList)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);
		T_SETV("showIntelInactiveList", _checked);

		// If nothing is selected on the map, update the intel panel
		if ( (count T_GETV("selectedLocationMarkers") == 0) && (count T_GETV("selectedGarrisonMarkers") == 0) ) then {
			T_CALLM1("intelPanelUpdateFromIntel", [INTEL_PANEL_CLEAR]);
			T_CALLM0("intelPanelDeselect");
			T_CALLM2("intelPanelSortIntel", T_GETV("intelPanelSortCategory"), T_GETV("intelPanelSortInverse"));
		};
		
	ENDMETHOD;

	/*
		Method: onButtonClickShowIntelActive
		Description: Toggles visibility of intel on the map.

	*/
	public event METHOD(onButtonClickShowIntelActive)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);
		T_SETV("showIntelActive", _checked);
		T_CALLM0("mapShowAllIntel");
	ENDMETHOD;

	/*
		Method: onButtonClickShowIntelActiveList
		Description: Toggles visibility of intel in the listbox.

	*/
	public event METHOD(onButtonClickShowIntelActiveList)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);
		T_SETV("showIntelActiveList", _checked);

		// If nothing is selected on the map, update the intel panel 
		if ( (count T_GETV("selectedLocationMarkers") == 0) && (count T_GETV("selectedGarrisonMarkers") == 0) ) then {
			T_CALLM1("intelPanelUpdateFromIntel", [INTEL_PANEL_CLEAR]);
			T_CALLM0("intelPanelDeselect");
			T_CALLM2("intelPanelSortIntel", T_GETV("intelPanelSortCategory"), T_GETV("intelPanelSortInverse"));
		};
		
	ENDMETHOD;

	/*
		Method: onButtonClickShowIntelEnded
		Description: Toggles visibility of intel on the map.

	*/
	public event METHOD(onButtonClickShowIntelEnded)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);
		T_SETV("showIntelEnded", _checked);
		T_CALLM0("mapShowAllIntel");
	ENDMETHOD;

	/*
		Method: onButtonClickShowIntelEndedList
		Description: Toggles visibility of intel in the listbox.

	*/
	public event METHOD(onButtonClickShowIntelEndedList)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);
		T_SETV("showIntelEndedList", _checked);

		// If nothing is selected on the map, update the intel panel too
		if ( (count T_GETV("selectedLocationMarkers") == 0) && (count T_GETV("selectedGarrisonMarkers") == 0) ) then {
			T_CALLM1("intelPanelUpdateFromIntel", [INTEL_PANEL_CLEAR]);
			T_CALLM0("intelPanelDeselect");
			T_CALLM2("intelPanelSortIntel", T_GETV("intelPanelSortCategory"), T_GETV("intelPanelSortInverse"));
		};
	ENDMETHOD;

	// shows or hides intel panel controls
	public event METHOD(onButtonClickShowIntelPanel)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		OOP_INFO_1("onButtonClickShowIntelPanel: %1", _this);
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);

		T_SETV("showIntelPanel", _checked);
		
		// All the class names of controls we will hide/show
		private _controlNames = [	"CMUI_INTEL_HEADLINE", 
									"CMUI_INTEL_LISTBOX", 
									"CMUI_INTEL_LISTBOX_BG", 
									"CMUI_INTEL_BTN_INACTIVE_MAP",
									"CMUI_INTEL_BTN_ACTIVE_MAP",
									"CMUI_INTEL_BTN_ENDED_MAP",
									"CMUI_INTEL_BTN_INACTIVE_LIST",
									"CMUI_INTEL_BTN_ACTIVE_LIST",
									"CMUI_INTEL_BTN_ENDED_LIST",
									"CMUI_INTEL_ACTIVE_DESCR",
									"CMUI_INTEL_INACTIVE_DESCR",
									"CMUI_INTEL_ENDED_DESCR",
									"CMUI_INTEL_BTNGRP",
									"CMUI_INTEL_BTNGRP_BG",
									"CMUI_INTEL_DESCRIPTION_BG",
									"CMUI_INTEL_DESCRIPTION_FRAME",
									"CMUI_INTEL_DESCRIPTION"
								];
		
		{
			([(finddisplay 12), _x] call ui_fnc_findControl) ctrlShow _checked;
		} forEach _controlNames;
	ENDMETHOD;

	public event METHOD(onButtonClickShowLocations)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);
		T_SETV("showLocations", _checked);

		pr _allLocMarkers = CALLSM0("MapMarkerLocation", "getAll");
		{
			CALLM1(_x, "show", _checked);
		} forEach _allLocMarkers;
	ENDMETHOD;

	public event METHOD(onButtonClickShowLocationMiniPanels)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);

		T_SETV("showLocationMiniPanels", _checked);
	ENDMETHOD;

	public event METHOD(onButtonClickShowPlayers)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);

		[_checked] call ui_fnc_enablePlayerMarkers;
	ENDMETHOD;

	/*
	public event METHOD(onButtonClickShowEnemies)
		params [P_THISOBJECT, ["_button", controlNull, [controlNull]]];
		pr _checked = T_CALLM1("onButtonClickCheckbox", _button);
		T_SETV("showEnemies", _checked);

	ENDMETHOD;
	*/

	public event METHOD(onButtonClickClearNotifications)
		params [P_THISOBJECT];

		CALLSM1("MapMarkerLocation", "setAllNotifications", false);
	ENDMETHOD;

	/*
		Method: onMapOpen
		Description: Called by user interface event handler each time the map is opened

		No parameters
	*/
	public event METHOD(onMapOpen)
		params [P_THISOBJECT];
		pr _mapDisplay = findDisplay 12;

		// Reset the map UI to default state
		T_CALLM0("showGlobalIntel");

		// Redraw mini panels
		if (T_GETV("showLocationMiniPanels")) then {
			{
				pr _ctrl = GETV(_x, "microPanel") select 0;
				if (!isNull _ctrl) then {ctrlDelete _ctrl;};
			} forEach (CALLSM0("MapMarkerLocation", "getAll") + CALLSM0("MapMarkerGarrison", "getAll"));
		};
	ENDMETHOD;

	// Not used now
	public event STATIC_METHOD(onButtonDownAddFriendlyGroup)
		params ["_thisClass", "_control"];

		private _mapDisplay = findDisplay 12;

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
		private _AI = CALLSM1("AICommander", "getAICommander", WEST);
		CALLM2(_AI, "postMethodAsync", "debugAddGroupToLocation", [_loc ARG 5]);

		(_mapDisplay displayCtrl IDC_BPANEL_HINTS) ctrlSetText "A friendly group has been added to the location!";
		*/
	ENDMETHOD;


	/*
		UNUSED!

		Method: onMouseEnter
		Description: Called when the mouse cursor enters the control.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	public event METHOD(onMouseEnter)
		params [P_THISOBJECT, "_ctrl"];

		pr _mapDisplay = findDisplay 12;
		
		T_CALLM0("updateHintTextFromContext");
		false // Must return false to still make it do the config-defined action
	ENDMETHOD;

	/*
		UNUSED!

		Method: onMouseExit
		Description: Called when the mouse cursor exits the control.

		Parameters: 
		0: _control - Reference to the control which called this method
	*/
	public event METHOD(onMouseExit)
		params [P_THISOBJECT, "_ctrl"];

		T_CALLM0("updateHintTextFromContext");
		false // Must return false to still make it do the config-defined action
	ENDMETHOD;


	/*
		Method: onMapDraw
		Description: Gets called each frame if map is open and being redrawn.
	*/
	public event METHOD(onMapDraw)
		params [P_THISOBJECT];

		// listbox selection changed event handler is called before lbSelection updates 
		// so we check here and call the method again to properly enable multiselction
		pr _mapDisplay = findDisplay 12;
		pr _lnb = (_mapdisplay displayCtrl IDC_LOCP_LISTNBOX);
		pr _lbSel = T_GETV("lbSelectionIndices");
		if !(_lbSel isEqualTo []) then {
			if ((count lbSelection _lnb) != (count _lbSel)) then { 
				T_CALLM1("intelPanelOnSelChanged", _lnb); // lbSelection size has changed, update selected intel
			};
		};

		// Garrison action listbox will update its position 
		T_CALLM0("garActionMenuUpdatePos");

		// Selected garrison menu will update its position
		T_CALLM0("garSelMenuUpdatePos");

		// Selected location menu will update its position
		T_CALLM0("locSelMenuUpdatePos");

		// Redraw the drawArrow on the map if we are currently giving order to something
		T_CALLM0("garOrderUpdateArrow");

		// Update state of respawn panel thing
		T_CALLM0("respawnPanelOnDraw");

		// Update location micro panels
		T_CALLM0("updateLocationMiniPanels");

	ENDMETHOD;

	/*
		Method: onMouseMoving
		Fires continuously while moving the mouse with a certain interval.
	*/
	public event METHOD(onMapMouseMoving)
		params [P_THISOBJECT, "_control", "_xPos", "_yPos", "_mouseOver"];

		//pr _garrisonsUnderCursor = CALLSM("MapMarkerGarrison", "getMarkersUnderCursor", [_control ARG _xPos ARG _yPos]); // Let's not do it for garrison markers yet, ok?
		pr _garrisonsUnderCursor = [];
		pr _locationsUnderCursor = CALLSM("MapMarkerLocation", "getMarkersUnderCursor", [_control ARG _xPos ARG _yPos]);
		pr _markersUnderCursor = _garrisonsUnderCursor + _locationsUnderCursor;

		// Previous markers under cursor
		pr _markersUnderCursorOld = T_GETV("markersUnderCursor");

		//OOP_INFO_1("ON MAP MOUSE MOVING: current: %1", _markersUnderCursor);
		//OOP_INFO_1("ON MAP MOUSE MOVING: old: %1", _markersUnderCursorOld);

		// Check if mouse has entered any new markers
		{
			if (!(_x in _markersUnderCursorOld)) then {
				//OOP_INFO_1("Entered marker: %1", _x);
				// Mouse has entered this marker
				CALLM1(_x, "setMouseOver", true);
			};
		} forEach _markersUnderCursor;

		// Check if any old markers are not under cursor any more
		{
			if (!(_x in _markersUnderCursor)) then {
				// Mouse has left this marker
				if (IS_OOP_OBJECT(_x)) then {
					//OOP_INFO_1("Left marker: %1", _x);
					CALLM1(_x, "setMouseOver", false);
				};
			};
		} forEach _markersUnderCursorOld;

		T_SETV("markersUnderCursor", _markersUnderCursor);

	ENDMETHOD;



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

	METHOD(garOrderUpdateArrow)
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
	ENDMETHOD;


	// //////////////////////////////////////////////////////////////////////////////////
	// //  R E S P A W N   B U T T O N
	// //////////////////////////////////////////////////////////////////////////////////

	public METHOD(respawnPanelEnable)
		params [P_THISOBJECT, P_BOOL("_enable")];

		pr _respawnCtrl = [(finddisplay 12), "CMUI_BUTTON_RESPAWN"] call ui_fnc_findControl;
		_respawnCtrl ctrlShow _enable;
		_respawnCtrl ctrlEnable false; // Disable the button initially, it will re-enable itself later

		pr _respawnStaticCtrl = [(finddisplay 12), "CMUI_STATIC_RESPAWN"] call ui_fnc_findControl;
		_respawnStaticCtrl ctrlShow _enable;

		// Might not be loaded yet
		if(!isNil "gGameModeServer") then {

			// Request update on players restore point from server
			REMOTE_EXEC_CALL_METHOD(gGameModeServer, "syncPlayerInfo", [player], ON_SERVER);

		};

		T_SETV("respawnPanelEnabled", _enable);
		T_SETV("doZoom", _enable);
	ENDMETHOD;

	METHOD(respawnPanelEnabled)
		params [P_THISOBJECT];
		T_GETV("respawnPanelEnabled");
	ENDMETHOD;

	public event METHOD(onButtonClickRespawn)
		params [P_THISOBJECT];

		// If player has clicked this button, then it must be enabled
		// If it's enabled, then respawn is possible here

		pr _restoreGear = gPlayerRestoreData;
		pr _locMarkers = T_GETV("selectedLocationMarkers");

		pr _loc = if (count _locMarkers != 0) then {
			pr _locMarker = _locMarkers#0;				// Get the location from marker
			pr _intel = CALLM0(_locMarker, "getIntel");	// marker->intel->location
			GETV(_intel, "location")
		} else {
			NULL_OBJECT
		};

		private _respawnPos = 0;
		private _respawnOkay = if (IS_OOP_OBJECT(_loc)) then {
			// Teleport player
			_respawnPos = CALLM0(_loc, "getPlayerRespawnPos");
			// Show a message to everyone
			pr _text = format [localize "STR_CMUI_PLAYER_RESPAWNED", name player, CALLM0(_loc, "getDisplayName")];
			[_text] remoteExecCall ["systemChat"];
			// Save the last respawn position
			T_SETV("lastRespawnPos", _respawnPos);
			true
		} else {
			// We want to be super sure that all is ok
			pr _restore = !(_restoreGear isEqualTo []);
			if (_restore) then {
				_respawnPos = ASLToAGL (_restoreGear#2);
			};
			_restore;
		};

		if(!_respawnOkay) exitWith {
			OOP_ERROR_1("Selected spawn Location at marker %1 does not exist", _locMarkers);
		};

		// Call gameMode method
		pr _args = [player, objNull, "", 0, _restoreGear, !IS_OOP_OBJECT(_loc), playerSide];
		CALLM(gGameMode, "playerSpawn", _args);

		// Execute script on the server
		[player, objNull, playerSide, +_respawnPos] remoteExec ["fnc_onPlayerRespawnServer", ON_SERVER, NO_JIP];

		// Disable this panel
		T_CALLM1("respawnPanelEnable", false);

		// Close the map
		openMap [false, false];
	ENDMETHOD;

	// Sets text on the respawn panel
	METHOD(respawnPanelSetText)
		params [P_THISOBJECT, P_STRING("_text")];

		pr _ctrl = [(finddisplay 12), "CMUI_STATIC_RESPAWN"] call ui_fnc_findControl;
		_ctrl ctrlSetText _text;
	ENDMETHOD;

	// Gets called on each draw event of map (on each frame when map is open)
	METHOD(respawnPanelOnDraw)
		params [P_THISOBJECT];

		if (T_GETV("respawnPanelEnabled")) then {
			pr _canRestore = !isNil "gPlayerRestoreData" && {!(gPlayerRestoreData isEqualTo [])};

			if(T_GETV("doZoom") && visibleMap) then {
				private _zoomPos = if(_canRestore) then { gPlayerRestoreData#2 } else { T_GETV("lastRespawnPos") };
				if(_zoomPos isEqualTo []) then {
					private _locMarkers = GETSV("MapMarkerLocation", "all");
					//private _locs = CALLSM0("Location", "getAll");
					private _locIdx = _locMarkers findIf { GETV(_x, "type") == LOCATION_TYPE_RESPAWN };
					if(_locIdx != NOT_FOUND) then {
						private _locMarker = _locMarkers#_locIdx;
						CALLM0(_locMarker, "select");
						_zoomPos = GETV(_locMarker, "pos");
						// If we do this it overwrites the player restore position, as restore data is not available straight away
						// Perhaps set restore data should clear selected marker?
						//T_CALLM2("_select", [], [_locMarker]);
					};
				};

				if !(_zoomPos isEqualTo []) then {
					mapAnimAdd [0.1, 0.05, _zoomPos];
					mapAnimCommit;
					T_SETV("doZoom", false);
				};
			};
			pr _locMarkers = T_GETV("selectedLocationMarkers");

			pr _ctrlButton = [(finddisplay 12), "CMUI_BUTTON_RESPAWN"] call ui_fnc_findControl;
			

			if(_canRestore) then {
				_ctrlButton ctrlSetText localize "STR_CMUI_RESTORE";
			} else {
				_ctrlButton ctrlSetText localize "STR_CMUI_RESPAWN";
			};

			// Bail if game mode is not initialized
			if (!CALLM0(gGameManager, "isGameModeInitialized")) exitWith {
				T_CALLM1("respawnPanelSetText", localize "STR_CMUI_CANT_RESPAWN_NOT_INITIALIZED");
				_ctrlButton ctrlEnable false;
			};

			// Bail if no markers are selected
			if (!_canRestore && count _locMarkers != 1) exitWith {
				T_CALLM1("respawnPanelSetText", localize "STR_CMUI_SELECT_RESPAWN_POINT");
				_ctrlButton ctrlEnable false;
			};

			if(count _locMarkers == 1) then {
				pr _locMarker = _locMarkers#0;				// Get the location from marker
				pr _intel = CALLM0(_locMarker, "getIntel");	// marker->intel->location
				pr _loc = GETV(_intel, "location");			//
				pr _locBorderArea = CALLM0(_loc, "getBorder");
				pr _locPos = CALLM0(_loc, "getPos");

				// Only one location is selected
				
				// Bail if location object is wrong (why??)
				if (IS_NULL_OBJECT(_loc)) exitWith {};		// Because who knows...

				// Bail if respawn is disabled
				if (!CALLM1(_loc, "playerRespawnEnabled", playerSide)) exitWith {
					// Respawn is disabled here through location's methods
					T_CALLM1("respawnPanelSetText", localize "STR_CMUI_RESAPWN_DISABLED");
					_ctrlButton ctrlEnable false;
				};

				// Check if there are enemies occupying this place, etc...
				pr _enemySides = [EAST, WEST, INDEPENDENT] - [playerSide];

				// Check enemies in area
				// todo: might not want to check that on each frame maybe... maybe once in a few frames instead
				pr _index = (allUnits select {(side group _x) in _enemySides}) findIf {	// Find all enemy units...
					// ((_x distance _locPos) < 200) ||									// Which are very close
					(_x inArea _locBorderArea)											// Or inside the area
				};

				// Bail if there are enemies in area
				if (_index != -1) exitWith {
					T_CALLM1("respawnPanelSetText", localize "STR_CMUI_RESPAWN_DISABLED_NEAR_ENY");
					_ctrlButton ctrlEnable false;
				};

				// No enemies found there
				if(_canRestore) then {
					T_CALLM1("respawnPanelSetText", localize "STR_CMUI_RESTORE_GEARS");
				} else {
					T_CALLM1("respawnPanelSetText", localize "STR_CMUI_CAN_RESPAWN");
				};
				_ctrlButton ctrlEnable true;
			} else {
				T_CALLM1("respawnPanelSetText", localize "STR_CMUI_RESTORE_GEARS_LAST_POSITION");
				_ctrlButton ctrlEnable true;
			};
		};
	ENDMETHOD;


	METHOD(updateLocationMiniPanels)
		params [P_THISOBJECT];

		pr _allMapMarkers = CALLSM0("MapMarkerLocation", "getAll");
		pr _allGarrisonMarkers = CALLSM0("MapMarkerGarrison", "getAll");
		pr _ctrlMap = ((findDisplay 12) displayCtrl IDC_MAP);

		if (T_GETV("showLocationMiniPanels")) then {

			// Create panels for everything except for cities

			pr _typesDontShowPanel = [LOCATION_TYPE_CITY, LOCATION_TYPE_POLICE_STATION, LOCATION_TYPE_UNKNOWN];
			pr _markersShowPanel = _allMapMarkers select {
				! ((GETV(_x, "type") in _typesDontShowPanel));
			};
			{ // forEach (_markersShowPanel + _allGarrisonMarkers);
				pr _unitData = [];
				if (GET_OBJECT_CLASS(_x) == "MapMarkerLocation") then {
					pr _intel = GETV(_x, "intel");
					if (GETV(_intel, "side") != playerSide) then {
						_unitData = GETV(_intel, "unitData");
					};
				} else {
					pr _garRecord = GETV(_x, "garRecord");
					pr _loc = GETV(_garRecord, "location");
					// Ignore garrisons at locations of types which we want to ignore
					if (!IS_NULL_OBJECT(_loc)) then {
						if (!(CALLM0(_loc, "getType") in _typesDontShowPanel)) then {
							_unitData = CALLM0(_garRecord, "getBasicComposition");
						};
					} else {
						_unitData = CALLM0(_garRecord, "getBasicComposition");
					};					
				};
				if (count _unitData > 0) then {
					pr _ctrl = GETV(_x, "microPanel") select 0;
					
					// If this marker doesn't have this micro panel, create one
					if (isNull _ctrl) then {
						// Calculate amounts of units
						OOP_INFO_2("updateLocationMiniPanels: intel: %1, unitData: %2", _intel, _unitData);
						pr _inf = _unitData#T_INF;
						pr _veh = _unitData#T_VEH;
						pr _nInf = 0;
						{ _nInf = _nInf + _x; } forEach _inf;

						pr _nTransport =	_veh#T_VEH_car_unarmed +
											_veh#T_VEH_car_armed +
											_veh#T_VEH_MRAP_unarmed +
											_veh#T_VEH_MRAP_HMG +
											_veh#T_VEH_MRAP_GMG +
											_veh#T_VEH_IFV +
											_veh#T_VEH_APC +
											_veh#T_VEH_truck_inf;

						pr _nArmor 		=	_veh#T_VEH_MRAP_unarmed +
											_veh#T_VEH_MRAP_HMG +
											_veh#T_VEH_MRAP_GMG +
											_veh#T_VEH_IFV +
											_veh#T_VEH_APC +
											_veh#T_VEH_MBT;

						pr _nAir = 			_veh#T_VEH_heli_light +
											_veh#T_VEH_heli_heavy +
											_veh#T_VEH_heli_cargo +
											_veh#T_VEH_heli_attack +
											_veh#T_VEH_plane_attack +
											_veh#T_VEH_plane_fighter +
											_veh#T_VEH_plane_cargo +
											_veh#T_VEH_plane_unarmed +
											_veh#T_VEH_plane_VTOL;

						pr _nStatics = 		_veh#T_VEH_stat_HMG_high +
											_veh#T_VEH_stat_HMG_low+
											_veh#T_VEH_stat_GMG_high+
											_veh#T_VEH_stat_GMG_low+
											_veh#T_VEH_stat_AA+
											_veh#T_VEH_stat_AT+
											_veh#T_VEH_stat_mortar_light+
											_veh#T_VEH_stat_mortar_heavy;
						
						// Each row is: name, amount, base amount (if amount==baseAmount, bar size is 50%)
						pr _rows = [
										[localize "STR_CMUI_INFANTRY", _nInf, 20],
										[localize "STR_CMUI_TRANSPORT", _nTransport, 2],
										[localize "STR_CMUI_ARMOR", _nArmor, 4],
										[localize "STR_CMUI_STATICS", _nStatics, 3],
										[localize "STR_CMUI_AIR", _nAir, 1]
									];
						_ctrl = CALLSM1("ClientMapUI", "createLocationMiniPanel", _rows);
						SETV(_x, "microPanel", [_ctrl]);
					};

					CALLSM3("ClientMapUI", "updateMiniPanelPosition", _ctrl, _ctrlMap, GETV(_x, "pos"));
				};


			} forEach (_markersShowPanel + _allGarrisonMarkers);


			// Create panels for cities
			{
				if (GETV(_x, "type") == LOCATION_TYPE_CITY) then {

					pr _ctrl = GETV(_x, "microPanel") select 0;

					if (isNull _ctrl) then {
						pr _intel = GETV(_x, "intel");
						pr _loc = GETV(_intel, "location");
						pr _gmData = CALLM0(_loc, "getGameModeData");
						if (GET_OBJECT_CLASS(_gmData) == "CivilWarCityData") then {
							pr _influence = CALLM0(_gmData, "getInfluence");
							pr _state = CALLM0(_gmData, "getState");
							pr _stateText = "";
							pr _stateColor = [];
							switch (_state) do {
								case CITY_STATE_ENEMY_CONTROL: { _stateColor = [248/255, 7/255, 32/255, 1]; _stateText = localize "STR_CMUI_ENY_CONTROL"; };			// Red
								case CITY_STATE_FRIENDLY_CONTROL: { _stateColor = [6/255, 124/255, 1, 1]; _stateText = localize "STR_CMUI_FRIENDLY_CONTROL"; };	// Blue
								default { _stateColor = [1,1,1,1]; _stateText = localize "STR_CMUI_NEUTRAL"; };							// Orange [244/255, 104/255, 0, 1.0]
							};
							_influence = round (_influence * 100);
							pr _rows = [
								[localize "STR_CMUI_STATUS", _stateText, _stateColor],
								[localize "STR_CMUI_INFLUENCE", _influence, 100, true]
							];
							_ctrl = CALLSM1("ClientMapUI", "createLocationMiniPanel", _rows);
							SETV(_x, "microPanel", [_ctrl]);
						};
					};

					CALLSM3("ClientMapUI", "updateMiniPanelPosition", _ctrl, _ctrlMap, GETV(_x, "pos"));
				};
			} forEach _allMapMarkers;
		} else {
			{
				pr _ctrl = GETV(_x, "microPanel") select 0;
				if (!isNull _ctrl) then {ctrlDelete _ctrl;};
			} forEach (_allMapMarkers + _allGarrisonMarkers);
		};
	ENDMETHOD;

	STATIC_METHOD(updateMiniPanelPosition)
		params [P_THISCLASS, P_CONTROL("_ctrl"), P_CONTROL("_ctrlMap"), P_POSITION("_pos")];

		// Update panel position
		pr _posScreen = _ctrlMap posWorldToScreen _pos;
		_posScreen params ["_xScreen", "_yScreen"];
		if (_yScreen < safeZoneY) then {_yScreen = -1;};
		(ctrlPosition _ctrl) params ["__x", "__y", "_w", "_h"];
		_ctrl ctrlSetPosition [_xScreen - 0.5*_w, _yScreen + 0.03, _w, _h];
		_ctrl ctrlCommit 0;
	ENDMETHOD;

	/*
	Creates a mini panel control
	rows - array of:

	"_name", "_amount", "_baseAmount", "_bipolar"
	_bipolar - optional, default false. If true, bar width is linear and can represent negative numbers:
	bar width = _amount / _baseAmount
	If false, bar width is logarithmic and can only represent positive numbers.

	or:
	"_name", "_valueStr", "_color"
	_valueStr - string to be placed on the right of name
	_color - array [r,g,b,a] - color of valuestr

	*/
	STATIC_METHOD(createLocationMiniPanel)
		params [P_THISCLASS, P_ARRAY("_rows")];

		private _disp = finddisplay 12;

		private _wGap = safeZoneW*0.003;
		private _hGap = safeZoneH/safeZoneW*_wGap;
		private _hRow = safeZoneH*0.015;
		private _wCol0 = safeZoneW*0.04;
		private _wCol1 = safeZoneW*0.02;
		private _wBarMax = safeZoneW*0.04;
		private _wBarNegative = safeZoneW*0.008;
		private _hBar = safeZoneH*0.008;
		private _wBackground = _wGap + _wCol0 + _wCol1 + _wBarMax; // + _wBarNegative;
		private _hBackground = 2*_hGap + (count _rows)*_hRow;

		private _ctrlGroup = _disp ctrlCreate ["RscControlsGroupNoScrollbars", -1];
		_ctrlGroup ctrlSetPosition [0.7, 0.7, _wBackground+0.005, _hBackground+0.005];
		_ctrlGroup ctrlCommit 0;

		private _ctrlBackground = _disp ctrlCreate ["MUI_BG_BLACKTRANSPARENT", -1, _ctrlGroup];
		_ctrlBackground ctrlSetPosition [0, 0, _wBackground, _hBackground];
		_ctrlBackground ctrlSetBackgroundColor [0, 0, 0, 0.8];
		_ctrlBackground ctrlCommit 0;

		{ //  forEach _rows;
			_x params ["_name", "_amount"]; // _bipolar - when true, that value can be positive and negative
			private _i = _forEachIndex;
			
			
			private _ctrlName = _disp ctrlCreate ["MUI_BG_TRANSPARENT_LEFT", -1, _ctrlGroup];
			_ctrlName ctrlSetPosition [0, _hGap + _i*_hRow, _wCol0, _hRow];
			_ctrlName ctrlCommit 0;
			_ctrlName ctrlSetText _name;
			
			private _ctrlAmount = _disp ctrlCreate ["MUI_BG_TRANSPARENT_LEFT", -1, _ctrlGroup];
			
			
			
			if (_amount isEqualType 0) then {
				_x params ["_name", "_amount", "_baseAmount", ["_bipolar", false]];

				_ctrlAmount ctrlSetPosition [ _wCol0, _hGap + _i*_hRow, _wCol1, _hRow];
				_ctrlAmount ctrlSetText (str _amount);
				_ctrlAmount ctrlCommit 0;

				if (!_bipolar) then {
					if (_amount > 0) then {
						private _barSizeRel = 0.5*(ln (_amount/_baseAmount))+0.25; // https://www.desmos.com/calculator/7uastykkza
						_barSizeRel = (_barSizeRel min 1.0) max 0.08; // Limited in range 0..1
						private _barWidth = _barSizeRel*_wBarMax;
						private _ctrlBar = _disp ctrlCreate ["RscText", -1, _ctrlGroup];
						_ctrlBar ctrlSetPosition [_wCol0 +_wCol1, _hGap + _i*_hRow + 0.5*(_hRow - _hBar), _barWidth, _hBar];

						// Color bar
						_ctrlBar ctrlSetBackgroundColor [244/255, 104/255, 0, 1.0];
						_ctrlBar ctrlCommit 0;
					} else {
						private _color = [0.5, 0.5, 0.5, 1.0];

						// Color texts
						//_ctrlName ctrlSetTextColor _color;
						_ctrlAmount ctrlSetTextColor _color;
						//_ctrlName ctrlCommit 0;
						_ctrlAmount ctrlCommit 0;
					};
				} else {
					if (_amount != 0) then {
						private _barSizeRel = 0.5 * abs (_amount / _baseAmount);
						private _barWidth = _barSizeRel*_wBarMax;
						private _ctrlBar = _disp ctrlCreate ["RscText", -1, _ctrlGroup];

						if (_amount > 0) then {
							_ctrlBar ctrlSetPosition [_wCol0 +_wCol1 + 0.5*_wBarMax, _hGap + _i*_hRow + 0.5*(_hRow - _hBar), _barWidth, _hBar];
							_ctrlBar ctrlSetBackgroundColor [6/255, 124/255, 1, 1];
						} else {
							_ctrlBar ctrlSetPosition [_wCol0 +_wCol1 + 0.5*_wBarMax - _barWidth, _hGap + _i*_hRow + 0.5*(_hRow - _hBar), _barWidth, _hBar];
							_ctrlBar ctrlSetBackgroundColor [1, 0, 0, 1];
						};
						_ctrlBar ctrlCommit 0;

						// Create a white mark at zero position
						private _ctrlMark = _disp ctrlCreate ["RscText", -1, _ctrlGroup];
						_ctrlMark ctrlSetBackgroundColor [1,1,1,1];
						pr _ctrlMarkWidth = safeZoneW * 0.0015;
						_ctrlMark ctrlSetPosition [_wCol0 +_wCol1 + 0.5*_wBarMax - 0.5*_ctrlMarkWidth, _hGap + _i*_hRow + 0.5*(_hRow - _hBar), _ctrlMarkWidth, _hBar];
						_ctrlmark ctrlCommit 0;
					};
				};
			};

			if (_amount isEqualType "") then {
				_x params ["_name", "_valueStr", "_color"];

				_ctrlAmount ctrlSetText _valueStr;
				_ctrlAmount ctrlSetTextColor _color;
				_ctrlAmount ctrlSetPosition [ _wCol0, _hGap + _i*_hRow, _wCol1 + _wBarMax, _hRow];
				_ctrlAmount ctrlCommit 0;
			};
			
		} forEach _rows;

		_ctrlGroup;
	ENDMETHOD;
	

	/* 
		Method: addDummyIntel
		Description: Adds some random intel to debug the intel panel
					 You can use this in the debug console:
					 Currently creates an error, but still works to visualize 
					 intel in the listbox and on the map.

		Example: call ClientMapUI_fnc_addDummyIntel;
	*/
	public STATIC_METHOD(addDummyIntel)
		params [P_THISCLASS];

		// Fill dummy data for testing
		_allIntels = [];
		pr _i = 0;
		while {_i < 10} do {
			pr _intel = NEW("IntelCommanderActionAttack", []);
			SETV(_intel, "posSrc", [random 10000 ARG random 20000 ARG 3]);
			SETV(_intel, "posTgt", [random 10000 ARG random 20000 ARG 3]);
			pr _dateNow = date;
			pr _minuteNow = _dateNow#4;
			pr _year = _dateNow#0;
			pr _dateDeparture = +_dateNow;
			_dateDeparture set [4, _minuteNow - (random 120) + 60];
			// Fix the minute overflow by converting twice
			//_dateDeparture = numberToDate [_year, dateToNumber _dateDeparture];
			SETV(_intel, "dateDeparture", _dateDeparture);
			pr _state = selectRandom [INTEL_ACTION_STATE_ACTIVE, INTEL_ACTION_STATE_INACTIVE, INTEL_ACTION_STATE_END];
			SETV(_intel, "state", _state);
			_allIntels pushBack _intel;
			_i = _i + 1;
		};

		{
			CALLM1(gIntelDatabaseClient, "addIntel", _x);
		} forEach _allIntels;
	ENDMETHOD;

ENDCLASS;

if(isNil "gPlayerRestoreData") then {
	gPlayerRestoreData = [];
};