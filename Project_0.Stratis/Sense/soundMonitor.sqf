#include "Sense.hpp"

/*
This is the sound monitor module. It processes sounds produced by units firing their weapons.
The main purpose of this is to warn the HQ and all locations that are not spawn of enemy presense when enemy fires a weapon.
*/

/*
Useful cfgAmmo classes:
BulletBase - bullets
ShellBase - tank, ifv cannons, also mortars
GrenadeBase - 40mm grenades
*/

/*
fired event handler data:
unit: Object - Object the event handler is assigned to 
weapon: String - Fired weapon 
muzzle: String - Muzzle that was used 
mode: String - Current mode of the fired weapon
ammo: String - Ammo used 
magazine: String - magazine name which was used
(Since Arma 2 OA)
projectile: Object - Object of the projectile that was shot out
(Since Arma 3 v 1.65)
gunner: Object - gunner whose weapons are firing.
*/

/*
hit data for different ammo:
handguns: ~5
rifles: ~10
12.7mm: 30..50
40mm: 70-150 (Marshall)
82mm: 165 (mortar)
120mm: 250-500 (merkava)
155mm: 165..340 (mortar)
230mm: 300 (MLRS Sandstorm)

Radius is calculated based on hit value for ammo.
handguns and rifles: ~1km
light mortar: ~5km
heavy mortars and tanks: ~10km
*/

sense_fnc_soundMonitor_create =
{
	/*
	Creates sound monitor object. Typically it is created per every side/faction.
	
	Parameters:
		none
		
	Return value:
		object - the soundMonitor object. Manipulate it with other functions.
	*/
	
	//Create a logic object
	private _o = groupLogic createUnit ["LOGIC", [55, 55, 55], [], 0, "NONE"];
	_o setVariable ["s_units", [], false]; //Units this sound monitor will be checking
	//_o setVariable ["s_hearingObjects", [], false]; //Objects that can hear the units. Now these are locations, but this might change
	_o setVariable ["s_hearingObjects", allLocations, false]; //todo add a func. to set the hearing objects
	_o setVariable ["s_time", time, false]; //Time is stored to measure time between each call to the  'process...' function
	_o setVariable ["s_locatedSounds", [], false]; //Sounds that have been located
	_o
};

sense_fnc_soundMonitor_addUnit =
{
	/*
	Adds unit to the soundMonitor object.
	Call this on a unit(infantry or vehicle) at the server if you want to monitor gunshots produced by it.
	
	Parameters:
		_unit - the unit object
		_soundMonitor - the sound monitor object that will handle this unit.
	
	Return value:
		nothing
	*/
	params ["_soundMonitor", "_unit"];
	_unit setVariable ["s_firedLight", 0, false]; //Counter for light weapons, like rifles ad handguns
	_unit setVariable ["s_firedMedium", 0, false]; //12mm and above
	_unit setVariable ["s_firedHeavy", 0, false]; //Above 40mm or so
	_unit setVariable ["s_firedArtillery", 0, false]; //Artillery
	private _eh = _unit getVariable ["s_firedEh", -1];
	private _unitType = 0; //0 - inf, 1 - veh, 2 - mortar
	private _silenced = false;
	if(_eh == -1) then
	{
		if(_unit isKindOf "Man") then
		{
			_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_infFired_eh}];
			_silenced = _unit call misc_fnc_currentWeaponSilenced;
			_unitType = 0;
		}
		else
		{
			//Check if the unit is a mortar
			if((_unit isKindOf "StaticMortar") || ((typeof _unit) in mortarClassnames)) then
			{
				_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_mortarFired_eh}];
				_unitType = 2;
			}
			else
			{
				_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_vehFired_eh}];
				_unitType = 1;
			};
			
			//Check if it's a plane or helicopter to monitor its emitted sound when its engine is on
			if (_unit isKindOf "Air") then
			{
				if(_unit isKindOf "Helicopter" && !(_unit isKindOf "UAV_01_base_F")) then
				{
					//
				};
				if(_unit isKindOf "Plane" && !(_unit isKindOf "UAV")) then
				{
					//
				};
			};
		};
		_unit setVariable ["s_firedEh", _eh];
		_unit setVariable ["s_silenced", _silenced, false]; //Is the unit using a silenced weapon? This variable will be updated every time the sound monitor function is called.
		//Add unit to the units array of the soundMonitor object
		private _units = _soundMonitor getVariable ["s_units", []];
		_units pushBack _unit;
		
	}
	else
	{
		diag_log format ["sense_fnc_initUnitSoundMonitor: error: attempt to launch second unitSoundMonitor script: %1", _unit];
	};
};

