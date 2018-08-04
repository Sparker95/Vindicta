/*
Creates default crew for a vehicle.
The vehicle must be in a group.


Author: Sparker 2.08.2018
*/

#include "Unit.hpp"
#include "..\OOP_Light\OOP_Light.h"

params [ ["_thisObject", "", [""]], ["_template", [], [[]]] ];

private _data = GET_VAR(_thisObject, "data");

// Check if the unit is in a group
private _group = _data select UNIT_DATA_ID_GROUP;
if (_group == "") exitWith { diag_log format ["[Unit::createDefaultCrew] Error: cannot create crew for a unit which has no group: %1", CALL_METHOD(_thisObject, "getDebugData", [])] };

private _className = _data select UNIT_DATA_ID_CLASS_NAME;
private _catID = _data select UNIT_DATA_ID_CAT;
private _subcatID = _data select UNIT_DATA_ID_SUBCAT;
private _crewData = [_catID, _subcatID, _className] call t_fnc_getDefaultCrew;

{
	private _unitCatID = _x select 0; // Unit's category
	private _unitSubcatID = _x select 1; // Unit's subcategory
	private _unitClassID = _x select 2;
	private _args = [_template, _unitCatID, _unitSubcatID, _unitClassID, _group]; // ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]]
	private _newUnit = NEW("Unit", _args);
} forEach _crewData;