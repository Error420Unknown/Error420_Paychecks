Qbox = exports.qbx_core

lib.callback.register('Error420_Paychecks:redeem', function(source)
    local paycheckItem = Config.PaycheckItem
    local player = Qbox:GetPlayer(source)

    if not player then
        return false, 'Error retrieving player data!'
    end

    local playerName = ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
    
    local paychecks = exports.ox_inventory:GetInventoryItems(source, paycheckItem)

    if not paychecks or #paychecks == 0 then
        return false, 'You have no paychecks to cash in!'
    end

    local totalPay = 0
    local paycheckCount = 0

    for index, paycheck in ipairs(paychecks) do
        local meta = paycheck.metadata
        
        if meta and type(meta.amount) == "number" and type(meta.owner) == "string" then
            if meta.owner ~= playerName then
                TriggerClientEvent('Error420_Paychecks:notifyPolice', source)
                return false, 'Attempted fraud detected. Police notified.'
            end
    
            if meta.amount < 0 or meta.amount > 10000 then
                return false, 'Suspicious paycheck detected. Contact staff.'
            end
    
            totalPay = totalPay + meta.amount
            paycheckCount = paycheckCount + 1
        end
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
    local player = Qbox:GetPlayer(src)

    if not player or not player.PlayerData.job then 
        return 
    end

    local jobData = player.PlayerData.job
    local amountPerCheck = jobData.payment or 0

    if amountPerCheck <= 0 or amountPerCheck > 10000 then
        return
    end

    local metadata = {
        job = jobData.name,
        amount = amountPerCheck,
        owner = ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
    }

    exports.ox_inventory:AddItem(src, Config.PaycheckItem, 1, metadata)
end)

local function discordprint()
    SetTimeout(2000, function()
        print('^5[INFO]^0 Discord: https://discord.gg/uKPFaNNHD4')
    end)
end
CreateThread(discordprint)

lib.versionCheck('Error420Unknown/Error420_Paychecks')