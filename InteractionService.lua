--> Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ToolBarEvent = ReplicatedStorage.Events.ToolBarEvent

local Knit = require(ReplicatedStorage.Packages.Knit)

local CreateInteraction = ReplicatedStorage.Events.CreateInteraction
local HideInteraction = ReplicatedStorage.Events.HideInteraction
local DeleteInteraction = ReplicatedStorage.Events.DeleteInteraction


--> interaction data
local Interactions = {
	{
		Interaction = (function()
			local UniformOutfits = {}
			for _, v in ipairs(workspace.Interactions.Uniforms.Locker:GetDescendants()) do
				if v.Name == 'Centre' then
					table.insert(UniformOutfits, v)
				end
			end
			return UniformOutfits
		end)(),
		MinimumRank = 1,
		GroupID = 2955779,
		MaxInteractionDistance = 8,
		keybind = "E",
		Buttons = {
			{OnTrigger = {Service = "UniformService", Function = "EquipUniform"}, Client = false}
		},
		Title = 'Equip Uniform'
	},
	{
		Interaction = workspace.Interactions.Gate.MainGate,
		MinimumRank = 23,
		GroupID = {["Main"] = 2955779, ["Special"] = {14688205}}, --> rmp and main group
		MaxInteractionDistance = 8,
		keybind = "E",
		Buttons = {
			{OnTrigger = function(player, targetObj)	
				local MainGateValue = targetObj.Value
				MainGateValue .Value = not MainGateValue .Value

				if MainGateValue .Value == true then
					workspace.InvisibleWalls.MainGate.CanCollide = false

					targetObj.MainGate1.MovingPart.Transparency = 1
					targetObj.MainGate2.MovingPart.Transparency = 1

					targetObj.MainGate1.MovingPart1.Transparency = 0
					targetObj.MainGate2.MovingPart1.Transparency = 0

					targetObj.MainGate1.MovingPart.CanCollide = false
					targetObj.MainGate2.MovingPart.CanCollide = false
				end
				if MainGateValue .Value == false then
					workspace.InvisibleWalls.MainGate.CanCollide = true

					targetObj.MainGate1.MovingPart.Transparency = 0
					targetObj.MainGate2.MovingPart.Transparency = 0

					targetObj.MainGate1.MovingPart1.Transparency = 1
					targetObj.MainGate2.MovingPart1.Transparency = 1

					targetObj.MainGate1.MovingPart.CanCollide = true
					targetObj.MainGate2.MovingPart.CanCollide = true
				end
			end}
		},
		Title = 'Open/Close Main Gate'
	},
	{
		Interaction = workspace.Interactions.Gate.AirBase,
		MinimumRank = 23,
		GroupID = {["Main"] = 2955779, ["Special"] = {14770401, 13874465, 13280525}}, --> pfp, aac, paras and main group
		MaxInteractionDistance = 8,
		keybind = "E",
		Buttons = {
			{OnTrigger = function(player, targetObj)	
				local AirbaseValue = targetObj.Value
				AirbaseValue.Value = not AirbaseValue.Value

				if AirbaseValue.Value == true then
					workspace.InvisibleWalls.Airbase.CanCollide = false
					targetObj.AirbaseGate1.MovingPart.Transparency = 1
					targetObj.AirbaseGate2.MovingPart.Transparency = 1

					targetObj.AirbaseGate1.MovingPart.CanCollide = false
					targetObj.AirbaseGate2.MovingPart.CanCollide = false
				end
				if AirbaseValue.Value == false then
					workspace.InvisibleWalls.Airbase.CanCollide = true

					targetObj.AirbaseGate1.MovingPart.Transparency = 0
					targetObj.AirbaseGate2.MovingPart.Transparency = 0

					targetObj.AirbaseGate1.MovingPart.CanCollide = true
					targetObj.AirbaseGate2.MovingPart.CanCollide = true
				end
			end}
		},
		Title = 'Open/Close AirBase Gate'
	},
	{
		Interaction = nil,
		MinimumRank = nil,
		MaxInteractionDistance = 6,
		keybind = "E",
		DeleteAfterInteract = false,
		Buttons = {
			{OnTrigger = {Controller = "ArrestController", Function = "CuffPlayer"}, Client = true}
		},
		Title = 'Arrest'
	},
	{
		Interaction = workspace.Interactions.Objects.VertolSyth.Torso,
		MinimumRank = nil,
		GroupID = nil;
		MaxInteractionDistance = 8,
		keybind = "B",
		DeleteAfterInteract = false,
		Buttons = {
			{OnTrigger = {Service = "GamePassService", Function = "RaidSystem"}, Client = false}
		},
		Title = 'Start Raid'
	},
	{
		Interaction = workspace.Interactions.Objects.AutoBmt,
		MinimumRank = 1,
		GroupID = 2955779,
		MaxInteractionDistance = 8,
		keybind = "E",
		Buttons = {
			{OnTrigger = {Service = "GameService", Function = "TeleportPlayerBmt"}, Client = false}
		},
		Title = 'Auto Training'
	},
	{
		Interaction = (function()
			local Doors = {}
			for _, v in ipairs(workspace.Interactions.Doors:GetDescendants()) do
				if v.Name == 'GivePart' then
					table.insert(Doors, v)
				end
			end
			return Doors
		end)(),
		MinimumRank = 1,
		GroupID = 2955779,
		MaxInteractionDistance = 8,
		keybind = "E",
		Buttons = {
			{OnTrigger = {Service = "GameService", Function = "DoorService"}, Client = false}
		},
		Title = 'Open/Close Door'
	},
}

