local TextChatService = game:GetService("TextChatService")
local MPS = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local products = require(game.ReplicatedStorage:WaitForChild("Modules").Products)

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local props = Instance.new("TextChatMessageProperties")
	
	if message.TextSource then
		local player = Players:GetPlayerByUserId(message.TextSource.UserId)
		
		if MPS:UserOwnsGamePassAsync(player.UserId, products.Gamepasses.VIP.Id) then
			props.PrefixText = "<font color='#F5CD30'>[VIP]</font> " .. message.PrefixText
		end
	end
	
	return props	
end