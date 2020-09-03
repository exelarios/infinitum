local remotes = script.Client:WaitForChild("Remotes");

return function(config)
	
	warn("Infinitum 2.0 initializing . . ");
	
	for _, module in pairs(script.Server.Core:GetChildren()) do
		if module:IsA("ModuleScript") then
			require(module):initialize(config, remotes, script.Server, script.Client);
		end
	end
	
	warn("Infinitum 2.0 has sucessfully loaded. ");
end

