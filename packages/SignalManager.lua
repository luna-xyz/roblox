-- SignalManager.lua

local SignalManager = {};
SignalManager.__index = SignalManager;

function SignalManager.__init()
	
	local self = setmetatable({}, SignalManager);
	self._signals = {}; self._threads = {};

	return self;
end;

function SignalManager:AddSignal(signal, callback)

	local connection = signal:Connect(callback);
	table.insert(self._signals, connection);

	return connection;
end;

function SignalManager:RemoveSignal(connection)

	for i, v in ipairs(self._signals) do

		if v ~= connection then continue end;

		v:Disconnect();
		table.remove(self._signals, i);

		break;
	end;
end;

function SignalManager:AddThread(callback)

	local thread = task.spawn(callback);
	table.insert(self._threads, thread);

	return thread;
end;

function SignalManager:RemoveThread(thread)

	for i, v in ipairs(self._threads) do

		if v ~= thread then continue end;

		pcall(task.cancel, thread);
		table.remove(self._threads, i);

		break;
	end;
end;

function SignalManager:RemoveAllSignals()

	for _, v in ipairs(self._signals) do
		v:Disconnect();
	end;

	self._signals = {};
end;

function SignalManager:RemoveAllThreads()

	for _, v in ipairs(self._threads) do
		pcall(task.cancel, v);
	end;
	
	self._threads = {};
end;

function SignalManager:RemoveAll()

	for _, v in ipairs(self._signals) do
		v:Disconnect();
	end;
	
	for _, v in ipairs(self._threads) do
		pcall(task.cancel, v);
	end;

	self._signals = {}; self._threads = {};
end;

return SignalManager.__init();
