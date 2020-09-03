local command = {}

function command:initialize(config, remotes, server, client)
	
	self.config = config;
	self.remotes = remotes;
	self.server = server;
	self.client = client;
	
	print("Team Command has been initialized")
	
end

function command:useEffect(sender, args)
	local getTeam = args[1]:sub(1, 1):upper() .. args[1]:sub(2);
	local findTeam = self.config.Teams[getTeam];
	if findTeam then
		local team = findTeam.Value;
		team.Name = args[2];
	end
end

return command;