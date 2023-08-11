--> Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableLib = require(ReplicatedStorage.Packages.TableUtil)
local MathLib = require(ReplicatedStorage.Packages.Math)

local InteractionUI = ReplicatedStorage.Assets.Interaction
local CreatedInteractions = {}
local PlayerInteractType, ToReset, NearestInteraction

--> events
local CreateInteraction = ReplicatedStorage.Events.CreateInteraction
local HideInteraction = ReplicatedStorage.Events.HideInteraction
local DeleteInteraction = ReplicatedStorage.Events.DeleteInteraction

local InteractionController = Knit.CreateController({Name = "InteractionController"})

function InteractionController:KnitStart()
	local InteractionService = Knit.GetService("InteractionService")
	local PlayerDevice = require(script.Parent.Parent.Core.Device).GetDevice()
	PlayerInteractType = PlayerDevice == 'Desktop' and 'Interact' or 'InteractMobile'

	local PlayerInteractions = InteractionService:GetInteractions():expect() --> get interactions client have
	for _, v in ipairs(PlayerInteractions) do
		local data = v
		if ( type(v.Interaction) == "table" )  and Players:FindFirstChild(tostring(data.Interaction[1].Name)) then
			InteractionController:HandleCharacterInteractions(data)

		elseif type(v.Interaction) == "table" then
			for i, obj in ipairs(v.Interaction) do
				if obj:IsA("BasePart") then
					local data = v
					data.Parent = obj
					InteractionController:CreateInteraction(data)
				end
			end

		else
			local data = v
			data.Parent = v.Interaction
			InteractionController:CreateInteraction(data)
		end
	end

	CreateInteraction.OnClientEvent:Connect(function(data, object)
		local data = data
		data.Interaction = object
		data.Parent = object
		InteractionController:CreateInteraction(data)
	end)

	DeleteInteraction.OnClientEvent:Connect(function(object)
		InteractionController:DeleteInteraction({Parent = object})
	end)

	HideInteraction.OnClientEvent:Connect(function(...)
		InteractionController:HideInteractionUI(...)
	end)

	local MobileTouch, PC_Click = Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1
	UserInputService.InputBegan:Connect(function(input)
		if UserInputService:GetFocusedTextBox() then return end
		if CreatedInteractions[NearestInteraction] then
			if input.KeyCode == Enum.KeyCode[CreatedInteractions[NearestInteraction].keybind] then
				if NearestInteraction and CreatedInteractions[NearestInteraction] then --> when user presses keybind and it not chatting and is close to a iteraction trigger it
					CreatedInteractions[NearestInteraction].Trigger()
				end
			elseif input.UserInputType == MobileTouch or input.UserInputType == PC_Click then --> same with mobile tap or mouse click
				local ThisReset = ToReset
				task.wait(.25)
				if CreatedInteractions[ThisReset] and ThisReset == ToReset then
					InteractionController:ResetInteraction(ThisReset)
				end
			end
		end
	end)

	RunService.Heartbeat:Connect(function()
		for k, v in pairs(CreatedInteractions) do
			if k and k:IsDescendantOf(workspace) then else
				InteractionController:DeleteInteraction({Parent = k}) --> any interaction in workspace just by itself
			end
		end

		if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character.PrimaryPart then return end

		local ListedInteractions = TableLib.Keys(CreatedInteractions) --> creates a list
		local Nearest = MathLib.GetNearest(Players.LocalPlayer.Character.PrimaryPart.Position, ListedInteractions) --> get the nearest interaction 
		for _, v in ipairs(ListedInteractions) do
			local Interaction = CreatedInteractions[v]
			--> if distance is below/ equal to the specified amount listed then show
			local dist = MathLib.rel_dist(Players.LocalPlayer.Character.PrimaryPart, v, false)
			if dist >= Interaction.MaxInteractionDistance then
				Interaction.Interface.Enabled = false
				continue
			else
				Interaction.Interface.Enabled = Knit.Player.PlayerGui.Interactions.Enabled
			end

			if v == Nearest then
				local data = {Parent = v, keybind = true}
				--InteractionController:UpdateInteraction(data)
				NearestInteraction = v
			else
				local data = {Parent = v}
				--InteractionController:UpdateInteraction(data)
			end
		end
	end)
end


