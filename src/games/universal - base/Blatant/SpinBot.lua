local SpinBot
local XToggle
local YToggle
local ZToggle
local Value
local AntiAim
local AntiAimPitch
local AntiAimPitchRandom
local AntiAimMode
local lastupd = 0
local jit_tog = false
local SpinAngle = 0
local UpdateReplication
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local GhostParts = {}
local VisualGhost = nil

local inSCPRP = game.PlaceId == 5041144419 or game.PlaceId == 10953555034

if inSCPRP then
	UpdateReplication = game:GetService("ReplicatedStorage").Remotes.UpdateReplication
end

local function destroyGhost()
	if VisualGhost then
		VisualGhost:Destroy()
		VisualGhost = nil
	end

	table.clear(GhostParts)
end

local function createGhost(charModel)
	destroyGhost()
	if not charModel then return end

	charModel.Archivable = true
	VisualGhost = charModel:Clone()
	charModel.Archivable = false

	VisualGhost.Name = 'AntiAimVisualGhost'

	local ghostHumanoid = VisualGhost:FindFirstChildOfClass('Humanoid')
	if ghostHumanoid then
		ghostHumanoid:Destroy()
	end

	local GHOST_COLOR = Color3.fromRGB(5, 133, 104)

	for _, child in VisualGhost:GetChildren() do
		if child:IsA('Accessory') or child:IsA('Accoutrement') then
			child:Destroy()
		end
	end

	for _, child in VisualGhost:GetDescendants() do
		if child:IsA('BasePart') then
			child.Anchored = true
			child.CanCollide = false
			child.CanTouch = false
			child.CanQuery = false
			child.LocalTransparencyModifier = 0
			child.Transparency = 0.35
			child.Color = GHOST_COLOR
			child.Material = Enum.Material.SmoothPlastic
		elseif child:IsA('Motor6D')
			or child:IsA('Weld')
			or child:IsA('WeldConstraint')
			or child:IsA('Constraint') then
			child:Destroy()
		elseif child:IsA('Decal')
			or child:IsA('Clothing')
			or child:IsA('ShirtGraphic') then
			child:Destroy()
		elseif child:IsA('Script')
			or child:IsA('LocalScript')
			or child:IsA('BillboardGui')
			or child:IsA('Animator') then
			child:Destroy()
		end
	end

	local highlight = Instance.new('Highlight')
	highlight.Name = 'GhostHighlight'
	highlight.Adornee = VisualGhost
	highlight.FillColor = GHOST_COLOR
	highlight.FillTransparency = 0.75
	highlight.OutlineColor = Color3.fromRGB(0, 255, 128)
	highlight.OutlineTransparency = 0
	highlight.Parent = VisualGhost

	VisualGhost.Parent = workspace
end

local function findGhostPart(realPart, realChar)
	if GhostParts[realPart] and GhostParts[realPart].Parent then
		return GhostParts[realPart]
	end

	local path = {}
	local current = realPart

	while current and current ~= realChar do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end

	current = VisualGhost

	for _, name in path do
		current = current and current:FindFirstChild(name)
	end

	if current and current:IsA('BasePart') then
		GhostParts[realPart] = current
		return current
	end
end

