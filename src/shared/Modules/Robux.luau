local Robux = {}

local TS = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

function Robux.CreateFrame(plr)
	local robuxFrame = plr.PlayerGui.RobuxGUI.Robux
	if robuxFrame and not robuxFrame.Visible then
		local backgroundTR = TS:Create(robuxFrame, tweenInfo, {BackgroundTransparency = 0.5})
		local imageTransparency = TS:Create(robuxFrame.ImageLabel, tweenInfo, {ImageTransparency = 0})
		
		robuxFrame.BackgroundTransparency = 1
		robuxFrame.ImageLabel.ImageTransparency = 1
		robuxFrame.Visible = true
		backgroundTR:Play()
		imageTransparency:Play()
	end
end

function Robux.HideFrame(plr)
	local robuxFrame = plr.PlayerGui.RobuxGUI.Robux
	if robuxFrame then
		local backgroundTR = TS:Create(robuxFrame, tweenInfo, {BackgroundTransparency = 1})
		local imageTransparency = TS:Create(robuxFrame.ImageLabel, tweenInfo, {ImageTransparency = 1})

		backgroundTR:Play()
		imageTransparency:Play()

		backgroundTR.Completed:Connect(function()
			robuxFrame.Visible = false
		end)
	end
end

return Robux