ESX = nil TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('wheelfucker', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('n_flattire:makeflattire', source, 10000)
end)

RegisterServerEvent('n_flattire:removeitem')
AddEventHandler('n_flattire:removeitem', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('wheelfucker', 1)
end)