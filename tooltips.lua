

local ids = LibStub("tekIDmemo")


local origs = {}
local OnTooltipSetItem = function(frame, ...)
	assert(frame, "arg 1 is nil, someone isn't hooking correctly")

	local _, link = frame:GetItem()
	if link then
		local id = ids[link]
		local min, max, count = tekauc.mins[id], tekauc.maxes[id], tekauc.counts[id]
		local _, _, _, _, _, _, _, maxStack = GetItemInfo(id)
		if min then frame:AddDoubleLine("AH buyout:", max and max ~= min and (tekauc:GS(min).." - "..tekauc:GS(max)) or tekauc:GS(min)) end
		if min and (maxStack or 0) > 1 then frame:AddDoubleLine("AH stack buyout:", max and max ~= min and (tekauc:GS(min*maxStack).." - "..tekauc:GS(max*maxStack)) or tekauc:GS(min*maxStack)) end
		if count then frame:AddDoubleLine("Number on AH:", count) end

--~ 		if val and (maxStack or 0) > 1 then
--~ 			frame:AddDoubleLine("Lowest AH buyout:", tekauc:GS(val).." ("..tekauc:GS(val*maxStack)..")")
--~ 			frame:AddDoubleLine("Highest AH buyout:", tekauc:GS(tekauc.maxes[id]).." ("..tekauc:GS(tekauc.maxes[id]*maxStack)..")")

--~ 		elseif val then
--~ 			frame:AddDoubleLine("Lowest AH buyout:", tekauc:GS(val))
--~ 			frame:AddDoubleLine("Highest AH buyout:", tekauc:GS(tekauc.maxes[id]))
--~ 			frame:AddDoubleLine("Number on AH:", tekauc.counts[id])
--~ 		end
	end
	if origs[frame] then return origs[frame](frame, ...) end
end

for i,frame in pairs{GameTooltip, ItemRefTooltip} do
	origs[frame] = frame:GetScript("OnTooltipSetItem")
	frame:SetScript("OnTooltipSetItem", OnTooltipSetItem)
end


