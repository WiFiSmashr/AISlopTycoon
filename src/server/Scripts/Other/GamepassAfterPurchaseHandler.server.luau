local MPS = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local products = require(RS:WaitForChild("Modules").Products)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(1)
		if player:GetAttribute("2xSpeed") == true then
			character.Humanoid.WalkSpeed *= 2
		end
	end)
end)

RS.Remotes.ObtainedGamepass.OnServerEvent:Connect(function(player, gamepassName)
	if gamepassName == "2xSpeed" then
		player:SetAttribute("2xSpeed", true)
		player.Character.Humanoid.WalkSpeed *= 2
	elseif gamepassName == "2xCash" then
		player:SetAttribute("2xCash", true)
	elseif gamepassName == "AutoCollect" then
		player:SetAttribute("AutoCollect", true)
	elseif gamepassName == "VIP" then
		player:SetAttribute("VIP", true)
	end
end)