local RS = game:GetService("ReplicatedStorage")

local remote = RS:WaitForChild("Remotes").ChangeValue

local function valueHandler(player, Value, changeAmount)
	if Value and changeAmount then
		Value.Value = changeAmount
	end
end

remote.OnServerEvent:Connect(valueHandler)