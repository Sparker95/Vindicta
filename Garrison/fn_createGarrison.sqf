/*
Creates an empty garrison object
*/

/*
Current structure:

Logic object's variables:
g_inf - an array of arrays like:
[classname, objectHandle, unitID, groupID]
	classname - the class name from the template
	objectHandle - the handle to this object if it's spawned, or objNull if it's not spawned
	unitID - unique ID of a unit inside this garrison. Used to reference this exact unit in other functions.
	groupID - the ID of the group this unit is assigned to.

g_veh - an array of arrays like:
[classname, objectHandle, unitID, groupID]

g_drone - an array of arrays like:
[classname, objectHandle, unitID, groupID]
	group - the group drone's imaginary crew is assigned to

g_group - an array of arrays like:
[_units, _groupHandle, _groupID, _groupType]
	_units - an array of unit data arrays in the form:
		[_unitData, _vehicleRole]
			_unitData = [_catID, _subcatID, _unitID]
				_unitID - the unitID of this unit or -1 if it's dead.
			_vehicleRole = [_vehicleData, _role, _turretPath]
				_vehicleData = [_catID, _subcatID, _unitID] of the vehicle
				_role - vehicle role (see initVariablesServer.sqf for vehicle roles)
				_turretPath - the turret path(if unit is assigned as turret) or [] if not

	_groupHandle - object of type Group if group has been spawned or grpNull if group isn't spawned
	_groupID - the ID of the group
	_groupType - the type of the groop. See initVariablesServer for group types.
*/

private _lo = groupLogic createUnit ["LOGIC", [0, 0, 0], [], 0, "NONE"]; //logic object

//==== Initialize infantry garrison ====
_subcat = [];
_subcat set [T_INF_SIZE-1, nil]; //Make an empty array first
private _subcatID = 0;
private _a = [];
while {_subcatID < T_INF_SIZE} do
{
	_subcat set [_subcatID, []];
	_subcatID = _subcatID + 1;
};

_lo setVariable ["g_inf", _subcat, false];

//==== Initialize vehicle garrison ====
_subcat = [];
_subcat set [T_VEH_SIZE-1, nil]; //Make an empty array first
private _subcatID = 0;
private _a = [];
while {_subcatID < T_VEH_SIZE} do
{
	_subcat set [_subcatID, []];
	_subcatID = _subcatID + 1;
};

_lo setVariable ["g_veh", _subcat, false];


//==== Initialize drone garrison ====
_subcat = [];
_subcat set [T_DRONE_SIZE-1, nil]; //Make an empty array first
private _subcatID = 0;
private _a = [];
while {_subcatID < T_DRONE_SIZE} do
{
	_subcat set [_subcatID, []];
	_subcatID = _subcatID + 1;
};

_lo setVariable ["g_drone", _subcat, false];

//==== Initialize the template for the garrison ====

_lo setVariable ["g_template", []]; //todo maybe template isn't even needed here?
_lo setVariable ["g_side", WEST];

//==== Initialize groups for the garrison ====

_lo setVariable ["g_groups", []];

//==== Initialize other variables for the garrison ====

_lo setVariable ["g_spawned", false, false];
_lo setVariable ["g_active", false, false]; //Means that it can or can't spawn other garrison
_lo setVariable ["g_threadHandle", scriptNull, false];
_lo setVariable ["g_threadQueue", [], false]; //Message queue to pass requests
_lo setVariable ["g_name", "Noname garrison", false]; //Name of this garrison
_lo setVariable ["g_unitIDCounter", 0]; //Counter for unitID. Each time a new unit or group is added this counter will be increased so that we have unique unit ID's for units and groups.
_lo setVariable ["g_location", objNull]; //The location where from to request spawn positions
_lo setVariable ["g_alertState", G_AS_none]; //By default there is no alert state
_lo setVariable ["g_assignRequestID", 0]; //Counter used for IDs assigned to requests
_lo setVariable ["g_execRequestID", 0]; //Counter used for IDs of executed requests

//Return the logic object
_lo