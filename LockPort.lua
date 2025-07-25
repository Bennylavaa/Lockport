local LockPortOptions_DefaultSettings = {
    sound = "Sound\\Creature\\Necromancer\\NecromancerReady1.wav",
    whisperMessage = "Summoning you to %zone - %subzone",
    sayMessage = "Summoning %name to %zone - %subzone [%shards]",
    ignoreList = {},
}

local SOUND_OPTIONS = {
    {name = "None", path = ""},
    {name = "Necromancer Ready", path = "Sound\\Creature\\Necromancer\\NecromancerReady1.wav"},
    {name = "Bell Toll", path = "Sound\\Doodad\\BellTollNightElf.wav"},
    {name = "Auction House", path = "Sound\\Interface\\AuctionWindowOpen.wav"},
    {name = "Map Ping", path = "Sound\\Interface\\MapPing.wav"},
    {name = "Level Up", path = "Sound\\Interface\\LevelUp.wav"},
    {name = "Whisper", path = "Sound\\Interface\\iTellMessage.wav"},
    {name = "Ready Check", path = "Sound\\Interface\\ReadyCheck.wav"},
    {name = "PvP Flag", path = "Sound\\Spells\\PVPFlagTaken.wav"},
    {name = "Goat Scream", path = "Interface\\AddOns\\LockPort\\sounds\\screaming-goat.mp3"},
}

LP = LP or {}

function LP:SpellName(spellID)
    local name = GetSpellInfo(spellID)
    return name or "Ritual of Summoning"
end

