AI_fnc_getConvoyState =
{
	params ["_so"];
	_so getVariable "AI_convoyState";
};

AI_fnc_setConvoyDestination =
{
	//Use it to change convoy's destination before it has arrived
	params ["_so", "_destPos"];
	_so setVariable ["AI_destPosChanged", true, false];
	_so setVariable ["AI_newDestPos", _destPos, false];
};
