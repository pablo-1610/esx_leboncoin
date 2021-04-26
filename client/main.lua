ESX = nil
canInteract = true


Citizen.CreateThread(function()
    TriggerEvent("esx:getSharedObject", function(obj)
        ESX = obj
    end)
    while ESX == nil do Wait(1) end
    -- Initialisation du blip
    local blip = AddBlipForCoord(Config.position.x, Config.position.y, Config.position.z)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 28)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Leboncoin")
    EndTextCommandSetBlipName(blip)
    -- Initialisation de la zone d'interaction
    while true do
        local interval = 250
        local playerPos = GetEntityCoords(PlayerPedId())
        local zone = Config.position
        local distance = #(playerPos - zone)
        if distance <= Config.drawDist then
            interval = 0
            DrawMarker(22, zone.x, zone.y, zone.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 99, 66, 245, 255, 55555, false, true, 2, false, false, false, false)
            if distance <= 1.0 then
                if canInteract then
                    AddTextEntry("LBC", "Appuyez sur ~INPUT_CONTEXT~ pour accéder à \"~y~Le bon coin~s~\"")
                    DisplayHelpTextThisFrame("LBC", 0)
                    if IsControlJustPressed(0, 51) then
                        canInteract = false
                        TriggerServerEvent("esx_leboncoin:interact")
                    end
                end
            end
        end
        Wait(interval)
    end
end)