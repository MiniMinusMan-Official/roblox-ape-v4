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
local OldAutoRotate
local UpdateReplication
local createGhost
local startGhostSync
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local VisualGhost = nil

local inSCPRP = game.PlaceId == 5041144419 or game.PlaceId == 10953555034

if inSCPRP then
	UpdateReplication = game:GetService("ReplicatedStorage").Remotes.UpdateReplication
	createGhost = function(character)
		if VisualGhost then VisualGhost:Destroy() end

		character.Archivable = true
		VisualGhost = character:Clone()
		character.Archivable = false

		VisualGhost.Name = "aavisual"
		for _, child in ipairs(VisualGhost:GetDescendants()) do
			if child:IsA("BasePart") then
				child.CanCollide = false
				child.Anchored = true
				child.Transparency = 0.75
			elseif child:IsA("Script") or child:IsA("LocalScript") or child:IsA("BillboardGui") then
				child:Destroy()
			end
		end
		local highlight = Instance.new("Highlight")
		highlight.Name = "GhostHighlight"
		highlight.Adornee = VisualGhost
		highlight.FillColor = Color3.fromRGB(0, 180, 0)
		highlight.FillTransparency = 0.8
		highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
		highlight.OutlineTransparency = 0
		highlight.Parent = VisualGhost

		VisualGhost.Parent = workspace
		return VisualGhost
	end

	startGhostSync = function(entitylib, getFakePitch, getFakeYaw)
		RunService:BindToRenderStep("UpdateAntiAimGhost", Enum.RenderPriority.Camera.Value + 1, function()
			if not entitylib.isAlive or not VisualGhost then return end

			local realRoot = entitylib.character.RootPart
			local ghostRoot = VisualGhost:FindFirstChild("HumanoidRootPart")

			if realRoot and ghostRoot then
				local pitch = math.rad(getFakePitch())
				local yaw = getFakeYaw()
				local ghostCFrame = CFrame.new(realRoot.Position) * CFrame.Angles(0, yaw, 0)
				VisualGhost:SetPrimaryPartCFrame(ghostCFrame)
				local lowerTorso = VisualGhost:FindFirstChild("LowerTorso")
				if lowerTorso then
					local rootJoint = lowerTorso:FindFirstChild("Root")
					if rootJoint then
						rootJoint.C0 = CFrame.new(rootJoint.C0.Position) * CFrame.Angles(pitch, 0, 0)
					end
				end
			end
		end)
	end
end

SpinBot = vape.Categories.Blatant:CreateModule({
	Name = 'SpinBot',
	Function = function(callback)
		if callback then
			SpinAngle = 0

			if entitylib.isAlive then
				OldAutoRotate = entitylib.character.Humanoid.AutoRotate
				entitylib.character.Humanoid.AutoRotate = false
			end

			SpinBot:Clean(runService.PreSimulation:Connect(function(delta)
				if entitylib.isAlive then
					local humanoid = entitylib.character.Humanoid
					local root = entitylib.character.RootPart

					humanoid.AutoRotate = false

					SpinAngle = (SpinAngle + math.rad(20 * Value.Value) * delta) % (math.pi * 2)

					local x, y, z = root.CFrame:ToOrientation()

					root.CFrame = CFrame.new(root.Position) * CFrame.Angles(XToggle.Enabled and SpinAngle or x, YToggle.Enabled and SpinAngle or y, ZToggle.Enabled and SpinAngle or z)
					
					if inSCPRP then
						if AntiAim.Enabled then
							createGhost(entitylib.character)
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
				end
			end))
		else
			if entitylib.isAlive then
				entitylib.character.Humanoid.AutoRotate = OldAutoRotate == nil and true or OldAutoRotate
				RunService:UnbindFromRenderStep("UpdateAntiAimGhost")
				VisualGhost:Destroy()
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