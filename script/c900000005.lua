--Tearlaments Scyklith
local s,id=GetID()
function s.initial_effect(c)
	
	--[[
	2 "Tearlaments" monster
	Must first be either Fusion Summoned, or Special Summoned (from your Extra Deck)
	by Tributing 1 "Tearlaments" Fusion monster you control.
	
	If this card is Special Summoned: You can send the top 3 cards of your Deck to the GY.
	
	You can target 1 monster you control; add 1 "Tearlaments" Spell/Trap from your Deck to your Hand,
	and if you do, send the targeted monster to the GY.
		
	If this card is sent to the GY by card effect: You can Special Summon this card,
	and if you do, send 1 "Tearlaments" Spell/Trap from your Deck to the GY.
		
	You can only use each effect of "Tearlaments Scyklith" once per turn. 
	]]--
	c:EnableReviveLimit()
	--Fusion Materials: 2 "Tearlaments" monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x182),aux.FilterBoolFunctionEx(Card.IsSetCard,0x182))
	c:AddMustFirstBeFusionSummoned()

	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.selfspcon)
	e0:SetTarget(s.selfsptg)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)

end
s.listed_series={0x182}
function s.selfspcostfilter(c,tp,fc)
	return c:IsSetCard(0x182) and c:IsReleasable() and c:IsType(TYPE_FUSION)
		and c:IsCanBeFusionMaterial(fc,MATERIAL_FUSION) and c:IsControler(tp)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
		and sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.selfspcon(e,c)
	if not c then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,e:GetHandler())
	return #mg>=1 and aux.SelectUnselectGroup(mg,e,tp,1,1,s.rescon,0)
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_ONFIELD,LOCATION_MZONE,nil,tp,e:GetHandler())
	local g=aux.SelectUnselectGroup(mg,e,tp,1,1,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end