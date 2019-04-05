ws_fnc_newGridArray = compile preprocessFileLineNumbers "GridStats\functions\fn_newGridArray.sqf";
ws_fnc_copyGrid = compile preprocessFileLineNumbers "GridStats\functions\fn_copyGrid.sqf";
ws_fnc_plotGrid = compile preprocessFileLineNumbers "GridStats\functions\fn_plotGrid.sqf";
ws_fnc_plotDirGrid = compile preprocessFileLineNumbers "GridStats\functions\fn_plotDirGrid.sqf";
ws_fnc_unplotGrid = compile preprocessFileLineNumbers "GridStats\functions\fn_unplotGrid.sqf";
ws_fnc_markersToGridArray = compile preprocessFileLineNumbers "GridStats\functions\fn_markersToGridArray.sqf";
ws_fnc_addGrid = compile preprocessFileLineNumbers "GridStats\functions\fn_addGrid.sqf";
ws_fnc_subGrid = compile preprocessFileLineNumbers "GridStats\functions\fn_subGrid.sqf";

//Get value
ws_fnc_getValue = compile preprocessFileLineNumbers "GridStats\functions\fn_getValue.sqf";
ws_fnc_getValueID = compile preprocessFileLineNumbers "GridStats\functions\fn_getValueID.sqf";
ws_fnc_getSmoothValueID = compile preprocessFileLineNumbers "GridStats\functions\fn_getSmoothValueID.sqf";
ws_fnc_getEdgeValueID = compile preprocessFileLineNumbers "GridStats\functions\fn_getEdgeValueID.sqf";
ws_fnc_getEdgeDirID = compile preprocessFileLineNumbers "GridStats\functions\fn_getEdgeDirID.sqf";
ws_fnc_getZeroCrossingValueID = compile preprocessFileLineNumbers "GridStats\functions\fn_getZeroCrossingValueID.sqf";

//Set value
ws_fnc_setValue = compile preprocessFileLineNumbers "GridStats\functions\fn_setValue.sqf";
ws_fnc_setValueID = compile preprocessFileLineNumbers "GridStats\functions\fn_setValueID.sqf";
ws_fnc_setValueAll = compile preprocessFileLineNumbers "GridStats\functions\fn_setValueAll.sqf";

//Change value
ws_fnc_addValue = compile preprocessFileLineNumbers "GridStats\functions\fn_addValue.sqf";
ws_fnc_addValueID = compile preprocessFileLineNumbers "GridStats\functions\fn_addValueID.sqf";

//Filtering functions
ws_fnc_filterEdge = compile preprocessFileLineNumbers "GridStats\functions\fn_filterEdge.sqf";
ws_fnc_filterEdgeDir = compile preprocessFileLineNumbers "GridStats\functions\fn_filterEdgeDir.sqf";
ws_fnc_filterSmooth = compile preprocessFileLineNumbers "GridStats\functions\fn_filterSmooth.sqf";
ws_fnc_filterZeroCrossing = compile preprocessFileLineNumbers "GridStats\functions\fn_filterZeroCrossing.sqf";
ws_fnc_filterThreshfunctions = compile preprocessFileLineNumbers "GridStats\functions\fn_filterThreshold.sqf";

//Functions related with roads
ws_fnc_getRandomPosOnRoad = compile preprocessFileLineNumbers "GridStats\functions\fn_getRandomPosOnRoad.sqf";
ws_fnc_getRoadWidth = compile preprocessFileLineNumbers "GridStats\functions\fn_getRoadWidth.sqf";
ws_fnc_getRoadLength = compile preprocessFileLineNumbers "GridStats\functions\fn_getRoadLength.sqf";
ws_fnc_findRoadblockRoads = compile preprocessFileLineNumbers "GridStats\functions\fn_findRoadblockRoads.sqf";
ws_fnc_findRoadblockPos = compile preprocessFileLineNumbers "GridStats\functions\fn_findRoadblockPos.sqf";
ws_fnc_putRoadblockMarkersAtFrontline = compile preprocessFileLineNumbers "GridStats\functions\fn_putRoadblockMarkersAtFrontline.sqf";
ws_fnc_sortRoadsByWidth = compile preprocessFileLineNumbers "GridStats\functions\fn_sortRoadsByWidth.sqf";
