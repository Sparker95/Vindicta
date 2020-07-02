#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\common.h"

#define pr private

#define DRAW_3D_MAX_UNITS 45 // maximum units to draw text for
#define DRAW_3D_MAX_DIST 25 // maximum distance to draw display at

#define DRAW_3D_DEBUG_EH 0
#define DRAW_3D_DEBUG_CONTROL_IDCS 1

// unit data
#define DRAW_3D_UNITDATA_UNIT_ACTION 0
#define DRAW_3D_UNITDATA_UNIT_GOAL 1
#define DRAW_3D_UNITDATA_GROUP_ACTION 2
#define DRAW_3D_UNITDATA_GROUP_GOAL 3



/*
	Retrieves a number of OOP unit variables from a unit.

	Returns: [
		current unit goal String, 
		current unit action String, 
		current group goal String, 
		current group action String
	]

	Returns empty array if failed.

*/
fnc_getUnitDetails = {
	params["_object"];

	if (side _object == civilian) exitWith {};
	if !(alive _object) exitWith {};

	pr _return = [];

	// get current action/goal 
	pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", _object);
	pr _unitAI = CALLM0(_unit, "getAI");
	pr _currentGoal = "";
	pr _currentAction = "";

	// group
	pr _groupUnit = CALLM0(_unit, "getGroup");
	pr _groupAI = CALLM0(_groupUnit, "getAI");
	pr _currentGoalGroup = "";
	pr _currentActionGroup = "";

	if (_unitAI != "") then {
		_currentGoal = GETV(_unitAI, "currentGoal");
		if (_currentGoal == "") then { _currentGoal = "NO GOAL"; };
		_currentAction = CALLM0(_unitAI, "getCurrentAction");
		if (_currentAction == "") then { _currentAction = "NO ACTION"; };
	};

	if (_groupAI != "") then {
		_currentGoalGroup = GETV(_groupAI, "currentGoal");
		if (_currentGoalGroup == "") then { _currentGoalGroup = "NO GROUP GOAL"; };
		_currentActionGroup = CALLM0(_groupAI, "getCurrentAction");
		if (_currentActionGroup == "") then { _currentActionGroup = "NO GROUP ACTION"; };
	};

	_return = [_currentAction, _currentGoal, _currentActionGroup, _currentGoalGroup];

	_return
};


/*

	Toggles drawing of unit actions, goals of nearby units.

*/

pr _debugDraw3D_Data = player getVariable ["_debugDraw3D_DataStored", []];

if (_debugDraw3D_Data isEqualTo []) then {
	// [draw3D event handler, controls array,  ]
	_debugDraw3D_Data = [
		-1,
		[] // idcs for controls on display 46
	];

	player setVariable ["_debugDraw3D_DataStored", _debugDraw3D_Data];
};



