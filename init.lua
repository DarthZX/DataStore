local datastoreservice = game:GetService("DataStoreService");
local playerData = datastoreservice:GetDataStore("PlayerData");

-- renaming in-built functions for efficiency

local createthread = coroutine.create
local resume = coroutine.resume
local wrap = coroutine.wrap
local yield = coroutine.yield

-- collecting garbage to prevent memory leaks

local function collectgarbage(value)
	
	if typeof(value) ~= nil then
		
		value = nil;
		
	else
		
		warn(value .. " is not garbage!")
		
	end
	
end

-- stores all the functions for our module!

local Data = {
	
	sessionData = {};	
	
	configuration = {
	
		_autoSave = 30; -- amount of seconds till data autosaves
	
		_checkTimes = 15; -- fires when retrieving player's data gives an error 
	
		_checkDelay = 2; -- delay between each check
	
	}
	
} do
	
	setmetatable({}, Data);
	
	-- inserted metamethods to update data!
	
	Data.__index = function(index, value)
		
		print(index, value);
		
	end
	
	Data.__newindex = function(self, index, value)
		
		self[index] = value;
		
	end
	
	-- after data is retrieved, we store that data in a table
	
	function Data:Add(player, ...)
		
		if typeof(...) ~= "table" then
			
			warn("Player data is not valid!");
			
			return "Unable to add data!";
			
		end
		
		if not self.sessionData[player] then
			
			self.sessionData[player] = table.unpack(...);
			
		end
		
		print(self.sessionData[player]);
		
		return self.sessionData;
		
	end
	
	-- tries to recieves player data in a pcall to prevent errors 
	
	function Data:Retrieve(player, ...)
		
		local data;
		
		local tries = 0;
		
		if #self.sessionData < 1 then
			
			local timeStarted;
			
			while tries < self.configuration._checkTimes do
				
				if self.configuration._checkTimes - tries <= 1 then
					
					if typeof(data) == nil and player then
						
						data = ...;
						
						return "Default"
						
					end
					
					return "Error";
					
				end
				
				if timeStarted == nil then
					
					timeStarted = os.time();
					
				else
					
					if os.time() - timeStarted >= self.configuration._checkDelay then
						
						timeStarted = os.time();
						
						local success, result = pcall(function()
				
							data = playerData:GetAsync(player.UserId);
				
						end)
			
						if not success then
				
							tries = tries + 1;
							
							warn(player .. "'s data could not load!");
					
						else
					
							for i, var in ipairs(self.configuration) do
								
								wrap(function()
									
									if #self.configuration > 0 and var ~= self.configuration._autoSave then
							
										collectgarbage(var)	;						
								
									end
									
								end)
						
							end
 					
							break;
					
						end
						
					end
					
				end
				
			end
			
			return "Success";
			
		end
		
	end
	
	-- updates data whenever necessary
	
	function Data:Update(player, ...)
		
		if Data:Retrieve(player, ...) == "Success" or "Default" then
			
			local success, result = pcall(function()
					
				playerData:UpdateAsync(player.UserId, function(oldvalue)	
					
									
						
				end)			
				
			end)
			
		else
			
			return "Unable to update null data"
			
		end
		
	end
	
end

return Data
