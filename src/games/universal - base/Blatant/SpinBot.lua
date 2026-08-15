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

local inSCPRP = game.PlaceId == 5041144419 or game.PlaceId == 10953555034

if inSCPRP then
	UpdateReplication = game:GetService("ReplicatedStorage").Remotes.UpdateReplication
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
							local pitch = 0
							local currentTime = tick()

							if AntiAimMode.Value == 'Static' then
								pitch = AntiAimPitch.Value
							elseif AntiAimMode.Value == 'Random' then
								if currentTime - lastupd >= 0.25 then
									pitch = AntiAimPitchRandom:GetRandomValue()
									lastupd = currentTime
								else
									pitch = lastPitchUpdate_Value 
								end
							elseif AntiAimMode.Value == 'Jitter' then
								if currentTime - lastupd >= 0.25 then
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
		Name = 'Pitch',
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