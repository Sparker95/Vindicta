#include "defineCommon.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	Core code

	Parameter(s):
	Object

	Returns:
	
	Usage: No use for end user, use  garage_init instead
	
*/


disableserialization;

_mode = [_this,0,"Open",[displaynull,""]] call bis_fnc_param;
_this = [_this,1,[]] call bis_fnc_param;
if!(_mode in ["draw3D","addVehicle","KeyDown"])then{
    diag_log format["JN_ammo mode: %1 %2", _mode, _this];
};

switch _mode do {

	///////////////////////////////////////////////////////////////////////////////////////////
	case "draw3D": {
		_display = uiNamespace getVariable "arsanalDisplay";
		_cam = (uinamespace getvariable ["BIS_fnc_arsenal_cam",objnull]);
		_center = (missionnamespace getvariable ["JNG_CENTER",objnull]);
		_target = (missionnamespace getvariable ["BIS_fnc_arsenal_target",objnull]);

		_camPos = (uinamespace getvariable ["BIS_fnc_arsenal_campos",objnull]);

		_dis = _camPos select 0;
		_dirH = _camPos select 1;
		_dirV = _camPos select 2;

		[_target,[_dirH + 180,-_dirV,0]] call bis_fnc_setobjectrotation;
		_target attachto [_center,_camPos select 3,""]; //--- Reattach for smooth movement

		_cam setpos (_target modeltoworld [0,-_dis,0]);
		_cam setvectordirandup [vectordir _target,vectorup _target];




		{
			_ctrl = _x;
			_offset = _ctrl getVariable ["location",[0,0,0]];

			if (_offset distance [0,0,0] > 0) then {
				_pos = _center modeltoworldvisual _offset;
				_uiPos = worldtoscreen _pos;
				if (count _uiPos > 0) then {
					{
						_ctrlPos = ctrlposition _ctrl;
						_ctrlPos set [0,(_uiPos select 0) - (_ctrlPos select 2) * 0.5];
						_ctrlPos set [1,(_uiPos select 1) - (_ctrlPos select 3) * 0.5];
						_ctrl ctrlsetposition _ctrlPos;
						_ctrl ctrlcommit 0;

					} foreach [IDC_RSCDISPLAYARSENAL_ICON,IDC_RSCDISPLAYARSENAL_ICONBACKGROUND];
				};
			};
		} foreach (missionnamespace getvariable ["JNG_garage_icons",[]]);
	};

	///////////////////////////////////////////////////////////////////////////////////////////
	case "MouseZChanged": {

		pr _cam = (uinamespace getvariable ["BIS_fnc_arsenal_cam",objnull]);
		pr _center = (missionnamespace getvariable ["JNG_CENTER",objnull]);
		pr _target = (missionnamespace getvariable ["BIS_fnc_arsenal_target",objnull]);
		pr _camPos = (uinamespace getvariable ["BIS_fnc_arsenal_campos",objnull]); //[5,-180.171,31.4394,[-0.151687,-0.000455028,0.169312]]

		pr _disMax = ((boundingboxreal _center select 0) vectordistance (boundingboxreal _center select 1)) * 1.5;
		pr _disMin = _disMax * 0.15;
		pr _z = _this select 1;
		pr _dis = _camPos select 0;
		_dis = _dis - (_z / 10);
		_dis = _dis max _disMin min _disMax;
		_camPos set [0,_dis];
	};

	/////////////////////////////////////////////////////////////////////////////////////////// Externaly called
	case "CustomInit":{
		_display = _this select 0;
		
		["CustomLayout",[_display]] call  jn_fnc_ammo_gui;
		["CustomEvents",[_display]] call  jn_fnc_ammo_gui;
		["CreateWeaponLists", [_display]] call  jn_fnc_ammo_gui;
		["showMessage", [_display,"Jeroen (Not) Limited Ammo"]] call jn_fnc_arsenal;

		["jn_fnc_ammo"] call bis_fnc_endLoadingScreen;
	};

	///////////////////////////////////////////////////////////////////////////////////////////
	case "CustomEvents":{
		_display = _this select 0;

		with (uinamespace) do {

				//Keys
			_display displayRemoveAllEventHandlers "keydown";
			_display displayAddEventHandler ["keydown",{['KeyDown',_this] call jn_fnc_ammo_gui;}];

			//custom draw function to remove icons on player
			removeMissionEventHandler ["draw3D",BIS_fnc_arsenal_draw3D];
			BIS_fnc_arsenal_draw3D = addMissionEventHandler ["draw3D",{
					["draw3D",[]] call jn_fnc_ammo_gui;
			}];

			//custom scroll zoom
			_ctrlMouseArea = _display displayctrl IDC_RSCDISPLAYARSENAL_MOUSEAREA;
			_ctrlMouseArea ctrlRemoveAllEventHandlers "mousezchanged";
			_ctrlMouseArea ctrladdeventhandler ["mousezchanged",{["MouseZChanged",[ctrlparent (_this select 0), (_this select 1)]] call jn_fnc_ammo_gui;}];

			//disable annoying deselecting of tabs when you misclick
			_ctrlMouseArea ctrlRemoveEventHandler ["mousebuttonclick",0];

			//
			_ctrlButtonClose = _display displayctrl (getnumber (configfile >> "RscDisplayArsenal" >> "Controls" >> "ControlBar" >> "controls" >> "ButtonClose" >> "idc"));
			_ctrlButtonClose ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlButtonClose ctrlSetText "Close";// "Get vehicle"
			_ctrlButtonClose ctrladdeventhandler ["buttonclick",{["Close"] call jn_fnc_ammo_gui;}];

			//lock button
			_ctrlButtonLock = _display displayctrl IDC_RSCDISPLAYARSENAL_CONTROLSBAR_BUTTONINTERFACE;
			_ctrlButtonLock ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlButtonLock ctrlSetText "TODO";
			_ctrlButtonLock ctrlEnable false;

			//disable
			_ctrlButtonExport = _display displayctrl IDC_RSCDISPLAYARSENAL_CONTROLSBAR_BUTTONEXPORT;
			_ctrlButtonExport ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlButtonExport ctrlSetText "TODO";
			_ctrlButtonExport ctrlEnable false;

			//disable
			_ctrlButtonImport = _display displayctrl IDC_RSCDISPLAYARSENAL_CONTROLSBAR_BUTTONIMPORT;
			_ctrlButtonImport ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlButtonImport ctrlSetText "TODO";
			_ctrlButtonImport ctrlEnable false;

			//disable
			_ctrlButtonRandom = _display displayctrl IDC_RSCDISPLAYARSENAL_CONTROLSBAR_BUTTONRANDOM;
			_ctrlButtonRandom ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlButtonRandom ctrlSetText "TODO";
			_ctrlButtonRandom ctrlEnable false;

			//disable
			_ctrlButtonSave = _display displayctrl IDC_RSCDISPLAYARSENAL_CONTROLSBAR_BUTTONSAVE;
			_ctrlButtonSave ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlButtonSave ctrlSetText "TODO";
			_ctrlButtonSave ctrlEnable false;

			//disable
			_ctrlButtonLoad = _display displayctrl IDC_RSCDISPLAYARSENAL_CONTROLSBAR_BUTTONLOAD;
			_ctrlButtonLoad ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlButtonLoad ctrlSetText "TODO";
			_ctrlButtonLoad ctrlEnable false;

			//custom button for add subtrack items in lists
			_ctrlArrowLeft = _display displayctrl IDC_RSCDISPLAYARSENAL_ARROWLEFT;
			_ctrlArrowLeft ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlArrowLeft ctrladdeventhandler ["buttonclick",{["buttonCargo",[ctrlparent (_this select 0),-1]] call jn_fnc_ammo_gui;}];

			_ctrlArrowRight = _display displayctrl IDC_RSCDISPLAYARSENAL_ARROWRIGHT;
			_ctrlArrowRight ctrlRemoveAllEventHandlers "buttonclick";
			_ctrlArrowRight ctrladdeventhandler ["buttonclick",{["buttonCargo",[ctrlparent (_this select 0),+1]] call jn_fnc_ammo_gui;}];


			{
				_idc = _x;
				
				_ctrlName = _display displayctrl (IDC_AMMO_SEATBUTTON + _idc);
				_ctrlName ctrlRemoveAllEventHandlers "buttonclick";
				_ctrlName ctrladdeventhandler ["buttonclick",format ["['TabSelect',[ctrlparent (_this select 0),%1],true] call jn_fnc_ammo_gui;",_idc]];
				

				_ctrlList = _display displayctrl (IDC_RSCDISPLAYARSENAL_LIST + _idc);
				_ctrlList ctrlRemoveAllEventHandlers "LBSelChanged";
				_ctrlList ctrlAddEventHandler ["MouseButtonUp",	{uiNamespace setvariable ['jn_userInput',true];}];
				_ctrlList ctrlAddEventHandler ["LBSelChanged",	format ["
					if(uiNamespace getvariable ['jn_userInput',false])then{
						uiNamespace setvariable ['jn_userInput',false];
						['SelectWeapon',[ctrlparent (_this select 0),(_this select 0),%1]] call jn_fnc_ammo_gui;
					};
				",_idc]];

				//sort

			} foreach IDCS;

			call {
				pr _ctrlList = _display displayctrl (IDC_RSCDISPLAYARSENAL_LIST + IDC_AMMO_LIST_MAGAZINES);
				_ctrlList ctrlRemoveAllEventHandlers "LBSelChanged";
				_ctrlList ctrlAddEventHandler ["MouseButtonUp",	{uiNamespace setvariable ['jn_userInput',true];}];
				_ctrlList ctrlAddEventHandler ["LBSelChanged","
					if(uiNamespace getvariable ['jn_userInput',false])then{
						uiNamespace setvariable ['jn_userInput',false];
						['SelectMagazine',[ctrlparent (_this select 0),(_this select 0)]] call jn_fnc_ammo_gui;
					};
				"];
			};

		};
	};

	///////////////////////////////////////////////////////////////////////////////////////////
	case "CustomLayout":{
		pr _display = _this select 0;
		pr _loadout = UINamespace getVariable "jn_objectTo_loadout";
		
		pr _posTab = ctrlPosition (_display displayctrl (IDC_RSCDISPLAYARSENAL_TAB +IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON));
		pr _posList = ctrlPosition (_display displayctrl (IDC_RSCDISPLAYARSENAL_LIST +IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON));
		pr _posXTab = _posTab select 0;
		pr _posWList = _posList select 2;
		pr _posOffset = (_posXTab - safezoneX);
		pr _posXListRight = _posXTab + AMMO_SEATBUTTON_WITDH + _posOffset;
		pr _posXListLeft = _posXListRight + _posWList + _posOffset;
		
		
		//disable unwanted icons on left
		for "_x" from 0 to IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL step 1 do {
			_index = _x;
			{
				_ctrlTab = _display displayctrl(_index + _x);
				_ctrlTab ctrlShow false;
				_ctrlTab ctrlEnable false;
				//_ctrlTab ctrlRemoveAllEventHandlers "buttonclick";
				_ctrlTab ctrlCommit 0;
			} forEach [IDC_RSCDISPLAYARSENAL_ICON,IDC_RSCDISPLAYARSENAL_ICONBACKGROUND,IDC_RSCDISPLAYARSENAL_TAB];
		};
		
		//hide icons on player
		for "_x" from 0 to IDC_RSCDISPLAYARSENAL_TAB_INSIGNIA step 1 do {
			_tab = _x;
			{
				_ctrl = _display displayctrl (_tab + _x);
				_ctrl ctrlshow false;
				_ctrl ctrlenable false;
				_ctrl ctrlremovealleventhandlers "buttonclick";
				_ctrl ctrlremovealleventhandlers "mousezchanged";
				_ctrl ctrlremovealleventhandlers "lbselchanged";
				_ctrl ctrlremovealleventhandlers "lbdblclick";
				_ctrl ctrlsetposition [0,0,0,0];
				_ctrl ctrlcommit 0;
			} foreach [IDC_RSCDISPLAYARSENAL_ICON,IDC_RSCDISPLAYARSENAL_ICONBACKGROUND];
		};
		
		//replace icons in left tab copy from garage
		_idcSort = [];
		{
			pr _seatName = _x select 1;
			pr _index = _foreachindex;
			pr _indexMoveTo = _foreachindex+1;
			pr _ctrlTab = _display displayctrl(IDC_RSCDISPLAYARSENAL_TAB + _index);
			pr _ctrlTabMoveTo = _display displayctrl(IDC_RSCDISPLAYARSENAL_TAB + _indexMoveTo);

			//move icons
			_ctrlTab ctrlSetPosition (ctrlPosition _ctrlTabMoveTo);

			//show icons
			_ctrlTab ctrlEnable false;
			_ctrlTab ctrlShow false;
			_ctrlTab ctrlSetScale 2;
			//_ctrlTab ctrlSetText gettext(configfile >> "RscDisplayGarage" >> "Controls" >> _x >> "text");
			//_ctrlTab ctrlSetTooltip gettext(configfile >> "RscDisplayGarage" >> "Controls" >> _x >> "tooltip");
			_ctrlTab ctrlCommit 0;
		
			_txt = _display ctrlCreate ["RscButton", IDC_AMMO_SEATBUTTON + _index];
			_txt ctrlsetText _seatName;
			_pos = (ctrlPosition _ctrlTab);
			_pos set [2,AMMO_SEATBUTTON_WITDH];
			_txt ctrlSetPosition _pos;
			_txt ctrlCommit 0;
			_txt ctrlSetBackgroundColor [0,0,0,0.8];
			//_txt ctrlAddEventHandler

			
	

			//move list to the right to not clip with bigger icons
			_ctrlList = _display displayctrl(IDC_RSCDISPLAYARSENAL_LIST + _index);
			_pos = (ctrlPosition _ctrlList);
			_pos set [0, _posXListRight];
			_ctrlList ctrlsetPosition _pos;
			_ctrlList ctrlCommit 0;
			

			_idcSort pushback (IDC_RSCDISPLAYARSENAL_SORT + _index);
		} forEach (_loadout);
		

		{
			_ctrl = _display displayctrl _x;
			_pos = (ctrlPosition _ctrl);
			_pos set [0, _posXListRight];
			_ctrl ctrlsetPosition _pos;
			_ctrl ctrlCommit 0;
		} foreach (
			[
				IDC_RSCDISPLAYARSENAL_LINETABLEFT,
				IDC_RSCDISPLAYARSENAL_FRAMELEFT,
				IDC_RSCDISPLAYARSENAL_BACKGROUNDLEFT
			] +	_idcSort
		);
		
		{
			_ctrl = _display displayctrl _x;
			_pos = (ctrlPosition _ctrl);
			_pos set [0, _posXListLeft];
			_ctrl ctrlsetPosition _pos;
			_ctrl ctrlCommit 0;
		} foreach [
            IDC_RSCDISPLAYARSENAL_LINETABRIGHT,
            IDC_RSCDISPLAYARSENAL_FRAMERIGHT,
            IDC_RSCDISPLAYARSENAL_BACKGROUNDRIGHT,
			IDC_AMMO_LIST_MAGAZINES+IDC_RSCDISPLAYARSENAL_SORT,
			IDC_AMMO_LIST_MAGAZINES+IDC_RSCDISPLAYARSENAL_LIST
        ];
		
		//removemissioneventhandler ["draw3D",BIS_fnc_arsenal_draw3D];

		_target = (missionnamespace getvariable ["BIS_fnc_arsenal_target",player]);
		_cam = uinamespace getvariable ["BIS_fnc_arsenal_cam",objnull];
		_camData = [getposatl _cam,(getposatl _cam) vectorfromto (getposatl _target)];
		_cam cameraeffect ["terminate","back"];
		camdestroy _cam;

		//--- Select correct weapon based on animation
		_center = (missionnamespace getvariable ["BIS_fnc_arsenal_center",player]);

	};
	
	case "CreateWeaponLists":{
		params["_display"];
		
		pr _loadout = UINamespace getVariable "jn_objectTo_loadout";
		

		{
			_x params ["_turretPath", "_turretDisplayName", "_turretData"];

			pr _index = _foreachindex;
			
			pr _ctrlList = _display displayctrl (IDC_RSCDISPLAYARSENAL_LIST + _index);
			lbClear _ctrlList;
			
			{
				_x params["_weaponDisplayName", "_dataWeapon"];
				pr _index = _ctrlList lbadd _weaponDisplayName;
				_ctrlList lbSetData [_index, str [_turretPath,_dataWeapon]];
				
			}foreach _turretData;
			
			
		} forEach _loadout;
		
	};
	
	case "SelectWeapon":{
		params ["_display","_ctrlListLeft","_index"];
		
		
		
		pr _ctrlListRight = _display displayctrl (IDC_RSCDISPLAYARSENAL_LIST + IDC_AMMO_LIST_MAGAZINES);
		lbClear _ctrlListRight;
		
        {
            pr _ctrl = _display displayctrl _x;
            _ctrl ctrlsetfade 0;
            _ctrl ctrlcommit FADE_DELAY;
        } foreach [
            IDC_RSCDISPLAYARSENAL_LINETABRIGHT,
            IDC_RSCDISPLAYARSENAL_FRAMERIGHT,
            IDC_RSCDISPLAYARSENAL_BACKGROUNDRIGHT
        ];
		
		{
			pr _ctrlList = _display displayctrl (_x + IDC_AMMO_LIST_MAGAZINES);
			_ctrlList ctrlenable true;
			_ctrlList ctrlsetfade 0;
			_ctrlList ctrlcommit FADE_DELAY;
		} foreach [IDC_RSCDISPLAYARSENAL_LIST,IDC_RSCDISPLAYARSENAL_LISTDISABLED,IDC_RSCDISPLAYARSENAL_SORT];
		
		pr _curselLeft = lbcursel _ctrlListLeft;
		pr _dataStr = _ctrlListLeft lbdata _curselLeft;
		
		pr _data = if(lbSize _ctrlListLeft == 0)then{["nil",[]]}else{parseSimpleArray _dataStr};
		
		pr _turretPath = _data select 0;
		
		{
			_x params["_turretMagazine","_turretMagazineDisplayName","_turretMagazineSize","_turretMagazineSizeMax","_turretMagazineCfgSize","_isPylon"];
			
			pr _index = _ctrlListRight lbadd MAGAZINE_TEXT(_turretMagazineDisplayName,_turretMagazineSize,_turretMagazineSizeMax);
			_ctrlListRight lbSetData [_index, str [_turretPath,_x]];
		}foreach (_data select 1);
		
	};
	
	case "SelectMagazine":{
		_this spawn{
			params ["_display","_ctrlListRight"];
			pr _objectTo = UINamespace getVariable "jn_objectTo";
			pr _objectFrom = UINamespace getVariable "jn_objectFrom";
			
			pr _curselRight = lbcursel _ctrlListRight;
			
			
			pr _dataStr = _ctrlListRight lbdata _curselRight;
			pr _data = parseSimpleArray _dataStr;
			pr _turretPath = _data select 0;
			(_data select 1) params["_turretMagazine","_turretMagazineDisplayName","_turretMagazineSize","_turretMagazineSizeMax","_turretMagazineCfgSize","_isPylon","_turretPath"];
			
			if(_turretMagazineSize != _turretMagazineSizeMax)then{
				pr _cargo = _objectFrom call jn_fnc_ammo_getCargo;
				pr _amount = _turretMagazineCfgSize;
				if(_amount + _turretMagazineSize>_turretMagazineSizeMax)then{_amount = _turretMagazineSizeMax-_turretMagazineSize};
				
				pr _cost = _turretMagazine call JN_fnc_ammo_getCost;
				pr _fullRearm = true;
				if(_cost * _amount > _cargo)then{_amount = floor(_cargo / _cost); _fullRearm = false;};
				
				if(_amount == 0)exitWith{};
				pr _costTotal = ROUND_TO(_cost * _amount,1);
				pr _amountLeft = ROUND_TO(_cargo - _costTotal,1);
			
				pr _status = [format[
					"%1 rearm magazine<br />Cost:%2 points<br />Points left after rearm:%3",
					["partly","full"]select _fullRearm,
					_costTotal,
					_amountLeft
				], "Selected", "rearm", "cancel",_display,true,false] call BIS_fnc_guiMessage;
				if(!_status)exitWith{};
			
				//update ammo
				pr _turretMagazineSizeNew = _turretMagazineSize + _amount;
				(_data select 1) set [2,_turretMagazineSizeNew];
				_ctrlListRight lbsetdata [_curselRight,str _data];
				_ctrlListRight lbSetText [_curselRight, MAGAZINE_TEXT(_turretMagazineDisplayName,_turretMagazineSizeNew,_turretMagazineSizeMax)];
				
				if(_isPylon == -1)then{
					[_objectTo,_turretPath,_turretMagazine,_turretMagazineSizeNew,_turretMagazineCfgSize] call JN_fnc_ammo_set;
				}else{
					_objectTo setAmmoOnPylon [_isPylon, _turretMagazineSizeNew];
				};
				
				[_objectFrom, _amountLeft] call JN_fnc_ammo_setCargo;
				
			};
			_ctrlListRight lbSetCurSel -1; //select non so we can select it later again
		};
	};
	
	case "TabSelect":{
		params["_display","_index"];

		//show selected, disable others
		{
			_idc = _x;
			_active = _idc == _index;

			{
				_ctrlList = _display displayctrl (_x + _idc);
				_ctrlList ctrlenable _active;
				_ctrlList ctrlsetfade ([1,0] select _active);
				_ctrlList ctrlcommit FADE_DELAY;
			} foreach [IDC_RSCDISPLAYARSENAL_LIST,IDC_RSCDISPLAYARSENAL_LISTDISABLED,IDC_RSCDISPLAYARSENAL_SORT];

			_ctrlTab = _display displayctrl (IDC_RSCDISPLAYARSENAL_TAB + _idc);
			_ctrlTab ctrlenable !_active;

			if (_active) then {
				_ctrlList = _display displayctrl (IDC_RSCDISPLAYARSENAL_LIST + _idc);
				_ctrlLineTabLeft = _display displayctrl IDC_RSCDISPLAYARSENAL_LINETABLEFT;
				_ctrlLineTabLeft ctrlsetfade 0;
				_ctrlTabPos = ctrlposition _ctrlTab;
				_ctrlLineTabPosX = (_ctrlTabPos select 0) + (_ctrlTabPos select 2) - 0.01;
				_ctrlLineTabPosY = (_ctrlTabPos select 1);
				_ctrlLineTabLeft ctrlsetposition [
					safezoneX,//_ctrlLineTabPosX,
					_ctrlLineTabPosY,
					(ctrlposition _ctrlList select 0) - safezoneX,//_ctrlLineTabPosX,
					ctrlposition _ctrlTab select 3
				];
				_ctrlLineTabLeft ctrlcommit 0;
				ctrlsetfocus _ctrlList;
			};

			_ctrlIcon = _display displayctrl (IDC_RSCDISPLAYARSENAL_ICON + _idc);
			//_ctrlIcon ctrlsetfade ([1,0] select _active);
			_ctrlIcon ctrlshow _active;
			_ctrlIcon ctrlenable !_active;

			_ctrlIconBackground = _display displayctrl (IDC_RSCDISPLAYARSENAL_ICONBACKGROUND + _idc);
			_ctrlIconBackground ctrlshow _active;
		} foreach IDCS;

		//Show left list background
		{
			_ctrl = _display displayctrl _x;
			_ctrl ctrlsetfade 0;
			_ctrl ctrlcommit FADE_DELAY;
		} foreach [
			IDC_RSCDISPLAYARSENAL_LINETABLEFT,
			IDC_RSCDISPLAYARSENAL_FRAMELEFT,
			IDC_RSCDISPLAYARSENAL_BACKGROUNDLEFT
		];
		
		["SelectWeapon",[_display, _display displayctrl (IDC_RSCDISPLAYARSENAL_LIST + _index),_index]] call jn_fnc_ammo_gui;
	};

	case "KeyDown": {
        params["_display","_key","_shift","_ctrl","_alt"];
        _return = false;
        switch true do {
            case (_key == DIK_ESCAPE || {_key == DIK_A} || {_key == DIK_D} || {_key == DIK_W} || {_key == DIK_S}): {
                ["buttonClose",[_display]] spawn jn_fnc_arsenal;
                _return = true;
            };

            //--- Prevent opening the commanding menu
            case (_key == DIK_1);
            case (_key == DIK_2);
            case (_key == DIK_3);
            case (_key == DIK_4);
            case (_key == DIK_5);
            case (_key == DIK_1);
            case (_key == DIK_7);
            case (_key == DIK_8);
            case (_key == DIK_9);
            case (_key == DIK_0);

            //--- Tab to browse tabs
            case (_key == DIK_TAB): {
            };



            //--- Save
            case (_key == DIK_S): {
                
            };
            //--- Open
            case (_key == DIK_O): {
                
            };

            //--- Vision mode
            case (_key in (actionkeys "nightvision") && !_inTemplate): {
                _mode = missionnamespace getvariable ["BIS_fnc_arsenal_visionMode",-1];
                _mode = (_mode + 1) % 3;
                missionnamespace setvariable ["BIS_fnc_arsenal_visionMode",_mode];
                switch _mode do {
                    //--- Normal
                    case 0: {
                        camusenvg false;
                        false setCamUseTi 0;
                    };
                    //--- NVG
                    case 1: {
                        camusenvg true;
                        false setCamUseTi 0;
                    };
                    //--- TI
                    default {
                        camusenvg false;
                        true setCamUseTi 0;
                    };
                };
                playsound ["RscDisplayCurator_visionMode",true];
                _return = true;

            };
        };
        _return
    };
	
	
	/////////////////////////////////////////////////////////////////////////////////////////// Externaly called
	case "Open":{
		params["_vehicleFrom","_vehicleTo"];
		diag_log ["AMMO open interface(we use arsenal interface)",_vehicleFrom,_vehicleTo];
		UINamespace setVariable ["jn_type","ammo"];
		UINamespace setVariable ["jn_objectFrom",_vehicleFrom];
		UINamespace setVariable ["jn_objectTo",_vehicleTo];
		UINamespace setVariable ["jn_objectTo_loadout",_vehicleTo call JN_fnc_ammo_getLoadout];
		
        ["Open",[nil,nil,player,false]] call bis_fnc_arsenal;
	};
	
	

	case "Close":{};

	///////////////////////////////////////////////////////////////////////////////////////////
	default {
		["Error: wrong input given '%1' for mode '%2'",_this,_mode] call BIS_fnc_error;
	};
};