local function CreateInterfaceOptionsPanel()
    local panel = CreateFrame("Frame", "LockPortOptionsPanel", UIParent)
    panel.name = "LockPort"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r Settings")

    local soundLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    soundLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -25)
    soundLabel:SetText("Summon Request Sound:")

    local soundDropdown = CreateFrame("Frame", "LockPort_SoundDropdown", panel, "UIDropDownMenuTemplate")
    soundDropdown:SetPoint("TOPLEFT", soundLabel, "BOTTOMLEFT", -15, -5)
    soundDropdown:SetWidth(200)

    UIDropDownMenu_SetWidth(soundDropdown, 180)
    UIDropDownMenu_SetText(soundDropdown, "Necromancer Ready")

    local function SoundDropdown_OnClick(self)
        UIDropDownMenu_SetSelectedValue(soundDropdown, self.value)
        UIDropDownMenu_SetText(soundDropdown, self:GetText())
        LockPortOptions.sound = self.value
        CloseDropDownMenus()
    end

    local function SoundDropdown_Initialize()
        local info = UIDropDownMenu_CreateInfo()
        local selectedValue = UIDropDownMenu_GetSelectedValue(soundDropdown)

        for i, soundOption in ipairs(SOUND_OPTIONS) do
            info.text = soundOption.name
            info.value = soundOption.path
            info.func = SoundDropdown_OnClick
            info.checked = (soundOption.path == selectedValue)
            info.keepShownOnClick = false
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(soundDropdown, SoundDropdown_Initialize)

    local testSoundButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testSoundButton:SetPoint("LEFT", soundDropdown, "RIGHT", 10, 2)
    testSoundButton:SetSize(60, 22)
    testSoundButton:SetText("Test")
    testSoundButton:SetScript("OnClick", function()
        local selectedSound = UIDropDownMenu_GetSelectedValue(soundDropdown)
        if selectedSound and selectedSound ~= "" then
            PlaySoundFile(selectedSound)
        end
    end)

    local variableHelpTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    variableHelpTitle:SetPoint("TOPLEFT", soundDropdown, "BOTTOMLEFT", 15, -5)
    variableHelpTitle:SetText("Available Variables: ")
    variableHelpTitle:SetTextColor(0.7, 0.7, 0.7)

    local variableHelp = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    variableHelp:SetPoint("TOPLEFT", variableHelpTitle, "BOTTOMLEFT", 0, -5)
    variableHelp:SetText("%name %class %race %zone %subzone %myname %shards")
    variableHelp:SetTextColor(0.7, 0.7, 0.7)

    local whisperLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    whisperLabel:SetPoint("TOPLEFT", variableHelpTitle, "BOTTOMLEFT", 0, -25)
    whisperLabel:SetText("Whisper Message: (leave blank to disable)")

    local whisperEditBox = CreateFrame("EditBox", "LockPort_WhisperEditBox", panel, "InputBoxTemplate")
    whisperEditBox:SetPoint("TOPLEFT", whisperLabel, "BOTTOMLEFT", 8, -5)
    whisperEditBox:SetSize(320, 20)
    whisperEditBox:SetAutoFocus(false)
    whisperEditBox:SetScript("OnEnterPressed", function(self)
        LockPortOptions.whisperMessage = self:GetText()
        self:ClearFocus()
    end)
    whisperEditBox:SetScript("OnEscapePressed", function(self)
        self:SetText(LockPortOptions.whisperMessage or "Summoning you to %zone - %subzone")
        self:ClearFocus()
    end)

    local whisperSaveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    whisperSaveButton:SetPoint("LEFT", whisperEditBox, "RIGHT", 10, 0)
    whisperSaveButton:SetSize(45, 22)
    whisperSaveButton:SetText("Save")
    whisperSaveButton:SetScript("OnClick", function()
        LockPortOptions.whisperMessage = whisperEditBox:GetText()
        whisperEditBox:ClearFocus()
    end)

    local sayLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sayLabel:SetPoint("TOPLEFT", whisperEditBox, "BOTTOMLEFT", -8, -20)
    sayLabel:SetText("Say Message:")

    local sayEditBox = CreateFrame("EditBox", "LockPort_SayEditBox", panel, "InputBoxTemplate")
    sayEditBox:SetPoint("TOPLEFT", sayLabel, "BOTTOMLEFT", 8, -5)
    sayEditBox:SetSize(320, 20)
    sayEditBox:SetAutoFocus(false)
    sayEditBox:SetScript("OnEnterPressed", function(self)
        LockPortOptions.sayMessage = self:GetText()
        self:ClearFocus()
    end)
    sayEditBox:SetScript("OnEscapePressed", function(self)
        self:SetText(LockPortOptions.sayMessage or "Summoning %name to %zone - %subzone [%shards]")
        self:ClearFocus()
    end)

    local saySaveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saySaveButton:SetPoint("LEFT", sayEditBox, "RIGHT", 10, 0)
    saySaveButton:SetSize(45, 22)
    saySaveButton:SetText("Save")
    saySaveButton:SetScript("OnClick", function()
        LockPortOptions.sayMessage = sayEditBox:GetText()
        sayEditBox:ClearFocus()
    end)

    local ignoreLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ignoreLabel:SetPoint("TOPLEFT", sayEditBox, "BOTTOMLEFT", -8, -25)
    ignoreLabel:SetText("Ignore List:")

    local ignoreListFrame = CreateFrame("ScrollFrame", "LockPort_IgnoreListFrame", panel, "UIPanelScrollFrameTemplate")
    ignoreListFrame:SetPoint("TOPLEFT", ignoreLabel, "BOTTOMLEFT", 0, -5)
    ignoreListFrame:SetSize(360, 100)

    ignoreListFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    ignoreListFrame:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

    local ignoreListContent = CreateFrame("Frame", "LockPort_IgnoreListContent", ignoreListFrame)
    ignoreListContent:SetSize(360, 100)
    ignoreListFrame:SetScrollChild(ignoreListContent)

    local addIgnoreEditBox = CreateFrame("EditBox", "LockPort_AddIgnoreEditBox", panel, "InputBoxTemplate")
    addIgnoreEditBox:SetPoint("TOPLEFT", ignoreListFrame, "BOTTOMLEFT", 8, -10)
    addIgnoreEditBox:SetSize(320, 20)
    addIgnoreEditBox:SetAutoFocus(false)

    local addIgnoreButton = CreateFrame("Button", "LockPort_AddIgnoreButton", panel, "UIPanelButtonTemplate")
    addIgnoreButton:SetPoint("LEFT", addIgnoreEditBox, "RIGHT", 10, 0)
    addIgnoreButton:SetSize(45, 22)
    addIgnoreButton:SetText("Add")
    addIgnoreButton:SetScript("OnClick", function()
        local name = addIgnoreEditBox:GetText():trim()
        if name ~= "" then
            LockPort_AddToIgnoreList(name)
            addIgnoreEditBox:SetText("")
            LockPort_UpdateIgnoreListDisplay()
        end
    end)

    addIgnoreEditBox:SetScript("OnEnterPressed", function(self)
        addIgnoreButton:Click()
    end)

    panel.soundDropdown = soundDropdown
    panel.whisperEditBox = whisperEditBox
    panel.sayEditBox = sayEditBox
    panel.ignoreListContent = ignoreListContent

    panel.refresh = function()
        local currentSound = LockPortOptions.sound or "Sound\\Creature\\Necromancer\\NecromancerReady1.wav"
        local soundName = "None"
        for i, soundOption in ipairs(SOUND_OPTIONS) do
            if soundOption.path == currentSound then
                soundName = soundOption.name
                break
            end
        end
        UIDropDownMenu_SetSelectedValue(soundDropdown, currentSound)
        UIDropDownMenu_SetText(soundDropdown, soundName)

        whisperEditBox:SetText(LockPortOptions.whisperMessage or "Summoning you to %zone - %subzone")
        whisperEditBox:SetCursorPosition(0)
        sayEditBox:SetText(LockPortOptions.sayMessage or "Summoning %name to %zone - %subzone [%shards]")
        sayEditBox:SetCursorPosition(0)
        LockPort_UpdateIgnoreListDisplay()
    end

    panel:SetScript("OnShow", function(self)
        if self.refresh then
            self.refresh()
        end
    end)

    panel.okay = function()
    end

    panel.cancel = function()
        panel.refresh()
    end

    panel.default = function()
        LockPortOptions.sound = LockPortOptions_DefaultSettings.sound
        LockPortOptions.whisperMessage = LockPortOptions_DefaultSettings.whisperMessage
        LockPortOptions.sayMessage = LockPortOptions_DefaultSettings.sayMessage
        LockPortOptions.ignoreList = {}
        panel.refresh()
    end

    return panel
