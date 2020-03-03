ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local mincash = 5000 -- minimum amount of cash a pile holds
local maxcash = 10000 -- maximum amount of cash a pile can hold
local black = false -- enable this if you want blackmoney as a reward
local mincops = 0 -- minimum required cops to start mission
local enablesound = true -- enables bank alarm sound
local lastrobbed = 0 -- don't change this
local cooldown = 1800 -- amount of time to do the heist again in seconds (30min)
local info = {stage = 0, style = nil, locked = false}
local totalcash = 0
local PoliceDoors = {
    {loc = vector3(257.10, 220.30, 106.28), txtloc = vector3(257.10, 220.30, 106.28), model = "hei_v_ilev_bk_gate_pris", model2 = "hei_v_ilev_bk_gate_molten", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(236.91, 227.50, 106.29), txtloc = vector3(236.91, 227.50, 106.29), model = "v_ilev_bk_door", model2 = "v_ilev_bk_door", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(262.35, 223.00, 107.05), txtloc = vector3(262.35, 223.00, 107.05), model = "hei_v_ilev_bk_gate2_pris", model2 = "hei_v_ilev_bk_gate2_pris", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(252.72, 220.95, 101.68), txtloc = vector3(252.72, 220.95, 101.68), model = "hei_v_ilev_bk_safegate_pris", model2 = "hei_v_ilev_bk_safegate_molten", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(261.01, 215.01, 101.68), txtloc = vector3(261.01, 215.01, 101.68), model = "hei_v_ilev_bk_safegate_pris", model2 = "hei_v_ilev_bk_safegate_molten", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(253.92, 224.56, 101.88), txtloc = vector3(253.92, 224.56, 101.88), model = "v_ilev_bk_vaultdoor", model2 = "v_ilev_bk_vaultdoor", obj = nil, obj2 = nil, locked = true}
}
ESX.RegisterServerCallback("utk_oh:GetData", function(source, cb)
    cb(info)
end)
ESX.RegisterServerCallback("utk_oh:GetDoors", function(source, cb)
    cb(PoliceDoors)
end)
ESX.RegisterServerCallback("utk_oh:startevent", function(source, cb, method)
    local xPlayers = ESX.GetPlayers()
    local copcount = 0
    local yPlayer = ESX.GetPlayerFromId(source)

    if not info.locked then
        if (os.time() - cooldown) > lastrobbed then
            for i = 1, #xPlayers, 1 do
                local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

                if xPlayer then
                    if xPlayer.job.name == "police" then
                        copcount = copcount + 1
                    end
                end
            end
            if copcount >= mincops then
                if method == 1 then
                    local item = yPlayer.getInventoryItem("thermal_charge")["count"]

                    if item >= 1 then
                        yPlayer.removeInventoryItem("thermal_charge", 1)
                        cb(true)
                        info.stage = 1
                        info.style = 1
                        info.locked = true
                    else
                        cb("You don't have any thermal charges.")
                    end
                elseif method == 2 then
                    local item = yPlayer.getInventoryItem("lockpick")["count"]

                    if item >= 1 then
                        yPlayer.removeInventoryItem("lockpick", 1)
                        info.stage = 1
                        info.style = 2
                        info.locked = true
                        cb(true)
                    else
                        cb("You don't have any lockpicks.")
                    end
                end
            else
                cb("There must be at least "..mincops.." police in the city.")
            end
        else
            cb(math.floor((cooldown - (os.time() - lastrobbed)) / 60)..":"..math.fmod((cooldown - (os.time() - lastrobbed)), 60).." left until the next robbery.")
        end
    else
        cb("Bank is currently being robbed.")
    end
end)
ESX.RegisterServerCallback("utk_oh:checkItem", function(source, cb, itemname)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(itemname)["count"]

    if item >= 1 then
        cb(true)
    else
        cb(false)
    end
end)
ESX.RegisterServerCallback("utk_oh:gettotalcash", function(source, cb)
    cb(totalcash)
end)
RegisterServerEvent("utk_oh:removeitem")
AddEventHandler("utk_oh:removeitem", function(itemname)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeInventoryItem(itemname, 1)
end)
RegisterServerEvent("utk_oh:updatecheck")
AddEventHandler("utk_oh:updatecheck", function(var, status)
    TriggerClientEvent("utk_oh:updatecheck_c", -1, var, status)
end)
--[[RegisterServerEvent("utk_oh:toggleDoor")
AddEventHandler("utk_oh:toggleDoor", function(door, coords, status)
    TriggerClientEvent("utk_oh:toggleDoor_c", -1, door, coords, status)
end)]]
RegisterServerEvent("utk_oh:policeDoor")
AddEventHandler("utk_oh:policeDoor", function(doornum, status)
    PoliceDoors[doornum].locked = status
    TriggerClientEvent("utk_oh:policeDoor_c", -1, doornum, status)
end)
RegisterServerEvent("utk_oh:moltgate")
AddEventHandler("utk_oh:moltgate", function(x, y, z, oldmodel, newmodel, method)
    TriggerClientEvent("utk_oh:moltgate_c", -1, x, y, z, oldmodel, newmodel, method)
end)
RegisterServerEvent("utk_oh:fixdoor")
AddEventHandler("utk_oh:fixdoor", function(hash, coords, heading)
    TriggerClientEvent("utk_oh:fixdoor_c", -1, hash, coords, heading)
end)
RegisterServerEvent("utk_oh:openvault")
AddEventHandler("utk_oh:openvault", function(method)
    TriggerClientEvent("utk_oh:openvault_c", -1, method)
end)
RegisterServerEvent("utk_oh:startloot")
AddEventHandler("utk_oh:startloot", function()
    TriggerClientEvent("utk_oh:startloot_c", -1)
end)
RegisterServerEvent("utk_oh:rewardCash")
AddEventHandler("utk_oh:rewardCash", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local reward = math.random(mincash, maxcash)

    if black then
        xPlayer.addAccountMoney("black_money", reward)
        totalcash = totalcash + reward
    else
        xPlayer.addMoney(reward)
        totalcash = totalcash + reward
    end
end)
RegisterServerEvent("utk_oh:rewardGold")
AddEventHandler("utk_oh:rewardGold", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.addInventoryItem("gold_bar", 1)
end)
RegisterServerEvent("utk_oh:rewardDia")
AddEventHandler("utk_oh:rewardDia", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.addInventoryItem("dia_box", 1)
end)
RegisterServerEvent("utk_oh:giveidcard")
AddEventHandler("utk_oh:giveidcard", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.addInventoryItem("id_card", 1)
end)
RegisterServerEvent("utk_oh:ostimer")
AddEventHandler("utk_oh:ostimer", function()
    lastrobbed = os.time()
    info.stage, info.style, info.locked = 0, nil, false
    Citizen.Wait(300000)
    totalcash = 0
    TriggerClientEvent("utk_oh:reset", -1)
end)
RegisterServerEvent("utk_oh:gas")
AddEventHandler("utk_oh:gas", function()
    TriggerClientEvent("utk_oh:gas_c", -1)
end)
RegisterServerEvent("utk_oh:ptfx")
AddEventHandler("utk_oh:ptfx", function(method)
    local xPlayers = ESX.GetPlayers()

    for i = 1, #xPlayers, 1 do -- This don't work as I expected :/ But works anyway...
        if xPlayers[i] ~= source then
            TriggerClientEvent("utk_oh:ptfx_c", xPlayers[i], method)
        end
    end
end)
RegisterServerEvent("utk_oh:alarm_s")
AddEventHandler("utk_oh:alarm_s", function(toggle)
    if enablesound then
        TriggerClientEvent("utk_oh:alarm", -1, toggle)
    end
    TriggerClientEvent("utk_oh:policenotify", -1, toggle)
end)
