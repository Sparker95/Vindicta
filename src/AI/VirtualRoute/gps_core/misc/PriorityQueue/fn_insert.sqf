/**
	@Author : 
		[Utopia] Amaury
	@Contributors :
		Code34
	@Creation : --
	@Modified : --
	@Description : PriorityQueue (FIFO) insert and sort
		More info on PriorityQueue : https://en.wikipedia.org/wiki/Priority_queue
	@Return : NOTHING
**/

params ["_queue","_priority","_counter","_element"];

_queue pushBack [_priority, _counter, _element];
_queue sort true;