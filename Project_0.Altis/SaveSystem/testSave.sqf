#include "common.hpp"

0 spawn {

	private _storage = NEW("StorageProfileNamespace", []);

	CALLM1(_storage, "open", "vinrec0");

	if(!CALLM0(_storage, "isOpen")) exitWith {
		diag_log "Storage is not open!";
	};

	CALLM1(_storage, "save", gGameMode);

	CALLM0(_storage, "close");

};