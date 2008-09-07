
--~ CanSendAuctionQuery("list")

local ids = LibStub("tekIDmemo")
local page, scanning, lastscanned, butt
local mins, maxes, counts, lastseen = {}, {}, {}, {}
local name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, _, isUsable, qualityIndex

tekauc.mins, tekauc.maxes, tekauc.counts = mins, maxes, counts


local function scanpage()
	for i=1,GetNumAuctionItems("list") do
		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list", i)
		local id = ids[GetAuctionItemLink("list", i)]
		buyoutPrice = buyoutPrice / count
		if buyoutPrice > 0 and (not tekauc.manualprices[id] or tekauc.manualprices[id] > (buyoutPrice/2.5)) then
			if (mins[id] or 9999999999) > buyoutPrice then mins[id] = buyoutPrice end
			if (maxes[id] or 0) < buyoutPrice then maxes[id] = buyoutPrice end
			counts[id] = (counts[id] or 0) + count
		end
	end
	return GetNumAuctionItems("list")
end


local allscanframe = CreateFrame("Frame", nil, AuctionFrame)
allscanframe:SetScript("OnShow", function(self)
	if not select(2, CanSendAuctionQuery("list")) then return end

	ChatFrame1:AddMessage("Sending all-scan query")
	mins, maxes, counts = {}, {}, {}
	tekauc.mins, tekauc.maxes, tekauc.counts = mins, maxes, counts
	QueryAuctionItems(nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
end)


allscanframe:SetScript("OnEvent", function(self)
	self:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	ChatFrame1:AddMessage("Time to scan")
	local count = scanpage()
	ChatFrame1:AddMessage("Done scanning "..count.. " items")
end)


local scanframe = CreateFrame("Frame")
scanframe:Hide()


function tekauc:Scan(...)
	name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, _, isUsable, qualityIndex = ...
	page, scanning = -1, GetTime()
	scanframe:Show()
	butt:Disable()
end


scanframe:SetScript("OnUpdate", function(self)
	if not CanSendAuctionQuery("list") then return end
	self:Hide()
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	page = page + 1
	QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
end)


scanframe:SetScript("OnEvent", function(self)
	if not scanning or page == lastscanned then return end

	scanpage()
	lastscanned = page
	local numbatch, numtotal = GetNumAuctionItems("list")

	if NUM_AUCTION_ITEMS_PER_PAGE * page + numbatch < numtotal then self:Show()
	else
		local time = GetTime() - scanning
		scanning = nil
		self:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		butt:Enable()
		tekauc:Print(time < 60 and string.format("Scan took %d seconds", time) or string.format("Scan took %.1f minutes", time/60))
	end
end)


BrowseSearchButton:SetPoint("LEFT", IsUsableCheckButton, "RIGHT", 10, -8)
butt = LibStub("tekKonfig-Button").new(BrowseSearchButton, "BOTTOM", BrowseSearchButton, "TOP")
butt:SetText("Scan")
butt:SetScript("OnClick", function()
	tekauc:Scan(BrowseName:GetText(), BrowseMinLevel:GetText(), BrowseMaxLevel:GetText(), AuctionFrameBrowse.selectedInvtypeIndex, AuctionFrameBrowse.selectedClassIndex,
		AuctionFrameBrowse.selectedSubclassIndex, AuctionFrameBrowse.page, IsUsableCheckButton:GetChecked(), UIDropDownMenu_GetSelectedValue(BrowseDropDown))
end)


-- Global API for any addon to query prices
local orig = GetAuctionBuyout
function GetAuctionBuyout(item)
	local id = ids[item]
	if id and mins[id] then return mins[id] end
	if id and tekauc.manualprices[id] then return tekauc.manualprices[id] end
	if orig then return orig(item) end
end
