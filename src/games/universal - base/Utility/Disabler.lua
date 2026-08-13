local Disabler
local characterAdded

local function disableConnections(signal)
	if not getconnections or not signal then return end
	for _, conn in getconnections(signal) do
		if conn.Function then
			hookfunction(conn.Function, function() end)
		else
			conn:Disable()
		end
	end
end

Disabler = vape.Categories.Utility:CreateModule({
	Name = 'Disabler',
	Function = function(callback)
		if callback then
			Disabler:Clean(entitylib.Events.LocalAdded:Connect(characterAdded))
			if entitylib.isAlive then
				characterAdded(entitylib.character)
			end
		end
	end,
	Tooltip = 'Disables client-side anticheat event listeners'
})

local GPCS = Disabler:CreateToggle({
	Name = 'GetPropertyChangedSignal',
	Default = true,
	Tooltip = 'Hooks CFrame, Position, and Velocity change signals'
})

local Assembly = Disabler:CreateToggle({
	Name = 'AssemblyVelocity',
	Tooltip = 'Hooks modern AssemblyLinearVelocity & AngularVelocity signals'
})

local ChangedSignal = Disabler:CreateToggle({
	Name = 'Changed Signal',
	Tooltip = 'Disables generic RootPart.Changed event connections'
})

local HumanoidState = Disabler:CreateToggle({
	Name = 'Humanoid State',
	Tooltip = 'Disables Humanoid StateChanged, FloorMaterial, and MoveDirection signals'
})

characterAdded = function(char)
	local realChar = typeof(char) == "Instance" and char or (type(char) == "table" and (char.Character or char.character or char.Model))
	if not realChar or typeof(realChar) ~= "Instance" then return end

	local root = realChar:WaitForChild('HumanoidRootPart', 5) or realChar.PrimaryPart
	local hum = realChar:WaitForChild('Humanoid', 5)

	if root then
		if GPCS.Enabled then
			disableConnections(root:GetPropertyChangedSignal('CFrame'))
			disableConnections(root:GetPropertyChangedSignal('Velocity'))
			disableConnections(root:GetPropertyChangedSignal('Position'))
		end
		if Assembly.Enabled then
			disableConnections(root:GetPropertyChangedSignal('AssemblyLinearVelocity'))
			disableConnections(root:GetPropertyChangedSignal('AssemblyAngularVelocity'))
		end
		if ChangedSignal.Enabled then
			disableConnections(root.Changed)
		end
	end

	if hum then
		if HumanoidState.Enabled then
			disableConnections(hum.StateChanged)
			disableConnections(hum:GetPropertyChangedSignal('FloorMaterial'))
			disableConnections(hum:GetPropertyChangedSignal('MoveDirection'))
			disableConnections(hum:GetPropertyChangedSignal('WalkSpeed'))
			disableConnections(hum:GetPropertyChangedSignal('JumpPower'))
		end
	end
end