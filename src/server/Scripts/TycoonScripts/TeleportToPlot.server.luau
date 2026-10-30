local remote = game.ReplicatedStorage:WaitForChild("Remotes").Teleport
local plotsFolder = game.Workspace:WaitForChild("Plots")

remote.OnServerEvent:Connect(function(player, TeleportPlayer)
	for _, plot in plotsFolder:GetChildren() do
		if plot:GetAttribute("Owner") == TeleportPlayer.UserId then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(plot.SpawnPoint.WorldPosition + Vector3.new(0, 5, 0))
		end
	end
end)