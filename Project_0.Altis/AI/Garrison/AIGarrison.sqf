#include "common.hpp"

/*
Class: AI.AIGarrison
*/

#define pr private

#define DEBUG_GOAL_MARKERS

#define MRK_GOAL	"_goal"
#define MRK_ARROW	"_arrow"

CLASS("AIGarrison", "AI_GOAP")

	// Array of targets known by this garrison
	VARIABLE("targets");
	
	VARIABLE("sensorHealth");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		// Initialize sensors
		pr _sensorHealth = NEW("SensorGarrisonHealth", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorHealth]);
		T_SETV("sensorHealth", _sensorHealth); // Keep reference to this sensor in case we want to update it
		
		pr _sensorTargets = NEW("SensorGarrisonTargets", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorTargets]);
		
		pr _sensorCasualties = NEW("SensorGarrisonCasualties", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorCasualties]);
		
		
		pr _loc = CALLM0(_agent, "getLocation");
		if (_loc != "") then {
			pr _sensorObserved = NEW("SensorGarrisonLocationIsObserved", [_thisObject]);
			CALLM1(_thisObject, "addSensor", _sensorObserved);
		};
		
		// Initialize the world state
		pr _ws = [WSP_GAR_COUNT] call ws_new; // todo WorldState size must depend on the agent
		[_ws, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_ALL_CREW_MOUNTED, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_ALL_INFANTRY_MOUNTED, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_VEHICLE_GROUPS_MERGED, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_VEHICLE_GROUPS_BALANCED, false] call ws_setPropertyValue;
		[_ws, WSP_GAR_CLEARING_AREA, [0, 0, 0]] call ws_setPropertyValue;
		pr _loc = CALLM0(_agent, "getLocation");
		[_ws, WSP_GAR_LOCATION, _loc] call ws_setPropertyValue;
		if (_loc != "") then {
			pr _pos = CALLM0(_loc, "getPos");
			[_ws, WSP_GAR_POSITION, _pos] call ws_setPropertyValue;
		};
		
		
		SETV(_thisObject, "worldState", _ws);
		SETV(_thisObject, "targets", []);
		
		// Set process interval
		CALLM1(_thisObject, "setProcessInterval", 1); //6);
		
		#ifdef DEBUG_GOAL_MARKERS
		// Main marker
		pr _color = [CALLM0(_agent, "getSide"), true] call BIS_fnc_sideColor;
		pr _name = _thisObject + MRK_GOAL;
		pr _mrk = createmarker [_name, CALLM0(_agent, "getPos")];
		_mrk setMarkerType "n_unknown";
		_mrk setMarkerColor _color;
		_mrk setMarkerAlpha 1;
		_mrk setMarkerText "new...";
		// Arrow marker (todo)
		
		// Arrow marker
		pr _name = _thisObject + MRK_ARROW;
		pr _mrk = createMarker [_name, [0, 0, 0]];
		_mrk setMarkerShape "RECTANGLE";
		_mrk setMarkerBrush "SolidFull";
		_mrk setMarkerSize [10, 10];
		_mrk setMarkerColor _color;
		_mrk setMarkerAlpha 0.5;
		
		#endif
		
	} ENDMETHOD;
	
	METHOD("delete") {
		params ["_thisObject"];
		deleteMarker (_thisObject + MRK_GOAL);
	} ENDMETHOD;
	
	
	#ifdef DEBUG_GOAL_MARKERS
	METHOD("process") {
		params ["_thisObject"];
		
		// Call base class process (classNameStr, objNameStr, methodNameStr, extraParams)
		CALL_CLASS_METHOD("AI_GOAP", _thisObject, "process", []);
		
		// Update the markers
		pr _gar = T_GETV("agent");
		pr _mrk = _thisObject + MRK_GOAL;
		
		// Set text
		pr _action = T_GETV("currentAction");
		if (_action != "") then {
			_action = CALLM0(_action, "getFrontSubaction");
		};
		pr _text = format ["%1, %2, %3, %4", _gar, T_GETV("currentGoal"), T_GETV("currentGoalParameters"), _action];
		_mrk setMarkerText _text;
		
		// Set pos
		pr _pos = CALLM0(_gar, "getPos");
		_mrk setMarkerPos _pos;
		
		// Update arrow marker
		pr _mrk = _thisObject + MRK_ARROW;
		pr _goalParameters = T_GETV("currentGoalParameters");
		// See if location or position is passed
		pr _pPos = CALLSM3("Action", "getParameterValue", _goalParameters, TAG_G_POS, false);
		pr _pLoc = CALLSM3("Action", "getParameterValue", _goalParameters, TAG_LOCATION, false);
		if (isNil "_pPos" && isNil "_pLoc") then {
			_mrk setMarkerAlpha 0; // Hide the marker
		} else {
			_mrk setMarkerAlpha 0.5; // Show the marker
			pr _posDest = [0, 0, 0];
			if (!isNil "_pPos") then {	_posDest = _pPos;	};
			if (!isNil "_pLoc") then {
				if (_pLoc isEqualType "") then {
					_posDest = CALLM0(_pLoc, "getPos");
				} else {
					_posDest = _pLoc;
				};
			};
			pr _mrkPos = (_pPos vectorAdd _pos) vectorMultiply 0.5;
			_mrk setMarkerPos _mrkPos;
			_mrk setMarkerSize [0.5*(_pos distance2D _posDest), 10];
			_mrk setMarkerDir ((_pos getDir _posDest) + 90);
		};
		
	} ENDMETHOD;
	#endif
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The garrison AI resides in the same thread as the garrison
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;

	/*
	Method: handleGroupsAdded
	Handles what happens when groups get added while there is an active action.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD("handleGroupsAdded") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		pr _action = T_GETV("currentAction");
		if (_action != "") then {
			// Call it directly since it is in the same thread
			CALLM1(_action, "handleGroupsAdded", [_groups]);
		};
		
		nil
	} ENDMETHOD;


	/*
	Method: handleGroupsRemoved
	Handles a group being removed from its garrison while the AI object is still operational.
	Currently it deletes goals from groups that have been assigned by this AI object and calls handleGroupsRemoved of current action of this AI object, if it exists.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD("handleGroupsRemoved") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		// Delete goals that have been given by this object
		{
			pr _groupAI = CALLM0(_x, "getAI");
			if (!isNil "_groupAI") then {
				if (_groupAI != "") then {
					CALLM2(_groupAI, "deleteExternalGoal", "", _thisObject);
				};
			};
		} forEach _groups;
		
		pr _action = T_GETV("currentAction");
		if (_action != "") then {
			// Call it directly since it is in the same thread
			CALLM1(_action, "handleGroupsRemoved", [_groups]);
		};
		
		nil
	} ENDMETHOD;
	
	
	
	/*
	Method: handleUnitsRemoved
	Handles what happens when units get removed from their group, for instance when they gets destroyed.
	
	Access: internal
	
	Parameters: _units
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		// Update health sensor
		CALLM0(T_GETV("sensorHealth"), "update");
	} ENDMETHOD;
	
	/*
	Method: handleUnitsAdded
	Handles what happens when units get added to a group.
	
	Access: internal
	
	Parameters: _unit
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		// Update health sensor
		CALLM0(T_GETV("sensorHealth"), "update");
	} ENDMETHOD;
	
	
	METHOD("handleLocationChanged") {
		params ["_thisObject", ["_loc", "", [""]]];
		pr _ws = T_GETV("worldState");
		[_ws, WSP_GAR_LOCATION, _loc] call ws_setPropertyValue;
	} ENDMETHOD;

ENDCLASS;