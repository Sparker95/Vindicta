// Get faction template entry metadata
// _path - path to the template entry in the form of array [catID, groupID, entryID]
params ["_path"];

if(count _path > 2 &&
	{!isNil {T_metadata#(_path#0)} && 
		{count (T_metadata#(_path#0)) > 1 &&
			{count (T_metadata#(_path#0)#1#(_path#2)) > 1}
		}
	}
) then {
	(T_metadata#(_path#0)#1#(_path#2)) params ["_entryName", "_required"];
	[T_metadata#(_path#0)#0, _entryName, _required]
	
} else {
	if(count _path > 0 && {!isNil {T_metadata#(_path#0)}}) then {
		[T_metadata#(_path#0)#0, "unknown entry", T_metadata#(_path#0)#2];
	} else {
		["unknown category", "unknown entry", [T_FACTION_Civ, T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police]]
	}
}