#include "defineCommon.inc"

params ["_vehicle","_repairVehicle"];

pr _skill = _repairVehicle getVariable ["jn_repair_skill",1];
pr _data = _vehicle call jn_fnc_repair_getVehicleData;
pr _hitpoints = _data select VEHICLE_DATA_HITPOINTS;
pr _hitTypes = _data select VEHICLE_DATA_HITTYPES;
uiNamespace setVariable ["jn_repair_vehicle_data",_data];
uiNamespace setVariable ["jn_repair_vehicle",_vehicle];


pr _display = (uiNamespace getVariable ["RscStanceInfo", []]);
pr _icons = [];

{
	pr _hitpoint = _x;
	pr _hitType = _hitTypes select _forEachIndex;
	pr _skill_part = SKILL_REQUIRED_PART select _hitType;
	if(_skill>=_skill_part)then{
		pr _icon = _display ctrlCreate ["RscButton",-1];//we use a button for now TODO
		pr _pos = ctrlPosition _icon;
		_pos set [2,0.2];
		_icon ctrlSetPosition _pos;
		_icon ctrlCommit 0;
		_icon setVariable ["_index",_forEachIndex];
		_icons pushBack _icon;
	};
}forEach _hitpoints;

uiNamespace setVariable ["jn_repair_icons",_icons];

pr _draw3D = addMissionEventHandler ["Draw3D", {
	pr _icons = uiNamespace getVariable "jn_repair_icons";
	pr _vehicle = uiNamespace getVariable "jn_repair_vehicle";
	pr _vehicleData = uiNamespace getVariable "jn_repair_vehicle_data";
	pr _selections = _vehicleData select VEHICLE_DATA_SELECTIONS;
	pr _hitpoints = _vehicleData select VEHICLE_DATA_HITPOINTS;
	pr _hitTypes = _vehicleData select VEHICLE_DATA_HITTYPES;
	
	pr _array_pos = [];
	pr _closest = controlNull;
	pr _distance_closed = 10;
	pr _index_closest = -1;
	{
		pr _icon = _x;
		pr _index = _icon getVariable "_index";
		pr _selection = _selections select _index;
		pr _hitpoint = _hitpoints select _index;
		pr _hitType = _hitTypes select _index;
		pr _hitname = TYPE_PARTS select _hitType;
		pr _pos_selection = (_vehicle selectionPosition _selection);
		pr _moveUp = {
			{
				if(_x isEqualTo _pos_selection)exitWith{
					_pos_selection set [2,(_pos_selection select 2)+0.2];
					call _moveUp;
				};
			}foreach _array_pos;
			_array_pos pushBack _pos_selection;
		};
		call _moveUp;
		
		
		
		
		pr _pos = worldToScreen (_vehicle modelToWorld _pos_selection);
		if(!(_pos isEqualTo []))then{
			_pos set [0, (_pos select 0) - 0.1];
			_icon ctrlSetPosition _pos;
			_icon ctrlShow true;
			_icon ctrlCommit 0;
			_icon ctrlSetText (format["%1 %2",_hitname, round ((_vehicle getHitPointDamage _hitpoint) *100)]+"%");
			
			pr _distance = _pos distance [0.5 - 0.1, 0.5];
			if(_distance < 0.1)then{
				
				if(_distance<_distance_closed)then{
					_distance_closed = _distance;
					_closest = _icon;
					_index_closest = _index;
				};
			};
		}else{
			_icon ctrlShow false;
		};
	}forEach _icons;
	//uiNamespace setVariable ["jn_repair_selected_icon",_closest];
	uiNamespace setVariable ["jn_repair_selected_index",_index_closest];
	
	//color icons
	{
		if(_closest isEqualTo _x)then{
			_x ctrlSetTextColor COLOR_ORANGE;
		}else{
			_x ctrlSetTextColor COLOR_WHITE;
		};
	}forEach _icons;
	

}];

uiNamespace setVariable ["jn_repair_draw3d",_draw3D];


//create select action

pr _script =  {
	params ["_vehicle"];
	
	pr _index = uiNamespace getVariable ["jn_repair_selected_index",-1];
	if(_index == -1)exitWith{hint "nothing selected";};
	
	pr _data = uiNamespace getVariable "jn_repair_vehicle_data";

	[_vehicle, player,_data,_index] call JN_fnc_repair_repairHitpoint;
	
};
pr _conditionActive = {
	params ["_vehicle"];
	alive player;
};
pr _conditionColor = {
	params ["_vehicle"];
	pr _index = uiNamespace getVariable ["jn_repair_selected_index",-1];
	_index != -1;
};

pr _removeScript = {
	removeMissionEventHandler ["Draw3D",(uiNamespace getVariable ["jn_repair_draw3d",-1])];
	uiNamespace setVariable ["jn_repair_draw3d",nil];
	{
		ctrlDelete _x;
	}forEach (uiNamespace getVariable ["jn_repair_icons",[]]);
};
			
[_script,_conditionActive,_conditionColor,_vehicle,false,5,_removeScript] call jn_fnc_common_addActionSelect;


