local addon, ns = ...
local E, M = unpack(yaCore)
local cfg = ns.cfg

local SetCVar = SetCVar
local GetMouseFocus = GetMouseFocus
local FrameStackTooltip_Toggle = FrameStackTooltip_Toggle

--	Frame which catches Events as they fire
local eventCatcher = CreateFrame("Frame")
eventCatcher:RegisterEvent("ADDON_LOADED")
eventCatcher:SetScript("OnEvent", function(self)
	SetCVar('UberTooltips', 1) -- Über Tooltips! Wunderbar!
	SetCVar('showTutorials', 0) -- Not a n00b. Don't show tutorials
	SetCVar('autoLootDefault', 1) -- Enable auto loot by default
	SetCVar('hideAdventureJournalAlerts', 0)
	SetCVar('lockActionBars', 0)
	SetCVar('screenshotFormat', 'png')
	SetCVar('screenshotQuality', 10)
	SetCVar('scriptErrors', 1)
	SetCVar('taintLog', 1)
	SetCVar('trackQuestSorting', 'proximity')
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)
end)

-- Write DELETE in the Confirmation popup when deleting an item
hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(s) s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING) end)

-- Hide the vehicle seat indicator
VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator:Hide()

SlashCmdList['RELOAD'] = ReloadUI
SLASH_RELOAD1 = '/rl'

-- Frame assist
SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil then FRAME = arg end --Set the global variable FRAME to = whatever we are mousing over to simplify messing with frames that have no name.
	if arg ~= nil and arg:GetName() ~= nil then
		local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		E:Print("|cffCC0000----------------------------")
		E:Print("Name: |cffFFD100"..arg:GetName())
		if arg:GetParent() and arg:GetParent():GetName() then
			E:Print("Parent: |cffFFD100"..arg:GetParent():GetName())
		end
 
		E:Print("Width: |cffFFD100"..format("%.2f",arg:GetWidth()))
		E:Print("Height: |cffFFD100"..format("%.2f",arg:GetHeight()))
 
		if xOfs then
			E:Print("X: |cffFFD100"..format("%.2f",xOfs))
		end
		if yOfs then
			E:Print("Y: |cffFFD100"..format("%.2f",yOfs))
		end
		if relativeTo and relativeTo:GetName() then
			E:Print("Point: |cffFFD100"..point.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint)
		end
		E:Print("Strata: |cffFFD100"..arg:GetFrameStrata())
		E:Print("Level: |cffFFD100"..arg:GetFrameLevel())
		E:Print("|cffCC0000----------------------------")
	elseif arg == nil then
		E:Print("Invalid frame name")
	else
		E:Print("Could not find frame info")
	end
end

SLASH_FRAMELIST1 = "/framelist"
SlashCmdList["FRAMELIST"] = function(msg)
	if(not FrameStackTooltip) then
		UIParentLoadAddOn("Blizzard_DebugTools")
	end

	local isPreviouslyShown = FrameStackTooltip:IsShown()
	if(not isPreviouslyShown) then
		if(msg == tostring(true)) then
			FrameStackTooltip_Toggle(true)
		else
			FrameStackTooltip_Toggle()
		end
	end

	E:Print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	for i = 2, FrameStackTooltip:NumLines() do
		local text = _G["FrameStackTooltipTextLeft"..i]:GetText()
		if(text and text ~= "") then
			E:Print(text)
		end
	end
	E:Print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if(not isPreviouslyShown) then
		FrameStackTooltip_Toggle()
	end
end

if cfg.autoConfirm then
	local autoConfirm = CreateFrame("frame")
	autoConfirm:RegisterEvent("CONFIRM_LOOT_ROLL");
	autoConfirm:RegisterEvent("CONFIRM_DISENCHANT_ROLL");
	autoConfirm:RegisterEvent("LOOT_BIND_CONFIRM")
	autoConfirm:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
		
		if event == "CONFIRM_LOOT_ROLL" or event == "CONFIRM_DISENCHANT_ROLL" then
			ConfirmLootRoll(arg1, arg2)
			StaticPopup_Hide("CONFIRM_LOOT_ROLL")
			return
		end

		if event == "LOOT_BIND_CONFIRM" then
			ConfirmLootSlot(arg1, arg2)
			StaticPopup_Hide("LOOT_BIND",...)
			return
		end
	end)

end

