-- Given a missile and a target point	
-- Calculate the direction the missile must be thrown to hit that point
-- Taken from https://www.roblox.com/catalog/81847365/Potato-Cannon
-- Merely 10/22/16

local Projectile = {}

local function calculateTheta(velocity, startPoint, targetPoint)

	local toTarget = targetPoint - startPoint	
	local dy = toTarget.Y
	toTarget = Vector3.new(toTarget.X, 0, toTarget.Z)
	local dx = toTarget.magnitude
	toTarget = toTarget.unit 
	
	-- Simplify the distance formula of a projectile 
	local g = math.abs(workspace.Gravity)
	local inRoot = (velocity * velocity * velocity * velocity) - (g * ((g * dx * dx) + (2 * dy * velocity * velocity)))
	if inRoot <= 0 then
		return 0.25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((velocity * velocity) + root) / (g*dx)

	local inATan2 = ((velocity * velocity) - root) / (g*dx)
	local a1 = math.atan(inATan1)
	local a2 = math.atan(inATan2)
	if a1 < a2 then return a1 end
	return a2
end

Projectile.getVelocity = function(throwVelocity, startPoint, targetPoint)		
	local theta = calculateTheta(throwVelocity, startPoint, targetPoint)
	local angleY = math.sin(theta)
	local angleXZ = math.cos(theta)
	local toTargetUnit = ((targetPoint - startPoint) * Vector3.new(1,0,1)).unit
	local vY = angleY *  throwVelocity
	local vX = toTargetUnit.X * angleXZ * throwVelocity 
	local vZ = toTargetUnit.Z * angleXZ * throwVelocity
	return Vector3.new(vX, vY, vZ)
end

return Projectile
