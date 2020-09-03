local Teams = game:GetService("Teams");
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");
local StarterGui = game:GetService("StarterGui");

local raidInfo = ReplicatedStorage:WaitForChild("RaidInfo");

local command = {}

function command:initialize(config, remotes, server, client)
	
	self.config = config;
	self.remotes = remotes;
	self.server = server;
	self.client = client;
	
	self.minimumPlayers = 1;
	self.showMessageTime = 7;
	self.raidDuration = 3600;
	self.debounce = false;
	
	print("Raid Command has been initialized")
	
end

local function giveAllForceField()
	for _, player in pairs(Players:GetPlayers()) do
		local Character = player.Character;
		if player.Character then
			local forceField = Instance.new("ForceField");
			forceField.Parent = player.Character;
		end
	end
end

local function respawnAll()
	for _, player in pairs(Players:GetPlayers()) do
		player:LoadCharacter();
	end
end

local function resetstatsAll()
	for _, player in pairs(Players:GetPlayers()) do
		local getLeaderstats = player:FindFirstChild("leaderstats");
		if getLeaderstats then
			local getKills = getLeaderstats:FindFirstChild("KOs");
			local getDeaths = getLeaderstats:FindFirstChild("Wipeouts");
			getKills.Value = 0;
			getDeaths.Value = 0;
		end
	end
end

local function displayCounterGui(value)
	local killCounter = StarterGui:WaitForChild("infinitumGui");
	killCounter.Scoreboard.Visible = value;
	killCounter.Timer.Visible = value;
	
	for _, player in pairs(Players:GetPlayers()) do
		local Gui = player.PlayerGui:WaitForChild("infinitumGui");
		Gui.Scoreboard.Visible = value;
		Gui.Timer.Visible = value;
	end
end

function command:useEffect(sender, args)
	
	if not self.config.Raidable.Value then
		return;
	end

	local raidStarted = raidInfo.RaidStarted;
	local reseting = raidInfo.Reseting;
	
	local teams = {
		allies = self.config.Teams.Allies.Value;
		axis = self.config.Teams.Axis.Value;
	}
	
	local function resetKills(raidInfo)
		local alliesKill = raidInfo.Score.Allies;
		alliesKill.Value = 0;
		
		local axisKill = raidInfo.Score.Axis;
		axisKill.Value = 0;
	end
	
	if not args[1] then
		return;
	end
	
	if args[1]:lower() == "start" then
		if self.debounce then
			return;
		end
		if not args[2] then
			self.remotes.SystemMessage:FireAllClients("Missing an second argument, expected integer got nil.", 5);
			return;
		end
		
		if args[3] then
			self.raidDuration = tonumber(args[3]);
		end

		if not raidStarted.Value then
			self.debounce = true;
			reseting.Value = false;
			
			local numberOfAllies = #teams.allies:GetPlayers();
			local numberOfAxies = #teams.axis:GetPlayers();
			
			if (numberOfAllies < self.minimumPlayers) or (numberOfAxies < self.minimumPlayers) then
				self.remotes.SystemMessage:FireAllClients("Both teams are requied to have at-least " .. self.minimumPlayers .. " players.", 5);
				self.debounce = false;
				return;
			end

			giveAllForceField();
			resetstatsAll();
			
			local maxKills = raidInfo.MaxKills;
			local timestamp = raidInfo.Timestamp;
			local timer = raidInfo.Timer;
			
			resetKills(raidInfo);
			maxKills.Value = args[2];
			self.remotes.SystemMessage:FireAllClients(sender.Name .. " has initialized the raid at " .. maxKills.Value .. " kills.", self.showMessageTime);
			wait(self.showMessageTime);
			displayCounterGui(true);
			respawnAll();
			timestamp.Value = os.time() + self.raidDuration;
			raidStarted.Value = true;
			self.debounce = false;
		else
			print("Raid has already been initialized.");
		end

	end
	
	if args[1]:lower() == "reset" then
		if raidInfo then
			self.remotes.SystemMessage:FireAllClients(sender.Name .. " has reseted the raid.", 5);
			raidStarted.Value = false;
			reseting.Value = true;
			displayCounterGui(false);
			resetKills(raidInfo);
		end
	end
end

return command;