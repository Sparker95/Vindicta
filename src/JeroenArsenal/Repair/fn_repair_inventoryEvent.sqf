#include "defineCommon.inc"

#define TOOLKITSIZE 400


pr _count = {"ToolKit" isEqualTo _x}count (itemCargo backpackContainer player);
[player,_count * TOOLKITSIZE] call JN_fnc_repair_setCargoCapacity;


player addEventHandler ["InventoryOpened", {
	
	_h = _this spawn {
		params ["_unit", "_container"];
		disableSerialization;
		waitUntil { !(isNull (findDisplay 602)) };
		_display = (findDisplay 602);
		
		_ctrl_backpack = (_display displayctrl 619);
		_ctrl_ground = (_display displayctrl 632);
		_ctrl_crate = (_display displayctrl 640);
		_ctrls = [_ctrl_backpack,_ctrl_ground,_ctrl_crate];
		uiNamespace setVariable ["JN_event_Toolbox_ctrl",_ctrls];
		
		_container_backpack = backpackContainer player;
		_container_ground = if (cursorObject isKindOf "GroundWeaponHolder" && {cursorObject distance player <=3})then{cursorObject}else{getpos player nearestObject "GroundWeaponHolder"};
		_container_crate = _container;
		_containers = [_container_backpack,_container_ground,_container_crate];
		uiNamespace setVariable ["JN_event_Toolbox_container",_containers];
		
		_object_backpack = player;
		_object_ground = _container_ground;
		_object_crate = _container_crate;
		_objects = [_object_backpack,_object_ground,_object_crate];
		uiNamespace setVariable ["JN_event_Toolbox_object",_objects];
		
		uiNamespace setVariable ["JN_event_Toolbox_listSize",[-1,-1,-1]];
		
		pr _toolKitCounts = [];
		{
			_container = _x;
			_toolKitCounts pushBack ({"ToolKit" isEqualTo _x}count (itemCargo _container));
		}foreach _containers;
		uiNamespace setVariable ["JN_event_Toolbox_count",_toolKitCounts];
		
		_id = addMissionEventHandler ["EachFrame", {
			pr _ctrls = uiNamespace getVariable "JN_event_Toolbox_ctrl";
			pr _containers = uiNamespace getVariable "JN_event_Toolbox_container";
			pr _objects = uiNamespace getVariable "JN_event_Toolbox_object";
			pr _toolKitCounts = uiNamespace getVariable "JN_event_Toolbox_count";

			pr "_addedTo";
			pr "_removedFrom";
			{
				pr _container = _x;
				pr _count = {"ToolKit" isEqualTo _x}count (itemCargo _container);
				pr _countOld = _toolKitCounts select _forEachIndex;
				
				if(_count != _countOld)then{
					
					_toolKitCounts set [_forEachIndex,_count];
					if(_count > _countOld)then{_addedTo = _forEachIndex}else{_removedFrom = _forEachIndex};

				};
			}foreach _containers;
			
			if(!isnil "_addedTo" && {!isnil "_removedFrom"})then{
				pr _objectTo = _objects select _addedTo;
				pr _objectFrom = _objects select _removedFrom;
				pr _toolKitCountTo = _toolKitCounts select _addedTo;
				pr _toolKitCountFrom = _toolKitCounts select _removedFrom;
				
				pr _amountTo = _objectTo call JN_fnc_repair_getCargo;
				pr _amountFrom = _objectFrom call JN_fnc_repair_getCargo;
				
				[_objectTo,_toolKitCountTo * TOOLKITSIZE] call JN_fnc_repair_setCargoCapacity;
				[_objectFrom, _toolKitCountFrom * TOOLKITSIZE] call JN_fnc_repair_setCargoCapacity;
				
				pr _amount = TOOLKITSIZE;
				if(_amount>_amountFrom)then{_amount = _amountFrom};
				
				_amountTo = _amountTo + _amount;
				_amountFrom = _amountFrom - _amount;
				
				[_objectTo, _amountTo] call JN_fnc_repair_setCargo;
				[_objectFrom, _amountFrom] call JN_fnc_repair_setCargo;
			};
			
			{
				pr _ctrl = _x;
				pr _object = _objects select _foreachIndex;
				for "_i" from 0 to lbSize _ctrl do{
					pr _name = _ctrl lbText _i;
					if(_name isEqualTo "Toolkit")then{
						pr _amount = _object call JN_fnc_repair_getCargo;
						pr _cap = _object call JN_fnc_repair_getCargoCapacity;
						_ctrl lbSetText [_i, format["Toolkit [%1/%2]",_amount,_cap]];
					};
				}
			}foreach _ctrls;

		}];
		
		missionNamespace setVariable ["JN_event_Toolbox_id",_id];
	};
}];

player addEventHandler ["InventoryClosed", { 
	removeMissionEventHandler ["EachFrame", missionNamespace getVariable "JN_event_Toolbox_id"];
	missionNamespace setVariable ["JN_event_Toolbox_id",nil];
}];

