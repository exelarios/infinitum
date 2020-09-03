local Teams = game:GetService("Teams");
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local RaidManager = {}

function RaidManager:initialize(config, remotes, server, client)
	
	self.config = config;
	self.remotes = remotes;
	self.server = client;
	
	if self.config.Raidable.Value then
		self:useEffect();
	end
	print("RaidManager has loaded");
end

function RaidManager:useEffect()
	
	local raidInfo = ReplicatedStorage:WaitForChild("RaidInfo");
	
	local scores = raidInfo.Score;
	local alliesScore = scores.Allies;
	local axisScore = scores.Axis;
	
	local teams = {
		allies = self.config.Teams.Allies.Value;
		axis = self.config.Teams.Axis.Value;
	}
	
	local function getKillerOfHumanoidIfStillInGame(humanoid)
		local tag = humanoid:findFirstChild("creator");
		if tag ~= nil then
			local killer = tag.Value
			if killer.Parent ~= nil then -- killer still in game
				return killer
			end
		end
		return nil
	end
	
	local function handleKillCount(humanoid, player)
		local killer = getKillerOfHumanoidIfStillInGame(humanoid)
		if killer ~= nil then
			local spectator = self.config.Teams.Spectator;
			for _, team in pairs(self.config.Teams:GetChildren()) do
				if team ~= spectator then
					if killer.TeamColor == team.Value.TeamColor then
						if team.Name == "Allies" then
							alliesScore.Value = alliesScore.Value + 1;
						end
						
						if team.Name == "Axis" then
							axisScore.Value = axisScore.Value + 1;
						end
					end
				end
			end
		end
	end
	
	function onHumanoidDied(humanoid, player)
		for i, findKiller in pairs(Players:GetPlayers()) do
			local killer = getKillerOfHumanoidIfStillInGame(humanoid)
			if findKiller == killer then
				local getKillerDistance = player:DistanceFromCharacter(findKiller.Character:FindFirstChild("HumanoidRootPart").Position);
				if getKillerDistance <= self.config.Leaderboard.ReachThreshold.Value then
					handleKillCount(humanoid, player)
				end
			end
		end
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
	
	local function setWinner(winner, loser)
		if not raidInfo.Reseting.Value then
			giveAllForceField();
			local winnerName = string.gsub(winner.Name:gsub(" $", ""), "%p%d+%p", "");
			local loserName = string.gsub(loser.Name:gsub(" $", ""), "%p%d+%p", "");
			self.remotes.SystemMessage:FireAllClients(winnerName .. " has routed " .. loserName .. ". " .. winnerName .. " takes victory!", 10);
			raidInfo.RaidStarted.Value = false;
		end
	end
	
	spawn(function()
		while wait(0.9) do
			if raidInfo.RaidStarted.Value then
				local timestamp = raidInfo.Timestamp;
				local timer = raidInfo.Timer;
				local countdown = timestamp.Value - os.time();
				timer.Value = countdown;
				
				if countdown <= 0 then
					raidInfo.RaidStarted.Value = false;
					if alliesScore.Value > axisScore.Value then
						setWinner(teams.allies, teams.axis);
					elseif alliesScore.Value < axisScore.Value then
						setWinner(teams.axis, teams.allies);
					else
						self.remotes.SystemMessage:FireAllClients("Both teams are equally match, the result is a draw due to ovetime.", 10);
					end
				end
			end 
		end
	end)
	
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			character:WaitForChild("Humanoid").Died:Connect(function()
				if raidInfo.RaidStarted.Value then
					local Humanoid = player.Character.Humanoid;
					onHumanoidDied(Humanoid, player);
				end
			end)
		end)
	end)
	
	alliesScore:GetPropertyChangedSignal("Value"):Connect(function()
		local maxScore = raidInfo.MaxKills.Value;
		if alliesScore.Value >= maxScore then
			setWinner(teams.allies, teams.axis);
		end
	end)
	
	axisScore:GetPropertyChangedSignal("Value"):Connect(function()
		local maxScore = raidInfo.MaxKills.Value;
		if axisScore.Value >= maxScore then
			setWinner(teams.axis, teams.allies);
		end
	end)
	
end

return RaidManager
