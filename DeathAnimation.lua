--[[
When a player dies, creates a clone of their character and plays a death animation of your choosing
Place in ServerScriptService
--]]

-- Replace with your animation
local deathAnimation = game.ReplicatedStorage.Animations.Wipeout
local animationLength = 4

function onCharacterAdded(player)
	local character = player.Character
	character.Humanoid.Died:connect(function()
		character.Archivable = true
		local dummyCharacter = character:Clone()
		character.Archivable = false
		character.Parent = nil
		for _,obj in pairs(dummyCharacter:GetChildren()) do
			if obj:IsA("Script") or obj:IsA("LocalScript") then
				obj:Destroy()
			end
		end		
		dummyCharacter.Parent = workspace
		dummyCharacter.Archivable = false
		dummyCharacter.Humanoid:LoadAnimation(deathAnimation):Play()
		wait(animationLength)
		dummyCharacter:Destroy()
	end)
end

function onPlayerAdded(player)
	if player.Character then
		onCharacterAdded(player)
	end
	player.CharacterAdded:connect(function()
		onCharacterAdded(player)
	end)
end

for _,player in pairs(game.Players:GetPlayers()) do
	onPlayerAdded(player)
end
game:GetService("Players").PlayerAdded:connect(onPlayerAdded)
