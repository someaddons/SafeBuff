-- Stores the looked up textures from spellbook, so they dont need to be searched again
local SpellTextureID = {}

-- Store which classes to buff
local BuffClasses = {WARRIOR=true, PALADIN=true, HUNTER=true, ROGUE=true, PRIEST=true, SHAMAN=true, MAGE=true, WARLOCK=true, DRUID=true}
local ClassName = {"WARRIOR","PALADIN","HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID"}

-- Store often used function locally for performance
local UnitBuff = UnitBuff



-- Returns Texture and Spellbook ID for a given spellname, stores in SpellTextureID for faster lookup	
function GetSpellTextureAndID(spell)
	if not SpellTextureID then SpellTextureID = {} end
	
	-- Already a texture
	if string.find(spell,"%\\") ~= nil then return nil,spell end
	
	-- Removes the rank from the spell
	spell = string.gsub(spell,"%(.*","")
	-- Find texture
	if not SpellTextureID[spell] or not SpellTextureID[spell]["texture"] then
		SpellTextureID[spell] = {}
	
		for i = 1,400 do
			if GetSpellName(i,BOOKTYPE_SPELL) and GetSpellName(i,BOOKTYPE_SPELL)==spell then 
				SpellTextureID[spell]["texture"] = GetSpellTexture(i,BOOKTYPE_SPELL)
				SpellTextureID[spell]["id"] = i
				break
			end
		end
	end
	if not SpellTextureID[spell]["texture"] then message("SafeBuff: No texture found for: "..spell) end
	return SpellTextureID[spell]["id"],SpellTextureID[spell]["texture"]
end

-- Checks if the Unit has the buff up, returns true if it does, false otherwise
local function HasBuff(unit,texture)

	if texture == nil then message("SafeBuff Error, no spell texture found for: "..textures[i]) end
	local castable = true
	
	-- Check 32 buffs
	for b = 1,32 do
		
		-- Stop checking castable buffs if nil got returned once
		if castable then 
			local cb = UnitBuff(unit,b,1)
			if cb == nil then 
				castable = false 
			elseif cb == texture then
				return true
			end
		end
		
		-- Check all buffs, if no more buffs nil is returned and function returns false
		local ub = UnitBuff(unit,b)
		if ub == nil then 
			return false 
		elseif ub == texture then
			return true
		end
	end
	
	return false
end

-- Buffs the given target if none of the given textures were found.
function SafeBuff(unit,buff,textures,ExClasses,raidBuffing)
    -- Only done once incase of raidbuffing
	if type(ExClasses) == "number" then ExClasses = {ExClasses} end
	if not raidBuffing then
		-- Reset Class restriction
		BuffClasses = {WARRIOR=true, PALADIN=true, HUNTER=true, ROGUE=true, PRIEST=true, SHAMAN=true, MAGE=true, WARLOCK=true, DRUID=true}
		if ExClasses then 
			-- Exclude classes
			for i = 1,getn(ExClasses) do
				BuffClasses[ClassName[ExClasses[i]]] = false
			end
		end
	end
	
	if type(textures) == "string" then textures = {textures} end
	if textures then
		table.insert(textures,1,buff) 
	else	
		textures = {buff}
	end

	if not unit then message("SafeBuff requires a target unit, e.g. 'target'. See http://wowwiki.wikia.com/wiki/UnitId") return end
	if not buff then message("SafeBuff requires a buff to cast unit, e.g. 'Power Word: Fortitude'.") return end
	if not textures then message("SafeBuff requires a list of spells which won't cause the buff to be casted, e.g. SafeBuff('target','Power Word: Fortitude',{'Prayer of Fortitude','Mark of the Wild'}).") return end

	local _,class = UnitClass(unit)
	if BuffClasses[class] and UnitExists(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit) then
		for i = 1,getn(textures) do
			local _,texture = GetSpellTextureAndID(textures[i])
			if HasBuff(unit,texture) then return false end 
		end
		if not UnitIsUnit("target",unit) and not (unit == "player" and (UnitCanAssist("player","target") == nil or UnitExists("target")== nil)) then TargetUnit(unit) end
		CastSpellByName(buff,unit)
		return true
	else
		return false
	end
end

-- Checks the raid for missing buffs and buffs them with SafeBuff(unit,buff,textures,ExClasses)
function SafeBuffRaid(buff,textures,ExClasses)

	if UnitInRaid("player") ~= nil then
		t = "raid"
		a = 40
	else
		a = 4
		t = "party"
	end
	-- Reset Class restriction
	BuffClasses = {WARRIOR=true, PALADIN=true, HUNTER=true, ROGUE=true, PRIEST=true, SHAMAN=true, MAGE=true, WARLOCK=true, DRUID=true}
		
	-- Init which classes get buffed:
	if type(ExClasses) == "number" then ExClasses = {ExClasses} end
	if ExClasses then 
		-- Exclude classes
		for i = 1,getn(ExClasses) do
			BuffClasses[ClassName[ExClasses[i]]] = false
		end
	end
 
	-- Loop through the raid/grp to buff
    for i=1,a do
		if UnitRace(t.."pet"..i) == nil and UnitExists(t.."pet"..i) and CheckInteractDistance(t.."pet"..i,4) == 1 then
				
			-- Exclude imp with phase shift
			local hasBuff = nil
			for j = 1,16,1 do
				if UnitBuff(t.."pet"..i,j) == "Interface\\Icons\\Spell_Shadow_ImpPhaseShift" then hasBuff = 1 break end
			end
			if hasBuff == nil then local r = SafeBuff(t.."pet"..i,buff,textures,nil,true) if r then return r end end
			if CheckInteractDistance(t..i,4) == 1 then local r = SafeBuff(t..i,buff,textures,nil,true) if r then return r end end
		elseif CheckInteractDistance(t..i,4) == 1 then 
			local r = SafeBuff(t..i,buff,textures,nil,true) 
			if r then return r end
		end
    end

	return SafeBuff("player",buff,textures,nil,true)
end