//despawns the module over time

params [["_module",objnull,[objnull]]];
if(isnull _module)exitWith{};
_module setVariable ["#active",false];