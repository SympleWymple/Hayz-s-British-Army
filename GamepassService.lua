----> Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HTTPs = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService('ServerStorage')
local Players = game:GetService('Players')
local MarketPlaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local numberController = require(ReplicatedStorage.Packages.NumberController)

local rankGamePassEvent = ReplicatedStorage.Events.GamePassBought
local openInivisibleDoor = ReplicatedStorage.Events.OpeninvisibleDoor
local GroupID = 2955779

local rankGunModule = require(ServerStorage.Modules.RankGunModule)


--> GamePasses
local Sergeant = 25931399
local LieutenantCol = 35173470
local SecondLieutenant = 25931431
local Corporal = 35174824
local BikeID = 27087328

local SergeantRankID = 5
local LieutenantColRankID = 15
local SecondLieutenantRankID = 11
local CorporalRankID = 4

local rankGamePass = {["25931431"] = SecondLieutenantRankID, ["25931399"] = SergeantRankID, ["35173470"] = LieutenantColRankID, ["35174824"] = CorporalRankID }
local toolGamePass = {["27087328"] = "Bike"}
local AreaPasses = {
	Vip = 26974327;
}

local GamePassService = Knit.CreateService({Name = "GamePassService", Client = {}})


--> ranking system
local function autoRankPlayer(rankId: number, client: Player)
	if client:GetRankInGroup(GroupID) > rankId then return end --> if client is greater than rank id dont demote them
	local success, message = pcall(function()
		rankGunModule.SetRank(rankId, client)
	end)

	print(message)

	if success then
		rankGamePassEvent:FireClient(client)
	end
	return success
end

--> when a player joins the game check if they have any gamepasses and give it to them

local function playerAdded(player: Player)
	local DataService = Knit.GetService("DataService")

	--> Sergeant Gamepass
	if MarketPlaceService:UserOwnsGamePassAsync(player.UserId, Sergeant) then
		local hasGamePass = DataService:Get(player, "SergeantGamepass")
		if hasGamePass == false then
			if autoRankPlayer(SergeantRankID, player) == true then --> if success fire remote event
				DataService:Set(player, "SergeantGamepass", true, true)
			end
		end
	else
		local hasGamePass = DataService:Get(player, "SergeantGamepass"):expect()
		if hasGamePass then
			-- if they dont have the game pass but they do in the datastore set the value to false
			DataService:Set(player, "SergeantGamepass", false, true)
		end
	end

	--> Lieutenant Colonel
	if MarketPlaceService:UserOwnsGamePassAsync(player.UserId, LieutenantCol) then
		local hasGamePass = DataService:Get(player, "LieutenantColGamepass"):expect()
		if hasGamePass == false then
			if autoRankPlayer(LieutenantColRankID, player) == true then --> if success fire remote event
				DataService:Set(player, "LieutenantColGamepass", true, true)
			end
		end
	else
		local hasGamePass = DataService:Get(player, "LieutenantColGamepass"):expect()
		if hasGamePass then
			-- if they dont have the game pass but they do in the datastore set the value to false
			DataService:Set(player, "LieutenantColGamepass", false, true)
		end
	end

	--> SecondLieutenant
	if MarketPlaceService:UserOwnsGamePassAsync(player.UserId, SecondLieutenant) then
		local hasGamePass = DataService:Get(player, "SecondLieutenantGamepass"):expect()
		if hasGamePass == false then
			if autoRankPlayer(SecondLieutenantRankID, player) == true then --> if success fire remote event
				DataService:Set(player, "SecondLieutenantGamepass", false, true)
			end
		end
	else
		local hasGamePass = DataService:Get(player, "SecondLieutenantGamepass"):expect()
		if hasGamePass then
			-- if they dont have the game pass but they do in the datastore set the value to false
			DataService:Set(player, "SecondLieutenantGamepass", false, true)
		end
	end

	--> Corporal
	if MarketPlaceService:UserOwnsGamePassAsync(player.UserId, Corporal) then
		local hasGamePass = DataService:Get(player, "CorporalGamepass"):expect()
		if hasGamePass == false then
			if autoRankPlayer(CorporalRankID, player) == true then --> if success fire remote event
				DataService:Set(player, "CorporalGamepass", true, true)
			end
		end
	else
		local hasGamePass = DataService:Get(player, "CorporalGamepass"):expect()
		if hasGamePass then
			-- if they dont have the game pass but they do in the datastore set the value to false
			DataService:Set(player, "CorporalGamepass", false, true)
		end
	end

	--> player iTems
	if MarketPlaceService:UserOwnsGamePassAsync(player.UserId, BikeID) then
		ServerStorage.Assets.Tools.Bike:Clone().Parent = player.Backpack
		ServerStorage.Assets.Tools.Bike:Clone().Parent = player.StarterGear
	end
