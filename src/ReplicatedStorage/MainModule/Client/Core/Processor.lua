local Players = game:GetService("Players");
local Lighting = game:GetService("Lighting");
local StarterGui = game:GetService("StarterGui");
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");
local LocalPlayer = Players.LocalPlayer;

local TweeningInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);

local Processor = {}

function Processor:initialize(remotes)
	
	self.remotes = remotes;
	self.player = Players.LocalPlayer;
	
	self:useEffect();
	print("client has loaded on " .. LocalPlayer.Name);
end

function Processor:useEffect()
	local Blur = Instance.new("BlurEffect");
	Blur.Name = "Blur"
	Blur.Size = 0;
	Blur.Parent = Lighting;
	
	self:useRemote();
	self:usePlayer();
end

function Processor:usePlayer()

	local function useEffect(character)
		
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true);
		
		local Humanoid = character:WaitForChild("Humanoid");
		Humanoid.Died:Connect(function()
			Humanoid:UnequipTools();
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false);
			Lighting["Blur"].Size = 0;
		end)
	end
	
	useEffect(self.player.Character or self.player.CharacterAdded:Wait());
	self.player.CharacterAdded:Connect(useEffect);

end

function Processor:useRemote()
	self.remotes.Ping.OnClientInvoke = function()
		return true
	end
	
	self.remotes.SendMessage.OnClientEvent:Connect(function(text)
		StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "{SYSTEM} " .. text;
		Color = BrickColor.new("Bright red").Color;
		});
	end)
	
	self.remotes.OnPlayerDeath.OnClientEvent:Connect(function(player)
		local BlurTweening = TweenService:Create(Lighting["Blur"], TweeningInfo, {Size = 0});
		BlurTweening:Play();
	end)
end

return Processor
