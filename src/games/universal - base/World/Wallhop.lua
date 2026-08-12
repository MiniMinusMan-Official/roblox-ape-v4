local Wallhop
local Offset
local funnyflick
local FlickOutTime
local FlickHoldTime
local FlickReturnTime

local params = OverlapParams.new()
params.RespectCanCollide = true

local timeout = os.clock()
local set
local flickStarted
local flickApplied = 0

local function smoothStep(value)
	value = math.clamp(value, 0, 1)
	return value * value * (3 - (2 * value))
end

local function restoreCamera()
	if set then
		gameCamera.CFrame = CFrame.new(gameCamera.CFrame.Position.X, gameCamera.CFrame.Position.Y, gameCamera.CFrame.Position.Z, unpack(set, 4, set.n))
		set = nil
	end

	if flickApplied ~= 0 then
		gameCamera.CFrame *= CFrame.Angles(0, math.rad(-flickApplied), 0)
		flickApplied = 0
	end

	flickStarted = nil
end

local function updateFunnyFlick()
	if not flickStarted then
		return false
	end

	local flickOutTime = FlickOutTime.Value
	local flickHoldTime = FlickHoldTime.Value
	local flickReturnTime = FlickReturnTime.Value

	local elapsed = os.clock() - flickStarted
	local returnStart = flickOutTime + flickHoldTime
	local totalTime = returnStart + flickReturnTime
	local desiredAngle

	if elapsed < flickOutTime then
		local progress = smoothStep(elapsed / flickOutTime)
		desiredAngle = Offset.Value * progress
	elseif elapsed < returnStart then
		desiredAngle = Offset.Value
	elseif elapsed < totalTime then
		local progress = smoothStep((elapsed - returnStart) / flickReturnTime)
		desiredAngle = Offset.Value * (1 - progress)
	else
		desiredAngle = 0
	end

	local angleChange = desiredAngle - flickApplied

	if angleChange ~= 0 then
		gameCamera.CFrame *= CFrame.Angles(0, math.rad(angleChange), 0)
	end

	flickApplied = desiredAngle

	if elapsed >= totalTime then
		flickStarted = nil
		flickApplied = 0
		return false
	end

	return true
end

local function doCheck()
	if set then
		gameCamera.CFrame = CFrame.new(gameCamera.CFrame.Position.X, gameCamera.CFrame.Position.Y, gameCamera.CFrame.Position.Z, unpack(set, 4, set.n))
		set = nil
	end

	if updateFunnyFlick() then
		return
	end

	local hum = entitylib.isAlive and entitylib.character.Humanoid
	if not (hum and hum.Jump and hum.MoveDirection.Magnitude > 0) then
		return
	end

	local root = entitylib.character.RootPart
	params.CollisionGroup = root.CollisionGroup
	params.FilterDescendantsInstances = {lplr.Character}

	if root.AssemblyLinearVelocity.Y >= 0 or hum.FloorMaterial ~= Enum.Material.Air then
		return
	end

	local parts = workspace:GetPartBoundsInBox(CFrame.new(root.Position - Vector3.new(0, entitylib.character.HipHeight / 2, 0)), Vector3.new(3, entitylib.character.HipHeight, 3), params )

	local doHop = false

	for _, part in parts do
		local position = part:GetClosestPointOnSurface(root.Position)
		local difference = root.Position.Y - position.Y

		if difference > root.Size.Y / 2 then
			doHop = true
			break
		end
	end

	if not doHop or os.clock() - timeout <= 0.2 then
		return
	end

	if funnyflick.Enabled then
		flickStarted = os.clock()
		flickApplied = 0
	else
		set = table.pack(gameCamera.CFrame:GetComponents())
		gameCamera.CFrame *= CFrame.Angles(0, math.rad(Offset.Value), 0)
	end

	timeout = os.clock()
end

Wallhop = vape.Categories.World:CreateModule({
	Name = 'Wallhop',
	Function = function(callback)
		if callback then
			if workspace.AuthorityMode == Enum.AuthorityMode.Server then
				Wallhop:Clean(runService:BindToSimulation(doCheck))
			else
				Wallhop:Clean(runService.RenderStepped:Connect(doCheck))
			end
		else
			restoreCamera()
		end
	end,
	Tooltip = 'Automatically performs the camera flick needed for wallhopping.'
})

Offset = Wallhop:CreateSlider({
	Name = 'Offset',
	Min = -45,
	Max = 45,
	Default = 45,
	Suffix = 'degrees'
})

funnyflick = Wallhop:CreateToggle({
	Name = 'better wallhop',
	Function = function(callback)
		FlickOutTime.Object.Visible = callback
		FlickHoldTime.Object.Visible = callback
		FlickReturnTime.Object.Visible = callback
		restoreCamera()
	end,
	Tooltip = 'same logic but more human ig'
})

FlickOutTime = Wallhop:CreateSlider({
	Name = 'Flick Out Time',
	Min = 0.01,
	Max = 0.05,
	Default = 0.035,
	Decimal = 1000,
	Darker = true,
	Visible = false,
	Suffix = 's'
})

FlickHoldTime = Wallhop:CreateSlider({
	Name = 'Flick Hold Time',
	Min = 0.01,
	Max = 0.05,
	Default = 0.01,
	Decimal = 1000,
	Darker = true,
	Visible = false,
	Suffix = 's'
})

FlickReturnTime = Wallhop:CreateSlider({
	Name = 'Flick Return Time',
	Min = 0.01,
	Max = 0.05,
	Default = 0.04,
	Decimal = 1000,
	Darker = true,
	Visible = false,
	Suffix = 's'
})