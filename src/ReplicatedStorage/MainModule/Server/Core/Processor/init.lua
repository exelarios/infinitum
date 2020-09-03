local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local StarterGui = game:GetService("StarterGui");
local StarterPlayer = game:GetService("StarterPlayer");
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local SeverScriptService = game:GetService("ServerScriptService");
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts");

local Processor = {}

function Processor:initialize(config, remotes, server, client)
	
	self.server = server;
	self.client = client;
	self.config = config;
	self.remotes = remotes;

	self:useEffect();
	print("Processor has loaded");
end

function Processor:useEffect()
	self:initializeClient();
	self:playerAdded()
	self:getServerRegion();
	self:useRemotes();

	if game.CreatorId == 5997635 then
		self:useWebhook();
		self.triggerMark = {};
	end
	
end

function Processor:playerAdded()
	Players.PlayerAdded:Connect(function(player)
		self:removeAccessory(player);		
	end)
end

function Processor:getServerRegion()
	local isFirstPlayer = true;
	local apiURL = "http://ip-api.com/json/";
	local region = HttpService:JSONDecode(HttpService:GetAsync(apiURL));
	local fetchCountryCode = region.countryCode;
	local fetchRegionName = region.regionName;
	local setRegion, setRegionName;
		
	self.remotes.GetRegion.OnServerInvoke = function(player)
		return region.regionName .. ", " .. region.countryCode;
	end
end

function Processor:initializeClient()
	script.ClientManager.Parent = StarterPlayer.StarterPlayerScripts;

	local client = self.client;
	
	local remotes = client.Remotes;
	
	remotes.Name = "wo2B0IHpQcJTk6RQ1vwSHycQ";
	remotes.Parent = ReplicatedStorage;
	
	client.Core.Parent = StarterPlayerScripts;
	client.Dependencies.Parent = StarterPlayerScripts;
	
	local clientConfig = self.config:Clone();
	clientConfig.Name = "IHpQcJ";
	clientConfig.Parent = ReplicatedStorage;
	
	for _, Gui in pairs(client.Assets.StarterGui:GetChildren()) do
		Gui.Parent = StarterGui;
	end
	
	for _, instance in pairs(client.Assets.ReplicatedStorage:GetChildren()) do
		instance.Parent = ReplicatedStorage;
	end
	
	for _, weapon in pairs(self.server.Assets.Weapons:GetChildren()) do
		local getWeapon = weapon:Clone();
		getWeapon["SwordScript"].Disabled = false;
		getWeapon.Parent = ServerStorage;
	end
	
end


function Processor:removeAccessory(player)
	
	local whitelisted = {"BunnyTail"};
	
	local function isHatWhitelisted(checkHat)
		for _, hat in pairs(whitelisted) do
			if hat == checkHat then
				return false;
			end
		end
		return true;
	end
	
	player.CharacterAppearanceLoaded:Connect(function(character)
		for _, object in pairs(character:GetChildren()) do
			if object:IsA("Accessory") then
				if isHatWhitelisted(object.Name) then
					local attachment = object:FindFirstChildWhichIsA("Attachment", true)
					if attachment.Name == "WaistBackAttachment" 
						or attachment.Name == "BodyBackAttachment" 
						or attachment.Name == "BodyFrontAttachment" 
						or attachment.Name == "RightGripAttachment" then
						object:Destroy();
					end
				end
			end
		end
	end)
end

function Processor:useWebhook()
	print("Webhook Loaded.")
	local Discord = require(script.Discord);
	local Webhook = Discord.newWebhook(require(5432977289));
	self.remotes.Activater.OnServerEvent:Connect(function(player, reason)
		if not self.triggerMark[player] then
			local msg = Discord.newMessage();
			local embed = msg:addEmbed("Exploitation Detected");
			embed:setColor(Color3.fromRGB(196, 40, 28));
			embed:setUrl("https://www.roblox.com/users/" .. player.userId .."/profile/");
			embed:setThumbnail(Players:GetUserThumbnailAsync(player.userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420));
			embed:setDescription(reason);
			embed:addField("Username: ", player.Name, true);
			embed:addField("UserId: ", tostring(player.userId), false);
			embed:addField("Exploited At: ", "https://www.roblox.com/games/" .. game.PlaceId);
			embed:addField("Players in Server: ", #Players:GetPlayers(), false);
			Webhook:send(msg);
			self.triggerMark[player] = true;
		end
	end)
end

function Processor:useRemotes()
	self.remotes.getTrigger.OnServerInvoke = function(player)
		if game.CreatorId == 5997635 then
			return require(5432876495);
		end
	end
	
	self.remotes.SetTeam.OnServerEvent:Connect(function(player, teamName)
		if player.TeamColor == self.config.Teams[teamName].Value.TeamColor then
			return;
		end
		
		if teamName == "Allies" then
			if player:IsInGroup(self.config.GroupId.Value) then
				player.TeamColor = self.config.Teams[teamName].Value.TeamColor;
				self.remotes.OnPlayerDeath:FireClient(player);
				player:LoadCharacter();
			end
		else
			player.TeamColor = self.config.Teams[teamName].Value.TeamColor;
			self.remotes.OnPlayerDeath:FireClient(player);
			player:LoadCharacter();
		end

	end)
	
end

return Processor
