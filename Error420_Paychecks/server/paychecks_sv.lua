Qbox = exports.qbx_core

lib.callback.register('Error420_Paychecks:redeem', function(source)
    local paycheckItem = Config.PaycheckItem
    local player = exports.qbx_core:GetPlayer(source)

    if not player then
        return false, 'Error retrieving player data!'
    end

    local paychecks = exports.ox_inventory:GetInventoryItems(source, paycheckItem)

    if not paychecks or #paychecks == 0 then
        return false, 'You have no paychecks to cash in!'
    end

    local totalPay = 0
    local paycheckCount = 0

    for _, paycheck in pairs(paychecks) do
        if paycheck.metadata and paycheck.metadata.amount then
            totalPay = totalPay + paycheck.metadata.amount
            paycheckCount = paycheckCount + 1
            exports.ox_inventory:RemoveItem(source, paycheckItem, 1)
        end
    end

    if paycheckCount > 0 then
        player.Functions.AddMoney('bank', totalPay)
        return true, ('You cashed in %d paycheck(s) for $%s'):format(paycheckCount, totalPay)
    else
        return false, 'Invalid paycheck data!'
    end
end)

RegisterNetEvent('Error420_Paychecks:givePaycheck')
AddEventHandler('Error420_Paychecks:givePaycheck', function(source)
    local paycheckItem = Config.PaycheckItem
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return end

    local jobData = player.PlayerData.job
    local amountPerCheck = jobData and jobData.payment

    if amountPerCheck and amountPerCheck > 0 then
        exports.ox_inventory:AddItem(source, paycheckItem, 1, {
            job = jobData.name,
            amount = amountPerCheck
        })
    end
end)