local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local UpdateWeapons = {}

function UpdateWeapons:initialize(config, remotes, server, client)
	
	self.config = config;
	self.remotes = remotes;
	self.server = server;
	self.client = client;
	
	self.weapons = {};
	self.orderedInventory = {"Shinjitsu", "Kurashikku"};
	
	self:useEffect();
	
    print("UpdateWeapons has loaded");
end

function UpdateWeapons:useEffect()
	self:getWeapons();
	self:usePlayer();
end

function UpdateWeapons:usePlayer()
	
	local function onPlayerAdded(player)
		local function onCharacterAdded(character)
			if self.config.Weapons.Value then
				self:addKatana(player);
			end
			self:findWhitelistedWeapons(player);
			self:addAccessory(player, character);
		end
	
		onCharacterAdded(player.Character or player.CharacterAdded:Wait());
		player.CharacterAdded:Connect(onCharacterAdded);
	end
	
	Players.PlayerAdded:Connect(onPlayerAdded);
	
	for _, player in pairs(Players:GetPlayers()) do
		onPlayerAdded(player);
	end
end

function UpdateWeapons:findWhitelistedWeapons(player)
	
	local function isToolWhitelisted(findTool)
		for _, tool in pairs(self.weapons) do
			if tool.Name == findTool then
				return tool;
			end
		end
	end
	
	local character = player.Character or player.CharacterAdded:Wait();
	local Humanoid = character:WaitForChild("Humanoid");
	
	local backpack = player:WaitForChild("Backpack");
	
	-- Removes weapons if the player's team is a spectator.
	for _, tool in pairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if player.TeamColor == self.config.Teams.Spectator.Value.TeamColor then
				local newTool = isToolWhitelisted(tool.Name);
				if newTool then
					tool:Destroy();
				end
			end
		end
	end
	
	for _, tool in pairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			local newTool = isToolWhitelisted(tool.Name);
			if newTool then
				local updatedTool = newTool:Clone();
				local weaponSettings = tool:FindFirstChild("Settings");
				if weaponSettings then
					local function checkSettingDuplicated(setting)
						for _, overwrittenSetting in pairs(tool.Settings:GetChildren()) do
							if overwrittenSetting.Name == setting.Name then
								return overwrittenSetting;
							end
						end
						return nil;
					end
					
					for _, defaultSetting in pairs(updatedTool.Settings:GetChildren()) do
						local getOverwrittenSetting = checkSettingDuplicated(defaultSetting);
						if getOverwrittenSetting then
							local getNewSetting = getOverwrittenSetting:Clone();
							defaultSetting:Destroy();
							getNewSetting.Parent = updatedTool.Settings;
						end
					end
				end

				tool:Destroy();
				updatedTool["SwordScript"].Disabled = false;
				updatedTool.Parent = backpack;
			end
		end
	end

end

function UpdateWeapons:addKatana(player)
	if player:GetRankInGroup(5997635) >= 60 then
		local kurashikku = self.server.Assets.Weapons.Kurashikku:Clone();
		kurashikku.Parent = player.Backpack;
		kurashikku["SwordScript"].Disabled = false;
	end
end


function UpdateWeapons:addAccessory(player, character)
	local accessories = ReplicatedStorage:WaitForChild("Accessories");
	
	local function isToolInPlayerInventory(toolName)
		
		local function checkWeaponName(object)
			if object:IsA("Tool") then
				local getSettings = object:FindFirstChild("Settings");
				if getSettings then
					local getWeaponName = getSettings:WaitForChild("WeaponName");
					if getWeaponName then
						if getWeaponName.Value == string.split(toolName, ".")[1] then
							return true;
						end
					end
				end
			end
			return false;
		end
		
		for _, object in pairs(character:GetChildren()) do
			if checkWeaponName(object) then
				return true;
			end
		end
		
		local backpack = player:WaitForChild("Backpack");
		for _, tool in pairs(backpack:GetChildren()) do
			if checkWeaponName(tool) then
				return true;
			end
		end
	end
	
	for _, accessory in pairs(accessories:GetChildren()) do
		if isToolInPlayerInventory(accessory.Name) then
			local Torso = character:WaitForChild("Torso");
			local getAccessory = accessory:Clone();
			getAccessory:MoveTo(Torso.Position);
			getAccessory.Parent = character;
			
			local weld = Instance.new("Weld");
			weld.Name = accessory.name .. "Weld";
			weld.Part0 = getAccessory:FindFirstChild("Root");
			weld.Part1 = Torso
			weld.Parent = Torso;
		end
	end
	
end

function UpdateWeapons:getWeapons()
	local weapons = self.server.Assets.Weapons;
	for _, weapon in pairs(weapons:GetChildren()) do
		table.insert(self.weapons, weapon);
	end
end

return UpdateWeapons