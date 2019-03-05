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

Author: Marvis
*/

#define pr private

g_BuildUI = nil;

CLASS("BuildUI", "")

	VARIABLE("activeBuildMenus");
	VARIABLE("EHKeyDown");
	VARIABLE("EHKeyUp") ;

	// Object currently highlighted
	VARIABLE("activeObject");
	// With an object selection we can do silly things like move a bunch at the same time, copy and paste etc.
	// Just implement Add To Selection and Remove From Selection
	VARIABLE("selectedObjects");
	VARIABLE("moveActionId");

	METHOD("new") {
		params ["_thisObject"];

		if(!(isNil("g_BuildUI"))) exitWith {
			OOP_ERROR_0("BuildUI already initialized! Make sure to delete it before trying to initialize it again!");
		};

		g_BuildUI = _thisObject;

		OOP_INFO_1("Player %1 build UI initialized.", name player);

		T_SETV("activeBuildMenus", []);
		T_SETV("EHKeyDown", nil);
		T_SETV("EHKeyUp", nil);

		T_SETV("activeObject", []);
		T_SETV("selectedObjects", []);
		T_SETV("moveActionId", -1);
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

		OOP_INFO_0("method called");

		T_CALLM0("enterMoveMode");

		// TEST CODE >>>
		player addAction ["Create Test Object", {
			params ["_target", "_caller", "_actionId", "_arguments"];
			_arguments params ["_thisObject"];
			pr _type = selectRandom ["Land_BagFence_Long_F", "Land_BagFence_Round_F", "Land_PortableLight_double_F", "Land_TentA_F"];
			T_CALLM1("createNewObject", _type);
		}, [_thisObject]];
		cutRsc ["buildUI", "PLAIN", 2];
		// <<< TEST CODE

		pr _EHKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			systemChat format ["%1", str _this];
			
			switch (_keyText) do {
				default { false; }; 
				case """UP""": { CALLM0(g_BuildUI, "navUp"); true; };
				case """DOWN""": { CALLM0(g_BuildUI, "navDown"); true; };
				case """Escape""": { CALLM0(g_BuildUI, "closeUI"); true; };
			};
		}];

		T_SETV("EHKeyDown", _EHKeyDown);

		// TODO: Add player on death event to hide UI and drop held items etc.
		// Also for when they leave camp area.
	} ENDMETHOD;

	METHOD("closeUI") {
		params ["_thisObject"];

		OOP_INFO_0("method called");

		(findDisplay 46) displayRemoveEventHandler ["KeyDown", T_GETV("EHKeyDown")];
		T_SETV("EHKeyDown", nil);

		OOP_INFO_0("Removed display event handler!");
	} ENDMETHOD;

	// navigate up item list
	METHOD("navUp") {
		params ["_thisObject"];

		OOP_INFO_0("method called");
	} ENDMETHOD;

	METHOD("navDown") {
		params ["_thisObject"];

		OOP_INFO_0("method called");
	} ENDMETHOD;

	METHOD("createNewObject") {
		params ["_thisObject", "_type", ["_offs", [0, 4, 0]]];
		
		T_CALLM0("exitMoveMode");
		pr _newObj = createVehicle [_type, player modelToWorld _offs, [], 0, "CAN_COLLIDE"];
		T_SETV("selectedObjects", [[_newObj, getPos _newObj]]);
		T_CALLM0("moveSelectedObjects");
	} ENDMETHOD;

	METHOD("enterMoveMode") {
		params ["_thisObject"];

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

build_ui_addOpenBuildMenuAction = {
	ASSERT_GLOBAL_OBJECT(g_BuildUI);

	CALLM1(g_BuildUI, "addOpenBuildMenuAction", _this);
};