end

function LockPort_AddToIgnoreList(name)
    if not LockPortOptions.ignoreList then
        LockPortOptions.ignoreList = {}
    end

    for i, v in ipairs(LockPortOptions.ignoreList) do
        if v == name then
            return
        end
    end

    table.insert(LockPortOptions.ignoreList, name)
end

function LockPort_RemoveFromIgnoreList(name)
    if not LockPortOptions.ignoreList then
        return
    end

    for i, v in ipairs(LockPortOptions.ignoreList) do
        if v == name then
            table.remove(LockPortOptions.ignoreList, i)
            break
        end
    end
end

function LockPort_IsIgnored(name)
    if not LockPortOptions.ignoreList then
        return false
    end

    for i, v in ipairs(LockPortOptions.ignoreList) do
        if v == name then
            return true
        end
    end
    return false
end

function LockPort_UpdateIgnoreListDisplay()
    local panel = LockPortOptionsPanel
    if not panel or not panel.ignoreListContent then
        return
    end

    local children = {panel.ignoreListContent:GetChildren()}
    for i, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end

    if LockPortOptions.ignoreList and #LockPortOptions.ignoreList > 0 then
        for i, name in ipairs(LockPortOptions.ignoreList) do
            local button = CreateFrame("Button", nil, panel.ignoreListContent)
            button:SetPoint("TOPLEFT", 5, -(i-1) * 22 - 4)
            button:SetSize(350, 20)

            local bgColor = (i % 2 == 0) and {0.15, 0.15, 0.2, 0.9} or {0.1, 0.1, 0.15, 0.9}

            button:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 6,
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })
            button:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
            button:SetBackdropBorderColor(0.3, 0.3, 0.4, 0.8)

            local highlight = button:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            highlight:SetBlendMode("ADD")
            highlight:SetAllPoints()
            highlight:SetAlpha(0.4)

            local nameText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("LEFT", button, "LEFT", 10, 0)
            nameText:SetText(name)
            nameText:SetJustifyH("LEFT")
            nameText:SetTextColor(1, 1, 1)

            local removeButton = CreateFrame("Button", nil, button)
            removeButton:SetPoint("RIGHT", button, "RIGHT", -6, 0)
            removeButton:SetSize(18, 18)

            local removeText = removeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            removeText:SetPoint("CENTER", removeButton, "CENTER", 0, 0)
            removeText:SetText("x")
            removeText:SetTextColor(0.8, 0.3, 0.3)

            removeButton:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 8,
                edgeSize = 4,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            removeButton:SetBackdropColor(0.2, 0.1, 0.1, 0.8)
            removeButton:SetBackdropBorderColor(0.4, 0.2, 0.2, 1)

            local function removePlayer()
                LockPort_RemoveFromIgnoreList(name)
                LockPort_UpdateIgnoreListDisplay()
            end

            button:SetScript("OnClick", removePlayer)
            removeButton:SetScript("OnClick", removePlayer)

            button:SetScript("OnEnter", function(self)
                removeText:SetTextColor(1, 0.2, 0.2)
                removeButton:SetBackdropColor(0.3, 0.1, 0.1, 1)
                nameText:SetTextColor(1, 1, 0.8)
                button:SetBackdropColor(bgColor[1] + 0.05, bgColor[2] + 0.05, bgColor[3] + 0.1, 1)
            end)

            button:SetScript("OnLeave", function(self)
                removeText:SetTextColor(0.8, 0.3, 0.3)
                removeButton:SetBackdropColor(0.2, 0.1, 0.1, 0.8)
                nameText:SetTextColor(1, 1, 1)
                button:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
            end)

            removeButton:SetScript("OnEnter", function(self)
                removeText:SetTextColor(1, 0.1, 0.1)
                removeButton:SetBackdropColor(0.4, 0.1, 0.1, 1)
                nameText:SetTextColor(1, 1, 0.8)
                button:SetBackdropColor(bgColor[1] + 0.05, bgColor[2] + 0.05, bgColor[3] + 0.1, 1)
            end)

            removeButton:SetScript("OnLeave", function(self)
                removeText:SetTextColor(0.8, 0.3, 0.3)
                removeButton:SetBackdropColor(0.2, 0.1, 0.1, 0.8)
                nameText:SetTextColor(1, 1, 1)
                button:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
            end)

            button:EnableMouse(true)
            removeButton:EnableMouse(true)
        end

        panel.ignoreListContent:SetHeight(math.max(100, #LockPortOptions.ignoreList * 22 + 4))
    else
        local emptyFrame = CreateFrame("Frame", nil, panel.ignoreListContent)
        emptyFrame:SetPoint("CENTER", panel.ignoreListContent, "CENTER", 0, 0)
        emptyFrame:SetSize(250, 40)

        emptyFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = true,
            tileSize = 16
        })
        emptyFrame:SetBackdropColor(0.1, 0.1, 0.2, 0.5)

        local emptyText = emptyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("CENTER", emptyFrame, "CENTER", 0, 0)
        emptyText:SetText("No players ignored")
        emptyText:SetTextColor(0.6, 0.6, 0.7)

        panel.ignoreListContent:SetHeight(100)
    end
