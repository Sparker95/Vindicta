#include "common.hpp"
FIX_LINE_NUMBERS()
/*
Class: MessageLoopMainManager
It's a MessageReceiverEx which is always attached to the gMessageLoopMain.
We need it to perform different synchronization tasks with the message loop.
We need an object which is always in the thread to send messages to it.
*/

#define pr private

#define OOP_CLASS_NAME MessageLoopMainManager
CLASS("MessageLoopMainManager", "MessageReceiverEx");

	/*
	Method: EH_killed
	It is called when a unit is killed.
	It is called in the main thread, so it's perfectly synchronized with everything.

	Parameters: "_objectHandle", "_killer", "_instigator", "_useEffects"

	Parameters are same as https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Killed

	Returns: nil
	*/
	METHOD(EH_Killed)
		params [P_THISOBJECT, P_OBJECT("_objectHandle"), P_OBJECT("_killer"), P_OBJECT("_instigator"), P_BOOL("_useEffects")];
		T_CALLM3("UnitObjectKilled", _objectHandle, objNull, _killer);
	ENDMETHOD;

	/*
	Method: EH_Respawn
	It is called when a unit respawns.
	It is called in the main thread, so it's perfectly synchronized with everything.

	Parameters: "_objectHandle", "_corpseHandle"

	Parameters are same as https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#Respawn

	Returns: nil
	*/
	METHOD(EH_Respawn)
		params [P_THISOBJECT, P_OBJECT("_objectHandle"), P_OBJECT("_corpseHandle")];
		T_CALLM2("UnitObjectKilled", _objectHandle, _corpseHandle);
	ENDMETHOD;

	METHOD(UnitObjectKilled)
		params [P_THISOBJECT, P_OBJECT("_objectHandle"), P_OBJECT("_corpseHandle"), P_OBJECT("_killer")];

		ASSERT_THREAD(_thisObject);

		OOP_INFO_1("%1", _this);

		// Is this object an instance of Unit class?
		private _unit = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_objectHandle]);

		if (!IS_NULL_OBJECT(_unit) && IS_OOP_OBJECT(_unit)) then {
			T_CALLM2("UnitKilled", _unit, _killer);
		} else {
			OOP_WARNING_1("Unit of object %1 is unknown", _objectHandle);
		};
	ENDMETHOD;

	METHOD(UnitKilled)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit"), P_OBJECT("_killer")];

		pr _data = GETV(_unit, "data");
		OOP_INFO_2("%1 %2", _unit, _data);

		// Since this code is run in the main thread, we can just call the methods directly
		// Post a message to the garrison of the unit
		pr _garrison = _data select UNIT_DATA_ID_GARRISON;
		if (!IS_NULL_OBJECT(_garrison)) then {	// Sanity check	
			CALLM1(_garrison, "handleUnitKilled", _unit);

			// Notify game mode that a unit was destroyed
			pr _catID = CALLM0(_unit, "getCategory");
			pr _subcatID = CALLM0(_unit, "getSubcategory");
			pr _side = CALLM0(_garrison, "getSide");
			pr _faction = CALLM0(_garrison, "getFaction");
			CALLM4(gGameMode, "unitDestroyed", _catID, _subcatID, _side, _faction);

			// Send stimulus to garrison's casualties sensor
			pr _garAI = CALLM0(_garrison, "getAI");
			if (!IS_NULL_OBJECT(_garAI)) then {
				pr _stim = STIMULUS_NEW();
				STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_UNIT_DESTROYED);
				pr _value = [_unit, _killer];
				STIMULUS_SET_VALUE(_stim, _value);
				CALLM1(_garAI, "handleStimulus", _stim);
			};
		} else {
			OOP_ERROR_2("Unit is not attached to a garrison: %1, %2", _unit, _data);
		};
	ENDMETHOD;

	STATIC_METHOD(KillUnit)
		params [P_THISCLASS, P_OBJECT("_objectHandle")];
		// Is this object an instance of Unit class?
		private _unit = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_objectHandle]);
		if (!IS_NULL_OBJECT(_unit) && IS_OOP_OBJECT(_unit)) then {
			DELETE(_unit);
		};
	ENDMETHOD;
	
	/*
	Method: EH_GetIn
	It is called when someone gets in a vehicle.
	It is called in the main thread, so it's perfectly synchronized with everything.

	Parameters: "_vehicle", "_role", "_unit", "_turret"

	Parameters are same as https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#GetIn

	Returns: nil
	*/
	METHOD(EH_GetIn)
		params [P_THISOBJECT, "_vehicle", "_role", "_unit", "_turret"];

		OOP_INFO_1("EH_GetIn: %1", _this);

		ASSERT_THREAD(_thisObject);

		// This is an async message, either vehicle or unit could have been deleted by now... this is a bit of a problem.
		// TODO: fix this somehow? Really we need to get the Unit OOP objects in the synchronous part of the handler.
		if(isNull _unit) exitWith {
			OOP_WARNING_1("EH_GetIn: unit handle is null (%1)", _this);
		};

		if(isNull _vehicle) exitWith {
			OOP_WARNING_1("EH_GetIn: vehicle handle is null (%1)", _this);
		};

		// Is this object an instance of Unit class?
		private _unitVeh = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_vehicle]);
		private _unitInf = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_unit]);

		OOP_INFO_4("EH_GetIn: _this: %1, _unitVeh: %2, _unitInf: %3, typeOf _vehicle: %4", _this, _unitVeh, _unitInf, typeof _vehicle);

		if (_unitVeh == "" || {!IS_OOP_OBJECT(_unitVeh)}) exitWith {
			OOP_ERROR_1("EH_GetIn: vehicle doesn't have a Unit object (%1)", _this);
		};

		if (_unitInf == "" || {!IS_OOP_OBJECT(_unitInf)}) exitWith {
			OOP_ERROR_1("EH_GetIn: unit doesn't have a Unit object (%1)", _this);
		};

		pr _data = GETV(_unitVeh, "data");
		pr _garrison = _data select UNIT_DATA_ID_GARRISON;
		if (_garrison != "") then {	// Sanity check
			CALLM2(_garrison, "handleGetInVehicle", _unitVeh, _unitInf);
		} else {
			OOP_ERROR_2("EH_GetIn: vehicle is not attached to a garrison: %1, %2", _unitVeh, _data);
		};

	ENDMETHOD;

	/*
	Method: EH_GetOut
	It is called when someone gets out of a vehicle.
	It is called in the main thread, so it's perfectly synchronized with everything.

	Parameters: "_vehicle", "_role", "_unit", "_turret"

	Parameters are same as https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#GetOut

	Returns: nil
	*/
	METHOD(EH_GetOut)
		params [P_THISOBJECT, "_vehicle", "_role", "_unit", "_turret"];

		OOP_INFO_1("EH_GetOut: %1", _this);

		ASSERT_THREAD(_thisObject);

		// This is an async message, either vehicle or unit could have been deleted by now... this is a bit of a problem.
		// TODO: fix this somehow? Really we need to get the Unit OOP objects in the synchronous part of the handler.
		if(isNull _unit) exitWith {
			OOP_WARNING_1("EH_GetOut: unit handle is null (%1)", _this);
		};

		if(isNull _vehicle) exitWith {
			OOP_WARNING_1("EH_GetOut: vehicle handle is null (%1)", _this);
		};

		// Is this object an instance of Unit class?
		private _unitVeh = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_vehicle]);
		private _unitInf = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_unit]);

		OOP_INFO_4("EH_GetOut: _this: %1, _unitVeh: %2, _unitInf: %3, typeOf _vehicle: %4", _this, _unitVeh, _unitInf, typeof _vehicle);

		if (_unitVeh == "" || {!IS_OOP_OBJECT(_unitVeh)}) exitWith {
			OOP_ERROR_1("EH_GetOut: vehicle doesn't have a Unit object (%1)", _this);
		};

		if (_unitInf == "" || {!IS_OOP_OBJECT(_unitInf)}) exitWith {
			OOP_ERROR_1("EH_GetOut: unit doesn't have a Unit object (%1)", _this);
		};

		pr _data = GETV(_unitVeh, "data");
		pr _garrison = _data select UNIT_DATA_ID_GARRISON;
		if (_garrison != "") then {	// Sanity check
			CALLM2(_garrison, "handleGetOutVehicle", _unitVeh, _unitInf);
		} else {
			OOP_ERROR_2("EH_GetOut: vehicle is not attached to a garrison: %1, %2", _unitVeh, _data);
		};

	ENDMETHOD;
	METHOD(EH_aceCargoLoaded)
		params [P_THISOBJECT, "_item", "_vehicle"];

		private _unitItem = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_item]);
		private _unitVeh = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_vehicle]);

		OOP_INFO_3("EH_aceCargoLoaded: _this: %1, _unitItem: %2, _unitVeh: %3", _this, _item, _vehicle);

		if (_unitItem == "" || {!IS_OOP_OBJECT(_unitItem)}) exitWith {
			OOP_ERROR_0("EH_aceCargoLoaded: item doesn't have a unit object!");
		};

		if (_unitVeh == "" || {!IS_OOP_OBJECT(_unitVeh)}) exitWith {
			OOP_ERROR_0("EH_aceCargoLoaded: vehicle doesn't have a unit object!");
		};

		pr _garrison = CALLM0(_unitItem, "getGarrison");
		if (_garrison != "") then {
			CALLM2(_garrison, "handleCargoLoaded", _unitItem, _unitVeh);
		} else {
			OOP_ERROR_1("EH_aceCargoLoaded: item is not attached to a garrison: %1", _unitItem);
		};
		
	ENDMETHOD;

	METHOD(EH_aceCargoUnloaded)
		params [P_THISOBJECT, "_item", "_vehicle"];

		private _unitItem = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_item]);
		private _unitVeh = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_vehicle]);

		OOP_INFO_3("EH_aceCargoUnloaded: _this: %1, _unitItem: %2, _unitVeh: %3", _this, _item, _vehicle);

		if (_unitItem == "" || {!IS_OOP_OBJECT(_unitItem)}) exitWith {
			OOP_ERROR_0("EH_aceCargoUnLoaded: item doesn't have a unit object!");
		};

		if (_unitVeh == "" || {!IS_OOP_OBJECT(_unitVeh)}) exitWith {
			OOP_ERROR_0("EH_aceCargoUnLoaded: vehicle doesn't have a unit object!");
		};

		pr _garrison = CALLM0(_unitItem, "getGarrison");
		if (_garrison != "") then {
			CALLM2(_garrison, "handleCargoUnloaded", _unitItem, _unitVeh);
		} else {
			OOP_ERROR_1("EH_aceCargoUnLoaded: item is not attached to a garrison: %1", _unitItem);
		};
		
	ENDMETHOD;

	/*
	Method: deleteObject
	Deletes object in this thread.

	Returns: nil
	*/
	METHOD(deleteObject)
		params [P_THISOBJECT, P_OOP_OBJECT("_objectRef")];
		if (IS_OOP_OBJECT(_objectRef)) then {
			DELETE(_objectRef);
		} else {
			OOP_ERROR_1("deleteObject: invalid object ref: %1", _objectRef);
		};
	ENDMETHOD;

	METHOD(getMessageLoop)
		gMessageLoopMain
	ENDMETHOD;

	// We use that to call some static methods in the main thread
	METHOD(callStaticMethodInThread)
		params [P_THISOBJECT, P_STRING("_className"), P_STRING("_methodName"), P_ARRAY("_parameters")];
		OOP_INFO_1("callStaticMethodInThread: %1", _this);
		CALL_STATIC_METHOD(_className, _methodName, _parameters);
	ENDMETHOD;

ENDCLASS;