sense_fnc_soundMonitor_removeUnit =
{
	/*
	Removes unit from the sound monitor object.
	
	Parameters:
		_unit - 
		_soundMonitor - 
	
	Return value:
		success - bool, if the operation was completed successfully
	*/
	params ["_soundMonitor", "_unit"];
	private _units = _soundMonitor getVariable ["s_units", []];
	private _id = _units find _unit;
	if (_id != -1) exitWith
	{
		_units deleteAt _id;
		private _eh = _unit getVariable ["s_firedEh", -1];
		if(_eh != -1) then
		{
			_unit removeEventHandler ["Fired", _eh];
			_unit setVariable ["s_firedEH", nil, false];
		};
		true
	};
	false
};

//It's probably not needed now!
sense_fnc_soundMonitorThreadClient =
{
	/*
		A thread spawned by each client(player) to monitor player's firing
	*/
};

sense_fnc_soundMonitor_process =
{
	/*
	This function processes the amount of shots fired and sound produced by all units attached to the sound monitor object. Call it in a loop with fixed intervals.
	
	Parameters:
		_soundMonitor - the sound monitor object
		// _processData - do you want the function also to process data about gunshots?
			If true, then the function will return array with all the gunshots in following format(see return value):
			
	Return vaue:
		Nothing
		//If _processData==true:
			_sounds - array of:
				[_x, _y, _size, _soundType]
					_x, _y - coordinates of the source
					_size - the size of the area
					_soundType - the type of sound source. See Sense.hpp
		//If _processData==false:
		//	[] - empty array
	*/
	params ["_soundMonitor"];
	//Update the time variable
	private _dt = time - (_soundMonitor getVariable ["s_time", 0]); //Time passed between prev. call to this function
	_soundMonitor setVariable ["s_time", time, false];
	private _locatedSounds = _soundMonitor getVariable ["s_locatedSounds", []];
	
	//The constant used to calculate dispersion of located soun
	private _dCoef = (200/1000);
	
	//Check all the units
	private _units = _soundMonitor getVariable ["s_units", []];
	private _i = 0;
	private _hearingObjects = _soundMonitor getVariable ["s_hearingObjects", []];
	while {_i < count _units} do
	{
		private _unit = _units select _i;
		private _active = true;
		//If the unit is dead or has been despawned, delete it from this sound monitor object
		
		//If the unit hasn't been removed from the array

		private _silenced = _unit getVariable ["s_silenced", false];
		//diag_log format ["Silenced: %1", s_silenced];
		//Read how many shots have been fired by the unit. Normalize them by the sleep time to get fires per second.
		//Reset the counters
		private _cl = (_unit getVariable ["s_firedLight", 0]); // /_dt; //Counter for light weapons
		_unit setVariable ["s_firedLight", 0];
		private _cm = (_unit getVariable ["s_firedMedium", 0]); // /_dt; //Medium
		_unit setVariable ["s_firedMedium", 0];
		private _ch = (_unit getVariable ["s_firedHeavy", 0]); // /_dt; //Heavy
		_unit setVariable ["s_firedHeavy", 0];
		private _ca = (_unit getVariable ["s_firedArtillery", 0]); // /_dt; //Artillery
		_unit setVariable ["s_firedArtillery", 0];
		
		//If the unit has produced any sound
		if((_cl > 0 || _cm > 0 || _ch > 0 || _ca > 0) && !_silenced) then
		{			
			private	_countST = [_cl, _cm, _ch, _ca]; //Count of sound types: light, med., heavy, art.
			diag_log format ["sense_fnc_processSoundMonitor: sounds produced by unit %1: %2", _unit, _countST];
			private _distST = [1000, 2000, 8000, 6000]; //Hearing distance for sound types
			{ //forEach _countST;
				private _soundType = _foreachindex;
				private _dMax = _distST select _soundType;
				private _count = _x; //Count of sounds of this type produced by the unit
				if (_count > 0) then
				{
					private _dMin = 666666;
					private _dMin2 = 666666;
					//Find objects that can hear sounds from this unit
					{ //forEach _hearingObjects;
						private _d = _x distance2D _unit;
						if(_d < _dMin) then
						{
							_dMin2 = _dMin;
							_dMin = _d;
						};
						_t = _d / 340; //Sound travel time
						//Notify the object of produced sound
						if(_d < _dMax) then
						{
							[_x, _t, _soundType] spawn
							{
								params ["_loc", "_t", "_st"];
								sleep _t;
								[_loc, _st] call loc_fnc_handleSound;
							};
						};
					} forEach _hearingObjects;
					
					/*
					If the sound has been heard by two objects, we assume that the position of sound source can be triangulated.
					Todo check if the objects have communication with the HQ
					*/
					if(_dMin2 < _dMax || _dMin < 0.3*_dMax) then
					{
						//diag_log format ["dmin2= %1", _dmin2];
						private _3sigma = _dCoef*_dMin;
						private _posUnit = getPosWorld _unit;
						private _ux = _posUnit select 0;
						private _uy = _posUnit select 1;
						private _mx = _ux + (random [-_3sigma, 0, _3sigma]); //Measured coordinates
						private _my = _uy + (random [-_3sigma, 0, _3sigma]);
						_locatedSounds pushBack [_mx, _my, _3sigma, _count, _soundType];
					};
				};
			} forEach _countST;
		};
		
		//If unit is infantry, check if it's using silenced weapon
		if(_unit isKindOf "Man") then
		{
			_unit setVariable ["s_silenced", _unit call misc_fnc_currentWeaponSilenced, false];
		};
			
		if(isNull _unit || !alive _unit) then
		{
			[_unit, _soundMonitor] call sense_fnc_soundMonitor_removeUnit;
			_active = false;
		}
		else
		{
			_i = _i + 1;
		};
	};
	_soundMonitor setVariable ["s_locatedSounds", _locatedSounds, false]; 
};

