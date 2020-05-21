#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.Actions.ConstructLocationCmdrAction

Action for commander to construct a location with some garrison.

Parent: <CmdrAction>
*/

#define pr private

#define OOP_CLASS_NAME ConstructLocationCmdrAction
CLASS("ConstructLocationCmdrAction", "CmdrAction")

	VARIABLE_ATTR("srcGarrID", [ATTR_SAVE]);
	VARIABLE_ATTR("locPos", [ATTR_SAVE]);
	VARIABLE_ATTR("locType", [ATTR_SAVE]);
	VARIABLE_ATTR("detachmentEffVar", [ATTR_SAVE]);	// Efficiency
	VARIABLE_ATTR("detachmentCompVar", [ATTR_SAVE]);	// Composition
	VARIABLE_ATTR("detachedGarrIdVar", [ATTR_SAVE]);
	VARIABLE_ATTR("startDateVar", [ATTR_SAVE]);
	VARIABLE_ATTR("buildRes", [ATTR_SAVE]);

	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_srcGarrID"), P_POSITION("_locPos"), P_DYNAMIC("_locType")];

		// Desired detachment efficiency changes when updateScore is called. This shouldn't happen once the action
		// has been started, but this constructor is called before that point.
		private _detachmentEffVar = T_CALLM1("createVariable", +EFF_ZERO);
		T_SETV("detachmentEffVar", _detachmentEffVar);
		private _detachmentCompVar = T_CALLM1("createVariable", +T_comp_null);
		T_SETV("detachmentCompVar", _detachmentCompVar);

		T_SETV("srcGarrID", _srcGarrID);
		T_SETV("locType", _locType);
		T_SETV("locPos", _locPos);
		T_SETV("buildRes", 60);	// temp
		
		private _startDateVar = T_CALLM1("createVariable", DATE_NOW); // Default to immediate, overriden at updateScore
		T_SETV("startDateVar", _startDateVar);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
	
		// Clear our debug markers
		#ifdef DEBUG_CMDRAI
		deleteMarker (_thisObject + "_line");
		deleteMarker (_thisObject + "_label");
		#endif
	ENDMETHOD;

	METHOD(createTransitions)
		params [P_THISOBJECT];

		private _srcGarrId = T_GETV("srcGarrId");
		pr _srcGarrIdVar = T_CALLM1("createVariable", _srcGarrId);

		private _detachmentCompVar = T_GETV("detachmentCompVar");
		private _detachmentEffVar = T_GETV("detachmentEffVar");
		private _startDateVar = T_GETV("startDateVar");
		
		pr _splitGarrIdVar = T_CALLM("createVariable", [MODEL_HANDLE_INVALID]);
		T_SETV("detachedGarrIdVar", _splitGarrIdVar);

		private _splitAST_Args = [
				_thisObject,						// This action (for debugging context)
				[CMDR_ACTION_STATE_START], 			// First action we do
				CMDR_ACTION_STATE_SPLIT, 			// State change if successful
				CMDR_ACTION_STATE_END, 				// State change if failed (go straight to end of action)
				_srcGarrIdVar, 						// Garrison to split (constant)
				_detachmentCompVar,					// COmposition of detachment
				_detachmentEffVar, 					// Efficiency we want the detachment to have (constant)
				_splitGarrIdVar]; 					// variable to recieve Id of the garrison after it is split
		private _splitAST = NEW("AST_SplitGarrison", _splitAST_Args);

		private _assignAST_Args = [
				_thisObject, 						// This action, gets assigned to the garrison
				[CMDR_ACTION_STATE_SPLIT], 			// Do this after splitting
				CMDR_ACTION_STATE_ASSIGNED, 		// State change when successful (can't fail)
				_splitGarrIdVar]; 					// Id of garrison to assign the action to
		private _assignAST = NEW("AST_AssignActionToGarrison", _assignAST_Args);

		private _waitAST_Args = [
				_thisObject,						// This action (for debugging context)
				[CMDR_ACTION_STATE_ASSIGNED], 		// Start wait after we assigned the action to the detachment
				CMDR_ACTION_STATE_READY_TO_MOVE, 	// State change if successful2
				CMDR_ACTION_STATE_END, 				// State change if failed (go straight to end of action)
				_startDateVar,						// Date to wait until
				_splitGarrIdVar];					// Garrison to wait (checks it is still alive)
		private _waitAST = NEW("AST_WaitGarrison", _waitAST_Args);

		// 

		private _target = [TARGET_TYPE_POSITION, T_GETV("locPos")];
		private _targetVar = T_CALLM1("createVariable", _target);
		private _moveAST_Args = [
				_thisObject, 						// This action (for debugging context)
				[CMDR_ACTION_STATE_READY_TO_MOVE], 		
				CMDR_ACTION_STATE_MOVED, 			// State change when successful
				CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
				CMDR_ACTION_STATE_END, 				// State change when target is dead
				_splitGarrIdVar, 					// Id of garrison to move
				_targetVar, 						// Target to move to (pos where we will create a location)
				T_CALLM1("createVariable", 200)]; 	// Radius to move within
		private _moveAST = NEW("AST_MoveGarrison", _moveAST_Args);

		private _constructAST_Args = [
				_thisObject,						// This action
				[CMDR_ACTION_STATE_MOVED],			// From states
				CMDR_ACTION_STATE_END,				// Success state
				CMDR_ACTION_STATE_END,				// Fail state
				_splitGarrIdVar,						// Garrison which will *build* the location
				T_GETV("locPos"),					// Location position
				T_GETV("locType"),					// Location type
				T_GETV("buildRes")					// Amount of build resources to consume
		];
		private _constructAST = NEW("AST_GarrisonConstructLocation", _constructAST_Args);

		[_splitAST, _assignAST, _waitAST, _moveAST, _constructAST]
	ENDMETHOD;


	// Copied from TakeLocationCmdrAction
	/* override */ METHOD(updateScore)
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		private _srcGarrId = T_GETV("srcGarrId");

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _srcGarrEff = GETV(_srcGarr, "efficiency");
		private _srcGarrComp = GETV(_srcGarr, "composition");

		//diag_log format [" src garr eff: %1", _srcGarrEff];
		//diag_log format ["  src garr comp: %1", _srcGarrComp];

		ASSERT_OBJECT(_srcGarr);

		// Bail if garrison is dead
		if(CALLM0(_srcGarr, "isDead")) exitWith {
			OOP_DEBUG_0("Src garrison is dead");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		private _tgtLocPos = T_GETV("locPos");
		private _tgtLocType = T_GETV("locType");
		private _enemyEff = +CALLM(_worldNow, "getDesiredEff", [_tgtLocPos]);
		OOP_INFO_1(" Enemy efficiency from grid : %1", _enemyEff);
		private _side = GETV(_srcGarr, "side");

		// Bail if the garrison clearly can not destroy the enemy
		if ( count ([_srcGarrEff, _enemyEff] call eff_fnc_validateAttack) > 0) exitWith {
			OOP_DEBUG_0("Attack requirement not satisfied");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		// Bail if in the future there will be a location already
		private _locs = CALLM4(_worldFuture, "getNearestLocations", _tgtLocPos, 200, [], []);
		if (count _locs > 0) exitWith {
			OOP_DEBUG_0("There is already a location at this place in the future");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		// Set up flags for allocation algorithm
		private _allocationFlags = [SPLIT_VALIDATE_ATTACK, SPLIT_VALIDATE_CREW_EXT, SPLIT_VALIDATE_CREW, SPLIT_VALIDATE_CREW_EXT, SPLIT_VALIDATE_TRANSPORT];
		private _payloadWhitelistMask = T_comp_ground_or_infantry_mask;	// Take only inf or ground vehicles as an attacking force
		// todo add other transport types?
		#ifndef _SQF_VM
		pr _dist = _tgtLocPos distance2D _srcGarrPos;
		#else
		pr _dist = _tgtLocPos distance _srcGarrPos;
		#endif

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
			OOP_DEBUG_0("  Failed to allocate resources");
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
		private _distCoeff = 1; //CALLSM1("CmdrAction", "calcDistanceFalloff", _srcGarrPos distance _tgtLocPos); // We don't care how far is it really, it's close enough anyway
		// How much to scale the score for transport requirements
		private _detachEffStrength = CALLSM1("CmdrAction", "getDetachmentStrength", _effAllocated);				// A number

		private _strategy = CALL_STATIC_METHOD("AICommander", "getCmdrStrategy", [_side]);
		
		private _scoreResource = _detachEffStrength * _distCoeff;

		// Same as in takeLocation, but we generally want to build less than to occupy existing pre-defined places
		private _scorePriority = CALLM(_strategy, "getConstructLocationDesirability", [_worldNow ARG _tgtLocPos ARG _tgtLocType ARG _side]);

		OOP_DEBUG_1("ScorePriority: %1", _scorePriority);

		// CALCULATE START DATE
		// Work out time to start based on how much force we mustering and distance we are travelling.
		// https://www.desmos.com/calculator/mawpkr88r3 * https://www.desmos.com/calculator/0vb92pzcz8
#ifndef RELEASE_BUILD
		private _delay = random 2;
#else
		private _delay = 50 * log (0.1 * _detachEffStrength + 1) * (1 + 2 * log (0.0003 * _dist + 1)) * 0.1 + 2 + (random 15 + 30);
#endif

		// Shouldn't need to cap it, the functions above should always return something reasonable, if they don't then fix them!
		// _delay = 0 max (120 min _delay);
		private _startDate = DATE_NOW;

		_startDate set [4, _startDate#4 + _delay];

		T_SET_AST_VAR("startDateVar", _startDate);

		// Uncomment for some more debug logging
		 OOP_DEBUG_MSG("[w %1 a %2] %3 construct %4 Score %5, _detachEff = %6, _detachEffStrength = %7, _distCoeff = %8",
		 	[_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG [_tgtLocType ARG _tgtLocPos] ARG [_scorePriority ARG _scoreResource] 
		 	ARG _effAllocated ARG _detachEffStrength ARG _distCoeff]);

		// APPLY STRATEGY
		// Get our Cmdr strategy implementation and apply it
		private _baseScore = MAKE_SCORE_VEC(_scorePriority, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getConstructLocationScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _tgtLocPos ARG _effAllocated]);
		OOP_DEBUG_1("  Strategy construct location score: %1", _score);
		T_CALLM("setScore", [_score]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""TakeOutpost"", ""src_garrison"": ""%2"", ""location_pos"": ""%3"", ""score_priority"": %4, ""score_resource"": %5, ""score_strategy"": %6, ""score_completeness"": %7}}", 
			_side, LABEL(_srcGarr), _tgtLocPos, _score#0, _score#1, _score#2, _score#3];
		OOP_INFO_MSG(_str, []);
		#endif
	ENDMETHOD;

	/* protected override */ METHOD(updateIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		ASSERT_MSG(CALLM0(_world, "isReal"), "Can only updateIntel from real world, this shouldn't be possible as updateIntel should ONLY be called by CmdrAction");

		private _intelClone = T_GETV("intelClone");
		private _intelNotCreated = IS_NULL_OBJECT(_intelClone);
		if(_intelNotCreated) then
		{
			// Create new intel object and fill in the constant values
			private _intel = NEW("IntelCommanderActionConstructLocation", []);

			private _srcGarrId = T_GETV("srcGarrId");
			private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			ASSERT_OBJECT(_srcGarr);

			CALLM0(_intel, "create");

			SETV(_intel, "type", T_GETV("locType"));
			SETV(_intel, "side", GETV(_srcGarr, "side"));
			SETV(_intel, "srcGarrison", GETV(_srcGarr, "actual"));
			SETV(_intel, "posSrc", GETV(_srcGarr, "pos"));
			SETV(_intel, "posTgt", T_GETV("locPos"));
			SETV(_intel, "dateDeparture", T_GET_AST_VAR("startDateVar")); // Sparker added this, I think it's allright??

			T_CALLM("updateIntelFromDetachment", [_world ARG _intel]);

			// If we just created this intel then register it now 
			private _intelClone = CALL_STATIC_METHOD("AICommander", "registerIntelCommanderAction", [_intel]);
			T_SETV("intelClone", _intelClone);

			// Send the intel to some places that should "know" about it
			T_CALLM("addIntelAt", [_world ARG GETV(_srcGarr, "pos")]);
			T_CALLM("addIntelAt", [_world ARG T_GETV("locPos")]);
		} else {
			T_CALLM("updateIntelFromDetachment", [_world ARG _intelClone]);
			CALLM0(_intelClone, "updateInDb");
		};
	ENDMETHOD;

	METHOD(updateIntelFromDetachment)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_OOP_OBJECT("_intel")];

		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		//ASSERT_OBJECT_CLASS(_intel, "IntelCommanderActionAttack");
		
		// Update progress of the detachment
		private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			SETV(_intel, "garrison", GETV(_detachedGarr, "actual"));
			SETV(_intel, "pos", GETV(_detachedGarr, "pos"));
			SETV(_intel, "posCurrent", GETV(_detachedGarr, "pos"));
			SETV(_intel, "strength", GETV(_detachedGarr, "efficiency"));

			// Set state
			if (T_GETV("state") == CMDR_ACTION_STATE_READY_TO_MOVE) then {
				T_CALLM1("setIntelState", INTEL_ACTION_STATE_ACTIVE);
			};

			// Send intel to the garrison doing this action
			T_CALLM1("setPersonalGarrisonIntel", _detachedGarr);
		};
	ENDMETHOD;


	// Debug drawing

	/* protected override */ METHOD(debugDraw)
		params [P_THISOBJECT, P_STRING("_world")];

		private _srcGarrId = T_GETV("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _srcGarrPos = GETV(_srcGarr, "pos");

		private _locPos = T_GETV("locPos");
		private _locType = T_GETV("locType");

		GET_DEBUG_MARKER_STYLE(_thisObject) params ["_debugColor", "_debugSymbol"];

		[_srcGarrPos, _locPos, _debugColor, 8, _thisObject + "_line"] call misc_fnc_mapDrawLine;

		private _centerPos = _srcGarrPos vectorAdd ((_locPos vectorDiff _srcGarrPos) apply { _x * 0.25 });
		private _mrk = _thisObject + "_label";
		createmarker [_mrk, _centerPos];
		_mrk setMarkerType _debugSymbol;
		_mrk setMarkerColor _debugColor;
		_mrk setMarkerPos _centerPos;
		_mrk setMarkerAlpha 1;
		_mrk setMarkerText T_CALLM("getLabel", [_world]);
	ENDMETHOD;

	/* protected override */ METHOD(getLabel)
		params [P_THISOBJECT, P_STRING("_world")];

		private _srcGarrId = T_GETV("srcGarrId");
		private _state = T_GETV("state");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _srcEff = GETV(_srcGarr, "efficiency");

		private _startDate = T_GET_AST_VAR("startDateVar");
		private _timeToStart = if(_startDate isEqualTo []) then {
			" (unknown)"
		} else {
			private _numDiff = (dateToNumber _startDate - dateToNumber DATE_NOW);
			if(_numDiff > 0) then {
				private _dateDiff = numberToDate [0, _numDiff];
				private _mins = _dateDiff#4 + _dateDiff#3*60;

				format [" (start in %1 mins)", _mins]
			} else {
				" (started)"
			};
		};

		private _targetName = "New Roadblock";
		private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		if(_detachedGarrId == MODEL_HANDLE_INVALID) then {
			format ["%1 %2%3 -> %4%5", _thisObject, LABEL(_srcGarr), _srcEff, _targetName, _timeToStart]
		} else {
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			private _detachedEff = GETV(_detachedGarr, "efficiency");
			format ["%1 %2%3 -> %4%5 -> %6%7", _thisObject, LABEL(_srcGarr), _srcEff, LABEL(_detachedGarr), _detachedEff, _targetName, _timeToStart]
		};
	ENDMETHOD;

ENDCLASS;

REGISTER_DEBUG_MARKER_STYLE("ConstructLocationCmdrAction", "ColorBrown", "loc_Ruin");

#ifdef _SQF_VM

#define SRC_POS [0, 0, 0]
#define TARGET_POS [6000, 6000, 0]

["ConstructLocationCmdrAction", {
	private _realworld = NEW("WorldModel", [WORLD_TYPE_REAL]);

	// Init the activity grid
	// We need it above zero to generate an action
	private _grid = GETV(_realWorld, "activityGrid");
	CALLM1(_grid, "setValueAll", 100);
	private _grid = GETV(_realWorld, "rawActivityGrid");
	CALLM1(_grid, "setValueAll", 100);

	/*
	private _value = CALLM1(_grid, "getValue", TARGET_POS);
	diag_log format ["Grid value at %1 : %2", TARGET_POS, _value];
	private _activity = CALLM1(_realWorld, "getActivity", TARGET_POS);
	*/

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

	pr _args = [GETV(_garrison, "id"), TARGET_POS, LOCATION_TYPE_ROADBLOCK];
	private _thisObject = NEW("ConstructLocationCmdrAction", _args);

	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	T_CALLM("updateScore", [_world ARG _future]);

	private _finalScore = T_CALLM("getFinalScore", []);
	//diag_log format ["Construct location final score: %1", _finalScore];
	["Score is above zero", _finalScore > 0] call test_Assert;

	// Apply to sim
	private _nowSimState = T_CALLM("applyToSim", [_world]);
	private _futureSimState = T_CALLM("applyToSim", [_future]);

}] call test_AddTest;

#endif