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
local GhostParts = {}
local GhostPitchParts = {}
local HiddenParts = {}
local ViewCharacter
local ViewPitch = 0
local ViewYaw = 0
local ViewActive = false

local LOWER_BODY_PARTS = {
	HumanoidRootPart = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
	['Left Leg'] = true,
	['Right Leg'] = true
}

local UPPER_BODY_PARTS = {
	LowerTorso = true,
	UpperTorso = true,
	Torso = true,
	Head = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	['Left Arm'] = true,
	['Right Arm'] = true
}

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
	table.clear(GhostParts)
	table.clear(GhostPitchParts)
end

local function clearPlayerView()
	restorePlayerVisibility()
	destroyGhost()
end

local function findCloneInstance(realInstance, realCharacter, cloneCharacter)
	local path = {}
	local current = realInstance

	while current and current ~= realCharacter do
		local siblingIndex = 0

		for _, sibling in current.Parent:GetChildren() do
			if sibling.Name == current.Name
				and sibling.ClassName == current.ClassName then
				siblingIndex += 1

				if sibling == current then
					break
				end
			end
		end

		table.insert(path, 1, {
			Name = current.Name,
			ClassName = current.ClassName,
			Index = siblingIndex
		})
		current = current.Parent
	end

	if current ~= realCharacter then return end

	current = cloneCharacter

	for _, segment in path do
		local matchIndex = 0
		local matchedChild

		for _, child in current:GetChildren() do
			if child.Name == segment.Name
				and child.ClassName == segment.ClassName then
				matchIndex += 1

				if matchIndex == segment.Index then
					matchedChild = child
					break
				end
			end
		end

		current = matchedChild

		if not current then
			return
		end
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

local function findPitchMotor(character)
	return findMotor(character, 'Root')
		or findMotor(character, 'RootJoint')
		or findMotor(character, 'Waist')
end

local function buildPitchParts(character)
	table.clear(GhostPitchParts)

	local pitchMotor = findPitchMotor(character)
	local startPart

	if pitchMotor then
		if pitchMotor.Part1
			and not LOWER_BODY_PARTS[pitchMotor.Part1.Name] then
			startPart = pitchMotor.Part1
		elseif pitchMotor.Part0
			and not LOWER_BODY_PARTS[pitchMotor.Part0.Name] then
			startPart = pitchMotor.Part0
		end
	end

	startPart = startPart
		or character:FindFirstChild('LowerTorso')
		or character:FindFirstChild('UpperTorso')
		or character:FindFirstChild('Torso')

	if not startPart then return end
	GhostPitchParts[startPart] = true

	for _, descendant in character:GetDescendants() do
		if descendant:IsA('BasePart')
			and UPPER_BODY_PARTS[descendant.Name] then
			GhostPitchParts[descendant] = true
		end
	end

	local joints = {}

	for _, descendant in character:GetDescendants() do
		if descendant:IsA('JointInstance')
			or descendant:IsA('WeldConstraint') then
			table.insert(joints, descendant)
		end
	end

	local changed = true

	while changed do
		changed = false

		for _, joint in joints do
			local part0 = joint.Part0
			local part1 = joint.Part1

			if part0 and part1 then
				if GhostPitchParts[part0]
					and not LOWER_BODY_PARTS[part1.Name]
					and not GhostPitchParts[part1] then
					GhostPitchParts[part1] = true
					changed = true
				elseif GhostPitchParts[part1]
					and not LOWER_BODY_PARTS[part0.Name]
					and not GhostPitchParts[part0] then
					GhostPitchParts[part0] = true
					changed = true
				end
			end
		end
	end

	for part in GhostPitchParts do
		if LOWER_BODY_PARTS[part.Name] then
			GhostPitchParts[part] = nil
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

	buildPitchParts(character)

	for _, realPart in character:GetDescendants() do
		if realPart:IsA('BasePart') then
			local ghostPart = findCloneInstance(realPart, character, VisualGhost)

			if ghostPart and ghostPart:IsA('BasePart') then
				GhostParts[realPart] = ghostPart
			end
		end
	end

	local realRoot = character:FindFirstChild('HumanoidRootPart')
	local ghostRoot = realRoot and GhostParts[realRoot]

	if not realRoot or not ghostRoot then
		destroyGhost()
		return false
	end

	local humanoid = VisualGhost:FindFirstChildOfClass('Humanoid')

	if humanoid then
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
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
			or descendant:IsA('Sound')
			or descendant:IsA('JointInstance')
			or descendant:IsA('Constraint')
			or descendant:IsA('BodyMover') then
			descendant:Destroy()
		elseif descendant:IsA('BasePart') then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant.AssemblyLinearVelocity = Vector3.zero
			descendant.AssemblyAngularVelocity = Vector3.zero
			descendant.LocalTransparencyModifier = 0
		end
	end

	ghostRoot.Transparency = 1
	VisualGhost.Parent = workspace

	if humanoid then
		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		end)
	end

	return true
