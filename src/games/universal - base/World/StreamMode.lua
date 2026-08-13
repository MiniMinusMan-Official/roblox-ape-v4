local StreamerMode

StreamerMode = vape.Categories.World:CreateModule({
	Name = 'StreamerMode',
	Tooltip = 'Hides your username and (optionally) your avatar too\nby the way this is a 1-time use so you have to turn it off and rejoin to undo',
	Function = function(callback)
		if callback then
			plr = game:GetService("Players").LocalPlayer
			local name = plr.Name
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
			   plr.Name, plr.DisplayName = "robolx", "robolx"
				if n:IsA("TextLabel") or n:IsA("TextButton") or n:IsA("TextBox") then
					if n.Text:lower():find(display:lower()) and not n.Text:find("robolx") then
						n.Text = n.Text:lower():gsub(display:lower(), "robolx")
					end
					if n.Text:lower():find(name:lower()) and not n.Text:find("robolx") then
						n.Text = n.Text:gsub(name:lower(), "robolx")
					end
				end
			end
			task.spawn(function()
				plr.Name, plr.DisplayName = "robolx", "robolx"
				while task.wait(5) do
					for i, v in next, game:GetDescendants() do
						changeText(v)
					end
				end
			end)
			game.DescendantAdded:Connect(changeText)

			for _, part in next, cha:GetDescendants() do
				if part:IsA("Part") then
					part.Color = Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))
				end
			end 
		else end
	end
})