/*

Author: code34 <nicolas_boiteux@yahoo.fr>
Author: Naught <dylanplecki@gmail.com>

Copyright (C) 2013-2018 Nicolas BOITEUX

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
	
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. 
*/

//////////////////////////////////////////////////////////////
//  Group: Basic Macros
//////////////////////////////////////////////////////////////

#define QUOTE(var) #var
#define DOUBLES(var1,var2) ##var1##_##var2
#define TRIPLES(var1,var2,var3) ##var1##_##var2##_##var3
#define DEFAULT_PARAM(idx,dft) (if ((count _this) > idx) then {_this select idx} else {dft})
#define TO_LOCAL(var) _##var

//////////////////////////////////////////////////////////////
//  Group: Internal Definitions
//////////////////////////////////////////////////////////////

#define CONSTRUCTOR_METHOD "constructor"
#define DECONSTRUCTOR_METHOD "deconstructor"
#define AUTO_INC_VAR(className) (className + "_IDAI")

//////////////////////////////////////////////////////////////
//  Group: Internal Macros
//////////////////////////////////////////////////////////////
#define SAFE_VAR(var) (if (isNil {var}) then {nil} else {var})
#define DEBUG(sharp,name) sharp##line 0 name
#define ENSURE_INDEX(idx,dft) if ((count _this) <= idx) then {_this set [idx,dft]}
#define CHECK_THIS if (isNil "_this") then {_this = []} else {if !(_this isEqualType []) then {_this = [_this]}}

#define CHECK_ACCESS(lvl) case ((_access >= lvl) &&
#define CHECK_TYPE(typeStr) ((_argType isEqualTo toUpper(typeStr)) || {toUpper(typeStr) isEqualTo "ANY"})
#define CHECK_NIL (_argType isEqualTo "")
#define CHECK_MEMBER(name) (_member == name)
#define CHECK_VAR(typeStr,varName) {CHECK_MEMBER(varName)} && {CHECK_TYPE(typeStr) || CHECK_NIL}

#define GETVAR(var) (_classID + "_" + var)
#define GETSVAR(var) (_class + "_" + var)
#define GETCLASS(className) (NAMESPACE getVariable [className, {nil}])
#define CALLCLASS(className,member,args,access) (if(isNil "_oopOriginCall")then{ [_classID, member, SAFE_VAR(args),access] call GETCLASS(className) }else{ [_classID, member, SAFE_VAR(args),access] call GETCLASS(_oopOriginCall)})
#define SPAWNCLASS(className,member,args,access) (if(isNil "_oopOriginCall")then{ [_classID, member, SAFE_VAR(args),access] spawn GETCLASS(className) }else{ [_classID, member, SAFE_VAR(args),access] spawn GETCLASS(_oopOriginCall)})
#define CALLCLASS_FROMCHILD(className,member,args,access,origin) ([_classID, member, SAFE_VAR(args), access, origin] call GETCLASS(className))

#define VAR_DFT_FUNC(varName) {if (isNil "_this") then {NAMESPACE getVariable [GETVAR(varName), nil]} else {NAMESPACE setVariable [GETVAR(varName), _this]};}
#define UIVAR_DFT_FUNC(varName) {if (isNil "_this") then {UINAMESPACE getVariable [GETVAR(varName), nil]} else {UINAMESPACE setVariable [GETVAR(varName), _this]};}

#define SVAR_DFT_FUNC(varName) {if (isNil "_this") then {NAMESPACE getVariable [GETSVAR(varName), nil]} else {NAMESPACE setVariable [GETSVAR(varName), _this]};}
#define SUIVAR_DFT_FUNC(varName) {if (isNil "_this") then {UINAMESPACE getVariable [GETSVAR(varName), nil]} else {UINAMESPACE setVariable [GETSVAR(varName), _this]};}

#define VAR_DELETE(varName) (NAMESPACE setVariable [GETVAR(varName), nil])
#define UIVAR_DELETE(varName) (UINAMESPACE setVariable [GETVAR(varName), nil])

#define MOD_VAR(varName,mod) MEMBER(varName,MEMBER(varName,nil)+mod); 
#define INC_VAR(varName) MOD_VAR(varName,1)
#define DEC_VAR(varName) MOD_VAR(varName,-1)
#define PUSH_ARR(varName,array) MOD_VAR(varName,array)
#define REM_ARR(varName,array) MOD_VAR(varName,array)

#define GET_AUTO_INC(className) (NAMESPACE getVariable [AUTO_INC_VAR(className),0])


//////////////////////////////////////////////////////////////
//  Group: Interactive (API) Macros and Definitions
//////////////////////////////////////////////////////////////

