#include "common.hpp"

CLASS("GameModeBase", "")

	VARIABLE("name");
	VARIABLE("spawningEnabled");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "unnamed");
		T_SETV("spawningEnabled", false);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	METHOD("init") {
		params [P_THISOBJECT];

		// Global flags
		gFlagAllCommanders = true; //false;
		// Main timer service
		gTimerServiceMain = NEW("TimerService", [0.2]); // timer resolution

		T_CALLM("preInitAll", []);

		if(IS_SERVER || IS_HEADLESSCLIENT) then {
			// Main message loop for garrisons
			gMessageLoopMain = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopMain, "setName", ["Main thread"]);

			// Global debug printer for tests
			private _args = ["TestDebugPrinter", gMessageLoopMain];
			gDebugPrinter = NEW("DebugPrinter", _args);

			// Message loop for group AI
			gMessageLoopGroupAI = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopGroupAI, "setName", ["Group AI thread"]);

			// Message loop for Stimulus Manager
			gMessageLoopStimulusManager = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopStimulusManager, "setName", ["Stimulus Manager thread"]);

			// Global Stimulus Manager
			gStimulusManager = NEW("StimulusManager", []);

			// Message loop for locations
			gMessageLoopLocation = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopLocation, "setName", ["Location thread"]);

			// Location unit array provider
			gLUAP = NEW("LocationUnitArrayProvider", []);

			T_CALLM("initServerOrHC", []);
		};
		if(IS_SERVER) then {
			T_CALLM("initCommanders", []);
			#ifndef _SQF_VM
			T_CALLM("initLocations", []);
			T_CALLM("initSideStats", []);
			T_CALLM("initMissionEventHandlers", []);
			T_CALLM("startCommanders", []);
			#endif
			T_CALLM("populateLocations", []);

			T_CALLM("initServerOnly", []);

			if(T_GETV("spawningEnabled")) then {
				T_CALLM("startSpawning", []);
			};
		};
		if (HAS_INTERFACE || IS_HEADLESSCLIENT) then {
			T_CALLM("initClientOrHCOnly", []);
		};
		if (IS_HEADLESSCLIENT) then {

			private _str = format ["Mission: I am a headless client! My player object is: %1. I have just connected! My owner ID is: %2", player, clientOwner];
			OOP_INFO_0(_str);
			systemChat _str;

			// Test: ask the server to create an object and pass it to this computer
			[clientOwner, {
				private _remoteOwner = _this;
				diag_log format ["---- Connected headless client with owner ID: %1. RemoteExecutedOwner: %2, isRemoteExecuted: %3", _remoteOwner, remoteExecutedOwner, isRemoteExecuted];
				diag_log format ["all players: %1, all headless clients: %2", allPlayers, entities "HeadlessClient_F"];
				diag_log format ["Owners of headless clients: %1", (entities "HeadlessClient_F") apply {owner _x}];

				private _args = ["Remote DebugPrinter test", gMessageLoopMain];
				remoteDebugPrinter = NEW("DebugPrinter", _args);
				CALLM(remoteDebugPrinter, "setOwner", [_remoteOwner]); // Transfer it to the machine that has connected
				diag_log format ["---- Created a debug printer for the headless client: %1", remoteDebugPrinter];

			}] remoteExec ["spawn", 2, false];

			T_CALLM("initHCOnly", []);
		};
		if(HAS_INTERFACE) then {
			diag_log "----- Player detected!";
			0 spawn {
				waitUntil {!((finddisplay 12) isEqualTo displayNull)};
				call compile preprocessfilelinenumbers "UI\initPlayerUI.sqf";
			};

			T_CALLM("initClientOnly", []);
		};
		T_CALLM("postInitAll", []);
	} ENDMETHOD;

	// Add garrisons to locations based where specified.
	// Behaviour is controlled by virtual functions "getLocationOwner" and "initGarrison",
	// or you can override the entire function.
	/* protected virtual */METHOD("populateLocations") {
		params [P_THISOBJECT];

		// Create initial garrisons
		{
			private _loc = _x;
			private _side = T_CALLM("getLocationOwner", [_loc]);
			CALLM(_loc, "setSide", [_side]);
			OOP_DEBUG_MSG("init loc %1 to side %2", [_loc ARG _side]);

			private _cmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
			if(!IS_NULL_OBJECT(_cmdr)) then {
				OOP_DEBUG_MSG("founc cmdr %1 for loc %2", [_cmdr ARG _loc]);
				CALLM(_cmdr, "registerLocation", [_loc]);

				private _gar = T_CALLM("initGarrison", [_loc ARG _side]);
				if(!IS_NULL_OBJECT(_gar)) then {
					OOP_DEBUG_MSG("Creating garrison %1 for location %2 (%3)", [_gar ARG _loc ARG _side]);

					CALLM1(_gar, "setLocation", _loc);
					CALLM1(_loc, "registerGarrison", _gar);
					CALLM0(_gar, "activate");
				};
			};

			// Send intel to commanders
			private _type = GETV(_loc, "type");
			{
				private _sideCommander = GETV(_x, "side");
				if (_sideCommander != WEST) then { // Enemies are smart
					private _updateLevel = [CLD_UPDATE_LEVEL_TYPE_UNKNOWN, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
					CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG _updateLevel ARG sideUnknown ARG false]);
				} else {
					// If it's player side, let it only know about cities
					if (_type == LOCATION_TYPE_CITY) then {
						CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG CLD_UPDATE_LEVEL_TYPE ARG sideUnknown ARG false ARG false]);
					};
				};
			} forEach gCommanders;
		} forEach GET_STATIC_VAR("Location", "all");
	} ENDMETHOD;
	
	// -------------------------------------------------------------------------
	// |                  V I R T U A L   F U N C T I O N S                    |
	// -------------------------------------------------------------------------
	// These are the customization points for game mode setups, implement them
	// in derived classes.
	/* protected virtual */ METHOD("preInitAll") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initServerOrHC") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initServerOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initClientOrHCOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initHCOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initClientOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("postInitAll") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("getLocationOwner") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		GETV(_loc, "side")
	} ENDMETHOD;

	/* protected virtual */ METHOD("initGarrison") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc"), P_SIDE("_side")];

		private _type = GETV(_loc, "type");
		OOP_INFO_MSG("%1 %2", [_loc ARG _side]);

		switch (_type) do {
			case LOCATION_TYPE_BASE;
			case LOCATION_TYPE_OUTPOST: {
				private _cInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
				private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
				private _cHMGGMG = CALLM(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high ARG GROUP_TYPE_ALL]);
				private _cBuildingSentry = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_BUILDING_SENTRY]]);				
				CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["military" ARG _side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry])
			};
			case LOCATION_TYPE_POLICE_STATION: {
				CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["police" ARG _side ARG 5])
			};
			default { NULL_OBJECT };
		};
	} ENDMETHOD;

	METHOD("startSpawning") {
		params [P_THISOBJECT];
		
		// TODO: fix this to correctly spawn at selected bases contingent on the critera we decide.
		// Move this to an existing thread?
		[] spawn {
			while{true} do {
				#ifdef RELEASE_BUILD
				sleep 3600;
				#else
				sleep 120;
				#endif
				{
					private _loc = _x;
					private _side = GETV(_loc, "side");
					private _template = GET_TEMPLATE(_side);
					private _targetCInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);

					private _garrisons = CALLM(_loc, "getGarrisons", [_side]);
					if (count _garrisons == 0) exitWith {};
					private _garrison = _garrisons#0;
					if(not CALLM(_garrison, "isSpawned", [])) then {
						private _infCount = count CALLM(_garrison, "getInfantryUnits", []);
						if(_infCount < _targetCInf) then {
							private _remaining = _targetCInf - _infCount;
							systemChat format["Spawning %1 units at %2", _remaining, _loc];
							while {_remaining > 0} do {
								CALLM2(_garrison, "postMethodSync", "createAddInfGroup", [_side ARG T_GROUP_inf_sentry ARG GROUP_TYPE_PATROL])
									params ["_newGroup", "_unitCount"];
								_remaining = _remaining - _unitCount;
							};
						};

						private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
						private _vehCount = count CALLM(_garrison, "getVehicleUnits", []);
						
						if(_vehCount < _cVehGround) then {
							systemChat format["Spawning %1 trucks at %2", _cVehGround - _vehCount, _loc];
						};

						while {_vehCount < _cVehGround} do {
							private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
							if (CALL_METHOD(_newUnit, "isValid", [])) then {
								CALLM2(_garrison, "postMethodSync", "addUnit", [_newUnit]);
								_vehCount = _vehCount + 1;
							} else {
								DELETE(_newUnit);
							};
						};
					};
				} forEach (GET_STATIC_VAR("Location", "all") select { GETV(_x, "type") == LOCATION_TYPE_BASE });

				// TODO: Do this for policeStations as well, we need getTemplate for side + faction
				// || GETV(_x, "type") == "policeStation" 
			};
		};
	} ENDMETHOD;
	// -------------------------------------------------------------------------
	// |                        S E R V E R   O N L Y                          |
	// -------------------------------------------------------------------------
	/* private */ METHOD("initCommanders") {
		params [P_THISOBJECT];

		// Garrison objects to track players and player owned vehicles
		gGarrisonPlayersWest = NEW("Garrison", [WEST]);
		gGarrisonPlayersEast = NEW("Garrison", [EAST]);
		gGarrisonPlayersInd = NEW("Garrison", [INDEPENDENT]);
		gGarrisonPlayersCiv = NEW("Garrison", [CIVILIAN]);
		gGarrisonAmbient = NEW("Garrison", [CIVILIAN]);

		gSpecialGarrisons = [gGarrisonPlayersWest, gGarrisonPlayersEast, gGarrisonPlayersInd, gGarrisonPlayersCiv, gGarrisonAmbient];
		{
			CALLM2(_x, "postMethodAsync", "spawn", []);
		} forEach gSpecialGarrisons;

		// Message loops for commander AI
		gMessageLoopCommanderInd = NEW("MessageLoop", []);

		// Commander AIs
		gCommanders = [];

		// Independent
		gCommanderInd = NEW("Commander", []); // all commanders are equal
		private _args = [gCommanderInd, INDEPENDENT, gMessageLoopCommanderInd];
		gAICommanderInd = NEW_PUBLIC("AICommander", _args);
		PUBLIC_VARIABLE "gAICommanderInd";
		gCommanders pushBack gAICommanderInd;

		if(gFlagAllCommanders) then { // but some are more equal

			gMessageLoopCommanderWest = NEW("MessageLoop", []);
			gMessageLoopCommanderEast = NEW("MessageLoop", []);

			// West
			gCommanderWest = NEW("Commander", []);
			private _args = [gCommanderWest, WEST, gMessageLoopCommanderWest];
			gAICommanderWest = NEW_PUBLIC("AICommander", _args);
			PUBLIC_VARIABLE "gAICommanderWest";
			gCommanders pushBack gAICommanderWest;

			// East
			gCommanderEast = NEW("Commander", []);
			private _args = [gCommanderEast, EAST, gMessageLoopCommanderEast];
			gAICommanderEast = NEW_PUBLIC("AICommander", _args);
			PUBLIC_VARIABLE "gAICommanderEast";
			gCommanders pushBack gAICommanderEast;
		};
	} ENDMETHOD;

	METHOD("startCommanders") {
		params [P_THISOBJECT];
		{
			CALLM(_x, "setProcessInterval", [10]);
			CALLM(_x, "start", []);
		} forEach gCommanders;
	} ENDMETHOD;


	// Create locations
	METHOD("initLocations") {
		params [P_THISOBJECT];

		private _allRoadBlocks = [];
		{
			private _locSector = _x;
			private _locSectorPos = getPos _locSector;
			private _locName = _locSector getVariable ["Name", ""];
			private _locType = _locSector getVariable ["Type", ""];
			private _locSide = _locSector getVariable ["Side", ""];
			private _locBorder = _locSector getVariable ["objectArea", [50, 50, 0, true]];
			private _locBorderType = ["circle", "rectangle"] select _locBorder#3;
			private _locCapacityInf = _locSector getVariable ["CapacityInfantry", ""];
			private _locCapacityCiv = _locSector getVariable ["CivPresUnitCount", ""];
			private _template = "";
			private _side = "";
			
			private _side = switch (_locSide) do{
				case "civilian": { CIVILIAN };//might not need this
				case "west": { WEST };
				case "east": { EAST };
				case "independant": { INDEPENDENT };
				default { INDEPENDENT };
			};

			// Create a new location
			private _loc = NEW_PUBLIC("Location", [_locSectorPos]);
			CALLM1(_loc, "initFromEditor", _locSector);
			CALLM1(_loc, "setName", _locName);
			CALLM1(_loc, "setSide", _side);
			CALLM1(_loc, "setType", _locType);
			CALLM2(_loc, "setBorder", _locBorderType, _locBorder);
			CALLM1(_loc, "setCapacityInf", _locCapacityInf);
			CALLM1(_loc, "setCapacityCiv", _locCapacityCiv);

			// TODO: improve this later
			private _roadBlocks = CALL_STATIC_METHOD("Location", "findRoadblocks", [_locSectorPos]) select {
				private _newRoadBlock = _x;
				_allRoadBlocks findIf { _x#0 distance _newRoadBlock#0 < 400 } == NOT_FOUND
			};
			_allRoadBlocks = _allRoadBlocks + _roadBlocks;
			{	
				_x params ["_roadblockPos", "_roadblockDir"];
				private _roadblockLoc = NEW_PUBLIC("Location", [_roadblockPos]);
				CALLM1(_roadblockLoc, "setName", _roadblockLoc);
				CALLM1(_roadblockLoc, "setSide", _side);
				CALLM2(_roadblockLoc, "setBorder", "rectangle", [10 ARG 10 ARG _roadblockDir]);
				CALLM1(_roadblockLoc, "setCapacityInf", 20);
				CALLM1(_roadblockLoc, "setCapacityCiv", 0);
				// Do setType last cos it will update the debug marker for us
				CALLM1(_roadblockLoc, "setType", "roadblock");
			} forEach _roadBlocks;

			// Create police stations
			// Create police stations in cities
			if (_locType == "city") then {
				// TODO: Add some visual/designs to this
				private _posPolice = +GETV(_loc, "pos");
				_posPolice = _posPolice vectorAdd [-200 + random 400, -200 + random 400, 0];
				private _policeStationBuilding = nearestBuilding _posPolice;
				private _policeStationLocation = NEW_PUBLIC("Location", [getPos _policeStationBuilding]);
				CALLM1(_policeStationLocation, "setSide", _side);
				CALLM1(_policeStationLocation, "setName", format ["%1 police station" ARG _locName] );
				CALLM1(_policeStationLocation, "setType", "policeStation");

				// TODO: Get city size or building count and scale police capacity from that ?
				CALLM1(_policeStationLocation, "setCapacityInf", 5);
				// add special gun shot sensor to police garrisons that will launch investigate->arrest goal ?
			};
			
		} forEach (entities "Project_0_LocationSector");

	} ENDMETHOD;

	#define ADD_TRUCKS
	#define ADD_UNARMED_MRAPS
	#define ADD_ARMED_MRAPS
	#define ADD_TANKS
	#define ADD_APCS_IFVS
	#define ADD_STATICS
	STATIC_METHOD("createGarrison") {
		params [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry")];
		
		private _gar = NEW("Garrison", [_side]);
		CALLM1(_gar, "setFaction", _faction);

		OOP_INFO_MSG("Creating garrison %1 for faction %2 for side %3, %4 inf, %5 veh, %6 hmg/gmg, %7 sentries", [_gar ARG _faction ARG _side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry]);
		
		if (_faction == "police") exitWith {
			private _policeGroup = NEW("Group", [_side ARG GROUP_TYPE_PATROL]);
			private _i = 0;
			while {_i < _cInf} do {
				private _variants = [T_INF_SL, T_INF_officer, T_INF_DEFAULT];
				private _newUnit = NEW("Unit", [tPOLICE ARG 0 ARG selectrandom _variants ARG -1 ARG _policeGroup]);
				_i = _i+1;
			};

			// Add a car in front of police station
			private _newUnit = NEW("Unit", [tPOLICE ARG T_VEH ARG T_VEH_personal ARG -1 ARG ""]);
			CALLM(_gar, "addUnit", [_newUnit]);

			OOP_INFO_MSG("%1: Created police group %2", [_gar ARG _policeGroup]);
			CALL_METHOD(_gar, "addGroup", [_policeGroup]);

			_gar
		};


		// Add default units to the garrison

		// Specification for groups to add to the garrison
		private _infSpec = [
			//|Min groups of this type
			//|    |Max groups of this type
			//|    |    |Group template
			//|	   |    |                          |Group behaviour
			[  0,   3,   T_GROUP_inf_sentry,   		GROUP_TYPE_PATROL],
			[  0,  -1,   T_GROUP_inf_rifle_squad,   GROUP_TYPE_IDLE]
		];

		private _vehGroupSpec = [
			//|Chance to spawn
			//|      |Min veh of this type
			//|      |    |Max veh of this type
			//|      |    |            |Veh type                          
			[  0.5,   0,  3,           T_VEH_MRAP_HMG],
			[  0.5,   0,  3,           T_VEH_MRAP_GMG],
			[  0.3,   0,  2,           T_VEH_APC],
			[  0.1,   0,  1,           T_VEH_MBT]
		];

		{
			_x params ["_min", "_max", "_groupTemplate", "_groupBehaviour"];
			private _i = 0;
			while{(_cInf > 0 or _i < _min) and (_max == -1 or _i < _max)} do {
				CALLM(_gar, "createAddInfGroup", [_side ARG _groupTemplate ARG _groupBehaviour])
					params ["_newGroup", "_unitCount"];
				OOP_INFO_MSG("%1: Created inf group %2 with %3 units", [_gar ARG _newGroup ARG _unitCount]);
				_cInf = _cInf - _unitCount;
				_i = _i + 1;
			};
		} forEach _infSpec;
		
		private _template = GET_TEMPLATE(_side);

		// Add building sentries
		if (_cBuildingSentry > 0) then {
			private _sentryGroup = NEW("Group", [_side ARG GROUP_TYPE_BUILDING_SENTRY]);
			while {_cBuildingSentry > 0} do {
				private _variants = [T_INF_marksman, T_INF_marksman, T_INF_LMG, T_INF_LAT, T_INF_LMG];
				private _newUnit = NEW("Unit", [_template ARG 0 ARG selectrandom _variants ARG -1 ARG _sentryGroup]);
				_cBuildingSentry = _cBuildingSentry - 1;
			};
			OOP_INFO_MSG("%1: Created sentry group %2", [_gar ARG _sentryGroup]);
			CALL_METHOD(_gar, "addGroup", [_sentryGroup]);
		};

		// Add default vehicles
		// Some trucks
		private _i = 0;
		#ifdef ADD_TRUCKS
		while {_cVehGround > 0 && _i < 3} do {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
			if (CALL_METHOD(_newUnit, "isValid", [])) then {
				CALL_METHOD(_gar, "addUnit", [_newUnit]);
				OOP_INFO_MSG("%1: Added truck %2", [_gar ARG _newUnit]);
				_cVehGround = _cVehGround - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};
		#endif

		// Unarmed MRAPs
		_i = 0;
		#ifdef ADD_UNARMED_MRAPS
		while {(_cVehGround > 0) && _i < 1} do  {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_MRAP_unarmed ARG -1 ARG ""]);
			if (CALL_METHOD(_newUnit, "isValid", [])) then {
				CALL_METHOD(_gar, "addUnit", [_newUnit]);
				OOP_INFO_MSG("%1: Added unarmed mrap %2", [_gar ARG _newUnit]);
				_cVehGround = _cVehGround - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};
		#endif

		// APCs
		#ifdef ADD_APCS_IFVS
		{
			_x params ["_chance", "_min", "_max", "_type"];
			if(random 1 <= _chance) then {
				private _i = 0;
				while{(_cVehGround > 0 or _i < _min) and (_max == -1 or _i < _max)} do {
					private _newGroup = CALLM(_gar, "createAddVehGroup", [_side ARG T_VEH ARG T_VEH_APC ARG -1]);
					OOP_INFO_MSG("%1: Created veh group %2", [_gar ARG _newGroup]);
					_cVehGround = _cVehGround - 1;
					_i = _i + 1;
				};
			};
		} forEach _vehGroupSpec;
		#endif

		// Static weapons
		if (_cHMGGMG > 0) then {
			// temp cap of amount of static guns
			_cHMGGMG = (4 + random 5) min _cHMGGMG;
			
			private _staticGroup = NEW("Group", [_side ARG GROUP_TYPE_VEH_STATIC]);
			while {_cHMGGMG > 0} do {
				private _variants = [T_VEH_stat_HMG_high, T_VEH_stat_GMG_high];
				private _newUnit = NEW("Unit", [_template ARG T_VEH ARG selectrandom _variants ARG -1 ARG _staticGroup]);
				CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
				_cHMGGMG = _cHMGGMG - 1;
			};
			OOP_INFO_MSG("%1: Added static group %2", [_gar ARG _staticGroup]);
			CALL_METHOD(_gar, "addGroup", [_staticGroup]);
		};
		_gar
	} ENDMETHOD;


	// Create SideStats
	/* private */ METHOD("initSideStats") {
		params [P_THISOBJECT];
		
		private _args = [EAST, 5];
		SideStatWest = NEW("SideStat", _args);
		gSideStatWestHR = CALLM0(SideStatWest, "getHumanResources");
		PUBLIC_VARIABLE "gSideStatWestHR";
	} ENDMETHOD;

	// create MissionEventHandlers
	/* private */ METHOD("initMissionEventHandlers") {
		params [P_THISOBJECT];
		call compile preprocessFileLineNumbers "Init\initMissionEH.sqf";
	} ENDMETHOD;

	/* private */ METHOD("fn") {
		params [P_THISOBJECT];

	} ENDMETHOD;
ENDCLASS;