#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define pr private

#define __CLASS_NAME "RecruitTab"

CLASS(__CLASS_NAME, "DialogTabBase")

	METHOD("new") {
		params [P_THISOBJECT];

		// Create controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["RecruitTab", -1];
		T_CALLM1("setControl", _group);

		SETSV(__CLASS_NAME, "instance", _thisObject);

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

	METHOD("_receiveWeaponData") {
		params [P_THISOBJECT, P_ARRAY("_unitsAndWeapons"), P_ARRAY("_validTemplates")];

		// We must use only templates valid both here and at the server
		// Because we are going to check available weapons in the local templates
		pr _templates = _validTemplates arrayIntersect (call t_fnc_getAllValidTemplateNames);

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

		diag_log "All weapon data:";
		{
			diag_log format [" ID: %1, data: %2", _foreachindex, _x];
		} forEach _allWeaponData;

		// Make a list of unit types for soldiers for which we have weapons
		pr _subcatsAvailable = []; // Array of subcat IDs of available soldiers
		for "_subcatID" from 0 to (T_INF_size-1) do {
			(_allWeaponData select _subcatID) params ["_primaryThisSubcatid", "_secondaryThisSubcatid"];
			// Search arsenals of all the provided cargo crates
			{
				_x params ["_arsenalUnit", "_primary", "_secondary"];
				_primary = _primary apply {_x#0};	// todo this must be done outside of this loop actually
				_secondary = _secondary apply {_x#0};
				pr _primary0 = _primary arrayIntersect _primaryThisSubcatID;
				pr _secondary0 = _secondary arrayIntersect _secondaryThisSubcatID;
				//diag_log format ["%1 primary from all templates: %2, we have: %3, secondary from all templates: %4, we have: %5", _subcatid, _primaryThisSubcatid, _primary, _secondaryThisSubcatID, _secondary];
				if ( ((count (_primary0)) > 0) && ( (count (_secondary0) > 0) || (count _secondaryThisSubcatID) == 0) ) then {
					_subcatsAvailable pushBack _subcatID;
					diag_log format ["%1: found weapons that fit: %2 %3", _subcatID, _primary0, _secondary0];
				};
			} forEach _unitsAndWeapons;
		};

		diag_log "We can recruit these soldier types:";
		{
			diag_log format ["  %1: %2", _x, T_NAMES select T_INF select _x];
		} forEach _subcatsAvailable;
	} ENDMETHOD;

	STATIC_METHOD("receiveWeaponData") {
		params [P_THISCLASS, P_ARRAY("_unitsAndWeapons"), P_ARRAY("_validTemplates")];

		OOP_INFO_0("RECEIVE WEAPON DATA:");
		{
			OOP_INFO_1("  Unit: %1", _x#0);
			OOP_INFO_1("  Primary weapons: %1", _x#1);
			OOP_INFO_1("  Secondary weapons: %1", _x#2);
		} forEach _unitsAndWeapons;
		OOP_INFO_1("  Valid templates: %1", _validTemplates);
		

		pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
		if (!IS_NULL_OBJECT(_instance)) then {
			CALLM2(_instance, "_receiveWeaponData", _unitsAndWeapons, _validTemplates);
		};
	} ENDMETHOD;

ENDCLASS;