end

function LockPort_QueryWarlockShards()
    LockPort_ShardResponses = {}

    if UnitClass("player") ~= "Warlock" then
        DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Only warlocks can query shard counts!")
        return
    end

    local raidnum = GetNumRaidMembers()
    local partynum = GetNumPartyMembers()

    if raidnum > 0 then
        SendAddonMessage(MSG_PREFIX_SHARD_QUERY, UnitName("player"), "RAID")
        DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Querying warlock soul shard counts...")
    elseif partynum > 0 then
        SendAddonMessage(MSG_PREFIX_SHARD_QUERY, UnitName("player"), "PARTY")
        DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Querying warlock soul shard counts...")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : You must be in a party or raid to query shard counts.")
    end

    local resultTimer = CreateFrame("Frame")
    resultTimer.elapsed = 0
    resultTimer:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= 3 then
            LockPort_DisplayShardResults()
            self:SetScript("OnUpdate", nil)
        end
    end)
end

function LockPort_HandleShardQuery(requester)
    if UnitClass("player") ~= "Warlock" then
        return
    end

    local bag, slot, texture, count = FindItem("Soul Shard")
    local shardCount = count or 0

    local responseData = UnitName("player") .. ":" .. tostring(shardCount)

    local raidnum = GetNumRaidMembers()
    local partynum = GetNumPartyMembers()

    if raidnum > 0 then
        SendAddonMessage(MSG_PREFIX_SHARD_RESPONSE, responseData, "RAID")
    elseif partynum > 0 then
        SendAddonMessage(MSG_PREFIX_SHARD_RESPONSE, responseData, "PARTY")
    end
