--Tearlaments Zekallos
local s,id=GetID()
function s.initial_effect(c)
	
	--[[
	3+ "Tearlaments" and/or Aqua monsters
	
	If this face-up card would leave the field, shuffle it into the Extra Deck instead.
	
	If this card is Special Summoned or if an Aqua monster(s) is shuffled into the Deck or Extra Deck (except during the Damage Step):
	Draw 1 card, then if it was an Aqua monster, you can destroy 1 card on the field.
	
	You can only use this effect of "Tearlaments Zekallos" once per turn.
	
	Once per chain, if a monster is Special Summoned; send the top card of your Deck to the GY,
	then if it was a "Tearlaments" card, you can shuffle 1 card from the field, GY or banished into the Deck.
	]]--
	c:EnableReviveLimit()
	--Fusion Materials: 3+ "Tearlaments" and/or Aqua monsters
	Fusion.AddProcMix(c,true,true,s.ffilter,s.ffilter,s.ffilter)
	function s.ffilter()
		return aux.FilterBoolFunctionEx(Card.IsSetCard,0x182) or aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA) end


	s.listed_series={0x182}

	end