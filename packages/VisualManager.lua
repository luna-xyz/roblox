----- || SERVICES || -----

local RunService = game:GetService("RunService");
local players = game:GetService("Players");

local SignalManager = hub_enviorment:GetLib("SignalManager");

----- || LIBRARY || -----

local Callbacks, Methods, Library = {}, {}, {};
Library.__index = Library;

Callbacks = {

	Enabled = false;
	Names = true;

	Tracers = false;
	Boxes = false;

	Distance = false;
	FaceCamera = false;

	Players = true;
	TeamMates = true;

	BoxShift = CFrame.new(0,-1.5,0);
	AttachShift = 1;

	RainbowMode = false,
	ColorTickSpeed = 20;

	Objects = setmetatable({}, { __mode = "kv" });

	Groups = setmetatable({}, {

		__index = function(self, groupName)

			local groupTable = {

				Objects = {},

				SetColor = function(self, color)

					for _, v in pairs(self.Objects) do
						v.Color = color;
					end;
				end;

				SetName = function(self, name)

					for _, v in pairs(self.Objects) do
						v.Name = name;
					end;
				end;

				RemoveAll = function(self)

					for _, v in pairs(self.Objects) do
						v:Remove();
					end;

					table.clear(self.Objects);
				end;
			};

			rawset(self, groupName, groupTable);

			return setmetatable(groupTable, {

				__newindex = function(_, key, value)
					if key == "color" then

						groupTable:SetColor(value);

					elseif key == "name" then

						groupTable:SetName(value);

					else

						rawset(groupTable, key, value);
					end;
				end;
			});
		end;
	}),

	Overrides = {};
};

local currentCam = workspace.CurrentCamera;
local mouse = players.LocalPlayer:GetMouse();

local rainbow_color = Color3.fromRGB(255, 255, 255);

local V3new = Vector3.new;
local WorldToViewportPoint = currentCam.WorldToViewportPoint;


----- || METHODS || -----

function Methods:Draw(obj, props)

	local new = Drawing.new(obj);

	props = props or {};

	for i,v in pairs(props) do
		new[i] = v
	end;

	return new;
end;

function Methods:GetTeam(player)

	local __f = self.Overrides.GetTeam

	if __f then return __f(player) end
	return player and player.Team
end

function Methods:IsTeamMate(player)

	local __f = self.Overrides.IsTeamMate
	if __f then return __f(player) end

	return self:GetTeam(player) == self:GetTeam(players.LocalPlayer)
end

----- || LIBRARY || -----

