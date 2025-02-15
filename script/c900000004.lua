--Tearlaments Estel
local s,id=GetID()
function s.initial_effect(c)
	
	--[[
	You can send this card from your hand to the GY;
	Fusion Summon 1 Fusion Monster from your Extra Deck,
	by placing Fusion Materials mentioned on it from your hand,
	field, and/or GY, including this card from your GY, on the bottom of the Deck in any order.
	 
	If this card is sent to the GY by card effect (except during the Damage Step):
	You can Fusion Summon 1 Fusion Monster from your Extra Deck,
	by placing Fusion Materials mentioned on it from your hand, field, and/or GY,
	including this card from your GY, on the bottom of the Deck in any order.
	
	You can only use each effect of "Tearlaments Estel" once per turn. 
	]]--
	local fusparams = {matfilter=Card.IsAbleToDeck,extrafil=s.extramat,extraop=s.extraop,gc=Fusion.ForcedHandler,extratg=s.extratarget}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	--e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(Fusion.SummonEffTG(fusparams))
	e1:SetOperation(Fusion.SummonEffOP(fusparams))
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return Duel.GetCurrentPhase()~=PHASE_DAMAGE and e:GetHandler():IsReason(REASON_EFFECT) end)
	e2:SetTarget(Fusion.SummonEffTG(fusparams))
	e2:SetOperation(Fusion.SummonEffOP(fusparams))
	c:RegisterEffect(e2)

end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.extramat(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,nil)
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
function s.extraop(e,tc,tp,sg)
	local gg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE)
	if #gg>0 then Duel.HintSelection(gg,true) end
	local rg=sg:Filter(Card.IsFacedown,nil)
	if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	local dg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	local ct=dg:FilterCount(Card.IsControler,nil,tp)
	if ct>0 then
		Duel.SortDeckbottom(tp,tp,ct)
	end
	if #dg>ct then
		Duel.SortDeckbottom(tp,1-tp,#dg-ct)
	end
	sg:Clear()
end