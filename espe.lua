local ESPFonts = { }
local SelectedESPFont

local Options, MiscOptions do
	if getgenv().Esp and getgenv().Esp.Unload then
		getgenv().Esp.Unload()
	end

	local Workspace = cloneref(game:GetService("Workspace"))
	local RunService = cloneref(game:GetService("RunService"))
	local HttpService = cloneref(game:GetService("HttpService"))
	local Players = cloneref(game:GetService("Players"))
	local TweenService = cloneref(game:GetService("TweenService"))

	local vec2 = Vector2.new
	local vec3 = Vector3.new
	local dim2 = UDim2.new
	local dim = UDim.new
	local rect = Rect.new
	local cfr = CFrame.new
	local empty_cfr = cfr()
	local angle = CFrame.Angles
	local dim_offset = UDim2.fromOffset

	local rgb = Color3.fromRGB
	local hex = Color3.fromHex
	local hsv = Color3.fromHSV
	local rgbseq = ColorSequence.new
	local rgbkey = ColorSequenceKeypoint.new
	local numseq = NumberSequence.new
	local numkey = NumberSequenceKeypoint.new
	local camera = Workspace.CurrentCamera
	local WorldToViewportPoint = camera.WorldToViewportPoint

	local math_floor = math.floor
	local math_max = math.max 
	local math_min = math.min
	local math_abs = math.abs
	local math_clamp = math.clamp
	local math_round = math.round
	local math_cos = math.cos
	local math_sin = math.sin
	local math_rad = math.rad
	local math_tan = math.tan
	local math_pi = math.pi
	local TWO_PI = math_pi * 2
	local tick = tick
	local tostring = tostring
	local pcall = pcall
	local type = type
	local rawset = rawset
	local table_create = table.create
	local Drawing_new = Drawing.new
	local Instance_new = Instance.new

	local CH_BRIM_OFFSET = vec3(0, 0.6, 0)
	local WHITE = Color3.new(1, 1, 1)

	local Bones = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"},
	{"UpperTorso", "RightUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"},
	{"RightUpperArm", "RightLowerArm"},
	{"LeftLowerArm", "LeftHand"},
	{"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"},
	{"LowerTorso", "RightUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"},
	{"RightUpperLeg", "RightLowerLeg"},
	{"LeftLowerLeg", "LeftFoot"},
	{"RightLowerLeg", "RightFoot"},
	}

	local R6Bones = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Torso", "Right Arm"},
	{"Torso", "Left Leg"},
	{"Torso", "Right Leg"},
	}

	MiscOptions = {
	["Enabled"] = true;

	-- Visible Check
	["VisibleCheck"] = true; -- bool (raycast to see if player is behind a wall)
	["Hidden_Color"] = { Color = rgb(255, 50, 50) }; -- {Color} (overrides all colors when player is hidden)
	["MaxDistance"] = 2500; -- number (studs, players beyond this distance are hidden)

	-- Boxes
	["Boxes"] = true;
	["BoxType"] = "Box"; -- "Corner" | "Box" | "Image" (charliekirk style)
	["Box Gradient 1"] = { Color = rgb(255, 255, 255), Transparency = 0.9 };
	["Box Gradient 2"] = { Color = rgb(255, 255, 255), Transparency = 0.9 };
	["Box Gradient Rotation"] = 90;
	["Box Gradient Moving"] = true; -- bool (auto-rotates box outline gradient)
	["Box Gradient Speed"] = 120; -- number (degrees per second)
	["Box Fill"] = true;
	["Box Fill 1"] = { Color = rgb(255, 0, 0), Transparency = 0.7 };
	["Box Fill 2"] = { Color = rgb(0, 0, 0), Transparency = 0.4 };
	["Box Fill Rotation"] = 90;
	["Box Fill Moving"] = true; -- bool (auto-rotates box fill gradient)
	["Box Fill Speed"] = 180; -- number (degrees per second)

	["Healthbar"] = true;
	["Healthbar_Position"] = "Left";
	["Healthbar_Number"] = true;
	["Healthbar_Low"] = { Color = rgb(255, 0, 0), Transparency = 1};
	["Healthbar_Medium"] = { Color = rgb(255, 153, 0), Transparency = 1};
	["Healthbar_Animations"] = true;
	["Healthbar_High"] = { Color = rgb(0, 255, 13), Transparency = 1};
	["Healthbar_Font"] = "Verdana";
	["Healthbar_Text_Size"] = 11;
	["Healthbar_Thickness"] = 1;
	["Healthbar_Tween"] = true;
	["Healthbar_EasingStyle"] = "Circular";
	["Healthbar_EasingDirection"] = "InOut";
	["Healthbar_Easing_Speed"] = 1;

	-- Text Based Elements
	["Name_Text"] = true;
	["Name_Text_Color"] = { Color = rgb(255, 255, 255) };
	["Name_Text_Position"] = "Top";
	["Name_Text_Font"] = "SmallestPixel";
	["Name_Text_Size"] = 11;

	["Distance_Text"] = true;
	["Distance_Text_Color"] = { Color = rgb(255, 255, 255) };
	["Distance_Text_Position"] = "Bottom";
	["Distance_Text_Font"] = "SmallestPixel";
	["Distance_Text_Size"] = 11;

	-- Weapon / Tool ESP
	["Weapon_ESP"] = true;
	["Weapon_ESP_Style"] = "Text"; -- "Text" | "Icon+Text"
	["Weapon_ESP_Position"] = "Left"; -- "Left" | "Right" | "Top" | "Bottom"
	["Weapon_ESP_Color"] = { Color = rgb(255, 255, 255) };
	["Weapon_ESP_Size"] = 48; -- ViewportFrame size for icon (Icon+Text only)

	-- Skeleton
	["Skeleton"] = false;
	["Skeleton_Color"] = { Color = rgb(150, 50, 255) };
	["Skeleton_Thickness"] = 1.5;
	["Skeleton_Outline"] = true; -- bool (black stroke behind each bone)
	["Skeleton_Outline_Color"] = { Color = rgb(0, 0, 0) }; -- {Color}
	["Skeleton_Outline_Thickness"] = 4; -- number

	-- Head Circle
	["HeadCircle"] = false; -- bool
	["HeadCircle_Color"] = { Color = rgb(150, 50, 255) }; -- {Color}
	["HeadCircle_Style"] = "Circle"; -- "Circle" | "Hexagon"
	["HeadCircle_Thickness"] = 1.5; -- number
	["HeadCircle_Radius"] = 1.0; -- number (world-space head radius multiplier)
	["HeadCircle_Filled"] = false; -- bool
	["HeadCircle_Outline"] = true; -- bool (black stroke behind circle)
	["HeadCircle_Outline_Color"] = { Color = rgb(0, 0, 0) }; -- {Color}
	["HeadCircle_Outline_Thickness"] = 3.5; -- number

	-- China Hat (3D conical hat projected to screen)
	["ChinaHat"] = false; -- bool
	["ChinaHat_Color"] = { Color = rgb(150, 50, 255) }; -- {Color}
	["ChinaHat_Thickness"] = 1.5; -- number
	["ChinaHat_Segments"] = 10; -- number (ring subdivisions, 8-64)
	["ChinaHat_Radius"] = 1.6; -- number (world-space brim radius)
	["ChinaHat_Height"] = 0.9; -- number (world-space cone height above head)
	["ChinaHat_Outline"] = true; -- bool (black stroke behind ring + spokes)
	["ChinaHat_Outline_Color"] = { Color = rgb(0, 0, 0) }; -- {Color}
	["ChinaHat_Outline_Thickness"] = 3; -- number

	-- Chams (Highlight)
	["Chams"] = false;
	["Chams_Fill_Color"] = { Color = rgb(120, 50, 200) };
	["Chams_Fill_Transparency"] = 0.5;
	["Chams_Outline_Color"] = { Color = rgb(180, 100, 255) };
	["Chams_Outline_Transparency"] = 0;
	["Chams_DepthMode"] = "AlwaysOnTop";

	-- Breadcrumbs
	["Breadcrumbs"] = false;
	["Breadcrumbs_Color"] = { Color = rgb(150, 50, 255) };
	["Breadcrumbs_Style"] = "";
	["Breadcrumbs_Thickness"] = 1.5;
	["Breadcrumbs_Size"] = 3;
	["Breadcrumbs_Lifetime"] = 3;
	["Breadcrumbs_Interval"] = 0.15;
	["Breadcrumbs_Fade"] = true;
	};

	Options = setmetatable({}, {__index = MiscOptions, __newindex = function(self, key, value) MiscOptions[key] = value Esp.RefreshElements(key, value) end});

	local InterFont = Font.new("rbxasset://fonts/families/Inter.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	local CustomFont = InterFont

	pcall(function()
	local fontUrl = "https://raw.githubusercontent.com/i77lhm/storage/refs/heads/main/fonts/smallest_pixel-7.ttf"
	if not isfile("smallest_pixel-7.ttf") then
		writefile("smallest_pixel-7.ttf", game:HttpGet(fontUrl))
	end
	local ttfAsset = getcustomasset("smallest_pixel-7.ttf")
	local familyJson = '{"name":"SmallestPixel","faces":[{"name":"Regular","weight":400,"style":"normal","assetId":"' .. ttfAsset .. '"}]}'
	writefile("SmallestPixel_family.json", familyJson)
	CustomFont = Font.new(getcustomasset("SmallestPixel_family.json"))
end)

local Fonts = setmetatable({}, {
__index = function(_, _)
return CustomFont
end
})
Fonts.ProggyClean = CustomFont
Fonts.Tahoma = CustomFont
Fonts.Verdana = CustomFont
Fonts.SmallestPixel = CustomFont
Fonts.ProggyTiny = CustomFont
Fonts.Minecraftia = CustomFont
Fonts["Tahoma Bold"] = CustomFont

local EspRayParams = RaycastParams.new()
EspRayParams.FilterType = Enum.RaycastFilterType.Exclude
EspRayParams.IgnoreWater = true

local Esp = {
Players = {},
PlayersList = {}, -- flat array for O(1) iteration, synced with Players
ScreenGui = Instance.new("ScreenGui", gethui()),
Cache = Instance.new("ScreenGui", gethui()),
Connections = {},
_frameIndex = 0,
}
getgenv().Esp = Esp; do
	Esp.ScreenGui.IgnoreGuiInset = true
	Esp.ScreenGui.Name = "EspObject"

	Esp.Cache.Enabled = false

	function Esp:Create(instance, options)
		local Ins = Instance.new(instance)

		for prop, value in options do
			Ins[prop] = value
		end

		return Ins
	end

	function Esp:Connection(signal, callback)
		local Connection = signal:Connect(callback)
		Esp.Connections[#Esp.Connections + 1] = Connection

		return Connection
	end

	function Esp:Lerp(start, finish, t)
		t = t or 1 / 8

		return start * (1 - t) + finish * t
	end

	function Esp:Tween(Object, Properties, Info)
		local tween = TweenService:Create(Object, Info, Properties)
		tween:Play()

		return tween
	end

	function Esp.CreateObject( player, typechar )
		local Data = {
		Items = { },
		Info = {Character; Humanoid; Health = 0};
		Drawings = { },
		Type = typechar or "player"
		}

		local Items = Data.Items
		local Drawings = Data.Drawings

		do
			-- Holder
			Items.Holder = Esp:Create( "Frame" , {
			Parent = Esp.ScreenGui;
			Name = "\0";
			BackgroundTransparency = 1;
			Position = dim2(0.4332570433616638, 0, 0.3255814015865326, 0);
			BorderColor3 = rgb(0, 0, 0);
			Size = dim2(0, 211, 0, 240);
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Items.HolderGradient = Esp:Create( "UIGradient" , {
			Rotation = 0;
			Name = "\0";
			Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(255, 255, 255))};
			Parent = Items.Holder;
			Enabled = true
			});

			-- Directions
			Items.Left = Esp:Create( "Frame" , {
			Parent = Items.Holder;
			Size = dim2(0, 0, 1, 0);
			Name = "\0";
			BackgroundTransparency = 1;
			Position = dim2(0, -1, 0, 0);
			BorderColor3 = rgb(0, 0, 0);
			ZIndex = 2;
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Items.HealthbarTextsLeft = Esp:Create( "Frame", {
			Visible = true;
			BorderColor3 = rgb(0, 0, 0);
			Parent = Esp.Cache;
			Name = "\0";
			BackgroundTransparency = 1;
			LayoutOrder = -100;
			BorderSizePixel = 0;
			ZIndex = 0;
			AutomaticSize = Enum.AutomaticSize.X;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout" , {
			FillDirection = Enum.FillDirection.Horizontal;
			HorizontalAlignment = Enum.HorizontalAlignment.Right;
			VerticalFlex = Enum.UIFlexAlignment.Fill;
			Parent = Items.Left;
			Padding = dim(0, 1);
			SortOrder = Enum.SortOrder.LayoutOrder
			});

			Items.LeftTexts = Esp:Create( "Frame" , {
			LayoutOrder = -100;
			Parent = Items.Left;
			BackgroundTransparency = 1;
			Name = "\0";
			BorderColor3 = rgb(0, 0, 0);
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.X;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout" , {
			Parent = Items.LeftTexts;
			Padding = dim(0, 1);
			SortOrder = Enum.SortOrder.LayoutOrder
			});

			Items.Bottom = Esp:Create( "Frame" , {
			Parent = Items.Holder;
			Size = dim2(1, 0, 0, 0);
			Name = "\0";
			BackgroundTransparency = 1;
			Position = dim2(0, 0, 1, 1);
			BorderColor3 = rgb(0, 0, 0);
			ZIndex = 2;
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout" , {
			SortOrder = Enum.SortOrder.LayoutOrder;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			HorizontalFlex = Enum.UIFlexAlignment.Fill;
			Parent = Items.Bottom;
			Padding = dim(0, 1)
			});

			Items.BottomTexts = Esp:Create( "Frame", {
			LayoutOrder = 1;
			Parent = Items.Bottom;
			BackgroundTransparency = 1;
			Name = "\0";
			BorderColor3 = rgb(0, 0, 0);
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.XY;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout", {
			Parent = Items.BottomTexts;
			Padding = dim(0, 1);
			SortOrder = Enum.SortOrder.LayoutOrder
			});

			Items.Top = Esp:Create( "Frame" , {
			Parent = Items.Holder;
			Size = dim2(1, 0, 0, 0);
			Name = "\0";
			BackgroundTransparency = 1;
			Position = dim2(0, 0, 0, -1);
			BorderColor3 = rgb(0, 0, 0);
			ZIndex = 2;
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout" , {
			VerticalAlignment = Enum.VerticalAlignment.Bottom;
			SortOrder = Enum.SortOrder.LayoutOrder;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			HorizontalFlex = Enum.UIFlexAlignment.Fill;
			Parent = Items.Top;
			Padding = dim(0, 1)
			});

			Items.TopTexts = Esp:Create( "Frame", {
			LayoutOrder = -100;
			Parent = Items.Top;
			BackgroundTransparency = 1;
			Name = "\0";
			BorderColor3 = rgb(0, 0, 0);
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.XY;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout", {
			Parent = Items.TopTexts;
			Padding = dim(0, 1);
			SortOrder = Enum.SortOrder.LayoutOrder
			});

			Items.Right = Esp:Create( "Frame" , {
			Parent = Esp.Cache;
			Size = dim2(0, 0, 1, 0);
			Name = "\0";
			BackgroundTransparency = 1;
			Position = dim2(1, 1, 0, 0);
			BorderColor3 = rgb(0, 0, 0);
			ZIndex = 2;
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout" , {
			FillDirection = Enum.FillDirection.Horizontal;
			VerticalFlex = Enum.UIFlexAlignment.Fill;
			Parent = Items.Right;
			Padding = dim(0, 1);
			SortOrder = Enum.SortOrder.LayoutOrder
			});

			Items.RightTexts = Esp:Create( "Frame" , {
			LayoutOrder = 100;
			Parent = Items.Right;
			BackgroundTransparency = 1;
			Name = "\0";
			BorderColor3 = rgb(0, 0, 0);
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.X;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout" , {
			Parent = Items.RightTexts;
			Padding = dim(0, 1);
			SortOrder = Enum.SortOrder.LayoutOrder
			});

			Items.HealthbarTextsRight = Esp:Create( "Frame", {
			Visible = true;
			BorderColor3 = rgb(0, 0, 0);
			Parent = Esp.Cache;
			Name = "\0";
			BackgroundTransparency = 1;
			LayoutOrder = 99;
			BorderSizePixel = 0;
			ZIndex = 0;
			AutomaticSize = Enum.AutomaticSize.X;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			-- Corner Boxes
			Items.Corners = Esp:Create( "Frame", {
			Parent = Esp.Cache;
			Name = "\0";
			BackgroundTransparency = 1;
			BorderColor3 = rgb(0, 0, 0);
			Size = dim2(1, 0, 1, 0);
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Items.BottomLeftX = Esp:Create( "ImageLabel", {
			ScaleType = Enum.ScaleType.Slice;
			Parent = Items.Corners;
			BorderColor3 = rgb(0, 0, 0);
			Name = "\0";
			BackgroundColor3 = rgb(255, 255, 255);
			Size = dim2(0.4, 0, 0, 3);
			AnchorPoint = vec2(0, 1);
			Image = "rbxassetid://83548615999411";
			BackgroundTransparency = 1;
			Position = dim2(0, 0, 1, 0);
			ZIndex = 2;
			BorderSizePixel = 0;
			SliceCenter = rect(vec2(1, 1), vec2(99, 2))
			});

			Esp:Create( "UIGradient", {
			Parent = Items.BottomLeftX
			});

			Items.BottomLeftY = Esp:Create( "ImageLabel", {
			ScaleType = Enum.ScaleType.Slice;
			Parent = Items.Corners;
			BorderColor3 = rgb(0, 0, 0);
			Name = "\0";
			BackgroundColor3 = rgb(255, 255, 255);
			Size = dim2(0, 3, 0.25, 0);
			AnchorPoint = vec2(0, 1);
			Image = "rbxassetid://101715268403902";
			BackgroundTransparency = 1;
			Position = dim2(0, 0, 1, -2);
			ZIndex = 500;
			BorderSizePixel = 0;
			SliceCenter = rect(vec2(1, 0), vec2(2, 96))
			});

			Esp:Create( "UIGradient", {
			Rotation = -90;
			Parent = Items.BottomLeftY
			});

			Items.BottomRighX = Esp:Create( "ImageLabel", {
			ScaleType = Enum.ScaleType.Slice;
			Parent = Items.Corners;
			BorderColor3 = rgb(0, 0, 0);
			Name = "\0";
			BackgroundColor3 = rgb(255, 255, 255);
			Size = dim2(0.4, 0, 0, 3);
			AnchorPoint = vec2(1, 1);
			Image = "rbxassetid://83548615999411";
			BackgroundTransparency = 1;
			Position = dim2(1, 0, 1, 0);
			ZIndex = 2;
			BorderSizePixel = 0;
			SliceCenter = rect(vec2(1, 1), vec2(99, 2))
			});

			Esp:Create( "UIGradient", {
			Parent = Items.BottomRighX
			});

			Items.BottomLeftY = Esp:Create( "ImageLabel", {
			ScaleType = Enum.ScaleType.Slice;
			Parent = Items.Corners;
			BorderColor3 = rgb(0, 0, 0);
			Name = "\0";
			BackgroundColor3 = rgb(255, 255, 255);
			Size = dim2(0, 3, 0.25, 0);
			AnchorPoint = vec2(1, 1);
			Image = "rbxassetid://101715268403902";
			BackgroundTransparency = 1;
			Position = dim2(1, 0, 1, -2);
			ZIndex = 500;
			BorderSizePixel = 0;
			SliceCenter = rect(vec2(1, 0), vec2(2, 96))
			});

			Esp:Create( "UIGradient", {
			Rotation = 90;
			Parent = Items.BottomLeftY
			});

			Items.TopLeftY = Esp:Create( "ImageLabel", {
			ScaleType = Enum.ScaleType.Slice;
			BorderColor3 = rgb(0, 0, 0);
			Parent = Items.Corners;
			Name = "\0";
			BackgroundColor3 = rgb(255, 255, 255);
			Size = dim2(0, 3, 0.25, 0);
			Image = "rbxassetid://102467475629368";
			BackgroundTransparency = 1;
			Position = dim2(0, 0, 0, 2);
			ZIndex = 500;
			BorderSizePixel = 0;
			SliceCenter = rect(vec2(1, 0), vec2(2, 98))
			});

			Esp:Create( "UIGradient", {
			Rotation = 90;
			Parent = Items.TopLeftY
			});

			Items.TopRightY = Esp:Create( "ImageLabel", {
			ScaleType = Enum.ScaleType.Slice;
			Parent = Items.Corners;
			BorderColor3 = rgb(0, 0, 0);
			Name = "\0";
			BackgroundColor3 = rgb(255, 255, 255);
			Size = dim2(0, 3, 0.25, 0);
			AnchorPoint = vec2(1, 0);
			Image = "rbxassetid://102467475629368";
			BackgroundTransparency = 1;
			Position = dim2(1, 0, 0, 2);
			ZIndex = 500;
			BorderSizePixel = 0;
			SliceCenter = rect(vec2(1, 0), vec2(2, 98))
			});

			Esp:Create( "UIGradient", {
			Rotation = -90;
			Parent = Items.TopRightY
			});

			Items.TopRightX = Esp:Create( "ImageLabel", {
			ScaleType = Enum.ScaleType.Slice;
			Parent = Items.Corners;
			BorderColor3 = rgb(0, 0, 0);
			Name = "\0";
			BackgroundColor3 = rgb(255, 255, 255);
			Size = dim2(0.4, 0, 0, 3);
			AnchorPoint = vec2(1, 0);
			Image = "rbxassetid://83548615999411";
			BackgroundTransparency = 1;
			Position = dim2(1, 0, 0, 0);
			ZIndex = 2;
			BorderSizePixel = 0;
			SliceCenter = rect(vec2(1, 1), vec2(99, 2))
			});

			Esp:Create( "UIGradient", {
			Parent = Items.TopRightX
			});

			Items.TopLeftX = Esp:Create( "ImageLabel", {
			ScaleType = Enum.ScaleType.Slice;
			BorderColor3 = rgb(0, 0, 0);
			Parent = Items.Corners;
			Name = "\0";
			BackgroundColor3 = rgb(255, 255, 255);
			Image = "rbxassetid://83548615999411";
			BackgroundTransparency = 1;
			Size = dim2(0.4, 0, 0, 3);
			ZIndex = 2;
			BorderSizePixel = 0;
			SliceCenter = rect(vec2(1, 1), vec2(99, 2))
			});

			Esp:Create( "UIGradient", {
			Parent = Items.TopLeftX
			});

			-- Image Box (charliekirk style)
			Items.ImageBox = Esp:Create( "ImageLabel", {
			Parent = Esp.Cache;
			Name = "\0";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			ScaleType = Enum.ScaleType.Slice;
			SliceCenter = rect(vec2(20, 20), vec2(80, 80));
			Image = "rbxassetid://129251711080353";
			Size = dim2(1, 0, 1, 0);
			Position = dim2(0, 0, 0, 0);
			BorderColor3 = rgb(0, 0, 0);
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIGradient", {
			Parent = Items.ImageBox
			});

			-- Normal Box
			Items.Box = Esp:Create( "Frame" , {
			Parent = Esp.Cache;
			Name = "\0";
			BackgroundTransparency = 0.8500000238418579;
			Position = dim2(0, 1, 0, 1);
			BorderColor3 = rgb(0, 0, 0);
			Size = dim2(1, -2, 1, -2);
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIStroke" , {
			Parent = Items.Box;
			LineJoinMode = Enum.LineJoinMode.Miter
			});

			Items.Inner = Esp:Create( "Frame" , {
			Parent = Items.Box;
			Name = "\0";
			BackgroundTransparency = 1;
			Position = dim2(0, 1, 0, 1);
			BorderColor3 = rgb(0, 0, 0);
			Size = dim2(1, -2, 1, -2);
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Items.UIStroke = Esp:Create( "UIStroke" , {
			Color = rgb(255, 255, 255);
			LineJoinMode = Enum.LineJoinMode.Miter;
			Parent = Items.Inner
			});

			Items.BoxGradient = Esp:Create( "UIGradient" , {
			Parent = Items.UIStroke
			});

			Items.Inner2 = Esp:Create( "Frame" , {
			Parent = Items.Inner;
			Name = "\0";
			BackgroundTransparency = 1;
			Position = dim2(0, 1, 0, 1);
			BorderColor3 = rgb(0, 0, 0);
			Size = dim2(1, -2, 1, -2);
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIStroke" , {
			Parent = Items.Inner2;
			LineJoinMode = Enum.LineJoinMode.Miter
			});

			-- Healthbar
			Items.Healthbar = Esp:Create( "Frame" , {
			Name = "Left";
			Parent = Esp.Cache;
			BorderColor3 = rgb(0, 0, 0);
			Size = dim2(0, 3, 0, 3);
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(0, 0, 0)
			});

			Items.HealthbarAccent = Esp:Create( "Frame" , {
			Parent = Items.Healthbar;
			Name = "\0";
			Position = dim2(0, 1, 0, 1);
			BorderColor3 = rgb(0, 0, 0);
			Size = dim2(1, -2, 1, -2);
			BorderSizePixel = 0;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Items.HealthbarGradient = Esp:Create( "UIGradient" , {
			Enabled = true;
			Parent = Items.HealthbarAccent;
			Rotation = 90;
			Color = rgbseq{rgbkey(0, rgb(0, 255, 0)), rgbkey(0.5, rgb(255, 125, 0)), rgbkey(1, rgb(255, 0, 0))}
			});

			Items.HealthbarText = Esp:Create( "TextLabel", {
			FontFace = Fonts.ProggyClean;
			TextColor3 = rgb(255, 255, 255);
			BorderColor3 = rgb(0, 0, 0);
			Parent = Esp.Cache;
			Name = "\0";
			BackgroundTransparency = 1;
			Size = dim2(0, 0, 0, 0);
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.XY;
			TextSize = 12;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIStroke", {
			Parent = Items.HealthbarText;
			LineJoinMode = Enum.LineJoinMode.Miter
			});

			-- Texts
			Items.Text = Esp:Create( "TextLabel", {
			FontFace = Fonts.ProggyClean;
			TextColor3 = rgb(255, 255, 255);
			BorderColor3 = rgb(0, 0, 0);
			Parent = Esp.Cache;
			Name = "Left";
			Text = player.Name;
			BackgroundTransparency = 1;
			Size = dim2(1, 0, 0, 0);
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.XY;
			TextSize = 9;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIStroke", {
			Parent = Items.Text;
			LineJoinMode = Enum.LineJoinMode.Miter
			});

			Items.Distance = Esp:Create( "TextLabel", {
			FontFace = Fonts.ProggyClean;
			TextColor3 = rgb(255, 255, 255);
			BorderColor3 = rgb(0, 0, 0);
			Parent = Esp.Cache;
			Name = "Left";
			BackgroundTransparency = 1;
			Size = dim2(1, 0, 0, 0);
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.XY;
			TextSize = 9;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIStroke", {
			Parent = Items.Distance;
			LineJoinMode = Enum.LineJoinMode.Miter
			});

			-- Weapon / Tool ESP
			Items.WeaponFrame = Esp:Create( "Frame", {
			Name = "Weapon";
			BackgroundTransparency = 1;
			Size = dim2(0, 1, 0, 1);
			BorderSizePixel = 0;
			LayoutOrder = 50;
			Parent = Esp.Cache;
			AutomaticSize = Enum.AutomaticSize.XY;
			BorderColor3 = rgb(0, 0, 0);
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal;
			VerticalAlignment = Enum.VerticalAlignment.Center;
			Padding = dim(0, 4);
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = Items.WeaponFrame
			});

			local vpSize = MiscOptions.Weapon_ESP_Size or 48
			Items.WeaponViewport = Esp:Create( "ViewportFrame", {
			Name = "WeaponIcon";
			Size = dim2(0, vpSize, 0, vpSize);
			LayoutOrder = 0;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Parent = Items.WeaponFrame
			});

			Items.WeaponCamera = Instance_new("Camera")
			Items.WeaponCamera.Parent = Items.WeaponViewport
			Items.WeaponViewport.CurrentCamera = Items.WeaponCamera

			Items.WeaponText = Esp:Create( "TextLabel", {
			FontFace = Fonts.ProggyClean;
			TextColor3 = rgb(255, 255, 255);
			BorderColor3 = rgb(0, 0, 0);
			Name = "WeaponName";
			Parent = Items.WeaponFrame;
			BackgroundTransparency = 1;
			Size = dim2(0, 1, 0, 1);
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.XY;
			TextSize = 9;
			Text = "";
			LayoutOrder = 1;
			BackgroundColor3 = rgb(255, 255, 255)
			});

			Esp:Create( "UIStroke", { Parent = Items.WeaponText; LineJoinMode = Enum.LineJoinMode.Miter })

			Drawings.Skeleton = {}
			Drawings.SkeletonOutline = {}
			local skelOLColor = (MiscOptions.Skeleton_Outline_Color and MiscOptions.Skeleton_Outline_Color.Color) or Color3.new(0,0,0)
			local skelOLThick = MiscOptions.Skeleton_Outline_Thickness or 4
			local skelMainColor = MiscOptions.Skeleton_Color.Color
			local skelMainThick = MiscOptions.Skeleton_Thickness
			for i = 1, #Bones do
				local ol = Drawing_new("Line")
				ol.Visible = false; ol.Color = skelOLColor; ol.Thickness = skelOLThick; ol.Transparency = 1
				Drawings.SkeletonOutline[i] = ol
				local line = Drawing_new("Line")
				line.Visible = false; line.Color = skelMainColor; line.Thickness = skelMainThick; line.Transparency = 1
				Drawings.Skeleton[i] = line
			end

			Drawings.ChinaHatRing = {}
			Drawings.ChinaHatSpokes = {}
			Drawings.ChinaHatRingOL = {}
			Drawings.ChinaHatSpokesOL = {}
			pcall(function()
			local chColor = MiscOptions.ChinaHat_Color.Color or WHITE
			local chThick = MiscOptions.ChinaHat_Thickness or 1.5
			local chOLColor = (MiscOptions.ChinaHat_Outline_Color and MiscOptions.ChinaHat_Outline_Color.Color) or Color3.new(0,0,0)
			local chOLThick = MiscOptions.ChinaHat_Outline_Thickness or 3
			local N = MiscOptions.ChinaHat_Segments or 10
			for i = 1, N do
				local ro = Drawing_new("Line"); ro.Visible = false; ro.Color = chOLColor; ro.Thickness = chOLThick; ro.Transparency = 1
				Drawings.ChinaHatRingOL[i] = ro
				local r = Drawing_new("Line"); r.Visible = false; r.Color = chColor; r.Thickness = chThick; r.Transparency = 1
				Drawings.ChinaHatRing[i] = r
				local so = Drawing_new("Line"); so.Visible = false; so.Color = chOLColor; so.Thickness = chOLThick; so.Transparency = 1
				Drawings.ChinaHatSpokesOL[i] = so
				local s = Drawing_new("Line"); s.Visible = false; s.Color = chColor; s.Thickness = chThick; s.Transparency = 1
				Drawings.ChinaHatSpokes[i] = s
			end
		end)

		local hcSides = MiscOptions.HeadCircle_Style == "Hexagon" and 6 or 24
		Drawings.HeadCircleOL = Drawing_new("Circle")
		Drawings.HeadCircleOL.Visible = false
		Drawings.HeadCircleOL.Color = (MiscOptions.HeadCircle_Outline_Color and MiscOptions.HeadCircle_Outline_Color.Color) or Color3.new(0,0,0)
		Drawings.HeadCircleOL.Thickness = MiscOptions.HeadCircle_Outline_Thickness or 3.5
		Drawings.HeadCircleOL.Filled = false; Drawings.HeadCircleOL.NumSides = hcSides; Drawings.HeadCircleOL.Transparency = 1

		Drawings.HeadCircle = Drawing_new("Circle")
		Drawings.HeadCircle.Visible = false
		Drawings.HeadCircle.Color = MiscOptions.HeadCircle_Color.Color
		Drawings.HeadCircle.Thickness = MiscOptions.HeadCircle_Thickness or 1.5
		Drawings.HeadCircle.Filled = MiscOptions.HeadCircle_Filled or false
		Drawings.HeadCircle.NumSides = hcSides; Drawings.HeadCircle.Transparency = 1

		Items.Highlight = Instance_new("Highlight")
		Items.Highlight.FillColor = MiscOptions.Chams_Fill_Color.Color
		Items.Highlight.FillTransparency = MiscOptions.Chams_Fill_Transparency
		Items.Highlight.OutlineColor = MiscOptions.Chams_Outline_Color.Color
		Items.Highlight.OutlineTransparency = MiscOptions.Chams_Outline_Transparency
		Items.Highlight.DepthMode = Enum.HighlightDepthMode[MiscOptions.Chams_DepthMode]
		Items.Highlight.Enabled = false
	end

	Data.ToolAdded = function()
	if not MiscOptions.Weapon_ESP then
		Items.WeaponFrame.Parent = Esp.Cache
		return
	end

	local char = Data.Info.Character
	local currentTool = char and char:FindFirstChildOfClass("Tool")
	if not currentTool and char then
		for _, child in char:GetChildren() do
			if child:IsA("Tool") or (child:IsA("Model") and (child:FindFirstChild("Handle") or child:FindFirstChild("ItemRoot"))) then
				currentTool = child
				break
			end
		end
	end

	local wf = Items.WeaponFrame
	local wt = Items.WeaponText
	local wv = Items.WeaponViewport
	local pos = MiscOptions.Weapon_ESP_Position or "Left"
	local parentFrame = (pos == "Top" or pos == "Bottom" or pos == "Left" or pos == "Right") and Items[pos] or Items.Left
	local style = MiscOptions.Weapon_ESP_Style or "Text"

	if currentTool then
		wt.Text = "[" .. currentTool.Name .. "]"
		wt.TextColor3 = (MiscOptions.Weapon_ESP_Color and MiscOptions.Weapon_ESP_Color.Color) or rgb(255,255,255)
		wv.Visible = (style == "Icon+Text")

		if style == "Icon+Text" then
			pcall(function()
			if Data._weaponClone then Data._weaponClone:Destroy() end
			local clone = currentTool:Clone()
			clone.Parent = wv
			Data._weaponClone = clone

			local target = clone:FindFirstChild("Handle") or clone:FindFirstChild("ItemRoot") or clone:FindFirstChildWhichIsA("BasePart")
			if target then
				local cf = target.CFrame
				local size = target.Size
				local dist = math.max(size.X, size.Y, size.Z) * 1.6 + 2
				local camPos = cf.Position + cf.LookVector * -dist
				Items.WeaponCamera.CFrame = CFrame.new(camPos, cf.Position)
				Items.WeaponCamera.FieldOfView = 25
			end
		end)
	elseif Data._weaponClone then
		Data._weaponClone:Destroy()
		Data._weaponClone = nil
	end
	wf.LayoutOrder = (pos == "Top") and 0 or (pos == "Bottom") and 0 or 50
	wf.Parent = parentFrame
else
	if Data._weaponClone then
		Data._weaponClone:Destroy()
		Data._weaponClone = nil
	end
	wt.Text = ""
	wv.Visible = false
	wf.Parent = Esp.Cache
end
end

Data.HealthChanged = function(Value)
if not MiscOptions.Healthbar then
	Data.Info.Health = Value
	return
end

local Humanoid = Data.Info.Humanoid
if not Humanoid then Data.Info.Health = Value return end
local MaxHP = Humanoid.MaxHealth
if MaxHP <= 0 then MaxHP = 100 end
local Multiplier = math.clamp(Value / MaxHP, 0, 1)
local isHorizontal = MiscOptions.Healthbar_Position == "Top" or MiscOptions.Healthbar_Position == "Bottom"

local Color = MiscOptions.Healthbar_Low.Color:Lerp(MiscOptions.Healthbar_Medium.Color, Multiplier)
local Color_2 = Color:Lerp(MiscOptions.Healthbar_High.Color, Multiplier)

local oldHealth = Data.Info.Health
Data.Info.Health = Value

if MiscOptions.Healthbar_Tween and math.abs(oldHealth - Value) > 0.5 then
	Esp:Tween(Items.HealthbarAccent, {
	Size = dim2(isHorizontal and Multiplier or 1, -2, isHorizontal and 1 or Multiplier, -2),
	Position = dim2(0, 1, isHorizontal and 0 or 1 - Multiplier, 1)
	}, TweenInfo.new(MiscOptions.Healthbar_Easing_Speed, Enum.EasingStyle[MiscOptions.Healthbar_EasingStyle], Enum.EasingDirection[MiscOptions.Healthbar_EasingDirection], 0, false, 0))
	Esp:Tween(Items.HealthbarText, {Position = dim2(0, 0, isHorizontal and 0 or 1 - Multiplier, 0), TextColor3 = Color_2}, TweenInfo.new(MiscOptions.Healthbar_Easing_Speed, Enum.EasingStyle[MiscOptions.Healthbar_EasingStyle], Enum.EasingDirection[MiscOptions.Healthbar_EasingDirection], 0, false, 0))

	Items.HealthbarText.Text = math.floor(Value)
else
	Items.HealthbarAccent.Size = dim2(isHorizontal and Multiplier or 1, -2, isHorizontal and 1 or Multiplier, -2)
	Items.HealthbarAccent.Position = dim2(0, 1, isHorizontal and 0 or 1 - Multiplier, 1)
	Items.HealthbarText.Text = math.floor(Value)
	Items.HealthbarText.Position = dim2(0, 0, isHorizontal and 0 or 1 - Multiplier, 0)
	Items.HealthbarText.TextColor3 = Color_2
end
end

Data.SetupChams = function()
local Character = Data.Info.Character
if not Character then return end

pcall(function()
Items.Highlight.Parent = MiscOptions.Chams and Character or nil
Items.Highlight.Enabled = MiscOptions.Chams
end)
end

Data.ClearBreadcrumbs = function()
if Drawings.Breadcrumbs then
	for _, crumb in Drawings.Breadcrumbs do
		if crumb.Obj then crumb.Obj:Remove() end
	end
end
Drawings.Breadcrumbs = {}
Drawings.BreadcrumbLines = Drawings.BreadcrumbLines or {}
for _, line in Drawings.BreadcrumbLines do
	line:Remove()
end
Drawings.BreadcrumbLines = {}
Data.LastCrumbTime = 0
end

Drawings.Breadcrumbs = {}
Drawings.BreadcrumbLines = {}
Data.LastCrumbTime = 0
Data._rayFrame = 0
Data._rayVisible = true
Data._rayFilter = table_create(3)
Data.IsVisible = true
Data._visApplied = nil
Data._chamsApplied = nil
Data._cornerGrads = {}
Data._boneParts = nil
Data._isR15 = false
Data._headPart = nil
Data._chTrig = nil

Data.RefreshDescendants = function()
local Character = (typechar and player) or player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild( "Humanoid" )

Data.Info.Character = typechar and player or Character
Data.Info.Humanoid = Humanoid
Data.Info.rootpart = Humanoid.RootPart
Data.Info.Health = Humanoid.Health

Data._isR15 = Character:FindFirstChild("UpperTorso") ~= nil
Data._headPart = Character:FindFirstChild("Head")

local BoneSet = Data._isR15 and Bones or R6Bones
local boneCache = {}
for i = 1, #BoneSet do
	local bp = BoneSet[i]
	boneCache[i] = { Character:FindFirstChild(bp[1]), Character:FindFirstChild(bp[2]) }
end
Data._boneParts = boneCache
Data._boneSet = BoneSet

local N = MiscOptions.ChinaHat_Segments or 10
local trig = {}
for i = 1, N do
	local a = (i - 1) / N * TWO_PI
	trig[i] = { math_cos(a), math_sin(a) }
end
Data._chTrig = trig

Data._visApplied = nil
Data._chamsApplied = nil

local cg = {}
if Items.Corners then
	for _, corner in Items.Corners:GetChildren() do
		local g = corner:FindFirstChildOfClass("UIGradient")
		if g then cg[#cg + 1] = g end
	end
end
if Items.ImageBox then
	local g = Items.ImageBox:FindFirstChildOfClass("UIGradient")
	if g then cg[#cg + 1] = g end
end
Data._cornerGrads = cg

Esp:Connection(Humanoid.HealthChanged, Data.HealthChanged)
Esp:Connection(Character.ChildAdded, Data.ToolAdded)
Esp:Connection(Character.ChildRemoved, Data.ToolAdded)

Data.HealthChanged(Humanoid.Health)
Data.SetupChams()
Data.ClearBreadcrumbs()
Data.ToolAdded()
end

Data.Destroy = function()
for _, line in Drawings.Skeleton do
	line:Remove()
end
if Drawings.SkeletonOutline then
	for _, line in Drawings.SkeletonOutline do line:Remove() end
end
if Drawings.HeadCircleOL then Drawings.HeadCircleOL:Remove() end
if Drawings.HeadCircle then Drawings.HeadCircle:Remove() end
if Drawings.ChinaHatRingOL then for _, l in Drawings.ChinaHatRingOL do l:Remove() end end
if Drawings.ChinaHatRing then for _, l in Drawings.ChinaHatRing do l:Remove() end end
if Drawings.ChinaHatSpokesOL then for _, l in Drawings.ChinaHatSpokesOL do l:Remove() end end
if Drawings.ChinaHatSpokes then for _, l in Drawings.ChinaHatSpokes do l:Remove() end end
Data.ClearBreadcrumbs()

pcall(function()
if Items.Highlight then Items.Highlight:Destroy() end
end)
if Data._weaponClone then Data._weaponClone:Destroy() Data._weaponClone = nil end

if Items["Holder"] then
	Items["Holder"].Parent = nil
	Items["Holder"]:Destroy()
end

if Esp.Players[player.Name] then
	Esp.Players[player.Name] = nil
end
end

Data.RefreshDescendants()
Esp:Connection(Data.Info.Character.ChildAdded, Data.ToolAdded)
Esp:Connection(player.CharacterAdded, Data.RefreshDescendants)

for _,ItemParentor in {Items.Left, Items.Right, Items.Top, Items.Bottom} do
	Esp:Connection(ItemParentor.ChildAdded, function()
	task.wait(.1)

	if ItemParentor.Parent == nil then
		return
	end

	ItemParentor.Parent = Items.Holder
end)

Esp:Connection(ItemParentor.ChildRemoved, function()
task.wait(.1)
if #ItemParentor:GetChildren() == 0 then
	if ItemParentor.Parent == nil then
		return
	end

	ItemParentor.Parent = Esp.Cache
end
end)
end

for _,HealthHolder in {"Right", "Left"} do
	local Parent = Items["HealthbarTexts" .. HealthHolder]

	Esp:Connection(Parent.ChildAdded, function()
	task.wait(.1)

	if Parent.Parent == nil then
		return
	end

	Parent.Parent = Items[HealthHolder]
end)

Esp:Connection(Parent.ChildRemoved, function()
task.wait(.1)
if #Parent:GetChildren() == 0 then
	if Parent.Parent == nil then
		return
	end

	Parent.Parent = Esp.Cache
end
end)
end

Esp.Players[player.Name] = Data
local pl = Esp.PlayersList
pl[#pl + 1] = Data

return Data
end

function Esp.Update()
	if not Esp then return end
	if not Options.Enabled then return end

	local camCF = camera.CFrame
	local camPos = camCF.Position
	local camUp = camCF.UpVector
	local camVP = camera.ViewportSize
	local W2VP = camera.WorldToViewportPoint

	local skeletonEnabled = MiscOptions.Skeleton
	local skeletonOLEnabled = skeletonEnabled and MiscOptions.Skeleton_Outline
	local headCircleEnabled = MiscOptions.HeadCircle
	local chinaHatEnabled = MiscOptions.ChinaHat
	local breadcrumbsEnabled = MiscOptions.Breadcrumbs
	local visCheckEnabled = MiscOptions.VisibleCheck
	local hiddenColorTbl = visCheckEnabled and MiscOptions.Hidden_Color
	local hiddenColor = hiddenColorTbl and hiddenColorTbl.Color or nil
	local maxDist = MiscOptions.MaxDistance or 2500
	local localChar = Players.LocalPlayer and Players.LocalPlayer.Character or nil

	local skelColor = skeletonEnabled and MiscOptions.Skeleton_Color.Color
	local hcColorBase = headCircleEnabled and MiscOptions.HeadCircle_Color.Color
	local hcRadius = MiscOptions.HeadCircle_Radius or 1.0
	local hcShowOL = MiscOptions.HeadCircle_Outline
	local chShowOL = chinaHatEnabled and MiscOptions.ChinaHat_Outline
	local chRadius = MiscOptions.ChinaHat_Radius or 1.6
	local chHeight = MiscOptions.ChinaHat_Height or 0.9
	local chColorBase = chinaHatEnabled and MiscOptions.ChinaHat_Color and MiscOptions.ChinaHat_Color.Color

	local hiddenSeq, visBoxGrad, visFillGrad
	local nameColorBase, distColorBase
	if visCheckEnabled and hiddenColor then
		hiddenSeq = rgbseq{rgbkey(0, hiddenColor), rgbkey(1, hiddenColor)}
		local g1 = MiscOptions["Box Gradient 1"]
		local g2 = MiscOptions["Box Gradient 2"]
		local f1 = MiscOptions["Box Fill 1"]
		local f2 = MiscOptions["Box Fill 2"]
		visBoxGrad = rgbseq{rgbkey(0, g2.Color), rgbkey(1, g1.Color)}
		visFillGrad = rgbseq{rgbkey(0, f1.Color), rgbkey(1, f2.Color)}
		nameColorBase = MiscOptions.Name_Text_Color and MiscOptions.Name_Text_Color.Color
		distColorBase = MiscOptions.Distance_Text_Color and MiscOptions.Distance_Text_Color.Color
	end

	local chamsEnabled = MiscOptions.Chams
	local chamsFillBase = chamsEnabled and MiscOptions.Chams_Fill_Color and MiscOptions.Chams_Fill_Color.Color
	local chamsOLBase = chamsEnabled and MiscOptions.Chams_Outline_Color and MiscOptions.Chams_Outline_Color.Color

	local bcLifetime, bcInterval, bcStyle, bcFade, bcColorBase, bcThickness, bcSize
	if breadcrumbsEnabled then
		bcLifetime = MiscOptions.Breadcrumbs_Lifetime
		bcInterval = MiscOptions.Breadcrumbs_Interval
		bcStyle = MiscOptions.Breadcrumbs_Style
		bcFade = MiscOptions.Breadcrumbs_Fade
		bcColorBase = MiscOptions.Breadcrumbs_Color.Color
		bcThickness = MiscOptions.Breadcrumbs_Thickness
		bcSize = MiscOptions.Breadcrumbs_Size
	end

	local now = tick()
	local frameIdx = Esp._frameIndex + 1
	Esp._frameIndex = frameIdx
	local maxDistSq = maxDist * maxDist

	local boxGradMoving = MiscOptions["Box Gradient Moving"]
	local boxGradSpeed = MiscOptions["Box Gradient Speed"] or 120
	local fillMoving = MiscOptions["Box Fill Moving"]
	local fillSpeed = MiscOptions["Box Fill Speed"] or 90

	local boxGradRot, fillRot
	if boxGradMoving then
		boxGradRot = (now * boxGradSpeed) % 360
	end
	if fillMoving then
		fillRot = (now * fillSpeed) % 360
	end

	local pl = Esp.PlayersList
	local plCount = #pl
	for i = 1, plCount do
		local Data = pl[i]
		if not Data then continue end
		local Info = Data.Info
		if not Info then continue end
		local Items = Data.Items
		if not Items then continue end
		local Drawings = Data.Drawings
		local Character = Info.Character
		local Humanoid = Info.Humanoid
		local rootPart = Humanoid and Humanoid.RootPart

		if not Character or not Humanoid or not rootPart then
			if Items.Holder and Items.Holder.Visible then Items.Holder.Visible = false end
			local sd = Drawings.Skeleton; if sd then for ix = 1, #sd do sd[ix].Visible = false end end
			local so = Drawings.SkeletonOutline; if so then for ix = 1, #so do so[ix].Visible = false end end
			if Drawings.HeadCircle then Drawings.HeadCircle.Visible = false end
			if Drawings.HeadCircleOL then Drawings.HeadCircleOL.Visible = false end
			local cr = Drawings.ChinaHatRing; if cr then for ix = 1, #cr do cr[ix].Visible = false end end
			local cs = Drawings.ChinaHatSpokes; if cs then for ix = 1, #cs do cs[ix].Visible = false end end
			local cro = Drawings.ChinaHatRingOL; if cro then for ix = 1, #cro do cro[ix].Visible = false end end
			local cso = Drawings.ChinaHatSpokesOL; if cso then for ix = 1, #cso do cso[ix].Visible = false end end
			local cl = Drawings.Breadcrumbs; if cl then for ix = 1, #cl do cl[ix].Obj.Visible = false end end
			local bl = Drawings.BreadcrumbLines; if bl then for ix = 1, #bl do bl[ix].Visible = false end end
			local hl = Items.Highlight; if hl and hl.Enabled then hl.Enabled = false end
			continue
		end

		local rootCF = rootPart.CFrame
		local rootPos = rootCF.Position
		local dx = rootPos.X - camPos.X
		local dy = rootPos.Y - camPos.Y
		local dz = rootPos.Z - camPos.Z
		local distSq = dx*dx + dy*dy + dz*dz

		if distSq > maxDistSq then
			if Items.Holder.Visible then Items.Holder.Visible = false end
			local sd = Drawings.Skeleton; if sd then for ix = 1, #sd do sd[ix].Visible = false end end
			local so = Drawings.SkeletonOutline; if so then for ix = 1, #so do so[ix].Visible = false end end
			if Drawings.HeadCircle then Drawings.HeadCircle.Visible = false end
			if Drawings.HeadCircleOL then Drawings.HeadCircleOL.Visible = false end
			local cr = Drawings.ChinaHatRing; if cr then for ix = 1, #cr do cr[ix].Visible = false end end
			local cs = Drawings.ChinaHatSpokes; if cs then for ix = 1, #cs do cs[ix].Visible = false end end
			local cro = Drawings.ChinaHatRingOL; if cro then for ix = 1, #cro do cro[ix].Visible = false end end
			local cso = Drawings.ChinaHatSpokesOL; if cso then for ix = 1, #cso do cso[ix].Visible = false end end
			local cl = Drawings.Breadcrumbs; if cl then for ix = 1, #cl do cl[ix].Obj.Visible = false end end
			local bl = Drawings.BreadcrumbLines; if bl then for ix = 1, #bl do bl[ix].Visible = false end end
			local hl = Items.Highlight; if hl and hl.Enabled then hl.Enabled = false end
			continue
		end

		local dist = distSq ^ 0.5
		local torsoUp = rootCF.UpVector
		local topWorld = rootPos + torsoUp * 1.8 + camUp
		local botWorld = rootPos - torsoUp * 2.5 - camUp
		local topSc, topOn = W2VP(camera, topWorld)
		local botSc, _ = W2VP(camera, botWorld)

		local OnScreen = topOn
		local Distance = math_floor(dist * 0.333)

		local tX, tY, bX, bY = topSc.X, topSc.Y, botSc.X, botSc.Y
		local Width = math_max(math_floor(math_abs(tX - bX)), 3)
		local Height = math_max(math_floor(math_max(math_abs(bY - tY), Width * 0.5)), 3)
		local bsW = math_floor(math_max(Height / 1.5, Width))
		local bpX = math_floor(tX * 0.5 + bX * 0.5 - bsW * 0.5)
		local bpY = math_floor(math_min(tY, bY))

		local isVisible = true
		if visCheckEnabled and hiddenColor then
			local rf = Data._rayFrame + 1
			if rf >= 8 then
				rf = 0
				local filter = Data._rayFilter
				filter[1] = Character; filter[2] = localChar; filter[3] = camera
				EspRayParams.FilterDescendantsInstances = filter
				Data._rayVisible = Workspace:Raycast(camPos, rootPos - camPos, EspRayParams) == nil
			end
			Data._rayFrame = rf
			isVisible = Data._rayVisible
		end
		local wasVisible = Data.IsVisible
		Data.IsVisible = isVisible
		local useHidden = not isVisible and hiddenColor

		local Holder = Items.Holder
		if Holder.Visible ~= OnScreen then Holder.Visible = OnScreen end

		local doExpensive = (i + frameIdx) % 2 == 0

		-- Skeleton (frame-sliced: every 2nd frame per player)
		if doExpensive then
			local skelDrawings = Drawings.Skeleton
			if skelDrawings then
				local skelOL = Drawings.SkeletonOutline
				if skeletonEnabled and OnScreen and dist < 250 then
					local useColor = useHidden or skelColor
					local boneParts = Data._boneParts
					local numBones = boneParts and #boneParts or 0
					for i = 1, numBones do
						local line = skelDrawings[i]
						if not line then break end
						local pair = boneParts[i]
						local pA, pB = pair[1], pair[2]
						if pA and pA.Parent and pB and pB.Parent then
							local sA, oA = W2VP(camera, pA.Position)
							local sB, oB = W2VP(camera, pB.Position)
							if oA and oB then
								local fv = vec2(sA.X, sA.Y)
								local tv = vec2(sB.X, sB.Y)
								local ol = skelOL and skelOL[i]
								if ol then ol.From = fv; ol.To = tv; ol.Visible = skeletonOLEnabled end
								line.Color = useColor; line.From = fv; line.To = tv; line.Visible = true
							else
								if skelOL and skelOL[i] then skelOL[i].Visible = false end
								line.Visible = false
							end
						else
							if skelOL and skelOL[i] then skelOL[i].Visible = false end
							line.Visible = false
						end
					end
					for i = numBones + 1, #skelDrawings do
						skelDrawings[i].Visible = false
						if skelOL and skelOL[i] then skelOL[i].Visible = false end
					end
				else
					for ix = 1, #skelDrawings do skelDrawings[ix].Visible = false end
					if skelOL then for ix = 1, #skelOL do skelOL[ix].Visible = false end end
				end
			end

			-- Cached head part for HeadCircle + ChinaHat (no FindFirstChild per frame)
			local head = Data._headPart
			local headValid = head and head.Parent and OnScreen

			-- Head Circle (LOD: skip beyond 400 studs)
			local hcDraw = Drawings.HeadCircle
			if hcDraw then
				if headCircleEnabled and headValid and dist < 350 then
					local hs = W2VP(camera, head.Position)
					if hs.Z > 0 then
						local sr = math_clamp(hcRadius * (500 / math_max(dist, 1)), 3, 150)
						local pos = vec2(hs.X, hs.Y)
						local hcOL = Drawings.HeadCircleOL
						if hcShowOL and hcOL then hcOL.Position = pos; hcOL.Radius = sr; hcOL.Visible = true
					elseif hcOL then hcOL.Visible = false end
						hcDraw.Color = useHidden or hcColorBase
						hcDraw.Position = pos; hcDraw.Radius = sr; hcDraw.Visible = true
					else
						hcDraw.Visible = false
						if Drawings.HeadCircleOL then Drawings.HeadCircleOL.Visible = false end
					end
				else
					hcDraw.Visible = false
					if Drawings.HeadCircleOL then Drawings.HeadCircleOL.Visible = false end
				end
			end

			-- China Hat using precomputed trig table (LOD: skip beyond 250 studs)
			local chRing = Drawings.ChinaHatRing
			if chinaHatEnabled and chRing then
				local N = #chRing
				local chSpokes = Drawings.ChinaHatSpokes
				local chRingOL = Drawings.ChinaHatRingOL
				local chSpokesOL = Drawings.ChinaHatSpokesOL
				if headValid and N > 0 and dist < 200 then
					local headCF = head.CFrame
					local headPos = headCF.Position
					local apexProj = W2VP(camera, headPos + vec3(0, chHeight + 1.0, 0))
					if apexProj.Z > 0 then
						local brimCenter = headPos + CH_BRIM_OFFSET
						local rv, lv = headCF.RightVector, headCF.LookVector
						local useColor = useHidden or chColorBase or WHITE
						local apexV = vec2(apexProj.X, apexProj.Y)
						local pX, pY, pZ, fX, fY, fZ
						local trig = Data._chTrig
						for i = 1, N do
							local t = trig[i]
							local pt = W2VP(camera, brimCenter + rv * (t[1] * chRadius) + lv * (t[2] * chRadius))
							local cx, cy, cz = pt.X, pt.Y, pt.Z
							if i == 1 then fX, fY, fZ = cx, cy, cz end
							if i > 1 then
								local idx = i - 1
								if pZ > 0 and cz > 0 then
									local fv, tv = vec2(pX, pY), vec2(cx, cy)
									if chShowOL and chRingOL[idx] then chRingOL[idx].From = fv; chRingOL[idx].To = tv; chRingOL[idx].Visible = true
								elseif chRingOL[idx] then chRingOL[idx].Visible = false end
									chRing[idx].From = fv; chRing[idx].To = tv; chRing[idx].Color = useColor; chRing[idx].Visible = true
								else
									chRing[idx].Visible = false
									if chRingOL[idx] then chRingOL[idx].Visible = false end
								end
							end
							if cz > 0 then
								local bv = vec2(cx, cy)
								if chShowOL and chSpokesOL[i] then chSpokesOL[i].From = bv; chSpokesOL[i].To = apexV; chSpokesOL[i].Visible = true
							elseif chSpokesOL[i] then chSpokesOL[i].Visible = false end
								chSpokes[i].From = bv; chSpokes[i].To = apexV; chSpokes[i].Color = useColor; chSpokes[i].Visible = true
							else
								chSpokes[i].Visible = false
								if chSpokesOL[i] then chSpokesOL[i].Visible = false end
							end
							pX, pY, pZ = cx, cy, cz
						end
						if pZ > 0 and fZ > 0 then
							local fv, tv = vec2(pX, pY), vec2(fX, fY)
							if chShowOL and chRingOL[N] then chRingOL[N].From = fv; chRingOL[N].To = tv; chRingOL[N].Visible = true
						elseif chRingOL[N] then chRingOL[N].Visible = false end
							chRing[N].From = fv; chRing[N].To = tv; chRing[N].Color = useColor; chRing[N].Visible = true
						else
							chRing[N].Visible = false; if chRingOL[N] then chRingOL[N].Visible = false end
						end
					else
						for i = 1, N do chRing[i].Visible = false; chSpokes[i].Visible = false
						if chRingOL[i] then chRingOL[i].Visible = false end
						if chSpokesOL[i] then chSpokesOL[i].Visible = false end
					end
				end
			else
				for i = 1, N do chRing[i].Visible = false; chSpokes[i].Visible = false
				if chRingOL and chRingOL[i] then chRingOL[i].Visible = false end
				if chSpokesOL and chSpokesOL[i] then chSpokesOL[i].Visible = false end
			end
		end
	elseif chRing then
		for i = 1, #chRing do chRing[i].Visible = false end
		local cs = Drawings.ChinaHatSpokes; if cs then for i = 1, #cs do cs[i].Visible = false end end
		local cro = Drawings.ChinaHatRingOL; if cro then for i = 1, #cro do cro[i].Visible = false end end
		local cso = Drawings.ChinaHatSpokesOL; if cso then for i = 1, #cso do cso[i].Visible = false end end
	end

	-- Breadcrumbs
	local crumbList = Drawings.Breadcrumbs
	if crumbList and breadcrumbsEnabled then
		local color = useHidden or bcColorBase
		if now - Data.LastCrumbTime >= bcInterval and #crumbList < 18 then
			Data.LastCrumbTime = now
			local obj
			if bcStyle == "Square" then
				obj = Drawing_new("Square")
				obj.Size = vec2(bcSize * 2, bcSize * 2); obj.Color = color; obj.Thickness = bcThickness; obj.Filled = true; obj.Visible = false
			else
				obj = Drawing_new("Circle")
				obj.Radius = bcSize; obj.Color = color; obj.Thickness = bcThickness; obj.Filled = true; obj.NumSides = 8; obj.Visible = false
			end
			crumbList[#crumbList + 1] = { WorldPos = rootPos, Time = now, Obj = obj }
		end
		local wIdx = 1
		local cnt = #crumbList
		for rIdx = 1, cnt do
			local cr = crumbList[rIdx]
			local age = now - cr.Time
			if age > bcLifetime then
				cr.Obj:Remove()
			else
				if rIdx ~= wIdx then crumbList[wIdx] = cr end
				local sp, onScr = W2VP(camera, cr.WorldPos)
				if onScr then
					local o = cr.Obj
					o.Transparency = bcFade and (1 - age / bcLifetime) or 1
					o.Visible = true
					o.Position = bcStyle == "Square" and vec2(sp.X - bcSize, sp.Y - bcSize) or vec2(sp.X, sp.Y)
				else
					cr.Obj.Visible = false
				end
				wIdx = wIdx + 1
			end
		end
		for i = wIdx, cnt do crumbList[i] = nil end
		if bcStyle == "Line" then
			local lines = Drawings.BreadcrumbLines
			local needed = math_max(#crumbList - 1, 0)
			while #lines < needed do
				local l = Drawing_new("Line"); l.Color = color; l.Thickness = bcThickness; l.Visible = false; l.Transparency = 1
				lines[#lines + 1] = l
			end
			for li = 1, needed do
				local sA, oA = W2VP(camera, crumbList[li].WorldPos)
				local sB, oB = W2VP(camera, crumbList[li+1].WorldPos)
				local ln = lines[li]
				if oA and oB then
					ln.From = vec2(sA.X, sA.Y); ln.To = vec2(sB.X, sB.Y)
					ln.Transparency = bcFade and (1 - (now - crumbList[li+1].Time) / bcLifetime) or 1
					ln.Color = color; ln.Visible = true
				else ln.Visible = false end
				end
				for li = needed + 1, #lines do lines[li].Visible = false end
			else
				local bl = Drawings.BreadcrumbLines
				if bl then for li = 1, #bl do bl[li].Visible = false end end
			end
		elseif crumbList and not breadcrumbsEnabled then
			for i = 1, #crumbList do crumbList[i].Obj.Visible = false end
			local bl = Drawings.BreadcrumbLines
			if bl then for li = 1, #bl do bl[li].Visible = false end end
		end
	end

	-- Chams color (no pcall in hot path)
	local hl = Items.Highlight
	if hl and chamsEnabled then
		if not hl.Enabled then hl.Parent = Character; hl.Enabled = true end
		if visCheckEnabled and hiddenColor and (wasVisible ~= isVisible or not Data._chamsApplied) then
			Data._chamsApplied = true
			hl.FillColor = useHidden or chamsFillBase
			hl.OutlineColor = useHidden or chamsOLBase
		end
	end

	if not OnScreen then continue end

	local lastBpX, lastBpY = Data._lastBpX, Data._lastBpY
	if lastBpX ~= bpX or lastBpY ~= bpY then
		Data._lastBpX, Data._lastBpY = bpX, bpY
		Holder.Position = dim_offset(bpX, bpY)
	end
	local lastBsW, lastH = Data._lastBsW, Data._lastHeight
	if lastBsW ~= bsW or lastH ~= Height then
		Data._lastBsW, Data._lastHeight = bsW, Height
		Holder.Size = dim2(0, bsW, 0, Height)
	end

	if boxGradMoving then
		local cg = Data._cornerGrads
		if cg then for i = 1, #cg do cg[i].Rotation = boxGradRot end end
		if Items.BoxGradient then Items.BoxGradient.Rotation = boxGradRot end
	end
	if fillMoving and Items.HolderGradient then
		Items.HolderGradient.Rotation = fillRot
	end

	local DistanceLabel = Items.Distance
	local distText = tostring(Distance) .. "m"
	if Data._lastDistText ~= distText then
		Data._lastDistText = distText
		DistanceLabel.Text = distText
	end

	if visCheckEnabled and hiddenColor and (wasVisible ~= isVisible or not Data._visApplied) then
		Data._visApplied = true
		local colorSeq = isVisible and visBoxGrad or hiddenSeq
		local fillSeq = isVisible and visFillGrad or hiddenSeq
		if Items.BoxGradient then Items.BoxGradient.Color = colorSeq end
		local cg = Data._cornerGrads
		if cg then for i = 1, #cg do cg[i].Color = colorSeq end end
		if Items.HolderGradient then Items.HolderGradient.Color = fillSeq end
		if Items.Text then Items.Text.TextColor3 = isVisible and nameColorBase or hiddenColor end
		if DistanceLabel then DistanceLabel.TextColor3 = isVisible and distColorBase or hiddenColor end
		if Items.HealthbarText then Items.HealthbarText.TextColor3 = isVisible and WHITE or hiddenColor end
		local weaponColor = MiscOptions.Weapon_ESP_Color and MiscOptions.Weapon_ESP_Color.Color
		if Items.WeaponText and weaponColor then Items.WeaponText.TextColor3 = isVisible and weaponColor or hiddenColor end
	end
end
end

function Esp.RefreshElements(key, value)
	for _,Data in Esp.Players do
		local Items = Data and Data.Items
		local Drawings = Data and Data.Drawings

		if not Items then continue end
		if not Items.Holder then continue end
		if Items.Holder.Parent == nil then continue end

		if key == "Enabled" then
			Items.Holder.Visible = value
			if not value then
				if Drawings.ChinaHatRingOL then for _, l in Drawings.ChinaHatRingOL do l.Visible = false end end
				if Drawings.ChinaHatRing then for _, l in Drawings.ChinaHatRing do l.Visible = false end end
				if Drawings.ChinaHatSpokesOL then for _, l in Drawings.ChinaHatSpokesOL do l.Visible = false end end
				if Drawings.ChinaHatSpokes then for _, l in Drawings.ChinaHatSpokes do l.Visible = false end end
				if Drawings.Skeleton then
					for _, line in Drawings.Skeleton do line.Visible = false end
				end
				if Drawings.SkeletonOutline then
					for _, ol in Drawings.SkeletonOutline do ol.Visible = false end
				end
				if Drawings.HeadCircle then Drawings.HeadCircle.Visible = false end
				if Drawings.HeadCircleOL then Drawings.HeadCircleOL.Visible = false end
				if Drawings.Breadcrumbs then
					for _, crumb in Drawings.Breadcrumbs do crumb.Obj.Visible = false end
				end
				if Drawings.BreadcrumbLines then
					for _, l in Drawings.BreadcrumbLines do l.Visible = false end
				end
				local hl = Items.Highlight; if hl then hl.Enabled = false end
			end
		end

		-- Boxes
		if key == "BoxType" then
			if not (Items.Box.Parent == Items.Holder or Items.Corners.Parent == Items.Holder or (Items.ImageBox and Items.ImageBox.Parent == Items.Holder)) then
				continue
			end

			local isCorner = value == "Corner"
			local isImage = value == "Image"
			Items.Box.Parent = (isCorner or isImage) and Esp.Cache or Items.Holder
			Items.Corners.Parent = (not isCorner) and Esp.Cache or Items.Holder
			Items.ImageBox.Parent = isImage and Items.Holder or Esp.Cache
		end

		if key == "Boxes" then
			local boxType = MiscOptions.BoxType or "Corner"
			local isCorner = boxType == "Corner"
			local isImage = boxType == "Image"
			local Enabled = value and Items.Holder or Esp.Cache

			if isCorner then
				Items.Corners.Parent = Enabled
			elseif isImage then
				Items.ImageBox.Parent = Enabled
			else
				Items.Box.Parent = Enabled
			end
		end

		if key == "Box Gradient 1" then
			local Color = rgbseq{
			Items.BoxGradient.Color.Keypoints[1],
			rgbkey(1, value.Color)
			}

			for _,corner in Items.Corners:GetChildren() do
				local g = corner:FindFirstChildOfClass("UIGradient")
				if g then g.Color = Color end
			end
			if Items.ImageBox then
				local g = Items.ImageBox:FindFirstChildOfClass("UIGradient")
				if g then g.Color = Color end
			end
			Items.BoxGradient.Color = Color
		end

		if key == "Box Gradient 2" then
			local Color = rgbseq{
			rgbkey(0, value.Color),
			Items.BoxGradient.Color.Keypoints[2]
			}

			for _,corner in Items.Corners:GetChildren() do
				local g = corner:FindFirstChildOfClass("UIGradient")
				if g then g.Color = Color end
			end
			if Items.ImageBox then
				local g = Items.ImageBox:FindFirstChildOfClass("UIGradient")
				if g then g.Color = Color end
			end
			Items.BoxGradient.Color = Color
		end

		if key == "Box Gradient Rotation" and not MiscOptions["Box Gradient Moving"] then
			Items.BoxGradient.Rotation = value
			local cg = Data._cornerGrads
			if cg then for i = 1, #cg do cg[i].Rotation = value end end
		end

		if key == "Box Gradient Moving" and not value then
			local rot = MiscOptions["Box Gradient Rotation"] or 90
			if Items.BoxGradient then Items.BoxGradient.Rotation = rot end
			local cg = Data._cornerGrads
			if cg then for i = 1, #cg do cg[i].Rotation = rot end end
		end

		if key == "Box Fill" then
			Items.Holder.BackgroundTransparency = value and 0 or 1
		end

		if key == "Box Fill 1" then
			local Path = Items.HolderGradient
			Path.Transparency = numseq{
			numkey(0, 1 - value.Transparency),
			Path.Transparency.Keypoints[2]
			};

			Path.Color = rgbseq{
			rgbkey(0, value.Color),
			Path.Color.Keypoints[2]
			}
		end

		if key == "Box Fill 2" then
			local Path = Items.HolderGradient
			Path.Transparency = numseq{
			Path.Transparency.Keypoints[1],
			numkey(1, 1 - value.Transparency)
			};

			Path.Color = rgbseq{
			Path.Color.Keypoints[1],
			rgbkey(1, value.Color)
			};
		end

		if key == "Box Fill Rotation" and not MiscOptions["Box Fill Moving"] then
			Items.HolderGradient.Rotation = value
		end

		if key == "Box Fill Moving" and not value then
			if Items.HolderGradient then
				Items.HolderGradient.Rotation = MiscOptions["Box Fill Rotation"] or 90
			end
		end

		-- Bars
		if key == "Healthbar" then
			if Items.Healthbar.Parent == nil then
				continue
			end

			Items.Healthbar.Parent = value and Items[Items.Healthbar.Name] or Esp.Cache
			Items.HealthbarText.Parent = (Items.HealthbarText.Parent ~= Esp.Cache and value) and Items["HealthbarTexts" .. Items.Healthbar.Name] or Esp.Cache
		end

		if key == "Healthbar_Position" then
			local isEnabled = not (Items.Healthbar.Parent == Esp.Cache)

			if Items.Healthbar.Parent == nil then
				return
			end

			Items.Healthbar.Parent = isEnabled and Items[value] or Esp.Cache
			Items.Healthbar.Name = value
			Items.HealthbarText.Parent = isEnabled and value and Items.HealthbarText.Parent ~= Esp.Cache and Items["HealthbarTexts" .. Items.Healthbar.Name] or Esp.Cache

			if value == "Bottom" or value == "Top" then
				Items.HealthbarGradient.Rotation = 0
			else
				Items.HealthbarGradient.Rotation = 90
			end

			Data.HealthChanged(Data.Info.Humanoid.Health)
		end

		if key == "Healthbar_Number" then
			if Items.Healthbar.Parent == Esp.Cache then
				continue
			end

			local Parent = Items["HealthbarTexts" .. Items.Healthbar.Name]

			Items.HealthbarText.Parent = value and Parent or Esp.Cache
		end

		if key == "Healthbar_Low" then
			local Color = rgbseq{
			Items.HealthbarGradient.Color.Keypoints[1],
			Items.HealthbarGradient.Color.Keypoints[2],
			rgbkey(1, value.Color)
			}

			Items.HealthbarGradient.Color = Color
		end

		if key == "Healthbar_Medium" then
			local Color = rgbseq{
			Items.HealthbarGradient.Color.Keypoints[1],
			rgbkey(0.5, value.Color),
			Items.HealthbarGradient.Color.Keypoints[3]
			}

			Items.HealthbarGradient.Color = Color
		end

		if key == "Healthbar_High" then
			local Color = rgbseq{
			rgbkey(0, value.Color),
			Items.HealthbarGradient.Color.Keypoints[2],
			Items.HealthbarGradient.Color.Keypoints[3]
			}

			Items.HealthbarGradient.Color = Color
		end

		if key == "Healthbar_Thickness" then
			local Bar = Items.Healthbar
			Bar.Size = dim2(0, value + 2, 0, value + 2)
		end

		if key == "Healthbar_Text_Size" then
			Items.HealthbarText.TextSize = value
		end

		if key == "Healthbar_Font" then
			Items.HealthbarText.FontFace = Fonts[value]
		end

		if key == "VisibleCheck" then
			Data._visApplied = nil
			Data._chamsApplied = nil
		end

		-- Texts (use sub instead of regex match for speed)
		local Text, Match
		local keyPre = key:sub(1, 4)
		if keyPre == "Name" then
			Text = Items.Text; Match = "Name"
		elseif keyPre == "Dist" then
			Text = Items.Distance; Match = "Distance"
		end

		if Text then
			if key == Match .. "_Text" then
				if Text.Parent == nil then
					continue
				end

				Text.Parent = value and Items[Text.Name .. "Texts"] or Esp.Cache
			end

			if key == Match .. "_Text_Position" then
				local isEnabled = not (Text.Parent == Esp.Cache)

				if Text.Parent == nil then
					return
				end

				Text.Parent = isEnabled and Items[value .. "Texts"] or Esp.Cache
				Text.Name = tostring(value)

				if value == "Top" or value == "Bottom" then
					Text.AutomaticSize = Enum.AutomaticSize.Y
					Text.TextXAlignment = Enum.TextXAlignment.Center
				else
					Text.AutomaticSize = Enum.AutomaticSize.XY
					Text.TextXAlignment = Enum.TextXAlignment[value == "Right" and "Left" or "Right"]
				end
			end

			if key == Match .. "_Text_Color" then
				Text.TextColor3 = value.Color
			end

			if key == Match .. "_Text_Font" then
				Text.FontFace = Fonts[value]
			end

			if key == Match .. "_Text_Size" then
				Text.TextSize = value
			end
		end

		-- Skeleton
		if key == "Skeleton_Color" and Drawings.Skeleton then
			for _, line in Drawings.Skeleton do
				line.Color = value.Color
			end
		end

		if key == "Skeleton_Thickness" and Drawings.Skeleton then
			for _, line in Drawings.Skeleton do
				line.Thickness = value
			end
		end

		if key == "Skeleton_Outline_Color" and Drawings.SkeletonOutline then
			for _, ol in Drawings.SkeletonOutline do
				ol.Color = value.Color
			end
		end

		if key == "Skeleton_Outline_Thickness" and Drawings.SkeletonOutline then
			for _, ol in Drawings.SkeletonOutline do
				ol.Thickness = value
			end
		end

		if key == "Skeleton_Outline" and Drawings.SkeletonOutline and not value then
			for _, ol in Drawings.SkeletonOutline do
				ol.Visible = false
			end
		end

		if key == "Skeleton" and Drawings.Skeleton then
			if not value then
				for _, line in Drawings.Skeleton do
					line.Visible = false
				end
				if Drawings.SkeletonOutline then
					for _, ol in Drawings.SkeletonOutline do ol.Visible = false end
				end
			end
		end

		-- Head Circle
		if key == "HeadCircle_Color" and Drawings.HeadCircle then
			Drawings.HeadCircle.Color = value.Color
		end
		if key == "HeadCircle_Thickness" and Drawings.HeadCircle then
			Drawings.HeadCircle.Thickness = value
		end
		if key == "HeadCircle_Filled" and Drawings.HeadCircle then
			Drawings.HeadCircle.Filled = value
		end
		if key == "HeadCircle_Style" then
			local sides = value == "Hexagon" and 6 or 24
			if Drawings.HeadCircle then Drawings.HeadCircle.NumSides = sides end
			if Drawings.HeadCircleOL then Drawings.HeadCircleOL.NumSides = sides end
		end
		if key == "HeadCircle_Outline_Color" and Drawings.HeadCircleOL then
			Drawings.HeadCircleOL.Color = value.Color
		end
		if key == "HeadCircle_Outline_Thickness" and Drawings.HeadCircleOL then
			Drawings.HeadCircleOL.Thickness = value
		end
		if key == "HeadCircle_Outline" and not value then
			if Drawings.HeadCircleOL then Drawings.HeadCircleOL.Visible = false end
		end
		if key == "HeadCircle" and not value then
			if Drawings.HeadCircle then Drawings.HeadCircle.Visible = false end
			if Drawings.HeadCircleOL then Drawings.HeadCircleOL.Visible = false end
		end

		-- China Hat
		if key == "ChinaHat_Color" then
			if Drawings.ChinaHatRing then for _, l in Drawings.ChinaHatRing do l.Color = value.Color end end
			if Drawings.ChinaHatSpokes then for _, l in Drawings.ChinaHatSpokes do l.Color = value.Color end end
		end
		if key == "ChinaHat_Thickness" then
			if Drawings.ChinaHatRing then for _, l in Drawings.ChinaHatRing do l.Thickness = value end end
			if Drawings.ChinaHatSpokes then for _, l in Drawings.ChinaHatSpokes do l.Thickness = value end end
		end
		if key == "ChinaHat_Outline_Color" then
			if Drawings.ChinaHatRingOL then for _, l in Drawings.ChinaHatRingOL do l.Color = value.Color end end
			if Drawings.ChinaHatSpokesOL then for _, l in Drawings.ChinaHatSpokesOL do l.Color = value.Color end end
		end
		if key == "ChinaHat_Outline_Thickness" then
			if Drawings.ChinaHatRingOL then for _, l in Drawings.ChinaHatRingOL do l.Thickness = value end end
			if Drawings.ChinaHatSpokesOL then for _, l in Drawings.ChinaHatSpokesOL do l.Thickness = value end end
		end
		if key == "ChinaHat_Outline" and not value then
			if Drawings.ChinaHatRingOL then for _, l in Drawings.ChinaHatRingOL do l.Visible = false end end
			if Drawings.ChinaHatSpokesOL then for _, l in Drawings.ChinaHatSpokesOL do l.Visible = false end end
		end
		if key == "ChinaHat" and not value then
			if Drawings.ChinaHatRingOL then for _, l in Drawings.ChinaHatRingOL do l.Visible = false end end
			if Drawings.ChinaHatRing then for _, l in Drawings.ChinaHatRing do l.Visible = false end end
			if Drawings.ChinaHatSpokesOL then for _, l in Drawings.ChinaHatSpokesOL do l.Visible = false end end
			if Drawings.ChinaHatSpokes then for _, l in Drawings.ChinaHatSpokes do l.Visible = false end end
		end

		-- Chams
		if key == "Chams" then
			pcall(function()
			Items.Highlight.Enabled = value
			Items.Highlight.Parent = value and Data.Info.Character or nil
		end)
	end

	if key == "Chams_Fill_Color" then
		pcall(function() Items.Highlight.FillColor = value.Color end)
	end

	if key == "Chams_Fill_Transparency" then
		pcall(function() Items.Highlight.FillTransparency = value end)
	end

	if key == "Chams_Outline_Color" then
		pcall(function() Items.Highlight.OutlineColor = value.Color end)
	end

	if key == "Chams_Outline_Transparency" then
		pcall(function() Items.Highlight.OutlineTransparency = value end)
	end

	if key == "Chams_DepthMode" then
		pcall(function() Items.Highlight.DepthMode = Enum.HighlightDepthMode[value] end)
	end

	-- Breadcrumbs
	if key == "Breadcrumbs" and not value then
		Data.ClearBreadcrumbs()
	end

	if key == "Breadcrumbs_Color" and Drawings.Breadcrumbs then
		for _, crumb in Drawings.Breadcrumbs do
			crumb.Obj.Color = value.Color
		end
		for _, l in Drawings.BreadcrumbLines do
			l.Color = value.Color
		end
	end

	if key == "Breadcrumbs_Thickness" then
		if Drawings.Breadcrumbs then
			for _, crumb in Drawings.Breadcrumbs do
				crumb.Obj.Thickness = value
			end
		end
		if Drawings.BreadcrumbLines then
			for _, l in Drawings.BreadcrumbLines do
				l.Thickness = value
			end
		end
	end

	if key == "Breadcrumbs_Size" and Drawings.Breadcrumbs then
		for _, crumb in Drawings.Breadcrumbs do
			if crumb.Obj.Radius then
				crumb.Obj.Radius = value
			elseif crumb.Obj.Size then
				crumb.Obj.Size = vec2(value * 2, value * 2)
			end
		end
	end

	if key == "Breadcrumbs_Style" then
		Data.ClearBreadcrumbs()
	end

	-- Weapon ESP
	if key == "Weapon_ESP" and Items.WeaponFrame then
		Data.ToolAdded()
	end
	if key == "Weapon_ESP_Style" and Items.WeaponFrame then
		local style = value or "Text"
		local showIcon = style == "Icon+Text"
		if Items.WeaponViewport then Items.WeaponViewport.Visible = showIcon end
		if Items.WeaponText then Items.WeaponText.Visible = true end
		Data.ToolAdded()
	end
	if key == "Weapon_ESP_Position" and Items.WeaponFrame then
		Data.ToolAdded()
	end
	if key == "Weapon_ESP_Color" and Items.WeaponText then
		Items.WeaponText.TextColor3 = value.Color
	end
	if key == "Weapon_ESP_Size" and Items.WeaponViewport then
		Items.WeaponViewport.Size = dim2(0, value or 48, 0, value or 48)
	end
end
end;

function Esp.Unload()
	for _,player in Players:GetPlayers() do
		Esp.RemovePlayer(player)
	end
	Esp.PlayersList = {}

	for _,connection in Esp.Connections do
		connection:Disconnect()
		connection = nil
	end

	if Esp.Loop then
		RunService:UnbindFromRenderStep("Run Loop")
		Esp.Loop = nil
	end

	Esp.Cache:Destroy()
	Esp.ScreenGui:Destroy()

	getgenv().Esp = nil
	getgenv().ESPConfig = nil
end

function Esp.RemovePlayer(player)
	local Path = Esp.Players[player.Name]
	if Path then
		Path.Destroy()
		Esp.Players[player.Name] = nil
		local pl = Esp.PlayersList
		for i = 1, #pl do
			if pl[i] == Path then
				pl[i] = pl[#pl]
				pl[#pl] = nil
				break
			end
		end
	end
end
end

for _,player in Players:GetPlayers() do
	if player == Players.LocalPlayer then continue end
	task.spawn(Esp.CreateObject, player)
end

Esp:Connection(Players.PlayerRemoving, Esp.RemovePlayer)
Esp:Connection(Players.PlayerAdded, function(player)
task.spawn(function()
Esp.CreateObject(player)
for index,value in MiscOptions do
	Options[index] = value
end
end)
end)

Esp.Loop = RunService:BindToRenderStep("Run Loop", 0, Esp.Update)

for index,value in MiscOptions do
	Options[index] = value
end
end

getgenv().ESPConfig = Options

return Options
