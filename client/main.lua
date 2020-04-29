local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(50)
	end
end)

-- Vehicle Anti Flip // Anti Air Control
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)

		local ped = GetPlayerPed(-1)
		local veh = GetVehiclePedIsIn(ped)
		if DoesEntityExist(veh) then
			disableAirControl(ped, veh)
			disableVehicleRoll(ped, veh)
		end
	end
end)

function disableAirControl(ped, veh)
	if IsPedSittingInAnyVehicle(ped) then
		if GetPedInVehicleSeat(veh, -1) == ped then
			if IsEntityInAir(veh) then
				DisableControlAction(0, 59)
				DisableControlAction(0, 60)
			end
		end
	end
end

function disableVehicleRoll(ped, veh)
	local roll = GetEntityRoll(veh)

	if GetPedInVehicleSeat(veh, -1) == ped then
		if (roll > 75.0 or roll < -75.0) then
			DisableControlAction(2,59,true)
			DisableControlAction(2,60,true)
		end
	end
end

-- Player // ID Lookup
RegisterNetEvent('daily_QoL:lookup')
AddEventHandler('daily_QoL:lookup', function(playerName)
	ESX.ShowNotification(_U('commands_lookup') .. playerName)
end)

RegisterNetEvent('daily_QoL:myid')
AddEventHandler('daily_QoL:myid', function()
	local player = GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1)))

	ESX.ShowNotification(_U('commands_getid') .. player)
end)


-- AFK Kick
local afkTimeout = Config.AFKTime -- AFK kick time limit in seconds
local timer = 0

local currentPosition  = nil
local previousPosition = nil
local currentHeading   = nil
local previousHeading  = nil

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)

		playerPed = PlayerPedId()
		if playerPed then
			currentPosition = GetEntityCoords(playerPed, true)
			currentHeading  = GetEntityHeading(playerPed)

			if currentPosition == previousPosition and currentHeading == previousHeading then
				if timer > 0 then
					if timer == math.ceil(afkTimeout / 4) then
						TriggerEvent('chat:addMessage', { args = { _U('afk'), _U('afk_warning', timer) } })
					end

					timer = timer - 1
				else
					TriggerServerEvent('afkkick:kickplayer')
				end
			else
				timer = afkTimeout
			end

			-- (always) update variables
			previousPosition = currentPosition
			previousHeading  = currentHeading
		end
	end
end)


-- Cant steal NPC cars
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(800)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

        if vehicle and DoesEntityExist(vehicle) then
            local driverPed = GetPedInVehicleSeat(vehicle, -1)

            if GetVehicleDoorLockStatus(vehicle) == 7 then
                SetVehicleDoorsLocked(vehicle, 2)
            end

            if driverPed and DoesEntityExist(driverPed) then
                SetPedCanBeDraggedOut(driverPed, false)
            end
        end
    end
end)


-- Disable police dont spawn
Citizen.CreateThread(function()
    SetCreateRandomCops(false) -- disable random cops walking/driving around
    SetCreateRandomCopsNotOnScenarios(false) -- stop random cops (not in a scenario) from spawning
    SetCreateRandomCopsOnScenarios(false) -- stop random cops (in a scenario) from spawning
end)


-- Disable all dispatch
Citizen.CreateThread(function()
    for dispatchService=1, 15 do
        EnableDispatchService(dispatchService, false)
        Citizen.Wait(1)
    end
end)


-- Calm Gangs
local relationshipTypes = {GetHashKey('PLAYER'), GetHashKey('CIVMALE'), GetHashKey('CIVFEMALE'), GetHashKey('GANG_1'), GetHashKey('GANG_2'), GetHashKey('GANG_9'), GetHashKey('GANG_10'), GetHashKey('AMBIENT_GANG_LOST'), GetHashKey('AMBIENT_GANG_MEXICAN'), GetHashKey('AMBIENT_GANG_FAMILY'), GetHashKey('AMBIENT_GANG_BALLAS'), GetHashKey('AMBIENT_GANG_MARABUNTE'), GetHashKey('AMBIENT_GANG_CULT'), GetHashKey('AMBIENT_GANG_SALVA'), GetHashKey('AMBIENT_GANG_WEICHENG'), GetHashKey('AMBIENT_GANG_HILLBILLY'), GetHashKey('DEALER'), GetHashKey('COP'), GetHashKey('PRIVATE_SECURITY'), GetHashKey('SECURITY_GUARD'), GetHashKey('ARMY'), GetHashKey('MEDIC'), GetHashKey('FIREMAN'), GetHashKey('HATES_PLAYER'), GetHashKey('NO_RELATIONSHIP'), GetHashKey('SPECIAL'), GetHashKey('MISSION2'), GetHashKey('MISSION3'), GetHashKey('MISSION4'), GetHashKey('MISSION5'), GetHashKey('MISSION6'), GetHashKey('MISSION7'), GetHashKey('MISSION8')}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        local playerHash = GetHashKey('PLAYER')

        for k,groupHash in ipairs(relationshipTypes) do
            SetRelationshipBetweenGroups(1, playerHash, groupHash)
            SetRelationshipBetweenGroups(1, groupHash, playerHash)
        end
    end
