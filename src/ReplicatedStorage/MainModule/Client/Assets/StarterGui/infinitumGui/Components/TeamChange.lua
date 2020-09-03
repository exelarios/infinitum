local TeamChange = {}

function TeamChange:initialize(player, remotes, components, localSettings, button, menu, config)
	self.player = player;
	self.remotes = remotes;
	self.components = components;
	self.config = config;
	self.menu = menu;
	
	self.component = script.Component.Value;
	
	if not self.config.TeamChangerGui.Value or not self.config.Raidable.Value then
		self.menu.TeamChange:Destroy();	
	else
		for _, button in pairs(self.component:GetChildren()) do
			if button:IsA("ImageButton") then
				local teamInfo = self.config.Teams[button.Name].Value;
				button.Frame.TextLabel.Text = teamInfo.Name;
				button.ImageColor3 = teamInfo.TeamColor.Color;
			end
		end	
	end
end

function TeamChange:useEffect()
	if self.config.TeamChangerGui.Value and self.config.Raidable.Value then
		self.menu.Visible = false;
		self.component.Visible = true;
		
		for _, button in pairs(self.component:GetChildren()) do
			if button:IsA("ImageButton") then
				button.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						self.remotes.SetTeam:FireServer(button.Name);
					end
				end)
			end
		end
	end
end

return TeamChange
