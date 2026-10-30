local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("SoundService")
local MPS = game:GetService("MarketplaceService")

local player = game.Players.LocalPlayer

local MainGui = player.PlayerGui:WaitForChild("MainGui")

local leaderstats = player:WaitForChild("leaderstats")
local otherStats = player:WaitForChild("otherStats")

local remotesFolder = RS:WaitForChild("Remotes")
local changerRemote = remotesFolder.ChangeValue

local productsModule = require(RS:WaitForChild("Modules").Products)
local framesHolderModule = require(script.FramesHandler)
local RobuxFrameModule = require(RS.Modules.Robux)
local notifiModule = require(RS.Modules.Notifications)
local globalSettings = require(RS.GlobalSettings)

function animateButton(button, scale)
	local uiScale = button:FindFirstChildWhichIsA("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = button
	end
	TS:Create(uiScale, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		Scale = scale
	}):Play()
end

local function changeRobuxValue(object)
	if not object then return end

	if productsModule.Gamepasses[object.Parent.Parent.Name] then
		local gamepassId = productsModule.Gamepasses[object.Parent.Parent.Name].Id
		local success, owns = pcall(function()
			return MPS:UserOwnsGamePassAsync(player.UserId, gamepassId)
		end)

		if success and owns then
			object.Title.Text = "Owned"
			object.ImageLabel:Destroy()
		else
			object.Title.Text = MPS:GetProductInfo(gamepassId, Enum.InfoType.GamePass).PriceInRobux
		end

	elseif productsModule.Products[object.Parent.Parent.Name] then
		object.Title.Text = MPS:GetProductInfo(productsModule.Products[object.Parent.Parent.Name].Id, Enum.InfoType.Product).PriceInRobux
	end
end

local function handleButtons()
	for _, object in pairs(MainGui:GetDescendants()) do
		if object:IsA("TextButton") or object:IsA("ImageButton") then
			if object.Name == "Purchase" then
				changeRobuxValue(object)
			end
			object.MouseEnter:Connect(function()
				SS.Hover:Play()
				animateButton(object, 1.1)
			end)
			object.MouseLeave:Connect(function()
				animateButton(object, 1)
			end)
			object.MouseButton1Down:Connect(function()
				animateButton(object, 0.9)
			end)
			object.MouseButton1Up:Connect(function()
				SS.Click:Play()
				if object:FindFirstChild("Warning") then
					object.Warning:Destroy()
				end
				if object.Name == "Friends" then
					game.SocialService:PromptGameInvite(player)
				end
				animateButton(object, 1)
				if object:FindFirstChild("Frame") then
					framesHolderModule.OpenFrame(player, object.Frame.Value, object)
				end
				if object.Name == "Purchase" and object.Title.Text ~= "Owned" then
					if productsModule.Gamepasses[object.Parent.Parent.Name] then
						local product = productsModule.Gamepasses[object.Parent.Parent.Name]
						if product then
							MPS:PromptGamePassPurchase(player, product.Id)
							RobuxFrameModule.CreateFrame(player)
						end
					elseif productsModule.Products[object.Parent.Parent.Name] then
						local product = productsModule.Products[object.Parent.Parent.Name]
						if product then
							MPS:PromptProductPurchase(player, product.Id)
							RobuxFrameModule.CreateFrame(player)
						end
					end
				end
			end)
		end
	end
end

local function handlePurchase(playerOrId, productId, wasPurchased)
	if not wasPurchased then
		RobuxFrameModule.HideFrame(player)
		return
	end
	local player

	if typeof(playerOrId) == "Instance" and playerOrId:IsA("Player") then
		player = playerOrId
	elseif typeof(playerOrId) == "number" then
		player = game.Players:GetPlayerByUserId(playerOrId)
	end

	if not player then
		warn("Player not found for purchase:", playerOrId)
		return
	end
	local Product = nil
	for name, product in pairs(productsModule.Products) do
		if product.Id == productId then
			Product = product
			break
		end
	end
	if Product == nil then
		for name, product in pairs(productsModule.Gamepasses) do
			if product.Id == productId then
				Product = product
				for _, frame in player.PlayerGui.MainGui.ShopFrame:GetDescendants() do
					if frame:IsA("Frame") and frame.Name == Product.Name then
						local text = frame:FindFirstChild("Frame"):FindFirstChild("Purchase"):FindFirstChild("Title")
						if text then
							text.Text = "Owned"
							text.Parent.ImageLabel:Destroy()
						end
					end
				end
				break
			end
		end
	end
	if Product.Amount then
		local Folder = Product.Folder
		local Amount = Product.Amount
		local Value = Product.Value
		if Value and Amount and Folder then
			changerRemote:FireServer(player:FindFirstChild(Folder):FindFirstChild(Value), player:FindFirstChild(Folder):FindFirstChild(Value).Value + Amount)
		end
	end

	if Product.Name == "2xCash" then
		remotesFolder.UpdateText:Fire(Product)
		remotesFolder.ObtainedGamepass:FireServer("2xCash")
		player.PlayerGui.MainGui.Boosters.x2CashBoost.Visible = true
		player.PlayerGui.MainGui.CashDisplay.x2Cash.Visible = false
	elseif Product.Name == "2xSpeed" then
		remotesFolder.ObtainedGamepass:FireServer("2xSpeed")
		player.PlayerGui.MainGui.Boosters.x2SpeedBoost.Visible = true
		player.PlayerGui.MainGui.CashDisplay.x2Speed.Visible = false
	elseif Product.Name == "AutoCollect" then
		remotesFolder.ObtainedGamepass:FireServer("AutoCollect")
		player.PlayerGui.MainGui.Boosters.AutoCollect.Visible = true
	elseif Product.Name == "VIP" then
		remotesFolder.UpdateText:Fire(Product)
		remotesFolder.ObtainedGamepass:FireServer("VIP")
		player.PlayerGui.MainGui.Boosters.VIP.Visible = true
		changerRemote:FireServer(player.otherStats.VIPBenefitsObtained, player.otherStats.VIPBenefitsObtained.Value + 1)
		changerRemote:FireServer(player.leaderstats.Cash, player.leaderstats.Cash.Value + 1000000)
	end
	SS.Purchase:Play()
	notifiModule.CreateNotification(player, "Thank you for your purchase!", 5, "Green")
	RobuxFrameModule.HideFrame(player)
end

MPS.PromptProductPurchaseFinished:Connect(handlePurchase)
MPS.PromptGamePassPurchaseFinished:Connect(handlePurchase)

handleButtons()