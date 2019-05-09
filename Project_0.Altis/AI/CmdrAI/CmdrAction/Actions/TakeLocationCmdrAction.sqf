#include "..\..\common.hpp"

// #define CMDR_ACTION_STATE_SPLIT				(CMDR_ACTION_STATE_CUSTOM+1)
// #define CMDR_ACTION_STATE_READY_TO_MOVE		(CMDR_ACTION_STATE_CUSTOM+2)
// #define CMDR_ACTION_STATE_MOVED				(CMDR_ACTION_STATE_CUSTOM+3)
// #define CMDR_ACTION_STATE_TARGET_DEAD		(CMDR_ACTION_STATE_CUSTOM+4)
// #define CMDR_ACTION_STATE_ARRIVED 			(CMDR_ACTION_STATE_CUSTOM+5)

CLASS("TakeLocationCmdrAction", "TakeOrJoinCmdrAction")
	VARIABLE("tgtLocId");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtLocId")];

		T_SETV("tgtLocId", _tgtLocId);
		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		T_SET_AST_VAR("targetVar", [TARGET_TYPE_LOCATION]+[_tgtLocId]);

#ifdef DEBUG_CMDRAI
		T_SETV("debugColor", "ColorBlue");
		T_SETV("debugSymbol", "mil_flag")
#endif
	} ENDMETHOD;

	/* override */ METHOD("updateScore") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtLocId);

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtLoc = CALLM(_worldFuture, "getLocation", [_tgtLocId]);
		ASSERT_OBJECT(_tgtLoc);

		private _side = GETV(_srcGarr, "side");
		private _toGarr = CALLM(_tgtLoc, "getGarrison", [_side]);
		if(!IS_NULL_OBJECT(_toGarr)) exitWith {
			// We never take a location we already have a garrison at, this should be reinforcement instead 
			// (however we can get here if multiple potential actions are generated targetting the same location
			// in the same planning cycle, and one gets accepted)
			T_SETV("scorePriority", 0);
			T_SETV("scoreResource", 0);
		};
		// Resource is how much src is *over* composition, scaled by distance (further is lower)
		// i.e. How much units/vehicles src can spare.
		private _detachEff = T_CALLM("getDetachmentEff", [_worldNow ARG _worldFuture]);
		// Save the calculation for use if we decide to perform the action 
		// We DON'T want to try and recalculate the detachment against the real world state when the action actually runs because
		// it won't be correctly taking into account our knowledge about other actions (as represented in the sim world models)
		T_SET_AST_VAR("detachmentEffVar", _detachEff);

		//CALLM1(_worldNow, "getOverDesiredEff", _srcGarr);
		private _detachEffStrength = EFF_SUB_SUM(EFF_DEF_SUB(_detachEff));

		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _tgtLocPos = GETV(_tgtLoc, "pos");

		private _distCoeff = CALLSM("CmdrAction", "calcDistanceFalloff", [_srcGarrPos ARG _tgtLocPos]);
		private _dist = _srcGarrPos distance _tgtLocPos;
		private _transportationScore = if(_dist < 2000) then {
			1
		} else {
			// We will force transport on top of scoring if we need to.
			T_SET_AST_VAR("splitFlagsVar", [ASSIGN_TRANSPORT]+[FAIL_UNDER_EFF]+[CHEAT_TRANSPORT]);
			CALLM(_srcGarr, "transportationScore", [_detachEff])
		};

		private _scoreResource = _detachEffStrength * _distCoeff * _transportationScore;

		// TODO: implement priority score for TakeLocationCmdrAction
		// TODO:OPT cache these scores!
		private _scorePriority = 1;

		// OOP_DEBUG_MSG("[w %1 a %2] %3 take %4 Score %5, _detachEff = %6, _detachEffStrength = %7, _distCoeff = %8, _transportationScore = %9",
		// 	[_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtLoc) ARG [_scorePriority ARG _scoreResource] 
		// 	ARG _detachEff ARG _detachEffStrength ARG _distCoeff ARG _transportationScore]);

		T_SETV("scorePriority", _scorePriority);
		T_SETV("scoreResource", _scoreResource);
	} ENDMETHOD;

	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	// TODO: factor out logic for working out detachments for various situations
	METHOD("getDetachmentEff") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtLocId);

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtLoc = CALLM(_worldFuture, "getLocation", [_tgtLocId]);
		ASSERT_OBJECT(_tgtLoc);

		// How much resources src can spare.
		private _srcOverEff = EFF_MAX_SCALAR(CALLM(_worldNow, "getOverDesiredEff", [_srcGarr]), 0);

		// How much resources tgt needs
		private _tgtRequiredEff = CALLM(_worldNow, "getDesiredEff", [GETV(_tgtLoc, "pos")]);
		// EFF_MAX_SCALAR(EFF_MUL_SCALAR(CALLM(_worldFuture, "getOverDesiredEff", [_tgtLoc]), -1), 0);

		// Min of those values
		// TODO: make this a "nice" composition. We don't want to send a bunch of guys to walk or whatever.
		private _effAvailable = EFF_MAX_SCALAR(EFF_FLOOR(EFF_MIN(_srcOverEff, _tgtRequiredEff)), 0);

		//OOP_DEBUG_MSG("[w %1 a %2] %3 take %4 getDetachmentEff: _tgtRequiredEff = %5, _srcOverEff = %6, _effAvailable = %7", [_worldNow ARG _thisObject ARG _srcGarr ARG _tgtLoc ARG _tgtRequiredEff ARG _srcOverEff ARG _effAvailable]);

		// Only send a reasonable amount at a time
		// TODO: min compositions should be different for detachments and garrisons holding outposts.
		if(!EFF_GTE(_effAvailable, EFF_MIN_EFF)) exitWith { EFF_ZERO };

		//if(_effAvailable#0 < MIN_COMP#0 or _effAvailable#1 < MIN_COMP#1) exitWith { [0,0] };
		_effAvailable
	} ENDMETHOD;
