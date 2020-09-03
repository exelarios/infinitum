local TeleportService = game:GetService("TeleportService")

local Commons = {}

function Commons:initialize(player, remotes, components, localSettings, button, menu, config)
	self.player = player;
	self.remotes = remotes;
	self.components = components;
	self.config = config;
	self.menu = menu;
	
	self.component = script.Component.Value;
end

function Commons:useEffect()
	self.menu.Visible = false;
	self.component.Visible = true;
	
	local frame = self.component.Frame;
	local submit = frame.Submit;
	submit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			TeleportService:Teleport(5060116738);
		end
	end)
end

return Commons;