function InteractionController:CreateInteraction(data)
	local obj = data.Parent
	if CreatedInteractions[obj] or not obj then return false end


	local InteractionService = Knit.GetService("InteractionService")

	local ThisInteraction = InteractionUI:Clone()
	local ButtonT =  ThisInteraction.Buttons.InteractionButtonTemplate
	local ButtonTemplate = InteractionUI.Buttons.InteractionButtonTemplate:Clone()
	ButtonT:Destroy()

	if not CreatedInteractions[obj] then CreatedInteractions[obj] = {} end
	CreatedInteractions[obj].Interface = ThisInteraction
	CreatedInteractions[obj].MaxInteractionDistance = data.MaxInteractionDistance

	ThisInteraction.Interaction.Interact.InteractionTitle.Text = data.Title
	ThisInteraction.Interaction.InteractMobile.InteractionTitle.Text = data.Title

	local function trigger(info)
		if ThisInteraction.MaxDistance <= .5 then return end
		if data.Buttons[info].Client then
			local TriggerInfo = data.Buttons[info].OnTrigger
			local Controller = Knit.GetController(TriggerInfo.Controller)

			task.spawn(Controller[TriggerInfo.Function], Controller, obj.Parent)
		else
			InteractionService:Clicked(info, obj, data.Title)
		end
	end


	CreatedInteractions[obj].keybind = "E" --> default keybind
	CreatedInteractions[obj].Trigger = function()
		if MathLib.rel_dist(Players.LocalPlayer.Character.PrimaryPart, obj, false) >= data.MaxInteractionDistance then
			return
		end

		local function animate()
			TweenService:Create(
				ThisInteraction.Interaction.InteractMobile, 
				TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In), 
				{Size = UDim2.fromScale(0.8, 0.7)}
			):Play()

			TweenService:Create(
				ThisInteraction.Interaction.Interact, 
				TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In), 
				{Size = UDim2.fromScale(0.8, 0.7)}
			):Play()

			task.wait(0.053)

			TweenService:Create(
				ThisInteraction.Interaction.InteractMobile, 
				TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In), 
				{Size = UDim2.fromScale(1, 0.8)}
			):Play()

			TweenService:Create(
				ThisInteraction.Interaction.Interact, 
				TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In), 
				{Size = UDim2.fromScale(1, 0.8)}
			):Play()
		end
		animate()

		if ToReset and ToReset == obj then return end

		if ToReset then
			InteractionController:ResetInteraction(ToReset)
		end

		if #data.Buttons <= 1 then
			trigger(1)

		else
			local EndSize = UDim2.new(.45, 0, 1, 0) -- ThisInteraction.Buttons.Size
			ThisInteraction.Interaction.Visible = false
			ThisInteraction.Buttons.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(ThisInteraction.Buttons, TweenInfo.new(.5), {Size = EndSize}):Play()
			ThisInteraction.Buttons.Visible = true

			for k, v in ipairs(data.Buttons) do
				local Button = ButtonTemplate:Clone()
				Button.TextLabel.Text = v.Name
				Button.MouseButton1Click:Connect(function()
					trigger(k)
				end)

				local DefaultSize = Button.TextLabel.Size
				Button.MouseEnter:Connect(function()
					TweenService:Create(Button.TextLabel, TweenInfo.new(.3), {Size = UDim2.new(1, 0, .85, 0)}):Play()
				end)
				Button.MouseLeave:Connect(function()
					TweenService:Create(Button.TextLabel, TweenInfo.new(.3), {Size = DefaultSize}):Play()
				end)

				Button.Parent = ThisInteraction.Buttons
			end

			ToReset = obj
		end
	end


	if data.keybind and PlayerInteractType == 'Interact' then
		CreatedInteractions[obj].keybind = data.keybind
		ThisInteraction.Interaction.Interact.Visible = true
		ThisInteraction.Interaction.Interact:WaitForChild("Text").Text = data.keybind
		ThisInteraction.Interaction.InteractMobile.Visible = false
	else
		CreatedInteractions[obj].keybind = false
		ThisInteraction.Interaction.Interact.Visible = false
		ThisInteraction.Interaction.InteractMobile.Visible = true
	end

	ThisInteraction.Interaction.InteractMobile.MouseButton1Click:Connect(CreatedInteractions[obj].Trigger)
	ThisInteraction.Interaction.Interact.MouseButton1Click:Connect(CreatedInteractions[obj].Trigger)

	ThisInteraction.Parent = Players.LocalPlayer.PlayerGui.Interactions.Interaction
	ThisInteraction.Adornee = obj

	return ThisInteraction
end

--function InteractionController:UpdateInteraction(data)
--	local Interaction = CreatedInteractions[data.Parent].Interface

--	if data.keybind and PlayerInteractType == 'Interact' then
--		CreatedInteractions[data.Parent].keybind = true
--		Interaction.Interaction.Interact.Visible = true
--		Interaction.Interaction.InteractMobile.Visible = false
--	else
--		CreatedInteractions[data.Parent].keybind = false
--		Interaction.Interaction.Interact.Visible = false
--		Interaction.Interaction.InteractMobile.Visible = true
--	end
--end

function InteractionController:HandleCharacterInteractions(data)
	for i, players in pairs(data.Interaction) do
		if Players[players.Name] then
			local character = workspace:FindFirstChild(players.Name)
			if character then
				local data = data
				data.Parent = character:WaitForChild('HumanoidRootPart')
				InteractionController:CreateInteraction(data)
			end
		end
	end
	
	local function characterAdded(char)
		local data = data
		data.Parent = char:WaitForChild('HumanoidRootPart')
		InteractionController:CreateInteraction(data)
	end

	Players.LocalPlayer.CharacterAdded:Connect(characterAdded)
end

function InteractionController:DeleteInteraction(data)
	local Interaction = CreatedInteractions[data.Parent]
	if Interaction then
		Interaction.Interface:Destroy()
		CreatedInteractions[data.Parent] = nil
	end
end

function InteractionController:HideInteractionUI(interactionObject, toggle)
	local Interaction = CreatedInteractions[interactionObject]
	if Interaction then
		Interaction.Interface.MaxDistance = toggle and .2 or 20
	end
end

function InteractionController:ResetInteraction(obj)
	if not CreatedInteractions[obj] then return end

	local Interface = CreatedInteractions[obj].Interface

	if Interface.Buttons.Visible == true then
		TweenService:Create(Interface.Buttons, TweenInfo.new(.1), {Size = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(.1)
		Interface.Buttons.Visible = false
	end

	Interface.Interaction.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(Interface.Interaction, TweenInfo.new(.05, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	Interface.Interaction.Visible = true

	for _, v in ipairs(Interface.Buttons:GetChildren()) do
		if v:IsA'GuiObject' then
			v:Destroy()
		end
	end

	if ToReset == obj then
		ToReset = nil
	end
end


return InteractionController
