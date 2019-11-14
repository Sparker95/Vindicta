#include "..\..\common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.Actions.ReinforceCmdrAction

CmdrAI garrison reinforcement action. 
Takes a source and target garrison id.
Sends a detachment from the source garrison to join the target garrison.

Parent: <TakeOrJoinCmdrAction>
*/

#define pr private

CLASS("ReinforceCmdrAction", "TakeOrJoinCmdrAction")
	VARIABLE("tgtGarrId");
	
	/*
	Constructor: new

	Create a CmdrAI action to send a detachment from the source garrison to join
	the target garrison.
	
	Parameters:
		_srcGarrId - Number, <Model.GarrisonModel> id from which to send the patrol detachment.
		_tgtGarrId - Number, <Model.GarrisonModel> id to reinforce with the detachment.
	*/
	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId")];
		T_SETV("tgtGarrId", _tgtGarrId);

		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		T_SET_AST_VAR("targetVar", [TARGET_TYPE_GARRISON ARG _tgtGarrId]);
		// T_SET_AST_VAR("splitFlagsVar", [ASSIGN_TRANSPORT ARG FAIL_UNDER_EFF ARG OCCUPYING_FORCE_HINT]);
#ifdef DEBUG_CMDRAI
		T_SETV("debugColor", "ColorWhite");
		T_SETV("debugSymbol", "mil_join")
