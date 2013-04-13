local SetJob_Frame = function(self, job)
    if job.alpha then
        self:SetAlpha(job.alpha)
        -- if self.health2 then
        --     if job.alpha < 1 then
        --         self.health2:Hide()
        --     else
        --         self.health2:Show()
        --     end
        -- end
    end
end
local Frame_HideFunc = function(self)
    self:SetAlpha(1) -- to exit frrom OOR status
end
local SetJob_HealthBar = function(self, job)
    local c
    if job.classcolor then
        c = self.parent.classcolor
    elseif job.color then
        c = job.color
    end
    if c then
        self:SetStatusBarColor(0,0,0,0.8)
        self.bg:SetVertexColor(unpack(c))
    end
end
local OnDead = function(self)
    self.power:Hide()
end
local OnAlive = function(self)
    if not self.power.disabled then
        self.power:Show()
    else
        self.power:Hide()
    end
end
local PowerBar_OnPowerTypeChange = function(self, powertype)
    local self = self.parent
    if powertype ~= "MANA" then
        self.power.disabled = true
        self.power:Hide()
    else
        self.power.disabled = nil
        self.power:Show()
    end
end
local SetJob_Indicator = function(self,job)
    if job.showDuration then
        self.cd:SetReverse(not job.reverseDuration)
        self.cd:SetCooldown(job.expirationTime - job.duration,job.duration)
        self.cd:Show()
    else
        self.cd:Hide()
    end

    local color
    if job.foreigncolor and job.isforeign then
        color = job.foreigncolor
    else
        color = job.color or { 1,1,1,1 }
    end
    self.color:SetVertexColor(unpack(color))
    
    if job.fade then
        if self.blink:IsPlaying() then
            self.blink:Stop()
            if self.traceJob ~= job then
                Aptechka.FrameSetJob(self.parent,self.traceJob, false)
            end
        end
        self.traceJob = job
        if job.noshine then
            self.blink.a2:SetChange(1)
        else
            self.blink.a2:SetChange(-1)
        end
        self.blink.a2:SetDuration(job.fade)
        self.blink:Play()
    end
    if job.pulse and (not self.currentJob or job.priority > self.currentJob.priority) then
        if not self.pulse:IsPlaying() then self.pulse:Play() end
    end
end

