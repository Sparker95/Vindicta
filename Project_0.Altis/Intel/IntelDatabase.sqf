#include "..\OOP_Light\OOP_Light.h"
#include "..\CriticalSection\CriticalSection.hpp"

/*
Class: IntelDatabase

All methods are atomic, there is no threading involved in this class.
Just call the methods to perform actions.

Author: Sparker 06.05.2019 
*/

#define pr private

CLASS("IntelDatabase", "")

	VARIABLE("items");
	VARIABLE("linkedItems"); // A hash map of linked items
	VARIABLE("side");

	/*
	Method: new

	Parameters: _side

	_side - side to which this DB is attached to
	*/
	METHOD("new") {
		params [P_THISOBJECT, P_SIDE("_side")];

		T_SETV("side", _side);
		pr _namespace = [false] call CBA_fnc_createNamespace;
		T_SETV("linkedItems", _namespace);
	} ENDMETHOD;

	/*
	Method: addIntel
	Adds item to the database

	Parameters: _item

	_item - <Intel> item

	Returns: nil
	*/
	METHOD("addIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			// Add to the array of items
			T_GETV("items") pushBack _item;

			// Add link from the source to this item
			pr _source = GETV(_item, "source");
			// If the intel item is linked to the source intel item, add the source to hashmap
			if (!isNil "_source") then {
				pr _hashmap = T_GETV("linkedItems");
				_hashMap setVariable [_source, _thisObject];
			};
		};
	} ENDMETHOD;

	/*
	Method: updateIntel
	Updates item in this database from another item

	Parameters: _itemOriginal, _itemNew

	_itemOriginal - <Intel> object in this database to update
	_itemNew - <Intel> object from which to get new values

	Returns: nil
	*/
	METHOD("updateIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_itemOriginal"), P_OOP_OBJECT("_itemNew")];

			pr _items = T_GETV("items");
			if (_itemOriginal in _items) then { // Make sure we have this intel item
				// Backup the source so that it doesn't get overwritten in update
				pr _prevSource = GETV(_itemOriginal, "source");
				
			};
		};
	} ENDMETHOD;

	/*
	Method: updateIntelFromSource
	Updates an intel item in this database from a source intel item, if there is an intel item linked to such source item.

	Parameters: _srcItem

	_srcItem - the <Intel> item to update

	Returns: Bool, true if the item was updated, false if the item with given source doesn't exist in this database.
	*/
	METHOD("updateIntelFromSource") {
		pr _return = false;
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_srcItem")];

			// Check if we have an item with given source
			pr _hashmap = T_GETV("linkedItems");
			pr _item = _hashmap getVariable _srcItem;
			if (isNil "_item") then {
				_return = false;
			} else {
				CALLM2(_thisObject, "updateIntel", _item, _srcItem);
				ASSIGN(_item, _srcItem); // Copy all variables
				_return = true;
			};
		};
		_return
	} ENDMETHOD;

	METHOD("queryItems") {

	} ENDMETHOD;

	/*
	Method: getAllItems
	Returns all items in the database

	Returns: array of items
	*/
	METHOD("getAllItems") {
		params [P_THISOBJECT];
		+T_GETV("items")
	} ENDMETHOD;

	/*
	Method: deleteItem
	Deletes an item from this database. Doesn't delete the item object from memory.

	Parameters: _item

	_item - the <Intel> item to delete

	Returns: nil
	*/
	METHOD("deleteItem") {
		params [P_THISOBJECT, P_OOP_OBJECT("_item")];
	} ENDMETHOD;

ENDCLASS;