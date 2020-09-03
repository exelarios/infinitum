local Players = game:GetService("Players");

local Admin = {}

function Admin:initialize(config, remotes, server, client)
	
	self.config = config;
	self.remotes = remotes;
	self.server = server;
	self.client = client;
	
	self.prefix = "!";
	self.commands = {};
	
	self:useEffect();
	print("Admin has loaded");
end

function Admin:useEffect()
	for _, command in pairs(script:GetChildren()) do
		local module = require(command);
		module:initialize(self.config, self.remotes, self.server);
		self.commands[command.Name:lower()] = module;
	end
	
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message, recipient)
			if not recipient and self:isAdmin(player) then
				self:parseMessage(player, message);
			end
		end)
	end)
end

function Admin:isAdmin(player)
	local rank = player:GetRankInGroup(self.config.GroupId.Value);
		if rank >= self.config.GroupId.groupAdminId.Value then
			return true;
		end
	return false;
end

function Admin:parseMessage(player, message)
	local prefixMatch = string.match(message,"^" .. self.prefix);
	
	if prefixMatch then
		message = string.gsub(message, prefixMatch, "");
		local arguments = {};
		
		for argument in string.gmatch(message,"[^%s]+") do
			table.insert(arguments, argument);
		end
		
		local CommandName = arguments[1];
		table.remove(arguments, 1);
		local CommandFunc = self.commands[CommandName];
		
		if CommandFunc ~= nil then
			CommandFunc:useEffect(player, arguments);
		end
	end
end

return Admin
