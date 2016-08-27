local addon, ns = ...
local E, M = unpack(yaCore)
local cfg = CreateFrame("Frame")
--------------

-- Messages when repairing
cfg.repairNoMoney = "You don't have enough money for repair!"
cfg.repairCost = "Your items have been repaired for"
cfg.repairGuildCost = "Your items have been repaired with guild funds for"
cfg.trashSell = "Your vendor trash has been sold and you earned"

cfg.goldAbbrev = "|cffffd700g|r"
cfg.silverAbbrev = "|cffc7c7cfs|r"
cfg.copperAbbrev = "|cffeda55fc|r"

-- Settings
cfg.autoGreed = true	-- Choose Greed/DE
cfg.autoRepair = true	-- Repair with own money --// Hold Shift if you dont want to repair
cfg.autoSellGray = true -- Sell all gray-quality items
cfg.autoRelease = true -- Release Spirit in BGs
cfg.autoEnchant = true	--Accepts the "Are you sure to replace this enchant?" Handy for leveling enchanting
cfg.autoConfirm = true -- Accepts the "bind on pickup"

cfg.hideError = false -- Show "Can't use that here" etc.

cfg.barTexture = M:Fetch("yaui", "statusbar")
cfg.dropTexture = M:Fetch("yaui", "backdrop")
cfg.dropEdgeTexture = M:Fetch("yaui", "backdropEdge")

cfg.font = M:Fetch("font", "Roboto")
cfg.fontSize = M:Fetch("font", "size")
cfg.fontFlag = M:Fetch("font", "outline")

--------------
ns.cfg = cfg