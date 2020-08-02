#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#include "Actions\common.hpp"
#include "..\common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.CmdrAction
The base class for all commander actions. An Action is defined as any behaviour the commander can
choose whether to perform. 
In general the actions are parameterized and scored based on relevance and the commanders current strategy.
The scoring can be a complex as required, but in the end is reduced down to a single number that can be 
used in comparison between actions of the same type, and other types of the same priority level (see CmdrAI
for how this works).
The behaviour of the action is defined by a state machine, defined by a set of ActionStateTransitions and a 
set of associated variables (kind of like a blackboard system).
Usually one or more pieces of intel will be associated with a CmdrAction to allow them to be discoverable
by other commanders.

e.g. An action for a garrison to attack an outpost could be parameterized by the specific garrison and
     outpost, and scored based on how much the commander wants to control that outpost, how close the garrison is
     to it, and how well the garrison is predicted to do when fighting the enemy at the outpost.

Parent: <RefCounted>
*/
#define OOP_CLASS_NAME CmdrAction
CLASS("CmdrAction", ["RefCounted" ARG "Storable"])

	// The priority of this action in relation to other actions of the same or different type.
	VARIABLE_ATTR("scorePriority", [ATTR_PRIVATE ARG ATTR_SAVE]);
	// The resourcing available for this action.
	VARIABLE_ATTR("scoreResource", [ATTR_PRIVATE ARG ATTR_SAVE]);
	// How strongly this action correlates with the current strategy.
	VARIABLE_ATTR("scoreStrategy", [ATTR_PRIVATE ARG ATTR_SAVE]);
	// How close to being complete this action is (>1)
	VARIABLE_ATTR("scoreCompleteness", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// State transition functions
	VARIABLE_ATTR("transitions", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// Registered AST_VARs. AST_VARs should be registered when they can be modified by any of the 
	// ASTs, so that they can be saved and restored during simulation (don't want simulation 
	// to effect real world actions).
	VARIABLE_ATTR("variables", [ATTR_SAVE]);

	// AST_VARs saved during simulation, to be restored afterwards.
	VARIABLE_ATTR("variablesStack", [ATTR_PRIVATE ARG ATTR_SAVE]);
	// Garrisons associated with this action, so we can automatically unassign this action from them 
	// when it is finished.
	VARIABLE_ATTR("garrisons", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// Current AST state of this action
	VARIABLE_ATTR("state", [ATTR_GET_ONLY ARG ATTR_SAVE]);

	// Intel object associated with this action
	// It's an intel clone! The actual intel is in the database
	VARIABLE_ATTR("intelClone", [ATTR_GET_ONLY ARG ATTR_SAVE]);

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("scorePriority", 1);
		T_SETV("scoreResource", 1);
		T_SETV("scoreStrategy", 1);
		T_SETV("scoreCompleteness", 1);
		T_SETV("state", CMDR_ACTION_STATE_START);
		T_SETV("transitions", []);
		T_SETV("variables", []);
		T_SETV("variablesStack", []);
		T_SETV("garrisons", []);
		T_SETV("intelClone", NULL_OBJECT);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		private _garrisons = T_GETV("garrisons");

		// Clean up this action from the garrisons it is assigned to
		{
			if(CALLM0(_x, "getAction") == _thisObject) then {
				CALLM0(_x, "clearAction");
			} else {
				OOP_WARNING_MSG("Garrison %1 was registered with action %2 but no longer has the action assigned", [_x ARG _thisObject]);
			};
		} foreach +_garrisons;

		private _intelClone = T_GETV("intelClone"); // We have a clone of intel
		if(!IS_NULL_OBJECT(_intelClone)) then {

			// Mark the action state as END
			SETV(_intelClone, "state", INTEL_ACTION_STATE_END);
			CALLM0(_intelClone, "updateInDb"); // Broadcast it to friendlies, also update _intel from _intelClone

			// If db is valid then we can directly remove our matching intel entry from it.
			private _db = GETV(_intelClone, "db");
			if(!isNil "_db") then {
				private _dbEntry = GETV(_intelClone, "dbEntry");
				ASSERT_MSG(_dbEntry != _intelClone, "Circular reference in Intel!");

				OOP_INFO_MSG("cleaning up intel object from db", []);
				// CALLM(_db, "removeIntelForClone", [_intelClone]);
				CALLSM2("AICommander", "unregisterIntelCommanderAction", _dbEntry, _intelClone);
				// DELETE(_dbEntry); // We DO NOT DELETE the intel in the database so that players can discover it !!
				OOP_INFO_MSG("cleaned up intel object from db", []);
			};

			DELETE(_intelClone); // We delete only the local clone of intel we temporarily used for updating the actual intel in the database
		};
	ENDMETHOD;

	/*
	Method: (protected) setScore
	Unpacks a score array (4 element number vector) into the individual scoring properties.

	Parameters:	
		_scoreVec - Array of Number, the score vector to assign
	*/
	protected METHOD(setScore)
		params [P_THISOBJECT, P_ARRAY("_scoreVec")];
		T_SETV("scorePriority", GET_SCORE_PRIORITY(_scoreVec));
		T_SETV("scoreResource", GET_SCORE_RESOURCE(_scoreVec));
		T_SETV("scoreStrategy", GET_SCORE_STRATEGY(_scoreVec));
		T_SETV("scoreCompleteness", GET_SCORE_COMPLETENESS(_scoreVec));
	ENDMETHOD;

	/*
	Method: (protected virtual) createTransitions
	Create the ASTs for the action and assign them to the transitions member variable.
	We do NOT do this in the constructor, because it is only required for actions that will
	definiely be used, and the vast majority of actions that are created are just speculative
	(they are scored and then discarded if the score is too low).
	*/
	protected virtual METHOD(createTransitions)
		params [P_THISOBJECT];
	ENDMETHOD;
	
	/*
	Method: registerGarrison
	Registers a garrison that has this action assigned to it, so we can automatically unassign 
	this action from it when it is finished (helps with cleanup).
	
	Parameters:
		_garrison - <Model.GarrisonModel>
	*/
	public METHOD(registerGarrison)
		params [P_THISOBJECT, P_OOP_OBJECT("_garrison")];
		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		private _garrisons = T_GETV("garrisons");
		_garrisons pushBack _garrison;
	ENDMETHOD;

	/*
	Method: unregisterGarrison
	Remove a garrison from the list for which we will automatically an assign this action when 
	it is finished.
	
	Parameters:
		_garrison - <Model.GarrisonModel>
	*/
	public METHOD(unregisterGarrison)
		params [P_THISOBJECT, P_OOP_OBJECT("_garrison")];
		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		private _garrisons = T_GETV("garrisons");
		private _idx = _garrisons find _garrison;
		if(_idx == NOT_FOUND) exitWith {
			OOP_WARNING_MSG("Garrison %1 is not registered with action %2, so can't be unregistered", [_garrison ARG _thisObject]);
		};
		_garrisons deleteAt _idx;
	ENDMETHOD;


	// Garrison's Intel:

	// Note that we now differentiate "general" intel known to garrison and garrison's "personal" intel
	// "general" intel is typically not related to this garrison but to other garrisons
	// "personal" intel is intel about cmdr action in which this garrison is currently involved

	/*
	Method: (protected) addGeneralIntelToGarrison
	Add the intel object of this action to a specific garrison.
	
	Parameters:
		_garrison - <Model.GarrisonModel>, the garrion to assign the intel to.
	*/
	protected METHOD(addGeneralGarrisonIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_garrison")];
		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		if(CALLM0(_garrison, "isActual") && !CALLM0(_garrison, "isDead")) then {
			private _intelClone = T_GETV("intelClone");

			// Bail if null
			if (!IS_NULL_OBJECT(_intelClone)) then { // Because it can be objNull
				private _intel = CALLM0(_intelClone, "getDbEntry");
				private _actual = GETV(_garrison, "actual");
				// It will make sure itself that it doesn't add duplicates of intel
				private _AI = CALLM0(_actual, "getAI");
				CALLM2(_AI, "postMethodAsync", "addGeneralIntel", [_intel]);
				//CALLM2(_AI, "postMethodAsync", "setIntelThis", [_intel]);
				
				// TODO: implement this Sparker. 
				// 	NOTES: Make Garrison.addIntel add the intel to the occupied location as well.
				// 	NOTES: Make Garrison.addIntel only add if it isn't already there because this will happen often.
			};
		};
	ENDMETHOD;

	/*
	Method: (protected) addIntelAtLocationForSide
	Add the intel object of this action to the garrison of the specified side at a location.
	
	Parameters:
		_location - <Model.LocationModel>, the location whose _side garrison the intel should be assigned to.
		_side - <side>, the side of the garrisons to assign the intel to
	*/
	protected METHOD(addIntelAtLocationForSide)
		params [P_THISOBJECT, P_OOP_OBJECT("_location"), P_SIDE("_side")];
		ASSERT_OBJECT_CLASS(_location, "LocationModel");
		if(CALLM0(_location, "isActual")) then {
			private _intelClone = T_GETV("intelClone");

			// Bail if null
			if (!IS_NULL_OBJECT(_intelClone)) then { // Because it can be objNull
				private _intel = CALLM0(_intelClone, "getDbEntry");
				private _locationActual = GETV(_location, "actual");
				{
					// It will make sure itself that it doesn't add duplicates of intel
					private _AI = CALLM0(_x, "getAI");
					CALLM2(_AI, "postMethodAsync", "addGeneralIntel", [_intel]);
					//CALLM2(_AI, "postMethodAsync", "setIntelThis", [_intel]);
				} forEach CALLM1(_locationActual, "getGarrisons", _side);
				// TODO: implement this Sparker. 
				// 	NOTES: Make Garrison.addIntel add the intel to the occupied location as well.
				// 	NOTES: Make Garrison.addIntel only add if it isn't already there because this will happen often.
			};
		};
	ENDMETHOD;

	/*
	Method: (public) setPersonalGarrisonIntel
	*/
	public METHOD(setPersonalGarrisonIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_garrison")];
		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");

		OOP_INFO_1("setPersonalGarrisonIntel: %1", _garrison);

		if(CALLM0(_garrison, "isActual") && !CALLM0(_garrison, "isDead")) then {

			OOP_INFO_0("  garrison is actual");

			private _intelClone = T_GETV("intelClone");

			// Bail if null
			if (!IS_NULL_OBJECT(_intelClone)) then { // Because it can be objNull
				private _intel = CALLM0(_intelClone, "getDbEntry");

				OOP_INFO_0("  intel is not null");

				private _actual = GETV(_garrison, "actual");
				// It will make sure itself that it doesn't add duplicates of intel
				private _AI = CALLM0(_actual, "getAI");
				CALLM2(_AI, "postMethodAsync", "setPersonalIntel", [_intel]);

				OOP_INFO_2("  sent intel %1 to AI: %2", _intel, _AI);
			};
		};
	ENDMETHOD;

	/*
	Method: (protected) addIntelAt
	Add the intel object of this action to garrisons in an area specified.
	
	Parameters:
		_world - <Model.WorldModel>, the world model in which to look for garrisons.
		_pos - Position, the center of the area in which we are placing intel.
		_radius - Number, default 2000, the radius in meters in which we are placing intel.
	*/
	protected METHOD(addIntelAt)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_POSITION("_pos"), ["_radius", 3500, [0]]]; // Testing
		ASSERT_OBJECT_CLASS(_world, "WorldModel");


		private _intelClone = T_GETV("intelClone");
		private _intel = NULL_OBJECT;
		if (!IS_NULL_OBJECT(_intelClone)) then {
			_intel = CALLM0(_intelClone, "getDbEntry");
		};

		{
			_x params ["_distance", "_garrison"];
			// For now let's give intel to all garrisons in range?
			/*
			private _chance =  1 - (_distance / _radius) ^ 2 + 0.1;
			if(_chance > random 1) then {
				T_CALLM("addIntelToGarrison", [_garrison]);
			};
			*/
			T_CALLM1("addGeneralGarrisonIntel", _garrison); // Note that we give general intel to this garrison, not personal
		} forEach CALLM(_world, "getNearestGarrisons", [_pos ARG _radius]);

		// Add intel for civilian informants in cities
		if (!IS_NULL_OBJECT(_intel)) then {
			{
				T_CALLM2("addIntelAtLocationForSide", _x, civilian);

				// Add intel directly to cities
				if (CALLM0(_x, "isActual")) then {
					pr _locActual = GETV(_x, "actual");
					CALLM1(_locActual, "addIntel", _intel);
				};
			} forEach (CALLM(_world, "getNearestLocations", [_pos ARG 2000 ARG [LOCATION_TYPE_CITY]]) apply {
				_x#1
			});
		};

		// Make enemies intercept this intel
		if (!IS_NULL_OBJECT(_intelClone)) then { // Because it can be objNull
			CALLSM2("AICommander", "interceptIntelAt", _intel, _pos);
		};
	ENDMETHOD;

	/*
	Method: updateIntelForEnemies

	Call this when we need to broadcast an intel update to enemies (enemy commanders)
	*/
	protected METHOD(updateIntelForEnemies)
		params [P_THISOBJECT];
		private _intelClone = T_GETV("intelClone");
		if (!IS_NULL_OBJECT(_intelClone)) then {
			private _intel = CALLM0(_intelClone, "getDbEntry");
			CALLSM2("AICommander", "updateIntelCommanderActionForEnemies", _intel, _intelClone);
		};
	ENDMETHOD;

	/*
	Method: setIntelState
	Sets the state of the intel associated with this action. /// (not any more) Updates it for enemies, but only if state was changed.
	*/
	protected METHOD(setIntelState)
		params [P_THISOBJECT, ["_state", INTEL_ACTION_STATE_INACTIVE, [0]], ["_updateForEnemies", true, [true]]];
		private _intelClone = T_GETV("intelClone");
		if (!IS_NULL_OBJECT(_intelClone)) then {
			//private _statePrev = GETV(_intelClone, "state");
			SETV(_intelClone, "state", _state);
			// If state has changed and update for enemies was requested
			//if (_state != _statePrev && _updateForEnemies) then {
			// Disabled for now to see if it resolves error when state isn't synchronized for some reason
				T_CALLM0("updateIntelForEnemies");
			//};
		};
	ENDMETHOD;

	/*
	Method: (virtual) updateScore
	Called by <AI.CmdrAI.CmdrAI> when evaluating potential actions. It should use the world states and settings this
	action was initialized with to evaluate its subjective value, and then set the score* member variables 
	appropriately.
	
	Parameters:
		_worldNow - <Model.WorldModel>, simulation of world in its current state possibly with some instantaneous actions applied (e.g. resource allocation).
		_worldFuture - <Model.WorldModel>, simulation of world in its predicted state once all currently planned actions are complete.
	*/
	public virtual METHOD(updateScore)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
	ENDMETHOD;

	public METHOD(getFinalScore)
		params [P_THISOBJECT];
		private _scorePriority = T_GETV("scorePriority");
		private _scoreResource = T_GETV("scoreResource");
		private _scoreStrategy = T_GETV("scoreStrategy");
		private _scoreCompleteness = T_GETV("scoreCompleteness");
		// TODO: what is the correct to combine these scores?
		// Should we try to get them all from 0 to 1?
		// Maybe we want R*(iP + jS + kC)?
		CLAMP_POSITIVE(_scorePriority) * CLAMP_POSITIVE(_scoreResource) * CLAMP_POSITIVE(_scoreStrategy) * CLAMP_POSITIVE(_scoreCompleteness)
	ENDMETHOD;

	/*
	Method: (protected) createVariable
	Creates and registers an <AST_VAR> variable for use with this actions ASTs. The registration ensures that the 
	value of the variable is saved and restored when performing simulations using this action. It is only required 
	if the value can be changed by any of the ASTs themselves. If it can't then you can just directly create 
	an <AST_VAR> without calling this function.
	
	Parameters:
		_initialValue - Any, initial value for the variable to hold.
	
	Returns: <AST_VAR> reference to the newly created and registered variable.
	*/
	protected METHOD(createVariable)
		params [P_THISOBJECT, P_DYNAMIC("_initialValue")];
		private _variables = T_GETV("variables");
		private _index = _variables pushBack _initialValue;
		_index
	ENDMETHOD;

	// Push the values of all registered variables.
	protected METHOD(pushVariables)
		params [P_THISOBJECT];
		private _variables = T_GETV("variables");
		private _variablesStack = T_GETV("variablesStack");
		
		// Make a deep copy of all the variables and push them into the stack
		private _variablesCopy = +_variables;
		_variablesStack pushBack _variablesCopy;
	ENDMETHOD;

	// Pop the values of all registered variables.
	protected METHOD(popVariables)
		params [P_THISOBJECT];
		private _variables = T_GETV("variables");
		private _variablesStack = T_GETV("variablesStack");
		private _stackSize = count _variablesStack;
		
		ASSERT_MSG(_stackSize > 0, "Variables stack is empty");

		// Restore our whole variables array from the top stack element
		private _prevVariables = _variablesStack deleteAt (_stackSize - 1);
		T_SETV("variables", _prevVariables);
	ENDMETHOD;
	
	// Returns (after creating if necessary) the ASTs of this action.
	METHOD(getTransitions)
		params [P_THISOBJECT];
		private _transitions = T_GETV("transitions");
		if(count _transitions == 0) then {
			_transitions = T_CALLM("createTransitions", []);
			T_SETV("transitions", _transitions);
		};
		_transitions
	ENDMETHOD;

	/*
	Method: applyToSim
	Apply applicable ASTs to the specified world sim. What is applicable depends on 
	current state, the type of world and the behaviour of the ASTs. Future world sims can 
	have all ASTs applied until END state is reached, as ASTs should implement simulation of their 
	final results. Now world sims can only have instantaneous AST results applied (e.g. allocating resources, 
	splitting a Garrison, assigning an action), so will usually not transition to END state.
	
	Parameters:	
		_world - <Model.WorldModel>, world to apply simulation of this action to. Sim worlds only, not real.
	
	Returns: <CMDR_ACTION_STATE>, the state after applying all applicable ASTs
	*/
	public METHOD(applyToSim)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		private _state = T_GETV("state");
		private _transitions = T_CALLM("getTransitions", []);
		ASSERT_MSG(count _transitions > 0, "CmdrAction hasn't got any _transitions assigned");

		T_CALLM("pushVariables", []);

		private _worldType = GETV(_world, "type");
		ASSERT_MSG(_worldType != WORLD_TYPE_REAL, "Cannot applyToSim on real world!");
		while {_state != CMDR_ACTION_STATE_END} do {
			private _newState = CALLSM("ActionStateTransition", "selectAndApply", [_world ARG _state ARG _transitions]);
			// State transitions are allowed to fail for NOW world sim (so they can limit changes to those that would happen instantly)
			ASSERT_MSG(_worldType == WORLD_TYPE_SIM_NOW or _newState != _state, format (["Couldn't apply action %1 to sim future, stuck in state %2" ARG _thisObject ARG _state]));
			if(_newState == _state) exitWith {};
			_state = _newState;
		};

		T_CALLM("popVariables", []);
		// We don't update to the new state, this is just a simulation, but return it for information purposes
		_state
	ENDMETHOD;

	/*
	Method: update
	Attempt to progress with this action in a real world model.
	
	Parameters:
		_world - <Model.WorldModel>, real world to update this action for. Sim worlds are not valid.
	*/
	public METHOD(update)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];

		ASSERT_MSG(CALLM0(_world, "isReal"), "Should only update CmdrActions on non sim world. Use applySim in sim worlds");

		private _state = T_GETV("state");
		private _transitions = T_CALLM("getTransitions", []);
		ASSERT_MSG(count _transitions > 0, "CmdrAction hasn't got any _transitions assigned");

		private _oldState = CMDR_ACTION_STATE_NONE;
		// Apply states until we are blocked.
		while {_state != _oldState} do 
		{
			_oldState = _state;
			_state = CALLSM("ActionStateTransition", "selectAndApply", [_world ARG _oldState ARG _transitions]);
		};
		T_SETV("state", _state);

		T_CALLM("updateIntel", [_world]);

		#ifdef DEBUG_CMDRAI_ACTIONS
		T_CALLM("debugDraw", [_world]);
		#endif
	ENDMETHOD;

	/*
	Method: cancel
	Cancel this action while it is in progress.
	It will call a "cancel" on the current AST.
	*/
	public virtual METHOD(cancel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];

		private _state = T_GETV("state");

		// The action is over, so there is surely no current AST
		if(_state == CMDR_ACTION_STATE_END) exitWith {};

		// Get current AST and call "cancel" on it
		private _transitions = T_CALLM("getTransitions", []);
		private _AST = CALLSM("ActionStateTransition", "selectTransition", [_world ARG _state ARG _transitions]);
		if (!IS_NULL_OBJECT(_AST)) then {
			CALLM1(_AST, "cancel", _world);
		};

	ENDMETHOD;

	/*
	Method: isComplete
	Is this action complete? i.e. reached state <CMDR_ACTION_STATE.CMDR_ACTION_STATE_END>
	Returns: Boolean, true if the action is complete.
	*/
	public METHOD(isComplete)
		params [P_THISOBJECT];
		T_GETV("state") == CMDR_ACTION_STATE_END
	ENDMETHOD;

	/*
	Method: (protected virtual) updateIntel
	Implement to update intel object. 
	
	Parameters:
		_world - <Model.WorldModel>, real world model that is being used.
	*/
	protected virtual METHOD(updateIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
	ENDMETHOD;

	/*
	Method: (protected virtual) getLabel
	Implement to generate debug label for map marker for this action. 
	
	Parameters:	
		_world - <Model.WorldModel>, real world model that is being used.
	*/
	protected virtual METHOD(getLabel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		""
	ENDMETHOD;

	/*
	Method: (protected virtual) debugDraw
	Implement to perform debug drawing (e.g. update a marker).
	*/
	protected virtual METHOD(debugDraw)
		params [P_THISOBJECT];
	ENDMETHOD;

	// Toolkit for scoring actions -----------------------------------------

	/*
	Method: (static) calcDistanceFalloff
	Get a value that falls off from 1 to 0 with distance, scaled by k.
	For k = 1:
	0m = 1, 2000m = 0.5, 4000m = 0.25, 6000m = 0.2, 10000m = 0.0385
	For k = 4:
	0m = 1, 500m = 0.5, 1000m = 0.25, 1500m = 0.2, 2500m = 0.0385
	For k = 0.25:
	0m = 1, 8000m = 0.5, 13850m = 0.25, 16000m = 0.2, ~40000m = 0.0385
	See https://www.desmos.com/calculator/pjs09xfxkm
	
	Parameters:
		_distance - Number, distance to generate falloff for, can be positive or negative, in meters
		_k - Number, optional, factor that scales falloff amount, see description for examples.
	
	Returns: Number, value in 0 to 1 range representing the falloff that should be applied for the specified positions.
	*/
	public STATIC_METHOD(calcDistanceFalloff)
		params [P_THISCLASS, P_NUMBER("_distance"), "_k"];
		private _kf = if(isNil "_k") then { 1 } else { _k };
		// See https://www.desmos.com/calculator/pjs09xfxkm
		private _distScaled = 0.0005 * _distance * _kf;
		(1 / (1 + _distScaled * _distScaled))
	ENDMETHOD;

	/*
	Method: (static)getDetachmentStrength
	Returns number from given efficiency vector which represents how 'strong' the detachment is
	*/
	public STATIC_METHOD(getDetachmentStrength)
		params [P_THISCLASS, P_ARRAY("_eff")];
		(_eff#T_EFF_soft) + 1.5*(_eff#T_EFF_medium) + 2*(_eff#T_EFF_armor) + 2*(_eff#T_EFF_air)
	ENDMETHOD;

	/*
	Method: (virtual) getRecordSerial
	Returns a serialized CmdrActionRecord associated with this action.
	Derived classes should implement this to have proper support for client's UI.
	
	Parameters:	
		_world - <Model.WorldModel>, real world model that is being used.
	*/
	public virtual METHOD(getRecordSerial)
		params [P_THISOBJECT, P_OOP_OBJECT("_garModel"), P_OOP_OBJECT("_world")];

		// Return [] by default
		[]
	ENDMETHOD;

	// - - - - - STORAGE - - - - - -
	public override METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Save our intel clone
		private _intelClone = T_GETV("intelClone");
		if(!IS_NULL_OBJECT(_intelClone)) then {
			CALLM1(_storage, "save", _intelClone);
		};

		// Save transitions
		{
			private _transition = _x;
			CALLM1(_storage, "save", _transition);
		} forEach T_GETV("transitions");

		true
	ENDMETHOD;

	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Load intel clone
		private _intelClone = T_GETV("intelClone");
		if(!IS_NULL_OBJECT(_intelClone)) then {
			CALLM1(_storage, "load", _intelClone);
		};
		
		// Load transitions
		{
			private _transition = _x;
			CALLM1(_storage, "load", _transition);
		} forEach T_GETV("transitions");

		true
	ENDMETHOD;
	
ENDCLASS;

if(isNil "gActionDebugMarkerStyle") then {
	gActionDebugMarkerStyle = [];
	debug_fnc_getDebugMarkerStyle = {
		private _className = if(IS_OOP_OBJECT(_this)) then {
			GET_OBJECT_CLASS(_this)
		} else {
			_this
		};
		private _idx = gActionDebugMarkerStyle findIf { (_x#0) isEqualTo _className };
		if(_idx != -1) then {
			[gActionDebugMarkerStyle#_idx#1, gActionDebugMarkerStyle#_idx#2]
		} else {
			["ColorRed", "loc_Ruin"]
		}
	};
	REGISTER_DEBUG_MARKER_STYLE("CmdrAction", "ColorRed", "loc_Ruin");
};

// Unit test
#ifdef _SQF_VM

// Test AST Variables

["AST_VAR", {

	#define OOP_CLASS_NAME ActionASTVarTest
	CLASS("ActionASTVarTest", "CmdrAction")
		public METHOD(testVars)
			params [P_THISOBJECT];

			private _var = T_CALLM1("createVariable", -1);
			private _var2 = _var;

			["GET_AST_VAR", GET_AST_VAR(_thisObject, _var) == -1] call test_Assert;
			SET_AST_VAR(_thisObject, _var, 1);
			["SET_AST_VAR", GET_AST_VAR(_thisObject, _var) == 1] call test_Assert;
			["AST_VAR share value works", GET_AST_VAR(_thisObject, _var2) == 1] call test_Assert;
		ENDMETHOD;
	ENDCLASS;

	private _testObj = NEW("ActionASTVarTest", []);
	CALLM0(_testObj, "testVars");

}] call test_AddTest;

#define CMDR_ACTION_STATE_KILLED CMDR_ACTION_STATE_CUSTOM+1
#define CMDR_ACTION_STATE_FAILED CMDR_ACTION_STATE_CUSTOM+2

// Dummy test classes

["CmdrAction Dummy test classes", {
	#define OOP_CLASS_NAME AST_KillGarrisonSetVar
CLASS("AST_KillGarrisonSetVar", "ActionStateTransition")
		VARIABLE("garrisonId");
		VARIABLE("var");
		VARIABLE("newVal");

		METHOD(new)
			params [P_THISOBJECT, P_OOP_OBJECT("_action"), P_NUMBER("_garrisonId"), P_AST_VAR("_var"), P_DYNAMIC("_newVal")];
			T_SETV("garrisonId", _garrisonId);
			T_SETV("var", _var);
			T_SETV("newVal", _newVal);
			T_SETV("fromStates", [CMDR_ACTION_STATE_START]);
		ENDMETHOD;

		public override METHOD(isAvailable) 
			params [P_THISOBJECT, P_STRING("_world")];
			private _garrisonId = T_GETV("garrisonId");
			private _garrison = CALLM(_world, "getGarrison", [_garrisonId]);
			!(isNil "_garrison")
		ENDMETHOD;

		public override METHOD(apply) 
			params [P_THISOBJECT, P_STRING("_world")];

			// Kill the garrison - this should be preserved after applySim
			private _garrisonId = T_GETV("garrisonId");
			private _garrison = CALLM(_world, "getGarrison", [_garrisonId]);
			CALLM0(_garrison, "killed");

			// Apply the change to the AST var - this should be reverted after applySim
			private _newVal = T_GETV("newVal");
			SET_AST_VAR(T_GETV("action"), T_GETV("var"), _newVal);

			CMDR_ACTION_STATE_KILLED
		ENDMETHOD;
	ENDCLASS;

	#define OOP_CLASS_NAME AST_TestVariable
CLASS("AST_TestVariable", "ActionStateTransition")
		VARIABLE("var");
		VARIABLE("compareVal");

		METHOD(new)
			params [P_THISOBJECT, P_OOP_OBJECT("_action"), P_AST_VAR("_var"), P_DYNAMIC("_compareVal")];
			T_SETV("fromStates", [CMDR_ACTION_STATE_KILLED]);
			T_SETV("var", _var);
			T_SETV("compareVal", _compareVal);
		ENDMETHOD;

		public override METHOD(apply) 
			params [P_THISOBJECT, P_STRING("_world")];
			private _compareVal = T_GETV("compareVal");
			if(GET_AST_VAR(T_GETV("action"), T_GETV("var")) isEqualTo _compareVal) then {
				CMDR_ACTION_STATE_END
			} else {
				CMDR_ACTION_STATE_FAILED
			}
		ENDMETHOD;
	ENDCLASS;
}] call test_AddTest;

["CmdrAction.new", {
	private _obj = NEW("CmdrAction", []);
	
	private _class = OBJECT_PARENT_CLASS_STR(_obj);
	["Object exists", !(isNil "_class")] call test_Assert;
	["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

["CmdrAction.delete", {
	private _obj = NEW("CmdrAction", []);
	DELETE(_obj);
	isNil { OBJECT_PARENT_CLASS_STR(_obj) }
}] call test_AddTest;

["CmdrAction.registerGarrison, unregisterGarrison", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _thisObject = NEW("CmdrAction", []);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);

	CALLM(_garrison, "setAction", [_thisObject]);
	["Garrison registered correctly", (T_GETV("garrisons") find _garrison) != NOT_FOUND] call test_Assert;
	
	DELETE(_garrison);
	["Garrison unregistered correctly", (T_GETV("garrisons") find _garrison) == NOT_FOUND] call test_Assert;

	_garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	CALLM(_garrison, "setAction", [_thisObject]);
	["Garrison registered correctly 2", (T_GETV("garrisons") find _garrison) != NOT_FOUND] call test_Assert;
	DELETE(_thisObject);
	["Action cleared from garrison on delete", CALLM0(_garrison, "getAction") == NULL_OBJECT] call test_Assert;
}] call test_AddTest;

["CmdrAction.createVariable, pushVariables, popVariables", {
	SCOPE_IGNORE_ACCESS(CmdrAction);
	private _thisObject = NEW("CmdrAction", []);

	private _var = T_CALLM("createVariable", [0]);
	private _var2 = T_CALLM("createVariable", [["test"]]);

	["Var is of correct form", _var isEqualTo 0] call test_Assert;
	["Var2 is of correct form", _var2 isEqualTo 1] call test_Assert;

	T_CALLM("pushVariables", []);

	SET_AST_VAR(_thisObject, _var, 1);
	SET_AST_VAR(_thisObject, _var2, 2);

	["Var is changed before popVariables", GET_AST_VAR(_thisObject, _var) == 1] call test_Assert;
	["Var2 is changed before popVariables", GET_AST_VAR(_thisObject, _var2) == 2] call test_Assert;

	T_CALLM("popVariables", []);

	//diag_log format [" Get var 0 after pop: %1", GET_AST_VAR(_thisObject, _var)];
	//diag_log format [" Get var 1 after pop: %1", GET_AST_VAR(_thisObject, _var2)];

	["Var is restored after popVariables", GET_AST_VAR(_thisObject, _var) isEqualTo 0] call test_Assert;
	["Var2 is restored after popVariables", GET_AST_VAR(_thisObject, _var2) isEqualTo ["test"] ] call test_Assert;
}] call test_AddTest;

["CmdrAction.getFinalScore", {
	private _obj = NEW("CmdrAction", []);
	CALLM0(_obj, "getFinalScore") == 1
}] call test_AddTest;

["CmdrAction.applyToSim", {
	SCOPE_IGNORE_ACCESS(CmdrAction);
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _action = NEW("CmdrAction", []);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _thisObject = NEW("CmdrAction", []);
	private _testVar = T_CALLM("createVariable", ["original"]);
	private _asts = [
		NEW("AST_KillGarrisonSetVar",
			[_action] +
			[GETV(_garrison, "id")]+
			[_testVar] +
			["modified"]
		),
		NEW("AST_TestVariable", 
			[_action] +
			[_testVar] +
			["modified"]
		)
	];

	T_SETV("transitions", _asts);

	["Transitions correct", T_GETV("transitions") isEqualTo _asts] call test_Assert;

	private _finalState = T_CALLM("applyToSim", [_world]);
	["applyToSim applied state to sim correctly", CALLM0(_garrison, "isDead")] call test_Assert;
	["applyToSim modified variables internally correctly", _finalState == CMDR_ACTION_STATE_END] call test_Assert;
	["applyToSim reverted action variables correctly", GET_AST_VAR(_thisObject, _testVar) isEqualTo "original"] call test_Assert;
}] call test_AddTest;

#endif