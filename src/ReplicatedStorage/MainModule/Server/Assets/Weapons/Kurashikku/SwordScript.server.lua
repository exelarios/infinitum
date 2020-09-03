local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local config = Tool.Settings;

local Damage = config.NormalDamage.Value;

local damageable = {"Head", "Left Arm", "Left Leg", "Right Arm", "Right Leg", "Torso"};

local Grips = {
	Up = CFrame.new(1.61819172, -1.82964754e-13, -0.130494729, 5.23339025e-08, -0.974983633, -0.22227636, -1, -4.37113847e-08, -4.37113883e-08, 3.29018768e-08, 0.22227636, -0.974983633),
	Out = CFrame.new(1.34591269, -2.48689958e-13, -0.010893777, -3.75183156e-08, -0.132820874, 0.991139948, -1, -4.37113847e-08, -4.37113883e-08, 4.91298948e-08, -0.991139948, -0.132820874)
}

local ToolEquipped = false

Tool.Grip = Grips.Up
Tool.Enabled = true

local function round(value)
	return math.floor(value * 100) / 100;
end

Tool.ToolTip = config.WeaponName.Value
.. " | Size: " .. tostring(round(Handle.Size.X)) 
.. " x " .. tostring(round(Handle.Size.Y)) 
.. " x " .. tostring(round(Handle.Size.Z))
.. " | Basic: " .. tostring(config.NormalDamage.Value)
.. " | Lunge: " .. tostring(config.LungeDamage.Value)
.. " | Slash: " .. tostring(config.SlashDamage.Value)
.. " | Cooldown: " .. tostring(round(config["AttackCooldown"].Value))
.. " | LungeDuration: " .. tostring(round(config["LungeDuration"].Value))
.. " | Anti-Tie: " .. tostring(config["Anti-Tie"].Value)
.. " | TeamKill: " .. tostring(config.TeamKill.Value);


function IsTeamMate(Player1, Player2)
	if config["TeamKill"].Value then
		return false;
	end
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

local function checkDamageable(checkLimb)
	for _, limb in pairs(damageable) do
		if checkLimb.Name == limb then
			return true;
		end
	end
	return false;
end

local function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

local function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("HumanoidRootPart")
	
	if not CheckIfAlive() then
		return
	end
	
	local accessory = Character:FindFirstChild(config.WeaponName.Value .. ".accessory");
	if accessory then
		accessory.Handle.Transparency = 1;
	end
	
	ToolEquipped = true
	Handle.Unsheath:Play()
end



local function Attack()
	Damage = config.SlashDamage.Value;
	Handle.Slash:Play()

	if Humanoid then
		local Anim = Instance.new("StringValue")
		Anim.Name = "toolanim"
		Anim.Value = "Slash"
		Anim.Parent = Tool
	end	
end

local function Lunge()
	
	Damage = config.LungeDamage.Value;
	Handle.Lunge:Play()
	
	if Humanoid then
		local Anim = Instance.new("StringValue")
		Anim.Name = "toolanim"
		Anim.Value = "Lunge"
		Anim.Parent = Tool
		
		local BodyVelocity = Instance.new("BodyVelocity");
		BodyVelocity.Name = "SwordVelocityLunge";
		BodyVelocity.MaxForce = Vector3.new(0, 0, 0);
		BodyVelocity.P = 0;
		BodyVelocity.Velocity = Vector3.new(0, 10, 0);
		BodyVelocity.Parent = Tool.Parent:FindFirstChild("Torso");
		Debris:AddItem(BodyVelocity, 0.5);
	end
	
	wait(config.AttackCooldown.Value)
	Tool.Grip = Grips.Out
	wait(config.LungeDuration.Value)
	Tool.Grip = Grips.Up

	Damage = config.NormalDamage.Value;
end

Tool.Enabled = true
local LastAttack = 0
local function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end
	LastAttack = Tick

	Damage = config.NormalDamage.Value;
	
	Tool.Enabled = true
end

local function Unequipped()
	Tool.Grip = Grips.Up
	ToolEquipped = false
	
	local accessory = Character:FindFirstChild(config.WeaponName.Value .. ".accessory");
	if accessory then
		accessory.Handle.Transparency = 0;
	end
end

local function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or not checkDamageable(Hit) then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	
	local opponentPosition = Hit.Parent.Torso.Position;
	local playerDistance = Player:DistanceFromCharacter(opponentPosition);
	if playerDistance <= config.StudsCap.Value then
		if config["Anti-Tie"] or humanoid.Health > 0 then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(Damage)
			Handle.Cuthim:Play();
		end
	end

end


Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

Connection = Handle.Touched:Connect(Blow)