SpinBot = vape.Categories.Blatant:CreateModule({
	Name = 'SpinBot',
	Function = function(callback)
		if callback then
			SpinAngle = 0

			if entitylib.isAlive then
				if AntiAim.Enabled then
					local charModel = entitylib.character.Character or game:GetService("Players").LocalPlayer.Character
					createGhost(charModel)
				end
			end
			SpinBot:Clean(runService.PreSimulation:Connect(function(delta)
				if entitylib.isAlive then
					local root = entitylib.character.RootPart
					SpinAngle = (SpinAngle + math.rad(20 * Value.Value) * delta) % (math.pi * 2)
					local x, y, z = root.CFrame:ToOrientation()
					local fakeYaw = YToggle.Enabled and SpinAngle or y
					root.CFrame = CFrame.new(root.Position) * CFrame.Angles(XToggle.Enabled and SpinAngle or x, fakeYaw, ZToggle.Enabled and SpinAngle or z)
					if inSCPRP and AntiAim.Enabled then
						local pitch = 0
						local currentTime = tick()
						if AntiAimMode.Value == 'Static' then
							pitch = AntiAimPitch.Value
						elseif AntiAimMode.Value == 'Random' then
							if currentTime - lastupd >= 1 then
								pitch = AntiAimPitchRandom:GetRandomValue()
								lastupd = currentTime
							else
								pitch = lastPitchUpdate_Value 
							end
						elseif AntiAimMode.Value == 'Jitter' then
							if currentTime - lastupd >= 1 then
								jit_tog = not jit_tog
								pitch = jit_tog and AntiAimPitchRandom.ValueMin or AntiAimPitchRandom.ValueMax
								lastupd = currentTime
							else
								pitch = jit_tog and AntiAimPitchRandom.ValueMin or AntiAimPitchRandom.ValueMax
							end
						end
						lastPitchUpdate_Value = pitch
						if VisualGhost and entitylib.character.Character then
							local realChar = entitylib.character.Character
							local realRoot = realChar:FindFirstChild('HumanoidRootPart')
							local realTorso = realChar:FindFirstChild('UpperTorso')
								or realChar:FindFirstChild('Torso')

							if realRoot and realTorso then
								local desiredRoot = CFrame.new(realRoot.Position)
									* CFrame.Angles(0, fakeYaw, 0)

								local yawOffset = desiredRoot * realRoot.CFrame:Inverse()
								local realPivot = realTorso.CFrame
									* CFrame.new(0, -realTorso.Size.Y / 2, 0)

								local ghostPivot = yawOffset * realPivot

								local pitchOffset = ghostPivot
									* CFrame.Angles(math.rad(pitch), 0, 0)
									* ghostPivot:Inverse()

								local lowerBody = {
									HumanoidRootPart = true,
									LowerTorso = true,

									LeftUpperLeg = true,
									LeftLowerLeg = true,
									LeftFoot = true,

									RightUpperLeg = true,
									RightLowerLeg = true,
									RightFoot = true,

									['Left Leg'] = true,
									['Right Leg'] = true
								}

								for _, realPart in realChar:GetDescendants() do
									if realPart:IsA('BasePart') then
										local ghostPart = findGhostPart(realPart, realChar)

										if ghostPart then
											local targetCFrame = yawOffset * realPart.CFrame

											if not lowerBody[realPart.Name] then
												targetCFrame = pitchOffset * targetCFrame
											end

											ghostPart.CFrame = targetCFrame
										end
									end
								end
							end
						end
						local bytes = { 2, 0, 0 }
						if pitch < 0 then
							bytes[1], bytes[2], bytes[3] = 2, 1, 255 + pitch
						else
							bytes[1], bytes[2], bytes[3] = 2, 0, pitch
						end
						UpdateReplication:FireServer((function(b_vals)
							local b = buffer.create(#b_vals)
							for i = 1, #b_vals do buffer.writeu8(b, i - 1, b_vals[i]) end
							return b
						end)(bytes))
					end
				end
			end))
		else
			destroyGhost()
			UpdateReplication:FireServer((function(b_vals)
				local b = buffer.create(#b_vals)
				for i = 1, #b_vals do buffer.writeu8(b, i - 1, b_vals[i]) end
				return b
			end)({ 2, 0, 0 }))
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
		Function = function(val)
			AntiAimPitch.Object.Visible = (AntiAimMode.Value == 'Static' and val and true) or false
			AntiAimPitchRandom.Object.Visible = ((AntiAimMode.Value == 'Random' and true) or (AntiAimMode.Value == 'Jitter' and true) and val) or false
			AntiAimMode.Object.Visible = val
			if SpinBot.Enabled then
				SpinBot:Toggle()
				SpinBot:Toggle()
			end
		end,
		Tooltip = methodTooltip
	})
	AntiAimMode = SpinBot:CreateDropdown({
		Name = 'AimType',
		List = {'Static', 'Random', 'Jitter'},
		Function = function(val)
			AntiAimPitch.Object.Visible = AntiAimMode.Value == 'Static' and true or false
			AntiAimPitchRandom.Object.Visible = (AntiAimMode.Value == 'Random' and true) or (AntiAimMode.Value == 'Jitter' and true) or false
			if SpinBot.Enabled then
				SpinBot:Toggle()
				SpinBot:Toggle()
			end
		end,
		Tooltip = methodTooltip
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
end
XToggle = SpinBot:CreateToggle({Name = 'Spin X'})
YToggle = SpinBot:CreateToggle({
	Name = 'Spin Y',
	Default = true
})
ZToggle = SpinBot:CreateToggle({Name = 'Spin Z'})