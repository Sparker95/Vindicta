#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG
#define OOP_ASSERT
#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define pr private

#define sv setVariable
#define gv getVariable

#define INTERVAL_GROUP_REQUEST 1
#define INTERVAL_GARRISON_REQUEST 3

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

	METHOD("new") {
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
					diag_log "Curator: Object selection changed";
					CALLM0(_instance, "update");
				}];
				_ehs pushBack ["CuratorObjectSelectionChanged", _id];

				pr _id = _curator addEventHandler ["CuratorGroupSelectionChanged", {
					//params ["_curator", "_entity"];
					pr _instance = GETSV("AIDebugUI", "instance");
					diag_log "Curator: Group selection changed";
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

	} ENDMETHOD;

	METHOD("delete") {
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
	} ENDMETHOD;

	// Base logic

	METHOD("update") {
		params [P_THISOBJECT];

		pr _selPrev = T_GETV("curatorSelected");
		pr _selNew = CuratorSelected;
		pr _units = _selNew#0;
		pr _groups = _selNew#1;
		pr _selChanged = !(_selPrev isEqualTo _selNew);
		pr _requestGroupAndUnit = false;
		T_SETV("curatorSelected", _selNew);

		// Request group and unit data if needed
		if (time - T_GETV("timeLastGroupRequest") > INTERVAL_GROUP_REQUEST || _selChanged) then {

			// Request unit AI data if only one unit is selected
			if (count _units == 1) then {
				pr _args = [clientOwner, 0, _units#0];
				OOP_INFO_1("Request unit data: %1", _units#0);
				REMOTE_EXEC_CALL_STATIC_METHOD("AI_GOAP", "requestDebugUIData", _args, 2, false);
			};

			// Request group AI data if only one group is selected
			if ((count _groups == 0 && count _units > 0) || (count _groups == 1)) then {
				pr _group = if(count _groups == 1) then {_groups#0} else {group (_units#0)}; // Selected group or group of first unit
				pr _args = [clientOwner, 1, _group];
				OOP_INFO_1("Request group data: %1", _group);
				REMOTE_EXEC_CALL_STATIC_METHOD("AI_GOAP", "requestDebugUIData", _args, 2, false);
				OOP_INFO_1("Requested group data: %1", _group);
			};
			T_SETV("timeLastGroupRequest", time);
		};

		// Request garrison data if needed
		if (time - T_GETV("timeLastGarrisonRequest") > INTERVAL_GARRISON_REQUEST || _selChanged) then {

			// We must have some unit to get its garrison data
			if (count _selGroups <= 1|| count _selUnits > 0) then {
				pr _unit = if (count _selGroups == 1) then {
					(units (_selGroups#0))#0
				} else {
					_selUnits#0
				};

				pr _args = [clientOwner, 2, _unit];
				OOP_INFO_1("Request garrison data: %1", _unit);
				REMOTE_EXEC_CALL_STATIC_METHOD("AI_GOAP", "requestDebugUIData", _args, 2, false);
			};
			

			T_SETV("timeLastGarrisonRequest", time);
		};

	} ENDMETHOD;

	// Called from "Draw3D" event handler
	METHOD("onDraw") {
		params [P_THISOBJECT];

		T_CALLM0("update");
	} ENDMETHOD;

	// Not used any more
	/*
	METHOD("onObjectSelectionChanged") {
		params [P_THISOBJECT, P_OBJECT("_object")];
		OOP_INFO_1("Object selection changed: %1", _object);
	} ENDMETHOD;

	METHOD("onGroupSelectionChanged") {
		params [P_THISOBJECT, P_GROUP("_group")];
		OOP_INFO_1("Group selection changed: %1", _group);
	} ENDMETHOD;
	*/

	// = = = Static methods to create/delete instance = = = = 

	// Static method to create this object
	STATIC_METHOD("createInstance") {
		params [P_THISCLASS];

		OOP_INFO_0("CREATE INSTANCE");

		// Bail if such object exists already
		if (!IS_NULL_OBJECT(GETSV("AIDebugUI", "instance"))) exitWith {};

		OOP_INFO_0("CALLING NEW");

		pr _ret = NEW("AIDebugUI", []);
		SETSV("AIDebugUI", "instance", _ret);
		_ret
	} ENDMETHOD;

	STATIC_METHOD("deleteInstance") {
		params [P_THISCLASS];

		OOP_INFO_0("DELETE INSTANCE");

		pr _inst = GETSV("AIDebugUI", "instance");
		
		if (!IS_NULL_OBJECT(_inst)) then {
			DELETE(_inst);
		};

	} ENDMETHOD;

	// = = = = = = = = = = = = = = = = =



	// ================ Curator open/close event handlers ==================
	STATIC_METHOD("onCuratorOpen") {
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
	} ENDMETHOD;

	STATIC_METHOD("onCuratorClose") {
		params [P_THISCLASS];
		CALLSM0("AIDebugUI", "deleteInstance");
	} ENDMETHOD;

	// ===================================================


	// Performs initialization of debug UI, must be called once when mission is loaded
	STATIC_METHOD("staticInit") {
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
	} ENDMETHOD;



	// =========================== Comms with server =====================

	METHOD("_receiveData") {
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
			if (_armaAgent isEqualType objNull && {_armaAgent in _units} && {count _units == 1}) then {
				_panel = T_GETV("panelUnit");
			};
			if (_armaAgent isEqualType grpNull && {count _groups <= 1}) then {
				_panel = T_GETV("panelGroup");
			};
			if (_armaAgent isEqualType "") then {
				_panel = T_GETV("panelGarrison");
			};
			if (!IS_NULL_OBJECT(_panel)) then {
				CALLM1(_panel, "updateData", _data);
			};
		};
	} ENDMETHOD;

	// Remote-executed on client from server
	STATIC_METHOD("receiveData") {
		params [P_THISCLASS, P_ARRAY("_data")];

		OOP_INFO_1("receiveData: %1", _data);

		pr _instance = GETSV(_thisClass, "instance");

		if (!IS_NULL_OBJECT(_instance)) then {
			CALLM1(_instance, "_receiveData", _data);
		};
	} ENDMETHOD;

ENDCLASS;

// Class for one tab
CLASS("AIDebugPanel", "")

	METHOD("new") {
		params [P_THISOBJECT];

		pr _d = findDisplay 312;
		pr _ctrl = _d ctrlCreate ["AI_DEBUG_GROUP", -1];
		
		uiNamespace sv [_thisObject + "group", _ctrl];
		uiNamespace sv [_thisObject + "tree", uiNamespace getVariable "vin_aidbg_tree"];
		uiNamespace sv [_thisObject + "editAI", uiNamespace getVariable "vin_aidbg_edit_ai_ref"];
		uiNamespace sv [_thisObject + "buttonHalt", uiNamespace getVariable "vin_aidbg_button_halt"];
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		pr _ctrl = T_CALLM0("getGroupPanel");
		ctrlDelete _ctrl; // Should also delete all child controls

		uiNamespace sv [_thisObject + "group", nil];
		uiNamespace sv [_thisObject + "tree", nil];
		uiNamespace sv [_thisObject + "editAI", nil];
		uiNamespace sv [_thisObject + "buttonHalt", nil];
	} ENDMETHOD;

	METHOD("getGroupPanel") {
		params [P_THISOBJECT];
		uiNamespace gv (_thisObject + "group")
	} ENDMETHOD;

	METHOD("getTreeView") {
		params [P_THISOBJECT];
		uiNamespace gv (_thisObject + "tree")
	} ENDMETHOD;

	METHOD("getEditAI") {
		params [P_THISOBJECT];
		uiNamespace gv (_thisObject + "editAI")
	} ENDMETHOD;

	METHOD("getButtonHalt") {
		params [P_THISOBJECT];
		uiNamespace gv (_thisObject + "buttonHalt")
	} ENDMETHOD;

	// Clears all UI fields
	METHOD("clearData") {
		params [P_THISOBJECT];
		
		pr _edit = T_CALLM0("getEditAI");
		_edit ctrlSetText "";

		pr _tree = T_CALLM0("getTreeView");
		tvClear _tree;

	} ENDMETHOD;

	// Updates data of this panel from data array (AIDebugUI.receiveData format)
	METHOD("updateData") {
		params [P_THISOBJECT, P_ARRAY("_data")];

		pr _edit = T_CALLM0("getEditAI");
		pr _tree = T_CALLM0("getTreeView");
		tvClear _tree;

		_data params [
			"_armaAgent",
			"_agent",
			"_agentClass",
			"_ai",
			"_goal",
			"_goalParameters",
			"_action",
			"_actionClass",
			"_subaction",
			"_subactionClass",
			"_actionState"
		];

		_edit ctrlSetText _ai;

		_tree tvAdd [[], format ["Goal: %1", _goal]];
		_tree tvAdd [[], format ["Goal parameters: %1", _goalParameters]];

	} ENDMETHOD;

ENDCLASS;

// Initialize static variables
if (isNil {GETSV("AIDebugUI", "initialized")}) then {
	SETSV("AIDebugUI", "initialized", false);
	SETSV("AIDEbugUI", "instance", NULL_OBJECT);
};