#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\common.h"
#include "..\Location\Location.hpp"
#include "InventoryItems.hpp"
#include "PersonalInventory.hpp"
#include "..\defineCommon.inc"

/*
A class with static functions that initialized variables on objects that can have intel.
Author: Sparker 18.05.2019
*/

#define pr private

#define __INV_ITEM_DATA "__intel_inv_item"

#define OOP_CLASS_NAME UnitIntel
CLASS("UnitIntel", "")

	STATIC_VARIABLE("eventHandlerAdded");

	/*
	Method: (static)initUnit
	Call it on server.
	It initializes intel on some unit

	Parameters: _unit

	_unit - Unit object

	Returns: nil
	*/
	public STATIC_METHOD(initUnit)
		params [P_THISCLASS, P_OOP_OBJECT("_unit")];

		ASSERT_GLOBAL_OBJECT(gPersonalInventory);

		// Bail if not spawned
		if (!CALLM0(_unit, "isSpawned")) exitWith {};

		// Civilians are not having any of the intel items for now
		pr _gar = CALLM0(_unit, "getGarrison");
		pr _side = CALLM0(_gar, "getSide");
		if ( (_side == CIVILIAN) || {_side == CALLM0(gGameMode, "getPlayerSide");}) exitWith {};

		// Bail if already initialized on this unit
		pr _hO = CALLM0(_unit, "getObjectHandle");
		if (!isNil {_hO getVariable __INV_ITEM_DATA}) exitWith {
			OOP_WARNING_1("Unit intel already initialized: %1", _unit);
		};

		if (CALLM0(_unit, "isInfantry")) then {
			pr _group = CALLM0(_unit, "getGroup");
			pr _groupLeader = CALLM0(_group, "getLeader");
			// Only leaders have tablets with intel now
			if (true) then { //_unit == _groupLeader) then {
				// Get an inventory item class name
				pr _baseClass = selectRandom INTEL_INVENTORY_TABLET_CLASSES;
				pr _IDs = CALLM2(gPersonalInventory, "getInventoryClassIDs", _baseClass, 1);

				// Bail if we have failed to find a free inventory item class name
				if (count _IDs == 0) exitWith {};

				pr _gar = CALLM0(_unit, "getGarrison");
				pr _AI = CALLM0(_gar, "getAI");
				pr _dataSerial = CALLM0(_AI, "getUnitIntelDataSerial");
				CALLM3(gPersonalInventory, "setInventoryData", _baseClass, _IDs#0, _dataSerial);

				// Add to uniform
				_hO addItemToUniform PERSONAL_INVENTORY_FULL_CLASS(_baseClass, _IDs#0);

				// Set base class and class ID on the unit
				// So that we can update that later if needed
				_hO setVariable [__INV_ITEM_DATA, [_baseClass, _IDs#0]];

				// Add event handler to free the used inventory items when the unit is destroyed
				_hO addEventHandler ["Deleted", { 
					params ["_entity"];
					pr _allItems = (uniformItems _entity) + (vestItems _entity) + (backpackItems _entity);
					// Find all inventory items which are of a certain class name
					pr _personalInventoryItems = _allItems select {
						pr _fullClassName = _x;
						pr _index = INTEL_INVENTORY_ALL_CLASSES findIf {(_fullClassName find _x) == 0 };
						_index != -1
					};

					{
						pr _classAndID = CALLSM1("PersonalInventory", "getBaseClassAndID", _x);
						_classAndID params ["_baseClass", "_ID"];
						// Reset the data to return the inventory item back to the pool of free classes
						CALLM3(gPersonalInventory, "setInventoryData", _baseClass, _ID, nil);
					} forEach _personalInventoryItems;
				}];
			};
		} else {
			// Get an inventory item class name
			pr _baseClass = selectRandom INTEL_INVENTORY_TABLET_CLASSES;
			pr _IDs = CALLM2(gPersonalInventory, "getInventoryClassIDs", _baseClass, 1);

			// Bail if we have failed to find a free inventory item class name
			if (count _IDs == 0) exitWith {};

			pr _gar = CALLM0(_unit, "getGarrison");
			pr _AI = CALLM0(_gar, "getAI");
			pr _dataSerial = CALLM0(_AI, "getUnitIntelDataSerial");
			CALLM3(gPersonalInventory, "setInventoryData", _baseClass, _IDs#0, _dataSerial);

			// Add to the cargo
			_hO addMagazineCargoGlobal [PERSONAL_INVENTORY_FULL_CLASS(_baseClass, _IDs#0), 1];

			// Set base class and class ID on the unit
			// So that we can update that later if needed
			_hO setVariable [__INV_ITEM_DATA, [_baseClass, _IDs#0]];

			// Add event handler to free the used inventory items when the unit is destroyed
			_hO addEventHandler ["Deleted", { 
				params ["_entity"];
				pr _allItems = (getMagazineCargo _entity)#0;
				// Find all inventory items which are of a certain class name
				pr _personalInventoryItems = _allItems select {
					pr _fullClassName = _x;
					pr _index = INTEL_INVENTORY_ALL_CLASSES findIf {(_fullClassName find _x) == 0 };
					_index != -1
				};

				{
					pr _classAndID = CALLSM1("PersonalInventory", "getBaseClassAndID", _x);
					_classAndID params ["_baseClass", "_ID"];
					// Reset the data to return the inventory item back to the pool of free classes
					CALLM3(gPersonalInventory, "setInventoryData", _baseClass, _ID, nil);
				} forEach _personalInventoryItems;
			}];
		};

	ENDMETHOD;

	/*
	Method: (static)updateUnit
	NOT USED RIGHT NOW
	Call it on server.
	It keeps intel inventory items of some unit up to date

	Parameters: _unit

	_unit - Unit object

	Returns: nil
	*/
	public STATIC_METHOD(updateUnit)
		params [P_THISCLASS, P_OOP_OBJECT("_unit")];

		// Bail if unit doesn't have an inventory item
		if (!CALLSM1("UnitIntel", "unitHasInventoryItem", _unit)) exitWith {};

		pr _hO = CALLM0(_unit, "getObjectHandle");
		pr _classAndID = _hO getVariable __INV_ITEM_DATA;
		_classAndID params ["_invItemBaseClass", "_invItemID"];
		
		pr _gar = CALLM0(_unit, "getGarrison");
		pr _AI = CALLM0(_gar, "getAI");
		pr _dataSerial = CALLM0(_AI, "getUnitIntelDataSerial");
		CALLM3(gPersonalInventory, "setInventoryData", _invItemBaseClass, _invItemID, _dataSerial);

		// Old code which searched for all inventory items of a unit
		// Very fair but might take lot of time
		/*
		// Get all inventory items of the unit which match the pattern
		pr _hO = CALLM0(_unit, "getObjectHandle");
		
		pr _allItems = (uniformItems _hO) + (vestItems _hO) + (backpackItems _hO);
		// Find all inventory items which are of a certain class name
		pr _personalInventoryItems = _allItems select {
			pr _fullClassName = _x;
			pr _index = INTEL_INVENTORY_ALL_CLASSES findIf {(_fullClassName find _x) == 0 };
			_index != -1
		};

		// Iterate through all personal inventory items and update their values
		pr _gar = CALLM0(_unit, "getGarrison");
		pr _intelArray = CALLM0(_gar, "getIntel");
		{
			pr _classAndID = CALLSM1("PersonalInventory", "getBaseClassAndID", _x);
			_classAndID params ["_baseClass", "_ID"];
			CALLM3(gPersonalInventory, "setInventoryData", _baseClass, _ID, _intelArray);
		} forEach _personalInventoryItems;
		*/
	ENDMETHOD;

	/*
	Method: unitHasInventoryItem
	Call it on server.
	Returns true if the unit has an intel inventory item

	Parameters: _unit

	_unit - Unit object

	Returns: bool
	*/
	public STATIC_METHOD(unitHasInventoryItem)
		params [P_THISCLASS, P_OOP_OBJECT("_unit")];
		pr _hO = CALLM0(_unit, "getObjectHandle");

		!(isNil {_hO getVariable __INV_ITEM_DATA})
	ENDMETHOD;

	/*
	Method: (static)initPlayer
	Call it on player's computer when he respawns to to add actions to player to take intel items

	Parameters: _hO

	_hO - player's object

	Returns: nil
	*/
	public STATIC_METHOD(initPlayer)
		params [P_THISCLASS];

		//diag_log "--- initPlayer";

		//player removeAllEventHandlers "InventoryOpened";
		if (! GETSV(_thisClass, "eventHandlerAdded") || !isMultiplayer) then { // In singleplayer event handler doesn't get magically on respawn transfered :/

			//diag_log "--- adding event handler";

			
			// Old code which would examing intel when player would double click it
			player addEventHandler ["InventoryOpened", 
			{

				diag_log "--- Inventory opened event handler!";

				[{!isNull (findDisplay 602)}, {
					
					{ // forEach [619, 633, 638];

						(finddisplay 602 displayctrl _x) ctrlAddEventHandler ["LBDblClick", {

							params ["_control", "_selectedIndex"];
							_data = _control lbData _selectedIndex;
							diag_log format ["Dbl click: index: %1, data: %2", _selectedIndex, _data];
							
							// Check if the class name of this item belongs to one of the predefined class names
							pr _index = INTEL_INVENTORY_ALL_CLASSES findIf {
								(_data find _x) == 0
							};

							pr _deleteItem = false;

							if (_index != -1) then { // If it's the document item, delete it and 'inspect' it
								// Call code to inspect the intel item
								CALLSM1("UnitIntel", "inspectIntel", _data);
								_deleteItem = true;
							}; // if (_data == ...)

							if (_data == "vin_pills") then {
								CALL_COMPILE_COMMON("UI\Notification\trip.sqf");
								_deleteItem = true;
							};

							// If item deletion was requested
							if (_deleteItem) then {
								[{ // call CBA_fnc_waitAndExecute
									params ["_IDC", "_data"];
									//diag_log format ["Inside waitAndExecute: %1", _this];
									switch (_IDC) do {
										case 619: {diag_log "Backpack"; player removeItemFromBackpack _data;};
										case 633: {diag_log "Uniform"; player removeItemFromUniform _data;};
										case 638: {diag_log "Vest"; player removeItemFromVest _data;};
									};
								}, [ctrlIDC _control, _data], 0] call CBA_fnc_waitAndExecute; // Can't remove the item right in this frame because it will crash the game
							};

						} ]; // ctrlAddEventHandler

					} forEach [619, 633, 638]; // These are IDCs of the uniform, vest and backpack containers

				}, []] call CBA_fnc_waitUntilAndExecute;

			}]; // Add event handler
			
			// 633 - uniform
			// 619 - backpack
			// 638 - vest

			


			private _ehid = player addEventHandler ["Take", 
			{
				params ["_unit", "_container", "_item"];

				// Check if the class name of this item belongs to one of the predefined class names
				pr _index = INTEL_INVENTORY_ALL_CLASSES findIf {
					(_item find _x) == 0
				};

				if (_index != -1) then { // If it's the document item, delete it and 'inspect' it
					// Deinitialize this _containter
					_container setVariable [__INV_ITEM_DATA, nil, true]; // todo Erase the varibalbe globally, we should only erase it on server.. but maybe another time

					// Call code to inspect the intel item
					CALLSM1("UnitIntel", "inspectIntel", _item);

					// Delete this document item from inventory
					[{ // call CBA_fnc_waitAndExecute
						params ["_item"];
						//diag_log format ["Inside waitAndExecute: %1", _this];
						player removeItemFromBackpack _item;
						player removeItemFromUniform _item;
						player removeItemFromVest _item;
					}, [_item], 0] call CBA_fnc_waitAndExecute; // Can't remove the item right in this frame because it will crash the game
				
				};
			}];
			player setVariable ["UnitIntel_take_EH", _ehid];

			SETSV("UnitIntel", "eventHandlerAdded", true);
		};
		
	ENDMETHOD;

	// Called on player's computer when he picks up the intel item
	STATIC_METHOD(inspectIntel)
		params [P_THISOBJECT, P_STRING("_fullClassName") ];

		// Get base class name and ID of this intel item
		pr _classAndID = CALLSM1("PersonalInventory", "getBaseClassAndID", _fullClassName);
		_classAndID params ["_baseClass", "_ID"];

		// Tell to commander! He must know about it :D !
		pr _playerCommander = CALLSM1("AICommander", "getAICommander", playerSide);
		//CALLM2(_playerCommander, "postMethodAsync", "getRandomIntelFromEnemy", [clientOwner]);
		CALLM2(_playerCommander, "postMethodAsync", "getIntelFromInventoryItem", [_baseClass ARG _ID ARG clientOwner]);
		//REMOTE_EXEC_CALL_METHOD(_playerCommander, "getIntelFromInventoryItem", [_baseClass ARG _ID ARG clientOwner], 2);

		private _inst = CALLSM0("TacticalTablet", "newInstance");

		// Make us some time while we are waiting for server response...
		pr _endl = toString [13,10];
		CALLM2(_inst,"appendTextDelay", "Welcome to TactiCool OS v28.3!" + _endl + "Detected 128 GB RAM, 16 TB SSD" + _endl, 0.1);
		pr _text = format ["System date: %1, grid: %2" + _endl, date call misc_fnc_dateToISO8601, mapGridPosition player];
		CALLM2(_inst,"appendTextDelay", _text, 0.2);
		pr _text = format ["User class: %1" + _endl, typeof player];
		CALLM2(_inst,"appendTextDelay", _text, 0.06);
		pr _text = format ["Primary weapon: %1" + _endl, primaryWeapon player];
		CALLM2(_inst,"appendTextDelay", _text, 0.06);
		pr _text = format ["Secondary weapon: %1" + _endl, secondaryWeapon player];
		CALLM2(_inst,"appendTextDelay", _text, 0.06);
		pr _text = format ["Dammage: %1 percent" + _endl, round ((damage player)*100)];
		CALLM2(_inst,"appendTextDelay", _text, 0.05);

		CALLM2(_inst,"appendTextDelay", _endl + "Tip of the day:" + _endl,  0.1 + random 0.2);
		CALLM2(_inst,"appendTextDelay", selectrandom gCombatTips, 0);
		CALLM2(_inst,"appendTextDelay", _endl, 0);

		CALLM2(_inst,"appendTextDelay", _endl + "Connecting to TactiCommNetwork server..." + _endl,  0.15 + random 0.2);
		CALLM2(_inst,"appendTextDelay", "Tx SYN" + _endl,  0.2 + random 0.2);
		CALLM2(_inst,"appendTextDelay", "Rx SYN-ACK" + _endl + "Tx ACK" + _endl,  0.2 + random 0.2);
		//CALLM2(_inst,"appendTextDelay", ".", 0.3);
		//CALLM2(_inst,"appendTextDelay", ".", 0.3);
		//CALLM2(_inst,"appendTextDelay", ".", 0.1);
		CALLM2(_inst,"appendTextDelay", "Tx RQ-DATA" + _endl, 0.2);
		CALLM2(_inst,"appendTextDelay", "Rx INTEL_CMDR_ACTION" + _endl, 0.2);
		CALLM2(_inst,"appendTextDelay", _endl + "Connection established!" + _endl, 0.1);

		CALLM2(_inst, "setTextDelay", "Logged in Altis Armed Forces TactiCommNetWork" + _endl, 0.4);
		pr _text = format ["System date: %1" + _endl, date call misc_fnc_dateToISO8601];
		CALLM2(_inst, "appendTextDelay", _text, 0.1);

		/*
		pr _intelDataSerial = CALLM2(gPersonalInventory, "getInventoryData", _baseClass, _ID);
		{
			CALLM2(_inst,"appendTextDelay", str _x, 0);
			CALLM2(_inst,"appendTextDelay", "\n", 0);
		} forEach _intelDataSerial;
		*/

	ENDMETHOD;

ENDCLASS;

SETSV("UnitIntel", "eventHandlerAdded", false);