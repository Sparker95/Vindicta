/*
Used to add a new group to the garrison.

if _subcatID and _classID are specified, the group composition will be taken from the template.
if _classID == -1, a random group will be chosen from this subcategory.

or _subcatID can be an array with [_catID, _subcatID, _classID] for each unit in this array.
if _classID == -1, random class will be selected for this unit.
*/

#include "garrison.hpp"

params ["_lo", "_template", ["_subcatID", 0, [0, []]], "_classID", "_groupType", ["_returnArray", []], ["_debug", true]];

private _typesInput = [];
private _typesNoCrew = []; //Array of [_catID, _subcatID, _class]

if(typeName _subcatID == "SCALAR") then
{
	private _catID = T_GROUP;
	//Check validity of IDs
	private _valid = false;
	if(_classID == -1) then
	{
		if(([_template, _catID, _subcatID, 0] call t_fnc_isValid)) then
		{
			_valid = true;
		};
	}
	else
	{
		if(([_template, _catID, _subcatID, _classID] call t_fnc_isValid)) then
		{
			_valid = true;
		};
	};

	if(!_valid) exitWIth {
		diag_log format ["fn_addNewGroup.sqf: garrison: %1, error: wrong group classname data: %2", _lo getVariable ["g_name", ""], [_catID, _subcatID, _classID]];
	};

	//If a random class was requested to be added
	private _classFromTemplate = 0;
	if(_classID == -1) then
	{
		private _classData = [_template, _catID, _subcatID] call t_fnc_selectRandom;
		_classID = _classData select 1;
		_classFromTemplate = _classData select 0;
	}
	else
	{
		_classFromTemplate = [_template, _catID, _subcatID, _classID] call t_fnc_select;
	};

	if(typeName _classFromTemplate == "ARRAY") exitWith //If inside the template is not a config entry but an array with types
	{
		_typesInput = _classFromTemplate;
		diag_log format ["Class from template is an array: %1", _classFromTemplate];
	};

	//diag_log format ["class from template is: %1", _classFromTemplate];

	//Get units data from the config file
	private _types = [];
	private _unitClassName = "";
	private _count = count _classFromTemplate - 1;
	for "_i" from 0 to _count do
	{
		private _item = _classFromTemplate select _i;
		if (isClass _item) then
		{
			_unitClassName = getText(_item >> "vehicle");
			private _unitClassification = [_template, _unitClassName] call t_fnc_find;
			//diag_log format ["Classname: %1, %2", _unitClassName, _unitClassification];
			if(!(_unitClassification isEqualTo [])) then //If the unit's classname was found
			{
				private _newUnitData = _unitClassification select 0;
				_typesNoCrew pushback ((_newUnitData select [0, 2]) + [_unitClassName]);
			}
			else
			{
				diag_log format ["fn_addNewGroup.sqf: garrison: %1, unit class name was not found in template: %2. Ignoring unit.", _lo getVariable ["g_name", ""], _unitClassName];
			};
		};
	};
}
else
{
	_typesInput = _subcatID; //Get an array with types from the input parameter.
};

//If an array was specified as input or inside the template, process it
if(count _typesInput > 0) then
{
	private _catID = 0;
	private _subcatID = 0;
	private _classID = 0;
	private _class = "";
	//Check given classes, choose random ones where -1 for class was given
	{

		private _newUnitData = _x;
		_catID = _newUnitData select 0;
		_subcatID = _newUnitData select 1;
		_classID = _newUnitData select 2;


		private _valid = false;
		if(_classID == -1) then
		{
			if(([_template, _catID, _subcatID, 0] call t_fnc_isValid)) then
			{
				_valid = true;
			};
		}
		else
		{
			if(([_template, _catID, _subcatID, _classID] call t_fnc_isValid)) then
			{
				_valid = true;
			};
		};

		if(!_valid) then {
			diag_log format ["fn_addNewGroup.sqf: garrison: %1, error: wrong classname data for unit: %2. Ignoring unit.", _lo getVariable ["g_name", ""], _newUnitData];
		}
		else
		{
			//If a random class was requested to be added
			if(_classID == -1) then
			{
				private _classData = [_template, _catID, _subcatID] call t_fnc_selectRandom;
				_class = _classData select 0;
			}
			else
			{
				_class = [_template, _catID, _subcatID, _classID] call t_fnc_select;
			};
			_typesNoCrew pushBack [_catID, _subcatID, _class];
		};
	} forEach _typesInput;
};