function Library:Update()

	if not self.PrimaryPart then return self:Remove(); end;
	local color = self.ColorDynamic and self:ColorDynamic() or self.Color;

	local isEnabled = true;

	--[[if Callbacks.Overrides.UpdateAllow and not Callbacks.Overrides.UpdateAllow(self) then
		isEnabled = false;
	end;]]--

	if self.Player and not Callbacks.TeamMates and Methods:IsTeamMate(self.Player) then
		isEnabled = false;
	end;

	if self.Player and not Callbacks.Players then
		isEnabled = false;
	end;

	if self.IsEnabled and (typeof(self.IsEnabled) == "string" and not Callbacks[self.IsEnabled] or typeof(self.IsEnabled) == "function" and not self:IsEnabled()) then
		isEnabled = false
	end

	if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then
		isEnabled = false;
	end;

	if not isEnabled then

		for _, v in pairs(self.Components) do
			v.Visible = false;
		end;

		return;
	end;

	--| @ Calculations

	local CF = self.PrimaryPart.CFrame;

	if Callbacks.FaceCamera then
		CF = CFrame.new(CF.Position, currentCam.CFrame.Position);
	end;

	local locs = {

		TopLeft = CF * Callbacks.BoxShift * CFrame.new(self.Size.X / 2, self.Size.Y / 2, 0),
		TopRight = CF * Callbacks.BoxShift * CFrame.new(-self.Size.X / 2, self.Size.Y / 2, 0),

		BottomLeft = CF * Callbacks.BoxShift * CFrame.new(self.Size.X / 2, -self.Size.Y / 2, 0),
		BottomRight = CF * Callbacks.BoxShift * CFrame.new(-self.Size.X / 2, -self.Size.Y / 2, 0),

		TagPos = CF * Callbacks.BoxShift * CFrame.new(0, self.Size.Y / 2, 0),
		Torso = CF * Callbacks.BoxShift
	};

	if Callbacks.Boxes then

		local TopLeft, Vis1 = WorldToViewportPoint(currentCam, locs.TopLeft.Position);
		local TopRight, Vis2 = WorldToViewportPoint(currentCam, locs.TopRight.Position);

		local BottomLeft, Vis3 = WorldToViewportPoint(currentCam, locs.BottomLeft.Position);
		local BottomRight, Vis4 = WorldToViewportPoint(currentCam, locs.BottomRight.Position);

		if self.Components.Quad then

			if Vis1 or Vis2 or Vis3 or Vis4 then

				self.Components.Quad.Visible = true;

				self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y);
				self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y);

				self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y);
				self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y);

				self.Components.Quad.Color = Callbacks.RainbowMode and rainbow_color or self.RainbowColor and rainbow_color or color;

			else

				self.Components.Quad.Visible = false;
			end;
		end;

	else

		self.Components.Quad.Visible = false;
	end;

	if Callbacks.Names then

		local TagPos, Vis5 = WorldToViewportPoint(currentCam, locs.TagPos.Position);

		if Vis5 then

			self.Components.Name.Visible = true;
			self.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y);

			self.Components.Name.Text = self.Name;
			self.Components.Name.Color = Callbacks.RainbowMode and rainbow_color or self.RainbowColor and rainbow_color or color;

		else

			self.Components.Name.Visible = false;
		end;

	else

		self.Components.Name.Visible = false;
	end;

	if Callbacks.Distance then

		local TagPos, Vis5 = WorldToViewportPoint(currentCam, locs.TagPos.Position);

		if Vis5 then

			self.Components.Distance.Visible = true;
			self.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 14);

			self.Components.Distance.Text = math.floor((currentCam.CFrame.Position - CF.Position).magnitude) .."m away";
			self.Components.Distance.Color = Callbacks.RainbowMode and rainbow_color or self.RainbowColor and rainbow_color or color;

		else

			self.Components.Distance.Visible = false;
		end;

	else

		self.Components.Distance.Visible = false;
	end;

	if Callbacks.Tracers then

		local TorsoPos, Vis6 = WorldToViewportPoint(currentCam, locs.Torso.Position);

		if Vis6 then

			self.Components.Tracer.Visible = true;
			self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y);

			self.Components.Tracer.To = Vector2.new(currentCam.ViewportSize.X / 2, currentCam.ViewportSize.Y / Callbacks.AttachShift);
			self.Components.Tracer.Color = Callbacks.RainbowMode and rainbow_color or self.RainbowColor and rainbow_color or color;

		else

			self.Components.Tracer.Visible = false;
		end;

	else

		self.Components.Tracer.Visible = false;
	end;
end

function Library:Remove()

	Callbacks.Objects[self.Object] = nil;

	for i, v in pairs(self.Components) do

		v.Visible = false;
		v:Remove();

		self.Components[i] = nil;
	end;
end;

----- || CALLBACKS || -----

function Callbacks:Toggle(bool)

	self.Enabled = bool;
	if bool then return end;

	for _, v in pairs(self.Objects) do

		if v.Temporary then v:Remove() continue end;

		for _, b in pairs(v.Components) do
			b.Visible = false;
		end;
	end;
end;

function Callbacks:GetESP(obj)
	return self.Objects[obj];
end;

function Callbacks:Add(obj, options)

	--assert(not obj.Parent and not options.RenderInNil, tostring(obj) .. " has not a valid parent, current parent: " .. tostring(obj:GetFullName()))

	local box = setmetatable({

		Name = options.Name or obj.Name,
		Object = obj, Type = "Box",

		Color = options.Color or (options.Player or players:GetPlayerFromCharacter(obj)) and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(255, 255, 255) --[[or self:GetColor(obj)]],
		Size = options.Size or Vector3.new(4, 6, 0),

		Player = options.Player or players:GetPlayerFromCharacter(obj),
		PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,

		Group = options.Group,
		Components = {},

		RainbowColor = options.RainbowColor,
		AutoRemove = options.AutoRemove,

		IsEnabled = options.IsEnabled,
		Temporary = options.Temporary,

		ColorDynamic = options.ColorDynamic,
		RenderInNil = options.RenderInNil

	}, Library);

	if self:GetESP(obj) then self:GetESP(obj):Remove(); end;

	box.Components["Quad"] = Methods:Draw("Quad", {

		Thickness = 2,
		Color = box.Color,

		Transparency = 1,
		Filled = false,

		Visible = self.Enabled and self.Boxes
	});

	box.Components["Name"] = Methods:Draw("Text", {

		Text = box.Name,
		Color = box.Color,

		Center = true,
		Outline = true,

		Size = 20,
		Visible = self.Enabled and self.Names
	});

	box.Components["Distance"] = Methods:Draw("Text", {

		Color = box.Color,

		Center = true,
		Outline = true,

		Size = 20,
		Visible = self.Enabled and self.Distance
	});

	box.Components["Tracer"] = Methods:Draw("Line", {

		Thickness = 2,
		Color = box.Color,

		Transparency = 1,
		Visible = self.Enabled and self.Tracers
	});

	self.Objects[obj] = box;

	if options.Group then

		local group = self.Groups[options.Group];
		table.insert(group.Objects, box);
	end;

	SignalManager:AddSignal(obj.AncestryChanged, function(_, parent)
		if parent == nil and box.AutoRemove then
			box:Remove();
		end;
	end);

	SignalManager:AddSignal(obj:GetPropertyChangedSignal("Parent"), function()
		if obj.Parent == nil and box.AutoRemove then
			box:Remove();
		end;
	end);

	local hum = obj:FindFirstChildOfClass("Humanoid");

	if obj:FindFirstChildOfClass("Humanoid") then

		SignalManager:AddSignal(obj:FindFirstChildOfClass("Humanoid").Died, function()
			if box.AutoRemove then box:Remove() end;
		end);
	end;

	return box;
