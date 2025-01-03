--Metaphys Alexandrite
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_ONFIELD)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.frodcost)
	e1:SetOperation(s.frod)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.scost)
	e2:SetOperation(s.sfb)
	c:RegisterEffect(e2)
	local e5=e2:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetOperation(s.bfdh)
	e3:SetCost(aux.SelfBanishCost)
	c:RegisterEffect(e3)


	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCost(s.rmcost2)
	e4:SetTarget(s.rmtg2)
	e4:SetOperation(s.rmop2)
	c:RegisterEffect(e4)

end
s.listed_series={0x105}

function s.frodcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() or c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and rc:IsSetCard(0x105) then
		Duel.SetChainLimit(function(_e,_rp,_tp) return _tp==_rp end)
	end
end
function s.frod(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	--banish all metaphys cards
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(1,0)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetTarget(function(_,c) return c:IsSetCard(0x105) and c:GetOwner()==tp end)
	Duel.RegisterEffect(e1,tp)
	--unrespondable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetOperation(s.chainop)
	Duel.RegisterEffect(e2,tp)
	
end

function s.sfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToRemove() and c:IsAbleToRemoveAsCost() and c:IsSummonableCard()
end
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST,PLAYER_NONE,1-tp)
	Duel.SetTargetCard(g)
function s.sfdfilter(c,e,tp)
	return c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
end
function s.sfb(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then

		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetCountLimit(1)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetLabel(Duel.GetTurnCount())
			e2:SetLabelObject(tc)
			e2:SetCondition(s.descon)
			e2:SetOperation(s.desop)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end


function s.bfdhfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToRemove()
end
function s.bfdh(e,tp,eg,ep,ev,re,r,rp,c)
	local ct=#Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)+1
	if ct>0 then
		local g=Duel.SelectMatchingCard(tp,s.bfdhfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,ct,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,1-tp)
	end
end

function s.rmfilter2(c)
	return c:IsSetCard(0x105) and not c:IsCode(id) and c:IsAbleToRemove()
end
function s.rmcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),tp,2,REASON_COST)
end
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end