#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "buildUI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Resources\BuildUI\BuildUI_Macros.h"
#include "..\..\GlobalAssert.hpp"

/*
Class: BuildUI
Initializes the build menu UI, handles opening and closing, and handles the building itself

sound place: 
playSound ["3DEN_notificationDefault", false];

Author: Marvis
*/

#define pr private

g_BuildUI = nil;

CLASS("BuildUI", "")

	VARIABLE("activeBuildMenus");
	VARIABLE("EHKeyDown");

	VARIABLE("currentCatID");				// currently selected category index
	VARIABLE("currentItemID");				// currently selected item index
	VARIABLE("UICatTexts");					// array of strings for category names
	VARIABLE("UIItemTexts");				// array of strings for item names in current category
	VARIABLE("TimeFadeIn");					// fade in time for category change UI effect
	VARIABLE("ItemCatOpen");				// true if item list should be shown

	// object variables
	VARIABLE("activeObject");				// Object currently highlighted
	VARIABLE("selectedObjects");
	VARIABLE("moveActionId");


	METHOD("new") {
		params ["_thisObject"];
		OOP_INFO_1("'new' method called. ====================================");

		if(!(isNil("g_BuildUI"))) exitWith {
			OOP_ERROR_0("BuildUI already initialized! Make sure to delete it before trying to initialize it again!");
		};

		g_rscLayerBuildUI = ["rscLayerBuildUI"] call BIS_fnc_rscLayer;	// register build UI layer

		g_BuildUI = _thisObject;
		T_SETV("currentCatID", 0);  			// index in g_buildUIObjects array of objects
		T_SETV("currentItemID", 0);  			// index in g_buildUIObjects category subarray of objects
		T_SETV("TimeFadeIn", 0);
		T_SETV("UICatTexts", []);

		pr _args = ["", "", "", "", ""];
		T_SETV("UIItemTexts", _args);

		T_SETV("ItemCatOpen", false);			// true if item list submenu is open
		T_SETV("activeBuildMenus", []);
		T_SETV("EHKeyDown", nil);
		T_SETV("activeObject", []);
		T_SETV("selectedObjects", []);
		T_SETV("moveActionId", -1);
		T_CALLM("makeCatTexts", [0]); 			// initialize UI category strings

	} ENDMETHOD;

	METHOD("delete") {
		params ["_thisObject"];

		OOP_INFO_1("Player %1 build UI destroyed.", name player);

		g_BuildUI = nil;
	} ENDMETHOD;

	METHOD("addOpenBuildMenuAction") {
		params ["_thisObject", "_object"];

		OOP_INFO_1("Adding Open Build Menu action to %1.", _object);

		pr _id = _object addaction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayEGSpectator\Fps.paa' />  %1", "Open Build Menu"], {  
			params ["_target", "_caller", "_actionId", "_arguments"];
			_arguments params ["_thisObject"];
			T_CALLM0("openUI");
		}, [_thisObject]];

		T_GETV("activeBuildMenus") pushBack [_object, _id];
	} ENDMETHOD;

	METHOD("removeAllActions") {
		params ["_thisObject"];

		OOP_INFO_0("Removing all active Open Build Menu actions.");

		{
			_x params ["_object", "_id"];
			_object removeAction _id;
		} forEach T_GETV("activeBuildMenus");
	} ENDMETHOD;

	METHOD("openUI") {
		params ["_thisObject"];
		OOP_INFO_0("'openUI' method called.");

		// update UI text and categories
		["BuildUIUpdate", "onEachFrame", {

			pr _UICatTexts = GETV(g_BuildUI, "UICatTexts");
			pr _UIItemTexts = GETV(g_BuildUI, "UIItemTexts");
			pr _TimeFadeIn = GETV(g_BuildUI, "TimeFadeIn");
			pr _ItemCatOpen = GETV(g_BuildUI, "ItemCatOpen");

			// Why not use a macro for these long-ass texts?
			// Arma doesn't want that.

			if (displayNull != (uinamespace getVariable "buildUI_display")) then {

				if (_ItemCatOpen) then { 
					((uinamespace getVariable "buildUI_display") displayCtrl IDC_ITEXTBG) ctrlSetBackgroundColor [0,0,0,0.6];
					{
						((uinamespace getVariable "buildUI_display") displayCtrl IDC_ITEXTL2) ctrlSetText format ["%1", (_UIItemTexts select 0)];
						((uinamespace getVariable "buildUI_display") displayCtrl IDC_ITEXTL1) ctrlSetText format ["%1", (_UIItemTexts select 1)];
						((uinamespace getVariable "buildUI_display") displayCtrl IDC_ITEXTC) ctrlSetText format ["%1", (_UIItemTexts select 2)];
						((uinamespace getVariable "buildUI_display") displayCtrl IDC_ITEXTR1) ctrlSetText format ["%1", (_UIItemTexts select 3)];
						((uinamespace getVariable "buildUI_display") displayCtrl IDC_ITEXTR2) ctrlSetText format ["%1", (_UIItemTexts select 4)];

						((uinamespace getVariable "buildUI_display") displayCtrl _x) ctrlShow true;

						{
						((uinamespace getVariable "buildUI_display") displayCtrl _x) ctrlCommit 0;
						} forEach [IDC_ITEXTR2, IDC_ITEXTR1, IDC_ITEXTC, IDC_ITEXTL1, IDC_ITEXTL2, IDC_ITEXTBG];

					} forEach [IDC_ITEXTR2, IDC_ITEXTR1, IDC_ITEXTC, IDC_ITEXTL1, IDC_ITEXTL2, IDC_ITEXTBG];
				} else { 
					((uinamespace getVariable "buildUI_display") displayCtrl IDC_ITEXTBG) ctrlSetBackgroundColor [0,0,0,0];
					{
						((uinamespace getVariable "buildUI_display") displayCtrl _x) ctrlShow false;
						((uinamespace getVariable "buildUI_display") displayCtrl _x) ctrlCommit 0;
					} forEach [IDC_ITEXTR2, IDC_ITEXTR1, IDC_ITEXTC, IDC_ITEXTL1, IDC_ITEXTL2, IDC_ITEXTBG];
				};

				((uinamespace getVariable "buildUI_display") displayCtrl IDC_TEXTL2) ctrlSetText format ["%1", (_UICatTexts select 0)];
				((uinamespace getVariable "buildUI_display") displayCtrl IDC_TEXTL1) ctrlSetText format ["%1", (_UICatTexts select 1)];
				((uinamespace getVariable "buildUI_display") displayCtrl IDC_TEXTC) ctrlSetText format ["%1", (_UICatTexts select 2)];
				
				// button highlight effect
				if (_TimeFadeIn > time) then { 
					((uinamespace getVariable "buildUI_display") displayCtrl IDC_TEXTC) ctrlSetBackgroundColor [1, 1, 1, (_TimeFadeIn - time)];
				} else { ((uinamespace getVariable "buildUI_display") displayCtrl IDC_TEXTC) ctrlSetBackgroundColor [1, 1, 1, 0]; };

				((uinamespace getVariable "buildUI_display") displayCtrl IDC_TEXTR1) ctrlSetText format ["%1", (_UICatTexts select 3)];
				((uinamespace getVariable "buildUI_display") displayCtrl IDC_TEXTR2) ctrlSetText format ["%1", (_UICatTexts select 4)];

				{
					((uinamespace getVariable "buildUI_display") displayCtrl _x) ctrlCommit 0;
				} forEach [IDC_TEXTL2, IDC_TEXTL1, IDC_TEXTC, IDC_TEXTR1, IDC_TEXTR2];
	
		  	};
		}] call BIS_fnc_addStackedEventHandler;

		T_CALLM0("enterMoveMode");
		g_rscLayerBuildUI cutRsc ["BuildUI", "PLAIN", -1, false]; // blend in UI

		pr _EHKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {

			switch ((keyName (_this select 1))) do {
				default { false; };

				case """Tab""": { 
					// TODO: add pick up/drop current object
					true; // disables default control 
				};

				case """Q""": { 
					// TODO: rotate object counter-clockwise
					true; // disables default control 
				};

				case """E""": { 
					// TODO: rotate object clockwise
					true; // disables default control 
				};

				case """UP""": { 
					playSound ["clicksoft", false];
					CALLM0(g_BuildUI, "openItems"); true; 
				};

				case """DOWN""": { 
					playSound ["clicksoft", false];
					CALLM0(g_BuildUI, "closeItems"); true; 
				};

				case """LEFT""": { 
					playSound ["clicksoft", false];
					SETV(g_BuildUI, "TimeFadeIn", (time+(0.4)));
					CALLM(g_BuildUI, "navLR", [-1]); 
					true; 
				};

				case """RIGHT""": { 
					playSound ["clicksoft", false];
					SETV(g_BuildUI, "TimeFadeIn", (time+(0.4)));
					CALLM(g_BuildUI, "navLR", [1]); 
					true; 
				};

				// close build menu
				case """Backspace""": { CALLM0(g_BuildUI, "closeUI"); true; };
			};
		}];

		T_SETV("EHKeyDown", _EHKeyDown);

		// TODO: Add player on death event to hide UI and drop held items etc.
		// Also for when they leave camp area.
	} ENDMETHOD;

	METHOD("closeUI") {
		params ["_thisObject"];

		OOP_INFO_0("'closeUI' method called. ====================================");

		T_CALLM0("exitMoveMode");
		g_rscLayerBuildUI cutRsc ["Default", "PLAIN", -1, false]; // hide UI

		(findDisplay 46) displayRemoveAllEventHandlers "keydown";
		T_SETV("EHKeyDown", nil);

		// close item category and reset selected item ID to avoid problems
		T_SETV("currentItemID", 0);
		T_SETV("ItemCatOpen", false);

		["BuildUIUpdate", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

		OOP_INFO_0("Removed display event handler!");
	} ENDMETHOD;

	// opens item list UI element
	METHOD("openItems") {
		params ["_thisObject"];
		OOP_INFO_0("'openItems' method called");
		T_SETV("ItemCatOpen", true);
		T_SETV("currentItemID", 0);

		T_CALLM("makeItemTexts", [0]); // create item list display texts
	} ENDMETHOD;

	// closes item list UI element
	METHOD("closeItems") {
		params ["_thisObject"];
		OOP_INFO_0("'closeItems' method called");
		T_SETV("ItemCatOpen", false);
		T_SETV("currentItemID", 0);
	} ENDMETHOD;

	/* Description: Navigate left or right in either category or item list on the UI

		Parameter: Number
		(+)1: array index plus 1 (right)
		-1: array index minus 1 (left)

		current category index + _num = new index
	*/
	METHOD("navLR") {
		params [["_thisObject", "", [""]], "_num"];
		OOP_INFO_1("'navLR' method called: %1", _num);
		pr _itemCatOpen = GETV(g_BuildUI, "ItemCatOpen");
		pr _currentCatID = T_GETV("currentCatID"); // currently selected category

		if (_itemCatOpen) then { 
		pr _currentItemID = T_GETV("currentItemID");
		pr _newItemID = _currentItemID + (_num);

		// make sure item ID is index of item subarray of g_buildUIObjects template array
		if (_newItemID < 0) exitWith { OOP_INFO_1("Invalid itemID: %1", _newItemID); };
		pr _itemCatIndexSize = (count (g_buildUIObjects select _currentCatID select 0)) - 1;
		if (_newItemID > _itemCatIndexSize) exitWith { OOP_INFO_1("Invalid itemID: %1", _newItemID); };

		T_SETV("currentItemID", _newItemID); 
		T_CALLM("makeItemTexts", [_newItemID]);
		} else {
		pr _newCatID = _currentCatID + (_num);

		// make sure category ID is index of g_buildUIObjects template array
		if ((_newCatID < 0) OR _newCatID > ((count g_buildUIObjects) - 1)) exitWith { OOP_INFO_1("Invalid newCatID: %1", _newCatID); };

		T_SETV("currentCatID", _newCatID); 
		T_CALLM("makeCatTexts", [_newCatID]);
		};

	} ENDMETHOD;

	// generates an array of display strings for each category on the UI
	// format: [Left text 2, Left text 1, Center text, Right text 1, Right text 2]
	METHOD("makeCatTexts") {
		params [["_thisObject", "", [""]], "_currentCatID"];
		OOP_INFO_0("'makeCatTexts' method called");

		pr _UIarray = [_currentCatID-2, _currentCatID-1, _currentCatID, _currentCatID+1, _currentCatID+2]; 
		pr _return = [];

		{ 
			if ((_x < 0) OR (_x > ((count g_buildUIObjects) - 1))) then { 
				_return pushBack ""; 
			} else {
				_return pushBack (toUpper ((g_buildUIObjects select _x) select 1));
			};
		} forEach _UIarray; 

		SETV(_thisObject, "UICatTexts", _return);

	} ENDMETHOD;

	// generates an array of display strings for the item list on the UI
	// format: [Left text 2, Left text 1, Center text, Right text 1, Right text 2]
	METHOD("makeItemTexts") {
		params [["_thisObject", "", [""]], "_ItemID"];
		OOP_INFO_0("'makeItemTexts' method called");

		pr _currentCatID = T_GETV("currentCatID");
		pr _itemCat = (g_buildUIObjects select _currentCatID) select 0;
		pr _itemCatIndexSize = (count _itemCat) -1;
		pr _UIarray = [_ItemID-2, _ItemID-1, _ItemID, _ItemID+1, _ItemID+2]; 
		pr _return = [];

		{ 
			if ((_x < 0) OR (_x > _itemCatIndexSize)) then { 
				_return pushBack ""; 
			} else {
				_return pushBack (toUpper ((_itemCat select _x) select 1));
			};
		} forEach _UIarray; 

		T_SETV("UIItemTexts", _return);

	} ENDMETHOD;

	/* 
		Returns the classname of the currently selected menu item, if the menu is open.
		Returns "" if the menu is closed.

		Example:
		private classname = T_CALLM0("currentClassname");

	*/
	METHOD("currentClassname") {
		params [["_thisObject", "", [""]]];

		pr _ItemCatOpen = T_GETV("ItemCatOpen");
		pr _return = "";

		if (_itemCatOpen) then { 
		pr _currentCatID = T_GETV("currentCatID");
		pr _currentItemID = T_GETV("currentItemID");
		pr _itemCat = (g_buildUIObjects select _currentCatID) select 0;
		_return = (_itemCat select _currentItemID) select 0;
		};
		
		_return
	} ENDMETHOD;

	METHOD("createNewObject") {
		params ["_thisObject", "_type", ["_offs", [0, 4, 0]]];
		OOP_INFO_0("'createNewObject' method called");
		
		T_CALLM0("exitMoveMode");
		pr _newObj = createVehicle [_type, player modelToWorld _offs, [], 0, "CAN_COLLIDE"];
		T_SETV("selectedObjects", [[_newObj, getPos _newObj]]);
		T_CALLM0("moveSelectedObjects");
	} ENDMETHOD;

	METHOD("enterMoveMode") {
		params ["_thisObject"];
		OOP_INFO_0("'enterMoveMode' method called");

		if(T_GETV("moveActionId") != -1) exitWith {
			OOP_ERROR_0("enterMoveMode called while already in move mode! Must call exitMoveMode before entering it again!");
		};

		pr _moveActionId = player addAction ["Move Selected Object", {
			params ["_target", "_caller", "_actionId", "_arguments"];
			_arguments params ["_thisObject"];

			T_CALLM0("moveSelectedObjects");
		}, [_thisObject]];

		T_SETV("moveActionId", _moveActionId);

		["BuildUIHighlightObject", "onEachFrame", {
			params ["_thisObject"];

			pr _activeObject = T_GETV("activeObject");
			//pr _selectedObjects = T_GETV("selectedObjects");
			
			if(count _activeObject == 0 or {cursorObject != _activeObject select 0 }) then {
				if(count _activeObject > 0) then {
					_activeObject params ["_obj", "_pos"];
					_obj setPosWorld _pos;
					_obj enableSimulation true;
					_activeObject = [];
					T_SETV("activeObject", _activeObject);
				};
				
				//if(cursorObject getVariable ["P0_allowMove", false]) then {
				if(true) then {
					private _pos = getPosWorld cursorObject;
					_activeObject = [cursorObject, _pos];
					T_SETV("activeObject", _activeObject);
					cursorObject enableSimulation false;
					cursorObject setPosWorld [_pos select 0, _pos select 1, (_pos select 2) + 0.02 + 0.02 * cos(time * 720)];
				};
			} else {
				if(count _activeObject != 0) then {
					_activeObject params ["_obj", "_pos"];
					_obj setPosWorld [_pos select 0, _pos select 1, (_pos select 2) + 0.02 + 0.02 * cos(time * 720)];
				};
			};

		}, [_thisObject]] call BIS_fnc_addStackedEventHandler;
	} ENDMETHOD;

	METHOD("exitMoveMode") {
		params ["_thisObject"];
		OOP_INFO_0("'exitMoveMode' method called");

		pr _activeObject = T_GETV("activeObject");
		if(count _activeObject > 0) then {
			_activeObject params ["_obj", "_pos"];
			_obj setPosWorld _pos;
			_obj enableSimulation true;
			T_SETV("activeObject", []);
		};

		player removeAction T_GETV("moveActionId");
		T_SETV("moveActionId", -1);

		["BuildUIHighlightObject", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
	} ENDMETHOD;

	METHOD("addToSelection") {
		params ["_thisObject"];
		OOP_INFO_0("'addToSelection' method called");

		pr _activeObject = T_GETV("activeObject");
		if(count _activeObject == 0) exitWith {
			OOP_ERROR_0("No item is active!");
		};
		pr _selectedObjects = T_GETV("selectedObjects");		
		if((_activeObject select 0) in (_selectedObjects apply { _x select 0 })) exitWith {false};
		_selectedObjects pushBack _activeObject;
		true
	} ENDMETHOD;

	METHOD("removeFromSelection") {
		params ["_thisObject"];
		OOP_INFO_0("'removeFromSelection' method called");

		pr _activeObject = T_GETV("activeObject");
		pr _selectedObjects = T_GETV("selectedObjects");		
		if(count _activeObject == 0) exitWith {
			OOP_ERROR_0("No item is active!");
		};

		if(!((_activeObject select 0) in (_selectedObjects apply { _x select 0 }))) exitWith {false};
		_selectedObjects = _selectedObjects - [_activeObject];

		T_SETV("selectedObjects", _selectedObjects);
		true
	} ENDMETHOD;

	METHOD("moveSelectedObjects") {
		params ["_thisObject"];
		OOP_INFO_0("'moveSelectedObjects' method called");
		
		// Add currently active object if it isn't already selected
		T_CALLM0("addToSelection");
		// Exit move mode so it doesn't interfere
		T_CALLM0("exitMoveMode");
		
		// Grab the selected objects
		pr _selectedObjects = T_GETV("selectedObjects");
		T_SETV("selectedObjects", []);			

		{
			_x params ["_object", "_pos"];
			_object setPosWorld _pos;
			_object enableSimulation true;

			private _relativePos = player worldToModel (_object modelToWorld [0,0,0.1]);
			private _starting_h = getCameraViewDirection player select 2;
			
			private _dir = getDir _object - getDir player; //vectorDir _object;
			//private _up = vectorUp _object;
			_object enableSimulationGlobal false;
			
			_object setVariable ["build_ui_beingMoved", true];
			_object setVariable ["build_ui_relativePos", _relativePos];
			_object setVariable ["build_ui_starting_h", _starting_h];

			_object attachTo [player, _relativePos];
			_object setDir _dir;
			//_object setVectorDirAndUp [_dir, _up];
		} forEach _selectedObjects;
		
		["SetHQObjectHeight", "onEachFrame", {
			params ["_selectedObjects"];
			{
				_x params ["_object", "_pos"];
				private _relativePos = _object getVariable "build_ui_relativePos";
				private _starting_h = _object getVariable "build_ui_starting_h";

				private _relative_h = (getCameraViewDirection player select 2) - _starting_h;
				//_object setPos (_relativePos vectorAdd [0, 0, _relative_h * vectorMagnitude _relativePos]);
				// detach _object;
				_object attachTo [player, _relativePos vectorAdd [0, 0, _relative_h * vectorMagnitude _relativePos]];
				// _object setDir _dir;
			} forEach _selectedObjects;
		}, [_selectedObjects]] call BIS_fnc_addStackedEventHandler;

		player addAction ["Drop Here", {
			params ["_target", "_caller", "_actionId", "_arguments"];
			["SetHQObjectHeight", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
			_arguments params ["_thisObject", "_selectedObjects"];

			{
				_x params ["_object", "_oldPos"];
				detach _object;
				private _pos = getPos _object;
				_object setPos [_pos select 0, _pos select 1, 0];
				_object enableSimulationGlobal true;
			} forEach _selectedObjects;

			player removeAction (_this select 2);
			
			T_CALLM0("enterMoveMode");
		}, [_thisObject, _selectedObjects], 0, false, true, "", ""];

	} ENDMETHOD;
ENDCLASS;

build_UI_addOpenBuildMenuAction = {
	ASSERT_GLOBAL_OBJECT(g_BuildUI);

	CALLM1(g_BuildUI, "addOpenBuildMenuAction", _this);
};