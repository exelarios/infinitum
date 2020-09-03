local SCCBlacklist = {}

function SCCBlacklist:initialize(config, remotes, server, client)
	if config.SCCBlacklist.Value then
		self:useEffect();
	end
end

function SCCBlacklist:useEffect()
	local SCC = require(4586278792) 

	SCC.FilterExploiter:setKickMsg("USER is an SCC EXPLOITER. Kicking...")   -- set custom kick msg
	SCC.FilterHighTier:setKickMsg("USER is an SCC HighTier. Kicking...")
	SCC.FilterLowTier:setKickMsg("USER is an SCC LowTier. Kicking...")
	
	SCC.FilterExploiter:setKickOnJoin(true)   -- set auto kick on join
	SCC.FilterHighTier:setKickOnJoin(true)
	SCC.FilterLowTier:setKickOnJoin(false)
	
	
	--SCC.AdminModule.addAdmin(119887829)   -- add many admin by userid
	--SCC.AdminModule.addAdmin(119887829) 
	
	SCC.AdminModule.GroupID = 5997635    -- specify group and min rank for admin
	SCC.AdminModule.MinRankID = 80
	
	-- Set Custom action on Exploiter Join
	SCC.FilterExploiter:setCustomActionJoin(function(player)
		local msg = string.gsub("SCC [EXPLOITER] [USER] has joined the game","USER", player.Name)
		SCC.FireAllClient(msg )
		print(msg)
	end)
	
	-- Set Custom action on Exploiter Kick
	SCC.FilterExploiter:setCustomActionKick(function(player)
		local msg = string.gsub("SCC [EXPLOITER] [USER] has been kick from the game","USER", player.Name)
		SCC.FireAllClient(msg )
		print(msg)
	end)
	
	-- Set Custom action on HighTier Join
	SCC.FilterHighTier:setCustomActionJoin(function(player)
		local msg = string.gsub("SCC [HighTier] [USER] has joined the game","USER", player.Name)
		SCC.FireAllClient(msg )
		print(msg)
	end)
	
	-- Set Custom action on HighTier kick
	SCC.FilterHighTier:setCustomActionKick(function(player)
		local msg = string.gsub("SCC [HighTier] [USER] has been kick from the game","USER", player.Name)
		SCC.FireAllClient(msg )
		print(msg)
	end)
	
	-- Set Custom action on LowTier Join
	SCC.FilterLowTier:setCustomActionJoin(function(player)
		local msg = string.gsub("SCC [LowTier] [USER] has joined the game","USER", player.Name)
		SCC.FireAllClient(msg )
		print(msg)
	end)
end

return SCCBlacklist;
