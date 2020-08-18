#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.Actions.TakeLocationCmdrAction

CmdrAI garrison action for taking a location.
Takes a source garrison id and target location id.
Sends a detachment from the source garrison to occupy the target location.

Parent: <TakeOrJoinCmdrAction>
*/

#define pr private

#define OOP_CLASS_NAME TakeLocationCmdrAction
CLASS("TakeLocationCmdrAction", "TakeOrJoinCmdrAction")
	VARIABLE_ATTR("tgtLocId", [ATTR_SAVE]);

	/*
	Constructor: new
	
	Create a CmdrAI action to send a detachment from the source garrison to occupy
	the target location.
	
	Parameters:
		_srcGarrId - Number, <Model.GarrisonModel> id from which to send the detachment.
		_tgtLocId - Number, <Model.GarrisonModel> id for the detachment to occupy.
	*/
	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtLocId")];

		T_SETV("tgtLocId", _tgtLocId);

		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		T_SET_AST_VAR("targetVar", [TARGET_TYPE_LOCATION ARG _tgtLocId]);
	ENDMETHOD;

	protected override METHOD(updateIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		ASSERT_MSG(CALLM0(_world, "isReal"), "Can only updateIntel from real world, this shouldn't be possible as updateIntel should ONLY be called by CmdrAction");

		private _intelClone = T_GETV("intelClone");
		private _intelNotCreated = IS_NULL_OBJECT(_intelClone);
		if(_intelNotCreated) then
		{
			// Create new intel object and fill in the constant values
			private _intel = NEW("IntelCommanderActionAttack", []);

			private _srcGarrId = T_GETV("srcGarrId");
			private _tgtLocId = T_GETV("tgtLocId");
			private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			ASSERT_OBJECT(_srcGarr);
			private _tgtLoc = CALLM(_world, "getLocation", [_tgtLocId]);
			ASSERT_OBJECT(_tgtLoc);

			CALLM0(_intel, "create");

			SETV(_intel, "type", "Take Location");
			SETV(_intel, "side", GETV(_srcGarr, "side"));
			SETV(_intel, "srcGarrison", GETV(_srcGarr, "actual"));
			SETV(_intel, "posSrc", GETV(_srcGarr, "pos"));
			SETV(_intel, "tgtLocation", GETV(_tgtLoc, "actual"));
			SETV(_intel, "location", GETV(_tgtLoc, "actual"));
			SETV(_intel, "posTgt", GETV(_tgtLoc, "pos"));
			SETV(_intel, "dateDeparture", T_GET_AST_VAR("startDateVar")); // Sparker added this, I think it's allright??

			T_CALLM("updateIntelFromDetachment", [_world ARG _intel]);

			// If we just created this intel then register it now 
			private _intelClone = CALLSM("AICommander", "registerIntelCommanderAction", [_intel]);
			T_SETV("intelClone", _intelClone);

			// Send the intel to some places that should "know" about it
			T_CALLM("addIntelAt", [_world ARG GETV(_srcGarr, "pos")]);
			T_CALLM("addIntelAt", [_world ARG GETV(_tgtLoc, "pos")]);
		} else {
			T_CALLM("updateIntelFromDetachment", [_world ARG _intelClone]);
			CALLM0(_intelClone, "updateInDb");
		};
	ENDMETHOD;

	public override METHOD(updateScore)
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		private _srcGarrId = T_GETV("srcGarrId");
		private _tgtLocId = T_GETV("tgtLocId");

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _srcGarrEff = GETV(_srcGarr, "efficiency");
		private _srcGarrComp = GETV(_srcGarr, "composition");

		//diag_log format [" src garr eff: %1", _srcGarrEff];
		//diag_log format ["  src garr comp: %1", _srcGarrComp];

		ASSERT_OBJECT(_srcGarr);
		
		// Bail if garrison is dead
		if(CALLM0(_srcGarr, "isDead")) exitWith {
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		private _tgtLoc = CALLM(_worldFuture, "getLocation", [_tgtLocId]);
		private _tgtLocPos = GETV(_tgtLoc, "pos");
		private _enemyEff = +CALLM(_worldNow, "getDesiredEff", [GETV(_tgtLoc, "pos")]);
		private _enemyEffFromIntel = GETV(_tgtLoc, "efficiency");
		OOP_INFO_1(" Enemy efficiency from grid : %1", _enemyEff);
		OOP_INFO_1(" Enemy efficiency from intel: %1", _enemyEffFromIntel);
		_enemyEff = EFF_MAX(_enemyEff, _enemyEffFromIntel);	// Maximum eff from grid and intel
		_enemyEff = [_enemyEff, ENEMY_LOCATION_EFF_MAX] call eff_fnc_min;
		OOP_INFO_1(" Resulting               eff: %1", _enemyEff);
		ASSERT_OBJECT(_tgtLoc);
		private _side = GETV(_srcGarr, "side");
		private _toGarr = CALLM(_tgtLoc, "getGarrison", [_side]);

		// Bail if we already own this place
		if(!IS_NULL_OBJECT(_toGarr)) exitWith {
			// We never take a location we already have a garrison at, this should be reinforcement instead 
			// (however we can get here if multiple potential actions are generated targetting the same location
			// in the same planning cycle, and one gets accepted)
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		// Bail if the garrison clearly can not destroy the enemy
		if ( count ([_srcGarrEff, _enemyEff] call eff_fnc_validateAttack) > 0) exitWith {
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		// Set up flags for allocation algorithm
		private _allocationFlags = [SPLIT_VALIDATE_ATTACK, SPLIT_VALIDATE_CREW_EXT, SPLIT_VALIDATE_CREW]; // Validate attack capability, allocate a min amount of infantry
		private _payloadWhitelistMask = T_comp_infantry_mask;	// Take only infantry as an attacking force
		// If it's too far to travel, also allocate transport
		// todo add other transport types?

		pr _dist = CALLM2(gStrategicNavGrid, "calculateGroundDistance", _srcGarrPos, _tgtLocPos);

		if (_dist == -1) exitWith {
			OOP_DEBUG_0("Destination is unreachable over ground");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		if ( _dist > TAKE_LOCATION_NO_TRANSPORT_DISTANCE_MAX) then {
			_allocationFlags append [	SPLIT_VALIDATE_TRANSPORT,		// Make sure we can transport ourselves
										// Also allocate a minimum amount of transport as an external requirement, not only for ourselves but for the future
										SPLIT_VALIDATE_TRANSPORT_EXT];
			_payloadWhitelistMask = T_comp_ground_or_infantry_mask;	// Take infantry or vehicles as an attacking force
		};

		_enemyEff set [T_EFF_transport, EFF_GARRISON_MIN_EFF#T_EFF_transport];
		_enemyEff set [T_EFF_crew, EFF_GARRISON_MIN_EFF#T_EFF_crew];	// Ensure minimal amount of crew (infantry)

		// Try to allocate units
		pr _payloadBlacklistMask = T_comp_static_mask;					// Don't take static weapons under any conditions
		pr _transportWhitelistMask = T_comp_ground_or_infantry_mask;	// Take ground units, take any infantry to satisfy crew requirements
		pr _transportBlacklistMask = [];
		pr _args = [_enemyEff, _allocationFlags, _srcGarrComp, _srcGarrEff,
					_payloadWhitelistMask, _payloadBlacklistMask,
					_transportWhitelistMask, _transportBlacklistMask];
		private _allocResult = CALLSM("GarrisonModel", "allocateUnits", _args);

		//diag_log format ["Allocated units for take location: %1", _allocResult];

		// Bail if we have failed to allocate resources
		if ((count _allocResult) == 0) exitWith {
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		_allocResult params ["_compAllocated", "_effAllocated", "_compRemaining", "_effRemaining"];

		// Bail if remaining efficiency is below minimum level for this garrison
		pr _srcDesiredEff = CALLM1(_worldNow, "getDesiredEff", _srcGarrPos);
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateAttack) > 0) exitWith {
			OOP_DEBUG_2("Remaining attack capability requirement not satisfied: %1 VS %2", _effRemaining, _srcDesiredEff);
			T_CALLM("setScore", [ZERO_SCORE]);
		};
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateCrew) > 0 ) exitWith {	// We must have enough crew to operate vehicles ...
			OOP_DEBUG_1("Remaining crew requirement not satisfied: %1", _effRemaining);
			T_CALLM("setScore", [ZERO_SCORE]);
		};
 
		// CALCULATE THE RESOURCE SCORE
		// In this case it is how well the source garrison can meet the resource requirements of this action,
		// specifically efficiency, transport and distance. Score is 0 when full requirements cannot be met, and 
		// increases with how much over the full requirements the source garrison is (i.e. how much OVER the 
		// required efficiency it is), with a distance based fall off (further away from target is lower scoring).

		// Save the calculation of the efficiency for use later.
		// We DON'T want to try and recalculate the detachment against the REAL world state when the action is actually active because
		// it won't be correctly taking into account our knowledge about other actions (as this is represented in the sim world models 
		// which are only available now, during scoring/planning).
		T_SET_AST_VAR("detachmentEffVar", _effAllocated);
		T_SET_AST_VAR("detachmentCompVar", _compAllocated);


		// How much to scale the score for distance to target
		private _distCoeff = CALLSM1("CmdrAction", "calcDistanceFalloff", _srcGarrPos distance _tgtLocPos);

		private _detachEffStrength = CALLSM1("CmdrAction", "getDetachmentStrength", _effAllocated);				// A number

		private _strategy = CALLSM("AICommander", "getCmdrStrategy", [_side]);
		
		private _scoreResource = _detachEffStrength * _distCoeff;
		private _scorePriority = CALLM(_strategy, "getLocationDesirability", [_worldNow ARG _tgtLoc ARG _side]);

		// CALCULATE START DATE
		// Work out time to start based on how much force we mustering and distance we are travelling.
		// https://www.desmos.com/calculator/mawpkr88r3 * https://www.desmos.com/calculator/0vb92pzcz8
#ifndef RELEASE_BUILD
		private _delay = random 2;
#else
		private _delay = 75 * log (0.1 * _detachEffStrength + 1) * (1 + 2 * log (0.0003 * _dist + 1)) * 0.1 + 2 + (random 30 + 30);
#endif

		// Shouldn't need to cap it, the functions above should always return something reasonable, if they don't then fix them!
		// _delay = 0 max (120 min _delay);
		private _startDate = DATE_NOW;

		_startDate set [4, _startDate#4 + _delay];

		T_SET_AST_VAR("startDateVar", _startDate);

		// Uncomment for some more debug logging
		 OOP_DEBUG_MSG("[w %1 a %2] %3 take %4 Score %5, _detachEff = %6, _detachEffStrength = %7, _distCoeff = %8",
		 	[_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtLoc) ARG [_scorePriority ARG _scoreResource] 
		 	ARG _effAllocated ARG _detachEffStrength ARG _distCoeff]);

		// APPLY STRATEGY
		// Get our Cmdr strategy implementation and apply it
		private _baseScore = MAKE_SCORE_VEC(_scorePriority, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getTakeLocationScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _tgtLoc ARG _effAllocated]);
		T_CALLM("setScore", [_score]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""TakeOutpost"", ""src_garrison"": ""%2"", ""tgt_location"": ""%3"", ""score_priority"": %4, ""score_resource"": %5, ""score_strategy"": %6, ""score_completeness"": %7}}", 
			_side, LABEL(_srcGarr), LABEL(_tgtLoc), _score#0, _score#1, _score#2, _score#3];
		OOP_INFO_MSG(_str, []);
		#endif
	ENDMETHOD;

	/*
	Method: (virtual) getRecordSerial
	Returns a serialized CmdrActionRecord associated with this action.
	Derived classes should implement this to have proper support for client's UI.
	
	Parameters:	
		_world - <Model.WorldModel>, real world model that is being used.
	*/
	public override METHOD(getRecordSerial)
		params [P_THISOBJECT, P_OOP_OBJECT("_garModel"), P_OOP_OBJECT("_world")];

		// Create a record
		private _record = NEW("TakeLocationCmdrActionRecord", []);

		// Fill data values
		//SETV(_record, "garRef", GETV(_garModel, "actual"));
		private _tgtLocModel = CALLM1(_world, "getLocation", T_GETV("tgtLocId"));
		SETV(_record, "locRef", GETV(_tgtLocModel, "actual"));

		// Serialize and delete it
		private _serial = SERIALIZE(_record);
		DELETE(_record);

		// Return the serialized data
		_serial
	ENDMETHOD;

ENDCLASS;

REGISTER_DEBUG_MARKER_STYLE("TakeLocationCmdrAction", "ColorBlue", "mil_flag");

#ifdef _SQF_VM

#define SRC_POS [0, 0, 0]
#define TARGET_POS [1000, 2, 3]

["TakeLocationCmdrAction", {
	private _realworld = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _world = CALLM(_realworld, "simCopy", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _srcComp = [30] call comp_fnc_new;
	for "_i" from 0 to (T_INF_SIZE-1) do {
		(_srcComp#T_INF) set [_i, 100]; // Otherwise crew requirement will fail
	};
	private _srcEff = [_srcComp] call comp_fnc_getEfficiency;
	SETV(_garrison, "efficiency", _srcEff);
	SETV(_garrison, "composition", _srcComp);
	SETV(_garrison, "pos", SRC_POS);
	SETV(_garrison, "side", WEST);

	private _targetLocation = NEW("LocationModel", [_world ARG "<undefined>"]);
	SETV(_targetLocation, "type", LOCATION_TYPE_BASE);
	SETV(_targetLocation, "pos", TARGET_POS);

	private _thisObject = NEW("TakeLocationCmdrAction", [GETV(_garrison, "id") ARG GETV(_targetLocation, "id")]);
	
	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	T_CALLM("updateScore", [_world ARG _future]);

	private _finalScore = T_CALLM("getFinalScore", []);
	//diag_log format ["Take location final score: %1", _finalScore];
	["Score is above zero", _finalScore > 0] call test_Assert;

	private _nowSimState = T_CALLM("applyToSim", [_world]);
	private _futureSimState = T_CALLM("applyToSim", [_future]);
	["Now sim state correct", _nowSimState == CMDR_ACTION_STATE_READY_TO_MOVE] call test_Assert;
	["Future sim state correct", _futureSimState == CMDR_ACTION_STATE_END] call test_Assert;
	
	private _futureLocation = CALLM(_future, "getLocation", [GETV(_targetLocation, "id")]);
	private _futureGarrison = CALLM(_futureLocation, "getGarrison", [WEST]);
	["Location is occupied in future", !IS_NULL_OBJECT(_futureGarrison)] call test_Assert;
	// ["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

["TakeLocationCmdrAction.save and load", {

	CALLSM0("AICommander", "initStrategicNavGrid");

	private _realworld = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _world = CALLM(_realworld, "simCopy", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _srcComp = [30] call comp_fnc_new;
	for "_i" from 0 to (T_INF_SIZE-1) do {
		(_srcComp#T_INF) set [_i, 100]; // Otherwise crew requirement will fail
	};
	private _srcEff = [_srcComp] call comp_fnc_getEfficiency;
	SETV(_garrison, "efficiency", _srcEff);
	SETV(_garrison, "composition", _srcComp);
	SETV(_garrison, "pos", SRC_POS);
	SETV(_garrison, "side", WEST);

	private _targetLocation = NEW("LocationModel", [_world ARG "<undefined>"]);
	SETV(_targetLocation, "type", LOCATION_TYPE_BASE);
	SETV(_targetLocation, "pos", TARGET_POS);

	private _thisObject = NEW("TakeLocationCmdrAction", [GETV(_garrison, "id") ARG GETV(_targetLocation, "id")]);
	
	// Try to save and load...
	pr _storage = NEW("StorageProfileNamespace", []);
	CALLM1(_storage, "open", "testRecordTakeLocationCmdrAction");
	CALLM1(_storage, "save", _thisObject);
	DELETE(_thisObject);
	CALLM1(_storage, "load", _thisObject);

	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	T_CALLM("updateScore", [_world ARG _future]);

	private _finalScore = T_CALLM("getFinalScore", []);
	//diag_log format ["Take location final score: %1", _finalScore];
	["Score is above zero", _finalScore > 0] call test_Assert;

	private _nowSimState = T_CALLM("applyToSim", [_world]);
	private _futureSimState = T_CALLM("applyToSim", [_future]);
	["Now sim state correct", _nowSimState == CMDR_ACTION_STATE_READY_TO_MOVE] call test_Assert;
	["Future sim state correct", _futureSimState == CMDR_ACTION_STATE_END] call test_Assert;
	
	private _futureLocation = CALLM(_future, "getLocation", [GETV(_targetLocation, "id")]);
	private _futureGarrison = CALLM(_futureLocation, "getGarrison", [WEST]);
	["Location is occupied in future", !IS_NULL_OBJECT(_futureGarrison)] call test_Assert;
}] call test_AddTest;

#endif