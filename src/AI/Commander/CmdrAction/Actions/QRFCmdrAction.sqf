#include "common.hpp"

#ifdef _SQF_VM
#undef DEBUG_AIR_QRF
#endif

FIX_LINE_NUMBERS()

/*
Class: AI.CmdrAI.CmdrAction.Actions.QRFCmdrAction

CmdrAI QRF action.
Takes a source garrison model ID and cluster model ID and generates an action
to attack the cluster using the garrison.

Parent: <AttackCmdrAction>
*/

#define OOP_CLASS_NAME QRFCmdrAction
CLASS("QRFCmdrAction", "AttackCmdrAction")
	// The target cluster model ID
	VARIABLE_ATTR("tgtClusterId", [ATTR_SAVE]);

	/*
	Constructor: new
	Create a CmdrAI action to send a detachment from a garrison to destroy an enemy
	cluster.
	
	Parameters:
		_srcGarrId - Number, <Model.GarrisonModel> id from which to send the QRF detachment.
		_tgtClusterId - Number, <Model.ClusterModel> id to attack.
	*/
	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtClusterId")];

		T_SETV("tgtClusterId", _tgtClusterId);

		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		T_SET_AST_VAR("targetVar", [TARGET_TYPE_CLUSTER ARG _tgtClusterId]);
	ENDMETHOD;

	// Create the intel object for this action
	protected override METHOD(updateIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];

		ASSERT_MSG(CALLM0(_world, "isReal"), "Can only updateIntel from real world, this shouldn't be possible as updateIntel should ONLY be called by CmdrAction");

		private _intel = NULL_OBJECT;
		private _intelClone = T_GETV("intelClone");
		// Created lazily here on the first call to update it. This ensures we only
		// create intel objects for actions that are active rather than merely proposed.
		private _intelNotCreated = IS_NULL_OBJECT(_intelClone);
		if(_intelNotCreated) then {
			// Create new intel object and fill in the constant values
			_intel = NEW("IntelCommanderActionAttack", []);

			private _srcGarrId = T_GETV("srcGarrId");
			private _tgtClusterId = T_GETV("tgtClusterId");
			private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			ASSERT_OBJECT(_srcGarr);
			private _tgtCluster = CALLM(_world, "getCluster", [_tgtClusterId]);
			ASSERT_OBJECT(_tgtCluster);

			CALLM0(_intel, "create");
			SETV(_intel, "state", INTEL_ACTION_STATE_ACTIVE); // It's instantly active

			SETV(_intel, "type", "Take Location");
			SETV(_intel, "side", GETV(_srcGarr, "side"));
			SETV(_intel, "srcGarrison", GETV(_srcGarr, "actual"));
			SETV(_intel, "posSrc", GETV(_srcGarr, "pos"));
			SETV(_intel, "tgtClusterId", GETV(_tgtCluster, "actual") select 1);
			//SETV(_intel, "location", GETV(_tgtCluster, "actual"));
			SETV(_intel, "posTgt", GETV(_tgtCluster, "pos"));
			SETV(_intel, "dateDeparture", T_GET_AST_VAR("startDateVar")); // Sparker added this, I think it's allright??

			// Call the base class function to update the detachment specific intel
			T_CALLM("updateIntelFromDetachment", [_world ARG _intel]);

			// If we just created this intel then register it now 			
			private _intelClone = CALLSM("AICommander", "registerIntelCommanderAction", [_intel]);
			T_SETV("intelClone", _intelClone);

			// Send the intel to some places that should "know" about it
			T_CALLM("addIntelAt", [_world ARG GETV(_srcGarr, "pos")]);
			T_CALLM("addIntelAt", [_world ARG GETV(_tgtCluster, "pos")]);

			// Reveal some friendly locations near the destination to the garrison performing the task
			private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
			if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
				private _detachedGarrModel = CALLM(_world, "getGarrison", [_detachedGarrId]);
				{
					CALLM2(_x, "addKnownFriendlyLocationsActual", GETV(_tgtCluster, "pos"), 2000 ); // Reveal friendly locations within 2000 meters
				} forEach [_srcGarr, _detachedGarrModel];
			};
		} else {
			// Call the base class function to update the detachment specific intel
			T_CALLM("updateIntelFromDetachment", [_world ARG _intelClone]);
			CALLM0(_intelClone, "updateInDb");
		};
	ENDMETHOD;

	// Update score for this action
	public override METHOD(updateScore)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		private _srcGarrId = T_GETV("srcGarrId");
		private _tgtClusterId = T_GETV("tgtClusterId");

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _srcGarrEff = GETV(_srcGarr, "efficiency");
		private _srcGarrComp = GETV(_srcGarr, "composition");
		
		ASSERT_OBJECT(_srcGarr);

		private _tgtCluster = CALLM(_worldFuture, "getCluster", [_tgtClusterId]);
		ASSERT_OBJECT(_tgtCluster);

		// Source or target being dead means action is invalid, return 0 score
		if(CALLM0(_srcGarr, "isDead") or CALLM0(_tgtCluster, "isDead")) exitWith {
			T_CALLM1("setScore", ZERO_SCORE);
		};

		private _tgtClusterPos = GETV(_tgtCluster, "pos");

		// Set up flags for allocation algorithm
		private _allocationFlags = [
			SPLIT_VALIDATE_ATTACK,
			SPLIT_VALIDATE_CREW
		];

