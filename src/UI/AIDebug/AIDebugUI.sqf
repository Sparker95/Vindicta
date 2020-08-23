#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG
//#define OOP_ASSERT
#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"
#include "..\..\AI\Action\Action.hpp"
#include "..\..\AI\Unit\unitHumanWorldStateProperties.hpp"
#include "..\..\AI\Group\groupWorldStateProperties.hpp"
#include "..\..\AI\Garrison\garrisonWorldStateProperties.hpp"
#include "..\..\AI\WorldState\WorldStateProperty.hpp"

#define pr private

#define sv setVariable
#define gv getVariable

#define INTERVAL_GROUP_REQUEST 1
#define INTERVAL_GARRISON_REQUEST 3

// Variable name for storing received data on units
#define AI_DEBUG_DATA_VAR_NAME "AIDebugData"

// Time when we received update on this unit last time
#define AI_DEBUG_DATA_LAST_RX_TIME_NAME "AIDebugDataLastUpdate"

// Structure of received debug message
#define DEBUG_DATA_PARAMS [ \
			"_armaAgent", \
			"_agent", \
			"_agentClass", \
			"_ai", \
			"_aiClass", \
			"_worldState", \
			"_goal", \
			"_goalParameters", \
			"_action", \
			"_actionClass", \
			"_subaction", \
			"_subactionClass", \
			"_subactionState", \
			"_extraAIVariables", \
			"_extraSubactionVariables" \
		]

