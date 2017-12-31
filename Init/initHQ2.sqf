//todo add separate artillery radars for sides!

diag_log "======== HQ INIT STARTED!";
globalArtilleryRadar = [] call sense_fnc_createArtilleryRadar;
//diag_log "======== HQ INIT DONE!";
globalSoundMonitor = [] call sense_fnc_createSoundMonitor;
diag_log "======== HQ INIT DONE!";

fn_highScript =
{
	while {true} do
	{
		sleep 1;
		globalSoundMonitor call sense_fnc_processSoundMonitor;
	};
};

_null = [] spawn fn_highScript;


diag_log "======== HQ INIT EXIT!";