#include "common.hpp"
FIX_LINE_NUMBERS()

/*
Class: AI.CmdrAI.CmdrAction.Actions.ReinforceCmdrAction

CmdrAI garrison reinforcement action. 
Takes a source and target garrison id.
Sends a detachment from the source garrison to join the target garrison.

Parent: <TakeOrJoinCmdrAction>
*/

#define OOP_CLASS_NAME ReinforceCmdrAction
CLASS("ReinforceCmdrAction", "TakeOrJoinCmdrAction")
	VARIABLE_ATTR("tgtGarrId", [ATTR_SAVE]);

	/*
	Constructor: new

	Create a CmdrAI action to send a detachment from the source garrison to join
	the target garrison.
	
	Parameters:
		_srcGarrId - Number, <Model.GarrisonModel> id from which to send the patrol detachment.
		_tgtGarrId - Number, <Model.GarrisonModel> id to reinforce with the detachment.
	*/
	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId")];
		T_SETV("tgtGarrId", _tgtGarrId);

		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		T_SET_AST_VAR("targetVar", [TARGET_TYPE_GARRISON ARG _tgtGarrId]);
	ENDMETHOD;

	protected override METHOD(updateIntel)
		params [P_THISOBJECT, P_STRING("_world")];

		ASSERT_MSG(CALLM0(_world, "isReal"), "Can only updateIntel from real world, this shouldn't be possible as updateIntel should ONLY be called by CmdrAction");

		private _intelClone = T_GETV("intelClone");
		private _intel = NULL_OBJECT;
		private _intelNotCreated = IS_NULL_OBJECT(_intelClone);
		if(_intelNotCreated) then {
			// Create new intel object and fill in the constant values
			_intel = NEW("IntelCommanderActionReinforce", []);

			private _srcGarrId = T_GETV("srcGarrId");
			private _tgtGarrId = T_GETV("tgtGarrId");
			private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			ASSERT_OBJECT(_srcGarr);
			private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
			ASSERT_OBJECT(_tgtGarr);

			CALLM0(_intel, "create");

			private _compAllocated = T_GET_AST_VAR("detachmentCompVar");
			if(_compAllocated#T_INF#T_INF_officer > 0) then {
				SETV(_intel, "type", "Assign New Officer");
			} else {
				SETV(_intel, "type", "Reinforce Garrison");
			};
			SETV(_intel, "side", GETV(_srcGarr, "side"));
			SETV(_intel, "srcGarrison", GETV(_srcGarr, "actual"));
			SETV(_intel, "posSrc", GETV(_srcGarr, "pos"));
			SETV(_intel, "tgtGarrison", GETV(_tgtGarr, "actual"));
			// SETV(_intel, "location", GETV(_tgtGarr, "actual"));
			SETV(_intel, "posTgt", GETV(_tgtGarr, "pos"));
			SETV(_intel, "dateDeparture", T_GET_AST_VAR("startDateVar"));

			T_CALLM("updateIntelFromDetachment", [_world ARG _intel]);

			// If we just created this intel then register it now 
			_intelClone = CALLSM("AICommander", "registerIntelCommanderAction", [_intel]);
			T_SETV("intelClone", _intelClone);

			// Send the intel to some places that should "know" about it
			T_CALLM("addIntelAt", [_world ARG GETV(_srcGarr, "pos")]);
			T_CALLM("addIntelAt", [_world ARG GETV(_tgtGarr, "pos")]);

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
			CALLM0(_intelClone, "updateInDb");
		};
	ENDMETHOD;

	public override METHOD(updateScore)
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		private _srcGarrId = T_GETV("srcGarrId");
		private _tgtGarrId = T_GETV("tgtGarrId");

		private _srcGarr = CALLM1(_worldNow, "getGarrison", _srcGarrId);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarr = CALLM1(_worldFuture, "getGarrison", _tgtGarrId);
		ASSERT_OBJECT(_tgtGarr);

		// Bail if src or dst are dead
		if(CALLM0(_srcGarr, "isDead") or {CALLM0(_tgtGarr, "isDead")}) exitWith {
			OOP_DEBUG_0("Src or dst garrison is dead");
			T_CALLM1("setScore", ZERO_SCORE);
		};

		private _side = GETV(_srcGarr, "side");
		private _tgtGarrEff = GETV(_tgtGarr, "efficiency");
		private _srcGarrEff = GETV(_srcGarr, "efficiency");
		private _srcGarrComp = GETV(_srcGarr, "composition");

		// TODO: full desired composition metric, not just officers
		private _tgtLocation = CALLM0(_tgtGarr, "getLocation");
		private _sendAnOfficer = _tgtLocation != NULL_OBJECT 
			&& { GETV(_tgtLocation, "type") in [LOCATION_TYPE_BASE, LOCATION_TYPE_AIRPORT, LOCATION_TYPE_OUTPOST] }
			&& { CALLM0(_srcGarr, "countOfficers") > 1 } 
			&& { CALLM0(_tgtGarr, "countOfficers") == 0 };

		// CALCULATE THE RESOURCE SCORE
		// In this case it is how well the source garrison can meet the resource requirements of this action,
		// specifically efficiency, transport and distance. Score is 0 when full requirements cannot be met, and 
		// increases with how much over the full requirements the source garrison is (i.e. how much OVER the 
		// required efficiency it is), with a distance based fall off (further away from target is lower scoring).

		// How much more efficiency we must overcompensate at this place
		private _tgtUnderEff = EFF_MAX_SCALAR(EFF_MUL_SCALAR(CALLM(_worldFuture, "getOverDesiredEff", [_tgtGarr]), -1), 0);

		// Bail if there is no need to reinforce this
		if (_tgtUnderEff isEqualTo T_EFF_null && !_sendAnOfficer) exitWith {
			OOP_DEBUG_0("No need to reinforce dst garrison");
			T_CALLM1("setScore", ZERO_SCORE);
		};

		private _allocationFlags = [	SPLIT_VALIDATE_ATTACK,
								SPLIT_VALIDATE_CREW,		// Ensure we can drive our vehicles
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
		private _dist = CALLM2(gStrategicNavGrid, "calculateGroundDistance", _srcGarrPos, _tgtGarrPos);

		if (_dist == -1) exitWith {
			OOP_DEBUG_0("Destination is unreachable over ground");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		if (_sendAnOfficer || _dist > REINFORCE_NO_TRANSPORT_DISTANCE_MAX) then {
			_needTransport = true;
		};

		if (_needTransport) then {
			_allocationFlags pushBack SPLIT_VALIDATE_TRANSPORT;	// Ensure we can transport ourselves
		};

		// Try to allocate units
		private _payloadWhitelistMask = if (_needTransport) then {
			T_comp_ground_or_infantry_mask 
		} else {
			T_comp_infantry_mask 
		};
		private _payloadBlacklistMask = T_comp_static_or_cargo_mask;			// Don't take static weapons or cargo under any conditions
		private _transportWhitelistMask = T_comp_ground_or_infantry_mask;	// Take ground units, take any infantry to satisfy crew requirements
		private _transportBlacklistMask = [];
		private _requiredComp = [];
		if(_sendAnOfficer) then {
			// Lets send an officer as well!
			_requiredComp = [
				[T_INF, T_INF_officer, 1]
			];
			// Any make sure we have some escort.
			_tgtUnderEff = EFF_MAX(_tgtUnderEff, EFF_MIN_EFF);
		};

		private _args = [_tgtUnderEff, _allocationFlags, _srcGarrComp, _srcGarrEff,
					_payloadWhitelistMask, _payloadBlacklistMask,
					_transportWhitelistMask, _transportBlacklistMask,
					_requiredComp];
		private _allocResult = CALLSM("GarrisonModel", "allocateUnits", _args);

		// Bail if we have failed to allocate resources
		if ((count _allocResult) == 0) exitWith {
			OOP_DEBUG_MSG("Failed to allocate resources", []);
			T_CALLM1("setScore", ZERO_SCORE);
		};

		_allocResult params ["_compAllocated", "_effAllocated", "_compRemaining", "_effRemaining"];

		if(_sendAnOfficer) then {
			ASSERT(_compAllocated#T_INF#T_INF_officer == 1);
		};
		// diag_log format ["Allocation results: %1", _allocResult];

		private _srcDesiredEff = CALLM1(_worldNow, "getDesiredEff", _srcGarrPos);

		// Bail if remaining efficiency is below minimum level for this garrison
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateAttack) > 0) exitWith {
			OOP_DEBUG_2("Remaining attack capability requirement not satisfied: %1 VS %2", _effRemaining, _srcDesiredEff);
			T_CALLM1("setScore", ZERO_SCORE);
		};
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateCrew) > 0 ) exitWith {	// we must have enough crew to operate vehicles ...
			OOP_DEBUG_1("Remaining crew requirement not satisfied: %1", _effRemaining);
			T_CALLM1("setScore", ZERO_SCORE);
		};

		T_SET_AST_VAR("detachmentEffVar", _effAllocated);
		T_SET_AST_VAR("detachmentCompVar", _compAllocated);

		// How much to scale the score for distance to target
		private _dist = CALLM2(gStrategicNavGrid, "calculateGroundDistance", _srcGarrPos, _tgtGarrPos);
		if (_dist == -1) exitWith {
			OOP_DEBUG_0("Destination is unreachable over ground");
			T_CALLM("setScore", [ZERO_SCORE]);
		};
		private _distCoeff = CALLSM1("CmdrAction", "calcDistanceFalloff", _dist);
		private _detachEffStrength = CALLSM1("CmdrAction", "getDetachmentStrength", _effAllocated); // A number!

		// Our final resource score combining available efficiency, distance and transportation.
		private _scoreResource = _detachEffStrength * _distCoeff;

		private _scorePriority = switch true do {
			case (_scoreResource == 0): {0};
			case (_sendAnOfficer): {
				// How much we want an officer can be estimated by the total strength of the 
				// garrison (including this detachment)
				// https://www.desmos.com/calculator/vealgnewq1
				log (1 + (CALLSM1("CmdrAction", "getDetachmentStrength", _effAllocated) + CALLSM1("CmdrAction", "getDetachmentStrength", _tgtGarrEff)) / 8)
				
			};
			// TODO:OPT cache these scores!
			default {CALLM(_worldFuture, "getReinforceRequiredScore", [_tgtGarr])};
		};

		// CALCULATE START DATE
		// Work out time to start based on how much force we mustering and distance we are travelling.
		// https://www.desmos.com/calculator/mawpkr88r3 * https://www.desmos.com/calculator/0vb92pzcz8 * 0.1
		private _delay = 50 * log (0.1 * _detachEffStrength + 1) * (1 + 2 * log (0.0003 * _dist + 1))  * 0.1 + (30 + random 15);
		if(_sendAnOfficer) then {
			// Longer wait for officer reinforcements
			_delay = _delay * 2;
		};

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
		
		OOP_DEBUG_MSG("[w %1 a %2] %3 reinforce %4 Score %5 _detachEff = %6 _detachEffStrength = %7 _distCoeff = %8", [_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtGarr) ARG [_scorePriority ARG _scoreResource] ARG _effAllocated ARG _detachEffStrength ARG _distCoeff]);

		// APPLY STRATEGY
		// Get our Cmdr strategy implementation and apply it
		private _strategy = CALLSM("AICommander", "getCmdrStrategy", [_side]);
		private _baseScore = MAKE_SCORE_VEC(_scorePriority, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getReinforceScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _tgtGarr ARG _effAllocated]);
		T_CALLM("setScore", [_score]);
		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Reinforce"", ""src_garrison"": ""%2"", ""tgt_garrison"": ""%3"", ""score_priority"": %4, ""score_resource"": %5, ""score_strategy"": %6, ""score_completeness"": %7}}", 
			_side, LABEL(_srcGarr), LABEL(_tgtGarr), _score#0, _score#1, _score#2, _score#3];
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
	ENDMETHOD;

ENDCLASS;

REGISTER_DEBUG_MARKER_STYLE("ReinforceCmdrAction", "ColorWhite", "mil_join");

#ifdef _SQF_VM

#define SRC_POS [1, 2, 0]
#define TARGET_POS [1000, 2, 3]

["ReinforceCmdrAction", {
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

	private _targetGarrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _targetComp = +T_comp_null;
	(_targetComp#T_INF) set [T_INF_rifleman, 4];
	private _targetEff = [_targetComp] call comp_fnc_getEfficiency;
	SETV(_targetGarrison, "efficiency", _targetEff);
	SETV(_targetGarrison, "composition", _targetComp);
	SETV(_targetGarrison, "pos", TARGET_POS);

	private _thisObject = NEW("ReinforceCmdrAction", [GETV(_garrison, "id") ARG GETV(_targetGarrison, "id")]);
	
	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	T_CALLM("updateScore", [_world ARG _future]);
	private _finalScore = T_CALLM("getFinalScore", []);

	//diag_log format ["Reinforce final score: %1", _finalScore];
	["Score is above zero", _finalScore > 0] call test_Assert;

	T_CALLM("applyToSim", [_world]);
	true
	// ["Object exists", !(isNil "_class")] call test_Assert;
	// ["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

#endif