end

function LockPort_HandleShardResponse(responseData)
    local name, shardCount = string.split(":", responseData)
    if name and shardCount then
        LockPort_ShardResponses[name] = tonumber(shardCount) or 0
    end
end

function LockPort_DisplayShardResults()
    DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Warlock Soul Shard Report:")

    local totalResponses = 0
    local totalShards = 0

    local sortedNames = {}
    for name, count in pairs(LockPort_ShardResponses) do
        table.insert(sortedNames, name)
        totalResponses = totalResponses + 1
        totalShards = totalShards + count
    end
    table.sort(sortedNames)

    if totalResponses == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("  |cffff6666No responses received. Make sure other warlocks have LockPort addon.|r")
        return
    end

    for _, name in ipairs(sortedNames) do
        local count = LockPort_ShardResponses[name]
        local colorCode = ""
        if count == 0 then
            colorCode = "|cffff6666"
        elseif count < 10 then
            colorCode = "|cffffff66"
        else
            colorCode = "|cff66ff66"
        end

        DEFAULT_CHAT_FRAME:AddMessage("  " .. colorCode .. name .. ": " .. count .. " shards|r")
    end

    DEFAULT_CHAT_FRAME:AddMessage("  |cff9482c9Total: " .. totalShards .. " shards across " .. totalResponses .. " warlocks|r")
end

local function LockPort_Initialize()
    if not LockPortOptions then
        LockPortOptions = {}
    end

    if type(LockPortOptions.sound) == "boolean" then
        if LockPortOptions.sound then
            LockPortOptions.sound = "Sound\\Creature\\Necromancer\\NecromancerReady1.wav"
        else
            LockPortOptions.sound = ""
        end
    end

    for i in pairs(LockPortOptions_DefaultSettings) do
        if LockPortOptions[i] == nil then
            LockPortOptions[i] = LockPortOptions_DefaultSettings[i]
        end
    end

    if not LockPortOptions.whisperMessage or LockPortOptions.whisperMessage == "" then
        LockPortOptions.whisperMessage = LockPortOptions_DefaultSettings.whisperMessage
    end
    if not LockPortOptions.sayMessage or LockPortOptions.sayMessage == "" then
        LockPortOptions.sayMessage = LockPortOptions_DefaultSettings.sayMessage
    end

    if not LockPortOptions.ignoreList then
        LockPortOptions.ignoreList = {}
    end

    local panel = CreateInterfaceOptionsPanel()
    InterfaceOptions_AddCategory(panel)

    if panel.refresh then
        panel.refresh()
    end
end

function LockPort_UpdateButtonStates()
    if InCombatLockdown() or not LockPort_RequestFrame:IsVisible() then
        return
    end

    for i = 1, 10 do
        local button = _G["LockPort_NameList"..i]
        if button and button:IsVisible() and LockPort_BrowseDB and LockPort_BrowseDB[i] then
            local name = LockPort_BrowseDB[i].rName
            local unitPrefix = LockPort_BrowseDB[i].unitPrefix or "raid"
            local unitID = unitPrefix..LockPort_BrowseDB[i].rIndex

            button.targetName = name
            button.unitID = unitID

            local macroText = string.format("/target %s\n/cast %s", name, LP:SpellName(698))
            button:SetAttribute("type", "macro")
            button:SetAttribute("macrotext", macroText)

            button:SetScript("PreClick", nil)
        end
    end
end

function LockPort_NameListButton_PostClick(self, button)
    if button == "RightButton" then
        local name = self.targetName or _G[self:GetName().."TextName"]:GetText()
        for i, v in ipairs(LockPortDB) do
            if v == name then
                SendAddonMessage(MSG_PREFIX_REMOVE, name, "RAID")
                table.remove(LockPortDB, i)
                LockPort_UpdateList()
                break
            end
        end
    elseif button == "LeftButton" then
        local name = self.targetName

        if not name then return end

        local checkTimer = CreateFrame("Frame")
        checkTimer.elapsed = 0
        checkTimer.targetName = name
        checkTimer:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.5 then
                if UnitExists("target") and UnitName("target") == self.targetName then
                    local playercombat = UnitAffectingCombat("player")
                    local targetcombat = UnitAffectingCombat("target")

                    if not playercombat and not targetcombat then
                        LockPort_HandleSummonActions(self.targetName)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Cannot summon " .. self.targetName .. " - someone is in combat!")
                    end
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Could not target " .. self.targetName)
                end
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
end

