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

#include "randomstart\settings.sqf";

if (!isServer) exitWith {};

_sizeOfSpawnAO = 500;
_minDistBetweenSpawn = 200;

// Array of "Locations": [name, size, pos, angle]
_objLocations = [
    ["Abdera",          [160,160], [9428.6553,20241.711], 0],
    
    ["Kore",            [150,150], [7156.0981,16473.186], 0],
    ["Negades",         [200,150], [4915.6445,16181.08],  0],
    ["Poliakko",        [200,200], [10955.016,13446.202], 0],
    ["Alikampos",       [150,150], [11135.173,14554.855], 0],
    
    ["Lakka",           [300,300], [12399.981,15723.699], 0],
    ["Telos",           [275,175], [16360.756,17247.285], 0],
    ["Charkia",         [250,200], [18129.295,15239.145], 0],
    
    ["Agios Dionysios", [460,230], [9372.5176,15907.256], 345],
    
    ["Frini",           [175,175], [14630.977,20801.369], 0]
];

/* Altis Locations

//Not good enough yet
["Aggelochori",     [300,300], [3822.207,13685.973],  0],
["Agia Triada",     [50,200],  [16617.021,20575.688], 323],
["Topolia",         [75,150],  [7378.4136,15335.224], 0],
["Katalaki",        [150,150], [11761.309,13712.03],  0],
*/

/* United Sahrani Locations
    ["Arcadia", [200, 250], [7622.8159, 6435.5762], 320]
    ["Eponia", [500, 500], [12585.727, 15133.22], 0]
*/

// Array of "Objective Types": ["name"]
_objTypes = [
    ["Hold"]
];

/* Incomplete Objectives
    ["Steal"],
    ["Destroy"],
    ["Hold"]
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

moveTriggersAndMarkers = {
    private ["_nextLoc","_objPos","_nextType","_typeName"];
    _nextLoc = _this select 0;
    _objPos = _this select 1;
    
    _nextType = _this select 2;
    _typeName = _nextType select 0;
    
    _3dObjPos = [_objPos select 0, _objPos select 1, 0];
    objBlue setPos _3dObjPos;
    //objBlue setSize [50,50];
    objRed setPos _3dObjPos;
    objGreen setPos _3dObjPos;
    objPurple setPos _3dObjPos;
    objBlueSeize setPos _3dObjPos;
    objRedSeize setPos _3dObjPos;
    objGreenSeize setPos _3dObjPos;
    objPurpleSeize setPos _3dObjPos;
    
    _objMarker = "objMarker";
    _objMarker setMarkerPos _objPos;
    _objMarker setMarkerText _typeName;
    
    _objHold = "objHold";
    _objHold setMarkerPos _objPos;
    _objHold setMarkerColor "ColorUNKNOWN";
    
};

randItemSpawn = {
    _nextLoc = _this select 0;
    _locSize = _nextLoc select 1;
    _locPos = _nextLoc select 2;
    _itemSpawnMarker = "randItemsMarker";
    
    // Move the randomloot marker
    //_itemSpawnPos = getMarkerPos _itemSpawnMarker;
    _itemSpawnMarker setMarkerPos _locPos;
    _itemSpawnMarker setMarkerSize [_sizeOfSpawnAO,_sizeOfSpawnAO];//_locSize;
    
    //Call item randomloot
    [_itemSpawnMarker] execVM "scripts\randomloot\server.sqf";
};

moveObjective = {
    private ["_nextLoc","_nextType","_locSize","_locPos","_typeName"];
    _nextLoc = _this select 0;
    _nextType = _this select 1;
    _locSize = _nextLoc select 1;
    _locPos = _nextLoc select 2;
    _typeName = _nextType select 0;
    
    _objAreaMarker = "objAreaMarker";
    _objAreaMarker setMarkerPos _locPos;
    _objAreaMarker setMarkerSize [(_locSize select 0)*0.1, (_locSize select 1)*0.1];
    _objPos = [_objAreaMarker, false] call CBA_fnc_randPosArea;
    
    [_nextLoc, _objPos, _nextType] call moveTriggersAndMarkers;
    
    _locName = _nextLoc select 0;
};

checkRandomStartPos = {
    private ["_pos","_placedPos","_check","_checkWater"];
    _pos = _this select 0;
    _placedPos = _this select 1;
    
    _check = false;
    // Fail check if pos is in water
    _checkWater = !(surfaceIsWater _pos);
    
    // Fail check if pos is too close to other markers
    _checkDist = true;
    {
        _placed = _x;
        _dist = _placed distance2D _pos;
        // 
        if (_dist < _minDistBetweenSpawn) exitWith {_checkDist=false};
    } forEach _placedPos;
    
    // AND all checks together; all must be true for check to pass
    _check = _checkWater && _checkDist; 
    _check
};

playerStart = {
    private ["_nextLoc","_locPos","_marker","_randomPos"];
    _nextLoc = _this select 0;
    _locPos = _nextLoc select 2;
    
    //Move the random start markers around the perim. of the AO (800m circle around the _nextLoc position)
    _objAreaMarker = "objAreaMarker";
    _objAreaMarker setMarkerPos _locPos;
    _objAreaMarker setMarkerSize [_sizeOfSpawnAO, _sizeOfSpawnAO];
    //_objAreaMarker setMarkerAlpha 0;
    
    _placedMarkerPos = [];
    {
        _marker = _x;
        _check = false;
        
        // Continually try a new randomPos until checkRandomStartPos returns true
        while { !_check } do {
            _randomPos = [_objAreaMarker, true] call CBA_fnc_randPosArea;
            _check = [_randomPos, _placedMarkerPos] call checkRandomStartPos;
        };
        
        // Found a good random pos
        _marker setMarkerPos _randomPos;
        
        // Keep that marker pos for further checks
        _placedMarkerPos pushBack _randomPos;
        
    } forEach _markerArrayWest;
    
    // All markers are randomly set...
    
    // Call player randomstart
    [] execVM "scripts\randomstart\server.sqf";
};

respawnPlayers = {
    
};

// Doing AI implementation last
shouldSpawnAI = {false};
spawnAI = {};

completedObjective = {
    private ["_nextLoc","_nextType"];
    // Delete old AI specifically. Not sure if anything else needs to happen yet
    [] call cleanOldObjective;
    
    _nextLoc = [] call nextObjectiveLocation;
    _nextType = [] call nextObjectiveType;
    
    [_nextLoc, _nextType] call moveObjective;
    
    /* Not respawning players yet
    if (deadPlayers > 0) then {
        [_nextLoc, _nextType] call respawnPlayers;
    };*/
    
    // Only some objective types use AI
    if ([] call shouldSpawnAI) then {
        [] call spawnAI;
    };
    
    // Spawn items last because it may take some time...
    [_nextLoc] call randItemSpawn;
};

// On loading of the map, this func will run
firstObjective = {
    private ["_nextLoc","_nextType"];
    _nextLoc = selectRandom _objLocations;
    _nextType = selectRandom _objTypes;
    
    [_nextLoc, _nextType] call moveObjective;
    [_nextLoc] call playerStart;
    
    // Spawn items last because it may take some time...
    [_nextLoc] call randItemSpawn;
};

[] call firstObjective;