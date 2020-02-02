#include "common.hpp"

0 spawn {

	private _storage = NEW("StorageProfileNamespace", []);

	CALLM1(_storage, "open", "vinrec0");

	if(!CALLM0(_storage, "isOpen")) exitWith {
		diag_log "Storage is not open!";
	};

	CALLM2(_storage, "save", "OOP_sessionID", call OOP_getSessionCounter);

	CALLM1(_storage, "save", gGameMode);
	CALLM2(_storage, "save", "gGameMode", gGameMode);

	CALLM0(_storage, "close");

};