Qbox = exports.qbx_core

lib.callback.register('Error420_Paychecks:redeem', function(source)
    local paycheckItem = Config.PaycheckItem
    local player = exports.qbx_core:GetPlayer(source)

    if not player then
        return false, 'Error retrieving player data!'
    end

    local jobData = player.PlayerData.job
    local amountPerCheck = jobData and jobData.payment

    if not amountPerCheck or amountPerCheck <= 0 then
        return false, 'Invalid paycheck amount in job!'
    end

    local paycheck = exports.ox_inventory:GetItem(source, paycheckItem)

    if paycheck and paycheck.count > 0 then
        local totalPay = paycheck.count * amountPerCheck
        exports.ox_inventory:RemoveItem(source, paycheckItem, paycheck.count)
        player.Functions.AddMoney('bank', totalPay)

        return true, ('You cashed in %d paycheck(s) for $%s'):format(paycheck.count, totalPay)
    else
        return false, 'You have no paychecks to cash in!'
    end
end)