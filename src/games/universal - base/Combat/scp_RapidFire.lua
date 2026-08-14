local RapidFire
local FRate
local OriginalValues = {}
local inSCPRP = game.PlaceId == 5041144419 or game.PlaceId == 10953555034

local function modifyTBS(value, isReverting)
    for _, module in pairs(getloadedmodules()) do
        local success, result = pcall(require, module)
        if success and type(result) == "table" then
            pcall(function()
                if rawget(result, "Pistol") ~= true then
                    if rawget(result, "TBS") ~= nil then
                        if isReverting then
                            result.TBS = OriginalValues[module] or 0.2
                        else
                            if not OriginalValues[module] then
                                OriginalValues[module] = result.TBS
                            end
                            result.TBS = value
                        end
                    end
                end
            end)
        end
    end
end

if inSCPRP then
	RapidFire = vape.Categories.Combat:CreateModule({
		Name = 'Rapid Fire',
		Function = function(callback)
			if callback then
				task.spawn(function()
					while RapidFire.Enabled do
						modifyTBS(FRate.Value, false)
						task.wait(1)
					end
				end)
			else
				modifyTBS(nil, true)
				OriginalValues = {}
			end
		end,
		Tooltip = 'changes the fire rate of weapons'
	})

	FRate = RapidFire:CreateSlider({
		Name = 'Fire rate',
		Min = 0.05,
		Max = 0.2,
		Decimal = 100
	})
end