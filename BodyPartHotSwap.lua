--[[
BodyPartHotswap v1
Allows you to replace body parts of an R6 or R15 character without killing the character
humanoid:BuildRigFromAttachments() creates the necessary attachments so the new part attaches properly with R15
See this wiki page for more information: http://wiki.roblox.com/index.php?title=R15_Compatibility_Guide

Example usage:
local character = game:GetService("Players"):GetPlayers()[1].Character
local goldenRobloxianBodyParts = {
	502448370, -- Torso
	502448293, -- Right Leg
	502448162, -- Right Arm
	502448231, -- Left Leg
	502448009 -- Left Arm
}
applyBodyParts(character, goldenRobloxianBodyParts)
]]--

local function getOldCharacterMesh(character, newCharacterMesh)
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("CharacterMesh") and obj.BodyPart == newCharacterMesh.BodyPart then
            return obj
        end 
    end
    return nil
end

local function applyBodyPart(character, bodyPartModel)
	-- assume bodyPartModel is a Model that contains a folder named R6 and a folder named R15
	local humanoid = character.Humanoid
	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		local r15Folder = bodyPartModel:FindFirstChild("R15")
		if r15Folder == nil then
			return
		end
		for _,bodyPart in pairs(r15Folder:GetChildren()) do
			local existingPart = character:FindFirstChild(bodyPart.Name)
			if existingPart then
				existingPart:Destroy()
				bodyPart.Parent = character
			end
			-- attach the new parts to the character if needed
			character.Humanoid:BuildRigFromAttachments()
		end
	elseif humanoid.RigType == Enum.HumanoidRigType.R6 then
		local r6Folder = bodyPartModel:FindFirstChild("R6")
		if r6Folder == nil then
			return
		end
		for _, characterMesh in pairs(r6Folder:GetChildren()) do
			local existingCharacterMesh = getOldCharacterMesh(character, characterMesh)
			if existingCharacterMesh then
				existingCharacterMesh:Destroy()
            		end
			characterMesh.Parent = character
        	end
	end
end

local function applyBodyParts(character, assetIds)
	for _,assetId in pairs(assetIds) do
		local bodyPartModel = game:GetService("InsertService"):LoadAsset(assetId)
		applyBodyPart(character, bodyPartModel)
	end
end