#endif
	} ENDMETHOD;

	/* protected override */ METHOD("updateIntel") {
		params [P_THISOBJECT, P_STRING("_world")];

		ASSERT_MSG(CALLM(_world, "isReal", []), "Can only updateIntel from real world, this shouldn't be possible as updateIntel should ONLY be called by CmdrAction");

		T_PRVAR(intelClone);
		private _intel = NULL_OBJECT;
		private _intelNotCreated = IS_NULL_OBJECT(_intelClone);
		if(_intelNotCreated) then
		{
			// Create new intel object and fill in the constant values
			_intel = NEW("IntelCommanderActionReinforce", []);

			T_PRVAR(srcGarrId);
			T_PRVAR(tgtGarrId);
			private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			ASSERT_OBJECT(_srcGarr);
			private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
			ASSERT_OBJECT(_tgtGarr);

			CALLM(_intel, "create", []);

			SETV(_intel, "type", "Reinforce garrison");
			SETV(_intel, "side", GETV(_srcGarr, "side"));
			SETV(_intel, "srcGarrison", GETV(_srcGarr, "actual"));
			SETV(_intel, "posSrc", GETV(_srcGarr, "pos"));
			SETV(_intel, "tgtGarrison", GETV(_tgtGarr, "actual"));
			// SETV(_intel, "location", GETV(_tgtGarr, "actual"));
			SETV(_intel, "posTgt", GETV(_tgtGarr, "pos"));
			SETV(_intel, "dateDeparture", T_GET_AST_VAR("startDateVar"));

			T_CALLM("updateIntelFromDetachment", [_world ARG _intel]);

			// If we just created this intel then register it now 
			_intelClone = CALL_STATIC_METHOD("AICommander", "registerIntelCommanderAction", [_intel]);
			T_SETV("intelClone", _intelClone);

			// Send the intel to some places that should "know" about it
			T_CALLM("addIntelAt", [_world ARG GETV(_srcGarr, "pos")]);
			T_CALLM("addIntelAt", [_world ARG GETV(_tgtGarr, "pos")]);

			// Reveal it to player side
			if (random 100 < 80) then {
				CALLSM1("AICommander", "revealIntelToPlayerSide", _intel);
			};

			// Reveal some friendly locations near the destination to the garrison performing the task
			private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
			if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
				private _detachedGarrModel = CALLM(_world, "getGarrison", [_detachedGarrId]);
				{
					CALLM2(_x, "addKnownFriendlyLocationsActual", GETV(_tgtGarr, "pos"), 2000); // Reveal friendly locations to src. and detachment which are within 2000 meters from destination
				} forEach [_srcGarr, _detachedGarrModel];
				CALLM2(_tgtGarr, "addKnownFriendlyLocationsActual", GETV(_srcGarr, "pos"), 2000); // Reveal friendly locations to dest. which are within 2000 meters from source
			};
		} else {
			T_CALLM("updateIntelFromDetachment", [_world ARG _intelClone]);
			CALLM(_intelClone, "updateInDb", []);
		};
	} ENDMETHOD;

	/* override */ METHOD("updateScore") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtGarrId);

		// TODO: do this properly wrt to now and future
		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarr = CALLM(_worldFuture, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		// Bail if src or dst are dead
		if(CALLM(_srcGarr, "isDead", []) or {CALLM(_tgtGarr, "isDead", [])}) exitWith {
			OOP_DEBUG_0("Src or dst garrison is dead");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		private _side = GETV(_srcGarr, "side");
		private _tgtGarrEff = GETV(_tgtGarr, "efficiency");
		private _srcGarrEff = GETV(_srcGarr, "efficiency");
		private _srcGarrComp = GETV(_srcGarr, "composition");

		// CALCULATE THE RESOURCE SCORE
		// In this case it is how well the source garrison can meet the resource requirements of this action,
		// specifically efficiency, transport and distance. Score is 0 when full requirements cannot be met, and 
		// increases with how much over the full requirements the source garrison is (i.e. how much OVER the 
		// required efficiency it is), with a distance based fall off (further away from target is lower scoring).

		// How much more efficiency we must overcompensate at this place
		pr _tgtUnderEff = EFF_MAX_SCALAR(EFF_MUL_SCALAR(CALLM(_worldFuture, "getOverDesiredEff", [_tgtGarr]), -1), 0);

		// Bail if there is no need to reinforce this
		if (_tgtUnderEff isEqualTo T_EFF_null) exitWith {
			OOP_DEBUG_0("No need to reinforce dst garrison");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		pr _allocationFlags = [	SPLIT_VALIDATE_CREW,		// Ensure we can drive our vehicles
								SPLIT_VALIDATE_CREW_EXT];	// Ensure we provide enough crew to destination

		private _needTransport = false;

		// Calculate if dst needs more crew
		private _extraCrewRequired = 0;
		private _crewCurrent = (_tgtGarrEff#T_EFF_crew);
		if (_crewCurrent <= (_tgtGarrEff#T_EFF_reqCrew)) then {
			_extraCrewRequired = 1.3 * ((_tgtGarrEff#T_EFF_reqCrew) - _crewCurrent) min 6;
			_tgtUnderEff set [T_EFF_crew, ceil _extraCrewRequired];
		};

		// Calculate if dst needs more transport
		private _extraTransportRequired = 0;
		if ((_tgtGarrEff#T_EFF_transport) <= (_tgtGarrEff#T_EFF_reqTransport)) then {
			_extraTransportRequired = 1.3 * ((_tgtGarrEff#T_EFF_reqTransport) - (_tgtGarrEff#T_EFF_transport)) min 3;
			_tgtUnderEff set [T_EFF_transport, ceil _extraTransportRequired];
			_allocationFlags pushBack SPLIT_VALIDATE_TRANSPORT_EXT;	// Ensure we provide enough extra transport
			_needTransport = true;
		};

		// Check if we will need transport or not
		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _tgtGarrPos = GETV(_tgtGarr, "pos");
		private _dist = _srcGarrPos distance _tgtGarrPos;
		if (_dist > REINFORCE_NO_TRANSPORT_DISTANCE_MAX) then {
			_needTransport = true;
		};

		if (_needTransport) then {
			_allocationFlags pushBack SPLIT_VALIDATE_TRANSPORT;	// Ensure we can transport ourselves
		};

		// Try to allocate units
		pr _payloadWhitelistMask = if (_needTransport) then { T_comp_ground_or_infantry_mask } else { T_comp_ground_or_infantry_mask };
		pr _payloadBlacklistMask = T_comp_static_mask;					// Don't take static weapons under any conditions
		pr _transportWhitelistMask = T_comp_ground_or_infantry_mask;	// Take ground units, take any infantry to satisfy crew requirements
		pr _transportBlacklistMask = [];
		pr _args = [_tgtUnderEff, _allocationFlags, _srcGarrComp, _srcGarrEff,
					_payloadWhitelistMask, _payloadBlacklistMask,
					_transportWhitelistMask, _transportBlacklistMask];
		private _allocResult = CALLSM("GarrisonModel", "allocateUnits", _args);

		// Bail if we have failed to allocate resources
		if ((count _allocResult) == 0) exitWith {
			OOP_DEBUG_MSG("Failed to allocate resources", []);
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		_allocResult params ["_compAllocated", "_effAllocated", "_compRemaining", "_effRemaining"];

		// diag_log format ["Allocation results: %1", _allocResult];

		pr _srcDesiredEff = CALLM1(_worldNow, "getDesiredEff", _srcGarrPos);

		// Bail if remaining efficiency is below minimum level for this garrison
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateAttack) > 0) exitWith {
			OOP_DEBUG_2("Remaining attack capability requirement not satisfied: %1 VS %2", _effRemaining, _srcDesiredEff);
			T_CALLM("setScore", [ZERO_SCORE]);
		};
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateCrew) > 0 ) exitWith {	// we must have enough crew to operate vehicles ...
			OOP_DEBUG_1("Remaining crew requirement not satisfied: %1", _effRemaining);
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		T_SET_AST_VAR("detachmentEffVar", _effAllocated);
		T_SET_AST_VAR("detachmentCompVar", _compAllocated);

		// How much to scale the score for distance to target
		private _distCoeff = CALLSM("CmdrAction", "calcDistanceFalloff", [_srcGarrPos ARG _tgtGarrPos]);
		// How much to scale the score for transport requirements
		private _transportationScore = if(!_needTransport) then {
			// If we are less than XXXm then we don't need transport so set the transport score to 1
			// (we "fullfilled" the transport requirements of not needing transport)
			1
		} else {
			// We will force transport on top of scoring if we need to.
			CALLM1(_srcGarr, "transportationScore", _effRemaining);
		};

		private _detachEffStrength = CALLSM1("CmdrAction", "getDetachmentStrength", _effAllocated); // A number!

		// Our final resource score combining available efficiency, distance and transportation.
		private _scoreResource = _detachEffStrength * _distCoeff * _transportationScore;

		// TODO:OPT cache these scores!
		private _scorePriority = if(_scoreResource == 0) then {0} else {CALLM(_worldFuture, "getReinforceRequiredScore", [_tgtGarr])};

		// CALCULATE START DATE
		// Work out time to start based on how much force we mustering and distance we are travelling.
		// https://www.desmos.com/calculator/mawpkr88r3 * https://www.desmos.com/calculator/0vb92pzcz8 * 0.1
		private _delay = 50 * log (0.1 * _detachEffStrength + 1) * (1 + 2 * log (0.0003 * _dist + 1))  * 0.1 + (30 + random 15);

		// Shouldn't need to cap it, the functions above should always return something reasonable, if they don't then fix them!
		// _delay = 0 max (120 min _delay);
		private _startDate = DATE_NOW;

		_startDate set [4, _startDate#4 + _delay];

		T_SET_AST_VAR("startDateVar", _startDate);

		//private _str = format ["%1->%2 _scorePriority = %3, _srcOverEff = %4, _srcOverEffScore = %5, _distCoeff = %6, _scoreResource = %7", _srcGarrId, _tgtGarrId, _scorePriority, _srcOverEff, _srcOverEffScore, _distCoeff, _scoreResource];
		//OOP_INFO_0(_str);
		// if(_scorePriority > 0 and _scoreResource > 0) then {
		private _srcEff = GETV(_srcGarr, "efficiency");
		private _tgtEff = GETV(_tgtGarr, "efficiency");
		
		OOP_DEBUG_MSG("[w %1 a %2] %3 reinforce %4 Score %5 _detachEff = %6 _detachEffStrength = %7 _distCoeff = %8 _transportationScore = %9", [_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtGarr) ARG [_scorePriority ARG _scoreResource] ARG _effAllocated ARG _detachEffStrength ARG _distCoeff ARG _transportationScore]);

		// APPLY STRATEGY
		// Get our Cmdr strategy implementation and apply it
		private _strategy = CALL_STATIC_METHOD("AICommander", "getCmdrStrategy", [_side]);
		private _baseScore = MAKE_SCORE_VEC(_scorePriority, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getReinforceScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _tgtGarr ARG _effAllocated]);
		T_CALLM("setScore", [_score]);
		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Reinforce"", ""src_garrison"": ""%2"", ""tgt_garrison"": ""%3"", ""score_priority"": %4, ""score_resource"": %5, ""score_strategy"": %6, ""score_completeness"": %7}}", 
			_side, LABEL(_srcGarr), LABEL(_tgtGarr), _score#0, _score#1, _score#2, _score#3];
		OOP_INFO_MSG(_str, []);
		#endif
	} ENDMETHOD;

	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	// TODO: factor out logic for working out detachments for various situations
	METHOD("getDetachmentEff") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtGarrId);

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarr = CALLM(_worldFuture, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);
		
		// Calculate how much efficiency is available for reinforcements then clamp desired efficiency against it

		// How much resources src can spare (how much is it over its desired efficiency).
		private _srcOverEff = EFF_MAX_SCALAR(CALLM(_worldNow, "getOverDesiredEff", [_srcGarr]), 0);

		// How much resources tgt needs (how much is it under its desired efficiency).
		private _tgtUnderEff = EFF_MAX_SCALAR(EFF_MUL_SCALAR(CALLM(_worldFuture, "getOverDesiredEff", [_tgtGarr]), -1), 0);

		// If tgt is depleted at all then we will send a min size reinforcement at least
		if(!EFF_LTE(_tgtUnderEff, EFF_ZERO)) then {
			_tgtUnderEff = EFF_MAX(_tgtUnderEff, EFF_MIN_EFF);
		};

		// Result is the mininum of the available and required efficiencies
		private _effAvailable = EFF_MAX_SCALAR(EFF_FLOOR(EFF_MIN(_srcOverEff, _tgtUnderEff)), 0);

		OOP_DEBUG_MSG("[w %1 a %2] %3 reinforce %4 getDetachmentEff: _tgtUnderEff = %5, _srcOverEff = %6, _effAvailable = %7", [_worldNow ARG _thisObject ARG _srcGarr ARG _tgtGarr ARG _tgtUnderEff ARG _srcOverEff ARG _effAvailable]);

		// Only send a reasonable amount at a time
		if(!EFF_GTE(_effAvailable, EFF_MIN_EFF)) exitWith { EFF_ZERO };

		_effAvailable
	} ENDMETHOD;

	/*
	Method: (virtual) getRecordSerial
	Returns a serialized CmdrActionRecord associated with this action.
	Derived classes should implement this to have proper support for client's UI.
	
	Parameters:	
		_world - <Model.WorldModel>, real world model that is being used.
	*/
	/* virtual override */ METHOD("getRecordSerial") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garModel"), P_OOP_OBJECT("_world")];

		// Create a record
		private _record = NEW("ReinforceCmdrActionRecord", []);

		// Fill data values
		//SETV(_record, "garRef", GETV(_garModel, "actual"));
		private _tgtGarModel = CALLM1(_world, "getGarrison", T_GETV("tgtGarrId"));
		SETV(_record, "dstGarRef", GETV(_tgtGarModel, "actual"));

		// Serialize and delete it
		private _serial = SERIALIZE(_record);
		DELETE(_record);

		// Return the serialized data
		_serial
	} ENDMETHOD;

ENDCLASS;

#ifdef _SQF_VM

#define SRC_POS [1, 2, 0]
#define TARGET_POS [1000, 2, 3]

["ReinforceCmdrAction", {
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

	private _targetGarrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _targetComp = +T_comp_null;
	(_targetComp#T_INF) set [T_INF_rifleman, 4];
	private _targetEff = [_targetComp] call comp_fnc_getEfficiency;
	SETV(_targetGarrison, "efficiency", _targetEff);
	SETV(_targetGarrison, "composition", _targetComp);
	SETV(_targetGarrison, "pos", TARGET_POS);

	private _thisObject = NEW("ReinforceCmdrAction", [GETV(_garrison, "id") ARG GETV(_targetGarrison, "id")]);
	
	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	CALLM(_thisObject, "updateScore", [_world ARG _future]);
	private _finalScore = CALLM(_thisObject, "getFinalScore", []);

	diag_log format ["Reinforce final score: %1", _finalScore];
	["Score is above zero", _finalScore > 0] call test_Assert;

	CALLM(_thisObject, "applyToSim", [_world]);
	true
	// ["Object exists", !(isNil "_class")] call test_Assert;
	// ["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

#endif