/*
	Define: NAMESPACE
	Defines the usable namespace for all preceeding classes.
	When extending a class from another class, both classes must be within the same namespace.
*/
#ifndef NAMESPACE
#define NAMESPACE missionNamespace
#endif

#ifndef UINAMESPACE
#define UINAMESPACE uiNamespace
#endif

/*
	Define: EXCEPTION
	Defines the exception codes
	When declare a new exception, must use an uniq exception code define here
*/

#ifndef ERR_UNDEFMEMBER
#define ERR_UNDEFMEMBER 34
#endif

/*
	Macro: CLASS(className)
	Initializes a new class, or overwrites an existing one.
	Interaction with the class can be performed with the following code:
		["memberName", args] call ClassName;
	This code must be executed in the correct namespace, and will only have access to public members.
	
	Parameters:
		className - The name of the class [string].
	
	See Also:
		<CLASSEXTENDS>
*/
#define CLASS(className) INSTANTIATE_CLASS(className, "No Parent") default { throw [ERR_UNDEFMEMBER, _class, _member, _argType]; };

/*
	Macro: CLASS_EXTENDS(childClassName,parentClassName)
	Initializes a new class extending a parent class, or overwrites an existing class.
	Interaction with the class can be performed with the following code:
		["memberName", args] call ClassName;
	This code must be executed in the correct namespace, and will only have access to public members.
	
	Parameters:
		childClassName - The name of the child class [string].
		parentClassName - The name of the parent class [string].
	
	See Also:
		<CLASS>
*/
#define CLASS_EXTENDS(childClassName,parentClassName) INSTANTIATE_CLASS(childClassName, parentClassName) default { if(isNil "_oopOriginCall")then{CALLCLASS_FROMCHILD(parentClassName,_member,_this,1, childClassName);}else{CALLCLASS_FROMCHILD(parentClassName,_member,_this,1, _oopOriginCall);}; };

/*
	Defines:
	- PRIVATE
		Initializes a private member within a class.
		Private members may only be accessed by members of its own class.
	- PROTECTED
		Initializes a protected member within a class.
		Protected members may only be accessed by members of its own class or child classes.
	- PRIVATE
		Initializes a public member within a class.
		Public members may be accessed by anyone.
*/
#define PRIVATE CHECK_ACCESS(2)
#define PROTECTED CHECK_ACCESS(1)
#define PUBLIC CHECK_ACCESS(0)

/*
	Macro: FUNCTION(typeStr,fncName)
	Initializes a new function member of a class.
	
	Parameters:
		typeStr - The typeName of the argument. Reference <http://community.bistudio.com/wiki/typeName> [string].
		fncName - The name of the function member [string].
	
	See Also:
		<VARIABLE>
*/
#define FUNCTION(typeStr,fncName) {CHECK_MEMBER(fncName)} && {CHECK_TYPE(typeStr)}):

/*
	Macros: 
		VARIABLE(typeStr,varName)
		UI_VARIABLE(typeStr,varName)
		STATIC_VARIABLE(typeStr,varName)
		STATIC_UI_VARIABLE(typeStr,varName)
		
	Description:
		Initializes a new variable member of a class. Static variables are share between instances of classes.
		UI variables are used for GUI elements

	Parameters:
		typeStr - The typeName of the argument. Reference <http://community.bistudio.com/wiki/typeName> [string].
		varName - The name of the variable member [string].
	
	See Also:
		<FUNCTION>
*/
#define VARIABLE(typeStr,varName) CHECK_VAR(typeStr,varName)): VAR_DFT_FUNC(varName)
#define UI_VARIABLE(typeStr,varName) CHECK_VAR(typeStr,varName)): UIVAR_DFT_FUNC(varName)
#define STATIC_VARIABLE(typeStr,varName) CHECK_VAR(typeStr,varName)): SVAR_DFT_FUNC(varName)
#define STATIC_UI_VARIABLE(typeStr,varName) CHECK_VAR(typeStr,varName)): SUIVAR_DFT_FUNC(varName)

/*
	Macro: 
	DELETE_VARIABLE(varName)
	DELETE_UI_VARIABLE(varName)

	Deletes (nils) a variable which has been defined using the <VARIABLE> macro.
	This macro must be used inside a member function, and works regardless of the variable's protection.
	
	Parameters:
		varName - The name of the variable member to delete [string].
	
	See Also:
		<VARIABLE>
*/
#define DELETE_VARIABLE(varName) VAR_DELETE(varName)
#define DELETE_UI_VARIABLE(varName) UIVAR_DELETE(varName)

