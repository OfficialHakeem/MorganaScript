local Player = Player
if Player.CharName ~= "Morgana" then
    return
end

module("Koexygens Morgana", package.seeall, log.setup)
clean.module("Koexygens Morgana", clean.seeall, log.setup)

--------------------------------------------------------------------------------
--- General Definition
--------------------------------------------------------------------------------
local Core, Libs = _G.CoreEx, _G.Libs
local Enums, EventManager, Renderer = Core.Enums, Core.EventManager, Core.Renderer

local SpellSlot, Spell, HitChance, DamageLib, PerksIds, DashLib, ImmobileLib = Enums.SpellSlots, Libs.Spell,
    Enums.HitChance, Libs.DamageLib, Enums.PerkIDs, Libs.DashLib, Libs.ImmobileLib
local TS, Menu, Orbwalker, Prediction = Libs.TargetSelector(), Libs.NewMenu, Libs.Orbwalker, Libs.Prediction
local Events = Enums.Events
local Vector = Core.Geometry.Vector
local insert, sort = table.insert, table.sort

local Koexygen = {}

local Morgana = {
    Spells = {
        _Q = Spell.Skillshot({
            Slot = Enums.SpellSlots.Q,
            Range = 1300,
            Radius = 60,
            Delay = 0.25,
            Speed = 1200,
            Collisions = {
                Heroes = true,
                Minions = true,
                WindWall = true
            },
            MaxCollisions = 1,
            Type = "Linear",
            UseHitbox = true
        }),
        _W = Spell.Skillshot({
            Slot = Enums.SpellSlots.W,
            Range = 900,
            Radius = 275,
            Delay = 0.25,
            Type = "Circular"
        })

    },
    hasScepter = false
}

--------------------------------------------------------------------------------
--- Koexygen Helper functions
--------------------------------------------------------------------------------
local function castOnDash(dashInstance, spell)
    local castPos = dashInstance:Prediction(Player.Position, spell.Speed, spell.Delay, spell.Radius, spell.UsetHitbox)

    if castPos then
        spell:Cast(castPos)
    end
end

local function isImmobile(unit)
    local immobile = ImmobileLib.GetImmobileTimeLeft(unit)
    if immobile > 0 then

        return true
    end
    return false
end

local function hasItem(itemId)
    for _, item in ipairs(Player.Items) do
        if item.ItemId == itemId then
            return true
        end
    end
    return false
end
--------------------------------------------------------------------------------
--- Extract Local Variables
--------------------------------------------------------------------------------
local _Q, _W = Morgana.Spells._Q, Morgana.Spells._W
--------------------------------------------------------------------------------
--- Init Menu
--------------------------------------------------------------------------------
local function InitMenu()
    local pinkColor = 0xCD44F7FF
    Menu.RegisterMenu("Morgana Koexygen", "Morgana Koexygen", function()
        Menu.ColumnLayout("cols", "cols", 2, true, function()
            Menu.ColoredText("Combo", pinkColor, true)
            Menu.Checkbox("Q.Combo", "Use [Q]", true)
            Menu.Checkbox("W.Combo", "Use [W]", true)

            Menu.NextColumn()

            Menu.ColoredText("Harass", pinkColor, true)
            Menu.Checkbox("Harass.Q", "Use [Q]", true)
        end)

        Menu.Separator()

        Menu.ColoredText("Automatic Options", pinkColor, true)
        Menu.Checkbox("Q.Auto.Hit", "Auto [Q] If high hit chance", true)
        Menu.Checkbox("W.Auto.Hit", "Auto [W] If high hit chance", true)

        Menu.Separator()
        Menu.ColoredText("Config", pinkColor, true)
        Menu.NewTree("ConfigQ", "[Q] Settings", function()

            Menu.Slider("Combo.Q.HitChance", "HitChance %", 35, 1, 100, 1)

        end)

        Menu.Separator()

        Menu.ColoredText("Drawing Options", pinkColor, true)
        Menu.ColumnLayout("colsQ", "colsQ", 2, true, function()
            Menu.ColoredText("Drawing Skills", pinkColor, true)
            Menu.Checkbox("Draw.Q", "Draw [Q] Range", true)
            Menu.ColorPicker("Draw.Q.Color", "Draw [Q] Color", pinkColor)
            Menu.Checkbox("Draw.W", "Draw [W] Range", true)
            Menu.ColorPicker("Draw.W.Color", "Draw [W] Color", pinkColor)

            Menu.NextColumn()

            Menu.ColoredText("Drawing Skills Utils", pinkColor, true)
        end)

    end)
