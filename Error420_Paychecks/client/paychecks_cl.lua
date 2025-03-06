for _, bank in ipairs(Config.Banks) do
    exports.ox_target:addBoxZone({
        coords = bank.coords,
        size = vec3(1.5, 1.5, 1.0),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'paycheck_cash',
                event = 'Error420_Paychecks:cash',
                icon = 'fa-solid fa-money-bill',
                label = 'Cash Paycheck'
            }
        }
    })
end

RegisterNetEvent('Error420_Paychecks:cash', function()
    lib.callback('Error420_Paychecks:redeem', false, function(success, message)
        if message then
            lib.notify({
                title = 'Paycheck',
                description = message,
                type = success and 'success' or 'error'
            })
        end
    end)
end)

RegisterNetEvent('Error420_Paychecks:notifyPolice', function()
    if Config.Dispatch == 'ps-dispatch' then
        exports['ps-dispatch']:SuspiciousActivity()
    elseif Config.Dispatch == 'stevo_cad' then
        local data = {
            caller = 'ESTA',
            coords = cache.coords,
            priority = "A",
            callmessage = "Paycheck Fruad",
            cadmessage = "Someone attempted to cash in a fraudulent paycheck"
        }
        exports['stevo_cad']:dispatch(data)
    elseif Config.Dispatch == 'custom' then
        -- Custom dispatch logic here
    end
end)

CreateThread(function()
    while not exports.ox_inventory do Wait(100) end

    exports.ox_inventory:displayMetadata({
        amount = 'Paycheck Value $',
        job = 'Job',
        owner = 'Owner'
    })
end)