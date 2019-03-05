#define pr private

pr _catDefense = [
	// format: Classname, Display name string
	["Land_HBarrier_01_big_4_green_F", "H-Barrier 1x4 L"],
	["Land_HBarrier_01_line_1_green_F", "H-Barrier Block"],
	["Land_HBarrier_01_line_5_green_F", "H-Barrier Long"],
	["Land_HBarrier_01_line_3_green_F", "H-Barrier Short"],
	["Land_HBarrier_01_wall_corridor_green_F", "H-Barrier Corridor"],
	["Land_HBarrier_01_wall_corner_green_F", "H-Barrier Corner"],
	["Land_HBarrier_01_wall_6_green_F", "H-Barrier Wall L"],
	["Land_HBarrier_01_wall_4_green_F", "H-Barrier Wall S"],
	["Land_HBarrier_01_big_tower_green_F", "H-Barrier Tower"]
];

pr _catLights = [
	// format: Classname, Display name string
	["Land_PortableLight_double_F", "Portable Floodlight"],
	["PortableHelipadLight_01_white_F", "White Helipad Light"],
	["PortableHelipadLight_01_green_F", "Green Helipad Light"],
	["PortableHelipadLight_01_red_F", "Red Helipad Light"],
	["Land_Camping_Light_F", "Camping Light"]
];

// array of categories and category names
g_BuildUIObjects = [

[_catLights, "Lights"], 
[_catDefense, "Fortification"]

];