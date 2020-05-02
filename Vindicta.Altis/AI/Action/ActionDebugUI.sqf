#include "..\..\common.h"
#include "..\Action\Action.hpp"

#ifndef RELEASE_BUILD
/*
This script will be displaying the actions of unit you are looking at.
*/
[] spawn {

#define ACTION_DEBUG_NEXT_CTRL_ID_START 6666
#define ACTION_DEBUG_MAX_COUNT 10

actionDebugNextCtrlID = ACTION_DEBUG_NEXT_CTRL_ID_START;
actionDebugs = [];

// update the position of controls each frame
addMissionEventHandler ["EachFrame", {
	{
		private _ctrlID = _x select 1;
		private _objectHandle = _x select 2;
		private _posScreen = worldToScreen (getPos _objectHandle);
		private _ctrl = (findDisplay 46) displayCtrl _ctrlID;
		_posScreen set [0, (_posScreen select 0) - 0.15];
		_ctrl ctrlSetPosition _posScreen;
		_ctrl ctrlCommit 0;
	} forEach actionDebugs;
}];

waitUntil { ! isNull findDisplay 46 };

// Remove previous controls
for "_ctrlID" from ACTION_DEBUG_NEXT_CTRL_ID_START to (ACTION_DEBUG_NEXT_CTRL_ID_START + ACTION_DEBUG_MAX_COUNT) do {
	private _ctrl = (findDisplay 46) displayCtrl _ctrlID;
	if (_ctrl != controlNull) then { ctrlDelete _ctrl; };
};

// Remove previous event handlers
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";

	(findDisplay 46) displayAddEventHandler ["KeyDown", {
		params ["_control", "_key", "_shift", "_ctrl", "_alt"];
			if (_key == 20) then { // T button
				if (!_ctrl) then { // T without Ctrl
					//diag_log "Pressed T key!!";
					private _ctrlID = cursorObject getVariable ["actionDebugCtrlID", -1];
					// Do we already have a control for this unit?
					if (_ctrlID == -1) then {
						// No we don't have a control for this unit
						private _unit = [cursorObject] call unit_fnc_getUnitFromObjectHandle;
						// Is cursorObject a unit?
						if (_unit != "") then {
							private _action = CALLM0(_unit, "getAction");
							// Does the unit have a action? Did we exceed max amount of debug controls?
							if (_action != "" && ((count actionDebugs) < ACTION_DEBUG_MAX_COUNT)) then {
								// Create a control
								private _ctrl = (findDisplay 46) ctrlCreate ["RscStructuredText", actionDebugNextCtrlID];
								_ctrl ctrlSetPosition [0.0, 0.0, 0.6, 0.4];
								_ctrl ctrlSetBackgroundColor [0.0, 0.0, 0.0, 0.4];
								_ctrl ctrlSetTextColor [1, 1, 1, 1];
								_ctrl ctrlSetFont "EtelkaMonospacePro";
								_ctrl ctrlSetScale 0.7;
								_ctrl ctrlSetText "Text goes here...";
								_ctrl ctrlCommit 0;

								actionDebugs pushBack [_unit, actionDebugNextCtrlID, cursorObject];

								// Set variable
								cursorObject setVariable ["actionDebugCtrlID", actionDebugNextCtrlID];
								actionDebugNextCtrlID = actionDebugNextCtrlID + 1;
							};
						};
					} else {
						// Yes we have a control for this unit
						// Delete this control
						private _unit = [cursorObject] call unit_fnc_getUnitFromObjectHandle;
						actionDebugs = actionDebugs - [_unit, _ctrlID, cursorObject];
						private _ctrl = (findDisplay 46) displayCtrl _ctrlID;
						if (_ctrl != controlNull) then { ctrlDelete _ctrl; };
						cursorObject setVariable ["actionDebugCtrlID", nil];
					};
				} else { // Ctrl+T
					while {count actionDebugs > 0} do {
						private _ctrlID = actionDebugs select 0 select 1;
						private _ctrl = (findDisplay 46) displayCtrl _ctrlID;
						if (_ctrl != controlNull) then { ctrlDelete _ctrl; };
						actionDebugs deleteAt 0;
					};
				};
			};
		}];

	// Function for retrieving the text of subaction tree
	_appendSubactionTree = {
		params ["_action", "_text", "_level"];
		private _state = GETV(_action, "state");
		private _stateText = ACTION_STATE_TEXT_ARRAY select _state;
		_text = _text + "\n";
		for "_i" from 0 to _level do {
			_text = _text + "  ";
		};
		_text = _text + _action + ": " + _stateText;
		_level = _level + 1;
		private _subactions = CALLM0(_action, "getSubactions");
		{
			_text = [_x, _text, _level] call _appendSubactionTree;
		} forEach _subactions;

		_text
	};


	while {true} do {
		sleep 0.1;

		{
			private _unit = _x select 0;
			private _ctrlID = _x select 1;
			private _action = CALLM0(_unit, "getAction");
			private _text = _unit;
			if (_action != "") then {
				// Make a string with the whole action tree
				_text = [_action, _text, 0] call _appendSubactionTree;
			};
			private _ctrl = (findDisplay 46) displayCtrl _ctrlID;
			_ctrl ctrlSetText _text;
			_ctrl ctrlCommit 0;
		} forEach actionDebugs;
	};


	/*
	private _action = "";
	private _unit = "";
	while {true} do {
		sleep 0.1;

		private _unitNew = [cursorObject] call unit_fnc_getUnitFromObjectHandle;
		if (_unitNew != "") then {
			// Get unit's action
			_unit = _unitNew;
			private _actionNew = CALLM0(_unit, "getAction");
			if (_actionNew != "") then {_action = _actionNew; };
		};
		if (_action != "") then {
			// Make a string with the whole action tree
			private _text = [_action, _unit, 0] call _appendSubactionTree;
			hint _text;
		};
	};
	*/
};
#endif