//Assign crew to all vehicles
private _typesWithCrew = [];
{
	private _unitData = _x;
	_typesWithCrew pushBack _unitData;
	private _catID = _unitData select 0;
	private _subcatID = _unitData select 1;
	private _class = _unitData select 2;
	if (_catID == T_VEH) then //If adding a vehicle, also add its crew
	{
		private _crewClass = "";
		private _fullCrew = [_class] call gar_fnc_aux_getFullCrew;
		//diag_log format ["Vehicle: %1 crew: %2", _unitClassName, _fullCrew];
		private _np = _fullCrew select 0; //Number of pilots or drivers
		private _ncp = count (_fullCrew select 1); //number of copilots
		private _nt = count (_fullCrew select 2); //Number of turrets
		call //Check what kind of crew is needed for this vehicle
		{
			if(_subcatID in T_VEH_need_crew) exitWith //Some armored vehicle needs crewmen
			{
				_crewClass = [_template, T_INF, T_INF_crew, 0] call t_fnc_select;
				for "_j" from 0 to (_np + _ncp + _nt - 1) do
				{
					_typesWithCrew pushBack [T_INF, T_INF_crew, _crewClass];
				};
			};
			if(_subcatID in T_VEH_need_heli_crew) exitWith //Helicopter crew is needed. Pilot and copilot get pilot_heli classes, gunners get crew_heli classes.
			{
				_crewClass = [_template, T_INF, T_INF_pilot_heli, 0] call t_fnc_select;
				for "_j" from 0 to (_np + _ncp  - 1) do
				{
					_typesWithCrew pushBack [T_INF, T_INF_pilot_heli, _crewClass];
				};
				_crewClass = [_template, T_INF, T_INF_crew_heli, 0] call t_fnc_select;
				for "_j" from 0 to (_nt  - 1) do
				{
					_typesWithCrew pushBack [T_INF, T_INF_crew_heli, _crewClass];
				};
			};
			if(_subcatID in T_VEH_need_plane_crew) exitWith //Plane pilots are needed
			{
				_crewClass = [_template, T_INF, T_INF_pilot, 0] call t_fnc_select;
				for "_j" from 0 to (_np + _ncp + _nt - 1) do
				{
					_typesWithCrew pushBack [T_INF, T_INF_pilot, _crewClass];
				};
			};
			if(_subcatID in T_VEH_static) exitWith //Static vehicles will have riflemen assigned
			{
				_crewClass = [_template, T_INF, T_INF_pilot, 0] call t_fnc_select; //todo replace pilots with riflemen
				for "_j" from 0 to (_np + _ncp + _nt - 1) do
				{
					_typesWithCrew pushBack [T_INF, T_INF_pilot, _crewClass]; //T_INF_rifleman, 0];
				};
			};
			if(_subcatID in T_VEH_need_basic_crew) exitWith //MRAPs and gunboats will have riflemen as drivers and gunners
			{
				_crewClass = [_template, T_INF, T_INF_rifleman, 0] call t_fnc_select;
				for "_j" from 0 to (_np + _ncp + _nt - 1) do
				{
					_typesWithCrew pushBack [T_INF, T_INF_rifleman, _crewClass];
				};
			};
			//Else add riflemen as crew
			_crewClass = [_template, T_INF, T_INF_rifleman, 0] call t_fnc_select;
			for "_j" from 0 to (_np + _ncp + _nt - 1) do
			{
				_typesWithCrew pushBack [T_INF, T_INF_rifleman, _crewClass];
			};
		};
	};
} forEach _typesNoCrew;


//diag_log format ["types with crew: %1", _typesWithCrew];

//Add it to the queue
private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_ADD_NEW_GROUP, [_typesWithCrew, _groupType], _returnArray];

private _hThread = _lo getVariable ["g_threadHandle", nil];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID