local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")

local FormatModule = require(RS:WaitForChild("Modules").Formatter)
local globalSettings = require(RS:WaitForChild("GlobalSettings"))
local TemplatePlot = game.Workspace:WaitForChild("TemplatePlot")

local function findItem(itemToUnlockId, TemplateItems)
	local TemplateItems = TemplatePlot.Items
	for _, item in TemplateItems:GetChildren() do
		if item:GetAttribute("Id") ~= itemToUnlockId then continue end
		return item
	end
end

local function spawnButtonForCurrentItem(plot, currentItemId)
	local TemplateButtons = TemplatePlot.Buttons
	local buttonToClone = nil

	for _, Button in TemplateButtons:GetChildren() do
		if Button:GetAttribute("IdOfItemToUnlock") == currentItemId then
			buttonToClone = Button:Clone()
			break
		end
	end

	if not buttonToClone then
		warn("No matching button found for item ID:", currentItemId)
		return
	end

	local RelativeCFrame = TemplatePlot.CFrame:ToObjectSpace(buttonToClone.CFrame)
	buttonToClone.CFrame = plot.CFrame:ToWorldSpace(RelativeCFrame)
	
	local itemToUnlockId = buttonToClone:GetAttribute("IdOfItemToUnlock")
	if not itemToUnlockId then
		warn("You've forgot to add Id of the item as attribute!!")
		buttonToClone:Destroy()
		return
	end
	
	local item = findItem(itemToUnlockId, TemplatePlot.Items)
	if not item then 
		warn("No matching item found for unlock ID:", itemToUnlockId)
		buttonToClone:Destroy()
		return
	end

	local Price = buttonToClone:GetAttribute("Cost")
	if Price then
		buttonToClone.BillboardGui.ObjectName.Text = item.Name
		buttonToClone.BillboardGui.Cost.Text = "$" .. FormatModule.FormatNumber(Price)
	end

	buttonToClone.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		if plot:GetAttribute("Owner") ~= player.UserId then return end
		if buttonToClone:GetAttribute("Debounce") then return end

		buttonToClone:SetAttribute("Debounce", true)
		task.delay(2, function()
			if buttonToClone then
				buttonToClone:SetAttribute("Debounce", false)
			end
		end)

		if Price then
			if player.leaderstats.Cash.Value < Price then
				warn("You can't afford this!")
				return
			else
				player.leaderstats.Cash.Value -= Price
				if buttonToClone:GetAttribute("CashPerSecondIncrease") then
					player.otherStats.CashPerSecond.Value += buttonToClone:GetAttribute("CashPerSecondIncrease")
				end
			end
		end

		if item then
			local itemClone = item:Clone()
			local ItemCFrame = itemClone:IsA("Model") and itemClone:GetPivot() or itemClone.CFrame

			local RelativeItemCFrame = TemplatePlot.CFrame:ToObjectSpace(ItemCFrame)
			local worldCFrameOfNewPlot = plot.CFrame:ToWorldSpace(RelativeItemCFrame)

			if itemClone:IsA("Model") then
				itemClone:PivotTo(worldCFrameOfNewPlot)
			else
				itemClone.CFrame = worldCFrameOfNewPlot
			end

			itemClone.Parent = plot.Items

			RS.Remotes.ToClient:FireClient(player, "Sound", game.SoundService.Purchase)
			buttonToClone:Destroy()

			local nextItemId = player.otherStats.currentItemId.Value + 1
			local moreButtonsExist = false
			for _, button in TemplatePlot.Buttons:GetChildren() do
				if button:GetAttribute("IdOfItemToUnlock") == nextItemId then
					moreButtonsExist = true
					break
				end
			end
			player.otherStats.currentItemId.Value += 1

			if moreButtonsExist then
				spawnButtonForCurrentItem(plot, nextItemId)
			else
				BadgeService:AwardBadge(player.UserId, globalSettings.FinishedTycoonBadgeId)
			end
			return
		end
	end)

	buttonToClone.Parent = plot.Buttons
end

RS.Remotes.Buttons.Event:Connect(function(action, plot, currentItemId)
	if action == "SpawnButtonForItem" then
		spawnButtonForCurrentItem(plot, currentItemId)
	end
end)
