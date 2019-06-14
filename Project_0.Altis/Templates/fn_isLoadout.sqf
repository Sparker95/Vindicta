/*
Returns true if given _tag is a loadout tag
*/

params [["_tag", "", [""]]];
#ifndef _SQF_VM
! (isNil {t_loadouts_hashmap getVariable _tag})
#else
false
#endif