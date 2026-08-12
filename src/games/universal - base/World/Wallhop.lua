local Wallhop
local Offset
local HumanizedFlick

local params = OverlapParams.new()
params.RespectCanCollide = true

local timeout = os.clock()

-- Original one-frame flick state
local set

-- Humanized flick state
local flickStarted
local flickApplied = 0

local flickOutTime = 0.055
local flickHoldTime = 0.025
local flickReturnTime = 0.065

local function smoothStep(value)
	value = math.clamp(value, 0, 1)
	return value * value * (3 - (2 * value))
end

local function restoreCamera()
	if set then
		gameCamera.CFrame = CFrame.new(
			gameCamera.CFrame.Position.X,
			gameCamera.CFrame.Position.Y,
			gameCamera.CFrame.Position.Z,
			unpack(set, 4, set.n)
		)

		set = nil
	end

	if flickApplied ~= 0 then
		gameCamera.CFrame *= CFrame.Angles(
			0,
			math.rad(-flickApplied),
			0
		)

		flickApplied = 0
	end

	flickStarted = nil
end

local function updateHumanizedFlick()
	if not flickStarted then
		return false
	end

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
		local progress = smoothStep(
			(elapsed - returnStart) / flickReturnTime
		)

		desiredAngle = Offset.Value * (1 - progress)
	else
		desiredAngle = 0
	end

	local angleChange = desiredAngle - flickApplied

	if angleChange ~= 0 then
		gameCamera.CFrame *= CFrame.Angles(
			0,
			math.rad(angleChange),
			0
		)
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
		gameCamera.CFrame = CFrame.new(
			gameCamera.CFrame.Position.X,
			gameCamera.CFrame.Position.Y,
			gameCamera.CFrame.Position.Z,
			unpack(set, 4, set.n)
		)

		set = nil
	end

	-- Continue an existing humanized flick before checking for another hop.
	if updateHumanizedFlick() then
		return
	end

	local hum = entitylib.isAlive
		and entitylib.character.Humanoid

	if not (
		hum
		and hum.Jump
		and hum.MoveDirection.Magnitude > 0
	) then
		return
	end

	local root = entitylib.character.RootPart

	params.CollisionGroup = root.CollisionGroup
	params.FilterDescendantsInstances = {
		lplr.Character
	}

	if root.AssemblyLinearVelocity.Y >= 0 then
		return
	end

	if hum.FloorMaterial ~= Enum.Material.Air then
		return
	end

	local parts = workspace:GetPartBoundsInBox(
		CFrame.new(
			root.Position
				- Vector3.new(
					0,
					entitylib.character.HipHeight / 2,
					0
				)
		),
		Vector3.new(
			3,
			entitylib.character.HipHeight,
			3
		),
		params
	)

	local doHop = false

	for _, part in parts do
		local position = part:GetClosestPointOnSurface(
			root.Position
		)

		local difference = root.Position.Y - position.Y

		if difference > root.Size.Y / 2 then
			doHop = true
			break
		end
	end

	if not doHop or os.clock() - timeout <= 0.2 then
		return
	end

	if HumanizedFlick.Enabled then
		-- Perform the same camera flick gradually over several frames.
		flickStarted = os.clock()
		flickApplied = 0
	else
		-- Original instant one-frame flick.
		set = table.pack(
			gameCamera.CFrame:GetComponents()
		)

		gameCamera.CFrame *= CFrame.Angles(
			0,
			math.rad(Offset.Value),
			0
		)
	end

	timeout = os.clock()
end

Wallhop = vape.Categories.World:CreateModule({
	Name = 'Wallhop',

	Function = function(callback)
		if callback then
			if workspace.AuthorityMode
				== Enum.AuthorityMode.Server then

				Wallhop:Clean(
					runService:BindToSimulation(doCheck)
				)
			else
				Wallhop:Clean(
					runService.RenderStepped:Connect(doCheck)
				)
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

HumanizedFlick = Wallhop:CreateToggle({
	Name = 'better wallhop',

	Function = function()
		restoreCamera()
	end,

	Tooltip = 'same logic but more human ig'
})