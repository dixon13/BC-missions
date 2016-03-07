if (!isServer) exitWith {};

_probability   = 100; // default 100: probability of loot spawning in %
_maxItemSpawns = 100; // default 8: max amount of spawns per building, which is limited by buildingpos number

// Show loot marker on map for debugging
_showLootType   = false;
_showLootRarity = false;

// struct to be able to set individual probabilities under a class of rarity.
// eventually we won't need classes of rarity because everything has it's own.
/*
itemsStructure = [
    [80, ["name", "type"]],
    [20, ["name", "type"]]
];
*/

// Probability of each class of item being spawned. Should total 100.
rarityHighlyCommon   = 30;
rarityCommon         = 38;
rarityUncommon       = 11;
rarityHighlyUncommon = 11;
rarityRare           = 7;
rarityExtremelyRare  = 3;

// Determine what rarity class this item fits into
minusCommon         = rarityHighlyCommon  + rarityCommon;
minusUncommon       = minusCommon         + rarityUncommon;
minusHighlyUncommon = minusUncommon       + rarityHighlyUncommon;
minusRare           = minusHighlyUncommon + rarityRare;
minusExtremelyRare  = minusRare           + rarityExtremelyRare;

itemsHighlyCommon = [
    ["Binocular", "item"],
    ["FirstAidKit", "item"],
    ["B_AssaultPack_blk", "backpack"],
    ["B_Carryall_mcamo", "backpack"],
    ["B_FieldPack_blk", "backpack"],
    ["MNP_B_ROK_KB", "backpack"],
    ["MNP_B_RU1_FP", "backpack"],
    ["Chemlight_green", "item"],
    ["Chemlight_blue", "item"],
    ["Chemlight_red", "item"],
    ["Chemlight_yellow", "item"],
    ["MNP_Vest_USMC_Xtreme_A", "vest"],
    ["MNP_Vest_UKR_A", "vest"],
    ["acc_flashlight", "item"],
    ["rhs_acc_2dpZenit", "item"]
];

itemsCommon = [
    ["rhs_mag_30Rnd_556x45_Mk318_Stanag", "mag"],
    ["rhs_30Rnd_762x39mm", "mag"]
];

itemsUncommon = [
    ["Rangefinder", "item"],
    ["ToolKit", "item"],
    ["MediKit", "item"],
    ["ItemGPS", "item"],
    ["rhs_acc_pso1m2", "item"],
    ["rhsusf_acc_rotex5_grey", "item"],
    ["rhsusf_acc_ACOG_USMC", "item"],
    ["rhsusf_acc_harris_bipod", "item"],
    ["SmokeShell", "item"],
    ["HandGrenade", "item"],
    ["MiniGrenade", "item"]
];

itemsHighlyUncommon = [
    ["rhs_weap_ak103", "weapon"],
    ["rhs_weap_akm", "weapon"],
    ["rhs_weap_akms", "weapon"],
    ["rhs_weap_m4_carryhandle", "weapon"],
    ["rhs_weap_m4a1_carryhandle", "weapon"],
    ["rhs_weap_m16a4_carryhandle", "weapon"]
];

itemsRare = [
    ["NVGoggles", "item"],
    ["rhs_10Rnd_762x54mmR_7N1", "mag"],
    ["rhsusf_100Rnd_556x45_M200_soft_pouch", "mag"],
    ["rhs_100Rnd_762x54mmR", "mag"]
];

itemsExtremelyRare = [
    ["rhs_weap_M136_hedp", "weapon"],
    ["rhs_weap_svd", "weapon"],
    ["rhs_weap_m249_pip_L", "weapon"],
    ["rhs_weap_pkp", "weapon"]
];

// Exclude buildings from loot spawn. Use 'TYPEOF' to find building name
_exclusionList=[];
//["Land_Pier_F","Land_Pier_small_F","Land_NavigLight","Land_LampHarbour_F"];

private ["_distance","_houseList"];
_mkr = (_this select 0);
_mkr setmarkerAlpha 0;
_pos = markerpos _mkr;
_mkrY= getmarkerSize _mkr select 0;
_mkrX= getmarkerSize _mkr select 1;

_distance = _mkrX;
if (_mkrY > _mkrX) then {
	_distance=_mkrY;
};

 _houseList= _pos nearObjects ["House",_distance];
 _numHouses = count _houseList;
{ // foreach in _houseList
    _spawnCheck = false;
    if (400 > random _numHouses) then {_spawnCheck=true};
    if (_spawnCheck) then {
    _house=_X;

	if (!(typeOf _house in _exclusionList)) then {
        // Using sizeOf
        _buildingSize = sizeOf (typeOf _house);
        _numItemSpawns = _buildingSize;
        
        if (_numItemSpawns > _maxItemSpawns) then {_numItemSpawns = _maxItemSpawns};
        
		for "_n" from 1 to _numItemSpawns do {
			_buildingPos = _house buildingPos _n;
            
			if (str _buildingPos == "[0,0,0]") exitwith {};
				if (_probability > random 100) then {
					[_buildingPos, _buildingSize, _showLootType, _showLootRarity] execVM "scripts\randomloot\spawnLoot.sqf";
				};
			};
		};
    };
} foreach _houseList;