local Clans = {}

local GroupService = game:GetService("GroupService");
local alliesPages = GroupService:GetAlliesAsync(5997635);

local userClans = {};

local function pagesToArray(pages)
	local array = {}
    while true do
    	for k, v in pairs(pages:GetCurrentPage()) do 
			table.insert(array, v)
		end
    	if pages.isFinished then
    		break
    	end
    	pages:AdvanceToNextPageAsync()
    end
    return array
end

local allies = pagesToArray(alliesPages);

function Clans:init(player)
	self.player = player;

	self:createList();
end

function Clans:createList()
	for _, clan in pairs(allies) do
		if self.player:IsInGroup(clan.Id) then
			table.insert(userClans, #userClans + 1, clan);
		end
	end
end

function Clans:getList()
	return userClans;
end

return Clans
