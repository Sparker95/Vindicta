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
	VARIABLE("selectedObjects");			// Objects that will be part of move actions
	VARIABLE("movingObjects");				// Objects currently being moved (includes selected and active when move starts)
	VARIABLE("isMovingObjects");			// Are objects being moved at the moment?

	// carousel
	VARIABLE("previousItemID");				// Previous item selected so we can animate things 
	VARIABLE("animStartTime");				// Animation start time, used to animated carousel
	VARIABLE("animCompleteTime");			// Time animation will complete (could be in the past, meaning the animation is complete)
	VARIABLE("carouselObjects");			// Objects in the carousel (vehicles)

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
		T_SETV("movingObjects", []);
		T_SETV("isMovingObjects", false);

		T_SETV("previousItemID", 0);
		T_SETV("animStartTime", 0);
		T_SETV("animCompleteTime", 0);
		T_SETV("carouselObjects", []);

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

	build_ui_UIUpdateOnEachFrame = {
		pr _UICatTexts = GETV(g_BuildUI, "UICatTexts");
		pr _UIItemTexts = GETV(g_BuildUI, "UIItemTexts");
		pr _TimeFadeIn = GETV(g_BuildUI, "TimeFadeIn");
		pr _ItemCatOpen = GETV(g_BuildUI, "ItemCatOpen");

		pr _display = uinamespace getVariable "buildUI_display";

		if (displayNull != _display) then {
			// item menu
			if (_ItemCatOpen) then { 
				(_display displayCtrl IDC_ITEXTBG) ctrlSetBackgroundColor [0,0,0,0.6];
				(_display displayCtrl IDC_ITEXTL2) ctrlSetText format ["%1", (_UIItemTexts select 0)];
				(_display displayCtrl IDC_ITEXTL1) ctrlSetText format ["%1", (_UIItemTexts select 1)];
				(_display displayCtrl IDC_ITEXTC) ctrlSetText format ["%1", (_UIItemTexts select 2)];
				(_display displayCtrl IDC_ITEXTR1) ctrlSetText format ["%1", (_UIItemTexts select 3)];
				(_display displayCtrl IDC_ITEXTR2) ctrlSetText format ["%1", (_UIItemTexts select 4)];

				{
					(_display displayCtrl _x) ctrlShow true;
					(_display displayCtrl _x) ctrlCommit 0;
				} forEach [IDC_ITEXTR2, IDC_ITEXTR1, IDC_ITEXTC, IDC_ITEXTL1, IDC_ITEXTL2, IDC_ITEXTBG];

			} else { 
				(_display displayCtrl IDC_ITEXTBG) ctrlSetBackgroundColor [0,0,0,0];
				{
					(_display displayCtrl _x) ctrlShow false;
					(_display displayCtrl _x) ctrlCommit 0;
				} forEach [IDC_ITEXTR2, IDC_ITEXTR1, IDC_ITEXTC, IDC_ITEXTL1, IDC_ITEXTL2, IDC_ITEXTBG];
			};

			// cat menu
			(_display displayCtrl IDC_TEXTL2) ctrlSetText format ["%1", (_UICatTexts select 0)];
			(_display displayCtrl IDC_TEXTL1) ctrlSetText format ["%1", (_UICatTexts select 1)];
			(_display displayCtrl IDC_TEXTC) ctrlSetText format ["%1", (_UICatTexts select 2)];

			// button highlight effect
			if (_TimeFadeIn > time) then { 
				(_display displayCtrl IDC_TEXTC) ctrlSetBackgroundColor [1, 1, 1, (_TimeFadeIn - time)];
			} else { (_display displayCtrl IDC_TEXTC) ctrlSetBackgroundColor [1, 1, 1, 0]; };

			(_display displayCtrl IDC_TEXTR1) ctrlSetText format ["%1", (_UICatTexts select 3)];
			(_display displayCtrl IDC_TEXTR2) ctrlSetText format ["%1", (_UICatTexts select 4)];

			{
				(_display displayCtrl _x) ctrlCommit 0;
			} forEach [IDC_TEXTL2, IDC_TEXTL1, IDC_TEXTC, IDC_TEXTR1, IDC_TEXTR2];

			CALLM0(g_BuildUI, "updateCarouselOffsets");
		};
	};

	METHOD("openUI") {
		params ["_thisObject"];
		OOP_INFO_0("'openUI' method called.");

		// update UI text and categories, this is a separate function due to https://feedback.bistudio.com/T123355
		["BuildUIUpdate", "onEachFrame", { call build_ui_UIUpdateOnEachFrame }] call BIS_fnc_addStackedEventHandler;

		T_CALLM0("enterMoveMode");
		g_rscLayerBuildUI cutRsc ["BuildUI", "PLAIN", -1, false]; // blend in UI

		pr _EHKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			if(isNil "g_BuildUI") exitWith {
				(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
			};
			CALLM1(g_BuildUI, "onKeyHandler", _this select 1);
		}];

		T_SETV("EHKeyDown", _EHKeyDown);

		// TODO: Add player on death event to hide UI and drop held items etc.
		// Also for when they leave camp area.
	} ENDMETHOD;

	METHOD("onKeyHandler") {
		params [P_THISOBJECT, "_dikCode"];

		switch (keyName _dikCode) do {
			default { false; };

			case """Tab""": { 
				playSound ["clicksoft", false];
				T_CALLM0("handleActionKey");
				true; // disables default control 
			};

			case """Q""": { 
				playSound ["clicksoft", false];
				// TODO: rotate object counter-clockwise
				true; // disables default control 
			};

			case """E""": { 
				playSound ["clicksoft", false];
				// TODO: rotate object clockwise
				true; // disables default control 
			};

			case """UP""": { 
				if !(T_GETV("isMovingObjects")) then {
					playSound ["clicksoft", false];
					T_CALLM0("openItems"); true; 
				};
			};

			case """DOWN""": { 
				playSound ["clicksoft", false];
				T_CALLM0("closeItems"); true; 
			};

			case """LEFT""": { 
				playSound ["clicksoft", false];
				T_CALLM1("navLR", -1); 
				true; 
			};

			case """RIGHT""": { 
				playSound ["clicksoft", false];
				T_CALLM1("navLR", 1);
				true; 
			};

			// close build menu
			case """Backspace""": {
				playSound ["clicksoft", false];
				if(T_GETV("isMovingObjects")) then {
					T_CALLM0("cancelMovingObjects");
				} else {
					T_CALLM0("closeUI"); 
				};
				true; 
			};
		};
	} ENDMETHOD;

	METHOD("closeUI") {
		params ["_thisObject"];

		OOP_INFO_0("'closeUI' method called. ====================================");

		T_CALLM0("clearCarousel");
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

	METHOD("handleActionKey") {
		P_DEFAULT_PARAMS;
		OOP_INFO_0("'handleActionKey' method called");

		T_PRVAR(ItemCatOpen);
		OOP_INFO_1("'handleActionKey' %1", _ItemCatOpen);
		if (_ItemCatOpen) then {
			pr _currentClassName = T_CALLM0("currentClassname");
			OOP_INFO_1("'handleActionKey' creating new %1", _currentClassName);
			T_CALLM0("closeItems");
			T_CALLM1("createNewObject", _currentClassName);
		} else {
			if (T_GETV("isMovingObjects")) then {
				T_CALLM0("dropHere");
			} else {
				T_CALLM0("moveSelectedObjects");
			};
		};
	} ENDMETHOD;

	// opens item list UI element
	METHOD("openItems") {
		params ["_thisObject"];
		OOP_INFO_0("'openItems' method called");
		T_SETV("ItemCatOpen", true);
		T_SETV("currentItemID", 0);

		T_CALLM("makeItemTexts", [0]); // create item list display texts

		T_CALLM0("createCarousel");
		T_CALLM0("exitMoveMode");
	} ENDMETHOD;

	// closes item list UI element
	METHOD("closeItems") {
		params ["_thisObject"];
		OOP_INFO_0("'closeItems' method called");
		T_SETV("ItemCatOpen", false);
		T_SETV("currentItemID", 0);
		T_CALLM0("clearCarousel");
		T_CALLM0("enterMoveMode");
	} ENDMETHOD;

	/* Description: Navigate left or right in either category or item list on the UI

		Parameter: Number
		(+)1: array index plus 1 (right)
		-1: array index minus 1 (left)

		current category index + _num = new index
	*/
	METHOD("navLR") {
		params [P_THISOBJECT, "_num"];

		OOP_INFO_1("'navLR' method called: %1", _num);
		pr _itemCatOpen = GETV(g_BuildUI, "ItemCatOpen");
		pr _currentCatID = T_GETV("currentCatID"); // currently selected category

		if (_itemCatOpen) then { 
			pr _currentItemID = T_GETV("currentItemID");
			T_SETV("previousItemID", _currentItemID); 
			T_SETV("animStartTime", time); 
			T_SETV("animCompleteTime", time + 0.2); 
			// How many items in the currently selected category
			pr _itemIndexSize = count (g_buildUIObjects select _currentCatID select 0);

			// Update the index and modulus to make it loop back around in both directions. https://stackoverflow.com/a/24093024
			pr _newItemID = (_currentItemID + _num + _itemIndexSize) mod _itemIndexSize;

			T_SETV("currentItemID", _newItemID); 
			T_CALLM("makeItemTexts", [_newItemID]);
		} else {
			T_SETV("TimeFadeIn", (time+(0.4)));
			pr _newCatID = _currentCatID + (_num);
			// How many categories
			pr _categoryIndexSize = count g_buildUIObjects;
			// Update the index and modulus to make it loop back around in both directions. https://stackoverflow.com/a/24093024
			pr _newCatID = (_currentCatID + _num + _categoryIndexSize) mod _categoryIndexSize;

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
		P_DEFAULT_PARAMS;

		T_PRVAR(ItemCatOpen);
		pr _return = "";
		OOP_INFO_1("'currentClassname' %1", _ItemCatOpen);
		if (_ItemCatOpen) then {
			T_PRVAR(currentCatID);
			T_PRVAR(currentItemID);
			pr _itemCat = (g_buildUIObjects select _currentCatID) select 0;
			_return = (_itemCat select _currentItemID) select 0;
			OOP_INFO_4("'currentClassname' %1 %2 %3 %4", _currentCatID, _currentItemID, _itemCat, _return);
		};

		_return
	} ENDMETHOD;

	METHOD("clearCarousel") {
		params ["_thisObject"];
		OOP_INFO_0("'clearCarousel' method called");

		T_PRVAR(carouselObjects);
		{
			detach _x;
			deleteVehicle _x;
		} forEach _carouselObjects;

		T_SETV("carouselObjects", []);
	} ENDMETHOD;

	METHOD("getCarouselOffsets") {
		params ["_thisObject"];

		T_PRVAR(currentCatID);
		T_PRVAR(currentItemID);

		// How many items in the currently selected category
		pr _itemCat = (g_buildUIObjects select _currentCatID) select 0;
		// _return = (_itemCat select _currentItemID) select 0;
		pr _itemIndexSize = count _itemCat - 1;

		pr _offsets = [];

		T_PRVAR(animStartTime);
		T_PRVAR(animCompleteTime);
		T_PRVAR(previousItemID);

		pr _xtotal = 0;
		pr _prevx = 0;
		pr _currx = 0;

		for "_i" from 0 to _itemIndexSize do {
			pr _item = (_itemCat select _i) select 0;
			pr _size = sizeOf _item;
			_xtotal = _xtotal + _size + 1;
			pr _xpos = _xtotal - (_size + 1) * 0.5;
			if (_i == _previousItemID) then { _prevx = _xpos; };
			if (_i == _currentItemID) then { _currx = _xpos; };

			pr _offsIdx = _i - _currentItemID;
			pr _offs = [_xpos, 5 + _size * 0.5, 2];
			_offsets pushBack _offs;
		};

		//pr _t = 1 - (0 max (_animCompleteTime - time) / (animCompleteTime - animStartTime));

		// pr _actualXOffs = if ((_previousItemID != _currentItemID) and (_animStartTime != _animCompleteTime) and (_currx != _prevx)) then { 
		// 	linearConversion [_animStartTime, _animCompleteTime, time, _prevx, _currx, true] 
		// } else { 
		// 	_currx
		// };

		pr _actualXOffs = linearConversion [_animStartTime, _animCompleteTime, time, _prevx, _currx, true];

		//_prevx + (_currx - _prevx) * _t;
		for "_i" from 0 to _itemIndexSize do {
			pr _offs = (_offsets select _i) vectorAdd [-_actualXOffs, 0, 0];
			pr _h = 1 - (1 min (0.5 * abs (_offs select 0)));
			_offs = _offs vectorAdd [0, -_h*2, -_h];
			_offsets set [_i, _offs];
		};

		_offsets
	} ENDMETHOD;

	METHOD("createCarousel") {
		params ["_thisObject"];
		OOP_INFO_0("'createCarousel' method called");

		T_CALLM0("clearCarousel");

		T_PRVAR(carouselObjects);
		T_PRVAR(currentCatID);
		// T_PRVAR(currentItemID);
		T_PRVAR(ItemCatOpen);

		if (!_ItemCatOpen) exitWith { [] };

		// How many items in the currently selected category
		pr _itemCat = (g_buildUIObjects select _currentCatID) select 0;
		// _return = (_itemCat select _currentItemID) select 0;
		pr _itemIndexSize = count _itemCat - 1;
		pr _offsets = T_CALLM0("getCarouselOffsets");
		for "_i" from 0 to _itemIndexSize do {
			pr _type = (_itemCat select _i) select 0;
			OOP_INFO_1("Creating carousel item %1", _type);
			pr _offs = _offsets select _i;
			pr _newObj = createVehicle [_type, player modelToWorld _offs, [], 0, "CAN_COLLIDE"];
			_newObj attachTo [player, _offs]; 
			_carouselObjects pushBack _newObj;
		};
	} ENDMETHOD;

	METHOD("updateCarouselOffsets") {
		params ["_thisObject"];

		T_PRVAR(carouselObjects);
		T_PRVAR(currentCatID);
		T_PRVAR(ItemCatOpen);

		if (!_ItemCatOpen) exitWith { [] };

		// T_PRVAR(currentItemID);

		// How many items in the currently selected category
		pr _itemCat = (g_buildUIObjects select _currentCatID) select 0;
		pr _itemIndexSize = count _itemCat - 1;
		pr _offsets = T_CALLM0("getCarouselOffsets");
		for "_i" from 0 to _itemIndexSize do {
			pr _offs = _offsets select _i;
			pr _veh = _carouselObjects select _i;
			_veh attachTo [player, _offs];
			// pr _item = (_itemCat select _i) select 0;
			// OOP_INFO_1("Creating carousel item %1", _item);
			// pr _offs = [(_i - _itemIndexSize / 2) * 3, 10, 2];
			// pr _veh = createVehicle [_item, player modelToWorld _offs, [], 0, "CAN_COLLIDE"];
			// _veh attachTo [player]; 
			// _carouselObjects pushBack _veh;
		};

		_offsets
	} ENDMETHOD;

	METHOD("createNewObject") {
		params [P_THISCLASS, "_type", ["_offs", []]];
		OOP_INFO_2("'createNewObject' method called, _type = %1, _offs = %2", _type, _offs);

		if(count _offs == 0) then {
			_offs = [0, sizeOf _type * 2, 0];
		};
		T_CALLM0("exitMoveMode");

		pr _pos = player modelToWorld _offs;
		pr _newObj = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
		CALL_STATIC_METHOD_2("BuildUI", "setObjectMovable", _newObj, true);

		pr _activeObject = [_newObj, _pos, vectorDir _newObj, vectorUp _newObj];
		T_SETV("activeObject", _activeObject);
		T_CALLM0("moveSelectedObjects");
	} ENDMETHOD;

	build_ui_highlightObjectOnEachFrame = {
		P_DEFAULT_PARAMS;

		if(T_GETV("isMovingObjects")) exitWith {};

		T_PRVAR(activeObject);

		if(count _activeObject == 0 or {cursorObject != _activeObject select 0}) then {

			if(count _activeObject > 0) then {
				CALL_STATIC_METHOD_1("BuildUI", "restoreSelectionObject", _activeObject);
				_activeObject = [];
				T_SETV("activeObject", _activeObject);
			};

			if(CALL_STATIC_METHOD_1("BuildUI", "isObjectMovable", cursorObject)) then {
				_activeObject = CALL_STATIC_METHOD_1("BuildUI", "createSelectionObject", cursorObject);
				_activeObject params ["_obj", "_pos", "_dir", "_up"];
				T_SETV("activeObject", _activeObject);
				cursorObject setPosWorld [_pos select 0, _pos select 1, (_pos select 2) + 0.02 + 0.02 * cos(time * 720)];
			};

		} else {

			if(count _activeObject != 0) then {
				_activeObject params ["_obj", "_pos", "_dir", "_up"];
				_obj setPosWorld [_pos select 0, _pos select 1, (_pos select 2) + 0.02 + 0.02 * cos(time * 720)];
			};

		};
	};

	METHOD("enterMoveMode") {
		P_DEFAULT_PARAMS;
		OOP_INFO_0("'enterMoveMode' method called");

		// Updated highlighted object, this is a separate function due to https://feedback.bistudio.com/T123355
		["BuildUIHighlightObject", "onEachFrame", { call build_ui_highlightObjectOnEachFrame }, [_thisObject]] call BIS_fnc_addStackedEventHandler;

	} ENDMETHOD;

	METHOD("exitMoveMode") {
		params ["_thisObject"];
		OOP_INFO_0("'exitMoveMode' method called");

		T_PRVAR(activeObject);
		if(count _activeObject > 0) then {
			CALL_STATIC_METHOD_1("BuildUI", "restoreSelectionObject", _activeObject);
			T_SETV("activeObject", []);
		};

		["BuildUIHighlightObject", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
	} ENDMETHOD;

	STATIC_METHOD("setObjectMovable") {
		params [P_THISCLASS, P_OBJECT("_obj"), P_BOOL("_set")];
		_obj setVariable ["build_ui_allowMove", _set, true];
	} ENDMETHOD;

	STATIC_METHOD("isObjectMovable") {
		params [P_THISCLASS, P_OBJECT("_obj")];
		_obj getVariable ["build_ui_allowMove", false]
	} ENDMETHOD;

	STATIC_METHOD("addSelection") {
		params [P_THISCLASS, P_ARRAY("_arr"), P_ARRAY("_obj")];
		if((_obj select 0) in (_arr apply { _x select 0 })) exitWith {false};
		_arr pushBack _obj;
		true
	} ENDMETHOD;

	STATIC_METHOD("removeSelection") {
		params [P_THISCLASS, P_ARRAY("_arr"), P_ARRAY("_obj")];
		pr _idx = _arr findIf { (_x select 0) == (_obj select 0) };
		if(_idx == -1) exitWith {false};
		_arr deleteAt _idx;
		true
	} ENDMETHOD;

	STATIC_METHOD("createSelectionObject") {
		params [P_THISCLASS, P_OBJECT("_obj")];
		[_obj, getPosWorld _obj, vectorDir _obj, vectorUp _obj]
	} ENDMETHOD;

	STATIC_METHOD("restoreSelectionObject") {
		params [P_THISCLASS, P_ARRAY("_sobj")];
		_sobj params ["_obj", "_pos", "_dir", "_up"];
		OOP_INFO_4("'exitMoveMode' method called %1/%2/%3/%4", _obj, _pos, _dir, _up);
		_obj setPosWorld _pos;
		_obj setVectorDirAndUp [_dir, _up];
		_obj enableSimulation true;
	} ENDMETHOD;

	build_ui_MoveObjectsOnEachFrame = {
		params [P_THISOBJECT];
		T_PRVAR(movingObjects);
		{
			_x params ["_object", "_pos", "_dir", "_up"];

			private _relativePos = _object getVariable "build_ui_relativePos";
			private _dist = _object getVariable "build_ui_dist";
			private _ins = lineIntersectsSurfaces [
				AGLToASL positionCameraToWorld [0,0,0],
				AGLToASL positionCameraToWorld [0,0,1000],
				player, _object
			];

			if(count _ins != 0) then {
				pr _firstIns = ASLToAGL ((_ins select 0) select 0);
				private _size = _object getVariable "build_ui_size";
				private _maxdist = _size * 5; // Max distance the object can be placed at
				
				_dist = (_size max (_maxdist min (player distance _firstIns))) - _size * 0.5;
			};
			private _height = _object getVariable "build_ui_height";
			private _worldPos = player modelToWorld [_relativePos select 0, _dist, _relativePos select 2];
			// Put on ground
			_worldPos set [2, _height];
			_object attachTo [player, player worldToModel _worldPos];
			_object setVariable ["build_ui_dist", _dist];
		} forEach _movingObjects;
	};

	METHOD("moveSelectedObjects") {
		P_DEFAULT_PARAMS;

		OOP_INFO_0("'moveSelectedObjects' method called");

		// Grab the selected objects
		T_PRVAR(activeObject);
		T_PRVAR(selectedObjects);

		pr _movingObjects = +_selectedObjects;
		if (count _activeObject > 0) then {
			CALL_STATIC_METHOD_2("BuildUI", "addSelection", _movingObjects, _activeObject);
		};
		if (count _movingObjects == 0) exitWith { false };

		T_SETV("isMovingObjects", true);
		T_SETV("movingObjects", _movingObjects);

		// Exit move mode so it doesn't interfere
		T_CALLM0("exitMoveMode");

		{
			_x params ["_object", "_pos", "_dir", "_up"];

			private _relativePos = player worldToModel (_object modelToWorld [0,0,0.1]);
			private _starting_h = getCameraViewDirection player select 2;
			private _bboxCenter = boundingCenter _object;

			private _originHeight = (getPosATL _object) select 2;
			private _height = (_bboxCenter select 2);
			private _relativeDir = getDir _object - getDir player;

			_object enableSimulation false;
			_object setVariable ["build_ui_beingMoved", true];
			_object setVariable ["build_ui_relativePos", _relativePos];
			_object setVariable ["build_ui_starting_h", _starting_h];
			_object setVariable ["build_ui_height", _height];
			_object setVariable ["build_ui_dist", _relativePos select 1];
			_object setVariable ["build_ui_size", sizeOf (typeOf _object)];

			_object attachTo [player, _relativePos];
			_object setDir _relativeDir;
		} forEach _movingObjects;

		// Update moving objects on each frame, this is a separate function due to https://feedback.bistudio.com/T123355
		["BuildUIMoveObjectsOnEachFrame", "onEachFrame", { call build_ui_MoveObjectsOnEachFrame }, [_thisObject]] call BIS_fnc_addStackedEventHandler;
		true
	} ENDMETHOD;

	METHOD("dropHere") {
		P_DEFAULT_PARAMS;
		T_PRVAR(movingObjects);

		["BuildUIMoveObjectsOnEachFrame", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

		// Detach objects from player and place them
		{
			_x params ["_object", "_pos", "_dir", "_up"];
			detach _object;
			private _currPos = getPos _object;
			_object setPos [_currPos select 0, _currPos select 1, 0];
			_object enableSimulationGlobal true;
		} forEach _movingObjects;

		T_SETV("movingObjects", []);
		T_SETV("isMovingObjects", false);

		T_CALLM0("enterMoveMode");

	} ENDMETHOD;

	METHOD("cancelMovingObjects") {
		P_DEFAULT_PARAMS;

		T_PRVAR(movingObjects);

		["SetHQObjectHeight", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

		// Detach objects and put objects back where they started
		{
			_x params ["_object", "_pos", "_dir", "_up"];
			detach _object;
			CALL_STATIC_METHOD_1("BuildUI", "restoreSelectionObject", _x);
		} forEach _movingObjects;
		T_SETV("movingObjects", []);
		T_SETV("isMovingObjects", false);

		T_CALLM0("enterMoveMode");

	} ENDMETHOD;

ENDCLASS;

build_UI_addOpenBuildMenuAction = {
	ASSERT_GLOBAL_OBJECT(g_BuildUI);
	CALLM1(g_BuildUI, "addOpenBuildMenuAction", _this);
};

build_UI_setObjectMovable = {
	params ["_obj", "_val"];
	OOP_INFO_2("'build_UI_setObjectMovable' method called with %1, %2", _obj, _val);
	CALL_STATIC_METHOD_2("BuildUI", "setObjectMovable", _obj, _val);
};
