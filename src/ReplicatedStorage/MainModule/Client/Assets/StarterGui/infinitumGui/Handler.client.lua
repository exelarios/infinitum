local Gui = script.Parent;

local Players = game:GetService("Players");
local Lighting = game:GetService("Lighting");
local StarterGui = game:GetService("StarterGui");
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");
local GroupService = game:GetService("GroupService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local remotes = ReplicatedStorage:WaitForChild("wo2B0IHpQcJTk6RQ1vwSHycQ");

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local localSettings = LocalPlayer:WaitForChild("Settings");
local Humanoid = Character:WaitForChild("Humanoid");

local components = Gui.Components;
local header = Gui.Menu.Header;
local topbar = Gui.Topbar;
topbar.Size = UDim2.new(1, 0, 0, -36);

local topbarLeft = topbar.Left;
local regionLabel = topbarLeft.TextLabel;
regionLabel.Text = remotes.GetRegion:InvokeServer();

local config = ReplicatedStorage:WaitForChild("IHpQcJ");
local TweeningInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);

_G.isMenuOpen = false;

local function toggleMenu()
	
	local function HideAllFrame()
		for _, instance in pairs(components:GetChildren()) do
			if instance:IsA("Frame") then
				instance.Visible = false;
			end
		end
	end
	
	if _G.isMenuOpen then
		_G.isMenuOpen = false;
		Gui.Menu.Visible = false;
		HideAllFrame();
		local BlurTweening = TweenService:Create(Lighting["Blur"], TweeningInfo, {Size = 0});
		BlurTweening:Play();
	else
		Gui.Menu.Visible = true;
		_G.isMenuOpen = true;
		local BlurTweening = TweenService:Create(Lighting["Blur"], TweeningInfo, {Size = 24});
		BlurTweening:Play();
	end
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	
	if gameProcessed then
		return;
	end

	if input.KeyCode == Enum.KeyCode.M then
		toggleMenu();
	end
	
end)

local settingBtn = topbar.SettingBtn.IconButton;
settingBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then	
		toggleMenu();
	end
end)

local function getButtonFromModule(findFrame)
	for _, instance in pairs(Gui:GetDescendants()) do
		if instance:IsA("ImageButton") then
			if instance.Name == findFrame then
				return instance;
			end
		end
	end
end

for _, component in pairs(components:GetChildren()) do
	if component:IsA("ModuleScript") then
		require(component):initialize(
			LocalPlayer, 
			remotes, 
			components, 
			localSettings, 
			getButtonFromModule(component.Name), 
			Gui.Menu, 
			config
		);		
	end
end

local function onClick(button)
	
	local function getComponent(button)
		for _, component in pairs(components:GetChildren()) do
			if component.Name == button.Name then
				return component;
			end
		end
		return nil;
	end
	
	local currentState = getComponent(button);
	
	if currentState:IsA("ModuleScript") then
		require(currentState):useEffect(button);
	end
end

for _, button in pairs(Gui.Menu:GetDescendants()) do
	if button:IsA("ImageButton") or button:IsA("TextButton") then
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then					
				onClick(button);
			end
		end)
	end
end

local fetchData = remotes.fetchPlayerData:InvokeServer(LocalPlayer);

if fetchData["primary"] then
	local groupInfo = GroupService:GetGroupInfoAsync(fetchData["primary"]);
	header.Frame.Logo.ImageFrame.Image = groupInfo.EmblemUrl;
	
	header.Frame.Title.GroupRole.Text = LocalPlayer:GetRoleInGroup(fetchData["primary"]);
end

if fetchData["firstname"] then
	header.Frame.Title.RoleplayName.Text = fetchData["firstname"];
end

if fetchData["family"] then
	header.Frame.Title.RoleplayName.Text = header.Frame.Title.RoleplayName.Text .. " " .. fetchData["family"];
end

if fetchData["firstname"] ~= LocalPlayer.Name then
	header.Frame.Title.Username.Text = LocalPlayer.Name;
end

-- Raid Client Manager
if config.Raidable.Value then
	local raidInfo = ReplicatedStorage:WaitForChild("RaidInfo");
	local scoreboard = Gui.Scoreboard;
	local timerFrame = Gui.Timer;
	local Msg = Gui.Msg;
	
	local alliesFrame = scoreboard.Allies;
	local axisFrame = scoreboard.Axis;
	
	local alliesTeam = config.Teams.Allies.Value;
	local axisTeam = config.Teams.Axis.Value;
	
	if not alliesTeam or not axisTeam then
		return;
	end
	
	local maxKills = raidInfo.MaxKills;
	
	maxKills:GetPropertyChangedSignal("Value"):Connect(function()
		maxKills = raidInfo.MaxKills;
	end)
	
	local timeValue = raidInfo.Timer;
	local alliesValue = raidInfo.Score.Allies;
	local axisValue = raidInfo.Score.Axis;
	
	timerFrame.Label.Text = timeValue.Value;
	alliesFrame["Amount"].Text = alliesValue.Value .. " / " .. maxKills.Value;
	axisFrame["Amount"].Text = axisValue.Value .. " / " .. maxKills.Value;
	
	alliesValue:GetPropertyChangedSignal("Value"):Connect(function()
		alliesFrame.Amount.Text = alliesValue.Value .. " / " .. maxKills.Value;
	end)
	
	axisValue:GetPropertyChangedSignal("Value"):Connect(function()
		axisFrame.Amount.Text = axisValue.Value .. " / " .. maxKills.Value;
	end)
	
	timeValue:GetPropertyChangedSignal("Value"):Connect(function()
		timerFrame.Label.Text = string.format("%02i:%02i", timeValue.Value / 60 % 60, timeValue.Value % 60)
	end)
	
	alliesFrame.Label.Text = string.gsub(alliesTeam.Name:gsub(" $", ""), "%p%d+%p", "");
	alliesFrame.Label.TextColor3 = (alliesTeam.TeamColor).Color;
	
	axisFrame.Label.Text = string.gsub(axisTeam.Name:gsub(" $", ""), "%p%d+%p", "");
	axisFrame.Label.TextColor3 = (axisTeam.TeamColor).Color;
	
	remotes.SystemMessage.OnClientEvent:Connect(function(message, timer)
		Msg.Label.Text = message;
		Msg.Visible = true;
		wait(timer);
		Msg.Visible = false;
	end)
end

Humanoid.Died:Connect(function()
	Gui.Menu.Visible = false;
	local BlurTweening = TweenService:Create(Lighting["Blur"], TweeningInfo, {Size = 0});
	BlurTweening:Play();
end)