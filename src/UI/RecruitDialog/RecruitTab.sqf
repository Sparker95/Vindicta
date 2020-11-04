#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"
FIX_LINE_NUMBERS()

#define pr private

#define __CLASS_NAME "RecruitTab"

#define WEAPON_PRIMARY_IDX 0
#define WEAPON_SECONDARY_IDX 1
#define HELMET_IDX 2
#define VEST_IDX 3
#define GEAR_DESC ["Primary Weapon", "Secondary Weapon", "Headgear", "Vest"]
#define GEAR_LISTBOXES ["TAB_RECRUIT_LISTBOX_PRIMARY", "TAB_RECRUIT_LISTBOX_SECONDARY", "TAB_RECRUIT_LISTBOX_HELMET", "TAB_RECRUIT_LISTBOX_VEST"]
#define NUM_GEAR_CATS 4
#define GEAR_REQUIRED [true, true, false, false]
#define GEAR_FILTERED [true, true, false, false]
#define GEAR_SORTBY [vin_fnc_sortPrimary, vin_fnc_sortSecondary, vin_fnc_sortHeadgear, vin_fnc_sortVest]

vin_fnc_sortPrimary = { _x#0 };
vin_fnc_sortSecondary = { _x#0 };
vin_fnc_sortHeadgear = {
	10 * getNumber (configfile >> "CfgWeapons" >> _x#0 >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Head" >> "armor") + 
	getNumber (configfile >> "CfgWeapons" >> _x#0 >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Face" >> "armor")
};
vin_fnc_sortVest = {
	getNumber (configfile >> "CfgWeapons" >> _x#0 >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor")
};

#define OOP_CLASS_NAME RecruitTab
CLASS("RecruitTab", "DialogTabBase")

	VARIABLE("arsenalUnits");

	VARIABLE("available");

	VARIABLE("lastSelectedRecruit");
	VARIABLE("selectionHistory");

	METHOD(new)
		params [P_THISOBJECT];

		SETSV(__CLASS_NAME, "instance", _thisObject);

		pr _array = [];
		_array resize NUM_GEAR_CATS;
		pr _gearArray = [];
		_gearArray resize T_INF_SIZE;
		_gearArray = _gearArray apply { [] };
		{
			_array set [_forEachIndex, +_gearArray];
		} forEach _array;
		T_SETV("available", _array);

		T_SETV("arsenalUnits", []);

		T_SETV("lastSelectedRecruit", -1);
		pr _selectionHistory = [];
		_selectionHistory resize NUM_GEAR_CATS;
		_selectionHistory = _selectionHistory apply { [] };
		T_SETV("selectionHistory", _selectionHistory);

		// Create controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["RecruitTab", -1];
		T_CALLM1("setControl", _group);

		// Set text...
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_STATIC_N_RECRUITS");
		_ctrl ctrlSetText localize "STR_RD_COUNT";
		// Disable the button
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_BUTTON_RECRUIT");
		_ctrl ctrlEnable false;

		// Add event handlers
		T_CALLM3("controlAddEventHandler", "TAB_RECRUIT_LISTBOX", "LBSelChanged", "onListboxSelChanged");
		T_CALLM3("controlAddEventHandler", "TAB_RECRUIT_BUTTON_RECRUIT", "buttonClick", "onButtonRecruit");

		// Send request to server to return data to us
		pr _dialogObj = T_CALLM0("getDialogObject");
		pr _loc = GETV(_dialogObj, "location");
		pr _args = [clientOwner, _loc, playerSide];
		CALLM2(gGarrisonServer, "postMethodAsync", "clientRequestRecruitGearAtLocation", _args);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", nil);
	ENDMETHOD;

	public event METHOD(onListboxSelChanged)
		params [P_THISOBJECT];

		pr _lnbMain = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX");
		T_CALLM1("_recruitSelectionChanged", lnbCurSelRow _lnbMain);
	ENDMETHOD;

	// Update listboxes with available gear
	METHOD(_recruitSelectionChanged)
		params [P_THISOBJECT, P_NUMBER("_id")];

		OOP_INFO_1("LISTBOX SEL CHANGED: %1", _id);

		pr _subcatid = if (_id == -1) then {
			-1
		} else {
			pr _lnbMain = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX");
			_lnbMain lnbValue [_id, 0]
		};
		OOP_INFO_1("  subcatid: %1", _subcatid);
		// Save it so we can restore the selection in the listbox next time we update it
		T_SETV("lastSelectedRecruit", _subcatid);
		T_CALLM1("_populateLists", _subcatid);
	ENDMETHOD;
	
	METHOD(_populateLists)
		params [P_THISOBJECT, P_NUMBER("_subcatid")];
		pr _selHistories = T_GETV("selectionHistory");
		pr _available = T_GETV("available");
		{
			pr _ctrl = T_CALLM1("findControl", _x);
			pr _items = if(_subcatid == -1) then {
				[]
			} else {
				[_available#_forEachIndex#_subcatid, GEAR_SORTBY#_forEachIndex, DESCENDING] call vin_fnc_sortBy;
			};
			pr _allowNone = if(_subcatid == -1) then { false } else { !(GEAR_REQUIRED#_forEachIndex) };
			pr _selHistory = _selHistories#_forEachIndex;
			CALLSM4("RecruitTab", "_populateList", _ctrl, _items, _selHistory, _allowNone);
		} forEach GEAR_LISTBOXES;
	ENDMETHOD;
	
	
	// Populate a list control with items, selecting the one most recently selected based on history
	STATIC_METHOD(_populateList)
		params [P_THISCLASS, P_CONTROL("_ctrl"), P_ARRAY("_items"), P_ARRAY("_selectionHistory"), P_BOOL("_allowNone")];

		// Update history
		private _selectedRow = lnbCurSelRow _ctrl;
		if (_selectedRow != -1) then {
			private _selectedItem = _ctrl lnbData [_selectedRow, 0];
			_selectedGear set [_forEachIndex, _selectedItem];
			// Delete any existing entry that is the same, to keep history a set of unique items
			_selectionHistory deleteAt (_selectionHistory find _selectedItem);
			_selectionHistory pushBack _selectedItem;
			if(count _selectionHistory > 20) then {
				_selectionHistory deleteAt 0;
			};
		};

		private _bestHistoryIdx = -1;
		private _bestIdx = 0;
		lnbClear _ctrl;
		private _itemsAndNames = _items apply {
			private _countStr = if(_x#1 == -1) then { "-" } else { str (_x#1) };
			[_x#0, _countStr, getText (configfile >> "CfgWeapons" >> _x#0 >> "displayName") ]
		};
		if(_allowNone) then {
			_itemsAndNames = [["", "", "(None)"]] + _itemsAndNames;
		};
		{
			_x params ["_class", "_countStr", "_name"];
			private _index = _ctrl lnbAddRow [_name, _countStr];
			//_ctrl lnbSetColor [[_index, 1], [1, 0.682, 0, 1]];
			_ctrl lnbSetData [[_index, 0], _class];
			private _historyIdx = _selectionHistory find _class;
			if(_historyIdx > _bestHistoryIdx) then {
				_bestHistoryIdx = _historyIdx;
				_bestIdx = _index;
			};
		} forEach _itemsAndNames;
		_ctrl lnbSetCurSelRow _bestIdx;
	ENDMETHOD;

	public event METHOD(onButtonRecruit)
		params [P_THISOBJECT];
		
		OOP_INFO_0("ON BUTTON RECRUIT");

		pr _dialog = T_CALLM0("getDialogObject");

		// Get selected loadout
		pr _lnbMain = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX");

		// Bail if nothing is selected
		pr _id = lnbCurSelRow _lnbMain;
		if (_id == -1) exitWith {
			CALLM1(_dialog, "setHintText", localize "STR_NEED_LOADOUT");
		};

		pr _subcatid = _lnbMain lnbValue [_id, 0];

		pr _selHistories = T_GETV("selectionHistory");
		pr _selectedGear = [];
		{
			pr _ctrl = T_CALLM1("findControl", _x);
			pr _selHistory = _selHistories#_forEachIndex;
			pr _selectedRow = lnbCurSelRow _ctrl;
			if (_selectedRow != -1) then {
				pr _selectedItem = _ctrl lnbData [_selectedRow, 0];
				_selectedGear set [_forEachIndex, _selectedItem];
				_selHistory pushBack _selectedItem;
				if(count _selHistory > 20) then {
					_selHistory deleteAt 0;
				};
			} else {
				_selectedGear set [_forEachIndex, ""];
			};
		} forEach GEAR_LISTBOXES;

		// Find the arsenal unit from which we will be taking the gear
		pr _arsenalUnits = T_GETV("arsenalUnits");
		pr _index = _arsenalUnits findIf {_x#0 == _subcatid};
		pr _arsenalUnit = NULL_OBJECT;
		if (_index != -1) then {_arsenalUnit = _arsenalUnits#_index#1};

		pr _dialogObj = T_CALLM0("getDialogObject");
		pr _loc = GETV(_dialogObj, "location");
		//pr _weapons = [_weaponPrimary, _weaponSecondary];
		pr _args = [clientOwner, _loc, playerSide, _subcatid, _selectedGear, _arsenalUnit];
		OOP_INFO_1("ON BUTTON RECRUIT: sending data to server: %1", _args);
		CALLM2(gGarrisonServer, "postMethodAsync", "recruitUnitAtLocation", _args);

		CALLM1(_dialogObj, "setHintText", localize "STR_RECRUITING");

		// Disable the button
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_BUTTON_RECRUIT");
		_ctrl ctrlEnable false;
	ENDMETHOD;

	METHOD(_receiveData)
		params [P_THISOBJECT, P_ARRAY("_unitsAndGear"), P_ARRAY("_validTemplates"), P_NUMBER("_nRecruits")];

		// Reset the arrays with gear
		pr _available = [];
		_available resize NUM_GEAR_CATS;
		pr _gearArray = [];
		_gearArray resize T_INF_SIZE;
		_gearArray = _gearArray apply { [] };
		{
			_available set [_forEachIndex, +_gearArray];
		} forEach _available;
		T_SETV("available", _available);

		// Set text...
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_STATIC_N_RECRUITS");
		_ctrl ctrlSetText (format [localize "STR_RECRUITS_AVAILABLE", _nRecruits]);
		// Enable the button
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_BUTTON_RECRUIT");
		_ctrl ctrlEnable true;

		// We must use only templates valid both here and at the server
		// Because we are going to check available weapons in the local templates
		pr _templates = _validTemplates arrayIntersect (call t_fnc_getAllValidTemplateNames);
		_templates = _templates - ["tPOLICE"]; // We don't want to arm people with police guns

		// Combine all gear data from all the available templates
		// todo improve this, it must be done only at startup
		pr _subcatAllowedGear = [];
		_subcatAllowedGear resize T_INF_SIZE;
		pr _subcatAllowedGearEntry = [];
		_subcatAllowedGearEntry resize NUM_GEAR_CATS;
		_subcatAllowedGearEntry = _subcatAllowedGearEntry apply { [] };
		{
			_subcatAllowedGear set [_forEachIndex, +_subcatAllowedGearEntry];
		} forEach _subcatAllowedGear;

		{
			pr _t = [_x] call t_fnc_getTemplate;
			pr _gearThisTemplate = _t#T_LOADOUT_GEAR;
			{
				pr _subCatID = _forEachIndex;
				pr _loadoutThisUnit = _x;
				{
					(_subcatAllowedGear#_subCatID#_forEachIndex) append _x;
				} forEach _loadoutThisUnit;
			} forEach _gearThisTemplate;
		} forEach _templates;

		// _unitsAndGear = _unitsAndGear apply {
		// 	_x params ["_arsenalUnit", "_arsenalGear"];
		// 	// Gear is returned with class and count but we only care about class, so mutate the array to remove count
		// 	[_arsenalUnit, _arsenalGear apply { _x apply { _x#0 } }]
		// };
		// Make a list of unit types for soldiers for which we have weapons
		pr _subcatsAvailable = []; // Array of subcat IDs of available soldiers
		pr _arsenalUnits = [];
		// Exclude the generic unit so start from 1
		for "_subcatID" from 1 to (T_INF_engineer-1) do {
			// Search arsenals of all the provided cargo crates
			{
				pr _hasRequiredGear = true;
				_x params ["_arsenalUnit", "_arsenalGear"];
				{
					pr _arsenalItems = _x;
					pr _gearIndex = _forEachIndex;
					// Filter the arsenal items by the subcat allowed items
					pr _allowedItems = _subcatAllowedGear#_subcatID#_gearIndex;
					pr _gearItemFiltered = if(GEAR_FILTERED#_gearIndex) then {
						_arsenalItems select { _allowedItems find _x#0 != NOT_FOUND }
						// arrayIntersect _allowedItems
					} else {
						_arsenalItems
					};
					// Finally we add the filtered items to the available list
					_available#_gearIndex#_subcatID append _gearItemFiltered;
					// If this gear class is required, but not fulfilled then the subcat can't be recruited
					if(GEAR_REQUIRED#_gearIndex && { count _gearItemFiltered == 0 } && { count _allowedItems != 0 }) then {
						_hasRequiredGear = false;
					};
				} forEach _arsenalGear;

				if (_hasRequiredGear) then {
					_subcatsAvailable pushBack _subcatID;
					_arsenalUnits pushBack [_subcatID, _arsenalUnit];
				};
			} forEach _unitsAndGear;
		};
		T_SETV("arsenalUnits", _arsenalUnits);

		// Fill the listbox
		pr _lastSelectedRecruit = T_GETV("lastSelectedRecruit");
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX");
		lnbClear _ctrl;
		pr _selectedIdx = -1;
		{
			pr _subcatID = _x;
			_ctrl lnbAddRow [localize (T_NAMES select T_INF select _subcatID)];
			_ctrl lnbSetValue [[_forEachIndex, 0], _subcatID];
			if(_subcatID == _lastSelectedRecruit) then {
				_selectedIdx = _forEachIndex;
			};
		} forEach _subcatsAvailable;
		_ctrl lnbSetCurSelRow _selectedIdx;

		T_CALLM1("_recruitSelectionChanged", _selectedIdx);
	ENDMETHOD;

	public STATIC_METHOD(receiveData)
		params [P_THISCLASS, P_ARRAY("_unitsAndGear"), P_ARRAY("_validTemplates"), P_NUMBER("_nRecruits")];

		OOP_INFO_0("RECEIVE WEAPON DATA:");
		{
			_x params ["_arsenalUnit", "_arsenalGear"];
			OOP_INFO_1("  Unit: %1", _arsenalUnit);
			{
				OOP_INFO_2("  %1: %2", GEAR_DESC#_forEachIndex, _x);
			} forEach _arsenalGear;
		} forEach _unitsAndGear;

		OOP_INFO_1("  Valid templates: %1", _validTemplates);

		pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
		if (!IS_NULL_OBJECT(_instance)) then {
			CALLM3(_instance, "_receiveData", _unitsAndGear, _validTemplates, _nRecruits);
		};
	ENDMETHOD;

ENDCLASS;