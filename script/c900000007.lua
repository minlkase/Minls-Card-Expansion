--Sangen Ina:
local s,id=GetID()
--[[
If your opponent controlls more cards than you do: Special Summon 1 FIRE Dragon monster from your Deck, then discard 1 card,
also you cannot Special Summon monsters for the rest of this Duel, except "Tenpai Dragon" monsters or Dragon Type monsters from the Extra Deck.
If this card is in your GY, you can banish 1  "Sangen" Spell/Trap and 1 "Tenpai Dragon" monster (1 from the hand and 1 from the Deck);
add this card from your GY to your hand.
You can only use this effect of "Sangen Ina" once per Turn.
During the BP, you can banish this card form your GY (QE); Special Summon 1 FIRE Dragon monster from your GY, then discard 1 card.
You can only use this effect of "Sangen Ina" once per Duel.
--]]

function s.initial_effect(c)
    --Special from Deck
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sfdtarget)
	e1:SetOperation(s.sfd)
    e1:SetCountLimit(1)
	c:RegisterEffect(e1)

    --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
    e2:SetCountLimit(1,{id,0})
	c:RegisterEffect(e2)

    --BP banish
	local e3=Effect.CreateEffect(c)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_ATTACK|TIMING_BATTLE_PHASE)
	e4:SetCondition(function() return Duel.IsBattlePhase() end)
    e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_SANGEN}


function s.sfdfilter(c,e,tp)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sfdtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	local ct=#g-Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfdfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and ct<=0 end
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sfd(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.sfdfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #sc>0 and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
    c=e:GetHandler()
    local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.splimit)
	Duel.RegisterEffect(ge1,tp)

end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not ((c:IsLocation(LOCATION_EXTRA) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON)) or c:IsSetCard(SET_TENPAI_DRAGON))
end

function s.bfdgfilterA(c)
	return c:IsSetCard(SET_TENPAI_DRAGON) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.bfdgfilterB(c)
    return c:IsSetCard(SET_SANGEN) and c:IsSpellTrap() and c:IsAbleToRemoveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    cond1 = Duel.IsExistingMatchingCard(s.bfdgfilterA,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.bfdgfilterB,tp,LOCATION_DECK,0,1,nil)
    cond2 = Duel.IsExistingMatchingCard(s.bfdgfilterB,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.bfdgfilterA,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return cond1 or cond2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,function (c) return s.bfdgfilterA(c) or bfdgfilterB(c) end,tp,LOCATION_HAND,0,1,1,nil)
    if g1:IsSetCard(SET_TENPAI_DRAGON) then
        f=s.bfdgfilterB
    else g1:IsSetCard(SET_SANGEN)
        f=s.bfdgfilterA
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
    Duel.Remove(g2,POS_FACEUP,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

function s.spfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
    end
end