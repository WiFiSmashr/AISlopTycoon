local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Plots = workspace:WaitForChild("Plots")
local TemplatePlot = workspace:WaitForChild("TemplatePlot")

Players.PlayerAdded:Connect(function(player)
	local currentItemId = player:WaitForChild("otherStats").currentItemId
	local assignedPlot = nil

	for _, plot in pairs(Plots:GetChildren()) do
		if plot:GetAttribute("Taken") then continue end
		plot:SetAttribute("Taken", true)
		plot:SetAttribute("Owner", player.UserId)
		assignedPlot = plot
		
		plot.OwnerTag.BillboardGui.Enabled = true
		plot.OwnerTag.BillboardGui.TextLabel.Text = player.Name .. " Tycoon"
		plot.OwnerTag.BillboardGui.ImageLabel.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

		-- Clone plot contents
		local ItemsFolder = Instance.new("Folder")
		ItemsFolder.Name = "Items"
		ItemsFolder.Parent = plot

		local ButtonsFolder = Instance.new("Folder")
		ButtonsFolder.Name = "Buttons"
		ButtonsFolder.Parent = plot

		for _, object in TemplatePlot:GetChildren() do
			if object:IsA("Model") then
				local ClonedObject = object:Clone()
				ClonedObject.Parent = plot
				local RelativeItemCFrame = TemplatePlot.CFrame:ToObjectSpace(ClonedObject:GetPivot())
				local worldCFrameOfNewPlot = plot.CFrame:ToWorldSpace(RelativeItemCFrame)
				ClonedObject:PivotTo(worldCFrameOfNewPlot)
			elseif object:IsA("BasePart") then
				local ClonedObject = object:Clone()
				ClonedObject.Parent = plot
				local RelativeItemCFrame = TemplatePlot.CFrame:ToObjectSpace(ClonedObject.CFrame)
				local worldCFrameOfNewPlot = plot.CFrame:ToWorldSpace(RelativeItemCFrame)
				ClonedObject.CFrame = worldCFrameOfNewPlot
			end
		end

		for _, templateItem in TemplatePlot.Items:GetChildren() do
			local itemId = templateItem:GetAttribute("Id")
			if itemId and itemId < currentItemId.Value then
				local itemClone = templateItem:Clone()
				local itemCFrame = itemClone:IsA("Model") and itemClone:GetPivot() or itemClone.CFrame
				local relativeItemCFrame = TemplatePlot.CFrame:ToObjectSpace(itemCFrame)
				local worldCFrame = plot.CFrame:ToWorldSpace(relativeItemCFrame)

				if itemClone:IsA("Model") then
					itemClone:PivotTo(worldCFrame)
				else
					itemClone.CFrame = worldCFrame
				end

				itemClone.Parent = plot.Items
			end
		end

		RS.Remotes.Buttons:Fire("SpawnButtonForItem", plot, currentItemId.Value)
		break
	end
	
	local function teleportToPlot(character)
		local rootPart = character:WaitForChild("HumanoidRootPart", 5)
		if rootPart and assignedPlot then
			rootPart.CFrame = CFrame.new(assignedPlot.SpawnPoint.WorldPosition + Vector3.new(0, 5, 0))
		end
	end

	player.CharacterAdded:Connect(teleportToPlot)

	if player.Character then
		teleportToPlot(player.Character)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	for _, plot in pairs(Plots:GetChildren()) do
		if plot:GetAttribute("Owner") ~= player.UserId then continue end
		plot:SetAttribute("Taken", nil)
		plot:SetAttribute("Owner", nil)
		plot.OwnerTag.BillboardGui.Enabled = false
		for _, item in plot:GetChildren() do
			if item:IsA("Attachment") then continue end
			item:Destroy()
		end
		break
	end
end)
