local Players = game:GetService("Players");

local ToggleMon = {}

function ToggleMon:initialize(player, remotes, components, localSettings, button)
	
	self.player = player;
	self.remotes = remotes;
	self.components = components;
	self.localSettings = localSettings;
	self.button = button;
	
end

function ToggleMon:useEffect(button)
	
	if self.localSettings.toggleUsername.Value then
		self:hideMon()
	else
		self:showMon();
	end
end

function ToggleMon:onSpawn()
	if self.localSettings.toggleUsername.Value then
		self:showMon();
	else
		self:hideMon();
	end
end

function ToggleMon:hideMon()
	self.button.Frame.TextLabel.Text = "Show Mon";
	self.button.ImageColor3 = Color3.fromRGB(255, 255, 255);
	self.localSettings.toggleUsername.Value = false;
	self.remotes.ToggleMon:FireServer();
end

function ToggleMon:showMon()
	self.localSettings.toggleUsername.Value = true;
	self.button.Frame.TextLabel.Text = "Hide Mon";
	self.button.ImageColor3 = Color3.fromRGB(50, 50, 50);
	self.remotes.ToggleMon:FireServer();
end

return ToggleMon
