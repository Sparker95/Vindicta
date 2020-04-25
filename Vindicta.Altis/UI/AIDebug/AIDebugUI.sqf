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

CLASS("AIDebugUI", "")

	STATIC_VARIABLE("initialized");
	STATIC_VARIABLE("instance");

	VARIABLE("drawEH");

	VARIABLE("panelGarrison");
	VARIABLE("panelGroup");
	VARIABLE("panelUnit");

	METHOD("new") {
		params [P_THISOBJECT];

		OOP_INFO_0("NEW");

		// Add event handler
		pr _id = addMissionEventHandler ["Draw3D", {
			pr _inst = GETSV("AIDebugUI", "instance");
			CALLM0(_inst, "onDraw");
		}];
		T_SETV("drawEH", _id);

		// Create panels
		pr _panelGarrison = NEW("AIDebugPanel", []);
		pr _panelGroup = NEW("AIDebugPanel", []);
		pr _panelUnit = NEW("AIDebugPanel", []);
		T_SETV("panelGarrison", _panelGarrison);
		T_SETV("panelGroup", _panelGroup);
		T_SETV("panelUnit", _panelUnit);

		// Set panel positions
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

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		SETSV("AIDebugUI", "instance", NULL_OBJECT);

		// Delete Eevent Handler
		removeMissionEventHandler ["Draw3D", T_GETV("drawEH")];

		// Delete panels
		DELETE(T_GETV("panelGarrison"));
		DELETE(T_GETV("panelGroup"));
		DELETE(T_GETV("panelUnit"));
	} ENDMETHOD;

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

	// Called from "Draw3D" event handler
	METHOD("onDraw") {
		params [P_THISOBJECT];
	} ENDMETHOD;



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

ENDCLASS;

// Initialize static variables
if (isNil {GETSV("AIDebugUI", "initialized")}) then {
	SETSV("AIDebugUI", "initialized", false);
	SETSV("AIDEbugUI", "instance", NULL_OBJECT);
};