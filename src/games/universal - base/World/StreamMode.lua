local StreamerMode
local fakename
local hideavatar

local name = "robolx"
local loopThread
local con

StreamerMode = vape.Categories.World:CreateModule({
	Name = 'StreamerMode',
	Tooltip = 'Hides your username and (optionally) your avatar too',
	Function = function(callback)
		if callback then
			local plr = game:GetService("Players").LocalPlayer
			local realName = plr.Name
			local display = plr.DisplayName

			function IsA(...)
				local Args = {...}
				if table.find(Args, Args[1].ClassName) then
					return true
				end
			end

			function e()
				for i, v in next, workspace:GetDescendants() do
					if v:IsA("Model") and game:GetService("Players"):GetPlayerFromCharacter(v) == plr then
						return v
					end
				end
			end

			local cha = e()

			function changeText(n)
				plr.Name, plr.DisplayName = name, name
				if n:IsA("TextLabel") or n:IsA("TextButton") or n:IsA("TextBox") then
					if n.Text:lower():find(display:lower()) and not n.Text:find(name) then
						n.Text = n.Text:lower():gsub(display:lower(), name)
					end
					if n.Text:lower():find(realName:lower()) and not n.Text:find(name) then
						n.Text = n.Text:gsub(realName:lower(), name)
					end
				end
			end

			loopThread = task.spawn(function()
				plr.Name, plr.DisplayName = name, name
				while task.wait(5) do
					for i, v in next, game:GetDescendants() do
						changeText(v)
					end
				end
			end)

			con = game.DescendantAdded:Connect(changeText)

			if hideavatar and hideavatar.Enabled and cha then
				for _, part in next, cha:GetDescendants() do
					if part:IsA("Part") then
						part.Color = Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))
					end
					if IsA(part, "Shirt", "Pants", "ShirtGraphic", "Accessory") then
						part:Destroy()
					end
				end
			end
		else
			if loopThread then
				task.cancel(loopThread)
				loopThread = nil
			end
			if con then
				con:Disconnect()
				con = nil
			end
		end
	end
})

fakename = StreamerMode:CreateTextBox({
	Name = 'Fake name',
	Placeholder = 'text here',
	Function = function(val)
		name = (val ~= "" and val) or "robolx"
	end
})

hideavatar = StreamerMode:CreateToggle({
	Name = 'Also hide avatar'
})