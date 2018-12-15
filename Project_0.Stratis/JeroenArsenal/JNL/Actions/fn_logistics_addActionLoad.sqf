params ["_object"];
diag_log ["addactionload"];
private _loadActionID = _object getVariable ["jnl_loadActionID",nil];

//Check if action exists already
if(!isnil "_loadActionID") then
{
	_object removeAction _loadActionID;
};

//Check if this vehicle can be loaded with JNL
if((_object call jn_fnc_logistics_getCargoType) == -1) exitWith {};

_loadActionID = _object addAction [
	"<img image='\A3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa' />  Load Cargo in Vehicle</t>",
	{ //Action script
		private _cargo = _this select 0;
		private _player = _this select 1;
		//Search for vehicles able to load cargo of this type
		private _nearestVehicle = objNull;
		private _nearestDistance = 7;
		{
			_distance = _x distance _cargo;

			if(_distance < _nearestDistance && !(_x isEqualTo _cargo) && isnull (attachedTo _x)) then
			{
				if(_x call jn_fnc_garage_getVehicleIndex != -1 && _x call jn_fnc_garage_getVehicleIndex != 5) then
				{
					_nearestVehicle = _x;
					_nearestDistance = _distance;
				};
			};
		} forEach vehicles;


		if(isNull _nearestVehicle) then
		{
			hint 'Bring vehicle closer';
		}
		else
		{
			private _nodeID = [_nearestVehicle, _cargo] call jn_fnc_logistics_canLoad;
			switch (_nodeID) do {
				case -4:
				{
					hint 'Can not load cargo: passengers have occupied cargo space!';
				};
				case -3:
				{
					hint 'This vehicle can not carry this cargo!';
				};
			    case -2:
			    {
			    	hint 'There is no space for this cargo!'
			    };
			    case -1:
			    {
			    	hint 'Can not load this type of cargo!';
			    };
			    default
			    {
			    	//[_nearestVehicle, _cargo, true] call jn_fnc_logistics_load;
			    	//Executing it on the server works better!
			    	[_nearestVehicle, _cargo, true, true] remoteexec ["jn_fnc_logistics_load", 2];
			    };
			};
		};
	},
	nil, 1, true, false, "", "isnull attachedTo _target && vehicle player == player;", 3.5, false, ""
];

_object setUserActionText [
	_loadActionID,
	"Load Cargo in Vehicle",
	"<t size='2'><img image='\A3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa'/></t>"
];

_object setVariable ["jnl_loadActionID", _loadActionID, false];

