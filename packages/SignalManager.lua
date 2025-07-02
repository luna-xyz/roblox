-- SignalManager.lua

local SignalManager = {};
SignalManager.__index = SignalManager;

function SignalManager.new()
	
	local self = setmetatable({}, SignalManager);
	self._connections = {};
	
	return self;
end;


function SignalManager:AddSignal(signal, callback)
	
	local connection = signal:Connect(callback);
	table.insert(self._connections, connection);
	
	return connection;
end;

function SignalManager:Remove(connection)
	
	for i, v in ipairs(self._connections) do
		
		if v ~= connection then continue end;
		
		v:Disconnect();
		table.remove(self._connections, i);
		
		break;
	end;
end;


function SignalManager:RemoveAll()
	
	for _, v in ipairs(self._connections) do
		v:Disconnect();
	end;
	
	self._connections = {};
end

return SignalManager;