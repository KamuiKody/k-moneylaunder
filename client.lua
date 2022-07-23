local QBCore = exports["qb-core"]:GetCoreObject()
local pedSpawned = false

local function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(1)
    end
end

local listen = false
local function Listen4Control()
    CreateThread(function()
        listen = true
        while listen do
            if IsControlJustPressed(0, 38) then -- E
                exports["qb-core"]:KeyPressed()
                TriggerServerEvent("k-moneytrade:trademoney")
                listen = false
                break
            end
            Wait(1)
        end
    end)
end

local function createPeds()
    if pedSpawned then return end
    local current = 'ig_barry' --ped
    current = type(current) == 'string' and GetHashKey(current) or current
    RequestModel(current)
    while not HasModelLoaded(current) do
        Wait(0)
    end
    ShopPed = CreatePed(0, current, Config.location.x, Config.location.y, Config.location.z - 1, Config.location.w, false, false)
    FreezeEntityPosition(ShopPed, true)
    SetEntityInvincible(ShopPed, true)
    SetBlockingOfNonTemporaryEvents(ShopPed, true)
    if Config.UseTarget then
        exports['qb-target']:AddTargetEntity(ShopPed, {
            options = {
                {
                    label = 'Exchange Money',
                    icon = 'fa-solid fa-coins',
                    action = function()
                        QBCore.Functions.TriggerCallback("k-moneytrade:trademoney", function(cb)
                            if cb then
                                LoadAnim('mp_common')
                                TaskPlayAnim(PlayerPedId(), 'mp_common', 'givetake1_b', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
                            else
                                QBCore.Functions.Notify('You don\'t have any marked money.', 'error', 5000)
                            end
                        end)
                    end
                }
            },
            distance = 2.0
        })
    end
    pedSpawned = true
end

-- Threads
CreateThread(function()
    if not Config.UseTarget then
        local moneytrade = CircleZone:Create(vector3(Config.location.x, Config.location.y, Config.location.z), 3, {useZ = true})
        moneytrade:onPlayerInOut(function(isPointInside)
            if isPointInside then
                exports["qb-core"]:DrawText('Exchange Money')
                Listen4Control()
            else
                exports["qb-core"]:HideText()
            end
        end)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    createPeds()
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        createPeds()
    end
end)
