if IY_LOADED and not _G.IY_DEBUG then
	-- error("Infinite Yield is already running!", 0)
	-- Running the script again in the same server stops here. Say so, otherwise a newer
	-- copy looks like it loaded but changed nothing.
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "SpreadCheeksGUI",
			Text = "Already running in this server. Rejoin, then run the script to load a new version.",
			Duration = 8,
		})
	end)
	return
end

pcall(function() getgenv().IY_LOADED = true end)
if not game:IsLoaded() then game.Loaded:Wait() end

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
gethui = missing("function", gethui or get_hidden_gui)
syn = missing("table", syn)
syn_protect_gui = missing("function", syn and syn.protect_gui)
sethidden =  missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
gethidden =  missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)
queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
firetouchinterest = missing("function", firetouchinterest)
waxwritefile, waxreadfile = writefile, readfile
writefile = missing("function", waxwritefile) and function(file, data, safe)
	if safe == true then return pcall(waxwritefile, file, data) end
	waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
	if safe == true then return pcall(waxreadfile, file) end
	return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
	local success, result = pcall(function()
		return readfile(file)
	end)
	return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
waxgetcustomasset = missing("function", getcustomasset or getsynasset)
hookfunction = missing("function", hookfunction)
hookmetamethod = missing("function", hookmetamethod)
getnamecallmethod = missing("function", getnamecallmethod or get_namecall_method)
checkcaller = missing("function", checkcaller, function() return false end)
newcclosure = missing("function", newcclosure, function(f, ...) return f(...) end)
getgc = missing("function", getgc or get_gc_objects)
setthreadidentity = missing("function", setthreadidentity or (syn and syn.set_thread_identity) or syn_context_set or setthreadcontext)
replicatesignal = missing("function", replicatesignal)
getconnections = missing("function", getconnections or get_signal_cons)

Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			error("Invalid Service: " .. tostring(name))
		end
	end
})

Players = Services.Players
UserInputService = Services.UserInputService
TweenService = Services.TweenService
HttpService = Services.HttpService
ExperienceService = Services.ExperienceService
MarketplaceService = Services.MarketplaceService
RunService = Services.RunService
TeleportService = Services.TeleportService
StarterGui = Services.StarterGui
GuiService = Services.GuiService
Lighting = Services.Lighting
ContextActionService = Services.ContextActionService
ReplicatedStorage = Services.ReplicatedStorage
GroupService = Services.GroupService
PathService = Services.PathfindingService
SoundService = Services.SoundService
Teams = Services.Teams
StarterPlayer = Services.StarterPlayer
InsertService = Services.InsertService
ChatService = Services.Chat
ProximityPromptService = Services.ProximityPromptService
ContentProvider = Services.ContentProvider
StatsService = Services.Stats
MaterialService = Services.MaterialService
AvatarEditorService = Services.AvatarEditorService
TextService = Services.TextService
TextChatService = Services.TextChatService
CaptureService = Services.CaptureService
VoiceChatService = Services.VoiceChatService
SocialService = Services.SocialService

PlayerGui = cloneref(Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
COREGUI = Services.CoreGui or PlayerGui
IYMouse = cloneref(Players.LocalPlayer:GetMouse())
PlaceId, JobId = game.PlaceId, game.JobId
xpcall(function()
	IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())
end, function()
	IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end)
isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService
--[[rcdEnabled = select(2, pcall(function()
    return gethidden(workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled
end)) or false]]

-- xylex & europa
local iyassets = {
	["infiniteyield/assets/bindsandplugins.png"] = "rbxassetid://5147695474",
	["infiniteyield/assets/close.png"] = "rbxassetid://5054663650",
	["infiniteyield/assets/editaliases.png"] = "rbxassetid://5147488658",
	["infiniteyield/assets/editkeybinds.png"] = "rbxassetid://129697930",
	["infiniteyield/assets/edittheme.png"] = "rbxassetid://4911962991",
	["infiniteyield/assets/editwaypoints.png"] = "rbxassetid://5147488592",
	["infiniteyield/assets/imgstudiopluginlogo.png"] = "rbxassetid://4113050383",
	["infiniteyield/assets/logo.png"] = "rbxassetid://1352543873",
	["infiniteyield/assets/minimize.png"] = "rbxassetid://2406617031",
	["infiniteyield/assets/pin.png"] = "rbxassetid://6234691350",
	["infiniteyield/assets/reference.png"] = "rbxassetid://3523243755",
	["infiniteyield/assets/settings.png"] = "rbxassetid://1204397029",
	["infiniteyield/assets/scrollbar.png"] = "rbxassetid://75024581433929"
}

local function getcustomasset(asset)
	if waxgetcustomasset then
		local success, result = pcall(function()
			return waxgetcustomasset(asset)
		end)
		if success and result ~= nil and result ~= "" then
			return result
		end
	end
	return iyassets[asset]
end

if makefolder and isfolder and writefile and isfile then
	pcall(function() -- good executor trust
		local assets = "https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/"
		for _, folder in {"infiniteyield", "infiniteyield/assets"} do
			if not isfolder(folder) then
				makefolder(folder)
			end
		end
		for path in iyassets do
			if not isfile(path) and path ~= 'infiniteyield/assets/scrollbar.png' then
				writefile(path, game:HttpGet((path:gsub("infiniteyield/", assets))))
			end
		end
		-- honestly just blame your phone if the assets appear in your gallery
		if IsOnMobile then writefile("infiniteyield/assets/.nomedia", "") end
	end)
end

currentVersion = "6.4.2"

ScaledHolder = Instance.new("Frame")
Scale = Instance.new("UIScale")
Holder = Instance.new("Frame")
Title = Instance.new("TextLabel")
Dark = Instance.new("Frame")
Cmdbar = Instance.new("TextBox")
CMDsF = Instance.new("ScrollingFrame")
cmdListLayout = Instance.new("UIListLayout")
SettingsButton = Instance.new("ImageButton")
ColorsButton = Instance.new("ImageButton")
Settings = Instance.new("Frame")
Prefix = Instance.new("TextLabel")
PrefixBox = Instance.new("TextBox")
Keybinds = Instance.new("TextLabel")
StayOpen = Instance.new("TextLabel")
Button = Instance.new("Frame")
On = Instance.new("TextButton")
Positions = Instance.new("TextLabel")
EventBind = Instance.new("TextLabel")
Plugins = Instance.new("TextLabel")
Example = Instance.new("TextButton")
Notification = Instance.new("Frame")
Title_2 = Instance.new("TextLabel")
Text_2 = Instance.new("TextLabel")
CloseButton = Instance.new("TextButton")
CloseImage = Instance.new("ImageLabel")
PinButton = Instance.new("TextButton")
PinImage = Instance.new("ImageLabel")
Tooltip = Instance.new("Frame")
Title_3 = Instance.new("TextLabel")
Description = Instance.new("TextLabel")
IntroBackground = Instance.new("Frame")
Logo = Instance.new("ImageLabel")
Credits = Instance.new("TextBox")
KeybindsFrame = Instance.new("Frame")
Close = Instance.new("TextButton")
Add = Instance.new("TextButton")
Delete = Instance.new("TextButton")
Holder_2 = Instance.new("ScrollingFrame")
Example_2 = Instance.new("Frame")
Text_3 = Instance.new("TextLabel")
Delete_2 = Instance.new("TextButton")
KeybindEditor = Instance.new("Frame")
background_2 = Instance.new("Frame")
Dark_3 = Instance.new("Frame")
Directions = Instance.new("TextLabel")
BindTo = Instance.new("TextButton")
TriggerLabel = Instance.new("TextLabel")
BindTriggerSelect = Instance.new("TextButton")
Add_2 = Instance.new("TextButton")
Toggles = Instance.new("ScrollingFrame")
ClickTP  = Instance.new("TextLabel")
Select = Instance.new("TextButton")
ClickDelete = Instance.new("TextLabel")
Select_2 = Instance.new("TextButton")
Cmdbar_2 = Instance.new("TextBox")
Cmdbar_3 = Instance.new("TextBox")
CreateToggle = Instance.new("TextLabel")
Button_2 = Instance.new("Frame")
On_2 = Instance.new("TextButton")
shadow_2 = Instance.new("Frame")
PopupText_2 = Instance.new("TextLabel")
Exit_2 = Instance.new("TextButton")
ExitImage_2 = Instance.new("ImageLabel")
PositionsFrame = Instance.new("Frame")
Close_3 = Instance.new("TextButton")
Delete_5 = Instance.new("TextButton")
Part = Instance.new("TextButton")
Holder_4 = Instance.new("ScrollingFrame")
Example_4 = Instance.new("Frame")
Text_5 = Instance.new("TextLabel")
Delete_6 = Instance.new("TextButton")
TP = Instance.new("TextButton")
AliasesFrame = Instance.new("Frame")
Close_2 = Instance.new("TextButton")
Delete_3 = Instance.new("TextButton")
Holder_3 = Instance.new("ScrollingFrame")
Example_3 = Instance.new("Frame")
Text_4 = Instance.new("TextLabel")
Delete_4 = Instance.new("TextButton")
Aliases = Instance.new("TextLabel")
PluginsFrame = Instance.new("Frame")
Close_4 = Instance.new("TextButton")
Add_3 = Instance.new("TextButton")
Holder_5 = Instance.new("ScrollingFrame")
Example_5 = Instance.new("Frame")
Text_6 = Instance.new("TextLabel")
Delete_7 = Instance.new("TextButton")
PluginEditor = Instance.new("Frame")
background_3 = Instance.new("Frame")
Dark_2 = Instance.new("Frame")
Img = Instance.new("ImageButton")
AddPlugin = Instance.new("TextButton")
FileName = Instance.new("TextBox")
About = Instance.new("TextLabel")
Directions_2 = Instance.new("TextLabel")
shadow_3 = Instance.new("Frame")
PopupText_3 = Instance.new("TextLabel")
Exit_3 = Instance.new("TextButton")
ExitImage_3 = Instance.new("ImageLabel")
AliasHint = Instance.new("TextLabel")
PluginsHint = Instance.new("TextLabel")
PositionsHint = Instance.new("TextLabel")
ToPartFrame = Instance.new("Frame")
background_4 = Instance.new("Frame")
ChoosePart = Instance.new("TextButton")
CopyPath = Instance.new("TextButton")
Directions_3 = Instance.new("TextLabel")
Path = Instance.new("TextLabel")
shadow_4 = Instance.new("Frame")
PopupText_5 = Instance.new("TextLabel")
Exit_4 = Instance.new("TextButton")
ExitImage_5 = Instance.new("ImageLabel")
logs = Instance.new("Frame")
shadow = Instance.new("Frame")
Hide = Instance.new("TextButton")
ImageLabel = Instance.new("ImageLabel")
PopupText = Instance.new("TextLabel")
Exit = Instance.new("TextButton")
ImageLabel_2 = Instance.new("ImageLabel")
background = Instance.new("Frame")
chat = Instance.new("Frame")
Clear = Instance.new("TextButton")
SaveChatlogs = Instance.new("TextButton")
Toggle = Instance.new("TextButton")
scroll_2 = Instance.new("ScrollingFrame")
join = Instance.new("Frame")
Toggle_2 = Instance.new("TextButton")
Clear_2 = Instance.new("TextButton")
scroll_3 = Instance.new("ScrollingFrame")
listlayout = Instance.new("UIListLayout",scroll_3)
selectChat = Instance.new("TextButton")
selectJoin = Instance.new("TextButton")

function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

PARENT = nil
MAX_DISPLAY_ORDER = 1.7976931348623157e308
if gethui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = gethui()
    PARENT = Main
elseif (not is_sirhurt_closure) and syn_protect_gui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    syn_protect_gui(Main)
    Main.Parent = COREGUI
    PARENT = Main
elseif COREGUI:FindFirstChild("RobloxGui") then
    PARENT = COREGUI.RobloxGui
else
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = COREGUI
    PARENT = Main
end

shade1 = {}
shade2 = {}
shade3 = {}
text1 = {}
text2 = {}
scroll = {}

ScaledHolder.Name = randomString()
ScaledHolder.Size = UDim2.fromScale(1, 1)
ScaledHolder.BackgroundTransparency = 1
ScaledHolder.Parent = PARENT
Scale.Name = randomString()

Holder.Name = randomString()
Holder.Parent = ScaledHolder
Holder.Active = true
Holder.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Holder.BorderSizePixel = 0
Holder.Position = UDim2.new(1, -250, 1, -220)
Holder.Size = UDim2.new(0, 250, 0, 220)
Holder.ZIndex = 10
table.insert(shade2,Holder)

Title.Name = "Title"
Title.Parent = Holder
Title.Active = true
Title.BackgroundColor3 = Color3.fromRGB(36,36,37)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(0, 250, 0, 20)
Title.Font = Enum.Font.SourceSans
Title.TextSize = 18
Title.Text = "Infinite Yield FE v" .. currentVersion

do
	local emoji = ({
		["01 01"] = "🎆",
		["02 14"] = "💝",
		["03 17"] = "☘️",
		[(function(Year)
			local A = math.floor(Year/100)
			local B = math.floor((13+8*A)/25)
			local C = (15-B+A-math.floor(A/4))%30
			local D = (4+A-math.floor(A/4))%7
			local E = (19*(Year%19)+C)%30
			local F = (2*(Year%4)+4*(Year%7)+6*E+D)%7
			local G = (22+E+F)
			if E == 29 and F == 6 then
				return "04 19"
			elseif E == 28 and F == 6 then
				return "04 18"
			elseif 31 < G then
				return ("04 %02d"):format(G-31)
			end
			return ("03 %02d"):format(G)
		end)(tonumber(os.date"%Y"))] = "🥚",
		["10 31"] = "🎃",
		["12 25"] = "🎄"
	})[os.date("%m %d")]
	if emoji then
		Title.Text = ("%s %s %s"):format(emoji, Title.Text, emoji)
	end
end

Title.TextColor3 = Color3.new(1, 1, 1)
Title.ZIndex = 10
table.insert(shade1,Title)
table.insert(text1,Title)

Dark.Name = "Dark"
Dark.Parent = Holder
Dark.Active = true
Dark.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Dark.BorderSizePixel = 0
Dark.Position = UDim2.new(0, 0, 0, 45)
Dark.Size = UDim2.new(0, 250, 0, 175)
Dark.ZIndex = 10
table.insert(shade1,Dark)

Cmdbar.Name = "Cmdbar"
Cmdbar.Parent = Holder
Cmdbar.BackgroundTransparency = 1
Cmdbar.BorderSizePixel = 0
Cmdbar.Position = UDim2.new(0, 5, 0, 20)
Cmdbar.Size = UDim2.new(0, 240, 0, 25)
Cmdbar.Font = Enum.Font.SourceSans
Cmdbar.TextSize = 18
Cmdbar.TextXAlignment = Enum.TextXAlignment.Left
Cmdbar.TextColor3 = Color3.new(1, 1, 1)
Cmdbar.Text = ""
Cmdbar.ZIndex = 10
Cmdbar.PlaceholderText = "Command Bar"

CMDsF.Name = "CMDs"
CMDsF.Parent = Holder
CMDsF.BackgroundTransparency = 1
CMDsF.BorderSizePixel = 0
CMDsF.Position = UDim2.new(0, 5, 0, 45)
CMDsF.Size = UDim2.new(0, 245, 0, 175)
CMDsF.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
CMDsF.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.CanvasSize = UDim2.new(0, 0, 0, 0)
CMDsF.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.ScrollBarThickness = 8
CMDsF.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.VerticalScrollBarInset = 'Always'
CMDsF.ZIndex = 10
table.insert(scroll,CMDsF)

cmdListLayout.Parent = CMDsF

SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = Holder
SettingsButton.BackgroundTransparency = 1
SettingsButton.Position = UDim2.new(0, 230, 0, 0)
SettingsButton.Size = UDim2.new(0, 20, 0, 20)
SettingsButton.Image = getcustomasset("infiniteyield/assets/settings.png")
SettingsButton.ZIndex = 10

ReferenceButton = Instance.new("ImageButton")
ReferenceButton.Name = "ReferenceButton"
ReferenceButton.Parent = Holder
ReferenceButton.BackgroundTransparency = 1
ReferenceButton.Position = UDim2.new(0, 212, 0, 2)
ReferenceButton.Size = UDim2.new(0, 16, 0, 16)
ReferenceButton.Image = getcustomasset("infiniteyield/assets/reference.png")
ReferenceButton.ZIndex = 10

Settings.Name = "Settings"
Settings.Parent = Holder
Settings.Active = true
Settings.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Settings.BorderSizePixel = 0
Settings.Position = UDim2.new(0, 0, 0, 220)
Settings.Size = UDim2.new(0, 250, 0, 175)
Settings.ZIndex = 10
table.insert(shade1,Settings)

SettingsHolder = Instance.new("ScrollingFrame")
SettingsHolder.Name = "Holder"
SettingsHolder.Parent = Settings
SettingsHolder.BackgroundTransparency = 1
SettingsHolder.BorderSizePixel = 0
SettingsHolder.Size = UDim2.new(1,0,1,0)
SettingsHolder.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
SettingsHolder.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.CanvasSize = UDim2.new(0, 0, 0, 235)
SettingsHolder.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.ScrollBarThickness = 8
SettingsHolder.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.VerticalScrollBarInset = 'Always'
SettingsHolder.ZIndex = 10
table.insert(scroll,SettingsHolder)

Prefix.Name = "Prefix"
Prefix.Parent = SettingsHolder
Prefix.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Prefix.BorderSizePixel = 0
Prefix.BackgroundTransparency = 1
Prefix.Position = UDim2.new(0, 5, 0, 5)
Prefix.Size = UDim2.new(1, -10, 0, 20)
Prefix.Font = Enum.Font.SourceSans
Prefix.TextSize = 14
Prefix.Text = "Prefix"
Prefix.TextColor3 = Color3.new(1, 1, 1)
Prefix.TextXAlignment = Enum.TextXAlignment.Left
Prefix.ZIndex = 10
table.insert(shade2,Prefix)
table.insert(text1,Prefix)

PrefixBox.Name = "PrefixBox"
PrefixBox.Parent = Prefix
PrefixBox.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
PrefixBox.BorderSizePixel = 0
PrefixBox.Position = UDim2.new(1, -20, 0, 0)
PrefixBox.Size = UDim2.new(0, 20, 0, 20)
PrefixBox.Font = Enum.Font.SourceSansBold
PrefixBox.TextSize = 14
PrefixBox.Text = ''
PrefixBox.TextColor3 = Color3.new(0, 0, 0)
PrefixBox.ZIndex = 10
table.insert(shade3,PrefixBox)
table.insert(text2,PrefixBox)

function makeSettingsButton(name,iconID,off)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	button.BorderSizePixel = 0
	button.Position = UDim2.new(0,0,0,0)
	button.Size = UDim2.new(1,0,0,25)
	button.Text = ""
	button.ZIndex = 10
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Parent = button
	icon.Position = UDim2.new(0,5,0,5)
	icon.Size = UDim2.new(0,16,0,16)
	icon.BackgroundTransparency = 1
	icon.Image = iconID
	icon.ZIndex = 10
	if off then
		icon.ScaleType = Enum.ScaleType.Crop
		icon.ImageRectSize = Vector2.new(16,16)
		icon.ImageRectOffset = Vector2.new(off,0)
	end
	local label = Instance.new("TextLabel")
	label.Name = "ButtonLabel"
	label.Parent = button
	label.BackgroundTransparency = 1
	label.Text = name
	label.Position = UDim2.new(0,28,0,0)
	label.Size = UDim2.new(1,-28,1,0)
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.ZIndex = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(shade2,button)
	table.insert(text1,label)
	return button
end

ColorsButton = makeSettingsButton("Edit Theme",getcustomasset("infiniteyield/assets/edittheme.png"))
ColorsButton.Position = UDim2.new(0, 5, 0, 55)
ColorsButton.Size = UDim2.new(1, -10, 0, 25)
ColorsButton.Name = "Colors"
ColorsButton.Parent = SettingsHolder

Keybinds = makeSettingsButton("Edit Keybinds",getcustomasset("infiniteyield/assets/editkeybinds.png"))
Keybinds.Position = UDim2.new(0, 5, 0, 85)
Keybinds.Size = UDim2.new(1, -10, 0, 25)
Keybinds.Name = "Keybinds"
Keybinds.Parent = SettingsHolder

Aliases = makeSettingsButton("Edit Aliases",getcustomasset("infiniteyield/assets/editaliases.png"))
Aliases.Position = UDim2.new(0, 5, 0, 115)
Aliases.Size = UDim2.new(1, -10, 0, 25)
Aliases.Name = "Aliases"
Aliases.Parent = SettingsHolder

StayOpen.Name = "StayOpen"
StayOpen.Parent = SettingsHolder
StayOpen.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
StayOpen.BorderSizePixel = 0
StayOpen.BackgroundTransparency = 1
StayOpen.Position = UDim2.new(0, 5, 0, 30)
StayOpen.Size = UDim2.new(1, -10, 0, 20)
StayOpen.Font = Enum.Font.SourceSans
StayOpen.TextSize = 14
StayOpen.Text = "Keep Menu Open"
StayOpen.TextColor3 = Color3.new(1, 1, 1)
StayOpen.TextXAlignment = Enum.TextXAlignment.Left
StayOpen.ZIndex = 10
table.insert(shade2,StayOpen)
table.insert(text1,StayOpen)

Button.Name = "Button"
Button.Parent = StayOpen
Button.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Button.BorderSizePixel = 0
Button.Position = UDim2.new(1, -20, 0, 0)
Button.Size = UDim2.new(0, 20, 0, 20)
Button.ZIndex = 10
table.insert(shade3,Button)

On.Name = "On"
On.Parent = Button
On.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On.BackgroundTransparency = 1
On.BorderSizePixel = 0
On.Position = UDim2.new(0, 2, 0, 2)
On.Size = UDim2.new(0, 16, 0, 16)
On.Font = Enum.Font.SourceSans
On.FontSize = Enum.FontSize.Size14
On.Text = ""
On.TextColor3 = Color3.new(0, 0, 0)
On.ZIndex = 10

Positions = makeSettingsButton("Edit/Goto Waypoints",getcustomasset("infiniteyield/assets/editwaypoints.png"))
Positions.Position = UDim2.new(0, 5, 0, 145)
Positions.Size = UDim2.new(1, -10, 0, 25)
Positions.Name = "Waypoints"
Positions.Parent = SettingsHolder

EventBind = makeSettingsButton("Edit Event Binds",getcustomasset("infiniteyield/assets/bindsandplugins.png"),759)
EventBind.Position = UDim2.new(0, 5, 0, 205)
EventBind.Size = UDim2.new(1, -10, 0, 25)
EventBind.Name = "EventBinds"
EventBind.Parent = SettingsHolder

Plugins = makeSettingsButton("Manage Plugins",getcustomasset("infiniteyield/assets/bindsandplugins.png"),743)
Plugins.Position = UDim2.new(0, 5, 0, 175)
Plugins.Size = UDim2.new(1, -10, 0, 25)
Plugins.Name = "Plugins"
Plugins.Parent = SettingsHolder

Example.Name = "Example"
Example.Parent = Holder
Example.BackgroundTransparency = 1
Example.BorderSizePixel = 0
Example.Size = UDim2.new(0, 190, 0, 20)
Example.Visible = false
Example.Font = Enum.Font.SourceSans
Example.TextSize = 18
Example.Text = "Example"
Example.TextColor3 = Color3.new(1, 1, 1)
Example.TextXAlignment = Enum.TextXAlignment.Left
Example.ZIndex = 10
table.insert(text1,Example)

Notification.Name = randomString()
Notification.Parent = ScaledHolder
Notification.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Notification.BorderSizePixel = 0
Notification.Position = UDim2.new(1, -500, 1, 20)
Notification.Size = UDim2.new(0, 250, 0, 100)
Notification.ZIndex = 10
table.insert(shade1,Notification)

Title_2.Name = "Title"
Title_2.Parent = Notification
Title_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Title_2.BorderSizePixel = 0
Title_2.Size = UDim2.new(0, 250, 0, 20)
Title_2.Font = Enum.Font.SourceSans
Title_2.TextSize = 14
Title_2.Text = "Notification Title"
Title_2.TextColor3 = Color3.new(1, 1, 1)
Title_2.ZIndex = 10
table.insert(shade2,Title_2)
table.insert(text1,Title_2)

Text_2.Name = "Text"
Text_2.Parent = Notification
Text_2.BackgroundTransparency = 1
Text_2.BorderSizePixel = 0
Text_2.Position = UDim2.new(0, 5, 0, 25)
Text_2.Size = UDim2.new(0, 240, 0, 75)
Text_2.Font = Enum.Font.SourceSans
Text_2.TextSize = 16
Text_2.Text = "Notification Text"
Text_2.TextColor3 = Color3.new(1, 1, 1)
Text_2.TextWrapped = true
Text_2.ZIndex = 10
table.insert(text1,Text_2)

CloseButton.Name = "CloseButton"
CloseButton.Parent = Notification
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = ""
CloseButton.ZIndex = 10

CloseImage.Parent = CloseButton
CloseImage.BackgroundColor3 = Color3.new(1, 1, 1)
CloseImage.BackgroundTransparency = 1
CloseImage.Position = UDim2.new(0, 5, 0, 5)
CloseImage.Size = UDim2.new(0, 10, 0, 10)
CloseImage.Image = getcustomasset("infiniteyield/assets/close.png")
CloseImage.ZIndex = 10

PinButton.Name = "PinButton"
PinButton.Parent = Notification
PinButton.BackgroundTransparency = 1
PinButton.Size = UDim2.new(0, 20, 0, 20)
PinButton.ZIndex = 10
PinButton.Text = ""

PinImage.Parent = PinButton
PinImage.BackgroundColor3 = Color3.new(1, 1, 1)
PinImage.BackgroundTransparency = 1
PinImage.Position = UDim2.new(0, 3, 0, 3)
PinImage.Size = UDim2.new(0, 14, 0, 14)
PinImage.ZIndex = 10
PinImage.Image = getcustomasset("infiniteyield/assets/pin.png")

Tooltip.Name = randomString()
Tooltip.Parent = ScaledHolder
Tooltip.Active = true
Tooltip.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Tooltip.BackgroundTransparency = 0.1
Tooltip.BorderSizePixel = 0
Tooltip.Size = UDim2.new(0, 200, 0, 96)
Tooltip.Visible = false
Tooltip.ZIndex = 10
table.insert(shade1,Tooltip)

Title_3.Name = "Title"
Title_3.Parent = Tooltip
Title_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Title_3.BackgroundTransparency = 0.1
Title_3.BorderSizePixel = 0
Title_3.Size = UDim2.new(0, 200, 0, 20)
Title_3.Font = Enum.Font.SourceSans
Title_3.TextSize = 14
Title_3.Text = ""
Title_3.TextColor3 = Color3.new(1, 1, 1)
Title_3.TextTransparency = 0.1
Title_3.ZIndex = 10
table.insert(shade2,Title_3)
table.insert(text1,Title_3)

Description.Name = "Description"
Description.Parent = Tooltip
Description.BackgroundTransparency = 1
Description.BorderSizePixel = 0
Description.Size = UDim2.new(0,180,0,72)
Description.Position = UDim2.new(0,10,0,18)
Description.Font = Enum.Font.SourceSans
Description.TextSize = 16
Description.Text = ""
Description.TextColor3 = Color3.new(1, 1, 1)
Description.TextTransparency = 0.1
Description.TextWrapped = true
Description.ZIndex = 10
table.insert(text1,Description)

IntroBackground.Name = "IntroBackground"
IntroBackground.Parent = Holder
IntroBackground.Active = true
IntroBackground.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
IntroBackground.BorderSizePixel = 0
IntroBackground.Position = UDim2.new(0, 0, 0, 45)
IntroBackground.Size = UDim2.new(0, 250, 0, 175)
IntroBackground.ZIndex = 10

Logo.Name = "Logo"
Logo.Parent = Holder
Logo.BackgroundTransparency = 1
Logo.BorderSizePixel = 0
Logo.Position = UDim2.new(0, 125, 0, 127)
Logo.Size = UDim2.new(0, 10, 0, 10)
Logo.Image = getcustomasset("infiniteyield/assets/logo.png")
Logo.ImageTransparency = 0
Logo.ZIndex = 10

Credits.Name = "Credits"
Credits.Parent = Holder
Credits.BackgroundTransparency = 1
Credits.BorderSizePixel = 0
Credits.Position = UDim2.new(0, 0, 0.9, 30)
Credits.Size = UDim2.new(0, 250, 0, 20)
Credits.Font = Enum.Font.SourceSansLight
Credits.FontSize = Enum.FontSize.Size14
Credits.Text = "Edge // Zwolf // Moon // Toon // Peyton // ATP"
Credits.TextColor3 = Color3.new(1, 1, 1)
Credits.ZIndex = 10

KeybindsFrame.Name = "KeybindsFrame"
KeybindsFrame.Parent = Settings
KeybindsFrame.Active = true
KeybindsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
KeybindsFrame.BorderSizePixel = 0
KeybindsFrame.Position = UDim2.new(0, 0, 0, 175)
KeybindsFrame.Size = UDim2.new(0, 250, 0, 175)
KeybindsFrame.ZIndex = 10
table.insert(shade1,KeybindsFrame)

Close.Name = "Close"
Close.Parent = KeybindsFrame
Close.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 205, 0, 150)
Close.Size = UDim2.new(0, 40, 0, 20)
Close.Font = Enum.Font.SourceSans
Close.TextSize = 14
Close.Text = "Close"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.ZIndex = 10
table.insert(shade2,Close)
table.insert(text1,Close)

Add.Name = "Add"
Add.Parent = KeybindsFrame
Add.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add.BorderSizePixel = 0
Add.Position = UDim2.new(0, 5, 0, 150)
Add.Size = UDim2.new(0, 40, 0, 20)
Add.Font = Enum.Font.SourceSans
Add.TextSize = 14
Add.Text = "Add"
Add.TextColor3 = Color3.new(1, 1, 1)
Add.ZIndex = 10
table.insert(shade2,Add)
table.insert(text1,Add)

Delete.Name = "Delete"
Delete.Parent = KeybindsFrame
Delete.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete.BorderSizePixel = 0
Delete.Position = UDim2.new(0, 50, 0, 150)
Delete.Size = UDim2.new(0, 40, 0, 20)
Delete.Font = Enum.Font.SourceSans
Delete.TextSize = 14
Delete.Text = "Clear"
Delete.TextColor3 = Color3.new(1, 1, 1)
Delete.ZIndex = 10
table.insert(shade2,Delete)
table.insert(text1,Delete)

Holder_2.Name = "Holder"
Holder_2.Parent = KeybindsFrame
Holder_2.BackgroundTransparency = 1
Holder_2.BorderSizePixel = 0
Holder_2.Position = UDim2.new(0, 0, 0, 0)
Holder_2.Size = UDim2.new(0, 250, 0, 145)
Holder_2.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_2.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.ScrollBarThickness = 0
Holder_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.VerticalScrollBarInset = 'Always'
Holder_2.ZIndex = 10

Example_2.Name = "Example"
Example_2.Parent = KeybindsFrame
Example_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_2.BorderSizePixel = 0
Example_2.Size = UDim2.new(0, 10, 0, 20)
Example_2.Visible = false
Example_2.ZIndex = 10
table.insert(shade2,Example_2)

Text_3.Name = "Text"
Text_3.Parent = Example_2
Text_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_3.BorderSizePixel = 0
Text_3.Position = UDim2.new(0, 10, 0, 0)
Text_3.Size = UDim2.new(0, 240, 0, 20)
Text_3.Font = Enum.Font.SourceSans
Text_3.TextSize = 14
Text_3.Text = "nom"
Text_3.TextColor3 = Color3.new(1, 1, 1)
Text_3.TextXAlignment = Enum.TextXAlignment.Left
Text_3.ZIndex = 10
table.insert(shade2,Text_3)
table.insert(text1,Text_3)

Delete_2.Name = "Delete"
Delete_2.Parent = Text_3
Delete_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_2.BorderSizePixel = 0
Delete_2.Position = UDim2.new(0, 200, 0, 0)
Delete_2.Size = UDim2.new(0, 40, 0, 20)
Delete_2.Font = Enum.Font.SourceSans
Delete_2.TextSize = 14
Delete_2.Text = "Delete"
Delete_2.TextColor3 = Color3.new(0, 0, 0)
Delete_2.ZIndex = 10
table.insert(shade3,Delete_2)
table.insert(text2,Delete_2)

KeybindEditor.Name = randomString()
KeybindEditor.Parent = ScaledHolder
KeybindEditor.Active = true
KeybindEditor.BackgroundTransparency = 1
KeybindEditor.Position = UDim2.new(0.5, -180, 0, -500)
KeybindEditor.Size = UDim2.new(0, 360, 0, 20)
KeybindEditor.ZIndex = 10

background_2.Name = "background"
background_2.Parent = KeybindEditor
background_2.Active = true
background_2.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_2.BorderSizePixel = 0
background_2.Position = UDim2.new(0, 0, 0, 20)
background_2.Size = UDim2.new(0, 360, 0, 185)
background_2.ZIndex = 10
table.insert(shade1,background_2)

Dark_3.Name = "Dark"
Dark_3.Parent = background_2
Dark_3.Active = true
Dark_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Dark_3.BorderSizePixel = 0
Dark_3.Position = UDim2.new(0, 135, 0, 0)
Dark_3.Size = UDim2.new(0, 2, 0, 185)
Dark_3.ZIndex = 10
table.insert(shade2,Dark_3)

Directions.Name = "Directions"
Directions.Parent = background_2
Directions.BackgroundTransparency = 1
Directions.BorderSizePixel = 0
Directions.Position = UDim2.new(0, 10, 0, 15)
Directions.Size = UDim2.new(0, 115, 0, 90)
Directions.ZIndex = 10
Directions.Font = Enum.Font.SourceSans
Directions.Text = "Click the button below and press a key/mouse button. Then select what you want to bind it to."
Directions.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions.TextSize = 14.000
Directions.TextWrapped = true
Directions.TextYAlignment = Enum.TextYAlignment.Top
table.insert(text1,Directions)

BindTo.Name = "BindTo"
BindTo.Parent = background_2
BindTo.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
BindTo.BorderSizePixel = 0
BindTo.Position = UDim2.new(0, 10, 0, 95)
BindTo.Size = UDim2.new(0, 115, 0, 50)
BindTo.ZIndex = 10
BindTo.Font = Enum.Font.SourceSans
BindTo.Text = "Click to bind"
BindTo.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTo.TextSize = 16.000
table.insert(shade2,BindTo)
table.insert(text1,BindTo)

TriggerLabel.Name = "TriggerLabel"
TriggerLabel.Parent = background_2
TriggerLabel.BackgroundTransparency = 1
TriggerLabel.Position = UDim2.new(0, 10, 0, 155)
TriggerLabel.Size = UDim2.new(0, 45, 0, 20)
TriggerLabel.ZIndex = 10
TriggerLabel.Font = Enum.Font.SourceSans
TriggerLabel.Text = "Trigger:"
TriggerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TriggerLabel.TextSize = 14.000
TriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,TriggerLabel)

BindTriggerSelect.Name = "BindTo"
BindTriggerSelect.Parent = background_2
BindTriggerSelect.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
BindTriggerSelect.BorderSizePixel = 0
BindTriggerSelect.Position = UDim2.new(0, 60, 0, 155)
BindTriggerSelect.Size = UDim2.new(0, 65, 0, 20)
BindTriggerSelect.ZIndex = 10
BindTriggerSelect.Font = Enum.Font.SourceSans
BindTriggerSelect.Text = "KeyDown"
BindTriggerSelect.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTriggerSelect.TextSize = 16.000
table.insert(shade2,BindTriggerSelect)
table.insert(text1,BindTriggerSelect)

Add_2.Name = "Add"
Add_2.Parent = background_2
Add_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add_2.BorderSizePixel = 0
Add_2.Position = UDim2.new(0, 310, 0, 35)
Add_2.Size = UDim2.new(0, 40, 0, 20)
Add_2.ZIndex = 10
Add_2.Font = Enum.Font.SourceSans
Add_2.Text = "Add"
Add_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Add_2.TextSize = 14.000
table.insert(shade2,Add_2)
table.insert(text1,Add_2)

Toggles.Name = "Toggles"
Toggles.Parent = background_2
Toggles.BackgroundTransparency = 1
Toggles.BorderSizePixel = 0
Toggles.Position = UDim2.new(0, 150, 0, 125)
Toggles.Size = UDim2.new(0, 200, 0, 50)
Toggles.ZIndex = 10
Toggles.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.CanvasSize = UDim2.new(0, 0, 0, 50)
Toggles.ScrollBarThickness = 8
Toggles.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.VerticalScrollBarInset = Enum.ScrollBarInset.Always
table.insert(scroll,Toggles)

ClickTP.Name = "Click TP (Hold Key & Click)"
ClickTP.Parent = Toggles
ClickTP.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ClickTP.BorderSizePixel = 0
ClickTP.Size = UDim2.new(0, 200, 0, 20)
ClickTP.ZIndex = 10
ClickTP.Font = Enum.Font.SourceSans
ClickTP.Text = "    Click TP (Hold Key & Click)"
ClickTP.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickTP.TextSize = 14.000
ClickTP.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickTP)
table.insert(text1,ClickTP)

Select.Name = "Select"
Select.Parent = ClickTP
Select.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Select.BorderSizePixel = 0
Select.Position = UDim2.new(0, 160, 0, 0)
Select.Size = UDim2.new(0, 40, 0, 20)
Select.ZIndex = 10
Select.Font = Enum.Font.SourceSans
Select.Text = "Add"
Select.TextColor3 = Color3.fromRGB(0, 0, 0)
Select.TextSize = 14.000
table.insert(shade3,Select)
table.insert(text2,Select)

ClickDelete.Name = "Click Delete (Hold Key & Click)"
ClickDelete.Parent = Toggles
ClickDelete.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ClickDelete.BorderSizePixel = 0
ClickDelete.Position = UDim2.new(0, 0, 0, 25)
ClickDelete.Size = UDim2.new(0, 200, 0, 20)
ClickDelete.ZIndex = 10
ClickDelete.Font = Enum.Font.SourceSans
ClickDelete.Text = "    Click Delete (Hold Key & Click)"
ClickDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickDelete.TextSize = 14.000
ClickDelete.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickDelete)
table.insert(text1,ClickDelete)

Select_2.Name = "Select"
Select_2.Parent = ClickDelete
Select_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Select_2.BorderSizePixel = 0
Select_2.Position = UDim2.new(0, 160, 0, 0)
Select_2.Size = UDim2.new(0, 40, 0, 20)
Select_2.ZIndex = 10
Select_2.Font = Enum.Font.SourceSans
Select_2.Text = "Add"
Select_2.TextColor3 = Color3.fromRGB(0, 0, 0)
Select_2.TextSize = 14.000
table.insert(shade3,Select_2)
table.insert(text2,Select_2)

Cmdbar_2.Name = "Cmdbar_2"
Cmdbar_2.Parent = background_2
Cmdbar_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Cmdbar_2.BorderSizePixel = 0
Cmdbar_2.Position = UDim2.new(0, 150, 0, 35)
Cmdbar_2.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_2.ZIndex = 10
Cmdbar_2.Font = Enum.Font.SourceSans
Cmdbar_2.PlaceholderText = "Command"
Cmdbar_2.Text = ""
Cmdbar_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_2.TextSize = 14.000
Cmdbar_2.TextXAlignment = Enum.TextXAlignment.Left

Cmdbar_3.Name = "Cmdbar_3"
Cmdbar_3.Parent = background_2
Cmdbar_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Cmdbar_3.BorderSizePixel = 0
Cmdbar_3.Position = UDim2.new(0, 150, 0, 60)
Cmdbar_3.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_3.ZIndex = 10
Cmdbar_3.Font = Enum.Font.SourceSans
Cmdbar_3.PlaceholderText = "Command 2"
Cmdbar_3.Text = ""
Cmdbar_3.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_3.TextSize = 14.000
Cmdbar_3.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle.Name = "CreateToggle"
CreateToggle.Parent = background_2
CreateToggle.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
CreateToggle.BackgroundTransparency = 1
CreateToggle.BorderSizePixel = 0
CreateToggle.Position = UDim2.new(0, 152, 0, 10)
CreateToggle.Size = UDim2.new(0, 198, 0, 20)
CreateToggle.ZIndex = 10
CreateToggle.Font = Enum.Font.SourceSans
CreateToggle.Text = "Create Toggle"
CreateToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CreateToggle.TextSize = 14.000
CreateToggle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,CreateToggle)

Button_2.Name = "Button"
Button_2.Parent = CreateToggle
Button_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Button_2.BorderSizePixel = 0
Button_2.Position = UDim2.new(1, -20, 0, 0)
Button_2.Size = UDim2.new(0, 20, 0, 20)
Button_2.ZIndex = 10
table.insert(shade3,Button_2)

On_2.Name = "On"
On_2.Parent = Button_2
On_2.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On_2.BackgroundTransparency = 1
On_2.BorderSizePixel = 0
On_2.Position = UDim2.new(0, 2, 0, 2)
On_2.Size = UDim2.new(0, 16, 0, 16)
On_2.ZIndex = 10
On_2.Font = Enum.Font.SourceSans
On_2.Text = ""
On_2.TextColor3 = Color3.fromRGB(0, 0, 0)
On_2.TextSize = 14.000

shadow_2.Name = "shadow"
shadow_2.Parent = KeybindEditor
shadow_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_2.BorderSizePixel = 0
shadow_2.Size = UDim2.new(0, 360, 0, 20)
shadow_2.ZIndex = 10
table.insert(shade2,shadow_2)

PopupText_2.Name = "PopupText_2"
PopupText_2.Parent = shadow_2
PopupText_2.BackgroundTransparency = 1
PopupText_2.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText_2.ZIndex = 10
PopupText_2.Font = Enum.Font.SourceSans
PopupText_2.Text = "Set Keybinds"
PopupText_2.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupText_2.TextSize = 14.000
PopupText_2.TextWrapped = true
table.insert(text1,PopupText_2)

Exit_2.Name = "Exit_2"
Exit_2.Parent = shadow_2
Exit_2.BackgroundTransparency = 1
Exit_2.Position = UDim2.new(1, -20, 0, 0)
Exit_2.Size = UDim2.new(0, 20, 0, 20)
Exit_2.ZIndex = 10
Exit_2.Text = ""

ExitImage_2.Parent = Exit_2
ExitImage_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ExitImage_2.BackgroundTransparency = 1
ExitImage_2.Position = UDim2.new(0, 5, 0, 5)
ExitImage_2.Size = UDim2.new(0, 10, 0, 10)
ExitImage_2.ZIndex = 10
ExitImage_2.Image = getcustomasset("infiniteyield/assets/close.png")

PositionsFrame.Name = "PositionsFrame"
PositionsFrame.Parent = Settings
PositionsFrame.Active = true
PositionsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
PositionsFrame.BorderSizePixel = 0
PositionsFrame.Size = UDim2.new(0, 250, 0, 175)
PositionsFrame.Position = UDim2.new(0, 0, 0, 175)
PositionsFrame.ZIndex = 10
table.insert(shade1,PositionsFrame)

Close_3.Name = "Close"
Close_3.Parent = PositionsFrame
Close_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_3.BorderSizePixel = 0
Close_3.Position = UDim2.new(0, 205, 0, 150)
Close_3.Size = UDim2.new(0, 40, 0, 20)
Close_3.Font = Enum.Font.SourceSans
Close_3.TextSize = 14
Close_3.Text = "Close"
Close_3.TextColor3 = Color3.new(1, 1, 1)
Close_3.ZIndex = 10
table.insert(shade2,Close_3)
table.insert(text1,Close_3)

Delete_5.Name = "Delete"
Delete_5.Parent = PositionsFrame
Delete_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete_5.BorderSizePixel = 0
Delete_5.Position = UDim2.new(0, 50, 0, 150)
Delete_5.Size = UDim2.new(0, 40, 0, 20)
Delete_5.Font = Enum.Font.SourceSans
Delete_5.TextSize = 14
Delete_5.Text = "Clear"
Delete_5.TextColor3 = Color3.new(1, 1, 1)
Delete_5.ZIndex = 10
table.insert(shade2,Delete_5)
table.insert(text1,Delete_5)

Part.Name = "PartGoto"
Part.Parent = PositionsFrame
Part.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Part.BorderSizePixel = 0
Part.Position = UDim2.new(0, 5, 0, 150)
Part.Size = UDim2.new(0, 40, 0, 20)
Part.Font = Enum.Font.SourceSans
Part.TextSize = 14
Part.Text = "Part"
Part.TextColor3 = Color3.new(1, 1, 1)
Part.ZIndex = 10
table.insert(shade2,Part)
table.insert(text1,Part)

Holder_4.Name = "Holder"
Holder_4.Parent = PositionsFrame
Holder_4.BackgroundTransparency = 1
Holder_4.BorderSizePixel = 0
Holder_4.Position = UDim2.new(0, 0, 0, 0)
Holder_4.Selectable = false
Holder_4.Size = UDim2.new(0, 250, 0, 145)
Holder_4.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_4.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_4.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.ScrollBarThickness = 0
Holder_4.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.VerticalScrollBarInset = 'Always'
Holder_4.ZIndex = 10

Example_4.Name = "Example"
Example_4.Parent = PositionsFrame
Example_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_4.BorderSizePixel = 0
Example_4.Size = UDim2.new(0, 10, 0, 20)
Example_4.Visible = false
Example_4.Position = UDim2.new(0, 0, 0, -5)
Example_4.ZIndex = 10
table.insert(shade2,Example_4)

Text_5.Name = "Text"
Text_5.Parent = Example_4
Text_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_5.BorderSizePixel = 0
Text_5.Position = UDim2.new(0, 10, 0, 0)
Text_5.Size = UDim2.new(0, 240, 0, 20)
Text_5.Font = Enum.Font.SourceSans
Text_5.TextSize = 14
Text_5.Text = "Position"
Text_5.TextColor3 = Color3.new(1, 1, 1)
Text_5.TextXAlignment = Enum.TextXAlignment.Left
Text_5.ZIndex = 10
table.insert(shade2,Text_5)
table.insert(text1,Text_5)

Delete_6.Name = "Delete"
Delete_6.Parent = Text_5
Delete_6.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_6.BorderSizePixel = 0
Delete_6.Position = UDim2.new(0, 200, 0, 0)
Delete_6.Size = UDim2.new(0, 40, 0, 20)
Delete_6.Font = Enum.Font.SourceSans
Delete_6.TextSize = 14
Delete_6.Text = "Delete"
Delete_6.TextColor3 = Color3.new(0, 0, 0)
Delete_6.ZIndex = 10
table.insert(shade3,Delete_6)
table.insert(text2,Delete_6)

TP.Name = "TP"
TP.Parent = Text_5
TP.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
TP.BorderSizePixel = 0
TP.Position = UDim2.new(0, 155, 0, 0)
TP.Size = UDim2.new(0, 40, 0, 20)
TP.Font = Enum.Font.SourceSans
TP.TextSize = 14
TP.Text = "Goto"
TP.TextColor3 = Color3.new(0, 0, 0)
TP.ZIndex = 10
table.insert(shade3,TP)
table.insert(text2,TP)

AliasesFrame.Name = "AliasesFrame"
AliasesFrame.Parent = Settings
AliasesFrame.Active = true
AliasesFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
AliasesFrame.BorderSizePixel = 0
AliasesFrame.Position = UDim2.new(0, 0, 0, 175)
AliasesFrame.Size = UDim2.new(0, 250, 0, 175)
AliasesFrame.ZIndex = 10
table.insert(shade1,AliasesFrame)

Close_2.Name = "Close"
Close_2.Parent = AliasesFrame
Close_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_2.BorderSizePixel = 0
Close_2.Position = UDim2.new(0, 205, 0, 150)
Close_2.Size = UDim2.new(0, 40, 0, 20)
Close_2.Font = Enum.Font.SourceSans
Close_2.TextSize = 14
Close_2.Text = "Close"
Close_2.TextColor3 = Color3.new(1, 1, 1)
Close_2.ZIndex = 10
table.insert(shade2,Close_2)
table.insert(text1,Close_2)

Delete_3.Name = "Delete"
Delete_3.Parent = AliasesFrame
Delete_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete_3.BorderSizePixel = 0
Delete_3.Position = UDim2.new(0, 5, 0, 150)
Delete_3.Size = UDim2.new(0, 40, 0, 20)
Delete_3.Font = Enum.Font.SourceSans
Delete_3.TextSize = 14
Delete_3.Text = "Clear"
Delete_3.TextColor3 = Color3.new(1, 1, 1)
Delete_3.ZIndex = 10
table.insert(shade2,Delete_3)
table.insert(text1,Delete_3)

Holder_3.Name = "Holder"
Holder_3.Parent = AliasesFrame
Holder_3.BackgroundTransparency = 1
Holder_3.BorderSizePixel = 0
Holder_3.Position = UDim2.new(0, 0, 0, 0)
Holder_3.Size = UDim2.new(0, 250, 0, 145)
Holder_3.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_3.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.ScrollBarThickness = 0
Holder_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.VerticalScrollBarInset = 'Always'
Holder_3.ZIndex = 10

Example_3.Name = "Example"
Example_3.Parent = AliasesFrame
Example_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_3.BorderSizePixel = 0
Example_3.Size = UDim2.new(0, 10, 0, 20)
Example_3.Visible = false
Example_3.ZIndex = 10
table.insert(shade2,Example_3)

Text_4.Name = "Text"
Text_4.Parent = Example_3
Text_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_4.BorderSizePixel = 0
Text_4.Position = UDim2.new(0, 10, 0, 0)
Text_4.Size = UDim2.new(0, 240, 0, 20)
Text_4.Font = Enum.Font.SourceSans
Text_4.TextSize = 14
Text_4.Text = "honk"
Text_4.TextColor3 = Color3.new(1, 1, 1)
Text_4.TextXAlignment = Enum.TextXAlignment.Left
Text_4.ZIndex = 10
table.insert(shade2,Text_4)
table.insert(text1,Text_4)

Delete_4.Name = "Delete"
Delete_4.Parent = Text_4
Delete_4.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_4.BorderSizePixel = 0
Delete_4.Position = UDim2.new(0, 200, 0, 0)
Delete_4.Size = UDim2.new(0, 40, 0, 20)
Delete_4.Font = Enum.Font.SourceSans
Delete_4.TextSize = 14
Delete_4.Text = "Delete"
Delete_4.TextColor3 = Color3.new(0, 0, 0)
Delete_4.ZIndex = 10
table.insert(shade3,Delete_4)
table.insert(text2,Delete_4)

PluginsFrame.Name = "PluginsFrame"
PluginsFrame.Parent = Settings
PluginsFrame.Active = true
PluginsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
PluginsFrame.BorderSizePixel = 0
PluginsFrame.Position = UDim2.new(0, 0, 0, 175)
PluginsFrame.Size = UDim2.new(0, 250, 0, 175)
PluginsFrame.ZIndex = 10
table.insert(shade1,PluginsFrame)

Close_4.Name = "Close"
Close_4.Parent = PluginsFrame
Close_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_4.BorderSizePixel = 0
Close_4.Position = UDim2.new(0, 205, 0, 150)
Close_4.Size = UDim2.new(0, 40, 0, 20)
Close_4.Font = Enum.Font.SourceSans
Close_4.TextSize = 14
Close_4.Text = "Close"
Close_4.TextColor3 = Color3.new(1, 1, 1)
Close_4.ZIndex = 10
table.insert(shade2,Close_4)
table.insert(text1,Close_4)

Add_3.Name = "Add"
Add_3.Parent = PluginsFrame
Add_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add_3.BorderSizePixel = 0
Add_3.Position = UDim2.new(0, 5, 0, 150)
Add_3.Size = UDim2.new(0, 40, 0, 20)
Add_3.Font = Enum.Font.SourceSans
Add_3.TextSize = 14
Add_3.Text = "Add"
Add_3.TextColor3 = Color3.new(1, 1, 1)
Add_3.ZIndex = 10
table.insert(shade2,Add_3)
table.insert(text1,Add_3)

Holder_5.Name = "Holder"
Holder_5.Parent = PluginsFrame
Holder_5.BackgroundTransparency = 1
Holder_5.BorderSizePixel = 0
Holder_5.Position = UDim2.new(0, 0, 0, 0)
Holder_5.Selectable = false
Holder_5.Size = UDim2.new(0, 250, 0, 145)
Holder_5.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_5.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_5.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.ScrollBarThickness = 0
Holder_5.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.VerticalScrollBarInset = 'Always'
Holder_5.ZIndex = 10

Example_5.Name = "Example"
Example_5.Parent = PluginsFrame
Example_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_5.BorderSizePixel = 0
Example_5.Size = UDim2.new(0, 10, 0, 20)
Example_5.Visible = false
Example_5.ZIndex = 10
table.insert(shade2,Example_5)

Text_6.Name = "Text"
Text_6.Parent = Example_5
Text_6.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_6.BorderSizePixel = 0
Text_6.Position = UDim2.new(0, 10, 0, 0)
Text_6.Size = UDim2.new(0, 240, 0, 20)
Text_6.Font = Enum.Font.SourceSans
Text_6.TextSize = 14
Text_6.Text = "F4 > Toggle Fly"
Text_6.TextColor3 = Color3.new(1, 1, 1)
Text_6.TextXAlignment = Enum.TextXAlignment.Left
Text_6.ZIndex = 10
table.insert(shade2,Text_6)
table.insert(text1,Text_6)

Delete_7.Name = "Delete"
Delete_7.Parent = Text_6
Delete_7.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_7.BorderSizePixel = 0
Delete_7.Position = UDim2.new(0, 200, 0, 0)
Delete_7.Size = UDim2.new(0, 40, 0, 20)
Delete_7.Font = Enum.Font.SourceSans
Delete_7.TextSize = 14
Delete_7.Text = "Delete"
Delete_7.TextColor3 = Color3.new(0, 0, 0)
Delete_7.ZIndex = 10
table.insert(shade3,Delete_7)
table.insert(text2,Delete_7)

PluginEditor.Name = randomString()
PluginEditor.Parent = ScaledHolder
PluginEditor.BorderSizePixel = 0
PluginEditor.Active = true
PluginEditor.BackgroundTransparency = 1
PluginEditor.Position = UDim2.new(0.5, -180, 0, -500)
PluginEditor.Size = UDim2.new(0, 360, 0, 20)
PluginEditor.ZIndex = 10

background_3.Name = "background"
background_3.Parent = PluginEditor
background_3.Active = true
background_3.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_3.BorderSizePixel = 0
background_3.Position = UDim2.new(0, 0, 0, 20)
background_3.Size = UDim2.new(0, 360, 0, 160)
background_3.ZIndex = 10
table.insert(shade1,background_3)

Dark_2.Name = "Dark"
Dark_2.Parent = background_3
Dark_2.Active = true
Dark_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Dark_2.BorderSizePixel = 0
Dark_2.Position = UDim2.new(0, 222, 0, 0)
Dark_2.Size = UDim2.new(0, 2, 0, 160)
Dark_2.ZIndex = 10
table.insert(shade2,Dark_2)

Img.Name = "Img"
Img.Parent = background_3
Img.BackgroundTransparency = 1
Img.Position = UDim2.new(0, 242, 0, 3)
Img.Size = UDim2.new(0, 100, 0, 95)
Img.Image = getcustomasset("infiniteyield/assets/imgstudiopluginlogo.png")
Img.ZIndex = 10

AddPlugin.Name = "AddPlugin"
AddPlugin.Parent = background_3
AddPlugin.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AddPlugin.BorderSizePixel = 0
AddPlugin.Position = UDim2.new(0, 235, 0, 100)
AddPlugin.Size = UDim2.new(0, 115, 0, 50)
AddPlugin.Font = Enum.Font.SourceSans
AddPlugin.TextSize = 14
AddPlugin.Text = "Add Plugin"
AddPlugin.TextColor3 = Color3.new(1, 1, 1)
AddPlugin.ZIndex = 10
table.insert(shade2,AddPlugin)
table.insert(text1,AddPlugin)

FileName.Name = "FileName"
FileName.Parent = background_3
FileName.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
FileName.BorderSizePixel = 0
FileName.Position = UDim2.new(0.028, 0, 0.625, 0)
FileName.Size = UDim2.new(0, 200, 0, 50)
FileName.Font = Enum.Font.SourceSans
FileName.TextSize = 14
FileName.Text = "Plugin File Name"
FileName.TextColor3 = Color3.new(1, 1, 1)
FileName.ZIndex = 10
table.insert(shade2,FileName)
table.insert(text1,FileName)

About.Name = "About"
About.Parent = background_3
About.BackgroundTransparency = 1
About.BorderSizePixel = 0
About.Position = UDim2.new(0, 17, 0, 10)
About.Size = UDim2.new(0, 187, 0, 49)
About.Font = Enum.Font.SourceSans
About.TextSize = 14
About.Text = "Plugins are .iy files and should be located in the 'workspace' folder of your exploit."
About.TextColor3 = Color3.fromRGB(255, 255, 255)
About.TextWrapped = true
About.TextYAlignment = Enum.TextYAlignment.Top
About.ZIndex = 10
table.insert(text1,About)

Directions_2.Name = "Directions"
Directions_2.Parent = background_3
Directions_2.BackgroundTransparency = 1
Directions_2.BorderSizePixel = 0
Directions_2.Position = UDim2.new(0, 17, 0, 60)
Directions_2.Size = UDim2.new(0, 187, 0, 49)
Directions_2.Font = Enum.Font.SourceSans
Directions_2.TextSize = 14
Directions_2.Text = "Type the name of the plugin file you want to add below."
Directions_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions_2.TextWrapped = true
Directions_2.TextYAlignment = Enum.TextYAlignment.Top
Directions_2.ZIndex = 10
table.insert(text1,Directions_2)

shadow_3.Name = "shadow"
shadow_3.Parent = PluginEditor
shadow_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_3.BorderSizePixel = 0
shadow_3.Size = UDim2.new(0, 360, 0, 20)
shadow_3.ZIndex = 10
table.insert(shade2,shadow_3)

PopupText_3.Name = "PopupText"
PopupText_3.Parent = shadow_3
PopupText_3.BackgroundTransparency = 1
PopupText_3.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_3.ZIndex = 10
PopupText_3.Font = Enum.Font.SourceSans
PopupText_3.TextSize = 14
PopupText_3.Text = "Add Plugins"
PopupText_3.TextColor3 = Color3.new(1, 1, 1)
PopupText_3.TextWrapped = true
table.insert(text1,PopupText_3)

Exit_3.Name = "Exit"
Exit_3.Parent = shadow_3
Exit_3.BackgroundTransparency = 1
Exit_3.Position = UDim2.new(1, -20, 0, 0)
Exit_3.Size = UDim2.new(0, 20, 0, 20)
Exit_3.Text = ""
Exit_3.ZIndex = 10

ExitImage_3.Parent = Exit_3
ExitImage_3.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_3.BackgroundTransparency = 1
ExitImage_3.Position = UDim2.new(0, 5, 0, 5)
ExitImage_3.Size = UDim2.new(0, 10, 0, 10)
ExitImage_3.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_3.ZIndex = 10

AliasHint.Name = "AliasHint"
AliasHint.Parent = AliasesFrame
AliasHint.BackgroundTransparency = 1
AliasHint.BorderSizePixel = 0
AliasHint.Position = UDim2.new(0, 25, 0, 40)
AliasHint.Size = UDim2.new(0, 200, 0, 50)
AliasHint.Font = Enum.Font.SourceSansItalic
AliasHint.TextSize = 16
AliasHint.Text = "Add aliases by using the 'addalias' command"
AliasHint.TextColor3 = Color3.new(1, 1, 1)
AliasHint.TextStrokeColor3 = Color3.new(1, 1, 1)
AliasHint.TextWrapped = true
AliasHint.ZIndex = 10
table.insert(text1,AliasHint)

PluginsHint.Name = "PluginsHint"
PluginsHint.Parent = PluginsFrame
PluginsHint.BackgroundTransparency = 1
PluginsHint.BorderSizePixel = 0
PluginsHint.Position = UDim2.new(0, 25, 0, 40)
PluginsHint.Size = UDim2.new(0, 200, 0, 50)
PluginsHint.Font = Enum.Font.SourceSansItalic
PluginsHint.TextSize = 16
PluginsHint.Text = "Download plugins from the IY Discord (discord.gg/78ZuWSq)"
PluginsHint.TextColor3 = Color3.new(1, 1, 1)
PluginsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PluginsHint.TextWrapped = true
PluginsHint.ZIndex = 10
table.insert(text1,PluginsHint)

PositionsHint.Name = "PositionsHint"
PositionsHint.Parent = PositionsFrame
PositionsHint.BackgroundTransparency = 1
PositionsHint.BorderSizePixel = 0
PositionsHint.Position = UDim2.new(0, 25, 0, 40)
PositionsHint.Size = UDim2.new(0, 200, 0, 70)
PositionsHint.Font = Enum.Font.SourceSansItalic
PositionsHint.TextSize = 16
PositionsHint.Text = "Use the 'swp' or 'setwaypoint' command to add a position using your character (NOTE: Part teleports will not save)"
PositionsHint.TextColor3 = Color3.new(1, 1, 1)
PositionsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PositionsHint.TextWrapped = true
PositionsHint.ZIndex = 10
table.insert(text1,PositionsHint)

ToPartFrame.Name = randomString()
ToPartFrame.Parent = ScaledHolder
ToPartFrame.Active = true
ToPartFrame.BackgroundTransparency = 1
ToPartFrame.Position = UDim2.new(0.5, -180, 0, -500)
ToPartFrame.Size = UDim2.new(0, 360, 0, 20)
ToPartFrame.ZIndex = 10

background_4.Name = "background"
background_4.Parent = ToPartFrame
background_4.Active = true
background_4.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_4.BorderSizePixel = 0
background_4.Position = UDim2.new(0, 0, 0, 20)
background_4.Size = UDim2.new(0, 360, 0, 117)
background_4.ZIndex = 10
table.insert(shade1,background_4)

ChoosePart.Name = "ChoosePart"
ChoosePart.Parent = background_4
ChoosePart.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ChoosePart.BorderSizePixel = 0
ChoosePart.Position = UDim2.new(0, 100, 0, 55)
ChoosePart.Size = UDim2.new(0, 75, 0, 30)
ChoosePart.Font = Enum.Font.SourceSans
ChoosePart.TextSize = 14
ChoosePart.Text = "Select Part"
ChoosePart.TextColor3 = Color3.new(1, 1, 1)
ChoosePart.ZIndex = 10
table.insert(shade2,ChoosePart)
table.insert(text1,ChoosePart)

CopyPath.Name = "CopyPath"
CopyPath.Parent = background_4
CopyPath.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
CopyPath.BorderSizePixel = 0
CopyPath.Position = UDim2.new(0, 185, 0, 55)
CopyPath.Size = UDim2.new(0, 75, 0, 30)
CopyPath.Font = Enum.Font.SourceSans
CopyPath.TextSize = 14
CopyPath.Text = "Copy Path"
CopyPath.TextColor3 = Color3.new(1, 1, 1)
CopyPath.ZIndex = 10
table.insert(shade2,CopyPath)
table.insert(text1,CopyPath)

Directions_3.Name = "Directions"
Directions_3.Parent = background_4
Directions_3.BackgroundTransparency = 1
Directions_3.BorderSizePixel = 0
Directions_3.Position = UDim2.new(0, 51, 0, 17)
Directions_3.Size = UDim2.new(0, 257, 0, 32)
Directions_3.Font = Enum.Font.SourceSans
Directions_3.TextSize = 14
Directions_3.Text = 'Click on a part and then click the "Select Part" button below to set it as a teleport location'
Directions_3.TextColor3 = Color3.new(1, 1, 1)
Directions_3.TextWrapped = true
Directions_3.TextYAlignment = Enum.TextYAlignment.Top
Directions_3.ZIndex = 10
table.insert(text1,Directions_3)

Path.Name = "Path"
Path.Parent = background_4
Path.BackgroundTransparency = 1
Path.BorderSizePixel = 0
Path.Position = UDim2.new(0, 0, 0, 94)
Path.Size = UDim2.new(0, 360, 0, 16)
Path.Font = Enum.Font.SourceSansItalic
Path.TextSize = 14
Path.Text = ""
Path.TextColor3 = Color3.new(1, 1, 1)
Path.TextScaled = true
Path.TextWrapped = true
Path.TextYAlignment = Enum.TextYAlignment.Top
Path.ZIndex = 10
table.insert(text1,Path)

shadow_4.Name = "shadow"
shadow_4.Parent = ToPartFrame
shadow_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_4.BorderSizePixel = 0
shadow_4.Size = UDim2.new(0, 360, 0, 20)
shadow_4.ZIndex = 10
table.insert(shade2,shadow_4)

PopupText_5.Name = "PopupText"
PopupText_5.Parent = shadow_4
PopupText_5.BackgroundTransparency = 1
PopupText_5.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_5.ZIndex = 10
PopupText_5.Font = Enum.Font.SourceSans
PopupText_5.TextSize = 14
PopupText_5.Text = "Teleport to Part"
PopupText_5.TextColor3 = Color3.new(1, 1, 1)
PopupText_5.TextWrapped = true
table.insert(text1,PopupText_5)

Exit_4.Name = "Exit"
Exit_4.Parent = shadow_4
Exit_4.BackgroundTransparency = 1
Exit_4.Position = UDim2.new(1, -20, 0, 0)
Exit_4.Size = UDim2.new(0, 20, 0, 20)
Exit_4.Text = ""
Exit_4.ZIndex = 10

ExitImage_5.Parent = Exit_4
ExitImage_5.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_5.BackgroundTransparency = 1
ExitImage_5.Position = UDim2.new(0, 5, 0, 5)
ExitImage_5.Size = UDim2.new(0, 10, 0, 10)
ExitImage_5.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_5.ZIndex = 10

logs.Name = randomString()
logs.Parent = ScaledHolder
logs.Active = true
logs.BackgroundTransparency = 1
logs.Position = UDim2.new(0, 0, 1, 10)
logs.Size = UDim2.new(0, 338, 0, 20)
logs.ZIndex = 10

shadow.Name = "shadow"
shadow.Parent = logs
shadow.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
shadow.BorderSizePixel = 0
shadow.Position = UDim2.new(0, 0, 0.00999999978, 0)
shadow.Size = UDim2.new(0, 338, 0, 20)
shadow.ZIndex = 10
table.insert(shade2,shadow)

Hide.Name = "Hide"
Hide.Parent = shadow
Hide.BackgroundTransparency = 1
Hide.Position = UDim2.new(1, -40, 0, 0)
Hide.Size = UDim2.new(0, 20, 0, 20)
Hide.ZIndex = 10
Hide.Text = ""

ImageLabel.Parent = Hide
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.new(0, 3, 0, 3)
ImageLabel.Size = UDim2.new(0, 14, 0, 14)
ImageLabel.Image = getcustomasset("infiniteyield/assets/minimize.png")
ImageLabel.ZIndex = 10

PopupText.Name = "PopupText"
PopupText.Parent = shadow
PopupText.BackgroundTransparency = 1
PopupText.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText.ZIndex = 10
PopupText.Font = Enum.Font.SourceSans
PopupText.FontSize = Enum.FontSize.Size14
PopupText.Text = "Logs"
PopupText.TextColor3 = Color3.new(1, 1, 1)
PopupText.TextWrapped = true
table.insert(text1,PopupText)

Exit.Name = "Exit"
Exit.Parent = shadow
Exit.BackgroundTransparency = 1
Exit.Position = UDim2.new(1, -20, 0, 0)
Exit.Size = UDim2.new(0, 20, 0, 20)
Exit.ZIndex = 10
Exit.Text = ""

ImageLabel_2.Parent = Exit
ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_2.Size = UDim2.new(0, 10, 0, 10)
ImageLabel_2.Image = getcustomasset("infiniteyield/assets/close.png")
ImageLabel_2.ZIndex = 10

background.Name = "background"
background.Parent = logs
background.Active = true
background.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
background.BorderSizePixel = 0
background.ClipsDescendants = true
background.Position = UDim2.new(0, 0, 1, 0)
background.Size = UDim2.new(0, 338, 0, 245)
background.ZIndex = 10

chat.Name = "chat"
chat.Parent = background
chat.Active = true
chat.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
chat.BorderSizePixel = 0
chat.ClipsDescendants = true
chat.Size = UDim2.new(0, 338, 0, 245)
chat.ZIndex = 10
table.insert(shade1,chat)

Clear.Name = "Clear"
Clear.Parent = chat
Clear.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear.BorderSizePixel = 0
Clear.Position = UDim2.new(0, 5, 0, 220)
Clear.Size = UDim2.new(0, 50, 0, 20)
Clear.ZIndex = 10
Clear.Font = Enum.Font.SourceSans
Clear.FontSize = Enum.FontSize.Size14
Clear.Text = "Clear"
Clear.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear)
table.insert(text1,Clear)

SaveChatlogs.Name = "SaveChatlogs"
SaveChatlogs.Parent = chat
SaveChatlogs.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
SaveChatlogs.BorderSizePixel = 0
SaveChatlogs.Position = UDim2.new(0, 258, 0, 220)
SaveChatlogs.Size = UDim2.new(0, 75, 0, 20)
SaveChatlogs.ZIndex = 10
SaveChatlogs.Font = Enum.Font.SourceSans
SaveChatlogs.FontSize = Enum.FontSize.Size14
SaveChatlogs.Text = "Save To .txt"
SaveChatlogs.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,SaveChatlogs)
table.insert(text1,SaveChatlogs)

Toggle.Name = "Toggle"
Toggle.Parent = chat
Toggle.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 60, 0, 220)
Toggle.Size = UDim2.new(0, 66, 0, 20)
Toggle.ZIndex = 10
Toggle.Font = Enum.Font.SourceSans
Toggle.FontSize = Enum.FontSize.Size14
Toggle.Text = "Disabled"
Toggle.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle)
table.insert(text1,Toggle)

scroll_2.Name = "scroll"
scroll_2.Parent = chat
scroll_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_2.BorderSizePixel = 0
scroll_2.Position = UDim2.new(0, 5, 0, 25)
scroll_2.Size = UDim2.new(0, 328, 0, 190)
scroll_2.ZIndex = 10
scroll_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_2.ScrollBarThickness = 8
scroll_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_2)
table.insert(shade2,scroll_2)

join.Name = "join"
join.Parent = background
join.Active = true
join.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
join.BorderSizePixel = 0
join.ClipsDescendants = true
join.Size = UDim2.new(0, 338, 0, 245)
join.Visible = false
join.ZIndex = 10
table.insert(shade1,join)

Toggle_2.Name = "Toggle"
Toggle_2.Parent = join
Toggle_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle_2.BorderSizePixel = 0
Toggle_2.Position = UDim2.new(0, 60, 0, 220)
Toggle_2.Size = UDim2.new(0, 66, 0, 20)
Toggle_2.ZIndex = 10
Toggle_2.Font = Enum.Font.SourceSans
Toggle_2.FontSize = Enum.FontSize.Size14
Toggle_2.Text = "Disabled"
Toggle_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle_2)
table.insert(text1,Toggle_2)

Clear_2.Name = "Clear"
Clear_2.Parent = join
Clear_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear_2.BorderSizePixel = 0
Clear_2.Position = UDim2.new(0, 5, 0, 220)
Clear_2.Size = UDim2.new(0, 50, 0, 20)
Clear_2.ZIndex = 10
Clear_2.Font = Enum.Font.SourceSans
Clear_2.FontSize = Enum.FontSize.Size14
Clear_2.Text = "Clear"
Clear_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear_2)
table.insert(text1,Clear_2)

scroll_3.Name = "scroll"
scroll_3.Parent = join
scroll_3.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_3.BorderSizePixel = 0
scroll_3.Position = UDim2.new(0, 5, 0, 25)
scroll_3.Size = UDim2.new(0, 328, 0, 190)
scroll_3.ZIndex = 10
scroll_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_3.ScrollBarThickness = 8
scroll_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_3)
table.insert(shade2,scroll_3)

selectChat.Name = "selectChat"
selectChat.Parent = background
selectChat.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
selectChat.BorderSizePixel = 0
selectChat.Position = UDim2.new(0, 5, 0, 5)
selectChat.Size = UDim2.new(0, 164, 0, 20)
selectChat.ZIndex = 10
selectChat.Font = Enum.Font.SourceSans
selectChat.FontSize = Enum.FontSize.Size14
selectChat.Text = "Chat Logs"
selectChat.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,selectChat)
table.insert(text1,selectChat)

selectJoin.Name = "selectJoin"
selectJoin.Parent = background
selectJoin.BackgroundColor3 = Color3.new(0.305882, 0.305882, 0.309804)
selectJoin.BorderSizePixel = 0
selectJoin.Position = UDim2.new(0, 169, 0, 5)
selectJoin.Size = UDim2.new(0, 164, 0, 20)
selectJoin.ZIndex = 10
selectJoin.Font = Enum.Font.SourceSans
selectJoin.FontSize = Enum.FontSize.Size14
selectJoin.Text = "Join Logs"
selectJoin.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade3,selectJoin)
table.insert(text1,selectJoin)

function create(data)
	local insts = {}
	for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end

	for _,v in pairs(data) do
		for prop,val in pairs(v[3]) do
			if type(val) == "table" then
				insts[v[1]][prop] = insts[val[1]]
			else
				insts[v[1]][prop] = val
			end
		end
	end

	return insts[1]
end

ViewportTextBox = (function()

	local funcs = {}
	funcs.Update = function(self)
		local cursorPos = self.TextBox.CursorPosition
		local text = self.TextBox.Text
		if text == "" then self.TextBox.Position = UDim2.new(0,2,0,0) return end
		if cursorPos == -1 then return end

		local cursorText = text:sub(1,cursorPos-1)
		local pos = nil
		local leftEnd = -self.TextBox.Position.X.Offset
		local rightEnd = leftEnd + self.View.AbsoluteSize.X

		local totalTextSize = TextService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
		local cursorTextSize = TextService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

		if cursorTextSize > rightEnd then
			pos = math.max(-2,cursorTextSize - self.View.AbsoluteSize.X + 2)
		elseif cursorTextSize < leftEnd then
			pos = math.max(-2,cursorTextSize-2)
		elseif totalTextSize < rightEnd then
			pos = math.max(-2,totalTextSize - self.View.AbsoluteSize.X + 2)
		end

		if pos then
			self.TextBox.Position = UDim2.new(0,-pos,0,0)
			self.TextBox.Size = UDim2.new(1,pos,1,0)
		end
	end

	local mt = {}
	mt.__index = funcs

	local function convert(textbox)
		local obj = setmetatable({OffsetX = 0, TextBox = textbox},mt)

		local view = Instance.new("Frame")
		view.BackgroundTransparency = textbox.BackgroundTransparency
		view.BackgroundColor3 = textbox.BackgroundColor3
		view.BorderSizePixel = textbox.BorderSizePixel
		view.BorderColor3 = textbox.BorderColor3
		view.Position = textbox.Position
		view.Size = textbox.Size
		view.ClipsDescendants = true
		view.Name = textbox.Name
		view.ZIndex = 10
		textbox.BackgroundTransparency = 1
		textbox.Position = UDim2.new(0,4,0,0)
		textbox.Size = UDim2.new(1,-8,1,0)
		textbox.TextXAlignment = Enum.TextXAlignment.Left
		textbox.Name = "Input"
		table.insert(text1,textbox)
		table.insert(shade2,view)

		obj.View = view

		textbox.Changed:Connect(function(prop)
			if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
				obj:Update()
			end
		end)

		obj:Update()

		view.Parent = textbox.Parent
		textbox.Parent = view

		return obj
	end

	return {convert = convert}
end)()

ViewportTextBox.convert(Cmdbar).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_2).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_3).View.ZIndex = 10

function writefileExploit()
	if writefile then
		return true
	end
end

function readfileExploit()
	if readfile then
		return true
	end
end

function isNumber(str)
	if tonumber(str) ~= nil or str == "inf" then
		return true
	end
end

function vtype(o, t)
	if o == nil then return false end
	if type(o) == "userdata" then return typeof(o) == t end
	return type(o) == t
end

function getRoot(char)
	if char and char:FindFirstChildOfClass("Humanoid") then
		return char:FindFirstChildOfClass("Humanoid").RootPart
	else
		return nil
	end
end

function tools(plr)
	if plr:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or plr.Character:FindFirstChildOfClass("Tool") then
		return true
	end
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function breakVelocity()
    local V3 = Vector3.new(0, 0, 0)
    for _, v in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Velocity, v.RotVelocity = V3, V3
        end
    end
end

function toClipboard(txt)
	if everyClipboard then
		everyClipboard(tostring(txt)) -- some executor errored without tostring btw so dont call me out for this
		notify("Clipboard", "Copied to clipboard")
	else
		notify("Clipboard", "Your exploit doesn't have the ability to use the clipboard")
	end
end

function chatMessage(str)
	str = tostring(str)
	if not isLegacyChat then
		TextChatService.TextChannels.RBXGeneral:SendAsync(str)
	else
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
	end
end

function getHierarchy(obj)
	local fullname
	local period

	if string.find(obj.Name,' ') then
		fullname = '["'..obj.Name..'"]'
		period = false
	else
		fullname = obj.Name
		period = true
	end

	local getS = obj
	local parent = obj
	local service = ''

	if getS.Parent ~= game then
		repeat
			getS = getS.Parent
			service = getS.ClassName
		until getS.Parent == game
	end

	if parent.Parent ~= getS then
		repeat
			parent = parent.Parent
			if string.find(tostring(parent),' ') then
				if period then
					fullname = '["'..parent.Name..'"].'..fullname
				else
					fullname = '["'..parent.Name..'"]'..fullname
				end
				period = false
			else
				if period then
					fullname = parent.Name..'.'..fullname
				else
					fullname = parent.Name..''..fullname
				end
				period = true
			end
		until parent.Parent == getS
	elseif string.find(tostring(parent),' ') then
		fullname = '["'..parent.Name..'"]'
		period = false
	end

	if period then
		return 'game:GetService("'..service..'").'..fullname
	else
		return 'game:GetService("'..service..'")'..fullname
	end
end

AllWaypoints = {}

local cooldown = false
function writefileCooldown(name,data)
	task.spawn(function()
		if not cooldown then
			cooldown = true
			writefile(name, data, true)
		else
			repeat wait() until cooldown == false
			writefileCooldown(name,data)
		end
		wait(3)
		cooldown = false
	end)
end

function dragGUI(gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
		end
		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragGUI(logs)
dragGUI(KeybindEditor)
dragGUI(PluginEditor)
dragGUI(ToPartFrame)

eventEditor = (function()
	local events = {}

	local function registerEvent(name,sets)
		events[name] = {
			commands = {},
			sets = sets or {}
		}
	end

	local onEdited = nil

	local function fireEvent(name,...)
		local args = {...}
		local event = events[name]
		if event then
			for i,cmd in pairs(event.commands) do
				local metCondition = true
				for idx,set in pairs(event.sets) do
					local argVal = args[idx]
					local cmdSet = cmd[2][idx]
					local condType = set.Type
					if condType == "Player" then
						if cmdSet == 0 then
							metCondition = metCondition and (tostring(Players.LocalPlayer) == argVal)
						elseif cmdSet ~= 1 then
							metCondition = metCondition and table.find(getPlayer(cmdSet,Players.LocalPlayer),argVal)
						end
					elseif condType == "String" then
						if cmdSet ~= 0 then
							metCondition = metCondition and string.find(argVal:lower(),cmdSet:lower())
						end
					elseif condType == "Number" then
						if cmdSet ~= 0 then
							metCondition = metCondition and tonumber(argVal)<=tonumber(cmdSet)
						end
					end
					if not metCondition then break end
				end

				if metCondition then
					pcall(task.spawn(function()
						local cmdStr = cmd[1]
						for count,arg in pairs(args) do
							cmdStr = cmdStr:gsub("%$"..count,arg)
						end
						if cmdStr:lower():match("plugin") then return end
						wait(cmd[3] or 0)
						execCmd(cmdStr)
					end))
				end
			end
		end
	end

	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderSizePixel=0,Name="EventEditor",Position=UDim2.new(0.5,-175,0,-500),Size=UDim2.new(0,350,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=currentShade2,BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0.95,0),Text="Event Editor",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,202),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={6},Position=UDim2.new(0,5,0,5),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,-10,1,-10),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{8,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={7},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{9,"UIListLayout",{Parent={8},SortOrder=2,}},
		{10,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,ClipsDescendants=true,Name="Settings",Parent={6},Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,150,1,0),ZIndex=10,}},
		{11,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),Name="Slider",Parent={10},Position=UDim2.new(0,-150,0,0),Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.23529413342476,0.23529413342476,0.23529413342476),BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,Name="Line",Parent={11},Size=UDim2.new(0,1,1,0),ZIndex=10,}},
		{13,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={11},Position=UDim2.new(0,0,0,25),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,-25),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{14,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={13},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{15,"UIListLayout",{Parent={14},SortOrder=2,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={11},Size=UDim2.new(1,0,0,20),Text="Event Settings",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{17,"TextButton",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Font=3,Name="Close",BorderSizePixel=0,Parent={11},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="<",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{18,"Folder",{Name="Templates",Parent={10},}},
		{19,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Players",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,86),Visible=false,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={19},Size=UDim2.new(1,0,0,20),Text="Choose Players",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{21,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={19},Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-10,0,20),Text="Any Player",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{22,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={21},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{23,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={22},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{24,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Me",Parent={19},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Me Only",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{25,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={24},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{26,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={25},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{27,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={19},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Custom Player Set",Position=UDim2.new(0,5,0,64),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{28,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={19},Position=UDim2.new(1,-25,0,64),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{29,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={28},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Strings",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={30},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={30},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any String",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={32},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{34,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={33},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Numbers",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={54},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={54},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any Number",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={56},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{58,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={57},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{59,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={54},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Number",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={54},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{61,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={60},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{35,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={30},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Match String",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={30},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{37,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={36},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{38,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="DelayEditor",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,24),Visible=false,ZIndex=10,}},
		{39,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Font=3,Name="Secs",Parent={38},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),Position=UDim2.new(0,60,0,2),Size=UDim2.new(1,-65,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Label",Parent={39},Position=UDim2.new(0,-55,0,0),Size=UDim2.new(1,0,1,0),Text="Delay (s):",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{41,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="EventTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{42,"TextButton",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="Expand",Parent={41},Size=UDim2.new(0,20,0,20),Text=">",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="EventName",Parent={41},Position=UDim2.new(0,25,0,0),Size=UDim2.new(1,-25,0,20),Text="OnSpawn",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{44,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BorderSizePixel=0,BackgroundTransparency=1,ClipsDescendants=true,Name="Cmds",Parent={41},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Name="Add",Parent={44},Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{46,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={45},PlaceholderColor3=Color3.new(0.7843137383461,0.7843137383461,0.7843137383461),PlaceholderText="Add new command",Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{47,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={44},Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{48,"UIListLayout",{Parent={47},SortOrder=2,}},
		{49,"Frame",{currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="CmdTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{50,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={49},PlaceholderColor3=Color3.new(1,1,1),Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-45,0,20),Text="a\\b\\c\\d",TextColor3=currentText1,TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{51,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Delete",Parent={49},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="X",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{52,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Settings",Parent={49},Position=UDim2.new(1,-40,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{53,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/settings.png"),Parent={52},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),ZIndex=10,}},
	})
	main.Name = randomString()
	local mainFrame = main:WaitForChild("Content")
	local eventList = mainFrame:WaitForChild("List")
	local eventListHolder = eventList:WaitForChild("Holder")
	local cmdTemplate = mainFrame:WaitForChild("CmdTemplate")
	local eventTemplate = mainFrame:WaitForChild("EventTemplate")
	local settingsFrame = mainFrame:WaitForChild("Settings"):WaitForChild("Slider")
	local settingsTemplates = mainFrame.Settings:WaitForChild("Templates")
	local settingsList = settingsFrame:WaitForChild("List"):WaitForChild("Holder")
	table.insert(shade2,main.TopBar) table.insert(shade1,mainFrame) table.insert(shade2,eventTemplate)
	table.insert(text1,eventTemplate.EventName) table.insert(shade1,eventTemplate.Cmds.Add) table.insert(shade1,cmdTemplate)
	table.insert(text1,cmdTemplate.TextBox) table.insert(shade2,cmdTemplate.Delete) table.insert(shade2,cmdTemplate.Settings)
	table.insert(scroll,mainFrame.List) table.insert(shade1,settingsFrame) table.insert(shade2,settingsFrame.Line)
	table.insert(shade2,settingsFrame.Close) table.insert(scroll,settingsFrame.List) table.insert(shade2,settingsTemplates.DelayEditor.Secs)
	table.insert(text1,settingsTemplates.DelayEditor.Secs) table.insert(text1,settingsTemplates.DelayEditor.Secs.Label) table.insert(text1,settingsTemplates.Players.Title)
	table.insert(shade3,settingsTemplates.Players.CustomButton) table.insert(shade2,settingsTemplates.Players.Custom) table.insert(text1,settingsTemplates.Players.Custom)
	table.insert(shade3,settingsTemplates.Players.Any.Button) table.insert(shade3,settingsTemplates.Players.Me.Button) table.insert(text1,settingsTemplates.Players.Any)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Strings.Title) table.insert(text1,settingsTemplates.Strings.Any)
	table.insert(shade3,settingsTemplates.Strings.Any.Button) table.insert(shade3,settingsTemplates.Strings.CustomButton) table.insert(text1,settingsTemplates.Strings.Custom)
	table.insert(shade2,settingsTemplates.Strings.Custom)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Numbers.Title) table.insert(text1,settingsTemplates.Numbers.Any)
	table.insert(shade3,settingsTemplates.Numbers.Any.Button) table.insert(shade3,settingsTemplates.Numbers.CustomButton) table.insert(text1,settingsTemplates.Numbers.Custom)
	table.insert(shade2,settingsTemplates.Numbers.Custom)

	local tweenInf = TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)

	local currentlyEditingCmd = nil

	settingsFrame:WaitForChild("Close").MouseButton1Click:Connect(function()
		settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end)

	local function resizeList()
		local size = 0

		for i,v in pairs(eventListHolder:GetChildren()) do
			if v.Name == "EventTemplate" then
				size = size + 20
				if v.Expand.Rotation == 90 then
					size = size + 20*(1+(#events[v.EventName:GetAttribute("RawName")].commands or 0))
				end
			end
		end

		TweenService:Create(eventList,tweenInf,{CanvasSize = UDim2.new(0,0,0,size)}):Play()

		if size > eventList.AbsoluteSize.Y then
			eventListHolder.Size = UDim2.new(1,-8,1,0)
		else
			eventListHolder.Size = UDim2.new(1,0,1,0)
		end
	end

	local function resizeSettingsList()
		local size = 0

		for i,v in pairs(settingsList:GetChildren()) do
			if v:IsA("Frame") then
				size = size + v.AbsoluteSize.Y
			end
		end

		settingsList.Parent.CanvasSize = UDim2.new(0,0,0,size)

		if size > settingsList.Parent.AbsoluteSize.Y then
			settingsList.Size = UDim2.new(1,-8,1,0)
		else
			settingsList.Size = UDim2.new(1,0,1,0)
		end
	end

	local function setupCheckbox(button,callback)
		local enabled = button.On.BackgroundTransparency == 0

		local function update()
			button.On.BackgroundTransparency = (enabled and 0 or 1)
		end

		button.On.MouseButton1Click:Connect(function()
			enabled = not enabled
			update()
			if callback then callback(enabled) end
		end)

		return {
			Toggle = function(nocall) enabled = not enabled update() if not nocall and callback then callback(enabled) end end,
			Enable = function(nocall) if enabled then return end enabled = true update()if not nocall and callback then callback(enabled) end end,
			Disable = function(nocall) if not enabled then return end enabled = false update()if not nocall and callback then callback(enabled) end end,
			IsEnabled = function() return enabled end
		}
	end

	local function openSettingsEditor(event,cmd)
		currentlyEditingCmd = cmd

		for i,v in pairs(settingsList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		local delayEditor = settingsTemplates.DelayEditor:Clone()
		delayEditor.Secs.FocusLost:Connect(function()
			cmd[3] = tonumber(delayEditor.Secs.Text) or 0
			delayEditor.Secs.Text = cmd[3]
			if onEdited then onEdited() end
		end)
		delayEditor.Secs.Text = cmd[3]
		delayEditor.Visible = true
		table.insert(shade2,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs.Label)
		delayEditor.Parent = settingsList

		for i,v in pairs(event.sets) do
			if v.Type == "Player" then
				local template = settingsTemplates.Players:Clone()
				template.Title.Text = v.Name or "Player"

				local me,any,custom

				me = setupCheckbox(template.Me.Button,function(on)
					if not on then return end
					any.Disable()
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					me.Disable()
					custom.Disable()
					cmd[2][i] = 1
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					me.Disable()
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					me:Enable()
				elseif cVal == 1 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(shade3,template.CustomButton)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.Me.Button)
				table.insert(text1,template.Any)
				table.insert(text1,template.Me)
				template.Parent = settingsList
			elseif v.Type == "String" then
				local template = settingsTemplates.Strings:Clone()
				template.Title.Text = v.Name or "String"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			elseif v.Type == "Number" then
				local template = settingsTemplates.Numbers:Clone()
				template.Title.Text = v.Name or "Number"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					cmd[2][i] = tonumber(customTextBox.Text) or 0
					customTextBox.Text = cmd[2][i]
					if custom:IsEnabled() then
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			end
		end
		resizeSettingsList()
		settingsFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end

	local function defaultSettings(ev)
		local res = {}

		for i,v in pairs(ev.sets) do
			if v.Type == "Player" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "String" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "Number" then
				res[#res+1] = v.Default or 0
			end
		end

		return res
	end

	local function refreshList()
		for i,v in pairs(eventListHolder:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		for name,event in pairs(events) do
			local eventF = eventTemplate:Clone()
			eventF.EventName.Text = name
			eventF.Visible = true
			eventF.EventName:SetAttribute("RawName", name)
			table.insert(shade2,eventF)
			table.insert(text1,eventF.EventName)
			table.insert(shade1,eventF.Cmds.Add)

			local expanded = false
			eventF.Expand.MouseButton1Down:Connect(function()
				expanded = not expanded
				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				eventF.Expand.Rotation = expanded and 90 or 0
				resizeList()
			end)

			local function refreshCommands()
				for i,v in pairs(eventF.Cmds.Holder:GetChildren()) do
					if v.Name == "CmdTemplate" then
						v:Destroy()
					end
				end

				eventF.EventName.Text = name..(#event.commands > 0 and " ("..#event.commands..")" or "")

				for i,cmd in pairs(event.commands) do
					local cmdF = cmdTemplate:Clone()
					local cmdTextBox = cmdF.TextBox
					ViewportTextBox.convert(cmdTextBox)
					cmdTextBox.Text = cmd[1]
					cmdF.Visible = true
					table.insert(shade1,cmdF)
					table.insert(shade2,cmdF.Delete)
					table.insert(shade2,cmdF.Settings)

					cmdTextBox.FocusLost:Connect(function()
						event.commands[i] = {cmdTextBox.Text,cmd[2],cmd[3]}
						if onEdited then onEdited() end
					end)

					cmdF.Settings.MouseButton1Click:Connect(function()
						openSettingsEditor(event,cmd)
					end)

					cmdF.Delete.MouseButton1Click:Connect(function()
						table.remove(event.commands,i)
						refreshCommands()
						resizeList()

						if currentlyEditingCmd == cmd then
							settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
						end
						if onEdited then onEdited() end
					end)

					cmdF.Parent = eventF.Cmds.Holder
				end

				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			end

			local newBox = eventF.Cmds.Add.TextBox
			ViewportTextBox.convert(newBox)
			newBox.FocusLost:Connect(function(enter)
				if enter then
					event.commands[#event.commands+1] = {newBox.Text,defaultSettings(event),0}
					newBox.Text = ""

					refreshCommands()
					resizeList()
					if onEdited then onEdited() end
				end
			end)

			--eventF:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeList)

			eventF.Parent = eventListHolder

			refreshCommands()
		end

		resizeList()
	end

	local function saveData()
		local result = {}
		for i,v in pairs(events) do
			result[i] = v.commands
		end
		return HttpService:JSONEncode(result)
	end

	local function loadData(str)
		local data = HttpService:JSONDecode(str)
		for i,v in pairs(data) do
			if events[i] then
				events[i].commands = v
			end
		end
	end

	local function addCmd(event,data)
		table.insert(events[event].commands,data)
	end

	local function setOnEdited(f)
		if type(f) == "function" then
			onEdited = f
		end
	end

	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-175,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	return {
		RegisterEvent = registerEvent,
		FireEvent = fireEvent,
		Refresh = refreshList,
		SaveData = saveData,
		LoadData = loadData,
		AddCmd = addCmd,
		Frame = main,
		SetOnEdited = setOnEdited
	}
end)()

reference = (function()
	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="Main",Position=UDim2.new(0.5,-250,0,-500),Size=UDim2.new(0,500,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Size=UDim2.new(1,0,0.94999998807907,0),Text="Reference",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,300),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,1313),Name="List",Parent={6},ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,0),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",VerticalScrollBarInset=2,ZIndex=10,}},
		{8,"UIListLayout",{Parent={7},SortOrder=2,}},
		{9,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,429),ZIndex=10,}},
		{10,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={9},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Special Player Cases",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={9},Position=UDim2.new(0,8,0,25),Size=UDim2.new(1,-8,0,20),Text="These keywords can be used to quickly select groups of players in commands:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={9},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{13,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Cases",Parent={9},Position=UDim2.new(0,8,0,55),Size=UDim2.new(1,-16,0,342),ZIndex=10,}},
		{14,"UIListLayout",{Parent={13},SortOrder=2,}},
		{15,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-4,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={15},Size=UDim2.new(1,0,1,0),Text="all",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{17,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={15},Position=UDim2.new(0,15,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{18,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-3,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{19,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={18},Size=UDim2.new(1,0,1,0),Text="others",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={18},Position=UDim2.new(0,37,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone except you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{21,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-2,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{22,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={21},Size=UDim2.new(1,0,1,0),Text="me",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{23,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={21},Position=UDim2.new(0,19,0,0),Size=UDim2.new(1,0,1,0),Text="- includes your player only",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{24,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{25,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={24},Size=UDim2.new(1,0,1,0),Text="#[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{26,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={24},Position=UDim2.new(0,59,0,0),Size=UDim2.new(1,0,1,0),Text="- gets a specified amount of random players",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{27,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{28,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={27},Size=UDim2.new(1,0,1,0),Text="random",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{29,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={27},Position=UDim2.new(0,44,0,0),Size=UDim2.new(1,0,1,0),Text="- affects a random player",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={30},Size=UDim2.new(1,0,1,0),Text="%[team name]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={30},Position=UDim2.new(0,78,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone on a given team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{34,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={33},Size=UDim2.new(1,0,1,0),Text="allies / team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{35,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={33},Position=UDim2.new(0,63,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{37,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={36},Size=UDim2.new(1,0,1,0),Text="enemies / nonteam",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{38,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={36},Position=UDim2.new(0,101,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are not on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{39,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={39},Size=UDim2.new(1,0,1,0),Text="friends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{41,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={39},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{42,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={42},Size=UDim2.new(1,0,1,0),Text="nonfriends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{44,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={42},Position=UDim2.new(0,61,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is not friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{46,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={45},Size=UDim2.new(1,0,1,0),Text="guests",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{47,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={45},Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,0,1,0),Text="- guest players (obsolete)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{48,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{49,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={48},Size=UDim2.new(1,0,1,0),Text="bacons",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{50,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={48},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone with the \"bacon\" or pal hair",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{51,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{52,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={51},Size=UDim2.new(1,0,1,0),Text="age[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{53,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={51},Position=UDim2.new(0,71,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone below or at the given age",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={54},Size=UDim2.new(1,0,1,0),Text="rad[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={54},Position=UDim2.new(0,70,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone within the given radius",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{58,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={57},Size=UDim2.new(1,0,1,0),Text="nearest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{59,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={57},Position=UDim2.new(0,43,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the closest player to you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{61,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={60},Size=UDim2.new(1,0,1,0),Text="farthest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{62,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={60},Position=UDim2.new(0,46,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the farthest player from you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{63,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{64,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={63},Size=UDim2.new(1,0,1,0),Text="group[ID]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{65,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={63},Position=UDim2.new(0,55,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are in a certain group",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{66,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{67,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={66},Size=UDim2.new(1,0,1,0),Text="alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{68,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={66},Position=UDim2.new(0,27,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{69,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{70,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={69},Size=UDim2.new(1,0,1,0),Text="dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{71,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={69},Position=UDim2.new(0,29,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{72,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{73,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={72},Size=UDim2.new(1,0,1,0),Text="@username",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{74,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={72},Position=UDim2.new(0,66,0,0),Size=UDim2.new(1,0,1,0),Text="- searches for players by username only (ignores displaynames)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{75,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,180),ZIndex=10,}},
		{76,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={75},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Various Operators",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{77,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={75},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{78,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,16),Text="Use commas to separate multiple expressions:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{79,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,75),Size=UDim2.new(1,-8,0,16),Text="Use - to exclude, and + to include players in your expression:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{80,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,91),Size=UDim2.new(1,-8,0,16),Text=";locate %blue-friends (gets players in blue team who aren't your friends)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{81,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,46),Size=UDim2.new(1,-8,0,16),Text=";locate noob,noob2,bob",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{82,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,120),Size=UDim2.new(1,-8,0,16),Text="Put ! before a command to run it with the last arguments it was ran with:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{83,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,136),Size=UDim2.new(1,-8,0,32),Text="After running ;offset 0 100 0,  you can run !offset anytime to repeat that command with the same arguments that were used to run it last time",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{84,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,154),ZIndex=10,}},
		{85,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={84},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Command Looping",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{86,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="Form: [How many times it loops]^[delay (optional)]^[command]",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{87,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={84},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{88,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,50),Size=UDim2.new(1,-8,0,20),Text="Use the 'breakloops' command to stop all running loops.",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{89,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,80),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{90,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,98),Size=UDim2.new(1,-8,0,42),Text=";5^btools - gives you 5 sets of btools\n;10^3^drophats - drops your hats every 3 seconds 10 times\n;inf^0.1^animspeed 100 - infinitely loops your animation speed to 100",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{91,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,120),ZIndex=10,}},
		{92,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={91},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Execute Multiple Commands at Once",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{93,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="You can execute multiple commands at once using \"\\\"",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{94,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={91},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{95,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{96,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={91},Position=UDim2.new(0,8,0,78),Size=UDim2.new(1,-8,0,32),Text=";drophats\\respawn - drops your hats and respawns you\n;enable inventory\\enable playerlist\\refresh - enables those coregui items and refreshes you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{97,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{98,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={97},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Browse Command History",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{99,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={97},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the up and down arrow keys to browse recently used commands",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{100,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={97},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{101,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{102,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={101},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Autocomplete in the Command Bar",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{103,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={101},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the tab key to insert the top suggested command into the command bar.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{104,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={101},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{105,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,175),ZIndex=10,}},
		{106,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={105},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Using Event Binds",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{107,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="Use event binds to set up commands that get executed when certain events happen. You can edit the conditions for an event command to run (such as which player triggers it).",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{108,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={105},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{109,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,70),Size=UDim2.new(1,-8,0,48),Text="Some events may send arguments; you can use them in your event command by using $ followed by the argument number ($1, $2, etc). You can find out the order and types of these arguments by looking at the settings of the event command.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{110,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={105},Position=UDim2.new(0,8,0,130),Size=UDim2.new(1,-8,0,16),Text="Example:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{111,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,148),Size=UDim2.new(1,-8,0,16),Text="Setting up 'goto $1' on the OnChatted event will teleport you to any player that chats.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{112,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,105),ZIndex=10,}},
		{113,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={112},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Get Further Help",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{114,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={112},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="You can join the Discord server to get support with IY,  and read up on more documentation such as the Plugin API.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{115,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={112},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),Visible=false,ZIndex=10,}},
		{116,"TextButton",{BackgroundColor3=Color3.new(0.48627451062202,0.61960786581039,0.85098040103912),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Font=4,Name="InviteButton",Parent={112},Position=UDim2.new(0,5,0,75),Size=UDim2.new(1,-10,0,25),Text="Copy Discord Invite Link (https://discord.gg/78ZuWSq)",TextColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),TextSize=16,ZIndex=10,}},
	})
	for i,v in pairs(main.Content.List:GetDescendants()) do
		if v:IsA("TextLabel") then
			table.insert(text1,v)
		end
	end
	table.insert(scroll,main.Content.List)
	table.insert(shade1,main.Content)
	table.insert(shade2,main.TopBar)
	main.Name = randomString()
	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	local inviteButton = main:FindFirstChild("InviteButton",true)
	local lastPress = nil
	inviteButton.MouseButton1Click:Connect(function()
		if everyClipboard then
			toClipboard("https://discord.gg/78ZuWSq")
			inviteButton.Text = "Copied"
		else
			inviteButton.Text = "No Clipboard Function, type out the link"
		end
		local pressTime = tick()
		lastPress = pressTime
		wait(2)
		if lastPress ~= pressTime then return end
		inviteButton.Text = "Copy Discord Invite Link (https://discord.gg/78ZuWSq)"
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	ReferenceButton.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0.5,-150), "InOut", "Quart", 0.5, true, nil)
	end)
end)()

currentShade1 = Color3.fromRGB(36, 36, 37)
currentShade2 = Color3.fromRGB(46, 46, 47)
currentShade3 = Color3.fromRGB(78, 78, 79)
currentText1 = Color3.new(1, 1, 1)
currentText2 = Color3.new(0, 0, 0)
currentScroll = Color3.fromRGB(78,78,79)

defaultGuiScale = IsOnMobile and 0.9 or 1
defaultsettings = {
	prefix = ';';
	StayOpen = false;
	guiScale = defaultGuiScale;
	espTransparency = 0.3;
	keepIY = true;
	logsEnabled = false;
	jLogsEnabled = false;
	aliases = {};
	binds = {};
	WayPoints = {};
	PluginsTable = {};
	currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
	currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
	currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
	currentText1 = {currentText1.R,currentText1.G,currentText1.B};
	currentText2 = {currentText2.R,currentText2.G,currentText2.B};
	currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
	eventBinds = eventEditor.SaveData()
}

defaults = HttpService:JSONEncode(defaultsettings)
nosaves = false
useFactorySettings = function()
	prefix = ';'
	StayOpen = false
	guiScale = defaultGuiScale
	KeepInfYield = true
	espTransparency = 0.3
	logsEnabled = false
	jLogsEnabled = false
	logsWebhook = nil
	aliases = {}
	binds = {}
	WayPoints = {}
	PluginsTable = {}
end

function createPopup(title, text)
	local Popup = Instance.new("Frame")
	local background = Instance.new("Frame")
	local Directions = Instance.new("TextLabel")
	local shadow = Instance.new("Frame")
	local PopupText = Instance.new("TextLabel")
	local Exit = Instance.new("TextButton")
	local ExitImage = Instance.new("ImageLabel")

	Popup.Name = randomString()
	Popup.Parent = ScaledHolder
	Popup.Active = true
	Popup.BackgroundTransparency = 1
	Popup.Position = UDim2.new(0.5, -180, 0, -500)
	Popup.Size = UDim2.new(0, 360, 0, 20)
	Popup.ZIndex = 10

	background.Name = "background"
	background.Parent = Popup
	background.Active = true
	background.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
	background.BorderSizePixel = 0
	background.Position = UDim2.new(0, 0, 0, 20)
	background.Size = UDim2.new(0, 360, 0, 205)
	background.ZIndex = 10

	Directions.Name = "Directions"
	Directions.Parent = background
	Directions.BackgroundTransparency = 1
	Directions.BorderSizePixel = 0
	Directions.Position = UDim2.new(0, 10, 0, 10)
	Directions.Size = UDim2.new(0, 340, 0, 185)
	Directions.Font = Enum.Font.SourceSans
	Directions.TextSize = 14
	Directions.Text = text
	Directions.TextColor3 = Color3.new(1, 1, 1)
	Directions.TextWrapped = true
	Directions.TextXAlignment = Enum.TextXAlignment.Left
	Directions.TextYAlignment = Enum.TextYAlignment.Top
	Directions.ZIndex = 10

	shadow.Name = "shadow"
	shadow.Parent = Popup
	shadow.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	shadow.BorderSizePixel = 0
	shadow.Size = UDim2.new(0, 360, 0, 20)
	shadow.ZIndex = 10

	PopupText.Name = "PopupText"
	PopupText.Parent = shadow
	PopupText.BackgroundTransparency = 1
	PopupText.Size = UDim2.new(1, 0, 0.95, 0)
	PopupText.ZIndex = 10
	PopupText.Font = Enum.Font.SourceSans
	PopupText.TextSize = 14
	PopupText.Text = title
	PopupText.TextColor3 = Color3.new(1, 1, 1)
	PopupText.TextWrapped = true

	Exit.Name = "Exit"
	Exit.Parent = shadow
	Exit.BackgroundTransparency = 1
	Exit.Position = UDim2.new(1, -20, 0, 0)
	Exit.Size = UDim2.new(0, 20, 0, 20)
	Exit.Text = ""
	Exit.ZIndex = 10

	ExitImage.Parent = Exit
	ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
	ExitImage.BackgroundTransparency = 1
	ExitImage.Position = UDim2.new(0, 5, 0, 5)
	ExitImage.Size = UDim2.new(0, 10, 0, 10)
	ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
	ExitImage.ZIndex = 10

	Popup:TweenPosition(UDim2.new(0.5, -180, 0, 150), "InOut", "Quart", 0.5, true, nil)

	Exit.MouseButton1Click:Connect(function()
		Popup:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
		task.wait(0.6)
		Popup:Destroy()
	end)
end

local loadedEventData = nil
local jsonAttempts = 0
function saves()
	if writefileExploit() and readfileExploit() and jsonAttempts < 10 then
		local readSuccess, out = readfile("IY_FE.iy", true)
		if readSuccess then
			if out ~= nil and tostring(out):gsub("%s", "") ~= "" then
				local success, response = pcall(function()
					local json = HttpService:JSONDecode(out)
					if vtype(json.prefix, "string") then prefix = json.prefix else prefix = ';' end
					if vtype(json.StayOpen, "boolean") then StayOpen = json.StayOpen else StayOpen = false end
					if vtype(json.guiScale, "number") then guiScale = json.guiScale else guiScale = defaultGuiScale end
					if vtype(json.keepIY, "boolean") then KeepInfYield = json.keepIY else KeepInfYield = true end
					if vtype(json.espTransparency, "number") then espTransparency = json.espTransparency else espTransparency = 0.3 end
					if vtype(json.logsEnabled, "boolean") then logsEnabled = json.logsEnabled else logsEnabled = false end
					if vtype(json.jLogsEnabled, "boolean") then jLogsEnabled = json.jLogsEnabled else jLogsEnabled = false end
					if vtype(json.logsWebhook, "string") then logsWebhook = json.logsWebhook else logsWebhook = nil end
					if vtype(json.aliases, "table") then aliases = json.aliases else aliases = {} end
					if vtype(json.binds, "table") then binds = json.binds else binds = {} end
					if vtype(json.spawnCmds, "table") then spawnCmds = json.spawnCmds end
					if vtype(json.WayPoints, "table") then AllWaypoints = json.WayPoints else WayPoints = {} AllWaypoints = {} end
					if vtype(json.PluginsTable, "table") then PluginsTable = json.PluginsTable else PluginsTable = {} end
					if vtype(json.currentShade1, "table") then currentShade1 = Color3.new(json.currentShade1[1],json.currentShade1[2],json.currentShade1[3]) end
					if vtype(json.currentShade2, "table") then currentShade2 = Color3.new(json.currentShade2[1],json.currentShade2[2],json.currentShade2[3]) end
					if vtype(json.currentShade3, "table") then currentShade3 = Color3.new(json.currentShade3[1],json.currentShade3[2],json.currentShade3[3]) end
					if vtype(json.currentText1, "table") then currentText1 = Color3.new(json.currentText1[1],json.currentText1[2],json.currentText1[3]) end
					if vtype(json.currentText2, "table") then currentText2 = Color3.new(json.currentText2[1],json.currentText2[2],json.currentText2[3]) end
					if vtype(json.currentScroll, "table") then currentScroll = Color3.new(json.currentScroll[1],json.currentScroll[2],json.currentScroll[3]) end
					if vtype(json.eventBinds, "string") then loadedEventData = json.eventBinds end
				end)
				if not success then
					jsonAttempts = jsonAttempts + 1
					warn("Save Json Error:", response)
					warn("Overwriting Save File")
					writefile("IY_FE.iy", defaults, true)
					wait()
					saves()
				end
			else
				writefile("IY_FE.iy", defaults, true)
				wait()
				local dReadSuccess, dOut = readfile("IY_FE.iy", true)
				if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
					saves()
				else
					nosaves = true
					useFactorySettings()
					createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
				end
			end
		else
			writefile("IY_FE.iy", defaults, true)
			wait()
			local dReadSuccess, dOut = readfile("IY_FE.iy", true)
			if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
				saves()
			else
				nosaves = true
				useFactorySettings()
				createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
			end
		end
	else
		if jsonAttempts >= 10 then
			nosaves = true
			useFactorySettings()
			createPopup("File Error", "Sorry, we have attempted to parse your save file, but it is unreadable!\n\nInfinite Yield is now using factory settings until your exploit's file system works.\n\nYour save file has not been deleted.")
		else
			nosaves = true
			useFactorySettings()
		end
	end
end

saves()

function updatesaves()
	if nosaves == false and writefileExploit() then
		local update = {
			prefix = prefix;
			StayOpen = StayOpen;
			guiScale = guiScale;
			keepIY = KeepInfYield;
			espTransparency = espTransparency;
			logsEnabled = logsEnabled;
			jLogsEnabled = jLogsEnabled;
			logsWebhook = logsWebhook;
			aliases = aliases;
			binds = binds or {};
			WayPoints = AllWaypoints;
			PluginsTable = PluginsTable;
			currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
			currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
			currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
			currentText1 = {currentText1.R,currentText1.G,currentText1.B};
			currentText2 = {currentText2.R,currentText2.G,currentText2.B};
			currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
			eventBinds = eventEditor.SaveData()
		}
		writefileCooldown("IY_FE.iy", HttpService:JSONEncode(update))
	end
end

eventEditor.SetOnEdited(updatesaves)

pWayPoints = {}
WayPoints = {}

if #AllWaypoints > 0 then
	for i = 1, #AllWaypoints do
		if not AllWaypoints[i].GAME or AllWaypoints[i].GAME == PlaceId then
			WayPoints[#WayPoints + 1] = {NAME = AllWaypoints[i].NAME, COORD = {AllWaypoints[i].COORD[1], AllWaypoints[i].COORD[2], AllWaypoints[i].COORD[3]}, GAME = AllWaypoints[i].GAME}
		end
	end
end

if type(binds) ~= "table" then binds = {} end

if type(PluginsTable) == "table" then
	for i = #PluginsTable, 1, -1 do
		if string.sub(PluginsTable[i], -3) ~= ".iy" then
			table.remove(PluginsTable, i)
		end
	end
end

function Time()
	local HOUR = math.floor((tick() % 86400) / 3600)
	local MINUTE = math.floor((tick() % 3600) / 60)
	local SECOND = math.floor(tick() % 60)
	local AP = HOUR > 11 and 'PM' or 'AM'
	HOUR = (HOUR % 12 == 0 and 12 or HOUR % 12)
	HOUR = HOUR < 10 and '0' .. HOUR or HOUR
	MINUTE = MINUTE < 10 and '0' .. MINUTE or MINUTE
	SECOND = SECOND < 10 and '0' .. SECOND or SECOND
	return HOUR .. ':' .. MINUTE .. ':' .. SECOND .. ' ' .. AP
end

PrefixBox.Text = prefix
local SettingsOpen = false
local isHidden = false

if StayOpen == false then
	On.BackgroundTransparency = 1
else
	On.BackgroundTransparency = 0
end

if logsEnabled then
	Toggle.Text = 'Enabled'
else
	Toggle.Text = 'Disabled'
end

if jLogsEnabled then
	Toggle_2.Text = 'Enabled'
else
	Toggle_2.Text = 'Disabled'
end

function maximizeHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -220), "InOut", "Quart", 0.2, true, nil)
	end
end

minimizeNum = -20
function minimizeHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, minimizeNum), "InOut", "Quart", 0.5, true, nil)
	end
end

function cmdbarHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -45), "InOut", "Quart", 0.5, true, nil)
	end
end

pinNotification = nil
local notifyCount = 0
function notify(text,text2,length)
	task.spawn(function()
		local LnotifyCount = notifyCount+1
		local notificationPinned = false
		notifyCount = notifyCount+1
		if pinNotification then pinNotification:Disconnect() end
		pinNotification = PinButton.MouseButton1Click:Connect(function()
			task.spawn(function()
				pinNotification:Disconnect()
				notificationPinned = true
				Title_2.BackgroundTransparency = 1
				wait(0.5)
				Title_2.BackgroundTransparency = 0
			end)
		end)
		Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.6)
		local closepressed = false
		if text2 then
			Title_2.Text = text
			Text_2.Text = text2
		else
			Title_2.Text = 'Notification'
			Text_2.Text = text
		end
		Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, -100), "InOut", "Quart", 0.5, true, nil)
		CloseButton.MouseButton1Click:Connect(function()
			Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
			closepressed = true
			pinNotification:Disconnect()
		end)
		if length and isNumber(length) then
			wait(length)
		else
			wait(10)
		end
		if LnotifyCount == notifyCount then
			if closepressed == false and notificationPinned == false then
				pinNotification:Disconnect()
				Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
			end
			notifyCount = 0
		end
	end)
end

local lastMessage = nil
local lastLabel = nil
local dupeCount = 1
function CreateLabel(Name, Text)
	if lastMessage == Name..Text then
		dupeCount = dupeCount+1
		lastLabel.Text = Time()..' - ['..Name..']: '..Text..' (x'..dupeCount..')'
	else
		if dupeCount > 1 then dupeCount = 1 end
		if #scroll_2:GetChildren() >= 2546 then
			scroll_2:ClearAllChildren()
		end
		local alls = 0
		for i,v in pairs(scroll_2:GetChildren()) do
			if v then
				alls = v.Size.Y.Offset + alls
			end
			if not v then
				alls = 0
			end
		end
		local tl = Instance.new('TextLabel')
		lastMessage = Name..Text
		lastLabel = tl
		tl.Name = Name
		tl.Parent = scroll_2
		tl.ZIndex = 10
		tl.RichText = true
		tl.Text = Time().." - ["..Name.."]: "..Text
		tl.Text = tl.ContentText
		tl.Size = UDim2.new(0,322,0,84)
		tl.BackgroundTransparency = 1
		tl.BorderSizePixel = 0
		tl.Font = "SourceSans"
		tl.Position = UDim2.new(-1,0,0,alls)
		tl.TextTransparency = 1
		tl.TextScaled = false
		tl.TextSize = 14
		tl.TextWrapped = true
		tl.TextXAlignment = "Left"
		tl.TextYAlignment = "Top"
		tl.TextColor3 = currentText1
		tl.Size = UDim2.new(0,322,0,tl.TextBounds.Y)
		table.insert(text1,tl)
		scroll_2.CanvasSize = UDim2.new(0,0,0,alls+tl.TextBounds.Y)
		scroll_2.CanvasPosition = Vector2.new(0,scroll_2.CanvasPosition.Y+tl.TextBounds.Y)
		tl:TweenPosition(UDim2.new(0,3,0,alls), 'In', 'Quint', 0.5)
		TweenService:Create(tl, TweenInfo.new(1.25, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
	end
end

function CreateJoinLabel(player, userId)
    if #scroll_3:GetChildren() >= 2546 then
        scroll_3:ClearAllChildren()
    end
    local infoFrame = Instance.new("Frame")
    local info1 = Instance.new("TextLabel")
    local info2 = Instance.new("TextLabel")
    local ImageLabel_3 = Instance.new("ImageLabel")
    infoFrame.Name = randomString()
    infoFrame.Parent = scroll_3
    infoFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    infoFrame.BackgroundTransparency = 1
    infoFrame.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
    infoFrame.Size = UDim2.new(1, 0, 0, 50)
    info1.Name = randomString()
    info1.Parent = infoFrame
    info1.BackgroundTransparency = 1
    info1.BorderSizePixel = 0
    info1.Position = UDim2.new(0, 45, 0, 0)
    info1.Size = UDim2.new(0, 135, 1, 0)
    info1.ZIndex = 10
    info1.Font = Enum.Font.SourceSans
    info1.FontSize = Enum.FontSize.Size14
    info1.Text = "Username: " .. player.Name .. "\nJoined Server: " .. Time()
    info1.TextColor3 = Color3.new(1, 1, 1)
    info1.TextWrapped = true
    info1.TextXAlignment = Enum.TextXAlignment.Left
    info2.Name = randomString()
    info2.Parent = infoFrame
    info2.BackgroundTransparency = 1
    info2.BorderSizePixel = 0
    info2.Position = UDim2.new(0, 185, 0, 0)
    info2.Size = UDim2.new(0, 140, 1, -5)
    info2.ZIndex = 10
    info2.Font = Enum.Font.SourceSans
    info2.FontSize = Enum.FontSize.Size14
    info2.Text = "User ID: " .. userId .. "\nAccount Age: " .. player.AccountAge .. "\nJoined Roblox: Loading..."
    info2.TextColor3 = Color3.new(1, 1, 1)
    info2.TextWrapped = true
    info2.TextXAlignment = Enum.TextXAlignment.Left
    info2.TextYAlignment = Enum.TextYAlignment.Center
    ImageLabel_3.Parent = infoFrame
    ImageLabel_3.BackgroundTransparency = 1
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.Size = UDim2.new(0, 45, 1, 0)
    ImageLabel_3.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
    scroll_3.CanvasSize = UDim2.new(0, 0, 0, listlayout.AbsoluteContentSize.Y)
    scroll_3.CanvasPosition = Vector2.new(0, scroll_2.CanvasPosition.Y + infoFrame.AbsoluteSize.Y)
    local date = os.date("!%Y-%m-%d", os.time() - (player.AccountAge * 86400))
    local splitDates = string.split(date, "-")
    info2.Text = string.gsub(info2.Text, "Loading...", splitDates[2] .. "/" .. splitDates[3] .. "/" .. splitDates[1])
end

IYMouse.KeyDown:Connect(function(Key)
	-- The custom bottom command bar owns the prefix shortcut when it exists.
	-- Letting the legacy bar capture focus as well races the new bar on `;`.
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui and playerGui:FindFirstChild("IYQuickCommandBar") then return end
	-- With the classic window hidden, its bar would take every key press while showing nothing.
	if not Holder.Visible then return end
	if (Key==prefix) then
		RunService.RenderStepped:Wait()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end
end)

local lastMinimizeReq = 0
Holder.MouseEnter:Connect(function()
	lastMinimizeReq = 0
	maximizeHolder()
end)

Holder.MouseLeave:Connect(function()
	if not Cmdbar:IsFocused() then
		local reqTime = tick()
		lastMinimizeReq = reqTime
		wait(1)
		if lastMinimizeReq ~= reqTime then return end
		if not Cmdbar:IsFocused() then
			minimizeHolder()
		end
	end
end)

function updateColors(color,ctype)
	if ctype == shade1 then
		for i,v in pairs(shade1) do
			v.BackgroundColor3 = color
		end
		currentShade1 = color
	elseif ctype == shade2 then
		for i,v in pairs(shade2) do
			v.BackgroundColor3 = color
		end
		currentShade2 = color
	elseif ctype == shade3 then
		for i,v in pairs(shade3) do
			v.BackgroundColor3 = color
		end
		currentShade3 = color
	elseif ctype == text1 then
		for i,v in pairs(text1) do
			v.TextColor3 = color
			if v:IsA("TextBox") then
				v.PlaceholderColor3 = color	
			end
		end
		currentText1 = color
	elseif ctype == text2 then
		for i,v in pairs(text2) do
			v.TextColor3 = color
		end
		currentText2 = color
	elseif ctype == scroll then
		for i,v in pairs(scroll) do
			v.ScrollBarImageColor3 = color
		end
		currentScroll = color
	end
end

local colorpickerOpen = false
ColorsButton.MouseButton1Click:Connect(function()
	cache_currentShade1 = currentShade1
	cache_currentShade2 = currentShade2
	cache_currentShade3 = currentShade3
	cache_currentText1 = currentText1
	cache_currentText2 = currentText2
	cache_currentScroll = currentScroll
	if not colorpickerOpen then
		colorpickerOpen = true
		picker = game:GetObjects("rbxassetid://4908465318")[1]
		picker.Name = randomString()
		picker.Parent = ScaledHolder

		local ColorPicker do
			ColorPicker = {}

			ColorPicker.new = function()
				local newMt = setmetatable({},{})

				local pickerGui = picker.ColorPicker
				local pickerTopBar = pickerGui.TopBar
				local pickerExit = pickerTopBar.Exit
				local pickerFrame = pickerGui.Content
				local colorSpace = pickerFrame.ColorSpaceFrame.ColorSpace
				local colorStrip = pickerFrame.ColorStrip
				local previewFrame = pickerFrame.Preview
				local basicColorsFrame = pickerFrame.BasicColors
				local customColorsFrame = pickerFrame.CustomColors
				local defaultButton = pickerFrame.Default
				local cancelButton = pickerFrame.Cancel
				local shade1Button = pickerFrame.Shade1
				local shade2Button = pickerFrame.Shade2
				local shade3Button = pickerFrame.Shade3
				local text1Button = pickerFrame.Text1
				local text2Button = pickerFrame.Text2
				local scrollButton = pickerFrame.Scroll

				local colorScope = colorSpace.Scope
				local colorArrow = pickerFrame.ArrowFrame.Arrow

				local hueInput = pickerFrame.Hue.Input
				local satInput = pickerFrame.Sat.Input
				local valInput = pickerFrame.Val.Input

				local redInput = pickerFrame.Red.Input
				local greenInput = pickerFrame.Green.Input
				local blueInput = pickerFrame.Blue.Input

				local mouse = IYMouse

				local hue,sat,val = 0,0,1
				local red,green,blue = 1,1,1
				local chosenColor = Color3.new(0,0,0)

				local basicColors = {Color3.new(0,0,0),Color3.new(0.66666668653488,0,0),Color3.new(0,0.33333334326744,0),Color3.new(0.66666668653488,0.33333334326744,0),Color3.new(0,0.66666668653488,0),Color3.new(0.66666668653488,0.66666668653488,0),Color3.new(0,1,0),Color3.new(0.66666668653488,1,0),Color3.new(0,0,0.49803924560547),Color3.new(0.66666668653488,0,0.49803924560547),Color3.new(0,0.33333334326744,0.49803924560547),Color3.new(0.66666668653488,0.33333334326744,0.49803924560547),Color3.new(0,0.66666668653488,0.49803924560547),Color3.new(0.66666668653488,0.66666668653488,0.49803924560547),Color3.new(0,1,0.49803924560547),Color3.new(0.66666668653488,1,0.49803924560547),Color3.new(0,0,1),Color3.new(0.66666668653488,0,1),Color3.new(0,0.33333334326744,1),Color3.new(0.66666668653488,0.33333334326744,1),Color3.new(0,0.66666668653488,1),Color3.new(0.66666668653488,0.66666668653488,1),Color3.new(0,1,1),Color3.new(0.66666668653488,1,1),Color3.new(0.33333334326744,0,0),Color3.new(1,0,0),Color3.new(0.33333334326744,0.33333334326744,0),Color3.new(1,0.33333334326744,0),Color3.new(0.33333334326744,0.66666668653488,0),Color3.new(1,0.66666668653488,0),Color3.new(0.33333334326744,1,0),Color3.new(1,1,0),Color3.new(0.33333334326744,0,0.49803924560547),Color3.new(1,0,0.49803924560547),Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Color3.new(1,0.33333334326744,0.49803924560547),Color3.new(0.33333334326744,0.66666668653488,0.49803924560547),Color3.new(1,0.66666668653488,0.49803924560547),Color3.new(0.33333334326744,1,0.49803924560547),Color3.new(1,1,0.49803924560547),Color3.new(0.33333334326744,0,1),Color3.new(1,0,1),Color3.new(0.33333334326744,0.33333334326744,1),Color3.new(1,0.33333334326744,1),Color3.new(0.33333334326744,0.66666668653488,1),Color3.new(1,0.66666668653488,1),Color3.new(0.33333334326744,1,1),Color3.new(1,1,1)}
				local customColors = {}

				dragGUI(picker)

				local function updateColor(noupdate)
					local relativeX,relativeY,relativeStripY = 219 - hue*219, 199 - sat*199, 199 - val*199
					local hsvColor = Color3.fromHSV(hue,sat,val)

					if noupdate == 2 or not noupdate then
						hueInput.Text = tostring(math.ceil(359*hue))
						satInput.Text = tostring(math.ceil(255*sat))
						valInput.Text = tostring(math.floor(255*val))
					end
					if noupdate == 1 or not noupdate then
						redInput.Text = tostring(math.floor(255*red))
						greenInput.Text = tostring(math.floor(255*green))
						blueInput.Text = tostring(math.floor(255*blue))
					end

					chosenColor = Color3.new(red,green,blue)

					colorScope.Position = UDim2.new(0,relativeX-9,0,relativeY-9)
					colorStrip.ImageColor3 = Color3.fromHSV(hue,sat,1)
					colorArrow.Position = UDim2.new(0,-2,0,relativeStripY-4)
					previewFrame.BackgroundColor3 = chosenColor

					newMt.Color = chosenColor
					if newMt.Changed then newMt:Changed(chosenColor) end
				end

				local function colorSpaceInput()
					local relativeX = mouse.X - colorSpace.AbsolutePosition.X
					local relativeY = mouse.Y - colorSpace.AbsolutePosition.Y

					if relativeX < 0 then relativeX = 0 elseif relativeX > 219 then relativeX = 219 end
					if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end

					hue = (219 - relativeX)/219
					sat = (199 - relativeY)/199

					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					updateColor()
				end

				local function colorStripInput()
					local relativeY = mouse.Y - colorStrip.AbsolutePosition.Y

					if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end	

					val = (199 - relativeY)/199

					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					updateColor()
				end

				local function hookButtons(frame,func)
					frame.ArrowFrame.Up.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Up.BackgroundTransparency = 0.5
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							local releaseEvent,runEvent

							local startTime = tick()
							local pressing = true
							local startNum = tonumber(frame.Text)

							if not startNum then return end

							releaseEvent = UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
								releaseEvent:Disconnect()
								pressing = false
							end)

							startNum = startNum + 1
							func(startNum)
							while pressing do
								if tick()-startTime > 0.3 then
									startNum = startNum + 1
									func(startNum)
								end
								wait(0.1)
							end
						end
					end)

					frame.ArrowFrame.Up.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Up.BackgroundTransparency = 1
						end
					end)

					frame.ArrowFrame.Down.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Down.BackgroundTransparency = 0.5
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							local releaseEvent,runEvent

							local startTime = tick()
							local pressing = true
							local startNum = tonumber(frame.Text)

							if not startNum then return end

							releaseEvent = UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
								releaseEvent:Disconnect()
								pressing = false
							end)

							startNum = startNum - 1
							func(startNum)
							while pressing do
								if tick()-startTime > 0.3 then
									startNum = startNum - 1
									func(startNum)
								end
								wait(0.1)
							end
						end
					end)

					frame.ArrowFrame.Down.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Down.BackgroundTransparency = 1
						end
					end)
				end

				colorSpace.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent

						releaseEvent = UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
						end)

						mouseEvent = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								colorSpaceInput()
							end
						end)

						colorSpaceInput()
					end
				end)

				colorStrip.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent

						releaseEvent = UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
						end)

						mouseEvent = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								colorStripInput()
							end
						end)

						colorStripInput()
					end
				end)

				local function updateHue(str)
					local num = tonumber(str)
					if num then
						hue = math.clamp(math.floor(num),0,359)/359
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						hueInput.Text = tostring(hue*359)
						updateColor(1)
					end
				end
				hueInput.FocusLost:Connect(function() updateHue(hueInput.Text) end) hookButtons(hueInput,updateHue)

				local function updateSat(str)
					local num = tonumber(str)
					if num then
						sat = math.clamp(math.floor(num),0,255)/255
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						satInput.Text = tostring(sat*255)
						updateColor(1)
					end
				end
				satInput.FocusLost:Connect(function() updateSat(satInput.Text) end) hookButtons(satInput,updateSat)

				local function updateVal(str)
					local num = tonumber(str)
					if num then
						val = math.clamp(math.floor(num),0,255)/255
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						valInput.Text = tostring(val*255)
						updateColor(1)
					end
				end
				valInput.FocusLost:Connect(function() updateVal(valInput.Text) end) hookButtons(valInput,updateVal)

				local function updateRed(str)
					local num = tonumber(str)
					if num then
						red = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						redInput.Text = tostring(red*255)
						updateColor(2)
					end
				end
				redInput.FocusLost:Connect(function() updateRed(redInput.Text) end) hookButtons(redInput,updateRed)

				local function updateGreen(str)
					local num = tonumber(str)
					if num then
						green = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						greenInput.Text = tostring(green*255)
						updateColor(2)
					end
				end
				greenInput.FocusLost:Connect(function() updateGreen(greenInput.Text) end) hookButtons(greenInput,updateGreen)

				local function updateBlue(str)
					local num = tonumber(str)
					if num then
						blue = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						blueInput.Text = tostring(blue*255)
						updateColor(2)
					end
				end
				blueInput.FocusLost:Connect(function() updateBlue(blueInput.Text) end) hookButtons(blueInput,updateBlue)

				local colorChoice = Instance.new("TextButton")
				colorChoice.Name = "Choice"
				colorChoice.Size = UDim2.new(0,25,0,18)
				colorChoice.BorderColor3 = Color3.new(96/255,96/255,96/255)
				colorChoice.Text = ""
				colorChoice.AutoButtonColor = false
				colorChoice.ZIndex = 10

				local row = 0
				local column = 0
				for i,v in pairs(basicColors) do
					local newColor = colorChoice:Clone()
					newColor.BackgroundColor3 = v
					newColor.Position = UDim2.new(0,1 + 30*column,0,21 + 23*row)

					newColor.MouseButton1Click:Connect(function()
						red,green,blue = v.r,v.g,v.b
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						updateColor()
					end)	

					newColor.Parent = basicColorsFrame
					column = column + 1
					if column == 6 then row = row + 1 column = 0 end
				end

				row = 0
				column = 0
				for i = 1,12 do
					local color = customColors[i] or Color3.new(0,0,0)
					local newColor = colorChoice:Clone()
					newColor.BackgroundColor3 = color
					newColor.Position = UDim2.new(0,1 + 30*column,0,20 + 23*row)

					newColor.MouseButton1Click:Connect(function()
						local curColor = customColors[i] or Color3.new(0,0,0)
						red,green,blue = curColor.r,curColor.g,curColor.b
						hue,sat,val = Color3.toHSV(curColor)
						updateColor()
					end)

					newColor.MouseButton2Click:Connect(function()
						customColors[i] = chosenColor
						newColor.BackgroundColor3 = chosenColor
					end)

					newColor.Parent = customColorsFrame
					column = column + 1
					if column == 6 then row = row + 1 column = 0 end
				end

				shade1Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade1) end end)
				shade1Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade1Button.BackgroundTransparency = 0.4 end end)
				shade1Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade1Button.BackgroundTransparency = 0 end end)

				shade2Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade2) end end)
				shade2Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade2Button.BackgroundTransparency = 0.4 end end)
				shade2Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade2Button.BackgroundTransparency = 0 end end)

				shade3Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade3) end end)
				shade3Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade3Button.BackgroundTransparency = 0.4 end end)
				shade3Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade3Button.BackgroundTransparency = 0 end end)

				text1Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,text1) end end)
				text1Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text1Button.BackgroundTransparency = 0.4 end end)
				text1Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text1Button.BackgroundTransparency = 0 end end)

				text2Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,text2) end end)
				text2Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text2Button.BackgroundTransparency = 0.4 end end)
				text2Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text2Button.BackgroundTransparency = 0 end end)

				scrollButton.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,scroll) end end)
				scrollButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then scrollButton.BackgroundTransparency = 0.4 end end)
				scrollButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then scrollButton.BackgroundTransparency = 0 end end)

				cancelButton.MouseButton1Click:Connect(function() if newMt.Cancel then newMt:Cancel() end end)
				cancelButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0.4 end end)
				cancelButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0 end end)

				defaultButton.MouseButton1Click:Connect(function() if newMt.Default then newMt:Default() end end)
				defaultButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then defaultButton.BackgroundTransparency = 0.4 end end)
				defaultButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then defaultButton.BackgroundTransparency = 0 end end)

				pickerExit.MouseButton1Click:Connect(function()
					picker:TweenPosition(UDim2.new(0.5, -219, 0, -500), "InOut", "Quart", 0.5, true, nil)
				end)

				updateColor()

				newMt.SetColor = function(self,color)
					red,green,blue = color.r,color.g,color.b
					hue,sat,val = Color3.toHSV(color)
					updateColor()
				end

				return newMt
			end
		end

		picker:TweenPosition(UDim2.new(0.5, -219, 0, 100), "InOut", "Quart", 0.5, true, nil)

		local Npicker = ColorPicker.new()
		Npicker.Confirm = function(self,color,ctype) updateColors(color,ctype) wait() updatesaves() end
		Npicker.Cancel = function(self)
			updateColors(cache_currentShade1,shade1)
			updateColors(cache_currentShade2,shade2)
			updateColors(cache_currentShade3,shade3)
			updateColors(cache_currentText1,text1)
			updateColors(cache_currentText2,text2)
			updateColors(cache_currentScroll,scroll)
			wait()
			updatesaves()
		end
		Npicker.Default = function(self)
			updateColors(Color3.fromRGB(36, 36, 37),shade1)
			updateColors(Color3.fromRGB(46, 46, 47),shade2)
			updateColors(Color3.fromRGB(78, 78, 79),shade3)
			updateColors(Color3.new(1, 1, 1),text1)
			updateColors(Color3.new(0, 0, 0),text2)
			updateColors(Color3.fromRGB(78,78,79),scroll)
			wait()
			updatesaves()
		end
	else
		picker:TweenPosition(UDim2.new(0.5, -219, 0, 100), "InOut", "Quart", 0.5, true, nil)
	end
end)


SettingsButton.MouseButton1Click:Connect(function()
	if SettingsOpen == false then SettingsOpen = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	else SettingsOpen = false
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.5, true, nil)
	end
end)

On.MouseButton1Click:Connect(function()
	if isHidden == false then
		if StayOpen == false then
			StayOpen = true
			On.BackgroundTransparency = 0
		else
			StayOpen = false
			On.BackgroundTransparency = 1
		end
		updatesaves()
	end
end)

Clear.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_2:GetChildren()) do
		child:Destroy()
	end
	scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Clear_2.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_3:GetChildren()) do
		child:Destroy()
	end
	scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Toggle.MouseButton1Down:Connect(function()
	if logsEnabled then
		logsEnabled = false
		Toggle.Text = 'Disabled'
		updatesaves()
	else
		logsEnabled = true
		Toggle.Text = 'Enabled'
		updatesaves()
	end
end)

Toggle_2.MouseButton1Down:Connect(function()
	if jLogsEnabled then
		jLogsEnabled = false
		Toggle_2.Text = 'Disabled'
		updatesaves()
	else
		jLogsEnabled = true
		Toggle_2.Text = 'Enabled'
		updatesaves()
	end
end)

selectChat.MouseButton1Down:Connect(function()
	join.Visible = false
	chat.Visible = true
	table.remove(shade3,table.find(shade3,selectChat))
	table.remove(shade2,table.find(shade2,selectJoin))
	table.insert(shade2,selectChat)
	table.insert(shade3,selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
end)

selectJoin.MouseButton1Down:Connect(function()
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3,table.find(shade3,selectJoin))
	table.remove(shade2,table.find(shade2,selectChat))
	table.insert(shade2,selectJoin)
	table.insert(shade3,selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
end)

if not writefileExploit() then
	notify("Saves", "Your exploit does not support read/write file. Your settings will not save.")
end

avatarcache = {}
function sendChatWebhook(player, message)
	if httprequest and vtype(logsWebhook, "string") then
		local id = player.UserId
		local avatar = avatarcache[id]
		if not avatar then
			local d = HttpService:JSONDecode(httprequest({
				Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. id .. "&size=420x420&format=Png&isCircular=false",
				Method = "GET"
			}).Body)["data"]
			avatar = d and d[1].state == "Completed" and d[1].imageUrl or "https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/assets/plain.png"
			avatarcache[id] = avatar
		end
		local log = HttpService:JSONEncode({
			content = message,
			avatar_url = avatar,
			username = formatUsername(player),
			allowed_mentions = {parse = {}}
		})
		httprequest({
			Url = logsWebhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = log
		})
	end
end

ChatLog = function(player)
	player.Chatted:Connect(function(message)
		if logsEnabled == true then
			CreateLabel(player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

JoinLog = function(plr)
	if jLogsEnabled == true then
		CreateJoinLabel(plr,plr.UserId)
	end
end

CleanFileName = function(name)
	return tostring(name):gsub("[*\\?:<>|]+", ""):sub(1, 175)
end

SaveChatlogs.MouseButton1Down:Connect(function()
	if writefileExploit() then
		if #scroll_2:GetChildren() > 0 then
			notify("Loading",'Hold on a sec')
			local placeName = CleanFileName(MarketplaceService:GetProductInfo(PlaceId).Name)
			local writelogs = '-- Infinite Yield Chat logs for "'..placeName..'"\n'
			for _, child in pairs(scroll_2:GetChildren()) do
				writelogs = writelogs..'\n'..child.Text
			end
			local writelogsFile = tostring(writelogs)
			local fileext = 0
			local function nameFile()
				local file
				pcall(function() file = readfile(placeName..' Chat Logs ('..fileext..').txt') end)
				if file then
					fileext = fileext+1
					nameFile()
				else
					writefileCooldown(placeName..' Chat Logs ('..fileext..').txt', writelogsFile)
				end
			end
			nameFile()
			notify('Chat Logs','Saved chat logs to the workspace folder within your exploit folder.')
		end
	else
		notify('Chat Logs','Your exploit does not support write file. You cannot save chat logs.')
	end
end)

if isLegacyChat then
	for _, plr in pairs(Players:GetPlayers()) do
		ChatLog(plr)
	end
end

Players.PlayerRemoving:Connect(function(player)
	if ESPenabled or CHMSenabled or COREGUI:FindFirstChild(player.Name..'_LC') then
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == player.Name..'_ESP' or v.Name == player.Name..'_LC' or v.Name == player.Name..'_CHMS' then
				v:Destroy()
			end
		end
	end
	if viewing ~= nil and player == viewing then
		workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character
		viewing = nil
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		notify('Spectate','View turned off (player left)')
	end
	eventEditor.FireEvent("OnLeave", player.Name)
end)

Exit.MouseButton1Down:Connect(function()
	logs:TweenPosition(UDim2.new(0, 0, 1, 10), "InOut", "Quart", 0.3, true, nil)
end)

Hide.MouseButton1Down:Connect(function()
	if logs.Position ~= UDim2.new(0, 0, 1, -20) then
		logs:TweenPosition(UDim2.new(0, 0, 1, -20), "InOut", "Quart", 0.3, true, nil)
	else
		logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
	end
end)

EventBind.MouseButton1Click:Connect(function()
	eventEditor.Frame:TweenPosition(UDim2.new(0.5,-175,0.5,-101), "InOut", "Quart", 0.5, true, nil)
end)

Keybinds.MouseButton1Click:Connect(function()
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Close.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Keybinds.MouseButton1Click:Connect(function()
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Add.MouseButton1Click:Connect(function()
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, 260), "InOut", "Quart", 0.5, true, nil)
end)

Delete.MouseButton1Click:Connect(function()
	binds = {}
	refreshbinds()
	updatesaves()
	notify('Keybinds Updated','Removed all keybinds')
end)

Close_2.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Aliases.MouseButton1Click:Connect(function()
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Close_3.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Positions.MouseButton1Click:Connect(function()
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

local selectionBox = Instance.new("SelectionBox")
selectionBox.Name = randomString()
selectionBox.Color3 = Color3.new(255,255,255)
selectionBox.Adornee = nil
selectionBox.Parent = PARENT

local selected = Instance.new("SelectionBox")
selected.Name = randomString()
selected.Color3 = Color3.new(0,166,0)
selected.Adornee = nil
selected.Parent = PARENT

local ActivateHighlight = nil
local ClickSelect = nil
function selectPart()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, 335), "InOut", "Quart", 0.5, true, nil)
	local function HighlightPart()
		if selected.Adornee ~= IYMouse.Target then
			selectionBox.Adornee = IYMouse.Target
		else
			selectionBox.Adornee = nil
		end
	end
	ActivateHighlight = IYMouse.Move:Connect(HighlightPart)
	local function SelectPart()
		if IYMouse.Target ~= nil then
			selected.Adornee = IYMouse.Target
			Path.Text = getHierarchy(IYMouse.Target)
		end
	end
	ClickSelect = IYMouse.Button1Down:Connect(SelectPart)
end

Part.MouseButton1Click:Connect(function()
	selectPart()
end)

Exit_4.MouseButton1Click:Connect(function()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	if ActivateHighlight then
		ActivateHighlight:Disconnect()
	end
	if ClickSelect then
		ClickSelect:Disconnect()
	end
	selectionBox.Adornee = nil
	selected.Adornee = nil
	Path.Text = ""
end)

CopyPath.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		toClipboard(Path.Text)
	else
		notify('Copy Path','Select a part to copy its path')
	end
end)

ChoosePart.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		local tpNameExt = ''
		local function handleWpNames()
			local FoundDupe = false
			for i,v in pairs(pWayPoints) do
				if v.NAME:lower() == selected.Adornee.Name:lower()..tpNameExt then
					FoundDupe = true
				end
			end
			if not FoundDupe then
				notify('Modified Waypoints',"Created waypoint: "..selected.Adornee.Name..tpNameExt)
				pWayPoints[#pWayPoints + 1] = {NAME = selected.Adornee.Name..tpNameExt, COORD = {selected.Adornee}}
			else
				if isNumber(tpNameExt) then
					tpNameExt = tpNameExt+1
				else
					tpNameExt = 1
				end
				handleWpNames()
			end
		end
		handleWpNames()
		refreshwaypoints()
	else
		notify('Part Selection','Select a part first')
	end
end)

cmds={}
customAlias = {}
Delete_3.MouseButton1Click:Connect(function()
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

PrefixBox:GetPropertyChangedSignal("Text"):Connect(function()
	prefix = PrefixBox.Text
	Cmdbar.PlaceholderText = "Command Bar ("..prefix..")"
	updatesaves()
end)

function CamViewport()
	if workspace.CurrentCamera then
		return workspace.CurrentCamera.ViewportSize.X
	end
end

function UpdateToViewport()
	if Holder.Position.X.Offset < -CamViewport() then
		Holder:TweenPosition(UDim2.new(1, -CamViewport(), Holder.Position.Y.Scale, Holder.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
		Notification:TweenPosition(UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
	end
end
CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)

function updateCamera(child, parent)
	if parent ~= workspace then
		CamMoved:Disconnect()
		CameraChanged:Disconnect()
		repeat wait() until workspace.CurrentCamera
		CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)
		CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)
	end
end
CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)

function dragMain(dragpoint,gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local pos = -250
			local delta = input.Position - dragStart
			if startPos.X.Offset + delta.X <= -500 then
				local Position = UDim2.new(1, -250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = 250
			else
				local Position = UDim2.new(1, -500, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = -250
			end
			if startPos.X.Offset + delta.X <= -250 and -CamViewport() <= startPos.X.Offset + delta.X then
				local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + pos, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			elseif startPos.X.Offset + delta.X > -500 then
				local Position = UDim2.new(1, -250, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
			elseif -CamViewport() > startPos.X.Offset + delta.X then
				gui:TweenPosition(UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
				local Position = UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			end
		end
		dragpoint.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		dragpoint.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragMain(Title,Holder)

Match = function(name,str)
	str = str:gsub("%W", "%%%1")
	return name:lower():find(str:lower()) and true
end

local canvasPos = Vector2.new(0,0)
local topCommand = nil
local function updateCommandCanvasSize(frame)
	local scale = (Scale and Scale.Scale) or 1
	if scale <= 0 then scale = 1 end
	local contentY = cmdListLayout.AbsoluteContentSize.Y
	local unscaledY = math.ceil(contentY / scale)
	frame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, unscaledY))
end
cmdListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	updateCommandCanvasSize(CMDsF)
end)
IndexContents = function(str,bool,cmdbar,Ianim)
	CMDsF.CanvasPosition = Vector2.new(0,0)
	local SizeY = 0
	local indexnum = 0
	local frame = CMDsF
	topCommand = nil
	local chunks = {}
	if str:sub(#str,#str) == "\\" then str = "" end
	for w in string.gmatch(str,"[^\\]+") do
		table.insert(chunks,w)
	end
	if #chunks > 0 then str = chunks[#chunks] end
	if str:sub(1,1) == "!" then str = str:sub(2) end
	for i,v in next, frame:GetChildren() do
		if v:IsA("TextButton") then
			if bool then
				if Match(v.Text,str) then
					indexnum = indexnum + 1
					v.Visible = true
					if topCommand == nil then
						topCommand = v.Text
					end
				else
					v.Visible = false
				end
			else
				v.Visible = true
				if topCommand == nil then
					topCommand = v.Text
				end
			end
		end
	end
	updateCommandCanvasSize(frame)
	if not Ianim then
		if indexnum == 0 or string.find(str, " ") then
			if not cmdbar then
				minimizeHolder()
			elseif cmdbar then
				cmdbarHolder()
			end
		else
			maximizeHolder()
		end
	else
		minimizeHolder()
	end
end

task.spawn(function()
	if not isLegacyChat then return end
	local chatbox
	local success, result = pcall(function() chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar end)
	if success then
		local function chatboxFocused()
			canvasPos = CMDsF.CanvasPosition
		end
		local chatboxFocusedC = chatbox.Focused:Connect(chatboxFocused)

		local function Index()
			if chatbox.Text:lower():sub(1,1) == prefix then
				if SettingsOpen == true then
					wait(0.2)
					CMDsF.Visible = true
					Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.2, true, nil)
				end
				IndexContents(PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar.Text:lower():sub(2),true)
			else
				minimizeHolder()
				if SettingsOpen == true then
					wait(0.2)
					Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.2, true, nil)
					CMDsF.Visible = false
				end
			end
		end
		local chatboxFunc = chatbox:GetPropertyChangedSignal("Text"):Connect(Index)

		local function chatboxFocusLost(enterpressed)
			if not enterpressed or chatbox.Text:lower():sub(1,1) ~= prefix then
				IndexContents('',true)
			end
			CMDsF.CanvasPosition = canvasPos
			minimizeHolder()
		end
		local chatboxFocusLostC = chatbox.FocusLost:Connect(chatboxFocusLost)

		PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.ChildAdded:Connect(function(newbar)
			wait()
			if newbar:FindFirstChild('BoxFrame') then
				chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
				if chatboxFocusedC then chatboxFocusedC:Disconnect() end
				chatboxFocusedC = chatbox.Focused:Connect(chatboxFocused)
				if chatboxFunc then chatboxFunc:Disconnect() end
				chatboxFunc = chatbox:GetPropertyChangedSignal("Text"):Connect(Index)
				if chatboxFocusLostC then chatboxFocusLostC:Disconnect() end
				chatboxFocusLostC = chatbox.FocusLost:Connect(chatboxFocusLost)
			end
		end)
		--else
		--print('Custom chat detected. Will not provide suggestions for commands typed in the chat.')
	end
end)

function autoComplete(str,curText)
	local endingChar = {"[", "/", "(", " "}
	local stop = 0
	for i=1,#str do
		local c = str:sub(i,i)
		if table.find(endingChar, c) then
			stop = i
			break
		end
	end
	curText = curText or Cmdbar.Text
	local subPos = 0
	local pos = 1
	local findRes = string.find(curText,"\\",pos)
	while findRes do
		subPos = findRes
		pos = findRes+1
		findRes = string.find(curText,"\\",pos)
	end
	if curText:sub(subPos+1,subPos+1) == "!" then subPos = subPos + 1 end
	Cmdbar.Text = curText:sub(1,subPos) .. str:sub(1, stop - 1)..' '
	RunService.RenderStepped:Wait()
	Cmdbar.Text = Cmdbar.Text:gsub( '\t', '' )
	Cmdbar.CursorPosition = #Cmdbar.Text+1--1020
end

CMDs = {}
CMDs[#CMDs + 1] = {NAME = 'discord / support / help', DESC = 'Invite to the Infinite Yield discord server.'}
CMDs[#CMDs + 1] = {NAME = 'guiscale [number]', DESC = 'Changes the size of the gui. [number] accepts decimals and whole numbers. Min is 0.4 and Max is 2'}
CMDs[#CMDs + 1] = {NAME = 'console', DESC = 'Opens the Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'oldconsole', DESC = 'Loads an old-themed Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'explorer / dex', DESC = 'Opens Dex++ by Chillz'}
CMDs[#CMDs + 1] = {NAME = 'moondex / mdex', DESC = 'Opens DEX by Moon'}
CMDs[#CMDs + 1] = {NAME = 'remotespy / rspy', DESC = 'Opens Cobalt to intercept incoming and outgoing network traffic'}
CMDs[#CMDs + 1] = {NAME = 'simplespy / sspy', DESC = 'Opens Simple Spy V3 to intercept remote calls from the client to the server'}
CMDs[#CMDs + 1] = {NAME = 'audiologger / alogger', DESC = 'Opens Edges audio logger'}
CMDs[#CMDs + 1] = {NAME = 'serverinfo / info', DESC = 'Gives you info about the server'}
CMDs[#CMDs + 1] = {NAME = 'jobid', DESC = 'Copies the games JobId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'notifyjobid', DESC = 'Notifies you the games JobId'}
CMDs[#CMDs + 1] = {NAME = 'rejoin / rj [reposition]', DESC = 'Makes you rejoin the game'}
CMDs[#CMDs + 1] = {NAME = 'inviteprompt', DESC = 'Prompts the user of your choice that they had invited you. Requires a rejoin to function.'}
CMDs[#CMDs + 1] = {NAME = 'autorejoin / autorj', DESC = 'Automatically rejoins the server if you get kicked/disconnected'}
CMDs[#CMDs + 1] = {NAME = 'serverhop / shop', DESC = 'Teleports you to a different server'}
CMDs[#CMDs + 1] = {NAME = 'gameteleport / gametp [place ID]', DESC = 'Joins a game by ID'}
CMDs[#CMDs + 1] = {NAME = 'antiidle / antiafk', DESC = 'Prevents the game from kicking you for being idle/afk'}
CMDs[#CMDs + 1] = {NAME = 'datalimit [num]', DESC = 'Set outgoing KBPS limit'}
CMDs[#CMDs + 1] = {NAME = 'replicationlag / backtrack [num]', DESC = 'Set IncomingReplicationLag'}
CMDs[#CMDs + 1] = {NAME = 'creatorid / creator', DESC = 'Notifies you the creators ID'}
CMDs[#CMDs + 1] = {NAME = 'copycreatorid / copycreator', DESC = 'Copies the creators ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'setcreatorid / setcreator', DESC = 'Sets your userid to the creators ID'}
CMDs[#CMDs + 1] = {NAME = 'noprompts', DESC = 'Prevents the game from showing you purchase/premium prompts'}
CMDs[#CMDs + 1] = {NAME = 'showprompts', DESC = 'Allows the game to show purchase/premium prompts again'}
CMDs[#CMDs + 1] = {NAME = 'enable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of coregui items'}
CMDs[#CMDs + 1] = {NAME = 'disable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of coregui items'}
CMDs[#CMDs + 1] = {NAME = 'showguis', DESC = 'Shows any invisible GUIs'}
CMDs[#CMDs + 1] = {NAME = 'unshowguis', DESC = 'Undoes showguis'}
CMDs[#CMDs + 1] = {NAME = 'hideguis', DESC = 'Hides any GUIs in PlayerGui'}
CMDs[#CMDs + 1] = {NAME = 'unhideguis', DESC = 'Undoes hideguis'}
CMDs[#CMDs + 1] = {NAME = 'guidelete', DESC = 'Enables backspace to delete GUI'}
CMDs[#CMDs + 1] = {NAME = 'unguidelete / noguidelete', DESC = 'Disables guidelete'}
CMDs[#CMDs + 1] = {NAME = 'hideiy', DESC = 'Hides the main IY GUI'}
CMDs[#CMDs + 1] = {NAME = 'showiy / unhideiy', DESC = 'Shows IY again'}
CMDs[#CMDs + 1] = {NAME = 'keepiy', DESC = 'Auto execute IY when you teleport through servers'}
CMDs[#CMDs + 1] = {NAME = 'unkeepiy', DESC = 'Disable keepiy'}
CMDs[#CMDs + 1] = {NAME = 'togglekeepiy', DESC = 'Toggles keepiy'}
CMDs[#CMDs + 1] = {NAME = 'removeads / adblock', DESC = 'Automatically removes ad billboards'}
CMDs[#CMDs + 1] = {NAME = 'savegame / saveplace', DESC = 'Uses saveinstance to save the game'}
CMDs[#CMDs + 1] = {NAME = 'clearerror', DESC = 'Clears the annoying box and blur when a game kicks you'}
CMDs[#CMDs + 1] = {NAME = 'antigameplaypaused', DESC = 'Clears the annoying box shown when a game is loading assets due to network lag'}
CMDs[#CMDs + 1] = {NAME = 'unantigameplaypaused', DESC = 'Disables antigameplaypaused'}
CMDs[#CMDs + 1] = {NAME = 'clientantikick / antikick (CLIENT)', DESC = 'Prevents localscripts from kicking you'}
CMDs[#CMDs + 1] = {NAME = 'clientantiteleport / antiteleport (CLIENT)', DESC = 'Prevents localscripts from teleporting you'}
CMDs[#CMDs + 1] = {NAME = 'allowrejoin / allowrj (CLIENT)', DESC = 'Toggles if antiteleport allows you to rejoin or not'}
CMDs[#CMDs + 1] = {NAME = 'cancelteleport / canceltp', DESC = 'Cancels teleports in progress'}
CMDs[#CMDs + 1] = {NAME = 'volume / vol [0-10]', DESC = 'Adjusts your game volume on a scale of 0 to 10'}
CMDs[#CMDs + 1] = {NAME = 'antilag / boostfps / lowgraphics', DESC = 'Lowers game quality to boost FPS'}
CMDs[#CMDs + 1] = {NAME = 'record / rec', DESC = 'Starts Roblox recorder'}
CMDs[#CMDs + 1] = {NAME = 'screenshot / scrnshot', DESC = 'Takes a screenshot'}
CMDs[#CMDs + 1] = {NAME = 'togglefullscreen / togglefs', DESC = 'Toggles fullscreen'}
CMDs[#CMDs + 1] = {NAME = 'notify [text]', DESC = 'Sends you a notification with the provided text'}
CMDs[#CMDs + 1] = {NAME = 'lastcommand / lastcmd', DESC = 'Executes the previous command used'}
CMDs[#CMDs + 1] = {NAME = 'notifyping / ping', DESC = 'Notify yourself your ping'}
CMDs[#CMDs + 1] = {NAME = 'norender', DESC = 'Disable 3d Rendering to decrease the amount of CPU the client uses'}
CMDs[#CMDs + 1] = {NAME = 'render', DESC = 'Enable 3d Rendering'}
CMDs[#CMDs + 1] = {NAME = 'use2022materials / 2022materials', DESC = 'Enables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'unuse2022materials / un2022materials', DESC = 'Disables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'alignmentkeys', DESC = 'Enables the left and right alignment keys (comma and period)'}
CMDs[#CMDs + 1] = {NAME = 'unalignmentkeys / noalignmentkeys', DESC = 'Disables the alignment keys'}
CMDs[#CMDs + 1] = {NAME = 'ctrllock', DESC = 'Binds Shiftlock to LeftControl'}
CMDs[#CMDs + 1] = {NAME = 'unctrllock', DESC = 'Re-binds Shiftlock to LeftShift'}
CMDs[#CMDs + 1] = {NAME = 'exit / shutdown / leave', DESC = 'Exits the game'}
CMDs[#CMDs + 1] = {NAME = 'removecmd / deletecmd', DESC = 'Removes a command until the script is reloaded'}
CMDs[#CMDs + 1] = {NAME = 'breakloops / break (cmd loops)', DESC = 'Stops any cmd loops (;100^1^cmd)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'noclip', DESC = 'Go through objects'}
CMDs[#CMDs + 1] = {NAME = 'unnoclip / clip', DESC = 'Disables noclip'}
CMDs[#CMDs + 1] = {NAME = 'fly [speed]', DESC = 'Makes you fly'}
CMDs[#CMDs + 1] = {NAME = 'unfly', DESC = 'Disables fly'}
CMDs[#CMDs + 1] = {NAME = 'flyspeed [num]', DESC = 'Set fly speed (default is 20)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclefly / vfly [speed]', DESC = 'Makes you fly in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'unvehiclefly / unvfly', DESC = 'Disables vehicle fly'}
CMDs[#CMDs + 1] = {NAME = 'vehicleflyspeed  / vflyspeed [num]', DESC = 'Set vehicle fly speed'}
CMDs[#CMDs + 1] = {NAME = 'cframefly / cfly [speed]', DESC = 'Makes you fly, bypassing some anti cheats (works on mobile)'}
CMDs[#CMDs + 1] = {NAME = 'uncframefly / uncfly', DESC = 'Disables cfly'}
CMDs[#CMDs + 1] = {NAME = 'cframeflyspeed  / cflyspeed [num]', DESC = 'Sets cfly speed'}
CMDs[#CMDs + 1] = {NAME = 'qefly [true / false]', DESC = 'Enables or disables the Q and E hotkeys for fly'}
CMDs[#CMDs + 1] = {NAME = 'vehiclenoclip / vnoclip', DESC = 'Turns off vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'vehicleclip / vclip / unvnoclip', DESC = 'Enables vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'float /  platform', DESC = 'Spawns a platform beneath you causing you to float'}
CMDs[#CMDs + 1] = {NAME = 'unfloat / noplatform', DESC = 'Removes the platform'}
CMDs[#CMDs + 1] = {NAME = 'swim', DESC = 'Allows you to swim in the air'}
CMDs[#CMDs + 1] = {NAME = 'unswim / noswim', DESC = 'Stops you from swimming everywhere'}
CMDs[#CMDs + 1] = {NAME = 'toggleswim', DESC = 'Toggles swimming'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'setwaypoint / swp [name]', DESC = 'Sets a waypoint at your position'}
CMDs[#CMDs + 1] = {NAME = 'waypointpos / wpp [name] [X Y Z]', DESC = 'Sets a waypoint with specified coordinates'}
CMDs[#CMDs + 1] = {NAME = 'waypoints', DESC = 'Shows a list of currently active waypoints'}
CMDs[#CMDs + 1] = {NAME = 'showwaypoints / showwp', DESC = 'Shows all currently set waypoints'}
CMDs[#CMDs + 1] = {NAME = 'hidewaypoints / hidewp', DESC = 'Hides shown waypoints'}
CMDs[#CMDs + 1] = {NAME = 'waypoint / wp [name]', DESC = 'Teleports player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'tweenwaypoint / twp [name]', DESC = 'Tweens player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'walktowaypoint / wtwp [name]', DESC = 'Walks player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'deletewaypoint / dwp [name]', DESC = 'Deletes a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'clearwaypoints / cwp', DESC = 'Clears all waypoints'}
CMDs[#CMDs + 1] = {NAME = 'cleargamewaypoints / cgamewp', DESC = 'Clears all waypoints for the game you are in'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'goto [player] [request stream]', DESC = 'Go to a player'}
CMDs[#CMDs + 1] = {NAME = 'tweengoto / tgoto [player]', DESC = 'Tween to a player (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'tweenspeed / tspeed [num]', DESC = 'Sets how fast all tween commands go (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclegoto / vgoto [player]', DESC = 'Go to a player while in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'loopgoto [player] [distance] [delay]', DESC = 'Loop teleport to a player'}
CMDs[#CMDs + 1] = {NAME = 'unloopgoto', DESC = 'Stops teleporting you to a player'}
CMDs[#CMDs + 1] = {NAME = 'pulsetp / ptp [player] [seconds]', DESC = 'Teleports you to a player for a specified amount of time'}
CMDs[#CMDs + 1] = {NAME = 'clientbring / cbring [player] (CLIENT)', DESC = 'Bring a player'}
CMDs[#CMDs + 1] = {NAME = 'loopbring [player] [distance] [delay] (CLIENT)', DESC = 'Loop brings a player to you (useful for killing)'}
CMDs[#CMDs + 1] = {NAME = 'unloopbring [player]', DESC = 'Undoes loopbring'}
CMDs[#CMDs + 1] = {NAME = 'freeze / fr [player] (CLIENT)', DESC = 'Freezes a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeanims', DESC = 'Freezes your animations / pauses your animations - Does not work on default animations'}
CMDs[#CMDs + 1] = {NAME = 'unfreezeanims', DESC = 'Unfreezes your animations / plays your animations'}
CMDs[#CMDs + 1] = {NAME = 'thaw / unfr [player] (CLIENT)', DESC = 'Unfreezes a player'}
CMDs[#CMDs + 1] = {NAME = 'anchor', DESC = 'Anchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'unanchor', DESC = 'Unanchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'tpposition / tppos [X Y Z]', DESC = 'Teleports you to certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweentpposition / ttppos [X Y Z]', DESC = 'Tween to coordinates (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'offset [X Y Z]', DESC = 'Offsets you by certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweenoffset / toffset [X Y Z]', DESC = 'Tween offset (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'thru [num]', DESC = 'Teleports you [num] studs ahead of where your character is facing'}
CMDs[#CMDs + 1] = {NAME = 'notifyposition / notifypos [player]', DESC = 'Notifies you the coordinates of a character'}
CMDs[#CMDs + 1] = {NAME = 'copyposition / copypos [player]', DESC = 'Copies the coordinates of a character to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'walktoposition / walktopos [X Y Z]', DESC = 'Makes you walk to a coordinate'}
CMDs[#CMDs + 1] = {NAME = 'spawnpoint / spawn [delay]', DESC = 'Sets a position where you will spawn'}
CMDs[#CMDs + 1] = {NAME = 'nospawnpoint / nospawn', DESC = 'Removes your custom spawn point'}
CMDs[#CMDs + 1] = {NAME = 'flashback / diedtp', DESC = 'Teleports you to where you last died'}
CMDs[#CMDs + 1] = {NAME = 'walltp', DESC = 'Teleports you above/over any wall you run into'}
CMDs[#CMDs + 1] = {NAME = 'nowalltp / unwalltp', DESC = 'Disables walltp'}
CMDs[#CMDs + 1] = {NAME = 'teleporttool / tptool', DESC = 'Gives you a teleport tool'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'logs', DESC = 'Opens the logs GUI'}
CMDs[#CMDs + 1] = {NAME = 'chatlogs / clogs', DESC = 'Log what people say or whisper'}
CMDs[#CMDs + 1] = {NAME = 'joinlogs / jlogs', DESC = 'Log when people join'}
CMDs[#CMDs + 1] = {NAME = 'chatlogswebhook / logswebhook [url]', DESC = 'Set a discord webhook for chatlogs to go to (provide no url to disable this)'}
CMDs[#CMDs + 1] = {NAME = 'chat / say [text]', DESC = 'Makes you chat a string (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'spam [text]', DESC = 'Makes you spam the chat'}
CMDs[#CMDs + 1] = {NAME = 'unspam', DESC = 'Turns off spam'}
CMDs[#CMDs + 1] = {NAME = 'whisper / pm [player] [text]', DESC = 'Makes you whisper a string to someone (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'pmspam [player] [text]', DESC = 'Makes you spam a players whispers'}
CMDs[#CMDs + 1] = {NAME = 'unpmspam [player]', DESC = 'Turns off pm spam'}
CMDs[#CMDs + 1] = {NAME = 'spamspeed [num]', DESC = 'How quickly you spam (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'bubblechat (CLIENT)', DESC = 'Enables bubble chat for your client'}
CMDs[#CMDs + 1] = {NAME = 'unbubblechat / nobubblechat', DESC = 'Disables the bubblechat command'}
CMDs[#CMDs + 1] = {NAME = 'chatwindow', DESC = 'Enables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'unchatwindow / nochatwindow', DESC = 'Disables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'darkchat', DESC = 'Makes the chat window dark for your client'}
CMDs[#CMDs + 1] = {NAME = 'listento [player]', DESC = 'Listens to the area around a player. Can also eavesdrop with vc'}
CMDs[#CMDs + 1] = {NAME = 'unlistento', DESC = 'Disables listento'}
CMDs[#CMDs + 1] = {NAME = 'muteallvoices / muteallvcs', DESC = 'Mutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'unmuteallvoices / unmuteallvcs', DESC = 'Unmutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'mutevc [player]', DESC = 'Mutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'unmutevc [player]', DESC = 'Unmutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'phonebook / call', DESC = 'Prompts the Roblox phonebook UI to let you call your friends. Needs voice chat enabled'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'esp', DESC = 'View all players and their status'}
CMDs[#CMDs + 1] = {NAME = 'espteam', DESC = 'ESP but teammates are green and bad guys are red'}
CMDs[#CMDs + 1] = {NAME = 'noesp / unesp / unespteam', DESC = 'Removes ESP'}
CMDs[#CMDs + 1] = {NAME = 'esptransparency [number]', DESC = 'Changes the transparency of ESP related commands'}
CMDs[#CMDs + 1] = {NAME = 'partesp [part name]', DESC = 'Highlights a part'}
CMDs[#CMDs + 1] = {NAME = 'unpartesp / nopartesp [part name]', DESC = 'removes partesp'}
CMDs[#CMDs + 1] = {NAME = 'chams', DESC = 'ESP but without text in the way'}
CMDs[#CMDs + 1] = {NAME = 'nochams / unchams', DESC = 'Removes chams'}
CMDs[#CMDs + 1] = {NAME = 'locate [player]', DESC = 'View a single player and their status'}
CMDs[#CMDs + 1] = {NAME = 'unlocate / nolocate [player]', DESC = 'Removes locate'}
CMDs[#CMDs + 1] = {NAME = 'xray', DESC = 'Makes all parts in workspace transparent'}
CMDs[#CMDs + 1] = {NAME = 'unxray / noxray', DESC = 'Restores transparency to all parts in workspace'}
CMDs[#CMDs + 1] = {NAME = 'loopxray', DESC = 'Makes all parts in workspace transparent but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopxray', DESC = 'Unloops xray'}
CMDs[#CMDs + 1] = {NAME = 'togglexray', DESC = 'Toggles xray'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'spectate / view [player]', DESC = 'View a player'}
CMDs[#CMDs + 1] = {NAME = 'viewpart / viewp [part name]', DESC = 'View a part'}
CMDs[#CMDs + 1] = {NAME = 'unspectate / unview', DESC = 'Stops viewing player'}
CMDs[#CMDs + 1] = {NAME = 'freecam / fc', DESC = 'Allows you to freely move camera around the game'}
CMDs[#CMDs + 1] = {NAME = 'freecampos / fcpos [X Y Z]', DESC = 'Moves / opens freecam in a certain position'}
CMDs[#CMDs + 1] = {NAME = 'freecamwaypoint / fcwp [name]', DESC = 'Moves / opens freecam to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'freecamgoto / fcgoto / fctp [player]', DESC = 'Moves / opens freecam to a player'}
CMDs[#CMDs + 1] = {NAME = 'unfreecam / unfc', DESC = 'Disables freecam'}
CMDs[#CMDs + 1] = {NAME = 'freecamspeed / fcspeed [num]', DESC = 'Adjusts freecam speed (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'notifyfreecamposition / notifyfcpos', DESC = 'Noitifies you your freecam coordinates'}
CMDs[#CMDs + 1] = {NAME = 'copyfreecamposition / copyfcpos', DESC = 'Copies your freecam coordinates to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'gotocamera / gotocam', DESC = 'Teleports you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'tweengotocam / tgotocam', DESC = 'Tweens you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'firstp', DESC = 'Forces camera to go into first person'}
CMDs[#CMDs + 1] = {NAME = 'thirdp', DESC = 'Allows camera to go into third person'}
CMDs[#CMDs + 1] = {NAME = 'noclipcam / nccam', DESC = 'Allows camera to go through objects like walls'}
CMDs[#CMDs + 1] = {NAME = 'maxzoom [num]', DESC = 'Maximum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'minzoom [num]', DESC = 'Minimum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'camdistance [num]', DESC = 'Changes camera distance from your player'}
CMDs[#CMDs + 1] = {NAME = 'fov [num]', DESC = 'Adjusts field of view (default is 70)'}
CMDs[#CMDs + 1] = {NAME = 'fixcam / restorecam', DESC = 'Fixes camera'}
CMDs[#CMDs + 1] = {NAME = 'enableshiftlock / enablesl', DESC = 'Enables the shift lock option'}
CMDs[#CMDs + 1] = {NAME = 'lookat [player]', DESC = 'Moves your camera view to a player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'btools (CLIENT)', DESC = 'Gives you building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'f3x (CLIENT)', DESC = 'Gives you F3X building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'partname / partpath', DESC = 'Allows you to click a part to see its path & name'}
CMDs[#CMDs + 1] = {NAME = 'delete [instance name] (CLIENT)', DESC = 'Removes any part with a certain name from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'deleteclass / dc [class name] (CLIENT)', DESC = 'Removes any part with a certain classname from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'lockworkspace / lockws', DESC = 'Locks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'unlockworkspace / unlockws', DESC = 'Unlocks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'invisibleparts / invisparts (CLIENT)', DESC = 'Shows invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'uninvisibleparts / uninvisparts (CLIENT)', DESC = 'Makes parts affected by invisparts return to normal'}
CMDs[#CMDs + 1] = {NAME = 'deleteinvisparts / dip (CLIENT)', DESC = 'Deletes invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopart [part name]', DESC = 'Moves your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopart / tgotopart [part name]', DESC = 'Tweens your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopartclass / gpc [class name]', DESC = 'Moves your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopartclass / tgpc [class name]', DESC = 'Tweens your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'gotomodel [part name]', DESC = 'Moves your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'tweengotomodel / tgotomodel [part name]', DESC = 'Tweens your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'gotopartdelay / gotomodeldelay [num]', DESC = 'Adjusts how quickly you teleport to each part (default is 0.1)'}
CMDs[#CMDs + 1] = {NAME = 'bringpart [part name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character'}
CMDs[#CMDs + 1] = {NAME = 'bringpartclass / bpc [class name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character based on classname'}
CMDs[#CMDs + 1] = {NAME = 'noclickdetectorlimits / nocdlimits', DESC = 'Sets all click detectors MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireclickdetectors / firecd [name]', DESC = 'Uses all click detectors in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'firetouchinterests / touchinterests [name]', DESC = 'Uses all touchinterests in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'noproximitypromptlimits / nopplimits', DESC = 'Sets all proximity prompts MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireproximityprompts / firepp [name]', DESC = 'Uses all proximity prompts in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'instantproximityprompts / instantpp', DESC = 'Disable the cooldown for proximity prompts'}
CMDs[#CMDs + 1] = {NAME = 'uninstantproximityprompts / uninstantpp', DESC = 'Undo the cooldown removal'}
CMDs[#CMDs + 1] = {NAME = 'tpunanchored / tpua [player]', DESC = 'Teleports unanchored parts to a player'}
CMDs[#CMDs + 1] = {NAME = 'animsunanchored / freezeua', DESC = 'Freezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'thawunanchored / thawua / unfreezeua', DESC = 'Thaws unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'removeterrain / rterrain / noterrain', DESC = 'Removes all terrain'}
CMDs[#CMDs + 1] = {NAME = 'clearnilinstances / nonilinstances / cni', DESC = 'Removes nil instances'}
CMDs[#CMDs + 1] = {NAME = 'destroyheight / dh [num]', DESC = 'Sets FallenPartsDestroyHeight'}
CMDs[#CMDs + 1] = {NAME = 'fakeout', DESC = 'Tp to the void and then back (useful to kill people attached to you)'}
CMDs[#CMDs + 1] = {NAME = 'antivoid', DESC = 'Prevents you from falling into the void by launching you upwards'}
CMDs[#CMDs + 1] = {NAME = 'unantivoid / noantivoid', DESC = 'Disables antivoid'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'fullbright / fb (CLIENT)', DESC = 'Makes the map brighter / more visible'}
CMDs[#CMDs + 1] = {NAME = 'loopfullbright / loopfb (CLIENT)', DESC = 'Makes the map brighter / more visible but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopfullbright / unloopfb', DESC = 'Unloops fullbright'}
CMDs[#CMDs + 1] = {NAME = 'ambient [num] [num] [num] (CLIENT)', DESC = 'Changes ambient'}
CMDs[#CMDs + 1] = {NAME = 'day (CLIENT)', DESC = 'Changes the time to day for the client'}
CMDs[#CMDs + 1] = {NAME = 'night (CLIENT)', DESC = 'Changes the time to night for the client'}
CMDs[#CMDs + 1] = {NAME = 'nofog (CLIENT)', DESC = 'Removes fog'}
CMDs[#CMDs + 1] = {NAME = 'brightness [num] (CLIENT)', DESC = 'Changes the brightness lighting property'}
CMDs[#CMDs + 1] = {NAME = 'globalshadows / gshadows (CLIENT)', DESC = 'Enables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'noglobalshadows / nogshadows (CLIENT)', DESC = 'Disables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'restorelighting / rlighting', DESC = 'Restores Lighting properties'}
CMDs[#CMDs + 1] = {NAME = 'light [radius] [brightness] (CLIENT)', DESC = 'Gives your player dynamic light'}
CMDs[#CMDs + 1] = {NAME = 'nolight / unlight', DESC = 'Removes dynamic light from your player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'inspect / examine [player]', DESC = 'Opens InspectMenu for a certain player'}
CMDs[#CMDs + 1] = {NAME = 'age [player]', DESC = 'Tells you the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'chatage [player]', DESC = 'Chats the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'joindate / jd [player]', DESC = 'Tells you the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'chatjoindate / cjd [player]', DESC = 'Chats the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'copyname / copyuser [player]', DESC = 'Copies a players full username to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'userid / id [player]', DESC = 'Notifies a players user ID'}
CMDs[#CMDs + 1] = {NAME = 'copyplaceid / placeid', DESC = 'Copies the current place id to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copygameid / gameid', DESC = 'Copies the current game id to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copyuserid / copyid [player]', DESC = 'Copies a players user ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'appearanceid / aid [player]', DESC = 'Notifies a players appearance ID'}
CMDs[#CMDs + 1] = {NAME = 'copyappearanceid / caid [player]', DESC = 'Copies a players appearance ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'bang [player] [speed]', DESC = 'owo'}
CMDs[#CMDs + 1] = {NAME = 'unbang', DESC = 'uwu'}
CMDs[#CMDs + 1] = {NAME = 'jerk', DESC = 'Makes you jork it'}
CMDs[#CMDs + 1] = {NAME = 'scare / spook [player]', DESC = 'Teleports in front of a player for half a second'}
CMDs[#CMDs + 1] = {NAME = 'carpet [player]', DESC = 'Be someones carpet'}
CMDs[#CMDs + 1] = {NAME = 'uncarpet', DESC = 'Undoes carpet'}
CMDs[#CMDs + 1] = {NAME = 'friend [player]', DESC = 'Sends a friend request to certain players'}
CMDs[#CMDs + 1] = {NAME = 'unfriend [player]', DESC = 'Unfriends certain players'}
CMDs[#CMDs + 1] = {NAME = 'headsit [player]', DESC = 'Sit on a players head'}
CMDs[#CMDs + 1] = {NAME = 'walkto / follow [player]', DESC = 'Follow a player'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalkto / pathfindfollow [player]', DESC = 'Follow a player using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalktowaypoint / pathfindwalktowp [waypoint]', DESC = 'Walk to a waypoint using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'unwalkto / unfollow', DESC = 'Stops following a player'}
CMDs[#CMDs + 1] = {NAME = 'orbit [player] [speed] [distance]', DESC = 'Makes your character orbit around a player with an optional speed and an optional distance'}
CMDs[#CMDs + 1] = {NAME = 'unorbit', DESC = 'Disables orbit'}
CMDs[#CMDs + 1] = {NAME = 'stareat / stare [player]', DESC = 'Stare / look at a player'}
CMDs[#CMDs + 1] = {NAME = 'unstareat / unstare [player]', DESC = 'Disables stareat'}
CMDs[#CMDs + 1] = {NAME = 'rolewatch [group id] [role name]', DESC = 'Notify if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchstop / unrolewatch', DESC = 'Disable Rolewatch'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchleave', DESC = 'Toggle if you should leave the game if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'staffwatch', DESC = 'Notify if a staff member of the game joins the server'}
CMDs[#CMDs + 1] = {NAME = 'unstaffwatch', DESC = 'Disable Staffwatch'}
CMDs[#CMDs + 1] = {NAME = 'findfriendgroups', DESC = 'Notifies you if any players are friends with each other'}
CMDs[#CMDs + 1] = {NAME = 'handlekill / hkill [player] [radius] (TOOL)', DESC = 'Kills a player using tool damage (YOU NEED A TOOL)'}
CMDs[#CMDs + 1] = {NAME = 'fling', DESC = 'Flings anyone you touch'}
CMDs[#CMDs + 1] = {NAME = 'unfling', DESC = 'Disables the fling command'}
CMDs[#CMDs + 1] = {NAME = 'flyfling [speed]', DESC = 'Basically the invisfling command but not invisible'}
CMDs[#CMDs + 1] = {NAME = 'unflyfling', DESC = 'Disables the flyfling command'}
CMDs[#CMDs + 1] = {NAME = 'walkfling', DESC = 'Basically fling but no spinning'}
CMDs[#CMDs + 1] = {NAME = 'unwalkfling / nowalkfling', DESC = 'Disables walkfling'}
CMDs[#CMDs + 1] = {NAME = 'invisfling', DESC = 'Enables invisible fling (the invis part is patched, try using the god command before using this)'}
CMDs[#CMDs + 1] = {NAME = 'antifling', DESC = 'Disables player collisions to prevent you from being flung'}
CMDs[#CMDs + 1] = {NAME = 'unantifling', DESC = 'Disables antifling'}
CMDs[#CMDs + 1] = {NAME = 'loopoof', DESC = 'Loops everyones character sounds (everyone can hear)'}
CMDs[#CMDs + 1] = {NAME = 'unloopoof', DESC = 'Stops the oof chaos'}
CMDs[#CMDs + 1] = {NAME = 'muteboombox [player]', DESC = 'Mutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'unmuteboombox [player]', DESC = 'Unmutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'hitboxes', DESC = 'Shows all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'unhitboxes', DESC = 'Stops showing all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'hitbox [player] [size] [transparency]', DESC = 'Expands the hitbox for players HumanoidRootPart (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'headsize [player] [size]', DESC = 'Expands the head size for players Head (default is 1)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'reset', DESC = 'Resets your character normally'}
CMDs[#CMDs + 1] = {NAME = 'respawn', DESC = 'Respawns you'}
CMDs[#CMDs + 1] = {NAME = 'refresh / re', DESC = 'Respawns and brings you back to the same position'}
CMDs[#CMDs + 1] = {NAME = 'god', DESC = 'Makes your character difficult to kill in most games'}
CMDs[#CMDs + 1] = {NAME = 'invisible / invis', DESC = 'Makes you invisible to other players'}
CMDs[#CMDs + 1] = {NAME = 'visible / vis', DESC = 'Makes you visible to other players'}
CMDs[#CMDs + 1] = {NAME = 'toolinvisible / toolinvis / tinvis', DESC = 'Makes you invisible to other players and able to use tools'}
CMDs[#CMDs + 1] = {NAME = 'speed / ws / walkspeed [num]', DESC = 'Change your walkspeed (default is 16)'}
CMDs[#CMDs + 1] = {NAME = 'spoofspeed / spoofws [num]', DESC = 'Spoofs your WalkSpeed on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopspeed / loopws [num]', DESC = 'Loops your walkspeed'}
CMDs[#CMDs + 1] = {NAME = 'unloopspeed / unloopws', DESC = 'Turns off loopspeed'}
CMDs[#CMDs + 1] = {NAME = 'hipheight / hheight [num]', DESC = 'Adjusts hip height'}
CMDs[#CMDs + 1] = {NAME = 'jumppower / jpower / jp [num]', DESC = 'Change a players jump height (default is 50)'}
CMDs[#CMDs + 1] = {NAME = 'spoofjumppower / spoofjp [num]', DESC = 'Spoofs your JumpPower on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopjumppower / loopjp [num]', DESC = 'Loops your jump height'}
CMDs[#CMDs + 1] = {NAME = 'unloopjumppower / unloopjp', DESC = 'Turns off loopjumppower'}
CMDs[#CMDs + 1] = {NAME = 'maxslopeangle / msa [num]', DESC = 'Adjusts MaxSlopeAngle'}
CMDs[#CMDs + 1] = {NAME = 'gravity / grav [num] (CLIENT)', DESC = 'Change your gravity'}
CMDs[#CMDs + 1] = {NAME = 'sit', DESC = 'Makes your character sit'}
CMDs[#CMDs + 1] = {NAME = 'lay / laydown', DESC = 'Makes your character lay down'}
CMDs[#CMDs + 1] = {NAME = 'sitwalk', DESC = 'Makes your character sit while still being able to walk'}
CMDs[#CMDs + 1] = {NAME = 'nosit', DESC = 'Prevents your character from sitting'}
CMDs[#CMDs + 1] = {NAME = 'unnosit', DESC = 'Disables nosit'}
CMDs[#CMDs + 1] = {NAME = 'jump', DESC = 'Makes your character jump'}
CMDs[#CMDs + 1] = {NAME = 'infinitejump / infjump', DESC = 'Allows you to jump before hitting the ground'}
CMDs[#CMDs + 1] = {NAME = 'uninfinitejump / uninfjump', DESC = 'Disables infjump'}
CMDs[#CMDs + 1] = {NAME = 'flyjump', DESC = 'Allows you to hold space to fly up'}
CMDs[#CMDs + 1] = {NAME = 'unflyjump', DESC = 'Disables flyjump'}
CMDs[#CMDs + 1] = {NAME = 'autojump / ajump', DESC = 'Automatically jumps when you run into an object'}
CMDs[#CMDs + 1] = {NAME = 'unautojump / unajump', DESC = 'Disables autojump'}
CMDs[#CMDs + 1] = {NAME = 'edgejump / ejump', DESC = 'Automatically jumps when you get to the edge of an object'}
CMDs[#CMDs + 1] = {NAME = 'unedgejump / unejump', DESC = 'Disables edgejump'}
CMDs[#CMDs + 1] = {NAME = 'platformstand / stun', DESC = 'Enables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'unplatformstand / unstun', DESC = 'Disables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'norotate / noautorotate', DESC = 'Disables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'unnorotate / autorotate', DESC = 'Enables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'enablestate [StateType]', DESC = 'Enables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'disablestate [StateType]', DESC = 'Disables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'team [team name] (CLIENT)', DESC = 'Changes your team. Sometimes fools localscripts.'}
CMDs[#CMDs + 1] = {NAME = 'nobillboardgui / nobgui / noname', DESC = 'Removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'loopnobgui / loopnoname', DESC = 'Loop removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'unloopnobgui / unloopnoname', DESC = 'Disables loopnobgui'}
CMDs[#CMDs + 1] = {NAME = 'noarms', DESC = 'Removes your arms'}
CMDs[#CMDs + 1] = {NAME = 'nolegs', DESC = 'Removes your legs'}
CMDs[#CMDs + 1] = {NAME = 'nolimbs', DESC = 'Removes your limbs'}
CMDs[#CMDs + 1] = {NAME = 'naked (CLIENT)', DESC = 'Removes your clothing'}
CMDs[#CMDs + 1] = {NAME = 'noface / removeface', DESC = 'Removes your face'}
CMDs[#CMDs + 1] = {NAME = 'blockhead', DESC = 'Turns your head into a block'}
CMDs[#CMDs + 1] = {NAME = 'blockhats', DESC = 'Turns your hats into blocks'}
CMDs[#CMDs + 1] = {NAME = 'blocktool', DESC = 'Turns the currently selected tool into a block'}
CMDs[#CMDs + 1] = {NAME = 'creeper', DESC = 'Makes you look like a creeper'}
CMDs[#CMDs + 1] = {NAME = 'drophats', DESC = 'Drops your hats'}
CMDs[#CMDs + 1] = {NAME = 'nohats / deletehats / rhats', DESC = 'Deletes your hats'}
CMDs[#CMDs + 1] = {NAME = 'hatspin / spinhats', DESC = 'Spins your characters accessories'}
CMDs[#CMDs + 1] = {NAME = 'unhatspin / unspinhats', DESC = 'Undoes spinhats'}
CMDs[#CMDs + 1] = {NAME = 'clearhats / cleanhats', DESC = 'Clears hats in the workspace'}
CMDs[#CMDs + 1] = {NAME = 'chardelete / cd [instance name]', DESC = 'Removes any part with a certain name from your character'}
CMDs[#CMDs + 1] = {NAME = 'chardeleteclass / cdc [class name]', DESC = 'Removes any part with a certain classname from your character'}
CMDs[#CMDs + 1] = {NAME = 'deletevelocity / dv / removeforces', DESC = 'Removes any velocity / force instances in your character'}
CMDs[#CMDs + 1] = {NAME = 'weaken [num]', DESC = 'Makes your character less dense'}
CMDs[#CMDs + 1] = {NAME = 'unweaken', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'strengthen [num]', DESC = 'Makes your character more dense (CustomPhysicalProperties)'}
CMDs[#CMDs + 1] = {NAME = 'unstrengthen', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'breakvelocity', DESC = 'Sets your characters velocity to 0'}
CMDs[#CMDs + 1] = {NAME = 'spin [speed]', DESC = 'Spins your character'}
CMDs[#CMDs + 1] = {NAME = 'unspin', DESC = 'Disables spin'}
CMDs[#CMDs + 1] = {NAME = 'split', DESC = 'Splits your character in half'}
CMDs[#CMDs + 1] = {NAME = 'nilchar', DESC = 'Sets your characters parent to nil'}
CMDs[#CMDs + 1] = {NAME = 'unnilchar / nonilchar', DESC = 'Sets your characters parent to workspace'}
CMDs[#CMDs + 1] = {NAME = 'noroot / removeroot / rroot', DESC = 'Removes your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'replaceroot', DESC = 'Replaces your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'clearcharappearance / clearchar / clrchar', DESC = 'Removes all accessory, shirt, pants, charactermesh, and bodycolors'}
CMDs[#CMDs + 1] = {NAME = 'tpwalk / teleportwalk [num]', DESC = 'Teleports you to your move direction'}
CMDs[#CMDs + 1] = {NAME = 'untpwalk / unteleportwalk', DESC = 'Undoes tpwalk / teleportwalk'}
CMDs[#CMDs + 1] = {NAME = 'trip', DESC = 'Makes your character fall over'}
CMDs[#CMDs + 1] = {NAME = 'wallwalk / walkonwalls', DESC = 'Walk on walls'}
CMDs[#CMDs + 1] = {NAME = 'promptr6', DESC = 'Prompts the game to switch your rig type to R6'}
CMDs[#CMDs + 1] = {NAME = 'promptr15', DESC = 'Prompts the game to switch your rig type to R15'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'animation / anim [ID] [speed]', DESC = 'Makes your character perform an animation (must be an animation on the marketplace or by roblox/stickmasterluke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'emote / em [ID] [speed]', DESC = 'Makes your character perform an emote (must be on the marketplace or by roblox/stickmasterluke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'dance', DESC = 'Makes you  d a n c e'}
CMDs[#CMDs + 1] = {NAME = 'undance', DESC = 'Stops dance animations'}
CMDs[#CMDs + 1] = {NAME = 'spasm', DESC = 'Makes you  c r a z y'}
CMDs[#CMDs + 1] = {NAME = 'unspasm', DESC = 'Stops spasm'}
CMDs[#CMDs + 1] = {NAME = 'headthrow', DESC = 'Simply makes you throw your head'}
CMDs[#CMDs + 1] = {NAME = 'noanim', DESC = 'Disables your animations'}
CMDs[#CMDs + 1] = {NAME = 'reanim', DESC = 'Restores your animations'}
CMDs[#CMDs + 1] = {NAME = 'animspeed [num]', DESC = 'Changes the speed of your current animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimation / copyanim / copyemote [player]', DESC = 'Copies someone elses animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimationid / copyanimid / copyemoteid [player]', DESC = 'Copies your animation id or someone elses to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'loopanimation / loopanim', DESC = 'Loops your current animation'}
CMDs[#CMDs + 1] = {NAME = 'stopanimations / stopanims', DESC = 'Stops running animations'}
CMDs[#CMDs + 1] = {NAME = 'refreshanimations / refreshanims', DESC = 'Refreshes animations'}
CMDs[#CMDs + 1] = {NAME = 'allowcustomanim / allowcustomanimations', DESC = 'Lets you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = 'unallowcustomanim / unallowcustomanimations', DESC = 'Doesn\'t let you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'autoclick [click delay] [release delay]', DESC = 'Automatically clicks your mouse with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautoclick / noautoclick', DESC = 'Turns off autoclick'}
CMDs[#CMDs + 1] = {NAME = 'autokeypress [key] [down delay] [up delay]', DESC = 'Automatically presses a key with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautokeypress', DESC = 'Stops autokeypress'}
CMDs[#CMDs + 1] = {NAME = 'hovername', DESC = 'Shows a players username when your mouse is hovered over them'}
CMDs[#CMDs + 1] = {NAME = 'unhovername / nohovername', DESC = 'Turns off hovername'}
CMDs[#CMDs + 1] = {NAME = 'mousesensitivity / ms [0-10]', DESC = 'Sets your mouse sensitivity (affects first person and right click drag) (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'clickdelete', DESC = 'Go to Settings > Keybinds > Add for click delete'}
CMDs[#CMDs + 1] = {NAME = 'clickteleport', DESC = 'Go to Settings > Keybinds > Add for click teleport'}
CMDs[#CMDs + 1] = {NAME = 'mouseteleport / mousetp', DESC = 'Teleports your character to your mouse. This is recommended as a keybind'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'tools', DESC = 'Copies tools from ReplicatedStorage and Lighting'}
CMDs[#CMDs + 1] = {NAME = 'notools / removetools / deletetools', DESC = 'Removes tools from character and backpack'}
CMDs[#CMDs + 1] = {NAME = 'deleteselectedtool / dst', DESC = 'Removes any currently selected tools'}
CMDs[#CMDs + 1] = {NAME = 'grabtools', DESC = 'Automatically get tools that are dropped'}
CMDs[#CMDs + 1] = {NAME = 'ungrabtools / nograbtools', DESC = 'Disables grabtools'}
CMDs[#CMDs + 1] = {NAME = 'copytools [player] (CLIENT)', DESC = 'Copies a players tools'}
CMDs[#CMDs + 1] = {NAME = 'dupetools / clonetools [num]', DESC = 'Duplicates your inventory tools a set amount of times'}
CMDs[#CMDs + 1] = {NAME = 'droptools', DESC = 'Drops your tools'}
CMDs[#CMDs + 1] = {NAME = 'droppabletools', DESC = 'Makes your tools droppable'}
CMDs[#CMDs + 1] = {NAME = 'equiptools', DESC = 'Equips every tool in your inventory at once'}
CMDs[#CMDs + 1] = {NAME = 'unequiptools', DESC = 'Unequips every tool you are currently holding at once'}
CMDs[#CMDs + 1] = {NAME = 'removespecifictool [name]', DESC = 'Automatically remove a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'unremovespecifictool [name]', DESC = 'Stops removing a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'clearremovespecifictool', DESC = 'Stop removing all specific tools from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'reach [num]', DESC = 'Increases the hitbox of your held tool'}
CMDs[#CMDs + 1] = {NAME = 'boxreach [num]', DESC = 'Increases the hitbox of your held tool in a box shape'}
CMDs[#CMDs + 1] = {NAME = 'unreach / noreach', DESC = 'Turns off reach'}
CMDs[#CMDs + 1] = {NAME = 'grippos [X Y Z]', DESC = 'Changes your current tools grip position'}
CMDs[#CMDs + 1] = {NAME = 'usetools [amount] [delay]', DESC = 'Activates all tools in your backpack at the same time'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addalias [cmd] [alias]', DESC = 'Adds an alias to a command'}
CMDs[#CMDs + 1] = {NAME = 'removealias [alias]', DESC = 'Removes a custom alias'}
CMDs[#CMDs + 1] = {NAME = 'clraliases', DESC = 'Removes all custom aliases'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addplugin / plugin [name]', DESC = 'Add a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'removeplugin / deleteplugin [name]', DESC = 'Remove a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'reloadplugin [name]', DESC = 'Reloads a plugin'}
CMDs[#CMDs + 1] = {NAME = 'addallplugins / loadallplugins', DESC = 'Adds all available plugins from the workspace folder'}
-- wait()

for i = 1, #CMDs do
	local newcmd = Example:Clone()
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = CMDs[i].NAME
	newcmd.Name = "CMD"
	table.insert(text1, newcmd)
	if CMDs[i].DESC ~= "" then
		newcmd:SetAttribute("Title", CMDs[i].NAME)
		newcmd:SetAttribute("Desc", CMDs[i].DESC)
		newcmd.MouseButton1Down:Connect(function()
			if not IsOnMobile and newcmd.Visible and newcmd.TextTransparency == 0 then
				local currentText = Cmdbar.Text
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text, currentText)
				maximizeHolder()
			end
		end)
	end
end

IndexContents("", true)

function checkTT()
	local t
	local guisAtPosition = COREGUI:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)

	for _, gui in pairs(guisAtPosition) do
		if gui.Parent == CMDsF then
			t = gui
		end
	end

	if t ~= nil and t:GetAttribute("Title") ~= nil then
		local x = IYMouse.X
		local y = IYMouse.Y
		local xP
		local yP
		if IYMouse.X > 200 then
			xP = x - 201
		else
			xP = x + 21
		end
		if IYMouse.Y > (IYMouse.ViewSizeY-96) then
			yP = y - 97
		else
			yP = y
		end
		Tooltip.Position = UDim2.new(0, xP, 0, yP)
		Description.Text = t:GetAttribute("Desc")
		if t:GetAttribute("Title") ~= nil then
			Title_3.Text = t:GetAttribute("Title")
		else
			Title_3.Text = ''
		end
		Tooltip.Visible = true
	else
		Tooltip.Visible = false
	end
end

function FindInTable(tbl,val)
	if tbl == nil then return false end
	for _,v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

function GetInTable(Table, Name)
	for i = 1, #Table do
		if Table[i] == Name then
			return i
		end
	end
	return false
end

function respawn(plr)
	if invisRunning then TurnVisible() end
    local char = plr.Character
    local hum = char:FindFirstChildWhichIsA("Humanoid")
	local archive = workspace.FallenPartsDestroyHeight
	local camType = workspace.CurrentCamera.CameraType
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.FallenPartsDestroyHeight = 0/0
    getRoot(char).Position = Vector3.yAxis * archive
	task.wait(plr:GetNetworkPing())
	workspace.FallenPartsDestroyHeight = archive
	repeat task.wait() until not char.Parent or not hum.Parent or (hum and hum.Health <= 0)
	if hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end
end

local refreshCmd = false
function refresh(plr)
	refreshCmd = true
	local root = getRoot(plr.Character)
	local pos = root.CFrame
	local pos1 = workspace.CurrentCamera.CFrame
	respawn(plr)
	task.spawn(function()
		local char = plr.CharacterAdded:Wait()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		while not humanoid do
			wait()
			humanoid = char:FindFirstChildOfClass("Humanoid")
		end
		humanoid.RootPart.CFrame, workspace.CurrentCamera.CFrame = pos, task.wait() and pos1
		refreshCmd = false
	end)
end

local lastDeath

function onDied()
	task.spawn(function()
		if pcall(function() Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') end) and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
			Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				if getRoot(Players.LocalPlayer.Character) then
					lastDeath = getRoot(Players.LocalPlayer.Character).CFrame
				end
			end)
		else
			wait(2)
			onDied()
		end
	end)
end

Clip = true
spDelay = 0.1
Players.LocalPlayer.CharacterAdded:Connect(function()
	NOFLY()
	floating = false

	if not Clip then
		execCmd('clip')
	end

	repeat wait() until getRoot(Players.LocalPlayer.Character)

	pcall(function()
		if spawnpoint and not refreshCmd and spawnpos ~= nil then
			wait(spDelay)
			getRoot(Players.LocalPlayer.Character).CFrame = spawnpos
		end
	end)

	onDied()
end)

onDied()

local booly = {
    truthy = { ["true"] = true, ["t"] = true, ["1"] = true, ["yes"] = true, ["y"] = true, ["on"] = true, ["enable"] = true, ["enabled"] = true },
    falsy = { ["false"] = true, ["f"] = true, ["0"] = true, ["no"] = true, ["n"] = true, ["off"] = true, ["disable"] = true, ["disabled"] = true },
}

function parseBoolean(raw, default)
    raw = tostring(raw):lower()
    if booly.truthy[raw] then return true end
    if booly.falsy[raw] then return false end
    return default or false
end

function getstring(begin, args)
    return table.concat(args or cargs, " ", begin)
end

findCmd=function(cmd_name)
	for i,v in pairs(cmds)do
		if v.NAME:lower()==cmd_name:lower() or FindInTable(v.ALIAS,cmd_name:lower()) then
			return v
		end
	end
	return customAlias[cmd_name:lower()]
end

function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

cmdHistory = {}
local lastCmds = {}
local historyCount = 0
local split=" "
local lastBreakTime = 0
function execCmd(cmdStr,speaker,store)
	cmdStr = cmdStr:gsub("%s+$", "")
	task.spawn(function()
		local rawCmdStr = cmdStr
		cmdStr = string.gsub(cmdStr, "\\\\", "%%BackSlash%%")

		local commandsToRun = splitString(cmdStr, "\\")
		for i, v in pairs(commandsToRun) do
			v = string.gsub(v, "%%BackSlash%%", "\\")
			local x, y, num = v:find("^(%d+)%^")
			local cmdDelay = 0
			local infTimes = false

			if num then
				v = v:sub(y + 1)
				local x, y, del = v:find("^([%d%.]+)%^")
				if del then
					v = v:sub(y + 1)
					cmdDelay = tonumber(del) or 0
				end
			else
				local x, y = v:find("^inf%^")
				if x then
					infTimes = true
					v = v:sub(y + 1)
					local x, y, del = v:find("^([%d%.]+)%^")
					if del then
						v = v:sub(y + 1)
						del = tonumber(del) or 1
						cmdDelay = (del > 0 and del or 1)
					else
						cmdDelay = 1
					end
				end
			end
			num = tonumber(num or 1)

			if v:sub(1, 1) == "!" then
				local chunks = splitString(v:sub(2), split)
				if chunks[1] and lastCmds[chunks[1]] then v = lastCmds[chunks[1]] end
			end

			local args = splitString(v, split)
			local cmdName = args[1]
			local cmd = findCmd(cmdName)
			if cmd then
				table.remove(args, 1)
				cargs = args
				if not speaker then speaker = Players.LocalPlayer end

				if store then
					if speaker == Players.LocalPlayer then
						if cmdHistory[1] ~= rawCmdStr and rawCmdStr:sub(1, 11) ~= "lastcommand" and rawCmdStr:sub(1, 7) ~= "lastcmd" then
							table.insert(cmdHistory, 1, rawCmdStr)
						end
					end
					if #cmdHistory > 30 then table.remove(cmdHistory) end

					lastCmds[cmdName] = v
				end

				local cmdStartTime = tick()
				if infTimes then
					while lastBreakTime < cmdStartTime do
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
						end
						wait(cmdDelay)
					end
				else
					for rep = 1, num do
						if lastBreakTime > cmdStartTime then break end
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
							notify("Command Error: " .. cmdName, "Check console")
						end
						if success and type(err) == "string" and not table.find(args, "nonotify") then
							notify("Command: " .. cmdName, err)
						end
						if cmdDelay ~= 0 then wait(cmdDelay) end
					end
				end
			end
		end
	end)
end

function addcmd(name,alias,func,plgn)
	cmds[#cmds+1]=
		{
			NAME=name;
			ALIAS=alias or {};
			FUNC=func;
			PLUGIN=plgn;
		}
end

function removecmd(cmd)
	if cmd ~= " " then
		for i = #cmds,1,-1 do
			if cmds[i].NAME == cmd or FindInTable(cmds[i].ALIAS,cmd) then
				table.remove(cmds, i)
				for a,c in pairs(CMDsF:GetChildren()) do
					if string.find(c.Text, "^"..cmd.."$") or string.find(c.Text, "^"..cmd.." ") or string.find(c.Text, " "..cmd.."$") or string.find(c.Text, " "..cmd.." ") then
						c.TextTransparency = 0.7
						c.MouseButton1Click:Connect(function()
							notify(c.Text, "Command has been disabled by you or a plugin")
						end)
					end
				end
			end
		end
	end
end

function overridecmd(name, func)
	local cmd = findCmd(name)
	if cmd and cmd.FUNC then cmd.FUNC = func end
end

function addbind(cmd,key,iskeyup,toggle)
	if toggle then
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
				TOGGLE = toggle;
			}
	else
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
			}
	end
end

function addcmdtext(text,name,desc)
	local newcmd = Example:Clone()
	local tooltipText = tostring(text)
	local tooltipDesc = tostring(desc)
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = text
	newcmd.Name = 'PLUGIN_'..name
	table.insert(text1,newcmd)
	if desc and desc ~= '' then
		newcmd:SetAttribute("Title", tooltipText)
		newcmd:SetAttribute("Desc", tooltipDesc)
		newcmd.MouseButton1Down:Connect(function()
			if newcmd.Visible and newcmd.TextTransparency == 0 then
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text)
				maximizeHolder()
			end
		end)
	end
end

local WorldToScreen = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local MousePositionToVector2 = function()
	return Vector2.new(IYMouse.X, IYMouse.Y)
end

local GetClosestPlayerFromCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if string.find(x.Name, "Torso") then
					local Distance = (WorldToScreen(x) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end

SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild('Pal Hair') or plr.Character:FindFirstChild('Kate Hair') then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker,args)
		local returns = {}
		local age = tonumber(args[1])
		if not age == nil then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker,args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then  
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker,args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns,plr) end
			end
		end
		return returns
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
	["npcs"] = function(speaker,args)
		local returns = {}
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and getRoot(v) and v:FindFirstChildWhichIsA("Humanoid") and Players:GetPlayerFromCharacter(v) == nil then
				local clone = Instance.new("Player")
				clone.Name = v.Name .. " - " .. v:FindFirstChildWhichIsA("Humanoid").DisplayName
				clone.Character = v
				table.insert(returns, clone)
			end
		end
		return returns
	end,
}

function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end

function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end

function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end

function formatUsername(player)
	if player.DisplayName ~= player.Name then
		return string.format("%s (%s)", player.Name, player.DisplayName)
	end
	return player.Name
end

getprfx=function(strn)
	if strn:sub(1,string.len(prefix))==prefix then return{'cmd',string.len(prefix)+1}
	end return
end

function do_exec(str, plr)
	str = str:gsub('/e ', '')
	local t = getprfx(str)
	if not t then return end
	str = str:sub(t[2])
	if t[1]=='cmd' then
		execCmd(str, plr, true)
		IndexContents('',true,false,true)
		CMDsF.CanvasPosition = canvasPos
	end
end

lastTextBoxString,lastTextBoxCon,lastEnteredString = nil,nil,nil

UserInputService.TextBoxFocused:Connect(function(obj)
	if lastTextBoxCon then lastTextBoxCon:Disconnect() end
	if obj == Cmdbar then lastTextBoxString = nil return end
	lastTextBoxString = obj.Text
	lastTextBoxCon = obj:GetPropertyChangedSignal("Text"):Connect(function()
		if not (UserInputService:IsKeyDown(Enum.KeyCode.Return) or UserInputService:IsKeyDown(Enum.KeyCode.KeypadEnter)) then
			lastTextBoxString = obj.Text
		end
	end)
end)

UserInputService.InputBegan:Connect(function(input,gameProcessed)
	if gameProcessed then
		if Cmdbar and Cmdbar:IsFocused() then
			if input.KeyCode == Enum.KeyCode.Up then
				historyCount = historyCount + 1
				if historyCount > #cmdHistory then historyCount = #cmdHistory end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			elseif input.KeyCode == Enum.KeyCode.Down then
				historyCount = historyCount - 1
				if historyCount < 0 then historyCount = 0 end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			end
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			lastEnteredString = lastTextBoxString
		end
	end
end)

Players.LocalPlayer.Chatted:Connect(function()
	wait()
	if lastEnteredString then
		local message = lastEnteredString
		lastEnteredString = nil
		do_exec(message, Players.LocalPlayer)
	end
end)

Cmdbar.PlaceholderText = "Command Bar ("..prefix..")"
Cmdbar:GetPropertyChangedSignal("Text"):Connect(function()
	if Cmdbar:IsFocused() then
		IndexContents(Cmdbar.Text,true,true)
	end
end)

local tabComplete = nil
tabAllowed = true
Cmdbar.FocusLost:Connect(function(enterpressed)
	if enterpressed then
		local cmdbarText = Cmdbar.Text:gsub("^"..prefix,"")
		execCmd(cmdbarText,Players.LocalPlayer,true)
	end
	if tabComplete then tabComplete:Disconnect() end
	wait()
	if not Cmdbar:IsFocused() then
		Cmdbar.Text = ""
		IndexContents('',true,false,true)
		if SettingsOpen == true then
			wait(0.2)
			Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.2, true, nil)
			CMDsF.Visible = false
		end
	end
	CMDsF.CanvasPosition = canvasPos
end)

Cmdbar.Focused:Connect(function()
	historyCount = 0
	canvasPos = CMDsF.CanvasPosition
	if SettingsOpen == true then
		wait(0.2)
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.2, true, nil)
	end
	tabComplete = UserInputService.InputBegan:Connect(function(input,gameProcessed)
		if Cmdbar:IsFocused() then
			if tabAllowed == true and input.KeyCode == Enum.KeyCode.Tab and topCommand ~= nil then
				autoComplete(topCommand)
			end
		else
			tabComplete:Disconnect()
		end
	end)
end)

ESPenabled = false
CHMSenabled = false

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- How the ESP looks. Changed from the ESP settings dropdown (the arrow on the ESP switch)
-- and saved between sessions.
espSettingsFile = "SpreadCheeksGUI_ESP.json"
espDefaultSettings = {
	outline = true,
	fill = false,
	box = false,
	tracers = false,
	name = true,
	distance = true,
	health = true,
	enemiesOnly = false, -- hide players on your own team
	colorMode = "Team", -- "Team", "Theme" or "Custom"
	customColor = "B1A4FF",
}
espSettings = {}
for key, value in pairs(espDefaultSettings) do
	espSettings[key] = value
end
-- Bumped on every look change; each player's ESP restyles itself when it sees a new value.
espStyleVersion = 0

function loadEspSettings()
	if not readfile then return end
	local readOk, contents = readfile(espSettingsFile, true)
	if not readOk or type(contents) ~= "string" or contents == "" then return end
	local decodeOk, data = pcall(function() return HttpService:JSONDecode(contents) end)
	if not decodeOk or type(data) ~= "table" then return end
	for key, default in pairs(espDefaultSettings) do
		if type(data[key]) == type(default) then
			espSettings[key] = data[key]
		end
	end
	if not table.find({ "Team", "Theme", "Custom" }, espSettings.colorMode) then
		espSettings.colorMode = espDefaultSettings.colorMode
	end
end

function saveEspSettings()
	espStyleVersion += 1
	if writefile then
		writefile(espSettingsFile, HttpService:JSONEncode(espSettings), true)
	end
end

loadEspSettings()

-- The menu theme sets this; chams and the Team/Theme ESP colour modes use it.
espAccentColor = Color3.fromRGB(177, 164, 255)
function setEspAccentColor(color)
	espAccentColor = color
	espStyleVersion += 1
	for _, holder in pairs(COREGUI:GetChildren()) do
		if string.sub(holder.Name, -5) == '_CHMS' then
			local highlight = holder:FindFirstChild("PlayerHighlight")
			if highlight and highlight:GetAttribute("UsesThemeAccent") then
				highlight.FillColor = color
				highlight.OutlineColor = color
			end
		end
	end
end

function espColorFor(plr, logic)
	-- espteam keeps its soft green/red whichever colour mode is picked.
	if logic == true then
		return plr.TeamColor == Players.LocalPlayer.TeamColor and Color3.fromRGB(96, 214, 140) or Color3.fromRGB(240, 96, 96)
	end
	if espSettings.colorMode == "Custom" then
		local ok, color = pcall(Color3.fromHex, espSettings.customColor)
		if ok then return color end
	elseif espSettings.colorMode == "Team" and not plr.Neutral then
		return plr.TeamColor.Color
	end
	return espAccentColor
end

-- True when plr is on your team. Nobody is a teammate when either of you has no team, so in
-- games without teams everyone counts as an enemy.
function espIsTeammate(plr)
	local me = Players.LocalPlayer
	if plr == me or me.Neutral or plr.Neutral then return false end
	if me.Team and plr.Team then return me.Team == plr.Team end
	return plr.TeamColor == me.TeamColor
end

function ESP(plr, logic)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_ESP') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_ESP'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			local character = plr.Character
			local root = getRoot(character)
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if root and humanoid then
				-- Colours and which parts show are set by applyStyle below.
				local highlight = Instance.new("Highlight")
				highlight.Name = "PlayerHighlight"
				highlight.Adornee = character
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Parent = ESPholder

				-- Box: sized every frame to the character's height on screen (see espLoop), but never
				-- smaller than minBoxHeight pixels, so far-away players stay easy to spot.
				local head = character:FindFirstChild("Head")
				local legHeight = humanoid.RigType == Enum.HumanoidRigType.R15 and humanoid.HipHeight or 2
				local boxBottom = -(legHeight + root.Size.Y / 2)
				local boxTop = head and math.clamp(head.Position.Y + head.Size.Y / 2 - root.Position.Y, 1.5, 6) or 2.5
				local boxHeight = boxTop - boxBottom + 0.4
				local boxCenter = (boxTop + boxBottom) / 2
				local minBoxHeight = 28
				local BoxGui = Instance.new("BillboardGui")
				BoxGui.Name = "PlayerBox"
				BoxGui.Adornee = root
				BoxGui.Size = UDim2.fromOffset(minBoxHeight * 0.6, minBoxHeight)
				BoxGui.StudsOffsetWorldSpace = Vector3.new(0, boxCenter, 0)
				BoxGui.AlwaysOnTop = true
				BoxGui.LightInfluence = 0
				BoxGui.MaxDistance = math.huge
				BoxGui.ClipsDescendants = false
				BoxGui.Parent = ESPholder
				-- A soft dark edge behind the coloured line keeps the box visible on bright maps.
				local boxShadow = Instance.new("Frame")
				boxShadow.Position = UDim2.fromOffset(2, 2)
				boxShadow.Size = UDim2.new(1, -4, 1, -4)
				boxShadow.BackgroundTransparency = 1
				boxShadow.Parent = BoxGui
				local boxShadowStroke = Instance.new("UIStroke")
				boxShadowStroke.Color = Color3.new(0, 0, 0)
				boxShadowStroke.Thickness = 3
				boxShadowStroke.Transparency = 0.6
				boxShadowStroke.Parent = boxShadow
				local boxFrame = Instance.new("Frame")
				boxFrame.Position = UDim2.fromOffset(2, 2)
				boxFrame.Size = UDim2.new(1, -4, 1, -4)
				boxFrame.BackgroundTransparency = 1
				boxFrame.ZIndex = 2
				boxFrame.Parent = BoxGui
				local boxStroke = Instance.new("UIStroke")
				boxStroke.Thickness = 1.5
				boxStroke.Parent = boxFrame

				-- Tracer: a line from the bottom of the screen to the player's feet.
				local TracerGui = Instance.new("ScreenGui")
				TracerGui.Name = "PlayerTracer"
				TracerGui.IgnoreGuiInset = true
				TracerGui.ResetOnSpawn = false
				TracerGui.Parent = ESPholder
				local tracerLine = Instance.new("Frame")
				tracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
				tracerLine.BackgroundTransparency = 0.2
				tracerLine.BorderSizePixel = 0
				tracerLine.Visible = false
				tracerLine.Parent = TracerGui

				-- One floating line above the player: name, distance and a thin health bar. It shares
				-- the box's anchor and espLoop resizes it so the text sits just above the player.
				local TagGui = Instance.new("BillboardGui")
				TagGui.Name = "PlayerTag"
				TagGui.Adornee = root
				TagGui.Size = UDim2.fromOffset(180, 26)
				TagGui.StudsOffsetWorldSpace = Vector3.new(0, boxCenter, 0)
				TagGui.AlwaysOnTop = true
				TagGui.LightInfluence = 0
				TagGui.MaxDistance = math.huge
				TagGui.Parent = ESPholder

				local displayName = plr.DisplayName:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
				local NameLabel = Instance.new("TextLabel")
				NameLabel.Name = "PlayerName"
				NameLabel.BackgroundTransparency = 1
				NameLabel.Size = UDim2.new(1, 0, 0, 16)
				NameLabel.Font = Enum.Font.GothamBold
				NameLabel.RichText = true
				NameLabel.Text = displayName
				NameLabel.TextColor3 = Color3.fromRGB(245, 247, 255)
				NameLabel.TextSize = 13
				NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
				NameLabel.TextStrokeTransparency = 0.4
				NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
				NameLabel.Parent = TagGui

				local HealthBackground = Instance.new("Frame")
				HealthBackground.Name = "HealthBackground"
				HealthBackground.AnchorPoint = Vector2.new(0.5, 0)
				HealthBackground.Position = UDim2.new(0.5, 0, 0, 19)
				HealthBackground.Size = UDim2.fromOffset(54, 3)
				HealthBackground.BackgroundColor3 = Color3.fromRGB(12, 14, 19)
				HealthBackground.BackgroundTransparency = 0.35
				HealthBackground.BorderSizePixel = 0
				HealthBackground.Parent = TagGui
				local healthBackCorner = Instance.new("UICorner")
				healthBackCorner.CornerRadius = UDim.new(1, 0)
				healthBackCorner.Parent = HealthBackground

				local HealthFill = Instance.new("Frame")
				HealthFill.Name = "HealthFill"
				HealthFill.BackgroundColor3 = Color3.fromRGB(96, 214, 140)
				HealthFill.BorderSizePixel = 0
				HealthFill.Size = UDim2.fromScale(1, 1)
				HealthFill.Parent = HealthBackground
				local healthFillCorner = Instance.new("UICorner")
				healthFillCorner.CornerRadius = UDim.new(1, 0)
				healthFillCorner.Parent = HealthFill
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local lastTagText
				local appliedStyle = -1
				-- With "Only show enemies" on, a teammate's ESP stays built but hidden, so it comes
				-- back straight away if either of you changes team or the option is turned off.
				local hiddenAsTeammate = false
				local function shouldHide()
					return espSettings.enemiesOnly == true and espIsTeammate(plr)
				end
				local function applyStyle()
					appliedStyle = espStyleVersion
					hiddenAsTeammate = shouldHide()
					local show = not hiddenAsTeammate
					local color = espColorFor(plr, logic)
					highlight.Enabled = show and (espSettings.outline or espSettings.fill)
					highlight.FillColor = color
					highlight.OutlineColor = color
					-- esptransparency still controls how strong the fill is.
					highlight.FillTransparency = espSettings.fill and math.clamp(espTransparency + 0.35, 0.35, 0.95) or 1
					highlight.OutlineTransparency = espSettings.outline and 0.15 or 1
					BoxGui.Enabled = show and espSettings.box
					boxStroke.Color = color
					TracerGui.Enabled = show and espSettings.tracers
					tracerLine.BackgroundColor3 = color
					TagGui.Enabled = show and (espSettings.name or espSettings.distance or espSettings.health)
					HealthBackground.Visible = espSettings.health
					lastTagText = nil
				end
				local function espLoop()
					if COREGUI:FindFirstChild(plr.Name..'_ESP') then
						if appliedStyle ~= espStyleVersion or shouldHide() ~= hiddenAsTeammate then
							applyStyle()
						end
						if hiddenAsTeammate then return end
						local myRoot = Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character)
						local targetRoot = plr.Character and getRoot(plr.Character)
						local targetHumanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
						if myRoot and targetRoot and targetHumanoid then
							local distance = math.floor((myRoot.Position - targetRoot.Position).Magnitude)
							local healthRatio = math.clamp(targetHumanoid.Health / math.max(targetHumanoid.MaxHealth, 1), 0, 1)
							local tagText = espSettings.name and displayName or ""
							if espSettings.distance then
								tagText = tagText .. (tagText ~= "" and "  " or "") .. '<font size="11" color="#A9B1C2">' .. distance .. ' studs</font>'
							end
							if tagText ~= lastTagText then
								lastTagText = tagText
								NameLabel.Text = tagText
							end
							HealthFill.Size = UDim2.fromScale(healthRatio, 1)
							HealthFill.BackgroundColor3 = Color3.fromHSV(healthRatio * 0.33, 0.7, 0.95)
							local camera = workspace.CurrentCamera
							local viewport = camera.ViewportSize
							local center = camera:WorldToViewportPoint(targetRoot.Position + Vector3.new(0, boxCenter, 0))
							if center.Z > 0 then
								-- How tall the character is on screen right now (capped so a camera inside
								-- them can't blow the billboards up to absurd sizes).
								local pixelsPerStud = viewport.Y / (2 * center.Z * math.tan(math.rad(camera.FieldOfView) / 2))
								local bodyPixels = math.min(boxHeight * pixelsPerStud, viewport.Y * 1.5)
								local boxPixels = math.max(bodyPixels, minBoxHeight)
								if espSettings.box then
									BoxGui.Size = UDim2.fromOffset(boxPixels * 0.6, boxPixels)
								end
								-- The tag's text fills its top 26px; this height leaves it 6px above the box
								-- (or the body when the box is off), however near or far the player is.
								TagGui.Size = UDim2.fromOffset(180, (espSettings.box and boxPixels or bodyPixels) + 64)
							end
							if espSettings.tracers then
								local feet = camera:WorldToViewportPoint(targetRoot.Position + Vector3.new(0, boxBottom, 0))
								if feet.Z > 0 then
									local from = Vector2.new(viewport.X / 2, viewport.Y)
									local delta = Vector2.new(feet.X, feet.Y) - from
									tracerLine.Position = UDim2.fromOffset(from.X + delta.X / 2, from.Y + delta.Y / 2)
									tracerLine.Size = UDim2.fromOffset(delta.Magnitude, 1.5)
									tracerLine.Rotation = math.deg(math.atan2(delta.Y, delta.X))
									tracerLine.Visible = true
								else
									-- Behind the camera there's no sensible place to draw the line.
									tracerLine.Visible = false
								end
							end
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				espLoopFunc = RunService.RenderStepped:Connect(espLoop)
			end
		end
	end)
end

function CHMS(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_CHMS' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_CHMS') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_CHMS'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			-- One filled silhouette that follows the real body shape and accessories,
			-- instead of a solid box around every part.
			local usesThemeAccent = plr.Neutral
			local chamsColor = usesThemeAccent and espAccentColor or plr.TeamColor.Color
			local highlight = Instance.new("Highlight")
			highlight.Name = "PlayerHighlight"
			highlight.Adornee = plr.Character
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = chamsColor
			-- esptransparency still controls the fill; the rim keeps the shape readable.
			highlight.FillTransparency = math.clamp(espTransparency + 0.25, 0.25, 0.9)
			highlight.OutlineColor = chamsColor
			highlight.OutlineTransparency = 0.35
			highlight:SetAttribute("UsesThemeAccent", usesThemeAccent)
			highlight.Parent = ESPholder
			local addedFunc
			local teamChange
			local CHMSremoved
			addedFunc = plr.CharacterAdded:Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					teamChange:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					addedFunc:Disconnect()
				else
					teamChange:Disconnect()
					addedFunc:Disconnect()
				end
			end)
			teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					addedFunc:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					teamChange:Disconnect()
				else
					teamChange:Disconnect()
				end
			end)
			CHMSremoved = ESPholder.AncestryChanged:Connect(function()
				teamChange:Disconnect()
				addedFunc:Disconnect()
				CHMSremoved:Disconnect()
			end)
		end
	end)
end

function Locate(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_LC' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_LC') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_LC'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			local character = plr.Character
			-- In the menu's accent colour (espAccentColor follows the theme), so it stands apart
			-- from ESP and chams, which go by team.
			local accent = espAccentColor

			-- Their whole body, through walls: a soft fill with a solid rim, breathing gently so
			-- they're easy to pick out in a crowd.
			local highlight = Instance.new("Highlight")
			highlight.Name = "LocateHighlight"
			highlight.Adornee = character
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = accent
			highlight.FillTransparency = 0.6
			highlight.OutlineColor = accent
			highlight.OutlineTransparency = 0
			highlight.Parent = ESPholder

			-- Above their head: a tag with their name, how far away they are and their health.
			local head = character:FindFirstChild("Head") or getRoot(character)
			local tagGui = Instance.new("BillboardGui")
			tagGui.Name = "LocateTag"
			tagGui.Adornee = head
			tagGui.Size = UDim2.fromOffset(220, 56)
			tagGui.StudsOffsetWorldSpace = Vector3.new(0, 2.4, 0)
			tagGui.AlwaysOnTop = true
			tagGui.LightInfluence = 0
			tagGui.MaxDistance = math.huge
			tagGui.Parent = ESPholder
			local tag = Instance.new("Frame")
			tag.AnchorPoint = Vector2.new(0.5, 1)
			tag.Position = UDim2.fromScale(0.5, 1)
			tag.AutomaticSize = Enum.AutomaticSize.X
			tag.Size = UDim2.fromOffset(0, 44)
			tag.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
			tag.BackgroundTransparency = 0.12
			tag.BorderSizePixel = 0
			tag.Parent = tagGui
			local tagWidth = Instance.new("UISizeConstraint")
			tagWidth.MinSize = Vector2.new(96, 44)
			tagWidth.MaxSize = Vector2.new(210, 44)
			tagWidth.Parent = tag
			local tagCorner = Instance.new("UICorner")
			tagCorner.CornerRadius = UDim.new(0, 10)
			tagCorner.Parent = tag
			local tagStroke = Instance.new("UIStroke")
			tagStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			tagStroke.Color = accent
			tagStroke.Transparency = 0.35
			tagStroke.Parent = tag
			local tagPadding = Instance.new("UIPadding")
			tagPadding.PaddingTop = UDim.new(0, 6)
			tagPadding.PaddingLeft = UDim.new(0, 12)
			tagPadding.PaddingRight = UDim.new(0, 12)
			tagPadding.Parent = tag
			local tagLayout = Instance.new("UIListLayout")
			tagLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			tagLayout.Padding = UDim.new(0, 1)
			tagLayout.SortOrder = Enum.SortOrder.LayoutOrder
			tagLayout.Parent = tag
			local nameLabel = Instance.new("TextLabel")
			nameLabel.LayoutOrder = 1
			nameLabel.AutomaticSize = Enum.AutomaticSize.X
			nameLabel.Size = UDim2.fromOffset(0, 15)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.Text = plr.DisplayName
			nameLabel.TextColor3 = Color3.fromRGB(245, 247, 255)
			nameLabel.TextSize = 13
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.Parent = tag
			local detailLabel = Instance.new("TextLabel")
			detailLabel.LayoutOrder = 2
			detailLabel.AutomaticSize = Enum.AutomaticSize.X
			detailLabel.Size = UDim2.fromOffset(0, 13)
			detailLabel.BackgroundTransparency = 1
			detailLabel.Font = Enum.Font.Gotham
			detailLabel.Text = "@" .. plr.Name
			detailLabel.TextColor3 = Color3.fromRGB(169, 177, 194)
			detailLabel.TextSize = 11
			detailLabel.TextTruncate = Enum.TextTruncate.AtEnd
			detailLabel.Parent = tag
			local healthBack = Instance.new("Frame")
			healthBack.LayoutOrder = 3
			healthBack.Size = UDim2.new(1, 0, 0, 3)
			healthBack.BackgroundColor3 = Color3.fromRGB(40, 44, 56)
			healthBack.BorderSizePixel = 0
			healthBack.Parent = tag
			local healthBackCorner = Instance.new("UICorner")
			healthBackCorner.CornerRadius = UDim.new(1, 0)
			healthBackCorner.Parent = healthBack
			local healthFill = Instance.new("Frame")
			healthFill.Size = UDim2.fromScale(1, 1)
			healthFill.BorderSizePixel = 0
			healthFill.Parent = healthBack
			local healthFillCorner = Instance.new("UICorner")
			healthFillCorner.CornerRadius = UDim.new(1, 0)
			healthFillCorner.Parent = healthFill

			-- When they're off screen (or behind you), an arrow at the edge of the screen points the
			-- way, with the distance under it.
			local arrowGui = Instance.new("ScreenGui")
			arrowGui.Name = "LocateArrow"
			arrowGui.IgnoreGuiInset = true
			arrowGui.ResetOnSpawn = false
			arrowGui.Parent = ESPholder
			local arrow = Instance.new("Frame")
			arrow.AnchorPoint = Vector2.new(0.5, 0.5)
			arrow.Size = UDim2.fromOffset(36, 36)
			arrow.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
			arrow.BackgroundTransparency = 0.12
			arrow.BorderSizePixel = 0
			arrow.Visible = false
			arrow.Parent = arrowGui
			local arrowCorner = Instance.new("UICorner")
			arrowCorner.CornerRadius = UDim.new(1, 0)
			arrowCorner.Parent = arrow
			local arrowStroke = Instance.new("UIStroke")
			arrowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			arrowStroke.Color = accent
			arrowStroke.Transparency = 0.2
			arrowStroke.Parent = arrow
			local arrowIcon = Instance.new("ImageLabel")
			arrowIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			arrowIcon.Position = UDim2.fromScale(0.5, 0.5)
			arrowIcon.Size = UDim2.fromOffset(18, 18)
			arrowIcon.BackgroundTransparency = 1
			-- Rayfield's dropdown arrow, which points up; it's turned to face them.
			arrowIcon.Image = "rbxassetid://88479147175134"
			arrowIcon.ImageColor3 = accent
			arrowIcon.Parent = arrow
			local arrowDistance = Instance.new("TextLabel")
			arrowDistance.AnchorPoint = Vector2.new(0.5, 0)
			arrowDistance.Position = UDim2.new(0.5, 0, 1, 4)
			arrowDistance.Size = UDim2.fromOffset(90, 14)
			arrowDistance.BackgroundTransparency = 1
			arrowDistance.Font = Enum.Font.GothamBold
			arrowDistance.TextColor3 = Color3.fromRGB(245, 247, 255)
			arrowDistance.TextSize = 11
			arrowDistance.TextStrokeTransparency = 0.5
			arrowDistance.Parent = arrow

			local function applyAccent(color)
				accent = color
				highlight.FillColor = color
				highlight.OutlineColor = color
				tagStroke.Color = color
				arrowStroke.Color = color
				arrowIcon.ImageColor3 = color
			end

			local lcLoopFunc
			local addedFunc
			-- A new character (they respawned): start again on it.
			addedFunc = plr.CharacterAdded:Connect(function()
				if ESPholder ~= nil and ESPholder.Parent ~= nil then
					lcLoopFunc:Disconnect()
					ESPholder:Destroy()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					Locate(plr)
					addedFunc:Disconnect()
				else
					addedFunc:Disconnect()
				end
			end)
			local lastDistance, lastHealth = nil, nil
			local function lcLoop()
				if not ESPholder.Parent then
					addedFunc:Disconnect()
					lcLoopFunc:Disconnect()
					return
				end
				if espAccentColor ~= accent then
					applyAccent(espAccentColor)
				end
				highlight.FillTransparency = 0.6 + 0.14 * math.sin(os.clock() * 3)
				local targetRoot = plr.Character and getRoot(plr.Character)
				local targetHumanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
				local myRoot = Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character)
				if not targetRoot or not targetHumanoid then
					arrow.Visible = false
					return
				end
				local distance = myRoot and math.floor((myRoot.Position - targetRoot.Position).Magnitude) or nil
				if distance ~= lastDistance then
					lastDistance = distance
					detailLabel.Text = "@" .. plr.Name .. (distance and ("  ·  " .. distance .. " studs") or "")
					arrowDistance.Text = distance and (distance .. " studs") or ""
				end
				local health = math.clamp(targetHumanoid.Health / math.max(targetHumanoid.MaxHealth, 1), 0, 1)
				if health ~= lastHealth then
					lastHealth = health
					healthFill.Size = UDim2.fromScale(health, 1)
					healthFill.BackgroundColor3 = Color3.fromHSV(health * 0.33, 0.7, 0.95)
				end

				-- On screen, the outline and tag are enough; otherwise point to them from the edge.
				local camera = workspace.CurrentCamera
				local viewport = camera.ViewportSize
				local point = camera:WorldToViewportPoint(targetRoot.Position)
				local margin = 48
				local onScreen = point.Z > 0 and point.X >= margin and point.X <= viewport.X - margin
					and point.Y >= margin and point.Y <= viewport.Y - margin
				arrow.Visible = not onScreen
				if onScreen then return end
				local center = viewport / 2
				local direction = Vector2.new(point.X, point.Y) - center
				-- Behind the camera the projection comes out mirrored, so it's turned back around.
				if point.Z < 0 then direction = -direction end
				if direction.Magnitude < 1 then direction = Vector2.new(0, 1) end
				local halfX, halfY = center.X - margin, center.Y - margin
				local scale = math.min(halfX / math.max(math.abs(direction.X), 0.001), halfY / math.max(math.abs(direction.Y), 0.001))
				local edge = center + direction * scale
				arrow.Position = UDim2.fromOffset(edge.X, edge.Y)
				arrowIcon.Rotation = math.deg(math.atan2(direction.Y, direction.X)) + 90
			end
			lcLoopFunc = RunService.RenderStepped:Connect(lcLoop)
		end
	end)
end

local bindsGUI = KeybindEditor
local awaitingInput = false
local keySelected = false

function refreshbinds()
	if Holder_2 then
		Holder_2:ClearAllChildren()
		Holder_2.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #binds do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newbind = Example_2:Clone()
			newbind.Parent = Holder_2
			newbind.Visible = true
			newbind.Position = UDim2.new(0,0,0, Position + 5)
			table.insert(shade2,newbind)
			table.insert(shade2,newbind.Text)
			table.insert(text1,newbind.Text)
			table.insert(shade3,newbind.Text.Delete)
			table.insert(text2,newbind.Text.Delete)
			local input = tostring(binds[i].KEY)
			local key
			if input == 'RightClick' or input == 'LeftClick' then
				key = input
			else
				key = input:sub(14)
			end
			if binds[i].TOGGLE then
				newbind.Text.Text = key.." > "..binds[i].COMMAND.." / "..binds[i].TOGGLE
			else
				newbind.Text.Text = key.." > "..binds[i].COMMAND.."  "..(binds[i].ISKEYUP and "(keyup)" or "(keydown)")
			end
			Holder_2.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newbind.Text.Delete.MouseButton1Click:Connect(function()
				unkeybind(binds[i].COMMAND,binds[i].KEY)
			end)
		end
	end
end

refreshbinds()

toggleOn = {}

function unkeybind(cmd,key)
	for i = #binds,1,-1 do
		if binds[i].COMMAND == cmd and binds[i].KEY == key then
			toggleOn[binds[i]] = nil
			table.remove(binds, i)
		end
	end
	refreshbinds()
	updatesaves()
	if key == 'RightClick' or key == 'LeftClick' then
		notify('Keybinds Updated','Unbinded '..key..' from '..cmd)
	else
		notify('Keybinds Updated','Unbinded '..key:sub(14)..' from '..cmd)
	end
end

PositionsFrame.Delete.MouseButton1Click:Connect(function()
	execCmd('cpos')
end)

function refreshwaypoints()
	if #WayPoints > 0 or #pWayPoints > 0 then
		PositionsHint:Destroy()
	end
	if Holder_4 then
		Holder_4:ClearAllChildren()
		Holder_4.CanvasSize = UDim2.new(0, 0, 0, 10)
		local YSize = 25
		local num = 1
		for i = 1, #WayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = WayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..WayPoints[i].NAME)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..WayPoints[i].NAME)
			end)
			num = num+1
		end
		for i = 1, #pWayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = pWayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..pWayPoints[i].NAME)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..pWayPoints[i].NAME)
			end)
			num = num+1
		end
	end
end

refreshwaypoints()

function refreshaliases()
	if #aliases > 0 then
		AliasHint:Destroy()
	end
	if Holder_3 then
		Holder_3:ClearAllChildren()
		Holder_3.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #aliases do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newalias = Example_3:Clone()
			newalias.Parent = Holder_3
			newalias.Visible = true
			newalias.Position = UDim2.new(0,0,0, Position + 5)
			newalias.Text.Text = aliases[i].CMD.." > "..aliases[i].ALIAS
			table.insert(shade2,newalias)
			table.insert(shade2,newalias.Text)
			table.insert(text1,newalias.Text)
			table.insert(shade3,newalias.Text.Delete)
			table.insert(text2,newalias.Text.Delete)
			Holder_3.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newalias.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('removealias '..aliases[i].ALIAS)
			end)
		end
	end
end

local bindChosenKeyUp = false

BindTo.MouseButton1Click:Connect(function()
	awaitingInput = true
	BindTo.Text = 'Press something'
end)

BindTriggerSelect.MouseButton1Click:Connect(function()
	bindChosenKeyUp = not bindChosenKeyUp
	BindTriggerSelect.Text = bindChosenKeyUp and "KeyUp" or "KeyDown"
end)

newToggle = false
Cmdbar_3.Parent.Visible = false
On_2.MouseButton1Click:Connect(function()
	if newToggle == false then newToggle = true
		On_2.BackgroundTransparency = 0
		Cmdbar_3.Parent.Visible = true
		BindTriggerSelect.Visible = false
	else newToggle = false
		On_2.BackgroundTransparency = 1
		Cmdbar_3.Parent.Visible = false
		BindTriggerSelect.Visible = true
	end
end)

Add_2.MouseButton1Click:Connect(function()
	if keySelected then
		if string.find(Cmdbar_2.Text, "\\\\") or string.find(Cmdbar_3.Text, "\\\\") then
			notify('Keybind Error','Only use one backslash to keybind multiple commands into one keybind or command')
		else
			if newToggle and Cmdbar_3.Text ~= '' and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,false,Cmdbar_3.Text)
			elseif not newToggle and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,bindChosenKeyUp)
			else
				return
			end
			refreshbinds()
			updatesaves()
			if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
				notify('Keybinds Updated','Binded '..keyPressed..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			else
				notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			end
		end
	end
end)

Exit_2.MouseButton1Click:Connect(function()
	Cmdbar_2.Text = 'Command'
	Cmdbar_3.Text = 'Command 2'
	BindTo.Text = 'Click to bind'
	bindChosenKeyUp = false
	BindTriggerSelect.Text = "KeyDown"
	keySelected = false
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
end)

function onInputBegan(input,gameProcessed)
	if awaitingInput then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			keyPressed = tostring(input.KeyCode)
			BindTo.Text = keyPressed:sub(14)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			keyPressed = 'LeftClick'
			BindTo.Text = 'LeftClick'
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			keyPressed = 'RightClick'
			BindTo.Text = 'RightClick'
		end
		awaitingInput = false
		keySelected = true
	end
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if not v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					if v.TOGGLE then
						local isOn = toggleOn[v] == true
						toggleOn[v] = not isOn
						if isOn then
							execCmd(v.TOGGLE,Players.LocalPlayer)
						else
							execCmd(v.COMMAND,Players.LocalPlayer)
						end
					else
						execCmd(v.COMMAND,Players.LocalPlayer)
					end
				end
			end
		end
	end
end

function onInputEnded(input,gameProcessed)
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					execCmd(v.COMMAND,Players.LocalPlayer)
				end
			end
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

ClickTP.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clicktp',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click tp')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click tp')
		end
	end
end)

ClickDelete.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clickdel',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click delete')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click delete')
		end
	end
end)

local function clicktpFunc()
	pcall(function()
		local character = Players.LocalPlayer.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.SeatPart then
			humanoid.Sit = false
			wait(0.1)
		end

		local hipHeight = humanoid and humanoid.HipHeight > 0 and (humanoid.HipHeight + 1)
		local rootPart = getRoot(character)
		local rootPartPosition = rootPart.Position
		local hitPosition = IYMouse.Hit.Position
		local newCFrame = CFrame.new(
			hitPosition, 
			Vector3.new(rootPartPosition.X, hitPosition.Y, rootPartPosition.Z)
		) * CFrame.Angles(0, math.pi, 0)

		rootPart.CFrame = newCFrame + Vector3.new(0, hipHeight or 4, 0)
		breakVelocity()
	end)
end

IYMouse.Button1Down:Connect(function()
	for i,v in pairs(binds) do
		if v.COMMAND == 'clicktp' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) and Players.LocalPlayer.Character then
				clicktpFunc()
			end
		elseif v.COMMAND == 'clickdel' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) then
				pcall(function() IYMouse.Target:Destroy() end)
			end
		end
	end
end)

PluginsGUI = PluginEditor.background

function addPlugin(name)
	if name:lower() == 'plugin file name' or name:lower() == 'iy_fe.iy' or name == 'iy_fe' then
		notify('Plugin Error','Please enter a valid plugin')
	else
		local file
		local fileName
		if name:sub(-3) == '.iy' then
			pcall(function() file = readfile(name) end)
			fileName = name
		else
			pcall(function() file = readfile(name..'.iy') end)
			fileName = name..'.iy'
		end
		if file then
			if not FindInTable(PluginsTable, fileName) then
				table.insert(PluginsTable, fileName)
				LoadPlugin(fileName)
				refreshplugins()
				pcall(eventEditor.Refresh)
			else
				notify('Plugin Error','This plugin is already added')
			end
		else
			notify('Plugin Error','Cannot locate file "'..fileName..'". Is the file in the correct folder?')
		end
	end
end

function deletePlugin(name)
	local pName = name..'.iy'
	if name:sub(-3) == '.iy' then
		pName = name
	end
	for i = #cmds,1,-1 do
		if cmds[i].PLUGIN == pName then
			table.remove(cmds, i)
		end
	end
	for i,v in pairs(CMDsF:GetChildren()) do
		if v.Name == 'PLUGIN_'..pName then
			v:Destroy()
		end
	end
	for i,v in pairs(PluginsTable) do
		if v == pName then
			table.remove(PluginsTable, i)
			notify('Removed Plugin',pName..' was removed')
		end
	end
	IndexContents('',true)
	refreshplugins()
end

function refreshplugins(dontSave)
	if #PluginsTable > 0 then
		PluginsHint:Destroy()
	end
	if Holder_5 then
		Holder_5:ClearAllChildren()
		Holder_5.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i,v in pairs(PluginsTable) do
			local pName = v
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newplugin = Example_5:Clone()
			newplugin.Parent = Holder_5
			newplugin.Visible = true
			newplugin.Position = UDim2.new(0,0,0, Position + 5)
			newplugin.Text.Text = pName
			table.insert(shade2,newplugin)
			table.insert(shade2,newplugin.Text)
			table.insert(text1,newplugin.Text)
			table.insert(shade3,newplugin.Text.Delete)
			table.insert(text2,newplugin.Text.Delete)
			Holder_5.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newplugin.Text.Delete.MouseButton1Click:Connect(function()
				deletePlugin(pName)
			end)
		end
		if not dontSave then
			updatesaves()
		end
	end
end

local PluginCache
function LoadPlugin(val,startup)
	local plugin

	function CatchedPluginLoad()
		plugin = loadfile(val)()
	end

	function handlePluginError(plerror)
		notify('Plugin Error','An error occurred with the plugin, "'..val..'" and it could not be loaded')
		if FindInTable(PluginsTable,val) then
			for i,v in pairs(PluginsTable) do
				if v == val then
					table.remove(PluginsTable,i)
				end
			end
		end
		updatesaves()

		print("Original Error: "..tostring(plerror))
		print("Plugin Error, stack traceback: "..tostring(debug.traceback()))

		plugin = nil

		return false
	end

	xpcall(CatchedPluginLoad, handlePluginError)

	if plugin ~= nil then
		if not startup then
			notify('Loaded Plugin',"Name: "..plugin["PluginName"].."\n".."Description: "..plugin["PluginDescription"])
		end
		addcmdtext('',val)
		addcmdtext(string.upper('--'..plugin["PluginName"]),val,plugin["PluginDescription"])
		if plugin["Commands"] then
			for i,v in pairs(plugin["Commands"]) do 
				local cmdExt = ''
				local cmdName = i
				local function handleNames()
					cmdName = i
					if findCmd(cmdName..cmdExt) then
						if isNumber(cmdExt) then
							cmdExt = cmdExt+1
						else
							cmdExt = 1
						end
						handleNames()
					else
						cmdName = cmdName..cmdExt
					end
				end
				handleNames()
				addcmd(cmdName, v["Aliases"], v["Function"], val)
				if v["ListName"] then
					local newName = v.ListName
					local cmdNames = {i,unpack(v.Aliases)}
					for i,v in pairs(cmdNames) do
						newName = newName:gsub(v,v..cmdExt)
					end
					addcmdtext(newName,val,v["Description"])
				else
					addcmdtext(cmdName,val,v["Description"])
				end
			end
		end
		IndexContents('',true)
	elseif plugin == nil then
		plugin = nil
	end
end

function FindPlugins()
	if PluginsTable ~= nil and type(PluginsTable) == "table" then
		for i,v in pairs(PluginsTable) do
			LoadPlugin(v,true)
		end
		refreshplugins(true)
	end
end

AddPlugin.MouseButton1Click:Connect(function()
	addPlugin(PluginsGUI.FileName.Text)
end)

Exit_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	FileName.Text = 'Plugin File Name'
end)

Add_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, 310), "InOut", "Quart", 0.5, true, nil)
end)

Plugins.MouseButton1Click:Connect(function()
	if writefileExploit() then
		PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.5)
		SettingsHolder.Visible = false
	else
		notify('Incompatible Exploit','Your exploit is unable to use plugins (missing read/writefile)')
	end
end)

Close_4.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

local TeleportCheck = false
Players.LocalPlayer.OnTeleport:Connect(function(State)
	if KeepInfYield and (not TeleportCheck) and queueteleport then
		TeleportCheck = true
		-- Reload this customized build after a teleport instead of the upstream
		-- source, which restores the stock Infinite Yield interface.
		local customScriptPath = "Infinite Yield - UI polish.txt"
		local queuedLoader = string.format([[
			local ok, source = pcall(readfile, %q)
			if not ok or type(source) ~= "string" or source == "" then
				warn("[SpreadCheeksGUI] Could not reload the custom script. Save '%s' in the executor workspace.")
				return
			end
			local compiled, chunk = pcall(loadstring, source)
			if not compiled or type(chunk) ~= "function" then
				warn("[SpreadCheeksGUI] Could not compile the custom script: " .. tostring(chunk))
				return
			end
			chunk()
		]], customScriptPath, customScriptPath)
		queueteleport(queuedLoader)
	end
end)

addcmd('addalias',{},function(args, speaker)
	if #args < 2 then return end
	local cmd = string.lower(args[1])
	local alias = string.lower(args[2])
	for i,v in pairs(cmds) do
		if v.NAME:lower()==cmd or FindInTable(v.ALIAS,cmd) then
			customAlias[alias] = v
			aliases[#aliases + 1] = {CMD = cmd, ALIAS = alias}
			notify('Aliases Modified',"Added "..alias.." as an alias to "..cmd)
			updatesaves()
			refreshaliases()
			break
		end
	end
end)

addcmd('removealias',{},function(args, speaker)
	if #args < 1 then return end
	local alias = string.lower(args[1])
	if customAlias[alias] then
		local cmd = customAlias[alias].NAME
		customAlias[alias] = nil
		for i = #aliases,1,-1 do
			if aliases[i].ALIAS == tostring(alias) then
				table.remove(aliases, i)
			end
		end
		notify('Aliases Modified',"Removed the alias "..alias.." from "..cmd)
		updatesaves()
		refreshaliases()
	end
end)

addcmd('clraliases',{},function(args, speaker)
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard then
		toClipboard('https://discord.com/invite/78ZuWSq')
		notify('Discord Invite', 'Copied to clipboard!\ndiscord.gg/78ZuWSq')
	else
		notify('Discord Invite', 'discord.gg/78ZuWSq')
	end
	if httprequest then
		httprequest({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = HttpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = HttpService:GenerateGUID(false),
				args = {code = '78ZuWSq'}
			})
		})
	end
end)

addcmd('keepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = true
		notify('KeepIY','Infinite Yield will now run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('unkeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = false
		notify('KeepIY','Infinite Yield will no longer run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('togglekeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = not KeepInfYield
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

local canOpenServerinfo = true
addcmd('serverinfo',{'info','sinfo'},function(args, speaker)
	if not canOpenServerinfo then return end
	canOpenServerinfo = false
	task.spawn(function()
		local FRAME = Instance.new("Frame")
		local shadow = Instance.new("Frame")
		local PopupText = Instance.new("TextLabel")
		local Exit = Instance.new("TextButton")
		local ExitImage = Instance.new("ImageLabel")
		local background = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")
		local TextLabel2 = Instance.new("TextLabel")
		local TextLabel3 = Instance.new("TextLabel")
		local Time = Instance.new("TextLabel")
		local appearance = Instance.new("TextLabel")
		local maxplayers = Instance.new("TextLabel")
		local name = Instance.new("TextLabel")
		local placeid = Instance.new("TextLabel")
		local playerid = Instance.new("TextLabel")
		local players = Instance.new("TextLabel")
		local CopyApp = Instance.new("TextButton")
		local CopyPlrID = Instance.new("TextButton")
		local CopyPlcID = Instance.new("TextButton")
		local CopyPlcName = Instance.new("TextButton")

		FRAME.Name = randomString()
		FRAME.Parent = ScaledHolder
		FRAME.Active = true
		FRAME.BackgroundTransparency = 1
		FRAME.Position = UDim2.new(0.5, -130, 0, -500)
		FRAME.Size = UDim2.new(0, 250, 0, 20)
		FRAME.ZIndex = 10
		dragGUI(FRAME)

		shadow.Name = "shadow"
		shadow.Parent = FRAME
		shadow.BackgroundColor3 = currentShade2
		shadow.BorderSizePixel = 0
		shadow.Size = UDim2.new(0, 250, 0, 20)
		shadow.ZIndex = 10
		table.insert(shade2,shadow)

		PopupText.Name = "PopupText"
		PopupText.Parent = shadow
		PopupText.BackgroundTransparency = 1
		PopupText.Size = UDim2.new(1, 0, 0.95, 0)
		PopupText.ZIndex = 10
		PopupText.Font = Enum.Font.SourceSans
		PopupText.TextSize = 14
		PopupText.Text = "Server"
		PopupText.TextColor3 = currentText1
		PopupText.TextWrapped = true
		table.insert(text1,PopupText)

		Exit.Name = "Exit"
		Exit.Parent = shadow
		Exit.BackgroundTransparency = 1
		Exit.Position = UDim2.new(1, -20, 0, 0)
		Exit.Size = UDim2.new(0, 20, 0, 20)
		Exit.Text = ""
		Exit.ZIndex = 10

		ExitImage.Parent = Exit
		ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
		ExitImage.BackgroundTransparency = 1
		ExitImage.Position = UDim2.new(0, 5, 0, 5)
		ExitImage.Size = UDim2.new(0, 10, 0, 10)
		ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
		ExitImage.ZIndex = 10

		background.Name = "background"
		background.Parent = FRAME
		background.Active = true
		background.BackgroundColor3 = currentShade1
		background.BorderSizePixel = 0
		background.Position = UDim2.new(0, 0, 1, 0)
		background.Size = UDim2.new(0, 250, 0, 250)
		background.ZIndex = 10
		table.insert(shade1,background)

		TextLabel.Name = "Text Label"
		TextLabel.Parent = background
		TextLabel.BackgroundTransparency = 1
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0, 5, 0, 80)
		TextLabel.Size = UDim2.new(0, 100, 0, 20)
		TextLabel.ZIndex = 10
		TextLabel.Font = Enum.Font.SourceSansLight
		TextLabel.TextSize = 20
		TextLabel.Text = "Run Time:"
		TextLabel.TextColor3 = currentText1
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel)

		TextLabel2.Name = "Text Label2"
		TextLabel2.Parent = background
		TextLabel2.BackgroundTransparency = 1
		TextLabel2.BorderSizePixel = 0
		TextLabel2.Position = UDim2.new(0, 5, 0, 130)
		TextLabel2.Size = UDim2.new(0, 100, 0, 20)
		TextLabel2.ZIndex = 10
		TextLabel2.Font = Enum.Font.SourceSansLight
		TextLabel2.TextSize = 20
		TextLabel2.Text = "Statistics:"
		TextLabel2.TextColor3 = currentText1
		TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel2)

		TextLabel3.Name = "Text Label3"
		TextLabel3.Parent = background
		TextLabel3.BackgroundTransparency = 1
		TextLabel3.BorderSizePixel = 0
		TextLabel3.Position = UDim2.new(0, 5, 0, 10)
		TextLabel3.Size = UDim2.new(0, 100, 0, 20)
		TextLabel3.ZIndex = 10
		TextLabel3.Font = Enum.Font.SourceSansLight
		TextLabel3.TextSize = 20
		TextLabel3.Text = "Local Player:"
		TextLabel3.TextColor3 = currentText1
		TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel3)

		Time.Name = "Time"
		Time.Parent = background
		Time.BackgroundTransparency = 1
		Time.BorderSizePixel = 0
		Time.Position = UDim2.new(0, 5, 0, 105)
		Time.Size = UDim2.new(0, 100, 0, 20)
		Time.ZIndex = 10
		Time.Font = Enum.Font.SourceSans
		Time.FontSize = Enum.FontSize.Size14
		Time.Text = "LOADING"
		Time.TextColor3 = currentText1
		Time.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,Time)

		appearance.Name = "appearance"
		appearance.Parent = background
		appearance.BackgroundTransparency = 1
		appearance.BorderSizePixel = 0
		appearance.Position = UDim2.new(0, 5, 0, 55)
		appearance.Size = UDim2.new(0, 100, 0, 20)
		appearance.ZIndex = 10
		appearance.Font = Enum.Font.SourceSans
		appearance.FontSize = Enum.FontSize.Size14
		appearance.Text = "Appearance: LOADING"
		appearance.TextColor3 = currentText1
		appearance.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,appearance)

		maxplayers.Name = "maxplayers"
		maxplayers.Parent = background
		maxplayers.BackgroundTransparency = 1
		maxplayers.BorderSizePixel = 0
		maxplayers.Position = UDim2.new(0, 5, 0, 175)
		maxplayers.Size = UDim2.new(0, 100, 0, 20)
		maxplayers.ZIndex = 10
		maxplayers.Font = Enum.Font.SourceSans
		maxplayers.FontSize = Enum.FontSize.Size14
		maxplayers.Text = "LOADING"
		maxplayers.TextColor3 = currentText1
		maxplayers.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,maxplayers)

		name.Name = "name"
		name.Parent = background
		name.BackgroundTransparency = 1
		name.BorderSizePixel = 0
		name.Position = UDim2.new(0, 5, 0, 215)
		name.Size = UDim2.new(0, 240, 0, 30)
		name.ZIndex = 10
		name.Font = Enum.Font.SourceSans
		name.FontSize = Enum.FontSize.Size14
		name.Text = "Place Name: LOADING"
		name.TextColor3 = currentText1
		name.TextWrapped = true
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextYAlignment = Enum.TextYAlignment.Top
		table.insert(text1,name)

		placeid.Name = "placeid"
		placeid.Parent = background
		placeid.BackgroundTransparency = 1
		placeid.BorderSizePixel = 0
		placeid.Position = UDim2.new(0, 5, 0, 195)
		placeid.Size = UDim2.new(0, 100, 0, 20)
		placeid.ZIndex = 10
		placeid.Font = Enum.Font.SourceSans
		placeid.FontSize = Enum.FontSize.Size14
		placeid.Text = "Place ID: LOADING"
		placeid.TextColor3 = currentText1
		placeid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,placeid)

		playerid.Name = "playerid"
		playerid.Parent = background
		playerid.BackgroundTransparency = 1
		playerid.BorderSizePixel = 0
		playerid.Position = UDim2.new(0, 5, 0, 35)
		playerid.Size = UDim2.new(0, 100, 0, 20)
		playerid.ZIndex = 10
		playerid.Font = Enum.Font.SourceSans
		playerid.FontSize = Enum.FontSize.Size14
		playerid.Text = "Player ID: LOADING"
		playerid.TextColor3 = currentText1
		playerid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,playerid)

		players.Name = "players"
		players.Parent = background
		players.BackgroundTransparency = 1
		players.BorderSizePixel = 0
		players.Position = UDim2.new(0, 5, 0, 155)
		players.Size = UDim2.new(0, 100, 0, 20)
		players.ZIndex = 10
		players.Font = Enum.Font.SourceSans
		players.FontSize = Enum.FontSize.Size14
		players.Text = "LOADING"
		players.TextColor3 = currentText1
		players.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,players)

		CopyApp.Name = "CopyApp"
		CopyApp.Parent = background
		CopyApp.BackgroundColor3 = currentShade2
		CopyApp.BorderSizePixel = 0
		CopyApp.Position = UDim2.new(0, 210, 0, 55)
		CopyApp.Size = UDim2.new(0, 35, 0, 20)
		CopyApp.Font = Enum.Font.SourceSans
		CopyApp.TextSize = 14
		CopyApp.Text = "Copy"
		CopyApp.TextColor3 = currentText1
		CopyApp.ZIndex = 10
		table.insert(shade2,CopyApp)
		table.insert(text1,CopyApp)

		CopyPlrID.Name = "CopyPlrID"
		CopyPlrID.Parent = background
		CopyPlrID.BackgroundColor3 = currentShade2
		CopyPlrID.BorderSizePixel = 0
		CopyPlrID.Position = UDim2.new(0, 210, 0, 35)
		CopyPlrID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlrID.Font = Enum.Font.SourceSans
		CopyPlrID.TextSize = 14
		CopyPlrID.Text = "Copy"
		CopyPlrID.TextColor3 = currentText1
		CopyPlrID.ZIndex = 10
		table.insert(shade2,CopyPlrID)
		table.insert(text1,CopyPlrID)

		CopyPlcID.Name = "CopyPlcID"
		CopyPlcID.Parent = background
		CopyPlcID.BackgroundColor3 = currentShade2
		CopyPlcID.BorderSizePixel = 0
		CopyPlcID.Position = UDim2.new(0, 210, 0, 195)
		CopyPlcID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcID.Font = Enum.Font.SourceSans
		CopyPlcID.TextSize = 14
		CopyPlcID.Text = "Copy"
		CopyPlcID.TextColor3 = currentText1
		CopyPlcID.ZIndex = 10
		table.insert(shade2,CopyPlcID)
		table.insert(text1,CopyPlcID)

		CopyPlcName.Name = "CopyPlcName"
		CopyPlcName.Parent = background
		CopyPlcName.BackgroundColor3 = currentShade2
		CopyPlcName.BorderSizePixel = 0
		CopyPlcName.Position = UDim2.new(0, 210, 0, 215)
		CopyPlcName.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcName.Font = Enum.Font.SourceSans
		CopyPlcName.TextSize = 14
		CopyPlcName.Text = "Copy"
		CopyPlcName.TextColor3 = currentText1
		CopyPlcName.ZIndex = 10
		table.insert(shade2,CopyPlcName)
		table.insert(text1,CopyPlcName)

		local SINFOGUI = background
		FRAME:TweenPosition(UDim2.new(0.5, -130, 0, 100), "InOut", "Quart", 0.5, true, nil) 
		wait(0.5)
		Exit.MouseButton1Click:Connect(function()
			FRAME:TweenPosition(UDim2.new(0.5, -130, 0, -500), "InOut", "Quart", 0.5, true, nil) 
			wait(0.6)
			FRAME:Destroy()
			canOpenServerinfo = true
		end)
		local Asset = MarketplaceService:GetProductInfo(PlaceId)
		SINFOGUI.name.Text = "Place Name: " .. Asset.Name
		SINFOGUI.playerid.Text = "Player ID: " ..speaker.UserId
		SINFOGUI.maxplayers.Text = Players.MaxPlayers.. " Players Max"
		SINFOGUI.placeid.Text = "Place ID: " ..PlaceId

		CopyApp.MouseButton1Click:Connect(function()
			toClipboard(speaker.CharacterAppearanceId)
		end)
		CopyPlrID.MouseButton1Click:Connect(function()
			toClipboard(speaker.UserId)
		end)
		CopyPlcID.MouseButton1Click:Connect(function()
			toClipboard(PlaceId)
		end)
		CopyPlcName.MouseButton1Click:Connect(function()
			toClipboard(Asset.Name)
		end)

		repeat
			players = Players:GetPlayers()
			SINFOGUI.players.Text = #players.. " Player(s)"
			SINFOGUI.appearance.Text = "Appearance: " ..speaker.CharacterAppearanceId
			local seconds = math.floor(workspace.DistributedGameTime)
			local minutes = math.floor(workspace.DistributedGameTime / 60)
			local hours = math.floor(workspace.DistributedGameTime / 60 / 60)
			local seconds = seconds - (minutes * 60)
			local minutes = minutes - (hours * 60)
			if hours < 1 then if minutes < 1 then
					SINFOGUI.Time.Text = seconds .. " Second(s)" else
					SINFOGUI.Time.Text = minutes .. " Minute(s), " .. seconds .. " Second(s)"
				end
			else
				SINFOGUI.Time.Text = hours .. " Hour(s), " .. minutes .. " Minute(s), " .. seconds .. " Second(s)"
			end
			wait(1)
		until SINFOGUI.Parent == nil
	end)
end)

addcmd("jobid", {}, function(args, speaker)
	toClipboard("roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId)
end)

addcmd('notifyjobid',{},function(args, speaker)
	notify('JobId / PlaceId',JobId..' / '..PlaceId)
end)

addcmd('breakloops',{'break'},function(args, speaker)
	lastBreakTime = tick()
end)

addcmd('gametp',{'gameteleport'},function(args, speaker)
	TeleportService:Teleport(args[1])
end)

teleportRespawnHandler = [[
local ok, data = pcall(function() return game:GetService("TeleportService"):GetLocalPlayerTeleportData() end)
if ok and typeof(data) == "CFrame" then
    local Players = game:GetService("Players")
    local ME = Players.LocalPlayer
    while not ME do
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        ME = Players.LocalPlayer
    end

    local Character = ME.Character or ME.CharacterAdded:Wait()
    Character:WaitForChild("HumanoidRootPart")

    local t = tick()
    while (tick() - t) <= 0.3 do
        Character:PivotTo(data)
        task.wait()
    end
end
]]
addcmd("rejoin", {"rj"}, function(args, speaker)
    local data = nil
    if parseBoolean(args[1], false) == true then
        if queueteleport then
            if speaker.Character then
                data = speaker.Character:GetPivot()
                queueteleport(teleportRespawnHandler)
            end
        else
            notify("Incompatible Exploit", "Your exploit does not support this argument (missing queue_on_teleport)")
        end
    end

    if #Players:GetPlayers() <= 1 then
        Players.LocalPlayer:Kick("\nRejoining...")
        task.wait(0.3)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer, data)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer, nil, data)
    end
end)

addcmd("inviteprompt", {}, function(args, speaker)
	local plrs = getPlayer(args[1], speaker)
	if #plrs > 0 then
		ExperienceService:LaunchExperience({
			placeId = PlaceId,
			gameInstanceId = JobId,
			referredByPlayerId = plr[1].UserId
		})
	end
end)

addcmd("autorejoin", {"autorj"}, function(args, speaker)
	GuiService.ErrorMessageChanged:Connect(function()
		execCmd("rejoin")
	end)
	notify("Auto Rejoin", "Auto rejoin enabled")
end)

addcmd("serverhop", {"shop"}, function(args, speaker)
	-- thanks to Amity for fixing
	local servers = {}
	local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
	local body = HttpService:JSONDecode(req)

	if body and body.data then
		for i, v in next, body.data do
			if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
				table.insert(servers, 1, v.id)
			end
		end
	end

	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
	else
		return notify("Serverhop", "Couldn't find a server.")
	end
end)

addcmd("exit", {"shutdown", "leave"}, function(args, speaker)
	game:Shutdown()
end)

local NoclipParts = {}
local Noclipping = nil
addcmd("noclip", {}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = false
    task.wait(0.1)
    NoclipParts = {}
    Noclipping = RunService.Stepped:Connect(function()
        if Clip == false and speaker.Character ~= nil then
            for _, child in pairs(speaker.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                    child.CanCollide = false
                    NoclipParts[child] = true
                end
            end
        end
    end)
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Enabled")
end)

addcmd("unnoclip", {"clip"}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = true
    task.wait(0.1)
    for child, _ in pairs(NoclipParts) do
        if typeof(child) == "Instance" and child:IsA("BasePart") and child.Parent then
            child.CanCollide = true
        end
    end
    NoclipParts = {}
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Disabled")
end)

addcmd("togglenoclip", {}, function(args, speaker)
    execCmd(Clip and "noclip" or "unnoclip")
end)

FLYING = false
QEfly = true
iyflyspeed = 1
vehicleflyspeed = 1
function sFLY(vfly)
	local plr = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end

				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()

			if humanoid then humanoid.PlatformStand = false end
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() camera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local velocityHandlerName = randomString()
local gyroHandlerName = randomString()
local mfly1
local mfly2

local unmobilefly = function(speaker)
	pcall(function()
		FLYING = false
		local root = getRoot(speaker.Character)
		root:FindFirstChild(velocityHandlerName):Destroy()
		root:FindFirstChild(gyroHandlerName):Destroy()
		speaker.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		mfly1:Disconnect()
		mfly2:Disconnect()
	end)
end

local mobilefly = function(speaker, vfly)
	unmobilefly(speaker)
	FLYING = true

	local root = getRoot(speaker.Character)
	local camera = workspace.CurrentCamera
	local v3none = Vector3.new()
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf = Vector3.new(9e9, 9e9, 9e9)

	local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero

	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50

	mfly1 = speaker.CharacterAdded:Connect(function()
		local bv = Instance.new("BodyVelocity")
		bv.Name = velocityHandlerName
		bv.Parent = root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = gyroHandlerName
		bg.Parent = root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50
	end)

	mfly2 = RunService.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VelocityHandler = root:FindFirstChild(velocityHandlerName)
			local GyroHandler = root:FindFirstChild(gyroHandlerName)

			VelocityHandler.MaxForce = v3inf
			GyroHandler.MaxTorque = v3inf
			if not vfly then humanoid.PlatformStand = true end
			GyroHandler.CFrame = camera.CoordinateFrame
			VelocityHandler.Velocity = v3none

			local direction = controlModule:GetMoveVector()
			if direction.X > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.X < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
		end
	end)
end

addcmd('fly',{},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY()
	else
		mobilefly(speaker)
	end
	if args[1] and isNumber(args[1]) then
		iyflyspeed = args[1]
	end
end)

addcmd('flyspeed',{'flysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		iyflyspeed = speed
	end
end)

addcmd('unfly',{'nofly','novfly','unvehiclefly','novehiclefly','unvfly'},function(args, speaker)
	if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
end)

addcmd('vfly',{'vehiclefly'},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY(true)
	else
		mobilefly(speaker, true)
	end
	if args[1] and isNumber(args[1]) then
		vehicleflyspeed = args[1]
	end
end)

addcmd('togglevfly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY(true) else mobilefly(speaker, true) end
	end
end)

addcmd('vflyspeed',{'vflysp','vehicleflyspeed','vehicleflysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		vehicleflyspeed = speed
	end
end)

addcmd('qefly',{'flyqe'},function(args, speaker)
	if args[1] == 'false' then
		QEfly = false
	else
		QEfly = true
	end
end)

addcmd('togglefly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY() else mobilefly(speaker) end
	end
end)

CFspeed = 50
addcmd('cframefly', {'cfly'}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		CFspeed = args[1]
	end

	-- Full credit to peyton#9148 (apeyton)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
	local Head = speaker.Character:WaitForChild("Head")
	Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = RunService.Heartbeat:Connect(function(deltaTime)
		local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
		local headCFrame = Head.CFrame
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame
		local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
		cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
		local cameraPosition = cameraCFrame.Position
		local headPosition = headCFrame.Position

		local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
		Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
	end)
end)

addcmd('uncframefly',{'uncfly'},function(args, speaker)
	if CFloop then
		CFloop:Disconnect()
		speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		local Head = speaker.Character:WaitForChild("Head")
		Head.Anchored = false
	end
end)

addcmd('cframeflyspeed',{'cflyspeed'},function(args, speaker)
	if isNumber(args[1]) then
		CFspeed = args[1]
	end
end)

floating = false
local beganListener: RBXScriptConnection
local endListener: RBXScriptConnection
local floatingFunc: RBXScriptConnection

addcmd('float', {'platform'},function(args, speaker)
	local pchar = speaker.Character
	floatName = randomString()
	floating = true
	
	if pchar and not pchar:FindFirstChild(floatName) then
		task.spawn(function()
			local floatPoint = -3.1
			local floatPart = Instance.new('Part')
			floatPart.Name = floatName
			floatPart.Parent = pchar
			floatPart.Transparency = 1
			floatPart.Size = Vector3.new(2, 0.2, 1.5)
			floatPart.Anchored = true
			
			notify('Float', 'Started floating (Q = down & E = up)')
			
			beganListener = UserInputService.InputBegan:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint -= 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint += 1.5
				end
			end)
			endListener = UserInputService.InputEnded:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint += 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint -= 1.5
				end
			end)
			
			floatDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				floatingFunc:Disconnect()
				floatPart:Destroy()
				floatDied:Disconnect()
				beganListener:Disconnect()
				endListener:Disconnect()
				floatName = nil
			end)
			local function floatPadLoop()
				if pchar:FindFirstChild(floatName) and getRoot(pchar) then
					floatPart.CFrame = getRoot(pchar).CFrame * CFrame.new(0, floatPoint, 0)
				else
					floatingFunc:Disconnect()
					floatPart:Destroy()
					floatDied:Disconnect()
					beganListener:Disconnect()
					endListener:Disconnect()
					floatName = nil
				end
			end			
			floatingFunc = RunService.PreAnimation:Connect(floatPadLoop)
		end)
	end
end)

addcmd('unfloat',{'nofloat','unplatform','noplatform'},function(args, speaker)
	floating = false
	local pchar = speaker.Character
	notify('Float', 'Stopped floating')
	if pchar:FindFirstChild(floatName) then
		pchar:FindFirstChild(floatName):Destroy()
	end
	if floatDied then
		floatingFunc:Disconnect()
		floatDied:Disconnect()
		beganListener:Disconnect()
		endListener:Disconnect()
		floatName = nil
	end
end)

addcmd('togglefloat',{},function(args, speaker)
	if floating then
		execCmd('unfloat')
	else
		execCmd('float')
	end
end)

swimming = false
local oldgrav = workspace.Gravity
local swimbeat = nil
addcmd('swim',{},function(args, speaker)
	if not swimming and speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		oldgrav = workspace.Gravity
		workspace.Gravity = 0
		local swimDied = function()
			workspace.Gravity = oldgrav
			swimming = false
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		gravReset = Humanoid.Died:Connect(swimDied)
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, false)
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		swimbeat = RunService.Heartbeat:Connect(function()
			pcall(function()
				getRoot(speaker.Character).Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and getRoot(speaker.Character).Velocity or Vector3.new())
			end)
		end)
		swimming = true
	end
end)

addcmd('unswim',{'noswim'},function(args, speaker)
	if speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		workspace.Gravity = oldgrav
		swimming = false
		if gravReset then
			gravReset:Disconnect()
		end
		if swimbeat ~= nil then
			swimbeat:Disconnect()
			swimbeat = nil
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, true)
		end
	end
end)

addcmd('toggleswim',{},function(args, speaker)
	if swimming then
		execCmd('unswim')
	else
		execCmd('swim')
	end
end)

addcmd('setwaypoint',{'swp','setwp','spos','saveposition','savepos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		local torso = getRoot(speaker.Character)
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypointpos',{'wpp','setwaypointposition','setpos','setwaypoint','setwaypointpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypoints',{'positions'},function(args, speaker)
	if SettingsOpen == false then SettingsOpen = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	end
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
	maximizeHolder()
end)

waypointParts = {}
addcmd('showwaypoints',{'showwp','showwps'},function(args, speaker)
	execCmd('hidewaypoints')
	wait()
	for i,_ in pairs(WayPoints) do
		local x = WayPoints[i].COORD[1]
		local y = WayPoints[i].COORD[2]
		local z = WayPoints[i].COORD[3]
		local part = Instance.new("Part")
		part.Size = Vector3.new(5,5,5)
		part.CFrame = CFrame.new(x,y,z)
		part.Parent = workspace
		part.Anchored = true
		part.CanCollide = false
		table.insert(waypointParts,part)
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = part
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = part.Size
		view.Parent = part
	end
	for i,v in pairs(pWayPoints) do
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = pWayPoints[i].COORD[1]
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = pWayPoints[i].COORD[1].Size
		view.Parent = pWayPoints[i].COORD[1]
		table.insert(waypointParts,view)
	end
end)

addcmd('hidewaypoints',{'hidewp','hidewps'},function(args, speaker)
	for i,v in pairs(waypointParts) do
		v:Destroy()
	end
	waypointParts = {}
end)

addcmd('waypoint',{'wp','lpos','loadposition','loadpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				local x = WayPoints[i].COORD[1]
				local y = WayPoints[i].COORD[2]
				local z = WayPoints[i].COORD[3]
				getRoot(speaker.Character).CFrame = CFrame.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				getRoot(speaker.Character).CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

tweenSpeed = 1
addcmd('tweenspeed',{'tspeed'},function(args, speaker)
	local newSpeed = args[1] or 1
	if tonumber(newSpeed) then
		tweenSpeed = tonumber(newSpeed)
	end
end)

addcmd('tweenwaypoint',{'twp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(x,y,z)}):Play()
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)}):Play()
			end
		end
	end
end)

addcmd('walktowaypoint',{'wtwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

addcmd('deletewaypoint',{'dwp','dpos','deleteposition','deletepos'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.NAME:lower() == tostring(getstring(1, args)):lower() then
				if not v.GAME or v.GAME == PlaceId then
					table.remove(AllWaypoints, i)
				end
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
end)

addcmd('clearwaypoints',{'cwp','clearpositions','cpos','clearpos'},function(args, speaker)
	WayPoints = {}
	pWayPoints = {}
	refreshwaypoints()
	updatesaves()
	AllWaypoints = {}
	notify('Modified Waypoints','Removed all waypoints')
end)

addcmd('cleargamewaypoints',{'cgamewp'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.GAME == PlaceId then
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.GAME == PlaceId then
				table.remove(AllWaypoints, i)
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.GAME == PlaceId then
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
	notify('Modified Waypoints','Deleted game waypoints')
end)


local coreGuiTypeNames = {
	-- predefined aliases
	["inventory"] = Enum.CoreGuiType.Backpack,
	["leaderboard"] = Enum.CoreGuiType.PlayerList,
	["emotes"] = Enum.CoreGuiType.EmotesMenu
}

-- Load the full list of enums
for _, enumItem in ipairs(Enum.CoreGuiType:GetEnumItems()) do
	coreGuiTypeNames[enumItem.Name:lower()] = enumItem
end

addcmd('enable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", true)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, true)
			end
		end
	end
end)

addcmd('disable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", false)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, false)
			end
		end
	end
end)


local invisGUIS = {}
addcmd('showguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and not v.Visible then
			v.Visible = true
			if not FindInTable(invisGUIS,v) then
				table.insert(invisGUIS,v)
			end
		end
	end
end)

addcmd('unshowguis',{},function(args, speaker)
	for i,v in pairs(invisGUIS) do
		v.Visible = false
	end
	invisGUIS = {}
end)

local hiddenGUIS = {}
addcmd('hideguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and v.Visible then
			v.Visible = false
			if not FindInTable(hiddenGUIS,v) then
				table.insert(hiddenGUIS,v)
			end
		end
	end
end)

addcmd('unhideguis',{},function(args, speaker)
	for i,v in pairs(hiddenGUIS) do
		v.Visible = true
	end
	hiddenGUIS = {}
end)

function deleteGuisAtPos()
	pcall(function()
		local guisAtPosition = PlayerGui:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)
		for _, gui in pairs(guisAtPosition) do
			if gui.Visible == true then
				gui:Destroy()
			end
		end
	end)
end

local deleteGuiInput
addcmd('guidelete',{},function(args, speaker)
	deleteGuiInput = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.Backspace then
				deleteGuisAtPos()
			end
		end
	end)
	notify('GUI Delete Enabled','Hover over a GUI and press backspace to delete it')
end)

addcmd('unguidelete',{'noguidelete'},function(args, speaker)
	if deleteGuiInput then deleteGuiInput:Disconnect() end
	notify('GUI Delete Disabled','GUI backspace delete has been disabled')
end)

local wasStayOpen = StayOpen
addcmd('hideiy',{},function(args, speaker)
	isHidden = true
	wasStayOpen = StayOpen
	if StayOpen == true then
		StayOpen = false
		On.BackgroundTransparency = 1
	end
	minimizeNum = 0
	minimizeHolder()
	if not (args[1] and tostring(args[1]) == 'nonotify') then notify('IY Hidden','You can press the prefix key to access the command bar') end
end)

addcmd('showiy',{'unhideiy'},function(args, speaker)
	isHidden = false
	minimizeNum = -20
	if wasStayOpen then
		maximizeHolder()
		StayOpen = true
		On.BackgroundTransparency = 0
	else
		minimizeHolder()
	end
end)

addcmd('rec', {'record'}, function(args, speaker)
	return COREGUI:ToggleRecording()
end)

addcmd('screenshot', {'scrnshot'}, function(args, speaker)
	return COREGUI:TakeScreenshot()
end)

addcmd('togglefs', {'togglefullscreen'}, function(args, speaker)
	return GuiService:ToggleFullscreen()
end)

addcmd('inspect', {'examine'}, function(args, speaker)
	for _, v in ipairs(getPlayer(args[1], speaker)) do
		GuiService:CloseInspectMenu()
		GuiService:InspectPlayerFromUserId(Players[v].UserId)
	end
end)

addcmd("savegame", {"saveplace"}, function(args, speaker)
	if saveinstance then
		notify("Loading", "Downloading game. This will take a while")
		saveinstance()
		notify("Game Saved", "Saved place to the workspace folder within your exploit folder.")
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing saveinstance)")
	end
end)

addcmd("clearerror", {"clearerrors"}, function(args, speaker)
    GuiService:ClearError()
end)

addcmd("antigameplaypaused", {}, function(args, speaker)
    pcall(function() networkPaused:Disconnect() end)
    networkPaused = COREGUI.RobloxGui.ChildAdded:Connect(function(obj)
        if obj.Name == "CoreScripts/NetworkPause" then
            obj:Destroy()
        end
    end)
    COREGUI.RobloxGui["CoreScripts/NetworkPause"]:Destroy()
end)

addcmd("unantigameplaypaused", {}, function(args, speaker)
    networkPaused:Disconnect()
end)

addcmd('clientantikick',{'antikick'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end
	local LocalPlayer = Players.LocalPlayer
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    	local method = getnamecallmethod and getnamecallmethod() or ""
    	if select(1, ...) == LocalPlayer and method == "Kick" or method == "kick" then
        	return nil
    	end
    	return oldNamecall(...)
	end))
	hookfunction(LocalPlayer.Kick, newcclosure(function(self, _)
    	if self ~= lp then
        	error("Expected ':' not '.' calling member function Kick", 2)
    	end
    	return nil
	end))

	notify('Client Antikick','Client anti kick is now active (only effective on localscript kick)')
end)

allow_rj = true
addcmd('clientantiteleport',{'antiteleport'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end

	local oldTp; oldTp = hookfunction(TeleportService.Teleport, newcclosure(function(self, placeId, player, _teleportData, customLoadingScreen)
		if checkcaller() or (allow_rj and placeId == game.PlaceId) then
			return oldTp(self, placeId, player, _teleportData, customLoadingScreen)
		end
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function Teleport", 2)
		end
		if placeId == nil then
			error("Argument 1 missing or nil", 2)
		end
		if typeof(placeId) ~= "number" and placeId ~= true then
			error(`Unable to cast {typeof(placeId)} to int64`, 2)
		elseif placeId == true then
			-- somehow raise raiseTeleportInitFailedEvent
			return
		end
		if typeof(customLoadingScreen) ~= "Instance" and customLoadingScreen ~= nil then
			error("Unable to cast value to Object", 2)
		end
		return nil
	end))
	hookfunction(TeleportService.TeleportAsync, newcclosure(function(self, placeId, players, teleportOptions)
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function TeleportAsync", 2)
		end
		if players == nil then
			error("Argument 2 missing or nil", 2)
		end
		if typeof(players) ~= "table" then
			error("Unable to cast value to Objects", 2)
		end
		error("TeleportUnknown must be called from a Server", 2)
	end))
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
		local nmc = getnamecallmethod()
		if select(1, ...) == TeleportService and nmc == "teleport" or nmc == "Teleport" or nmc == "TeleportToPlaceInstance" or nmc == "TeleportAsync" then
			if checkcaller() or (allow_rj and select(2, ...) == game.PlaceId) then
				return oldNamecall(...)
			end
			return
		end
		return oldNamecall(...)
	end))

	notify('Client AntiTP','Client anti teleport is now active (only effective on localscript teleport)')
end)

addcmd('allowrejoin',{'allowrj'},function(args, speaker)
	allow_rj = not allow_rj
	notify("Client AntiTP", `Scripts now may{allow_rj and "" or " not"} make you rejoin the server`)
end)

addcmd("cancelteleport", {"canceltp"}, function(args, speaker)
	TeleportService:TeleportCancel()
end)

addcmd("volume",{ "vol"}, function(args, speaker)
	UserSettings():GetService("UserGameSettings").MasterVolume = args[1]/10
end)

addcmd("antilag", {"boostfps", "lowgraphics"}, function(args, speaker)
	local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	settings().Rendering.QualityLevel = 1
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
			v.Material = "Plastic"
			v.Reflectance = 0
			v.BackSurface = "SmoothNoOutlines"
			v.BottomSurface = "SmoothNoOutlines"
			v.FrontSurface = "SmoothNoOutlines"
			v.LeftSurface = "SmoothNoOutlines"
			v.RightSurface = "SmoothNoOutlines"
			v.TopSurface = "SmoothNoOutlines"
		elseif v:IsA("Decal") then
			v.Transparency = 1
			v.Texture = ""
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		end
	end
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
				RunService.Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA("BasePart") then
				child.CastShadow = false
			end
		end)
	end)
end)

addcmd("setfpscap", {"fpscap", "maxfps"}, function(args, speaker)
	if fpscaploop then
		task.cancel(fpscaploop)
		fpscaploop = nil
	end

	local fpsCap = 60
	local num = tonumber(args[1]) or 1e6
	if num == "none" then
		return
	elseif num > 0 then
		fpsCap = num
	else
		return notify("Invalid argument", "Please provide a number above 0 or 'none'.")
	end

	if setfpscap and type(setfpscap) == "function" then
		setfpscap(fpsCap)
	else
		fpscaploop = task.spawn(function()
			local timer = os.clock()
			while true do
				if os.clock() >= timer + 1 / fpsCap then
					timer = os.clock()
					task.wait()
				end
			end
		end)
	end
end)

addcmd('notify',{},function(args, speaker)
	notify(getstring(1, args))
end)

addcmd('lastcommand',{'lastcmd'},function(args, speaker)
	if cmdHistory[1]:sub(1,11) ~= 'lastcommand' and cmdHistory[1]:sub(1,7) ~= 'lastcmd' then
		execCmd(cmdHistory[1])
	end
end)

addcmd('esp',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('espteam',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v, true)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('noesp',{'unesp','unespteam'},function(args, speaker)
	ESPenabled = false
	for i,c in pairs(COREGUI:GetChildren()) do
		if string.sub(c.Name, -4) == '_ESP' then
			c:Destroy()
		end
	end
end)

addcmd("esptransparency", {}, function(args, speaker)
    espTransparency = tonumber(args[1]) or 0.3
    if ESPenabled then execCmd("esp") end
    if CHMSenabled then execCmd("chams") end
    updatesaves()
end)

local espParts = {}
local partEspTrigger = nil
function partAdded(part)
	if #espParts > 0 then
		if FindInTable(espParts,part.Name:lower()) then
			local a = Instance.new("BoxHandleAdornment")
			a.Name = part.Name:lower().."_PESP"
			a.Parent = part
			a.Adornee = part
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = part.Size
			a.Transparency = espTransparency
			a.Color = BrickColor.new("Lime green")
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
	end
end

addcmd('partesp',{},function(args, speaker)
	local partEspName = getstring(1, args):lower()
	if not FindInTable(espParts,partEspName) then
		table.insert(espParts,partEspName)
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower() == partEspName then
				local a = Instance.new("BoxHandleAdornment")
				a.Name = partEspName.."_PESP"
				a.Parent = v
				a.Adornee = v
				a.AlwaysOnTop = true
				a.ZIndex = 0
				a.Size = v.Size
				a.Transparency = espTransparency
				a.Color = BrickColor.new("Lime green")
			end
		end
	end
	if partEspTrigger == nil then
		partEspTrigger = workspace.DescendantAdded:Connect(partAdded)
	end
end)

addcmd('unpartesp',{'nopartesp'},function(args, speaker)
	if args[1] then
		local partEspName = getstring(1, args):lower()
		if FindInTable(espParts,partEspName) then
			table.remove(espParts, GetInTable(espParts, partEspName))
		end
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name == partEspName..'_PESP' then
				v:Destroy()
			end
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
		espParts = {}
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name:sub(-5) == '_PESP' then
				v:Destroy()
			end
		end
	end
end)

addcmd('chams',{},function(args, speaker)
	if not ESPenabled then
		CHMSenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				CHMS(v)
			end
		end
	else
		notify('Chams','Disable ESP (noesp) before using chams')
	end
end)

addcmd('nochams',{'unchams'},function(args, speaker)
	CHMSenabled = false
	for i,v in pairs(Players:GetPlayers()) do
		local chmsplr = v
		for i,c in pairs(COREGUI:GetChildren()) do
			if c.Name == chmsplr.Name..'_CHMS' then
				c:Destroy()
			end
		end
	end
end)

addcmd('locate',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		Locate(Players[v])
	end
end)

addcmd('nolocate',{'unlocate'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if args[1] then
		for i,v in pairs(players) do
			for i,c in pairs(COREGUI:GetChildren()) do
				if c.Name == Players[v].Name..'_LC' then
					c:Destroy()
				end
			end
		end
	else
		for i,c in pairs(COREGUI:GetChildren()) do
			if string.sub(c.Name, -3) == '_LC' then
				c:Destroy()
			end
		end
	end
end)

viewing = nil
addcmd('view',{'spectate'},function(args, speaker)
	StopFreecam()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		viewing = Players[v]
		workspace.CurrentCamera.CameraSubject = viewing.Character
		notify('Spectate','Viewing ' .. Players[v].Name)
		local function viewDiedFunc()
			repeat wait() until Players[v].Character ~= nil and getRoot(Players[v].Character)
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewDied = Players[v].CharacterAdded:Connect(viewDiedFunc)
		local function viewChangedFunc()
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
	end
end)

addcmd('viewpart',{'viewp'},function(args, speaker)
	StopFreecam()
	if args[1] then
		for i,v in pairs(workspace:GetDescendants()) do
			if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
				wait(0.1)
				workspace.CurrentCamera.CameraSubject = v
			end
		end
	end
end)

addcmd('unview',{'unspectate'},function(args, speaker)
	StopFreecam()
	if viewing ~= nil then
		viewing = nil
		notify('Spectate','View turned off')
	end
	if viewDied then
		viewDied:Disconnect()
		viewChanged:Disconnect()
	end
	workspace.CurrentCamera.CameraSubject = speaker.Character
end)


fcRunning = false
local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value

Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()

local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

Input = {} do

	keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
	}

	mouse = {
		Delta = Vector2.new(),
	}

	NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	PAN_MOUSE_SPEED = Vector2.new(1, 1)*(math.pi/64)
	NAV_ADJ_SPEED = 0.75
	NAV_SHIFT_MUL = 0.25

	navSpeed = 1

	function Input.Vel(dt)
		navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

		return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end

	do
		function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority("FreecamKeyboard",Keypress,false,INPUT_PRIORITY,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.E,
				Enum.KeyCode.Q,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority("FreecamMousePan",MousePan,false,INPUT_PRIORITY,Enum.UserInputType.MouseMovement)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			ContextActionService:UnbindAction("FreecamMousePan")
		end
	end
end

function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*math.tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))

	local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

	cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
	cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

local PlayerState = {} do
	mouseBehavior = ""
	mouseIconEnabled = ""
	cameraType = ""
	cameraFocus = ""
	cameraCFrame = ""
	cameraFieldOfView = ""

	function PlayerState.Push()
		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = true

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	function PlayerState.Pop()
		Camera.FieldOfView = 70

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

function StartFreecam(pos)
	if fcRunning then
		StopFreecam()
	end
	local cameraCFrame = Camera.CFrame
	if pos then
		cameraCFrame = pos
	end
	cameraRot = Vector2.new()
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())

	PlayerState.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
	fcRunning = true
end

function StopFreecam()
	if not fcRunning then return end
	Input.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
	workspace.Camera.FieldOfView = 70
	fcRunning = false
end

addcmd('freecam',{'fc'},function(args, speaker)
	StartFreecam()
end)

addcmd('freecampos',{'fcpos','fcp','freecamposition','fcposition'},function(args, speaker)
	if not args[1] then return end
	local freecamPos = CFrame.new(args[1],args[2],args[3])
	StartFreecam(freecamPos)
end)

addcmd('freecamwaypoint',{'fcwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(x,y,z))
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(pWayPoints[i].COORD[1].Position))
			end
		end
	end
end)

addcmd('freecamgoto',{'fcgoto','freecamtp','fctp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		StartFreecam(getRoot(Players[v].Character).CFrame)
	end
end)

addcmd('unfreecam',{'nofreecam','unfc','nofc'},function(args, speaker)
	StopFreecam()
end)

addcmd('freecamspeed',{'fcspeed'},function(args, speaker)
	local FCspeed = args[1] or 1
	if isNumber(FCspeed) then
		NAV_KEYBOARD_SPEED = Vector3.new(FCspeed, FCspeed, FCspeed)
	end
end)

addcmd('notifyfreecamposition',{'notifyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		notify("Current Position", Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('copyfreecamposition',{'copyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		toClipboard(Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('gotocamera',{'gotocam','tocam'},function(args, speaker)
	getRoot(speaker.Character).CFrame = workspace.Camera.CFrame
end)

addcmd('tweengotocamera',{'tweengotocam','tgotocam','ttocam'},function(args, speaker)
	TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = workspace.Camera.CFrame}):Play()
end)

addcmd('fov',{},function(args, speaker)
	local fov = args[1] or 70
	if isNumber(fov) then
		workspace.CurrentCamera.FieldOfView = fov
	end
end)

local preMaxZoom = Players.LocalPlayer.CameraMaxZoomDistance
local preMinZoom = Players.LocalPlayer.CameraMinZoomDistance
addcmd('lookat',{},function(args, speaker)
	if speaker.CameraMaxZoomDistance ~= 0.5 then
		preMaxZoom = speaker.CameraMaxZoomDistance
		preMinZoom = speaker.CameraMinZoomDistance
	end
	speaker.CameraMaxZoomDistance = 0.5
	speaker.CameraMinZoomDistance = 0.5
	wait()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local target = Players[v].Character
		if target and target:FindFirstChild('Head') then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, target.Head.CFrame.p)
			wait(0.1)
		end
	end
	speaker.CameraMaxZoomDistance = preMaxZoom
	speaker.CameraMinZoomDistance = preMinZoom
end)

addcmd('fixcam',{'restorecam'},function(args, speaker)
	StopFreecam()
	execCmd('unview')
	workspace.CurrentCamera:remove()
	wait(.1)
	repeat wait() until speaker.Character ~= nil
	workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildWhichIsA('Humanoid')
	workspace.CurrentCamera.CameraType = "Custom"
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	speaker.Character.Head.Anchored = false
end)

addcmd("enableshiftlock", {"enablesl", "shiftlock"}, function(args, speaker)
	local function enableShiftlock() 
		speaker.DevEnableMouseLock = true 
	end
	speaker:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(enableShiftlock)
	enableShiftlock()
	notify("Shiftlock", "Shift lock should now be available")
end)

addcmd('firstp',{},function(args, speaker)
	speaker.CameraMode = "LockFirstPerson"
end)

addcmd('thirdp',{},function(args, speaker)
	speaker.CameraMode = "Classic"
end)

addcmd('noclipcam', {'nccam'}, function(args, speaker)
	local sc = (debug and debug.setconstant) or setconstant
	local gc = (debug and debug.getconstants) or getconstants
	if not sc or not getgc or not gc then
		return notify('Incompatible Exploit', 'Your exploit does not support this command (missing setconstant or getconstants or getgc)')
	end
	local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
	for _, v in pairs(getgc()) do
		if type(v) == 'function' and getfenv(v).script == pop then
			for i, v1 in pairs(gc(v)) do
				if tonumber(v1) == .25 then
					sc(v, i, 0)
				elseif tonumber(v1) == 0 then
					sc(v, i, .25)
				end
			end
		end
	end
end)

addcmd('maxzoom',{},function(args, speaker)
	speaker.CameraMaxZoomDistance = args[1]
end)

addcmd('minzoom',{},function(args, speaker)
	speaker.CameraMinZoomDistance = args[1]
end)

addcmd('camdistance',{},function(args, speaker)
	local camMax = speaker.CameraMaxZoomDistance
	local camMin = speaker.CameraMinZoomDistance
	if camMax < tonumber(args[1]) then
		camMax = args[1]
	end
	speaker.CameraMaxZoomDistance = args[1]
	speaker.CameraMinZoomDistance = args[1]
	wait()
	speaker.CameraMaxZoomDistance = camMax
	speaker.CameraMinZoomDistance = camMin
end)

addcmd('unlockws',{'unlockworkspace'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = false
		end
	end
end)

addcmd('lockws',{'lockworkspace'},function(args, speaker) 
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true
		end
	end
end)

addcmd('delete',{'remove'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('deleteclass',{'removeclass','deleteclassname','removeclassname','dc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('chardelete',{'charremove','cd'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('chardeleteclass',{'charremoveclass','chardeleteclassname','charremoveclassname','cdc'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('deletevelocity',{'dv','removevelocity','removeforces'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("RocketPropulsion") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") or v:IsA("AngularVelocity") or v:IsA("BodyForce") or v:IsA("VectorForce") or v:IsA("LineForce") then
			v:Destroy()
		end
	end
end)

addcmd('deleteinvisparts',{'deleteinvisibleparts','dip'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 and v.CanCollide then
			v:Destroy()
		end
	end
end)

local shownParts = {}
addcmd('invisibleparts',{'invisparts'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 then
			if not table.find(shownParts,v) then
				table.insert(shownParts,v)
			end
			v.Transparency = 0
		end
	end
end)

addcmd('uninvisibleparts',{'uninvisparts'},function(args, speaker)
	for i,v in pairs(shownParts) do
		v.Transparency = 1
	end
	shownParts = {}
end)

addcmd("btools", {}, function(args, speaker)
	for i = 1, 4 do
		local Tool = Instance.new("HopperBin")
		Tool.BinType = i
		Tool.Name = randomString()
		Tool.Parent = speaker:FindFirstChildWhichIsA("Backpack")
	end
end)

addcmd("f3x", {"fex"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
end)

addcmd("partpath", {"partname"}, function(args, speaker)
	selectPart()
end)

local antiAfkCon = nil
addcmd("antiafk", {"antiidle"}, function(args, speaker)
    if getconnections then
        for _, c in getconnections(speaker.Idled) do
            pcall(function() c:Disable() end) -- supposed to "pause" it
            pcall(function() c:Disconnect() end) -- supposed to disconnect it
        end
    end

    pcall(function() antiAfkCon:Disconnect() end)
    antiAfkCon = speaker.Idled:Connect(function()
        local VirtualInputManager = Instance.new("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        VirtualInputManager:Destroy()
    end)

    if not (args[1] and tostring(args[1]) == "nonotify") then notify("Anti Idle", "Anti idle is enabled") end
end)

addcmd("datalimit", {}, function(args, speaker)
	local kbps = tonumber(args[1])
	if kbps then
		Services.NetworkClient:SetOutgoingKBPSLimit(kbps)
	end
end)

addcmd("replicationlag", {"backtrack"}, function(args, speaker)
	if tonumber(args[1]) then
		settings():GetService("NetworkSettings").IncomingReplicationLag = args[1]
	end
end)

addcmd("noprompts", {"nopurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = false
end)

addcmd("showprompts", {"showpurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = true
end)

promptNewRig = function(speaker, rig)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		AvatarEditorService:PromptSaveAvatar(humanoid.HumanoidDescription, Enum.HumanoidRigType[rig])
		local result = AvatarEditorService.PromptSaveAvatarCompleted:Wait()
		if result == Enum.AvatarPromptResult.Success then
			execCmd("reset")
		end
	end
end

addcmd("promptr6", {}, function(args, speaker)
	promptNewRig(speaker, "R6")
end)

addcmd("promptr15", {}, function(args, speaker)
	promptNewRig(speaker, "R15")
end)

addcmd("wallwalk", {"walkonwalls"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
end)

addcmd('age',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	notify('Account Age',table.concat(ages, ',\n'))
end)

addcmd('chatage',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	local chatString = table.concat(ages, ', ')
	chatMessage(chatString)
end)

addcmd('joindate',{'jd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	notify('Join Date (Month/Day/Year)',table.concat(dates, ',\n'))
end)

addcmd('chatjoindate',{'cjd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	local chatString = table.concat(dates, ', ')
	chatMessage(chatString)
end)

addcmd('copyname',{'copyuser'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local name = tostring(Players[v].Name)
		toClipboard(name)
	end
end)

addcmd('userid',{'id'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		notify('User ID',id)
	end
end)

addcmd("copyplaceid", {"placeid"}, function(args, speaker)
	toClipboard(PlaceId)
end)

addcmd("copygameid", {"gameid"}, function(args, speaker)
	toClipboard(game.GameId)
end)

addcmd('copyid',{'copyuserid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		toClipboard(id)
	end
end)

addcmd('creatorid',{'creator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		notify('Creator ID',game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Creator ID',OwnerID)
	end
end)

addcmd('copycreatorid',{'copycreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		toClipboard(game.CreatorId)
		notify('Copied ID','Copied creator ID to clipboard')
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		toClipboard(OwnerID)
		notify('Copied ID','Copied creator ID to clipboard')
	end
end)

addcmd('setcreatorid',{'setcreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		speaker.UserId = game.CreatorId
		notify('Set ID','Set UserId to '..game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Set ID','Set UserId to '..OwnerID)
	end
end)

addcmd('appearanceid',{'aid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		notify('Appearance ID',aid)
	end
end)

addcmd('copyappearanceid',{'caid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		toClipboard(aid)
	end
end)

addcmd('norender',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(false)
end)

addcmd('render',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(true)
end)

addcmd('2022materials',{'use2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", true)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd('un2022materials',{'unuse2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", false)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd("goto", {"to"}, function(args, speaker)
	local character = speaker and speaker.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	if humanoid == nil then return end

	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
		task.wait(0.1)
	end

	local waitForStream = parseBoolean(args[2], false)
	for _, name in getPlayer(args[1], speaker) do
		local targetCharacter = Players[name].Character
		if targetCharacter ~= nil then
			local targetPivot = targetCharacter:GetPivot()
			local targetPosition = targetPivot.Position

			if waitForStream and workspace.StreamingEnabled then
				task.spawn(speaker.RequestStreamAroundAsync, speaker, targetPosition, 5)
				targetCharacter:WaitForChild("HumanoidRootPart", 5)
			end

			speaker.Character:PivotTo(CFrame.new(targetPosition + (targetPivot.LookVector * 3), targetPosition))
			breakVelocity()
			break
		end
	end
end)

addcmd("tweengoto", {"tgoto", "tto", "tweento"}, function(args, speaker)
    local character = speaker and speaker.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

    local oldState = humanoid and humanoid:GetStateEnabled(Enum.HumanoidStateType.Seated)
    if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end

    local players = getPlayer(args[1], speaker)
    for _, v in pairs(players) do
        if Players[v].Character ~= nil then
            if humanoid and humanoid.SeatPart then
                humanoid.Sit = false
                task.wait(0.1)
            end
            TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {
                CFrame = getRoot(Players[v].Character):GetPivot() + Vector3.new(3, 1, 0)
            }):Play()
        end
    end
    execCmd("breakvelocity")

    if type(oldState) == "boolean" then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, oldState)
    end
end)

addcmd("vehiclegoto", {"vgoto", "vtp", "vehicletp"}, function(args, speaker)
    local character = speaker.Character
    local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
    if not humanoid then return end

    local seat = humanoid.SeatPart
    local vehicleModel = if seat then seat:FindFirstAncestorWhichIsA("Model") else nil
    if vehicleModel == nil then
        notify("Vehicle Goto", "Make sure you're sitting in a vehicle.")
        return
    end

    for _, v in getPlayer(args[1], speaker) do
        if Players[v].Character == nil then continue end

        local root = getRoot(Players[v].Character)
        if root == nil then continue end

        vehicleModel:PivotTo(root:GetPivot())
        break
    end
end)

addcmd('pulsetp',{'ptp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			local startPos = getRoot(speaker.Character).CFrame
			local seconds = args[2] or 1
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
			wait(seconds)
			getRoot(speaker.Character).CFrame = startPos
		end
	end
	execCmd('breakvelocity')
end)

local vnoclipParts = {}
addcmd('vehiclenoclip',{'vnoclip'},function(args, speaker)
	vnoclipParts = {}
	local seat = speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart
	local vehicleModel = seat.Parent
	repeat
		if vehicleModel.ClassName ~= "Model" then
			vehicleModel = vehicleModel.Parent
		end
	until vehicleModel.ClassName == "Model"
	wait(0.1)
	execCmd('noclip')
	for i,v in pairs(vehicleModel:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide then
			table.insert(vnoclipParts,v)
			v.CanCollide = false
		end
	end
end)

addcmd("vehicleclip", {"vclip", "unvnoclip", "unvehiclenoclip"}, function(args, speaker)
	execCmd("clip")
	for i, v in pairs(vnoclipParts) do
		v.CanCollide = true
	end
	vnoclipParts = {}
end)

addcmd("togglevnoclip", {}, function(args, speaker)
	execCmd(Clip and "vnoclip" or "vclip")
end)

addcmd('clientbring',{'cbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if Players[v].Character:FindFirstChildOfClass('Humanoid') then
				Players[v].Character:FindFirstChildOfClass('Humanoid').Sit = false
			end
			wait()
			getRoot(Players[v].Character).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(3,1,0)
		end
	end
end)

local bringT = {}
addcmd('loopbring',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			if Players[v].Name ~= speaker.Name and not FindInTable(bringT, Players[v].Name) then
				table.insert(bringT, Players[v].Name)
				local plrName = Players[v].Name
				local pchar=Players[v].Character
				local distance = 3
				if args[2] and isNumber(args[2]) then
					distance = args[2]
				end
				local lDelay = 0
				if args[3] and isNumber(args[3]) then
					lDelay = args[3]
				end
				repeat
					for i,c in pairs(players) do
						if Players:FindFirstChild(v) then
							pchar = Players[v].Character
							if pchar~= nil and Players[v].Character ~= nil and getRoot(pchar) and speaker.Character ~= nil and getRoot(speaker.Character) then
								getRoot(pchar).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(distance,1,0)
							end
							wait(lDelay)
						else 
							for a,b in pairs(bringT) do if b == plrName then table.remove(bringT, a) end end
						end
					end
				until not FindInTable(bringT, plrName)
			end
		end)
	end
end)

addcmd('unloopbring',{'noloopbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(bringT) do if b == Players[v].Name then table.remove(bringT, a) end end
		end)
	end
end)

local walkto = false
local waypointwalkto = false
addcmd('walkto',{'follow'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalkto',{'pathfindfollow'},function(args, speaker)
	walkto = false
	wait()
	local players = getPlayer(args[1], speaker)
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				local success, response = pcall(function()
					path:ComputeAsync(getRoot(speaker.Character).Position, getRoot(Players[v].Character).Position)
					local waypoints = path:GetWaypoints()
					local distance 
					for waypointIndex, waypoint in pairs(waypoints) do
						local waypointPosition = waypoint.Position
						hum:MoveTo(waypointPosition)
						repeat 
							distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
							wait()
						until
						distance <= 5
					end	 
				end)
				if not success then
					speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
				end
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalktowaypoint',{'pathfindwalktowp'},function(args, speaker)
	waypointwalkto = false
	wait()
	local WPName = tostring(getstring(1, args))
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = Vector3.new(WayPoints[i].COORD[1], WayPoints[i].COORD[2], WayPoints[i].COORD[3])
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = pWayPoints[i].COORD[1].Position
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
	end
end)

addcmd('unwalkto',{'nowalkto','unfollow','nofollow'},function(args, speaker)
	walkto = false
	waypointwalkto = false
end)

addcmd("orbit", {}, function(args, speaker)
	execCmd("unorbit nonotify")

	local target = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
	local root = getRoot(speaker.Character)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")

	if target and target.Character and getRoot(target.Character) and root and humanoid then
		local rotation = 0
		local speed = tonumber(args[2]) or 0.2
		local distance = tonumber(args[3]) or 6

		orbit1 = RunService.Stepped:Connect(function()
			breakVelocity()
			rotation = rotation + speed

			local targetRoot = getRoot(target.Character).Position
			local orbitPosition = (CFrame.new(targetRoot) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(distance, 0, 0)).Position
			root.CFrame = CFrame.lookAt(orbitPosition, Vector3.new(targetRoot.X, orbitPosition.Y, targetRoot.Z))
		end)

		orbit2 = humanoid.Died:Connect(function() execCmd("unorbit") end)

		orbit3 = humanoid.Seated:Connect(function(value)
			if value then execCmd("unorbit") end
		end)

		notify("Orbit", "Started orbiting " .. formatUsername(target))
	end
end)

addcmd("unorbit", {}, function(args, speaker)
	if orbit1 then orbit1:Disconnect() end
	if orbit2 then orbit2:Disconnect() end
	if orbit3 then orbit3:Disconnect() end
	if args[1] ~= "nonotify" then notify("Orbit", "Stopped orbiting player") end
end)


addcmd('freeze',{'fr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("BasePart") and not x.Anchored then
						x.Anchored = true
					end
				end
			end)
		end
	end
end)


addcmd('thaw',{'unfreeze','unfr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x.Name ~= floatName and x:IsA("BasePart") and x.Anchored then
						x.Anchored = false
					end
				end
			end)
		end
	end
end)

addcmd("anchor", {}, function(args, speaker)
    getRoot(speaker.Character).Anchored = true
end)

addcmd("unanchor", {}, function(args, speaker)
    getRoot(speaker.Character).Anchored = false
end)

oofing = false
addcmd('loopoof',{},function(args, speaker)
	oofing = true
	repeat wait(0.1)
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character ~= nil and v.Character:FindFirstChild'Head' then
				for _,x in pairs(v.Character.Head:GetChildren()) do
					if x:IsA'Sound' then x.Playing = true end
				end
			end
		end
	until oofing == false
end)

addcmd('unloopoof',{},function(args, speaker)
	oofing = false
end)

local notifiedRespectFiltering = false
addcmd('muteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
				for i, x in next, Players[v]:FindFirstChildOfClass("Backpack"):GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
			end)
		end
	end
end)

addcmd('unmuteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == false then
						x.Playing = true
					end
				end
			end)
		end
	end
end)

addcmd("reset", {}, function(args, speaker)
	local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	else
		speaker.Character:BreakJoints()
	end
end)

addcmd('freezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(0)
	end
end)

addcmd('unfreezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(1)
	end
end)

addcmd("respawn", {}, function(args, speaker)
	respawn(speaker)
end)

addcmd("refresh", {"re"}, function(args, speaker)
	refresh(speaker)
end)

addcmd("god", {}, function(args, speaker)
	local Cam = workspace.CurrentCamera
	local Char, Pos = speaker.Character, Cam.CFrame
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local nHuman = Human:Clone()
	nHuman.Parent = char
	speaker.Character = nil
	nHuman:SetStateEnabled(15, false)
	nHuman:SetStateEnabled(1, false)
	nHuman:SetStateEnabled(0, false)
	nHuman.BreakJointsOnDeath = true
	Human:Destroy()
	speaker.Character = char
	Cam.CameraSubject = nHuman
	Cam.CFrame = task.wait() and pos
	nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local Script = Char:FindFirstChild("Animate")
	if Script then
		Script.Disabled = true
		task.wait()
		Script.Disabled = false
	end
	nHuman.Health = nHuman.MaxHealth
end)

invisRunning = false
addcmd('invisible',{'invis'},function(args, speaker)
	if invisRunning then return end
	invisRunning = true
	-- Full credit to AmokahFox @V3rmillion
	local Player = speaker
	repeat wait(.1) until Player.Character
	local Character = Player.Character
	Character.Archivable = true
	local IsInvis = false
	local IsRunning = true
	local InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = Lighting
	local Void = workspace.FallenPartsDestroyHeight
	InvisibleCharacter.Name = ""
	local CF

	local invisFix = RunService.Stepped:Connect(function()
		pcall(function()
			local IsInteger
			if tostring(Void):find'-' then
				IsInteger = true
			else
				IsInteger = false
			end
			local Pos = Player.Character.Humanoid.RootPart.Position
			local Pos_String = tostring(Pos)
			local Pos_Seperate = Pos_String:split(', ')
			local X = tonumber(Pos_Seperate[1])
			local Y = tonumber(Pos_Seperate[2])
			local Z = tonumber(Pos_Seperate[3])
			if IsInteger == true then
				if Y <= Void then
					Respawn()
				end
			elseif IsInteger == false then
				if Y >= Void then
					Respawn()
				end
			end
		end)
	end)

	for i,v in pairs(InvisibleCharacter:GetDescendants())do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = .5
			end
		end
	end

	function Respawn()
		IsRunning = false
		if IsInvis == true then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				IsInvis = false
				InvisibleCharacter.Parent = nil
				invisRunning = false
			end)
		elseif IsInvis == false then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				TurnVisible()
			end)
		end
	end

	local invisDied
	invisDied = InvisibleCharacter:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
		Respawn()
		invisDied:Disconnect()
	end)

	if IsInvis == true then return end
	IsInvis = true
	CF = workspace.CurrentCamera.CFrame
	local CF_1 = Player.Character.Humanoid.RootPart.CFrame
	Character:MoveTo(Vector3.new(0,math.pi*1000000,0))
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	wait(.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	InvisibleCharacter = InvisibleCharacter
	Character.Parent = Lighting
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.Humanoid.RootPart.CFrame = CF_1
	Player.Character = InvisibleCharacter
	execCmd('fixcam')
	Player.Character.Animate.Disabled = true
	Player.Character.Animate.Disabled = false

	function TurnVisible()
		if IsInvis == false then return end
		invisFix:Disconnect()
		invisDied:Disconnect()
		CF = workspace.CurrentCamera.CFrame
		Character = Character
		local CF_1 = Player.Character.Humanoid.RootPart.CFrame
		Character.Humanoid.RootPart.CFrame = CF_1
		InvisibleCharacter:Destroy()
		Player.Character = Character
		Character.Parent = workspace
		IsInvis = false
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
		invisDied = Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
			Respawn()
			invisDied:Disconnect()
		end)
		invisRunning = false
	end
	notify('Invisible','You now appear invisible to other players')
end)

addcmd("visible", {"vis","uninvisible"}, function(args, speaker)
	TurnVisible()
end)

addcmd("toggleinvis", {}, function(args, speaker)
	execCmd(invisRunning and "visible" or "invisible")
end)

addcmd('toolinvisible',{'toolinvis','tinvis'},function(args, speaker)
	local Char  = Players.LocalPlayer.Character
	local touched = false
	local tpdback = false
	local box = Instance.new('Part')
	box.Anchored = true
	box.CanCollide = true
	box.Size = Vector3.new(10,1,10)
	box.Position = Vector3.new(0,10000,0)
	box.Parent = workspace
	local boxTouched = box.Touched:connect(function(part)
		if (part.Parent.Name == Players.LocalPlayer.Name) then
			if touched == false then
				touched = true
				local function apply()
					local no = Char.Humanoid.RootPart:Clone()
					task.wait(.25)
					Char.Humanoid.RootPart:Destroy()
					no.Parent = Char
					Char:MoveTo(loc)
					touched = false
				end
				if Char then
					apply()
				end
			end
		end
	end)
	repeat wait() until Char
	local cleanUp
	cleanUp = Players.LocalPlayer.CharacterAdded:connect(function(char)
		boxTouched:Disconnect()
		box:Destroy()
		cleanUp:Disconnect()
	end)
	loc = Char.Humanoid.RootPart.Position
	Char:MoveTo(box.Position + Vector3.new(0,.5,0))
end)

addcmd("strengthen", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
			end
		end
	end
end)

addcmd("weaken", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(-args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(0, 0.3, 0.5)
			end
		end
	end
end)

addcmd("unweaken", {"unstrengthen"}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end
end)

addcmd("breakvelocity", {}, function(args, speaker)
	local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
	delay(1, function()
		BeenASecond = true
	end)
	while not BeenASecond do
		for _, v in ipairs(speaker.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity, v.RotVelocity = V3, V3
			end
		end
		wait()
	end
end)

addcmd('jpower',{'jumppower','jp'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
		end
	end
end)

addcmd("maxslopeangle", {"msa"}, function(args, speaker)
	local sangle = args[1] or 89
	if isNumber(sangle) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").MaxSlopeAngle = sangle
	end
end)

addcmd("gravity", {"grav"}, function(args, speaker)
	local grav = args[1] or oldgrav
	if isNumber(grav) then
		workspace.Gravity = grav
	end
end)

addcmd("hipheight", {"hheight"}, function(args, speaker)
	local hipHeight = args[1] or (r15(speaker) and 2.1 or 0)
	if isNumber(hipHeight) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = hipHeight
	end
end)

addcmd("dance", {}, function(args, speaker)
	pcall(execCmd, "undance")
	local dances = {"27789359", "30196114", "248263260", "45834924", "33796059", "28488254", "52155728"}
	if r15(speaker) then
		dances = {"3333432454", "4555808220", "4049037604", "4555782893", "10214311282", "10714010337", "10713981723", "10714372526", "10714076981", "10714392151", "11444443576"}
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. dances[math.random(1, #dances)]
	danceTrack = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	danceTrack.Looped = true
	danceTrack:Play()
end)

addcmd("undance", {"nodance"}, function(args, speaker)
	danceTrack:Stop()
	danceTrack:Destroy()
end)

addcmd('nolimbs',{'rlimbs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" or
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" or
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('noarms',{'rarms'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('nolegs',{'rlegs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" then
				v:Destroy()
			end
		end
	end
end)

addcmd("sit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid").Sit = true
end)

addcmd("lay", {"laydown"}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	humanoid.Sit = true
	task.wait(0.1)
	humanoid.RootPart.CFrame = humanoid.RootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
	for _, v in ipairs(humanoid:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end)

addcmd("sitwalk", {}, function(args, speaker)
	local anims = speaker.Character.Animate
	local sit = anims.sit:FindFirstChildWhichIsA("Animation").AnimationId
	anims.idle:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.walk:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.run:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.jump:FindFirstChildWhichIsA("Animation").AnimationId = sit
	speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = not r15(speaker) and -1.5 or 0.5
end)

addcmd("nosit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end)

addcmd("unnosit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
end)

addcmd("jump", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end)

local infJump
infJumpDebounce = false
addcmd("infjump", {"infinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
	infJump = UserInputService.JumpRequest:Connect(function()
		if not infJumpDebounce then
			infJumpDebounce = true
			speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
			wait()
			infJumpDebounce = false
		end
	end)
end)

addcmd("uninfjump", {"uninfinitejump", "noinfjump", "noinfinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
end)

local flyjump
addcmd("flyjump", {}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
	flyjump = UserInputService.JumpRequest:Connect(function()
		speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end)
end)

addcmd("unflyjump", {"noflyjump"}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
end)

local HumanModCons = {}
addcmd('autojump',{'ajump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local function autoJump()
		if Char and Human then
			local check1 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position-Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			local check2 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position+Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			if check1 or check2 then
				Human.Jump = true
			end
		end
	end
	autoJump()
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		autoJump()
		HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	end)
end)

addcmd('unautojump',{'noautojump', 'noajump', 'unajump'},function(args, speaker)
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or nil
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or nil
end)

addcmd('edgejump',{'ejump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	-- Full credit to NoelGamer06 @V3rmillion
	local state
	local laststate
	local lastcf
	local function edgejump()
		if Char and Human then
			laststate = state
			state = Human:GetState()
			if laststate ~= state and state == Enum.HumanoidStateType.Freefall and laststate ~= Enum.HumanoidStateType.Jumping then
				Char.Humanoid.RootPart.CFrame = lastcf
				Char.Humanoid.RootPart.Velocity = Vector3.new(Char.Humanoid.RootPart.Velocity.X, Human.JumpPower or Human.JumpHeight, Char.Humanoid.RootPart.Velocity.Z)
			end
			lastcf = Char.Humanoid.RootPart.CFrame
		end
	end
	edgejump()
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		edgejump()
		HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	end)
end)

addcmd('unedgejump',{'noedgejump', 'noejump', 'unejump'},function(args, speaker)
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or nil
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or nil
end)

addcmd("team", {}, function(args, speaker)
	local teamName = getstring(1, args)
	local team = nil
	local root = speaker.Character and getRoot(speaker.Character)
	for _, v in ipairs(Teams:GetChildren()) do
		if v.Name:lower():match(teamName:lower()) then
			team = v
			break
		end
	end
	if not team then
		return notify("Invalid Team", teamName .. " is not a valid team")
	end
	if root and firetouchinterest then
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("SpawnLocation") and v.BrickColor == team.TeamColor and v.AllowTeamChangeOnTouch == true then
				firetouchinterest(v, root, 0)
				firetouchinterest(v, root, 1)
				break
			end
		end
	else
		speaker.Team = team
	end
end)

addcmd('nobgui',{'unbgui','nobillboardgui','unbillboardgui','noname','rohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
end)

addcmd('loopnobgui',{'loopunbgui','loopnobillboardgui','loopunbillboardgui','loopnoname','looprohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
	local function charPartAdded(part)
		if part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
			wait()
			part:Destroy()
		end
	end
	charPartTrigger = speaker.Character.DescendantAdded:Connect(charPartAdded)
end)

addcmd('unloopnobgui',{'unloopunbgui','unloopnobillboardgui','unloopunbillboardgui','unloopnoname','unlooprohg'},function(args, speaker)
	if charPartTrigger then
		charPartTrigger:Disconnect()
	end
end)

addcmd('spasm',{},function(args, speaker)
	if not r15(speaker) then
		local pchar=speaker.Character
		local AnimationId = "33796059"
		SpasmAnim = Instance.new("Animation")
		SpasmAnim.AnimationId = "rbxassetid://"..AnimationId
		Spasm = pchar:FindFirstChildOfClass('Humanoid'):LoadAnimation(SpasmAnim)
		Spasm:Play()
		Spasm:AdjustSpeed(99)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('unspasm',{'nospasm'},function(args, speaker)
	Spasm:Stop()
	SpasmAnim:Destroy()
end)

addcmd('headthrow',{},function(args, speaker)
	if not r15(speaker) then
		local AnimationId = "35154961"
		local Anim = Instance.new("Animation")
		Anim.AnimationId = "rbxassetid://"..AnimationId
		local k = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(Anim)
		k:Play(0)
		k:AdjustSpeed(1)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

local function anim2track(asset_id)
	local objs = game:GetObjects(asset_id)
	for i = 1, #objs do
		if objs[i]:IsA("Animation") then
			return objs[i].AnimationId
		end
	end
	return asset_id
end

addcmd("animation", {"anim"}, function(args, speaker)
	local animid = tostring(args[1])
	if not animid:find("rbxassetid://") then
		animid = "rbxassetid://" .. animid
	end
	animid = anim2track(animid)
	local animation = Instance.new("Animation")
	animation.AnimationId = animid
	local anim = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	anim.Priority = Enum.AnimationPriority.Movement
	anim:Play()
	if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)

addcmd("emote", {"em"}, function(args, speaker)
	local anim = humanoid:PlayEmoteAndGetAnimTrackById(args[1])
	if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)


addcmd('noanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = true
end)

addcmd('reanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = false
end)

addcmd('animspeed',{},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:AdjustSpeed(tonumber(args[1] or 1))
	end
end)

addcmd('copyanimation',{'copyanim','copyemote'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for _,v in ipairs(players)do
		local char = Players[v].Character
		for _, v1 in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			v1:Stop()
		end
		for _, v1 in pairs(Players[v].Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			if not string.find(v1.Animation.AnimationId, "507768375") then
				local ANIM = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(v1.Animation)
				ANIM:Play(.1, 1, v1.Speed)
				ANIM.TimePosition = v1.TimePosition
				task.spawn(function()
					v1.Stopped:Wait()
					ANIM:Stop()
					ANIM:Destroy()
				end)
			end
		end
	end
end)

addcmd("copyanimationid", {"copyanimid", "copyemoteid"}, function(args, speaker)
	local copyAnimId = function(player)
		local found = "Animations Copied"

		for _, v in pairs(player.Character:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks()) do
			local animationId = v.Animation.AnimationId
			local assetId = animationId:find("rbxassetid://") and animationId:match("%d+")

			if not string.find(animationId, "507768375") and not string.find(animationId, "180435571") then
				if assetId then
					local success, result = pcall(function()
						return MarketplaceService:GetProductInfo(tonumber(assetId)).Name
					end)
					local name = success and result or "Failed to get name"
					found = found .. "\n\nName: " .. name .. "\nAnimation Id: " .. animationId
				else
					found = found .. "\n\nAnimation Id: " .. animationId
				end
			end
		end

		if found ~= "Animations Copied" then
			toClipboard(found)
		else
			notify("Animations", "No animations to copy")
		end
	end

	if args[1] then
		copyAnimId(Players[getPlayer(args[1], speaker)[1]])
	else
		copyAnimId(speaker)
	end
end)

addcmd('stopanimations',{'stopanims','stopanim'},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:Stop()
	end
end)

addcmd('refreshanimations', {'refreshanimation', 'refreshanims', 'refreshanim'}, function(args, speaker)
	local Char = speaker.Character or speaker.CharacterAdded:Wait()
	local Human = Char and Char:WaitForChild('Humanoid', 15)
	local Animate = Char and Char:WaitForChild('Animate', 15)
	if not Human or not Animate then
		return notify('Refresh Animations', 'Failed to get Animate/Humanoid')
	end
	Animate.Disabled = true
	for _, v in ipairs(Human:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	Animate.Disabled = false
end)

addcmd('allowcustomanim', {'allowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = true
	execCmd('refreshanimations')
end)

addcmd('unallowcustomanim', {'unallowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = false
	execCmd('refreshanimations')
end)

addcmd('loopanimation', {'loopanim'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char.FindFirstChildWhichIsA(Char, "Humanoid")
	for _, v in ipairs(Human.GetPlayingAnimationTracks(Human)) do
		v.Looped = true
	end
end)

addcmd('tpposition',{'tppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		getRoot(char).CFrame = CFrame.new(tpX,tpY,tpZ)
	end
end)

addcmd('tweentpposition',{'ttppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tpX,tpY,tpZ)}):Play()
	end
end)

addcmd("offset", {}, function(args, speaker)
    if #args < 3 then return end
    speaker.Character:TranslateBy(Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0))
end)

addcmd("tweenoffset", {"toffset"}, function(args, speaker)
    if #args < 3 then return end
    local tpX, tpY, tpZ = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    local root = getRoot(speaker.Character)
    local pos = root.Position + Vector3.new(tpX, tpY, tpZ)
    TweenService:Create(root, TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)}):Play()
    breakVelocity()
end)

addcmd("clickteleport", {}, function(args, speaker)
    if speaker ~= Players.LocalPlayer then return end
    notify("Click TP", "Go to Settings > Keybinds > Add to set up click teleport")
end)

addcmd("mouseteleport", {"mousetp"}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local pos = IYMouse.Hit
    if root and pos then
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
        breakVelocity()
    end
end)

addcmd("tptool", {"teleporttool"}, function(args, speaker)
    local TpTool = Instance.new("Tool")
    TpTool.Name = "Teleport Tool"
    TpTool.RequiresHandle = false
    TpTool.Parent = speaker:FindFirstChildOfClass("Backpack")
    TpTool.Activated:Connect(function()
        local root = getRoot(speaker.Character)
        local pos = IYMouse.Hit
        if not root or not pos then return end
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
        breakVelocity()
    end)
end)

addcmd("thru", {}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local num = tonumber(args[1]) or 5
    local pos = root.CFrame.Position + (root.CFrame.LookVector * num)
    root.CFrame = CFrame.new(pos, pos + root.CFrame.LookVector)
end)

addcmd('clickdelete',{},function(args, speaker)
	if speaker == Players.LocalPlayer then
		notify('Click Delete','Go to Settings > Keybinds > Add to set up click delete')
	end
end)

addcmd('getposition',{'getpos','notifypos','notifyposition'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		notify('Current Position',roundedPos)
	end
end)

addcmd('copyposition',{'copypos'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		toClipboard(roundedPos)
	end
end)

addcmd('walktopos',{'walktoposition'},function(args, speaker)
	if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
		wait(.1)
	end
	speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(args[1],args[2],args[3])
end)

addcmd('speed',{'ws','walkspeed'},function(args, speaker)
	if args[2] then
		local speed = args[2] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	else
		local speed = args[1] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	end
end)

addcmd('spoofspeed',{'spoofws','spoofwalkspeed'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setspeed;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					return setspeed or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					setspeed = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopspeed',{'loopws'},function(args, speaker)
	local speed = args[1] or 16
	if args[2] then
		speed = args[2] or 16
	end
	if isNumber(speed) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function WalkSpeedChange()
			if Char and Human then
				Human.WalkSpeed = speed
			end
		end
		WalkSpeedChange()
		HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			WalkSpeedChange()
			HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		end)
	end
end)

addcmd('unloopspeed',{'unloopws'},function(args, speaker)
	HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or nil
	HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or nil
end)

addcmd('spoofjumppower',{'spoofjp'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setpower;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					return setpower or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					setpower = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopjumppower',{'loopjp','loopjpower'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function JumpPowerChange()
			if Char and Human then
				if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
				else
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
				end
			end
		end
		JumpPowerChange()
		HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			JumpPowerChange()
			HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		end)
	end
end)

addcmd('unloopjumppower',{'unloopjp','unloopjpower'},function(args, speaker)
	local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or nil
	HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or nil
	if Char and Human then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = 50
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = 50
		end
	end
end)

addcmd('tools',{'gears'},function(args, speaker)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(Lighting)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(ReplicatedStorage)
	notify('Tools','Copied tools from ReplicatedStorage and Lighting')
end)

addcmd('notools',{'rtools','clrtools','removetools','deletetools','dtools'},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd('deleteselectedtool',{'dst'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd("console", {}, function(args, speaker)
	StarterGui:SetCore("DevConsoleVisible", true)
end)

addcmd('oldconsole',{},function(args, speaker)
	-- Thanks wally!!
	notify("Loading",'Hold on a sec')
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	notify('Console','Press F9 to open the console')
end)

addcmd("explorer", {"dex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
end)

addcmd("moondex", {"mdex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addcmd("remotespy", {"rspy", "cobalt", "cspy"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    -- Full credit to notpoiu, creator of Cobalt
    loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
end)

addcmd("simplespy", {"sspy"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    -- Full credit to exx, creator of SimpleSpy
    -- also thanks to Amity for fixing
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

addcmd('audiologger',{'alogger'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
end)

local loopgoto = nil
addcmd('loopgoto',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		loopgoto = nil
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		loopgoto = Players[v]
		local distance = 3
		if args[2] and isNumber(args[2]) then
			distance = args[2]
		end
		local lDelay = 0
		if args[3] and isNumber(args[3]) then
			lDelay = args[3]
		end
		repeat
			if Players:FindFirstChild(v) then
				if Players[v].Character ~= nil then
					getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(distance,1,0)
				end
				wait(lDelay)
			else
				loopgoto = nil
			end
		until loopgoto ~= Players[v]
	end
end)

addcmd('unloopgoto',{'noloopgoto'},function(args, speaker)
	loopgoto = nil
end)

addcmd('headsit',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if headSit then headSit:Disconnect() end
	for i,v in pairs(players)do
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = true
		headSit = RunService.Heartbeat:Connect(function()
			if Players:FindFirstChild(Players[v].Name) and Players[v].Character ~= nil and getRoot(Players[v].Character) and getRoot(speaker.Character) and speaker.Character:FindFirstChildOfClass('Humanoid').Sit == true then
				getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame * CFrame.Angles(0,math.rad(0),0)* CFrame.new(0,1.6,0.4)
			else
				headSit:Disconnect()
			end
		end)
	end
end)

addcmd('chat',{'say'},function(args, speaker)
	local cString = getstring(1, args)
	chatMessage(cString)
end)


spamming = false
spamspeed = 1
addcmd('spam',{},function(args, speaker)
	spamming = true
	local spamstring = getstring(1, args)
	repeat wait(spamspeed)
		chatMessage(spamstring)
	until spamming == false
end)

addcmd('nospam',{'unspam'},function(args, speaker)
	spamming = false
end)

addcmd('whisper',{'pm'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			local pmstring = getstring(2, args)
			chatMessage("/w "..plrName.." "..pmstring)
		end)
	end
end)

pmspamming = {}
addcmd('pmspam',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			if FindInTable(pmspamming, plrName) then return end
			table.insert(pmspamming, plrName)
			local pmspamstring = getstring(2, args)
			repeat
				if Players:FindFirstChild(v) then
					wait(spamspeed)
					chatMessage("/w "..plrName.." "..pmspamstring)
				else
					for a,b in pairs(pmspamming) do if b == plrName then table.remove(pmspamming, a) end end
				end
			until not FindInTable(pmspamming, plrName)
		end)
	end
end)

addcmd('nopmspam',{'unpmspam'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(pmspamming) do
				if b == Players[v].Name then
					table.remove(pmspamming, a)
				end
			end
		end)
	end
end)

addcmd('spamspeed',{},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		spamspeed = speed
	end
end)

addcmd('bubblechat',{},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = true
	else
		TextChatService.BubbleChatConfiguration.Enabled = true
	end
end)

addcmd('unbubblechat',{'nobubblechat'},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = false
	else
		TextChatService.BubbleChatConfiguration.Enabled = false
	end
end)

addcmd("chatwindow", {}, function(args, speaker)
	TextChatService.ChatWindowConfiguration.Enabled = true
end)

addcmd("unchatwindow", {"nochatwindow"}, function(args, speaker)
	TextChatService.ChatWindowConfiguration.Enabled = false
end)

addcmd("darkchat", {}, function(args, speaker)
    local BCC = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")
    local CWC = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
    local CIBC = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
    if BCC then
        BCC.Enabled = true
        BCC.BackgroundColor3 = Color3.fromRGB()
        BCC.BackgroundTransparency = 0.3
        BCC.TailVisible = true
        BCC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
    end
    if CWC then
        CWC.Enabled = true
        CWC.BackgroundColor3 = Color3.fromRGB()
        CWC.BackgroundTransparency = 0.3
        CWC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CWC.TextStrokeColor3 = Color3.fromRGB()
        CWC.TextStrokeTransparency = 0.5
    end
    if CIBC then
        CIBC.Enabled = true
        CIBC.BackgroundColor3 = Color3.fromRGB()
        CIBC.BackgroundTransparency = 0.5
        CIBC.PlaceholderColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CIBC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CIBC.TextStrokeColor3 = Color3.fromRGB()
        CIBC.TextStrokeTransparency = 0.5
    end
end)

addcmd('blockhead',{},function(args, speaker)
	speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
end)

addcmd('blockhats',{},function(args, speaker)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		for i,c in pairs(v:GetDescendants()) do
			if c:IsA("SpecialMesh") then
				c:Destroy()
			end
		end
	end
end)

addcmd('blocktool',{},function(args, speaker)
	for _,v in pairs(speaker.Character:GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			for i,c in pairs(v:GetDescendants()) do
				if c:IsA("SpecialMesh") then
					c:Destroy()
				end
			end
		end
	end
end)

addcmd('creeper',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character.LeftUpperArm:Destroy()
		speaker.Character.RightUpperArm:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	else
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character["Left Arm"]:Destroy()
		speaker.Character["Right Arm"]:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	end
end)

function getTorso(x)
	x = x or Players.LocalPlayer.Character
	return x:FindFirstChild("Torso") or x:FindFirstChild("UpperTorso") or x:FindFirstChild("LowerTorso") or x:FindFirstChild("HumanoidRootPart")
end

addcmd("bang", {"rape"}, function(args, speaker)
	execCmd("unbang")
	wait()
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	bangAnim = Instance.new("Animation")
	bangAnim.AnimationId = not r15(speaker) and "rbxassetid://148840371" or "rbxassetid://5918726674"
	bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(args[2] or 3)
	bangDied = humanoid.Died:Connect(function()
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		bangLoop:Disconnect()
	end)
	if args[1] then
		local players = getPlayer(args[1], speaker)
		for _, v in pairs(players) do
			local bangplr = Players[v].Name
			local bangOffet = CFrame.new(0, 0, 1.1)
			bangLoop = RunService.Stepped:Connect(function()
				pcall(function()
					local otherRoot = getTorso(Players[bangplr].Character)
					getRoot(speaker.Character).CFrame = otherRoot.CFrame * bangOffet
				end)
			end)
			break
		end
	end
end)

addcmd("unbang", {"unrape"}, function(args, speaker)
	if bangDied then
		bangDied:Disconnect()
		bang:Stop()
		bangAnim:Destroy()
		bangLoop:Disconnect()
	end
end)

addcmd('carpet',{},function(args, speaker)
	if not r15(speaker) then
		execCmd('uncarpet')
		wait()
		local players = getPlayer(args[1], speaker)
		for i,v in pairs(players)do
			carpetAnim = Instance.new("Animation")
			carpetAnim.AnimationId = "rbxassetid://282574440"
			carpet = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(carpetAnim)
			carpet:Play(.1, 1, 1)
			local carpetplr = Players[v].Name
			carpetDied = speaker.Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
				carpetLoop:Disconnect()
				carpet:Stop()
				carpetAnim:Destroy()
				carpetDied:Disconnect()
			end)
			carpetLoop = RunService.Heartbeat:Connect(function()
				pcall(function()
					getRoot(Players.LocalPlayer.Character).CFrame = getRoot(Players[carpetplr].Character).CFrame
				end)
			end)
		end
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('uncarpet',{'nocarpet'},function(args, speaker)
	if carpetLoop then
		carpetLoop:Disconnect()
		carpetDied:Disconnect()
		carpet:Stop()
		carpetAnim:Destroy()
	end
end)

addcmd('friend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RequestFriendship(Players[v])
	end
end)

addcmd('unfriend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RevokeFriendship(Players[v])
	end
end)

addcmd('bringpart',{},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

addcmd('bringpartclass',{'bpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

gotopartDelay = 0.1
addcmd('gotopart',{'topart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopart',{'tgotopart','ttopart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotopartclass',{'gpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopartclass',{'tgpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotomodel',{'tomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v:GetModelCFrame()
		end
	end
end)

addcmd('tweengotomodel',{'tgotomodel','ttomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v:GetModelCFrame()}):Play()
		end
	end
end)

addcmd('gotopartdelay',{},function(args, speaker)
	local gtpDelay = args[1] or 0.1
	if isNumber(gtpDelay) then
		gotopartDelay = gtpDelay
	end
end)

addcmd('noclickdetectorlimits',{'nocdlimits','removecdlimits'},function(args, speaker)
	for i,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireclickdetectors',{'firecd','firecds'}, function(args, speaker)
	if fireclickdetector then
		if args[1] then
			local name = getstring(1, args):lower()
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") and descendant.Name:lower() == name or descendant.Parent.Name:lower() == name then
					fireclickdetector(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") then
					fireclickdetector(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireclickdetector)")
	end
end)

addcmd('noproximitypromptlimits',{'nopplimits','removepplimits'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireproximityprompts',{'firepp'},function(args, speaker)
	if fireproximityprompt then
		if args[1] then
			local name = getstring(1, args)
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") and descendant.Name == name or descendant.Parent.Name == name then
					fireproximityprompt(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") then
					fireproximityprompt(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireproximityprompt)")
	end
end)

local PromptButtonHoldBegan = nil
addcmd('instantproximityprompts',{'instantpp'},function(args, speaker)
	if fireproximityprompt then
		execCmd("uninstantproximityprompts")
		wait(0.1)
		PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
			fireproximityprompt(prompt)
		end)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing fireproximityprompt)')
	end
end)

addcmd('uninstantproximityprompts',{'uninstantpp'},function(args, speaker)
	if PromptButtonHoldBegan ~= nil then
		PromptButtonHoldBegan:Disconnect()
		PromptButtonHoldBegan = nil
	end
end)

addcmd('notifyping',{'ping'},function(args, speaker)
	notify("Ping", math.round(speaker:GetNetworkPing() * 1000) .. "ms")
end)

addcmd('grabtools', {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	for _, child in ipairs(workspace:GetChildren()) do
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end

	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	grabtoolsFunc = workspace.ChildAdded:Connect(function(child)
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end)

	notify("Grabtools", "Picking up any dropped tools")
end)

addcmd('nograbtools',{'ungrabtools'},function(args, speaker)
	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	notify("Grabtools", "Grabtools has been disabled")
end)

local specifictoolremoval = {}
addcmd('removespecifictool',{},function(args, speaker)
	if args[1] and speaker:FindFirstChildOfClass("Backpack") then
		local tool = string.lower(getstring(1, args))
		local RST = RunService.RenderStepped:Connect(function()
			if speaker:FindFirstChildOfClass("Backpack") then
				for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
					if v.Name:lower() == tool then
						v:Remove()
					end
				end
			end
		end)
		specifictoolremoval[tool] = RST
	end
end)

addcmd('unremovespecifictool',{},function(args, speaker)
	if args[1] then
		local tool = string.lower(getstring(1, args))
		if specifictoolremoval[tool] ~= nil then
			specifictoolremoval[tool]:Disconnect()
			specifictoolremoval[tool] = nil
		end
	end
end)

addcmd('clearremovespecifictool',{},function(args, speaker)
	for obj in pairs(specifictoolremoval) do
		specifictoolremoval[obj]:Disconnect()
		specifictoolremoval[obj] = nil
	end
end)

addcmd('light',{},function(args, speaker)
	local light = Instance.new("PointLight")
	light.Parent = getRoot(speaker.Character)
	light.Range = 30
	if args[1] then
		light.Brightness = args[2]
		light.Range = args[1]
	else
		light.Brightness = 5
	end
end)

addcmd('unlight',{'nolight'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName == "PointLight" then
			v:Destroy()
		end
	end
end)

addcmd('copytools',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for i,v in pairs(Players[v]:FindFirstChildOfClass("Backpack"):GetChildren()) do
				if v:IsA('Tool') or v:IsA('HopperBin') then
					v:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
				end
			end
		end)
	end
end)

addcmd('naked',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Clothing") or v:IsA("ShirtGraphic") then
			v:Destroy()
		end
	end
end)

addcmd('noface',{'removeface'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Decal") and v.Name == 'face' then
			v:Destroy()
		end
	end
end)

addcmd('spawnpoint',{'spawn'},function(args, speaker)
	spawnpos = getRoot(speaker.Character).CFrame
	spawnpoint = true
	spDelay = tonumber(args[1]) or 0.1
	notify('Spawn Point','Spawn point created at '..tostring(spawnpos))
end)

addcmd('nospawnpoint',{'nospawn','removespawnpoint'},function(args, speaker)
	spawnpoint = false
	notify('Spawn Point','Removed spawn point')
end)

addcmd('flashback',{'diedtp'},function(args, speaker)
	if lastDeath ~= nil then
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		getRoot(speaker.Character).CFrame = lastDeath
	end
end)

addcmd('hatspin',{'spinhats'},function(args, speaker)
	execCmd('unhatspin')
	wait(.5)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		local keep = Instance.new("BodyPosition") keep.Name = randomString() keep.Parent = v.Handle
		local spin = Instance.new("BodyAngularVelocity") spin.Name = randomString() spin.Parent = v.Handle
		v.Handle:FindFirstChildOfClass("Weld"):Destroy()
		if args[1] then
			spin.AngularVelocity = Vector3.new(0, args[1], 0)
			spin.MaxTorque = Vector3.new(0, args[1] * 2, 0)
		else
			spin.AngularVelocity = Vector3.new(0, 100, 0)
			spin.MaxTorque = Vector3.new(0, 200, 0)
		end
		keep.P = 30000
		keep.D = 50
		spinhats = RunService.Stepped:Connect(function()
			pcall(function()
				keep.Position = Players.LocalPlayer.Character.Head.Position
			end)
		end)
	end
end)

addcmd('unhatspin',{'unspinhats'},function(args, speaker)
	if spinhats then
		spinhats:Disconnect()
	end
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		v.Parent = workspace
		for i,c in pairs(v.Handle) do
			if c:IsA("BodyPosition") or c:IsA("BodyAngularVelocity") then
				c:Destroy()
			end
		end
		wait()
		v.Parent = speaker.Character
	end
end)

addcmd('clearhats',{'cleanhats'},function(args, speaker)
	if firetouchinterest then
		local Player = Players.LocalPlayer
		local Character = Player.Character
		local Old = getRoot(Character).CFrame
		local Hats = {}

		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Accessory") then
				table.insert(Hats, child)
			end
		end

		for _, accessory in ipairs(Character:FindFirstChildOfClass("Humanoid"):GetAccessories()) do
			accessory:Destroy()
		end

		for i = 1, #Hats do
			repeat RunService.Heartbeat:wait() until Hats[i]
			firetouchinterest(Hats[i].Handle,getRoot(Character),0)
			repeat RunService.Heartbeat:wait() until Character:FindFirstChildOfClass("Accessory")
			Character:FindFirstChildOfClass("Accessory"):Destroy()
			repeat RunService.Heartbeat:wait() until not Character:FindFirstChildOfClass("Accessory")
		end

		execCmd("reset")

		Player.CharacterAdded:Wait()

		for i = 1,20 do 
			RunService.Heartbeat:Wait()
			if getRoot(Player.Character) then
				getRoot(Player.Character).Humanoid.RootPart.CFrame = Old
			end
		end
	else
		notify("Incompatible Exploit","Your exploit does not support this command (missing firetouchinterest)")
	end
end)

addcmd('split',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.UpperTorso.Waist:Destroy()
	else
		notify('R15 Required','This command requires the r15 rig type')
	end
end)

addcmd('nilchar',{},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = nil
	end
end)

addcmd('unnilchar',{'nonilchar'},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = workspace
	end
end)

addcmd('noroot',{'removeroot','rroot'},function(args, speaker)
	if speaker.Character ~= nil then
		local char = Players.LocalPlayer.Character
		char.Parent = nil
		char.Humanoid.RootPart:Destroy()
		char.Parent = workspace
	end
end)

addcmd('replaceroot',{'replacerootpart'},function(args, speaker)
	if speaker.Character ~= nil and getRoot(speaker.Character) then
		local Char = speaker.Character
		local OldParent = Char.Parent
		local HRP = Char and getRoot(Char)
		local OldPos = HRP.CFrame
		Char.Parent = game
		local HRP1 = HRP:Clone()
		HRP1.Parent = Char
		HRP = HRP:Destroy()
		HRP1.CFrame = OldPos
		Char.Parent = OldParent
	end
end)

addcmd('clearcharappearance',{'clearchar','clrchar'},function(args, speaker)
	speaker:ClearCharacterAppearance()
end)

addcmd('equiptools',{},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			v.Parent = speaker.Character
		end
	end
end)

addcmd('unequiptools',{},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
end)

local function GetHandleTools(p)
	p = p or Players.LocalPlayer
	local r = {}
	for _, v in ipairs(p.Character and p.Character:GetChildren() or {}) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	for _, v in ipairs(p.Backpack:GetChildren()) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	return r
end
addcmd('dupetools', {'clonetools'}, function(args, speaker)
	local LOOP_NUM = tonumber(args[1]) or 1
	local OrigPos = speaker.Character.Humanoid.RootPart.Position
	local Tools, TempPos = {}, Vector3.new(math.random(-2e5, 2e5), 2e5, math.random(-2e5, 2e5))
	for i = 1, LOOP_NUM do
		local Human = speaker.Character:WaitForChild("Humanoid")
		wait(.1, Human.Parent:MoveTo(TempPos))
		Human.RootPart.Anchored = speaker:ClearCharacterAppearance(wait(.1)) or true
		local t = GetHandleTools(speaker)
		while #t > 0 do
			for _, v in ipairs(t) do
				task.spawn(function()
					for _ = 1, 25 do
						v.Parent = speaker.Character
						v.Handle.Anchored = true
					end
					for _ = 1, 5 do
						v.Parent = workspace
					end
					table.insert(Tools, v.Handle)
				end)
			end
			t = GetHandleTools(speaker)
		end
		wait(.1)
		speaker.Character = speaker.Character:Destroy()
		speaker.CharacterAdded:Wait():WaitForChild("Humanoid").Parent:MoveTo(LOOP_NUM == i and OrigPos or TempPos, wait(.1))
		if i == LOOP_NUM or i % 5 == 0 then
			local HRP = speaker.Character.Humanoid.RootPart
			if type(firetouchinterest) == "function" then
				for _, v in ipairs(Tools) do
					v.Anchored = not firetouchinterest(v, HRP, 1, firetouchinterest(v, HRP, 0)) and false or false
				end
			else
				for _, v in ipairs(Tools) do
					task.spawn(function()
						local x = v.CanCollide
						v.CanCollide = false
						v.Anchored = false
						for _ = 1, 10 do
							v.CFrame = HRP.CFrame
							wait()
						end
						v.CanCollide = x
					end)
				end
			end
			wait(.1)
			Tools = {}
		end
		TempPos = TempPos + Vector3.new(10, math.random(-5, 5), 0)
	end
end)

addcmd('touchinterests', {'touchinterest', 'firetouchinterests', 'firetouchinterest'}, function(args, speaker)
	local Root = getRoot(speaker.Character) or speaker.Character:FindFirstChildWhichIsA("BasePart")

	if not firetouchinterest then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
		return
	end

	local function Touch(x)
		x = x.FindFirstAncestorWhichIsA(x, "Part")
		if x then
			return task.spawn(function()
				firetouchinterest(x, Root, 1, wait() and firetouchinterest(x, Root, 0))
			end)
		end
		x.CFrame = Root.CFrame
	end

	if args[1] then
		local name = getstring(1, args):lower()
		print(name..' -name')
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("TouchTransmitter") and v.Name:lower() == name or v.Parent.Name:lower() == name then
				Touch(v)
			end
		end
	else
		for _, v in ipairs(workspace:GetDescendants()) do
			if v.IsA(v, "TouchTransmitter") then
				Touch(v)
			end
		end
	end
end)

addcmd('fullbright',{'fb','fullbrightness'},function(args, speaker)
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

addcmd('loopfullbright',{'loopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
	local function brightFunc()
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end

	brightLoop = RunService.RenderStepped:Connect(brightFunc)
end)

addcmd('unloopfullbright',{'unloopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
end)

addcmd('ambient',{},function(args, speaker)
	Lighting.Ambient = Color3.new(args[1],args[2],args[3])
	Lighting.OutdoorAmbient = Color3.new(args[1],args[2],args[3])
end)

addcmd('day',{},function(args, speaker)
	Lighting.ClockTime = 14
end)

addcmd('night',{},function(args, speaker)
	Lighting.ClockTime = 0
end)

addcmd('nofog',{},function(args, speaker)
	Lighting.FogEnd = 100000
	for i,v in pairs(Lighting:GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
end)

addcmd('brightness',{},function(args, speaker)
	Lighting.Brightness = args[1]
end)

addcmd('globalshadows',{'gshadows'},function(args, speaker)
	Lighting.GlobalShadows = true
end)

addcmd('unglobalshadows',{'nogshadows','ungshadows','noglobalshadows'},function(args, speaker)
	Lighting.GlobalShadows = false
end)

origsettings = {abt = Lighting.Ambient, oabt = Lighting.OutdoorAmbient, brt = Lighting.Brightness, time = Lighting.ClockTime, fe = Lighting.FogEnd, fs = Lighting.FogStart, gs = Lighting.GlobalShadows}

addcmd('restorelighting',{'rlighting'},function(args, speaker)
	Lighting.Ambient = origsettings.abt
	Lighting.OutdoorAmbient = origsettings.oabt
	Lighting.Brightness = origsettings.brt
	Lighting.ClockTime = origsettings.time
	Lighting.FogEnd = origsettings.fe
	Lighting.FogStart = origsettings.fs
	Lighting.GlobalShadows = origsettings.gs
end)

addcmd('stun',{'platformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
end)

addcmd('unstun',{'nostun','unplatformstand','noplatformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
end)

addcmd('norotate',{'noautorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = false
end)

addcmd('unnorotate',{'autorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = true
end)

addcmd('enablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, true)
end)

addcmd('disablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, false)
end)

addcmd('drophats',{'drophat'},function(args, speaker)
	if speaker.Character then
		for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
			v.Parent = workspace
		end
	end
end)

addcmd('deletehats',{'nohats','rhats'},function(args, speaker)
	for i,v in next, speaker.Character:GetDescendants() do
		if v:IsA("Accessory") then
			for i,p in next, v:GetDescendants() do
				if p:IsA("Weld") then
					p:Destroy()
				end
			end
		end
	end
end)

addcmd('droptools',{'droptool'},function(args, speaker)
	for i,v in pairs(Players.LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = Players.LocalPlayer.Character
		end
	end
	wait()
	for i,v in pairs(Players.LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = workspace
		end
	end
end)

addcmd('droppabletools',{},function(args, speaker)
	if speaker.Character then
		for _,obj in pairs(speaker.Character:GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
	if speaker:FindFirstChildOfClass("Backpack") then
		for _,obj in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
end)

local currentToolSize = ""
local currentGripPos = ""
addcmd('reach',{},function(args, speaker)
	execCmd('unreach')
	wait()
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			if args[1] then
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,args[1])
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			else
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,60)
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			end
		end
	end
end)

addcmd("boxreach", {}, function(args, speaker)
	execCmd("unreach")
	wait()
	for i, v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			local size = tonumber(args[1]) or 60
			currentToolSize = v.Handle.Size
			currentGripPos = v.GripPos
			local a = Instance.new("SelectionBox")
			a.Name = "SelectionBoxCreated"
			a.Parent = v.Handle
			a.Adornee = v.Handle
			v.Handle.Massless = true
			v.Handle.Size = Vector3.new(size, size, size)
			v.GripPos = Vector3.new(0, 0, 0)
			speaker.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
		end
	end
end)

addcmd('unreach',{'noreach','unboxreach'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Handle.Size = currentToolSize
			v.GripPos = currentGripPos
			v.Handle.SelectionBoxCreated:Destroy()
		end
	end
end)

addcmd('grippos',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Parent = speaker:FindFirstChildOfClass("Backpack")
			v.GripPos = Vector3.new(args[1],args[2],args[3])
			v.Parent = speaker.Character
		end
	end
end)

addcmd('usetools', {}, function(args, speaker)
	local Backpack = speaker:FindFirstChildOfClass("Backpack")
	local amount = tonumber(args[1]) or 1
	local delay_ = tonumber(args[2]) or false
	for _, v in ipairs(Backpack:GetChildren()) do
		v.Parent = speaker.Character
		task.spawn(function()
			for _ = 1, amount do
				v:Activate()
				if delay_ then
					wait(delay_)
				end
			end
			v.Parent = Backpack
		end)
	end
end)

addcmd("logs", {}, function(args, speaker)
	logsEnabled = true
	jLogsEnabled = true
	Toggle.Text = "Enabled"
	Toggle_2.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogs", {"clogs"}, function(args, speaker)
	logsEnabled = true
	join.Visible = false
	chat.Visible = true
	table.remove(shade3, table.find(shade3, selectChat))
	table.remove(shade2, table.find(shade2, selectJoin))
	table.insert(shade2, selectChat)
	table.insert(shade3, selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
	Toggle.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("joinlogs", {"jlogs"}, function(args, speaker)
	jLogsEnabled = true
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3, table.find(shade3, selectJoin))
	table.remove(shade2, table.find(shade2, selectChat))
	table.insert(shade2, selectJoin)
	table.insert(shade3, selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
	Toggle_2.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogswebhook", {"logswebhook"}, function(args, speaker)
	if not httprequest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing request)")
	end
	logsWebhook = args[1] or nil
	updatesaves()
end)

flinging = false
addcmd('fling',{},function(args, speaker)
	flinging = false
	for _, child in next, speaker.Character:GetDescendants() do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
		end
	end
	execCmd('noclip nonotify')
	task.wait(.1)
	local bambam = Instance.new("BodyAngularVelocity")
	bambam.Name = randomString()
	bambam.Parent = getRoot(speaker.Character)
	bambam.AngularVelocity = Vector3.new(0,99999,0)
	bambam.MaxTorque = Vector3.new(0,math.huge,0)
	bambam.P = math.huge
	for i, v in next, speaker.Character:GetChildren() do
		if v:IsA("BasePart") then
			v.Massless = true
			v.Velocity = Vector3.zero
		end
	end
	flinging = true
	flingDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
		execCmd('unfling')
	end)
	repeat
		bambam.AngularVelocity = Vector3.new(0,99999,0)
		task.wait(.2)
		bambam.AngularVelocity = Vector3.new(0,0,0)
		task.wait(.1)
	until flinging == false
end)

addcmd('unfling',{'nofling'},function(args, speaker)
	execCmd('clip nonotify')
	if flingDied then flingDied:Disconnect() end
	flinging = false
	task.wait(.1)
	local speakerChar = speaker.Character
	if not speakerChar or not getRoot(speakerChar) then return end
	for _, v in next, speakerChar:GetDescendants() do
		if v:IsA("BasePart") then
			v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
			v.Massless = false
			v.Velocity = Vector3.zero
		elseif v:IsA("BodyAngularVelocity") then
			v:Destroy()
		end
	end
end)

addcmd('togglefling',{},function(args, speaker)
	if flinging then
		execCmd('unfling')
	else
		execCmd('fling')
	end
end)

addcmd("flyfling", {}, function(args, speaker)
	execCmd("unvehiclefly\\unwalkfling")
	task.wait()
	vehicleflyspeed = tonumber(args[1]) or vehicleflyspeed
	execCmd("vehiclefly\\walkfling")
end)

addcmd("unflyfling", {}, function(args, speaker)
	execCmd("unvehiclefly\\unwalkfling\\breakvelocity")
end)

addcmd("toggleflyfling", {}, function(args, speaker)
	execCmd(flinging and "unflyfling" or "flyfling")
end)

walkflinging = false
addcmd("walkfling", {}, function(args, speaker)
	execCmd("unwalkfling")
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			execCmd("unwalkfling")
		end)
	end

	execCmd("noclip nonotify")
	walkflinging = true
	repeat RunService.Heartbeat:Wait()
		local character = speaker.Character
		local root = getRoot(character)
		local vel, movel = nil, 0.1

		while not (character and character.Parent and root and root.Parent) do
			RunService.Heartbeat:Wait()
			character = speaker.Character
			root = getRoot(character)
		end

		vel = root.Velocity
		root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

		RunService.RenderStepped:Wait()
		if character and character.Parent and root and root.Parent then
			root.Velocity = vel
		end

		RunService.Stepped:Wait()
		if character and character.Parent and root and root.Parent then
			root.Velocity = vel + Vector3.new(0, movel, 0)
			movel = movel * -1
		end
	until walkflinging == false
end)

addcmd("unwalkfling", {"nowalkfling"}, function(args, speaker)
	walkflinging = false
	execCmd("unnoclip nonotify")
end)

addcmd("togglewalkfling", {}, function(args, speaker)
	execCmd(walkflinging and "unwalkfling" or "walkfling")
end)

addcmd('invisfling',{},function(args, speaker)
	local ch = speaker.Character
	ch:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	local prt=Instance.new("Model")
	prt.Parent = speaker.Character
	local z1 = Instance.new("Part")
	z1.Name="Torso"
	z1.CanCollide = false
	z1.Anchored = true
	local z2 = Instance.new("Part")
	z2.Name="Head"
	z2.Parent = prt
	z2.Anchored = true
	z2.CanCollide = false
	local z3 =Instance.new("Humanoid")
	z3.Name="Humanoid"
	z3.Parent = prt
	z1.Position = Vector3.new(0,9999,0)
	speaker.Character=prt
	wait(3)
	speaker.Character=ch
	wait(3)
	local Hum = Instance.new("Humanoid")
	z2:Clone()
	Hum.Parent = speaker.Character
	local root =  getRoot(speaker.Character)
	for i,v in pairs(speaker.Character:GetChildren()) do
		if v ~= root and  v.Name ~= "Humanoid" then
			v:Destroy()
		end
	end
	root.Transparency = 0
	root.Color = Color3.new(1, 1, 1)
	local invisflingStepped
	invisflingStepped = RunService.Stepped:Connect(function()
		if speaker.Character and getRoot(speaker.Character) then
			getRoot(speaker.Character).CanCollide = false
		else
			invisflingStepped:Disconnect()
		end
	end)
	sFLY()
	workspace.CurrentCamera.CameraSubject = root
	local bambam = Instance.new("BodyThrust")
	bambam.Parent = getRoot(speaker.Character)
	bambam.Force = Vector3.new(99999,99999*10,99999)
	bambam.Location = getRoot(speaker.Character).Position
end)

local antiflingOriginalCollisions = {}
local function stopAntiFlingModule()
	if antifling then
		antifling:Disconnect()
		antifling = nil
	end
	for part, canCollide in pairs(antiflingOriginalCollisions) do
		if part.Parent then
			part.CanCollide = canCollide
		end
	end
	antiflingOriginalCollisions = {}
end

addcmd("antifling", {}, function(args, speaker)
	stopAntiFlingModule()
	antifling = RunService.Stepped:Connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= speaker and player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						if antiflingOriginalCollisions[v] == nil then
							antiflingOriginalCollisions[v] = v.CanCollide
						end
						v.CanCollide = false
					end
				end
			end
		end
	end)
end)

addcmd("unantifling", {}, function(args, speaker)
	stopAntiFlingModule()
end)

addcmd("toggleantifling", {}, function(args, speaker)
	execCmd(antifling and "unantifling" or "antifling")
end)

function attach(speaker,target)
	if tools(speaker) then
		local char = speaker.Character
		local tchar = target.Character
		local hum = speaker.Character:FindFirstChildOfClass("Humanoid")
		local hrp = getRoot(speaker.Character)
		local hrp2 = getRoot(target.Character)
		hum.Name = "1"
		local newHum = hum:Clone()
		newHum.Parent = char
		newHum.Name = "Humanoid"
		wait()
		hum:Destroy()
		workspace.CurrentCamera.CameraSubject = char
		newHum.DisplayDistanceType = "None"
		local tool = speaker:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or speaker.Character:FindFirstChildOfClass("Tool")
		tool.Parent = char
		hrp.CFrame = hrp2.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-100, 100)/200,math.random(-100, 100)/200,math.random(-100, 100)/200)
		local n = 0
		repeat
			wait(.1)
			n = n + 1
			hrp.CFrame = hrp2.CFrame
		until (tool.Parent ~= char or not hrp or not hrp2 or not hrp.Parent or not hrp2.Parent or n > 250) and n > 2
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function kill(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = CFrame.new(999999, workspace.FallenPartsDestroyHeight + 5,999999)
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd("handlekill", {"hkill"}, function(args, speaker)
	if not firetouchinterest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
	end
	if not speaker.Character then return end
	local tool = speaker.Character:FindFirstChildWhichIsA("Tool")
	local handle = tool and tool:FindFirstChild("Handle")
	if not handle then
		return notify("Handle Kill", "You need to hold a \"Tool\" that does damage on touch. For example a common Sword tool.")
	end
	local range = tonumber(args[2]) or math.huge
	if range ~= math.huge then notify("Handle Kill", ("Started!\nRadius: %s"):format(tostring(range):upper())) end

	while task.wait() and speaker.Character and tool.Parent and tool.Parent == speaker.Character do
		for _, plr in next, getPlayer(args[1], speaker) do
			plr = Players[plr]
			if plr ~= speaker and plr.Character then
				local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
				local root = hum and getRoot(plr.Character)

				if root and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead and speaker:DistanceFromCharacter(root.Position) <= range then
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
				end
			end
		end
	end

	notify("Handle Kill", "Stopped!")
end)

tpwalkStack = 0
addcmd("teleportwalk", {"tpwalk"}, function(args, speaker)
    pcall(function() tpwalking:Disconnect() end)

    local character = speaker.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local speed = (args[1] and isNumber(args[1])) and tonumber(args[1]) or 1

    if parseBoolean(args[2]) then
        tpwalkStack = tpwalkStack + speed
    end

    tpwalking = RunService.Heartbeat:Connect(function(delta)
        if not (character and humanoid and humanoid.Parent) then
            tpwalking:Disconnect()
            return
        end

        if humanoid.MoveDirection.Magnitude > 0 then
            character:TranslateBy(humanoid.MoveDirection * (speed + tpwalkStack) * delta * 10)
        end
    end)
end)

addcmd("unteleportwalk", {"untpwalk"}, function(args, speaker)
    tpwalkStack = 0
    tpwalking:Disconnect()
end)

function bring(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = NormPos
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function teleport(speaker,target,target2,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			local hrp2 = getRoot(target2.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = hrp2.CFrame
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			wait(1)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd('spin',{},function(args, speaker)
	local spinSpeed = 20
	if args[1] and isNumber(args[1]) then
		spinSpeed = args[1]
	end
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
	local Spin = Instance.new("BodyAngularVelocity")
	Spin.Name = "Spinning"
	Spin.Parent = getRoot(speaker.Character)
	Spin.MaxTorque = Vector3.new(0, math.huge, 0)
	Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
end)

addcmd('unspin',{},function(args, speaker)
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
end)

xrayEnabled = false
function xray()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
			v.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
		end
	end
end

addcmd("xray", {}, function(args, speaker)
	xrayEnabled = true
	xray()
end)

addcmd("unxray", {"noxray"}, function(args, speaker)
	xrayEnabled = false
	xray()
end)

addcmd("togglexray", {}, function(args, speaker)
	xrayEnabled = not xrayEnabled
	xray()
end)

addcmd("loopxray", {}, function(args, speaker)
	pcall(function() xrayLoop:Disconnect() end)
	xrayLoop = RunService.RenderStepped:Connect(function()
		xrayEnabled = true
		xray()
	end)
end)

addcmd("unloopxray", {}, function(args, speaker)
	pcall(function() xrayLoop:Disconnect() end)
	xrayEnabled = false
	xray()
end)

local walltpTouch = nil
addcmd('walltp',{},function(args, speaker)
	local torso
	if r15(speaker) then
		torso = speaker.Character.UpperTorso
	else
		torso = speaker.Character.Torso
	end
	local function touchedFunc(hit)
		local Root = getRoot(speaker.Character)
		if hit:IsA("BasePart") and hit.Position.Y > Root.Position.Y - speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight then
			local hitP = getRoot(hit.Parent)
			if hitP ~= nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hitP.Size.Z/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			elseif hitP == nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hit.Size.Y/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			end
		end
	end
	walltpTouch = torso.Touched:Connect(touchedFunc)
end)

addcmd('unwalltp',{'nowalltp'},function(args, speaker)
	if walltpTouch then
		walltpTouch:Disconnect()
	end
end)

autoclicking = false
addcmd('autoclick',{},function(args, speaker)
	if mouse1press and mouse1release then
		execCmd('unautoclick')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[1] and isNumber(args[1]) then clickDelay = args[1] end
		if args[2] and isNumber(args[2]) then releaseDelay = args[2] end
		autoclicking = true
		cancelAutoClick = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoclicking = false
					cancelAutoClick:Disconnect()
				end
			end
		end)
		notify('Auto Clicker',"Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			mouse1press()
			wait(releaseDelay)
			mouse1release()
		until autoclicking == false
	else
		notify('Auto Clicker',"Your exploit doesn't have the ability to use the autoclick")
	end
end)

addcmd('unautoclick',{'noautoclick'},function(args, speaker)
	autoclicking = false
	if cancelAutoClick then cancelAutoClick:Disconnect() end
end)

addcmd('mousesensitivity',{'ms'},function(args, speaker)
	UserInputService.MouseDeltaSensitivity = args[1]
end)

local nameBox = nil
local nbSelection = nil
addcmd('hovername',{},function(args, speaker)
	execCmd('unhovername')
	wait()
	nameBox = Instance.new("TextLabel")
	nameBox.Name = randomString()
	nameBox.Parent = ScaledHolder
	nameBox.BackgroundTransparency = 1
	nameBox.Size = UDim2.new(0,200,0,30)
	nameBox.Font = Enum.Font.Code
	nameBox.TextSize = 16
	nameBox.Text = ""
	nameBox.TextColor3 = Color3.new(1, 1, 1)
	nameBox.TextStrokeTransparency = 0
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.ZIndex = 10
	nbSelection = Instance.new('SelectionBox')
	nbSelection.Name = randomString()
	nbSelection.LineThickness = 0.03
	nbSelection.Color3 = Color3.new(1, 1, 1)
	local function updateNameBox()
		local t
		local target = IYMouse.Target

		if target then
			local humanoid = target.Parent:FindFirstChildOfClass("Humanoid") or target.Parent.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				t = humanoid.Parent
			end
		end

		if t ~= nil then
			local x = IYMouse.X
			local y = IYMouse.Y
			local xP
			local yP
			if IYMouse.X > 200 then
				xP = x - 205
				nameBox.TextXAlignment = Enum.TextXAlignment.Right
			else
				xP = x + 25
				nameBox.TextXAlignment = Enum.TextXAlignment.Left
			end
			nameBox.Position = UDim2.new(0, xP, 0, y)
			nameBox.Text = t.Name
			nameBox.Visible = true
			nbSelection.Parent = t
			nbSelection.Adornee = t
		else
			nameBox.Visible = false
			nbSelection.Parent = nil
			nbSelection.Adornee = nil
		end
	end
	nbUpdateFunc = IYMouse.Move:Connect(updateNameBox)
end)

addcmd('unhovername',{'nohovername'},function(args, speaker)
	if nbUpdateFunc then
		nbUpdateFunc:Disconnect()
		nameBox:Destroy()
		nbSelection:Destroy()
	end
end)

addcmd('headsize',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v] ~= speaker and Players[v].Character:FindFirstChild('Head') then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Head = Players[v].Character:FindFirstChild('Head')
			if Head:IsA("BasePart") then
				Head.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Head.Size = Vector3.new(2,1,1)
				else
					Head.Size = Size
				end
			end
		end
	end
end)

addcmd('hitbox',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local transparency = args[3] and tonumber(args[3]) or 0.4
	for i,v in pairs(players) do
		if Players[v] ~= speaker and getRoot(Players[v].Character) then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Root = getRoot(Players[v].Character)
			if Root:IsA("BasePart") then
				Root.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Root.Size = Vector3.new(2,1,1)
					Root.Transparency = transparency
				else
					Root.Size = Size
					Root.Transparency = transparency
				end
			end
		end
	end
end)

addcmd("hitboxes", {}, function(args, speaker)
    settings():GetService("RenderSettings").ShowBoundingBoxes = true
end)

addcmd("unhitboxes", {}, function(args, speaker)
    settings():GetService("RenderSettings").ShowBoundingBoxes = false
end)

addcmd('stareat',{'stare'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if stareLoop then
			stareLoop:Disconnect()
		end
		if not getRoot(Players.LocalPlayer.Character) and getRoot(Players[v].Character) then return end
		local function stareFunc()
			if Players.LocalPlayer.Character.PrimaryPart and Players:FindFirstChild(v) and Players[v].Character ~= nil and getRoot(Players[v].Character) then
				local chrPos=Players.LocalPlayer.Character.PrimaryPart.Position
				local tPos=getRoot(Players[v].Character).Position
				local modTPos=Vector3.new(tPos.X,chrPos.Y,tPos.Z)
				local newCF=CFrame.new(chrPos,modTPos)
				Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCF)
			elseif not Players:FindFirstChild(v) then
				stareLoop:Disconnect()
			end
		end

		stareLoop = RunService.RenderStepped:Connect(stareFunc)
	end
end)

addcmd('unstareat',{'unstare','nostare','nostareat'},function(args, speaker)
	if stareLoop then
		stareLoop:Disconnect()
	end
end)

RolewatchData = {Group = 0, Role = "", Leave = false}
RolewatchConnection = Players.PlayerAdded:Connect(function(player)
	if RolewatchData.Group == 0 then return end
	if player:IsInGroup(RolewatchData.Group) then
		if tostring(player:GetRoleInGroup(RolewatchData.Group)):lower() == RolewatchData.Role:lower() then
			if RolewatchData.Leave == true then
				Players.LocalPlayer:Kick("\n\nRolewatch\nPlayer \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"\n")
			else
				notify("Rolewatch", "Player \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"")
			end
		end
	end
end)

addcmd("rolewatch", {}, function(args, speaker)
	local groupId = tonumber(args[1] or 0)
	local roleName = args[2] and tostring(getstring(2, args))
	if groupId and roleName then
		RolewatchData.Group = groupId
		RolewatchData.Role = roleName
		notify("Rolewatch", "Watching Group ID \"" .. tostring(groupId) .. "\" for Role \"" .. roleName .. "\"")
	end
end)

addcmd("rolewatchstop", {}, function(args, speaker)
	RolewatchData.Group = 0
	RolewatchData.Role = ""
	RolewatchData.Leave = false
	notify("Rolewatch", "Disabled")
end)

addcmd("rolewatchleave", {"unrolewatch"}, function(args, speaker)
	RolewatchData.Leave = not RolewatchData.Leave
	notify("Rolewatch", RolewatchData.Leave and "Leave has been Enabled" or "Leave has been Disabled")
end)

staffRoles = {"mod", "admin", "staff", "dev", "founder", "owner", "supervis", "manager", "management", "executive", "president", "chairman", "chairwoman", "chairperson", "director"}

getStaffRole = function(player)
	local playerRole = player:GetRoleInGroup(game.CreatorId)
	local result = {Role = playerRole, Staff = false}
	if player:IsInGroup(1200769) then
		result.Role = "Roblox Employee"
		result.Staff = true
	end
	for _, role in pairs(staffRoles) do
		if string.find(string.lower(playerRole), role) then
			result.Staff = true
		end
	end
	return result
end

addcmd("staffwatch", {}, function(args, speaker)
	if staffwatchjoin then
		staffwatchjoin:Disconnect()
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local found = {}
		staffwatchjoin = Players.PlayerAdded:Connect(function(player)
			local result = getStaffRole(player)
			if result.Staff then
				notify("Staffwatch", formatUsername(player) .. " is a " .. result.Role)
			end
		end)
		for _, player in pairs(Players:GetPlayers()) do
			local result = getStaffRole(player)
			if result.Staff then
				table.insert(found, formatUsername(player) .. " is a " .. result.Role)
			end
		end
		if #found > 0 then
			notify("Staffwatch", table.concat(found, ",\n"))
		else
			notify("Staffwatch", "Enabled")
		end
	else
		notify("Staffwatch", "Game is not owned by a Group")
	end
end)

addcmd("unstaffwatch", {}, function(args, speaker)
	if staffwatchjoin then
		staffwatchjoin:Disconnect()
	end
	notify("Staffwatch", "Disabled")
end)

local function playerGroups()
    local players = Players:GetPlayers()
    local graph = {}
    local seen = {}
    local groups = {}

    for _, p in ipairs(players) do
        graph[p] = {}
    end

    for i = 1, #players do
        for j = i + 1, #players do
            local p1 = players[i]
            local p2 = players[j]

            local success, result = pcall(function()
                return p1:IsFriendsWithAsync(p2.UserId)
            end)

            if success and result then
                table.insert(graph[p1], p2)
                table.insert(graph[p2], p1)
            end
        end
    end

    local function dfs(player, group)
        seen[player] = true
        table.insert(group, player)

        for _, possible in ipairs(graph[player]) do
            if not seen[possible] then
                dfs(possible, group)
            end
        end
    end

    for _, p in ipairs(players) do
        if not seen[p] then
            local group = {}
            dfs(p, group)
            table.insert(groups, group)
        end
    end

    return groups
end

addcmd("findfriendgroups", {}, function(args, speaker)
    notify("Checking Players", "This might take a while (slow function)")

    local groups = playerGroups()
    local playerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)

    local result = ""
    local index = 1
    local found = 0

    for _, group in ipairs(groups) do
        if #group == 1 then continue end
        local names = {}
        for _, player in ipairs(group) do
            table.insert(names, playerList and player.DisplayName or player.Name)
        end
        result = result .. index .. ". " .. table.concat(names, ", ") .. "\n"
        index = index + 1
        found = found + 1
    end

    createPopup("Friend Groups", found == 0 and "None" or result)
end)

addcmd('removeterrain',{'rterrain','noterrain'},function(args, speaker)
	workspace:FindFirstChildOfClass('Terrain'):Clear()
end)

addcmd('clearnilinstances',{'nonilinstances','cni'},function(args, speaker)
	if getnilinstances then
		for i,v in pairs(getnilinstances()) do
			v:Destroy()
		end
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing getnilinstances)')
	end
end)

addcmd('destroyheight',{'dh'},function(args, speaker)
	local dh = args[1] or -500
	if isNumber(dh) then
		workspace.FallenPartsDestroyHeight = dh
	end
end)

OrgDestroyHeight = workspace.FallenPartsDestroyHeight
addcmd("antivoid", {}, function(args, speaker)
	execCmd("unantivoid nonotify")
	task.wait()
	antivoidloop = RunService.Stepped:Connect(function()
		local root = getRoot(speaker.Character)
		if root and root.Position.Y <= OrgDestroyHeight + 25 then
			root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
		end
	end)
	if args[1] ~= "nonotify" then notify("antivoid", "Enabled") end
end)

addcmd("unantivoid", {"noantivoid"}, function(args, speaker)
	pcall(function() antivoidloop:Disconnect() end)
	antivoidloop = nil
	if args[1] ~= "nonotify" then notify("antivoid", "Disabled") end
end)

antivoidWasEnabled = false
addcmd("fakeout", {}, function(args, speaker)
	local root = getRoot(speaker.Character)
	local oldpos = root.CFrame
	if antivoidloop then
		execCmd("unantivoid nonotify")
		antivoidWasEnabled = true
	end
	workspace.FallenPartsDestroyHeight = 0/1/0
	root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 25, 0))
	task.wait(1)
	root.CFrame = oldpos
	workspace.FallenPartsDestroyHeight = OrgDestroyHeight
	if antivoidWasEnabled then
		execCmd("antivoid nonotify")
		antivoidWasEnabled = false
	end
end)

addcmd("trip", {}, function(args, speaker)
	local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local root = speaker.Character and getRoot(speaker.Character)
	if humanoid and root then
		humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		root.Velocity = root.CFrame.LookVector * 30
	end
end)

addcmd("removeads", {"adblock"}, function(args, speaker)
	while wait() do
		pcall(function()
			for i, v in pairs(workspace:GetDescendants()) do
				if v:IsA("PackageLink") then
					if v.Parent:FindFirstChild("ADpart") then
						v.Parent:Destroy()
					end
					if v.Parent:FindFirstChild("AdGuiAdornee") then
						v.Parent.Parent:Destroy()
					end
				end
			end
		end)
	end
end)

addcmd("scare", {"spook"}, function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local oldpos = nil

	for _, v in pairs(players) do
		local root = speaker.Character and getRoot(speaker.Character)
		local target = Players[v]
		local targetRoot = target and target.Character and getRoot(target.Character)

		if root and targetRoot and target ~= speaker then
			oldpos = root.CFrame
			root.CFrame = targetRoot.CFrame + targetRoot.CFrame.lookVector * 2
			root.CFrame = CFrame.new(root.Position, targetRoot.Position)
			task.wait(0.5)
			root.CFrame = oldpos
		end
	end
end)

addcmd("alignmentkeys", {}, function(args, speaker)
	alignmentKeys = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Comma then workspace.CurrentCamera:PanUnits(-1) end
		if input.KeyCode == Enum.KeyCode.Period then workspace.CurrentCamera:PanUnits(1) end
	end)
	alignmentKeysEmotes = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

addcmd("unalignmentkeys", {"noalignmentkeys"}, function(args, speaker)
	if type(alignmentKeysEmotes) == "boolean" then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, alignmentKeysEmotes)
	end
	alignmentKeys:Disconnect()
end)

addcmd("ctrllock", {}, function(args, speaker)
	local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

	if boundKeys then
		boundKeys.Value = "LeftControl"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftControl"
		boundKeys.Parent = mouseLockController
	end
end)

addcmd("unctrllock", {}, function(args, speaker)
	local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

	if boundKeys then
		boundKeys.Value = "LeftShift"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftShift"
		boundKeys.Parent = mouseLockController
	end
end)

addcmd("listento", {}, function(args, speaker)
	execCmd("unlistento")
	if not args[1] then return end

	local player = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
	local root = player and player.Character and getRoot(player.Character)

	if root then
		SoundService:SetListener(Enum.ListenerType.ObjectPosition, root)
		listentoChar = player.CharacterAdded:Connect(function()
			repeat task.wait() until Players[player.Name].Character ~= nil and getRoot(Players[player.Name].Character)
			SoundService:SetListener(Enum.ListenerType.ObjectPosition, getRoot(Players[player.Name].Character))
		end)
	end
end)

addcmd("unlistento", {}, function(args, speaker)
	SoundService:SetListener(Enum.ListenerType.Camera)
	listentoChar:Disconnect()
end)

addcmd("jerk", {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local backpack = speaker:FindFirstChildWhichIsA("Backpack")
	if not humanoid or not backpack then return end

	local tool = Instance.new("Tool")
	tool.Name = "Jerk Off"
	tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
	tool.RequiresHandle = false
	tool.Parent = backpack

	local jorkin = false
	local track = nil

	local function stopTomfoolery()
		jorkin = false
		if track then
			track:Stop()
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	humanoid.Died:Connect(stopTomfoolery)

	while task.wait() do
		if not jorkin then continue end

		local isR15 = r15(speaker)
		if not track then
			local anim = Instance.new("Animation")
			anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
			track = humanoid:LoadAnimation(anim)
		end

		track:Play()
		track:AdjustSpeed(isR15 and 0.7 or 0.65)
		track.TimePosition = 0.6
		task.wait(0.1)
		while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
		if track then
			track:Stop()
			track = nil
		end
	end
end)

addcmd("guiscale", {}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		local scale = tonumber(args[1])
		if scale % 1 == 0 then scale = scale / 100 end
		-- me when i divide and it explodes
		if scale == 0.01 then scale = 1 end
		if scale == 0.02 then scale = 2 end

		if scale >= 0.4 and scale <= 2 then
			guiScale = scale
		end
	else
		guiScale = defaultGuiScale
	end

	Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale)
	updatesaves()
end)

addcmd("muteallvoices", {"muteallvcs"}, function(args, speaker)
	Services.VoiceChatInternal:SubscribePauseAll(true)
end)

addcmd("unmuteallvoices", {"unmuteallvcs"}, function(args, speaker)
	Services.VoiceChatInternal:SubscribePauseAll(false)
end)

addcmd("mutevc", {}, function(args, speaker)
	for _, plr in getPlayer(args[1], speaker) do
		if Players[plr] == speaker then continue end
		Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, true)
	end
end)

addcmd("unmutevc", {}, function(args, speaker)
	for _, plr in getPlayer(args[1], speaker) do
		if Players[plr] == speaker then continue end
		Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, false)
	end
end)

addcmd("phonebook", {"call"}, function(args, speaker)
	local success, canInvite = pcall(function()
		return SocialService:CanSendCallInviteAsync(speaker)
	end)
	if success and canInvite then
		SocialService:PromptPhoneBook(speaker, "")
	else
		notify("Phonebook", "It seems you're not able to call anyone. Sorry!")
	end
end)

local freezingua = nil
frozenParts = {}
addcmd('freezeunanchored',{'freezeua'},function(args, speaker)
	local badnames = {
		"Head",
		"UpperTorso",
		"LowerTorso",
		"RightUpperArm",
		"LeftUpperArm",
		"RightLowerArm",
		"LeftLowerArm",
		"RightHand",
		"LeftHand",
		"RightUpperLeg",
		"LeftUpperLeg",
		"RightLowerLeg",
		"LeftLowerLeg",
		"RightFoot",
		"LeftFoot",
		"Torso",
		"Right Arm",
		"Left Arm",
		"Right Leg",
		"Left Leg",
		"HumanoidRootPart"
	}
	local function FREEZENOOB(v)
		if v:IsA("BasePart" or "UnionOperation") and v.Anchored == false then
			local BADD = false
			for i = 1,#badnames do
				if v.Name == badnames[i] then
					BADD = true
				end
			end
			if speaker.Character and v:IsDescendantOf(speaker.Character) then
				BADD = true
			end
			if BADD == false then
				for i,c in pairs(v:GetChildren()) do
					if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
						c:Destroy()
					end
				end
				local bodypos = Instance.new("BodyPosition")
				bodypos.Parent = v
				bodypos.Position = v.Position
				bodypos.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
				local bodygyro = Instance.new("BodyGyro")
				bodygyro.Parent = v
				bodygyro.CFrame = v.CFrame
				bodygyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
				if not table.find(frozenParts,v) then
					table.insert(frozenParts,v)
				end
			end
		end
	end
	for i,v in pairs(workspace:GetDescendants()) do
		FREEZENOOB(v)
	end
	freezingua = workspace.DescendantAdded:Connect(FREEZENOOB)
end)

addcmd('thawunanchored',{'thawua','unfreezeunanchored','unfreezeua'},function(args, speaker)
	if freezingua then
		freezingua:Disconnect()
	end
	for i,v in pairs(frozenParts) do
		for i,c in pairs(v:GetChildren()) do
			if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
				c:Destroy()
			end
		end
	end
	frozenParts = {}
end)

addcmd('tpunanchored',{'tpua'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local Forces = {}
		for _,part in pairs(workspace:GetDescendants()) do
			if Players[v].Character:FindFirstChild('Head') and part:IsA("BasePart" or "UnionOperation" or "Model") and part.Anchored == false and not part:IsDescendantOf(speaker.Character) and part.Name == "Torso" == false and part.Name == "Head" == false and part.Name == "Right Arm" == false and part.Name == "Left Arm" == false and part.Name == "Right Leg" == false and part.Name == "Left Leg" == false and part.Name == "HumanoidRootPart" == false then
				for i,c in pairs(part:GetChildren()) do
					if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
						c:Destroy()
					end
				end
				local ForceInstance = Instance.new("BodyPosition")
				ForceInstance.Parent = part
				ForceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				table.insert(Forces, ForceInstance)
				if not table.find(frozenParts,part) then
					table.insert(frozenParts,part)
				end
			end
		end
		for i,c in pairs(Forces) do
			c.Position = Players[v].Character.Head.Position
		end
	end
end)

keycodeMap = {
	["0"] = 0x30,
	["1"] = 0x31,
	["2"] = 0x32,
	["3"] = 0x33,
	["4"] = 0x34,
	["5"] = 0x35,
	["6"] = 0x36,
	["7"] = 0x37,
	["8"] = 0x38,
	["9"] = 0x39,
	["a"] = 0x41,
	["b"] = 0x42,
	["c"] = 0x43,
	["d"] = 0x44,
	["e"] = 0x45,
	["f"] = 0x46,
	["g"] = 0x47,
	["h"] = 0x48,
	["i"] = 0x49,
	["j"] = 0x4A,
	["k"] = 0x4B,
	["l"] = 0x4C,
	["m"] = 0x4D,
	["n"] = 0x4E,
	["o"] = 0x4F,
	["p"] = 0x50,
	["q"] = 0x51,
	["r"] = 0x52,
	["s"] = 0x53,
	["t"] = 0x54,
	["u"] = 0x55,
	["v"] = 0x56,
	["w"] = 0x57,
	["x"] = 0x58,
	["y"] = 0x59,
	["z"] = 0x5A,
	["enter"] = 0x0D,
	["shift"] = 0x10,
	["ctrl"] = 0x11,
	["alt"] = 0x12,
	["pause"] = 0x13,
	["capslock"] = 0x14,
	["spacebar"] = 0x20,
	["space"] = 0x20,
	["pageup"] = 0x21,
	["pagedown"] = 0x22,
	["end"] = 0x23,
	["home"] = 0x24,
	["left"] = 0x25,
	["up"] = 0x26,
	["right"] = 0x27,
	["down"] = 0x28,
	["insert"] = 0x2D,
	["delete"] = 0x2E,
	["f1"] = 0x70,
	["f2"] = 0x71,
	["f3"] = 0x72,
	["f4"] = 0x73,
	["f5"] = 0x74,
	["f6"] = 0x75,
	["f7"] = 0x76,
	["f8"] = 0x77,
	["f9"] = 0x78,
	["f10"] = 0x79,
	["f11"] = 0x7A,
	["f12"] = 0x7B,
}
autoKeyPressing = false
cancelAutoKeyPress = nil

addcmd('autokeypress',{'keypress'},function(args, speaker)
	if keypress and keyrelease and args[1] then
		local code = keycodeMap[args[1]:lower()]
		if not code then notify('Auto Key Press',"Invalid key") return end
		execCmd('unautokeypress')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[2] and isNumber(args[2]) then clickDelay = args[2] end
		if args[3] and isNumber(args[3]) then releaseDelay = args[3] end
		autoKeyPressing = true
		cancelAutoKeyPress = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoKeyPressing = false
					cancelAutoKeyPress:Disconnect()
				end
			end
		end)
		notify('Auto Key Press',"Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			keypress(code)
			wait(releaseDelay)
			keyrelease(code)
		until autoKeyPressing == false
		if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() keyrelease(code) end
	else
		notify('Auto Key Press',"Your exploit doesn't have the ability to use auto key press")
	end
end)

addcmd('unautokeypress',{'noautokeypress','unkeypress','nokeypress'},function(args, speaker)
	autoKeyPressing = false
	if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() end
end)

addcmd('addplugin',{'plugin'},function(args, speaker)
	addPlugin(getstring(1, args))
end)

addcmd('removeplugin',{'deleteplugin'},function(args, speaker)
	deletePlugin(getstring(1, args))
end)

addcmd('reloadplugin',{},function(args, speaker)
	local pluginName = getstring(1, args)
	deletePlugin(pluginName)
	wait(1)
	addPlugin(pluginName)
end)

addcmd("addallplugins", {"loadallplugins"}, function(args, speaker)
	if not listfiles or not isfolder then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing listfiles/isfolder)")
		return
	end

	for _, filePath in ipairs(listfiles("")) do
		local fileName = filePath:match("([^/\\]+%.iy)$")

		if fileName and
			fileName:lower() ~= "iy_fe.iy" and
			not isfolder(fileName) and
			not table.find(PluginsTable, fileName)
		then
			addPlugin(fileName)
		end
	end
end)

addcmd('removecmd',{'deletecmd'},function(args, speaker)
	removecmd(args[1])
end)

addcmd("debug", {}, function(args, speaker)
    _G.IY_DEBUG = parseBoolean(args[1], true)
    return _G.IY_DEBUG and "Enabled" or "Disabled"
end)

if IsOnMobile then
	local QuickCapture = Instance.new("TextButton")
	local UICorner = Instance.new("UICorner")
	QuickCapture.Name = randomString()
	QuickCapture.Parent = PARENT
	QuickCapture.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	QuickCapture.BackgroundTransparency = 0.14
	QuickCapture.Position = UDim2.new(0.489, 0, 0, 0)
	QuickCapture.Size = UDim2.new(0, 32, 0, 33)
	QuickCapture.Font = Enum.Font.SourceSansBold
	QuickCapture.Text = "IY"
	QuickCapture.TextColor3 = Color3.fromRGB(255, 255, 255)
	QuickCapture.TextSize = 20
	QuickCapture.TextWrapped = true
	QuickCapture.ZIndex = 10
	QuickCapture.Draggable = true
	UICorner.Name = randomString()
	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = QuickCapture
	QuickCapture.MouseButton1Click:Connect(function()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end)
	table.insert(shade1, QuickCapture)
	table.insert(text1, QuickCapture)
end

pcall(function() Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale) end)
Scale.Parent = ScaledHolder
ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
Scale:GetPropertyChangedSignal("Scale"):Connect(function()
	ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
	for _, v in ScaledHolder:GetDescendants() do
		if v:IsA("GuiObject") and v.Visible then
			v.Visible = false
			v.Visible = true
		end
	end
end)

updateColors(currentShade1,shade1)
updateColors(currentShade2,shade2)
updateColors(currentShade3,shade3)
updateColors(currentText1,text1)
updateColors(currentText2,text2)
updateColors(currentScroll,scroll)

if PluginsTable ~= nil or PluginsTable ~= {} then
	FindPlugins(PluginsTable)
end

-- Events
eventEditor.RegisterEvent("OnExecute")
eventEditor.RegisterEvent("OnSpawn",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDied",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDamage",{
	{Type="Player",Name="Player Filter ($1)"},
	{Type="Number",Name="Below Health ($2)"}
})
eventEditor.RegisterEvent("OnKilled",{
	{Type="Player",Name="Victim Player ($1)"},
	{Type="Player",Name="Killer Player ($2)",Default = 1}
})
eventEditor.RegisterEvent("OnJoin",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnLeave",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnChatted",{
	{Type="Player",Name="Player Filter ($1)",Default = 1},
	{Type="String",Name="Message Filter ($2)"}
})

function hookCharEvents(plr, instant)
	task.spawn(function()
		local char = plr.Character
		if not char then return end

		local humanoid = char:WaitForChild("Humanoid", 10)
		if not humanoid or not humanoid:IsA("Humanoid") then return end

		local oldHealth = humanoid.Health
		humanoid.HealthChanged:Connect(function(health)
			local change = math.abs(oldHealth - health)
			if oldHealth > health then
				eventEditor.FireEvent("OnDamage", plr.Name, tonumber(health))
			end
			oldHealth = health
		end)

		humanoid.Died:Connect(function()
			eventEditor.FireEvent("OnDied", plr.Name)

			local killedBy = humanoid:FindFirstChild("creator")
			if killedBy and killedBy:IsA("ObjectValue") and killedBy.Value and killedBy.Value.Parent then
				eventEditor.FireEvent("OnKilled", plr.Name, killedBy.Name)
			end
		end)
	end)
end

Players.PlayerAdded:Connect(function(plr)
	eventEditor.FireEvent("OnJoin",plr.Name)
	if isLegacyChat then plr.Chatted:Connect(function(msg) eventEditor.FireEvent("OnChatted",tostring(plr),msg) end) end
	plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn",tostring(plr)) hookCharEvents(plr) end)
	JoinLog(plr)
	if isLegacyChat then ChatLog(plr) end
	if ESPenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		ESP(plr)
	end
	if CHMSenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		CHMS(plr)
	end
end)

if not isLegacyChat then
	TextChatService.MessageReceived:Connect(function(textChatMessage)
		if textChatMessage.TextSource and textChatMessage.Status ~= Enum.TextChatMessageStatus.InvalidTextChannelPermissions then
			local player = Players:GetPlayerByUserId(textChatMessage.TextSource.UserId)
			if not player then return end

            local message = textChatMessage.Text
            pcall(function() if textChatMessage.WasRewritten == true then message = "(rephrased) " .. textChatMessage.RewrittenText end end)

			if logsEnabled == true then
				CreateLabel(player.Name, message)
			end
			if player.UserId == Players.LocalPlayer.UserId then
				do_exec(message, Players.LocalPlayer)
			end
			eventEditor.FireEvent("OnChatted", player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

for _, plr in pairs(Players:GetPlayers()) do
	pcall(function()
		plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn", tostring(plr)) hookCharEvents(plr) end)
		hookCharEvents(plr)
	end)
end

if spawnCmds and #spawnCmds > 0 then
	for i,v in pairs(spawnCmds) do
		eventEditor.AddCmd("OnSpawn",{v.COMMAND or "",{0},v.DELAY or 0})
	end
	updatesaves()
end

if loadedEventData then eventEditor.LoadData(loadedEventData) end
eventEditor.Refresh()

eventEditor.FireEvent("OnExecute")

if aliases and #aliases > 0 then
	local cmdMap = {}
	for i,v in pairs(cmds) do
		cmdMap[v.NAME:lower()] = v
		for _,alias in pairs(v.ALIAS) do
			cmdMap[alias:lower()] = v
		end
	end
	for i = 1, #aliases do
		local cmd = string.lower(aliases[i].CMD)
		local alias = string.lower(aliases[i].ALIAS)
		if cmdMap[cmd] then
			customAlias[alias] = cmdMap[cmd]
		end
	end
	refreshaliases()
end

IYMouse.Move:Connect(checkTT)

CaptureService.CaptureBegan:Connect(function()
	PARENT.Enabled = false
end)

CaptureService.CaptureEnded:Connect(function()
	task.delay(0.1, function()
		PARENT.Enabled = true
	end)
end)

task.spawn(function()
	local success, latestVersionInfo = pcall(function() 
		local versionJson = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/version")
		return HttpService:JSONDecode(versionJson)
	end)

	if success then
		if currentVersion ~= latestVersionInfo.Version then
			notify("Outdated", "Get the new version at infyiff.github.io")
		end

		if latestVersionInfo.Announcement and latestVersionInfo.Announcement ~= "" then
			local AnnGUI = Instance.new("Frame")
			local background = Instance.new("Frame")
			local TextBox = Instance.new("TextLabel")
			local shadow = Instance.new("Frame")
			local PopupText = Instance.new("TextLabel")
			local Exit = Instance.new("TextButton")
			local ExitImage = Instance.new("ImageLabel")

			AnnGUI.Name = randomString()
			AnnGUI.Parent = ScaledHolder
			AnnGUI.Active = true
			AnnGUI.BackgroundTransparency = 1
			AnnGUI.Position = UDim2.new(0.5, -180, 0, -500)
			AnnGUI.Size = UDim2.new(0, 360, 0, 20)
			AnnGUI.ZIndex = 10

			background.Name = "background"
			background.Parent = AnnGUI
			background.Active = true
			background.BackgroundColor3 = currentShade1
			background.BorderSizePixel = 0
			background.Position = UDim2.new(0, 0, 0, 20)
			background.Size = UDim2.new(0, 360, 0, 150)
			background.ZIndex = 10

			TextBox.Parent = background
			TextBox.BackgroundTransparency = 1
			TextBox.Position = UDim2.new(0, 5, 0, 5)
			TextBox.Size = UDim2.new(0, 350, 0, 140)
			TextBox.Font = Enum.Font.SourceSans
			TextBox.TextSize = 18
			TextBox.TextWrapped = true
			TextBox.Text = latestVersionInfo.Announcement
			TextBox.TextColor3 = currentText1
			TextBox.TextXAlignment = Enum.TextXAlignment.Left
			TextBox.TextYAlignment = Enum.TextYAlignment.Top
			TextBox.ZIndex = 10

			shadow.Name = "shadow"
			shadow.Parent = AnnGUI
			shadow.BackgroundColor3 = currentShade2
			shadow.BorderSizePixel = 0
			shadow.Size = UDim2.new(0, 360, 0, 20)
			shadow.ZIndex = 10

			PopupText.Name = "PopupText"
			PopupText.Parent = shadow
			PopupText.BackgroundTransparency = 1
			PopupText.Size = UDim2.new(1, 0, 0.95, 0)
			PopupText.ZIndex = 10
			PopupText.Font = Enum.Font.SourceSans
			PopupText.TextSize = 14
			PopupText.Text = "Server Announcement"
			PopupText.TextColor3 = currentText1
			PopupText.TextWrapped = true

			Exit.Name = "Exit"
			Exit.Parent = shadow
			Exit.BackgroundTransparency = 1
			Exit.Position = UDim2.new(1, -20, 0, 0)
			Exit.Size = UDim2.new(0, 20, 0, 20)
			Exit.Text = ""
			Exit.ZIndex = 10

			ExitImage.Parent = Exit
			ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
			ExitImage.BackgroundTransparency = 1
			ExitImage.Position = UDim2.new(0, 5, 0, 5)
			ExitImage.Size = UDim2.new(0, 10, 0, 10)
			ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
			ExitImage.ZIndex = 10

			task.wait(1)
			AnnGUI:TweenPosition(UDim2.new(0.5, -180, 0, 150), "InOut", "Quart", 0.5, true, nil)

			Exit.MouseButton1Click:Connect(function()
				AnnGUI:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
				task.wait(0.6)
				AnnGUI:Destroy()
			end)
		end
	end
end)

task.spawn(function()
    task.wait()
    pcall(function()
        Credits:TweenPosition(UDim2.new(0, 0, 0.9, 0), "Out", "Quart", 0.2)
        Logo:TweenSizeAndPosition(UDim2.new(0, 175, 0, 175), UDim2.new(0, 37, 0, 45), "Out", "Quart", 0.3)
        task.wait(1)
        local OutInfo = TweenInfo.new(1.6809, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
        TweenService:Create(Logo, OutInfo, {ImageTransparency = 1}):Play()
        TweenService:Create(IntroBackground, OutInfo, {BackgroundTransparency = 1}):Play()
        Credits:TweenPosition(UDim2.new(0, 0, 0.9, 30), "Out", "Quart", 0.2)
        task.wait(0.2)
    end)
    Logo:Destroy()
    Credits:Destroy()
    IntroBackground:Destroy()
    minimizeHolder()
end)

-- The legacy splash screen is removed immediately; Rayfield is the only main window.
if Credits then Credits:Destroy() end
if Logo then Logo:Destroy() end
if IntroBackground then IntroBackground:Destroy() end
if Holder then Holder.Visible = false end

local auxiliaryUiTheme = {
	Background = Color3.fromRGB(18, 21, 28),
	Card = Color3.fromRGB(24, 28, 37),
	Field = Color3.fromRGB(18, 21, 28),
	FieldTransparency = 0,
	Inset = Color3.fromRGB(18, 21, 28),
	Stroke = Color3.fromRGB(45, 52, 66),
	Accent = Color3.fromRGB(137, 122, 239),
	AccentText = Color3.fromRGB(177, 164, 255),
	OnAccent = Color3.new(1, 1, 1),
	Text = Color3.fromRGB(237, 240, 246),
	SubText = Color3.fromRGB(161, 171, 188),
	Muted = Color3.fromRGB(104, 113, 130),
	SelectedCard = Color3.fromRGB(42, 37, 66),
	-- Status colours for numbers like FPS and ping: good, so-so and bad.
	Good = Color3.fromRGB(74, 222, 128),
	Fair = Color3.fromRGB(255, 212, 59),
	Bad = Color3.fromRGB(255, 90, 90),
}
local auxiliaryUiColorBindings = {}
-- Called after every theme change, for UI whose colours depend on state rather than a fixed role.
local auxiliaryUiThemeListeners = {}
local function bindAuxiliaryUiColor(object, property, role)
	local binding = { object, property, role }
	table.insert(auxiliaryUiColorBindings, binding)
	object[property] = auxiliaryUiTheme[role]
end
-- palette, when given, is the menu theme's palette (themePalettes): light themes get deeper
-- wells, and its accentText is the accent for text and icons.
local function updateAuxiliaryUiTheme(theme, palette)
	local function color(value, fallback)
		if typeof(value) == "ColorSequence" then return value.Keypoints[1].Value end
		if typeof(value) == "Color3" then return value end
		return fallback
	end
	local accent = color(theme.AccentColor, auxiliaryUiTheme.Accent)
	local card = color(theme.ElementGradient, auxiliaryUiTheme.Card)
	local background = color(theme.WindowColor, auxiliaryUiTheme.Background)
	-- ElementStroke is the row border colour; SurfaceStroke is white in most themes.
	local stroke = color(theme.ElementStroke, color(theme.SurfaceStroke, auxiliaryUiTheme.Stroke))
	local light = palette ~= nil and palette.light == true
	-- How bright the accent looks (relative luminance), to pick text that reads on top of it.
	local function linear(channel)
		return channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
	end
	local accentLuminance = 0.2126 * linear(accent.R) + 0.7152 * linear(accent.G) + 0.0722 * linear(accent.B)
	auxiliaryUiTheme = {
		Background = background,
		Card = card,
		-- Rayfield's own themes use a white FieldBackground that is meant to be 90% see-through,
		-- so anything drawn solid uses Inset instead: the row colour pulled toward the window
		-- colour (on light themes, the window colour pulled toward the borders).
		Field = color(theme.FieldBackground, card),
		FieldTransparency = type(theme.FieldTransparency) == "number" and theme.FieldTransparency or 0,
		Inset = light and background:Lerp(stroke, 0.35) or card:Lerp(background, 0.6),
		Stroke = stroke,
		Accent = accent,
		AccentText = (palette and palette.accentText) or color(theme.AccentStroke, accent),
		-- Text on the accent colour: dark on bright accents (gold, teal), white on the rest.
		OnAccent = accentLuminance > 0.32 and Color3.fromRGB(16, 18, 24) or Color3.new(1, 1, 1),
		Text = color(theme.ContentColor, auxiliaryUiTheme.Text),
		SubText = color(theme.TabColor, auxiliaryUiTheme.SubText),
		Muted = color(theme.PlaceholderColor, auxiliaryUiTheme.Muted),
		SelectedCard = accent:Lerp(card, 0.72),
		-- Deeper on light themes, so they read on white.
		Good = light and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(74, 222, 128),
		Fair = light and Color3.fromRGB(202, 138, 4) or Color3.fromRGB(255, 212, 59),
		Bad = light and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(255, 90, 90),
	}
	setEspAccentColor(auxiliaryUiTheme.AccentText)
	for index = #auxiliaryUiColorBindings, 1, -1 do
		local binding = auxiliaryUiColorBindings[index]
		if binding[1].Parent then
			binding[1][binding[2]] = auxiliaryUiTheme[binding[3]]
		else
			table.remove(auxiliaryUiColorBindings, index)
		end
	end
	for _, listener in ipairs(auxiliaryUiThemeListeners) do
		task.spawn(listener)
	end
end

-- Lucide icons for the menu. Rayfield gen2 only shows image ids, so these come from the sprite
-- sheets the original Rayfield uses: each icon is one 48px cell of a sheet image.
local menuIcons = { byName = {} }
function menuIcons.load()
	local iconFile = "SpreadCheeksGUI_Icons.lua"
	-- The map is read as data rather than run.
	local function parse(source)
		local sheet = type(source) == "string" and source:match('%["48px"%]%s*=%s*(%b{})')
		if not sheet then return false end
		for name, id, width, height, x, y in sheet:gmatch('%[?"?([%w_%-]+)"?%]?%s*=%s*{%s*(%d+)%s*,%s*{%s*(%d+)%s*,%s*(%d+)%s*}%s*,%s*{%s*(%d+)%s*,%s*(%d+)%s*}%s*}') do
			menuIcons.byName[name] = {
				image = "rbxassetid://" .. id,
				size = Vector2.new(tonumber(width), tonumber(height)),
				offset = Vector2.new(tonumber(x), tonumber(y)),
			}
		end
		return next(menuIcons.byName) ~= nil
	end
	if readfile then
		local readOk, saved = readfile(iconFile, true)
		if readOk and parse(saved) then return end
	end
	local fetched, source = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")
	end)
	if fetched and parse(source) then
		if writefile then writefile(iconFile, source, true) end
	else
		warn("[SpreadCheeksGUI] Menu icons couldn't be loaded, so the menu shows without them.")
	end
end
-- The first of the given names that exists, so an icon can fall back to another.
function menuIcons.get(...)
	for index = 1, select("#", ...) do
		local icon = menuIcons.byName[select(index, ...)]
		if icon then return icon end
	end
	return nil
end
function menuIcons.apply(label, icon)
	label.Image = icon.image
	label.ImageRectSize = icon.size
	label.ImageRectOffset = icon.offset
end
-- Points labels under root that show this icon's sheet, but no cell of it yet, at the icon.
function menuIcons.fitUnfitted(root, icon)
	for _, descendant in ipairs(root:GetDescendants()) do
		if (descendant:IsA("ImageLabel") or descendant:IsA("ImageButton"))
			and descendant.Image == icon.image and descendant.ImageRectSize == Vector2.zero then
			descendant.ImageRectSize = icon.size
			descendant.ImageRectOffset = icon.offset
		end
	end
end
-- Command icons, matched on the command's name: the first rule whose text appears in the name
-- wins, and "=" means the whole name. Order matters: "respawn" and "remotespy" contain "esp",
-- "chat" contains "hat", "blockhead" contains "lock" and "mousesensitivity" contains "sit".
menuIcons.commandRules = {
	{ "spy", "radio" }, { "respawn", "rotate-ccw" }, { "remove", "trash-2" }, { "sensitivity", "mouse" },
	{ "blockhead", "box" }, { "brightness", "sun" }, { "jpower", "arrow-big-up" },
	{ "userid", "fingerprint" }, { "jobid", "fingerprint" }, { "creatorid", "fingerprint" }, { "appearanceid", "fingerprint" },
	{ "discord", "message-circle" }, { "hideiy", "eye-off" }, { "showiy", "eye" }, { "keepiy", "pin" },
	{ "spawnpoint", "flag" }, { "flashback", "history" }, { "lastcommand", "history" }, { "guiscale", "scaling" },
	{ "guis", "app-window" }, { "inviteprompt", "user-plus" }, { "promptr", "person-standing" },
	{ "proximity", "hand" }, { "prompts", "bell-off" }, { "shiftlock", "lock" },
	{ "render", "monitor" }, { "materials", "layers" }, { "arms", "bone" }, { "legs", "bone" }, { "limbs", "bone" },
	{ "naked", "shirt" }, { "noface", "smile" }, { "nilchar", "user-x" }, { "root", "user-x" }, { "stun", "zap-off" },
	{ "=trip", "footprints" }, { "scare", "ghost" }, { "fakeout", "skull" }, { "destroyheight", "skull" },
	{ "pulsetp", "navigation" }, { "=thru", "navigation" }, { "offset", "move" }, { "gametp", "rocket" },
	{ "datalimit", "network" }, { "replicationlag", "network" }, { "enable", "toggle-right" }, { "disable", "toggle-right" },
	{ "alignmentkeys", "keyboard" }, { "gameplaypaused", "pause" }, { "grippos", "hand" }, { "handlekill", "sword" },
	{ "hovername", "tag" }, { "maxslopeangle", "mountain" }, { "nobgui", "tag" }, { "partpath", "box" },
	{ "=rec", "video" }, { "togglefs", "maximize" }, { "split", "scissors" },
	{ "esp", "scan-eye" }, { "chams", "person-standing" }, { "locate", "locate" }, { "xray", "scan" },
	{ "antifling", "shield" }, { "antikick", "shield" }, { "antiteleport", "shield" }, { "antivoid", "shield" },
	{ "antiafk", "coffee" }, { "antilag", "zap" }, { "god", "shield" },
	{ "fling", "tornado" }, { "vehiclefly", "car" }, { "vfly", "car" }, { "flyjump", "chevrons-up" }, { "fly", "plane" },
	{ "noclip", "ghost" }, { "clip", "ghost" }, { "jump", "arrow-big-up" }, { "gravity", "orbit" },
	{ "swim", "waves" }, { "float", "cloud" }, { "freecam", "video" },
	{ "spectate", "eye" }, { "view", "eye" }, { "lookat", "eye" }, { "stare", "eye" },
	{ "waypoint", "map-pin" }, { "goto", "navigation" }, { "tppos", "navigation" }, { "teleport", "navigation" },
	{ "position", "map-pinned" }, { "bring", "magnet" }, { "tpunanchored", "magnet" },
	{ "freeze", "snowflake" }, { "thaw", "snowflake" }, { "spin", "refresh-cw" }, { "orbit", "orbit" },
	{ "follow", "footprints" }, { "walkto", "footprints" },
	{ "rejoin", "refresh-cw" }, { "serverhop", "server" }, { "reset", "rotate-ccw" },
	{ "refresh", "rotate-ccw" }, { "delete", "trash-2" }, { "clear", "eraser" },
	{ "invis", "eye-off" }, { "visible", "eye" }, { "sit", "armchair" }, { "=lay", "bed" },
	{ "dance", "music" }, { "anim", "person-standing" }, { "emote", "smile" },
	{ "chat", "message-square" }, { "spam", "message-square" }, { "whisper", "message-square" }, { "=say", "message-square" },
	{ "btools", "hammer" }, { "f3x", "hammer" }, { "tool", "hammer" }, { "reach", "sword" },
	{ "hitbox", "box" }, { "headsize", "box" }, { "hat", "hard-hat" },
	{ "fullbright", "sun" }, { "=day", "sun" }, { "night", "moon" }, { "fog", "cloud-fog" }, { "light", "lightbulb" },
	{ "shadows", "sun" }, { "ambient", "sun" }, { "logs", "scroll-text" },
	{ "fov", "focus" }, { "zoom", "zoom-in" }, { "cam", "camera" }, { "firstp", "eye" }, { "thirdp", "eye" },
	{ "unlock", "lock-open" }, { "lock", "lock" }, { "unfriend", "user-minus" }, { "friend", "user-plus" },
	{ "=age", "calendar" }, { "joindate", "calendar" }, { "copy", "copy" },
	{ "unmute", "volume-2" }, { "mute", "volume-x" }, { "volume", "volume-2" }, { "listento", "ear" },
	{ "dex", "folder-tree" }, { "explorer", "folder-tree" }, { "audiologger", "music" },
	{ "console", "square-terminal" }, { "console", "terminal-square" }, { "plugin", "puzzle" }, { "alias", "tag" },
	{ "keypress", "keyboard" }, { "click", "mouse-pointer-click" }, { "proximity", "hand" }, { "touch", "hand" },
	{ "anchor", "anchor" }, { "notify", "bell" }, { "ping", "wifi" }, { "exit", "log-out" }, { "screenshot", "camera" },
	{ "record", "video" }, { "fullscreen", "maximize" }, { "info", "info" }, { "speed", "gauge" }, { "fps", "gauge" },
	{ "loop", "repeat" }, { "break", "circle-stop" }, { "weaken", "dumbbell" }, { "strengthen", "dumbbell" },
	{ "wall", "brick-wall" }, { "hipheight", "ruler" }, { "rotate", "rotate-3d" }, { "=team", "users" },
	{ "inspect", "search" }, { "watch", "eye" }, { "phonebook", "phone" }, { "save", "save" }, { "debug", "bug" },
}
-- A command's icon, or the first of the fallback names that exists when no rule fits.
function menuIcons.forCommand(commandName, ...)
	local name = tostring(commandName):lower()
	for _, rule in ipairs(menuIcons.commandRules) do
		local text = rule[1]
		local fits
		if text:sub(1, 1) == "=" then
			fits = name == text:sub(2)
		else
			fits = name:find(text, 1, true) ~= nil
		end
		if fits then
			local icon = menuIcons.get(rule[2])
			if icon then return icon end
		end
	end
	return menuIcons.get(...)
end

-- Lets the menu open the ; bar too (the Home page has a button for it).
local quickCommandBar = {}

-- The ; command bar is built before the Rayfield menu loads, so it works straight away and
-- can't be held up or stopped by anything in the menu setup.
(function()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	-- Remove a previous copy so re-running the script always installs a fresh
	-- hotkey listener instead of leaving a hidden, unresponsive bar behind.
	local previousCommandGui = playerGui:FindFirstChild("IYQuickCommandBar")
	if previousCommandGui then
		previousCommandGui:Destroy()
	end

	local commandGui = Instance.new("ScreenGui")
	commandGui.Name = "IYQuickCommandBar"
	commandGui.ResetOnSpawn = false
	commandGui.IgnoreGuiInset = true
	commandGui.DisplayOrder = 1000
	commandGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	commandGui.Enabled = false
	commandGui.Parent = playerGui

	local shell = Instance.new("Frame")
	shell.Name = "CommandBar"
	shell.AnchorPoint = Vector2.new(0.5, 0.5)
	shell.Position = UDim2.fromScale(0.5, 0.5)
	shell.Size = UDim2.new(0.86, 0, 0, 62)
	shell.BackgroundColor3 = Color3.fromRGB(18, 21, 28)
	shell.BorderSizePixel = 0
	shell.Parent = commandGui
	bindAuxiliaryUiColor(shell, "BackgroundColor3", "Background")
	local shellConstraint = Instance.new("UISizeConstraint")
	shellConstraint.MinSize = Vector2.new(280, 62)
	shellConstraint.MaxSize = Vector2.new(560, 62)
	shellConstraint.Parent = shell
	local shellCorner = Instance.new("UICorner")
	shellCorner.CornerRadius = UDim.new(0, 11)
	shellCorner.Parent = shell
	local shellStroke = Instance.new("UIStroke")
	shellStroke.Color = Color3.fromRGB(137, 122, 239)
	shellStroke.Transparency = 0.18
	shellStroke.Thickness = 1
	shellStroke.Parent = shell
	bindAuxiliaryUiColor(shellStroke, "Color", "Accent")

	local prefixMark = Instance.new("TextLabel")
	prefixMark.Size = UDim2.fromOffset(28, 28)
	prefixMark.Position = UDim2.fromOffset(12, 8)
	prefixMark.BackgroundColor3 = Color3.fromRGB(37, 43, 55)
	prefixMark.BorderSizePixel = 0
	prefixMark.Text = tostring(prefix or ";")
	prefixMark.Font = Enum.Font.GothamBold
	prefixMark.TextSize = 15
	prefixMark.TextColor3 = Color3.fromRGB(177, 164, 255)
	prefixMark.Parent = shell
	bindAuxiliaryUiColor(prefixMark, "BackgroundColor3", "Card")
	bindAuxiliaryUiColor(prefixMark, "TextColor3", "AccentText")
	local prefixCorner = Instance.new("UICorner")
	prefixCorner.CornerRadius = UDim.new(0, 7)
	prefixCorner.Parent = prefixMark

	local commandInput = Instance.new("TextBox")
	commandInput.Name = "Input"
	commandInput.Position = UDim2.fromOffset(50, 7)
	commandInput.Size = UDim2.new(1, -100, 0, 29)
	commandInput.BackgroundTransparency = 1
	commandInput.ClearTextOnFocus = false
	commandInput.Text = ""
	commandInput.PlaceholderText = "Type a command and press Enter"
	commandInput.PlaceholderColor3 = Color3.fromRGB(104, 113, 130)
	commandInput.TextColor3 = Color3.fromRGB(237, 240, 246)
	commandInput.Font = Enum.Font.Gotham
	commandInput.TextSize = 14
	commandInput.TextXAlignment = Enum.TextXAlignment.Left
	commandInput.Parent = shell
	bindAuxiliaryUiColor(commandInput, "PlaceholderColor3", "Muted")
	bindAuxiliaryUiColor(commandInput, "TextColor3", "Text")

	local hint = Instance.new("TextLabel")
	hint.Position = UDim2.fromOffset(50, 36)
	hint.Size = UDim2.new(1, -90, 0, 14)
	hint.BackgroundTransparency = 1
	hint.Text = "ENTER  RUN     TAB  COMPLETE     UP / DOWN  PICK OR HISTORY     ESC  CLOSE"
	hint.Font = Enum.Font.GothamMedium
	hint.TextSize = 9
	hint.TextColor3 = Color3.fromRGB(104, 113, 130)
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.TextTruncate = Enum.TextTruncate.AtEnd
	hint.Parent = shell
	bindAuxiliaryUiColor(hint, "TextColor3", "Muted")

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.fromOffset(26, 26)
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -10, 0, 9)
	closeButton.BackgroundColor3 = Color3.fromRGB(37, 43, 55)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "×"
	closeButton.Font = Enum.Font.Gotham
	closeButton.TextSize = 18
	closeButton.TextColor3 = Color3.fromRGB(148, 157, 173)
	closeButton.AutoButtonColor = true
	closeButton.Parent = shell
	bindAuxiliaryUiColor(closeButton, "BackgroundColor3", "Card")
	bindAuxiliaryUiColor(closeButton, "TextColor3", "SubText")
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 7)
	closeCorner.Parent = closeButton

	-- Matching commands, listed under the bar while you type.
	local suggestionPanel = Instance.new("Frame")
	suggestionPanel.Name = "Suggestions"
	suggestionPanel.Position = UDim2.new(0, 0, 1, 8)
	suggestionPanel.Size = UDim2.new(1, 0, 0, 0)
	suggestionPanel.BorderSizePixel = 0
	suggestionPanel.Visible = false
	suggestionPanel.Parent = shell
	bindAuxiliaryUiColor(suggestionPanel, "BackgroundColor3", "Background")
	local suggestionCorner = Instance.new("UICorner")
	suggestionCorner.CornerRadius = UDim.new(0, 11)
	suggestionCorner.Parent = suggestionPanel
	local suggestionStroke = Instance.new("UIStroke")
	suggestionStroke.Transparency = 0.2
	suggestionStroke.Parent = suggestionPanel
	bindAuxiliaryUiColor(suggestionStroke, "Color", "Stroke")
	local suggestionList = Instance.new("ScrollingFrame")
	suggestionList.Position = UDim2.fromOffset(4, 4)
	suggestionList.Size = UDim2.new(1, -8, 1, -8)
	suggestionList.BackgroundTransparency = 1
	suggestionList.BorderSizePixel = 0
	suggestionList.ScrollBarThickness = 3
	suggestionList.ScrollingDirection = Enum.ScrollingDirection.Y
	suggestionList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	suggestionList.CanvasSize = UDim2.new()
	suggestionList.Parent = suggestionPanel
	bindAuxiliaryUiColor(suggestionList, "ScrollBarImageColor3", "Muted")
	local suggestionLayout = Instance.new("UIListLayout")
	suggestionLayout.Padding = UDim.new(0, 2)
	suggestionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	suggestionLayout.Parent = suggestionList

	local rowHeight, maxVisibleRows, maxSuggestions = 38, 6, 60
	local rows = {}
	local currentMatches = {}
	local highlighted = 0
	-- Set once a suggestion is picked with the arrow keys, so Enter runs that one.
	local navigated = false
	-- While arguments are being typed the list just shows how the command is used.
	local hintMode = false
	-- Text the bar set itself, so the change doesn't count as typing.
	local programmaticText = nil
	local historyIndex, historyDraft = 0, ""
	local acceptSuggestion

	-- Every command once, with its usage and description: IY's command list first, then
	-- anything registered but not listed there (plugin commands, for one).
	local commandIndex = {}
	local indexedCommandCount = -1
	local function buildCommandIndex()
		commandIndex = {}
		local listed = {}
		for _, info in ipairs(type(CMDs) == "table" and CMDs or {}) do
			local display = tostring(info.NAME or "")
			local cut = display:find("[%[%(]")
			local head = cut and display:sub(1, cut - 1) or display
			local names = {}
			for name in head:gmatch("[^/]+") do
				name = name:gsub("^%s+", ""):gsub("%s+$", ""):lower()
				if name ~= "" then
					table.insert(names, name)
					listed[name] = true
				end
			end
			if #names > 0 then
				table.insert(commandIndex, {
					names = names,
					usage = cut and display:sub(cut) or "",
					description = tostring(info.DESC or ""),
				})
			end
		end
		for _, command in ipairs(type(cmds) == "table" and cmds or {}) do
			local name = type(command) == "table" and type(command.NAME) == "string" and command.NAME:lower()
			if name and not listed[name] then
				local names = { name }
				for _, alias in ipairs(type(command.ALIAS) == "table" and command.ALIAS or {}) do
					table.insert(names, tostring(alias):lower())
				end
				for _, each in ipairs(names) do listed[each] = true end
				table.insert(commandIndex, {
					names = names,
					usage = "",
					description = command.PLUGIN and ("From " .. tostring(command.PLUGIN)) or "",
				})
			end
		end
		indexedCommandCount = type(cmds) == "table" and #cmds or 0
	end

	-- Exact names first, then names that start with what's typed, then names that contain it.
	local function findMatches(word)
		local found = {}
		for _, entry in ipairs(commandIndex) do
			local bestRank, bestName
			for _, name in ipairs(entry.names) do
				local rank = (name == word and 1) or (name:sub(1, #word) == word and 2) or (name:find(word, 1, true) and 3) or nil
				if rank and (not bestRank or rank < bestRank) then
					bestRank, bestName = rank, name
				end
			end
			if bestRank then
				table.insert(found, { entry = entry, name = bestName, rank = bestRank })
			end
		end
		table.sort(found, function(left, right)
			if left.rank ~= right.rank then return left.rank < right.rank end
			if #left.name ~= #right.name then return #left.name < #right.name end
			return left.name < right.name
		end)
		for index = #found, maxSuggestions + 1, -1 do
			found[index] = nil
		end
		return found
	end

	-- Splits the bar's text around the command being typed. IY runs \-separated commands one
	-- after another, and a leading ! repeats a command with its last arguments.
	local function splitCommandText(text)
		local commandPrefix = tostring(prefix or ";")
		if commandPrefix ~= "" and text:sub(1, #commandPrefix) == commandPrefix then
			text = text:sub(#commandPrefix + 1)
		end
		local before, chunk = text:match("^(.*\\)(.-)$")
		if not before then
			before, chunk = "", text
		end
		local spaces, lead, word, rest = chunk:match("^(%s*)(!?)(%S*)(.*)$")
		return before .. spaces, lead, word, rest
	end

	local function getRow(index)
		if rows[index] then return rows[index] end
		local row = { index = index }
		row.button = Instance.new("TextButton")
		row.button.Name = "Suggestion"
		row.button.LayoutOrder = index
		row.button.Size = UDim2.new(1, -6, 0, rowHeight)
		row.button.AutoButtonColor = false
		row.button.BackgroundTransparency = 1
		row.button.BorderSizePixel = 0
		row.button.Text = ""
		row.button.Parent = suggestionList
		bindAuxiliaryUiColor(row.button, "BackgroundColor3", "SelectedCard")
		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 8)
		rowCorner.Parent = row.button
		row.icon = Instance.new("ImageLabel")
		row.icon.AnchorPoint = Vector2.new(0, 0.5)
		row.icon.Position = UDim2.new(0, 10, 0.5, 0)
		row.icon.Size = UDim2.fromOffset(16, 16)
		row.icon.BackgroundTransparency = 1
		row.icon.Parent = row.button
		bindAuxiliaryUiColor(row.icon, "ImageColor3", "Text")
		local titleLine = Instance.new("Frame")
		titleLine.Position = UDim2.fromOffset(36, 4)
		titleLine.Size = UDim2.new(1, -46, 0, 16)
		titleLine.BackgroundTransparency = 1
		titleLine.ClipsDescendants = true
		titleLine.Parent = row.button
		local titleLayout = Instance.new("UIListLayout")
		titleLayout.FillDirection = Enum.FillDirection.Horizontal
		titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		titleLayout.Padding = UDim.new(0, 6)
		titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
		titleLayout.Parent = titleLine
		row.name = Instance.new("TextLabel")
		row.name.LayoutOrder = 1
		row.name.AutomaticSize = Enum.AutomaticSize.X
		row.name.Size = UDim2.new(0, 0, 1, 0)
		row.name.BackgroundTransparency = 1
		row.name.Font = Enum.Font.GothamMedium
		row.name.TextSize = 13
		row.name.Parent = titleLine
		bindAuxiliaryUiColor(row.name, "TextColor3", "Text")
		row.usage = Instance.new("TextLabel")
		row.usage.LayoutOrder = 2
		row.usage.AutomaticSize = Enum.AutomaticSize.X
		row.usage.Size = UDim2.new(0, 0, 1, 0)
		row.usage.BackgroundTransparency = 1
		row.usage.Font = Enum.Font.Gotham
		row.usage.TextSize = 12
		row.usage.Parent = titleLine
		bindAuxiliaryUiColor(row.usage, "TextColor3", "Muted")
		row.description = Instance.new("TextLabel")
		row.description.Position = UDim2.fromOffset(36, 21)
		row.description.Size = UDim2.new(1, -46, 0, 13)
		row.description.BackgroundTransparency = 1
		row.description.Font = Enum.Font.Gotham
		row.description.TextSize = 11
		row.description.TextXAlignment = Enum.TextXAlignment.Left
		row.description.TextTruncate = Enum.TextTruncate.AtEnd
		row.description.Parent = row.button
		bindAuxiliaryUiColor(row.description, "TextColor3", "SubText")
		row.button.MouseEnter:Connect(function()
			if row.index ~= highlighted then row.button.BackgroundTransparency = 0.6 end
		end)
		row.button.MouseLeave:Connect(function()
			row.button.BackgroundTransparency = row.index == highlighted and 0 or 1
		end)
		row.button.Activated:Connect(function()
			acceptSuggestion(row.index)
		end)
		rows[index] = row
		return row
	end

	local function renderSuggestions()
		for index = 1, math.max(#currentMatches, #rows) do
			local match = currentMatches[index]
			if match then
				local row = getRow(index)
				local icon = menuIcons.forCommand(match.entry.names[1], "square-terminal", "terminal-square", "chevron-right")
				row.icon.Visible = icon ~= nil
				if icon then menuIcons.apply(row.icon, icon) end
				row.name.Text = table.concat(match.entry.names, " / ")
				row.usage.Text = match.entry.usage
				row.description.Text = match.entry.description
				row.button.BackgroundTransparency = index == highlighted and 0 or 1
				row.button.Visible = true
			elseif rows[index] then
				rows[index].button.Visible = false
			end
		end
		local shown = math.min(#currentMatches, maxVisibleRows)
		suggestionPanel.Visible = shown > 0
		suggestionPanel.Size = UDim2.new(1, 0, 0, shown * (rowHeight + 2) + 6)
	end

	local function scrollToHighlighted()
		local top = (highlighted - 1) * (rowHeight + 2)
		local scroll = suggestionList.CanvasPosition.Y
		local viewHeight = suggestionList.AbsoluteSize.Y
		if top < scroll then
			suggestionList.CanvasPosition = Vector2.new(0, top)
		elseif top + rowHeight > scroll + viewHeight then
			suggestionList.CanvasPosition = Vector2.new(0, top + rowHeight - viewHeight)
		end
	end

	local function hideSuggestions()
		currentMatches, highlighted, navigated, hintMode = {}, 0, false, false
		renderSuggestions()
	end

	local function setInputText(text)
		programmaticText = text
		commandInput.Text = text
		commandInput.CursorPosition = #text + 1
	end

	local function refreshSuggestions()
		local _, _, word, rest = splitCommandText(commandInput.Text)
		word = word:lower()
		currentMatches, highlighted, navigated, hintMode = {}, 0, false, false
		if word ~= "" then
			if rest ~= "" then
				-- The arguments are being typed now: show how the command is used.
				for _, entry in ipairs(commandIndex) do
					if table.find(entry.names, word) then
						currentMatches = { { entry = entry, name = word } }
						hintMode = true
						break
					end
				end
			else
				currentMatches = findMatches(word)
				highlighted = #currentMatches > 0 and 1 or 0
			end
		end
		suggestionList.CanvasPosition = Vector2.zero
		renderSuggestions()
	end

	-- Fills in the picked command, ready for its arguments.
	acceptSuggestion = function(index)
		local match = currentMatches[index or highlighted]
		if not match or hintMode then return false end
		local before, lead = splitCommandText(commandInput.Text)
		setInputText(before .. lead .. match.name .. " ")
		refreshSuggestions()
		return true
	end

	-- Up steps back through commands run before (newest first), Down steps forward again,
	-- ending on whatever had been typed before stepping back.
	local function browseHistory(direction)
		local history = type(cmdHistory) == "table" and cmdHistory or {}
		if #history == 0 then return end
		if historyIndex == 0 then historyDraft = commandInput.Text end
		historyIndex = math.clamp(historyIndex + direction, 0, #history)
		hideSuggestions()
		setInputText(historyIndex == 0 and historyDraft or tostring(history[historyIndex]))
	end

	commandInput:GetPropertyChangedSignal("Text"):Connect(function()
		local text = commandInput.Text
		if text == programmaticText then return end
		programmaticText = nil
		if text:find("\t", 1, true) then
			-- Roblox types Tab into the box; it means "use the highlighted suggestion".
			if not acceptSuggestion() then
				setInputText((text:gsub("\t", "")))
			end
			return
		end
		historyIndex = 0
		refreshSuggestions()
	end)

	local function isOverBar(point)
		for _, frame in ipairs({ shell, suggestionPanel }) do
			if frame.Visible then
				local position, size = frame.AbsolutePosition, frame.AbsoluteSize
				if point.X >= position.X and point.X <= position.X + size.X
					and point.Y >= position.Y and point.Y <= position.Y + size.Y then
					return true
				end
			end
		end
		return false
	end

	local function closeCommandBar()
		commandGui.Enabled = false
		hideSuggestions()
		if UserInputService:GetFocusedTextBox() == commandInput then
			commandInput:ReleaseFocus()
		end
	end

	local function openCommandBar()
		commandGui.Enabled = true
		task.defer(function()
			if not commandGui.Enabled then return end
			if indexedCommandCount ~= #cmds then buildCommandIndex() end
			historyIndex = 0
			hideSuggestions()
			setInputText("")
			commandInput:CaptureFocus()
		end)
	end
	quickCommandBar.open = openCommandBar

	commandInput.FocusLost:Connect(function(enterPressed, cause)
		if enterPressed then
			local commandText = commandInput.Text
			-- A suggestion picked with the arrow keys runs as though it had been typed in full.
			local picked = navigated and not hintMode and currentMatches[highlighted]
			if picked then
				local before, lead = splitCommandText(commandText)
				commandText = before .. lead .. picked.name
			end
			commandText = commandText:gsub("^%s+", ""):gsub("%s+$", "")
			local commandPrefix = tostring(prefix or ";")
			if commandPrefix ~= "" and commandText:sub(1, #commandPrefix) == commandPrefix then
				commandText = commandText:sub(#commandPrefix + 1):gsub("^%s+", "")
			end
			if commandText ~= "" then
				execCmd(commandText, Players.LocalPlayer, true)
			end
		elseif cause and (cause.UserInputType == Enum.UserInputType.MouseButton1 or cause.UserInputType == Enum.UserInputType.Touch)
			and isOverBar(UserInputService:GetMouseLocation()) then
			-- A click on the bar or its list (picking a suggestion, say) keeps it open.
			task.defer(function()
				if commandGui.Enabled and not UserInputService:GetFocusedTextBox() then
					commandInput:CaptureFocus()
					commandInput.CursorPosition = #commandInput.Text + 1
				end
			end)
			return
		end
		commandGui.Enabled = false
		hideSuggestions()
	end)

	closeButton.Activated:Connect(closeCommandBar)

	-- True while the player is typing in a text box they can see, such as chat or a menu input.
	-- A box that isn't on screen can still hold the keyboard; that shouldn't stop the bar
	-- opening, and opening the bar takes the keyboard back from it.
	local function isTypingElsewhere()
		local focused = UserInputService:GetFocusedTextBox()
		if not focused then return false end
		local inspected, onScreen = pcall(function()
			local node = focused
			while node and not node:IsA("LayerCollector") do
				if node:IsA("GuiObject") and not node.Visible then return false end
				node = node.Parent
			end
			return node ~= nil and node.Enabled
		end)
		-- A box that can't be inspected is treated as one the player is typing in.
		return not inspected or onScreen
	end

	-- Kept in the shared environment so running the script again replaces this listener
	-- instead of leaving the old one acting on a bar that no longer exists.
	local sharedEnv = (type(getgenv) == "function" and getgenv()) or _G
	if sharedEnv.SpreadCheeksCommandBarConnection then
		pcall(function() sharedEnv.SpreadCheeksCommandBarConnection:Disconnect() end)
	end
	sharedEnv.SpreadCheeksCommandBarConnection = UserInputService.InputBegan:Connect(function(input)
		if commandInput:IsFocused() then
			-- Up and Down move through the suggestions when there are some, otherwise
			-- through commands run before.
			if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down then
				local step = input.KeyCode == Enum.KeyCode.Down and 1 or -1
				if #currentMatches > 0 and not hintMode then
					highlighted = (highlighted - 1 + step) % #currentMatches + 1
					navigated = true
					renderSuggestions()
					scrollToHighlighted()
				else
					browseHistory(-step)
				end
				-- Roblox can move the cursor on Up and Down; keep it at the end of the text.
				task.defer(function()
					commandInput.CursorPosition = #commandInput.Text + 1
				end)
			end
			return
		end
		if input.KeyCode ~= Enum.KeyCode.Semicolon then return end
		-- Don't steal `;` while the player is typing in chat or another input. Checking the
		-- bar's focus rather than whether it's showing means `;` still works if the bar is
		-- ever left open without the cursor in it.
		if isTypingElsewhere() then return end
		openCommandBar()
	end)
end)()

-- Loaded once the ; bar exists, since downloading the icons the first time can take a moment.
menuIcons.load()

local rayfieldLoaded, Rayfield = pcall(function()
	return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)

if rayfieldLoaded and Rayfield then
	local rayfieldOk, rayfieldError = pcall(function()
		local spreadLogo = "terminal"
		local spreadLogoLoaded = false
		local assetLoader = waxgetcustomasset or getcustomasset or getsynasset
		if type(assetLoader) == "function" then
			for _, logoPath in ipairs({
				"C:/Users/coolp/AppData/Local/Potassium/workspace/Rayfield/Assets/SpreadCheeksLogo.png",
				"Assets/SpreadCheeksLogo.png",
				"SpreadCheeksLogo.png",
				"C:/Users/coolp/Documents/ChatGPT/12/SpreadCheeksLogo.png",
			}) do
				local logoOk, logoAsset = pcall(assetLoader, logoPath)
				if logoOk and type(logoAsset) == "string" then
					spreadLogo = logoAsset
					spreadLogoLoaded = true
					break
				end
			end
		end
		if not spreadLogoLoaded then
			warn("[SpreadCheeksGUI] Logo image not loaded. Put SpreadCheeksLogo.png in the executor workspace or use an uploaded Roblox image asset ID.")
		end
		-- Feature settings (fly speeds and so on) are kept between sessions in this file and
		-- changed from the settings cards further down.
		local featureSettingsFile = "SpreadCheeksGUI_Features.json"
		-- keybindListX/Y place the on-screen keybind list as a share of the screen (-1 until it's dragged).
		local featureSettings = {
			-- The menu's colour theme, by name (see themePalettes).
			theme = "SpreadCheeks",
			flySpeed = 1, vehicleFlySpeed = 1, freecamSpeed = 1, flyUpDownKeys = true,
			keybindList = true, keybindListX = -1, keybindListY = -1,
			-- Aimbot (under ESP). The key is "RightClick", "LeftClick" or a KeyCode name.
			aimbotKey = "RightClick", aimbotPart = "Head", aimbotMethod = "Camera",
			aimbotFov = 150, aimbotSmoothness = 3, aimbotShowFov = true, aimbotTeamCheck = true, aimbotWallCheck = true,
			-- FOV circle colour: "Theme", "Rainbow" or "Custom" (aimbotFovColor, a hex code).
			aimbotFovColorMode = "Theme", aimbotFovColor = "B1A4FF",
			-- How far Free aim moves the mouse, as a multiple of what Roblox's own camera needs.
			aimbotFreeAimSpeed = 1,
			-- The Target choice "Random": aim at a random body part instead of always aimbotPart.
			aimbotRandomPart = false,
			-- Trigger bot: "Tap" or "Hold", the wait before the first shot and between taps (in
			-- milliseconds), and when it may fire.
			triggerMode = "Tap", triggerDelay = 60, triggerInterval = 150,
			triggerTeamCheck = true, triggerWhileAiming = false, triggerIndicator = true,
			-- Cheater Detector: on or off, what it watches for, how sure it has to be ("Relaxed",
			-- "Normal" or "Strict"), and whether flagged players get outlined.
			cheatDetector = false, cheatFly = true, cheatSpeed = true, cheatTeleport = true,
			cheatNoclip = true, cheatFling = true, cheatSensitivity = "Normal", cheatOutline = true,
			-- The Performance Stats window, and where it was dragged to (like keybindListX/Y).
			performanceStats = false, performanceStatsX = -1, performanceStatsY = -1,
		}
		local featureLimits = {
			flySpeed = { 0.1, 10 }, vehicleFlySpeed = { 0.1, 10 }, freecamSpeed = { 0.5, 10 },
			aimbotFov = { 20, 600 }, aimbotSmoothness = { 1, 10 }, aimbotFreeAimSpeed = { 0.1, 3 },
			triggerDelay = { 0, 500 }, triggerInterval = { 50, 1000 },
		}
		if readfile then
			local readOk, contents = readfile(featureSettingsFile, true)
			if readOk and type(contents) == "string" and contents ~= "" then
				local decodeOk, data = pcall(function() return HttpService:JSONDecode(contents) end)
				if decodeOk and type(data) == "table" then
					for key, default in pairs(featureSettings) do
						if type(data[key]) == type(default) then
							featureSettings[key] = data[key]
						end
					end
				end
			end
		end
		for key, limits in pairs(featureLimits) do
			featureSettings[key] = math.clamp(featureSettings[key], limits[1], limits[2])
		end
		iyflyspeed = featureSettings.flySpeed
		vehicleflyspeed = featureSettings.vehicleFlySpeed
		NAV_KEYBOARD_SPEED = Vector3.new(featureSettings.freecamSpeed, featureSettings.freecamSpeed, featureSettings.freecamSpeed)
		QEfly = featureSettings.flyUpDownKeys
		local function saveFeatureSettings()
			if writefile then
				writefile(featureSettingsFile, HttpService:JSONEncode(featureSettings), true)
			end
		end

		-- Themes. Each is built from a small palette, so they all share one clean look: flat colours
		-- with no gradients or glow, soft borders, and the accent kept for what's on or selected.
		-- window is the window's background, element a row's, stroke their borders; accentText is
		-- the accent for text and icons (lighter on dark themes, deeper on light ones); subText is
		-- for tab names and secondary text, muted for placeholders.
		local themePalettes = {
			{
				name = "SpreadCheeks",
				window = Color3.fromRGB(14, 16, 22), element = Color3.fromRGB(23, 26, 35), stroke = Color3.fromRGB(42, 48, 62),
				accent = Color3.fromRGB(137, 122, 239), accentText = Color3.fromRGB(177, 164, 255),
				text = Color3.fromRGB(237, 240, 246), subText = Color3.fromRGB(156, 165, 184), muted = Color3.fromRGB(104, 113, 130),
			},
			{
				name = "Default",
				window = Color3.fromRGB(16, 16, 18), element = Color3.fromRGB(26, 26, 29), stroke = Color3.fromRGB(44, 44, 50),
				accent = Color3.fromRGB(34, 197, 140), accentText = Color3.fromRGB(110, 231, 183),
				text = Color3.fromRGB(240, 240, 243), subText = Color3.fromRGB(160, 160, 170), muted = Color3.fromRGB(108, 108, 118),
			},
			{
				name = "Midnight",
				window = Color3.fromRGB(7, 7, 11), element = Color3.fromRGB(15, 15, 22), stroke = Color3.fromRGB(32, 32, 46),
				accent = Color3.fromRGB(129, 140, 248), accentText = Color3.fromRGB(165, 180, 252),
				text = Color3.fromRGB(236, 237, 250), subText = Color3.fromRGB(150, 152, 180), muted = Color3.fromRGB(98, 100, 128),
			},
			{
				name = "Cobalt",
				window = Color3.fromRGB(13, 18, 26), element = Color3.fromRGB(21, 28, 40), stroke = Color3.fromRGB(38, 50, 70),
				accent = Color3.fromRGB(59, 130, 246), accentText = Color3.fromRGB(125, 180, 255),
				text = Color3.fromRGB(234, 240, 250), subText = Color3.fromRGB(150, 166, 190), muted = Color3.fromRGB(98, 114, 138),
			},
			{
				name = "Ocean",
				window = Color3.fromRGB(9, 19, 23), element = Color3.fromRGB(15, 30, 35), stroke = Color3.fromRGB(29, 52, 59),
				accent = Color3.fromRGB(20, 184, 166), accentText = Color3.fromRGB(94, 234, 212),
				text = Color3.fromRGB(229, 246, 245), subText = Color3.fromRGB(146, 180, 182), muted = Color3.fromRGB(94, 126, 130),
			},
			{
				name = "Emerald",
				window = Color3.fromRGB(9, 19, 14), element = Color3.fromRGB(15, 30, 22), stroke = Color3.fromRGB(28, 53, 39),
				accent = Color3.fromRGB(16, 185, 129), accentText = Color3.fromRGB(110, 231, 183),
				text = Color3.fromRGB(231, 246, 237), subText = Color3.fromRGB(148, 182, 162), muted = Color3.fromRGB(96, 128, 108),
			},
			{
				name = "Amethyst",
				window = Color3.fromRGB(17, 12, 25), element = Color3.fromRGB(27, 19, 39), stroke = Color3.fromRGB(50, 37, 70),
				accent = Color3.fromRGB(168, 85, 247), accentText = Color3.fromRGB(216, 180, 254),
				text = Color3.fromRGB(243, 236, 252), subText = Color3.fromRGB(180, 162, 204), muted = Color3.fromRGB(124, 108, 148),
			},
			{
				name = "Rose",
				window = Color3.fromRGB(23, 12, 18), element = Color3.fromRGB(35, 18, 27), stroke = Color3.fromRGB(62, 35, 49),
				accent = Color3.fromRGB(236, 72, 153), accentText = Color3.fromRGB(249, 168, 212),
				text = Color3.fromRGB(252, 236, 244), subText = Color3.fromRGB(204, 164, 184), muted = Color3.fromRGB(146, 110, 128),
			},
			{
				name = "Crimson",
				window = Color3.fromRGB(19, 10, 12), element = Color3.fromRGB(31, 16, 19), stroke = Color3.fromRGB(58, 30, 35),
				accent = Color3.fromRGB(239, 68, 68), accentText = Color3.fromRGB(252, 165, 165),
				text = Color3.fromRGB(250, 236, 236), subText = Color3.fromRGB(196, 160, 162), muted = Color3.fromRGB(140, 106, 108),
			},
			{
				name = "Ember",
				window = Color3.fromRGB(21, 14, 10), element = Color3.fromRGB(33, 22, 16), stroke = Color3.fromRGB(60, 41, 30),
				accent = Color3.fromRGB(249, 115, 22), accentText = Color3.fromRGB(253, 186, 116),
				text = Color3.fromRGB(252, 240, 232), subText = Color3.fromRGB(200, 172, 152), muted = Color3.fromRGB(144, 118, 100),
			},
			{
				name = "Gold",
				window = Color3.fromRGB(16, 14, 10), element = Color3.fromRGB(27, 24, 17), stroke = Color3.fromRGB(52, 46, 32),
				accent = Color3.fromRGB(234, 179, 8), accentText = Color3.fromRGB(253, 224, 71),
				text = Color3.fromRGB(250, 246, 232), subText = Color3.fromRGB(192, 180, 150), muted = Color3.fromRGB(136, 126, 100),
			},
			{
				name = "Frost", light = true,
				window = Color3.fromRGB(240, 245, 249), element = Color3.fromRGB(255, 255, 255), stroke = Color3.fromRGB(218, 226, 233),
				accent = Color3.fromRGB(14, 165, 233), accentText = Color3.fromRGB(3, 105, 161),
				text = Color3.fromRGB(22, 30, 40), subText = Color3.fromRGB(84, 98, 116), muted = Color3.fromRGB(140, 152, 168),
			},
			{
				name = "Daylight", light = true,
				window = Color3.fromRGB(243, 243, 246), element = Color3.fromRGB(255, 255, 255), stroke = Color3.fromRGB(224, 224, 230),
				accent = Color3.fromRGB(37, 99, 235), accentText = Color3.fromRGB(29, 78, 216),
				text = Color3.fromRGB(20, 20, 26), subText = Color3.fromRGB(96, 96, 110), muted = Color3.fromRGB(148, 148, 160),
			},
			{
				name = "Sakura", light = true,
				window = Color3.fromRGB(251, 242, 246), element = Color3.fromRGB(255, 255, 255), stroke = Color3.fromRGB(241, 216, 227),
				accent = Color3.fromRGB(219, 39, 119), accentText = Color3.fromRGB(190, 24, 93),
				text = Color3.fromRGB(40, 20, 30), subText = Color3.fromRGB(120, 88, 104), muted = Color3.fromRGB(172, 140, 156),
			},
		}
		local function paletteNamed(name)
			for _, palette in ipairs(themePalettes) do
				if palette.name == name then return palette end
			end
			return nil
		end
		-- A full Rayfield theme from a palette. ChangeTheme only replaces the keys it's given, so
		-- this sets every colour Rayfield uses (fonts are left alone). Dark themes follow Rayfield's
		-- default and light ones its Frost theme, in how they use each key.
		local function makeTheme(palette)
			local dark = not palette.light
			local window, element, stroke, accent = palette.window, palette.element, palette.stroke, palette.accent
			-- Hovered surfaces get lighter on dark themes and darker on light ones.
			local shade = dark and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
			-- Wells for text boxes, slider tracks and switches, set into the rows.
			local inset = dark and element:Lerp(window, 0.6) or window:Lerp(stroke, 0.35)
			local function flat(color)
				return ColorSequence.new(color)
			end
			return {
				CornerRoundness = UDim.new(0, 14),
				ElementCornerRadius = UDim.new(0, 10),
				PillCornerRadius = UDim.new(0, 10),
				LiveAnimation = false,
				DarkToggleOverlay = dark,
				WindowColor = flat(window),
				ShadowColor = dark and Color3.new(0, 0, 0) or stroke:Lerp(Color3.new(0, 0, 0), 0.4),
				SurfaceStroke = stroke,
				ContentColor = palette.text,
				TitlingColor = palette.text,
				ElementTextHoverColor = palette.text,
				ActionColor = palette.subText,
				TabColor = palette.subText,
				-- The selected tab: a soft tint of the accent on dark themes, the accent itself on light.
				TabBackground = flat(dark and accent:Lerp(element, 0.8) or accent),
				TabStroke = flat(dark and accent:Lerp(element, 0.55) or accent:Lerp(Color3.new(1, 1, 1), 0.3)),
				ElementGradient = flat(element),
				ElementTransparency = 0,
				ElementStroke = stroke,
				ElementStrokeGradient = flat(stroke),
				ElementStrokeTransparency = dark and 0.35 or 0.1,
				ElementStrokeHover = accent,
				ElementStrokeHoverTransparency = 0.25,
				AccentColor = accent,
				AccentStroke = dark and palette.accentText or accent:Lerp(Color3.new(1, 1, 1), 0.3),
				AccentGlow = dark and 0.8 or 0.9,
				DropdownHighlight = accent,
				StatBackground = inset,
				SliderBackground = inset,
				SliderBackgroundHover = inset:Lerp(shade, 0.05),
				SliderProgress = flat(accent),
				SliderStroke = stroke,
				SliderHandle = dark and Color3.fromRGB(250, 250, 252) or palette.text,
				ToggleTrack = dark and inset or stroke:Lerp(Color3.new(0, 0, 0), 0.08),
				ToggleTrackTransparency = 0,
				ToggleKnobOff = dark and palette.muted or Color3.new(1, 1, 1),
				ToggleKnobOffTransparency = 0,
				FieldBackground = inset,
				FieldTransparency = 0,
				FieldGlow = accent,
				PlaceholderColor = palette.muted,
				NeutralButton = element:Lerp(shade, 0.05),
				NeutralButtonHover = element:Lerp(shade, 0.09),
				NeutralButtonStroke = stroke,
				ErrorColor = Color3.fromRGB(220, 60, 60),
				ErrorStrokeColor = Color3.fromRGB(248, 113, 113),
			}
		end
		-- The theme picked last time, or SpreadCheeks.
		local currentPalette = paletteNamed(featureSettings.theme) or themePalettes[1]

		local window = Rayfield:CreateWindow({
			name = "SpreadCheeksGUI",
			icon = spreadLogoLoaded and spreadLogo or nil,
			subtitle = "COMMAND CENTER",
			sidebarLayout = true,
			profile = tostring(#cmds) .. " commands loaded",
			theme = makeTheme(currentPalette),
			showName = "SpreadCheeksGUI",
			showIcon = spreadLogo,
		})
		-- When the window first appears. Rayfield grows it open and fades its own parts in from
		-- that moment; the Home page times its fade-in from it.
		local windowOpenedAt = nil
		if typeof(window.main) ~= "Instance" then
			windowOpenedAt = 0
		elseif window.main.Visible then
			windowOpenedAt = os.clock()
		else
			local openedConnection
			openedConnection = window.main:GetPropertyChangedSignal("Visible"):Connect(function()
				if window.main.Visible then
					openedConnection:Disconnect()
					windowOpenedAt = os.clock()
				end
			end)
		end
		local function restoreLogoPresentation()
			if window.topbarIcon then
				local logoTheme = window.themeProperties and window.themeProperties[window.topbarIcon]
				if logoTheme then
					logoTheme.ImageColor3 = nil
					if next(logoTheme) == nil then window.themeProperties[window.topbarIcon] = nil end
				end
				window.topbarIcon.ImageColor3 = Color3.new(1, 1, 1)
				window.topbarIcon.ScaleType = Enum.ScaleType.Fit
				window.topbarIcon.Size = UDim2.fromOffset(48, 32)
			end
			if window.collapsedIcon then
				local logoTheme = window.themeProperties and window.themeProperties[window.collapsedIcon]
				if logoTheme then
					logoTheme.ImageColor3 = nil
					if next(logoTheme) == nil then window.themeProperties[window.collapsedIcon] = nil end
				end
				window.collapsedIcon.ImageColor3 = Color3.new(1, 1, 1)
				window.collapsedIcon.ScaleType = Enum.ScaleType.Fit
				window.collapsedIcon.Size = UDim2.fromOffset(30, 30)
			end
			if window.collapsedText then
				window.collapsedText.Position = UDim2.new(0, 54, 0.5, 0)
			end
		end
		restoreLogoPresentation()
		updateAuxiliaryUiTheme(window.theme, currentPalette)

		-- Creates a Rayfield element (or tab) with a Lucide icon: pass an icon, or icon names to
		-- try in order. Rayfield draws the icon's whole sprite sheet, so the element's icon label
		-- is pointed at the icon's cell afterwards.
		local windowRoot = typeof(window.main) == "Instance" and (window.main:FindFirstAncestorWhichIsA("LayerCollector") or window.main) or nil
		local function withIcon(container, method, options, iconOrName, ...)
			local icon = type(iconOrName) == "table" and iconOrName or menuIcons.get(iconOrName, ...)
			options.icon = icon and icon.image or nil
			local element = container[method](container, options)
			if icon and type(element) == "table" then
				local label = element.iconLabel or element.topbarItemIcon
				if typeof(label) == "Instance" then
					label.ImageRectSize = icon.size
					label.ImageRectOffset = icon.offset
				end
				-- Anything else Rayfield drew from the same icon, such as a tab's page header.
				local root = method == "CreateTab" and windowRoot or element.main
				if typeof(root) == "Instance" then
					menuIcons.fitUnfitted(root, icon)
				end
			end
			return element
		end

		task.spawn(function()
			local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
			local previousToastGui = playerGui:FindFirstChild("SpreadCheeksNotifications")
			if previousToastGui then previousToastGui:Destroy() end
			local toastGui = Instance.new("ScreenGui")
			toastGui.Name = "SpreadCheeksNotifications"
			toastGui.ResetOnSpawn = false
			toastGui.IgnoreGuiInset = true
			toastGui.DisplayOrder = 10001
			toastGui.Parent = playerGui

			local toastWidth, toastPadding = 300, 14
			local maxVisibleToasts = 4

			local toastHolder = Instance.new("Frame")
			toastHolder.Name = "ToastHolder"
			toastHolder.AnchorPoint = Vector2.new(1, 0)
			toastHolder.Position = UDim2.new(1, -16, 0, 16)
			toastHolder.Size = UDim2.fromOffset(toastWidth, 500)
			toastHolder.BackgroundTransparency = 1
			toastHolder.Parent = toastGui

			local toastLayout = Instance.new("UIListLayout")
			toastLayout.Padding = UDim.new(0, 8)
			toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
			toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			toastLayout.Parent = toastHolder

			local toastSerial = 0
			local activeToasts = {}

			-- Fades every part of a toast between hidden (1) and its resting transparency.
			local function fadeToast(toast, visible, duration)
				local info = TweenInfo.new(duration, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
				for _, part in ipairs(toast.fadeParts) do
					TweenService:Create(part[1], info, { [part[2]] = visible and part[3] or 1 }):Play()
				end
			end

			-- Destroyed toast parts would otherwise sit in the theme bindings until the next theme change.
			local function pruneDeadThemeBindings()
				for index = #auxiliaryUiColorBindings, 1, -1 do
					if not auxiliaryUiColorBindings[index][1].Parent then
						table.remove(auxiliaryUiColorBindings, index)
					end
				end
			end

			local function dismissToast(toast)
				if toast.closing then return end
				toast.closing = true
				local index = table.find(activeToasts, toast)
				if index then table.remove(activeToasts, index) end
				fadeToast(toast, false, 0.18)
				TweenService:Create(toast.card, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					Position = UDim2.fromOffset(24, 0),
				}):Play()
				-- Collapse the empty slot afterwards so the toasts below slide up into place.
				task.delay(0.18, function()
					if not toast.slot.Parent then return end
					TweenService:Create(toast.slot, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = UDim2.new(1, 0, 0, 0),
					}):Play()
					task.delay(0.22, function()
						if toast.slot.Parent then toast.slot:Destroy() end
						pruneDeadThemeBindings()
					end)
				end)
			end

			notify = function(text, text2, length)
				toastSerial += 1
				local title = text2 and tostring(text or "Notification") or "SpreadCheeksGUI"
				local message = tostring(text2 or text or "")
				local duration = math.clamp(tonumber(length) or 4.5, 1.5, 12)
				-- Size the card to its text so one-word toasts stay small.
				local bodyHeight = 0
				if message ~= "" then
					local innerWidth = toastWidth - toastPadding * 2
					bodyHeight = math.min(TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(innerWidth, 1000)).Y, 64)
				end
				local height = 12 + 16 + (bodyHeight > 0 and bodyHeight + 4 or 0) + 14

				local slot = Instance.new("Frame")
				slot.Name = "ToastSlot"
				slot.Size = UDim2.new(1, 0, 0, height)
				slot.BackgroundTransparency = 1
				slot.LayoutOrder = -toastSerial
				slot.Parent = toastHolder

				-- The whole card is the button: click anywhere on a toast to dismiss it.
				local card = Instance.new("TextButton")
				card.Name = "Toast"
				card.AutoButtonColor = false
				card.Text = ""
				card.Position = UDim2.fromOffset(24, 0)
				card.Size = UDim2.new(1, 0, 0, height)
				card.BorderSizePixel = 0
				bindAuxiliaryUiColor(card, "BackgroundColor3", "Background")
				card.Parent = slot
				local cardCorner = Instance.new("UICorner")
				cardCorner.CornerRadius = UDim.new(0, 12)
				cardCorner.Parent = card
				local cardStroke = Instance.new("UIStroke")
				cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				bindAuxiliaryUiColor(cardStroke, "Color", "Stroke")
				cardStroke.Parent = card

				local dot = Instance.new("Frame")
				dot.AnchorPoint = Vector2.new(0, 0.5)
				dot.Position = UDim2.fromOffset(toastPadding, 20)
				dot.Size = UDim2.fromOffset(6, 6)
				dot.BorderSizePixel = 0
				bindAuxiliaryUiColor(dot, "BackgroundColor3", "Accent")
				dot.Parent = card
				local dotCorner = Instance.new("UICorner")
				dotCorner.CornerRadius = UDim.new(1, 0)
				dotCorner.Parent = dot

				local titleLabel = Instance.new("TextLabel")
				titleLabel.Position = UDim2.fromOffset(toastPadding + 14, 12)
				titleLabel.Size = UDim2.new(1, -(toastPadding * 2 + 14), 0, 16)
				titleLabel.BackgroundTransparency = 1
				titleLabel.Font = Enum.Font.GothamSemibold
				titleLabel.Text = title
				titleLabel.TextSize = 13
				titleLabel.TextXAlignment = Enum.TextXAlignment.Left
				titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
				bindAuxiliaryUiColor(titleLabel, "TextColor3", "Text")
				titleLabel.Parent = card

				local bodyLabel
				if bodyHeight > 0 then
					bodyLabel = Instance.new("TextLabel")
					bodyLabel.Position = UDim2.fromOffset(toastPadding, 32)
					bodyLabel.Size = UDim2.new(1, -toastPadding * 2, 0, bodyHeight)
					bodyLabel.BackgroundTransparency = 1
					bodyLabel.Font = Enum.Font.Gotham
					bodyLabel.Text = message
					bodyLabel.TextSize = 12
					bodyLabel.TextWrapped = true
					bodyLabel.TextTruncate = Enum.TextTruncate.AtEnd
					bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
					bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
					bindAuxiliaryUiColor(bodyLabel, "TextColor3", "SubText")
					bodyLabel.Parent = card
				end

				local progress = Instance.new("Frame")
				progress.Position = UDim2.new(0, toastPadding, 1, -6)
				progress.Size = UDim2.new(1, -toastPadding * 2, 0, 2)
				progress.BorderSizePixel = 0
				bindAuxiliaryUiColor(progress, "BackgroundColor3", "Accent")
				progress.Parent = card
				local progressCorner = Instance.new("UICorner")
				progressCorner.CornerRadius = UDim.new(1, 0)
				progressCorner.Parent = progress

				local toast = {
					slot = slot,
					card = card,
					fadeParts = {
						{ card, "BackgroundTransparency", 0.04 },
						{ cardStroke, "Transparency", 0.3 },
						{ dot, "BackgroundTransparency", 0 },
						{ titleLabel, "TextTransparency", 0 },
						{ progress, "BackgroundTransparency", 0.35 },
					},
				}
				if bodyLabel then
					table.insert(toast.fadeParts, { bodyLabel, "TextTransparency", 0 })
				end
				for _, part in ipairs(toast.fadeParts) do
					part[1][part[2]] = 1
				end

				card.MouseEnter:Connect(function() cardStroke.Color = auxiliaryUiTheme.Accent end)
				card.MouseLeave:Connect(function() cardStroke.Color = auxiliaryUiTheme.Stroke end)
				card.Activated:Connect(function() dismissToast(toast) end)

				-- Keep the stack short when toasts arrive quickly (e.g. tapping keybinds).
				table.insert(activeToasts, toast)
				if #activeToasts > maxVisibleToasts then
					dismissToast(activeToasts[1])
				end

				fadeToast(toast, true, 0.25)
				TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = UDim2.fromOffset(0, 0),
				}):Play()
				TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
					Size = UDim2.new(0, 0, 0, 2),
				}):Play()
				task.delay(duration, function() dismissToast(toast) end)
			end
		end)
		local commandList = {}
		for _, command in ipairs(cmds) do
			if type(command) == "table" and type(command.NAME) == "string" then
				table.insert(commandList, command)
			end
		end
		table.sort(commandList, function(left, right)
			return left.NAME:lower() < right.NAME:lower()
		end)

		local categories = {
			{ name = "Movement", icon = "move", section = "Movement & physics" },
			{ name = "Teleport", icon = "map-pin", section = "Waypoints & travel" },
			{ name = "Camera", icon = "camera", section = "Camera controls" },
			{ name = "Character", icon = "user-round", section = "Character actions" },
			{ name = "Visuals", icon = "eye", section = "Visuals & overlays" },
			{ name = "World", icon = "box", section = "World tools" },
			{ name = "Utility", icon = "wrench", section = "Session & utilities" },
		}
		local commandsByCategory = {}
		for _, category in ipairs(categories) do
			commandsByCategory[category.name] = {}
		end

		local function containsAny(value, words)
			for _, word in ipairs(words) do
				if string.find(value, word, 1, true) then return true end
			end
			return false
		end

		local function categoryForCommand(commandName)
			local name = commandName:lower()
			if containsAny(name, { "freecam", "camera", "cam", "fov", "view", "lookat", "zoom", "shiftlock", "firstp", "thirdp" }) then
				return "Camera"
			elseif containsAny(name, { "goto", "teleport", "waypoint", "tpposition", "tppos", "bring", "walkto", "joinplayer", "pulsetp" }) then
				return "Teleport"
			elseif containsAny(name, { "esp", "chams", "locate", "invis", "visible", "render", "2022materials", "partpath", "nobgui", "gui" }) then
				return "Visuals"
			elseif containsAny(name, { "anim", "dance", "limb", "head", "arms", "legs", "god", "sit", "lay", "respawn", "reset", "team" }) then
				return "Character"
			elseif containsAny(name, { "fly", "noclip", "clip", "float", "swim", "speed", "jump", "gravity", "hipheight", "slope", "walk", "velocity", "freeze", "thaw", "strength", "weaken" }) then
				return "Movement"
			elseif containsAny(name, { "delete", "part", "btools", "f3x", "workspace", "lockws", "unlockws", "prompt", "replication", "datalimit" }) then
				return "World"
			end
			return "Utility"
		end

		for _, command in ipairs(commandList) do
			local categoryName = categoryForCommand(command.NAME)
			table.insert(commandsByCategory[categoryName], command)
		end

		-- Home is created first so it's the page the menu opens on; its cards are filled in at the
		-- end, once everything they report on exists.
		window:CreateSection({ name = "OVERVIEW" })
		local homeTab = withIcon(window, "CreateTab", { name = "Home" }, "house", "home", "layout-grid")

		-- Quick controls are split into tabs by what they're for, like the admin commands. Rayfield
		-- lists a tab's rows in the order they're made and each tab keeps its own order, so rows are
		-- added to their tab further down as the code that needs them comes along. The names differ
		-- from the admin command tabs (Movement, Camera...) so no two tabs share a name.
		window:CreateSection({ name = "QUICK CONTROLS" })
		local mobilityTab = withIcon(window, "CreateTab", { name = "Mobility" }, "move", "footprints")
		local combatTab = withIcon(window, "CreateTab", { name = "Combat" }, "swords", "crosshair")
		local viewTab = withIcon(window, "CreateTab", { name = "View" }, "aperture", "eye")
		local protectionTab = withIcon(window, "CreateTab", { name = "Protection" }, "shield")
		local interfaceTab = withIcon(window, "CreateTab", { name = "Interface" }, "layout-dashboard", "app-window")
		-- Rayfield's gear button opens this built-in tab; keep appearance options there.
		withIcon(window.rfSettings, "CreateSection", { name = "Appearance" }, "palette")
		local themeNames = {}
		for _, palette in ipairs(themePalettes) do
			table.insert(themeNames, palette.name)
		end
		withIcon(window.rfSettings, "CreateDropdown", {
			name = "Theme",
			description = "The colours for this menu and its windows. Frost, Daylight and Sakura are light. Remembered between sessions.",
			options = themeNames,
			value = currentPalette.name,
			callback = function(value)
				if type(value) == "table" then value = value[1] end
				local palette = paletteNamed(tostring(value))
				if not palette then return end
				currentPalette = palette
				window:ChangeTheme(makeTheme(palette))
				restoreLogoPresentation()
				updateAuxiliaryUiTheme(window.theme, palette)
				if featureSettings.theme ~= palette.name then
					featureSettings.theme = palette.name
					saveFeatureSettings()
				end
			end,
		}, "palette")
		-- Quick toggles register here so a keybind can flip them and keep the
		-- switch in the menu showing the right state.
		local quickToggles = {}
		local quickToggleByName = {}

		local function addQuickToggle(tab, name, description, apply, ...)
			-- icons is kept for the Home page, which shows what's switched on.
			local entry = { name = name, state = false, key = nil, icons = { ... } }
			-- The switch callback and keybinds both land here, and Rayfield may or
			-- may not re-fire the callback on :Set, so repeat calls are no-ops.
			function entry.apply(enabled)
				enabled = enabled == true
				if enabled == entry.state then return end
				entry.state = enabled
				if apply(enabled) == false then
					entry.state = false
					pcall(function() entry.object:Set(false, true) end)
				end
			end
			entry.object = withIcon(tab, "CreateToggle", {
				name = name,
				description = description,
				value = false,
				callback = entry.apply,
			}, ...)
			table.insert(quickToggles, entry)
			quickToggleByName[name] = entry
		end

		local function addCommandToggle(tab, name, enabledCommand, disabledCommand, description, ...)
			addQuickToggle(tab, name, description, function(enabled)
				execCmd(enabled and enabledCommand or disabledCommand, Players.LocalPlayer, true)
			end, ...)
		end

		-- Turns a quick toggle on or off from code, moving its switch to match.
		local function setQuickToggle(entry, enabled)
			entry.apply(enabled)
			pcall(function() entry.object:Set(entry.state, true) end)
		end

		local noFallState = {
			enabled = false,
			rootConnection = nil,
			characterConnection = nil,
		}
		local function clearNoFallRoot()
			if noFallState.rootConnection then
				noFallState.rootConnection:Disconnect()
				noFallState.rootConnection = nil
			end
		end
		local function bindNoFallCharacter(character)
			clearNoFallRoot()
			if not noFallState.enabled then return end
			local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
			if not noFallState.enabled or not root or not root:IsA("BasePart") then return end
			noFallState.rootConnection = RunService.Heartbeat:Connect(function()
				if not root.Parent then
					clearNoFallRoot()
					return
				end
				local velocity = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.zero
				RunService.RenderStepped:Wait()
				if noFallState.enabled and root.Parent then
					root.AssemblyLinearVelocity = velocity
				end
			end)
		end
		local function setNoFall(enabled)
			if enabled and game.PlaceId ~= 189707 then
				notify("No Fall Damage", "This option only works in Natural Disaster Survival.")
				return false
			end
			noFallState.enabled = enabled
			if enabled then
				local character = Players.LocalPlayer.Character
				if character then task.spawn(bindNoFallCharacter, character) end
				if not noFallState.characterConnection then
					noFallState.characterConnection = Players.LocalPlayer.CharacterAdded:Connect(bindNoFallCharacter)
				end
			else
				if noFallState.characterConnection then
					noFallState.characterConnection:Disconnect()
					noFallState.characterConnection = nil
				end
				clearNoFallRoot()
			end
		end

		-- Fly and Vehicle Fly share one flight system, so starting one replaces the other; the
		-- other's switch just goes off without running its stop command.
		local function markOff(name)
			local other = quickToggleByName[name]
			if other and other.state then
				other.state = false
				pcall(function() other.object:Set(false, true) end)
			end
		end
		-- Mobility: flying and getting around. Its speed and gravity sliders are added further down.
		withIcon(mobilityTab, "CreateSection", { name = "Flight" }, "plane")
		addQuickToggle(mobilityTab, "Fly", "Right-click for fly speed and controls", function(enabled)
			if enabled then markOff("Vehicle Fly") end
			execCmd(enabled and "fly" or "unfly", Players.LocalPlayer, true)
		end, "plane")
		addQuickToggle(mobilityTab, "Vehicle Fly", "Fly the vehicle you're sitting in. Right-click for its speed", function(enabled)
			if enabled then markOff("Fly") end
			execCmd(enabled and "vfly" or "unvfly", Players.LocalPlayer, true)
		end, "car")
		withIcon(mobilityTab, "CreateSection", { name = "Getting around" }, "footprints")
		addCommandToggle(mobilityTab, "Noclip", "noclip", "clip", nil, "ghost")
		addCommandToggle(mobilityTab, "Infinite Jump", "infjump", "uninfjump", nil, "chevrons-up")

		-- Combat: seeing and aiming at players, then flinging them.
		withIcon(combatTab, "CreateSection", { name = "ESP & aim" }, "scan-eye")
		addCommandToggle(combatTab, "ESP", "esp", "noesp", "Right-click or use the arrow for ESP settings", "scan-eye")
		-- ESP's row has the settings arrow where the key box would go, so it gets no keybind.
		quickToggleByName["ESP"].noKeybind = true
		-- Aimbot sits right under ESP. Rayfield lists rows in the order they're made, so its switch
		-- is made here; the aim key box, its settings and the aiming itself come from buildAimbot
		-- further down, once everything they use exists.
		local aimbotState = { enabled = false, held = false, target = nil }
		local function aimbotKeyText()
			local name = featureSettings.aimbotKey
			return name == "RightClick" and "RMB" or name == "LeftClick" and "LMB" or name
		end
		local aimbotToggle = withIcon(combatTab, "CreateToggle", {
			name = "Aimbot",
			description = "Hold the key to aim. Right-click for settings",
			value = false,
			callback = function(enabled)
				enabled = enabled == true
				if enabled == aimbotState.enabled then return end
				aimbotState.enabled = enabled
				aimbotState.held = false
				aimbotState.target = nil
				if enabled then
					notify("Aimbot", "Hold " .. aimbotKeyText() .. " to aim", 2.5)
				end
			end,
		}, "crosshair")
		-- Trigger Bot fires for you while your crosshair is on another player. Its switch is made
		-- here, under Aimbot, so it gets a key box; the rest comes from buildTriggerBot further down.
		local triggerBotState = { enabled = false, stop = nil }
		addQuickToggle(combatTab, "Trigger Bot", "Fires when your crosshair is on a player. Right-click for settings", function(enabled)
			triggerBotState.enabled = enabled
			-- Lets go of the mouse if it was holding it down for you.
			if not enabled and triggerBotState.stop then triggerBotState.stop() end
		end, "mouse-pointer-click", "target")
		addCommandToggle(combatTab, "Chams", "chams", "nochams", "Right-click for fill strength", "person-standing")
		withIcon(combatTab, "CreateSection", { name = "Fling" }, "tornado")
		addCommandToggle(combatTab, "Fling", "fling", "unfling", nil, "tornado")
		-- Walk Fling and No Fall Damage both rewrite the character's velocity every frame and
		-- undo each other, so No Fall Damage pauses while Walk Fling is on and comes back
		-- afterwards if it was on before.
		local restoreNoFall = false
		addQuickToggle(combatTab, "Walk Fling", "Pauses No Fall Damage while it runs", function(enabled)
			local noFall = quickToggleByName["No Fall Damage"]
			if enabled then
				if noFall and noFall.state then
					restoreNoFall = true
					setQuickToggle(noFall, false)
					notify("No Fall Damage", "Paused while Walk Fling is on", 2.5)
				end
				execCmd("walkfling", Players.LocalPlayer, true)
			else
				execCmd("unwalkfling", Players.LocalPlayer, true)
				if restoreNoFall and noFall then
					-- Give the fling loop a moment to finish its last frame first. If Walk Fling
					-- is back on by then, No Fall Damage waits for it to go off again.
					task.delay(0.25, function()
						if restoreNoFall and not quickToggleByName["Walk Fling"].state then
							restoreNoFall = false
							if not noFall.state then
								setQuickToggle(noFall, true)
								notify("No Fall Damage", "Back on", 2)
							end
						end
					end)
				end
			end
		end, "footprints")

		-- View: the camera. The Field of View slider is added further down.
		withIcon(viewTab, "CreateSection", { name = "Camera" }, "camera")
		addCommandToggle(viewTab, "Freecam", "freecam", "unfreecam", "Right-click for freecam speed", "video")
		addCommandToggle(viewTab, "First Person", "firstp", "thirdp", nil, "glasses", "eye")

		-- Protection: staying safe and unseen.
		withIcon(protectionTab, "CreateSection", { name = "Safety" }, "shield-check", "shield")
		local function setAntiFling(enabled)
			local command = findCmd(enabled and "antifling" or "unantifling")
			if command and command.FUNC then
				command.FUNC({}, Players.LocalPlayer)
			end
		end
		addQuickToggle(protectionTab, "Anti-Fling", "Toggle Infinite Yield's Anti-Fling module", setAntiFling, "shield")
		addQuickToggle(protectionTab, "No Fall Damage", "Prevents fall damage in Natural Disaster Survival", setNoFall, "feather")
		withIcon(protectionTab, "CreateSection", { name = "Stealth" }, "eye-off")
		addCommandToggle(protectionTab, "Invisible", "invisible", "visible", nil, "eye-off")
		-- Cheater Detector warns you about players who move like cheaters. Its switch is made here,
		-- with the others, so it gets a key box; the watching is built further down
		-- (buildCheaterDetector), and it's remembered between sessions.
		withIcon(protectionTab, "CreateSection", { name = "Awareness" }, "radar", "scan-eye")
		local cheaterDetector = nil
		addQuickToggle(protectionTab, "Cheater Detector", "Warns you when someone moves like a cheater. Right-click for settings", function(enabled)
			if featureSettings.cheatDetector ~= enabled then
				featureSettings.cheatDetector = enabled
				saveFeatureSettings()
			end
			if cheaterDetector then cheaterDetector.setEnabled(enabled) end
		end, "radar", "siren", "shield-alert")

		-- Interface: windows on screen, keybinds and extras. Performance Stats is made here, with the
		-- other switches, so it gets a key box; its window is built further down (buildPerformanceStats).
		withIcon(interfaceTab, "CreateSection", { name = "Overlays" }, "layers", "app-window")
		local performanceStats = nil
		addQuickToggle(interfaceTab, "Performance Stats", "FPS, ping and more in a window of their own. Drag it to move it", function(enabled)
			if featureSettings.performanceStats ~= enabled then
				featureSettings.performanceStats = enabled
				saveFeatureSettings()
			end
			if performanceStats then performanceStats.setShown(enabled) end
		end, "activity", "gauge")

		local keybindFile = "SpreadCheeksGUI_Keybinds.json"
		-- Semicolon opens the quick command bar; Escape and Backspace are used while capturing.
		local reservedKeys = {
			[Enum.KeyCode.Semicolon] = true,
			[Enum.KeyCode.Escape] = true,
			[Enum.KeyCode.Backspace] = true,
			[Enum.KeyCode.Unknown] = true,
		}

		local function saveQuickKeybinds()
			if not writefile then return end
			local data = {}
			for _, entry in ipairs(quickToggles) do
				if entry.key then data[entry.name] = entry.key.Name end
			end
			writefile(keybindFile, HttpService:JSONEncode(data), true)
		end

		local function loadQuickKeybinds()
			if not readfile then return end
			local readOk, contents = readfile(keybindFile, true)
			if not readOk or type(contents) ~= "string" or contents == "" then return end
			local decodeOk, data = pcall(function() return HttpService:JSONDecode(contents) end)
			if not decodeOk or type(data) ~= "table" then return end
			for name, keyName in pairs(data) do
				local entry = quickToggleByName[name]
				local keyOk, keyCode = pcall(function() return Enum.KeyCode[keyName] end)
				if entry and not entry.noKeybind and keyOk and keyCode and not reservedKeys[keyCode] then
					entry.key = keyCode
				end
			end
		end
		loadQuickKeybinds()

		local capturingEntry = nil
		local captureSerial = 0

		local function isMenuToggleKey(keyCode)
			local ok, menuKey = pcall(function() return window.settings.toggleKeybind end)
			return ok and menuKey == keyCode
		end

		local function refreshKeyChip(entry)
			local chip = entry.chip
			if not chip then return end
			local recording = capturingEntry == entry
			local text = recording and "Recording" or (entry.key and entry.key.Name or "None")
			local textWidth = TextService:GetTextSize(text, chip.TextSize, chip.Font, Vector2.new(1000, 24)).X
			chip.Text = text
			chip.Size = UDim2.fromOffset(math.clamp(textWidth + 22, 40, 130), 24)
			chip.TextTransparency = (entry.key or recording) and 0 or 0.45
			entry.chipStroke.Color = recording and auxiliaryUiTheme.Accent or auxiliaryUiTheme.Stroke
			entry.chipStroke.Transparency = recording and 0 or 0.35
		end

		local function stopKeyRecording()
			local entry = capturingEntry
			capturingEntry = nil
			if entry then refreshKeyChip(entry) end
		end

		local function startKeyRecording(entry)
			stopKeyRecording()
			captureSerial += 1
			local serial = captureSerial
			capturingEntry = entry
			refreshKeyChip(entry)
			-- Stop waiting if no key arrives, so a stray press later doesn't rebind.
			task.delay(10, function()
				if captureSerial == serial and capturingEntry == entry then
					stopKeyRecording()
				end
			end)
		end

		-- Each toggle row gets a key box just left of its switch, styled like
		-- Rayfield's own keybind box. Click it, then press a key.
		for _, entry in ipairs(quickToggles) do
			local row = entry.object and entry.object.main
			if entry.noKeybind then
				-- No key box on this row.
			elseif typeof(row) == "Instance" then
				local chip = Instance.new("TextButton")
				chip.Name = "KeybindChip"
				chip.AnchorPoint = Vector2.new(1, 0.5)
				-- Rayfield's switch is 50px wide and sits 15px in from the row's right edge.
				chip.Position = UDim2.new(1, -73, 0, 20)
				chip.AutoButtonColor = false
				chip.BorderSizePixel = 0
				chip.Font = Enum.Font.GothamMedium
				chip.TextSize = 13
				-- Above the toggle's full-row click target (ZIndex 10) so clicking the box doesn't flip the switch.
				chip.ZIndex = 11
				bindAuxiliaryUiColor(chip, "BackgroundColor3", "Inset")
				bindAuxiliaryUiColor(chip, "TextColor3", "Text")
				local chipCorner = Instance.new("UICorner")
				chipCorner.CornerRadius = UDim.new(1, 0)
				chipCorner.Parent = chip
				local chipStroke = Instance.new("UIStroke")
				chipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				bindAuxiliaryUiColor(chipStroke, "Color", "Stroke")
				chipStroke.Parent = chip
				entry.chip = chip
				entry.chipStroke = chipStroke
				chip.MouseButton1Click:Connect(function()
					if capturingEntry == entry then
						stopKeyRecording()
					else
						startKeyRecording(entry)
					end
				end)
				chip.Parent = row
				refreshKeyChip(entry)
			else
				warn("[SpreadCheeksGUI] Couldn't add a key box to " .. entry.name .. "; Rayfield's toggle layout may have changed.")
			end
		end

		local function flipQuickToggle(entry)
			entry.apply(not entry.state)
			pcall(function() entry.object:Set(entry.state, true) end)
			notify(entry.name, entry.state and "On" or "Off", 1.5)
		end

		local sharedEnv = (type(getgenv) == "function" and getgenv()) or _G
		if sharedEnv.SpreadCheeksKeybindConnection then
			pcall(function() sharedEnv.SpreadCheeksKeybindConnection:Disconnect() end)
		end
		sharedEnv.SpreadCheeksKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if UserInputService:GetFocusedTextBox() then return end

			if capturingEntry then
				local entry = capturingEntry
				local keyCode = input.KeyCode
				if keyCode == Enum.KeyCode.Escape or keyCode == Enum.KeyCode.Backspace then
					entry.key = nil
				else
					-- Refused keys keep the box recording so another key can be tried.
					if reservedKeys[keyCode] then
						notify("Keybinds", keyCode.Name .. " is reserved, pick another key")
						return
					elseif isMenuToggleKey(keyCode) then
						notify("Keybinds", keyCode.Name .. " already opens and closes the menu, pick another key")
						return
					end
					-- One key drives one control; take it from whichever had it before.
					for _, other in ipairs(quickToggles) do
						if other ~= entry and other.key == keyCode then
							other.key = nil
							refreshKeyChip(other)
						end
					end
					entry.key = keyCode
				end
				stopKeyRecording()
				saveQuickKeybinds()
				return
			end

			if gameProcessed then return end
			for _, entry in ipairs(quickToggles) do
				if entry.key == input.KeyCode then
					flipQuickToggle(entry)
				end
			end
		end)

		-- Keybind list: a small panel on screen with every key that does something, and a switch
		-- on the ones that turn a feature on and off. Drag it anywhere; the Keybind List switch
		-- in this section shows or hides it.
		local function buildKeybindList()
			local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
			local previousGui = playerGui:FindFirstChild("SpreadCheeksKeybindList")
			if previousGui then previousGui:Destroy() end
			-- Kept in the shared environment so running the script again drops the old listeners.
			if sharedEnv.SpreadCheeksKeybindListConnections then
				for _, connection in ipairs(sharedEnv.SpreadCheeksKeybindListConnections) do
					pcall(function() connection:Disconnect() end)
				end
			end
			local connections = {}
			sharedEnv.SpreadCheeksKeybindListConnections = connections

			local headerHeight, rowHeight, rowGap, padding = 36, 28, 4, 8

			local gui = Instance.new("ScreenGui")
			gui.Name = "SpreadCheeksKeybindList"
			gui.ResetOnSpawn = false
			gui.IgnoreGuiInset = true
			-- Under the ; bar (1000) and the notifications (10001).
			gui.DisplayOrder = 999
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Enabled = false
			gui.Parent = playerGui

			-- The panel is a button so clicking it doesn't reach the game, and it's what gets dragged.
			local panel = Instance.new("TextButton")
			panel.Name = "KeybindList"
			panel.AutoButtonColor = false
			panel.Text = ""
			panel.BackgroundTransparency = 0.04
			panel.BorderSizePixel = 0
			panel.ClipsDescendants = true
			panel.Size = UDim2.fromOffset(200, headerHeight + rowHeight + padding)
			bindAuxiliaryUiColor(panel, "BackgroundColor3", "Background")
			panel.Parent = gui
			local panelCorner = Instance.new("UICorner")
			panelCorner.CornerRadius = UDim.new(0, 12)
			panelCorner.Parent = panel
			local panelStroke = Instance.new("UIStroke")
			panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			panelStroke.Transparency = 0.3
			bindAuxiliaryUiColor(panelStroke, "Color", "Stroke")
			panelStroke.Parent = panel

			-- Header: the logo (or a keyboard icon), the title and how many keys are listed.
			local headerIcon = Instance.new("ImageLabel")
			headerIcon.AnchorPoint = Vector2.new(0, 0.5)
			headerIcon.Position = UDim2.new(0, 12, 0, headerHeight / 2)
			headerIcon.BackgroundTransparency = 1
			if spreadLogoLoaded then
				-- A little wider than tall, since the logo is wide in the menu's top bar.
				headerIcon.Size = UDim2.fromOffset(24, 20)
				headerIcon.Image = spreadLogo
				headerIcon.ScaleType = Enum.ScaleType.Fit
			else
				headerIcon.Size = UDim2.fromOffset(15, 15)
				local icon = menuIcons.get("keyboard")
				if icon then menuIcons.apply(headerIcon, icon) end
				bindAuxiliaryUiColor(headerIcon, "ImageColor3", "AccentText")
			end
			headerIcon.Parent = panel
			local titleX = 12 + headerIcon.Size.X.Offset + 8
			local title = Instance.new("TextLabel")
			title.AnchorPoint = Vector2.new(0, 0.5)
			title.Position = UDim2.new(0, titleX, 0, headerHeight / 2)
			title.Size = UDim2.new(1, -(titleX + 46), 0, 16)
			title.BackgroundTransparency = 1
			title.Font = Enum.Font.GothamBold
			title.Text = "Active Keybinds"
			title.TextSize = 13
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.TextTruncate = Enum.TextTruncate.AtEnd
			bindAuxiliaryUiColor(title, "TextColor3", "Text")
			title.Parent = panel
			local countPill = Instance.new("TextLabel")
			countPill.AnchorPoint = Vector2.new(1, 0.5)
			countPill.Position = UDim2.new(1, -10, 0, headerHeight / 2)
			countPill.Size = UDim2.fromOffset(24, 18)
			countPill.BorderSizePixel = 0
			countPill.Font = Enum.Font.GothamBold
			countPill.Text = "0"
			countPill.TextSize = 11
			bindAuxiliaryUiColor(countPill, "BackgroundColor3", "Inset")
			bindAuxiliaryUiColor(countPill, "TextColor3", "SubText")
			countPill.Parent = panel
			local countCorner = Instance.new("UICorner")
			countCorner.CornerRadius = UDim.new(1, 0)
			countCorner.Parent = countPill
			local countStroke = Instance.new("UIStroke")
			countStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			countStroke.Transparency = 0.35
			bindAuxiliaryUiColor(countStroke, "Color", "Stroke")
			countStroke.Parent = countPill

			local list = Instance.new("Frame")
			list.Name = "Rows"
			list.Position = UDim2.fromOffset(padding, headerHeight)
			list.Size = UDim2.new(1, -padding * 2, 1, -(headerHeight + padding))
			list.BackgroundTransparency = 1
			list.Parent = panel
			local listLayout = Instance.new("UIListLayout")
			listLayout.Padding = UDim.new(0, rowGap)
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Parent = list
			local emptyLabel = Instance.new("TextLabel")
			emptyLabel.Size = UDim2.new(1, 0, 0, rowHeight)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Font = Enum.Font.Gotham
			emptyLabel.Text = "No keybinds set yet"
			emptyLabel.TextSize = 12
			emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
			emptyLabel.Visible = false
			bindAuxiliaryUiColor(emptyLabel, "TextColor3", "SubText")
			emptyLabel.Parent = list

			local function textWidth(text, font, size)
				return TextService:GetTextSize(text, size, font, Vector2.new(1000, 100)).X
			end
			-- Short names for keys whose KeyCode name is long or spelled out.
			local keyLabels = {
				Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
				Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
				LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl",
				LeftAlt = "LAlt", RightAlt = "RAlt", LeftSuper = "Win", RightSuper = "Win", CapsLock = "Caps",
				Return = "Enter", PageUp = "PgUp", PageDown = "PgDn", Insert = "Ins", Delete = "Del",
				Backquote = "`", Minus = "-", Equals = "=", LeftBracket = "[", RightBracket = "]",
				BackSlash = "\\", Quote = "'", Comma = ",", Period = ".", Slash = "/",
				LeftClick = "LMB", RightClick = "RMB",
			}
			local function keyLabel(keyName)
				if keyLabels[keyName] then return keyLabels[keyName] end
				local keypadKey = keyName:match("^Keypad(.+)$")
				if keypadKey then return "Num" .. (keyLabels[keypadKey] or keypadKey) end
				return keyName
			end

			-- Other parts of the menu (the aimbot) add their keys through addSource: each source
			-- returns a row, or nil while its key does nothing.
			local extraSources = {}

			-- Everything a key does right now: the menu key, the Controls switches, other sources,
			-- then binds made in Infinite Yield's own keybind editor. Each row: name, key, kind and,
			-- for switches, on.
			local function collectRows()
				local rows = {}
				local menuKeyOk, menuKey = pcall(function() return window.settings.toggleKeybind end)
				local menuKeyName = menuKeyOk and (typeof(menuKey) == "EnumItem" and menuKey.Name or (type(menuKey) == "string" and menuKey)) or nil
				if menuKeyName and menuKeyName ~= "" then
					table.insert(rows, { name = "Menu", key = menuKeyName, kind = "toggle", on = not window.hidden })
				end
				for _, entry in ipairs(quickToggles) do
					if entry.key then
						table.insert(rows, { name = entry.name, key = entry.key.Name, kind = "toggle", on = entry.state })
					end
				end
				for _, source in ipairs(extraSources) do
					local sourceOk, row = pcall(source)
					if sourceOk and type(row) == "table" then
						table.insert(rows, row)
					end
				end
				if type(binds) == "table" then
					for _, bind in ipairs(binds) do
						local rawKey = tostring(bind.KEY)
						local key = (rawKey == "LeftClick" or rawKey == "RightClick") and rawKey or rawKey:match("^Enum%.KeyCode%.(.+)$")
						local command = type(bind.COMMAND) == "string" and bind.COMMAND or nil
						if key and command then
							-- One bind can run several commands, split with a backslash.
							local row = { key = key, name = (command:gsub("\\", " + "):gsub("^%l", string.upper)), kind = "run" }
							if command == "clicktp" or command == "clickdel" then
								-- These work while the key is held down and you click.
								row.name = command == "clicktp" and "Click Teleport" or "Click Delete"
								row.kind = "hold"
							elseif bind.TOGGLE then
								row.kind = "toggle"
								row.on = type(toggleOn) == "table" and toggleOn[bind] == true
							end
							table.insert(rows, row)
						end
					end
				end
				return rows
			end

			local function makeBadge(parent, text, textSize, textRole)
				local badge = Instance.new("TextLabel")
				badge.AnchorPoint = Vector2.new(1, 0.5)
				badge.Size = UDim2.fromOffset(math.max(20, textWidth(text, Enum.Font.GothamBold, textSize) + 12), 18)
				badge.BorderSizePixel = 0
				badge.Font = Enum.Font.GothamBold
				badge.Text = text
				badge.TextSize = textSize
				bindAuxiliaryUiColor(badge, "BackgroundColor3", "Inset")
				bindAuxiliaryUiColor(badge, "TextColor3", textRole)
				local badgeCorner = Instance.new("UICorner")
				badgeCorner.CornerRadius = UDim.new(0, 5)
				badgeCorner.Parent = badge
				local badgeStroke = Instance.new("UIStroke")
				badgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				badgeStroke.Transparency = 0.35
				bindAuxiliaryUiColor(badgeStroke, "Color", "Stroke")
				badgeStroke.Parent = badge
				badge.Parent = parent
				return badge
			end

			local function buildRow(data, order)
				local view = { data = data, on = data.on == true }
				local row = Instance.new("Frame")
				row.LayoutOrder = order
				row.Size = UDim2.new(1, 0, 0, rowHeight)
				row.BorderSizePixel = 0
				bindAuxiliaryUiColor(row, "BackgroundColor3", "Card")
				local rowCorner = Instance.new("UICorner")
				rowCorner.CornerRadius = UDim.new(0, 8)
				rowCorner.Parent = row
				local rowStroke = Instance.new("UIStroke")
				rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				rowStroke.Transparency = 0.5
				bindAuxiliaryUiColor(rowStroke, "Color", "Stroke")
				rowStroke.Parent = row
				-- From the right: the key, then the switch or what the key does.
				local keyBadge = makeBadge(row, keyLabel(data.key), 11, "Text")
				keyBadge.Position = UDim2.new(1, -5, 0.5, 0)
				local used = 5 + keyBadge.Size.X.Offset + 6
				if data.kind == "toggle" then
					local track = Instance.new("Frame")
					track.AnchorPoint = Vector2.new(1, 0.5)
					track.Position = UDim2.new(1, -used, 0.5, 0)
					track.Size = UDim2.fromOffset(28, 16)
					track.BorderSizePixel = 0
					track.Parent = row
					local trackCorner = Instance.new("UICorner")
					trackCorner.CornerRadius = UDim.new(1, 0)
					trackCorner.Parent = track
					local trackStroke = Instance.new("UIStroke")
					trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					trackStroke.Parent = track
					local knob = Instance.new("Frame")
					knob.AnchorPoint = Vector2.new(0, 0.5)
					knob.Size = UDim2.fromOffset(12, 12)
					knob.BorderSizePixel = 0
					knob.Parent = track
					local knobCorner = Instance.new("UICorner")
					knobCorner.CornerRadius = UDim.new(1, 0)
					knobCorner.Parent = knob
					view.track, view.trackStroke, view.knob = track, trackStroke, knob
					used += 28
				else
					local tag = makeBadge(row, data.kind == "hold" and "HOLD" or "RUN", 10, "SubText")
					tag.Position = UDim2.new(1, -used, 0.5, 0)
					used += tag.Size.X.Offset
				end
				local nameLabel = Instance.new("TextLabel")
				nameLabel.Position = UDim2.fromOffset(10, 0)
				nameLabel.Size = UDim2.new(1, -(10 + used + 8), 1, 0)
				nameLabel.BackgroundTransparency = 1
				nameLabel.Font = Enum.Font.GothamMedium
				nameLabel.Text = data.name
				nameLabel.TextSize = 12
				nameLabel.TextXAlignment = Enum.TextXAlignment.Left
				nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
				bindAuxiliaryUiColor(nameLabel, "TextColor3", "Text")
				nameLabel.Parent = row
				row.Parent = list
				view.row, view.rowStroke, view.keyBadge = row, rowStroke, keyBadge
				view.width = 10 + textWidth(data.name, Enum.Font.GothamMedium, 12) + 8 + used
				return view
			end

			-- Switch colours depend on state, so they're set here rather than bound to a theme role.
			local function showState(view, animate)
				if not view.track then return end
				local theme = auxiliaryUiTheme
				local on = view.on
				local goals = {
					{ view.track, { BackgroundColor3 = on and theme.Accent or theme.Inset } },
					{ view.trackStroke, { Color = on and theme.Accent or theme.Stroke } },
					{ view.knob, {
						BackgroundColor3 = on and Color3.new(1, 1, 1) or theme.SubText,
						Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
					} },
				}
				for _, goal in ipairs(goals) do
					if animate then
						TweenService:Create(goal[1], TweenInfo.new(0.15, Enum.EasingStyle.Quad), goal[2]):Play()
					else
						for property, value in pairs(goal[2]) do
							goal[1][property] = value
						end
					end
				end
			end

			-- A pressed key lights up its row for a moment.
			local flashInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local function flash(view)
				local theme = auxiliaryUiTheme
				view.keyBadge.BackgroundColor3 = theme.Accent
				view.keyBadge.TextColor3 = theme.OnAccent
				view.rowStroke.Color = theme.Accent
				TweenService:Create(view.keyBadge, flashInfo, { BackgroundColor3 = theme.Inset, TextColor3 = theme.Text }):Play()
				TweenService:Create(view.rowStroke, flashInfo, { Color = theme.Stroke }):Play()
			end

			local rowViews = {}
			local signature = nil
			local shown, ready, wantShown = false, false, false
			local dragInput, dragFrom, panelFrom = nil, nil, nil
			local hovering = false
			local panelSize = Vector2.new(200, headerHeight + rowHeight + padding)
			local sizeTween = nil

			local function screenSize()
				local camera = workspace.CurrentCamera
				return camera and camera.ViewportSize or gui.AbsoluteSize
			end
			local function clampToScreen(x, y)
				local screen = screenSize()
				x = math.clamp(x, 0, math.max(0, screen.X - panelSize.X))
				y = math.clamp(y, 0, math.max(0, screen.Y - panelSize.Y))
				return UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
			end
			-- Where it was dragged to is kept as a share of the screen, so it stays put at any size.
			local function placePanel()
				local screen = screenSize()
				if featureSettings.keybindListX >= 0 and featureSettings.keybindListY >= 0 then
					panel.Position = clampToScreen(featureSettings.keybindListX * screen.X, featureSettings.keybindListY * screen.Y)
				else
					panel.Position = clampToScreen(16, screen.Y * 0.36)
				end
			end

			local function refresh()
				local rows = collectRows()
				local lines = {}
				for _, data in ipairs(rows) do
					table.insert(lines, data.kind .. "|" .. data.key .. "|" .. data.name)
				end
				local newSignature = table.concat(lines, "\n")
				if newSignature == signature then
					-- Same keys as before, so only switches can have changed.
					for index, view in ipairs(rowViews) do
						local on = rows[index].on == true
						if on ~= view.on then
							view.on = on
							showState(view, true)
						end
					end
					return
				end
				local animate = signature ~= nil and shown
				signature = newSignature
				for _, view in ipairs(rowViews) do
					view.row:Destroy()
				end
				rowViews = {}
				local widest = 0
				for index, data in ipairs(rows) do
					local view = buildRow(data, index)
					showState(view, false)
					widest = math.max(widest, view.width)
					rowViews[index] = view
				end
				emptyLabel.Visible = #rows == 0
				countPill.Text = tostring(#rows)
				local pillWidth = math.max(24, textWidth(countPill.Text, Enum.Font.GothamBold, 11) + 14)
				countPill.Size = UDim2.fromOffset(pillWidth, 18)
				-- As wide as the longest row needs, within limits; longer names are cut short.
				local headerWidth = titleX + textWidth(title.Text, Enum.Font.GothamBold, 13) + 12 + pillWidth + 10
				local width = math.ceil(math.max(math.clamp(widest, 168, 248) + padding * 2, headerWidth))
				local count = math.max(#rows, 1)
				local height = headerHeight + count * rowHeight + (count - 1) * rowGap + padding
				panelSize = Vector2.new(width, height)
				if sizeTween then sizeTween:Cancel() end
				if animate then
					sizeTween = TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = UDim2.fromOffset(width, height),
					})
					sizeTween:Play()
				else
					panel.Size = UDim2.fromOffset(width, height)
				end
				if not dragInput then placePanel() end
			end

			-- Fading: each part goes fully see-through and back to the transparency it was made with,
			-- recorded the first time it's seen (always at rest, since rows are only made while shown).
			local resting = setmetatable({}, { __mode = "k" })
			local fadeProperties = {
				{ "GuiObject", "BackgroundTransparency" },
				{ "TextLabel", "TextTransparency" },
				{ "ImageLabel", "ImageTransparency" },
				{ "UIStroke", "Transparency" },
			}
			local function fadeParts()
				local parts = {}
				local function visit(object)
					local record = resting[object]
					if not record then
						record = {}
						for _, entry in ipairs(fadeProperties) do
							if object:IsA(entry[1]) then
								record[entry[2]] = object[entry[2]]
							end
						end
						resting[object] = record
					end
					for property, value in pairs(record) do
						if value < 1 then
							table.insert(parts, { object, property, value })
						end
					end
				end
				visit(panel)
				for _, descendant in ipairs(panel:GetDescendants()) do
					visit(descendant)
				end
				return parts
			end
			local fadeSerial = 0
			local function applyShown()
				local visible = wantShown and ready
				if visible == shown then return end
				fadeSerial += 1
				local serial = fadeSerial
				if visible then
					-- Brought up to date first, while still hidden, so it appears at its full size.
					pcall(refresh)
					shown = true
					local parts = fadeParts()
					for _, part in ipairs(parts) do
						part[1][part[2]] = 1
					end
					gui.Enabled = true
					local info = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					for _, part in ipairs(parts) do
						TweenService:Create(part[1], info, { [part[2]] = part[3] }):Play()
					end
				else
					shown = false
					dragInput = nil
					local info = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
					for _, part in ipairs(fadeParts()) do
						TweenService:Create(part[1], info, { [part[2]] = 1 }):Play()
					end
					-- Switched off once faded, so the hidden panel can't be clicked.
					task.delay(0.2, function()
						if fadeSerial == serial then
							gui.Enabled = false
						end
					end)
				end
			end

			-- Dragging. Drags are measured from where they started, so screen insets cancel out.
			local function showBorder()
				panelStroke.Color = (hovering or dragInput) and auxiliaryUiTheme.Accent or auxiliaryUiTheme.Stroke
			end
			panel.MouseEnter:Connect(function()
				hovering = true
				showBorder()
			end)
			panel.MouseLeave:Connect(function()
				hovering = false
				showBorder()
			end)
			panel.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
					dragFrom = Vector2.new(input.Position.X, input.Position.Y)
					panelFrom = Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
					showBorder()
				end
			end)
			table.insert(connections, UserInputService.InputChanged:Connect(function(input)
				if dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input == dragInput) then
					panel.Position = clampToScreen(panelFrom.X + input.Position.X - dragFrom.X, panelFrom.Y + input.Position.Y - dragFrom.Y)
				end
			end))
			table.insert(connections, UserInputService.InputEnded:Connect(function(input)
				if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
					dragInput = nil
					showBorder()
					local screen = screenSize()
					featureSettings.keybindListX = panel.Position.X.Offset / math.max(screen.X, 1)
					featureSettings.keybindListY = panel.Position.Y.Offset / math.max(screen.Y, 1)
					saveFeatureSettings()
				end
			end))

			-- Keys pressed while playing light up their rows. The keybinds themselves are handled
			-- by their own listeners and skip typing the same way.
			table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if not shown or gameProcessed or UserInputService:GetFocusedTextBox() then return end
				local key = nil
				if input.UserInputType == Enum.UserInputType.Keyboard then
					key = input.KeyCode.Name
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					key = "LeftClick"
				elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
					key = "RightClick"
				end
				local pressed = false
				for _, view in ipairs(rowViews) do
					if view.data.key == key then
						flash(view)
						pressed = true
					end
				end
				-- The keybind switches its feature in its own listener; show the result straight after.
				if pressed then
					task.defer(function()
						if shown then pcall(refresh) end
					end)
				end
			end))

			table.insert(auxiliaryUiThemeListeners, function()
				for _, view in ipairs(rowViews) do
					showState(view, false)
				end
				showBorder()
			end)

			-- Switch states and the list itself follow the features ten times a second.
			local lastScreen = nil
			task.spawn(function()
				while gui.Parent do
					if shown then
						local ok, problem = pcall(refresh)
						if not ok then
							warn("[SpreadCheeksGUI] The keybind list stopped updating: " .. tostring(problem))
							break
						end
						local screen = screenSize()
						if screen ~= lastScreen and not dragInput then
							lastScreen = screen
							placePanel()
						end
					end
					task.wait(0.1)
				end
			end)

			-- Appears as the menu finishes opening, along with everything in it.
			task.spawn(function()
				local waited = 0
				while not windowOpenedAt and waited < 15 do
					waited += task.wait(0.1)
				end
				task.wait(math.max(0, (windowOpenedAt or os.clock()) + 1.45 - os.clock()))
				ready = true
				applyShown()
			end)

			return {
				setShown = function(on)
					wantShown = on == true
					applyShown()
				end,
				addSource = function(source)
					table.insert(extraSources, source)
				end,
			}
		end

		-- Kept separate so a problem in the list can't stop the rest of the menu loading.
		local keybindListOk, keybindList = pcall(buildKeybindList)
		if not keybindListOk then
			warn("[SpreadCheeksGUI] The keybind list couldn't be added: " .. tostring(keybindList))
			keybindList = nil
		end
		withIcon(interfaceTab, "CreateToggle", {
			name = "Keybind List",
			description = "Shows your keybinds on screen. Drag it to move it",
			value = featureSettings.keybindList,
			callback = function(enabled)
				enabled = enabled == true
				if featureSettings.keybindList ~= enabled then
					featureSettings.keybindList = enabled
					saveFeatureSettings()
				end
				if keybindList then keybindList.setShown(enabled) end
			end,
		}, "layout-list", "list")
		if keybindList then keybindList.setShown(featureSettings.keybindList) end

		-- Performance Stats: FPS, ping, memory and more in a window of their own that can be dragged
		-- anywhere. The Performance Stats switch in Interface shows it, and it's remembered.
		local function buildPerformanceStats()
			local localPlayer = Players.LocalPlayer
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
			local previousGui = playerGui:FindFirstChild("SpreadCheeksPerformance")
			if previousGui then previousGui:Destroy() end
			-- Kept in the shared environment so running the script again drops the old listeners.
			if sharedEnv.SpreadCheeksPerformanceConnections then
				for _, connection in ipairs(sharedEnv.SpreadCheeksPerformanceConnections) do
					pcall(function() connection:Disconnect() end)
				end
			end
			local connections = {}
			sharedEnv.SpreadCheeksPerformanceConnections = connections

			local panelWidth, headerHeight, heroHeight, rowHeight, padding = 236, 36, 62, 22, 12
			-- Green, amber or red from the theme, which deepens them on light themes.
			local function fpsColor(fps)
				if fps >= 50 then return auxiliaryUiTheme.Good end
				if fps >= 30 then return auxiliaryUiTheme.Fair end
				return auxiliaryUiTheme.Bad
			end
			local function pingColor(ping)
				if ping < 100 then return auxiliaryUiTheme.Good end
				if ping < 200 then return auxiliaryUiTheme.Fair end
				return auxiliaryUiTheme.Bad
			end

			local gui = Instance.new("ScreenGui")
			gui.Name = "SpreadCheeksPerformance"
			gui.ResetOnSpawn = false
			gui.IgnoreGuiInset = true
			-- Level with the keybind list: under the ; bar (1000) and the notifications (10001).
			gui.DisplayOrder = 999
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Enabled = false
			gui.Parent = playerGui

			-- The window is a button so clicking it doesn't reach the game, and it's what gets dragged.
			local panel = Instance.new("TextButton")
			panel.Name = "PerformanceStats"
			panel.AutoButtonColor = false
			panel.Text = ""
			panel.BackgroundTransparency = 0.04
			panel.BorderSizePixel = 0
			panel.ClipsDescendants = true
			panel.Size = UDim2.fromOffset(panelWidth, headerHeight + heroHeight + 8)
			bindAuxiliaryUiColor(panel, "BackgroundColor3", "Background")
			panel.Parent = gui
			local panelCorner = Instance.new("UICorner")
			panelCorner.CornerRadius = UDim.new(0, 12)
			panelCorner.Parent = panel
			local panelStroke = Instance.new("UIStroke")
			panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			panelStroke.Transparency = 0.3
			bindAuxiliaryUiColor(panelStroke, "Color", "Stroke")
			panelStroke.Parent = panel

			local function makeLabel(parent, font, size, role, alignX)
				local label = Instance.new("TextLabel")
				label.BackgroundTransparency = 1
				label.Font = font
				label.TextSize = size
				label.Text = ""
				label.TextXAlignment = alignX or Enum.TextXAlignment.Left
				label.TextTruncate = Enum.TextTruncate.AtEnd
				bindAuxiliaryUiColor(label, "TextColor3", role)
				label.Parent = parent
				return label
			end
			local function makeIcon(parent, size, role, ...)
				local image = Instance.new("ImageLabel")
				image.BackgroundTransparency = 1
				image.Size = UDim2.fromOffset(size, size)
				local icon = menuIcons.get(...)
				if icon then menuIcons.apply(image, icon) end
				image.Visible = icon ~= nil
				bindAuxiliaryUiColor(image, "ImageColor3", role)
				image.Parent = parent
				return image
			end

			-- Header: an icon, the title, and a one-word verdict on how the game is running.
			local headerIcon = makeIcon(panel, 15, "AccentText", "activity", "gauge")
			headerIcon.AnchorPoint = Vector2.new(0, 0.5)
			headerIcon.Position = UDim2.new(0, 12, 0, headerHeight / 2)
			local title = makeLabel(panel, Enum.Font.GothamBold, 13, "Text")
			title.AnchorPoint = Vector2.new(0, 0.5)
			title.Position = UDim2.new(0, 35, 0, headerHeight / 2)
			title.Size = UDim2.new(1, -110, 0, 16)
			title.Text = "Performance"
			local verdict = Instance.new("TextLabel")
			verdict.AnchorPoint = Vector2.new(1, 0.5)
			verdict.Position = UDim2.new(1, -10, 0, headerHeight / 2)
			verdict.Size = UDim2.fromOffset(64, 18)
			verdict.BorderSizePixel = 0
			verdict.Font = Enum.Font.GothamBold
			verdict.Text = "..."
			verdict.TextSize = 10
			verdict.TextColor3 = auxiliaryUiTheme.Good
			bindAuxiliaryUiColor(verdict, "BackgroundColor3", "Inset")
			verdict.Parent = panel
			local verdictCorner = Instance.new("UICorner")
			verdictCorner.CornerRadius = UDim.new(1, 0)
			verdictCorner.Parent = verdict
			local verdictStroke = Instance.new("UIStroke")
			verdictStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			verdictStroke.Transparency = 0.5
			verdictStroke.Color = auxiliaryUiTheme.Good
			verdictStroke.Parent = verdict

			-- The frame rate, large, with its average and low point, beside a graph of the last
			-- 13 seconds (a bar every half second, newest on the right).
			local fpsValue = makeLabel(panel, Enum.Font.GothamBold, 28, "Text")
			fpsValue.Position = UDim2.fromOffset(padding, headerHeight)
			fpsValue.Size = UDim2.fromOffset(92, 30)
			fpsValue.Text = "--"
			local fpsCaption = makeLabel(panel, Enum.Font.GothamBold, 10, "Muted")
			fpsCaption.Position = UDim2.fromOffset(padding, headerHeight + 30)
			fpsCaption.Size = UDim2.fromOffset(92, 13)
			fpsCaption.Text = "FPS"
			local fpsDetail = makeLabel(panel, Enum.Font.Gotham, 10, "SubText")
			fpsDetail.Position = UDim2.fromOffset(padding, headerHeight + 44)
			fpsDetail.Size = UDim2.fromOffset(100, 13)
			local barCount, barWidth, barGap, graphHeight = 26, 3, 1, 46
			local graph = Instance.new("Frame")
			graph.AnchorPoint = Vector2.new(1, 0)
			graph.Position = UDim2.new(1, -padding, 0, headerHeight + 4)
			graph.Size = UDim2.fromOffset(barCount * (barWidth + barGap) - barGap + 10, graphHeight)
			graph.BorderSizePixel = 0
			graph.ClipsDescendants = true
			bindAuxiliaryUiColor(graph, "BackgroundColor3", "Inset")
			graph.Parent = panel
			local graphCorner = Instance.new("UICorner")
			graphCorner.CornerRadius = UDim.new(0, 8)
			graphCorner.Parent = graph
			local graphStroke = Instance.new("UIStroke")
			graphStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			graphStroke.Transparency = 0.5
			bindAuxiliaryUiColor(graphStroke, "Color", "Stroke")
			graphStroke.Parent = graph
			local bars = {}
			for index = 1, barCount do
				local bar = Instance.new("Frame")
				bar.AnchorPoint = Vector2.new(0, 1)
				bar.Position = UDim2.new(0, 5 + (index - 1) * (barWidth + barGap), 1, -5)
				bar.Size = UDim2.fromOffset(barWidth, 0)
				bar.BorderSizePixel = 0
				bar.BackgroundColor3 = auxiliaryUiTheme.Good
				bar.Parent = graph
				local barCorner = Instance.new("UICorner")
				barCorner.CornerRadius = UDim.new(0, 1)
				barCorner.Parent = bar
				bars[index] = bar
			end

			-- Everything else, a line each. A line stays hidden while its number can't be read.
			local rowDefinitions = {
				{ "frame", "Frame time", { "timer", "clock" } },
				{ "ping", "Ping", { "wifi" } },
				{ "memory", "Memory", { "memory-stick", "cpu" } },
				{ "physics", "Physics", { "atom", "orbit" } },
				{ "network", "Network", { "arrow-down-up", "network" } },
				{ "instances", "Instances", { "boxes", "box" } },
				{ "players", "Players", { "users" } },
				{ "uptime", "Server up", { "server", "clock" } },
			}
			local rowList = Instance.new("Frame")
			rowList.Position = UDim2.fromOffset(padding, headerHeight + heroHeight)
			rowList.Size = UDim2.new(1, -padding * 2, 0, 0)
			rowList.AutomaticSize = Enum.AutomaticSize.Y
			rowList.BackgroundTransparency = 1
			rowList.Parent = panel
			local rowLayout = Instance.new("UIListLayout")
			rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rowLayout.Parent = rowList
			local rows = {}
			for index, definition in ipairs(rowDefinitions) do
				local row = Instance.new("Frame")
				row.LayoutOrder = index
				row.Size = UDim2.new(1, 0, 0, rowHeight)
				row.BackgroundTransparency = 1
				row.Visible = false
				row.Parent = rowList
				local icon = makeIcon(row, 12, "SubText", table.unpack(definition[3]))
				icon.AnchorPoint = Vector2.new(0, 0.5)
				icon.Position = UDim2.fromScale(0, 0.5)
				local label = makeLabel(row, Enum.Font.Gotham, 12, "SubText")
				label.Position = UDim2.fromOffset(19, 0)
				label.Size = UDim2.new(0, 76, 1, 0)
				label.Text = definition[2]
				local value = makeLabel(row, Enum.Font.GothamMedium, 12, "Text", Enum.TextXAlignment.Right)
				value.Position = UDim2.fromOffset(96, 0)
				value.Size = UDim2.new(1, -96, 1, 0)
				rows[definition[1]] = { frame = row, value = value }
			end
			local function setRow(key, text, color)
				local row = rows[key]
				row.frame.Visible = type(text) == "string"
				if row.frame.Visible then
					row.value.Text = text
					row.value.TextColor3 = color or auxiliaryUiTheme.Text
				end
			end

			local function readNumber(read)
				local readOk, value = pcall(read)
				return (readOk and type(value) == "number") and value or nil
			end
			-- Round trip to the server in milliseconds, from the player, or else from Stats.
			local function readPing()
				local ping = readNumber(function() return localPlayer:GetNetworkPing() * 1000 end)
				if ping and ping > 0 then return ping end
				return readNumber(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
			end
			local function formatDuration(seconds)
				seconds = math.max(0, math.floor(seconds))
				if seconds < 60 then return seconds .. "s" end
				local minutes = math.floor(seconds / 60)
				if minutes < 60 then return minutes .. "m" end
				return math.floor(minutes / 60) .. "h " .. minutes % 60 .. "m"
			end
			local function formatCount(count)
				if count >= 1e6 then return string.format("%.1fM", count / 1e6) end
				if count >= 1e3 then return string.format("%.1fk", count / 1e3) end
				return tostring(math.floor(count))
			end

			-- Frames are counted all the time, so the graph already has a history when the window opens.
			local frames, slowestFrame, sampleStart = 0, 0, os.clock()
			local history = {}
			local latest = nil
			table.insert(connections, RunService.RenderStepped:Connect(function(deltaTime)
				frames += 1
				if deltaTime > slowestFrame then slowestFrame = deltaTime end
			end))
			local function takeSample()
				local now = os.clock()
				local elapsed = math.max(now - sampleStart, 0.001)
				latest = {
					fps = frames / elapsed,
					frameMs = frames > 0 and elapsed / frames * 1000 or 0,
					slowestMs = slowestFrame * 1000,
				}
				frames, slowestFrame, sampleStart = 0, 0, now
				table.insert(history, latest.fps)
				if #history > barCount then table.remove(history, 1) end
			end

			local shown, ready, wantShown = false, false, false
			local dragInput, dragFrom, panelFrom = nil, nil, nil
			local hovering = false
			local panelSize = Vector2.new(panelWidth, headerHeight + heroHeight + 8)
			local function screenSize()
				local camera = workspace.CurrentCamera
				return camera and camera.ViewportSize or gui.AbsoluteSize
			end
			local function clampToScreen(x, y)
				local screen = screenSize()
				x = math.clamp(x, 0, math.max(0, screen.X - panelSize.X))
				y = math.clamp(y, 0, math.max(0, screen.Y - panelSize.Y))
				return UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
			end
			-- Where it was dragged to is kept as a share of the screen, so it stays put at any size.
			-- It starts on the right, clear of the keybind list on the left.
			local function placePanel()
				local screen = screenSize()
				if featureSettings.performanceStatsX >= 0 and featureSettings.performanceStatsY >= 0 then
					panel.Position = clampToScreen(featureSettings.performanceStatsX * screen.X, featureSettings.performanceStatsY * screen.Y)
				else
					panel.Position = clampToScreen(screen.X - panelSize.X - 16, screen.Y * 0.4)
				end
			end
			-- Tall enough for the lines that are showing.
			local function resize()
				local visibleRows = 0
				for _, row in pairs(rows) do
					if row.frame.Visible then visibleRows += 1 end
				end
				local height = headerHeight + heroHeight + visibleRows * rowHeight + 8
				if height ~= panelSize.Y then
					panelSize = Vector2.new(panelWidth, height)
					panel.Size = UDim2.fromOffset(panelWidth, height)
					if not dragInput then placePanel() end
				end
			end

			local function render()
				if not latest then return end
				local fps = latest.fps
				fpsValue.Text = tostring(math.floor(fps + 0.5))
				fpsValue.TextColor3 = fpsColor(fps)
				local total, lowest, highest = 0, math.huge, 60
				for _, sample in ipairs(history) do
					total += sample
					lowest = math.min(lowest, sample)
					highest = math.max(highest, sample)
				end
				fpsDetail.Text = string.format("avg %d  ·  low %d", math.floor(total / #history + 0.5), math.floor(lowest + 0.5))
				-- The tallest bar is the highest frame rate seen lately, or 60.
				for index, bar in ipairs(bars) do
					local sample = history[#history - barCount + index]
					if sample then
						bar.Size = UDim2.fromOffset(barWidth, math.max(2, math.floor(sample / highest * (graphHeight - 10) + 0.5)))
						bar.BackgroundColor3 = fpsColor(sample)
					else
						bar.Size = UDim2.fromOffset(barWidth, 0)
					end
				end

				local frameText = string.format("%.1f ms", latest.frameMs)
				if latest.slowestMs >= 25 and latest.slowestMs > latest.frameMs * 2 then
					-- A hitch in the last half second shows beside the average.
					frameText ..= string.format("  (max %d)", math.floor(latest.slowestMs + 0.5))
				end
				setRow("frame", frameText, latest.slowestMs >= 50 and auxiliaryUiTheme.Fair or nil)
				local ping = readPing()
				setRow("ping", ping and (math.floor(ping + 0.5) .. " ms"), ping and pingColor(ping))
				local memory = readNumber(function() return StatsService:GetTotalMemoryUsageMb() end)
				setRow("memory", memory and (memory >= 1024 and string.format("%.2f GB", memory / 1024) or (math.floor(memory + 0.5) .. " MB")))
				local physics = readNumber(function() return workspace:GetRealPhysicsFPS() end)
				setRow("physics", physics and (math.floor(physics + 0.5) .. " Hz"))
				local received = readNumber(function() return StatsService.DataReceiveKbps end)
				local sent = readNumber(function() return StatsService.DataSendKbps end)
				setRow("network", received and sent and string.format("%.1f / %.1f KB/s", received, sent))
				local instances = readNumber(function() return StatsService.InstanceCount end)
				setRow("instances", instances and formatCount(instances))
				setRow("players", #Players:GetPlayers() .. " / " .. Players.MaxPlayers)
				setRow("uptime", formatDuration(workspace.DistributedGameTime))

				-- The verdict goes by the frame rate and ping together.
				local pingValue = ping or 0
				local theme = auxiliaryUiTheme
				if fps >= 50 and pingValue < 150 then
					verdict.Text, verdict.TextColor3, verdictStroke.Color = "SMOOTH", theme.Good, theme.Good
				elseif fps >= 30 and pingValue < 300 then
					verdict.Text, verdict.TextColor3, verdictStroke.Color = "OKAY", theme.Fair, theme.Fair
				else
					verdict.Text, verdict.TextColor3, verdictStroke.Color = "LAGGY", theme.Bad, theme.Bad
				end
				resize()
			end

			-- Fading: each part goes fully see-through and back to the transparency it was made with,
			-- recorded the first time it's seen (always at rest).
			local resting = setmetatable({}, { __mode = "k" })
			local fadeProperties = {
				{ "GuiObject", "BackgroundTransparency" },
				{ "TextLabel", "TextTransparency" },
				{ "ImageLabel", "ImageTransparency" },
				{ "UIStroke", "Transparency" },
			}
			local function fadeParts()
				local parts = {}
				local function visit(object)
					local record = resting[object]
					if not record then
						record = {}
						for _, entry in ipairs(fadeProperties) do
							if object:IsA(entry[1]) then
								record[entry[2]] = object[entry[2]]
							end
						end
						resting[object] = record
					end
					for property, value in pairs(record) do
						if value < 1 then
							table.insert(parts, { object, property, value })
						end
					end
				end
				visit(panel)
				for _, descendant in ipairs(panel:GetDescendants()) do
					visit(descendant)
				end
				return parts
			end
			local fadeSerial = 0
			local function applyShown()
				local visible = wantShown and ready
				if visible == shown then return end
				fadeSerial += 1
				local serial = fadeSerial
				if visible then
					-- Filled in first, while still hidden, so it appears with numbers and at its full size.
					pcall(render)
					shown = true
					placePanel()
					local parts = fadeParts()
					for _, part in ipairs(parts) do
						part[1][part[2]] = 1
					end
					gui.Enabled = true
					local info = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					for _, part in ipairs(parts) do
						TweenService:Create(part[1], info, { [part[2]] = part[3] }):Play()
					end
				else
					shown = false
					dragInput = nil
					local info = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
					for _, part in ipairs(fadeParts()) do
						TweenService:Create(part[1], info, { [part[2]] = 1 }):Play()
					end
					-- Switched off once faded, so the hidden window can't be clicked.
					task.delay(0.2, function()
						if fadeSerial == serial then
							gui.Enabled = false
						end
					end)
				end
			end

			-- Dragging. Drags are measured from where they started, so screen insets cancel out.
			local function showBorder()
				panelStroke.Color = (hovering or dragInput) and auxiliaryUiTheme.Accent or auxiliaryUiTheme.Stroke
			end
			panel.MouseEnter:Connect(function()
				hovering = true
				showBorder()
			end)
			panel.MouseLeave:Connect(function()
				hovering = false
				showBorder()
			end)
			panel.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
					dragFrom = Vector2.new(input.Position.X, input.Position.Y)
					panelFrom = Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
					showBorder()
				end
			end)
			table.insert(connections, UserInputService.InputChanged:Connect(function(input)
				if dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input == dragInput) then
					panel.Position = clampToScreen(panelFrom.X + input.Position.X - dragFrom.X, panelFrom.Y + input.Position.Y - dragFrom.Y)
				end
			end))
			table.insert(connections, UserInputService.InputEnded:Connect(function(input)
				if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
					dragInput = nil
					showBorder()
					local screen = screenSize()
					featureSettings.performanceStatsX = panel.Position.X.Offset / math.max(screen.X, 1)
					featureSettings.performanceStatsY = panel.Position.Y.Offset / math.max(screen.Y, 1)
					saveFeatureSettings()
				end
			end))

			-- Colours that depend on the numbers are set again after a theme change.
			table.insert(auxiliaryUiThemeListeners, function()
				showBorder()
				if shown then pcall(render) end
			end)

			-- A sample every half second; the window shows it while it's open.
			local lastScreen = nil
			task.spawn(function()
				while gui.Parent do
					task.wait(0.5)
					if not gui.Parent then break end
					takeSample()
					if shown then
						local renderOk, problem = pcall(render)
						if not renderOk then
							warn("[SpreadCheeksGUI] Performance Stats stopped updating: " .. tostring(problem))
							break
						end
						local screen = screenSize()
						if screen ~= lastScreen and not dragInput then
							lastScreen = screen
							placePanel()
						end
					end
				end
			end)

			-- Appears as the menu finishes opening, along with everything in it.
			task.spawn(function()
				local waited = 0
				while not windowOpenedAt and waited < 15 do
					waited += task.wait(0.1)
				end
				task.wait(math.max(0, (windowOpenedAt or os.clock()) + 1.45 - os.clock()))
				ready = true
				applyShown()
			end)

			return {
				setShown = function(on)
					wantShown = on == true
					applyShown()
				end,
			}
		end

		-- Kept separate so a problem in the window can't stop the rest of the menu loading.
		local performanceStatsOk, builtPerformanceStats = pcall(buildPerformanceStats)
		if performanceStatsOk then
			performanceStats = builtPerformanceStats
		else
			warn("[SpreadCheeksGUI] The Performance Stats window couldn't be added: " .. tostring(builtPerformanceStats))
		end
		-- Opens again if it was open last time.
		if featureSettings.performanceStats and quickToggleByName["Performance Stats"] then
			setQuickToggle(quickToggleByName["Performance Stats"], true)
		end

		withIcon(interfaceTab, "CreateSection", { name = "Keybinds" }, "keyboard")
		interfaceTab:CreateText({
			text = "Click the key box next to any switch in Quick Controls, then press a key to bind it. Press Esc instead to clear it, or click the box again to cancel. Keybinds are ignored while you're typing in chat or a text box.",
		})

		-- Clears the keys set on the Quick Controls switches. The first click asks for a second
		-- one, so a stray click can't wipe them all.
		local clearConfirmUntil = 0
		withIcon(interfaceTab, "CreateButton", {
			name = "Clear All Keybinds",
			callback = function()
				local count = 0
				for _, entry in ipairs(quickToggles) do
					if entry.key then count += 1 end
				end
				if count == 0 then
					clearConfirmUntil = 0
					notify("Keybinds", "No keybinds to clear")
					return
				end
				if os.clock() > clearConfirmUntil then
					clearConfirmUntil = os.clock() + 4
					notify("Clear all keybinds?", "Click the button again to clear " .. (count == 1 and "your 1 keybind" or ("all " .. count .. " keybinds")), 4)
					return
				end
				clearConfirmUntil = 0
				stopKeyRecording()
				for _, entry in ipairs(quickToggles) do
					entry.key = nil
					refreshKeyChip(entry)
				end
				saveQuickKeybinds()
				notify("Keybinds", count == 1 and "Cleared 1 keybind" or ("Cleared " .. count .. " keybinds"))
			end,
		}, "trash-2", "eraser")

		withIcon(interfaceTab, "CreateSection", { name = "Extras" }, "sparkles")
		local logoBounceGui, logoBounceConnection
		local logoBounceToggle
		local function stopLogoBounce()
			if logoBounceConnection then
				logoBounceConnection:Disconnect()
				logoBounceConnection = nil
			end
			if logoBounceGui then
				logoBounceGui:Destroy()
				logoBounceGui = nil
			end
		end
		logoBounceToggle = withIcon(interfaceTab, "CreateToggle", {
			name = "DVD Logo Bounce",
			description = "Bounce the SpreadCheeksGUI logo around the screen",
			value = false,
			callback = function(enabled)
				if not enabled then
					stopLogoBounce()
					return
				end
				if not spreadLogoLoaded then
					notify("Logo unavailable", "Place SpreadCheeksLogo.png in the executor workspace first.")
					logoBounceToggle:Set(false, true)
					return
				end
				stopLogoBounce()

				local bounceGui = Instance.new("ScreenGui")
				bounceGui.Name = "SpreadCheeksLogoBounce"
				bounceGui.ResetOnSpawn = false
				bounceGui.IgnoreGuiInset = true
				bounceGui.DisplayOrder = 10000
				bounceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				bounceGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
				logoBounceGui = bounceGui

				local logoImage = Instance.new("ImageLabel")
				logoImage.Name = "BouncingLogo"
				logoImage.BackgroundTransparency = 1
				logoImage.BorderSizePixel = 0
				logoImage.Image = spreadLogo
				logoImage.ScaleType = Enum.ScaleType.Fit
				logoImage.Size = UDim2.fromOffset(112, 112)
				logoImage.Position = UDim2.fromOffset(24, 72)
				logoImage.Active = false
				logoImage.Parent = bounceGui

				local x, y = 24, 72
				local speedX, speedY = 210, 165
				logoBounceConnection = RunService.RenderStepped:Connect(function(deltaTime)
					if not bounceGui.Parent then
						stopLogoBounce()
						return
					end
					local viewport = bounceGui.AbsoluteSize
					local maxX = math.max(0, viewport.X - logoImage.AbsoluteSize.X)
					local maxY = math.max(0, viewport.Y - logoImage.AbsoluteSize.Y)
					x += speedX * deltaTime
					y += speedY * deltaTime
					if x <= 0 then x, speedX = 0, math.abs(speedX) end
					if x >= maxX then x, speedX = maxX, -math.abs(speedX) end
					if y <= 0 then y, speedY = 0, math.abs(speedY) end
					if y >= maxY then y, speedY = maxY, -math.abs(speedY) end
					logoImage.Position = UDim2.fromOffset(x, y)
				end)
			end,
		}, "disc")

		-- Settings cards open under a switch the way Rayfield's dropdowns do. Right-click a switch's
		-- row to open or close its card (ESP also has an arrow, in place of its key box).
		local function createSettingsCard(entry)
			local row = entry and entry.object and entry.object.main
			if typeof(row) ~= "Instance" or not row.Parent then
				warn("[SpreadCheeksGUI] Couldn't add settings to " .. tostring(entry and entry.name) .. "; Rayfield's toggle layout may have changed.")
				return nil
			end
			local settingsCard = { expanded = false, refreshers = {}, onExpandedChanged = {} }

			-- As wide as its row, wherever the row is (Rayfield's search moves rows; see below).
			local function cardWidth()
				local width = row.Size.X
				if width.Scale == 0 and width.Offset <= 0 then return UDim.new(1, -20) end
				return width
			end
			local card = Instance.new("Frame")
			card.Name = entry.name .. "Settings"
			card.Size = UDim2.new(cardWidth(), UDim.new(0, 0))
			card.BorderSizePixel = 0
			card.ClipsDescendants = true
			card.Visible = false
			-- Rayfield spaces rows 10 apart in LayoutOrder, so +5 slots the card straight under its row.
			card.LayoutOrder = row.LayoutOrder + 5
			row:GetPropertyChangedSignal("LayoutOrder"):Connect(function()
				card.LayoutOrder = row.LayoutOrder + 5
			end)
			-- Style the card like Rayfield's own rows; without that helper, use the menu theme colours.
			local styleOk, cardStroke = pcall(function() return window:StyleElementBody(card) end)
			if styleOk then
				local function matchRowBackground()
					card.BackgroundColor3 = row.BackgroundColor3
					card.BackgroundTransparency = row.BackgroundTransparency
				end
				matchRowBackground()
				row:GetPropertyChangedSignal("BackgroundColor3"):Connect(matchRowBackground)
				row:GetPropertyChangedSignal("BackgroundTransparency"):Connect(matchRowBackground)
				-- The helper's border starts hidden; show it at the theme's strength.
				if typeof(cardStroke) == "Instance" and cardStroke.Transparency >= 1 then
					cardStroke.Transparency = (window.theme and tonumber(window.theme.ElementStrokeTransparency)) or 0.3
				end
			else
				bindAuxiliaryUiColor(card, "BackgroundColor3", "Card")
				local cardCorner = Instance.new("UICorner")
				cardCorner.CornerRadius = UDim.new(0, 9)
				cardCorner.Parent = card
				local fallbackStroke = Instance.new("UIStroke")
				fallbackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				fallbackStroke.Transparency = 0.3
				bindAuxiliaryUiColor(fallbackStroke, "Color", "Stroke")
				fallbackStroke.Parent = card
			end
			card.Parent = row.Parent
			settingsCard.card = card
			-- Rayfield's search moves the rows that match into its results page, and puts them back
			-- when the search closes. The card goes wherever its row goes, so right-clicking a search
			-- result opens its settings right under it. The search also hides rows that don't match,
			-- and an open card hides with its row.
			row:GetPropertyChangedSignal("Parent"):Connect(function()
				if row.Parent then
					card.Parent = row.Parent
				end
			end)
			row:GetPropertyChangedSignal("Visible"):Connect(function()
				card.Visible = row.Visible and settingsCard.expanded
			end)

			local content = Instance.new("Frame")
			content.Name = "Content"
			content.Size = UDim2.fromScale(1, 0)
			content.AutomaticSize = Enum.AutomaticSize.Y
			content.BackgroundTransparency = 1
			content.Parent = card
			local contentPadding = Instance.new("UIPadding")
			contentPadding.PaddingTop = UDim.new(0, 6)
			contentPadding.PaddingBottom = UDim.new(0, 12)
			contentPadding.PaddingLeft = UDim.new(0, 14)
			contentPadding.PaddingRight = UDim.new(0, 14)
			contentPadding.Parent = content
			local contentLayout = Instance.new("UIListLayout")
			contentLayout.Padding = UDim.new(0, 6)
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			contentLayout.Parent = content
			settingsCard.content = content

			local layoutOrder = 0
			function settingsCard.nextOrder()
				layoutOrder += 1
				return layoutOrder
			end

			-- On/off and selected colours depend on state, so they're re-read from the theme on
			-- every refresh, including after a theme change.
			function settingsCard.refresh()
				for _, refresher in ipairs(settingsCard.refreshers) do
					refresher()
				end
			end
			table.insert(auxiliaryUiThemeListeners, settingsCard.refresh)

			-- A small heading, with an icon when one of the given names exists.
			function settingsCard.addSectionLabel(text, ...)
				local holder = Instance.new("Frame")
				holder.LayoutOrder = settingsCard.nextOrder()
				holder.Size = UDim2.new(1, 0, 0, 22)
				holder.BackgroundTransparency = 1
				holder.Parent = content
				local labelX = 0
				local icon = menuIcons.get(...)
				if icon then
					local iconLabel = Instance.new("ImageLabel")
					iconLabel.AnchorPoint = Vector2.new(0, 1)
					iconLabel.Position = UDim2.new(0, 0, 1, -1)
					iconLabel.Size = UDim2.fromOffset(12, 12)
					iconLabel.BackgroundTransparency = 1
					menuIcons.apply(iconLabel, icon)
					bindAuxiliaryUiColor(iconLabel, "ImageColor3", "Muted")
					iconLabel.Parent = holder
					labelX = 18
				end
				local label = Instance.new("TextLabel")
				label.Position = UDim2.fromOffset(labelX, 0)
				label.Size = UDim2.new(1, -labelX, 1, 0)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.GothamBold
				label.Text = text
				label.TextSize = 10
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextYAlignment = Enum.TextYAlignment.Bottom
				bindAuxiliaryUiColor(label, "TextColor3", "Muted")
				label.Parent = holder
			end

			-- A row of buttons, one per choice, like the ESP colour modes. get returns the current
			-- choice; set is called with the one clicked.
			function settingsCard.addChoice(options, get, set)
				local choiceRow = Instance.new("Frame")
				choiceRow.LayoutOrder = settingsCard.nextOrder()
				choiceRow.Size = UDim2.new(1, 0, 0, 28)
				choiceRow.BackgroundTransparency = 1
				choiceRow.Parent = content
				local rowWidth = Instance.new("UISizeConstraint")
				rowWidth.MaxSize = Vector2.new(110 * #options, 28)
				rowWidth.Parent = choiceRow
				local layout = Instance.new("UIListLayout")
				layout.FillDirection = Enum.FillDirection.Horizontal
				layout.Padding = UDim.new(0, 6)
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.Parent = choiceRow
				local buttons = {}
				for index, option in ipairs(options) do
					local button = Instance.new("TextButton")
					button.LayoutOrder = index
					button.Size = UDim2.new(1 / #options, -6 * (#options - 1) / #options, 1, 0)
					button.AutoButtonColor = false
					button.BorderSizePixel = 0
					button.Font = Enum.Font.GothamMedium
					button.Text = option
					button.TextSize = 12
					button.Parent = choiceRow
					local buttonCorner = Instance.new("UICorner")
					buttonCorner.CornerRadius = UDim.new(0, 8)
					buttonCorner.Parent = button
					button.Activated:Connect(function()
						set(option)
						settingsCard.refresh()
					end)
					buttons[option] = button
				end
				table.insert(settingsCard.refreshers, function()
					local theme = auxiliaryUiTheme
					local current = get()
					for option, button in pairs(buttons) do
						local selected = current == option
						button.BackgroundColor3 = selected and theme.Accent or theme.Inset
						button.TextColor3 = selected and theme.OnAccent or theme.SubText
					end
				end)
			end

			-- A line of small print under the setting above it: the text, or a function returning
			-- it, which is asked again on every refresh. With no text, the line is hidden.
			function settingsCard.addHint(text)
				local hint = Instance.new("TextLabel")
				hint.LayoutOrder = settingsCard.nextOrder()
				hint.Size = UDim2.new(1, 0, 0, 14)
				hint.AutomaticSize = Enum.AutomaticSize.Y
				hint.BackgroundTransparency = 1
				hint.Font = Enum.Font.Gotham
				hint.TextSize = 11
				hint.TextWrapped = true
				hint.TextXAlignment = Enum.TextXAlignment.Left
				bindAuxiliaryUiColor(hint, "TextColor3", "SubText")
				hint.Parent = content
				local function show(value)
					hint.Text = value or ""
					hint.Visible = hint.Text ~= ""
				end
				if type(text) == "function" then
					table.insert(settingsCard.refreshers, function() show(text()) end)
				else
					show(text)
				end
				return hint
			end

			-- On/off cells: the whole cell is clickable, with a small switch on the right.
			-- Each option is { text = ..., get = function() -> on, set = function(on) }.
			local function addSwitch(parent, order, option)
				local cell = Instance.new("TextButton")
				cell.LayoutOrder = order
				cell.AutoButtonColor = false
				cell.BackgroundTransparency = 1
				cell.BorderSizePixel = 0
				cell.Text = ""
				bindAuxiliaryUiColor(cell, "BackgroundColor3", "Inset")
				cell.Parent = parent
				local cellCorner = Instance.new("UICorner")
				cellCorner.CornerRadius = UDim.new(0, 8)
				cellCorner.Parent = cell
				local label = Instance.new("TextLabel")
				label.Position = UDim2.fromOffset(8, 0)
				label.Size = UDim2.new(1, -60, 1, 0)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.Gotham
				label.Text = option.text
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextTruncate = Enum.TextTruncate.AtEnd
				bindAuxiliaryUiColor(label, "TextColor3", "Text")
				label.Parent = cell
				local track = Instance.new("Frame")
				track.AnchorPoint = Vector2.new(1, 0.5)
				track.Position = UDim2.new(1, -8, 0.5, 0)
				track.Size = UDim2.fromOffset(34, 18)
				track.BorderSizePixel = 0
				track.Parent = cell
				local trackCorner = Instance.new("UICorner")
				trackCorner.CornerRadius = UDim.new(1, 0)
				trackCorner.Parent = track
				local trackStroke = Instance.new("UIStroke")
				trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				trackStroke.Parent = track
				local knob = Instance.new("Frame")
				knob.AnchorPoint = Vector2.new(0, 0.5)
				knob.Position = UDim2.new(0, 2, 0.5, 0)
				knob.Size = UDim2.fromOffset(14, 14)
				knob.BorderSizePixel = 0
				knob.Parent = track
				local knobCorner = Instance.new("UICorner")
				knobCorner.CornerRadius = UDim.new(1, 0)
				knobCorner.Parent = knob
				cell.MouseEnter:Connect(function() cell.BackgroundTransparency = 0.5 end)
				cell.MouseLeave:Connect(function() cell.BackgroundTransparency = 1 end)
				cell.Activated:Connect(function()
					option.set(not option.get())
					settingsCard.refresh()
				end)
				table.insert(settingsCard.refreshers, function()
					local theme = auxiliaryUiTheme
					local on = option.get() == true
					track.BackgroundColor3 = on and theme.Accent or theme.Inset
					trackStroke.Color = on and theme.Accent or theme.Stroke
					knob.BackgroundColor3 = on and Color3.new(1, 1, 1) or theme.SubText
					TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
						Position = on and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
					}):Play()
				end)
			end

			-- Two switches per line keeps a card short; pass 1 for full-width switches.
			function settingsCard.addSwitchGrid(options, columns)
				columns = columns or 2
				local grid = Instance.new("Frame")
				grid.LayoutOrder = settingsCard.nextOrder()
				grid.Size = UDim2.fromScale(1, 0)
				grid.AutomaticSize = Enum.AutomaticSize.Y
				grid.BackgroundTransparency = 1
				grid.Parent = content
				local gridLayout = Instance.new("UIGridLayout")
				gridLayout.CellSize = UDim2.new(1 / columns, columns > 1 and -4 or 0, 0, 30)
				gridLayout.CellPadding = UDim2.fromOffset(8, 2)
				gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
				gridLayout.Parent = grid
				for index, option in ipairs(options) do
					addSwitch(grid, index, option)
				end
			end

			-- A slider: its name and value on top, the track underneath. options: text, icon (a
			-- list of icon names), min, max, step, get, set (also called while dragging),
			-- commit (called once the value settles, to save it) and format (value -> text).
			function settingsCard.addSlider(options)
				local step = options.step or 1
				local function snap(value)
					value = math.clamp(tonumber(value) or options.min, options.min, options.max)
					value = options.min + math.floor((value - options.min) / step + 0.5) * step
					return math.clamp(tonumber(string.format("%.4f", value)), options.min, options.max)
				end
				local function formatValue(value)
					if options.format then return options.format(value) end
					return step < 1 and string.format("%.1f", value) or tostring(math.floor(value + 0.5))
				end

				local holder = Instance.new("Frame")
				holder.LayoutOrder = settingsCard.nextOrder()
				holder.Size = UDim2.new(1, 0, 0, 48)
				holder.BackgroundTransparency = 1
				holder.Parent = content

				local labelX = 0
				local icon = options.icon and menuIcons.get(table.unpack(options.icon))
				if icon then
					local iconLabel = Instance.new("ImageLabel")
					iconLabel.AnchorPoint = Vector2.new(0, 0.5)
					iconLabel.Position = UDim2.fromOffset(0, 12)
					iconLabel.Size = UDim2.fromOffset(15, 15)
					iconLabel.BackgroundTransparency = 1
					menuIcons.apply(iconLabel, icon)
					bindAuxiliaryUiColor(iconLabel, "ImageColor3", "SubText")
					iconLabel.Parent = holder
					labelX = 23
				end
				local label = Instance.new("TextLabel")
				label.Position = UDim2.fromOffset(labelX, 0)
				label.Size = UDim2.new(1, -(labelX + 76), 0, 24)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.Gotham
				label.Text = options.text
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextTruncate = Enum.TextTruncate.AtEnd
				bindAuxiliaryUiColor(label, "TextColor3", "Text")
				label.Parent = holder

				-- Type an exact value here, or drag the track.
				local valueBox = Instance.new("TextBox")
				valueBox.AnchorPoint = Vector2.new(1, 0)
				valueBox.Position = UDim2.new(1, 0, 0, 0)
				valueBox.Size = UDim2.fromOffset(68, 24)
				valueBox.BorderSizePixel = 0
				valueBox.ClearTextOnFocus = false
				valueBox.Font = Enum.Font.GothamMedium
				valueBox.TextSize = 12
				bindAuxiliaryUiColor(valueBox, "BackgroundColor3", "Inset")
				bindAuxiliaryUiColor(valueBox, "TextColor3", "Text")
				valueBox.Parent = holder
				local valueCorner = Instance.new("UICorner")
				valueCorner.CornerRadius = UDim.new(0, 7)
				valueCorner.Parent = valueBox
				local valueStroke = Instance.new("UIStroke")
				valueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				valueStroke.Transparency = 0.35
				bindAuxiliaryUiColor(valueStroke, "Color", "Stroke")
				valueStroke.Parent = valueBox

				local track = Instance.new("Frame")
				track.Position = UDim2.fromOffset(0, 35)
				track.Size = UDim2.new(1, 0, 0, 6)
				track.BorderSizePixel = 0
				bindAuxiliaryUiColor(track, "BackgroundColor3", "Inset")
				track.Parent = holder
				local trackCorner = Instance.new("UICorner")
				trackCorner.CornerRadius = UDim.new(1, 0)
				trackCorner.Parent = track
				local trackStroke = Instance.new("UIStroke")
				trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				trackStroke.Transparency = 0.35
				bindAuxiliaryUiColor(trackStroke, "Color", "Stroke")
				trackStroke.Parent = track
				local fill = Instance.new("Frame")
				fill.Size = UDim2.fromScale(0, 1)
				fill.BorderSizePixel = 0
				bindAuxiliaryUiColor(fill, "BackgroundColor3", "Accent")
				fill.Parent = track
				local fillCorner = Instance.new("UICorner")
				fillCorner.CornerRadius = UDim.new(1, 0)
				fillCorner.Parent = fill
				local knob = Instance.new("Frame")
				knob.AnchorPoint = Vector2.new(0.5, 0.5)
				knob.Position = UDim2.fromScale(0, 0.5)
				knob.Size = UDim2.fromOffset(14, 14)
				knob.BackgroundColor3 = Color3.new(1, 1, 1)
				knob.BorderSizePixel = 0
				knob.ZIndex = 2
				knob.Parent = track
				local knobCorner = Instance.new("UICorner")
				knobCorner.CornerRadius = UDim.new(1, 0)
				knobCorner.Parent = knob
				local knobStroke = Instance.new("UIStroke")
				knobStroke.Thickness = 2
				bindAuxiliaryUiColor(knobStroke, "Color", "Accent")
				knobStroke.Parent = knob
				-- A taller invisible strip over the track, so it's easy to grab.
				local grab = Instance.new("TextButton")
				grab.Position = UDim2.fromOffset(-7, 26)
				grab.Size = UDim2.new(1, 14, 0, 22)
				grab.BackgroundTransparency = 1
				grab.AutoButtonColor = false
				grab.Text = ""
				grab.ZIndex = 3
				grab.Parent = holder

				local function show(value)
					local fraction = (value - options.min) / (options.max - options.min)
					fill.Size = UDim2.fromScale(fraction, 1)
					knob.Position = UDim2.fromScale(fraction, 0.5)
					if not valueBox:IsFocused() then
						valueBox.Text = formatValue(value)
					end
				end
				table.insert(settingsCard.refreshers, function()
					show(snap(options.get()))
				end)

				-- Screen X lines up with the track's AbsolutePosition whatever the GUI inset is.
				local function setFromScreenX(x)
					local fraction = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
					local value = snap(options.min + fraction * (options.max - options.min))
					options.set(value)
					show(value)
				end
				local dragInput = nil
				grab.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragInput = input
						setFromScreenX(input.Position.X)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input == dragInput) then
						setFromScreenX(input.Position.X)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragInput = nil
						if options.commit then options.commit() end
					end
				end)
				valueBox.FocusLost:Connect(function()
					local typed = tonumber((valueBox.Text:gsub("[^%d%.%-]", "")))
					if typed then
						options.set(snap(typed))
						if options.commit then options.commit() end
					end
					-- Anything that isn't a number just snaps back to the current value.
					show(snap(options.get()))
				end)
				show(snap(options.get()))
			end

			-- If Rayfield scales its UI, AbsoluteSize includes that scale but Size doesn't.
			local function uiScaleFactor()
				local factor = 1
				local ancestor = card.Parent
				while ancestor do
					-- Some containers above the menu can refuse lookups; skip those.
					local found, uiScale = pcall(ancestor.FindFirstChildOfClass, ancestor, "UIScale")
					if found and uiScale then factor *= uiScale.Scale end
					ancestor = ancestor.Parent
				end
				return factor > 0 and factor or 1
			end

			local heightTween
			local function tweenCardHeight(info)
				if heightTween then heightTween:Cancel() end
				local height = settingsCard.expanded and content.AbsoluteSize.Y / uiScaleFactor() or 0
				heightTween = TweenService:Create(card, info, { Size = UDim2.new(cardWidth(), UDim.new(0, height)) })
				heightTween:Play()
				return heightTween
			end
			-- Same feel as Rayfield's dropdowns: 0.5s to open, 0.35s to follow a change in size.
			local openInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local resizeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			-- Keep the open card fitted to its content, e.g. once layout has run on the first open.
			content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if settingsCard.expanded then tweenCardHeight(resizeInfo) end
			end)

			function settingsCard.setExpanded(expanded)
				if expanded == settingsCard.expanded then return end
				settingsCard.expanded = expanded
				if expanded then
					-- Values can change from commands too, so show them fresh.
					settingsCard.refresh()
					card.Visible = true
				end
				local tween = tweenCardHeight(openInfo)
				if not expanded then
					tween.Completed:Connect(function(playbackState)
						-- Hidden once closed, so the tab's list doesn't keep a gap for it.
						if playbackState == Enum.PlaybackState.Completed and not settingsCard.expanded then
							card.Visible = false
						end
					end)
				end
				for _, callback in ipairs(settingsCard.onExpandedChanged) do
					callback(expanded)
				end
			end
			function settingsCard.toggle()
				settingsCard.setExpanded(not settingsCard.expanded)
			end

			-- Right-click anywhere on the switch's row opens or closes the card.
			local interact = entry.object.interact
			if typeof(interact) == "Instance" and interact:IsA("GuiButton") then
				interact.MouseButton2Click:Connect(settingsCard.toggle)
			else
				row.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton2 then
						settingsCard.toggle()
					end
				end)
			end
			return settingsCard
		end

		-- ESP settings: right-click the ESP switch, or use the arrow next to it.
		local function buildEspSettings(espEntry)
			local espCard = createSettingsCard(espEntry)
			if not espCard then return end
			local content = espCard.content
			local nextOrder = espCard.nextOrder
			local refreshSettings = espCard.refresh
			local hexInput
			local function espOption(text, key)
				return {
					text = text,
					get = function() return espSettings[key] == true end,
					set = function(on)
						espSettings[key] = on
						saveEspSettings()
					end,
				}
			end

			espCard.addSectionLabel("PLAYERS", "users-round", "users")
			espCard.addSwitchGrid({ espOption("Only show enemies", "enemiesOnly") }, 1)
			local teamHint = Instance.new("TextLabel")
			teamHint.LayoutOrder = nextOrder()
			teamHint.Size = UDim2.new(1, 0, 0, 14)
			teamHint.AutomaticSize = Enum.AutomaticSize.Y
			teamHint.BackgroundTransparency = 1
			teamHint.Font = Enum.Font.Gotham
			teamHint.Text = "Hides your teammates. In games without teams, everyone still shows."
			teamHint.TextSize = 11
			teamHint.TextWrapped = true
			teamHint.TextXAlignment = Enum.TextXAlignment.Left
			bindAuxiliaryUiColor(teamHint, "TextColor3", "SubText")
			teamHint.Parent = content
			espCard.addSectionLabel("DRAW", "pen-line", "pencil")
			espCard.addSwitchGrid({ espOption("Outline", "outline"), espOption("Fill", "fill"), espOption("Box", "box"), espOption("Tracers", "tracers") })
			espCard.addSectionLabel("LABEL", "tag")
			espCard.addSwitchGrid({ espOption("Name", "name"), espOption("Distance", "distance"), espOption("Health bar", "health") })
			espCard.addSectionLabel("COLOUR", "palette")

			local modeRow = Instance.new("Frame")
			modeRow.LayoutOrder = nextOrder()
			modeRow.Size = UDim2.new(1, 0, 0, 28)
			modeRow.BackgroundTransparency = 1
			modeRow.Parent = content
			local modeRowWidth = Instance.new("UISizeConstraint")
			modeRowWidth.MaxSize = Vector2.new(330, 28)
			modeRowWidth.Parent = modeRow
			local modeLayout = Instance.new("UIListLayout")
			modeLayout.FillDirection = Enum.FillDirection.Horizontal
			modeLayout.Padding = UDim.new(0, 6)
			modeLayout.SortOrder = Enum.SortOrder.LayoutOrder
			modeLayout.Parent = modeRow
			local modeButtons = {}
			for index, mode in ipairs({ "Team", "Theme", "Custom" }) do
				local button = Instance.new("TextButton")
				button.LayoutOrder = index
				button.Size = UDim2.new(1 / 3, -4, 1, 0)
				button.AutoButtonColor = false
				button.BorderSizePixel = 0
				button.Font = Enum.Font.GothamMedium
				button.Text = mode
				button.TextSize = 12
				button.Parent = modeRow
				local buttonCorner = Instance.new("UICorner")
				buttonCorner.CornerRadius = UDim.new(0, 8)
				buttonCorner.Parent = button
				button.Activated:Connect(function()
					espSettings.colorMode = mode
					saveEspSettings()
					refreshSettings()
				end)
				modeButtons[mode] = button
			end

			local modeHints = {
				Team = "Team colours, or your theme colour when there are no teams.",
				Theme = "Always your menu theme's accent colour.",
				Custom = "Pick a colour below or type a hex code.",
			}
			local modeHint = Instance.new("TextLabel")
			modeHint.LayoutOrder = nextOrder()
			modeHint.Size = UDim2.new(1, 0, 0, 14)
			modeHint.AutomaticSize = Enum.AutomaticSize.Y
			modeHint.BackgroundTransparency = 1
			modeHint.Font = Enum.Font.Gotham
			modeHint.TextSize = 11
			modeHint.TextWrapped = true
			modeHint.TextXAlignment = Enum.TextXAlignment.Left
			bindAuxiliaryUiColor(modeHint, "TextColor3", "SubText")
			modeHint.Parent = content

			local swatchRow = Instance.new("Frame")
			swatchRow.LayoutOrder = nextOrder()
			swatchRow.Size = UDim2.new(1, 0, 0, 26)
			swatchRow.BackgroundTransparency = 1
			swatchRow.Parent = content
			local swatchLayout = Instance.new("UIListLayout")
			swatchLayout.FillDirection = Enum.FillDirection.Horizontal
			swatchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			swatchLayout.Padding = UDim.new(0, 8)
			swatchLayout.SortOrder = Enum.SortOrder.LayoutOrder
			swatchLayout.Parent = swatchRow
			local swatchRings = {}
			for index, hex in ipairs({ "FFFFFF", "FF5A5A", "FF9F43", "FFD43B", "4ADE80", "22D3EE", "60A5FA", "B1A4FF", "F472B6" }) do
				local swatch = Instance.new("TextButton")
				swatch.LayoutOrder = index
				swatch.Size = UDim2.fromOffset(22, 22)
				swatch.AutoButtonColor = false
				swatch.BorderSizePixel = 0
				swatch.Text = ""
				swatch.BackgroundColor3 = Color3.fromHex(hex)
				swatch.Parent = swatchRow
				local swatchCorner = Instance.new("UICorner")
				swatchCorner.CornerRadius = UDim.new(1, 0)
				swatchCorner.Parent = swatch
				-- A ring marks the colour in use.
				local ring = Instance.new("UIStroke")
				ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				ring.Thickness = 2
				ring.Parent = swatch
				swatch.Activated:Connect(function()
					espSettings.colorMode = "Custom"
					espSettings.customColor = hex
					saveEspSettings()
					refreshSettings()
				end)
				swatchRings[hex] = ring
			end

			-- Hex code on the left, reset on the right of the same line.
			local hexRow = Instance.new("Frame")
			hexRow.LayoutOrder = nextOrder()
			hexRow.Size = UDim2.new(1, 0, 0, 28)
			hexRow.BackgroundTransparency = 1
			hexRow.Parent = content
			local hexLabel = Instance.new("TextLabel")
			hexLabel.Size = UDim2.new(0, 80, 1, 0)
			hexLabel.BackgroundTransparency = 1
			hexLabel.Font = Enum.Font.Gotham
			hexLabel.Text = "Custom hex"
			hexLabel.TextSize = 12
			hexLabel.TextXAlignment = Enum.TextXAlignment.Left
			bindAuxiliaryUiColor(hexLabel, "TextColor3", "SubText")
			hexLabel.Parent = hexRow
			hexInput = Instance.new("TextBox")
			hexInput.AnchorPoint = Vector2.new(0, 0.5)
			hexInput.Position = UDim2.new(0, 84, 0.5, 0)
			hexInput.Size = UDim2.fromOffset(100, 26)
			hexInput.BorderSizePixel = 0
			hexInput.ClearTextOnFocus = false
			hexInput.Font = Enum.Font.GothamMedium
			hexInput.PlaceholderText = "#B1A4FF"
			hexInput.Text = ""
			hexInput.TextSize = 12
			bindAuxiliaryUiColor(hexInput, "BackgroundColor3", "Inset")
			bindAuxiliaryUiColor(hexInput, "TextColor3", "Text")
			bindAuxiliaryUiColor(hexInput, "PlaceholderColor3", "Muted")
			hexInput.Parent = hexRow
			local hexCorner = Instance.new("UICorner")
			hexCorner.CornerRadius = UDim.new(0, 8)
			hexCorner.Parent = hexInput
			local hexStroke = Instance.new("UIStroke")
			hexStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			hexStroke.Transparency = 0.35
			bindAuxiliaryUiColor(hexStroke, "Color", "Stroke")
			hexStroke.Parent = hexInput
			hexInput.FocusLost:Connect(function()
				local digits = hexInput.Text:gsub("[^%x]", "")
				if #digits == 6 then
					espSettings.colorMode = "Custom"
					espSettings.customColor = string.upper(digits)
					saveEspSettings()
				end
				-- Anything that isn't a 6-digit hex code just snaps back to the current colour.
				refreshSettings()
			end)

			local resetButton = Instance.new("TextButton")
			resetButton.AnchorPoint = Vector2.new(1, 0.5)
			resetButton.Position = UDim2.new(1, 0, 0.5, 0)
			resetButton.Size = UDim2.new(0, 130, 1, 0)
			resetButton.AutoButtonColor = false
			resetButton.BackgroundTransparency = 1
			resetButton.Font = Enum.Font.GothamMedium
			resetButton.Text = "Reset to defaults"
			resetButton.TextSize = 12
			resetButton.TextXAlignment = Enum.TextXAlignment.Right
			bindAuxiliaryUiColor(resetButton, "TextColor3", "Muted")
			resetButton.Parent = hexRow
			resetButton.MouseEnter:Connect(function() resetButton.TextColor3 = auxiliaryUiTheme.Text end)
			resetButton.MouseLeave:Connect(function() resetButton.TextColor3 = auxiliaryUiTheme.Muted end)
			resetButton.Activated:Connect(function()
				for key, value in pairs(espDefaultSettings) do
					espSettings[key] = value
				end
				saveEspSettings()
				refreshSettings()
			end)

			-- The colour choices depend on state too, so they refresh along with the switches.
			table.insert(espCard.refreshers, function()
				local theme = auxiliaryUiTheme
				for mode, button in pairs(modeButtons) do
					local selected = espSettings.colorMode == mode
					button.BackgroundColor3 = selected and theme.Accent or theme.Inset
					button.TextColor3 = selected and theme.OnAccent or theme.SubText
				end
				modeHint.Text = modeHints[espSettings.colorMode] or ""
				local customHex = string.upper(espSettings.customColor)
				for hex, ring in pairs(swatchRings) do
					ring.Color = theme.Text
					ring.Transparency = (espSettings.colorMode == "Custom" and hex == customHex) and 0 or 1
				end
				if not hexInput:IsFocused() then
					hexInput.Text = "#" .. customHex
				end
			end)
			refreshSettings()

			-- The arrow sits next to the switch, where other rows have their key box (ESP has no keybind).
			local chevronButton = Instance.new("TextButton")
			chevronButton.Name = "EspSettingsArrow"
			chevronButton.AnchorPoint = Vector2.new(1, 0.5)
			chevronButton.Position = UDim2.new(1, -71, 0, 20)
			chevronButton.Size = UDim2.fromOffset(26, 26)
			chevronButton.AutoButtonColor = false
			chevronButton.BackgroundTransparency = 1
			chevronButton.Text = ""
			-- Above the toggle's full-row click target (ZIndex 10) so the arrow doesn't flip ESP.
			chevronButton.ZIndex = 11
			chevronButton.Parent = espEntry.object.main
			local chevronIcon = Instance.new("ImageLabel")
			chevronIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			chevronIcon.Position = UDim2.fromScale(0.5, 0.5)
			chevronIcon.Size = UDim2.fromOffset(16, 16)
			chevronIcon.BackgroundTransparency = 1
			-- Rayfield's own dropdown arrow. It points up, so 180 is the closed (pointing down) state.
			chevronIcon.Image = "rbxassetid://88479147175134"
			chevronIcon.ImageTransparency = 0.2
			chevronIcon.Rotation = 180
			chevronIcon.ZIndex = 11
			bindAuxiliaryUiColor(chevronIcon, "ImageColor3", "Text")
			chevronIcon.Parent = chevronButton
			chevronButton.MouseEnter:Connect(function() chevronIcon.ImageTransparency = 0 end)
			chevronButton.MouseLeave:Connect(function() chevronIcon.ImageTransparency = 0.2 end)
			chevronButton.Activated:Connect(espCard.toggle)
			-- Turns like Rayfield's dropdown arrows, however the card was opened.
			local arrowInfo = TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			table.insert(espCard.onExpandedChanged, function(expanded)
				TweenService:Create(chevronIcon, arrowInfo, { Rotation = expanded and 0 or 180 }):Play()
			end)
		end

		-- Settings for the other switches that have them, opened by right-clicking the switch.
		local function buildFeatureSettings()
			local function speedText(value)
				return string.format("%.1f×", value)
			end

			local flyCard = createSettingsCard(quickToggleByName["Fly"])
			if flyCard then
				flyCard.addSectionLabel("SPEED", "gauge")
				flyCard.addSlider({
					text = "Fly speed",
					icon = { "wind" },
					min = 0.1, max = 10, step = 0.1,
					get = function() return tonumber(iyflyspeed) or 1 end,
					set = function(value)
						iyflyspeed = value
						featureSettings.flySpeed = value
					end,
					commit = saveFeatureSettings,
					format = speedText,
				})
				flyCard.addSectionLabel("CONTROLS", "keyboard")
				flyCard.addSwitchGrid({
					{
						text = "Q and E fly down and up",
						get = function() return QEfly ~= false end,
						set = function(on)
							QEfly = on
							featureSettings.flyUpDownKeys = on
							saveFeatureSettings()
						end,
					},
				}, 1)
			end

			local vehicleFlyCard = createSettingsCard(quickToggleByName["Vehicle Fly"])
			if vehicleFlyCard then
				vehicleFlyCard.addSectionLabel("SPEED", "gauge")
				vehicleFlyCard.addSlider({
					text = "Vehicle fly speed",
					icon = { "car" },
					min = 0.1, max = 10, step = 0.1,
					get = function() return tonumber(vehicleflyspeed) or 1 end,
					set = function(value)
						vehicleflyspeed = value
						featureSettings.vehicleFlySpeed = value
					end,
					commit = saveFeatureSettings,
					format = speedText,
				})
			end

			local freecamCard = createSettingsCard(quickToggleByName["Freecam"])
			if freecamCard then
				freecamCard.addSectionLabel("SPEED", "gauge")
				freecamCard.addSlider({
					text = "Freecam speed",
					icon = { "video" },
					min = 0.5, max = 10, step = 0.5,
					get = function() return typeof(NAV_KEYBOARD_SPEED) == "Vector3" and NAV_KEYBOARD_SPEED.X or 1 end,
					set = function(value)
						NAV_KEYBOARD_SPEED = Vector3.new(value, value, value)
						featureSettings.freecamSpeed = value
					end,
					commit = saveFeatureSettings,
					format = speedText,
				})
			end

			local chamsCard = createSettingsCard(quickToggleByName["Chams"])
			if chamsCard then
				chamsCard.addSectionLabel("LOOK", "palette")
				chamsCard.addSlider({
					text = "Fill strength",
					icon = { "paint-bucket", "droplet", "palette" },
					min = 10, max = 75, step = 1,
					-- Chams fill at esptransparency + 0.25, so this is how solid that fill looks.
					get = function() return (0.75 - (tonumber(espTransparency) or 0.3)) * 100 end,
					set = function(value)
						espTransparency = 0.75 - value / 100
						for _, holder in pairs(COREGUI:GetChildren()) do
							if string.sub(holder.Name, -5) == "_CHMS" then
								local highlight = holder:FindFirstChild("PlayerHighlight")
								if highlight then
									highlight.FillTransparency = math.clamp(espTransparency + 0.25, 0.25, 0.9)
								end
							end
						end
						-- ESP's fill reads the same setting.
						espStyleVersion += 1
					end,
					-- Infinite Yield saves esptransparency with its own settings.
					commit = function() updatesaves() end,
					format = function(value) return tostring(math.floor(value + 0.5)) .. "%" end,
				})
			end
		end

		-- Kept separate so a problem in a settings card can't stop the rest of the menu loading.
		local espSettingsOk, espSettingsError = pcall(buildEspSettings, quickToggleByName["ESP"])
		if not espSettingsOk then
			warn("[SpreadCheeksGUI] ESP settings couldn't be added: " .. tostring(espSettingsError))
		end
		local featureSettingsOk, featureSettingsError = pcall(buildFeatureSettings)
		if not featureSettingsOk then
			warn("[SpreadCheeksGUI] Feature settings couldn't be added: " .. tostring(featureSettingsError))
		end

		local function addCommandSlider(tab, name, minValue, maxValue, initialValue, command, increment, suffix, ...)
			withIcon(tab, "CreateSlider", {
				name = name,
				range = { minValue, maxValue },
				value = initialValue,
				increment = increment or 1,
				suffix = suffix,
				callback = function(value)
					execCmd(command .. " " .. tostring(value), Players.LocalPlayer, true)
				end,
			}, ...)
		end

		-- Fly and freecam speed are in those switches' settings cards (right-click them). These land
		-- at the bottom of their tabs: Mobility gets a section of its own, and Field of View joins
		-- the Camera section in View.
		withIcon(mobilityTab, "CreateSection", { name = "Character values" }, "gauge")
		addCommandSlider(mobilityTab, "Walk Speed", 0, 150, 16, "speed", 1, nil, "gauge")
		addCommandSlider(mobilityTab, "Jump Power", 0, 300, 50, "jpower", 1, nil, "arrow-big-up")
		addCommandSlider(mobilityTab, "Gravity", 0, 300, 196, "gravity", 1, nil, "orbit")
		addCommandSlider(viewTab, "Field of View", 40, 120, 70, "fov", 1, "°", "focus")

		-- Whether the pointer is over this menu. Clicks there are for the menu (right-clicking a switch
		-- for its settings, say): they never count as the aim key, and the trigger bot doesn't fire.
		local function pointerOverMenu()
			local main = window.main
			if typeof(main) ~= "Instance" or not main.Visible or window.hidden then return false end
			local point = UserInputService:GetMouseLocation()
			-- Mouse positions count from the very top of the screen; a GUI's positions start under
			-- Roblox's top bar unless it ignores the bar.
			local screenGui = main:FindFirstAncestorWhichIsA("ScreenGui")
			if screenGui and not screenGui.IgnoreGuiInset then
				point -= (GuiService:GetGuiInset())
			end
			local position, size = main.AbsolutePosition, main.AbsoluteSize
			return point.X >= position.X and point.X <= position.X + size.X
				and point.Y >= position.Y and point.Y <= position.Y + size.Y
		end

		-- Aimbot: while the aim key is held, turns your view (or moves your cursor) onto the player
		-- nearest the cursor inside the FOV circle, and stays on them until you let go. Its switch
		-- (aimbotToggle) is under ESP.
		local function buildAimbot()
			local localPlayer = Players.LocalPlayer
			local state = aimbotState

			-- Saved choices that no longer make sense go back to their defaults.
			local savedKey = featureSettings.aimbotKey
			if savedKey ~= "RightClick" and savedKey ~= "LeftClick" then
				local keyOk, keyCode = pcall(function() return Enum.KeyCode[savedKey] end)
				if not keyOk or not keyCode or reservedKeys[keyCode] then
					featureSettings.aimbotKey = "RightClick"
				end
			end
			if featureSettings.aimbotPart ~= "Torso" then featureSettings.aimbotPart = "Head" end
			if not table.find({ "Camera", "Mouse", "Free aim" }, featureSettings.aimbotMethod) then
				featureSettings.aimbotMethod = "Camera"
			end
			if not table.find({ "Theme", "Rainbow", "Custom" }, featureSettings.aimbotFovColorMode) then
				featureSettings.aimbotFovColorMode = "Theme"
			end
			if not featureSettings.aimbotFovColor:match("^%x%x%x%x%x%x$") then
				featureSettings.aimbotFovColor = "B1A4FF"
			end

			local keyText = aimbotKeyText
			-- Whether the aim key is physically held down right now. This reads the mouse and
			-- keyboard directly rather than waiting for input events: games can take those over
			-- (many claim right click for their own aiming), and then the events never arrive here.
			local cachedKeyName, cachedKeyCode = nil, nil
			local function aimInputDown()
				local name = featureSettings.aimbotKey
				if name == "RightClick" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
				if name == "LeftClick" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
				if name ~= cachedKeyName then
					cachedKeyName = name
					local keyOk, keyCode = pcall(function() return Enum.KeyCode[name] end)
					cachedKeyCode = keyOk and keyCode or nil
				end
				return cachedKeyCode ~= nil and UserInputService:IsKeyDown(cachedKeyCode)
			end

			-- The FOV circle, centred on the cursor. Targets are picked from inside it.
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
			local previousGui = playerGui:FindFirstChild("SpreadCheeksAimbot")
			if previousGui then previousGui:Destroy() end
			local fovGui = Instance.new("ScreenGui")
			fovGui.Name = "SpreadCheeksAimbot"
			fovGui.ResetOnSpawn = false
			fovGui.IgnoreGuiInset = true
			-- Under the keybind list (999), the ; bar and the notifications.
			fovGui.DisplayOrder = 998
			fovGui.Parent = playerGui
			local fovCircle = Instance.new("Frame")
			fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
			fovCircle.BackgroundTransparency = 1
			fovCircle.Visible = false
			fovCircle.Parent = fovGui
			local fovCorner = Instance.new("UICorner")
			fovCorner.CornerRadius = UDim.new(1, 0)
			fovCorner.Parent = fovCircle
			local fovStroke = Instance.new("UIStroke")
			fovStroke.Thickness = 1.5
			fovStroke.Transparency = 0.4
			fovStroke.Color = auxiliaryUiTheme.AccentText
			fovStroke.Parent = fovCircle
			-- The circle's colour, set every frame so Rainbow can cycle and theme changes show at once.
			local parsedHex, parsedColor = nil, nil
			local function fovColor()
				local mode = featureSettings.aimbotFovColorMode
				if mode == "Rainbow" then
					-- Once round the colour wheel every 4 seconds.
					return Color3.fromHSV((os.clock() / 4) % 1, 0.7, 1)
				elseif mode == "Custom" then
					if parsedHex ~= featureSettings.aimbotFovColor then
						parsedHex = featureSettings.aimbotFovColor
						local colorOk, color = pcall(Color3.fromHex, parsedHex)
						parsedColor = colorOk and color or nil
					end
					if parsedColor then return parsedColor end
				end
				return auxiliaryUiTheme.AccentText
			end
			-- Solid while locked onto someone.
			local function showLocked(locked)
				fovStroke.Transparency = locked and 0 or 0.4
				fovStroke.Thickness = locked and 2 or 1.5
			end

			local function aimPart(character)
				if featureSettings.aimbotPart == "Torso" then
					return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
				end
				return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
			end
			-- The part to aim at on this player, or nil when they can't be a target.
			local function targetPart(player)
				if player == localPlayer then return nil end
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then return nil end
				if featureSettings.aimbotTeamCheck and espIsTeammate(player) then return nil end
				local part = aimPart(character)
				return part and part:IsA("BasePart") and part or nil
			end
			local wallParams = RaycastParams.new()
			wallParams.FilterType = Enum.RaycastFilterType.Exclude
			wallParams.IgnoreWater = true
			-- Whether the camera can see the part. See-through parts, like glass and invisible
			-- walls, don't count as cover.
			local function canSee(part, character)
				local camera = workspace.CurrentCamera
				local origin = camera.CFrame.Position
				local ignore = { camera, character }
				if localPlayer.Character then table.insert(ignore, localPlayer.Character) end
				for _ = 1, 5 do
					wallParams.FilterDescendantsInstances = ignore
					local hit = workspace:Raycast(origin, part.Position - origin, wallParams)
					if not hit then return true end
					if hit.Instance.Transparency < 0.8 then return false end
					table.insert(ignore, hit.Instance)
				end
				return false
			end
			-- Whether a target can still be aimed at from here: on screen and, with wall check on, in view.
			local function canAimAt(part, character)
				local _, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
				return onScreen and (not featureSettings.aimbotWallCheck or canSee(part, character))
			end
			-- The player nearest the cursor inside the circle. Walls are only checked for players
			-- closer than the best so far, which keeps the raycasts down.
			local function findTarget(cursor)
				local camera = workspace.CurrentCamera
				local best, bestDistance = nil, featureSettings.aimbotFov
				for _, player in ipairs(Players:GetPlayers()) do
					local part = targetPart(player)
					if part then
						local point, onScreen = camera:WorldToViewportPoint(part.Position)
						local distance = (Vector2.new(point.X, point.Y) - cursor).Magnitude
						if onScreen and distance < bestDistance
							and (not featureSettings.aimbotWallCheck or canSee(part, player.Character)) then
							best, bestDistance = player, distance
						end
					end
				end
				return best
			end

			-- Random target: aim at a random body part instead of always the head or torso. A new part
			-- is picked for each new target and again every second or so while the key is held, and
			-- the head and torso come up twice as often as an arm or leg. Targets are still found and
			-- kept by the last Head/Torso choice (the head at first), so the circle, team check and
			-- wall check work as before.
			local bodyRegions = {
				{ "Head", { "Head" } },
				{ "Torso", { "UpperTorso", "Torso", "LowerTorso" } },
				{ "Left arm", { "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm" } },
				{ "Right arm", { "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm" } },
				{ "Left leg", { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg" } },
				{ "Right leg", { "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg" } },
			}
			local randomGenerator = Random.new()
			local randomPick = { target = nil, part = nil, nextPickAt = 0 }
			-- A random body part of the character; with visibleOnly, only parts the camera can see.
			local function pickRandomPart(character, visibleOnly)
				local choices, totalWeight = {}, 0
				for _, region in ipairs(bodyRegions) do
					local parts = {}
					for _, partName in ipairs(region[2]) do
						local part = character:FindFirstChild(partName)
						if part and part:IsA("BasePart") and (not visibleOnly or canSee(part, character)) then
							table.insert(parts, part)
						end
					end
					if #parts > 0 then
						local weight = (region[1] == "Head" or region[1] == "Torso") and 2 or 1
						table.insert(choices, { parts = parts, weight = weight })
						totalWeight += weight
					end
				end
				if totalWeight == 0 then return nil end
				local roll = randomGenerator:NextNumber() * totalWeight
				local chosen = choices[#choices]
				for _, choice in ipairs(choices) do
					roll -= choice.weight
					if roll <= 0 then
						chosen = choice
						break
					end
				end
				return chosen.parts[randomGenerator:NextInteger(1, #chosen.parts)]
			end
			-- The part to aim at on the locked target while Random target is on, or the fallback.
			local function randomPartFor(target, fallback)
				local character = target.Character
				if not character then return fallback end
				local now = os.clock()
				local part = randomPick.part
				if randomPick.target ~= target or now >= randomPick.nextPickAt or not part or not part:IsDescendantOf(character) then
					part = pickRandomPart(character, featureSettings.aimbotWallCheck)
					randomPick.target = target
					randomPick.nextPickAt = now + randomGenerator:NextNumber(0.6, 1.6)
				elseif featureSettings.aimbotWallCheck and not canSee(part, character) then
					-- The part went behind cover, so swap to one still in view.
					part = pickRandomPart(character, true)
				end
				randomPick.part = part
				return part or fallback
			end

			local moveMouse = type(mousemoverel) == "function" and mousemoverel or nil
			-- Mouse moves are whole pixels, so the part of a move that's left over is carried into the
			-- next frame; otherwise small corrections would be lost and the aim would stop short.
			local mouseRemainder = Vector2.zero
			local function nudgeMouse(dx, dy)
				local total = mouseRemainder + Vector2.new(math.clamp(dx, -1000, 1000), math.clamp(dy, -1000, 1000))
				local wholeX = total.X < 0 and math.ceil(total.X) or math.floor(total.X)
				local wholeY = total.Y < 0 and math.ceil(total.Y) or math.floor(total.Y)
				mouseRemainder = total - Vector2.new(wholeX, wholeY)
				if wholeX ~= 0 or wholeY ~= 0 then
					moveMouse(wholeX, wholeY)
				end
			end
			-- The player's camera sensitivity from Roblox's settings, which scales how far the camera
			-- turns for each pixel the mouse moves.
			local userGameSettings = nil
			pcall(function() userGameSettings = UserSettings():GetService("UserGameSettings") end)
			local function mouseSensitivity()
				local readOk, value = pcall(function() return userGameSettings.MouseSensitivity end)
				return (readOk and type(value) == "number" and value > 0) and value or 1
			end
			-- Free aim never touches the camera. It moves the mouse the way you would, so a game that
			-- runs its own camera turns it itself.
			local function freeAim(camera, cursor, point, alpha)
				local offsetX, offsetY = point.X - cursor.X, point.Y - cursor.Y
				if UserInputService.MouseBehavior == Enum.MouseBehavior.Default then
					-- A free cursor moves pixel for pixel, so it's moved straight onto them.
					nudgeMouse(offsetX * alpha, offsetY * alpha)
					return
				end
				-- A locked mouse turns the camera instead. Work out how far it has to turn to face
				-- them, then how much mouse movement that is at Roblox's usual camera speed (the
				-- Free aim speed slider covers games that turn faster or slower).
				local focalLength = (camera.ViewportSize.Y / 2) / math.tan(math.rad(camera.FieldOfView) / 2)
				local yaw = math.atan(offsetX / focalLength)
				local pitch = math.atan(offsetY / focalLength)
				local scale = alpha * featureSettings.aimbotFreeAimSpeed / mouseSensitivity()
				nudgeMouse(yaw / (0.002 * math.pi) * scale, pitch / (0.0015 * math.pi) * scale)
			end

			local wasDown, pressCounts = false, false
			local function step(deltaTime)
				-- A press of the aim key counts unless it started on this menu, while typing, or while
				-- setting a new key, and it keeps counting until the key comes back up.
				local down = aimInputDown()
				if not down then
					pressCounts = false
					state.ignoreUntilRelease = false
				elseif not wasDown then
					pressCounts = not state.ignoreUntilRelease and not UserInputService:GetFocusedTextBox() and not pointerOverMenu()
				end
				wasDown = down
				state.held = down and pressCounts

				local camera = workspace.CurrentCamera
				local cursor = UserInputService:GetMouseLocation()
				local radius = featureSettings.aimbotFov
				fovCircle.Visible = state.enabled and featureSettings.aimbotShowFov
				if fovCircle.Visible then
					fovCircle.Position = UDim2.fromOffset(cursor.X, cursor.Y)
					fovCircle.Size = UDim2.fromOffset(radius * 2, radius * 2)
					fovStroke.Color = fovColor()
				end
				if not state.enabled or not state.held or not camera then
					state.target = nil
					randomPick.target = nil
					mouseRemainder = Vector2.zero
					showLocked(false)
					return
				end
				-- Stay on the same player while the key is held, for as long as they can be aimed at.
				local target, part = state.target, nil
				if target and target.Parent then
					part = targetPart(target)
					if part and not canAimAt(part, target.Character) then part = nil end
				end
				if not part then
					target = findTarget(cursor)
					part = target and targetPart(target)
				end
				state.target = part and target or nil
				showLocked(part ~= nil)
				if not part then return end

				local aimAt = part
				if featureSettings.aimbotRandomPart then
					aimAt = randomPartFor(target, part)
				end

				-- Smoothness 1 snaps straight on; higher values close the gap more slowly. Scaled by
				-- frame time so it feels the same at any frame rate.
				local smoothness = featureSettings.aimbotSmoothness
				local alpha = smoothness <= 1 and 1 or 1 - (1 - 1 / smoothness) ^ math.clamp(deltaTime * 60, 0, 10)
				local method = featureSettings.aimbotMethod
				if method == "Free aim" and moveMouse then
					freeAim(camera, cursor, camera:WorldToViewportPoint(aimAt.Position), alpha)
				elseif method == "Mouse" and moveMouse then
					local point = camera:WorldToViewportPoint(aimAt.Position)
					nudgeMouse((point.X - cursor.X) * alpha, (point.Y - cursor.Y) * alpha)
				else
					local from = camera.CFrame
					camera.CFrame = from:Lerp(CFrame.lookAt(from.Position, aimAt.Position), alpha)
				end
			end
			-- Right after Roblox's camera has moved for the frame, so this has the final say.
			pcall(function() RunService:UnbindFromRenderStep("SpreadCheeksAimbot") end)
			RunService:BindToRenderStep("SpreadCheeksAimbot", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
				local stepOk, problem = pcall(step, deltaTime)
				if not stepOk then
					RunService:UnbindFromRenderStep("SpreadCheeksAimbot")
					fovCircle.Visible = false
					warn("[SpreadCheeksGUI] The aimbot stopped: " .. tostring(problem))
				end
			end)

			local toggle = aimbotToggle

			-- The aim key box, like the key boxes on the Controls switches. Click it, then press a
			-- key or click a mouse button in the game; Esc cancels.
			local recording, recordSerial = false, 0
			local chip, chipStroke = nil, nil
			local function showChip()
				if not chip then return end
				local text = recording and "Recording" or keyText()
				local width = TextService:GetTextSize(text, chip.TextSize, chip.Font, Vector2.new(1000, 24)).X
				chip.Text = text
				chip.Size = UDim2.fromOffset(math.clamp(width + 22, 40, 130), 24)
				chipStroke.Color = recording and auxiliaryUiTheme.Accent or auxiliaryUiTheme.Stroke
				chipStroke.Transparency = recording and 0 or 0.35
			end
			local function stopRecording()
				recording = false
				recordSerial += 1
				showChip()
			end
			local row = toggle and toggle.main
			if typeof(row) == "Instance" then
				chip = Instance.new("TextButton")
				chip.Name = "AimKeyChip"
				chip.AnchorPoint = Vector2.new(1, 0.5)
				-- Where the Controls switches have their key boxes, left of the switch.
				chip.Position = UDim2.new(1, -73, 0, 20)
				chip.AutoButtonColor = false
				chip.BorderSizePixel = 0
				chip.Font = Enum.Font.GothamMedium
				chip.TextSize = 13
				-- Above the toggle's full-row click target (ZIndex 10) so clicking the box doesn't flip the switch.
				chip.ZIndex = 11
				bindAuxiliaryUiColor(chip, "BackgroundColor3", "Inset")
				bindAuxiliaryUiColor(chip, "TextColor3", "Text")
				local chipCorner = Instance.new("UICorner")
				chipCorner.CornerRadius = UDim.new(1, 0)
				chipCorner.Parent = chip
				chipStroke = Instance.new("UIStroke")
				chipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				bindAuxiliaryUiColor(chipStroke, "Color", "Stroke")
				chipStroke.Parent = chip
				chip.MouseButton1Click:Connect(function()
					if recording then
						stopRecording()
						return
					end
					recording = true
					recordSerial += 1
					local serial = recordSerial
					showChip()
					-- Stop waiting if nothing is pressed, so a stray press later doesn't change it.
					task.delay(10, function()
						if recording and recordSerial == serial then stopRecording() end
					end)
				end)
				chip.Parent = row
				showChip()
				table.insert(auxiliaryUiThemeListeners, showChip)
			end

			-- Settings, opened by right-clicking the switch.
			local card = createSettingsCard({ name = "Aimbot", object = toggle })
			if card then
				local function setting(text, key)
					return {
						text = text,
						get = function() return featureSettings[key] == true end,
						set = function(on)
							featureSettings[key] = on
							saveFeatureSettings()
						end,
					}
				end
				-- Buttons for a saved choice, like the ESP colour modes.
				local function addChoice(options, key)
					card.addChoice(options, function() return featureSettings[key] end, function(option)
						featureSettings[key] = option
						saveFeatureSettings()
					end)
				end

				card.addSectionLabel("TARGET", "target", "crosshair")
				-- Random is saved apart from the Head/Torso choice, which finding targets still goes by.
				card.addChoice({ "Head", "Torso", "Random" }, function()
					return featureSettings.aimbotRandomPart and "Random" or featureSettings.aimbotPart
				end, function(option)
					if option == "Random" then
						featureSettings.aimbotRandomPart = true
					else
						featureSettings.aimbotPart = option
						featureSettings.aimbotRandomPart = false
					end
					saveFeatureSettings()
				end)
				card.addHint(function()
					if featureSettings.aimbotRandomPart then
						return "Picks a random body part, mostly the head and torso, and switches every second or so."
					end
					return nil
				end)
				card.addSwitchGrid({ setting("Team check", "aimbotTeamCheck"), setting("Wall check", "aimbotWallCheck") })

				card.addSectionLabel("AIM", "mouse-pointer-2", "mouse-pointer")
				addChoice({ "Camera", "Mouse", "Free aim" }, "aimbotMethod")
				card.addHint(function()
					local method = featureSettings.aimbotMethod
					if method == "Camera" then
						return "Turns your view onto them. Best in first person or shift lock. If the game runs its own camera and this doesn't stick, use Free aim."
					elseif not moveMouse then
						return "Your executor can't move the mouse, so the camera is used instead."
					elseif method == "Mouse" then
						return "Moves your cursor onto them, for games that shoot where you click."
					end
					return "For games that run their own camera. Never touches the camera; moves your mouse like you would, so the game turns it. If it stops short, raise Free aim speed; if it overshoots or shakes, lower it."
				end)
				card.addSlider({
					text = "Smoothness",
					icon = { "waves", "activity" },
					min = 1, max = 10, step = 0.5,
					get = function() return featureSettings.aimbotSmoothness end,
					set = function(value) featureSettings.aimbotSmoothness = value end,
					commit = saveFeatureSettings,
					format = function(value) return value <= 1 and "Instant" or string.format("%.1f", value) end,
				})
				card.addSlider({
					text = "Free aim speed",
					icon = { "gauge" },
					min = 0.1, max = 3, step = 0.1,
					get = function() return featureSettings.aimbotFreeAimSpeed end,
					set = function(value) featureSettings.aimbotFreeAimSpeed = value end,
					commit = saveFeatureSettings,
					format = function(value) return string.format("%.1f×", value) end,
				})

				card.addSectionLabel("FOV", "circle-dashed", "circle")
				card.addSlider({
					text = "Circle size",
					icon = { "circle-dashed", "circle" },
					min = 20, max = 600, step = 10,
					get = function() return featureSettings.aimbotFov end,
					set = function(value) featureSettings.aimbotFov = value end,
					commit = saveFeatureSettings,
					format = function(value) return math.floor(value + 0.5) .. " px" end,
				})
				card.addSwitchGrid({ setting("Show FOV circle", "aimbotShowFov") }, 1)

				-- Circle colour: the theme's accent, a cycling rainbow, or a colour of your own.
				card.addSectionLabel("CIRCLE COLOUR", "palette")
				addChoice({ "Theme", "Rainbow", "Custom" }, "aimbotFovColorMode")
				local function useCustomColor(hex)
					featureSettings.aimbotFovColorMode = "Custom"
					featureSettings.aimbotFovColor = string.upper(hex)
					saveFeatureSettings()
					card.refresh()
				end
				local swatchRow = Instance.new("Frame")
				swatchRow.LayoutOrder = card.nextOrder()
				swatchRow.Size = UDim2.new(1, 0, 0, 26)
				swatchRow.BackgroundTransparency = 1
				swatchRow.Parent = card.content
				local swatchLayout = Instance.new("UIListLayout")
				swatchLayout.FillDirection = Enum.FillDirection.Horizontal
				swatchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				swatchLayout.Padding = UDim.new(0, 8)
				swatchLayout.SortOrder = Enum.SortOrder.LayoutOrder
				swatchLayout.Parent = swatchRow
				local swatchRings = {}
				for index, hex in ipairs({ "FFFFFF", "FF5A5A", "FF9F43", "FFD43B", "4ADE80", "22D3EE", "60A5FA", "B1A4FF", "F472B6" }) do
					local swatch = Instance.new("TextButton")
					swatch.LayoutOrder = index
					swatch.Size = UDim2.fromOffset(22, 22)
					swatch.AutoButtonColor = false
					swatch.BorderSizePixel = 0
					swatch.Text = ""
					swatch.BackgroundColor3 = Color3.fromHex(hex)
					swatch.Parent = swatchRow
					local swatchCorner = Instance.new("UICorner")
					swatchCorner.CornerRadius = UDim.new(1, 0)
					swatchCorner.Parent = swatch
					-- A ring marks the colour in use.
					local ring = Instance.new("UIStroke")
					ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					ring.Thickness = 2
					ring.Parent = swatch
					swatch.Activated:Connect(function() useCustomColor(hex) end)
					swatchRings[hex] = ring
				end

				local hexRow = Instance.new("Frame")
				hexRow.LayoutOrder = card.nextOrder()
				hexRow.Size = UDim2.new(1, 0, 0, 28)
				hexRow.BackgroundTransparency = 1
				hexRow.Parent = card.content
				local hexLabel = Instance.new("TextLabel")
				hexLabel.Size = UDim2.new(0, 80, 1, 0)
				hexLabel.BackgroundTransparency = 1
				hexLabel.Font = Enum.Font.Gotham
				hexLabel.Text = "Custom hex"
				hexLabel.TextSize = 12
				hexLabel.TextXAlignment = Enum.TextXAlignment.Left
				bindAuxiliaryUiColor(hexLabel, "TextColor3", "SubText")
				hexLabel.Parent = hexRow
				local hexInput = Instance.new("TextBox")
				hexInput.AnchorPoint = Vector2.new(0, 0.5)
				hexInput.Position = UDim2.new(0, 84, 0.5, 0)
				hexInput.Size = UDim2.fromOffset(100, 26)
				hexInput.BorderSizePixel = 0
				hexInput.ClearTextOnFocus = false
				hexInput.Font = Enum.Font.GothamMedium
				hexInput.PlaceholderText = "#B1A4FF"
				hexInput.Text = ""
				hexInput.TextSize = 12
				bindAuxiliaryUiColor(hexInput, "BackgroundColor3", "Inset")
				bindAuxiliaryUiColor(hexInput, "TextColor3", "Text")
				bindAuxiliaryUiColor(hexInput, "PlaceholderColor3", "Muted")
				hexInput.Parent = hexRow
				local hexCorner = Instance.new("UICorner")
				hexCorner.CornerRadius = UDim.new(0, 8)
				hexCorner.Parent = hexInput
				local hexStroke = Instance.new("UIStroke")
				hexStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				hexStroke.Transparency = 0.35
				bindAuxiliaryUiColor(hexStroke, "Color", "Stroke")
				hexStroke.Parent = hexInput
				hexInput.FocusLost:Connect(function()
					local digits = hexInput.Text:gsub("[^%x]", "")
					if #digits == 6 then
						useCustomColor(digits)
					else
						-- Anything that isn't a 6-digit hex code just snaps back to the current colour.
						card.refresh()
					end
				end)
				table.insert(card.refreshers, function()
					local custom = featureSettings.aimbotFovColorMode == "Custom"
					local customHex = string.upper(featureSettings.aimbotFovColor)
					for hex, ring in pairs(swatchRings) do
						ring.Color = auxiliaryUiTheme.Text
						ring.Transparency = (custom and hex == customHex) and 0 or 1
					end
					if not hexInput:IsFocused() then
						hexInput.Text = "#" .. customHex
					end
				end)
				card.refresh()
			end

			-- Kept in the shared environment so running the script again drops the old listeners.
			if sharedEnv.SpreadCheeksAimbotConnections then
				for _, connection in ipairs(sharedEnv.SpreadCheeksAimbotConnections) do
					pcall(function() connection:Disconnect() end)
				end
			end
			local connections = {}
			sharedEnv.SpreadCheeksAimbotConnections = connections
			-- Only used to set a new aim key; holding the key is read each frame in step.
			table.insert(connections, UserInputService.InputBegan:Connect(function(input)
				if UserInputService:GetFocusedTextBox() then return end
				if recording then
					-- Whatever is pressed while setting the key doesn't start aiming.
					state.ignoreUntilRelease = true
					local newKey = nil
					if input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode == Enum.KeyCode.Escape then
							stopRecording()
							return
						elseif reservedKeys[input.KeyCode] then
							notify("Aimbot", input.KeyCode.Name .. " is reserved, pick another key")
							return
						elseif isMenuToggleKey(input.KeyCode) then
							notify("Aimbot", input.KeyCode.Name .. " already opens and closes the menu, pick another key")
							return
						end
						newKey = input.KeyCode.Name
					-- Clicks on the menu (such as on this box, to cancel) aren't taken as the key. Clicks
					-- in the game are, even where the game claims the button for itself.
					elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not pointerOverMenu() then
						newKey = "RightClick"
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 and not pointerOverMenu() then
						newKey = "LeftClick"
					end
					if newKey then
						featureSettings.aimbotKey = newKey
						saveFeatureSettings()
						stopRecording()
					end
				end
			end))
			-- A key held while Roblox loses focus is never seen coming back up, so it doesn't count.
			table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
				state.ignoreUntilRelease = true
			end))

			-- The on-screen keybind list shows the aim key while the aimbot is on.
			if keybindList and keybindList.addSource then
				keybindList.addSource(function()
					if state.enabled then
						return { name = "Aimbot", key = featureSettings.aimbotKey, kind = "hold" }
					end
					return nil
				end)
			end

			return {
				isEnabled = function() return state.enabled end,
			}
		end

		-- Kept separate so a problem in the aimbot can't stop the rest of the menu loading.
		local aimbotOk, aimbot = pcall(buildAimbot)
		if not aimbotOk then
			warn("[SpreadCheeksGUI] The aimbot couldn't be added: " .. tostring(aimbot))
			aimbot = nil
		end

		-- Trigger Bot: while it's on, clicks for you when the player under your crosshair (or cursor)
		-- is one you can shoot. Tap clicks once per shot delay; Hold keeps the button down while
		-- you're on them, for automatic guns. Its switch is under Aimbot.
		local function buildTriggerBot()
			local localPlayer = Players.LocalPlayer
			local state = triggerBotState
			if featureSettings.triggerMode ~= "Hold" then featureSettings.triggerMode = "Tap" end

			-- How clicks are made: the executor's own mouse functions when it has them, then Roblox's
			-- virtual input, and for guns that are Roblox tools, the equipped tool as a last resort.
			local virtualInput = nil
			pcall(function() virtualInput = game:GetService("VirtualInputManager") end)
			local clickMethod = "tool"
			if type(mouse1press) == "function" and type(mouse1release) == "function" then
				clickMethod = "mouse"
			elseif virtualInput then
				clickMethod = "virtual"
			end
			-- Presses or releases the left mouse button; false when it can't, which leaves the tool.
			local function sendMouse(down)
				if clickMethod == "mouse" then
					if down then mouse1press() else mouse1release() end
					return true
				elseif clickMethod == "virtual" then
					local cursor = UserInputService:GetMouseLocation()
					local sent = pcall(function()
						virtualInput:SendMouseButtonEvent(cursor.X, cursor.Y, 0, down, game, 0)
					end)
					if sent then return true end
					-- Blocked here, so the tool is used from now on.
					clickMethod = "tool"
				end
				return false
			end
			local function activateTool()
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildOfClass("Tool")
				if tool then pcall(function() tool:Activate() end) end
			end
			local holding = false
			local function startHold()
				if not holding and sendMouse(true) then holding = true end
			end
			local function stopHold()
				if holding then
					holding = false
					sendMouse(false)
				end
			end
			state.stop = stopHold
			-- One click: press, then let go a moment later so the game sees a whole click.
			local function tap()
				if sendMouse(true) then
					task.delay(0.03, function() sendMouse(false) end)
				else
					activateTool()
				end
			end

			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.IgnoreWater = true
			-- The player whose character a part belongs to (hats and held tools included), if any.
			local function playerFromPart(part)
				local model = part:FindFirstAncestorOfClass("Model")
				while model do
					local player = Players:GetPlayerFromCharacter(model)
					if player then return player end
					model = model:FindFirstAncestorOfClass("Model")
				end
				return nil
			end
			-- The player a shot at the cursor would hit: the first thing on the line from the camera
			-- through the cursor, looking past see-through parts like glass and invisible walls.
			local function playerUnderCursor(camera, cursor)
				local ray = camera:ViewportPointToRay(cursor.X, cursor.Y)
				local ignore = { camera }
				if localPlayer.Character then table.insert(ignore, localPlayer.Character) end
				for _ = 1, 6 do
					rayParams.FilterDescendantsInstances = ignore
					local hit = workspace:Raycast(ray.Origin, ray.Direction * 2000, rayParams)
					if not hit then return nil end
					local player = playerFromPart(hit.Instance)
					if player then
						local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
						if player == localPlayer or not humanoid or humanoid.Health <= 0 then return nil end
						-- A teammate in the way blocks the shot rather than being shot.
						if featureSettings.triggerTeamCheck and espIsTeammate(player) then return nil end
						return player
					end
					if hit.Instance.Transparency < 0.8 then return nil end
					table.insert(ignore, hit.Instance)
				end
				return nil
			end

			-- A small ring on the cursor: faint while it's watching, lit when a player is under it,
			-- with a dot while it's firing.
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
			local previousGui = playerGui:FindFirstChild("SpreadCheeksTriggerBot")
			if previousGui then previousGui:Destroy() end
			local indicatorGui = Instance.new("ScreenGui")
			indicatorGui.Name = "SpreadCheeksTriggerBot"
			indicatorGui.ResetOnSpawn = false
			indicatorGui.IgnoreGuiInset = true
			-- With the aimbot's circle, under the keybind list, the ; bar and the notifications.
			indicatorGui.DisplayOrder = 998
			indicatorGui.Parent = playerGui
			local indicator = Instance.new("Frame")
			indicator.AnchorPoint = Vector2.new(0.5, 0.5)
			indicator.Size = UDim2.fromOffset(18, 18)
			indicator.BackgroundTransparency = 1
			indicator.Visible = false
			indicator.Parent = indicatorGui
			local indicatorCorner = Instance.new("UICorner")
			indicatorCorner.CornerRadius = UDim.new(1, 0)
			indicatorCorner.Parent = indicator
			local indicatorStroke = Instance.new("UIStroke")
			indicatorStroke.Thickness = 2
			indicatorStroke.Parent = indicator
			local indicatorDot = Instance.new("Frame")
			indicatorDot.AnchorPoint = Vector2.new(0.5, 0.5)
			indicatorDot.Position = UDim2.fromScale(0.5, 0.5)
			indicatorDot.Size = UDim2.fromOffset(6, 6)
			indicatorDot.BorderSizePixel = 0
			indicatorDot.Visible = false
			indicatorDot.Parent = indicator
			local dotCorner = Instance.new("UICorner")
			dotCorner.CornerRadius = UDim.new(1, 0)
			dotCorner.Parent = indicatorDot

			local windowFocused = true
			local onTargetSince, lastShot = nil, 0
			local function step()
				local camera = workspace.CurrentCamera
				local cursor = UserInputService:GetMouseLocation()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				-- Never while typing, in Roblox's menu, over this menu, with Roblox in the background or
				-- while dead; with "Only while aim key held", only while the aim key is down.
				local active = state.enabled and camera ~= nil and windowFocused and not GuiService.MenuIsOpen
					and not UserInputService:GetFocusedTextBox() and not pointerOverMenu()
					and humanoid ~= nil and humanoid.Health > 0
					and (not featureSettings.triggerWhileAiming or aimbotState.held == true)
				local target = active and playerUnderCursor(camera, cursor) or nil
				local now = os.clock()
				if target then
					onTargetSince = onTargetSince or now
				else
					onTargetSince = nil
				end
				-- It fires once the crosshair has stayed on them for the reaction time.
				local ready = onTargetSince ~= nil and (now - onTargetSince) * 1000 >= featureSettings.triggerDelay
				if ready and featureSettings.triggerMode == "Hold" and clickMethod ~= "tool" then
					startHold()
				else
					stopHold()
					if ready and (now - lastShot) * 1000 >= featureSettings.triggerInterval then
						lastShot = now
						tap()
					end
				end

				indicator.Visible = state.enabled and featureSettings.triggerIndicator
				if indicator.Visible then
					local theme = auxiliaryUiTheme
					indicator.Position = UDim2.fromOffset(cursor.X, cursor.Y)
					indicatorStroke.Color = target and theme.AccentText or theme.Muted
					indicatorStroke.Transparency = target and 0 or (active and 0.3 or 0.7)
					indicatorDot.BackgroundColor3 = theme.AccentText
					indicatorDot.Visible = ready
				end
			end
			-- After the aimbot (Camera + 1) has turned the view for the frame, so this checks where the
			-- crosshair ends up.
			pcall(function() RunService:UnbindFromRenderStep("SpreadCheeksTriggerBot") end)
			RunService:BindToRenderStep("SpreadCheeksTriggerBot", Enum.RenderPriority.Camera.Value + 2, function()
				local stepOk, problem = pcall(step)
				if not stepOk then
					RunService:UnbindFromRenderStep("SpreadCheeksTriggerBot")
					pcall(stopHold)
					indicator.Visible = false
					warn("[SpreadCheeksGUI] The trigger bot stopped: " .. tostring(problem))
				end
			end)

			-- Kept in the shared environment so running the script again drops the old listeners.
			if sharedEnv.SpreadCheeksTriggerBotConnections then
				for _, connection in ipairs(sharedEnv.SpreadCheeksTriggerBotConnections) do
					pcall(function() connection:Disconnect() end)
				end
			end
			local connections = {}
			sharedEnv.SpreadCheeksTriggerBotConnections = connections
			-- Clicks only go out while Roblox is the window in front.
			table.insert(connections, UserInputService.WindowFocused:Connect(function()
				windowFocused = true
			end))
			table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
				windowFocused = false
				stopHold()
			end))

			-- Settings, opened by right-clicking the switch.
			local entry = quickToggleByName["Trigger Bot"]
			local card = entry and createSettingsCard(entry)
			if card then
				local function setting(text, key)
					return {
						text = text,
						get = function() return featureSettings[key] == true end,
						set = function(on)
							featureSettings[key] = on
							saveFeatureSettings()
						end,
					}
				end
				card.addSectionLabel("FIRING", "mouse-pointer-click", "target")
				card.addChoice({ "Tap", "Hold" }, function() return featureSettings.triggerMode end, function(mode)
					featureSettings.triggerMode = mode
					saveFeatureSettings()
				end)
				card.addHint(function()
					if clickMethod == "tool" then
						return "Your executor can't click for you, so it uses the tool you're holding instead, once per shot delay."
					elseif featureSettings.triggerMode == "Hold" then
						return "Holds the mouse button down while you're on them and lets go when you're off, for automatic guns."
					end
					return "Clicks once, then again every shot delay while you stay on them, for guns that fire once per click."
				end)
				card.addSlider({
					text = "Reaction time",
					icon = { "timer", "clock" },
					min = 0, max = 500, step = 10,
					get = function() return featureSettings.triggerDelay end,
					set = function(value) featureSettings.triggerDelay = value end,
					commit = saveFeatureSettings,
					format = function(value) return value <= 0 and "Instant" or (math.floor(value + 0.5) .. " ms") end,
				})
				card.addSlider({
					text = "Shot delay",
					icon = { "repeat", "rotate-cw" },
					min = 50, max = 1000, step = 10,
					get = function() return featureSettings.triggerInterval end,
					set = function(value) featureSettings.triggerInterval = value end,
					commit = saveFeatureSettings,
					format = function(value) return math.floor(value + 0.5) .. " ms" end,
				})
				card.addSectionLabel("WHEN", "shield-check", "shield")
				card.addSwitchGrid({ setting("Team check", "triggerTeamCheck"), setting("Show indicator", "triggerIndicator") })
				card.addSwitchGrid({ setting("Only while aim key held", "triggerWhileAiming") }, 1)
				card.addHint(function()
					return "With this on, it only fires while you hold the aimbot's aim key (" .. aimbotKeyText() .. "), so you choose when."
				end)
				card.refresh()
			end
		end

		-- Kept separate so a problem in the trigger bot can't stop the rest of the menu loading.
		local triggerBotOk, triggerBotError = pcall(buildTriggerBot)
		if not triggerBotOk then
			warn("[SpreadCheeksGUI] The trigger bot couldn't be added: " .. tostring(triggerBotError))
		end

		-- Cheater Detector: watches how other players move, ten times a second, and warns you when
		-- someone looks like they're flying, speed hacking, teleporting, walking through walls or
		-- flinging. It only has what your game sees to go on, so it says "possible": lag, jump pads
		-- and some game features can set it off. Its switch is in Protection.
		local function buildCheaterDetector()
			local localPlayer = Players.LocalPlayer
			if not table.find({ "Relaxed", "Normal", "Strict" }, featureSettings.cheatSensitivity) then
				featureSettings.cheatSensitivity = "Normal"
			end
			-- How far out of the ordinary something has to be before it says anything. flyTime is
			-- seconds off the ground; fallSpeed is how fast (studs/s, downwards) counts as falling;
			-- speedFactor multiplies their walk speed; teleport is studs in a tenth of a second;
			-- wallPasses is walls gone through in six seconds; flingSpeed and flingSpin are the
			-- velocity (studs/s) and spin (radians/s) that count as flinging.
			local sensitivities = {
				Relaxed = { flyTime = 4, fallSpeed = -3, speedFactor = 3, teleport = 120, wallPasses = 3, flingSpeed = 800, flingSpin = 120 },
				Normal = { flyTime = 2.5, fallSpeed = -6, speedFactor = 2.2, teleport = 80, wallPasses = 2, flingSpeed = 400, flingSpin = 60 },
				Strict = { flyTime = 1.6, fallSpeed = -10, speedFactor = 1.7, teleport = 50, wallPasses = 1, flingSpeed = 250, flingSpin = 40 },
			}
			local running, monitorSerial = false, 0
			local card = nil

			-- A red outline on a flagged player, gone after ten seconds.
			local previousMarks = COREGUI:FindFirstChild("SpreadCheeksCheaterMarks")
			if previousMarks then previousMarks:Destroy() end
			local markFolder = Instance.new("Folder")
			markFolder.Name = "SpreadCheeksCheaterMarks"
			markFolder.Parent = COREGUI
			local marks = setmetatable({}, { __mode = "k" })
			local function outline(player)
				local character = player.Character
				if not character then return end
				local mark = marks[player]
				if not mark or not mark.Parent then
					mark = Instance.new("Highlight")
					mark.Name = player.Name
					mark.FillTransparency = 1
					mark.OutlineColor = Color3.fromRGB(255, 90, 90)
					mark.OutlineTransparency = 0
					mark.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					mark.Parent = markFolder
					marks[player] = mark
				end
				mark.Adornee = character
				-- Flagged again before it fades: the ten seconds start over.
				local serial = (mark:GetAttribute("Serial") or 0) + 1
				mark:SetAttribute("Serial", serial)
				task.delay(10, function()
					if mark.Parent and mark:GetAttribute("Serial") == serial then
						mark:Destroy()
					end
				end)
			end

			-- The last few flags, newest first, listed in the settings card.
			local recentFlags = {}
			local lastFlagged = setmetatable({}, { __mode = "k" })
			local function flag(player, kind, short, message)
				local now = os.clock()
				local times = lastFlagged[player]
				if not times then
					times = {}
					lastFlagged[player] = times
				end
				-- At most once every 30 seconds for each player and kind of thing, so it doesn't nag.
				if times[kind] and now - times[kind] < 30 then return end
				times[kind] = now
				local who = player.DisplayName ~= player.Name and (player.DisplayName .. " (@" .. player.Name .. ")") or player.Name
				notify("Possible cheater", who .. " " .. message, 6)
				table.insert(recentFlags, 1, { name = player.DisplayName, short = short, at = os.time() })
				if #recentFlags > 6 then table.remove(recentFlags) end
				if featureSettings.cheatOutline then outline(player) end
				if card and card.expanded then card.refresh() end
			end

			-- When the game moves lots of players at once (a new round, say), that isn't cheating, so a
			-- big jump is only flagged if few others jumped at the same moment.
			local recentJumps = {}
			local function noteTeleport(player, distance)
				local at = os.clock()
				table.insert(recentJumps, { player = player, at = at })
				task.delay(1.2, function()
					local jumpers = {}
					for index = #recentJumps, 1, -1 do
						local jump = recentJumps[index]
						if os.clock() - jump.at > 5 then
							table.remove(recentJumps, index)
						elseif math.abs(jump.at - at) <= 1.5 then
							jumpers[jump.player] = true
						end
					end
					local count = 0
					for _ in pairs(jumpers) do count += 1 end
					if count < 3 and running and featureSettings.cheatTeleport and player.Parent then
						flag(player, "teleport", "teleporting", string.format("jumped %d studs in an instant. They may be teleporting.", math.floor(distance + 0.5)))
					end
				end)
			end

			local groundParams = RaycastParams.new()
			groundParams.FilterType = Enum.RaycastFilterType.Exclude
			local nearbyParams = OverlapParams.new()
			nearbyParams.FilterType = Enum.RaycastFilterType.Exclude
			nearbyParams.MaxParts = 20
			local wallParams = RaycastParams.new()
			wallParams.FilterType = Enum.RaycastFilterType.Exclude
			wallParams.IgnoreWater = true
			-- On something (or someone), in water, sitting, or right up against something solid, as
			-- when climbing a ladder or hugging a wall.
			local function isSupported(character, root, humanoid)
				if humanoid.SeatPart or humanoid.Sit then return true end
				groundParams.FilterDescendantsInstances = { character }
				if workspace:Raycast(root.Position, Vector3.new(0, -9, 0), groundParams) then return true end
				nearbyParams.FilterDescendantsInstances = { character }
				for _, part in ipairs(workspace:GetPartBoundsInBox(root.CFrame, Vector3.new(6, 8, 6), nearbyParams)) do
					if part.CanCollide then return true end
				end
				return false
			end

			-- What's known about each player's movement: where they've been over the last second
			-- and a half, and how long each odd thing has been going on.
			local trackers = setmetatable({}, { __mode = "k" })
			local function watch(player, now, limits, characters)
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not root or not humanoid or humanoid.Health <= 0 then
					trackers[player] = nil
					return
				end
				local tracker = trackers[player]
				-- A new character, or one not seen for a moment (it may have been too far away to load,
				-- or this game lagged): start again from here rather than call the gap a teleport.
				if not tracker or tracker.root ~= root or now - tracker.lastTime > 0.6 then
					local spawnedAt = (tracker and tracker.root == root) and tracker.spawnedAt or now
					tracker = { root = root, spawnedAt = spawnedAt, history = {}, wallPasses = {}, flingHits = {} }
					trackers[player] = tracker
					tracker.lastPosition, tracker.lastTime = root.Position, now
					table.insert(tracker.history, { now, root.Position })
					return
				end

				local position = root.Position
				local elapsed = now - tracker.lastTime
				local moved = position - tracker.lastPosition
				tracker.lastPosition, tracker.lastTime = position, now
				table.insert(tracker.history, { now, position })
				while now - tracker.history[1][1] > 1.6 do
					table.remove(tracker.history, 1)
				end
				-- Where they were about a second ago, for speeds over a whole second.
				local past, span = nil, 0
				for _, entry in ipairs(tracker.history) do
					if now - entry[1] <= 1.05 then
						past, span = entry, now - entry[1]
						break
					end
				end
				-- Nothing counts for a few seconds after spawning, while the game places them.
				local settled = now - tracker.spawnedAt > 4
				local seated = humanoid.SeatPart ~= nil or humanoid.Sit
				local supported = isSupported(character, root, humanoid)
				-- Low gravity makes jumps longer and falls slower, so the flying check allows for it.
				local gravityScale = math.max(workspace.Gravity, 1) / 196.2

				-- Teleporting: a big jump between two looks a tenth of a second apart.
				if featureSettings.cheatTeleport and settled and not seated and moved.Magnitude > limits.teleport then
					tracker.teleportedAt = now
					noteTeleport(player, moved.Magnitude)
				end
				local justTeleported = tracker.teleportedAt ~= nil and now - tracker.teleportedAt < 1.5

				-- Flying: off the ground for a while without falling.
				if supported then
					tracker.airborneSince = nil
				else
					tracker.airborneSince = tracker.airborneSince or now
					local airTime = now - tracker.airborneSince
					local climb = span >= 0.8 and (position.Y - past[2].Y) / span or nil
					if featureSettings.cheatFly and settled and not justTeleported and climb
						and airTime >= limits.flyTime / math.sqrt(gravityScale)
						and climb > limits.fallSpeed * gravityScale then
						flag(player, "fly", "flying", string.format("has been in the air for %ds without falling. They may be flying.", math.floor(airTime + 0.5)))
					end
				end

				-- Speed: on the ground and covering far more of it than their walk speed allows.
				if featureSettings.cheatSpeed and settled and supported and not seated and not justTeleported and span >= 0.8 then
					local flat = Vector3.new(position.X - past[2].X, 0, position.Z - past[2].Z)
					local speed = flat.Magnitude / span
					if speed > math.max(humanoid.WalkSpeed, 16) * limits.speedFactor + 6 then
						tracker.fastSince = tracker.fastSince or now
						if now - tracker.fastSince >= 1 then
							flag(player, "speed", "speed hacking", string.format("is moving at %d studs/s (their walk speed is %d). They may be speed hacking.", math.floor(speed + 0.5), math.floor(humanoid.WalkSpeed + 0.5)))
						end
					else
						tracker.fastSince = nil
					end
				else
					tracker.fastSince = nil
				end

				-- Noclip: going straight through something solid between two looks. Glass, invisible
				-- walls and parts you can walk through don't count, and neither do other players.
				if featureSettings.cheatNoclip and settled and not seated and not justTeleported then
					local flatMove = Vector3.new(moved.X, 0, moved.Z).Magnitude
					if flatMove > 0.5 and moved.Magnitude < 25 then
						wallParams.FilterDescendantsInstances = characters
						local hit = workspace:Raycast(position - moved, moved, wallParams)
						local wall = hit and hit.Instance
						if wall and wall.CanCollide and wall.Transparency < 0.95 and not wall:IsA("TrussPart") then
							table.insert(tracker.wallPasses, now)
						end
					end
					while #tracker.wallPasses > 0 and now - tracker.wallPasses[1] > 6 do
						table.remove(tracker.wallPasses, 1)
					end
					if #tracker.wallPasses >= limits.wallPasses then
						tracker.wallPasses = {}
						flag(player, "noclip", "noclip", "went straight through a wall. They may be using noclip.")
					end
				end

				-- Flinging: huge speed or spin that doesn't actually carry them anywhere. (Someone
				-- being flung moves a long way, so they aren't flagged.)
				if featureSettings.cheatFling and settled then
					local velocity = root.AssemblyLinearVelocity.Magnitude
					local spin = root.AssemblyAngularVelocity.Magnitude
					local staysPut = moved.Magnitude < 10
					if staysPut and (spin > limits.flingSpin or (velocity > limits.flingSpeed and moved.Magnitude < velocity * elapsed * 0.2)) then
						table.insert(tracker.flingHits, now)
					end
					while #tracker.flingHits > 0 and now - tracker.flingHits[1] > 2 do
						table.remove(tracker.flingHits, 1)
					end
					if #tracker.flingHits >= 3 then
						tracker.flingHits = {}
						flag(player, "fling", "flinging", "is spinning or moving with huge, sudden force. They may be flinging people.")
					end
				end
			end

			local warnedOnce = false
			local function monitor(serial)
				while running and serial == monitorSerial do
					local now = os.clock()
					local limits = sensitivities[featureSettings.cheatSensitivity] or sensitivities.Normal
					-- Everyone's characters, so players walking through each other isn't noclip.
					local players = Players:GetPlayers()
					local characters = {}
					for _, player in ipairs(players) do
						if player.Character then table.insert(characters, player.Character) end
					end
					for _, player in ipairs(players) do
						if player ~= localPlayer then
							local watchOk, problem = pcall(watch, player, now, limits, characters)
							if not watchOk then
								trackers[player] = nil
								if not warnedOnce then
									warnedOnce = true
									warn("[SpreadCheeksGUI] Cheater Detector couldn't check " .. player.Name .. ": " .. tostring(problem))
								end
							end
						end
					end
					task.wait(0.1)
				end
			end
			local function setEnabled(enabled)
				enabled = enabled == true
				if enabled == running then return end
				running = enabled
				monitorSerial += 1
				if enabled then
					task.spawn(monitor, monitorSerial)
				else
					table.clear(trackers)
				end
			end

			-- Settings, opened by right-clicking the switch.
			local entry = quickToggleByName["Cheater Detector"]
			card = entry and createSettingsCard(entry)
			if card then
				local function setting(text, key)
					return {
						text = text,
						get = function() return featureSettings[key] == true end,
						set = function(on)
							featureSettings[key] = on
							saveFeatureSettings()
						end,
					}
				end
				local function timeAgo(seconds)
					if seconds < 10 then return "just now" end
					if seconds < 60 then return seconds .. "s ago" end
					if seconds < 3600 then return math.floor(seconds / 60) .. "m ago" end
					return math.floor(seconds / 3600) .. "h ago"
				end

				card.addSectionLabel("WATCH FOR", "scan-eye", "eye")
				card.addSwitchGrid({
					setting("Flying", "cheatFly"),
					setting("Speed", "cheatSpeed"),
					setting("Teleporting", "cheatTeleport"),
					setting("Noclip", "cheatNoclip"),
					setting("Flinging", "cheatFling"),
				})
				card.addSectionLabel("SENSITIVITY", "gauge")
				card.addChoice({ "Relaxed", "Normal", "Strict" }, function() return featureSettings.cheatSensitivity end, function(level)
					featureSettings.cheatSensitivity = level
					saveFeatureSettings()
				end)
				card.addHint(function()
					local level = featureSettings.cheatSensitivity
					if level == "Relaxed" then
						return "Only clear-cut cases, like hovering for seconds or jumping across the map."
					elseif level == "Strict" then
						return "Catches more, but lag and game features like jump pads are more likely to set it off."
					end
					return "Catches most cheats with few false alarms."
				end)
				card.addSectionLabel("ALERTS", "bell")
				card.addSwitchGrid({ setting("Outline flagged players", "cheatOutline") }, 1)
				card.addHint("You get a notification naming the player and what they did, at most every 30 seconds for each player and kind of thing. The outline shows where they are, through walls, for 10 seconds.")
				card.addSectionLabel("RECENT", "history", "clock")
				card.addHint(function()
					if #recentFlags == 0 then return "Nothing flagged yet." end
					local lines = {}
					for _, recent in ipairs(recentFlags) do
						table.insert(lines, recent.name .. "  ·  " .. recent.short .. "  ·  " .. timeAgo(os.time() - recent.at))
					end
					return table.concat(lines, "\n")
				end)
				card.refresh()
			end

			return { setEnabled = setEnabled }
		end

		-- Kept separate so a problem in the detector can't stop the rest of the menu loading.
		local cheaterDetectorOk, builtCheaterDetector = pcall(buildCheaterDetector)
		if cheaterDetectorOk then
			cheaterDetector = builtCheaterDetector
		else
			warn("[SpreadCheeksGUI] Cheater Detector couldn't be added: " .. tostring(builtCheaterDetector))
		end
		-- Starts watching again if it was on last time.
		if featureSettings.cheatDetector and quickToggleByName["Cheater Detector"] then
			setQuickToggle(quickToggleByName["Cheater Detector"], true)
		end

		window:CreateSection({ name = "PLAYER TOOLS" })
		local playerTab = withIcon(window, "CreateTab", { name = "Players" }, "users-round", "users")
		withIcon(playerTab, "CreateSection", { name = "Select a player" }, "contact")
		playerTab:CreateText({
			text = "Choose a username from the current server list or type a name below. Actions use the selected username.",
		})

		local selectedPlayerName = Players.LocalPlayer.Name
		-- The player Locate is showing, while its switch is on.
		local locatedPlayerName = nil
		local selectedPlayerDisplay = withIcon(playerTab, "CreateText", {
			name = "Selected player",
			text = Players.LocalPlayer.DisplayName .. "  (@" .. Players.LocalPlayer.Name .. ")",
		}, "user-round")
		-- Picking someone else while Locate is on moves Locate to them.
		local function selectPlayer(name, label)
			selectedPlayerName = name
			selectedPlayerDisplay:Set(label)
			if locatedPlayerName and locatedPlayerName ~= name then
				execCmd("nolocate " .. locatedPlayerName, Players.LocalPlayer, true)
				execCmd("locate " .. name, Players.LocalPlayer, true)
				locatedPlayerName = name
			end
		end
		local function buildFacePicker()
			local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
			local pickerParent = playerGui
			if type(gethui) == "function" then
				local hiddenOk, hiddenGui = pcall(gethui)
				if hiddenOk and hiddenGui then pickerParent = hiddenGui end
			end
			local previousPicker = pickerParent:FindFirstChild("SpreadCheeksPlayerPicker")
			if previousPicker then previousPicker:Destroy() end
			if pickerParent ~= playerGui then
				local playerGuiPicker = playerGui:FindFirstChild("SpreadCheeksPlayerPicker")
				if playerGuiPicker then playerGuiPicker:Destroy() end
			end
			local pickerGui = Instance.new("ScreenGui")
			pickerGui.Name = "SpreadCheeksPlayerPicker"
			pickerGui.ResetOnSpawn = false
			pickerGui.IgnoreGuiInset = true
			pickerGui.DisplayOrder = 2147483647
			pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			pickerGui.Enabled = false
			pickerGui.Parent = pickerParent

			local backdrop = Instance.new("TextButton")
			backdrop.Size = UDim2.fromScale(1, 1)
			backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
			backdrop.BackgroundTransparency = 0.38
			backdrop.Text = ""
			backdrop.AutoButtonColor = false
			backdrop.Parent = pickerGui

			local panel = Instance.new("Frame")
			panel.AnchorPoint = Vector2.new(0.5, 0.5)
			panel.Position = UDim2.fromScale(0.5, 0.5)
			panel.Size = UDim2.new(0.86, 0, 0.78, 0)
			panel.BackgroundColor3 = Color3.fromRGB(18, 21, 28)
			panel.BorderSizePixel = 0
			panel.Active = true
			panel.Parent = pickerGui
			bindAuxiliaryUiColor(panel, "BackgroundColor3", "Background")
			local panelConstraint = Instance.new("UISizeConstraint")
			panelConstraint.MinSize = Vector2.new(300, 320)
			panelConstraint.MaxSize = Vector2.new(560, 500)
			panelConstraint.Parent = panel
			local panelCorner = Instance.new("UICorner")
			panelCorner.CornerRadius = UDim.new(0, 13)
			panelCorner.Parent = panel
			local panelStroke = Instance.new("UIStroke")
			panelStroke.Color = Color3.fromRGB(59, 66, 82)
			panelStroke.Transparency = 0.15
			panelStroke.Parent = panel
			bindAuxiliaryUiColor(panelStroke, "Color", "Stroke")

			local dragHandle = Instance.new("Frame")
			dragHandle.Name = "DragHandle"
			dragHandle.Position = UDim2.fromOffset(0, 0)
			dragHandle.Size = UDim2.new(1, -52, 0, 58)
			dragHandle.BackgroundTransparency = 1
			dragHandle.Active = true
			dragHandle.Parent = panel

			local pickerTitle = Instance.new("TextLabel")
			pickerTitle.Position = UDim2.fromOffset(18, 13)
			pickerTitle.Size = UDim2.new(1, -70, 0, 22)
			pickerTitle.BackgroundTransparency = 1
			pickerTitle.Font = Enum.Font.GothamSemibold
			pickerTitle.Text = "Choose a player"
			pickerTitle.TextColor3 = Color3.fromRGB(237, 240, 246)
			pickerTitle.TextSize = 16
			pickerTitle.TextXAlignment = Enum.TextXAlignment.Left
			pickerTitle.Parent = panel
			bindAuxiliaryUiColor(pickerTitle, "TextColor3", "Text")

			local selectedLabel = Instance.new("TextLabel")
			selectedLabel.Position = UDim2.fromOffset(18, 37)
			selectedLabel.Size = UDim2.new(1, -70, 0, 16)
			selectedLabel.BackgroundTransparency = 1
			selectedLabel.Font = Enum.Font.Gotham
			selectedLabel.TextColor3 = Color3.fromRGB(154, 163, 179)
			selectedLabel.TextSize = 11
			selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
			selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
			selectedLabel.Parent = panel
			bindAuxiliaryUiColor(selectedLabel, "TextColor3", "SubText")
			local titleIcon = menuIcons.get("users-round", "users")
			if titleIcon then
				local titleIconLabel = Instance.new("ImageLabel")
				titleIconLabel.Position = UDim2.fromOffset(18, 16)
				titleIconLabel.Size = UDim2.fromOffset(18, 18)
				titleIconLabel.BackgroundTransparency = 1
				menuIcons.apply(titleIconLabel, titleIcon)
				titleIconLabel.Parent = panel
				bindAuxiliaryUiColor(titleIconLabel, "ImageColor3", "AccentText")
				pickerTitle.Position = UDim2.fromOffset(44, 13)
				selectedLabel.Position = UDim2.fromOffset(44, 37)
			end
			dragHandle.Parent = nil
			dragHandle.Parent = panel

			local pickerDrag = {}
			local pickerDragMove = UserInputService.InputChanged:Connect(function(input)
				if not pickerDrag.input then return end
				if pickerDrag.input.UserInputType == Enum.UserInputType.MouseButton1 then
					if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
				elseif input ~= pickerDrag.input then
					return
				end
				local delta = Vector2.new(input.Position.X, input.Position.Y) - pickerDrag.origin
				local screenSize = pickerGui.AbsoluteSize
				local panelSize = panel.AbsoluteSize
				local centerX = screenSize.X * pickerDrag.panelPosition.X.Scale + pickerDrag.panelPosition.X.Offset + delta.X
				local centerY = screenSize.Y * pickerDrag.panelPosition.Y.Scale + pickerDrag.panelPosition.Y.Offset + delta.Y
				centerX = math.clamp(centerX, panelSize.X / 2 + 8, math.max(panelSize.X / 2 + 8, screenSize.X - panelSize.X / 2 - 8))
				centerY = math.clamp(centerY, panelSize.Y / 2 + 8, math.max(panelSize.Y / 2 + 8, screenSize.Y - panelSize.Y / 2 - 8))
				panel.Position = UDim2.new(
					pickerDrag.panelPosition.X.Scale,
					centerX - screenSize.X * pickerDrag.panelPosition.X.Scale,
					pickerDrag.panelPosition.Y.Scale,
					centerY - screenSize.Y * pickerDrag.panelPosition.Y.Scale
				)
			end)
			local pickerDragEnd = UserInputService.InputEnded:Connect(function(input)
				if not pickerDrag.input then return end
				if pickerDrag.input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1 then
					pickerDrag.input = nil
				elseif pickerDrag.input.UserInputType == Enum.UserInputType.Touch and input == pickerDrag.input then
					pickerDrag.input = nil
				end
			end)
			local pickerFocusReleased = UserInputService.WindowFocusReleased:Connect(function()
				pickerDrag.input = nil
			end)
			pickerGui.Destroying:Connect(function()
				pickerDragMove:Disconnect()
				pickerDragEnd:Disconnect()
				pickerFocusReleased:Disconnect()
			end)
			local function beginPickerDrag(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
				pickerDrag.input = input
				pickerDrag.origin = Vector2.new(input.Position.X, input.Position.Y)
				pickerDrag.panelPosition = panel.Position
			end
			dragHandle.InputBegan:Connect(beginPickerDrag)

			local closePicker = Instance.new("TextButton")
			closePicker.AnchorPoint = Vector2.new(1, 0)
			closePicker.Position = UDim2.new(1, -12, 0, 10)
			closePicker.Size = UDim2.fromOffset(30, 30)
			closePicker.BackgroundColor3 = Color3.fromRGB(37, 43, 55)
			closePicker.Text = "×"
			closePicker.Font = Enum.Font.Gotham
			closePicker.TextSize = 20
			closePicker.TextColor3 = Color3.fromRGB(184, 191, 204)
			closePicker.Parent = panel
			bindAuxiliaryUiColor(closePicker, "BackgroundColor3", "Card")
			bindAuxiliaryUiColor(closePicker, "TextColor3", "SubText")
			local closeCorner = Instance.new("UICorner")
			closeCorner.CornerRadius = UDim.new(0, 8)
			closeCorner.Parent = closePicker

			local searchInput = Instance.new("TextBox")
			searchInput.Position = UDim2.fromOffset(16, 63)
			searchInput.Size = UDim2.new(1, -32, 0, 34)
			searchInput.BackgroundColor3 = Color3.fromRGB(12, 14, 19)
			searchInput.BorderSizePixel = 0
			searchInput.ClearTextOnFocus = false
			searchInput.PlaceholderText = "Search players"
			searchInput.PlaceholderColor3 = Color3.fromRGB(104, 113, 130)
			searchInput.Text = ""
			searchInput.TextColor3 = Color3.fromRGB(237, 240, 246)
			searchInput.Font = Enum.Font.Gotham
			searchInput.TextSize = 12
			searchInput.TextXAlignment = Enum.TextXAlignment.Left
			searchInput.Parent = panel
			bindAuxiliaryUiColor(searchInput, "BackgroundColor3", "Field")
			bindAuxiliaryUiColor(searchInput, "BackgroundTransparency", "FieldTransparency")
			bindAuxiliaryUiColor(searchInput, "PlaceholderColor3", "Muted")
			bindAuxiliaryUiColor(searchInput, "TextColor3", "Text")
			local searchCorner = Instance.new("UICorner")
			searchCorner.CornerRadius = UDim.new(0, 8)
			searchCorner.Parent = searchInput
			local searchPadding = Instance.new("UIPadding")
			searchPadding.PaddingLeft = UDim.new(0, 10)
			searchPadding.Parent = searchInput
			local searchIcon = menuIcons.get("search")
			if searchIcon then
				-- Drawn over the box's left edge; it doesn't take clicks, so the box still gets them.
				local searchIconLabel = Instance.new("ImageLabel")
				searchIconLabel.AnchorPoint = Vector2.new(0, 0.5)
				searchIconLabel.Position = UDim2.fromOffset(27, 80)
				searchIconLabel.Size = UDim2.fromOffset(14, 14)
				searchIconLabel.BackgroundTransparency = 1
				searchIconLabel.ZIndex = 2
				menuIcons.apply(searchIconLabel, searchIcon)
				searchIconLabel.Parent = panel
				bindAuxiliaryUiColor(searchIconLabel, "ImageColor3", "Muted")
				searchPadding.PaddingLeft = UDim.new(0, 34)
			end

			local faceList = Instance.new("ScrollingFrame")
			faceList.Position = UDim2.fromOffset(14, 108)
			faceList.Size = UDim2.new(1, -28, 1, -122)
			faceList.BackgroundTransparency = 1
			faceList.BorderSizePixel = 0
			faceList.ScrollBarThickness = 3
			faceList.ScrollBarImageColor3 = Color3.fromRGB(104, 113, 130)
			faceList.AutomaticCanvasSize = Enum.AutomaticSize.Y
			faceList.CanvasSize = UDim2.new()
			faceList.Parent = panel
			bindAuxiliaryUiColor(faceList, "ScrollBarImageColor3", "Muted")
			local tileGap, minTileWidth, tileHeight = 8, 104, 112
			local faceGrid = Instance.new("UIGridLayout")
			faceGrid.CellSize = UDim2.fromOffset(minTileWidth, tileHeight)
			faceGrid.CellPadding = UDim2.fromOffset(tileGap, tileGap)
			faceGrid.SortOrder = Enum.SortOrder.LayoutOrder
			faceGrid.Parent = faceList
			-- Tiles stretch to fill each row, so the grid doesn't leave an empty strip on the right.
			local function fitTiles()
				local width = faceList.AbsoluteSize.X - faceList.ScrollBarThickness - 4
				if width <= 0 then return end
				local columns = math.max(1, math.floor((width + tileGap) / (minTileWidth + tileGap)))
				local tileWidth = math.floor((width - tileGap * (columns - 1)) / columns)
				faceGrid.CellSize = UDim2.fromOffset(tileWidth, tileHeight)
			end
			faceList:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitTiles)

			local function refreshFaceCards()
				for _, child in ipairs(faceList:GetChildren()) do
					if child:IsA("GuiObject") and child ~= faceGrid then child:Destroy() end
				end
				local roster = Players:GetPlayers()
				table.sort(roster, function(left, right)
					return left.Name:lower() < right.Name:lower()
				end)
				selectedLabel.Text = "Selected: " .. tostring(selectedPlayerName)
				for index, targetPlayer in ipairs(roster) do
					local tile = Instance.new("TextButton")
					tile.Name = "Player_" .. targetPlayer.Name
					tile.LayoutOrder = index
					tile.BackgroundColor3 = targetPlayer.Name == selectedPlayerName and Color3.fromRGB(42, 37, 66) or Color3.fromRGB(26, 30, 40)
					tile.Text = ""
					tile.AutoButtonColor = false
					tile.Parent = faceList
					bindAuxiliaryUiColor(tile, "BackgroundColor3", targetPlayer.Name == selectedPlayerName and "SelectedCard" or "Card")
					local tileCorner = Instance.new("UICorner")
					tileCorner.CornerRadius = UDim.new(0, 9)
					tileCorner.Parent = tile
					local tileStroke = Instance.new("UIStroke")
					tileStroke.Color = targetPlayer.Name == selectedPlayerName and Color3.fromRGB(157, 139, 255) or Color3.fromRGB(55, 62, 77)
					tileStroke.Transparency = targetPlayer.Name == selectedPlayerName and 0 or 0.55
					tileStroke.Parent = tile
					bindAuxiliaryUiColor(tileStroke, "Color", targetPlayer.Name == selectedPlayerName and "Accent" or "Stroke")

					local face = Instance.new("ImageLabel")
					face.AnchorPoint = Vector2.new(0.5, 0)
					face.Position = UDim2.new(0.5, 0, 0, 7)
					face.Size = UDim2.fromOffset(70, 70)
					face.BackgroundColor3 = Color3.fromRGB(41, 47, 60)
					face.Image = ""
					face.Parent = tile
					bindAuxiliaryUiColor(face, "BackgroundColor3", "Inset")
					local faceCorner = Instance.new("UICorner")
					faceCorner.CornerRadius = UDim.new(1, 0)
					faceCorner.Parent = face
					local nameLabel = Instance.new("TextLabel")
					nameLabel.Position = UDim2.new(0, 4, 0, 80)
					nameLabel.Size = UDim2.new(1, -8, 0, 16)
					nameLabel.BackgroundTransparency = 1
					nameLabel.Font = Enum.Font.GothamMedium
					nameLabel.Text = targetPlayer.DisplayName
					nameLabel.TextColor3 = Color3.fromRGB(237, 240, 246)
					nameLabel.TextSize = 11
					nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
					nameLabel.Parent = tile
					bindAuxiliaryUiColor(nameLabel, "TextColor3", "Text")
					local userLabel = Instance.new("TextLabel")
					userLabel.Position = UDim2.new(0, 4, 0, 95)
					userLabel.Size = UDim2.new(1, -8, 0, 12)
					userLabel.BackgroundTransparency = 1
					userLabel.Font = Enum.Font.Gotham
					userLabel.Text = "@" .. targetPlayer.Name
					userLabel.TextColor3 = Color3.fromRGB(145, 153, 169)
					userLabel.TextSize = 9
					userLabel.TextTruncate = Enum.TextTruncate.AtEnd
					userLabel.Parent = tile
					bindAuxiliaryUiColor(userLabel, "TextColor3", "SubText")

					tile.Activated:Connect(function()
						selectPlayer(targetPlayer.Name, targetPlayer.DisplayName .. "  (@" .. targetPlayer.Name .. ")")
						selectedLabel.Text = "Selected: " .. targetPlayer.DisplayName .. "  (@" .. targetPlayer.Name .. ")"
						pickerGui.Enabled = false
					end)
					task.spawn(function()
						local ok, image = pcall(function()
							return Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
						end)
						if ok and tile.Parent then face.Image = image end
					end)
				end
			end

			searchInput:GetPropertyChangedSignal("Text"):Connect(function()
				local query = searchInput.Text:lower()
				for _, tile in ipairs(faceList:GetChildren()) do
					if tile:IsA("TextButton") then
						local playerName = tile.Name:gsub("^Player_", ""):lower()
						local targetPlayer = Players:FindFirstChild(tile.Name:gsub("^Player_", ""))
						local displayName = targetPlayer and targetPlayer.DisplayName:lower() or ""
						tile.Visible = query == "" or playerName:find(query, 1, true) ~= nil or displayName:find(query, 1, true) ~= nil
					end
				end
			end)
			backdrop.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
				local point = Vector2.new(input.Position.X, input.Position.Y)
				local panelPosition = panel.AbsolutePosition
				local panelSize = panel.AbsoluteSize
				local insidePanel = point.X >= panelPosition.X and point.X <= panelPosition.X + panelSize.X
					and point.Y >= panelPosition.Y and point.Y <= panelPosition.Y + panelSize.Y
				if not insidePanel then pickerGui.Enabled = false end
			end)
			closePicker.Activated:Connect(function() pickerGui.Enabled = false end)
			Players.PlayerAdded:Connect(refreshFaceCards)
			Players.PlayerRemoving:Connect(refreshFaceCards)
			refreshFaceCards()
			withIcon(playerTab, "CreateButton", {
				name = "Player picker",
				description = "Choose a player from their face and username",
				callback = function()
					refreshFaceCards()
					searchInput.Text = ""
					pickerGui.Enabled = true
					fitTiles()
				end,
			}, "layout-grid")
		end
		buildFacePicker()
		withIcon(playerTab, "CreateInput", {
			name = "Player name",
			description = "Enter a username if the player is not in the list",
			placeholder = selectedPlayerName,
			callback = function(value)
				local name = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
				if name ~= "" then
					selectPlayer(name, "@" .. name)
				end
			end,
		}, "at-sign")

		local function runForSelectedPlayer(command)
			local name = tostring(selectedPlayerName or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if name ~= "" then
				execCmd(command .. " " .. name, Players.LocalPlayer, true)
			end
		end

		withIcon(playerTab, "CreateSection", { name = "Player actions" }, "crosshair")
		withIcon(playerTab, "CreateToggle", {
			name = "View selected player",
			value = false,
			callback = function(enabled)
				if enabled then
					runForSelectedPlayer("view")
				else
					execCmd("unview", Players.LocalPlayer, true)
				end
			end,
		}, "eye")
		withIcon(playerTab, "CreateToggle", {
			name = "Loop goto selected player",
			description = "Keep teleporting to the selected player",
			value = false,
			callback = function(enabled)
				if enabled then
					runForSelectedPlayer("loopgoto")
				else
					execCmd("unloopgoto", Players.LocalPlayer, true)
				end
			end,
		}, "repeat")
		withIcon(playerTab, "CreateToggle", {
			name = "Locate selected player",
			description = "Shows where they are, through walls, until you turn this off",
			value = false,
			callback = function(enabled)
				if enabled then
					local name = tostring(selectedPlayerName or ""):gsub("^%s+", ""):gsub("%s+$", "")
					if name ~= "" then
						locatedPlayerName = name
						execCmd("locate " .. name, Players.LocalPlayer, true)
					end
				elseif locatedPlayerName then
					execCmd("nolocate " .. locatedPlayerName, Players.LocalPlayer, true)
					locatedPlayerName = nil
				end
			end,
		}, "locate", "crosshair")
		withIcon(playerTab, "CreateButton", {
			name = "Go to selected player",
			callback = function() runForSelectedPlayer("goto") end,
		}, "navigation")
		withIcon(playerTab, "CreateButton", {
			name = "TP unanchored parts to selected player",
			description = "Move loose, unanchored parts to the selected player's character",
			callback = function() runForSelectedPlayer("tpunanchored") end,
		}, "magnet")

		window:CreateSection({ name = "TOOLS" })
		local runTab = withIcon(window, "CreateTab", { name = "Command Bar" }, "square-terminal", "terminal-square")
		withIcon(runTab, "CreateSection", { name = "Run a command" }, "square-terminal", "terminal-square")
		runTab:CreateText({
			text = "Type a command and its arguments, then press Enter. Your command prefix is optional. You can also press ; anywhere: it suggests commands as you type (Tab fills one in), and Up and Down step through commands you've run.",
		})
		withIcon(runTab, "CreateInput", {
			name = "Command input",
			description = "Examples: fly   •   speed 32   •   goto playername",
			placeholder = "Enter command and arguments",
			callback = function(value)
				local commandText = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
				if commandText:sub(1, #prefix) == prefix then
					commandText = commandText:sub(#prefix + 1)
				end
				if commandText ~= "" then
					execCmd(commandText, Players.LocalPlayer, true)
				end
			end,
		}, "chevron-right")

		-- Servers: every public server of this game, from Roblox's server list (the same one
		-- ;serverhop uses), each with a button to join it. Drawn with our own cards inside the tab's
		-- page, like Home.
		local serversTab = withIcon(window, "CreateTab", { name = "Servers" }, "server", "globe")
		local function buildServerBrowser()
			local page = serversTab and serversTab.tabPage
			if typeof(page) ~= "Instance" then
				warn("[SpreadCheeksGUI] Couldn't build the Servers page; Rayfield's tab layout may have changed.")
				return
			end

			local function addCorner(object, radius)
				local corner = Instance.new("UICorner")
				corner.CornerRadius = radius or UDim.new(0, 12)
				corner.Parent = object
			end
			-- A card in the menu's row colours (role is the background's theme role, Card by default).
			local function makeCard(parent, className, role)
				local card = Instance.new(className or "Frame")
				card.BorderSizePixel = 0
				bindAuxiliaryUiColor(card, "BackgroundColor3", role or "Card")
				addCorner(card)
				local stroke = Instance.new("UIStroke")
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				stroke.Transparency = 0.3
				bindAuxiliaryUiColor(stroke, "Color", "Stroke")
				stroke.Parent = card
				card.Parent = parent
				return card, stroke
			end
			local function makeLabel(parent, options)
				local label = Instance.new("TextLabel")
				label.BackgroundTransparency = 1
				label.Font = options.font or Enum.Font.Gotham
				label.TextSize = options.size or 12
				label.Text = options.text or ""
				label.TextXAlignment = options.alignX or Enum.TextXAlignment.Left
				label.TextTruncate = Enum.TextTruncate.AtEnd
				label.Position = options.position or UDim2.new()
				label.Size = options.frameSize or UDim2.new(1, 0, 0, (options.size or 12) + 4)
				bindAuxiliaryUiColor(label, "TextColor3", options.role or "Text")
				label.Parent = parent
				return label
			end
			local function makeIcon(parent, size, role, ...)
				local icon = menuIcons.get(...)
				local image = Instance.new("ImageLabel")
				image.BackgroundTransparency = 1
				image.Size = UDim2.fromOffset(size, size)
				image.Visible = icon ~= nil
				if icon then menuIcons.apply(image, icon) end
				bindAuxiliaryUiColor(image, "ImageColor3", role)
				image.Parent = parent
				return image
			end
			-- A small rounded button that's as wide as its text.
			local function makePill(parent, text, order)
				local pill = Instance.new("TextButton")
				pill.LayoutOrder = order or 0
				pill.AutomaticSize = Enum.AutomaticSize.X
				pill.Size = UDim2.fromOffset(0, 26)
				pill.AutoButtonColor = false
				pill.BorderSizePixel = 0
				pill.Font = Enum.Font.GothamMedium
				pill.Text = text
				pill.TextSize = 12
				addCorner(pill, UDim.new(0, 8))
				local padding = Instance.new("UIPadding")
				padding.PaddingLeft = UDim.new(0, 11)
				padding.PaddingRight = UDim.new(0, 11)
				padding.Parent = pill
				pill.Parent = parent
				return pill
			end
			local function commas(number)
				local text = tostring(math.floor(number))
				local grouped = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
				return (grouped:gsub("^,", ""))
			end

			local root = Instance.new("Frame")
			root.Name = "ServerBrowser"
			root.LayoutOrder = 1
			root.Size = UDim2.new(1, -20, 0, 0)
			root.AutomaticSize = Enum.AutomaticSize.Y
			root.BackgroundTransparency = 1
			root.Parent = page
			local rootLayout = Instance.new("UIListLayout")
			rootLayout.Padding = UDim.new(0, 8)
			rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rootLayout.Parent = root

			-- Header: what's loaded, Refresh, and how the list is sorted and filtered.
			local header = makeCard(root)
			header.LayoutOrder = 1
			header.Size = UDim2.fromScale(1, 0)
			header.AutomaticSize = Enum.AutomaticSize.Y
			local headerPadding = Instance.new("UIPadding")
			headerPadding.PaddingTop = UDim.new(0, 14)
			headerPadding.PaddingBottom = UDim.new(0, 14)
			headerPadding.PaddingLeft = UDim.new(0, 14)
			headerPadding.PaddingRight = UDim.new(0, 14)
			headerPadding.Parent = header
			-- Stacked, so the sort buttons can wrap onto a second line on a narrow menu.
			local headerLayout = Instance.new("UIListLayout")
			headerLayout.Padding = UDim.new(0, 8)
			headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
			headerLayout.Parent = header
			local titleRow = Instance.new("Frame")
			titleRow.LayoutOrder = 1
			titleRow.Size = UDim2.new(1, 0, 0, 26)
			titleRow.BackgroundTransparency = 1
			titleRow.Parent = header
			local headerIcon = makeIcon(titleRow, 18, "AccentText", "server", "globe")
			headerIcon.Position = UDim2.fromOffset(0, 4)
			makeLabel(titleRow, {
				text = "Servers", font = Enum.Font.GothamBold, size = 15,
				position = UDim2.fromOffset(26, 3), frameSize = UDim2.new(1, -130, 0, 20),
			})
			local refresh = makePill(titleRow, "Refresh")
			refresh.AnchorPoint = Vector2.new(1, 0)
			refresh.Position = UDim2.fromScale(1, 0)
			local summary = makeLabel(header, {
				text = "Press Refresh to load this game's servers.", size = 12, role = "SubText",
				frameSize = UDim2.new(1, 0, 0, 16),
			})
			summary.LayoutOrder = 2
			local controls = Instance.new("Frame")
			controls.LayoutOrder = 3
			controls.Size = UDim2.fromScale(1, 0)
			controls.AutomaticSize = Enum.AutomaticSize.Y
			controls.BackgroundTransparency = 1
			controls.Parent = header
			local controlsLayout = Instance.new("UIListLayout")
			controlsLayout.FillDirection = Enum.FillDirection.Horizontal
			controlsLayout.Padding = UDim.new(0, 6)
			controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			pcall(function() controlsLayout.Wraps = true end)
			controlsLayout.Parent = controls
			local footnote = makeLabel(header, {
				text = "Ping and FPS are what each server reports for its players.", size = 10, role = "Muted",
				frameSize = UDim2.new(1, 0, 0, 13),
			})
			footnote.LayoutOrder = 4

			-- Shown instead of the list when there's nothing to list, or something went wrong.
			local statusCard = makeCard(root)
			statusCard.LayoutOrder = 2
			statusCard.Size = UDim2.fromScale(1, 0)
			statusCard.AutomaticSize = Enum.AutomaticSize.Y
			local statusPadding = Instance.new("UIPadding")
			statusPadding.PaddingTop = UDim.new(0, 14)
			statusPadding.PaddingBottom = UDim.new(0, 14)
			statusPadding.PaddingLeft = UDim.new(0, 14)
			statusPadding.PaddingRight = UDim.new(0, 14)
			statusPadding.Parent = statusCard
			local statusText = makeLabel(statusCard, {
				text = "The server list loads when you open this tab, or press Refresh.", size = 12, role = "SubText",
			})
			statusText.Size = UDim2.fromScale(1, 0)
			statusText.AutomaticSize = Enum.AutomaticSize.Y
			statusText.TextWrapped = true
			statusText.TextTruncate = Enum.TextTruncate.None

			local list = Instance.new("Frame")
			list.LayoutOrder = 3
			list.Size = UDim2.fromScale(1, 0)
			list.AutomaticSize = Enum.AutomaticSize.Y
			list.BackgroundTransparency = 1
			list.Parent = root
			local listLayout = Instance.new("UIListLayout")
			listLayout.Padding = UDim.new(0, 6)
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Parent = list

			local loadMore, loadMoreStroke = makeCard(root, "TextButton")
			loadMore.LayoutOrder = 4
			loadMore.Size = UDim2.new(1, 0, 0, 40)
			loadMore.AutoButtonColor = false
			loadMore.Font = Enum.Font.GothamMedium
			loadMore.Text = "Load more servers"
			loadMore.TextSize = 13
			loadMore.Visible = false
			bindAuxiliaryUiColor(loadMore, "TextColor3", "Text")
			loadMore.MouseEnter:Connect(function() loadMoreStroke.Color = auxiliaryUiTheme.Accent end)
			loadMore.MouseLeave:Connect(function() loadMoreStroke.Color = auxiliaryUiTheme.Stroke end)

			-- Joining. Roblox says why a teleport fails (the server filled up or closed, say).
			local joining = false
			local function join(serverId)
				if joining then return end
				joining = true
				notify("Servers", "Joining that server...", 3)
				local started, problem = pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, Players.LocalPlayer)
				end)
				if not started then
					joining = false
					notify("Servers", "Couldn't join: " .. tostring(problem), 5)
					return
				end
				task.delay(10, function() joining = false end)
			end
			if sharedEnv.SpreadCheeksServerJoinFailed then
				pcall(function() sharedEnv.SpreadCheeksServerJoinFailed:Disconnect() end)
			end
			sharedEnv.SpreadCheeksServerJoinFailed = TeleportService.TeleportInitFailed:Connect(function(player, result, message)
				if player ~= Players.LocalPlayer then return end
				joining = false
				local reason = tostring(message or "")
				notify("Servers", "Couldn't join: " .. (reason ~= "" and reason or tostring(result)), 5)
			end)

			-- One server: how full it is, its ping and frame rate, and Join (or why not).
			local function makeServerRow(server, order)
				local playing = tonumber(server.playing) or 0
				local maxPlayers = tonumber(server.maxPlayers) or 0
				local isHere = server.id == game.JobId
				local isFull = maxPlayers > 0 and playing >= maxPlayers
				local row, rowStroke = makeCard(list, "Frame", isHere and "SelectedCard" or "Card")
				row.LayoutOrder = order
				row.Size = UDim2.new(1, 0, 0, 54)

				makeLabel(row, {
					text = playing .. " / " .. maxPlayers, font = Enum.Font.GothamBold, size = 14,
					position = UDim2.fromOffset(14, 9), frameSize = UDim2.fromOffset(78, 18),
				})
				local capacity = Instance.new("Frame")
				capacity.Position = UDim2.fromOffset(14, 33)
				capacity.Size = UDim2.fromOffset(70, 4)
				capacity.BorderSizePixel = 0
				bindAuxiliaryUiColor(capacity, "BackgroundColor3", "Inset")
				capacity.Parent = row
				addCorner(capacity, UDim.new(1, 0))
				local capacityFill = Instance.new("Frame")
				capacityFill.Size = UDim2.fromScale(maxPlayers > 0 and math.clamp(playing / maxPlayers, 0, 1) or 0, 1)
				capacityFill.BorderSizePixel = 0
				bindAuxiliaryUiColor(capacityFill, "BackgroundColor3", "Accent")
				capacityFill.Parent = capacity
				addCorner(capacityFill, UDim.new(1, 0))

				local ping, fps = tonumber(server.ping), tonumber(server.fps)
				local stats = {}
				if ping then table.insert(stats, math.floor(ping + 0.5) .. " ms ping") end
				if fps then table.insert(stats, math.floor(fps + 0.5) .. " fps") end
				local dot = Instance.new("Frame")
				dot.AnchorPoint = Vector2.new(0, 0.5)
				dot.Position = UDim2.fromOffset(104, 18)
				dot.Size = UDim2.fromOffset(7, 7)
				dot.BorderSizePixel = 0
				bindAuxiliaryUiColor(dot, "BackgroundColor3", not ping and "Muted" or (ping < 100 and "Good" or (ping < 200 and "Fair" or "Bad")))
				dot.Parent = row
				addCorner(dot, UDim.new(1, 0))
				makeLabel(row, {
					text = #stats > 0 and table.concat(stats, "  ·  ") or "No ping reported", font = Enum.Font.GothamMedium, size = 12,
					position = UDim2.fromOffset(117, 10), frameSize = UDim2.new(1, -221, 0, 16),
				})
				makeLabel(row, {
					text = (isHere and "Your server  ·  " or "Server ") .. string.sub(server.id, 1, 8), size = 10, role = isHere and "AccentText" or "Muted",
					position = UDim2.fromOffset(104, 30), frameSize = UDim2.new(1, -208, 0, 14),
				})

				local action = Instance.new("TextButton")
				action.AnchorPoint = Vector2.new(1, 0.5)
				action.Position = UDim2.new(1, -12, 0.5, 0)
				action.Size = UDim2.fromOffset(78, 30)
				action.AutoButtonColor = false
				action.BorderSizePixel = 0
				action.Font = Enum.Font.GothamBold
				action.TextSize = 12
				action.Parent = row
				addCorner(action, UDim.new(0, 8))
				if isHere then
					action.Text = "You're here"
					bindAuxiliaryUiColor(action, "BackgroundColor3", "Inset")
					bindAuxiliaryUiColor(action, "TextColor3", "AccentText")
				elseif isFull then
					action.Text = "Full"
					bindAuxiliaryUiColor(action, "BackgroundColor3", "Inset")
					bindAuxiliaryUiColor(action, "TextColor3", "Muted")
				else
					action.Text = "Join"
					bindAuxiliaryUiColor(action, "BackgroundColor3", "Accent")
					bindAuxiliaryUiColor(action, "TextColor3", "OnAccent")
					action.Activated:Connect(function() join(server.id) end)
				end
				row.MouseEnter:Connect(function() rowStroke.Color = auxiliaryUiTheme.Accent end)
				row.MouseLeave:Connect(function() rowStroke.Color = auxiliaryUiTheme.Stroke end)
			end

			-- What's loaded, and how it's shown. Most and Fewest players come sorted from Roblox;
			-- Best ping sorts whatever is loaded.
			local servers, nextCursor, fetchedOrder = {}, nil, nil
			local sortMode, hideFull, loading, loadSerial = "Most players", false, false, 0

			local sortChips = {}
			for index, mode in ipairs({ "Most players", "Fewest players", "Best ping" }) do
				sortChips[mode] = makePill(controls, mode, index)
			end
			local hideFullChip = makePill(controls, "Hide full", 10)
			local function paintChips()
				local theme = auxiliaryUiTheme
				for mode, chip in pairs(sortChips) do
					local selected = mode == sortMode
					chip.BackgroundColor3 = selected and theme.Accent or theme.Inset
					chip.TextColor3 = selected and theme.OnAccent or theme.SubText
				end
				hideFullChip.BackgroundColor3 = hideFull and theme.Accent or theme.Inset
				hideFullChip.TextColor3 = hideFull and theme.OnAccent or theme.SubText
				refresh.BackgroundColor3 = theme.Inset
				refresh.TextColor3 = loading and theme.Muted or theme.Text
			end
			table.insert(auxiliaryUiThemeListeners, paintChips)

			-- Rows are rebuilt on every load, so their old theme bindings are cleared out as they go.
			local function pruneDeadThemeBindings()
				for index = #auxiliaryUiColorBindings, 1, -1 do
					if not auxiliaryUiColorBindings[index][1].Parent then
						table.remove(auxiliaryUiColorBindings, index)
					end
				end
			end
			local function render()
				for _, child in ipairs(list:GetChildren()) do
					if child:IsA("GuiObject") then child:Destroy() end
				end
				pruneDeadThemeBindings()
				local shown = {}
				for _, server in ipairs(servers) do
					local full = (tonumber(server.playing) or 0) >= (tonumber(server.maxPlayers) or math.huge)
					if not (hideFull and full and server.id ~= game.JobId) then
						table.insert(shown, server)
					end
				end
				if sortMode == "Best ping" then
					table.sort(shown, function(left, right)
						return (tonumber(left.ping) or math.huge) < (tonumber(right.ping) or math.huge)
					end)
				end
				for index, server in ipairs(shown) do
					makeServerRow(server, index)
				end
				local totalPlayers = 0
				for _, server in ipairs(servers) do
					totalPlayers += tonumber(server.playing) or 0
				end
				summary.Text = commas(#servers) .. (#servers == 1 and " server" or " servers") .. "  ·  "
					.. commas(totalPlayers) .. " players" .. (nextCursor and "  ·  more to load" or "")
				statusCard.Visible = #shown == 0
				if #shown == 0 then
					statusText.Text = #servers == 0 and "No public servers are running right now."
						or "Every server loaded so far is full. Turn off Hide full, or load more."
				end
				loadMore.Visible = nextCursor ~= nil
			end

			local function friendlyError(problem)
				problem = tostring(problem or "")
				if problem:find("429") or problem:lower():find("too many") then
					return "Roblox is limiting how often the server list can load. Wait a few seconds, then press Refresh."
				end
				return "Couldn't load the server list. Your executor may not allow web requests to Roblox. (" .. problem .. ")"
			end
			-- One page (up to 100 servers) from Roblox's list, after the given cursor.
			local function requestPage(order, cursor)
				local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100&sortOrder=" .. order
				if cursor then
					url ..= "&cursor=" .. HttpService:UrlEncode(cursor)
				end
				local fetched, body = pcall(function() return game:HttpGet(url) end)
				if not fetched then return nil, body end
				local decoded, data = pcall(function() return HttpService:JSONDecode(body) end)
				if not decoded or type(data) ~= "table" then return nil, "Roblox sent back something unreadable." end
				if type(data.errors) == "table" and data.errors[1] then
					return nil, tostring(data.errors[1].message or "Roblox refused the request.")
				end
				return data
			end
			-- Loads the list from the start, or (append) the next page onto what's there.
			local function load(append)
				if loading or (append and not nextCursor) then return end
				loading = true
				loadSerial += 1
				local serial = loadSerial
				local order = append and fetchedOrder or (sortMode == "Fewest players" and "Asc" or "Desc")
				refresh.Text = "Loading..."
				loadMore.Text = append and "Loading..." or "Load more servers"
				if not append then summary.Text = "Loading this game's servers..." end
				paintChips()
				task.spawn(function()
					local data, problem = requestPage(order, append and nextCursor or nil)
					if serial ~= loadSerial or not root.Parent then return end
					loading = false
					refresh.Text = "Refresh"
					loadMore.Text = "Load more servers"
					paintChips()
					if not data then
						if append then
							notify("Servers", friendlyError(problem), 6)
						else
							servers, nextCursor = {}, nil
							render()
							statusCard.Visible = true
							statusText.Text = friendlyError(problem)
							summary.Text = "The server list didn't load."
						end
						return
					end
					if not append then
						servers = {}
						fetchedOrder = order
					end
					for _, server in ipairs(type(data.data) == "table" and data.data or {}) do
						if type(server) == "table" and type(server.id) == "string" then
							table.insert(servers, server)
						end
					end
					nextCursor = type(data.nextPageCursor) == "string" and data.nextPageCursor ~= "" and data.nextPageCursor or nil
					render()
				end)
			end

			refresh.Activated:Connect(function() load(false) end)
			loadMore.Activated:Connect(function() load(true) end)
			for mode, chip in pairs(sortChips) do
				chip.Activated:Connect(function()
					if mode == sortMode then return end
					sortMode = mode
					paintChips()
					-- Players sorts come from Roblox, so a different one means loading again.
					local wanted = mode == "Fewest players" and "Asc" or (mode == "Most players" and "Desc" or nil)
					if wanted and wanted ~= fetchedOrder then
						load(false)
					else
						render()
					end
				end)
			end
			hideFullChip.Activated:Connect(function()
				hideFull = not hideFull
				paintChips()
				render()
			end)
			paintChips()

			-- Loads by itself the first time the tab is opened (Refresh does it otherwise).
			local loadedOnce = false
			local function loadOnFirstView()
				if loadedOnce or not page.Visible then return end
				loadedOnce = true
				load(false)
			end
			page:GetPropertyChangedSignal("Visible"):Connect(loadOnFirstView)
			refresh.Activated:Connect(function() loadedOnce = true end)
		end
		-- Kept separate so a problem on the Servers page can't stop the rest of the menu loading.
		local serversOk, serversError = pcall(buildServerBrowser)
		if not serversOk then
			warn("[SpreadCheeksGUI] The Servers page couldn't be built: " .. tostring(serversError))
		end

		window:CreateSection({ name = "ADMIN COMMANDS" })
		for _, category in ipairs(categories) do
			local categoryCommands = commandsByCategory[category.name]
			if #categoryCommands > 0 then
				local tab = withIcon(window, "CreateTab", { name = category.name }, category.icon)
				withIcon(tab, "CreateSection", { name = category.section }, category.icon)
				tab:CreateText({
					text = "Tap a command to run it. Use Command Bar when you need to add arguments.",
				})
				for _, command in ipairs(categoryCommands) do
					local commandName = command.NAME
					withIcon(tab, "CreateButton", {
						name = commandName,
						callback = function()
							execCmd(commandName, Players.LocalPlayer, true)
						end,
					}, menuIcons.forCommand(commandName, category.icon))
				end
			end
		end

		-- Home: a dashboard of this session, drawn with our own cards inside the tab's page and
		-- refreshed twice a second for as long as the menu exists.
		local function buildHomePage()
			local page = homeTab and homeTab.tabPage
			if typeof(page) ~= "Instance" then
				warn("[SpreadCheeksGUI] Couldn't build the Home page; Rayfield's tab layout may have changed.")
				return
			end
			local localPlayer = Players.LocalPlayer
			local gap = 8

			local function addCorner(object, radius)
				local corner = Instance.new("UICorner")
				corner.CornerRadius = radius or UDim.new(0, 12)
				corner.Parent = object
			end
			-- A card in the menu's row colours; pass "TextButton" for a card that can be clicked.
			local function makeCard(parent, className)
				local card = Instance.new(className or "Frame")
				card.BorderSizePixel = 0
				bindAuxiliaryUiColor(card, "BackgroundColor3", "Card")
				addCorner(card)
				local stroke = Instance.new("UIStroke")
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				stroke.Transparency = 0.3
				bindAuxiliaryUiColor(stroke, "Color", "Stroke")
				stroke.Parent = card
				card.Parent = parent
				return card, stroke
			end
			local function makeLabel(parent, options)
				local label = Instance.new("TextLabel")
				label.BackgroundTransparency = 1
				label.Font = options.font or Enum.Font.Gotham
				label.TextSize = options.size or 12
				label.Text = options.text or ""
				label.TextXAlignment = options.alignX or Enum.TextXAlignment.Left
				label.TextTruncate = Enum.TextTruncate.AtEnd
				label.Position = options.position or UDim2.new()
				label.Size = options.frameSize or UDim2.new(1, 0, 0, (options.size or 12) + 4)
				bindAuxiliaryUiColor(label, "TextColor3", options.role or "Text")
				label.Parent = parent
				return label
			end
			local function makeIcon(parent, size, role, ...)
				local icon = menuIcons.get(...)
				local image = Instance.new("ImageLabel")
				image.BackgroundTransparency = 1
				image.Size = UDim2.fromOffset(size, size)
				image.Visible = icon ~= nil
				if icon then menuIcons.apply(image, icon) end
				bindAuxiliaryUiColor(image, "ImageColor3", role)
				image.Parent = parent
				return image
			end
			-- Lays its items out left to right, wrapping onto another line when the card is narrow.
			local function makeFlowRow(parent, position, widthOffset)
				local row = Instance.new("Frame")
				row.BackgroundTransparency = 1
				row.Position = position
				row.Size = UDim2.new(1, widthOffset, 0, 0)
				row.AutomaticSize = Enum.AutomaticSize.Y
				row.Parent = parent
				local layout = Instance.new("UIListLayout")
				layout.FillDirection = Enum.FillDirection.Horizontal
				layout.Padding = UDim.new(0, 6)
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				pcall(function() layout.Wraps = true end)
				layout.Parent = row
				return row
			end
			-- A small pill with an icon and a value, such as the player count or ping.
			local function makeChip(parent, order, iconRole, ...)
				local chip = Instance.new("Frame")
				chip.LayoutOrder = order
				chip.AutomaticSize = Enum.AutomaticSize.X
				chip.Size = UDim2.fromOffset(0, 24)
				chip.BorderSizePixel = 0
				bindAuxiliaryUiColor(chip, "BackgroundColor3", "Inset")
				addCorner(chip, UDim.new(1, 0))
				local padding = Instance.new("UIPadding")
				padding.PaddingLeft = UDim.new(0, 9)
				padding.PaddingRight = UDim.new(0, 10)
				padding.Parent = chip
				local layout = Instance.new("UIListLayout")
				layout.FillDirection = Enum.FillDirection.Horizontal
				layout.VerticalAlignment = Enum.VerticalAlignment.Center
				layout.Padding = UDim.new(0, 6)
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.Parent = chip
				local icon = makeIcon(chip, 12, iconRole, ...)
				icon.LayoutOrder = 1
				local label = Instance.new("TextLabel")
				label.LayoutOrder = 2
				label.AutomaticSize = Enum.AutomaticSize.X
				label.Size = UDim2.fromOffset(0, 24)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 12
				label.Text = "--"
				bindAuxiliaryUiColor(label, "TextColor3", "Text")
				label.Parent = chip
				chip.Parent = parent
				return label, icon
			end

			local root = Instance.new("Frame")
			root.Name = "HomeDashboard"
			root.LayoutOrder = 1
			root.Size = UDim2.new(1, -20, 0, 0)
			root.AutomaticSize = Enum.AutomaticSize.Y
			root.BackgroundTransparency = 1
			root.Parent = page
			local rootLayout = Instance.new("UIListLayout")
			rootLayout.Padding = UDim.new(0, gap)
			rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rootLayout.Parent = root

			-- Top: the welcome and server cards on the left, performance down the right.
			local topHeight, welcomeHeight, leftShare = 238, 100, 0.62
			local topRow = Instance.new("Frame")
			topRow.LayoutOrder = 1
			topRow.Size = UDim2.new(1, 0, 0, topHeight)
			topRow.BackgroundTransparency = 1
			topRow.Parent = root

			local welcome = makeCard(topRow)
			welcome.Size = UDim2.new(leftShare, -gap / 2, 0, welcomeHeight)
			local avatar = Instance.new("ImageLabel")
			avatar.AnchorPoint = Vector2.new(0, 0.5)
			avatar.Position = UDim2.new(0, 16, 0.5, 0)
			avatar.Size = UDim2.fromOffset(58, 58)
			avatar.BorderSizePixel = 0
			avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. localPlayer.UserId .. "&w=150&h=150"
			bindAuxiliaryUiColor(avatar, "BackgroundColor3", "Inset")
			addCorner(avatar, UDim.new(1, 0))
			local avatarRing = Instance.new("UIStroke")
			avatarRing.Thickness = 2
			avatarRing.Transparency = 0.25
			bindAuxiliaryUiColor(avatarRing, "Color", "Accent")
			avatarRing.Parent = avatar
			avatar.Parent = welcome
			local textX = 88
			makeLabel(welcome, {
				text = "WELCOME BACK", font = Enum.Font.GothamBold, size = 10, role = "Muted",
				position = UDim2.fromOffset(textX, 24), frameSize = UDim2.new(1, -textX - 14, 0, 14),
			})
			makeLabel(welcome, {
				text = localPlayer.DisplayName, font = Enum.Font.GothamBold, size = 17,
				position = UDim2.fromOffset(textX, 39), frameSize = UDim2.new(1, -textX - 14, 0, 22),
			})
			local welcomeDetail = makeLabel(welcome, {
				text = "@" .. localPlayer.Name, size = 11, role = "SubText",
				position = UDim2.fromOffset(textX, 62), frameSize = UDim2.new(1, -textX - 14, 0, 15),
			})

			local server = makeCard(topRow)
			server.Position = UDim2.fromOffset(0, welcomeHeight + gap)
			server.Size = UDim2.new(leftShare, -gap / 2, 0, topHeight - welcomeHeight - gap)
			local gameIcon = Instance.new("ImageLabel")
			gameIcon.Position = UDim2.fromOffset(14, 14)
			gameIcon.Size = UDim2.fromOffset(44, 44)
			gameIcon.BorderSizePixel = 0
			gameIcon.Image = game.GameId ~= 0 and ("rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150") or ""
			bindAuxiliaryUiColor(gameIcon, "BackgroundColor3", "Inset")
			addCorner(gameIcon, UDim.new(0, 10))
			gameIcon.Parent = server
			local gameName = makeLabel(server, {
				text = "Loading game...", font = Enum.Font.GothamBold, size = 14,
				position = UDim2.fromOffset(70, 16), frameSize = UDim2.new(1, -84, 0, 18),
			})
			local serverDetail = makeLabel(server, {
				size = 11, role = "SubText",
				position = UDim2.fromOffset(70, 37), frameSize = UDim2.new(1, -84, 0, 15),
			})
			local serverChips = makeFlowRow(server, UDim2.fromOffset(14, 70), -28)
			local playersText = makeChip(serverChips, 1, "SubText", "users")
			local pingText, pingIcon = makeChip(serverChips, 2, "SubText", "wifi")
			local sessionText = makeChip(serverChips, 3, "SubText", "timer", "clock")
			local jobText = makeChip(serverChips, 4, "SubText", "fingerprint")
			-- The game's name takes a web request, so it fills in when that comes back.
			task.spawn(function()
				local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
				if gameName.Parent then
					gameName.Text = ok and type(info) == "table" and tostring(info.Name or "") ~= "" and info.Name or ("Place " .. game.PlaceId)
				end
			end)

			local performance = makeCard(topRow)
			performance.Position = UDim2.new(leftShare, gap / 2, 0, 0)
			performance.Size = UDim2.new(1 - leftShare, -gap / 2, 1, 0)
			makeLabel(performance, {
				text = "PERFORMANCE", font = Enum.Font.GothamBold, size = 10, role = "Muted",
				alignX = Enum.TextXAlignment.Center, position = UDim2.fromOffset(0, 14), frameSize = UDim2.new(1, 0, 0, 14),
			})
			-- The FPS ring is two half rings. Each shows only part of itself through a hard-edged
			-- gradient that turns with the value: the right half covers 0 to 180 degrees
			-- (clockwise from the top) and the left half 180 to 360.
			local ringSize, ringThickness = 112, 8
			local ring = Instance.new("Frame")
			ring.AnchorPoint = Vector2.new(0.5, 0)
			ring.Position = UDim2.new(0.5, 0, 0, 36)
			ring.Size = UDim2.fromOffset(ringSize, ringSize)
			ring.BackgroundTransparency = 1
			ring.Parent = performance
			-- Strokes are drawn outside their frame, so each circle is inset by the stroke's width.
			local function makeRingStroke(parent, offsetX, role)
				local circle = Instance.new("Frame")
				circle.Position = UDim2.fromOffset(offsetX + ringThickness, ringThickness)
				circle.Size = UDim2.fromOffset(ringSize - ringThickness * 2, ringSize - ringThickness * 2)
				circle.BackgroundTransparency = 1
				addCorner(circle, UDim.new(1, 0))
				local stroke = Instance.new("UIStroke")
				stroke.Thickness = ringThickness
				bindAuxiliaryUiColor(stroke, "Color", role)
				stroke.Parent = circle
				circle.Parent = parent
				return stroke
			end
			makeRingStroke(ring, 0, "Inset")
			local function makeRingHalf(xScale)
				local half = Instance.new("Frame")
				half.Position = UDim2.fromScale(xScale, 0)
				half.Size = UDim2.fromScale(0.5, 1)
				half.BackgroundTransparency = 1
				half.ClipsDescendants = true
				half.Parent = ring
				local stroke = makeRingStroke(half, -xScale * ringSize, "Accent")
				local gradient = Instance.new("UIGradient")
				gradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(0.501, 1),
					NumberSequenceKeypoint.new(1, 1),
				})
				gradient.Parent = stroke
				return gradient
			end
			local rightGradient = makeRingHalf(0.5)
			local leftGradient = makeRingHalf(0)
			local ringAngle = Instance.new("NumberValue")
			local function showRingAngle(angle)
				rightGradient.Rotation = math.clamp(angle, 0, 180)
				leftGradient.Rotation = math.clamp(angle, 180, 360)
			end
			ringAngle.Changed:Connect(showRingAngle)
			showRingAngle(0)
			local fpsText = makeLabel(ring, {
				text = "--", font = Enum.Font.GothamBold, size = 24, alignX = Enum.TextXAlignment.Center,
				position = UDim2.new(0, 0, 0.5, -17), frameSize = UDim2.new(1, 0, 0, 26),
			})
			makeLabel(ring, {
				text = "frames per second", size = 9, role = "SubText", alignX = Enum.TextXAlignment.Center,
				position = UDim2.new(0, 0, 0.5, 9), frameSize = UDim2.new(1, 0, 0, 12),
			})
			local function makeStatLine(y, ...)
				local line = Instance.new("Frame")
				line.AnchorPoint = Vector2.new(0.5, 0)
				line.Position = UDim2.new(0.5, 0, 0, y)
				line.AutomaticSize = Enum.AutomaticSize.X
				line.Size = UDim2.fromOffset(0, 18)
				line.BackgroundTransparency = 1
				line.Parent = performance
				local layout = Instance.new("UIListLayout")
				layout.FillDirection = Enum.FillDirection.Horizontal
				layout.VerticalAlignment = Enum.VerticalAlignment.Center
				layout.Padding = UDim.new(0, 6)
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.Parent = line
				local icon = makeIcon(line, 13, "SubText", ...)
				icon.LayoutOrder = 1
				local label = Instance.new("TextLabel")
				label.LayoutOrder = 2
				label.AutomaticSize = Enum.AutomaticSize.X
				label.Size = UDim2.fromOffset(0, 18)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 12
				label.Text = "--"
				bindAuxiliaryUiColor(label, "TextColor3", "Text")
				label.Parent = line
				return label, icon
			end
			local perfPingText, perfPingIcon = makeStatLine(164, "wifi")
			local memoryText = makeStatLine(188, "memory-stick", "cpu", "hard-drive")

			-- What's switched on right now, from the Controls tab (and Locate on the Players tab).
			local active = makeCard(root)
			active.LayoutOrder = 2
			active.Size = UDim2.fromScale(1, 0)
			active.AutomaticSize = Enum.AutomaticSize.Y
			local activePadding = Instance.new("UIPadding")
			activePadding.PaddingTop = UDim.new(0, 12)
			activePadding.PaddingBottom = UDim.new(0, 12)
			activePadding.PaddingLeft = UDim.new(0, 14)
			activePadding.PaddingRight = UDim.new(0, 14)
			activePadding.Parent = active
			local activeIcon = makeIcon(active, 13, "AccentText", "zap")
			activeIcon.Position = UDim2.fromOffset(0, 1)
			makeLabel(active, {
				text = "ACTIVE NOW", font = Enum.Font.GothamBold, size = 10, role = "Muted",
				position = UDim2.fromOffset(19, 0), frameSize = UDim2.new(0.5, -19, 0, 15),
			})
			local activeSummary = makeLabel(active, {
				size = 11, role = "SubText", alignX = Enum.TextXAlignment.Right,
				position = UDim2.fromScale(0.5, 0), frameSize = UDim2.new(0.5, 0, 0, 15),
			})
			local activeChips = makeFlowRow(active, UDim2.fromOffset(0, 25), 0)
			local emptyText = makeLabel(active, {
				text = "Nothing's switched on. Turn features on in Quick Controls.", size = 12, role = "SubText",
				position = UDim2.fromOffset(0, 25), frameSize = UDim2.new(1, 0, 0, 24),
			})

			-- Quick actions.
			local tiles = Instance.new("Frame")
			tiles.LayoutOrder = 3
			tiles.Size = UDim2.fromScale(1, 0)
			tiles.AutomaticSize = Enum.AutomaticSize.Y
			tiles.BackgroundTransparency = 1
			tiles.Parent = root
			local tileLayout = Instance.new("UIGridLayout")
			tileLayout.CellSize = UDim2.new(1 / 3, -gap * 2 / 3, 0, 72)
			tileLayout.CellPadding = UDim2.fromOffset(gap, gap)
			tileLayout.SortOrder = Enum.SortOrder.LayoutOrder
			tileLayout.Parent = tiles
			local tileCards = {}
			local function addTile(order, title, subtitle, action, ...)
				local tile, stroke = makeCard(tiles, "TextButton")
				tile.LayoutOrder = order
				tile.AutoButtonColor = false
				tile.Text = ""
				local icon = makeIcon(tile, 18, "AccentText", ...)
				icon.Position = UDim2.fromOffset(14, 13)
				makeLabel(tile, {
					text = title, font = Enum.Font.GothamSemibold, size = 13,
					position = UDim2.fromOffset(14, 37), frameSize = UDim2.new(1, -20, 0, 16),
				})
				makeLabel(tile, {
					text = subtitle, size = 11, role = "SubText",
					position = UDim2.fromOffset(14, 53), frameSize = UDim2.new(1, -20, 0, 14),
				})
				tile.MouseEnter:Connect(function() stroke.Color = auxiliaryUiTheme.Accent end)
				tile.MouseLeave:Connect(function() stroke.Color = auxiliaryUiTheme.Stroke end)
				tile.Activated:Connect(action)
				table.insert(tileCards, tile)
			end
			addTile(1, "Rejoin", "same server", function() execCmd("rejoin", localPlayer, true) end, "refresh-cw")
			addTile(2, "Server Hop", "find a fresh one", function() execCmd("serverhop", localPlayer, true) end, "arrow-left-right", "shuffle", "server")
			addTile(3, "Copy Join Link", "share this server", function() execCmd("jobid", localPlayer, true) end, "link", "copy")
			addTile(4, "Respawn", "fresh character", function() execCmd("respawn", localPlayer, true) end, "heart-pulse", "heart", "user-round")
			addTile(5, "Refresh", "respawn where you stand", function() execCmd("refresh", localPlayer, true) end, "rotate-ccw")
			addTile(6, "Command Bar", "or press ;", function()
				if quickCommandBar.open then quickCommandBar.open() end
			end, "square-terminal", "terminal-square")

			-- Fading. Rayfield fades its own rows in and out with the window, but these cards are
			-- ours, so they follow the window themselves. Each part's resting transparency is
			-- recorded the first time it's seen, so a fade always returns it to the right value.
			local resting = setmetatable({}, { __mode = "k" })
			local fadeProperties = {
				{ "GuiObject", "BackgroundTransparency" },
				{ "TextLabel", "TextTransparency" },
				{ "TextButton", "TextTransparency" },
				{ "ImageLabel", "ImageTransparency" },
				{ "UIStroke", "Transparency" },
			}
			local function partsOf(card)
				local parts = {}
				local function visit(object)
					local record = resting[object]
					if not record then
						record = {}
						for _, entry in ipairs(fadeProperties) do
							if object:IsA(entry[1]) then
								record[entry[2]] = object[entry[2]]
							end
						end
						resting[object] = record
					end
					for property, value in pairs(record) do
						if value < 1 then
							table.insert(parts, { object, property, value })
						end
					end
				end
				visit(card)
				for _, descendant in ipairs(card:GetDescendants()) do
					visit(descendant)
				end
				return parts
			end
			-- Top to bottom, then the tiles one by one, the way Rayfield reveals a page.
			local revealOrder = { welcome, performance, server, active }
			for _, tile in ipairs(tileCards) do
				table.insert(revealOrder, tile)
			end
			local dashboardShown = false
			local fadeSerial = 0
			local function hideNow(card)
				for _, part in ipairs(partsOf(card)) do
					part[1][part[2]] = 1
				end
			end
			local function fadeDashboard(shown, firstTime)
				fadeSerial += 1
				local serial = fadeSerial
				dashboardShown = shown
				if not shown then
					local info = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
					for _, card in ipairs(revealOrder) do
						for _, part in ipairs(partsOf(card)) do
							TweenService:Create(part[1], info, { [part[2]] = 1 }):Play()
						end
					end
					return
				end
				local info = TweenInfo.new(firstTime and 0.5 or 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				for _, card in ipairs(revealOrder) do
					-- A newer fade (the window closing again) takes over.
					if serial ~= fadeSerial then return end
					for _, part in ipairs(partsOf(card)) do
						TweenService:Create(part[1], info, { [part[2]] = part[3] }):Play()
					end
					task.wait(0.04)
				end
			end

			-- Live numbers.
			local executorName = nil
			pcall(function()
				if type(identifyexecutor) == "function" then
					executorName = tostring((identifyexecutor()))
				end
			end)
			local function formatDuration(seconds)
				seconds = math.max(0, math.floor(seconds))
				if seconds < 60 then return seconds .. "s" end
				local minutes = math.floor(seconds / 60)
				if minutes < 60 then return minutes .. "m" end
				return math.floor(minutes / 60) .. "h " .. minutes % 60 .. "m"
			end
			-- Round trip to the server in milliseconds, from the player, or else from Stats.
			local function readPing()
				local ok, ping = pcall(function() return localPlayer:GetNetworkPing() * 1000 end)
				if ok and type(ping) == "number" and ping > 0 then return ping end
				local statOk, statPing = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
				return statOk and tonumber(statPing) or 0
			end
			local function pingColor(ping)
				if ping < 100 then return auxiliaryUiTheme.Good end
				if ping < 200 then return auxiliaryUiTheme.Fair end
				return auxiliaryUiTheme.Bad
			end
			local jobId = tostring(game.JobId)
			jobText.Text = #jobId > 10 and (jobId:sub(1, 4) .. "..." .. jobId:sub(-4)) or (jobId ~= "" and jobId or "No job id")

			local activeSignature = nil
			local function refreshActive()
				local items = {}
				for _, entry in ipairs(quickToggles) do
					if entry.state then
						table.insert(items, { text = entry.name, icons = entry.icons })
					end
				end
				if locatedPlayerName then
					table.insert(items, { text = "Locating " .. locatedPlayerName, icons = { "locate" } })
				end
				if aimbot and aimbot.isEnabled() then
					table.insert(items, { text = "Aimbot", icons = { "crosshair" } })
				end
				local names = {}
				for _, item in ipairs(items) do
					table.insert(names, item.text)
				end
				-- Only rebuilt when something actually changed.
				local signature = table.concat(names, "\n")
				if signature == activeSignature then return end
				activeSignature = signature
				for _, child in ipairs(activeChips:GetChildren()) do
					if child:IsA("GuiObject") then child:Destroy() end
				end
				for index, item in ipairs(items) do
					local label = makeChip(activeChips, index, "AccentText", table.unpack(item.icons or {}))
					label.Text = item.text
				end
				emptyText.Visible = #items == 0
				-- New chips made while the dashboard is hidden wait to fade in with their card.
				if not dashboardShown then
					hideNow(activeChips)
				end
			end

			local frames, lastSample = 0, os.clock()
			local frameCounter = RunService.RenderStepped:Connect(function()
				frames += 1
			end)
			local ringTween = nil
			local ringTarget = 0
			local revealedOnce = false
			local function moveRing(info)
				if ringTween then ringTween:Cancel() end
				ringTween = TweenService:Create(ringAngle, info, { Value = ringTarget })
				ringTween:Play()
			end
			local function update()
				local now = os.clock()
				local fps = frames / math.max(now - lastSample, 0.001)
				frames, lastSample = 0, now
				fpsText.Text = tostring(math.floor(fps + 0.5))
				-- A 60 FPS cap fills the ring; unlocked frame rates are measured against 240.
				local ringMax = fps <= 62 and 60 or 240
				ringTarget = math.clamp(fps / ringMax, 0, 1) * 360
				-- The ring stays empty until the dashboard is first revealed, then sweeps up.
				if revealedOnce then
					moveRing(TweenInfo.new(0.4, Enum.EasingStyle.Quad))
				end

				local ping = math.floor(readPing() + 0.5)
				pingText.Text = ping .. " ms"
				perfPingText.Text = ping .. " ms"
				pingIcon.ImageColor3 = pingColor(ping)
				perfPingIcon.ImageColor3 = pingColor(ping)
				local memoryOk, memory = pcall(function() return StatsService:GetTotalMemoryUsageMb() end)
				if memoryOk and type(memory) == "number" then
					memoryText.Text = memory >= 1024 and string.format("%.1f GB", memory / 1024) or (math.floor(memory + 0.5) .. " MB")
				end

				local session = formatDuration(time())
				playersText.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
				sessionText.Text = session
				local details = { "@" .. localPlayer.Name }
				if executorName then table.insert(details, executorName) end
				table.insert(details, session .. " on this server")
				welcomeDetail.Text = table.concat(details, "  ·  ")
				serverDetail.Text = "Server up " .. formatDuration(workspace.DistributedGameTime) .. "  ·  " .. #cmds .. " commands"

				local keybinds = 0
				for _, entry in ipairs(quickToggles) do
					if entry.key then keybinds += 1 end
				end
				activeSummary.Text = keybinds == 1 and "1 keybind set" or (keybinds .. " keybinds set")
				refreshActive()
			end
			refreshActive()
			-- Everything starts hidden until the window opens.
			for _, card in ipairs(revealOrder) do
				hideNow(card)
			end
			local function reveal()
				local firstTime = not revealedOnce
				revealedOnce = true
				pcall(update)
				if firstTime then
					moveRing(TweenInfo.new(1.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out))
				end
				fadeDashboard(true, firstTime)
			end
			-- Follow the window: hidden while it's closed or minimised, faded in when it opens.
			-- The first time, Rayfield spends about 1.5s growing the window and fading its own
			-- parts in before it reveals the page, so the dashboard waits for that too.
			local pendingReveal = nil
			local watcher
			watcher = RunService.Heartbeat:Connect(function()
				if not root.Parent then
					watcher:Disconnect()
					return
				end
				local main = window.main
				local open = (typeof(main) ~= "Instance" or main.Visible) and not window.hidden and not window.minimised
				if open and not dashboardShown and not pendingReveal then
					local revealIn = revealedOnce and 0.25 or math.max(0.25, (windowOpenedAt or os.clock()) + 1.45 - os.clock())
					pendingReveal = task.delay(revealIn, function()
						pendingReveal = nil
						reveal()
					end)
				elseif not open then
					if pendingReveal then
						task.cancel(pendingReveal)
						pendingReveal = nil
					end
					if dashboardShown then
						fadeDashboard(false)
					end
				end
			end)
			task.spawn(function()
				while root.Parent do
					task.wait(0.5)
					if not root.Parent then break end
					local ok, problem = pcall(update)
					if not ok then
						warn("[SpreadCheeksGUI] The Home page stopped updating: " .. tostring(problem))
						break
					end
				end
				frameCounter:Disconnect()
			end)
		end

		-- Kept separate so a problem on the Home page can't stop the rest of the menu loading.
		local homeOk, homeError = pcall(buildHomePage)
		if not homeOk then
			warn("[SpreadCheeksGUI] The Home page couldn't be built: " .. tostring(homeError))
		end
	end)

	if not rayfieldOk then
		warn("[Infinite Yield] Rayfield setup failed: " .. tostring(rayfieldError))
		if Holder then Holder.Visible = true end
	end
else
	warn("[Infinite Yield] Rayfield could not be loaded: " .. tostring(Rayfield))
	if Holder then Holder.Visible = true end
end

if table.find({Enum.Platform.IOS, Enum.Platform.Android}, UserInputService:GetPlatform()) then
	notify("Unstable Device", "On mobile, Infinite Yield may have issues or features that are not functioning correctly.")
end