ENDCLASS;

#ifdef _SQF_VM

#define CMDR_ACTION_STATE_SPLIT				(CMDR_ACTION_STATE_CUSTOM+1)
#define CMDR_ACTION_STATE_READY_TO_MOVE		(CMDR_ACTION_STATE_CUSTOM+2)
#define CMDR_ACTION_STATE_MOVED				(CMDR_ACTION_STATE_CUSTOM+3)
#define CMDR_ACTION_STATE_TARGET_DEAD		(CMDR_ACTION_STATE_CUSTOM+4)
#define CMDR_ACTION_STATE_ARRIVED 			(CMDR_ACTION_STATE_CUSTOM+5)

#define SRC_POS [0, 0, 0]
#define TARGET_POS [1, 2, 3]

["TakeLocationCmdrAction", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _srcEff = [100,100,100,100,100,100,100,100];
	SETV(_garrison, "efficiency", _srcEff);
	SETV(_garrison, "pos", SRC_POS);
	SETV(_garrison, "side", WEST);

	private _targetLocation = NEW("LocationModel", [_world]);
	SETV(_targetLocation, "pos", TARGET_POS);

	private _thisObject = NEW("TakeLocationCmdrAction", [GETV(_garrison, "id"), GETV(_targetLocation, "id")]);
	
	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	CALLM(_thisObject, "updateScore", [_world, _future]);

	private _nowSimState = CALLM(_thisObject, "applyToSim", [_world]);
	private _futureSimState = CALLM(_thisObject, "applyToSim", [_future]);
	["Now sim state correct", _nowSimState == CMDR_ACTION_STATE_READY_TO_MOVE] call test_Assert;
	["Future sim state correct", _futureSimState == CMDR_ACTION_STATE_END] call test_Assert;
	
	private _futureLocation = CALLM(_future, "getLocation", [GETV(_targetLocation, "id")]);
	private _futureGarrison = CALLM(_futureLocation, "getGarrison", [WEST]);
	["Location is occupied in future", !IS_NULL_OBJECT(_futureGarrison)] call test_Assert;
	// ["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

#endif