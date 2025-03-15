if getgenv().hub_enviorment then
	return warn("luna.xyz is already loaded!")
end

local supported_games = {
	["rakoof"] = 15367709476,
};

getgenv().hub_enviorment = {
	hub_version = game:HttpGet("https://raw.githubusercontent.com/luna-xyz/roblox/refs/heads/main/version.txt");
};

function hub_enviorment:Notify(text)

	game:GetService("StarterGui"):SetCore("SendNotification", {

		Title = 'luna.xyz ' .. tostring(hub_enviorment.hub_version),
		Text = tostring(text),

		Duration = 3,
	})
end;

for i, v in supported_games do
	
	if tostring(game.PlaceId) == tostring(v) then
		return loadstring(game:HttpGet('https://raw.githubusercontent.com/luna-xyz/roblox/refs/heads/main/games/' .. tostring(i) .. '.lua'))();
	end;
end;

getgenv().hub_enviorment = nil;

local LP = game:GetService("Players").LocalPlayer;
pcall(function() LP:Kick('This game is not supported!\n\nVersion: ' .. tostring(hub_enviorment.hub_version)) end);
