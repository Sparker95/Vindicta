#include "common.hpp"

0 spawn {

	private _storage = NEW("StorageProfileNamespace", []);

	CALLM1(_storage, "open", "vinrec0");

	if(!CALLM0(_storage, "isOpen")) exitWith {
		diag_log "Storage is not open!";
	};

	// Load OOP session ID and increase it
	private _sessionID = CALLM1(_storage, "load", "OOP_sessionID");
	[_sessionID+1] call OOP_setSessionCounter;

	gGameMode = CALLM1(_storage, "load", "gGameMode");
	CALLM1(_storage, "load", gGameMode);
	PUBLIC_VARIABLE "gGameMode";

	CALLM0(_storage, "close");

};