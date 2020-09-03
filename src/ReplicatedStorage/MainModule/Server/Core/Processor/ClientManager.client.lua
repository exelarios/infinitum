local Players = game:GetService("Players");
local StarterPlayer = game:GetService("StarterPlayer");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local LocalPlayer = Players.LocalPlayer;

local modules = StarterPlayer.StarterPlayerScripts:WaitForChild("Core");
local remotes = ReplicatedStorage:WaitForChild("wo2B0IHpQcJTk6RQ1vwSHycQ");
local localSettings = Players.LocalPlayer:WaitForChild("Settings");

for _, module in pairs(modules:GetChildren()) do
	if module:IsA("ModuleScript") then
		require(module):initialize(remotes, localSettings);
	end
end