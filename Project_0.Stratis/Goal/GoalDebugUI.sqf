/*
This script will be displaying the goals of unit you are looking at.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

[] spawn {

goalDebugNextCtrlID = 6666;
goalDebugs = [];

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
	} forEach goalDebugs;
}];

waitUntil { ! isNull findDisplay 46 };

	(findDisplay 46) displayAddEventHandler ["KeyDown", {
		params ["_control", "_key", "_shift", "_ctrl", "_alt"];
			if (_key == 20) then { // T button
				if (!_ctrl) then { // T without Ctrl
					//diag_log "Pressed T key!!";
					private _ctrlID = cursorObject getVariable ["goalDebugCtrlID", -1];				
					// Do we already have a control for this unit?
					if (_ctrlID == -1) then {
						// No we don't have a control for this unit
						private _unit = [cursorObject] call unit_fnc_getUnitFromObjectHandle;
						// Is cursorObject a unit?
						if (_unit != "") then {
							private _goal = CALLM(_unit, "getGoal", []);
							// Does the unit have a goal?
							if (_goal != "") then {
								// Create a control
								private _ctrl = (findDisplay 46) ctrlCreate ["RscStructuredText", goalDebugNextCtrlID];
								_ctrl ctrlSetPosition [0.0, 0.0, 0.6, 0.4];
								_ctrl ctrlSetBackgroundColor [0.0, 0.0, 0.0, 0.4];
								_ctrl ctrlSetTextColor [1, 1, 1, 1];
								_ctrl ctrlSetFont "EtelkaMonospacePro";
								_ctrl ctrlSetScale 0.7;
								_ctrl ctrlSetText "Text goes here...";
								_ctrl ctrlCommit 0;
							
								goalDebugs pushBack [_unit, goalDebugNextCtrlID, cursorObject];
								
								// Set variable
								cursorObject setVariable ["goalDebugCtrlID", goalDebugNextCtrlID];
								goalDebugNextCtrlID = goalDebugNextCtrlID + 1;							
							};
						};
					} else {
						// Yes we have a control for this unit
						// Delete this control
						private _unit = [cursorObject] call unit_fnc_getUnitFromObjectHandle;
						goalDebugs = goalDebugs - [_unit, _ctrlID, cursorObject];
						private _ctrl = (findDisplay 46) displayCtrl _ctrlID;
						if (_ctrl != controlNull) then { ctrlDelete _ctrl; };
						cursorObject setVariable ["goalDebugCtrlID", nil];
					};
				} else { // Ctrl+T
					while {count goalDebugs > 0} do {
						private _ctrlID = goalDebugs select 0 select 1;
						private _ctrl = (findDisplay 46) displayCtrl _ctrlID;
						if (_ctrl != controlNull) then { ctrlDelete _ctrl; };
						goalDebugs deleteAt 0;
					};
				};
			};
		}];

	// Function for retrieving the text of subgoal tree
	_appendSubgoalTree = {
		params ["_goal", "_text", "_level"];
		private _state = GETV(_goal, "state");
		private _stateText = GOAL_STATE_TEXT_ARRAY select _state;
		_text = _text + "\n";
		for "_i" from 0 to _level do {
			_text = _text + "  ";
		};
		_text = _text + _goal + ": " + _stateText;
		_level = _level + 1;
		private _subgoals = CALLM(_goal, "getSubgoals", []);
		{
			_text = [_x, _text, _level] call _appendSubgoalTree;
		} forEach _subgoals;
		
		_text
	};


	while {true} do {
		sleep 0.1;
		
		{
			private _unit = _x select 0;
			private _ctrlID = _x select 1;
			private _goal = CALLM(_unit, "getGoal", []);
			private _text = _unit;
			if (_goal != "") then {
				// Make a string with the whole goal tree
				_text = [_goal, _text, 0] call _appendSubgoalTree;
			};
			private _ctrl = (findDisplay 46) displayCtrl _ctrlID;			
			_ctrl ctrlSetText _text;
			_ctrl ctrlCommit 0;
		} forEach goalDebugs;
	};


	/*
	private _goal = "";
	private _unit = "";
	while {true} do {
		sleep 0.1;
		
		private _unitNew = [cursorObject] call unit_fnc_getUnitFromObjectHandle;
		if (_unitNew != "") then {
			// Get unit's goal
			_unit = _unitNew;
			private _goalNew = CALLM(_unit, "getGoal", []);
			if (_goalNew != "") then {_goal = _goalNew; };
		};
		if (_goal != "") then {
			// Make a string with the whole goal tree
			private _text = [_goal, _unit, 0] call _appendSubgoalTree;
			hint _text;
		};
	};
	*/
};