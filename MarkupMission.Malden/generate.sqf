_animSetNames = ["STAND","STAND1","STAND_IA","STAND2","STAND_U1","STAND_U2","STAND_U3","WATCH","WATCH1","WATCH2","GUARD","LISTEN_BRIEFING","LEAN_ON_TABLE","LEAN","SIT_AT_TABLE","SIT1","SIT","SIT2","SIT3","SIT_U1","SIT_U2","SIT_U3","SIT_HIGH1","SIT_HIGH","SIT_HIGH2","SIT_LOW","SIT_LOW_U","SIT_SAD1","SIT_SAD2","KNEEL","REPAIR_VEH_PRONE","REPAIR_VEH_KNEEL","REPAIR_VEH_STAND","PRONE_INJURED_U1","PRONE_INJURED_U2","PRONE_INJURED","KNEEL_TREAT","KNEEL_TREAT2","BRIEFING","BRIEFING_POINT_LEFT","BRIEFING_POINT_RIGHT","BRIEFING_POINT_TABLE"];
_animSets = _animSetNames apply {
	(_x call BIS_fnc_ambientAnimGetParams) params [
		"_anims","_azimutFix","_attachSnap","_attachOffset","_noBackpack","_noWeapon","_randomGear","_canInterpolate"
	];
	[
		_x,
		_azimutFix,
		_attachOffset,
		_anims apply { toLower _x }
	]
};

_objs = ([worldSize/2, worldSize/2, 0] nearObjects 20000) select { _x getVariable ["m_tag", false] };

_markUps = _objs apply {
	private _obj = _x;
	private _markers = (units group (nearestObjects [_obj, ["Man"], 100] select 0)) apply {
		private _unit = _x;
		private _unitAnims = (_unit getVariable ["enh_ambientanimations_anims", []]) apply { toLower _x };
		private _ambientAnimIdx = _animSets findIf { _x#3 isEqualTo _unitAnims };
		private _animData = if(_ambientAnimIdx != -1) then {
			_animSets#_ambientAnimIdx;
		} else {
			systemChat format ["ERROR: unit %1 has invalid anims %2", _unit, _unitAnims];
			["STAND", 0, 0, []]
		};
		_animData params ["_animSet", "_azimutFix", "_attachOffset"];
		private _posVec = _obj worldToModel (_unit modelToWorld [0,0,0]);
		_posVec = [round (_posVec#0 * 100) / 100, round (_posVec#1 * 100) / 100, round ((_posVec#2 - _attachOffset) * 100) / 100];
		private _dir = getDir _unit - getDir _obj - _azimutFix;
		//private _dirVec = _obj vectorWorldToModel vectorDir _unit;
		//_dirVec = [round (_dirVec#0 * 100) / 100, round (_dirVec#1 * 100) / 100, round (_dirVec#2 * 100) / 100];
		//private _upVec = _obj vectorWorldToModel vectorDir _unit;
		//_upVec = [round (_upVec#0 * 100) / 100, round (_upVec#1 * 100) / 100, round (_upVec#2 * 100) / 100];
		[
			_posVec,
			_dir,
			//_upVec,
			_animData#0
		]
	};
	[
		typeOf _obj,
		_markers
	]
};
gMarkups = _markUps;
copyToClipboard str _markUps;