local TweenService = game:GetService("TweenService")

local Notification = {}

function Notification.CreateNotification(plr, message, duration, color)
	local NotificationFrame = plr.PlayerGui:WaitForChild("MainGui").Notifications
	if NotificationFrame then
		spawn(function()
			local template = NotificationFrame:WaitForChild("Template"):Clone()
			template.Text = message
			if color == "Red" then
				template.PinkGradient.Enabled = false
				template.RedGradient.Enabled = true
				template.GreenGradient.Enabled = false
				template.OrangeGradient.Enabled = false
			elseif color == "Pink"  then
				template.PinkGradient.Enabled = true
				template.RedGradient.Enabled = false
				template.GreenGradient.Enabled = false
				template.OrangeGradient.Enabled = false
			elseif color == "Orange"  then
				template.PinkGradient.Enabled = false
				template.RedGradient.Enabled = false
				template.GreenGradient.Enabled = false
				template.OrangeGradient.Enabled = true
			else
				template.PinkGradient.Enabled = false
				template.RedGradient.Enabled = false
				template.GreenGradient.Enabled = true
				template.OrangeGradient.Enabled = false
			end
			template.Name = "Notification"
			template.Visible = true
			template.Parent = NotificationFrame

			template.Size = UDim2.new(0, 0, 0, 0)

			local popupTween = TweenService:Create(template, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0.12, 0)})
			popupTween:Play()

			task.wait(duration - 0.5)  

			local fadeTween = TweenService:Create(template, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
			fadeTween:Play()
			local fadeTweenStroke = TweenService:Create(template.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1})
			fadeTweenStroke:Play()

			wait(0.5)
			template:Destroy()
		end)
	end
end

return Notification
