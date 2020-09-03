local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");
local GroupService = game:GetService("GroupService");

local ClanIdentifier = {}

function ClanIdentifier:initialize(config, remotes, server, client)
	
	self.server = server;
	self.remotes = remotes;
	self.events = server.Events;
	
	self:useEffect();
	self:useRemotes();
	print("ClanIdentifier has loaded");
end

function ClanIdentifier:useEffect()
	
	spawn(function()
		Players.PlayerAdded:Connect(function(player)
			self:generateBillboard(player);
		end)
		
		for _, player in pairs(Players:GetPlayers()) do
			self:generateBillboard(player);
		end
	end)

end

function ClanIdentifier:generateBillboard(player)
	
	local function setBillboard(character)
		
		local playerData;
		
		repeat wait(1) -- Ugly hax, but it works.
			playerData = self.events.getPlayerData:Invoke(player);
		until playerData;
		
		if playerData["primary"] then
			local groupInfo = GroupService:GetGroupInfoAsync(playerData["primary"]);
			local clanInfo = self.server.Assets.ClanInfo:Clone();
			clanInfo.Parent = character:WaitForChild("Head");
			
			local localSettings = player:WaitForChild("Settings");
			if not localSettings.toggleMon.Value then
				clanInfo.Enabled = false;
			end
			
			local frame = clanInfo.Frame;
			frame.Mon.Image = groupInfo.EmblemUrl;
			frame.Clan.Text = groupInfo.Name;
			frame.Rank.Text = player:GetRoleInGroup(playerData["primary"]);
			
			self.remotes.HideLocalClanInfo:FireClient(player);
		end
		
		if playerData["aura"] then
			local character = player.Character or player.CharacterAdded:Wait();
			local Torso = character:WaitForChild("Torso");
			local aura = self.server.Assets.Aura:Clone();
			aura.Parent = Torso;
		end
		
	end
	
	setBillboard(player.Character or player.CharacterAdded:Wait());
	player.CharacterAdded:Connect(setBillboard);

end

function ClanIdentifier:useRemotes()
	self.remotes.ToggleMon.OnServerEvent:Connect(function(player)
		
		local localSettings = player:WaitForChild("Settings");
		localSettings.toggleMon.Value = not localSettings.toggleMon.Value;
		
		local character = player.Character or player.CharacterAdded:Wait();
		local Head = character:WaitForChild("Head");
		local ClanInfos = Head:WaitForChild("ClanInfo");
		ClanInfos.Enabled = not ClanInfos.Enabled;
		
		self.remotes.HideLocalClanInfo:FireClient(player);
		
	end)
end

return ClanIdentifier
