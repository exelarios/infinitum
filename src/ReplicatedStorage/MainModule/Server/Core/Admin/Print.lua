local command = {}

function command:initialize(config, remotes, server, client)
	
	self.config = config;
	self.remotes = remotes;
	self.server = server;
	self.client = client;
	
	print("Print Command has been initialized")
	
end

function command:useEffect(sender, args)
	print("yesssssss");
	local message = table.concat(args, " ");
	print("From " .. sender.Name .. ":\n" .. message);
end

return command;