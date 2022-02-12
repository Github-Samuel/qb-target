function Load(name)
	local resourceName = GetCurrentResourceName()
	local chunk = LoadResourceFile(resourceName, ('data/%s.lua'):format(name))
	if chunk then
		local err
		chunk, err = load(chunk, ('@@%s/data/%s.lua'):format(resourceName, name), 't')
		if err then
			error(('\n^1 %s'):format(err), 0)
		end
		return chunk()
	end
end

-------------------------------------------------------------------------------
-- Settings
-------------------------------------------------------------------------------

Config = {}

-- It's possible to interact with entities through walls so this should be low
Config.MaxDistance = 6.0

-- Enable debug options
Config.Debug = false

-- Supported values: true, false
Config.Standalone = false

-- Enable outlines around the entity you're looking at
Config.EnableOutline = false

-- Enable default options (Toggling vehicle doors)
Config.EnableDefaultOptions = false

-- Disable the target eye whilst being in a vehicle
Config.DisableInVehicle = false

-- Key to open the target
Config.OpenKey = 'LMENU' -- Left Alt
Config.OpenControlKey = 19 -- Control for keypress detection also Left Alt for the eye itself, controls are found here https://docs.fivem.net/docs/game-references/controls/

-- Key to open the menu
Config.MenuControlKey = 238 -- Control for keypress detection on the context menu, this is the Right Mouse Button, controls are found here https://docs.fivem.net/docs/game-references/controls/

-------------------------------------------------------------------------------
-- Target Configs
-------------------------------------------------------------------------------

-- These are all empty for you to fill in, refer to the .md files for help in filling these in

Config.CircleZones = {

}

Config.BoxZones = {

}
	

Config.PolyZones = {

}

Config.TargetBones = {
	["mechanic"] = {
        bones = {
            "door_dside_f",
            "door_dside_r",
            "door_pside_f",
            "door_pside_r"
        },
        options = {
            {
                type = "client",
                event = "craft:vehmenu",
                icon = "fad fa-key",
                label = "Vehicle Menu",
                job = "mechanic",
            },
            {
                type = "client",
                event = "vehiclekeys:client:GiveKeys",
                icon = "fad fa-key",
                label = "GIVE KEYS",
            },
            {
                type = "client",
                event = "police:client:PutPlayerInVehicle",
                icon = "fas fa-chevron-circle-left",
                label = "PLACE IN VEHICLE",
            },
            {
                type = "client",
                event = "police:client:SetPlayerOutVehicle",
                icon = "fas fa-chevron-circle-right",
                label = "TAKE OUT OF VEHICLE",
            },
            {
                type = "client",
                event = "police:client:ImpoundVehicle",
                icon = "fas fa-car",
                label = "IMPOUND VEHICLE",
                job = 'police'
            },
        },
        distance = 3.0
    },
	
	["Shops"] = {
        models = {
            `mp_m_shopkeep_01`,
		`s_m_y_construct_01`,
		`mp_m_weapexp_01`,
                `ig_jimmyboston_02`,

        },
        options = {
            {
                type = "client",
                event = "qb-shops:247clerk",
                icon = "fas fa-shopping-basket",
                label = "Enter shop",
                --job = "police",
            },
        },
        distance = 2.5
    },
	["Weed"] = {
        models = {
            `mp_m_weed_01`,

        },
        options = {
            {
                type = "client",
                event = "qb-shops:247clerk",
                icon = "fas fa-shopping-basket",
                label = "Browse Weed Shop",
                --job = "police",
            },
        },
        distance = 2.5
    },
    
}


Config.TargetEntities = {

}

Config.TargetModels = {

}

Config.GlobalPedOptions = {

}

Config.GlobalVehicleOptions = {
    

}

Config.GlobalObjectOptions = {

}

Config.GlobalPlayerOptions = {
    options = {
        {
            type = "client",
            event = "qb-phone:client:GiveContactDetails",
            icon = "fas fa-address-book",
            label = "Give Contact Details",
        },
        {
            event = "police:client:RobPlayer",
            icon = "fas fa-user-secret",
            label = "Rob Player",
        },
        {
            type = "client",
            event = "police:client:CuffPlayer",
            icon = "fas fa-hands",
            label = "Cuff / Uncuff",
            job = "police",
            item = 'handcuffs',
        },
        {
          type = "client",
          event = "police:client:EscortPlayer",
          icon = "fas fa-key",
          label = "Escort",
        },
        {
            type = "client",
            event = "police:client:PutPlayerInVehicle",
            icon = "fas fa-chevron-circle-left",
            job = 'police',
            label = "Place in Vehicle",
        },
        {
            type = "client",
            event = "police:client:SetPlayerOutVehicle",
            icon = "fas fa-chevron-circle-right",
            job = 'police',
            label = "Take out of Vehicle",
        },
    }
}



Config.Peds = {

}

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
local function JobCheck() return true end
local function GangCheck() return true end
local function ItemCount() return true end
local function CitizenCheck() return true end

CreateThread(function()
	if not Config.Standalone then
		local QBCore = exports['qb-core']:GetCoreObject()
		local PlayerData = QBCore.Functions.GetPlayerData()

		ItemCount = function(item)
			for _, v in pairs(PlayerData.items) do
				if v.name == item then
					return true
				end
			end
			return false
		end

		JobCheck = function(job)
			if type(job) == 'table' then
				job = job[PlayerData.job.name]
				if job and PlayerData.job.grade.level >= job then
					return true
				end
			elseif job == 'all' or job == PlayerData.job.name then
				return true
			end
			return false
		end

		GangCheck = function(gang)
			if type(gang) == 'table' then
				gang = gang[PlayerData.gang.name]
				if gang and PlayerData.gang.grade.level >= gang then
					return true
				end
			elseif gang == 'all' or gang == PlayerData.gang.name then
				return true
			end
			return false
		end

		CitizenCheck = function(citizenid)
			return citizenid == PlayerData.citizenid or citizenid[PlayerData.citizenid]
		end

		RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
			PlayerData = QBCore.Functions.GetPlayerData()
			SpawnPeds()
		end)

		RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
			PlayerData = {}
			DeletePeds()
		end)

		RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
			PlayerData.job = JobInfo
		end)

		RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
			PlayerData.gang = GangInfo
		end)

		RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
			PlayerData = val
		end)
	else
		local firstSpawn = false
		AddEventHandler('playerSpawned', function()
			if not firstSpawn then
				SpawnPeds()
				firstSpawn = true
			end
		end)
	end
end)

function CheckOptions(data, entity, distance)
	if distance and data.distance and distance > data.distance then return false end
	if data.job and not JobCheck(data.job) then return false end
	if data.gang and not GangCheck(data.gang) then return false end
	if data.item and not ItemCount(data.item) then return false end
	if data.citizenid and not CitizenCheck(data.citizenid) then return false end
	if data.canInteract and not data.canInteract(entity, distance, data) then return false end
	return true
end
