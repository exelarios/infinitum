local TweenService = game:GetService("TweenService");

local TweeningInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);

local module = {}

function module:fade(frame, state)
	
	if not frame or not frame:IsA("Frame") then
		return;
	end
	
	if state == "out" then
		for _, button in pairs(frame:GetChildren()) do
			if button:IsA("ImageButton") then
				local TransparentTweening = TweenService:Create(button, TweeningInfo, {ImageTransparency = 1});
				TransparentTweening:Play();
				button.Visible = false;
			end
		end
		frame.Visible = false;
	end
	
	if state == "in" then
		frame.Visible = true;
		for _, button in pairs(frame:GetChildren()) do
			if button:IsA("ImageButton") then
				button.Visible = true;
				button.ImageTransparency = 1;
			end
		end
		
		for _, button in pairs(frame:GetChildren()) do
			if button:IsA("ImageButton") then
				button.Visible = true;
				local TransparentTweening = TweenService:Create(button, TweeningInfo, {ImageTransparency = 0});
				TransparentTweening:Play();
			end
		end
	end
end

return module
