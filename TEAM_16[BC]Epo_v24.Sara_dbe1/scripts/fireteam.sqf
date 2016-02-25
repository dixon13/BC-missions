// Fireteam Gamemode

// Description:
// * Players start with an unarmed vehicle around the objective.
// * Objective type and location is placed randomly.
// * New objectives will be assigned after the current objective is completed and will only be placed in adjacent locations.
// * A player will remain dead until the objective is complete.
// * Dead players will respawn upon a new objective being assigned.
// * Equipment will spawn in buildings around the current objective AO.
// * Vehicles will also spawn in the AO. Higher value vehicles spawn with fewer ammo and fuel.

// Configuration:
// * randomloot\server.sqf - _maxSpawns     // Maxmimum number of items per building
// * randomloot\server.sqf - _probability   // Probability that the item spawns in a building

if (!isServer) exitWith {};

// Array of "Locations": ["Name", "Size"]
_objLocations = [
    ["name", "size", ["x","y"]]
];

/* United Sahrani Locations
    [],
    []
*/

// Array of "Objective Types": ["name"]
_objTypes = [
    ["steal"],
    ["destroy"],
    ["hold"]
];

/* Incomplete Objectives
    ["kill"],
    ["transport"],
    ["resupply"],
    ["locate"],
    ["capture"],
    ["inform"],
    ["disguise"]
*/

cleanOldObjective = {};

nextObjectiveLocation = {
    _nextLoc = selectRandom _objLocations;
    _nextLoc
};

nextObjectiveType = {
    _nextType = selectRandom _objTypes;
    _nextType
};

moveTriggers = {};
moveMarkers = {};
randItemSpawn = {
    //Call item randomloot
    ["randItemsMarker"] execVM "scripts\randomloot\server.sqf";
};

moveObjective = {
    [] call moveTriggers;
    [] call moveMarkers;
    [] call randItemSpawn;
};

playerStart = {
    //Call player randomstart
    [] execVM "scripts\randomstart\server.sqf";
    [] execVM "scripts\randomstart\client.sqf";
};

respawnPlayers = {
    
};

// Doing AI implementation last
shouldSpawnAI = {false};
spawnAI = {};

firstObjective = {
    _nextLoc = selectRandom _objLocations;
    _nextType = selectRandom _objTypes;
    
    [_nextLoc, _nextType] call moveObjective;
    
    [] call playerStart;
};

completedObjective = {
    // Delete old AI specifically. Not sure if anything else needs to happen yet.
    [] call cleanOldObjective;
    
    _nextLoc = [] call nextObjectiveLocation;
    _nextType = [] call nextObjectiveType;
    
    [_nextLoc, _nextType] call moveObjective;
    
    /* Not respawning players yet
    if (deadPlayers > 0) then {
        [] call respawnPlayers;
    };*/
    
    // Only some objective types use AI
    if ([] call shouldSpawnAI) then {
        [] call spawnAI;
    };
};