#include "defineCommon.inc"

params["_object",["_text",""]];

pr _id = _object getVariable "jn_cancelAction_id";

if(isnil "_id")exitWith{};

_object setUserActionText [_id,  format["<t color='#FFA500'>%1 %2",localize "STR_JNC_ACT_CANCEL",_text]];

