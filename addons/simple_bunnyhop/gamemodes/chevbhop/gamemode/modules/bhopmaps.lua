module("bhopmaps", package.seeall)

local bhopMaps = {}

function Add(map, tb)
    print('Adding ' .. map .. ' to the bunnyhop map list')
    bhopMaps[map] = tb
end

function MapIsValid(map)
    if !bhopMaps[map] then return false end
    if !bhopMaps[map].StartLocation or !bhopMaps[map].StartLocation[1] or !bhopMaps[map].StartLocation[2] then return false end
    if !bhopMaps[map].EndLocation or !bhopMaps[map].EndLocation[1] or !bhopMaps[map].EndLocation[2] then return false end

    return true
end

function GetLocations(map)
    return bhopMaps[map]
end
