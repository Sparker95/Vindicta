#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#include "..\..\common.h"
#include "..\Resources\MapUI\MapUI_Macros.h"
#include "..\Resources\UIProfileColors.h"

/*
abstract Class: PlayerListUI
Singleton class that performs things related to player list interface
*/
#define CLASS_NAME "PlayerListUI"
#define OOP_CLASS_NAME PlayerListUI
CLASS("PlayerListUI", "")

	STATIC_METHOD(new)
		params [P_THISOBJECT];
		private _mapDisplay = findDisplay 12;

		(_mapDisplay displayCtrl IDC_PL_BUTTON_SHOW_PLAYERLIST) ctrlAddEventHandler ["MouseButtonDown", { CALLSM0(CLASS_NAME, "PlayerListMouseButtonDown") }];
		(_mapDisplay displayCtrl IDC_PL_BUTTON_SHOW_PLAYERLIST) ctrlAddEventHandler ["MouseButtonUp", { CALLSM1(CLASS_NAME, "PlayerListMouseExit", _this) }];
		(_mapDisplay displayCtrl IDC_PL_BUTTON_SHOW_PLAYERLIST) ctrlAddEventHandler ["MouseEnter", { CALLSM1(CLASS_NAME, "PlayerListMouseEnter", _this) }];
		(_mapDisplay displayCtrl IDC_PL_BUTTON_SHOW_PLAYERLIST) ctrlAddEventHandler ["MouseExit", { CALLSM1(CLASS_NAME, "PlayerListMouseExit", _this) }];

		(_mapDisplay displayCtrl IDC_PL_BUTTON_ADD_MEMBER) ctrlAddEventHandler ["MouseButtonDown", { CALLSM1(CLASS_NAME, "AddMemberMouseButtonDown", _this) }];
		(_mapDisplay displayCtrl IDC_PL_BUTTON_ADD_MEMBER) ctrlAddEventHandler ["MouseButtonUp", { CALLSM1(CLASS_NAME, "AddMemberMouseExit", _this) }];
		(_mapDisplay displayCtrl IDC_PL_BUTTON_SHOW_PLAYERLIST) ctrlAddEventHandler ["MouseExit", { CALLSM1(CLASS_NAME, "AddMemberMouseExit", _this) }];
		(_mapDisplay displayCtrl IDC_PL_BUTTON_SHOW_PLAYERLIST) ctrlAddEventHandler ["MouseEnter", { CALLSM1(CLASS_NAME, "AddMemberMouseEnter", _this) }];

		(_mapDisplay displayCtrl IDC_HR_VALUE) ctrlAddEventHandler ["MouseEnter", { CALLSM1(CLASS_NAME, "HRValueMouseEnter", _this) }];
	ENDMETHOD;

	STATIC_METHOD(HRValueMouseEnter)
		private _mapDisplay = findDisplay 12;
		private _ctrl = _mapDisplay displayCtrl IDC_HR_VALUE;
		(_mapDisplay displayCtrl IDC_HR_VALUE) ctrlSetText (format ["%1", gSideStatWestHR]);
	ENDMETHOD;

	// Start PlayerList EH
	STATIC_METHOD(updatePlayers)
		private _ctrlList = (findDisplay 12) displayCtrl IDC_PL_LISTPLAYERS;
		lbClear _ctrlList;
		
		OOP_DEBUG_1("gPlayersList %1",  gPlayersList);
		{
			private _name = _x select 2;
			private _playerUID = _x select 1;
			private _index =  _ctrlList lbAdd _name;
			_ctrlList lbSetData [_index, _playerUID];
			_ctrlList lbSetText [_index, _name];
		} forEach gPlayersList;
	ENDMETHOD;

	STATIC_METHOD(PlayerListMouseButtonDown)
		private _mapDisplay = findDisplay 12;
		private _ctrl = _mapDisplay displayCtrl IDC_PL_BUTTON_SHOW_PLAYERLIST;
		_ctrl ctrlSetBackgroundColor [0.1,0.3,0.1,0.7];

		_ctrl = _mapDisplay displayCtrl IDC_PL_LISTPLAYERS;
		_bool = ctrlShown _ctrl;
		if (_bool) then {
			(_mapDisplay displayCtrl IDC_PL_PANEL) ctrlShow false;
			(_mapDisplay displayCtrl IDC_PL_HEADER_LISTPLAYERS) ctrlShow false;
			(_mapDisplay displayCtrl IDC_PL_BUTTON_ADD_MEMBER) ctrlShow false;
			(_mapDisplay displayCtrl IDC_PL_LISTPLAYERS) ctrlShow false;
		} else {
			CALLSM0(CLASS_NAME, "updatePlayers");
			(_mapDisplay displayCtrl IDC_PL_PANEL) ctrlShow true;
			(_mapDisplay displayCtrl IDC_PL_HEADER_LISTPLAYERS) ctrlShow true;
			(_mapDisplay displayCtrl IDC_PL_BUTTON_ADD_MEMBER) ctrlShow true;
			(_mapDisplay displayCtrl IDC_PL_LISTPLAYERS) ctrlShow true;
		};
	ENDMETHOD;

	STATIC_METHOD(PlayerListMouseEnter)
		params ["_thisClass", "_paramsEH"];
		_paramsEH params ["_control"];
		_control ctrlSetBackgroundColor [0.1,0.1,0.1,0.7];
	ENDMETHOD;

	STATIC_METHOD(PlayerListMouseExit)
		params ["_thisClass", "_paramsEH"];
		_paramsEH params ["_control"];
		_control ctrlSetBackgroundColor [0.1,0.1,0.1,0.5];
	ENDMETHOD;
	// End PlayerList Eh

	// Start AddMember button EH
	STATIC_METHOD(AddMemberMouseEnter)
		params ["_thisClass", "_paramsEH"];
		_paramsEH params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
		_control ctrlSetBackgroundColor [0.1,0.1,0.1,0.7];
	ENDMETHOD;

	STATIC_METHOD(AddMemberMouseExit)
		params ["_thisClass", "_paramsEH"];
		_paramsEH params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
		_control ctrlSetBackgroundColor [0.1,0.1,0.1,0.5];
	ENDMETHOD;

	STATIC_METHOD(AddMemberMouseButtonDown)
		params ["_thisClass", "_paramsEH"];
		_paramsEH params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
		private _mapDisplay = findDisplay 12;

		_control ctrlSetBackgroundColor [0.1,0.3,0.1,0.7];

		private _ctrlPL = _mapDisplay displayCtrl IDC_PL_LISTPLAYERS;
		private _selectedPlayer = lbCurSel _ctrlPL;
		OOP_DEBUG_1("MouseButtonUp _selectedPlayer lbText %1", _ctrlPL lbText _selectedPlayer);
		OOP_DEBUG_1("MouseButtonUp _selectedPlayer lbData %1", _ctrlPL lbData _selectedPlayer);
	ENDMETHOD;
	// End AddMember button EH

ENDCLASS;
