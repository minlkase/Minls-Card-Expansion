--Tenpai Dragon Condra
local s,id=GetID()
function s.initial_effect(c)
	--[[
	If this card is Normal or Special Summoned; add 1 Level 4 or lower FIRE Dragon monster from your Deck to your hand.
	You can only use this effect of "Tenpai Dragon Condra" once per turn.
	Your opponent cannot activate cards or effects durring the MP2 and EP.
	Cards and effects activated by your opponent during the BP are negated, while you control more FIRE Dragon monsters, than cards your opponent controlls.
	Once per turn during the BP, you can (QE); Immediatly after this effect resolves, Synchro Summon using cards you control.
	--]]

	--add 1 Level 4 or lower FIRE Dragon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	--cannot activate cards or effects durring the MP2 and EP
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(function () return Duel.IsPhase(0x100) or Duel.IsPhase(0x200) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	--during the BP are negated
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.condition)
	e4:SetTargetRange(0,1)
	e4:SetTarget(s.disable)
	e4:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e4)

	--quick synchro
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_END)
	e5:SetCountLimit(1)
	e5:SetCondition(function () return Duel.IsBattlePhase() end)
	e5:SetTarget(s.synchtg)
	e5:SetOperation(s.synchop)
	c:RegisterEffect(e5)

end
s.listed_series={SET_TENPAI_DRAGON}


function s.thfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
	end
end

function s.disable(e,c)
	return c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT
end
function s.nfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON)
end
function s.condition(e)
	tp=Duel.IsTurnPlayer(1)
	return #Duel.GetMatchingGroup(s.nfilter,tp,LOCATION_ONFIELD,1,0,nil)-#Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
end

function s.synchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end