end

local function bindGamepassAreas()
	for _, v in ipairs(workspace.GamepassAreas:GetChildren()) do
		local AreasPssId = AreaPasses[v.Name] --> get the correct Area gamepass
		if AreasPssId then --> if exists check if the object that touched has a humanoid(is a player)
			v.Touched:Connect(function(hit)
				local Humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
				if Humanoid then --> once everything is confirmed and its a player get the client and check if they have the gamepass
					local client = Players:GetPlayerFromCharacter(Humanoid.Parent)
					if client then
						if MarketPlaceService:UserOwnsGamePassAsync(client.UserId, AreasPssId) then
							-- they have gamepass fire the client and open the insible barrier for the client only
							openInivisibleDoor:FireClient(client, "Vip")
						end
					end
				end
			end)
		end
	end
end


local function gamePassBoards()
	local gamepassBoardsFolder = workspace:FindFirstChild("Interactions").GamePassBoards

	for i, gamepassBoard in pairs(gamepassBoardsFolder:GetChildren()) do
		for i, v in pairs(gamepassBoard:GetChildren()) do
			if v.Name == "GamePass" and v:IsA("Model") then
				local currentModel = v
				local ClickDetector = currentModel.PurchasePrompt.ClickDetector
				ClickDetector.MouseClick:Connect(function(player)
					MarketPlaceService:PromptGamePassPurchase(player, ClickDetector["ID"].Value)
				end)
			end
		end
	end 
end



function GamePassService.Client:PromotePlayer(client: Player, promotePlayer)
	if client:IsInGroup(13146155) or client:GetRankInGroup(2955779) >= 23 then
		if promotePlayer:GetRankInGroup(2955779) < 2 then
			rankGunModule.Promote(2, promotePlayer)
			--> send to discord
			rankGunModule.PromoteDiscord(promotePlayer, client)
		end
	end
end



--> raid system
local startRaid, raidInProgress = false, false
local WorkspaceRaidUI = workspace["Raid Initiation"].UI:WaitForChild("Tag").Frame

function GamePassService:RaidSystem(player: Player)
	if startRaid == true and raidInProgress ==  false then
		MarketPlaceService:PromptProductPurchase(player, 1551556811, false)
	end
end

MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassID, wasPurchased)
	if rankGamePass[tostring(gamePassID)]  then
		if wasPurchased then
			autoRankPlayer(rankGamePass[tostring(gamePassID)], player)
		end
	end
	if toolGamePass[tostring(gamePassID)] and wasPurchased then
		ServerStorage.Assets.Tools[toolGamePass[tostring(gamePassID)]]:Clone().Parent = player.Backpack
		ServerStorage.Assets.Tools[toolGamePass[tostring(gamePassID)]]:Clone().Parent = player.StarterGear
	end
end)

MarketPlaceService.PromptProductPurchaseFinished:Connect(function(player, product, wasPurchased)
	local RaidService = Knit.GetService("RaidService")

	if product == 1551556811 then --> raid id
		startRaid = false
		raidInProgress = true
		RaidService:Initiate()
	end
end)

function GamePassService:ReturnRaidIsDone()
	startRaid, raidInProgress = false, false
end

--> initialise the program
function GamePassService:KnitStart()
	game.Players.PlayerAdded:Connect(playerAdded)
	bindGamepassAreas()
	gamePassBoards()

	--> raid timer
	spawn(function()
		while true do --> so its always checking the child thing
			while raidInProgress == false and startRaid == false do 
				for timer  = 10, 0, -1 do
					local clock = numberController.ToDHMSorHMS(timer)
					WorkspaceRaidUI:WaitForChild("Timer").Text = "INITIATE RAID IN: ".. clock
					WorkspaceRaidUI:WaitForChild("Timer2").Text = "INITIATE RAID IN: ".. clock

					task.wait(1)
					if timer == 0 then
						startRaid = true
						WorkspaceRaidUI:WaitForChild("Timer").Text = "START RAID!"
						WorkspaceRaidUI:WaitForChild("Timer2").Text = "START RAID!"
					else
						startRaid = false
					end
				end
			end
			task.wait()
		end
	end)
end


return GamePassService