end
--------------------------------------------------------------------------------
--- Checkings
--------------------------------------------------------------------------------
local itemCheckCount = 0
function Morgana:CheckSettings()
    self.useQcombo = Menu.Get("Q.Combo")
    self.autoQ = Menu.Get("Q.Auto.Hit")
    _Q.MenuHitChance = Menu.Get("Combo.Q.HitChance") / 100
    _Q.qDraw = Menu.Get("Draw.Q")
    _Q.qDrawColor = Menu.Get("Draw.Q.Color")

    self.useWcombo = Menu.Get("W.Combo")
    self.autoW = Menu.Get("W.Auto.Hit")
    _W.wDraw = Menu.Get("Draw.W")
    _W.wDrawColor = Menu.Get("Draw.W.Color")

    if itemCheckCount == 10 then
        itemCheckCount = 0
        self.hasScepter = hasItem(3116)
    end
    itemCheckCount = itemCheckCount + 1
end
--------------------------------------------------------------------------------
--- Q Skill Logic
--------------------------------------------------------------------------------
function _Q:Logic()
    local target = TS:GetTarget(self.Range)
    if not Morgana.useQcombo or not target or not self:IsLearned() or not self:IsReady() then
        return
    end

    self:CastOnHitChance(target, self.MenuHitChance)
end

function _Q:Auto()
    local targets = TS:GetTargets(self.Range)
    if not Morgana.autoQ or #targets < 1 or not self:IsLearned() or not self:IsReady() then
        return
    end

    for i = 1, #targets do
        local target = targets[i]
        local dashInstance = DashLib.GetDash(target)

        if dashInstance then
            return castOnDash(dashInstance, self)
        end

        if isImmobile(target) or target.IsSlowed then
            return self:CastOnHitChance(target, Enums.HitChance.Medium)
        end
    end

end

function _W:Logic()
    local target = TS:GetTarget(self.Range)

    if not Morgana.useWcombo or not target or not self:IsLearned() or not self:IsReady() then
        return
    end

    return self:Cast(target)
end

function _W:Auto()
    local targets = TS:GetTargets(self.Range)
    if not Morgana.autoW or #targets < 1 or not self:IsLearned() or not self:IsReady() then
        return
    end

    for i = 1, #targets do
        local target = targets[i]
        if isImmobile(target) or target.IsSlowed then
            return self:Cast(target)
        end

        if self:CastIfWillHit(2) then
            return
        end
    end

end
--------------------------------------------------------------------------------
--- Combat Logic
--------------------------------------------------------------------------------
function Morgana:Combat()
    if self.autoQ then
        _Q:Auto()
    end

    if self.autoW then
        _W:Auto()
    end

    if self.OrbMode == "nil" then
        return
    end

    if self.hasScepter then
        _W:Logic()
        _Q:Logic()
    else
        _Q:Logic()
        _W:Logic()
    end
end
--------------------------------------------------------------------------------
--- OnUpdate 60 FPS
--------------------------------------------------------------------------------
function Koexygen.OnUpdate(tick)
    Morgana:Combat()
end
--------------------------------------------------------------------------------
--- OnTick 30 FPS
--------------------------------------------------------------------------------
local ticker = 0
function Koexygen.OnTick(tick)
    Morgana.OrbMode = Orbwalker:GetMode()

    if ticker == 20 then
        Morgana:CheckSettings()
        ticker = 0
    end

    ticker = ticker + 1
end
--------------------------------------------------------------------------------
--- Perks Calculation
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--- Drawings
--------------------------------------------------------------------------------
function _Q:Drawing()
    if self.qDraw then
        Renderer.DrawCircle3D(Player.Position, self.Range, 1, 3, self.qDrawColor)
    end
end
function _W:Drawing()
    if self.wDraw then
        Renderer.DrawCircle3D(Player.Position, self.Range, 1, 1, self.wDrawColor)
    end

end

function Koexygen:OnDraw()
    if Player.IsDead or not Player.IsOnScreen then
        return
    end

    _Q:Drawing()
    _W:Drawing()
end

--------------------------------------------------------------------------------
--- Init Script " Koexygen Morgana"
--------------------------------------------------------------------------------
local function BeginKoexygen()
    InitMenu()

    for eventName, eventId in pairs(Enums.Events) do
        if Koexygen[eventName] then
            EventManager.RegisterCallback(eventId, Koexygen[eventName])
        end
    end

    return true
end

function Koexygen.OnLoad()

end

BeginKoexygen()
--------------------------------------------------------------------------------
--- The end, Happy Scripting : )
--------------------------------------------------------------------------------

