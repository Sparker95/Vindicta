# Project_0.Stratis

## What is it?
It is a mission for ARMA III. The goal of this project is to make a guerrilla warfare simulator for ARMA III, hugely influenced by a similar mission by Barbolani: Antistasi (http://www.a3antistasi.enjin.com/).

## Goals of this project
* Most of the features of the original Antistasi.
* Proper operation of logistics of the enemy and friendly factions, including handling of all units, i.e. no areas generating infinite amounts of enemies.
* Implement high level AI easier to control by player and more responsive to actions of enemy side.

## Current state of development
Currently rewriting all the code with OOP-Light (https://github.com/Sparker95/OOP-Light) in the development-OOP branch.
OOP should help produce manageable code and help implement complex event-driven systems needed for functioning of key components of the scenario.

Mainly done in the old (non-OOP) code:
* Basic generation of some types of locations (bases, outposts, etc.)
* Garrison caching
* Structure of AI command and some basic functions. AI controlled bases can respond to threats and provide help to other bases.
