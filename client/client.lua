local RSGCore = exports['rsg-core']:GetCoreObject()
local isLoggedIn = false
local walking = false
local leading = false
local playerjob = nil

-----------------------------------------------------------------------------------

AddEventHandler('RSGCore:Client:OnPlayerLoaded', function() -- Don't use this with the native method
    isLoggedIn = true
    PlayerData = RSGCore.Functions.GetPlayerData()
    playerjob = PlayerData.job.name
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function() -- Don't use this with the native method
    isLoggedIn = false
    PlayerData = {}
end)

RegisterNetEvent('RSGCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-----------------------------------------------------------------------------------

-- horse trainer (leading horse)
CreateThread(function()
    while true do
        Wait(1000)
        if playerjob == 'horsetrainer' then
            if Citizen.InvokeNative(0xDE4C184B2B9B071A, PlayerPedId()) then    -- walking
                walking = true
            else
                walking = false
            end
            if Citizen.InvokeNative(0xEFC4303DDC6E60D3, PlayerPedId()) then -- leading
                leading = true
            else
                leading = false
            end
            if walking == true and leading == true then
                Wait(Config.LeadingXpTime * 60 * 1000)
                --print('walking and leading')
                TriggerEvent('rsg-horsetrainer:client:updateXP')
            end
        end
    end
end)

-------------------------------------------------------------------------------

-- update horse xp
RegisterNetEvent('rsg-horsetrainer:client:updateXP',function()
    RSGCore.Functions.TriggerCallback('rsg-horsetrainer:server:GetActiveHorse', function(data)
        local ped = PlayerPedId()
        local activehorse = data.horseid
        local horsexp = data.horsexp
        if horsexp == 100 then
            RSGCore.Functions.Notify('horse fully trained', 'primary')
        else
            local newxp = horsexp + Config.XpIncrease
            TriggerServerEvent('rsg-horsetrainer:server:updateXP', newxp, activehorse)
        end
    end)
end)

-------------------------------------------------------------------------------