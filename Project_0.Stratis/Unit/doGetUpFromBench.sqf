#include "..\OOP_Light\OOP_Light.h"
#include "..\Unit\Unit.hpp"

params [["_thisObject", "", [""]]];

private _data = GETV(_thisObject, "data");
private _unitObject = _data select UNIT_DATA_ID_OBJECT_HANDLE;

_unitObject enableAI "ALL"; 
//_unitObject setDir _newDir;  
_unitObject switchMove "AcrgPknlMstpSnonWnonDnon_AmovPercMstpSrasWrflDnon_getOutLow"; // Jump back on your feet!