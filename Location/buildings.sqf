/*
Building positions suitable for for specific roles.

Each building position is structered:
	[_buildingPosID, _direction]
		_buildingPosID - number of the building position returned by buildingPos command.
		_direction - hte direction where the unit must be heading relative to the building's position.
	OR it can be specified in cylindrical coordinates relative to building's center:
	[_offset, _offsetDirection, _offsetHeight, _direction]
		_offset - the magnitude of the offset projected onto horizontal plane.
		_offsetDirection - the direction of the offset.
		_offsetHeight - the height of the offset.
		_direction - direction where the unit must be heading relative to the building's position.

The structure of each array with positions for specific type is:
	[[_typesArray, _positionArray], [_typesArray, _positionArray], ...]
		_typesArray - the array of types (typeOf ...) of this building sharing the same building positions. For example, different variants of the same watchtower.
		_positioArray - the array of positions in the form [_buildingPosID, _direction] or [_offset, _offsetDirection, _offsetHeight, _direction]
*/

//Positions where a high GMG or a high HMG can be placed and operated from.
loc_bp_HGM_GMG_high =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		[[11, 90], [13, 0], [14, 0], [16, 180], [17, 180]]
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		[[1.9, 220, 4.4, 180], [1.9, 130, 4.4, 180]]
	]

	/*
	[ //The military HQ
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		[[4, 90], [5, 0], [6, -45], [7, 225], [8, 180]]
	]
	*/
];

//Positions where soldiers can freely shoot from.
//Note that soldiers can also shoot well from HMG positions.
loc_bp_sentry =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		[[10, 180], [12, 0], [15, 270], [2, 0], [4, 180], [7, 90], [8, 270]]
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		[[0, 180], [1, 180]]
	],
	[ //The military HQ
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		[[4, 90], [5, 0], [6, -45], [7, 225], [8, 180]]
	]
];

//Capacities of buildings for infantry
loc_b_capacity =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		14
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		2
	],
	[ //The military HQ
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		10
	],
	[ //The military metal box
		["Land_Cargo_House_V1_F", "Land_Cargo_House_V2_F", "Land_Cargo_House_V3_F"],
		4
	]
];