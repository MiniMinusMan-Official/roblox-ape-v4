local FOV
local Value
local oldfov
local fovconnection

FOV = vape.Legit:CreateModule({
	Name = 'FOV',
	Function = function(callback)
		if callback then
			oldfov = gameCamera.FieldOfView

			fovconnection = gameCamera:GetPropertyChangedSignal('FieldOfView'):Connect(function()
				if FOV.Enabled and gameCamera.FieldOfView ~= Value.Value then
					gameCamera.FieldOfView = Value.Value
				end
			end)

			repeat
				gameCamera.FieldOfView = Value.Value
				game:GetService('RunService').RenderStepped:Wait()
			until not FOV.Enabled
		else
			if fovconnection then
				fovconnection:Disconnect()
				fovconnection = nil
			end

			gameCamera.FieldOfView = oldfov
		end
	end,
	Tooltip = 'Adjusts camera vision'
})
Value = FOV:CreateSlider({
	Name = 'FOV',
	Min = 30,
	Max = 120
})