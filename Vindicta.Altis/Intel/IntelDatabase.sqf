#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\common.h"
#include "..\CriticalSection\CriticalSection.hpp"

/*
Class: IntelDatabase

All methods are atomic, there is no threading involved in this class.
Just call the methods to perform actions.

Author: Sparker 06.05.2019 
*/

#define pr private

#define OOP_CLASS_NAME IntelDatabase
CLASS("IntelDatabase", "Storable");

				VARIABLE("items");							// Hash map for refs of items added here
				VARIABLE("linkedItems");					// A hash map of linked items
	/* save */	VARIABLE_ATTR("side", [ATTR_SAVE]);			// Side
				VARIABLE("variables");						// A hash map for variable
	/* save */	VARIABLE_ATTR("savedItems", [ATTR_SAVE]);	// Array with all items we have. Only for saving.

	/*
	Method: new

	Parameters: _side

	_side - side to which this DB is attached to
	*/
	METHOD(new)
		params [P_THISOBJECT, P_SIDE("_side")];

		OOP_INFO_1("NEW, side: %1", _side);
		T_SETV("side", _side);

		T_CALLM0("_initHashmaps");
	ENDMETHOD;

	// Initializes hashmaps
	METHOD(_initHashmaps)
		params [P_THISOBJECT];
				
		#ifndef _SQF_VM
		pr _namespaceLinked = [false] call CBA_fnc_createNamespace;
		pr _namespaceItems = [false] call CBA_fnc_createNamespace;
		pr _namespaceVariables = [false] call  CBA_fnc_createNamespace;
		#else
		pr _namespaceLinked = "Dummy" createVehicle [0, 0, 0];
		pr _namespaceItems = "Dummy" createVehicle [0, 0, 0];
		pr _namespaceVariables = "Dummy" createVehicle [0, 0, 0];
		#endif
		T_SETV("linkedItems", _namespaceLinked);
		T_SETV("items", _namespaceItems);
		T_SETV("variables", _namespaceVariables);
	ENDMETHOD;

	/*
	Method: addIntel
	Adds item to the database

	Parameters: _item

	_item - <Intel> item

	Returns: nil
	*/
	public virtual METHOD(addIntel)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			OOP_INFO_1("ADD INTEL: %1", _item);
			FIX_LINE_NUMBERS()
			pr _items = T_GETV("items");

			// Add to index
			CALLM1(_item, "addToDatabaseIndex", _thisObject);

			// Add link from the source to this item
			pr _source = GETV(_item, "source");
			// If the intel item is linked to the source intel item, add the source to hashmap
			if (!isNil "_source") then {
				// If the source is specified, make sure we don't overwrite an existing source in the hashmap
				OOP_INFO_2("  source intel of %1: %2", _item, _source);

				pr _linkedItems = T_GETV("linkedItems");
				if (isNil {_linkedItems getVariable _source}) then {
					_linkedItems setVariable [_source, _item];
					_items setVariable [_item, 1]; // Add to the hashmap of  existing items
				} else {
					// This source is already set in the hashmap, make an error!
					OOP_ERROR_1("There is already an intel item linked to source item: %1", _source);
				};
			} else {
				// If there is no source specified, just add it
				_items setVariable [_item, 1]; // Add to the hashmap of  existing items
			};
		};
	ENDMETHOD;

	/*
	Method: updateIntel
	Updates item in this database from another item

	Parameters: _itemDest, _itemSrc

	_itemDest - <Intel> object in this database to update
	_itemSrc - <Intel> object from which to get new values

	Returns: nil
	*/
	public virtual METHOD(updateIntel)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_itemDst"), P_OOP_OBJECT("_itemSrc")];

			OOP_INFO_2("UPDATE INTEL: %1 from %2", _itemDst, _itemSrc);

			pr _items = T_GETV("items");
			if (! isNil {_items getVariable _itemDst}) then { // Make sure we have this intel item
				// Update index before copying values
				CALLM2(_itemDst, "updateDatabaseIndex", _thisObject, _itemSrc);

				// Backup the source so that it doesn't get overwritten in update
				pr _prevSource = GETV(_itemDst, "source");
				UPDATE_VIA_ATTR(_itemDst, _itemSrc, ATTR_SERIALIZABLE); // Copy all variables that are not nil in itemSrc
				// Restore the source
				if (!isNil "_prevSource") then {
					SETV(_itemDst, "source", _prevSource);
				};
			};
		};
	ENDMETHOD;

	/*
	Method: updateIntelFromSource
	Updates an intel item in this database from a source intel item, if there is an intel item linked to such source item.

	Parameters: _srcItem

	_srcItem - the <Intel> item to update from

	Returns: Bool, true if the item was updated, false if the item with given source doesn't exist in this database.
	*/
	public METHOD(updateIntelFromSource)
		pr _return = false;
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_srcItem")];

			OOP_INFO_1("UPDATE INTEL FROM SOURCE: %1", _srcItem);

			// Check if we have an item with given source
			pr _linkedItems = T_GETV("linkedItems");
			pr _item = _linkedItems getVariable _srcItem;
			if (isNil "_item") then {
				OOP_WARNING_1("Intel with given source was not found in database: %1", _srcItem);
				_return = false;
			} else {
				T_CALLM2("updateIntel", _item, _srcItem);
				_return = true;
			};
		};
		_return
	ENDMETHOD;

	/*
	Method: addIntelClone
	Adds item to the database and returns a modifiable clone.
	Don't modify _item after passing it in, modify the clone instead.
	Parameters: _item

	_item - <Intel> item

	Returns: clone of _item that can be used in further updateIntelFromClone operations.
	*/
	public METHOD(addIntelClone)
		params [P_THISOBJECT, P_OOP_OBJECT("_item")];

		pr _clone = CLONE(_item);
		SETV(_clone, "dbEntry", _item);
		SETV(_clone, "db", _thisObject);
		OOP_INFO_2("ADD INTEL CLONE: intel: %1, clone: %2", _item, _clone);

		CRITICAL_SECTION {
			// Add to index
			CALLM1(_item, "addToDatabaseIndex", _thisObject);

			// Add to the array of items
			pr _items = T_GETV("items");
			_items setVariable [_item, 1];

#ifdef OOP_ASSERT
			// Add link from the source to this item
			pr _source = GETV(_item, "source");
			// If the intel item is linked to the source intel item, add the source to hashmap
			if (!isNil "_source") then {
				FAILURE("Use addIntel for intel items from other sources, addIntelClone is only for cmdrs own intel!")
			};
#endif
		};

		_clone
	ENDMETHOD;

	/*
	Method: updateIntelFromClone
	Updates item in this database from a modified clone previously returned by addIntelClone

	Parameters: _item

	_item - <Intel> object returned by addIntelClone.

	Returns: nil
	*/
	public METHOD(updateIntelFromClone)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			OOP_INFO_1("UPDATE INTEL FROM CLONE: %1", _item);

			pr _dbEntry = GETV(_item, "dbEntry");
			ASSERT_OBJECT(_dbEntry);

			T_CALLM("updateIntel", [_dbEntry ARG _item]);
		};
		nil
	ENDMETHOD;

	/*
	Method: removeIntelForClone
	Deletes an item from this database. Doesn't delete the item object from memory.

	Parameters: _item

	_item - the <Intel> item to delete

	Returns: nil
	*/
	public METHOD(removeIntelForClone)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			pr _dbEntry = GETV(_item, "dbEntry");
			ASSERT_OBJECT(_dbEntry);
			OOP_INFO_MSG("REMOVE INTEL FOR CLONE: item: %1, db entry: %2", [_item ARG _dbEntry]);

			T_CALLM1("removeIntel", _dbEntry);
		};
		nil
	ENDMETHOD;


	/*
	Method: queryIntel
	Returns an array of <Intel> objects in this database that match a query.
	The algorithm checks if all non-nil member variables of _queryItem are equal to the same member variables in 

	!! WARNING !! It is VERY SLOW! It's probably only ok to use this for rare one-time events. Consider indexed queries with getFromIndex method for everything else.

	Parameters: _queryItem

	_queryItem - the <Intel> object

	Returns: Array of <Intel> objects
	*/
	/*
	METHOD(queryIntel)
		pr _array = [];
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_queryItem")];

			pr _className = GET_OBJECT_CLASS(_queryItem);
			pr _memList = GET_CLASS_MEMBERS(_className); // First variable in member list is always class name!

			pr _items = allVariables T_GETV("items");
			_array = _items select {
				pr _dbItem = _x;
				pr _index = _memList findIf {
					_x params ["_varName"];
					pr _queryValue = _GETV(_queryItem, _varName);
					pr _dbValue = _GETV(_dbItem, _varName);
					!(isNil "_queryValue") && !([_queryValue] isEqualTo [_dbValue]) // Variable exists in query and is not equal to the var in db, or var in db is nil
				};
				//pr _valueprint = if (_index != -1) then {_memList select _index} else {"nothing"};
				//diag_log format ["Database item: %1, index: %2, variable: %3", _dbItem, _index, _valueprint];
				_index == -1 // We didn't find mismatched variables that exist in query
			};
		};
		_array
	ENDMETHOD;
	*/

	/*
	Method: findFirstIntel
	Same as queryIntel, but returns the first item to match the query. Can speed up lookup if you already know that there is only one item you need.

	!! WARNING !! It is VERY SLOW! It's probably only ok to use this for rare one-time events. Consider indexed queries with getFromIndex method for everything else.

	Parameters: _queryItem

	_queryItem - the <Intel> object

	Returns: <Intel> object or "" if such object was not found
	*/
	/*
	METHOD(findFirstIntel)
		pr _return = "";
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_queryItem")];

			pr _className = GET_OBJECT_CLASS(_queryItem);
			pr _memList = GET_CLASS_MEMBERS(_className); // First variable in member list is always class name!

			pr _items = allVariables T_GETV("items");
			_index = _items findIf {
				pr _dbItem = _x;
				_memList findIf {
					_x params ["_varName"];
					pr _queryValue = _GETV(_queryItem, _varName);
					pr _dbValue = _GETV(_dbItem, _varName);
					!(isNil "_queryValue") && !([_queryValue] isEqualTo [_dbValue]) // Variable exists in query and is not equal to the var in db, or var in db is nil
				} == -1 // We didn't find mismatched variables that exist in query
			};
			if (_index != -1) then { _return = _items select _index; };
		};
		_return
	ENDMETHOD;
	*/

	/*
	Method: isIntelAdded
	Returns true if given <Intel> object exists in this intel database

	Parameters: _item

	_item - the <Intel> object

	Returns: Bool
	*/
	public METHOD(isIntelAdded)
		params [P_THISOBJECT, P_OOP_OBJECT("_item")];

		!isNil {T_GETV("items") getVariable _item}
	ENDMETHOD;

	/*
	Method: isIntelAddedFromSource
	Returns true if given <Intel> object is a source of an existing <Intel> object in this database

	Parameters: _item

	_item - the <Intel> object

	Returns: Bool
	*/
	public METHOD(isIntelAddedFromSource)
		params [P_THISOBJECT, P_OOP_OBJECT("_item")];

		!isNil { T_GETV("linkedItems") getVariable _item }
	ENDMETHOD;

	/*
	Method: getIntelFromSource
	Returns an existing <Intel> object in this database which is sourced by the given <Intel> object 

	Parameters: _item

	_item - the <Intel> object

	Returns: <Intel> object or "" if such there is no object sourced by the passed object
	*/
	public METHOD(getIntelFromSource)
		params [P_THISOBJECT, P_OOP_OBJECT("_item")];

		pr _return = T_GETV("linkedItems") getVariable [_item, ""];
		
		OOP_INFO_2("GET INTEL FROM SOURCE: %1, result: %2", _item, _return);

		_return
	ENDMETHOD;

	/*
	Method: getAllIntel
	Returns all items in the database

	Returns: array of items
	*/
	public METHOD(getAllIntel)
		params [P_THISOBJECT];
		pr _items = T_GETV("items");
		// If we nil a variable in hashmap, allvariables hashmap still returns this variable name!
		// So we must select variables which are not nil
		(allVariables _items) select { !isNil {_items getVariable _x} }
	ENDMETHOD;

	/*
	Method: removeIntel
	Deletes an item from this database. Doesn't delete the item object from memory.

	Parameters: _item

	_item - the <Intel> item to delete

	Returns: nil
	*/
	public virtual METHOD(removeIntel)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			OOP_INFO_1("REMOVE INTEL: %1", _item);

			pr _items = T_GETV("items");

			// Remove from index
			CALLM1(_item, "removeFromDatabaseIndex", _thisObject);

			// Remove the item from items hashmap
			_items setVariable [_item, nil];

			// Check if the item was linked to a source item
			// If it was, then remove the source item from hashmap too
			pr _itemSource = GETV(_item, "source");
			if (!isNil "_itemSource") then {
				OOP_INFO_2("  source item of item %1: %2", _item, _itemSource);
				T_GETV("linkedItems") setVariable [_itemSource, nil];
			};
		};
		nil
	ENDMETHOD;


	// = = = = = = = = = I N D E X   M E T H O D S = = = = = = = = = =

	public METHOD(addToIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_item"), P_STRING("_varName"), P_STRING("_varValue")];

		pr _variablesHashmap = T_GETV("variables");

		pr _valuesHashmap = _variablesHashmap getVariable _varName;

		// If the hashmap for this variable doesn't exist, then create it
		if (isNil "_valuesHashmap") then {
			_valuesHashmap = [false] call  CBA_fnc_createNamespace;
			_variablesHashmap setVariable [_varName, _valuesHashmap];
		};

		// Convert value to string if needed
		pr _varValueStr = if (_varValue isEqualType "") then {
			_varValue
		} else {
			str _varValue
		};

		if (_varValue == "") then {
			ADE_dumpCallStack;
		};

		pr _refsArray = _valuesHashmap getVariable _varValueStr; // Array with intel objects which reference this _varValue
		if (isNil "_refsArray") then {
			_refsArray = [];
			_valuesHashmap setVariable [_varValueStr, _refsArray];
		};
		_refsArray pushBack _item;

	ENDMETHOD;

	public METHOD(removeFromIndex)
		params [P_THISOBJECT, P_OOP_OBJECT("_item"), P_STRING("_varName"), "_varValue"];

		pr _variablesHashmap = T_GETV("variables");

		pr _valuesHashmap = _variablesHashmap getVariable _varName;

		// If the hashmap for this variable doesn't exist, then create it
		if (isNil "_valuesHashmap") then {
			_valuesHashmap = [false] call  CBA_fnc_createNamespace;
			_variablesHashmap setVariable [_varName, _valuesHashmap];
		};

		// Convert value to string if needed
		pr _varValueStr = if (_varValue isEqualType "") then {
			_varValue
		} else {
			str _varValue
		};
		pr _refsArray = _valuesHashmap getVariable _varValueStr; // Array with intel objects which reference this _varValue
		if (isNil "_refsArray") then {
			_refsArray = [];
			_valuesHashmap setVariable [_varValueStr, _refsArray];
		} else {
			_refsArray deleteAt (_refsArray find _varValue);
		};

	ENDMETHOD;

	public METHOD(getFromIndex)
		params [P_THISOBJECT, P_STRING("_varName"), "_varValue"];

		pr _variablesHashmap = T_GETV("variables");

		pr _valuesHashmap = _variablesHashmap getVariable _varName;

		// If the hashmap for this variable doesn't exist, return an empty array
		if (isNil "_valuesHashmap") exitWith {
			[]
		};

		// Convert value to string if needed
		pr _varValueStr = if (_varValue isEqualType "") then {
			_varValue
		} else {
			str _varValue
		};
		pr _refsArray = _valuesHashmap getVariable _varValueStr; // Array with intel objects which reference this _varValue
		
		if (isNil "_refsArray") exitWith {
			[]
		};
		
		_refsArray
	ENDMETHOD;

	// - - - - STORAGE - - - - -

	public override METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Save all intel objects we have
		pr _allIntel = T_CALLM0("getAllIntel");
		{
			pr _intel = _x;
			CALLM1(_storage, "save", _intel);
		} forEach _allIntel;

		T_SETV("savedItems", +_allIntel);

		true
	ENDMETHOD;

	public override METHOD(postSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		T_SETV("savedItems", nil);	// Erase the temporary variable
		true
	ENDMETHOD;

	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Reinitialize all our hashmaps
		T_CALLM0("_initHashmaps");

		// Load all intel and readd it
		pr _allIntel = T_GETV("savedItems");
		{
			pr _intel = _x;
			CALLM1(_storage, "load", _intel);
			T_CALLM1("addIntel", _intel);
		} forEach _allIntel;

		T_SETV("savedItems", nil);	// Erase the temporary variable

		true
	ENDMETHOD;

ENDCLASS;

// - - - TESTS - - - 
#ifdef _SQF_VM

["IntelDatabase.save and load", {
	private _db = NEW("IntelDatabase", [EAST]);
	pr _createdIntel = [];

	for "_i" from 0 to 3 do {
		private _intel = NEW("Intel", []);
		SETV(_intel, "method", _i);
		CALLM1(_db, "addIntel", _intel);
		_createdIntel pushBack _intel;
	};

	pr _storage = NEW("StorageProfileNamespace", []);
	CALLM1(_storage, "open", "testRecordInteldb");
	CALLM1(_storage, "save", _db);
	DELETE(_db);
	{
		DELETE(_x);
	} forEach _createdIntel;
	CALLM1(_storage, "load", _db);

	["Object loaded", GETV(_db, "side") == EAST ] call test_Assert;

	["Database intel loaded", GETV(_createdIntel#1, "method") == 1] call test_Assert;

	true
}] call test_AddTest;

#endif