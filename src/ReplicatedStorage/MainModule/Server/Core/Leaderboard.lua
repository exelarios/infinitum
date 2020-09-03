local Teams = game:GetService("Teams");
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local remotes = ReplicatedStorage:WaitForChild("wo2B0IHpQcJTk6RQ1vwSHycQ");

local Leaderboard = {}

function Leaderboard:initialize(config)
	
	if config.Leaderboard.Value then
		self.config = config;
		
		self:useEffect();
		self:countPlayers();
		print("Leaderboard has loaded");
	end
	
end

local function updatePingAsync(player)
	local ping = player:FindFirstChild("leaderstats"):WaitForChild("Ping");
	while wait(0.5) do
		local one = tick();
		remotes.Ping:InvokeClient(player);
		local two = tick() - one;
		ping.Value = math.floor(two * 1000);
	end
end

function Leaderboard:useEffect()
	Players.PlayerAdded:Connect(function(player)
		
		self:generateLeaderstats(player);
		
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid");
			if humanoid then
				humanoid.Died:Connect(function()
					self:incrementValue(player, character);
				end)
			end
		end)
		
		coroutine.wrap(function()
			updatePingAsync(player);
		end)();
		
	end)
end


function Leaderboard:generateLeaderstats(player)
	
	local leaderboardSettings = self.config.Leaderboard;
	
	local leaderstats = Instance.new("Folder");
	leaderstats.Name = "leaderstats";
	leaderstats.Parent = player;
	
	if leaderboardSettings["KOs/Wipeouts"].Value then
		local kills = Instance.new("IntValue");
		kills.Name = "KOs";
		kills.Parent = leaderstats;

		local deaths = Instance.new("IntValue");
		deaths.Name = "Wipeouts";
		deaths.Parent = leaderstats;
	end
	
	if leaderboardSettings.Ranks.Value then
		local rank = Instance.new("StringValue");
		rank.Name = "Rank";
		rank.Parent = leaderstats;
		
		if player:isInGroup(self.config.GroupId.Value) then
			rank.Value = player:GetRoleInGroup(self.config.GroupId.Value);
		elseif player:isInGroup(5997635) then
			rank.Value = player:GetRoleInGroup(5997635);
		else
			rank.Value = "Ronin";
		end
	end
	
	if leaderboardSettings.TeamKills.Value then
		local teamkill = Instance.new("IntValue");
		teamkill.Name = "TKs";
		teamkill.Parent = leaderstats;
	end
	
	if leaderboardSettings.Ping.Value then
		local ping = Instance.new("IntValue");
		ping.Name = "Ping";
		ping.Parent = leaderstats;
	end
	
end

function Leaderboard:countPlayers()
	if self.config.Leaderboard.CountPlayers.Value then
		for i, team in pairs(Teams:GetTeams()) do
			team.PlayerAdded:Connect(function(player)
				if team:IsA("Team") then
					local numberOfPlayersInTeam = #team:GetPlayers();
					team.Name = string.gsub(team.Name, "[%A]", "") .. " [" .. numberOfPlayersInTeam .. "]";
				end
			end)
			
			team.PlayerRemoved:Connect(function(player)
				if team:IsA("Team") then
					local numberOfPlayersInTeam = #team:GetPlayers();
					team.Name = string.gsub(team.Name, "[%A]", "") .. " [" .. numberOfPlayersInTeam .. "]";
				end
			end)
		end
	end
end

function Leaderboard:incrementValue(player, character)
	local leaderstats = player:FindFirstChild("leaderstats");
	local deaths = leaderstats:FindFirstChild("Wipeouts");
	deaths.Value = deaths.Value + 1;
	local killer = character.Humanoid:FindFirstChild("creator");
	if killer then
		local killerStats = Players[killer.Value.Name]:FindFirstChild("leaderstats");
		if killerStats then
			local killerHumanoidRootPart = Players[killer.Value.Name].Character:FindFirstChild("HumanoidRootPart");
			local getKillerDistance = player:DistanceFromCharacter(killerHumanoidRootPart.Position);
			local reachThreshold = self.config.Leaderboard.ReachThreshold.Value;
			if getKillerDistance <= reachThreshold then
				if self.config.Leaderboard.TeamKills.Value then
					local teamkills = leaderstats:FindFirstChild("TKs");
					if player.TeamColor == Players[killer.Value.Name].TeamColor then
						teamkills.Value = teamkills.Value + 1;
					end
				end
				killerStats["KOs"].Value = killerStats["KOs"].Value + 1; 
			else
				deaths.Value = deaths.Value - 1;
				remotes.SendMessage:FireAllClients(killer.Value.Name 
					.. " exceeded the reach threshold on " 
					.. player.Name .. ". The kill didn't count on leaderboard. (" 
					.. math.floor(getKillerDistance) .. " studs)"
				);
			end
		end
	end
end

return Leaderboard
