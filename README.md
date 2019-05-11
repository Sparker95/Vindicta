# Project_0.Altis

## What is it?
It is a mission for ARMA III. The goal of this project is to make a guerrilla warfare simulator for ARMA III, hugely influenced by a similar mission by Barbolani: Antistasi (http://www.a3antistasi.enjin.com/).

## How do I run it??
It's not released yet, but you can still try. Instructions are here: https://github.com/Sparker95/Project_0/wiki/Setup-mission

## Goals of this project
* Most of the features of the original Antistasi.
* Proper operation of logistics of the enemy and friendly factions, including handling of all units, i.e. no areas generating infinite amounts of enemies.
* Implement high level AI easier to control by player and more responsive to actions of enemy side.

## Current state of development
Currently the following components are fully or partially implemented:
* Main system components
* Enhanced logistics framework by Jeroen Not (enhanced arsenal, enhanced garage, enhanced repairing, rearming, refueling, etc.)
* HC management
* Garrison caching of locations
* GOAP AI framework

## Technical implementation
* Most of the code is being developed with OOP-Light (https://github.com/Sparker95/OOP-Light), a custom OOP implementation for SQF.
OOP paradigm should help produce manageable code and help implement complex systems.
* AI is being handled by a custom GOAP (Goal-Oriented Action Planning) AI framework. GOAP is a technology which was first used in fameous F.E.A.R. first person shooter. GOAP should help manage the complexity of creation of complex AI behaviours that involve replannable chains of actions. More on GOAP here: http://aigamedev.com/open/article/fear-sdk/ http://alumni.media.mit.edu/~jorkin/