end

local function getPitchPivot(character)
	local motor = findPitchMotor(character)

	if motor and motor.Part0 then
		return motor.Part0.CFrame * motor.C0 * motor.Transform
	end

	local torso = character:FindFirstChild('UpperTorso')
		or character:FindFirstChild('Torso')

	if torso then
		return torso.CFrame * CFrame.new(0, -torso.Size.Y / 2, 0)
	end
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
	local ghostRoot = realRoot and GhostParts[realRoot]

	if not realRoot or not ghostRoot or not ghostRoot.Parent then
		return false
	end

	local targetRoot = CFrame.new(realRoot.Position)
		* CFrame.Angles(0, fakeYaw, 0)
	local yawOffset = targetRoot * realRoot.CFrame:Inverse()
	local realPivot = getPitchPivot(character)
	local pitchRotation

	if realPivot then
		local targetPivot = yawOffset * realPivot
		pitchRotation = targetPivot
			* CFrame.Angles(math.rad(pitch), 0, 0)
			* targetPivot:Inverse()
	end

	for realPart, ghostPart in GhostParts do
		if realPart.Parent and ghostPart.Parent then
			local targetCFrame = yawOffset * realPart.CFrame

			if pitchRotation and GhostPitchParts[realPart] then
				targetCFrame = pitchRotation * targetCFrame
			end

			ghostPart.CFrame = targetCFrame
			ghostPart.LocalTransparencyModifier = 0
		end
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
			ViewCharacter = nil
			ViewPitch = 0
			ViewYaw = 0
			ViewActive = false

			SpinBot:Clean(RunService.PreRender:Connect(function()
				if ViewActive and ViewCharacter and entitylib.isAlive then
					updateAntiAimView(ViewCharacter, ViewPitch, ViewYaw)
				else
					clearPlayerView()
				end
			end))

			SpinBot:Clean(RunService.PreSimulation:Connect(function(delta)
				if not entitylib.isAlive then
					ViewActive = false
					ViewCharacter = nil
					clearPlayerView()
					return
				end

				local character = entitylib.character.Character
				local root = entitylib.character.RootPart

				if not character or not root then
					ViewActive = false
					ViewCharacter = nil
					clearPlayerView()
					return
				end

				SpinAngle = (SpinAngle + math.rad(20 * Value.Value) * delta) % (math.pi * 2)

				local x, y, z = root.CFrame:ToOrientation()
				local fakeYaw = YToggle.Enabled and SpinAngle or y

				root.CFrame = CFrame.new(root.Position) * CFrame.Angles(XToggle.Enabled and SpinAngle or x, fakeYaw, ZToggle.Enabled and SpinAngle or z)

				if inSCPRP and AntiAim and AntiAim.Enabled then
					local pitch = getAntiAimPitch()
					ViewCharacter = character
					ViewPitch = pitch
					ViewYaw = fakeYaw
					ViewActive = AntiAimView and AntiAimView.Enabled or false

					if not ViewActive then
						clearPlayerView()
					end

					sendPitch(pitch)
				else
					ViewActive = false
					ViewCharacter = nil
					clearPlayerView()
				end
			end))
		else
			ViewActive = false
			ViewCharacter = nil
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