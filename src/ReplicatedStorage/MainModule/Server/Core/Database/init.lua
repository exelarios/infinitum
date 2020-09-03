local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");

local Database = {}

function Database:initialize(config, remotes, server, client)
	self.server = server;
	self.events = server.Events;
	self.remotes = remotes;
	self.getClanList = require(server.Dependencies.GetClanList);
	self.serverUserData = {};
	
	self:useEffect();
	self:useBindable();
	self:useRemote();
	print("Database Module has been initialized.");
end

function Database:useEffect()
	Players.PlayerAdded:Connect(function(player)
		self:initializeData(player)
	end)
	
	for _, player in pairs(Players:GetPlayers()) do
		self:initializeData(player)
	end
	
	Players.PlayerRemoving:Connect(function(player)
		self.serverUserData[player] = nil;
	end)
end

function Database:initializeData(player)
	local userModel = require(script.User);
	local FirebaseService = require(self.server.Dependencies.FirebaseService);
	local userStore = FirebaseService:GetFirebase("users");
	
	local function getPlayerFirstClan(player)
		self.getClanList:init(player);
		for _, ally in ipairs(self.getClanList:getList()) do
			local allyId = ally.Id;
			if player:IsInGroup(allyId) then
				return allyId;
			end
		end
	end
	
	local userData;
	
	userData = userStore:GetAsync(tostring(player.userId));
	
	if userData then
		userData = HttpService:JSONDecode(userData);
		print(player.Name .. "'s data has successfully loaded from database.");
	else
		if player:IsInGroup(5997635) then
			userData = userModel(player.Name, 5997635);
		else
			userData = userModel(player.Name);
		end
		print(player.Name .. "'s data has successfully loaded from object.");
	end
	
	self.serverUserData[player] = userData;

	if self.serverUserData[player]["ban"] then
		player:Kick("You have been banned By Sengoku Japan.");
		return;
	end
	
	self:createSettings(player);

end

function Database:createSettings(player)
	local localSettings = self.server.Assets.Settings:Clone();
	localSettings.Parent = player;
end

function Database:useRemote()
	self.remotes.fetchPlayerData.OnServerInvoke = function(player, playerData)
		return self.serverUserData[playerData];
	end
end

function Database:useBindable()
	self.events.getPlayerData.OnInvoke = function(player)
		return self.serverUserData[player];
	end
end

return Database