/*
	Macro: 
	MEMBER(memberStr,args)
	SPAWN_MEMBER(memberStr,args)

	Calls or Spawn a member function or gets/sets a member variable. This will only work on members
	of the current class. All class members (private, protected, public) can be accessed through this
	macro. All public and protected members of parent classes will be available while using this macro.
	If accessing a variable member, passing a nil argument will retrieve the variable while anything else
	will set the variable to the value of the argument.
	
	Parameters:
		memberStr - The name of the member function or variable [string].
		args - The arguments to be passed to the member function or variable [any].
*/
#define MEMBER(memberStr,args) CALLCLASS(_class,memberStr,args,2)
#define SPAWN_MEMBER(memberStr,args) SPAWNCLASS(_class,memberStr,args,2)

/*
	Macro: SUPER(memberStr,args)
	Insert the parent function in the current function
	
	Parameters:
		memberStr - The name of the parent mumber function
		args - The arguments to be passed to the member function or variable [any].
*/
#define SUPER(memberStr,args) CALLCLASS_FROMCHILD(_parentClass,memberStr,args,1, _class)

/*
	Macro:  NEW(class, args)
	Instanciate a new object of class with args 
*/
#define NEW(class, args) ["new", args] call class

/*
	Macro: DELETE(class, instance)
	Delete the instance of object of class
*/
#define DELETE(instance) "deconstructor" call instance

/*
	Macro: STATIC_FUNCTION(class, fncName, args)
	Call a static function name of class with args
*/
#define STATIC_FUNCTION(instance, fncName, args) ["static", [fncName, args]] call instance

/*
	Macro: FUNC_GETVAR(varName)
	Returns a variable of the current class, used as a function.
	
	Example:
		PUBLIC FUNCTION("","getSpawnState") FUNC_GETVAR("spawned");
	
	Parameters:
		varName - The name of the variable member [string].
*/
#define FUNC_GETVAR(varName) {MEMBER(varName,nil);}

/*
	Define: ENDCLASS
	Ends a class's initializaton and finalizes SQF output.
*/
#define ENDCLASS FINALIZE_CLASS

#define INSTANTIATE_CLASS(className, parentClassName) \
	NAMESPACE setVariable [className, { try { \
	CHECK_THIS; \
	if ((count _this) > 0) then { \
		private _class = className; \
		private _parentClass = parentClassName; \
		if (isNil {_this select 0}) then {_this set [0,_class]}; \
		switch (_this select 0) do { \
		case "new": { \
			NAMESPACE setVariable [AUTO_INC_VAR(className), (GET_AUTO_INC(className) + 1)]; \
			private _code = compile format ['CHECK_THIS; ENSURE_INDEX(1,nil); (["%1", (_this select 0), (_this select 1), 0]) call GETCLASS(className);', (className + "_" + str(GET_AUTO_INC(className)))]; \
			ENSURE_INDEX(1,nil); \
			private _classID = className + "_" + str(GET_AUTO_INC(className)); \
			NAMESPACE setVariable [format ['%1_this', _classID], _code]; \
			[CONSTRUCTOR_METHOD, (_this select 1)] call _code; \
			_code; \
		}; \
		case "static":{ \
			private _code = compile format ['CHECK_THIS; ENSURE_INDEX(1,nil); (["%1", (_this select 0), (_this select 1), 0]) call GETCLASS(className);', className]; \
			[(_this select 1) select 0, (_this select 1) select 1] call _code; \
		}; \
		case "protected":{ \
			private _array = toArray str (missionNamespace getVariable className); \
    			_array deleteAt (count _array - 1); \
    			_array deleteAt (0); \
    			missionNamespace setVariable[className, (compileFinal toString _array)]; \
		}; \
		case "delete": { \
			if ((count _this) == 2) then {_this set [2,nil]}; \
			[DECONSTRUCTOR_METHOD, (_this select 2)] call (_this select 1); \
		}; \
		default { \
			private _classID = _this select 0; \
			private _member = _this select 1; \
			private _access = DEFAULT_PARAM(3,0); \
			private _oopOriginCall = DEFAULT_PARAM(4,nil); \
			_this = DEFAULT_PARAM(2,nil); \
			private _argType = if (isNil "_this") then {""} else {typeName _this}; \
			switch (true) do { \
			
#define FINALIZE_CLASS };};};};} catch { \
	switch (_exception select 0) do { \
		case ERR_UNDEFMEMBER : { \
			format ['ERROR UNDEF : %1("%3","%2")', _exception select 1, _exception select 2, _exception select 3] call BIS_fnc_error; \
		}; \
	}; \
}}] 