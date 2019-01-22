--[[
SelectiveReplicator.lua 1.0
Author: Merely

This lets you replicate instances from server->client without replicating to all other clients.
Useful in cases where the objects are not relevant to every client.
Uses PlayerGui as storage.
  
Example usage:

-- Local script
local key = "ModelToPreload"

local model = SelectiveReplicator:GetFromServer(key, function()
	-- This function is only called if the model with name = 'key' is not found in the local cache
	-- Once it has been called successfully, the script short-circuits and returns the local copy instead
	-- This makes it safe to call multiple times without worrying about whether it's loaded.
	return game.ReplicatedStorage.Remotes.Preview.LoadModel:InvokeServer(key)
end)
  
-- Server script
game.ReplicatedStorage.Remotes.Preview.LoadModel.OnServerInvoke = function(player, key)
	print("Player " .. tostring(player) .. " asked to replicate model with key " .. tostring(key))
	local model = game.ServerStorage.ModelsForReplication:FindFirstChild(tostring(key))
	if model == nil then
		error("No model found with key " .. key)
	end

	return SelectiveReplicator:ReplicateToClient(player, key, function()
		-- This function is only called if the object hasn't been replicated to the player yet.
		-- You could do InsertService:LoadAsset() calls or other expensive operations here as needed.
		return model
  	end)
end

--]]



local SelectiveReplicator = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local folderName = "SelectiveReplication"
local ClientFolder = nil

local function getFolderForServer(player)
	local folder = player.PlayerGui:FindFirstChild(folderName)
	if folder then
		return folder
	end
	folder = Instance.new("Folder")
	folder.Name = folderName
	folder.Parent = player.PlayerGui
	return folder
end

local function getClientFolder()
	if ClientFolder then
		return ClientFolder
	end
	
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui == nil then
		return nil
	end
	
	ClientFolder = playerGui:FindFirstChild(folderName)
	if ClientFolder then
		ClientFolder.Parent = ReplicatedStorage
		print("Moved ClientFolder to location that won't get wiped")
	end
	
	return ClientFolder -- can be nil
end

function SelectiveReplicator:ReplicateToClient(player, key, instanceGetter)
	if not isServer then
		error("ReplicateToClient should only be called from server")
	end
	
	local folder = getFolderForServer(player)
	local instance = folder:FindFirstChild(key)
	if instance then
		return instance
	end
	instance = instanceGetter()
	instance.Name = key
	instance.Parent = folder
	return instance
end


function SelectiveReplicator:GetFromServer(key, instanceGetter)
	if not isClient then
		error("GetFromServer should only be called from client")
	end
	
	local clientFolder = getClientFolder()
	if clientFolder then
		local existingInstance = clientFolder:FindFirstChild(key)
		if existingInstance then
			return existingInstance
		end
	end
	local instance = instanceGetter()
	instance.Parent = nil
	return instance
end

return SelectiveReplicator
