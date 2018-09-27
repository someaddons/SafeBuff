# SafeBuff
wow 1.12 addon for smart buffs


How to use SafeBuff:
3 Functions(To Be used in a macro with /run or /script) are introduced and can be used to your liking:

1.SafeBuff(unit,buff,excludeBuffs,ExcludeClasses) Buffs the given unit, if it doesnt match either excluded buffs and excluded classes.

	Parameters: 
	
	unit: The unit to cast the buff on, e.g. "target" or "player" or "raid1".
		  See http://wowwiki.wikia.com/wiki/UnitId?oldid=204442 for more units.

	buff: The Spell to be cast on the unit, e.g. "Power Word: Fortitude(Rank 1)". 

	(optional)excludeBuffs: Buffs or Buff Textures on the target which exclude the unit from getting buffed with the above given buff.
				  Use Buff Textures if the Buff doesnt exist in your spellbook.
				  E.g. {"Prayer of Fortitude"} or {"Interface\\Icons\\Spell_Holy_WordFortitude"}
				  To find the texture here is a list with most spells: http://wowwiki.wikia.com/wiki/Queriable_buff_effects
				  make sure to add Interface\\Icons\\ infront of the given texture.
				  
				  To exclude multiple Buffs you can list them like this: {"Prayer of Fortitude","Prayer of Spirit"}
				  Use  nil  to skip this parameter
	
	(optional)ExcludeClasses: The classes which should not be buffed, using this class Index:
					1 Warrior
					2 Paladin
					3 Hunter
					4 Rogue
					5 Priest
					6 Shaman
					7 Mage
					8 Warlock
					9 Druid

					E.g. {1,5,3} Excludes Warriors priests and hunters from beeing buffed.
					E.g. {1} Excludes only warriors from beeing buffed
					
					Use  nil  or dont specify it to skip this parameter.
	Examples:
	
	Buffs the target only if it does not have Power Word: Fortitude.
	/run SafeBuff("target","Power Word: Fortitude")

	Buffs the target only if it does not have Power Word: Fortitude nor Prayer of Fortitude.
	/run SafeBuff("target","Power Word: Fortitude",{"Prayer of Fortitude"}) 
	
	Buffs the target only if it does not have Power Word: Fortitude nor Prayer of Fortitude and Mark of the Wild.
	/run SafeBuff("target","Power Word: Fortitude",{"Prayer of Fortitude","Interface\\Icons\\Spell_Nature_Regeneration"})

	Buffs the target only if it does not have Power Word: Fortitude and is neither a Warrior nor a Hunter(hunter pets and npcs count as warriors)
		nil is used to skip the excludeBuffs parameter.
	/run SafeBuff("target","Power Word: Fortitude",nil,{1,3})

	
2. SafeBuffRaid(buff,excludeBuffs,ExcludeClasses) Selects and Buffs a raidmember which is missing the Buff and does not match the excluded buffs nor the excluded classes.
	
	Parameters: Same as SafeBuff() above, except there is no unit needed.
	
	Examples:
	
	Buff the whole Raid with Thorns Rank 1 (1 Buff each click), doesnt buff ppl that already have thorns.
	/run SafeBuffRaid("Thorns(Rank 1)") 
	
	Buff the whole Raid with Thorns Rank 1 (1 Buff each click), doesnt buff ppl that already have thorns and neither buffs priests.
		nil skips the excludeBuffs parameter here
	/run SafeBuffRaid("Thorns",nil,{5}) 
	
	Buffs all warriors(and hunter pets) in the raid thorns, all other classes are excluded
	/run SafeBuffRaid("Thorns",nil,{2,3,4,5,6,7,8,9})
	
	Buff Power Word: Fortitude to all raidmembers which dont have Prayer of Fortitude and is not a priest.
	/run SafeBuffRaid("Power Word: Fortitude",{"Prayer of Fortitude"},{5}) 
	
3. GetSpellTextureAndID(spell) returns the spellbook id and texture of the given spell, in that order. Saves once looked up spells to speedup lookups. (Doesnt check different ranks yet)
/run id,texture = GetSpellTextureAndID("Power Word: Fortitude")
