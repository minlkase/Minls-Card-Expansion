--Metaphys Showdown
local s,id=GetID()
function s.initial_effect(c)
	
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.btarget)
	e1:SetOperation(s.b)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.ath)
    e2:SetTarget(s.athtarget)
	e2:SetCost(aux.SelfBanishCost)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_REMOVED)
    e3:SetTargetRange(1,0)
	e3:SetCountLimit(1,{id,2})
	e3:SetOperation(s.sfd)
	e3:SetTarget(s.sfttarget)
	e3:SetCost(s.rtg)
	c:RegisterEffect(e3)
end
s.listed_series={0x105}
function s.btarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):RemoveCard(e:GetHandler())
    if chk==0 then return #g>0 and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEUP,REASON_EFFECT) and Duel.IsPlayerCanDraw(tp) end
end
function s.b(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):RemoveCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,1-tp)
	local nb=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):RemoveCard(e:GetHandler())
    Duel.Draw(tp,#nb,REASON_EFFECT)
end

function s.athfilter(c)
    return c:IsSetCard(0x105) and c:IsAbleToHand()
end
function s.bfdhfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToRemove()
end
function s.athtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct = #Duel.GetMatchingGroup(s.athfilter,tp,LOCATION_REMOVED,0,1,nil)
    if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_REMOVED)
end
function s.ath(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(s.athfilter,tp,LOCATION_REMOVED,0,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local b=Duel.SelectMatchingCard(tp,s.bfdhfilter,tp,LOCATION_DECK+LOCATION_HAND,0,#g,#g,nil)
		Duel.Remove(b,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,1-tp)
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