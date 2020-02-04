#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define __CLASS_NAME "InGameMenuTabGameModeInit"

#define pr private

#define LB_CUR_SEL_DATA(lb) lb lbData (lbCurSel lb)

CLASS(__CLASS_NAME, "DialogTabBase")

	METHOD("new") {
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", _thisObject);

		// Create controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["TAB_GMINIT", -1];
		T_CALLM1("setControl", _group);

		// Add event handlers
		T_CALLM3("controlAddEventHandler", "TAB_GMINIT_BUTTON_START", "buttonClick", "onButtonStart");

		// Populate combo boxes
		pr _cbGameMode = T_CALLM1("findControl", "TAB_GMINIT_COMBO_GAME_MODE");
		pr _cbEnemyFaction = T_CALLM1("findControl", "TAB_GMINIT_COMBO_ENEMY_FACTION");
		pr _cbPoliceFaction = T_CALLM1("findControl", "TAB_GMINIT_COMBO_POLICE_FACTION");

		// Add game mode names
		pr _gameModes = [["Civil War", "CivilWarGameMode"]];

		// Add more game modes for debug builds
		#ifndef RELEASE_BUILD
		_gameModes append [
			["Red VS Green", "RedVsGreenGameMode"],
			["Expand", "ExpandGameMode"],
			["Almost Empty", "AlmostEmptyGameMode"]
		];
		#endif
		{
			_cbGameMode lbAdd _x#0;
			_cbGameMode lbSetData [_forEachIndex, _x#1];
		} forEach _gameModes;

		_cbGameMode lbSetCurSel 0;

		// Add enemy factions

		pr _milBlacklist = ["tDefault"];
		pr _counter = 0;	// Counter of lines in combo box
		{
			pr _tName = _x;
			if (!(_tName in _milBlacklist)) then {						// Ignore factions from blacklist
				pr _t = [_tName] call t_fnc_getTemplate;
				if ((_t select T_FACTION) == T_FACTION_Military) then {	// Ignore non-military factions
					pr _lbData = _tName;
					pr _text = _t select T_DISPLAY_NAME;
					_cbEnemyFaction lbAdd _text;
					_cbEnemyFaction lbSetData [_counter, _lbData];
				};
				_counter = _counter + 1;
			};
		} forEach (call t_fnc_getAllTemplateNames);
		_cbEnemyFaction lbSetCurSel 0;

		// Add police factions
		pr _counter = 0;
		{
			pr _tName = _x;
			pr _t = [_tName] call t_fnc_getTemplate;
			if (_t#T_FACTION == T_FACTION_Police) then {
				pr _text = _t select T_DISPLAY_NAME;
				pr _lbData = _tName;
				_cbPoliceFaction lbAdd _text;						// Set text from template name
				_cbPoliceFaction lbSetData [_counter, _lbData];// Set data - template internal name
				_counter = _counter + 1;
			};
		} forEach (call t_fnc_getAllTemplateNames);
		_cbPoliceFaction lbSetCurSel 0;

		// Enable/disable controls depending on user's permissions
		pr _bnStart = T_CALLM1("findControl", "TAB_GMINIT_BUTTON_START");
		pr _isAdmin = call misc_fnc_isAdminLocal;
		if (!_isAdmin) then {
			_bnStart ctrlEnable false;
			_bnStart ctrlSetTooltip "Only for admins";
		};

		// Add control event handlers
		T_CALLM3("controlAddEventHandler", "TAB_GMINIT_COMBO_ENEMY_FACTION", "LBSelChanged", "onCbSelChanged");
		T_CALLM3("controlAddEventHandler", "TAB_GMINIT_COMBO_POLICE_FACTION", "LBSelChanged", "onCbSelChanged");

		// Update the description
		T_CALLM0("updateDescription");

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", nil);

	} ENDMETHOD;

	// Called when we select something new in the combo box
	METHOD("onCbSelChanged") {
		params [P_THISOBJECT];
		OOP_INFO_0("CB SEL CHANGED");
		T_CALLM0("updateDescription");
	} ENDMETHOD;

	// Updates description text.
	METHOD("updateDescription") {
		params [P_THISOBJECT];

		pr _cbEnemyFaction = T_CALLM1("findControl", "TAB_GMINIT_COMBO_ENEMY_FACTION");
		pr _cbPoliceFaction = T_CALLM1("findControl", "TAB_GMINIT_COMBO_POLICE_FACTION");
		pr _staticDescription = T_CALLM1("findControl", "TAB_GMINIT_STATIC_DESCRIPTION");

		pr _str = "Chosen factions:\n";

		// Format text according to selected factions.
		pr _enemyTemplateName = LB_CUR_SEL_DATA(_cbEnemyFaction);
		pr _policeTemplateName = LB_CUR_SEL_DATA(_cbPoliceFaction);
		{
			pr _t = [_x] call t_fnc_getTemplate;
			_str = _str + format ["- %1\n%2\n", _t#T_DISPLAY_NAME, _t#T_DESCRIPTION];

			// Add more text if tempalte is not valid
			if (!(_t#T_VALID)) then {
				if (count (_t#T_MISSING_ADDONS) > 0) then {
					_str = _str + "ERROR: following addons are missing for this faction: ";
					{
						_str = _str + _x;
						if (_forEachIndex < (count (_t#T_MISSING_ADDONS)) - 1) then {
							_str = _str + ", ";
						} else {
							_str = _str + ".\n";
						};
					} forEach (_t#T_MISSING_ADDONS);
				} else {
					_str = _str + format ["ERROR: faction file has errors. Check .RPT file for more info."];
				};
			};

			_str = _str + "\n";
		} forEach [_enemyTemplateName, _policeTemplateName];

		_staticDescription ctrlSetText _str;

	} ENDMETHOD;

	METHOD("onButtonStart") {
		params [P_THISOBJECT];

		// Validate inputs
		pr _cbGameMode = T_CALLM1("findControl", "TAB_GMINIT_COMBO_GAME_MODE");
		pr _cbEnemyFaction = T_CALLM1("findControl", "TAB_GMINIT_COMBO_ENEMY_FACTION");
		pr _cbPoliceFaction = T_CALLM1("findControl", "TAB_GMINIT_COMBO_POLICE_FACTION");
		pr _editCampaignName = T_CALLM1("findControl", "TAB_GMINIT_EDIT_CAMPAIGN_NAME");
		pr _editEnemyForcePercent = T_CALLM1("findControl", "TAB_GMINIT_EDIT_ENEMY_PERCENTAGE");

		pr _dialogObj = T_CALLM0("getDialogObject");

		// Campaign name
		pr _campaignName = ctrlText _editCampaignName;
		if (count _campaignName == 0) exitWith {
			CALLM1(_dialogObj, "setHintText", "You must enter a campaign name");
		};

		// Enemy force
		pr _enemyForceText = ctrlText _editEnemyForcePercent;
		pr _enemyForcePercent = parseNumber _enemyForceText;
		if (isNil "_enemyForcePercent") exitWith {
			CALLM1(_dialogObj, "setHintText", "You must enter a valid amount of enemy forces");
		};
		_enemyForcePercent = (_enemyForcePercent max 0) min 1000;

		pr _gameModeClassName = LB_CUR_SEL_DATA(_cbGameMode);
		pr _enemyTemplateName = LB_CUR_SEL_DATA(_cbEnemyFaction);
		pr _policeTemplateName = LB_CUR_SEL_DATA(_cbPoliceFaction);

		// Verify templates
		// todo really we must check that on server
		pr _templatesGood = true;
		{
			pr _t = [_x] call t_fnc_getTemplate;
			if (!(_t select T_VALID)) then {
				_templatesGood = false;
			};
		} forEach [_enemyTemplateName, _policeTemplateName];

		// Bail if incompatible template was selected
		if (!_templatesGood) exitWith {
			CALLM1(_dialogObj, "setHintText", "ERROR: You must select factions which have all the addons loaded on the server");
		};

		// Send data to server's GameManager
		pr _gameModeParams = [_enemyTemplateName, _policeTemplateName, _enemyForcePercent];
		pr _templatesVerify = [_enemyTemplateName, _policeTemplateName];
		pr _args = [clientOwner, _gameModeClassName, _gameModeParams, _campaignName, _templatesVerify];
		CALLM2(gGameManagerServer, "postMethodAsync", "initCampaignServer", _args);

		// Close in game menu after creating
		CALLM0(gInGameMenu, "close");
	} ENDMETHOD;

ENDCLASS;
