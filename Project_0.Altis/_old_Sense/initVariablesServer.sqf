mortarClassnames = ["rhsusf_m109d_usarmy",	"rhsusf_m109_usarmy",	"RHS_M119_WD",
					"RHS_M252_WD",			"RHS_M252_USMC_WD",		"RHS_M252_USMC_D",
					"B_MBT_01_arty_F",		"B_MBT_01_mlrs_F",		"RHS_M119_D",
					"RHS_M252_D",			"B_Mortar_01_F",		"rhs_D30_at_msv",
					"O_Mortar_01_F",		"O_MBT_02_arty_F",		"rhs_D30_msv",
					"rhs_2b14_82mm_msv",	"rhs_2s3_tv",			"rhs_D30_vdv",
					"I_Mortar_01_F"];

/*
globalArtilleryRadar = [] call sense_fnc_artilleryRadar_create;
globalSoundMonitor = [] call sense_fnc_soundMonitor_create;
globalEnemyMonitor = [] call sense_fnc_enemyMonitor_create;
*/

sense_artilleryRadarEast = [] call sense_fnc_artilleryRadar_create;
sense_soundMonitorEast = [] call sense_fnc_soundMonitor_create;
sense_enemyMonitorEast = [] call sense_fnc_enemyMonitor_create;

sense_artilleryRadarWest = [] call sense_fnc_artilleryRadar_create;
sense_soundMonitorWest = [] call sense_fnc_soundMonitor_create;
sense_enemyMonitorWest= [] call sense_fnc_enemyMonitor_create;

sense_artilleryRadarInd = [] call sense_fnc_artilleryRadar_create;
sense_soundMonitorInd = [] call sense_fnc_soundMonitor_create;
sense_enemyMonitorInd = [] call sense_fnc_enemyMonitor_create;