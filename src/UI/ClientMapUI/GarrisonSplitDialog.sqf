#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\common.h"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\..\AI\Commander\CmdrAction\CmdrActionStates.hpp"
#include "..\Resources\MapUI\MapUI_Macros.h"
#include "ClientMapUI_Macros.h"
#include "..\..\Location\Location.hpp"
#include "..\Resources\UIProfileColors.h"
#include "..\..\PlayerDatabase\PlayerDatabase.hpp"

FIX_LINE_NUMBERS()

/*                                                                                                                                       
 ad88888ba   88888888ba   88           88  888888888888     88888888ba,    88         db         88           ,ad8888ba,      ,ad8888ba,   
d8"     "8b  88      "8b  88           88       88          88      `"8b   88        d88b        88          d8"'    `"8b    d8"'    `"8b  
Y8,          88      ,8P  88           88       88          88        `8b  88       d8'`8b       88         d8'        `8b  d8'            
`Y8aaaaa,    88aaaaaa8P'  88           88       88          88         88  88      d8'  `8b      88         88          88  88             
  `"""""8b,  88""""""'    88           88       88          88         88  88     d8YaaaaY8b     88         88          88  88      88888  
        `8b  88           88           88       88          88         8P  88    d8""""""""8b    88         Y8,        ,8P  Y8,        88  
Y8a     a8P  88           88           88       88          88      .a8P   88   d8'        `8b   88          Y8a.    .a8P    Y8a.    .a88  
 "Y88888P"   88           88888888888  88       88          88888888Y"'    88  d8'          `8b  88888888888  `"Y8888Y"'      `"Y88888P"   
http://patorjk.com/software/taag/#p=display&f=Univers&t=SPLIT%20DIALOG
This class, when the object is created, creates the dialog for splitting the garrison

Author: Sparker 30 August 2019
*/

#define pr private

#define LEFT_COL 0
#define RIGHT_COL 1

