local plr = game:GetService("Players").LocalPlayer
local realName = plr.Name
local realDisplay = plr.DisplayName
local name = "robolx"

local StreamerMode
local fakename
local hideavatar

local descendantConnection
local loopThread
local removedItems = {}

StreamerMode = vape.Categories.Blatant:CreateModule({
	Name = 'StreamerMode',
	Function = function(callback)
		if callback then
			plr.Name = name
			plr.DisplayName = name

			local function changeText(n)
				if n:IsA("TextLabel") or n:IsA("TextButton") or n:IsA("TextBox") then
					if n.Text:lower():find(realDisplay:lower(), 1, true) and not n.Text:find(name) then
						n.Text = n.Text:gsub("(?i)" .. realDisplay, name)
					end
					if n.Text:lower():find(realName:lower(), 1, true) and not n.Text:find(name) then
						n.Text = n.Text:gsub("(?i)" .. realName, name)
					end
				end
			end

			for _, v in next, game:GetDescendants() do
				changeText(v)
			end

			descendantConnection = game.DescendantAdded:Connect(changeText)

			loopThread = task.spawn(function()
				while task.wait(3) do
					plr.Name = name
					plr.DisplayName = name
					for _, v in next, game:GetDescendants() do
						changeText(v)
					end
				end
			end)

			if hideavatar and hideavatar.Enabled then
				local cha = plr.Character
				if cha then
					removedItems = {}
					for _, part in next, cha:GetDescendants() do
						if part:IsA("BasePart") then
							part:SetAttribute("OrigColor", part.Color)
							part.Color = Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))
						elseif part:IsA("Shirt") or part:IsA("Pants") or part:IsA("ShirtGraphic") or part:IsA("Accessory") then
							part.Parent = nil
							table.insert(removedItems, part)
						end
					end
				end
			end
		else
			if descendantConnection then
				descendantConnection:Disconnect()
				descendantConnection = nil
			end
			if loopThread then
				task.cancel(loopThread)
				loopThread = nil
			end

			plr.Name = realName
			plr.DisplayName = realDisplay

			local cha = plr.Character
			if cha then
				for _, item in next, removedItems do
					if item then item.Parent = cha end
				end
				removedItems = {}
				for _, part in next, cha:GetDescendants() do
					if part:IsA("BasePart") and part:GetAttribute("OrigColor") then
						part.Color = part:GetAttribute("OrigColor")
					end
				end
			end
		end
	end,
	Tooltip = 'Hides your username and (optionally) your avatar too'
})

fakename = PlayerModel:CreateTextBox({
	Name = 'Fake name',
	Placeholder = 'text here',
	Function = function(val)
		name = (val ~= "" and val) or "robolx"
		if StreamerMode.Enabled then
			plr.Name = name
			plr.DisplayName = name
		end
	end
})

hideavatar = StreamerMode:CreateToggle({
	Name = 'Also hide avatar'
})