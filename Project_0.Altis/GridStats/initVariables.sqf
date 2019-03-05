#include "..\OOP_Light\OOP_Light.h"

//Initializes variables neccessary for using all other ws functions
//09.08.2017
//Author: Sparker

ws_squareSize = 500;
ws_mapSizeX = 27000; //30000; //Size in meters
ws_mapSizeY = 22000; //30000;
ws_gridStartX = 2000;
ws_gridStartY = 4000;

/*
Road types for altis sorted by the width returned by fn_getRoadWidth.sqf
*/
road_width_big = 14.1; //The main road of Altis
road_width_medium = 10.1; //Medium road used in cities and between them
road_width_small = 7.2; //Dirt road

private _args = [ws_gridStartX, ws_gridStartY, ws_mapSizeX, ws_mapSizeY, ws_squareSize];
main_grid = NEW("Grid", _args);
