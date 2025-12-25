--Mitsurugi Circular
local s,id=GetID()
function s.initial_effect(c)
	--[[
	☆You can Tribute 1 "Mitsurugi" monster, except "Mitsurugi Circular", from your Deck; Special Summon this card from your hand,
	also you can only attack with 1 monster for the rest of this turn.
	☆If this card is Normal or Special Summoned, or if this card is Tributed: You can Ritual Summon 1 "Mitsurugi" monster
	from your Hand, Deck, GY or Banished, by Suffling up to 2 Reptile monsters from your Hand, Field, GY or Banished
	into the Deck, whose total Levels equal the Level of the Ritual Monster, except "Mitsurugi Circular".
	☆If another Reptile monster(s) you control would be destroyed by battle or card effect, you can Tribute this card instead.
	You can only use each effect of "Mitsurugi Circular" once per turn.
	--]]

	--You can Tribute 1 "Mitsurugi" monster,...
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned, or if this card is Tributed:...
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e4)
	--If another Reptile monster(s) you control would be destroyed by battle or card effect, you can Tribute this card instead
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.reptg)
	e5:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	e5:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.Release(e:GetHandler(),REASON_EFFECT|REASON_REPLACE) end)
	c:RegisterEffect(e5)
end
s.listed_series={SET_MITSURUGI}

function s.spcfilter(c)
	return c:IsSetCard(SET_MITSURUGI) and c:IsMonster() and not c:IsCode(id) and c:IsReleasableByEffect()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST|REASON_RELEASE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--Can only attack with 1 monster this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(function(e) return e:GetLabel()~=0 end)
	e1:SetTarget(function(e,c) return c:GetFieldID()~=e:GetLabel() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.checkop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end

-- e2

function s.matfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToDeck() 
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	mat:Sub(mat2)
	-- Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoDeck(mat2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL|REASON_RELEASE)
	Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL|REASON_RELEASE)
end
function s.tributelimit(e,tp,g,sc)
	return #g<=2,#g>2
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params1={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
	if chk==0 then return not Duel.HasFlagEffect(tp,id) and Ritual.Target(params1)(e,tp,eg,ep,ev,re,r,rp,0) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local params1={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
	Ritual.Operation(params1)(e,tp,eg,ep,ev,re,r,rp)
end

-- e3

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_REPTILE)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp)
		and c:IsReleasableByEffect(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end