sense_fnc_soundMonitor_getActiveClusters =
{
	/*
		Returns clusters with sounds that have been located since previous call to this function.
		
		Parameters:
			_soundMonitor - the sound monitor object
		Return value: _soundsOut
			array of:
			[_cluster, _soundCount]
				_cluster - cluster array
				_soundCount - [light, medium, heavy, artillery, ...] array with counts of sounds of specific type emitted
	*/
	params ["_soundMonitor"];
	private _locatedSounds = _soundMonitor getVariable ["s_locatedSounds", []];
	//diag_log format ["_locatedSounds: %1", _locatedSounds];
	
	//Convert located sounds to clusters
	private _locatedSoundsClusters = [];
	private _id = 0;
	{
		diag_log format ["_locatedSounds[%1]: %2", _foreachindex, _x];
		private _sx = _x select 0;
		private _sy = _x select 1;
		private _size = _x select 2;
		//private _count = _x select 3;
		//private _type = _x select 4;
		_locatedSoundsClusters pushBack ([_sx - _size, _sy - _size, _sx + _size, _sy + _size, _id] call cluster_fnc_newCluster);
		_id = _id + 1;
	} forEach _locatedSounds;
	//diag_log format ["Clusters from sounds: %1", _locatedSoundsClusters];
	
	//Find bigger clusters
	private _soundClusters = [_locatedSoundsClusters, 5] call cluster_fnc_findClusters;
	//diag_log format ["Clusters from clusters: %1", _soundClusters];
	private _soundClustersOut = [];
	{
		private _soundCluster = _x;
		private _soundCount = [0, 0, 0, 0, 0, 0];
		private _ids = _x select 4; //Array with IDs of initial sound sources
		//Sum up all the sound counts from initial sound sources
		{ //forEach _ids;
			private _id = _x;
			private _ls = _locatedSounds select _id;
			private _count = _ls select 3;
			private _type = _ls select 4;
			private _c = _soundCount select _type;
			_c = _c + _count;
			_soundCount set [_type, _c];
		} forEach _ids;
		_soundCluster set [4, []]; //Clear the array of IDs for big clusters because we don't need the IDs any more
		_soundClustersOut pushBack [_soundCluster, _soundCount];
	} forEach _soundClusters;
	
	//Clear the _locatedSounds array.
	_soundMonitor setVariable ["s_locatedSounds", [], false];
	
	//Return value
	_soundClustersOut
};
