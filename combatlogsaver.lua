local report = true -- 'false' for quiet mode

-- do not edit below this point
local db
local _G = getfenv(0)
local event = CreateFrame("Frame")
event:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
event:RegisterEvent"ADDON_LOADED"
event:RegisterEvent"ZONE_CHANGED_NEW_AREA"

event.ADDON_LOADED = function(self, event, ...)
	db = _G.clsaverDB
	if(not db) then
		db = {}
		_G.clsaverDB = db
	end
end

event.ZONE_CHANGED_NEW_AREA = function(self, event, ...) self.onZoning() end

local function isZoneTracked(zone)
	return db[zone] and true or false
end

local function pr(what)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cffabd473cl|rsaver|cff666666:|r "..what)
	end
end

event.onZoning = function()
	local zone = GetRealZoneText()
	if report then
		local status = "OFF"
		if isZoneTracked(zone) then status = "ON" end
		pr("CombatLog " ..status.." for "..zone)
	end
	if isZoneTracked(zone) and not LoggingCombat() then
		if report then UIErrorsFrame:AddMessage("CombatLog ON", 0.2, 1.0, 0.2, 1.0, UIERRORS_HOLD_TIME) end
		LoggingCombat(true)
	end
	if not isZoneTracked(zone) and LoggingCombat() then
		if report then UIErrorsFrame:AddMessage("CombatLog OFF", 1.0, 0.0, 0.0, 1.0, UIERRORS_HOLD_TIME) end
		LoggingCombat(false)
	end
end

SLASH_CLSAVER1 = "/clsaver"
SLASH_CLSAVER2 = "/combatlogsaver"
SlashCmdList["CLSAVER"] = function(m)
	if m == "toggle" then
		local zone = GetRealZoneText()
		if db[zone] then
			db[zone] = nil
			pr(zone.." removed form list")
		else	
			db[zone] = true
			pr(zone.." added to the list")
		end
		event:onZoning()
	elseif m == "list" then
		if next(db) then
			pr("CombatLog on in zones:")
			for z,s in pairs(db) do
				pr("* " .. z)
			end
		else
			pr("CombatLog off for all zones")
		end
	else
		pr("CombatLog - Smart CombatLog saver, available commands:")
		pr("/clsaver toggle - Toggle CombatLog save on/off for current zone.")
		pr("/clsaver list - Lists zones for which CombatLog is turned on.")
	end
end