end)


-- Veh rewards
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        DisablePlayerVehicleRewards(PlayerId())
    end
end)


-- NPC Drops
local weapon_list = {"PICKUP_AMMO_BULLET_MP","PICKUP_AMMO_FIREWORK","PICKUP_AMMO_FLAREGUN","PICKUP_AMMO_GRENADELAUNCHER","PICKUP_AMMO_GRENADELAUNCHER_MP","PICKUP_AMMO_HOMINGLAUNCHER","PICKUP_AMMO_MG","PICKUP_AMMO_MINIGUN","PICKUP_AMMO_MISSILE_MP","PICKUP_AMMO_PISTOL","PICKUP_AMMO_RIFLE","PICKUP_AMMO_RPG","PICKUP_AMMO_SHOTGUN","PICKUP_AMMO_SMG","PICKUP_AMMO_SNIPER","PICKUP_ARMOUR_STANDARD","PICKUP_CAMERA","PICKUP_CUSTOM_SCRIPT","PICKUP_GANG_ATTACK_MONEY","PICKUP_HEALTH_SNACK","PICKUP_HEALTH_STANDARD","PICKUP_MONEY_CASE","PICKUP_MONEY_DEP_BAG","PICKUP_MONEY_MED_BAG","PICKUP_MONEY_PAPER_BAG","PICKUP_MONEY_PURSE","PICKUP_MONEY_SECURITY_CASE","PICKUP_MONEY_VARIABLE","PICKUP_MONEY_WALLET","PICKUP_PARACHUTE","PICKUP_PORTABLE_CRATE_FIXED_INCAR","PICKUP_PORTABLE_CRATE_UNFIXED","PICKUP_PORTABLE_CRATE_UNFIXED_INCAR","PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL","PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW","PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE","PICKUP_PORTABLE_PACKAGE","PICKUP_SUBMARINE","PICKUP_VEHICLE_ARMOUR_STANDARD","PICKUP_VEHICLE_CUSTOM_SCRIPT","PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW","PICKUP_VEHICLE_HEALTH_STANDARD","PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW","PICKUP_VEHICLE_MONEY_VARIABLE","PICKUP_VEHICLE_WEAPON_APPISTOL","PICKUP_VEHICLE_WEAPON_ASSAULTSMG","PICKUP_VEHICLE_WEAPON_COMBATPISTOL","PICKUP_VEHICLE_WEAPON_GRENADE","PICKUP_VEHICLE_WEAPON_MICROSMG","PICKUP_VEHICLE_WEAPON_MOLOTOV","PICKUP_VEHICLE_WEAPON_PISTOL","PICKUP_VEHICLE_WEAPON_PISTOL50","PICKUP_VEHICLE_WEAPON_SAWNOFF","PICKUP_VEHICLE_WEAPON_SMG","PICKUP_VEHICLE_WEAPON_SMOKEGRENADE","PICKUP_VEHICLE_WEAPON_STICKYBOMB","PICKUP_WEAPON_ADVANCEDRIFLE","PICKUP_WEAPON_APPISTOL","PICKUP_WEAPON_ASSAULTRIFLE","PICKUP_WEAPON_ASSAULTSHOTGUN","PICKUP_WEAPON_ASSAULTSMG","PICKUP_WEAPON_AUTOSHOTGUN","PICKUP_WEAPON_BAT","PICKUP_WEAPON_BATTLEAXE","PICKUP_WEAPON_BOTTLE","PICKUP_WEAPON_BULLPUPRIFLE","PICKUP_WEAPON_BULLPUPSHOTGUN","PICKUP_WEAPON_CARBINERIFLE","PICKUP_WEAPON_COMBATMG","PICKUP_WEAPON_COMBATPDW","PICKUP_WEAPON_COMBATPISTOL","PICKUP_WEAPON_COMPACTLAUNCHER","PICKUP_WEAPON_COMPACTRIFLE","PICKUP_WEAPON_CROWBAR","PICKUP_WEAPON_DAGGER","PICKUP_WEAPON_DBSHOTGUN","PICKUP_WEAPON_FIREWORK","PICKUP_WEAPON_FLAREGUN","PICKUP_WEAPON_FLASHLIGHT","PICKUP_WEAPON_GRENADE","PICKUP_WEAPON_GRENADELAUNCHER","PICKUP_WEAPON_GUSENBERG","PICKUP_WEAPON_GOLFCLUB","PICKUP_WEAPON_HAMMER","PICKUP_WEAPON_HATCHET","PICKUP_WEAPON_HEAVYPISTOL","PICKUP_WEAPON_HEAVYSHOTGUN","PICKUP_WEAPON_HEAVYSNIPER","PICKUP_WEAPON_HOMINGLAUNCHER","PICKUP_WEAPON_KNIFE","PICKUP_WEAPON_KNUCKLE","PICKUP_WEAPON_MACHETE","PICKUP_WEAPON_MACHINEPISTOL","PICKUP_WEAPON_MARKSMANPISTOL","PICKUP_WEAPON_MARKSMANRIFLE","PICKUP_WEAPON_MG","PICKUP_WEAPON_MICROSMG","PICKUP_WEAPON_MINIGUN","PICKUP_WEAPON_MINISMG","PICKUP_WEAPON_MOLOTOV","PICKUP_WEAPON_MUSKET","PICKUP_WEAPON_NIGHTSTICK","PICKUP_WEAPON_PETROLCAN","PICKUP_WEAPON_PIPEBOMB","PICKUP_WEAPON_PISTOL","PICKUP_WEAPON_PISTOL50","PICKUP_WEAPON_POOLCUE","PICKUP_WEAPON_PROXMINE","PICKUP_WEAPON_PUMPSHOTGUN","PICKUP_WEAPON_RAILGUN","PICKUP_WEAPON_REVOLVER","PICKUP_WEAPON_RPG","PICKUP_WEAPON_SAWNOFFSHOTGUN","PICKUP_WEAPON_SMG","PICKUP_WEAPON_SMOKEGRENADE","PICKUP_WEAPON_SNIPERRIFLE","PICKUP_WEAPON_SNSPISTOL","PICKUP_WEAPON_SPECIALCARBINE","PICKUP_WEAPON_STICKYBOMB","PICKUP_WEAPON_STUNGUN","PICKUP_WEAPON_SWITCHBLADE","PICKUP_WEAPON_VINTAGEPISTOL","PICKUP_WEAPON_WRENCH"}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        for i = 1, #weapon_list, 1 do
            RemoveAllPickupsOfType(GetHashKey(weapon_list[i]))
        end
    end