#define OOP_CLASS_NAME AIDebugUI
CLASS("AIDebugUI", "")

	STATIC_VARIABLE("initialized");
	STATIC_VARIABLE("instance");

	VARIABLE("drawEventHandler");
	VARIABLE("curatorEventHandlers"); // Array of [type, id] to remove event handlers later

	VARIABLE("curator");

	VARIABLE("panelGarrison");
	VARIABLE("panelGroup");
	VARIABLE("panelUnit");

	// Currently selected object and group
	VARIABLE("curatorSelected");	// Array of selected items by curator UI

	// Time when last request of this kidn was sent
	VARIABLE("timeLastGroupRequest");		// Group and unit requests are sent at the same time
	VARIABLE("timeLastGarrisonRequest");

	METHOD(new)
		params [P_THISOBJECT];

		OOP_INFO_0("NEW");

		T_SETV("timeLastGroupRequest", time);
		T_SETV("timeLastGarrisonRequest", time);
		T_SETV("curatorSelected", curatorSelected);

		// Add event handlers
		pr _ehs = [];
		T_SETV("curatorEventHandlers", _ehs);
		pr _id = addMissionEventHandler ["Draw3D", {
			pr _inst = GETSV("AIDebugUI", "instance");
			CALLM0(_inst, "onDraw");
		}];
		T_SETV("drawEventHandler", _id);

		// Add curator event handlers
		pr _curator = ace_zeus_zeus;						// !!! The code searches for curator object created by ACE // todo: add other ways to find curator object?
		T_SETV("curator", objNull);
		if (!isNil "_curator") then {
			if (!isNull _curator) then {
				
				pr _id = _curator addEventHandler ["CuratorObjectSelectionChanged", {
					//params ["_curator", "_entity"];
					pr _instance = GETSV("AIDebugUI", "instance");
					//diag_log "Curator: Object selection changed";
					CALLM0(_instance, "update");
				}];
				_ehs pushBack ["CuratorObjectSelectionChanged", _id];

				pr _id = _curator addEventHandler ["CuratorGroupSelectionChanged", {
					//params ["_curator", "_entity"];
					pr _instance = GETSV("AIDebugUI", "instance");
					//diag_log "Curator: Group selection changed";
					CALLM0(_instance, "update");
				}];
				_ehs pushBack ["CuratorGroupSelectionChanged", _id];

				T_SETV("curator", _curator);
			} else {
				OOP_ERROR_0("Curator object is null");
			};
		} else {
			OOP_ERROR_0("Curator object is nil");
		};

		// Create panels
		pr _panelGarrison = NEW("AIDebugPanel", []);
		pr _panelGroup = NEW("AIDebugPanel", []);
		pr _panelUnit = NEW("AIDebugPanel", []);
		T_SETV("panelGarrison", _panelGarrison);
		T_SETV("panelGroup", _panelGroup);
		T_SETV("panelUnit", _panelUnit);

		// ===== Set panel positions =====
		pr _gGarrison = CALLM0(_panelGarrison, "getGroupPanel");	// Get group control handles
		pr _gGroup = CALLM0(_panelGroup, "getGroupPanel");
		pr _gUnit = CALLM0(_panelUnit, "getGroupPanel");

		pr _d = findDisplay 312;
		pr _ctrlRight = _d displayCtrl 450;		// The right-side curator control

		#ifndef _SQF_VM
		pr _gapy = 0.005*safeZoneH;				// Gaps between panels
		pr _gapx = _gapy*safeZoneH/safeZoneW;

		pr _w = (ctrlPosition _gGarrison)#2;	// Width and height of one panel
		pr _h = (ctrlPosition _gGarrison)#3;

		pr _x0 = ((ctrlPosition _ctrlRight)#0) - _w - _gapx;		// Start coordinates
		pr _y0 = safeZoneY + safeZoneH*0.08;

		_gGarrison ctrlSetPositionX _x0;
		_gGarrison ctrlSetPositionY _y0;

		_gGroup ctrlSetPositionX _x0;
		_gGroup ctrlSetPositionY _y0 + (_h+_gapy);

		_gUnit ctrlSetPositionX _x0;
		_gUnit ctrlSetPositionY _y0 + 2*(_h+_gapy);

		_gGarrison ctrlCommit 0;
		_gGroup ctrlCommit 0;
		_gUnit ctrlCommit 0;
		#endif
		// ========================

	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		SETSV("AIDebugUI", "instance", NULL_OBJECT);

		// Delete Event Handlers
		removeMissionEventHandler ["Draw3D", T_GETV("drawEventHandler")];
		{
			T_GETV("curator") removeEventHandler _x;
		} forEach T_GETV("curatorEventHandlers");

		// Delete panels
		DELETE(T_GETV("panelGarrison"));
		DELETE(T_GETV("panelGroup"));
		DELETE(T_GETV("panelUnit"));
	ENDMETHOD;

	// Base logic

	METHOD(update)
		params [P_THISOBJECT];

		pr _selPrev = T_GETV("curatorSelected");
		pr _unitsPrev = _selPrev#0;
		pr _groupsPrev = _selPrev#1;
		pr _selNew = CuratorSelected;
		pr _units = _selNew#0;
		pr _groups = _selNew#1;
		pr _selChanged = !(_selPrev isEqualTo _selNew);
		pr _requestGroupAndUnit = false;
		T_SETV("curatorSelected", _selNew);

		// Erase panels if we have deselected everything
		if ((count _unitsPrev != 0) && (count _units == 0) ||
			(count _groupsPrev != 0) && (count _groups == 0)) then {
			{
				pr _panel = T_GETV(_x);
				CALLM0(_panel, "clearData");
			} forEach ["panelUnit", "panelGroup", "panelGarrison"];
		};

		// Request group and unit data if needed
		if (time - T_GETV("timeLastGroupRequest") > INTERVAL_GROUP_REQUEST || _selChanged) then {

			// Request unit AI data if some units are selected
			// Request data for all selected units - we want to draw markers on all of them
			{
				pr _args = [clientOwner, 0, _x];
				OOP_INFO_1("Request unit data: %1", _x);
				REMOTE_EXEC_CALL_STATIC_METHOD("AI_GOAP", "requestDebugUIData", _args, 2, false);
			} forEach _units;

			// Request group AI data for all selected group
			pr _groupsRequest = _groups;
			if (count _groups == 0) then {				// If no groups are selected
				if (count _units != 0) then {			// Then we request data from group of first selected unit
					_groupsRequest = [group (_units#0)];
				};
			};
			{
				//pr _group = if(count _groups == 1) then {_groups#0} else {group (_units#0)}; // Selected group or group of first unit
				pr _group = _x;
				pr _args = [clientOwner, 1, _group];
				OOP_INFO_1("Request group data: %1", _group);
				REMOTE_EXEC_CALL_STATIC_METHOD("AI_GOAP", "requestDebugUIData", _args, 2, false);
				OOP_INFO_1("Requested group data: %1", _group);
			} forEach _groupsRequest;

			T_SETV("timeLastGroupRequest", time);
		};

		// Request garrison data if needed
		if (time - T_GETV("timeLastGarrisonRequest") > INTERVAL_GARRISON_REQUEST || _selChanged) then {

			// We must have some unit to get its garrison data
			if ((count _groups == 1) || (count _units > 0)) then {
				pr _unit = if (count _groups == 1) then {
					pr _groupUnits = units (_groups#0);
					if (count _groupUnits > 0) then { _groupUnits#0 } else { objNull };
				} else {
					_units#0
				};

				if (!isNull _unit) then {
					pr _args = [clientOwner, 2, _unit];
					OOP_INFO_1("Request garrison data: %1", _unit);
					REMOTE_EXEC_CALL_STATIC_METHOD("AI_GOAP", "requestDebugUIData", _args, 2, false);
				};
			};
			

			T_SETV("timeLastGarrisonRequest", time);
		};

	ENDMETHOD;

	// Called from "Draw3D" event handler
	public event METHOD(onDraw)
		params [P_THISOBJECT];

		T_CALLM0("update");

		// Draw markers
		pr _sel = T_GETV("curatorSelected");
		pr _units = _sel#0;
		pr _groups = _sel#1;

		{ // forEach _units;
			pr _data = _x getVariable AI_DEBUG_DATA_VAR_NAME;
			pr _text = "No AI";

			// If AI data for this unit/group exists
			if (!isNil "_data") then {
				_goal = _data#6;
				pr _lastUpdateTime = _x getVariable AI_DEBUG_DATA_LAST_RX_TIME_NAME;
				//OOP_INFO_1("Last update time: %1", _lastUpdateTime);
				_text = "No Goal";
				// If this AI has a goal
				if (_goal != "") then {
					_text = _goal;
					/*
					if (_x isEqualType objNull) then {
						_text = _goal select [8, 32]; // We want to remove "GoalUnit" at string start
					} else {
						_text = _goal select [9, 32]; // Remove "GoalGroup"
					};
					*/
				};

				// If we haven't received updates on this unit for some time, display a warning
				//OOP_INFO_1("Delta time: %1", time - _lastUpdateTime);
				if ((time - _lastUpdateTime) > (INTERVAL_GROUP_REQUEST+2)) then {
					_text = _text + " OUTDATED";
				};
			};
			
			// Draw marker
			pr _texture = "";
			pr _posAGL = [];
			if (_x isEqualType objNull) then {
				// Unit
				_posAGL = _x modelToWorldVisual [0, 0, 2];
				_texture = "\A3\ui_f\data\map\markers\handdrawn\unknown_CA.paa";
			} else {
				// Group
				_posAGL = (leader _x) modelToWorldVisual [0, 0, 5];	// Draw marker at leaader pos if it's a group
				_texture = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
			};
			drawIcon3D [_texture, //texture,
						[1, 1, 1, 1], //color, 
						_posAGL,
						1.0, //width,
						1.0, //height,
						0, //angle,
						_text, // text
						true, //shadow - outline
						0.05]; //textSize,
						//font,
						//textAlign,
						//drawSideArrows];
		} forEach (_units + _groups);

	ENDMETHOD;

	// Not used any more
	/*
	public event METHOD(onObjectSelectionChanged)
		params [P_THISOBJECT, P_OBJECT("_object")];
		OOP_INFO_1("Object selection changed: %1", _object);
	ENDMETHOD;

	public event METHOD(onGroupSelectionChanged)
		params [P_THISOBJECT, P_GROUP("_group")];
		OOP_INFO_1("Group selection changed: %1", _group);
	ENDMETHOD;
	*/

	// = = = Static methods to create/delete instance = = = = 

	// Static method to create this object
	STATIC_METHOD(createInstance)
		params [P_THISCLASS];

		OOP_INFO_0("CREATE INSTANCE");

		// Bail if such object exists already
		if (!IS_NULL_OBJECT(GETSV("AIDebugUI", "instance"))) exitWith {};

		OOP_INFO_0("CALLING NEW");

		pr _ret = NEW("AIDebugUI", []);
		SETSV("AIDebugUI", "instance", _ret);
		_ret
	ENDMETHOD;

	STATIC_METHOD(deleteInstance)
		params [P_THISCLASS];

		OOP_INFO_0("DELETE INSTANCE");

		pr _inst = GETSV("AIDebugUI", "instance");
		
		if (!IS_NULL_OBJECT(_inst)) then {
			DELETE(_inst);
		};

	ENDMETHOD;

	// = = = = = = = = = = = = = = = = =



	// ================ Curator open/close event handlers ==================
	public event STATIC_METHOD(onCuratorOpen)
		params [P_THISCLASS];

		if (call misc_fnc_isAdminLocal) then {	// Only for admin!
			// Create a button which will toggle AI debugging
			pr _d = findDisplay 312;
			pr _ctrlRight = _d displayCtrl 450;		// The right-side curator control
			pr _ctrlCompass = _d displayCtrl 16810;

			pr _btn = _d ctrlCreate ["MUI_BUTTON_TXT", -1];
			_btn ctrlSetText "AI DEBUG PANEL";
			pr _w = safeZoneW * 0.1;
			_btn ctrlSetPosition [
				((ctrlPosition _ctrlRight)#0) - _w - 0.005*safeZoneW,
				(ctrlPosition _ctrlCompass)#1 + 0.005*safeZoneH,
				_w,
				safeZoneH * 0.025
			];
			_btn ctrlCommit 0;

			_btn ctrlAddEventHandler ["ButtonClick", {
				pr _inst = GETSV("AIDebugUI", "instance");
				if (IS_NULL_OBJECT(_inst)) then {
					CALLSM0("AIDebugUI", "createInstance");
				} else {
					CALLSM0("AIDebugUI", "deleteInstance");
				};
			}];
		};
	ENDMETHOD;

	public event STATIC_METHOD(onCuratorClose)
		params [P_THISCLASS];
		CALLSM0("AIDebugUI", "deleteInstance");
	ENDMETHOD;

	// ===================================================


	// Performs initialization of debug UI, must be called once when mission is loaded
	public STATIC_METHOD(staticInit)
		params [P_THISCLASS];

		OOP_INFO_0("STATIC INIT");

		// Bail if already initialized
		if (GETSV(_thisClass, "initialized")) exitWith {
			OOP_WARNING_0("ALREADY INITIALIZED");
		};

		// Add CBA event handler to detect when player opens curator interface
		["featureCamera", {
			pr _newCamera = [] call CBA_fnc_getActiveFeatureCamera;
			//diag_log format ["== featureCamera"];
			if (_newCamera == "Curator") then {
				CALLSM0("AIDebugUI", "onCuratorOpen");
			} else {
				// If we are switching from curator camera
				CALLSM0("AIDebugUI", "onCuratorClose");
			};
		}] call CBA_fnc_addPlayerEventHandler;
	ENDMETHOD;



	// =========================== Comms with server =====================

	METHOD(_receiveData)
		params [P_THISOBJECT, P_ARRAY("_data")];

		// Error
		if (count _data == 0) exitWith {};

		if (count _data == 1) then {
			// Wrong target data was specified
			pr _armaAgent = _data#0;
			pr _panel = NULL_OBJECT;
			if (_armaAgent isEqualType objNull) then {
				_panel = T_GETV("panelUnit");
			};
			if (_armaAgent isEqualType grpNull) then {
				_panel = T_GETV("panelGroup");
			};
			if (_armaAgent isEqualType "") then {	// Garrison ref received
				_panel = T_GETV("panelGarrison");
			};
			if (!IS_NULL_OBJECT(_panel)) then {
				CALLM0(_panel, "clearData");
			};
		} else {
			// Data seems correct
			pr _sel = T_GETV("curatorSelected");
			pr _units = _sel#0;
			pr _groups = _sel#1;
			
			pr _armaAgent = _data#0;
			pr _panel = NULL_OBJECT;

			// Is it a unit?
			if (_armaAgent isEqualType objNull && {_armaAgent in _units}) then {

				// Store received data on this unit
				_armaAgent setVariable [AI_DEBUG_DATA_VAR_NAME, _data];
				_armaAgent setVariable [AI_DEBUG_DATA_LAST_RX_TIME_NAME, time];

				if (count _units == 1) then {
					_panel = T_GETV("panelUnit");
				};
			};
			if (_armaAgent isEqualType grpNull) then {

				// Store received data on this group
				_armaAgent setVariable [AI_DEBUG_DATA_VAR_NAME, _data];
				_armaAgent setVariable [AI_DEBUG_DATA_LAST_RX_TIME_NAME, time];

				if (count _groups <= 1) then {
					_panel = T_GETV("panelGroup");
				};
			};
			if (_armaAgent isEqualType "") then {
				_panel = T_GETV("panelGarrison");
			};
			if (!IS_NULL_OBJECT(_panel)) then {
				CALLM1(_panel, "updateData", _data);
			};
			
		};
	ENDMETHOD;

	// Remote-executed on client from server
	STATIC_METHOD(receiveData)
		params [P_THISCLASS, P_ARRAY("_data")];

		OOP_INFO_1("receiveData: %1", _data);

		pr _instance = GETSV(_thisClass, "instance");

		if (!IS_NULL_OBJECT(_instance)) then {
			CALLM1(_instance, "_receiveData", _data);
		};
	ENDMETHOD;

ENDCLASS;

// Class for one tab
#define OOP_CLASS_NAME AIDebugPanel
CLASS("AIDebugPanel", "")

	VARIABLE("ai");	// AI object

	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("ai", NULL_OBJECT);

		pr _d = findDisplay 312;
		pr _ctrl = _d ctrlCreate ["AI_DEBUG_GROUP", -1];
		
		uiNamespace sv [_thisObject + "group", _ctrl];
		uiNamespace sv [_thisObject + "tree", uiNamespace getVariable "vin_aidbg_tree"];
		uiNamespace sv [_thisObject + "editAI", uiNamespace getVariable "vin_aidbg_edit_ai_ref"];
		uiNamespace sv [_thisObject + "buttonHalt", uiNamespace getVariable "vin_aidbg_button_halt"];

		// Add button event handler
		pr _btn = T_CALLM0("getButtonHalt");
		_btn setVariable ["panel", _thisObject];
		_btn ctrlAddEventHandler ["ButtonClick", {
			params ["_control"];
			pr _thisObject = _control getVariable "panel";
			pr _ai = T_GETV("AI");
			if (!IS_NULL_OBJECT(_ai)) then {
				OOP_INFO_1("Halt AI: %1", _ai);
				REMOTE_EXEC_CALL_STATIC_METHOD("AI_GOAP", "requestHaltAI", [_ai], 2, false);
			};
		}];

		// Reset tree veiw - it must have some data
		T_CALLM0("resetTreeView");
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		pr _ctrl = T_CALLM0("getGroupPanel");
		ctrlDelete _ctrl; // Should also delete all child controls

		uiNamespace sv [_thisObject + "group", nil];
		uiNamespace sv [_thisObject + "tree", nil];
		uiNamespace sv [_thisObject + "editAI", nil];
		uiNamespace sv [_thisObject + "buttonHalt", nil];
	ENDMETHOD;

	public METHOD(getGroupPanel)
		params [P_THISOBJECT];
		uiNamespace gv (_thisObject + "group")
	ENDMETHOD;

	public METHOD(getTreeView)
		params [P_THISOBJECT];
		uiNamespace gv (_thisObject + "tree")
	ENDMETHOD;

	public METHOD(getEditAI)
		params [P_THISOBJECT];
		uiNamespace gv (_thisObject + "editAI")
	ENDMETHOD;

	public METHOD(getButtonHalt)
		params [P_THISOBJECT];
		uiNamespace gv (_thisObject + "buttonHalt")
	ENDMETHOD;

	// Clears all UI fields
	public METHOD(clearData)
		params [P_THISOBJECT];
		
		T_SETV("ai", NULL_OBJECT);

		pr _edit = T_CALLM0("getEditAI");
		_edit ctrlSetText "";

		T_CALLM0("resetTreeView");

	ENDMETHOD;

	// Updates data of this panel from data array (AIDebugUI.receiveData format)
	public METHOD(updateData)
		params [P_THISOBJECT, P_ARRAY("_data")];

		pr _edit = T_CALLM0("getEditAI");
		pr _tree = T_CALLM0("getTreeView");

		_data params DEBUG_DATA_PARAMS;

		
		// Set variables ...
		T_SETV("ai", _ai);

		_edit ctrlSetText _ai;

		pr _id = 0;
		#define _INC _id = _id + 1;

		// AI object and its variables
		_tree tvSetText [[_id], format ["AI: %1", _ai]];
		pr _count = _tree tvCount [_id];		// Clear prev variables
		for "_j" from 0 to (_count - 1) do { _tree tvDelete [_id, 0]; };
		{	// Add new variables
			_x params ["_varName", "_varValue"]; 
			_tree tvAdd [[_id], format ["%1: %2", _varName, _varValue]];
		} forEach _extraAIVariables;
		_INC
		

		// World state
		_tree tvSetText [[_id], "World State: ..."];
		if (! (_agentClass in [/*"Unit", "Civilian"*/])) then {				// Units have no world state currently
			pr _wsNames = switch (_aiClass) do {		// Names of world state properties
				case "AIUnitInfantry";
				case "AIUnitCivilian": {WSP_UNIT_HUMAN_NAMES};
				case "AIGroup": {WSP_GROUP_NAMES};
				case "AIGarrison": {WSP_GARRISON_NAMES};
				case "AIGarrisonAir": {WSP_GARRISON_NAMES};
				default {["error", "error", "error", "error"]};
			};
			//diag_log format ["World state names: %1, _agentClass: %2", _wsNames, _agentClass];
			// Clear previous data first
			pr _count = _tree tvCount [_id];
			for "_j" from 0 to (_count - 1) do {
				_tree tvDelete [_id, 0];
			};
			// Fill world state properties
			_worldState params ["_props"];
			for "_i" from 0 to ((count _props) - 1) do {
				
				pr _valueStr = "";
				if (isNil {_props#_i}) then {
					_valueStr = "<does not exist>";
				} else {
					_valueStr = str (_props#_i);
				};
				pr _text = format ["%1 %2: %3", _i, _wsNames#_i, _valueStr];
				_tree tvAdd [[_id], _text];
			};
		};
		_INC



		// Goal
		_tree tvSetText [[_id], format ["Goal: %1", _goal]]; _INC
		
		// Goal parameters
		tree tvSetText [[_id], format ["Goal parameters: %1", _goalParameters]];
		// Clear previous goal parameters first
		pr _prevParametersCount = _tree tvCount [_id];
		for "_j" from 0 to (_prevParametersCount-1) do {
			_tree tvDelete [_id, 0]; // Deletes first row
		};
		{	// Add new parameters
			_tree tvAdd [[_id], str _x];
		} forEach _goalParameters;
		_INC

		// Action
		_tree tvSetText [[_id], format ["Action: %1", _action]]; _INC
		_tree tvSetText [[_id], format ["Action Class: %1", _actionClass]]; _INC

		// Subaction and its variables
		_tree tvSetText [[_id], format ["Subaction: %1", _subaction]];
		pr _count = _tree tvCount [_id];
		for "_j" from 0 to (_count - 1) do { _tree tvDelete [_id, 0]; };
		{
			_x params ["_varName", "_varValue"]; 
			_tree tvAdd [[_id], format ["%1: %2", _varName, _varValue]];
		} forEach _extraSubactionVariables;
		_INC

		_tree tvSetText [[_id], format ["Subaction Class: %1", _subactionClass]]; _INC
		pr _stateText = if (_subactionState == -1) then {""} else {ACTION_STATE_TEXT_ARRAY select _subactionState};
		_tree tvSetText [[_id], format ["Subaction State: %1", _stateText]]; _INC

	ENDMETHOD;

	public METHOD(resetTreeView)
		params [P_THISOBJECT];
		pr _tree = T_CALLM0("getTreeView");
		tvClear _tree;
		_tree tvAdd [[], "AI:"];
		_tree tvAdd [[], "World State:"];
		_tree tvAdd [[], "Goal:"];
		_tree tvAdd [[], "Goal Parameters:"];
		_tree tvAdd [[], "Action:"];
		_tree tvAdd [[], "Action Class:"];
		_tree tvAdd [[], "Subaction:"];
		_tree tvAdd [[], "Subaction Class:"];
		_tree tvAdd [[], "Subaction State:"];
	ENDMETHOD;

ENDCLASS;

// Initialize static variables
if (isNil {GETSV("AIDebugUI", "initialized")}) then {
	SETSV("AIDebugUI", "initialized", false);
	SETSV("AIDEbugUI", "instance", NULL_OBJECT);
};