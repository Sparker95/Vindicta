#include "common.hpp"
#include "..\AI\Unit\AIunit.hpp"

/*
Dialogue class.
Manages a conversation between two characters, one of which is player.

This is a base class for all dialogues. Specific dialogue variants must be implemented
as classes derived from this class.
You must override getNodes method when implementing own dialogue class.

Authors: Sparker and Jeroen.
*/

#define OOP_CLASS_NAME Dialogue
CLASS("Dialogue", "")

	// Array of nodes
	VARIABLE("nodes");

	// Remote client ID of the user doing the dialogue
	VARIABLE("remoteClientID");

	// Time when this was updated last time
	VARIABLE("timeLastProcess");

	// Time when the current sentence will be over
	VARIABLE("timeSentenceEnd");

	// State of execution of current node
	VARIABLE("state");

	// Current node ID to execute
	VARIABLE("nodeID");

	// Stack of node IDs (analog of address), like computer's stack memory
	VARIABLE("callStack");

	// Flag, true when we are handling an event. It's needed so that we don't handle another
	// event while handling this one
	VARIABLE("handlingEvent");

	// Object handles - units performing the dialogue
	VARIABLE("unit0"); // Always AI
	VARIABLE("unit1"); // AI or player

	// ID of per frame handler used to process this dialogue
	VARIABLE("pfhId");

	METHOD(new)
		params [P_THISOBJECT, P_OBJECT("_unit0"),
					P_OBJECT("_unit1"), P_NUMBER("_clientID")];

		if (!isServer) exitWith {
			OOP_ERROR_0("Dialogue must be created at server.");
		};

		T_SETV("remoteClientID", _clientID);
		T_SETV("unit0", _unit0);
		T_SETV("unit1", _unit1);

		T_SETV("nodeID", 0);
		T_SETV("callStack", []);
		T_SETV("timeLastProcess", -1); // Means it wasn't updated yet
		T_SETV("timeSentenceEnd", 0);
		T_SETV("handlingEvent", false);
		T_SETV("state", DIALOGUE_STATE_RUN);

		T_SETV("nodes", []); // Nodes are initialized later in process call

		// Send request to client
		if (_clientID != -1) then {
			pr _args = [_thisObject, _unit0];
			REMOTE_EXEC_CALL_STATIC_METHOD("DialogueClient", "requestConnect", _args, _clientID, false);
		};
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		T_CALLM0("terminate");
		T_CALLM0("endProcessing");
	ENDMETHOD;

	// Must be called periodically, up to once per frame
	METHOD(process)
		params [P_THISOBJECT];

		// Generate nodes if not yet initialized
		// Call virtual method to get nodes
		pr _nodes = T_GETV("nodes");
		if (count _nodes == 0) then {
			_nodes = T_CALLM2("getNodes", _unit0, _unit1);
			if (isNil "_nodes" || {count _nodes == 0}) then {
				OOP_ERROR_0("Node array is nil or empty");
				_nodes = [];
			};
			T_SETV("nodes", _nodes);
		};

		// Bail if dialogue is over
		pr _state = T_GETV("state");
		//OOP_INFO_1("process  state: %1", _state);
		if (_state == DIALOGUE_STATE_END) exitWith {};

		// Calculate delta-time
		pr _timeLastProcess = T_GETV("timeLastProcess");
		pr _deltaTime = if (_timeLastProcess < 0) then {0} else {
			time - _timeLastProcess;
		};

		// Check if units walked away or died
		pr _unit0 = T_GETV("unit0");
		pr _unit1 = T_GETV("unit1");

		if (!T_GETV("handlingEvent")) then {
			// Check if someone is not alive of null
			if (!(alive _unit0) || !(alive _unit1)) then {
				OOP_INFO_0("Critical event: a unit is not alive");
				T_CALLM1("_handleCriticalEvent", NODE_TAG_EVENT_NOT_ALIVE);
			} else {
				// Check if units are far away
				if ((_unit0 distance _unit1) > DIALOGUE_DISTANCE) then {
					OOP_INFO_0("Critical event: units are far away");
					T_CALLM1("_handleCriticalEvent", NODE_TAG_EVENT_AWAY);
				};
			};
		};

		// Check current node
		pr _nodes = T_GETV("nodes");
		pr _nodeID = T_GETV("nodeID");

		// Bail if we have reached the end of the node array
		if (_nodeID >= (count _nodes) || _nodeID < 0) exitWith {
			OOP_INFO_1("Node ID exceeded limit: %1, ending dialogue", _nodeID);
			T_SETV("state", DIALOGUE_STATE_END);
		};

		pr _error = false; // Error flag, set it if an error has happened
		pr _node = _nodes#_nodeID;
		pr _type = _node#NODE_ID_TYPE;
		pr _tag = _node#NODE_ID_TAG;

		// Select the rest of the array (omit type and tag)
		pr _nodeTail = _node select [2, 100];

		//OOP_INFO_2("Node: %1, type: %2", _node, _type);

		switch (_type) do {

			// Show sentence
			case NODE_TYPE_SENTENCE_METHOD;
			case NODE_TYPE_OPTION;
			case NODE_TYPE_SENTENCE: {
				_nodeTail params [P_NUMBER("_talker"), P_DYNAMIC("_text"), P_STRING("_methodName")];

				switch (_state) do {
					// Start this sentence
					case DIALOGUE_STATE_RUN: {
						OOP_INFO_1("Process: node: option/sentence: %1", _node);
						// Start lip animation
						pr _talkObject = T_GETV("unit0");
						if (_talker == TALKER_1) then {
							_talkObject = T_GETV("unit1");
						};
						[_talkObject, true] remoteExecCall ["setRandomLip", 0];

						// Call method if a method must provide text
						if (_methodName != "") then {
							OOP_INFO_1("  calling method to get text: %1", _methodName);
							_text = T_CALLM0(_methodName);
						} else {
							// If method name wasn't provided, then we have either _text = some string
							// Or an array of strings
							if (_text isEqualType []) then {
								_text = selectRandom _text;
							};
						};

						// Calculate time when the sentence ends
						pr _duration = SENTENCE_DURATION(_text);
						pr _timeEnd = time + _duration;
						T_SETV("timeSentenceEnd", _timeEnd);

						// Set state
						T_SETV("state", DIALOGUE_STATE_WAIT_SENTENCE_END);

						// Transmit data to nearby listeners
						CALLSM3("Dialogue", "objectSaySentence", _thisObject, _talkObject, _text);
					};

					// Wait until this sentence is over
					case DIALOGUE_STATE_WAIT_SENTENCE_END: {
						if (time > T_GETV("timeSentenceEnd")) then {

							OOP_INFO_1("Process: END node: option/sentence: %1", _node);

							// Stop lip animation
							[T_GETV("unit0"), false] remoteExecCall ["setRandomLip", 0];
							[T_GETV("unit1"), false] remoteExecCall ["setRandomLip", 0];

							// Set state
							T_SETV("state", DIALOGUE_STATE_RUN);

							// Go to next node
							T_SETV("nodeID", _nodeID + 1);
						} else {
							// Wait for this sentence to end...
							//OOP_INFO_1("Waiting for sentence to end: %1 s left", T_GETV("timeSentenceEnd") - time);
						};
					};

					default {
						OOP_ERROR_2("Invalid state: %1, node: %2", _state, _node);
						_error = true;
					};
				};
			};

			// Go to another node
			case NODE_TYPE_JUMP_IF;
			case NODE_TYPE_JUMP: {
				_nodeTail params [P_STRING("_tagNext"), P_STRING("_methodName"), P_ARRAY("_arguments")];
				if (_state != DIALOGUE_STATE_RUN) then {
					OOP_ERROR_2("Invalid state: %1, node: %2", _state, _node);
					_error = true;					
				} else {
					pr _do = true;

					OOP_INFO_1("Process: node: jump/jumpif: %1", _node);

					// If it's an 'if' node, also call method to evaluate the statement
					if (_methodName != "") then {
						pr _callResult = CALLM(_thisObject, _methodName, _arguments);
						OOP_INFO_2("Called method %1, result: %2", _methodName, _callResult);
						if (!_callResult) then { _do = false; };
					};

					if (_do) then {
						pr _stack = T_GETV("callStack");
						T_CALLM1("goto", _tagNext);
					} else {
						// Skip this node otherwise
						T_SETV("nodeID", _nodeID + 1);
					};
				};
			};

			// Go to another node and push address of next node to stack
			// So we can return from that sequence later
			case NODE_TYPE_CALL_IF;
			case NODE_TYPE_CALL: {
				_nodeTail params [P_STRING("_tagCall"), P_STRING("_methodName"), P_ARRAY("_arguments")];
				if (_state != DIALOGUE_STATE_RUN) then {
					OOP_ERROR_2("Invalid state: %1, node: %2", _state, _node);
					_error = true;					
				} else {
					pr _do = true;

					OOP_INFO_1("Process: node: call/callif: %1", _node);

					// If it's an 'if' node, also call method to evaluate the statement
					if (_methodName != "") then {
						pr _callResult = CALLM(_thisObject, _methodName, _arguments);
						OOP_INFO_2("Called method %1, result: %2", _methodName, _callResult);
						if (!_callResult) then { _do = false; };
					};

					if (_do) then {
						pr _stack = T_GETV("callStack");
						_stack pushBack (_nodeID+1); // We will return to next node
						T_CALLM1("goto", _tagCall);
					} else {
						// Skip this node otherwise
						T_SETV("nodeID", _nodeID + 1);
					};
				};
			};

			// Return from sequence to address stored in stack
			// Only makes sense after a call
			case NODE_TYPE_RETURN: {
				if (_state != DIALOGUE_STATE_RUN) then {
					OOP_ERROR_2("Invalid state: %1, node: %2", _state, _node);
					_error = true;					
				} else {
					OOP_INFO_1("Process: node: return: %1", _node);
					pr _stack = T_GETV("callStack");
					if (count _stack == 0) then {
						OOP_INFO_0("Nowhere to return to, ending dialogue");
						// If there is nothing else in the stack then we should end the dialogue
						T_SETV("state", DIALOGUE_STATE_END);
					} else {
						// Pop node tag from the stack and go there
						pr _idReturn = _stack deleteAt ((count _stack) - 1);
						OOP_INFO_2("Returning to node id: %1: %2", _idReturn, _nodes select _idReturn);
						T_SETV("nodeID", _idReturn);
					};
				};
			};


			// Show options to client
			case NODE_TYPE_OPTIONS: {
				_nodeTail params [P_ARRAY("_optionTagArray")];

				switch (_state) do {

					// Make an array of data to send to client
					case DIALOGUE_STATE_RUN: {

						OOP_INFO_1("Process: node: options: %1", _node);

						// Options only make sense if a remote client ID is specified
						if (T_GETV("remoteClientID") == -1) then {
							OOP_ERROR_1("Options node encountered but remote client id is missing: %1", _node);
							_error = true;
						};

						// It will contain the text of each option and tag
						if (!_error) then {
							pr _options = [];
							{
								pr _nodeID = T_CALLM1("findNode", _x);

								if (_nodeID == -1) then {
									OOP_ERROR_1("Node with tag %1 was not found", _x);
									_error = true;
								};

								pr _nodeOpt = _nodes#_nodeID;

								// If the node with this tag isn't an option type,
								// Scan till we find first node with option type
								while {_nodeOpt#NODE_ID_TYPE != NODE_TYPE_OPTION && !_error} do {
									_nodeID = _nodeID + 1;
									if (_nodeID >= count _nodes) then {
										OOP_ERROR_1("Couldn't find an option node after tag: %1", _x);
										_error = true;
									} else {
										_nodeOpt = _nodes#_nodeID;
									};
								};
								
								if (!_error) then {
									pr _optionText = _nodeOpt#3;
									if (_optionText isEqualType []) then {
										_optionText = selectRandom _optionText;
										// We replace array with different sentences with a single sentence selected right now
										// So that the actual sentence said later matches ot the one displayed to player
										NODE_SET_TEXT(_nodeOpt, _optionText);
									};
									_options pushBack [_x, _optionText]; // [tag, text] of the option node
								};
							} forEach _optionTagArray;

							if (count _options > 0 && !_error) then {
								// Send data to client
								REMOTE_EXEC_CALL_STATIC_METHOD("DialogueClient", "createOptions", [_options], T_GETV("remoteClientID"), false);
								
								// Now we are waiting for client's response
								T_SETV("state", DIALOGUE_STATE_WAIT_OPTION);
							} else {
								// Raise error
								OOP_ERROR_1("Could not resolve option nodes for tag %1", _tag);
								_error = true;
							};
						};

					};

					// We are still waiting for user to choose the option
					// Do nothing
					case DIALOGUE_STATE_WAIT_OPTION: {
						
					};

					default {
						OOP_ERROR_2("Invalid state: %1, node: %2", _state, _node);
						_error = true;
					};
				};
			};

			// Call code and continue
			case NODE_TYPE_CALL_METHOD: {
				_nodeTail params [P_STRING("_method"), P_ARRAY("_arguments")];

				if (_state != DIALOGUE_STATE_RUN) then {
					OOP_ERROR_2("Invalid state: %1, node: %2", _state, _node);
					_error = true;					
				} else {
					OOP_INFO_1("Process: node: call method: %1", _node);
					// Call method
					CALLM(_thisObject, _method, _arguments);
					// Go to next node
					T_SETV("nodeID", _nodeID + 1);
				};
			};

			// End dialogue
			case NODE_TYPE_END: {
				if (_state != DIALOGUE_STATE_RUN) then {
					OOP_ERROR_2("Invalid state: %1, node: %2", _state, _node);
					_error = true;					
				} else {
					OOP_INFO_0("Process: node: end");
					T_SETV("state", DIALOGUE_STATE_END);
				};
			};

			default {
				OOP_ERROR_1("Unknown node type: %1", _type);
			};
		};

		// Find out what to do now
		if (_error) then {
			OOP_INFO_0("Error while processing one of nodes, ending dialogue");
			T_SETV("state", DIALOGUE_STATE_END);
		};

	ENDMETHOD;

	// Finds node and prints error if node was not found
	METHOD(findNode)
		params [P_THISOBJECT, P_STRING("_tag")];
		pr _id = FIND_NODE(T_GETV("nodes"), _tag);
		if (_id == -1) then {
			OOP_ERROR_1("Could not find node with tag %1", _tag);
		};
		_id;
	ENDMETHOD;

	// Handles a critical event - that is event which can lead to termination
	// of the dialogue.
	// It tries to jump to an event handler node if it's found, otherwise it ends the dialogue
	METHOD(_handleCriticalEvent)
		params [P_THISOBJECT, P_STRING("_tag")];
		pr _nodes = T_GETV("nodes");
		pr _nodeID = FIND_NODE(_nodes, _tag);
		if (_nodeID == -1) then {
			// Terminate this
			T_SETV("state", DIALOGUE_STATE_END);
		} else {
			// Jump to that node
			T_SETV("nodeID", _nodeID);
			T_SETV("handlingEvent", true);
		};
	ENDMETHOD;

	// Called before dialogue is deleted
	METHOD(terminate)
		params [P_THISOBJECT];
		
		// Force-stop lip animations
		[T_GETV("unit0"), false] remoteExecCall ["setRandomLip", 0];
		[T_GETV("unit1"), false] remoteExecCall ["setRandomLip", 0];
		
		// Send data to client
		pr _clientID = T_GETV("remoteClientID");
		if (_clientID != -1) then {
			REMOTE_EXEC_CALL_STATIC_METHOD("DialogueClient", "disconnect", [_thisObject], _clientID, false);
		};
	ENDMETHOD;

	// Returns true if the dialogue has ended, because of any reason
	// (someone walked away or died or it just ended naturally)
	METHOD(hasEnded)
		params [P_THISOBJECT];
		T_GETV("state") == DIALOGUE_STATE_END;
	ENDMETHOD;

	// ===== Connection
	// See description of connection procedure in DialogueClient.sqf

	// Remotely executed on server by client when client has accepted connection
	public METHOD(acceptConnect)
		params [P_THISOBJECT];
		OOP_INFO_0("acceptConnect");
	ENDMETHOD;

	// Remotely executed on server by client when client has rejected connection
	public METHOD(rejectConnect)
		params [P_THISOBJECT];

		OOP_INFO_0("rejectConnect");

		// Just terminate this
		T_SETV("state", DIALOGUE_STATE_END);
	ENDMETHOD;

	// Remotely executed on server by client when client selects an option
	public METHOD(selectOption)
		params [P_THISOBJECT, P_NUMBER("_optionID")];

		OOP_INFO_1("selectOption: %1", _optionID);

		if (T_GETV("state") == DIALOGUE_STATE_WAIT_OPTION) then {
			pr _nodes = T_GETV("nodes");
			pr _node = _nodes select T_GETV("nodeID");
			_node params [P_STRING("_type"), P_STRING("_tag"), P_ARRAY("_optionTagArray")];
			_optionID = _optionID % (count _optionTagArray); // We want to be safe with ID
			pr _nextTag = _optionTagArray#_optionID;
			T_CALLM1("goto", _nextTag);
			T_SETV("state", DIALOGUE_STATE_RUN);

			// Process this right now to accelerate the response
			T_CALLM0("process");
		} else {
			OOP_ERROR_0("selectOption called called while not waiting for option selection");
		};
	ENDMETHOD;
	
	// Remotely executed on server by client when client wants to talk to a unit
	// Performs checks and causes AI to start a dialogue
	public STATIC_METHOD(requestStartNewDialogue)
		params [P_THISOBJECT, P_OBJECT("_unitNPC"), P_OBJECT("_unitPlayer"), P_NUMBER("_playerOwner")];

		OOP_INFO_1("requestStartNewDialogue: %1", _this);

		// Bail if not run on server
		if (!isServer) exitWith {
			OOP_ERROR_0("requestStartNewDialogue must be run on server");
		};

		// Bail if either objects are not alive
		if (!(alive _unitNPC) || !(alive _unitPlayer)) exitWith {
			OOP_INFO_0("  Unit or player is not alive");
		};

		// Check if unit is free for talk
		private _aiHuman = GET_AI_FROM_OBJECT_HANDLE(_unitNPC);

		// Bail if trying to talk with an invalid AI
		if (IS_NULL_OBJECT(_aiHuman)) exitWith {
			OOP_INFO_0("  Unit has no AI, can't create dialogue");
		};

		// Player will say something
		pr _text = localize selectRandom g_phrasesPlayerStartDialogue;
		CALLSM3("Dialogue", "objectSaySentence", NULL_OBJECT, _unitPlayer, _text);

		CALLM2(_aiHuman, "startNewDialogue", _unitPlayer, _playerOwner);
	ENDMETHOD;

	/*
	=====================================================================
	= PUBLIC API BELOW
	=====================================================================
	*/

	/*
	Call this on server or on client when an object says something aloud and you want nearby players can hear that.

	Parameters:
	_dialogueRef - reference to dialogue OOP object, or NULL_OBJECT if sentence does not originate from a dialogue.
		(for instance if unit says something not from dialogue).
	_talker - object which is saying the sentence.
	_text - text to say.
	*/
	public STATIC_METHOD(objectSaySentence)
		params [P_THISOBJECT, P_OOP_OBJECT("_dialogueRef"), P_OBJECT("_talker"), P_STRING("_text")];

		OOP_INFO_1("objectSaySentence: %1", _this);

		// We only care to transmit it to players
		pr _playersNearby = allPlayers select { (_x distance _talker) < SENTENCE_HEAR_DISTANCE};
		if (count _playersNearby > 0) then {
			// REMOTE_EXEC_CALL_STATIC_METHOD(classNameStr, methodNameStr, extraParams, targets, JIP)
			pr _params = [_dialogueRef, _talker, _text];
			REMOTE_EXEC_CALL_STATIC_METHOD("DialogueClient", "onObjectSaySentence", _params, _playersNearby, false);
		};
	ENDMETHOD;

	/*
	Sets current node to a node with given tag.
	You can use it to jump to a specific node.
	*/
	METHOD(goto)
		params [P_THISOBJECT, P_STRING("_tag")];
		pr _id = T_CALLM1("findNode", _tag);
		OOP_INFO_2("goto: %1, id: %2", _tag, _id);
		T_SETV("nodeID", _id);
		T_SETV("state", DIALOGUE_STATE_RUN);
	ENDMETHOD;

	/*
	Must be implemented in derived classes.
	Returns an array of nodes for this dialogue class.
	_unit0, _unit1 - same as in constructor.
	*/
	protected virtual METHOD(getNodes)
		params [P_THISOBJECT, P_OBJECT("_unit0"), P_OBJECT("_unit1")];
		[]
	ENDMETHOD;

	/*
	Starts and ends processing of this dialogue on each frame
	*/
	public METHOD(startProcessing)
		params [P_THISOBJECT];

		if (T_GETV("pfhId") != -1) exitWith {};

		pr _code = {
			(_this#0) params ["_thisObject"];
			T_CALLM0("process");
		};
		pr _pfhId = [_code, 0.1, [_thisObject]] call CBA_fnc_addPerFrameHandler;
		T_SETV("pfhId", _pfhId);
	ENDMETHOD;

	public METHOD(endProcessing)
		params [P_THISOBJECT];

		pr _pfhId = T_GETV("pfhId");
		if (_pfhId == -1) exitWith {};

		[_pfhId] call CBA_fnc_removePerFrameHandler;
	ENDMETHOD;

ENDCLASS;