// only create EH if it doesn't exist yet
if ((_debugDraw3D_Data select DRAW_3D_DEBUG_EH) == -1) then {

	systemChat "Creating event handler draw3D";
	player setVariable ["_debugDraw3D_time", time];

	// draw 3D texts on units
	pr _debugDraw3D = addMissionEventHandler ["Draw3D", {

		pr _debugDraw3D_Data = player getVariable ["_debugDraw3D_DataStored", []];
		// get array with idcs
		pr _idcs = _debugDraw3D_Data select DRAW_3D_DEBUG_CONTROL_IDCS;

		// clear old controls, if there are any
		if !(_idcs isEqualTo []) then {
			{
				if (_x != -1) then {
					ctrlDelete ((findDisplay 46) displayCtrl _x);
				};
			} forEach _idcs;
		};

		// gather units to draw text for
		pr _nearUnits = player nearObjects ["Man", DRAW_3D_MAX_DIST];
		//_nearUnits = _nearUnits - [player];

		if !(_nearUnits isEqualTo []) then {

			// draw text for each nearby unit
			{
				if (count _idcs <= DRAW_3D_MAX_UNITS && !(isPlayer _x) && (side _x != civilian)) then {

					if !(alive _x) exitWith {};
					
					pr _myUnit = _x;


					pr _pos = worldToScreen (getPos _myUnit);
					if (_pos isEqualTo []) exitWith {  };

					// workaround to ensure that this EH doesn't get OOP unit variables each frame 
					pr _time = player getVariable "_debugDraw3D_time";
					pr _unitData = [];
					if ((_time + 2) < time) then {
						player setVariable ["_debugDraw3D_time", time];
						
						if !(isNil "_myUnit") then {
							_unitData = [_myUnit] call fnc_getUnitDetails;
						};
					};

					pr _str = _myUnit getVariable ["draw3DString", (parseText "")];
					pr _groupID = groupID (group _myUnit);
					pr _strGroup = "GroupID: " + _groupID;

					if !(_unitData isEqualTo []) then { // update with new unit data, if possible

						pr _txtStart = "<t shadow=2>";
						pr _txtEnd = "</t>";

						pr _currentAction = parseText format[_txtStart + "unitAction: %1" + _txtEnd, (_unitData select DRAW_3D_UNITDATA_UNIT_ACTION)];
						pr _currentGoal = parseText format[_txtStart + "unitGoal: %1" + _txtEnd, (_unitData select DRAW_3D_UNITDATA_UNIT_GOAL)];
						pr _currentGroupAction = parseText format[_txtStart + "groupAction: %1" + _txtEnd, (_unitData select DRAW_3D_UNITDATA_GROUP_ACTION)];
						pr _currentGroupGoal = parseText format[_txtStart + "groupGoal: %1" + _txtEnd, (_unitData select DRAW_3D_UNITDATA_GROUP_GOAL)];
						pr _currentTime = parseText format[_txtStart + "Update time: %1" + _txtEnd, time];

						// create structured text _str = _currentAction + _currentGoal + _currentGroupAction + _currentGroupGoal + _currentTime;
						_str = composeText [
							_currentAction, 
							lineBreak, 
							_currentGoal, 
							lineBreak, 
							_currentGroupAction,
							lineBreak,
							_currentGroupGoal, 
							lineBreak,
							_currentTime
						];

						_myUnit setVariable ["draw3DString", _str];
					};

					// create new controls
					pr _newIdc = 97111;
					pr _newIdc = (_newIdc + _forEachIndex);
					pr _control = (finddisplay 46) ctrlCreate ["RscStructuredText", _newIdc];

					// store new control idc 
					_idcs pushBackUnique _newIdc;

					_control ctrlSetStructuredText _str;
					//_control ctrlSetFontHeight 0.048;
					pr _posX = (_pos select 0);
					pr _posY = (_pos select 1);

					// SQF-VM doesn't know ctrlTextWidth
				#ifndef _SQF_VM
					pr _width = ctrlTextWidth _control;
				#endif
				
					pr _height = ctrlTextHeight _control;
					_control ctrlSetPosition [_posX, _posY, _width, _height];
				
					// fade text and background
					pr _dist = (getPos player) distance (getPos _x);
					
					pr _alphaVal = linearConversion [0, DRAW_3D_MAX_DIST,_dist,1, 0,true];

					//_control ctrlSetBackgroundColor [0, 0, 0, _alphaVal];
					_control ctrlSetTextColor [1, 1, 1, 1];

					// scale font according to distance 

					_control ctrlCommit 0;
				};

			} forEach _nearUnits;
		};
						
		_debugDraw3D_Data set [DRAW_3D_DEBUG_CONTROL_IDCS, _idcs]; // save idcs
		player setVariable ["_debugDraw3D_DataStored", _debugDraw3D_Data];

	}]; // end draw3D event handler

	// store draw3D event handler
	_debugDraw3D_Data set [DRAW_3D_DEBUG_EH, _debugDraw3D];
	player setVariable ["_debugDraw3D_DataStored", _debugDraw3D_Data]; // save data again

} else {
	// else remove draw3D event handler
	pr _debugDraw3D = _debugDraw3D_Data select DRAW_3D_DEBUG_EH;
	removeMissionEventHandler ["Draw3D", _debugDraw3D];
	systemChat format["Removing EH: %1", _debugDraw3D];
	_debugDraw3D_Data set [DRAW_3D_DEBUG_EH, -1];

	// remove controls 
	pr _idcs = _debugDraw3D_Data select DRAW_3D_DEBUG_CONTROL_IDCS;

		// clear old controls, if there are any
		if !(_idcs isEqualTo []) then {
			{
				if (_x != -1) then {
					ctrlDelete ((findDisplay 46) displayCtrl _x);
				};
			} forEach _idcs;
		};

	_debugDraw3D_Data set [DRAW_3D_DEBUG_EH, -1];
	_debugDraw3D_Data set [DRAW_3D_DEBUG_CONTROL_IDCS, []];
	player setVariable ["_debugDraw3D_DataStored", _debugDraw3D_Data]; // save data again
};
