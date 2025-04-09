Qbox = exports.qbx_core

lib.callback.register('Error420_Paychecks:redeem', function(source)
    local paycheckItem = Config.PaycheckItem
    local player = exports.qbx_core:GetPlayer(source)

    if not player then
        return false, 'Error retrieving player data!'
    end

    local playerName = ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
    local paychecks = exports.ox_inventory:GetInventoryItems(source, paycheckItem) or {}

    if #paychecks == 0 then
        return false, 'You have no paychecks to cash in!'
    end

    local totalPay = 0
    local paycheckCount = 0

    for _, paycheck in ipairs(paychecks) do
        local meta = paycheck.metadata

        if not meta or type(meta.amount) ~= "number" or type(meta.owner) ~= "string" then
            return false, 'Invalid paycheck metadata! Contact staff.'
        end

        if meta.owner ~= playerName then
            TriggerClientEvent('Error420_Paychecks:notifyPolice', source)
            print(('[SECURITY] Player %s (%d) tried to redeem a stolen paycheck.'):format(playerName, source))
            return false, 'Attempted fraud detected. Police notified.'
        end

        if meta.amount < 0 or meta.amount > 10000 then
            return false, 'Suspicious paycheck detected. Contact staff.'
        end

        totalPay = totalPay + meta.amount
        paycheckCount = paycheckCount + 1
    end

    if paycheckCount > 0 then
        exports.ox_inventory:RemoveItem(source, paycheckItem, paycheckCount)
        player.Functions.AddMoney('bank', totalPay)
        return true, ('You cashed in %d paycheck(s) for $%s'):format(paycheckCount, totalPay)
    end

    return false, 'No valid paychecks found to cash in!'
end)

RegisterNetEvent('Error420_Paychecks:givePaycheck', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if not player or not player.PlayerData.job then return end

    local jobData = player.PlayerData.job
    local amountPerCheck = jobData.payment or 0

    if amountPerCheck <= 0 or amountPerCheck > 10000 then
        print(('[SECURITY] Invalid paycheck value for %s (%d): $%s'):format(player.PlayerData.charinfo.firstname, src, amountPerCheck)) -- Log issue
        return
    end

    local metadata = {
        job = jobData.name,
        amount = amountPerCheck,
        owner = ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
    }

    exports.ox_inventory:AddItem(src, Config.PaycheckItem, 1, metadata)
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