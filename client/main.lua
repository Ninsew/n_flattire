ESX = nil TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('n_flattire:makeflattire')
AddEventHandler('n_flattire:makeflattire', function(time)

    -- CONFIGURATION --
    local successChance     = 35    -- Success chance, will play until success
    local breakChance       = 70    -- Chance to break the item after use
    local policeChance  	= 60    -- Chance to alert police when something is broken
    local alarmChance     	= 40    -- Chance to trigger car alarm when tire is popped
	local minDistance       = 1.0   -- Minimum distance to wheel
    local animDict          = "melee@knife@streamed_core_fps"
    local animation         = "ground_attack_on_spot"
    -- CONFIGURATION --

    local playerId      = PlayerId()
    local playerPed     = GetPlayerPed(playerId)
    local vehicle       = ESX.Game.GetVehicleInDirection()
    local success       = false
    local dropItem      = false
    local vehicleAlarm  = false

    if vehicle then

        local closestTire = GetClosestWheel(vehicle, minDistance)

        if closestTire then

            if not IsVehicleTyreBurst(vehicle, closestTire.tireIndex, true) then

                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Citizen.Wait(100)
                end

                local animDuration = GetAnimDuration(animDict, animation)
                TaskPlayAnim(playerPed, animDict, animation, 8.0, -8.0, animDuration, 15, 1.0, 0, 0, 0)

                while not success do

                    if not closestTire then
                        ESX.ShowNotification('Ställ dig närmare bilen.')
                        break
                    end

                    if not vehicleAlarm then
                        local alarmRandom = math.random(100)
                        if alarmRandom < alarmChance then
                            SetVehicleAlarm(vehicle, true)
                            StartVehicleAlarm(vehicle)
                            vehicleAlarm = true
                        end
                    end

                    Citizen.Wait((animDuration / 2) * 1000)

                    local successRandom = math.random(100)
                    if successRandom < successChance then
                            SetVehicleTyreBurst(vehicle, closestTire.tireIndex, true, 1000.0)
                            success = true
                            Citizen.Wait((animDuration / 2) * 1000)
                        break
                    end

                    Citizen.Wait((animDuration / 2) * 1000)
                end

                ClearPedTasksImmediately(playerPed)
                if success then
                    if not vehicleAlarm then
                        SetVehicleAlarm(vehicle, true)
                        StartVehicleAlarm(vehicle)
                        vehicleAlarm = true
                    end

                    local breakRandom = math.random(100)
                    if breakRandom < breakChance then
                        TriggerServerEvent('n_flattire:removeitem', source)
                    end
                end
            end
        end
    end
end)

function GetClosestWheel(vehicle, minDistance)
    local tireBones = {"wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1", "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3", "wheel_lr", "wheel_rr"}
	local tireIndex = {
		["wheel_lf"]    = 0,
		["wheel_rf"]    = 1,
		["wheel_lm1"]   = 2,
		["wheel_rm1"]   = 3,
		["wheel_lr"]    = 4,
		["wheel_rr"]    = 5,
		["wheel_lm2"]   = 45,
		["wheel_lm3"]   = 46,
		["wheel_rm2"]   = 47,
		["wheel_rm3"]   = 48,
	}

	local player        = PlayerId()
	local playedPed     = GetPlayerPed(player)
	local playerPos     = GetEntityCoords(playedPed, false)
	local closestTire   = nil

    for a = 1, #tireBones do
		local bonePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tireBones[a]))
		local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, bonePos.x, bonePos.y, bonePos.z)

		if closestTire == nil then
			if distance <= minDistance then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		else
			if distance < closestTire.boneDist then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		end
	end

	return closestTire
end