#include "..\OOP_Light\OOP_Light.h"
#include "..\Unit\Unit.hpp"

params [["_thisObject", "", [""]]];

private _data = GETV(_thisObject, "data");
private _unitObject = _data select UNIT_DATA_ID_OBJECT_HANDLE;

if (alive _unitObject) then {
	_unitObject enableAI "ALL"; 
	//_unitObject setDir _newDir;  
	_unitObject switchMove "AcrgPknlMstpSnonWnonDnon_AmovPercMstpSrasWrflDnon_getOutLow"; // Jump back on your feet!
	_unitObject doMove ((getPos _unitObject) getPos [2.0, direction _unitObject]); // Move forward a bit
};

// Make sure we terminate the bench script
private _data = GET_MEM(_thisObject, "data");
private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
private _hScriptBench = _objectHandle getVariable ["unit_hScriptBench", scriptNull];
if (!isNull _hScriptBench) then {terminate _hScriptBench;};