if cfg.autoGreed then
	local autogreed = CreateFrame("frame")
	autogreed:RegisterEvent("START_LOOT_ROLL")
	autogreed:RegisterEvent("CONFIRM_LOOT_ROLL", "CONFIRM_ROLL")
	autogreed:RegisterEvent("CONFIRM_DISENCHANT_ROLL", "CONFIRM_ROLL")
	autogreed:SetScript("OnEvent", function(self, event, id)
		local name = select(2, GetLootRollItemInfo(id))
		
		--Auto Need Chaos Orb
		if (name == select(1, GetItemInfo(52078))) then
			RollOnLoot(id, 1)
		end
		
		if(id and select(4, GetLootRollItemInfo(id))==2 and not (select(5, GetLootRollItemInfo(id)))) then
			if RollOnLoot(id, 3) then
				RollOnLoot(id, 3)
			else
				RollOnLoot(id, 2)
			end
		end
	end)
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	if cfg.autoSellGray then
		local c = 0
		for b=0,4 do
			for s=1,GetContainerNumSlots(b) do
				local l = GetContainerItemLink(b, s)
				if l then
					local containerItemInfo = select(2, GetContainerItemInfo(b, s)) --get stackcount
					local itemInfo = select(11, GetItemInfo(l)) --get vendorvalue
					if itemInfo then --some items have no vendorvalue so we need to check for it
						local p = itemInfo*containerItemInfo
						if select(3, GetItemInfo(l))==0 and p>0 then
							UseContainerItem(b, s)
							PickupMerchantItem()
							c = c+p
						end
					end
				end
			end
		end
		if c>0 then
			local g, s, c = math.floor(c/10000) or 0, math.floor((c%10000)/100) or 0, c%100
			E:Print(cfg.trashSell.." |cffffffff"..g..cfg.goldAbbrev.." |cffffffff"..s..cfg.silverAbbrev.." |cffffffff"..c..cfg.copperAbbrev..".")
		end
	end
	hooksecurefunc("MerchantItemButton_OnModifiedClick", function(self, button)
		if (button=="RightButton") and IsShiftKeyDown() then
			OpenStackSplitFrame(100000, self, "BOTTOMLEFT", "TOPLEFT")
		end
	end)
	if not IsShiftKeyDown() then
		if CanMerchantRepair() and cfg.autoRepair then
			local cost, possible = GetRepairAllCost()
			local useGuild = false
			
			--Check if possible to use guild bank
			if (IsInGuild() and CanGuildBankRepair()) then
				local limit = GetGuildBankWithdrawMoney()
				local bank = GetGuildBankMoney()
				
				--If you can withdraw enough (or if you can withdraw infinite)
				-- ... and if the guild bank can afford it
				-- Specifically use "greater than" here to avoid potential issues
				if(((limit == -1) or (limit > cost)) and (bank > cost)) then
					useGuild = true
				end
			end
		
			if cost>0 then
				if possible then
					local c = cost%100
					local s = math.floor((cost%10000)/100)
					local g = math.floor(cost/10000)
					if(useGuild == true) then
						RepairAllItems(true)
						E:Print(cfg.repairGuildCost.." |cffffffff"..g..cfg.goldAbbrev.." |cffffffff"..s..cfg.silverAbbrev.." |cffffffff"..c..cfg.copperAbbrev..".")
					else
						RepairAllItems(false)
						E:Print(cfg.repairCost.." |cffffffff"..g..cfg.goldAbbrev.." |cffffffff"..s..cfg.silverAbbrev.." |cffffffff"..c..cfg.copperAbbrev..".")
					end
				else
					E:Print(cfg.repairNoMoney)
				end
			end
		end
	end
end)
f:RegisterEvent("MERCHANT_SHOW")

-- buy max number value with alt
local savedMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
function MerchantItemButton_OnModifiedClick(self, ...)
	if ( IsAltKeyDown() ) then
		local itemLink = GetMerchantItemLink(self:GetID())
		if not itemLink then return end
		local maxStack = select(8, GetItemInfo(itemLink))
		if ( maxStack and maxStack > 1 ) then
			BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
		end
	end
	savedMerchantItemButton_OnModifiedClick(self, ...)
end

if cfg.hideError then
	local event = CreateFrame"Frame"
	local dummy = function() end


	UIErrorsFrame:UnregisterEvent"UI_ERROR_MESSAGE"
	event.UI_ERROR_MESSAGE = function(self, event, error)
		if(not stuff[error]) then
			UIErrorsFrame:AddMessage(error, 1, .1, .1)
		end
	end
		
	event:RegisterEvent"UI_ERROR_MESSAGE"
end

if cfg.autoEnchant then
	local AutoAcceptEnchantReplace = {}

	function AutoAcceptEnchantReplace:OnEvent(event, old_enchant, new_enchant, ...)
		
		if (event == "REPLACE_ENCHANT") then
			-- Because ReplaceEnchant() is a protected funtion we have to make sure that we are allowed to use it.
			-- The restriction is all based on if we are applying an 'Imbue' Enchant or not.
			-- http://forums.wowace.com/showthread.php?t=16545
			-- http://www.wowwiki.com/Imbue Imbue refers to a temporary enchant that can be added to equipment.
			-- So to keep things simple we will make sure that the player has their Enchant profession window open,
			-- this will not assure us that we are dealing with a real enchant but it is a nice easy way to get
			-- around the issue for now.
			if ("Enchant" == GetTradeSkillInfo(1)) then
				if (old_enchant == new_enchant) then
					--AutoAcceptEnchantReplace:Log(string.format("Auto Accepted replacing %s with %s", old_enchant, new_enchant))
					ReplaceEnchant();
				else
					return;
				end
			end
		end
	end

	AutoAcceptEnchantReplace.frame = CreateFrame("Frame");
	AutoAcceptEnchantReplace.frame:SetScript("OnEvent", AutoAcceptEnchantReplace.OnEvent);
	AutoAcceptEnchantReplace.frame:RegisterEvent("REPLACE_ENCHANT");
end