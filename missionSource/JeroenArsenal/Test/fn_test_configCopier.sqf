private _running = missionNamespace getVariable ["configCopier_running",false];
if(!_running)then{
	[missionNamespace, "arsenalOpened", {
		disableSerialization;
		UINamespace setVariable ["arsanalDisplay",(_this select 0)];

		[] spawn arsenal_configCopier_code;

	}] call BIS_fnc_addScriptedEventHandler;
	missionNamespace setVariable ["configCopier_running",true];
};

arsenal_configCopier_code = {
	disableSerialization;
	private _display = uiNamespace getVariable "arsanalDisplay";

	{
		private _idc = _x;
		private _ctrlList = _display displayctrl (960 + _idc);
		_ctrlList ctrlAddEventHandler ["MouseButtonDown", {
			params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			uiNamespace setvariable ['config_arsenal_shift',_shift];
			uiNamespace setvariable ['config_arsenal_click',true];
		}];
		_ctrlList ctrlAddEventHandler ["LBSelChanged",  {
			if(uiNamespace getvariable ['config_arsenal_click',false])then{
				params ['_control', '_selectedIndex'];
				private _shift = uiNamespace getvariable ['config_arsenal_shift',false];
				
				private _item = _control lbData _selectedIndex;
				private _item_cfg = (configfile >> 'CfgWeapons' >> _item);
				private _dlcName = "";
				private _addons = configsourceaddonlist _item_cfg;
				if (count _addons > 0) then {
					private _mods = configsourcemodlist (configfile >> "CfgPatches" >> _addons select 0);
					if (count _mods > 0) then {
						_dlcName = _mods select 0;
					};
				};
				
				private _dlc_id = getNumber(configFile >> "CfgMods" >> _dlcName >> "appId");

				if(!_shift)then{
					copyToClipboard format ["""%1""",_item];
				}else{
					copyToClipboard format ['"%1" | "%2" | %3',_item,_dlcName,_dlc_id];
				};

				uiNamespace setvariable ['config_arsenal_click',false];
			};
		}];
	} foreach [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,18,19,20,25,21,26,22,23,24];
};

[ "Open", [ true ] ] call BIS_fnc_arsenal;