end)


-- No Crosshair
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		HideHudComponentThisFrame(14) -- hide crosshair
	end
end)


-- Handsup
Citizen.CreateThread(function()
	local dict = "missminuteman_1ig_2"

	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
	end
	local handsup = false

	while true do
		Citizen.Wait(10)
		if IsControlJustPressed(1, Keys['X']) and GetLastInputMethod(2) and IsPedOnFoot(PlayerPedId()) then
			if not handsup then
				TaskPlayAnim(PlayerPedId(), dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
				handsup = true
			else
				handsup = false
				ClearPedTasks(PlayerPedId())
			end
		end
	end
end)

-- No Drive-By
local passengerDriveBy = true

Citizen.CreateThread(function()
	while true do
		Wait(1)

		playerPed = GetPlayerPed(-1)
		car = GetVehiclePedIsIn(playerPed, false)
		if car then
			if GetPedInVehicleSeat(car, -1) == playerPed then
                SetPlayerCanDoDriveBy(PlayerId(), false)
                ShowNotice()
			elseif passengerDriveBy then
				SetPlayerCanDoDriveBy(PlayerId(), true)
			else
                SetPlayerCanDoDriveBy(PlayerId(), false)
                ShowNotice()
			end
		end
	end
end)

function ShowNotice()
	if not hasShownMessage then
		ESX.ShowNotification(_U('nodrive_action_disabled'))
		hasShownMessage = true
	end
end


-- Finger Point
local mp_pointing = false
local keyPressed = false

function startPointing()
    local ped = GetPlayerPed(-1)
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

function stopPointing()
    local ped = GetPlayerPed(-1)
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
local oldval = false
local oldvalped = false

Citizen.CreateThread(function()
    while true do
        Wait(0)

        if once then
            once = false
        end

        if not keyPressed then
            if IsControlPressed(0, Keys['B']) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
                Wait(200)
                if not IsControlPressed(0, Keys['B']) then
                    keyPressed = true
                    startPointing()
                    mp_pointing = true
                else
                    keyPressed = true
                    while IsControlPressed(0, Keys['B']) do
                        Wait(50)
                    end
                end
            elseif (IsControlPressed(0, Keys['B']) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
                keyPressed = true
                mp_pointing = false
                stopPointing()
            end
        end

        if keyPressed then
            if not IsControlPressed(0, Keys['B']) then
                keyPressed = false
            end
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
            stopPointing()
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
            if not IsPedOnFoot(PlayerPedId()) then
                stopPointing()
            else
                local ped = GetPlayerPed(-1)
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = 0
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
                nn,blocked,coords,coords = GetRaycastResult(ray)

                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

            end
        end
    end
end)


-- GPS Commands
local isMinimapEnabled = false

RegisterNetEvent('daily_QoL:setgps')
AddEventHandler('daily_QoL:setgps', function(pos_x, pos_y)
	-- add required decimal or else it wont work
	pos_x = pos_x + 0.00
	pos_y = pos_y + 0.00

	SetNewWaypoint(pos_x, pos_y)
	ESX.ShowHelpNotification(_U('gpstools_setgps_ok'))
end)

RegisterNetEvent('daily_QoL:getpos')
AddEventHandler('daily_QoL:getpos', function()
	local playerPed = PlayerPedId()

	local pos      = GetEntityCoords(playerPed)
	local heading  = GetEntityHeading(playerPed)
	local finalPos = {}

	-- round to 2 decimals
	finalPos.x = string.format("%.2f", pos.x)
	finalPos.y = string.format("%.2f", pos.y)
	finalPos.z = string.format("%.2f", pos.z)
	finalPos.h = string.format("%.2f", heading)

	local formattedText = "x = " .. finalPos.x .. ", y = " .. finalPos.y .. ", z = " .. finalPos.z .. ', h = ' .. finalPos.h
	TriggerEvent('chatMessage', 'YOUR POSITION: ', { 0, 0, 0 }, formattedText)
	print(formattedText)
end)

RegisterNetEvent('daily_QoL:tpwaypoint')
AddEventHandler('daily_QoL:tpwaypoint', function()
	local playerPed = GetPlayerPed(-1)
	local blip = GetFirstBlipInfoId(8)

	if DoesBlipExist(blip) then
		local coord = GetBlipInfoIdCoord(blip)
		local groundFound, coordZ = false, 0
		local groundCheckHeights = { 0.0, 50.0, 100.0, 150.0, 200.0, 250.0, 300.0, 350.0, 400.0,450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0 }

		for i, height in ipairs(groundCheckHeights) do

			ESX.Game.Teleport(playerPed, {
				x = coord.x,
				y = coord.y,
				z = height
			})

			local foundGround, z = GetGroundZFor_3dCoord(coord.x, coord.y, height)
			if foundGround then
				coordZ = z + 3
				groundFound = true
				break
			end
		end

		if not groundFound then
			coordZ = 100
			TriggerEvent('esx:addWeapon', 'GADGET_PARACHUTE', 0)
			ESX.ShowHelpNotification(_U('gpstools_tp_ground'))
		end

		ESX.Game.Teleport(playerPed, {
			x = coord.x,
			y = coord.y,
			z = coordZ
		})
	else
		ESX.ShowHelpNotification(_U('gpstools_tp_no_waypoint'))
	end
end)

-- Seat Shuffle
local disableShuffle = true

function disableSeatShuffle(flag)
	disableShuffle = flag
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsPedInAnyVehicle(GetPlayerPed(-1), false) and disableShuffle then
			if GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) == GetPlayerPed(-1) then
				if GetIsTaskActive(GetPlayerPed(-1), 165) then
					SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
				end
			end
		end
	end
end)

RegisterNetEvent("daily_QoL:shuffle")
AddEventHandler("daily_QoL:shuffle", function()
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
		disableSeatShuffle(false)
		Citizen.Wait(5000)
		disableSeatShuffle(true)
	else
		CancelEvent()
	end
end)