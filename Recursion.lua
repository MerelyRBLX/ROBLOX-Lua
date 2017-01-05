local function recur(obj, func)
	func(obj)
	for _,child in pairs(obj:GetChildren()) do
		recur(child, func)
	end
end

local function forAll(obj, className, func)
	recur(obj, function(o)
		if o:IsA(className) then
			func(o)
		end
	end)
end

--[[ Example usage: unanchor all parts in Workspace ]]--
forAll(game.Workspace, "BasePart", function(o)
	o.Anchored = false
end)
