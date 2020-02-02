/**
	@Author : 
		[Utopia] Amaury
	@Contributors :
		Code34
	@Creation : --
	@Modified : --
	@Description : PriorityQueue (FIFO) get
		More info on PriorityQueue : https://en.wikipedia.org/wiki/Priority_queue
	@Return : ANYTHING - deleted element
**/

params ["_queue"];

(_queue deleteAt 0) select 2;