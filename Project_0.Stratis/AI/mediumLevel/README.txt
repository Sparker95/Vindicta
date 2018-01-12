Medium level AI scripts operate with all groups of specified garrison. These scripts can call low level AI scripts.
The goal of the 'medium level AI script' abstraction is to track other lower level scripts spawned inside a bigger major script, then terminate them all when needed.

The structure of medium level AI script is as follows:

//Do initialization
Initialization
...
...
//Spawn a main loop
_hScript = spawn
{
};
//Return script handle
_hScript