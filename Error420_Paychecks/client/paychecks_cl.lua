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

RegisterNetEvent('Error420_Paychecks:cash')
AddEventHandler('Error420_Paychecks:cash', function()
    lib.callback('Error420_Paychecks:redeem', false, function(success, message)
        print("[DEBUG] Callback Response:", success, message)
        if message then
            lib.notify({
                title = 'Paycheck',
                description = message,
                type = success and 'success' or 'error'
            })
        end
    end)
end)