#define OOP_CLASS_NAME GarrisonSplitDialog
CLASS("GarrisonSplitDialog", "")

	STATIC_VARIABLE("instance");

	// The garrison record for which this dialog is open
	VARIABLE("garRecord");

	// Composition on the left and on the right of the dialog (left and right listboxes)
	VARIABLE("compLeft");
	VARIABLE("compRight");
	// Arrays where each element is [_catID, _subcatID] of a non-empty subcategory
	// It's used to map listbox row index to [_catID, _subcatID]
	VARIABLE("IDsCompLeft");
	VARIABLE("IDsCompRight");

	// Bool, we set it to true when we are doing lnbSetCurSel on a listbox, because it does the same in its EH callback, and the game might freeze otherwise
	VARIABLE("setCurSelInProgress");

	VARIABLE("lastSetRowLeft");
	VARIABLE("lastSetRowRight");
	VARIABLE("dblClickedLeft");
	VARIABLE("dblClickedRight");

	// Current state of the dialog, default 0, it changes as we change buttons
	VARIABLE("state");


	// Static methods for creating/destroying the dialog
	
	// Create a new unique instance of this dialog
	// There can be only one instance of this dialog
	public STATIC_METHOD(newInstance)
		params [P_THISCLASS, P_OOP_OBJECT("_garRecord")];
		pr _instance = GETSV(_thisClass, "instance");
		if (IS_NULL_OBJECT(_instance)) then {
			_instance = NEW(_thisClass, [_garRecord]);
			SETSV(_thisClass, "instance", _instance);
			// Return object instance
			_instance
		} else {
			// Produce an error?
			
			// Return a ref to the existing object anyway
			_instance
		};
	ENDMETHOD;

	public STATIC_METHOD(deleteInstance)
		params [P_THISCLASS];
		pr _instance = GETSV(_thisClass, "instance");
		if (IS_NULL_OBJECT(_instance)) then {
			// No need to delete anything
		} else {
			DELETE(_instance);
			SETSV(_thisClass, "instance", "");
		};
	ENDMETHOD;

	public STATIC_METHOD(getInstance)
		params [P_THISCLASS];
		GETSV(_thisClass, "instance");
	ENDMETHOD;


	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		OOP_INFO_1("NEW: %1", _garRecord);

		T_SETV("garRecord", _garRecord);
		// Set compositions we are working with
		T_SETV("compLeft", +GETV(T_GETV("garRecord"), "composition")); // Make a deep copy! We don't want to mess this up.
		pr _compRight = [];
		{
			pr _tempArray = [];
			_tempArray resize _x;
			_compRight pushBack (_tempArray apply {[]});
		} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE];
		T_SETV("compRight", _compRight);
		T_SETV("IDsCompLeft", []);
		T_SETV("IDsCompRight", []);
		T_SETV("setCurSelInProgress", false);
		T_SETV("dblClickedLeft", false);
		T_SETV("dblClickedRight", false);
		T_SETV("lastSetRowLeft", -1);
		T_SETV("lastSetRowRight", -1);

		T_SETV("state", 0);

		// Create the dialog
		pr _display = (finddisplay 12) createDisplay "GSPLIT_DIALOG";
		_display displayAddEventHandler ["Unload", {
			_thisClass = "GarrisonSplitDialog";
			OOP_INFO_0("UNLOAD EVENT HANDLER");
			CALLSM0(_thisClass, "deleteInstance");
		}];

		// Add event handlers
		// Close & cancel
		(_display displayCtrl IDC_GSPLIT_BUTTON_CANCEL) ctrlAddEventHandler ["ButtonClick", {
			//params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: CANCEL BUTTON CLICK");
			T_CALLM0("onButtonClose");
		}];
		(_display displayCtrl IDC_GSPLIT_BUTTON_CLOSE) ctrlAddEventHandler ["ButtonClick", {
			//params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: CLOSE BUTTON CLICK");
			T_CALLM0("onButtonClose");
		}];
		// Split button
		(_display displayCtrl IDC_GSPLIT_BUTTON_SPLIT) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: SPLIT BUTTON CLICK");
			T_CALLM0("onButtonSplit");
		}];
		// Move left/right
		(_display displayCtrl IDC_GSPLIT_BUTTON_MOVE_LEFT) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: MOVE LEFT BUTTON CLICK");
			T_CALLM0("onButtonMoveLeft");
		}];
		(_display displayCtrl IDC_GSPLIT_BUTTON_MOVE_RIGHT) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: MOVE RIGHT BUTTON CLICK");
			T_CALLM0("onButtonMoveRight");
		}];
		// Move all left/right
		(_display displayCtrl IDC_GSPLIT_BUTTON_MOVE_LEFT_ALL) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: MOVE LEFT ALL BUTTON CLICK");
			T_CALLM0("onButtonMoveLeftAll");
		}];
		(_display displayCtrl IDC_GSPLIT_BUTTON_MOVE_RIGHT_ALL) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: MOVE RIGHT ALL BUTTON CLICK");
			T_CALLM0("onButtonMoveRightAll");
		}];
		// Listbox
		(_display displayCtrl IDC_GSPLIT_LB_LEFT) ctrlAddEventHandler ["LBDblClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: LEFT LB DOUBLE CLICK");
			T_CALLM0("onButtonMoveRight");
			T_SETV("dblClickedLeft", true);
		}];
		(_display displayCtrl IDC_GSPLIT_LB_RIGHT) ctrlAddEventHandler ["LBDblClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: RIGHT LB DOUBLE CLICK");
			T_CALLM0("onButtonMoveLeft");
			T_SETV("dblClickedRight", true);
		}];
		(_display displayCtrl IDC_GSPLIT_LB_LEFT) ctrlAddEventHandler ["LBSelChanged", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: LEFT LB SEL CHANGED");
			if (!T_GETV("setCurSelInProgress")) then {
				/*if(T_GETV("dblClickedLeft")) then {
					T_SETV("dblClickedLeft", false); OOP_INFO_0("  IGNORED: PREV DBL CLICK");
					T_CALLM2("setListboxRow", 0, T_GETV("lastSetRowLeft"));
				} else {*/
					T_CALLM1("syncListboxRows", RIGHT_COL);
				//};
			} else {
				OOP_INFO_0("  IGNORED: IN PROGRESS");
			};
		}];
		(_display displayCtrl IDC_GSPLIT_LB_RIGHT) ctrlAddEventHandler ["LBSelChanged", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			OOP_INFO_0("EH: RIGHT LB SEL CHANGED");
			if (!T_GETV("setCurSelInProgress")) then {
				T_CALLM1("syncListboxRows", LEFT_COL);
			};
			if (!T_GETV("setCurSelInProgress")) then {
				/*if(T_GETV("dblClickedRight")) then {
					T_SETV("dblClickedRight", false); OOP_INFO_0("  IGNORED: PREV DBL CLICK");
					T_CALLM2("setListboxRow", 1, T_GETV("lastSetRowRight"));
				} else {*/
					T_CALLM1("syncListboxRows", LEFT_COL);
				//};
			} else {
				OOP_INFO_0("  IGNORED: IN PROGRESS");
			};
		}];
		// Listbox buttons
		(_display displayCtrl IDC_GSPLIT_LB_LEFT_LEFT) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			T_CALLM0("onButtonMoveLeft");
		}];
		(_display displayCtrl IDC_GSPLIT_LB_LEFT_RIGHT) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			T_CALLM0("onButtonMoveRight");
		}];
		(_display displayCtrl IDC_GSPLIT_LB_RIGHT_LEFT) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			T_CALLM0("onButtonMoveLeft");
		}];
		(_display displayCtrl IDC_GSPLIT_LB_RIGHT_RIGHT) ctrlAddEventHandler ["ButtonClick", {
			_thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");
			T_CALLM0("onButtonMoveRight");
		}];

		T_CALLM1("updateListboxAndText", LEFT_COL);
		T_CALLM1("updateListboxAndText", RIGHT_COL);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		// Delete the dialog
		(finDdisplay IDD_GSPLIT_DIALOG) closeDisplay 1;

		// Notify the client map UI??
		CALLM0(gClientMapUI, "onGarrisonSplitDialogDeleted");
	ENDMETHOD;

	// = = = = = = = = Button callbacks = = = = = = = = = =

	// Close or cancel button was pressed
	public event METHOD(onButtonClose)
		params [P_THISOBJECT];
		OOP_INFO_0("ON BUTTON CLOSE");
		CALLSM0("GarrisonSplitDialog", "deleteInstance");
	ENDMETHOD;

	public event METHOD(onButtonMoveLeft)
		params [P_THISOBJECT];
		pr _unitData = T_CALLM1("moveUnitsLeft", false);
		_unitData params ["_catID", "_subcatID"];
		if (_catID == -1) exitWith {}; // Bail if we were not able to move anything
		// Update the listboxes
		T_CALLM1("updateListboxAndText", LEFT_COL);
		T_CALLM1("updateListboxAndText", RIGHT_COL);
		T_CALLM3("syncListboxRows", RIGHT_COL, _catID, _subcatID);
		T_CALLM3("syncListboxRows", LEFT_COL, _catID, _subcatID);
	ENDMETHOD;

	public event METHOD(onButtonMoveRight)
		params [P_THISOBJECT];
		pr _unitData = T_CALLM1("moveUnitsRight", false);
		_unitData params ["_catID", "_subcatID"];
		if (_catID == -1) exitWith {}; // Bail if we were not able to move anything
		// Update the listboxes
		T_CALLM1("updateListboxAndText", LEFT_COL);
		T_CALLM1("updateListboxAndText", RIGHT_COL);
		T_CALLM3("syncListboxRows", LEFT_COL, _catID, _subcatID);
		T_CALLM3("syncListboxRows", RIGHT_COL, _catID, _subcatID);
	ENDMETHOD;

	public event METHOD(onButtonMoveLeftAll)
		params [P_THISOBJECT];
		pr _unitData = T_CALLM1("moveUnitsLeft", true);
		_unitData params ["_catID", "_subcatID"];
		if (_catID == -1) exitWith {}; // Bail if we were not able to move anything
		// Update the listboxes
		T_CALLM1("updateListboxAndText", LEFT_COL);
		T_CALLM1("updateListboxAndText", RIGHT_COL);
		T_CALLM3("syncListboxRows", RIGHT_COL, _catID, _subcatID);
		T_CALLM3("syncListboxRows", LEFT_COL, _catID, _subcatID);
	ENDMETHOD;

	public event METHOD(onButtonMoveRightAll)
		params [P_THISOBJECT];
		pr _unitData = T_CALLM1("moveUnitsRight", true);
		_unitData params ["_catID", "_subcatID"];
		if (_catID == -1) exitWith {}; // Bail if we were not able to move anything
		// Update the listboxes
		T_CALLM1("updateListboxAndText", LEFT_COL);
		T_CALLM1("updateListboxAndText", RIGHT_COL);
		T_CALLM3("syncListboxRows", LEFT_COL, _catID, _subcatID);
		T_CALLM3("syncListboxRows", RIGHT_COL, _catID, _subcatID);
	ENDMETHOD;

	public event METHOD(onButtonSplit)
		params [P_THISOBJECT];

		// Bail if another request is in progress
		if (T_GETV("state") != 0) exitWith {
			T_CALLM1("setHintText", "Another request is in progress!");
		};

		// Bail if nothing is selected
		pr _comp = T_GETV("compRight");
		pr _countUnitsRight = 0;
		{
			{
				_countUnitsRight = _countUnitsRight + (count _x);
			} forEach _x;
		} forEach _comp;
		if (_countUnitsRight < 1) exitWith {
			OOP_INFO_0("Nothing is selected");
			T_CALLM1("setHintText", "You must move some units to the right first!");
		};

		// Bail if garrison record is invalid
		pr _garRecord = T_GETV("garRecord");
		if (!IS_OOP_OBJECT(_garRecord)) exitWith {
			OOP_INFO_0("Selected garrison is already destroyed");
			T_CALLM1("setHintText", "The selected garrison has been destroyed!");
		};

		// Send message to the server
		OOP_INFO_2("Sending split reqest to server: %1", _garRef, _comp);
		pr _garRef = CALLM0(_garRecord, "getGarrison");
		pr _AI = CALLSM("AICommander", "getAICommander", [playerSide]);
		// Although it's on another machine, messageReceiver class will route the message for us		
		pr _args = [_garRef, _comp,  clientOwner];
		CALLM2(_AI, "postMethodAsync", "splitGarrisonFromComposition", _args);
		T_CALLM1("setHintText", "Waiting for server to respond...");
		T_SETV("state", 1);
		// Close now
		T_CALLM0("onButtonClose");
	ENDMETHOD;

	// = = = = = = = = = Other methods = = = = = = = = = = 

	METHOD(updateListboxAndText)
		params [P_THISOBJECT, P_NUMBER("_leftOrRight")];
		private ["_lnb", "_idcInf", "_idcCargo", "_IDsArray", "_comp"];
		if (_leftOrRight == RIGHT_COL) then {
			_lnb = (findDisplay IDD_GSPLIT_DIALOG) displayCtrl IDC_GSPLIT_LB_RIGHT;
			_idcInf = IDC_GSPLIT_STATIC_NEW_INF;
			_idcCargo = IDC_GSPLIT_STATIC_NEW_CARGO;
			_IDsArray = T_GETV("IDsCompRight");
			_comp = T_GETV("compRight");
		} else {
			_lnb = (findDisplay IDD_GSPLIT_DIALOG) displayCtrl IDC_GSPLIT_LB_LEFT;
			_idcInf = IDC_GSPLIT_STATIC_CURRENT_INF;
			_idcCargo = IDC_GSPLIT_STATIC_CURRENT_CARGO;
			_IDsArray = T_GETV("IDsCompLeft");
			_comp = T_GETV("compLeft");
		};

		// Update listbox
		_IDsArray resize 0;
		lnbClear _lnb;
		{
			pr _catID = _foreachindex;
			{
				pr _subcatID = _forEachIndex;
				pr _classes = _x; // Array with IDs of classes
				if (count _classes > 0) then {
					pr _name = T_NAMES#_catID#_subcatID;
					_lnb lnbAddRow [str (count _classes), _name];
					_IDsArray pushBack [_catID, _subCatID];
				};
			} forEach _x;
		} forEach _comp;

		// Update text
		pr _nInf = T_CALLM1("getInfantryCount", _comp);
		pr _nCargo = T_CALLM1("getCargoSeatCount", _comp);
		((findDisplay IDD_GSPLIT_DIALOG) displayCtrl _idcInf) ctrlSetText (format ["Infantry: %1", _nInf]);
		((findDisplay IDD_GSPLIT_DIALOG) displayCtrl _idcCargo) ctrlSetText (format ["Cargo seats: %1", _nCargo]);

		/*
		for "_i" from 0 to 40 do {
			_lnb lnbAddRow [str _i, "Uber soldier"];
		};
		*/
	ENDMETHOD;

	// Modifies the composition, moves the currently selected unit on the left LB to the right (LB isn't updated)
	// Returns [_catID, _subcatID] of the unit just moved
	METHOD(moveUnitsRight)
		params [P_THISOBJECT, P_BOOL("_moveAll")];

		OOP_INFO_0("MOVE UNIT RIGHT");

		return T_CALLM2("_moveUnitsTo", RIGHT_COL, _moveAll)
	ENDMETHOD;

	METHOD(moveUnitsLeft)
		params [P_THISOBJECT, P_BOOL("_moveAll")];

		OOP_INFO_0("MOVE UNIT LEFT");

		return T_CALLM2("_moveUnitsTo", LEFT_COL, _moveAll)
	ENDMETHOD;

	METHOD(_moveUnitsTo)
		params [P_THISOBJECT, P_NUMBER("_leftOrRight"), P_BOOL("_moveAll")];

		pr _compFrom = [T_GETV("compRight"), T_GETV("compLeft")] select _leftOrRight;
		pr _IDsFrom = [T_GETV("IDsCompRight"), T_GETV("IDsCompLeft")] select _leftOrRight;
		pr _compTo = [T_GETV("compLeft"), T_GETV("compRight")] select _leftOrRight;
		pr _listCtrlFrom = ((findDisplay IDD_GSPLIT_DIALOG) displayCtrl ([IDC_GSPLIT_LB_RIGHT, IDC_GSPLIT_LB_LEFT] select _leftOrRight));

		// Get row index
		pr _rowID = lnbCurSelRow _listCtrlFrom;

		// Bail if row is incorrect
		if (_rowID < 0 || _rowID >= count _IDsFrom) exitWith { OOP_ERROR_1("Wrong row selected: %1", _rowID); [-1, -1] };

		// Move one item
		(_IDsFrom#_rowID) params ["_catID", "_subCatID"];
		pr _classesSrc = _compFrom#_catID#_subcatID;
		pr _classesDst = _compTo#_catID#_subcatID;

		// Bail if there is nothing to select here (why???)
		if (count _classesSrc == 0) exitWith { OOP_ERROR_0("Nothing to move from this row any more"); [-1, -1] };

		pr _moveCount = [1, count _classesSrc] select _moveAll;
		while {count _classesSrc > 0 && _moveCount > 0} do {
			pr _class = _classesSrc#0;
			_classesSrc deleteAt 0;
			_classesDst pushBack _class;
			_moveCount = _moveCount - 1;
		};

		[_catID, _subCatID]
	ENDMETHOD;
	

	// Synchronizes currently selected rows
	// 0 - from left to right
	// 1 - from right to left
	METHOD(syncListboxRows)
		params [P_THISOBJECT, P_NUMBER("_leftOrRight"), ["_catID", -1, [0]], P_NUMBER("_subcatID")];

		OOP_INFO_1("SYNC LISTBOX ROWS: %1", _this);
		
		private ["_IDsSrc", "_IDsDst", "_rowSrc", "_lnbDst", "_lastRowVarName"];
		if (_leftOrRight == RIGHT_COL) then {
			// From left
			_IDsSrc = T_GETV("IDsCompLeft");
			_IDsDst = T_GETV("IDsCompRight");
			_rowSrc = lnbCurSelRow ((findDisplay IDD_GSPLIT_DIALOG) displayCtrl IDC_GSPLIT_LB_LEFT);
			OOP_INFO_0("  LEFT --> RIGHT");
		} else {
			// From right
			_IDsSrc = T_GETV("IDsCompRight");
			_IDsDst = T_GETV("IDsCompLeft");
			_rowSrc = lnbCurSelRow ((findDisplay IDD_GSPLIT_DIALOG) displayCtrl IDC_GSPLIT_LB_RIGHT);
			OOP_INFO_0("  LEFT <-- RIGHT");
		};

		pr _rowDst = if (_catID != -1) then {
			// If _catID and _subcatID are supplied, we search for [_catID, _subcatID]
			_IDsDst findIf {_x isEqualTo [_catID, _subcatID]};
		} else {
			// Otherwise we try to sync with the other listbox
			if (_rowSrc < 0 || _rowSrc >= count _IDsSrc) then {
				OOP_ERROR_1("Wrong source row selected: %1", _rowSrc);
				-1
			} else {
				_IDsDst findIf {_x isEqualTo (_IDsSrc#_rowSrc)};
			};
		};
		T_CALLM2("setListboxRow", _leftOrRight, _rowDst);
	ENDMETHOD;

	// Sets the currently selected row of a listbox
	// We call this instead of directly setting the row because it triggers a callback, and we don't want that
	METHOD(setListboxRow)
		params [P_THISOBJECT, P_NUMBER("_leftOrRight"), P_NUMBER("_row")];
		private ["_lnbDst", "_lastRowVarName"];
		if (_leftOrRight == RIGHT_COL) then {
			_lnbDst = (findDisplay IDD_GSPLIT_DIALOG) displayCtrl IDC_GSPLIT_LB_RIGHT;
			_lastRowVarName = "lastSetRowRight";
		} else {
			_lnbDst = (findDisplay IDD_GSPLIT_DIALOG) displayCtrl IDC_GSPLIT_LB_LEFT;
			_lastRowVarName = "lastSetRowLeft";
		};

		T_SETV("setCurSelInProgress", true);
		OOP_INFO_1("  LB SET CUR SEL ROW START: new row: %1", _row);
		_lnbDst lnbSetCurSelRow _row;
		OOP_INFO_0("  LB SET CUR SEL ROW END");
		T_SETV("setCurSelInProgress", false);
		T_SETV(_lastRowVarName, _row);
	ENDMETHOD;


	// Returns amount of infantry units in the composition
	METHOD(getInfantryCount)
		params [P_THISOBJECT, P_ARRAY("_comp")];

		pr _num = 0;
		{
			_num = _num + (count _x);
		} forEach _comp#T_INF;

		_num
	ENDMETHOD;

	METHOD(setHintText)
		params [P_THISOBJECT, P_STRING("_s")];
		((findDisplay IDD_GSPLIT_DIALOG) displayCtrl IDC_GSPLIT_HINTS) ctrlSetText _s;
	ENDMETHOD;

	// Returns amount of cargo seats all the vehicles in the composition have
	METHOD(getCargoSeatCount)
		params [P_THISOBJECT, P_ARRAY("_comp")];

		OOP_INFO_1("COMP: %1", _comp);
		pr _num = 0;
		pr _catID = _foreachindex;
		{
			{
				pr _subcatID = _forEachIndex;
				pr _classes = _x; // Array with IDs of classes
				//OOP_INFO_1("CLASSES: %1", _classes);
				{
					pr _classID = _x; // Each element in _classes is an ID of a class name
					pr _className = [_classID] call t_fnc_numberToClassName;
					pr _nCargo = [_className] call misc_fnc_getCargoInfantryCapacity;
					_num = _num + _nCargo;
					//OOP_INFO_3("GET CARGO SEAT COUNT: class ID: %1, class: %2, count: %3", _classID, _className, _nCargo);
				} forEach _classes;
			} forEach _x;
		} forEach [_comp#T_VEH, _comp#T_DRONE];

		_num
	ENDMETHOD;

	// Gets remotely called by the server
	public server STATIC_METHOD(sendServerResponse)
		params [P_THISCLASS, P_NUMBER("_responseCode")];

		OOP_INFO_1("SEND SERVER RESPONSE: %1", _this);

		pr _thisObject = CALLSM0("GarrisonSplitDialog", "getInstance");;

		// Check if the dialog is closed already
		// We can still notify player, even if it's closed
		if (IS_NULL_OBJECT(_thisObject)) exitWith{
			switch (_responseCode) do {
			// Garrison is destroyed
			case 11: {
				systemChat "Error: Garrison is destroyed.";
			};
			case 22: {
				// It's a success
				systemChat "Garrison was split successfully.";
			};
		};
		};

		// Bail if we didn't send anything - WTF
		if(T_GETV("state") == 0) exitWith {};

		switch (_responseCode) do {
			// Garrison is destroyed
			case 11: {
				T_CALLM1("setHintText", "Error: Garrison is destroyed.");
			};
			case 22: {
				// It's a success
				T_CALLM1("setHintText", "Garrison was split successfully.");
				systemChat "Garrison was split successfully";
				//CALLSM0("GarrisonSplitDialog", "deleteInstance"); no let's rather not auto-close it, because we might have opened another dialog already
			};
		};

	ENDMETHOD;
ENDCLASS;

if (isNil {GETSV("GarrisonSplitDialog", "instance")}) then {
	SETSV("GarrisonSplitDialog", "instance", "");
};