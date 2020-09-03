local Players = game:GetService("Players");
local Lighting = game:GetService("Lighting");
local UserInputService = game:GetService("UserInputService");
local LocalPlayer = Players.LocalPlayer;

local Trigger = {}

function Trigger:initialize(remotes, localSettings)
	
	self.remotes = remotes;
	self.localSettings = localSettings;
	self.count = 0;
	
	if game.CreatorId == 5997635 then
		self:useEffect();
		self:useRemote();
		print("Trigger has loaded on " .. LocalPlayer.Name);
	end
	
end

function Trigger:useEffect()
	
	local function onPlayerAdded(player)
		local Backpack = player:WaitForChild("Backpack");
		local function useEffect(character)
			local Humanoid = character:WaitForChild("Humanoid");
			self:checkHumanoid(Humanoid);
			self:checkBody(character);
			self:checkArm(character);
		end
		
		Backpack.ChildAdded:Connect(function()
			for _, tool in pairs(Backpack:GetChildren()) do
				self:checkTool(tool);
			end
		end)		

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

function Trigger:tracker()
	self.count = self.count + 1;
	if self.count >= 3 then
		LocalPlayer:Kick("imgaine haxing");
	end
end

function Trigger:checkHumanoid(Humanoid)
	local humList = {"WalkSpeed", "JumpPower", "HipHeight"};
	for _, v in pairs(humList) do
		Humanoid:GetPropertyChangedSignal(v):Connect(function()
			if v == "WalkSpeed" then
				if Humanoid["WalkSpeed"] < 17 then
					return;
				end
			end
			self.remotes.Activater:FireServer("Humanoid Property Changed.")
			Trigger:tracker();
		end)
		Humanoid.DescendantAdded:Connect(function(n)
			if n.ClassName == 'Weld' then
				self.remotes.Activater:FireServer("DDOS")
				Trigger:tracker();
				Humanoid:Destroy()
			end
		end)
	end
end

function Trigger:checkBody(character)
	local bodyCheckList = {"Head","Left Arm","Right Arm","Left Leg","Right Leg","Torso","HumanoidRootPart"};
	local moverWhiitelist = {["SwordVelocityLunge"] = true}
	for _, v in pairs(bodyCheckList) do
		v = character:WaitForChild(v)
		v:GetPropertyChangedSignal("Size"):Connect(function()
			self.remotes.Activater:FireServer("change body size.");
			Trigger:tracker();
		end)
		if character == LocalPlayer.Character then
			v.ChildAdded:Connect(function(i)
				if (i:IsA('BodyMover') or i:IsA("Constraint") or i:IsA("BasePart")) and not moverWhiitelist[i.Name] then
					self.remotes.Activater:FireServer("added movers/Constraint/part to character");
					Trigger:tracker();
				end
			end)
		end
	end
end

function Trigger:checkTool(tool)
	if tool:IsA("HopperBin") then
		self.remotes.Activater:FireServer("roblox btools");
	elseif tool:WaitForChild('Handle',1) then 
		tool.Handle:GetPropertyChangedSignal("Size"):Connect(function()
			self.remotes.Activater:FireServer("change handle size");
			Trigger:tracker();
		end)
	end
end

function Trigger:checkArm(character)
	local Humanoid = character:WaitForChild("Humanoid");
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart");
	local rightArm = character:WaitForChild("Right Arm");
	spawn(function()
		while Humanoid.Health > 1 do
			if (HumanoidRootPart.Position - rightArm.Position).magnitude >= 3 then
				self.remotes.Activater:FireServer("right arm out of distance.");
				Trigger:tracker();
			end
			wait(1);
		end
	end)

	local arm = character:WaitForChild("Torso"):WaitForChild("Right Shoulder")
	arm:GetPropertyChangedSignal("C0"):Connect(function()
		self.remotes.Activater:FireServer("changing right arm position");
		Trigger:tracker();
	end)
end

function Trigger:useRemote()

end

return Trigger
