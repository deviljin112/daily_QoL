ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- AFK Kick
RegisterServerEvent('afkkick:kickplayer')
AddEventHandler('afkkick:kickplayer', function()
	DropPlayer(source, _U('afk_kicked_message'))
end)


-- Commands
ESX.RegisterCommand('lookup', 'user', function(xPlayer, args, showError)

	xPlayer.triggerEvent("daily_QoL:lookup", args.id.name)

	end, false,	{help = "Get someones name from their server ID", validate = true, arguments = {
		{name = "id", help = "Player ID", type = 'player'}
	}
})

ESX.RegisterCommand('myid', 'user', function(xPlayer)

	xPlayer.triggerEvent("daily_QoL:myid")

	end, false,	{help = "Get your own ID number"
})

ESX.RegisterCommand('setgps', 'user', function(xPlayer, args, showError)

	xPlayer.triggerEvent('daily_QoL:setgps', args.x, args.y)

	end, false, {help = "Set a waypoint to specific coordinates", validate = true, arguments = {
		{name = "x", help = "Sets the \"x\" coordinate", type = "number"},
		{name = "y", help = "Sets the \"y\" coordinate", type = "number"}
	}
})

ESX.RegisterCommand('getpos', 'user', function(xPlayer, args, showError)

	xPlayer.triggerEvent('daily_QoL:getpos')

	end, false, {help = "Get your current position"
})

ESX.RegisterCommand('tpm', 'user', function(xPlayer, args, showError)

	xPlayer.triggerEvent('daily_QoL:tpwaypoint')

	end, false, {help = "Teleport to your current waypoint"
})

ESX.RegisterCommand('shuff', 'user', function(xPlayer)

	xPlayer.triggerEvent("daily_QoL:shuffle")

	end, false, {help = "Seat Shuffle"
})