function LockPort_EventFrame_OnLoad(self)
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r version %s by %s. Type /lockport to show.", GetAddOnMetadata("LockPort", "Version"), GetAddOnMetadata("LockPort", "Author")))

    self:RegisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("CHAT_MSG_RAID")
    self:RegisterEvent("CHAT_MSG_RAID_LEADER")
    self:RegisterEvent("CHAT_MSG_SAY")
    self:RegisterEvent("CHAT_MSG_YELL")
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("CHAT_MSG_PARTY")
    self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")

    SlashCmdList["LockPort"] = LockPort_SlashCommand
    SLASH_LockPort1 = "/lockport"
    SLASH_LockPort2 = "/gurky"

    MSG_PREFIX_ADD = "RSAdd"
    MSG_PREFIX_REMOVE = "RSRemove"
    MSG_PREFIX_SHARD_QUERY = "RSShardQuery"
    MSG_PREFIX_SHARD_RESPONSE = "RSShardResponse"
    LockPortDB = {}
    LockPort_ShardResponses = {}

    LockPortLoc_Header = "|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r"
    LockPortLoc_Settings_Header = "|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r Settings"
    LockPortLoc_Settings_Chat_Header = "|CFFB700B7C|CFFFF00FFh|CFFFF50FFa|CFFFF99FFt|CFFFFC4FF S|cffffffffett|rings"

    LockPort_UpdateTimerFrame = CreateFrame("Frame")
    LockPort_UpdateTimerFrame.elapsed = 0
    LockPort_UpdateTimerFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= 0.1 then
            LockPort_UpdateButtonStates()
            self.elapsed = 0
        end
    end)
end

function LockPort_EventFrame_OnEvent(self, event, ...)
    if event == "VARIABLES_LOADED" then
        self:UnregisterEvent("VARIABLES_LOADED")
        LockPort_Initialize()
    elseif event == "CHAT_MSG_SAY" or event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
        local text, playerName = ...
        if string.find(text, "^123") then
            SendAddonMessage(MSG_PREFIX_ADD, playerName, "RAID")
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix == MSG_PREFIX_ADD then
            if not LockPort_hasValue(LockPortDB, message) and UnitName("player") ~= message and UnitClass("player") == "Warlock" and not LockPort_IsIgnored(message) then
                table.insert(LockPortDB, message)
                LockPort_UpdateList()
                if LockPortOptions.sound and LockPortOptions.sound ~= "" then
                    PlaySoundFile(LockPortOptions.sound)
                end
            end
        elseif prefix == MSG_PREFIX_REMOVE then
            if LockPort_hasValue(LockPortDB, message) then
                for i, v in ipairs(LockPortDB) do
                    if v == message then
                        table.remove(LockPortDB, i)
                        LockPort_UpdateList()
                        break
                    end
                end
            end
        elseif prefix == MSG_PREFIX_SHARD_QUERY then
            LockPort_HandleShardQuery(message)
        elseif prefix == MSG_PREFIX_SHARD_RESPONSE then
            LockPort_HandleShardResponse(message)
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        LockPort_UpdateButtonStates()
    end
end

function LockPort_hasValue(tab, val)
    for i, v in ipairs(tab) do
        if v == val then
            return true
        end
    end
    return false
end

