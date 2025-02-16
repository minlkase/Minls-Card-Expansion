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
	Fusion.AddProcMix(c,true,true,
	aux.FilterBoolFunctionEx(Card.IsSetCard,0x182) or aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),
	aux.FilterBoolFunctionEx(Card.IsSetCard,0x182) or aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),
	aux.FilterBoolFunctionEx(Card.IsSetCard,0x182) or aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA))

	--to Extra if it leaves the field
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCondition(function(e)return e:GetHandler():IsFaceup()end)
	e0:SetValue(LOCATION_EXTRA)
	c:RegisterEffect(e0)
	s.listed_series={0x182}


	--Draw 1, Destroy 1 card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	local e2 = e1:Clone()
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(function() return true end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

end


function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE+LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsSetCard(0x182) and (c:IsMonster() or c:IsPreviousLocation(LOCATION_MZONE)) and c:IsReason(REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end

	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,dc)
	if dc:IsMonster() and dc:IsRace(RACE_AQUA) and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		Duel.ShuffleHand(tp)
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end