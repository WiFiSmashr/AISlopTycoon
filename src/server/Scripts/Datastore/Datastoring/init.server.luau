local DataStoreService = game:GetService("DataStoreService")
local MPS = game:GetService("MarketplaceService")
local RS = game:GetService("ReplicatedStorage")
local myDataStore = DataStoreService:GetDataStore("Data#" .. script.DataVersion.Value)

local notificationModule = require(RS:WaitForChild("Modules").Notifications)
local products = require(RS:WaitForChild("Modules").Products)
local globalSettings = require(RS.GlobalSettings)

local saving = script["Saving"]

game.Players.PlayerAdded:Connect(function(plr)
	local key = plr.UserId .. "'s' Data"
	local success, data = pcall(function()
		if not globalSettings.SavingEnabled then
			return nil
		else
			return myDataStore:GetAsync(key)
		end
	end)

	if not success and globalSettings.SavingEnabled then
		notificationModule.CreateNotification(plr, "⚠️ Warning: Data could not be loaded. Please enable datastoring in game's settings in studio.", 20, "Red")
		data = nil
	end

	for _, folder in pairs(script:GetChildren()) do
		if folder:IsA("Folder") then
			local fc = folder:Clone()
			fc.Parent = plr

			if saving then
				for _, item in pairs(fc:GetChildren()) do
					if data then
						item.Value = data[item.Name .. " " .. folder.Name]
					else
						warn("There is no data!")
					end
				end
			end
		end
	end
	if MPS:UserOwnsGamePassAsync(plr.UserId, products.Gamepasses["2xSpeed"].Id) then
		plr:SetAttribute("2xSpeed", true)
	end
	if MPS:UserOwnsGamePassAsync(plr.UserId, products.Gamepasses["AutoCollect"].Id) then
		plr:SetAttribute("AutoCollect", true)
	end
	if MPS:UserOwnsGamePassAsync(plr.UserId, products.Gamepasses["2xCash"].Id) then
		plr:SetAttribute("2xCash", true)
	end
	if MPS:UserOwnsGamePassAsync(plr.UserId, products.Gamepasses.VIP.Id) then
		plr:SetAttribute("VIP", true)
		if plr.otherStats.VIPBenefitsObtained.Value == 0 then
			plr.otherStats.VIPBenefitsObtained.Value = 1
			notificationModule.CreateNotification(plr, "You have received the VIP benefits! (VIP Chat tag, +$1M Cash and +25% Cash)", 5, "Green")
			plr.leaderstats.Cash.Value += 1000000
		end
	end
end)

if saving then
	local function create_table(plr)
		local player_stats = {}

		for _, folder in pairs(script:GetChildren()) do
			if folder:IsA("Folder") then
				for _, stat in pairs(plr:FindFirstChild(folder.Name):GetChildren()) do
					player_stats[stat.Name .. " " .. folder.Name] = stat.Value
				end
			end
		end

		return player_stats
	end

	game.Players.PlayerRemoving:Connect(function(plr)
		if not globalSettings.SavingEnabled then
			return
		end

		local player_stats = create_table(plr)

		local success, err = pcall(function()
			local key = plr.UserId .. "'s' Data"
			myDataStore:SetAsync(key, player_stats)
		end)

		if success then
			print("Saved Data Correctly!")
		else
			warn("⚠️ Error saving data: " .. err)
		end
	end)
end

print("✅ Datastore has successfully loaded. Made by @aligocz <3")