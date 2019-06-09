/*
Returns true if given _tag is a loadout tag
*/

params [["_tag", "", [""]]];

! (isNil {t_loadouts_hashmap getVariable _tag})