function LockPort_HandleSummonActions(name)
    if not UnitExists("target") or UnitName("target") ~= name then
        return
    end

    local bag, slot, texture, count = FindItem("Soul Shard")

    if not count or count == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Cannot summon " .. name .. " - |cffff0000No Soul Shards|r!")
        return
    end

    local playercombat = UnitAffectingCombat("player")
    local targetcombat = UnitAffectingCombat("target")

    if not playercombat and not targetcombat then
        if CheckInteractDistance("target", 4) then
            DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : <" .. name .. "> already in range")
        else
            local say_message = LockPortOptions.sayMessage or "Summoning %name to %zone - %subzone [%shards]"
            local whisper_message = LockPortOptions.whisperMessage or "Summoning you to %zone - %subzone"

            local targetClass, targetClassToken = UnitClass("target")
            local targetRace = UnitRace("target")
            local playerName = UnitName("player")
            local zoneName = GetZoneText()
            local subzoneName = GetSubZoneText()
            local shardsLeft = (count and count > 0) and (count - 1) or 0

            local function replaceVariables(msg)
                msg = string.gsub(msg, "%%name", name)
                msg = string.gsub(msg, "%%class", targetClass or "Unknown")
                msg = string.gsub(msg, "%%race", targetRace or "Unknown")
                msg = string.gsub(msg, "%%myname", playerName)
                msg = string.gsub(msg, "%%zone", zoneName)
                msg = string.gsub(msg, "%%subzone", subzoneName)
                msg = string.gsub(msg, "%%shards", tostring(shardsLeft) .. " shards left")
                return msg
            end

            say_message = replaceVariables(say_message)
            whisper_message = replaceVariables(whisper_message)

            SendChatMessage(say_message, "SAY")

            if LockPortOptions.whisperMessage and LockPortOptions.whisperMessage:trim() ~= "" then
                SendChatMessage(whisper_message, "WHISPER", nil, name)
            end
        end

        for i, v in ipairs(LockPortDB) do
            if v == name then
                SendAddonMessage(MSG_PREFIX_REMOVE, name, "RAID")
                table.remove(LockPortDB, i)
                LockPort_UpdateList()
                break
            end
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Cannot summon " .. name .. " - someone is in combat!")
    end
end

function LockPort_UpdateList()
    LockPort_BrowseDB = {}

    if UnitClass("player") == "Warlock" then
        local raidnum = GetNumRaidMembers()
        local partynum = GetNumPartyMembers()
        local browseIndex = 1

        if raidnum > 0 then
            for raidmember = 1, raidnum do
                local rName, rRank, rSubgroup, rLevel, rClass = GetRaidRosterInfo(raidmember)
                for i, v in ipairs(LockPortDB) do
                    if v == rName then
                        LockPort_BrowseDB[browseIndex] = {}
                        LockPort_BrowseDB[browseIndex].rName = rName
                        LockPort_BrowseDB[browseIndex].rClass = rClass
                        LockPort_BrowseDB[browseIndex].rIndex = raidmember
                        LockPort_BrowseDB[browseIndex].unitPrefix = "raid"
                        if rName == "Shadowtoots" then
                            LockPort_BrowseDB[browseIndex].vipPriority = 2
                        elseif rClass == "Warlock" then
                            LockPort_BrowseDB[browseIndex].vipPriority = 1
                        else
                            LockPort_BrowseDB[browseIndex].vipPriority = 0
                        end
                        browseIndex = browseIndex + 1
                        break
                    end
                end
            end
        elseif partynum > 0 then
            for partymember = 1, partynum do
                local unitID = "party"..partymember
                local rName = UnitName(unitID)
                local rClass = UnitClass(unitID)

                for i, v in ipairs(LockPortDB) do
                    if v == rName then
                        LockPort_BrowseDB[browseIndex] = {}
                        LockPort_BrowseDB[browseIndex].rName = rName
                        LockPort_BrowseDB[browseIndex].rClass = rClass
                        LockPort_BrowseDB[browseIndex].rIndex = partymember
                        LockPort_BrowseDB[browseIndex].unitPrefix = "party"
                        if rName == "Shadowtoots" then
                            LockPort_BrowseDB[browseIndex].vipPriority = 2
                        elseif rClass == "Warlock" then
                            LockPort_BrowseDB[browseIndex].vipPriority = 1
                        else
                            LockPort_BrowseDB[browseIndex].vipPriority = 0
                        end
                        browseIndex = browseIndex + 1
                        break
                    end
                end
            end
        end

        table.sort(LockPort_BrowseDB, function(a, b) return a.vipPriority > b.vipPriority end)

        for i = 1, 10 do
            if LockPort_BrowseDB[i] then
                _G["LockPort_NameList"..i.."TextName"]:SetText(LockPort_BrowseDB[i].rName)

                local c = LockPort_GetClassColour(LockPort_BrowseDB[i].rClass)
                _G["LockPort_NameList"..i.."TextName"]:SetTextColor(c.r, c.g, c.b, 1)

                _G["LockPort_NameList"..i]:Show()
            else
                _G["LockPort_NameList"..i]:Hide()
            end
        end

        LockPort_UpdateButtonStates()

        if not LockPortDB[1] then
            if LockPort_RequestFrame:IsVisible() then
                LockPort_RequestFrame:Hide()
            end
        else
            ShowUIPanel(LockPort_RequestFrame, 1)
        end
    end
