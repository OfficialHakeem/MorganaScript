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
local Enums, EventManager, Renderer, Evade = Core.Enums, Core.EventManager, Core.Renderer, Core.EvadeAPI

local SpellSlots, Spell, HitChance, DamageLib, PerksIds, DashLib, ImmobileLib, BuffType = Enums.SpellSlots, Libs.Spell,
    Enums.HitChance, Libs.DamageLib, Enums.PerkIDs, Libs.DashLib, Libs.ImmobileLib, Enums.BuffTypes
local TS, Menu, Orbwalker, Prediction = Libs.TargetSelector(), Libs.NewMenu, Libs.Orbwalker, Libs.Prediction
local Events, ObjectManager = Enums.Events, Core.ObjectManager
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
        }),
        _E = Spell.Targeted({
            Slot = Enums.SpellSlots.E,
            Range = 800
        })

    },
    hasScepter = false
}

--------------------------------------------------------------------------------
--- Credits to Shulepin, for debuff data and Menu for CC <3 Thanks bro.
--- Credits to me for modify and advance this data <3 :))
--------------------------------------------------------------------------------

local DebuffData = {
    Ahri = {{
        MenuName = 'ahriseducedoom',
        Type = BuffType.Charm,
        Slot = SpellSlots.E
    }},
    Amumu = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }, {
        MenuName = 'CurseoftheSadMummy',
        Type = BuffType.Snare,
        Slot = SpellSlots.R
    }},
    Anivia = {{
        MenuName = 'aniviaiced',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }},
    Annie = {{
        MenuName = 'anniepassivestun',
        Type = BuffType.Stun,
        Slot = -1
    }},
    Alistar = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }, {
        MenuName = 'Knockback',
        Type = BuffType.Knockback,
        Slot = SpellSlots.W
    }, {
        MenuName = 'Knockup',
        Type = BuffType.Knockup,
        Slot = SpellSlots.Q
    }},
    Ashe = {{
        MenuName = 'AsheR',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    AurelionSol = {{
        MenuName = 'aurelionsolqstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }},
    Bard = {{
        MenuName = 'BardQSchacleDebuff',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }},
    Blitzcrank = {{
        MenuName = 'Silence',
        Type = BuffType.Silence,
        Slot = SpellSlots.R
    }},
    Brand = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }},
    Braum = {{
        MenuName = 'braumstundebuff',
        Type = BuffType.Stun,
        Slot = -1
    }},
    Caitlyn = {{
        MenuName = 'caitlynyordletrapdebuff',
        Type = BuffType.Snare,
        Slot = SpellSlots.W
    }},
    Camille = {{
        MenuName = 'camilleestun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Cassiopeia = {{
        MenuName = 'CassiopeiaRStun',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Chogath = {{
        MenuName = 'Silence',
        Type = BuffType.Silence,
        Slot = SpellSlots.W
    }},
    Ekko = {{
        MenuName = 'ekkowstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Elise = {{
        MenuName = 'EliseHumanE',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Evelynn = {{
        MenuName = 'Charm',
        Type = BuffType.Charm,
        Slot = SpellSlots.W
    }},
    FiddleSticks = {{
        MenuName = 'Flee',
        Type = BuffType.Flee,
        Slot = SpellSlots.Q
    }, {
        MenuName = 'DarkWind',
        Type = BuffType.Silence,
        Slot = SpellSlots.E
    }},
    Fiora = {{
        MenuName = 'fiorawstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Galio = {{
        MenuName = 'Taunt',
        Type = BuffType.Taunt,
        Slot = SpellSlots.W
    }},
    Garen = {{
        MenuName = 'Silence',
        Type = BuffType.Silence,
        Slot = SpellSlots.Q
    }},
    Gnar = {{
        MenuName = 'gnarstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }, {
        MenuName = 'gnarknockbackcc',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Hecarim = {{
        MenuName = 'HecarimUltMissileGrab',
        Type = BuffType.Flee,
        Slot = SpellSlots.R
    }},
    Heimerdinger = {{
        MenuName = 'HeimerdingerESpell',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }, {
        MenuName = 'HeimerdingerESpell_ult',
        Type = BuffType.Stun,
        Slot = SpellSlots.E,
        Display = 'Enchanted E'
    }},
    Irelia = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Ivern = {{
        MenuName = 'IvernQ',
        Type = BuffType.Snare,
        Slot = SpellSlots.Q
    }},
    Jax = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Jhin = {{
        MenuName = 'JhinW',
        Type = BuffType.Snare,
        Slot = SpellSlots.W
    }},
    Jinx = {{
        MenuName = 'JinxEMineSnare',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }},
    Karma = {{
        MenuName = 'karmaspiritbindroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.W
    }},
    Kennen = {{
        MenuName = 'KennenMoSDiminish',
        Type = BuffType.Stun,
        Slot = -1
    }},
    Leblanc = {{
        MenuName = 'leblanceroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }, {
        MenuName = 'leblancreroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.E,
        Display = 'Enchanted E'
    }},
    Leona = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }},
    Lissandra = {{
        MenuName = 'LissandraWFrozen',
        Type = BuffType.Snare,
        Slot = SpellSlots.W
    }, {
        MenuName = 'LissandraREnemy2',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Lulu = {{
        MenuName = 'LuluWTwo',
        Type = BuffType.Polymorph,
        Slot = SpellSlots.W
    }},
    Lux = {{
        MenuName = 'LuxLightBindingMis',
        Type = BuffType.Snare,
        Slot = SpellSlots.Q
    }},
    Malzahar = {{
        MenuName = 'MalzaharQMissile',
        Type = BuffType.Silence,
        Slot = SpellSlots.Q
    }, {
        MenuName = 'MalzaharR',
        Type = BuffType.Suppression,
        Slot = SpellSlots.R
    }},
    Maokai = {{
        MenuName = 'maokaiwroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.W
    }, {
        MenuName = 'maokairroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.R
    }},
    Mordekaiser = {{
        MenuName = 'MordekaiserR',
        Type = BuffType.CombatDehancer,
        Slot = SpellSlots.R
    }},
    Morgana = {{
        MenuName = 'MorganaQ',
        Type = BuffType.Snare,
        Slot = SpellSlots.Q
    }, {
        MenuName = 'morganarstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Nami = {{
        MenuName = 'NamiQDebuff',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }},
    Nasus = {{
        MenuName = 'NasusW',
        Type = BuffType.Slow,
        Slot = SpellSlots.W
    }},
    Nautilus = {{
        MenuName = 'nautiluspassiveroot',
        Type = BuffType.Stun,
        Slot = -1
    }, {
        MenuName = 'nautilusanchordragroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.R
    }},
    Neeko = {{
        MenuName = 'neekoeroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }, {
        MenuName = 'neekorstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Nocture = {{
        MenuName = 'Flee',
        Type = BuffType.Flee,
        Slot = SpellSlots.E
    }},
    Nunu = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Pantheon = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Pyke = {{
        MenuName = 'PykeEMissile',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Qiyana = {{
        MenuName = 'qiyanarstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }, {
        MenuName = 'qiyanaqroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.Q
    }},
    Rakan = {{
        MenuName = 'rakanrdebuff',
        Type = BuffType.Charm,
        Slot = SpellSlots.R
    }},
    Rammus = {{
        MenuName = 'Taunt',
        Type = BuffType.Taunt,
        Slot = SpellSlots.E
    }},
    Renekton = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Rengar = {{
        MenuName = 'RengarEEmp',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }},
    Riven = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Ryze = {{
        MenuName = 'RyzeW',
        Type = BuffType.Snare,
        Slot = SpellSlots.W
    }},
    Sejuani = {{
        MenuName = 'sejuanistun',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Shaco = {{
        MenuName = 'shacoboxsnare',
        Type = BuffType.Snare,
        Slot = SpellSlots.W
    }},
    Shen = {{
        MenuName = 'Taunt',
        Type = BuffType.Taunt,
        Slot = SpellSlots.E
    }},
    Skarner = {{
        MenuName = 'skarnerpassivestun',
        Type = BuffType.Stun,
        Slot = -1
    }, {
        MenuName = 'suppression',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Sona = {{
        MenuName = 'SonaR',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Soraka = {{
        MenuName = 'sorakaesnare',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }},
    Sylas = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Swain = {{
        MenuName = 'swaineroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }},
    Syndra = {{
        MenuName = 'syndraebump',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    TahmKench = {{
        MenuName = 'tahmkenchqstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }, {
        MenuName = 'tahmkenchwdevoured',
        Type = BuffType.Suppression,
        Slot = SpellSlots.W
    }},
    Taric = {{
        MenuName = 'taricestun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Teemo = {{
        MenuName = 'BlindingDart',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }},
    Thresh = {{
        MenuName = 'threshqfakeknockup',
        Type = BuffType.Knockup,
        Slot = SpellSlots.Q
    }, {
        MenuName = 'threshrslow',
        Type = BuffType.Slow,
        Slot = SpellSlots.R
    }},
    Tryndamere = {{
        MenuName = 'tryndamerewslow',
        Type = BuffType.Slow,
        Slot = SpellSlots.W
    }},
    TwistedFate = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Udyr = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Urgot = {{
        MenuName = 'urgotrfear',
        Type = BuffType.Fear,
        Slot = SpellSlots.R
    }},
    Varus = {{
        MenuName = 'varusrroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.R
    }},
    Vayne = {{
        MenuName = 'VayneCondemnMissile',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Veigar = {{
        MenuName = 'veigareventhorizonstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Viktor = {{
        MenuName = 'viktorgravitonfieldstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }, {
        MenuName = 'viktorwaugstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Warwick = {{
        MenuName = 'Flee',
        Type = BuffType.Flee,
        Slot = SpellSlots.E
    }, {
        MenuName = 'suppression',
        Type = BuffType.Suppression,
        Slot = SpellSlots.R
    }},
    Xayah = {{
        MenuName = 'XayahE',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }},
    Xerath = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Yuumi = {{
        MenuName = 'yuumircc',
        Type = BuffType.Snare,
        Slot = SpellSlots.R
    }},
    Yasuo = {{
        MenuName = 'yasuorknockup',
        Type = BuffType.Knockup,
        Slot = SpellSlots.R
    }},
    Zac = {{
        MenuName = 'zacqyankroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.Q
    }, {
        MenuName = 'zachitstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Zilean = {{
        MenuName = 'ZileanStunAnim',
        Type = BuffType.Stun,
        Slot = SpellSlots.Q
    }, {
        MenuName = 'timewarpslow',
        Type = BuffType.Slow,
        Slot = SpellSlots.E
    }},
    Zoe = {{
        MenuName = 'zoeesleepstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Zyra = {{
        MenuName = 'zyraehold',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }},
    Senna = {{
        MenuName = 'sennawroot',
        Type = BuffType.Snare,
        Slot = SpellSlots.W
    }},
    Lillia = {{
        MenuName = 'LilliaRSleep',
        Type = BuffType.Drowsy,
        Slot = SpellSlots.R
    }},
    Sett = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Yone = {{
        MenuName = 'yonerstun',
        Type = BuffType.Stun,
        Slot = SpellSlots.R
    }},
    Viego = {{
        MenuName = 'ViegoWMis',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Sylas = {{
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Seraphine = {{
        MenuName = 'SeraphineERoot',
        Type = BuffType.Snare,
        Slot = SpellSlots.E
    }, {
        MenuName = 'seraphineestun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }},
    Rell = {{
        MenuName = 'rellestun',
        Type = BuffType.Stun,
        Slot = SpellSlots.E
    }, {
        MenuName = 'Stun',
        Type = BuffType.Stun,
        Slot = SpellSlots.W
    }},
    Aphelios = {{
        MenuName = 'ApheliosGravitumRoot',
        Type = BuffType.Snare,
        Slot = SpellSlots.Q
    }}
}

local SlotToString = {
    [-1] = "Passive",
    [SpellSlots.Q] = "Q",
    [SpellSlots.W] = "W",
    [SpellSlots.E] = "E",
    [SpellSlots.R] = "R"
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
-- this function will update data and add Name Values in skills for better use
local function BuffDataUpdater()
    for _, hero in pairs(ObjectManager.Get("enemy", "heroes")) do
        local charName = hero.CharName
        if DebuffData[charName] then
            for _, buffData in pairs(DebuffData[charName]) do
                buffData.Name = hero.AsHero:GetSpell(buffData.Slot).Name
                buffData.CastRadius = hero.AsHero:GetSpell(buffData.Slot).CastRadius
            end
        end
    end

end
function IsInRange(From, To, Min, Max)
    -- Is Target in range
    local Distance = From:Distance(To)
    return Distance > Min and Distance <= Max
end

--------------------------------------------------------------------------------
--- Extract Local Variables
--------------------------------------------------------------------------------
local _Q, _W, _E = Morgana.Spells._Q, Morgana.Spells._W, Morgana.Spells._E
--------------------------------------------------------------------------------
--- Init Menu
--------------------------------------------------------------------------------
local function InitMenu()
    local pinkColor = 0xCD44F7FF
    local greenColor = 0x44F7B1FF
    Menu.RegisterMenu("Morgana Koexygen", "Morgana Koexygen", function()
        Menu.ColumnLayout("cols", "cols", 2, true, function()
            Menu.ColoredText("Combo", pinkColor, true)
            Menu.Checkbox("Q.Combo", "Use [Q]", true)
            Menu.Checkbox("W.Combo", "Use [W]", true)
            Menu.Checkbox("E.Combo", "Use [E]", true)

            Menu.NextColumn()

            Menu.ColoredText("Harass", pinkColor, true)
            Menu.Checkbox("Harass.Q", "Use [Q]", true)
        end)

        Menu.Separator()

        Menu.ColoredText("Automatic Options", pinkColor, true)
        Menu.Checkbox("Q.Auto.Hit", "Auto [Q] If high hit chance", true)
        Menu.Checkbox("W.Auto.Hit", "Auto [W] If high hit chance", true)
        Menu.Checkbox("E.Auto.Use", "Auto [E] Smart Use", true)
        -- Menu.NewTree("EautoWhiteList", "[E] Whitelist", function()
        --     for _, Object in pairs(ObjectManager.Get("enemy", "heroes")) do
        --         local enemy = Object.AsAI
        --         local spell = enemy:GetSpell(SpellSlots.E)
        --         Menu.Checkbox("RC" .. enemy.Name, "Use [R] for " .. spell.Name, true)
        --     end
        -- end)
        Menu.NewTree("Morgana.E.CC", "CC List", function()
            for _, hero in pairs(ObjectManager.Get("enemy", "heroes")) do
                local charName = hero.CharName
                if DebuffData[charName] then
                    for _, buffData in pairs(DebuffData[charName]) do
                        local id = "Morgana.E.CC." .. charName .. "." .. buffData.MenuName
                        local name = charName .. " | " .. SlotToString[buffData.Slot] .. " | " .. buffData.MenuName
                        Menu.Checkbox(id, name, true)
                    end
                end
            end
        end)

        Menu.Text("")

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
            Menu.Checkbox("Draw.E", "Draw [E] Range", true)
            Menu.ColorPicker("Draw.E.Color", "Draw [E] Color", greenColor)

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

    self.autoE = Menu.Get("E.Auto.Use")
    _E.eDraw = Menu.Get("Draw.E")
    _E.eDrawColor = Menu.Get("Draw.E.Color")
    self.comboE = Menu.Get("E.Combo")

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

    return self:CastOnHitChance(target, self.MenuHitChance)
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

-- function _E:Auto()
--     local getAllies = ObjectManager.GetNearby("ally", "heroes")
--     local getEnemies = TS:GetTargets(_Q.Range)
--     if not Morgana.autoE or #getAllies < 1 or not self:IsLearned() or not self:IsReady() then
--         return
--     end

--     for i = 1, #getEnemies do
--         local enemy = getEnemies[i]

--         if enemy.IsDead or enemy.IsInvulnerable then
--             goto continue
--         end
--         -- DEBUG(tostring(enemy:GetSpell(SpellSlot.Q).Level))

--         local ActiveSpell = enemy.ActiveSpell

--         if ActiveSpell and not ActiveSpell.IsBasicAttack then
--             DEBUG("Getting hero and setting")
--             local hero = ActiveSpell.Target.AsHero
--             DEBUG(tostring(enemy.ActiveSpell.Target.Position))

--             self:Cast(hero)
--         end

--         ::continue::
--     end
-- end

function _E:Auto(tick)
    if not self.IsReady then
        return
    end

    local DetectedSkillshots = {}
    DetectedSkillshots = Evade.GetDetectedSkillshots()

    for k, v in ipairs(ObjectManager.GetNearby("ally", "heroes")) do
        -- DEBUG(v.Name)
        for i, p in ipairs(DetectedSkillshots) do

            DEBUG("DEBUGING FROM INSIDE")
            if p:IsAboutToHit(1, v.Position) then
                self:Cast(v)
            end
        end

    end

    -- DEBUG("got " .. #enemies .. " Enemys")
end

--------------------------------------------------------------------------------
--- Combat Logic
--------------------------------------------------------------------------------
function Morgana:Combat(tick)

    if self.autoQ then
        _Q:Auto()
    end

    if self.autoW then
        _W:Auto()
    end

    if self.autoE then
        _E:Auto(tick)
    end

    if self.OrbMode == "nil" then
        return
    end

    if self.hasScepter then
        if tick == 1 then
            _W:Logic()
        elseif tick == 2 then
            _Q:Logic()
        end
    else
        if tick == 1 then
            _W:Logic()
        elseif tick == 2 then
            _Q:Logic()
        end
    end
end
--------------------------------------------------------------------------------
--- OnUpdate 60 FPS
--------------------------------------------------------------------------------
local ticker = 0
local detectedSkills = {}

function Koexygen.OnUpdate(tick)
    Morgana.OrbMode = Orbwalker:GetMode()
    Morgana:Combat(tick)

    if ticker == 5 then
        Morgana:CheckSettings()
        ticker = 0
    end

    ticker = ticker + 1
end
--------------------------------------------------------------------------------
--- OnTick 30 FPS
--------------------------------------------------------------------------------
-- local ticker = 0
function Koexygen.OnTick(tick)
    -- Morgana.OrbMode = Orbwalker:GetMode()
    -- Morgana:Combat(tick)

    -- if ticker == 20 then
    --     Morgana:CheckSettings()
    --     ticker = 0
    -- end

    -- ticker = ticker + 1

end
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

function _E:Drawing()
    if self.eDraw then
        Renderer.DrawCircle3D(Player.Position, self.Range, 1, 1, self.eDrawColor)
    end
end

function Koexygen:OnDraw()
    if Player.IsDead or not Player.IsOnScreen then
        return
    end

    _Q:Drawing()
    _W:Drawing()
    _E:Drawing()
end

--------------------------------------------------------------------------------
--- Init Script " Koexygen Morgana"
--------------------------------------------------------------------------------
local function BeginKoexygen()
    InitMenu()
    BuffDataUpdater()

    for eventName, eventId in pairs(Enums.Events) do
        if Koexygen[eventName] then
            EventManager.RegisterCallback(eventId, Koexygen[eventName])
        end
    end

    return true
end

BeginKoexygen()
--------------------------------------------------------------------------------
--- The end, Happy Scripting : )
--------------------------------------------------------------------------------

