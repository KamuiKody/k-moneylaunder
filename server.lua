local QBCore = exports["qb-core"]:GetCoreObject()

QBCore.Functions.CreateCallback('k-moneytrade:trademoney', function(source, cb)
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    local items = Player.Functions.GetItemsByName('markedbills')
    local value = 0
    for i = 1,#items,1 do 
        local item = items[i]
        local worth = item.info.worth * item.amount
        --print(worth)
        if Player.Functions.RemoveItem('markedbills', item.amount, item.slot) then
            value = value + worth
        end
    end
    if value ~= 0 then
        local amt = math.floor((value * Config.value) * 1)
        if not Config.item then
            if Player.Functions.AddMoney('cash', amt) then
                cb(true)
                TriggerClientEvent('QBCore:Notify', src, 'You got $'..amt..'!', 'success') 
            else
                cb(false)   
            end
        else
            if Player.Functions.AddItem(Config.item, amt) then
                cb(true)
                TriggerClientEvent('QBCore:Notify', src, 'You got '..amt..' '..QBCore.Shared.Items[Config.item].label, 'success') 
            else
                cb(false)   
            end
        end
    else
        cb(false)   
    end
end)