#include "common.hpp"

0 spawn {

	private _storage = NEW("StorageProfileNamespace", []);

	private _allRecords = CALLM0(_storage, "getAllRecords");

	diag_log format ["All records in storage: %1", _allRecords];

	{
		diag_log format ["Erasing record: %1", _x];
		CALLM1(_storage, "eraseRecord", _x);
	} forEach _allRecords;

};