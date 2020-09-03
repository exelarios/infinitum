--[[

.__           _____ .__         .__   __                   
|__|  ____  _/ ____\|__|  ____  |__|_/  |_  __ __   _____  
|  | /    \ \   __\ |  | /    \ |  |\   __\|  |  \ /     \ 
|  ||   |  \ |  |   |  ||   |  \|  | |  |  |  |  /|  Y Y  \
|__||___|  / |__|   |__||___|  /|__| |__|  |____/ |__|_|  /
         \/                  \/                         \/ 2.0
				Sengoku Japan Framework 2020
				   Developed by Algorist
________________________________________________________________

Weapons:
- Shinjitsu (Katana)
- Kurashikku (Wakizashi)

]]

-- Don't touch anything below or you will break the script.
local config = script.Settings;
if config.Debugging.Value then
	require(game:GetService("ReplicatedStorage").MainModule)(config);
else
	require(5386419664)(script.Settings);
end