--------------------------------------------------------------------------------
-- sDKP (c) 2011 by Siarkowy
-- Released under the terms of GNU GPL v3 license.
--------------------------------------------------------------------------------

sDKP = {
    name    = "sDKP",
    author  = GetAddOnMetadata("sDKP", "Author"),
    version = GetAddOnMetadata("sDKP", "Version"),
    frame   = CreateFrame("Frame", "sDKP_Frame"),
    player  = UnitName("player"),

    Class   = {},   -- object prototypes
    Comms   = {},   -- comm message handlers
    LogData = {},   -- operations' log
    Options = {},   -- options database
    Roster  = {},   -- guild roster data
    Versions = {}   -- guild mates' versions
}

local sDKP = sDKP

local format = format
local select = select
local setmetatable = setmetatable
local tostring = tostring

-- Event handlers --------------------------------------------------------------

local DB_VERSION = 20140208

function sDKP:VARIABLES_LOADED()
    self:UnregisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("GUILD_ROSTER_UPDATE")
    self:RegisterEvent("PLAYER_GUILD_UPDATE")

    -- database management
    sDKP_DB = sDKP_DB and sDKP_DB.Version == DB_VERSION and sDKP_DB or
    self:Print("Database initialised.") or {
        Externals = { --[[ char = main, ... ]] },       -- out of guild aliases
        Rosters = { --[[ guild = { char = data, ... }, ... ]] },
        Options = {
            -- Chat
            ["chat.ignoredids"] = {                     -- ignored item IDs
                [29434] = true, -- Badge of Justice
            },
            ["chat.nolootlinks"] = false,               -- toggle loot charge links
            ["chat.rarity"] = 4, -- epic                -- min. item quality to show links

            -- Core
            ["core.diff"] = true,                       -- enable verbose diff
            ["core.format"] = "Net:%n Tot:%t Hrs:%h",   -- DKP note format
            ["core.noginfo"] = false,                   -- ignore ginfo note format
            ["core.whispers"] = true,                   -- toggle whisper announce

            -- Log
            ["log.rarity"] = 4, -- epic                 -- min. item quality
        },

        -- database version
        Version = DB_VERSION
    }

    self.DB         = sDKP_DB
    self.Externals  = sDKP_DB.Externals
    self.Options    = sDKP_DB.Options

    self:PLAYER_GUILD_UPDATE("player")
    self:Reconfigure()
    self:CommSend("HI")
    self.VARIABLES_LOADED = nil
end

-- Utilities -------------------------------------------------------------------

local prompt = format("|cff56a3ff%s:|r ", sDKP.name)

function sDKP:Print(s, ...) DEFAULT_CHAT_FRAME:AddMessage(prompt .. tostring(s), ...) end
function sDKP:Printf(...) DEFAULT_CHAT_FRAME:AddMessage(prompt .. format(...)) end
function sDKP:Echo(...) DEFAULT_CHAT_FRAME:AddMessage(format(...)) end

local frame = sDKP.frame

function sDKP:RegisterEvent(e) frame:RegisterEvent(e) end
function sDKP:UnregisterEvent(e) frame:UnregisterEvent(e) end

-- Class management ------------------------------------------------------------

local Class = sDKP.Class

--- Checks whether object is of given class.
-- @param o (table) Tested object.
-- @param class (string) Class name.
-- @return boolean - Comparison result.
function sDKP:IsClass(o, class)
    assert(o, "Object required.")
    return getmetatable(o) == (class and Class[class].__meta or nil)
end

--- Binds object to given class.
-- @param o (table|nil) Object to bind or nil to create new.
-- @param class (string) Class name.
-- @result table - Object of specified class.
function sDKP:BindClass(o, class)
    return setmetatable(o or new(), class and Class[class].__meta or nil), true
end

-- Initialization --------------------------------------------------------------

function sDKP:Init()
    frame:SetScript("OnEvent", function(frame, event, ...)
        self[event](self, ...)
    end)

    self:RegisterEvent("VARIABLES_LOADED")
    self:Printf("Version %s enabled. Usage: /sdkp", self.version)
end

sDKP:Init()
