--Primitsurugi Alembertian
local s,id=GetID()
function s.initial_effect(c)
	--[[
		☆ You can Tribute 1 Monster; Special Summon 1 Lever 4 "Mitsurugi" Monster from your Hand or GY.
		☆ If this card is Tributed: You can add 1 "Mitsurugi" card from your Deck to your hand,
		then you can Special Summon this card.
		☆ If this card is Xyz Summoned: You can detach 2 to 4 materials from this card, then activate the appropriate effect;
		●2: Add 1 "Mitsurugi" card from your Deck to your Hand.
		●3: Ritual Summon 1 Reptile Ritual Monster from your Hand, by Tributing up to 2 Reptile monsters
		from your Hand, Deck, or field, whose total Levels equal the Level of the Ritual Monster.
		●4: Ritual Summon 1 Reptile Ritual Monster from your Deck, GY or Banished, by Tributing up to 2 Reptile monsters
		from your Hand, Deck, or field, whose total Levels equal the Level of the Ritual Monster. 
		You can only use each effect of "Primitsurugi Alembertial" once per turn.
	--]]

	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2,nil,nil,Xyz.InfiniteMats)
	--Special Summon 1 Level 4 "Mitsurugi" monster from your hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Activate the appropriate effect based on the number of materials detached
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e2:SetCost(Cost.Choice(
		{Cost.DetachFromSelf(2),aux.Stringid(id,2),s.effcheck(1)},
		{Cost.DetachFromSelf(3),aux.Stringid(id,3),s.effcheck(2)},
		{Cost.DetachFromSelf(4),aux.Stringid(id,4),s.effcheck(3)}
	))
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	--Add 1 "Mitsurugi" card from your Deck to your hand then you can Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,5))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MITSURUGI}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,aux.ReleaseCheckMMZ,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MITSURUGI) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.thfilter(c)
	return c:IsSetCard(SET_MITSURUGI) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.effcheck(op)
	if op==1 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	if op==2 then
		local params1={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_HAND,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
		return function(e,tp,eg,ep,ev,re,r,rp)
			return not Duel.HasFlagEffect(tp,id) and Ritual.Target(params1)(e,tp,eg,ep,ev,re,r,rp,0)
		end
	end
	if op==3 then
		local params2={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
		return function(e,tp,eg,ep,ev,re,r,rp)
			return not Duel.HasFlagEffect(tp,id) and Ritual.Target(params2)(e,tp,eg,ep,ev,re,r,rp,0)
		end
	end
end

function s.matfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsReleasableByEffect() 
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
function s.tributelimit(e,tp,g,sc)
	return #g<=2,#g>2
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local op=e:GetLabel()
	local params1={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_HAND,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
	local params2={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
	if chk==0 then return (op==1 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)) or (op==2 and not Duel.HasFlagEffect(tp,id) and Ritual.Target(params1)(e,tp,eg,ep,ev,re,r,rp,0)) or (op==3 and not Duel.HasFlagEffect(tp,id) and Ritual.Target(params2)(e,tp,eg,ep,ev,re,r,rp,0)) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	if op==1 then
	end
	if op==2 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE)
	end
	if op==3 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if op==2 then
		local params1={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_HAND,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
		Ritual.Operation(params1)(e,tp,eg,ep,ev,re,r,rp)
	end
	if op==3 then
		local params2={handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
		Ritual.Operation(params2)(e,tp,eg,ep,ev,re,r,rp)
	end
end