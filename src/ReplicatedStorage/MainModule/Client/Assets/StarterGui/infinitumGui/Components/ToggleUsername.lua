local Players = game:GetService("Players");

local module = {}

function module:initialize(player, remotes, components, localSettings)
	
	self.player = player;
	self.remotes = remotes;
	self.components = components;
	self.localSettings = localSettings;
	
end

function module:useEffect(button)
	
	self.button = button;
	
	if self.localSettings.toggleUsername.Value then
		self.button.Frame.TextLabel.Text = "Show All Username";
		self.button.ImageColor3 = Color3.fromRGB(255, 255, 255);
		self.localSettings.toggleUsername.Value = false;
		for _, player in pairs(Players:GetPlayers()) do
			local fetchData = self.remotes.fetchPlayerData:InvokeServer(player);
			local character = player.Character or player.CharacterAdded:Wait();
			local Humanoid = character:WaitForChild("Humanoid");
			Humanoid.DisplayName = fetchData["firstname"];
		end
	else
		self.localSettings.toggleUsername.Value = true;
		self.button.Frame.TextLabel.Text = "Show Roleplay Name";
		self.button.ImageColor3 = Color3.fromRGB(50, 50, 50);
		for _, player in pairs(Players:GetPlayers()) do
			local character = player.Character or player.CharacterAdded:Wait();
			local Humanoid = character:WaitForChild("Humanoid");
			Humanoid.DisplayName = player.Name;
		end
	end
	
end

return module;