local CreateIndicator = function (parent,w,h,point,frame,to,x,y,nobackdrop)
    local f = CreateFrame("Frame",nil,parent)
    f:SetWidth(w); f:SetHeight(h);
    if not nobackdrop then
    f:SetBackdrop{
        bgFile = "Interface\\Addons\\Aptechka\\white", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    f:SetBackdropColor(0, 0, 0, 1)
    end
    f:SetFrameLevel(6)
    local t = f:CreateTexture(nil,"ARTWORK")
    t:SetTexture[[Interface\AddOns\Aptechka\white]]
    t:SetAllPoints(f)
    f.color = t
    local icd = CreateFrame("Cooldown",nil,f)
    icd.noCooldownCount = true -- disable OmniCC for this cooldown
    icd:SetReverse(true)
    icd:SetAllPoints(f)
    f.cd = icd
    f:SetPoint(point,frame,to,x,y)
    f.parent = parent
    f.SetJob = SetJob_Indicator
    
    local pag = f:CreateAnimationGroup()
    local pa1 = pag:CreateAnimation("Scale")
    pa1:SetScale(2,2)
    pa1:SetDuration(0.2)
    pa1:SetOrder(1)
    local pa2 = pag:CreateAnimation("Scale")
    pa2:SetScale(0.5,0.5)
    pa2:SetDuration(0.8)
    pa2:SetOrder(2)
    
    f.pulse = pag
    
    local bag = f:CreateAnimationGroup()
    bag:SetLooping("NONE")
    local ba1 = bag:CreateAnimation("Alpha")
    ba1:SetChange(1)
    ba1:SetDuration(0.1)
    ba1:SetOrder(1)
    local ba2 = bag:CreateAnimation("Alpha")
    ba2:SetChange(-1)
    ba2:SetDuration(0.7)
    ba2:SetOrder(2)
    bag.a2 = ba2
    bag:SetScript("OnFinished",function(self)
        self = self:GetParent()
        Aptechka.FrameSetJob(self.parent,self.traceJob, false)
    end)
    f.blink = bag
    
    f:Hide()
    return f
end


local SetJob_Corner = function(self,job)
    local color
    if job.foreigncolor and job.isforeign then
        color = job.foreigncolor
    else
        color = job.color or { 1,1,1,1 }
    end
    self.color:SetVertexColor(unpack(color))

    if job.pulse and (not self.currentJob or job.priority > self.currentJob.priority) then
        if not self.pulse:IsPlaying() then self.pulse:Play() end
    end
end
local CreateCorner = function (parent,w,h,point,frame,to,x,y,nobackdrop)
    local f = CreateFrame("Frame",nil,parent)
    f:SetWidth(w); f:SetHeight(h);

    f:SetFrameLevel(5)
    local t = f:CreateTexture(nil,"ARTWORK")
    t:SetTexture[[Interface\AddOns\Aptechka\corner]]
    t:SetAllPoints(f)

    if point == "TOPRIGHT" then
        t:SetTexCoord(0,1,1,0)
    elseif point == "TOPLEFT" then
        t:SetTexCoord(1,0,1,0)
    elseif point == "BOTTOMLEFT" then
        t:SetTexCoord(1,0,0,1)
    end

    f.color = t
    f:SetPoint(point,frame,to,x,y)
    f.parent = parent
    f.SetJob = SetJob_Corner

    local pag = f:CreateAnimationGroup()
    local pa1 = pag:CreateAnimation("Scale")
    pa1:SetOrigin(point,0,0)
    pa1:SetScale(2,2)
    pa1:SetDuration(0.2)
    pa1:SetOrder(1)
    local pa2 = pag:CreateAnimation("Scale")
    pa2:SetOrigin(point,0,0)
    pa2:SetScale(0.5,0.5)
    pa2:SetDuration(0.8)
    pa2:SetOrder(2)
    
    f.pulse = pag
        
    f:Hide()
    return f
end

local SetJob_StatusBar = function(self,job)
    -- if job.showDuration then
        -- self.cd:SetReverse(not job.reverseDuration)
        -- self.cd:SetCooldown(job.expirationTime - job.duration,job.duration)
        -- self.cd:Show()
    -- else
        -- self.cd:Hide()
    -- end
    self.expires = job.expirationTime
    self:SetMinMaxValues(0, job.duration)
    self:SetValue(self.expires - GetTime())

    local color
    if job.foreigncolor and job.isforeign then
        color = job.foreigncolor
    else
        color = job.color or { 1,1,1,1 }
    end
    self.bg:SetVertexColor(color[1]/3, color[2]/3, color[3]/3)
    self:SetStatusBarColor(unpack(color))
    
    -- if job.fade then
    --     if self.blink:IsPlaying() then self.blink:Finish() end
    --     self.traceJob = job
    --     self.blink.a2:SetDuration(job.fade)
    --     self.blink:Play()
    -- end
    -- if job.pulse and (not self.currentJob or job.priority > self.currentJob.priority) then
    --     if not self.pulse:IsPlaying() then self.pulse:Play() end
    -- end
end
local StatusBarOnUpdate = function(self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 0.05 then return end
    self.OnUpdateCounter = 0

    self:SetValue(self.expires - GetTime())
end
local CreateStatusBar = function (parent,w,h,point,frame,to,x,y,nobackdrop)
    local f = CreateFrame("StatusBar",nil,parent)
    f:SetWidth(w); f:SetHeight(h);
    if not nobackdrop then
    f:SetBackdrop{
        bgFile = "Interface\\Addons\\Aptechka\\white", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    f:SetBackdropColor(0, 0, 0, 1)
    end
    f:SetFrameLevel(7)

    f:SetStatusBarTexture[[Interface\AddOns\Aptechka\white]]
    -- f:SetMinMaxValues(0,100)
    -- f:SetStatusBarColor(1,1,1)

    local bg = f:CreateTexture(nil,"ARTWORK",nil,-1)
    bg:SetTexture[[Interface\AddOns\Aptechka\white]]
    bg:SetAllPoints(f)
    f.bg = bg

    f:SetPoint(point,frame,to,x,y)
    f.parent = parent
    f.SetJob = SetJob_StatusBar
    f:SetScript("OnUpdate", StatusBarOnUpdate)

    -- local pag = f:CreateAnimationGroup()
    -- local pa1 = pag:CreateAnimation("Scale")
    -- pa1:SetScale(2,2)
    -- pa1:SetDuration(0.2)
    -- pa1:SetOrder(1)
    -- local pa2 = pag:CreateAnimation("Scale")
    -- pa2:SetScale(0.5,0.5)
    -- pa2:SetDuration(0.8)
    -- pa2:SetOrder(2)
    
    -- f.pulse = pag

    f:Hide()
    return f
end



AptechkaDefaultConfig.GridSkin_CreateIndicator = CreateIndicator
local SetJob_Icon = function(self,job)
    if job.fade then self.jobs[job.name] = nil; return end
    if job.showDuration then
        self.cd:SetReverse(not job.reverseDuration)
        self.cd:SetCooldown(job.expirationTime - job.duration,job.duration)
        self.cd:Show()
    else
        self.cd:Hide()
    end
    self.texture:SetTexture(job.texture)
    
    if self.stacktext then
        if job.stacks then self.stacktext:SetText(job.stacks > 1 and job.stacks or "") end
    end
end
local CreateIcon = function(parent,w,h,alpha,point,frame,to,x,y)
    local icon = CreateFrame("Frame",nil,parent)
    icon:SetWidth(w); icon:SetHeight(h)
    icon:SetPoint(point,frame,to,x,y)
    local icontex = icon:CreateTexture(nil,"ARTWORK")
    icontex:SetTexCoord(.1, .9, .1, .9)
    icon:SetFrameLevel(6)
    icontex:SetPoint("TOPLEFT",icon, "TOPLEFT",0,0)
    icontex:SetWidth(h);
    icontex:SetHeight(h);
    icon.texture = icontex
    icon:SetAlpha(alpha)
    
    local icd = CreateFrame("Cooldown",nil,icon)
    icd.noCooldownCount = true -- disable OmniCC for this cooldown
    icd:SetReverse(true)
    icd:SetAllPoints(icontex)
    icon.cd = icd
    
    local stacktext = icon:CreateFontString(nil,"OVERLAY")
    if AptechkaUserConfig.font then
        stacktext:SetFont(AptechkaUserConfig.font,10,"OUTLINE")
    else
        stacktext:SetFontObject("NumberFontNormal")
    end
    stacktext:SetJustifyH"RIGHT"
    stacktext:SetPoint("BOTTOMRIGHT",icon,"BOTTOMRIGHT",0,0)
    stacktext:SetTextColor(1,1,1)
    icon.stacktext = stacktext
    icon.SetJob = SetJob_Icon
    
    return icon
end
AptechkaDefaultConfig.GridSkin_CreateIcon = CreateIcon


local DebuffTypeColor = DebuffTypeColor
local function SetJob_DebuffIcon(self, job)
    SetJob_Icon(self, job)
    local debuffType = job.debuffType
    local color = debuffType and DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
    self.debuffTypeTexture:SetVertexColor(color.r, color.g, color.b, 0.6)
end
local CreateDebuffIcon = function(parent, w, h, alpha, point, frame, to, x, y)
    local icon = CreateIcon(parent, w,h, alpha, point, frame, to, x, y)

    icon.texture:SetTexCoord(.2, .8, .2, .8)
    
    local dttex = icon:CreateTexture(nil, "ARTWORK")
    dttex:SetTexture("Interface\\Addons\\Aptechka\\white")
    dttex:SetPoint("TOPLEFT", icon, "TOPRIGHT", h-w, 0) -- filling all the space left from icon
    dttex:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT",0,0)
    icon.debuffTypeTexture = dttex

    -- icon:SetBackdrop{
        -- bgFile = "Interface\\Addons\\Aptechka\\white", tile = true, tileSize = 0,
        -- insets = {left = 0, right = -2, top = 0, bottom = 0},
    -- }
    -- icon:SetBackdropColor(0, 0, 0, 1)

    icon.SetJob = SetJob_DebuffIcon

    icon:Hide()

    return icon
end


local SetJob_Text1 = function(self,job)
    if job.healthtext then
        self:SetFormattedText("-%.0fk", (self.parent.vHealthMax - self.parent.vHealth) / 1e3)
    elseif job.nametext then
        self:SetText(self.parent.name)
    elseif job.text then
        self:SetText(job.text)
    end
    local c
    if job.classcolor then
        c = self.parent.classcolor
    elseif job.color then
        c = job.textcolor or job.color
    end
    if c then self:SetTextColor(unpack(c)) end
end
local SetJob_Text2 = function(self,job) -- text2 is always green
    if job.healthtext then
        self:SetFormattedText("-%.0fk", (self.parent.vHealthMax - self.parent.vHealth) / 1e3)
    elseif job.inchealtext then
        self:SetFormattedText("+%.0fk", self.parent.vIncomingHeal / 1e3)
    elseif job.nametext then
        self:SetText(self.parent.name)
    elseif job.text then
        self:SetText(job.text)
    end

    local c
    if job.color then
        c = job.textcolor or job.color
        self:SetTextColor(unpack(c))
    end
end
    local Text3_OnUpdate = function(self,time)
        self.text:SetText(string.format("%.1f",self.text.expirationTime - GetTime()))
    end
    local Text3_HideFunc = function(self)
        self.frame:SetScript("OnUpdate",nil)
        self:Hide()
    end
local SetJob_Text3 = function(self,job) -- text2 is always green
    self.expirationTime = job.expirationTime
    self.frame:SetScript("OnUpdate",Text3_OnUpdate)
    
    local c
    if job.color then
        c = job.color
    end
    self:SetTextColor(unpack(c))
end
local CreateTextTimer = function(parent,point,frame,to,x,y,hjustify,fontsize,font,flags)
    local text3container = CreateFrame("Frame", nil, parent) -- We need frame to create OnUpdate handler for time updates
    local text3 = text3container:CreateFontString(nil, "ARTWORK")
    text3container.text = text3
--~     text3container:Hide()
    text3:SetPoint(point,frame,to,x,y)--"TOPLEFT",self,"TOPLEFT",-2,0)
    text3:SetJustifyH"LEFT"
    text3:SetFont(font, fontsize or 11, flags)
    text3.SetJob = SetJob_Text3
    text3.HideFunc = Text3_HideFunc
    text3.parent = parent
    text3.frame = text3container
    return text3
end
AptechkaDefaultConfig.GridSkin_CreateTextTimer = CreateTextTimer


local SetJob_Border = function(self,job)
    if job.color then
        self:SetBackdropColor(unpack(job.color))
    end
end



local OnMouseEnterFunc = function(self)
    self.mouseover:Show()
end
local OnMouseLeaveFunc = function(self)
    self.mouseover:Hide()
end

AptechkaDefaultConfig.GridSkinSettings = function(self)
    AptechkaDefaultConfig.width = 50
    AptechkaDefaultConfig.height = 50
    AptechkaDefaultConfig.texture = [[Interface\AddOns\Aptechka\gradient]]
    AptechkaDefaultConfig.font = [[Interface\AddOns\Aptechka\ClearFont.ttf]]
    AptechkaDefaultConfig.fontsize = 12
end
AptechkaDefaultConfig.GridSkin = function(self)
    local config
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    
    local texture = config.texture
    local font = config.font
    local fontsize = config.fontsize
    local manabar_width = config.manabarwidth
    
    local backdrop = {
        bgFile = "Interface\\Addons\\Aptechka\\white", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
    
    
    local mot = self:CreateTexture(nil,"OVERLAY")
    mot:SetAllPoints(self)
    mot:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    --mot:SetTexture[[Interface\AddOns\Aptechka\shine]]
    --mot:SetVertexColor(0.7,0.7,1)
    mot:SetBlendMode("ADD")
    mot:Hide()
    self.mouseover = mot
    
        
    local powerbar = CreateFrame("StatusBar", nil, self)
	powerbar:SetWidth(4)
    powerbar:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
    powerbar:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
	powerbar:SetStatusBarTexture(texture)
    powerbar:GetStatusBarTexture():SetDrawLayer("ARTWORK",-2)
    powerbar:SetMinMaxValues(0,100)
    powerbar.parent = self
    powerbar:SetOrientation("VERTICAL")
    powerbar.SetJob = SetJob_HealthBar
    powerbar.OnPowerTypeChange = PowerBar_OnPowerTypeChange
    
    local pbbg = powerbar:CreateTexture(nil,"ARTWORK",nil,-3)
	pbbg:SetAllPoints(powerbar)
	pbbg:SetTexture(texture)
    powerbar.bg = pbbg
    
    
    local hp = CreateFrame("StatusBar", nil, self)
	--hp:SetAllPoints(self)
    hp:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    -- hp:SetPoint("TOPRIGHT",powerbar,"TOPLEFT",0,0)
    hp:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
	hp:SetStatusBarTexture(texture)
    hp:GetStatusBarTexture():SetDrawLayer("ARTWORK",-6)
    hp:SetMinMaxValues(0,100)
    hp:SetOrientation("VERTICAL")
    hp.parent = self
    hp.SetJob = SetJob_HealthBar
    --hp:SetValue(0)


    local absorb = CreateFrame("Frame", nil, self)
    absorb:SetParent(hp)
    -- absorb:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    absorb:SetPoint("TOPLEFT",self,"TOPLEFT",-3,0)
    absorb:SetWidth(3)

    local at = absorb:CreateTexture(nil, "ARTWORK", nil, -4)
    at:SetTexture[[Interface\AddOns\Aptechka\white]]
    at:SetVertexColor(.7, .7, 1, 1)
    at:SetAllPoints(absorb)

    local atbg = absorb:CreateTexture(nil, "ARTWORK", nil, -5)
    atbg:SetTexture[[Interface\AddOns\Aptechka\white]]
    atbg:SetVertexColor(0,0,0,1)
    atbg:SetPoint("TOPLEFT", at, "TOPLEFT", -1,1)
    atbg:SetPoint("BOTTOMRIGHT", at, "BOTTOMRIGHT", 1,-1)

    absorb.maxheight = config.height
    absorb.SetValue = function(self, v)
        local p = v/100
        if p > 1 then p = 1 end
        if p < 0 then p = 0 end
        if p == 0 then self:Hide() else self:Show() end
        self:SetHeight(p*self.maxheight)
    end
    absorb:SetValue(0)
    hp.absorb = absorb

    -- local absorb = CreateFrame("StatusBar", nil, self)
    -- absorb:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    -- absorb:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    -- absorb:SetWidth(1)
    -- -- absorb:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
    -- absorb:SetStatusBarTexture[[Interface\AddOns\Aptechka\white]]  --absorbOverlay]]
    -- absorb:GetStatusBarTexture():SetDrawLayer("ARTWORK",-4)
    -- absorb:SetStatusBarColor(.6, .6, 1)
    -- absorb:SetMinMaxValues(0,100)
    -- absorb:SetOrientation("VERTICAL")
    -- absorb:SetReverseFill(true)
    -- absorb:SetValue(50)
    -- hp.absorb = absorb
    -- self.absorb = absorb

    -- local abg = hp:CreateTexture(nil,"ARTWORK",nil,-5)
    -- abg:SetPoint("BOTTOMLEFT",absorb,"BOTTOMLEFT",0,0)
    -- abg:SetPoint("TOPLEFT",absorb,"TOPLEFT",0,0)
    -- abg:SetWidth(2)
    -- abg:SetTexture("Interface\\Addons\\Aptechka\\gradient")
    -- abg:SetVertexColor(0,0,0, .3)
    -- absorb.bg = abg
    
    local hpbg = hp:CreateTexture(nil,"ARTWORK",nil,-7)
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)
    hp.bg = hpbg

    -- if AptechkaUserConfig.useCombatLogHealthUpdates or AptechkaDefaultConfig.useCombatLogHealthUpdates then
    --     print('p2')
    --     local hp2 = CreateFrame("StatusBar", nil, self)
    --     --hp:SetAllPoints(self)
    --     hp2:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    --     -- hp:SetPoint("TOPRIGHT",powerbar,"TOPLEFT",0,0)
    --     hp2:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    --     hp2:SetWidth(13)
    --     hp2:SetStatusBarTexture(texture)
    --     hp2:GetStatusBarTexture():SetDrawLayer("ARTWORK",-4)
    --     hp2:SetMinMaxValues(0,100)
    --     hp2:SetOrientation("VERTICAL")
    --     hp2.parent = self
    --     hp2.SetJob = SetJob_HealthBar
    --     --hp:SetValue(0)
        
    --     local hp2bg = hp:CreateTexture(nil,"ARTWORK",nil,-5)
    --     hp2bg:SetAllPoints(hp2)
    --     hp2bg:SetTexture(texture)
    --     hp2.bg = hp2bg
    --     self.health2 = hp2
    -- end
    local hpi = CreateFrame("StatusBar", nil, self)
	hpi:SetAllPoints(self)
	hpi:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    hpi:SetOrientation("VERTICAL")
    hpi:SetStatusBarColor(0,0,0,0.3)
    hpi:SetMinMaxValues(0,100)
    --hpi:SetValue(0)
    
    local border = CreateFrame("Frame",nil,self)
    border:SetAllPoints(self)
    border:SetFrameStrata("LOW")
    border:SetBackdrop{
        bgFile = "Interface\\Addons\\Aptechka\\white", tile = true, tileSize = 0,
        insets = {left = -4, right = -4, top = -4, bottom = -4},
    }
    border:SetAlpha(0.5)
    border.SetJob = SetJob_Border
    border:Hide()
    
    local text = hp:CreateFontString(nil, "ARTWORK") --, "GameFontNormal")
    text:SetPoint("CENTER",self,"CENTER",0,0)
    text:SetJustifyH"CENTER"
    text:SetFont(font, fontsize)
    text:SetTextColor(1, 1, 1)
    text:SetShadowColor(0,0,0)
    text:SetShadowOffset(1,-1)
    text.SetJob = SetJob_Text1
    text.parent = self
    
    local text2 = hp:CreateFontString(nil, "ARTWORK")
    text2:SetPoint("TOP",text,"BOTTOM",0,0)
    text2:SetJustifyH"CENTER"
    text2:SetFont(font, fontsize-3)
    text2.SetJob = SetJob_Text2
    text2:SetTextColor(0.2, 1, 0.2)
    text2.parent = self
    
    local icon = CreateIcon(self,24,24,0.4,"CENTER",self,"CENTER",0,0)
    
    local raidicon = CreateFrame("Frame",nil,self)
    raidicon:SetWidth(20); raidicon:SetHeight(20)
    raidicon:SetPoint("CENTER",hp,"TOPLEFT",0,0)
    local raidicontex = raidicon:CreateTexture(nil,"OVERLAY")
    raidicontex:SetAllPoints(raidicon)
    raidicon.texture = raidicontex
    raidicon:SetAlpha(0.3)
    
    local topind = CreateIndicator(self,10,10,"TOP",self,"TOP",0,0)
    local tr = CreateIndicator(self,7,7,"TOPRIGHT",self,"TOPRIGHT",0,0)
    local br = CreateIndicator(self,9,9,"BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
    local btm = CreateIndicator(self,7,7,"BOTTOM",self,"BOTTOM",0,0)
    -- local left = CreateIndicator(self,7,7,"LEFT",self,"LEFT",0,0)
    local tl = CreateIndicator(self,5,5,"TOPLEFT",self,"TOPLEFT",0,0)
    local text3 = CreateTextTimer(self,"TOPLEFT",self,"TOPLEFT",-2,0,"LEFT",fontsize-3,font,"OUTLINE")

    local bar1 = CreateStatusBar(self, 19, 7, "BOTTOMRIGHT",self, "BOTTOMRIGHT",0,0)

    local brcorner = CreateCorner(self, 17, 17, "BOTTOMRIGHT", self, "BOTTOMRIGHT",0,0)

    self.dicon1 = CreateDebuffIcon(self, 14, 11, 1, "BOTTOMLEFT", self, "BOTTOMLEFT",0,0)
    self.dicon2 = CreateDebuffIcon(self, 14, 11, 1, "BOTTOMLEFT", self.dicon1, "TOPLEFT",0,0)
    self.dicon3 = CreateDebuffIcon(self, 14, 11, 1, "BOTTOMLEFT", self.dicon2, "TOPLEFT",0,0)
    
    self.SetJob = SetJob_Frame
    self.HideFunc = Frame_HideFunc
    
    self.health = hp
    self.health.incoming = hpi
    self.text1 = text
    self.text2 = text2
    self.healthtext = self.text2
    self.text3 = text3
    self.power = powerbar
    self.spell1 = br
    self.spell2 = topind
    self.spell3 = tr
    self.spell4 = btm
    self.bar1 = bar1
    self.raidbuff = tl
    self.border = border
    self.bossdebuff = brcorner
    self.dispel = brcorner
    self.icon = icon
    self.raidicon = raidicon
    self.absorb = absorb

    
    self.OnMouseEnterFunc = OnMouseEnterFunc
    self.OnMouseLeaveFunc = OnMouseLeaveFunc
    self.OnDead = OnDead
    self.OnAlive = OnAlive
end

AptechkaDefaultConfig.GridSkinHorizontal = function(self)
    AptechkaDefaultConfig.GridSkin(self)
    self.health:SetOrientation("HORIZONTAL")
    self.health.incoming:SetOrientation("HORIZONTAL")
    self.power:SetOrientation("HORIZONTAL")
    
    self.power:ClearAllPoints()
    self.power:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    self.power:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
    self.power:SetHeight(5)
    self.power:SetWidth(0)
    
    local PowerBar_OnPowerTypeChange = function(self, powertype)
        local self = self.parent
        if powertype ~= "MANA" then
            self.power.disabled = true
            self.power:Hide()
        else
            self.power.disabled = nil
            self.power:Show()
        end
    end
    self.power.OnPowerTypeChange = PowerBar_OnPowerTypeChange
end


--~ AptechkaDefaultConfig.GridSkinInverted = function(self)  -- oooh, it looks like shit
--~     AptechkaDefaultConfig.GridSkin(self)
--~     AptechkaDefaultConfig.useAnchors = "GridSkin" -- use parent skin anchors
--~     local newSetJob_HealthBar = function(self, job)
--~         local c
--~         if job.classcolor then
--~             c = self.parent.classcolor
--~         elseif job.color then
--~             c = job.color
--~         end
--~         if c then
--~             self:SetStatusBarColor(unpack(c))
--~             self.bg:SetVertexColor(c[1]/3,c[2]/3,c[3]/3)
--~         end
--~     end
--~     self.health.SetJob = newSetJob_HealthBar
--~     self.power.SetJob = newSetJob_HealthBar
--~ end