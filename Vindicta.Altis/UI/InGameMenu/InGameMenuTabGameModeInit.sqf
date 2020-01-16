#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define __CLASS_NAME "InGameMenuTabGameModeInit"

#define pr private

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
		pr _data = [
			["Arma 3 - AAF",		"tAAF"],
			["Arma 3 - CSAT", 	"tCSAT"],
			["Arma 3 - NATO",		"tNATO"],
			["RHS, AAF2017 - Altis Armed Forces",	"tRHS_AAF2017_elite"],
			["RHS - Russian Armed Forces", 		"tRHS_AFRF"],
			["RHS - US Army", 		"tRHS_USAF"],
			["RHS - Livonian Defence Forces", 		"tRHS_LDF"]
			["RHS - HIDF",	"tRHS_HIDF"]
			["IFA3 - Germany",	"tIFA3_Germany"]
			["IFA3 - UK",	"tIFA3_UK"]//,
			//["Test: must error", "test_error"]
		];
		{
			_x params ["_text", "_lbData"];
			_cbEnemyFaction lbAdd _text;
			_cbEnemyFaction lbSetData [_forEachIndex, _lbData];
		} forEach _data;
		_cbEnemyFaction lbSetCurSel 0;

		// Add police factions
		pr _data = [
			["Arma 3 - Police", "tPolice"],
			["RHS, AAF2017 - Altian Police", "tRHS_AAF2017_police"],
			["RHS - Livonian Forest Rangers ", "tRHS_LDF_ranger"]
			["IFA3 - Germany (Police)", "tIFA3_Germany_police"]
			["IFA3 - UK (Police)", "tIFA3_UK_police"]
		];
		{
			_x params ["_text", "_lbData"];
			_cbPoliceFaction lbAdd _text;
			_cbPoliceFaction lbSetData [_forEachIndex, _lbData];
		} forEach _data;
		_cbPoliceFaction lbSetCurSel 0;

		// Enable/disable controls depending on user's permissions
		pr _bnStart = T_CALLM1("findControl", "TAB_GMINIT_BUTTON_START");
		pr _isAdmin = call misc_fnc_isAdminLocal;
		if (!_isAdmin) then {
			_bnStart ctrlEnable false;
			_bnStart ctrlSetTooltip "Only for admins";
		};

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", nil);

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

		#define LB_CUR_SEL_DATA(lb) lb lbData (lbCurSel lb)

		pr _gameModeClassName = LB_CUR_SEL_DATA(_cbGameMode);
		pr _enemyTemplateName = LB_CUR_SEL_DATA(_cbEnemyFaction);
		pr _policeTemplateName = LB_CUR_SEL_DATA(_cbPoliceFaction);

		// Verify templates
		// todo really we must check that on server
		pr _templatesGood = true;
		{
			if (([_x] call t_fnc_getTemplate) isEqualTo []) then {
				_templatesGood = false;
			};
		} forEach [_enemyTemplateName, _policeTemplateName];

		// Bail if incompatible template was selected
		if (!_templatesGood) exitWith {
			CALLM1(_dialogObj, "setHintText", "You must select factions which are loaded");
		};

		// Send data to server's GameManager
		pr _gameModeParams = [_enemyTemplateName, _policeTemplateName, _enemyForcePercent];
		pr _templatesVerify = [_enemyTemplateName, _policeTemplateName];
		pr _args = [clientOwner, _gameModeClassName, _gameModeParams, _campaignName, _templatesVerify];
		CALLM2(gGameManagerServer, "postMethodAsync", "initCampaignServer", _args);

	} ENDMETHOD;

ENDCLASS;
