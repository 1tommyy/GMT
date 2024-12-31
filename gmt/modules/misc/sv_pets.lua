local petStoreCoords = vector3(559.2889, 2749.858, 42.85172)

local changeNamePrice = 60000

local petStore = {
    coords = petStoreCoords,
    changeNamePrice = changeNamePrice,
}

local ownedPets = {
    ["bear"] = {
        awaitingHealthReduction = false,
        name = "Bear",
        id = "bear",
        ownedSkills = {
            teleport = true,
        },
    },
}

-- Define disabled pet abilities (replace with actual abilities)
local disabledAbilities = {
    attack = false,
}

-- Trigger the client event to build pet configuration
AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    local user_id = GMT.getUserId(source)
    if first_spawn then
        petStore.ownedPets = ownedPets
        TriggerClientEvent('GMT:buildPetCFG', source, ownedPets, disabledAbilities, petStore) 
    end
end)

-- Handle receiving pet commands
RegisterServerEvent('GMT:receivePetCommand')
AddEventHandler("GMT:receivePetCommand", function(id, M, L, zz)
    local source = source
    local user_id = GMT.getUserId(source)
    -- Check if the player owns this pet
    TriggerClientEvent('GMT:receivePetCommand', source, M, L, zz)
end)

-- Handle starting pet attacks
RegisterServerEvent('GMT:startPetAttack')
AddEventHandler("GMT:startPetAttack", function(id, M, Y)
    local source = source
    local user_id = GMT.getUserId(source)
    -- Check if the player owns this pet and that attacks aren't disabled
    TriggerClientEvent('GMT:sendClientRagdollPet', Y, user_id, GMT.getPlayerName(GMT.getUserId(source)))
    TriggerClientEvent('GMT:startPetAttack', source, id)
end)

-- Create a command to toggle the pet menu (replace with actual permission checks)
RegisterCommand('pet', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id == 1 then
        TriggerClientEvent('GMT:togglePetMenu', source)
    end
end)