end

function LockPort_SlashCommand(msg)
    if msg == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r usage:")
        DEFAULT_CHAT_FRAME:AddMessage("/lockport { help | show | config | ignore }")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9help|r: prints out this help")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9show|r: shows the current summon list")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9config|r: opens the configuration panel")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9ignore [playername]|r: adds player to ignore list")
    elseif msg == "show" then
        for i, v in ipairs(LockPortDB) do
            DEFAULT_CHAT_FRAME:AddMessage(tostring(v))
        end
    elseif msg == "config" then
        InterfaceOptionsFrame_OpenToCategory("LockPort")
    elseif msg == "shardcheck" or msg == "shards" then
        LockPort_QueryWarlockShards()
    elseif string.find(msg, "^ignore ") then
        local name = string.gsub(msg, "^ignore ", "")
        if name and name ~= "" then
            LockPort_AddToIgnoreList(name)
            DEFAULT_CHAT_FRAME:AddMessage("|CFFB700B7L|CFFFF00FFo|CFFFF50FFc|CFFFF99FFk|CFFFFC4FFP|cffffffffort|r : Added " .. name .. " to ignore list")
        end
    else
        if LockPort_RequestFrame:IsVisible() then
            LockPort_RequestFrame:Hide()
        else
            LockPort_UpdateList()
            ShowUIPanel(LockPort_RequestFrame, 1)
        end
    end
end

function LockPort_GetClassColour(class)
    local classTable = {
        ["Druid"] = "DRUID",
        ["Hunter"] = "HUNTER",
        ["Mage"] = "MAGE",
        ["Paladin"] = "PALADIN",
        ["Priest"] = "PRIEST",
        ["Rogue"] = "ROGUE",
        ["Shaman"] = "SHAMAN",
        ["Warlock"] = "WARLOCK",
        ["Warrior"] = "WARRIOR"
    }

    local colorKey = classTable[class]
    if colorKey and RAID_CLASS_COLORS[colorKey] then
        return RAID_CLASS_COLORS[colorKey]
    end
    return {r = 0.5, g = 0.5, b = 1}
end

function FindItem(item)
    if not item then return nil, nil, nil, 0 end

    local itemName = string.lower(item)
    if type(item) == "number" then
        itemName = string.lower(GetItemInfo(item) or "")
    else
        itemName = string.lower(ItemLinkToName(item))
    end

    local totalcount = 0

    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        if numSlots then
            for slot = 1, numSlots do
                local link = GetContainerItemLink(bag, slot)
                if link then
                    local linkName = string.lower(ItemLinkToName(link))
                    if linkName == itemName then
                        local _, count = GetContainerItemInfo(bag, slot)
                        totalcount = totalcount + (count or 1)
                    end
                end
            end
        end
    end

    return nil, nil, nil, totalcount
end

function ItemLinkToName(link)
    if link then
        return gsub(link, "^.*%[(.*)%].*$", "%1")
    end
end

if not string.split then
    function string.split(str, delimiter)
        local result = {}
        local pattern = string.format("([^%s]+)", delimiter)
        for match in string.gmatch(str, pattern) do
            table.insert(result, match)
        end
        return unpack(result)
    end
end

function hcstrsplit(delimiter, subject)
    if not subject then return nil end
    local fields = {}
    local pattern = string.format("([^%s]+)", delimiter or ":")
    string.gsub(subject, pattern, function(c) fields[#fields+1] = c end)
    return unpack(fields)
end

local major, minor, fix = hcstrsplit(".", tostring(GetAddOnMetadata("LockPort", "Version")))
local localversion = tonumber(major*10000 + minor*100 + fix)

lpupdater = CreateFrame("Frame")
lpupdater:RegisterEvent("PLAYER_ENTERING_WORLD")
lpupdater:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
    end
end)