local InteractionService = Knit.CreateService({Name = "InteractionService", Client = {}})


function InteractionService:FindDataFromTitle(title)
	for _, v in ipairs(Interactions) do
		if v.Title == title then
			return v
		end
	end
end

function InteractionService.Client:Clicked(player, buttonIndex, targetObj, title)
	local data = InteractionService:FindDataFromTitle(title)
	if data then
		local TriggerData = data.Buttons[buttonIndex].OnTrigger
		if type(TriggerData) == "function" then --> if its a function then run the function if not run the service
			TriggerData(player, targetObj)
		else
			if TriggerData.Service then
				local Service = Knit.GetService(TriggerData.Service)
				Service[TriggerData.Function](Service,player, targetObj)
			end
			if TriggerData.Controller then
				local Controller = Knit.GetController(TriggerData.Controller)
				Controller[TriggerData.Function](Controller, player, targetObj)
			end
		end
	end
end

function InteractionService.Client:GetInteractions(player: Player)
	if not player:IsDescendantOf(Players) then return {} end

	local PlayerInteractions  = {}
	for _, v in ipairs(Interactions) do

		if 	v.MinimumRank == nil  or v.groupID == nil or v.MinimumRank == 0 then
			table.insert(PlayerInteractions, v)
		elseif v.MinimumRank >= 1 then
			if type(v.GroupID) == 'table' then
				if player:GetRankInGroup(v.GroupID["Main"]) >= v.MinimumRank then
					table.insert(PlayerInteractions, v)
				end

				for i, groupID in pairs(v.GroupID["Special"]) do
					if player:IsInGroup(groupID) then
						table.insert(PlayerInteractions, v)
					end
				end
			else
				if player:GetRankInGroup(v.GroupID) >= v.MinimumRank then
					table.insert(PlayerInteractions, v)
				end
			end		
		end
	end

	return PlayerInteractions
end


function InteractionService:CreateInteraction(players, data, object)
	for _, v in ipairs(players) do
		CreateInteraction:FireClient(v, data, object)
	end
end

function InteractionService:DeleteInteraction(players, object)
	for _, v in ipairs(players) do
		DeleteInteraction:FireClient(v, object)
	end
end

function InteractionService:HideInteraction(interaction, toggle)
	HideInteraction:FireAll(interaction, toggle)
end

--> padlocks
local function ShowNotShowBoxes(BoxName, Bool: boolean)
	local PadLockBoxes = workspace:FindFirstChild("Interactions").Padlocks.Boxes
	if PadLockBoxes:FindFirstChild(BoxName) then
		if Bool then
			for i, v in pairs(PadLockBoxes:FindFirstChild(BoxName).Box.Walls:GetChildren()) do
				v.Transparency = 0
				v.CanCollide = true
			end
			PadLockBoxes:FindFirstChild(BoxName).Box.ButtonGui.SurfaceGui.TextButton.Text = "🔓"
		else
			for i, v in pairs(PadLockBoxes:FindFirstChild(BoxName).Box.Walls:GetChildren()) do
				v.Transparency = 1
				v.CanCollide = false
			end
			PadLockBoxes:FindFirstChild(BoxName).Box.ButtonGui.SurfaceGui.TextButton.Text = "🔒"
		end
	end
end


local function interactPadLocks()
	local PadLockIcons = workspace:FindFirstChild("Interactions").Padlocks.Icons

	for i, v in pairs(PadLockIcons:GetChildren()) do
		if v:FindFirstChild("OPEN") then
			local MouseClick: ClickDetector = v:FindFirstChild("OPEN")
			MouseClick.MouseClick:Connect(function(player)
				if player:GetRankInGroup(2955779) >= 13 then
					v.Value.Value = not v.Value.Value
					ShowNotShowBoxes(v.Name, v.Value.Value)
				end
			end)
		end
	end
end


--> hot bar
-- ToolBarEvent.OnServerEvent:Connect(function(plr,CurrentSlotEquipped,ToolForEquipping)

-- 	local bp = plr.Backpack
-- 	local char =  plr.Character


-- 	if CurrentSlotEquipped == nil then
-- 		for i,v in pairs(char:GetChildren())do
-- 			if v:IsA("Tool")then
-- 				v.Parent = bp
-- 			end
-- 		end
-- 	else
-- 		for i,v in pairs(char:GetChildren())do
-- 			if v:IsA("Tool") and v~= ToolForEquipping then
-- 				v.Parent = bp
-- 			end
-- 		end
-- 		if ToolForEquipping ~= nil and ToolForEquipping ~= ""then
-- 			if ToolForEquipping.Parent ==  bp then
-- 				ToolForEquipping.Parent = char
-- 			end
-- 		end
-- 	end	

-- end)

function InteractionService:KnitStart()
	interactPadLocks()
end

return InteractionService
