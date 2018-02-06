private _unit = _this select 0; //: Object - Object the event handler is assigned to.

//private _hitSelection = _this select 1; //: String - Name of the selection where the unit was damaged. "" for over-all structural damage, "?" for unknown selections.

//private _damage = _this select 2; //: Number - Resulting level of damage for the selection.

private _source = _this select 3; //: Object - The source unit that caused the damage.

//private _projectile = _this select 4; //: String - Classname of the projectile that caused inflicted the damage. ("" for unknown, such as falling damage.)

//private _hitPartIndex = _this select 5; //: Number - Hit part index of the hit point, -1 otherwise.

private _instigator = _this select 6; //: Object - Person who pulled the trigger

//private _hitPoint = _this select 7;  //: String - hit point Cfg name

//diag_log format ["fn_EH_handleDamage.sqf: _unit: %1, _hitSelection: %2, _damage: %3, _source: %4, _projectile: %5, _hitPartIndex: %6, _instigator: %7, _hitPoint_ %8", _unit, _hitSelection, _damage, _source, _projectile, _hitPartIndex, _instigator, _hitPoint];

//diag_log format ["source type: %1", typeOf _source];

if ((side _source == side _unit) && /*(_projectile == "") &&*/ (isNull _instigator)) then
{
	0
}
else
{
	//diag_log format ["fn_EH_handleDamage.sqf: _unit: %1, _hitSelection: %2, _damage: %3, _source: %4, _projectile: %5, _hitPartIndex: %6, _instigator: %7, _hitPoint_ %8", _unit, _hitSelection, _damage, _source, _projectile, _hitPartIndex, _instigator, _hitPoint];
	_damage
};