end;

function Callbacks:AddObjectListener(parent, options)

	local function NewListener(obj)

		if type(options.Name) == "string" and (tostring(obj) == options.Name or options.Name == nil) and (not options.Validator or options.Validator(obj)) then

			local box = Callbacks:Add(obj, {

				PrimaryPart = type(options.PrimaryPart) == "string" and obj:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(obj),
				Color = type(options.Color) == "function" and options.Color(obj) or options.Color,

				ColorDynamic = options.ColorDynamic,
				Name = type(options.CustomName) == "function" and options.CustomName(obj) or options.CustomName,

				Group = options.Group,

				IsEnabled = options.IsEnabled,
				RenderInNil = options.RenderInNil;
			});

			if options.OnAdded then coroutine.wrap(options.OnAdded)(box); end;
		end;
	end;

	if options.Recursive then

		SignalManager:AddSignal(parent.DescendantAdded, NewListener);

		for _, v in pairs(parent:GetDescendants()) do
			coroutine.wrap(NewListener)(v);
		end;

	else

		SignalManager:AddSignal(parent.ChildAdded, NewListener);

		for _, v in pairs(parent:GetChildren()) do
			coroutine.wrap(NewListener)(v);
		end;
	end;
end;

function Callbacks:RemoveAll()

	for _, v in pairs(self.Objects) do
		if v and v.Remove then v:Remove(); end;
	end;

	table.clear(self.Objects);

	for _, v in pairs(self.Groups) do
		if v and v.Objects then table.clear(v.Objects); end;
	end;
end;

local function onCharAdded(char)

	local player = players:GetPlayerFromCharacter(char);

	if not char:FindFirstChild("HumanoidRootPart") then

		local conn;

		conn = SignalManager:AddSignal(char.ChildAdded, function(child)

			if tostring(child) ~= "HumanoidRootPart" then return; end;
			conn:Disconnect();

			Callbacks:Add(char, {

				Name = tostring(player),
				Player = player,

				PrimaryPart = child
			});
		end);

		return;
	end;

	Callbacks:Add(char, {

		Name = tostring(player),
		Player = player,

		Group = "players",
		PrimaryPart = char.HumanoidRootPart
	});
end;

local function onPlayerAdded(player)

	SignalManager:AddSignal(player.CharacterAdded, onCharAdded);
	if player.Character then coroutine.wrap(onCharAdded)(player.Character); end;
end;

for _, v in pairs(players:GetPlayers()) do
	if v ~= players.LocalPlayer then onPlayerAdded(v); end;
end;

SignalManager:AddSignal(players.PlayerAdded, onPlayerAdded);

SignalManager:AddSignal(RunService.RenderStepped, function()

	currentCam = workspace.CurrentCamera;

	for _, v in (Callbacks.Enabled and pairs or ipairs)(Callbacks.Objects) do

		if not v.Update then continue; end;

		local __s, __e = pcall(v.Update, v);
		if not __s then warn("[EU]", __e, v.Object:GetFullName()) end;
	end;
end);

coroutine.resume(coroutine.create(function()
	while task.wait() do
		rainbow_color = Color3.fromHSV((tick() % Callbacks.ColorTickSpeed) / Callbacks.ColorTickSpeed, 1, 1);
	end;
end));

----- || RETURN || -----

return Callbacks;
