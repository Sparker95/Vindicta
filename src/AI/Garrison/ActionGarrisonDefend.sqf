#include "common.hpp"
FIX_LINE_NUMBERS()

#define pr private

// Base for defensive actions (active, passive, relax)
// 
// Specify group behaviors in derived classes
//
// Number of road patrols -- prefers vehicles
// Number of overwatch groups -- same as clear area action
// Fraction of idle vs patrol for general inf
// Fraction of idle vs patrol for general vehicles
// Inf behavior -- behavior, speed, combat mode, formation
// Vic behavior -- behavior, speed, combat mode, formation
// Static group goal
// Idle group goals -- array of possible goals with weights

#define OOP_CLASS_NAME ActionGarrisonDefend
CLASS("ActionGarrisonDefend", "ActionGarrisonBehaviour")
	VARIABLE("behaviour");
	VARIABLE("speedMode");
	VARIABLE("infantryFormation");
	VARIABLE("air"); // Fraction of air assets to deploy in defense (0 - 1)

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		T_SETV("behaviour", "AWARE");
		T_SETV("speedMode", "NORMAL");
		T_SETV("infantryFormation", "STAG COLUMN");
		T_SETV("air", 0.25);
	ENDMETHOD;

	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		OOP_INFO_0("ACTIVATE");

		// Give goals to groups
		private _AI = T_GETV("AI");
		private _gar = GETV(_AI, "agent");

		CALLM0(_gar, "rebalanceGroups");

		pr _groups = CALLM0(_gar, "getGroups");
		pr _groupsInf = _groups select { CALLM0(_x, "getType") == GROUP_TYPE_INF };

		private _loc = CALLM0(_gar, "getLocation");

		pr _commonParams = [
			[TAG_COMBAT_MODE, "RED"],
			[TAG_BEHAVIOUR, T_GETV("behaviour")],
			[TAG_INSTANT, _instant]
		];

		if(count _groupsInf > 0) then {
			// Buildings into which groups will be ordered to move
			private _buildings = if (_loc != NULL_OBJECT) then {+
				CALLM0(_loc, "getOpenBuildings")
			} else {
				[]
			};

			// Sort buildings by their height (or maybe there is a better criteria, but higher is better, right?)
			_buildings = _buildings apply {[abs ((boundingBoxReal _x)#1#2), _x]};
			_buildings sort DESCENDING;

			// Half patrol / half in buildings
			pr _maxInBuildings = count _groupsInf / 2;

			// Order to some groups to occupy buildings
			// This is obviously ignored if the garrison is not at a location
			pr _i = 0;
			while {(count _groupsInf > _maxInBuildings) && (count _buildings > 0)} do {
				pr _group = _groupsInf#0;
				pr _groupAI = CALLM0(_group, "getAI");
				pr _goalParameters = [
					[TAG_TARGET, _buildings#0#1]
				] + _commonParams;
				pr _args = ["GoalGroupGetInBuilding", 0, _goalParameters, _AI]; // Get in the house!
				CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);

				_buildings deleteAt 0;
				_groupsInf deleteAt 0;
				_groups deleteAt (_groups find _group);
			};
		};

		private _infExtraParams = [
			[TAG_SPEED_MODE, T_GETV("speedMode")],
			[TAG_FORMATION, T_GETV("infantryFormation")]
		];

		private _vehExtraParams = [
			[TAG_COMBAT_MODE, "GREEN"],// Vehicle operators must mount vehicles first of all, not chase enemies
			[TAG_BEHAVIOUR, "AWARE"],
			[TAG_INSTANT, _instant]
		];

		pr _routes = if(_loc != NULL_OBJECT) then { CALLM0(_loc, "getPatrolRoutes") } else { [[],[]] };
		pr _radius = if(_loc != NULL_OBJECT) then { CALLM0(_loc, "getBoundingRadius") } else { 250 };

		pr _pos = CALLM0(_gar, "getPos");

		// Give goals to remaining groups
		private _nPatrolGroups = 0;
		private _nAirPatrolGroups = 0;
		private _totalAirGroups = ({ CALLM0(_x, "isAirGroup") } count _groups);
		private _nDesiredAirPatrolGroups = ceil (_totalAirGroups * T_GETV("air"));

		{// foreach _groups
			private _group = _x;
			private _groupAI = CALLM0(_group, "getAI");

			if (_groupAI != NULL_OBJECT) then {
				private _args = switch (CALLM0(_group, "getType")) do {
					case GROUP_TYPE_VEH: {
						if(CALLM0(_group, "isAirGroup") && _nAirPatrolGroups <  _nDesiredAirPatrolGroups) then {
							_nAirPatrolGroups = _nAirPatrolGroups + 1;
							["GoalGroupClearArea", 0, [
								[TAG_POS, _pos],
								[TAG_CLEAR_RADIUS, _radius]
							] + _commonParams, _AI]
						} else {
							["GoalGroupGetInVehiclesAsCrew", 0, [[TAG_ONLY_COMBAT_VEHICLES, true]] + _commonParams, _AI]
						};
					};
					case GROUP_TYPE_STATIC: {
						["GoalGroupGetInVehiclesAsCrew", 0, _vehExtraParams, _AI]
					};
					// case GROUP_TYPE_VEH: {
					// 	["GoalGroupGetInVehiclesAsCrew", 0, [[TAG_ONLY_COMBAT_VEHICLES, true]] + _commonParams, _AI]
					// };
					case GROUP_TYPE_INF: {
						// We need at least enough patrol groups to cover the defined routes
						if (_nPatrolGroups < count _routes) then {
							_nPatrolGroups = _nPatrolGroups + 1;
							["GoalGroupPatrol", 0, [[TAG_ROUTE, _routes#(_nPatrolGroups - 1)]] + _infExtraParams + _commonParams, _AI];
						} else {
							["GoalGroupPatrol", 0, _infExtraParams + _commonParams, _AI];
						};
					};
				};
				CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
			};
		} forEach _groups;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	ENDMETHOD;

	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];

		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		pr _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			T_CALLM0("attackEnemyBuildings"); // It will try to give goals to free groups to attack nearby enemy buildings
		};

		// Return the current state
		_state
	ENDMETHOD;

ENDCLASS;