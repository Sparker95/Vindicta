#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define pr private

#define __CLASS_NAME "RecruitTab"

CLASS(__CLASS_NAME, "DialogTabBase")

	VARIABLE("arsenalUnits");

	// Array with available primary and secondary weapons for each subcategory
	VARIABLE("availableWeaponsPrimary");
	VARIABLE("availableWeaponsSecondary");

	METHOD("new") {
		params [P_THISOBJECT];

		SETSV(__CLASS_NAME, "instance", _thisObject);

		pr _array = []; _array resize T_INF_SIZE;
		_array = _array apply {[]};
		T_SETV("availableWeaponsPrimary", +_array);
		T_SETV("availableWeaponsSecondary", +_array);
		T_SETV("arsenalUnits", []);

		// Create controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["RecruitTab", -1];
		T_CALLM1("setControl", _group);

		// Set text...
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_STATIC_N_RECRUITS");
		_ctrl ctrlSetText "Data is loading...";
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
		CALLM2(gGarrisonServer, "postMethodAsync", "clientRequestRecruitWeaponsAtLocation", _args);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", nil);
	} ENDMETHOD;

	METHOD("onListboxSelChanged") {
		params [P_THISOBJECT];

		pr _lnbMain = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX");
		pr _lnbPrimary = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX_PRIMARY");
		pr _lnbSecondary = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX_SECONDARY");

		// Clear listboxes
		lnbClear _lnbPrimary;
		lnbClear _lnbSecondary;

		// Fill listboxes with available weapons
		pr _id = lnbCurSelRow _lnbMain;

		OOP_INFO_1("LISTBOX SEL CHANGED: %1", _id);

		if (_id == -1) exitWith {}; // Bail if wrong row is selected
		pr _subcatid = _lnbMain lnbValue [_id, 0];

		OOP_INFO_1("  subcatid: %1", _subcatid);

		pr _primary =  T_GETV("availableWeaponsPrimary") select _subcatid;
		pr _secondary = T_GETV("availableWeaponsSecondary") select _subcatid;

		//diag_log format ["  primary: %1, secondary: %2", _primary, _secondary];
		//diag_log _lnbPrimary;
		//diag_log _lnbSecondary;

		{
			pr _name = getText (configfile >> "CfgWeapons" >> _x >> "displayName");
			_lnbPrimary lnbAddRow [_name];
			_lnbPrimary lnbSetData [ [_foreachindex, 0], _x];
		} forEach _primary;
		{
			pr _name = getText (configfile >> "CfgWeapons" >> _x >> "displayName");
			_lnbSecondary lnbAddRow [_name];
			_lnbSecondary lnbSetData [ [_foreachindex, 0], _x];
		} forEach _secondary;

		_lnbPrimary lnbSetCurSelRow 0;
		_lnbSecondary lnbSetCurSelRow 0;
	} ENDMETHOD;

	METHOD("onButtonRecruit") {
		params [P_THISOBJECT];
		
		OOP_INFO_0("ON BUTTON RECRUIT");

		pr _dialog = T_CALLM0("getDialogObject");

		// Get selected loadout
		pr _lnbMain = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX");
		pr _lnbPrimary = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX_PRIMARY");
		pr _lnbSecondary = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX_SECONDARY");

		// Bail if nothing is selected
		pr _id = lnbCurSelRow _lnbMain;
		if (_id == -1) exitWith {
			CALLM1(_dialog, "setHintText", "You must select a loadout first");
		};

		pr _subcatid = _lnbMain lnbValue [_id, 0];
		pr _rowPrimary = lnbCurSelRow _lnbPrimary;
		pr _rowSecondary = lnbCurSelRow _lnbSecondary;
		pr _weaponPrimary = "";
		pr _weaponSecondary = "";

		if (_rowPrimary != -1) then {
			_weaponPrimary = _lnbPrimary lnbData [_rowPrimary, 0];
		};
		if (_rowSecondary != -1) then {
			_weaponSecondary = _lnbSecondary lnbData [_rowSecondary, 0];
		};

		// Find the arsenal unit from which we will be taking the weapons
		pr _arsenalUnits = T_GETV("arsenalUnits");
		pr _index = _arsenalUnits findIf {_x#0 == _subcatID};
		pr _arsenalUnit = NULL_OBJECT;
		if (_index != -1) then {_arsenalUnit = _arsenalUnits#_index#1};

		pr _dialogObj = T_CALLM0("getDialogObject");
		pr _loc = GETV(_dialogObj, "location");
		pr _weapons = [_weaponPrimary, _weaponSecondary];
		pr _args = [clientOwner, _loc, playerSide, _subcatID, _weapons, _arsenalUnit];
		OOP_INFO_1("ON BUTTON RECRUIT: sending data to server: %1", _args);
		CALLM2(gGarrisonServer, "postMethodAsync", "recruitUnitAtLocation", _args);

		CALLM1(_dialogObj, "setHintText", "Recruiting soldier...");

		// Disable the button
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_BUTTON_RECRUIT");
		_ctrl ctrlEnable false;
	} ENDMETHOD;

	METHOD("_receiveData") {
		params [P_THISOBJECT, P_ARRAY("_unitsAndWeapons"), P_ARRAY("_validTemplates"), P_NUMBER("_nRecruits")];

		// Reset the arrays with weapons
		pr _array = []; _array resize T_INF_SIZE;
		_array = _array apply {[]};
		T_SETV("availableWeaponsPrimary", +_array);
		T_SETV("availableWeaponsSecondary", +_array);

		// Set text...
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_STATIC_N_RECRUITS");
		_ctrl ctrlSetText (format ["%1", _nRecruits]);
		// Enable the button
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_BUTTON_RECRUIT");
		_ctrl ctrlEnable true;

		// We must use only templates valid both here and at the server
		// Because we are going to check available weapons in the local templates
		pr _templates = _validTemplates arrayIntersect (call t_fnc_getAllValidTemplateNames);
		_templates = _templates - ["tPOLICE"]; // We don't want to arm people with police guns

		// Combine all weapon data from all the available templates
		// todo improve this, it must be done only at startup
		pr _allWeaponData = [];
		_allWeaponData resize T_INF_SIZE;
		_allWeaponData = _allWeaponData apply { [[], []] };
		{
			pr _t = [_x] call t_fnc_getTemplate;
			pr _weaponsThisTemplate = _t#T_LOADOUT_WEAPONS;
			{
				pr _subCatID = _forEachIndex;
				pr _loadoutThisUnit = _x;
				(_allWeaponData#_subCatID#0) append (_loadoutThisUnit#0);
				(_allWeaponData#_subCatID#1) append (_loadoutThisUnit#1);
			} forEach _weaponsThisTemplate;
		} forEach _templates;

		/*
		diag_log "All weapon data:";
		{
			diag_log format [" ID: %1, data: %2", _foreachindex, _x];
		} forEach _allWeaponData;
		*/

		// Make a list of unit types for soldiers for which we have weapons
		pr _subcatsAvailable = []; // Array of subcat IDs of available soldiers
		pr _arsenalUnits = [];
		for "_subcatID" from 0 to (T_INF_engineer-1) do {
			(_allWeaponData select _subcatID) params ["_primaryThisSubcatid", "_secondaryThisSubcatid"];
			// Search arsenals of all the provided cargo crates
			{
				_x params ["_arsenalUnit", "_primary", "_secondary"];
				_primary = _primary apply {_x#0};	// todo this must be done outside of this loop actually
				_secondary = _secondary apply {_x#0};
				pr _primary0 = _primary arrayIntersect _primaryThisSubcatID;
				pr _secondary0 = _secondary arrayIntersect _secondaryThisSubcatID;

				(T_GETV("availableWeaponsPrimary") select _subcatID) append _primary0;
				(T_GETV("availableWeaponsSecondary") select _subcatID) append _secondary0;

				//_subcatsAvailable pushBack _subcatID;

				//diag_log format ["%1 primary from all templates: %2, we have: %3, secondary from all templates: %4, we have: %5", _subcatid, _primaryThisSubcatid, _primary, _secondaryThisSubcatID, _secondary];
				if ( ((count (_primary0)) > 0) && ( (count (_secondary0) > 0) || (count _secondaryThisSubcatID) == 0) ) then {
					_subcatsAvailable pushBack _subcatID;
					_arsenalUnits pushBack [_subcatID, _arsenalUnit];
					//diag_log format ["%1: found weapons that fit: %2 %3", _subcatID, _primary0, _secondary0];
				};
			} forEach _unitsAndWeapons;
		};
		T_SETV("arsenalUnits", _arsenalUnits);

		/*
		diag_log "We can recruit these soldier types:";
		{
			diag_log format ["  %1: %2", _x, T_NAMES select T_INF select _x];
		} forEach _subcatsAvailable;
		*/

		// Fill the listbox
		pr _ctrl = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX");
		lnbClear _ctrl;
		{
			pr _subcatID = _x;
			pr _i = _foreachindex;
			_ctrl lnbAddRow [T_NAMES select T_INF select _subcatID];
			_ctrl lnbSetValue [[_i, 0], _subcatID];
		} forEach _subcatsAvailable;
		_ctrl lnbSetCurSelRow -1;

		// Clear other listboxes
		pr _lnbPrimary = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX_PRIMARY");
		lnbClear _lnbPrimary;
		pr _lnbSecondary = T_CALLM1("findControl", "TAB_RECRUIT_LISTBOX_SECONDARY");
		lnbClear _lnbSecondary;

	} ENDMETHOD;

	STATIC_METHOD("receiveData") {
		params [P_THISCLASS, P_ARRAY("_unitsAndWeapons"), P_ARRAY("_validTemplates"), P_NUMBER("_nRecruits")];

		OOP_INFO_0("RECEIVE WEAPON DATA:");
		{
			OOP_INFO_1("  Unit: %1", _x#0);
			OOP_INFO_1("  Primary weapons: %1", _x#1);
			OOP_INFO_1("  Secondary weapons: %1", _x#2);
		} forEach _unitsAndWeapons;
		OOP_INFO_1("  Valid templates: %1", _validTemplates);
		

		pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
		if (!IS_NULL_OBJECT(_instance)) then {
			CALLM3(_instance, "_receiveData", _unitsAndWeapons, _validTemplates, _nRecruits);
		};
	} ENDMETHOD;

ENDCLASS;