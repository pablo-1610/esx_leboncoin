local ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

local function getLicense(source)
    for k,v in pairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("license:")) == "license:" then
        return v
        end

    end
    return ""
end

RegisterNetEvent("esx_leboncoin:buyOffer")
AddEventHandler("esx_leboncoin:buyOffer", function(plate, authorLicense)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentMoney = xPlayer.getAccount('bank').money

    MySQL.Async.fetchAll("SELECT * FROM esx_leboncoin WHERE license = @a AND plate = @b", {['a'] = authorLicense, ['b'] = plate}, function(result)
        if result[1] then
            local offer = result[1]
            local price = offer.price
            if currentMoney > price then 
                xPlayer.removeAccountMoney("bank", price)
                MySQL.Async.execute("DELETE FROM esx_leboncoin WHERE license = @a AND plate = @b", {['a'] = authorLicense, ['b'] = plate}, function()
                    MySQL.Async.insert("INSERT INTO owned_vehicles (vehicle, owner, stored, plate) VALUES(@a,@b,1,@c)", {
                        ['a'] = offer.model,
                        ['b'] = xPlayer.identifier,
                        ['c'] = offer.plate,
                    }, function(insertId)
                        TriggerClientEvent("esx_leboncoin:serverReturnStatusBuy", source, 1)
                        local xPlayers = ESX.GetPlayers()
                        for i=1, #xPlayers, 1 do
                            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                            if xPlayer.identifier == offer.license then
                                TriggerClientEvent("esx:showNotification", xPlayers[i], "~g~Félicitations ! ~s~Vous remportez un total de ~g~"..ESX.Math.GroupDigits(offer.price).."$ ~s~pour la vente de votre véhicule (~b~"..offer.plate.."~s~)")
                                xPlayer.addAccountMoney("bank",offer.price)
                                return
                            end
                        end
                        MySQL.Async.execute("SELECT accounts FROM users WHERE identifier = @a", {['a'] = offer.license}, function(result)
                            if result[1] then
                                local accounts = json.decode(result[1].accounts)
                                accounts.bank = accounts.bank + offer.price
                                MySQL.Async.execute("UPDATE users SET accounts = @a WHERE identifier = @b", {['a'] = json.encode(accounts), ['b'] = offer.license})
                            end
                        end)
                    end)
                end)
            else
                TriggerClientEvent("esx_leboncoin:serverReturnStatusBuy", source, 0)
                TriggerClientEvent("esx:showNotification", source, "~r~Vous n'avez pas assez d'argent pour payer ce véhicule")
            end
        else
            TriggerClientEvent("esx_leboncoin:serverReturnStatusBuy", source, 0)
        end
    end)
end)
local function getDate()
    return os.date("*t", os.time()).day.."/"..os.date("*t", os.time()).month.."/"..os.date("*t", os.time()).year.." à "..os.date("*t", os.time()).hour.."h"..os.date("*t", os.time()).min
end

RegisterNetEvent("esx_leboncoin:publishOffer")
AddEventHandler("esx_leboncoin:publishOffer", function(plate, builder)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local steam = xPlayer.identifier
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @a AND plate = @b", {['a'] = steam, ['b'] = plate}, function(result)
        if result[1] then
            local savedData = result[1]
            MySQL.Async.execute("DELETE FROM owned_vehicles WHERE owner = @a AND plate = @b", {['a'] = steam, ['b'] = plate}, function()
                MySQL.Async.insert("INSERT INTO esx_leboncoin (license, name, description, model, price, createdAt, plate) VALUES(@a,@b,@c,@d,@e,@f,@g)", {
                    ['a'] = steam,
                    ['b'] = GetPlayerName(source),
                    ['c'] = builder.description,
                    ['d'] = savedData.vehicle,
                    ['e'] = builder.price,
                    ['f'] = getDate(),
                    ['g'] = savedData.plate
                }, function(insertId)
                    TriggerClientEvent("esx_leboncoin:serverReturnStatus", source, 1)
                    TriggerClientEvent("esx:showNotification", source, ("~g~Votre offre porte le numéro unique ~y~%i"):format(insertId))
                end)
            end)
            
        else
            TriggerClientEvent("esx_leboncoin:serverReturnStatus", source, 0)
        end
    end)
end)

RegisterNetEvent("esx_leboncoin:interact")
AddEventHandler("esx_leboncoin:interact", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local source = source
    local busy = true
    local myVehicles = {}
    local availableVehicles = {}
    local function getIdentifier()
        local identifier = ""
        if Config.identifier == 1 then
            -- Steam
            identifier = xPlayer.getIdentifier()
        else
            -- License Rockstar
            identifier = getLicense(source)
        end
        return identifier
    end
    print(getIdentifier(source))
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @a", {['a'] = getIdentifier(source)}, function(result)
        myVehicles = result
        busy = false
    end)
    while busy do Wait(1) end
    busy = true
    MySQL.Async.fetchAll("SELECT * FROM esx_leboncoin", {}, function(result)
        availableVehicles = result
        busy = false
    end)
    while busy do Wait(1) end
    TriggerClientEvent("esx_leboncoin:cb", source, myVehicles, availableVehicles)
end)