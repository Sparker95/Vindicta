// Disables collision damage for vehicles
_this params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

/*
_array = ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"]; 
_str = ""; 
{ 
_str = _str + format ["%1: %2, ", _x, _this select _foreachindex]; 
} forEach _array; 
diag_log "Handle Damage:"; 
diag_log _str;
*/

if ((isNull _source) && {_projectile == ""} && {isNull _instigator}) then {
	//diag_log "  Ignored damage";
	0;
} else {
	nil;
};