local SpinBot
local XToggle
local YToggle
local ZToggle
local Value
local AntiAim
local AntiAimPitch
local AntiAimView
local AntiAimPitchRandom
local AntiAimMode

local lastPitchUpdate = 0
local lastPitchValue = 0
local jitterState = false
local SpinAngle = 0

local RunService = game:GetService('RunService')
local UpdateReplication

local VisualGhost
local GhostCharacter
local GhostRoot
local GhostMotors = {}
local HiddenParts = {}

local inSCPRP = game.PlaceId == 5041144419 or game.PlaceId == 10953555034

if inSCPRP then
	UpdateReplication = game:GetService('ReplicatedStorage').Remotes.UpdateReplication
end

local function restorePlayerVisibility()
	for part, transparency in HiddenParts do
		if part.Parent then
			part.LocalTransparencyModifier = transparency
		end
	end

	table.clear(HiddenParts)
end

local function hidePlayer(character)
	if not character then return end

	for _, descendant in character:GetDescendants() do
		if descendant:IsA('BasePart') then
			if HiddenParts[descendant] == nil then
				HiddenParts[descendant] = descendant.LocalTransparencyModifier
			end

			descendant.LocalTransparencyModifier = 1
		end
	end
end

local function destroyGhost()
	if VisualGhost then
		VisualGhost:Destroy()
	end

	VisualGhost = nil
	GhostCharacter = nil
	GhostRoot = nil
	table.clear(GhostMotors)
end

local function clearPlayerView()
	restorePlayerVisibility()
	destroyGhost()
end

local function findCloneInstance(realInstance, realCharacter, cloneCharacter)
	local path = {}
	local current = realInstance

	while current and current ~= realCharacter do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end

	if current ~= realCharacter then return end

	current = cloneCharacter

	for _, name in path do
		current = current and current:FindFirstChild(name)
		if not current then return end
	end

	return current
end

local function findMotor(character, name)
	if not character then return end

	for _, descendant in character:GetDescendants() do
		if descendant:IsA('Motor6D') and descendant.Name == name then
			return descendant
		end
	end
end

local function createPlayerGhost(character)
	clearPlayerView()
	if not character then return false end

	local oldArchivable = character.Archivable
	character.Archivable = true

	local success, clone = pcall(function()
		return character:Clone()
	end)

	character.Archivable = oldArchivable

	if not success or not clone then
		return false
	end

	VisualGhost = clone
	GhostCharacter = character
	VisualGhost.Name = 'AntiAimPlayerView'
	GhostRoot = VisualGhost:FindFirstChild('HumanoidRootPart')

	if not GhostRoot then
		destroyGhost()
		return false
	end

	local humanoid = VisualGhost:FindFirstChildOfClass('Humanoid')

	if humanoid then
		humanoid.AutoRotate = false
		humanoid.BreakJointsOnDeath = false
		humanoid.RequiresNeck = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

		pcall(function()
			humanoid.EvaluateStateMachine = false
		end)
	end

	for _, descendant in VisualGhost:GetDescendants() do
		if descendant:IsA('Script')
			or descendant:IsA('LocalScript')
			or descendant:IsA('ModuleScript')
			or descendant:IsA('BillboardGui')
			or descendant:IsA('Sound') then
			descendant:Destroy()
		elseif descendant:IsA('BasePart') then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant.AssemblyLinearVelocity = Vector3.zero
			descendant.AssemblyAngularVelocity = Vector3.zero
			descendant.LocalTransparencyModifier = 0
		end
	end

	GhostRoot.Anchored = true
	GhostRoot.Transparency = 1
	VisualGhost.Parent = workspace

	if humanoid then
		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		end)
	end

	for _, realMotor in character:GetDescendants() do
		if realMotor:IsA('Motor6D') then
			local ghostMotor = findCloneInstance(realMotor, character, VisualGhost)

			if ghostMotor and ghostMotor:IsA('Motor6D') then
				GhostMotors[realMotor] = ghostMotor
			end
		end
	end

	return true
end

local function updatePlayerGhost(character, pitch, fakeYaw)
	if not VisualGhost
		or not VisualGhost.Parent
		or GhostCharacter ~= character then
		if not createPlayerGhost(character) then
			return false
		end
	end

	local realRoot = character:FindFirstChild('HumanoidRootPart')

	if not realRoot or not GhostRoot or not GhostRoot.Parent then
		return false
	end
	
	for realMotor, ghostMotor in GhostMotors do
		if realMotor.Parent and ghostMotor.Parent then
			ghostMotor.Transform = realMotor.Transform
		end
	end
	
	GhostRoot.CFrame = CFrame.new(realRoot.Position) * CFrame.Angles(0, fakeYaw, 0)

	local pitchOffset = CFrame.Angles(math.rad(pitch), 0, 0)
	local realWaist = findMotor(character, 'Waist')
	local ghostWaist = realWaist and GhostMotors[realWaist]

	if ghostWaist then
		ghostWaist.Transform = realWaist.Transform * pitchOffset
		return true
	end

	-- fallback if they are in r6
	local realRootJoint = findMotor(character, 'RootJoint')
	local ghostRootJoint = realRootJoint and GhostMotors[realRootJoint]

	if ghostRootJoint then
		ghostRootJoint.Transform = realRootJoint.Transform * pitchOffset
	end

	local inversePitch = CFrame.Angles(math.rad(-pitch), 0, 0)
	local realLeftHip = findMotor(character, 'Left Hip')
	local ghostLeftHip = realLeftHip and GhostMotors[realLeftHip]

	if ghostLeftHip then
		ghostLeftHip.Transform = realLeftHip.Transform * inversePitch
	end

	local realRightHip = findMotor(character, 'Right Hip')
	local ghostRightHip = realRightHip and GhostMotors[realRightHip]

	if ghostRightHip then
		ghostRightHip.Transform = realRightHip.Transform * inversePitch
	end

	return true
