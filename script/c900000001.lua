--Metaphys Awakening
local s,id=GetID()
function s.initial_effect(c)
	
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.thtarget)
	e1:SetOperation(s.th)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.bfd)
	e2:SetCost(aux.SelfBanishCost)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,{id,2})
	e3:SetOperation(s.sfd)
	e3:SetTarget(s.sfttarget)
	e3:SetCost(s.rtg)
	c:RegisterEffect(e3)
end
s.listed_series={0x105}
function s.thfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToHand()
end
function s.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.th(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.bfdfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToRemove()
end
function s.bfd(e,tp,eg,ep,ev,re,r,rp,c)
	local ct=#Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)+1
	if ct>0 then
		local g=Duel.SelectMatchingCard(tp,s.bfdfilter,tp,LOCATION_DECK,0,1,ct,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,1-tp)
	end
end

function s.sfdfilter(c,e,tp)
	return c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc = e:GetHandler()
	if chk==0 then return tc and tc:IsLocation(LOCATION_REMOVED) end
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
end
function s.sfttarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sfdfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sfd(e,tp,eg,ep,ev,re,r,rp,c)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sfdfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
		local tc=Duel.SelectMatchingCard(tp,s.sfdfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end