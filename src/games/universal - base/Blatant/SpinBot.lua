local SpinBot
local XToggle
local YToggle
local ZToggle
local Value
local DownAntiAim
local UpAntiAim
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
						if DownAntiAim.Enabled then
							UpdateReplication:FireServer((function(bytes)
								local b = buffer.create(#bytes)
								for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
								return b
							end)({ 2, 1, 176 }))
						elseif UpAntiAim.Enabled then
							UpdateReplication:FireServer((function(bytes)
								local b = buffer.create(#bytes)
								for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
								return b
							end)({ 2, 0, 80 }))
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
	DownAntiAim = SpinBot:CreateToggle({Name = 'Anti Aim (Down)'})
	UpAntiAim = SpinBot:CreateToggle({Name = 'Anti Aim (Up)'})
end
XToggle = SpinBot:CreateToggle({Name = 'Spin X'})
YToggle = SpinBot:CreateToggle({
	Name = 'Spin Y',
	Default = true
})
ZToggle = SpinBot:CreateToggle({Name = 'Spin Z'})