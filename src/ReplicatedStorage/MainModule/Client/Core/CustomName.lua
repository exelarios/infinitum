local Players = game:GetService("Players");
local Lighting = game:GetService("Lighting");
local UserInputService = game:GetService("UserInputService");
local LocalPlayer = Players.LocalPlayer;

local Processor = {}

function Processor:initialize(remotes, localSettings)
	
	self.remotes = remotes;
	self.localSettings = localSettings;
	
	self:useEffect();
	
	self:useRemote();
	self:usePlayer();
	print("Custom Name has loaded on " .. LocalPlayer.Name);
end

function Processor:useEffect()
	
	local function onPlayerAdded(player)
		local function useEffect(character)
			
			if self.localSettings.toggleUsername.Value then
				return;
			end
			
			spawn(function()
				local Humanoid = character:WaitForChild("Humanoid");
				local fetchData = self.remotes.fetchPlayerData:InvokeServer(player);
				Humanoid.DisplayName = fetchData["firstname"];
				if fetchData["family"] then
					Humanoid.DisplayName = Humanoid.DisplayName .. " " .. fetchData["family"];
				end
				
			end)
	    end

	    useEffect(player.Character or player.CharacterAdded:Wait());
	    player.CharacterAdded:Connect(useEffect);
	end
	
	
	Players.PlayerAdded:Connect(function(player)
		onPlayerAdded(player)
	end)
	
	for _, player in pairs(Players:GetChildren()) do
		onPlayerAdded(player);
	end
	
end

function Processor:usePlayer()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
	local Humanoid = character:WaitForChild("Humanoid");
	Humanoid.Died:Connect(function()
		if self.localSettings.toggleUsername.Value then
			for _, player in pairs(Players:GetPlayers()) do
				local Humanoid = character:WaitForChild("Humanoid");
				Humanoid.DisplayName = player.Name;
			end
		end
	end)
end

function Processor:useRemote()
	self.remotes.HideLocalClanInfo.OnClientEvent:Connect(function()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
		local Head = character:WaitForChild("Head");
		local ClanInfos = Head:WaitForChild("ClanInfo");
		ClanInfos.Enabled = false;
	end)
end

return Processor