#ifdef DEBUG_BIG_QRF
		// Make sure we allocate a lot of inf
		_allocationFlags pushBack SPLIT_VALIDATE_CREW_EXT;

		private _enemyEff = +T_EFF_null;
		_enemyEff set[T_EFF_soft, 30];
		_enemyEff set[T_EFF_medium, 6];
		_enemyEff set[T_EFF_armor, 6];
		_enemyEff set[T_EFF_crew, 24];
#else
		private _enemyEff = +GETV(_tgtCluster, "efficiency");
		// Scale enemy efficiency
		private _scaleFactor = (CALLM1(_worldNow, "calcActivityMultiplier", _tgtClusterPos)) max 1.3;
		_enemyEff = EFF_MUL_SCALAR(_enemyEff, _scaleFactor);
		_enemyEff = [_enemyEff, ENEMY_CLUSTER_EFF_MAX] call eff_fnc_min;
		if ((_enemyEff#T_eff_soft) > 0) then {
			_enemyEff set [T_EFF_soft, (_enemyEff#T_eff_soft) max 6];	// Set min amount of attack force
		};
#endif
		FIX_LINE_NUMBERS()

		// Bail if the garrison clearly can not destroy the enemy
		if (count ([_srcGarrEff, _enemyEff] call eff_fnc_validateAttack) > 0) exitWith {
			T_CALLM1("setScore", ZERO_SCORE);
		};

		private _srcType = GETV(_srcGarr, "type");

		private _needTransport = false;

		// If it's too far to travel, also allocate transport
		// todo add other transport types?
		private _dist = switch (_srcType) do {
			// Air counterattack doesn't care about terrain
			case GARRISON_TYPE_AIR: {
				_tgtClusterPos DISTANCE_2D _srcGarrPos;
			};

			// Ground counterattack must calculate distance from simplified terrain grid
			case GARRISON_TYPE_GENERAL: {
				private _distanceOverGround = CALLM2(gStrategicNavGrid, "calculateGroundDistance", _srcGarrPos, _tgtClusterPos);
				_distanceOverGround;
			};
		};

		if (_dist == -1) exitWith {
			OOP_DEBUG_0("Destination is unreachable over ground");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		if ( _dist > QRF_NO_TRANSPORT_DISTANCE_MAX) then {
			_allocationFlags pushBack SPLIT_VALIDATE_TRANSPORT;		// Make sure we can transport ourselves
			_needTransport = true;
		};

		// Try to allocate units
		private _allocArgs = [];
		private _allocResult = switch _srcType do {
#ifndef DEBUG_AIR_QRF
			case GARRISON_TYPE_GENERAL: {
				private _payloadWhitelistMask = T_comp_ground_or_infantry_mask;
				private _payloadBlacklistMask = T_comp_static_mask;					// Don't take static weapons under any conditions
				private _transportWhitelistMask = T_comp_ground_or_infantry_mask;	// Take ground units, take any infantry to satisfy crew requirements
				private _transportBlacklistMask = [];
				_allocArgs = [_enemyEff, _allocationFlags, _srcGarrComp, _srcGarrEff,
					_payloadWhitelistMask, _payloadBlacklistMask,
					_transportWhitelistMask, _transportBlacklistMask];
				CALLSM("GarrisonModel", "allocateUnits", _allocArgs)
			};
#endif
			FIX_LINE_NUMBERS()
			case GARRISON_TYPE_AIR: {
				private _payloadWhitelistMask = T_comp_air_mask;
				private _payloadBlacklistMask = T_comp_static_mask;					// Don't take static weapons under any conditions
				private _transportWhitelistMask = T_comp_ground_or_infantry_mask;	// Take ground units, take any infantry to satisfy crew requirements
				private _transportBlacklistMask = [];
				_allocArgs = [_enemyEff, _allocationFlags, _srcGarrComp, _srcGarrEff,
					_payloadWhitelistMask, _payloadBlacklistMask,
					_transportWhitelistMask, _transportBlacklistMask];
				CALLSM("GarrisonModel", "allocateUnits", _allocArgs)
			};
			default { [] };
		};

		// Bail if we have failed to allocate resources
		if (count _allocResult == 0) exitWith {
			OOP_DEBUG_MSG("Failed to allocate resources: %1", [_allocArgs]);
			T_CALLM1("setScore", ZERO_SCORE);
		};

		_allocResult params ["_compAllocated", "_effAllocated", "_compRemaining", "_effRemaining"];

		// Bail if remaining efficiency is below minimum level for this garrison
		/*
		// Disabled those for now, probably we want QRFs to be quite aggressive
		private _srcDesiredEff = CALLM1(_worldNow, "getDesiredEff", _srcGarrPos);
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateAttack) > 0) exitWith {
			OOP_DEBUG_2("Remaining attack capability requirement not satisfied: %1 VS %2", _effRemaining, _srcDesiredEff);
			T_CALLM1("setScore", ZERO_SCORE);
		};
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateCrew) > 0 ) exitWith {	// We must have enough crew to operate vehicles ...
			OOP_DEBUG_1("Remaining crew requirement not satisfied: %1", _effRemaining);
			T_CALLM1("setScore", ZERO_SCORE);
		};
		*/

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

		// Take the sum of the attack part of the efficiency vector.
		private _detachEffStrength = CALLSM1("CmdrAction", "getDetachmentStrength", _effAllocated);

		// Air units prefer to attack higher threat targets only
		if(_srcType == GARRISON_TYPE_AIR) then {
			// Air garrison likes to attack armor, and hates AA
			// This equation will apply a weighting to the enemy efficiency and then calculate its modified strength.
			// The ration of the original strength to modified is used as a coefficient to calculate our own adjusted strength.
			// It means our adjusted strength goes up a lot against armor and down a lot against AA, resulting in scoring 
			// doing the same.
			//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
			#define AIR_GARRISON_EFF_PROFILE 			[0.25,	1.5,	3,		1,		1,		1,		1,		-3,		1,		1,		1,		1,		1,		1]
			private _enemyStr = EFF_SUM(_enemyEff);
			if(_enemyStr > 0) then {
				private _modifiedEnemyEff = EFF_MUL(_enemyEff, AIR_GARRISON_EFF_PROFILE);
				private _modifiedEnemyStr = EFF_SUM(_modifiedEnemyEff);
				// We also apply a response curve to stop air units responding vs weak enemy, but preference them vs strong:
				// Its called softplus Relu https://en.wikipedia.org/wiki/Rectifier_(neural_networks)#Softplus
				// See this function at https://www.desmos.com/calculator/ptlmv3tdcf
				#define AIR_RESPONSE_FN(_str) (1.45 * ln(1 + exp((_str) - 4.7)))
				private _strengthScalar = AIR_RESPONSE_FN(_modifiedEnemyStr) / _enemyStr;
				_detachEffStrength = _detachEffStrength * CLAMP_POSITIVE(_strengthScalar);
			};
		};

		// Air units care about distance less than ground units (check https://www.desmos.com/calculator/pjs09xfxkm to determine good values)
		private _fallOffRate = if(_srcType == GARRISON_TYPE_AIR) then { 0.4 } else { 1 };
		private _distCoeff = CALLSM2("CmdrAction", "calcDistanceFalloff", _srcGarrPos distance _tgtClusterPos, _fallOffRate);

		// Our final resource score combining available efficiency, distance and transportation.
		private _scoreResource = _detachEffStrength * _distCoeff;

		// TODO: implement priority score for TakeLocationCmdrAction
		// TODO:OPT cache these scores!
		private _scorePriority = 1;

		// OOP_DEBUG_MSG("[w %1 a %2] %3 take %4 Score %5, _effAllocated = %6, _detachEffStrength = %7, _distCoeff = %8",
		// 	[_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtCluster) ARG [_scorePriority ARG _scoreResource] 
		// 	ARG _effAllocated ARG _detachEffStrength ARG _distCoeff]);

		// APPLY STRATEGY
		// Get our Cmdr strategy implementation and apply it
		private _side = GETV(_srcGarr, "side");
		private _strategy = CALLSM("AICommander", "getCmdrStrategy", [_side]);
		private _baseScore = MAKE_SCORE_VEC(_scorePriority, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getQRFScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _tgtCluster ARG _effAllocated]);
		T_CALLM("setScore", [_score]);
		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""QRF"", ""src_garrison"": ""%2"", ""tgt_cluster"": ""%3"", ""score_priority"": %4, ""score_resource"": %5, ""score_strategy"": %6, ""score_completeness"": %7}}", 
			_side, LABEL(_srcGarr), LABEL(_tgtCluster), _score#0, _score#1, _score#2, _score#3];
		OOP_INFO_MSG(_str, []);
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	// TODO: factor out logic for working out detachments for various situations
	/* private */ METHOD(getDetachmentEff)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		private _srcGarrId = T_GETV("srcGarrId");
		private _tgtClusterId = T_GETV("tgtClusterId");

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtCluster = CALLM(_worldFuture, "getCluster", [_tgtClusterId]);
		ASSERT_OBJECT(_tgtCluster);

		// Calculate how much efficiency is available for QRF then clamp desired efficiency against it

		// How much resources src can spare.
		private _srcOverEff = EFF_MAX_SCALAR(CALLM(_worldNow, "getOverDesiredEff", [_srcGarr]), 0);

		// How much resources we need to defeat target and be safe in hot zone
		private _clusterEff = GETV(_tgtCluster, "efficiency");
		private _zoneEff = CALLM(_worldNow, "getDesiredEff", [GETV(_tgtCluster, "pos")]);
		// Max of our two eff predictions * 1.5 (for margin of safety, somewhat), with a min required value so we don't send something ridiculously small
		private _tgtRequiredEff = EFF_MAX(EFF_MUL_SCALAR(EFF_MAX(_clusterEff, _zoneEff), 1.5), EFF_MIN_EFF);

		// Min of those values
		// TODO: make this a "nice" composition. We don't want to send a bunch of guys to walk or whatever.
		private _effAvailable = EFF_MAX_SCALAR(EFF_FLOOR(EFF_MIN(_srcOverEff, _tgtRequiredEff)), 0);

		//OOP_DEBUG_MSG("[w %1 a %2] %3 take %4 getDetachmentEff: _tgtRequiredEff = %5, _srcOverEff = %6, _effAvailable = %7", [_worldNow ARG _thisObject ARG _srcGarr ARG _tgtCluster ARG _tgtRequiredEff ARG _srcOverEff ARG _effAvailable]);

		// Only send a reasonable amount at a time
		// TODO: min compositions should be different for detachments and garrisons holding outposts.
		if(!EFF_GTE(_effAvailable, EFF_MIN_EFF)) exitWith { EFF_ZERO };

		//if(_effAvailable#0 < MIN_COMP#0 or _effAvailable#1 < MIN_COMP#1) exitWith { [0,0] };
		_effAvailable
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
		private _record = NEW("AttackCmdrActionRecord", []);

		// Fill data values
		//SETV(_record, "garRef", GETV(_garModel, "actual"));

		// Resolve target
		private _tgtClusterModel = CALLM1(_world, "getCluster", T_GETV("tgtClusterId"));
		private _pos = GETV(_tgtClusterModel, "pos");
		SETV(_record, "pos", _pos);

		// Serialize and delete it
		private _serial = SERIALIZE(_record);
		DELETE(_record);

		// Return the serialized data
		_serial
	ENDMETHOD;

ENDCLASS;

REGISTER_DEBUG_MARKER_STYLE("QRFCmdrAction", "ColorRed", "mil_destroy");

#ifdef _SQF_VM

#define SRC_POS [0, 0, 0]
#define TARGET_POS [1000, 2, 3]

["QRFCmdrAction", {
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

	private _targetCluster = NEW("ClusterModel", [_world ARG []]);
	private _targetEff = +T_EFF_null;
	_targetEff set [T_EFF_soft, 10];
	SETV(_targetCluster, "pos", TARGET_POS);
	SETV(_targetCluster, "efficiency", _targetEff);

	private _thisObject = NEW("QRFCmdrAction", [GETV(_garrison, "id") ARG GETV(_targetCluster, "id")]);
	
	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	T_CALLM("updateScore", [_world ARG _future]);
	private _finalScore = T_CALLM("getFinalScore", []);
	//diag_log format ["QRF action final score: %1", _finalScore];
	["Score is above zero", _finalScore > 0] call test_Assert;

	private _nowSimState = T_CALLM("applyToSim", [_world]);
	private _futureSimState = T_CALLM("applyToSim", [_future]);
	["Now sim state correct", _nowSimState == CMDR_ACTION_STATE_READY_TO_MOVE] call test_Assert;
	["Future sim state correct", _futureSimState == CMDR_ACTION_STATE_END] call test_Assert;
	
	private _futureCluster = CALLM(_future, "getCluster", [GETV(_targetCluster, "id")]);
	["Cluster is destroyed in future", CALLM0(_futureCluster, "isDead")] call test_Assert;
}] call test_AddTest;

#endif