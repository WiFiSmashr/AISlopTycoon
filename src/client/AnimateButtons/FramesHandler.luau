local TS = game:GetService("TweenService")

local FramesHandler = {}

local FrameSizes = {}

local debounce = false
local oldFrame

function FramesHandler.OpenFrame(player, frame, object)
	if debounce then return end
	debounce = true
	local MainGui = player.PlayerGui.MainGui
	local Camera = game.Workspace:WaitForChild("Camera")

	if frame then
		if frame.Visible then
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
			TS:Create(game.Lighting.Blur, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Size = 0}):Play()
			local FOVTWEEN = TS:Create(Camera, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {FieldOfView = 70})
			FOVTWEEN:Play()
			TS:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position =UDim2.new(0.5, 0,0.581, 0) }):Play()
			frame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.1, true)
			task.wait(0.1)
			frame.Visible = false
		else
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			if oldFrame and oldFrame.Name ~= frame.Name then
				oldFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.1, true)
				task.wait(0.1)
				oldFrame.Visible = false
			end
			if not FrameSizes[frame.Name] then
				FrameSizes[frame.Name] = frame.Size
			end

			TS:Create(game.Lighting.Blur, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Size = 24}):Play()
			local FOVTWEEN = TS:Create(Camera, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {FieldOfView = 70})
			FOVTWEEN:Play()
			
			frame.Size = UDim2.new(0,0,0,0) 
			frame.Position = UDim2.new(0.5, 0,0.581, 0)
			frame.Visible = true

			oldFrame = frame
			local targetSize = FrameSizes[frame.Name] or UDim2.new(0.3, 0, 0.5, 0)
			frame:TweenSize(targetSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quint,0.1, true)
			TS:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position =UDim2.new(0.5, 0,0.5, 0) }):Play()
			if oldFrame and oldFrame.Name ~= frame.Name then
				task.wait(0.2)
				oldFrame.Visible = false
			end
		end
	end
	debounce = false
end

return FramesHandler
