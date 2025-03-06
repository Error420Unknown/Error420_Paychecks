Qbox = exports.qbx_core

lib.callback.register('Error420_Paychecks:redeem', function(source)
    local paycheckItem = Config.PaycheckItem
    local player = exports.qbx_core:GetPlayer(source)

    if not player then
        return false, 'Error retrieving player data!'
    end

    local playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    local paychecks = exports.ox_inventory:GetInventoryItems(source, paycheckItem) or {}

    if #paychecks == 0 then
        return false, 'You have no paychecks to cash in!'
    end

    local totalPay = 0
    local paycheckCount = 0
    local invalidPaycheck = false

    for _, paycheck in ipairs(paychecks) do
        if not paycheck.metadata or not paycheck.metadata.amount or not paycheck.metadata.owner then
            invalidPaycheck = true
        elseif paycheck.metadata.owner ~= playerName then
            TriggerClientEvent('Error420_Paychecks:notifyPolice', source)
            return false, 'You tried to cash a stolen paycheck! The police have been notified.'
        else
            totalPay = totalPay + tonumber(paycheck.metadata.amount)
            paycheckCount = paycheckCount + 1
        end
    end

    if paycheckCount > 0 then
        exports.ox_inventory:RemoveItem(source, paycheckItem, paycheckCount)
        player.Functions.AddMoney('bank', totalPay)
        return true, ('You cashed in %d paycheck(s) for $%s'):format(paycheckCount, totalPay)
    elseif invalidPaycheck then
        return false, 'Some paychecks have invalid metadata! Contact an admin.'
    else
        return false, 'No valid paychecks found to cash in!'
    end
end)

RegisterNetEvent('Error420_Paychecks:givePaycheck', function(source)
    local player = exports.qbx_core:GetPlayer(source)

    if not player or not player.PlayerData.job then return end

    local jobData = player.PlayerData.job
    local paycheckItem = Config.PaycheckItem
    local amountPerCheck = jobData.payment or 0
    local playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname

    if amountPerCheck > 0 then
        local metadata = {
            job = jobData.name,
            amount = tonumber(amountPerCheck),
            owner = playerName
        }

        exports.ox_inventory:AddItem(source, paycheckItem, 1, metadata)
    end
end)

function NotifyPolice(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    TriggerClientEvent('Error420_Paychecks:notifyPolice', source)
end

local function discordprint()
    SetTimeout(2000, function()
        print('^5Discord: https://discord.gg/uKPFaNNHD4^0')
    end)
end
CreateThread(discordprint)

lib.versionCheck('Error420Unknown/Error420_Paychecks')