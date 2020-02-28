#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.Actions.SupplyCmdrAction

CmdrAI garrison supply action. 
Takes a source and target garrison id.
Sends a detachment from the source garrison to join the target garrison.
Both garrisons must be at a location.

Parent: <TakeOrJoinCmdrAction>
*/

//#define private private

// These are defined in CmdrActionStates.hpp
// #define ACTION_SUPPLY_TYPE_BUILDING 0
// #define ACTION_SUPPLY_TYPE_AMMO 1
// #define ACTION_SUPPLY_TYPE_EXPLOSIVES 2
// #define ACTION_SUPPLY_TYPE_MEDICAL 3
// #define ACTION_SUPPLY_TYPE_MISC 4

CLASS("SupplyCmdrAction", "TakeOrJoinCmdrAction")
	VARIABLE_ATTR("tgtGarrId", [ATTR_SAVE]);
	// Type ACTION_SUPPLY_*
	VARIABLE_ATTR("type", [ATTR_SAVE]);
	// Amount - abstract value representing "how much" of the stuff to supply from 0-1.
	VARIABLE_ATTR("amount", [ATTR_SAVE]);
	// Array of UI names for the types of supplies
	STATIC_VARIABLE("SupplyNames");

	/*
	Constructor: new

	Create a CmdrAI action to send a detachment with supplies, from the source garrison to join
	the target garrison.
	
	Parameters:
		_srcGarrId - Number, <Model.GarrisonModel> id from which to send the patrol detachment.
		_tgtGarrId - Number, <Model.GarrisonModel> id to reinforce with the detachment.
		_type - Number, type of supplies we are sending (from the ACTION_SUPPLY_* macros)
		_amount - Number, 0-1, how much, non-specific units
	*/
	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId"), P_NUMBER("_type"), P_NUMBER("_amount")];
		T_SETV("tgtGarrId", _tgtGarrId);
		T_SETV("type", _type);
		T_SETV("amount", _amount);

		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		T_SET_AST_VAR("targetVar", [TARGET_TYPE_GARRISON ARG _tgtGarrId]);
	} ENDMETHOD;
	
	/* protected override */ METHOD("getPrepareActions") {
		params [P_THISOBJECT,
				P_ARRAY("_fromStates"),
				P_AST_STATE("_successState"),
				P_AST_STATE("_failedState"),
				P_AST_VAR("_srcGarrIdVar"),
				P_AST_VAR("_detachedGarrIdVar"),
				P_AST_VAR("_targetVar")
		];
		private _astArgs = [
			_thisObject,
			_fromStates,
			_successState,
			_detachedGarrIdVar,
			T_CALLM0("calculateCargo")
		];
		NEW("AST_AssignCargo", _astArgs)
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
			_intel = NEW("IntelCommanderActionSupply", []);

			T_PRVAR(srcGarrId);
			T_PRVAR(tgtGarrId);
			private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			ASSERT_OBJECT(_srcGarr);
			private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
			ASSERT_OBJECT(_tgtGarr);

			CALLM(_intel, "create", []);

			private _typeName = GETSV("SupplyCmdrAction", "SupplyNames") select T_GETV("type");
			SETV(_intel, "type", _typeName);
			private _amount = T_GETV("amount");
			SETV(_intel, "amount", _amount);

			SETV(_intel, "side", GETV(_srcGarr, "side"));
			SETV(_intel, "srcGarrison", GETV(_srcGarr, "actual"));
			SETV(_intel, "posSrc", GETV(_srcGarr, "pos"));
			SETV(_intel, "tgtGarrison", GETV(_tgtGarr, "actual"));
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

		private _allocationFlags = [
			SPLIT_VALIDATE_ATTACK,		// Validate our escort strength	
			SPLIT_VALIDATE_CREW,		// Ensure we can drive our vehicles
			SPLIT_VALIDATE_CREW_EXT,	// Ensure we provide enough crew to destination
			SPLIT_VALIDATE_TRANSPORT	// Definitely need transport as we are moving supplies
		];

		// Try to allocate units
		private _payloadWhitelistMask = T_comp_ground_or_infantry_mask;
		// Don't take static weapons or cargo under any conditions
		// (we will manually assign cargo to our trucks, don't need T_CARGO stuff)
		private _payloadBlacklistMask = T_comp_static_or_cargo_mask;
		// Take ground units, take any infantry to satisfy crew requirements
		private _transportWhitelistMask = T_comp_ground_or_infantry_mask;
		private _transportBlacklistMask = [];
		// Obviously we need a cargo truck!
		private _requiredComp =  [
			[T_VEH, T_VEH_truck_ammo, 1]
		];

		private _amount = T_GETV("amount");

		// Determine an appropriate escort for our cargo
		private _requiredEff = +T_eff_null;

		// Add some armor if we need it
		_requiredEff set [T_EFF_soft, floor (12 + 24 * _amount)];
		_requiredEff set [T_EFF_medium, floor (3 * _amount)];
		_requiredEff set [T_EFF_armor, floor (3 * _amount)];

		// [6, 0, 0, 0, 6, 0, 0, 0, 0, 6, 0, 0, 0, 6]
		private _args = [_requiredEff, _allocationFlags, _srcGarrComp, _srcGarrEff,
					_payloadWhitelistMask, _payloadBlacklistMask,
					_transportWhitelistMask, _transportBlacklistMask,
					_requiredComp];
		private _allocResult = CALLSM("GarrisonModel", "allocateUnits", _args);

		// Bail if we have failed to allocate resources
		if ((count _allocResult) == 0) exitWith {
			OOP_DEBUG_MSG("Failed to allocate resources", []);
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		_allocResult params ["_compAllocated", "_effAllocated", "_compRemaining", "_effRemaining"];

		ASSERT(_compAllocated#T_VEH#T_VEH_truck_ammo >= 1);

		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _srcDesiredEff = CALLM1(_worldNow, "getDesiredEff", _srcGarrPos);

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
		private _tgtGarrPos = GETV(_tgtGarr, "pos");
		private _distCoeff = CALLSM("CmdrAction", "calcDistanceFalloff", [_srcGarrPos ARG _tgtGarrPos]);
		private _detachEffStrength = CALLSM1("CmdrAction", "getDetachmentStrength", _effAllocated); // A number!

		// Our final resource score combining available efficiency, distance and transportation.
		private _scoreResource = _detachEffStrength * _distCoeff;

		private _dist = _srcGarrPos distance _tgtGarrPos;

		// CALCULATE START DATE
		// Work out time to start based on amount of supplies we mustering and distance we are travelling.
		// linear * https://www.desmos.com/calculator/0vb92pzcz8 * 0.1
		
		private _delay = 50 * (_amount + 0.5) * (1 + 2 * log (0.0003 * _dist + 1)) * 0.1 + (30 + random 15);

		// Shouldn't need to cap it, the functions above should always return something reasonable, if they don't then fix them!
		// _delay = 0 max (120 min _delay);
		private _startDate = DATE_NOW;

		_startDate set [4, _startDate#4 + _delay];

		T_SET_AST_VAR("startDateVar", _startDate);

		private _type = T_GETV("type");
		private _typeName = GETSV("SupplyCmdrAction", "SupplyNames") select _type;
		OOP_DEBUG_MSG("[w %1 a %2] %3 supply %4 with %5 %6, Score %7 _detachEff = %8 _detachEffStrength = %9 _distCoeff = %10", 
			[_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtGarr) ARG _typeName ARG _amount ARG [1 ARG _scoreResource] ARG _effAllocated ARG _detachEffStrength ARG _distCoeff]);

		// APPLY STRATEGY
		// Get our Cmdr strategy implementation and apply it
		private _strategy = CALL_STATIC_METHOD("AICommander", "getCmdrStrategy", [_side]);
		private _baseScore = MAKE_SCORE_VEC(1, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getSupplyScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _tgtGarr ARG _effAllocated ARG _type ARG _amount]);
		T_CALLM("setScore", [_score]);
		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Reinforce"", ""src_garrison"": ""%2"", ""tgt_garrison"": ""%3"", ""score_priority"": %4, ""score_resource"": %5, ""score_strategy"": %6, ""score_completeness"": %7}}", 
			_side, LABEL(_srcGarr), LABEL(_tgtGarr), _score#0, _score#1, _score#2, _score#3];
		OOP_INFO_MSG(_str, []);
		#endif
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
		private _record = NEW("SupplyCmdrActionRecord", []);

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

	STATIC_METHOD("randomAmount") {
		params [P_THISCLASS, P_NUMBER("_base"), P_NUMBER("_variation")];
		#ifdef _SQF_VM
		1
		#else
		floor (_base + _variation * random [0, 0.5, 1])
		#endif
	} ENDMETHOD;
	

	METHOD("calculateCargo") {
		params [P_THISOBJECT];
		private _type = T_GETV("type");
		private _amount = T_GETV("amount");

		// Cargo/inventory array format:
		// 	[
		//		[[weapon, count],...],
		//		[[item, count],...],
		//		[[mag, count],...],
		//		[[backpack, count],...]
		// 	]
		switch (_type) do {
			case ACTION_SUPPLY_TYPE_BUILDING: {
				[
					[],
					[["vin_build_res_0", CALLSM2("SupplyCmdrAction", "randomAmount", 25, 50 * _amount)]],
					[],
					[]
				]
			};
			case ACTION_SUPPLY_TYPE_AMMO: {
				T_PRVAR(srcGarrId);
				T_PRVAR(tgtGarrId);
				private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
				private _side = GETV(_srcGarr, "side");
				private _templateName = CALLM2(gGameMode, "getTemplateName", _side, "");
				private _t = [_templateName] call t_fnc_getTemplate;
				private _tInv = _t#T_INV;

				// Add weapons and magazines
				private _arr = [[T_INV_handgun, ceil (1 + random 2), CALLSM2("SupplyCmdrAction", "randomAmount", 2, 5 * _amount)]];
				_arr = _arr + (if(random 10 < 7) then {
					[[T_INV_primary, ceil (1 + random 2), CALLSM2("SupplyCmdrAction", "randomAmount", 5, 20 * _amount)]]
				} else {
					[[T_INV_secondary, ceil (1 + random 2), CALLSM2("SupplyCmdrAction", "randomAmount", 5, 10 * _amount)]]
				});

				private _weapons = [];
				private _mags = [];

				{ // forEach _arr;
					_x params ["_subcatID", "_nTypes", "_nOfEach"];
					if (count (_tInv#_subcatID) > 0) then { // If there are any weapons in this subcategory
						private _weaponsAndMags = (+_tInv#_subcatID) call BIS_fnc_arrayShuffle;
						private _maxType = _nTypes min count _weaponsAndMags;
						for "_i" from 0 to (_maxType-1) do {
							private _weaponAndMag = _weaponsAndMags#_i;
							_weaponAndMag params ["_weaponClassName", "_magazines"];
							_weapons = _weapons + [[_weaponClassName, ceil (_nOfEach * random[0.5, 1, 1.5])]];
							if(count _magazines > 0) then {
								private _nMags = ceil (_nOfEach * 10 * random[0.5, 1, 1.5]);
								_mags = _magazines apply { [_x, 0] } ;
								while {_nMags > 0} do {
									private _mag = selectRandom _mags;
									_mag set [1, _mag#1 + 1];
									_nMags = _nMags - 1;
								};
								_mags = _mags select { _x#1 > 0 };
							};
						};
					};
				} forEach _arr;

				[
					_weapons,
					[],
					_mags,
					[]
				]
			};
			case ACTION_SUPPLY_TYPE_EXPLOSIVES: {
				[
					[],
					[
						["IEDLandSmall_Remote_Mag", 	CALLSM2("SupplyCmdrAction", "randomAmount", 4, 10 * _amount)],
						["IEDUrbanSmall_Remote_Mag", 	CALLSM2("SupplyCmdrAction", "randomAmount", 4, 10 * _amount)],
						["IEDLandBig_Remote_Mag", 		CALLSM2("SupplyCmdrAction", "randomAmount", 0, 10 * _amount)],
						["IEDUrbanBig_Remote_Mag", 		CALLSM2("SupplyCmdrAction", "randomAmount", 0, 10 * _amount)],
						["DemoCharge_Remote_Mag", 		CALLSM2("SupplyCmdrAction", "randomAmount", 0, 5 * _amount)],
						["SatchelCharge_Remote_Mag", 	CALLSM2("SupplyCmdrAction", "randomAmount", 0, 5 * _amount)],
						["TrainingMine_Mag", 			CALLSM2("SupplyCmdrAction", "randomAmount", 5, 20 * _amount)],
						["ACE_DeadManSwitch", 			CALLSM2("SupplyCmdrAction", "randomAmount", 5, 10 * _amount)],
						["ACE_DefusalKit", 				CALLSM2("SupplyCmdrAction", "randomAmount", 5, 10 * _amount)],
						["ACE_M26_Clacker", 			CALLSM2("SupplyCmdrAction", "randomAmount", 5, 10 * _amount)],
						["ACE_Clacker", 				CALLSM2("SupplyCmdrAction", "randomAmount", 5, 10 * _amount)],
						["MineDetector", 				CALLSM2("SupplyCmdrAction", "randomAmount", 5, 10 * _amount)]
					],
					[],
					[]
				]
			};
			case ACTION_SUPPLY_TYPE_MEDICAL: {
				[
					[],
					[
						["ACE_adenosine", 				CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)],
						["ACE_fieldDressing", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 20 * _amount)],
						["ACE_elasticBandage", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 20 * _amount)],
						["ACE_packingBandage", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 20 * _amount)],
						["ACE_quikclot", 				CALLSM2("SupplyCmdrAction", "randomAmount", 10, 20 * _amount)],
						["ACE_bloodIV", 				CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_bloodIV_250", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_bloodIV_500", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_bodyBag", 				CALLSM2("SupplyCmdrAction", "randomAmount",  5,  5 * _amount)],
						["ACE_epinephrine", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)],
						["ACE_morphine", 				CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)],
						["ACE_personalAidKit", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)],
						["ACE_plasmaIV", 				CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_plasmaIV_250", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_plasmaIV_500", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_salineIV", 				CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_salineIV_250", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_salineIV_500", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_surgicalKit", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_tourniquet", 				CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)]
					],
					[],
					[]
				]
			};
			case ACTION_SUPPLY_TYPE_MISC: {
				[
					[],
					[
						["ACE_adenosine", 				CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)],
						["ACE_fieldDressing", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 20 * _amount)],
						["ACE_elasticBandage", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 20 * _amount)],
						["ACE_packingBandage", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 20 * _amount)],
						["ACE_quikclot", 				CALLSM2("SupplyCmdrAction", "randomAmount", 10, 20 * _amount)],
						["ACE_bloodIV", 				CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_bloodIV_250", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_bloodIV_500", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_bodyBag", 				CALLSM2("SupplyCmdrAction", "randomAmount",  5,  5 * _amount)],
						["ACE_epinephrine", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)],
						["ACE_morphine", 				CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)],
						["ACE_personalAidKit", 			CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)],
						["ACE_plasmaIV", 				CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_plasmaIV_250", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_plasmaIV_500", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_salineIV", 				CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_salineIV_250", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_salineIV_500", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_surgicalKit", 			CALLSM2("SupplyCmdrAction", "randomAmount",  5, 10 * _amount)],
						["ACE_tourniquet", 				CALLSM2("SupplyCmdrAction", "randomAmount", 10, 10 * _amount)]
					],
					[],
					[]
				]
			};
		}
	} ENDMETHOD;
	

ENDCLASS;

REGISTER_DEBUG_MARKER_STYLE("SupplyCmdrAction", "ColorPink", "mil_pickup");

if(isNil { GETSV("SupplyCmdrAction", "SupplyNames")}) then {
	private _actionSupplyNames = [
		"Building Supplies",
		"Ammunition",
		"Explosives",
		"Medical",
		"Miscellaneous"
	];
	SETSV("SupplyCmdrAction", "SupplyNames", _actionSupplyNames);
};

#ifdef _SQF_VM

#define SRC_POS [1, 2, 0]
#define TARGET_POS [1000, 2, 3]

["SupplyCmdrAction", {
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

	private _thisObject = NEW("SupplyCmdrAction", [GETV(_garrison, "id") ARG GETV(_targetGarrison, "id") ARG ACTION_SUPPLY_TYPE_BUILDING ARG 0.2]);
	
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