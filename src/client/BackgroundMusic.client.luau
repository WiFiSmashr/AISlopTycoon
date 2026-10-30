local MusicFolder = game.SoundService:WaitForChild("BackgroundMusic")

local ActiveMusic
local LastMusic = nil

spawn(function()
	while true do
		local Children = MusicFolder:GetChildren()

		if #Children < 2 then
			warn("Not enough music tracks to ensure uniqueness!")
			return
		end

		local ChosenMusic
		repeat
			ChosenMusic = Children[math.random(1, #Children)]
		until ChosenMusic ~= LastMusic

		ActiveMusic = ChosenMusic
		ActiveMusic:Play()
		ActiveMusic.Ended:Wait()
		LastMusic = ActiveMusic
	end	
end)

local function Update()
	repeat
		task.wait()
	until ActiveMusic ~= nil
	ActiveMusic:Play()
end