end

local function updateAntiAimView(character, pitch, fakeYaw)
	if not AntiAimView or not AntiAimView.Enabled then
		clearPlayerView()
		return
	end

	if updatePlayerGhost(character, pitch, fakeYaw) then
		hidePlayer(character)
	else
		clearPlayerView()
	end
end

local function getAntiAimPitch()
	local mode = AntiAimMode.Value
	local currentTime = tick()

	if mode == 'Static' then
		lastPitchValue = AntiAimPitch.Value
	elseif mode == 'Random' then
		if currentTime - lastPitchUpdate >= 1 then
			lastPitchValue = AntiAimPitchRandom:GetRandomValue()
			lastPitchUpdate = currentTime
		end
	elseif mode == 'Jitter' and currentTime - lastPitchUpdate >= 1 then
		jitterState = not jitterState
		lastPitchValue = jitterState and AntiAimPitchRandom.ValueMin or AntiAimPitchRandom.ValueMax
		lastPitchUpdate = currentTime
	end

	return lastPitchValue
end

local function sendPitch(pitch)
	if not UpdateReplication then return end

	pitch = math.clamp(math.round(pitch), -90, 90)

	local values

	if pitch < 0 then
		values = {2, 1, 255 + pitch}
	else
		values = {2, 0, pitch}
	end

	local packet = buffer.create(#values)

	for index, value in values do
		buffer.writeu8(packet, index - 1, value)
	end

	UpdateReplication:FireServer(packet)
end

local function restartSpinBot()
	if SpinBot and SpinBot.Enabled then
		SpinBot:Toggle()
		SpinBot:Toggle()
	end
end

local function updateAntiAimOptionVisibility()
	if not AntiAim then return end

	local enabled = AntiAim.Enabled
	local mode = AntiAimMode and AntiAimMode.Value

	if AntiAimMode then
		AntiAimMode.Object.Visible = enabled
	end

	if AntiAimView then
		AntiAimView.Object.Visible = enabled
	end

	if AntiAimPitch then
		AntiAimPitch.Object.Visible = enabled and mode == 'Static'
	end

	if AntiAimPitchRandom then
		AntiAimPitchRandom.Object.Visible = enabled and (mode == 'Random' or mode == 'Jitter')
	end
end

SpinBot = vape.Categories.Blatant:CreateModule({
	Name = 'SpinBot',
	Function = function(callback)
		if callback then
			SpinAngle = 0
			lastPitchUpdate = 0
			lastPitchValue = 0
			jitterState = false

			SpinBot:Clean(RunService.PreSimulation:Connect(function(delta)
				if not entitylib.isAlive then
					clearPlayerView()
					return
				end

				local character = entitylib.character.Character
				local root = entitylib.character.RootPart

				if not character or not root then
					clearPlayerView()
					return
				end

				SpinAngle = (SpinAngle + math.rad(20 * Value.Value) * delta) % (math.pi * 2)

				local x, y, z = root.CFrame:ToOrientation()
				local fakeYaw = YToggle.Enabled and SpinAngle or y

				root.CFrame = CFrame.new(root.Position) * CFrame.Angles(XToggle.Enabled and SpinAngle or x, fakeYaw, ZToggle.Enabled and SpinAngle or z)

				if inSCPRP and AntiAim and AntiAim.Enabled then
					local pitch = getAntiAimPitch()
					updateAntiAimView(character, pitch, fakeYaw)
					sendPitch(pitch)
				else
					clearPlayerView()
				end
			end))
		else
			clearPlayerView()

			if inSCPRP then
				sendPitch(0)
			end
		end
	end,
	Tooltip = 'Makes your character continuously spin'
})

Value = SpinBot:CreateSlider({
	Name = 'Speed',
	Min = 1,
	Max = 100,
	Default = 40
})

if inSCPRP then
	AntiAim = SpinBot:CreateToggle({
		Name = 'Anti Aim',
		Function = function()
			updateAntiAimOptionVisibility()
			restartSpinBot()
		end,
		Tooltip = 'Spoofs your pitch server-side'
	})

	AntiAimMode = SpinBot:CreateDropdown({
		Name = 'AimType',
		List = {'Static', 'Random', 'Jitter'},
		Function = function()
			updateAntiAimOptionVisibility()
			restartSpinBot()
		end,
		Tooltip = 'Forces your pitch in three ways\nStatic: always one value\nRandom: random value in a range\nJitter: switches between two values'
	})

	AntiAimView = SpinBot:CreateToggle({
		Name = 'Serverside view',
		Function = restartSpinBot,
		Tooltip = 'lets you somewhat accruately see what others see ur character as'
	})

	AntiAimPitch = SpinBot:CreateSlider({
		Name = 'Pitch',
		Min = -90,
		Max = 90,
		Default = 0
	})

	AntiAimPitchRandom = SpinBot:CreateTwoSlider({
		Name = 'Pitch range',
		Min = -90,
		Max = 90,
		DefaultMin = -90,
		DefaultMax = 90
	})

	updateAntiAimOptionVisibility()
end

XToggle = SpinBot:CreateToggle({Name = 'Spin X'})

YToggle = SpinBot:CreateToggle({
	Name = 'Spin Y',
	Default = true
})

ZToggle = SpinBot:CreateToggle({Name = 'Spin Z'})