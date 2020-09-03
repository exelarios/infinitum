local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;

local ToggleAllMon = {}

function ToggleAllMon:initialize(player, remotes, components, localSettings, button)
	
	self.player = player;
	self.remotes = remotes;
	self.components = components;
	self.localSettings = localSettings;
	self.button = button;
	
	self:onMount()
end

function ToggleAllMon:useEffect()
	
	if self.localSettings.toggleAllMon.Value then
		self:HideAllMon();
	else
		self:ShowAllMon();
	end

end

function ToggleAllMon:onMount()
	if self.localSettings.toggleAllMon.Value then
		self:ShowAllMon();
	else
		self:HideAllMon();
	end
end

function ToggleAllMon:ShowAllMon()
	self.localSettings.toggleAllMon.Value = true;
	self.button.Frame.TextLabel.Text = "Hide All Mon";
	self.button.ImageColor3 = Color3.fromRGB(255, 255, 255);
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name ~= LocalPlayer.Name then
			local localSettings = player:WaitForChild("Settings");
			if localSettings.toggleMon.Value then
				local character = player.Character or player.CharacterAdded:Wait();
				local head = character:WaitForChild("Head");
				local clanInfo = head:FindFirstChild("ClanInfo");
				if clanInfo then
					clanInfo.Enabled = true;
				end
			end
		end
	end
end

function ToggleAllMon:HideAllMon()
	self.button.Frame.TextLabel.Text = "Show All Mon";
	self.button.ImageColor3 = Color3.fromRGB(50, 50, 50);
	self.localSettings.toggleAllMon.Value = false;
	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character or player.CharacterAdded:Wait();
		local head = character:WaitForChild("Head");
		local clanInfo = head:FindFirstChild("ClanInfo");
		if clanInfo then
			clanInfo.Enabled = false;
		end
	end
end

return ToggleAllMon
