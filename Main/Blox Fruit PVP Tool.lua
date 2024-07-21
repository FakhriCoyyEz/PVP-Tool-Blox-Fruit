--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_76979 = 0;
			while true do
				if (FlatIdent_76979 == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local FlatIdent_69270 = 0;
			local Plc;
			while true do
				if (FlatIdent_69270 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_6D4CB = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_6D4CB == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_6D4CB == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_6D4CB = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_12703 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_12703 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_2BD95 = 0;
							while true do
								if (FlatIdent_2BD95 == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							local FlatIdent_23BE8 = 0;
							while true do
								if (FlatIdent_23BE8 == 0) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
									break;
								end
							end
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 38) then
					if (Enum <= 18) then
						if (Enum <= 8) then
							if (Enum <= 3) then
								if (Enum <= 1) then
									if (Enum > 0) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										VIP = Inst[3];
									end
								elseif (Enum > 2) then
									local Edx;
									local Results, Limit;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								elseif (Inst[2] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 5) then
								if (Enum == 4) then
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									do
										return Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									do
										return Unpack(Stk, A, Top);
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								end
							elseif (Enum <= 6) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif (Enum == 7) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local FlatIdent_1076E = 0;
								local A;
								while true do
									if (FlatIdent_1076E == 0) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							end
						elseif (Enum <= 13) then
							if (Enum <= 10) then
								if (Enum == 9) then
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								else
									Stk[Inst[2]] = Env[Inst[3]];
								end
							elseif (Enum <= 11) then
								local A = Inst[2];
								do
									return Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum > 12) then
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							else
								local B = Inst[3];
								local K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
							end
						elseif (Enum <= 15) then
							if (Enum > 14) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							elseif (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 16) then
							local A = Inst[2];
							local Cls = {};
							for Idx = 1, #Lupvals do
								local List = Lupvals[Idx];
								for Idz = 0, #List do
									local FlatIdent_C460 = 0;
									local Upv;
									local NStk;
									local DIP;
									while true do
										if (FlatIdent_C460 == 0) then
											Upv = List[Idz];
											NStk = Upv[1];
											FlatIdent_C460 = 1;
										end
										if (FlatIdent_C460 == 1) then
											DIP = Upv[2];
											if ((NStk == Stk) and (DIP >= A)) then
												Cls[DIP] = NStk[DIP];
												Upv[1] = Cls;
											end
											break;
										end
									end
								end
							end
						elseif (Enum == 17) then
							Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
						else
							local B;
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum <= 28) then
						if (Enum <= 23) then
							if (Enum <= 20) then
								if (Enum == 19) then
									local FlatIdent_7F35E = 0;
									while true do
										if (1 == FlatIdent_7F35E) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_7F35E = 2;
										end
										if (FlatIdent_7F35E == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7F35E = 3;
										end
										if (FlatIdent_7F35E == 0) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_7F35E = 1;
										end
										if (FlatIdent_7F35E == 3) then
											VIP = Inst[3];
											break;
										end
									end
								else
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								end
							elseif (Enum <= 21) then
								local FlatIdent_703C8 = 0;
								local A;
								local B;
								while true do
									if (FlatIdent_703C8 == 0) then
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_703C8 = 1;
									end
									if (FlatIdent_703C8 == 1) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
								end
							elseif (Enum == 22) then
								local FlatIdent_1B51D = 0;
								local B;
								while true do
									if (FlatIdent_1B51D == 0) then
										B = Stk[Inst[4]];
										if not B then
											VIP = VIP + 1;
										else
											Stk[Inst[2]] = B;
											VIP = Inst[3];
										end
										break;
									end
								end
							else
								local FlatIdent_17196 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_17196 == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										FlatIdent_17196 = 1;
									end
									if (FlatIdent_17196 == 6) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_17196 == 3) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_17196 = 4;
									end
									if (FlatIdent_17196 == 1) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_17196 = 2;
									end
									if (FlatIdent_17196 == 4) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										FlatIdent_17196 = 5;
									end
									if (FlatIdent_17196 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_17196 = 6;
									end
									if (FlatIdent_17196 == 2) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_17196 = 3;
									end
								end
							end
						elseif (Enum <= 25) then
							if (Enum > 24) then
								local FlatIdent_35A31 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_35A31 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_35A31 = 1;
									end
									if (FlatIdent_35A31 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_35A31 = 4;
									end
									if (5 == FlatIdent_35A31) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_35A31 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_35A31 = 3;
									end
									if (FlatIdent_35A31 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_35A31 = 5;
									end
									if (FlatIdent_35A31 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_35A31 = 2;
									end
								end
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 26) then
							local A = Inst[2];
							Stk[A] = Stk[A]();
						elseif (Enum == 27) then
							local FlatIdent_28F1 = 0;
							local A;
							while true do
								if (FlatIdent_28F1 == 6) then
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_28F1 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_28F1 = 4;
								end
								if (FlatIdent_28F1 == 0) then
									A = nil;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_28F1 = 1;
								end
								if (FlatIdent_28F1 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_28F1 = 3;
								end
								if (FlatIdent_28F1 == 5) then
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_28F1 = 6;
								end
								if (FlatIdent_28F1 == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_28F1 = 2;
								end
								if (4 == FlatIdent_28F1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_28F1 = 5;
								end
							end
						else
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum <= 33) then
						if (Enum <= 30) then
							if (Enum > 29) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 31) then
							local B;
							local A;
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						elseif (Enum == 32) then
							local B;
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3] ~= 0;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							do
								return Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							do
								return Unpack(Stk, A, Top);
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							do
								return;
							end
						else
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
					elseif (Enum <= 35) then
						if (Enum > 34) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						else
							local FlatIdent_47ABB = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_47ABB == 3) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_47ABB = 4;
								end
								if (FlatIdent_47ABB == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									break;
								end
								if (FlatIdent_47ABB == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_47ABB = 3;
								end
								if (FlatIdent_47ABB == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_47ABB = 1;
								end
								if (FlatIdent_47ABB == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_47ABB = 2;
								end
							end
						end
					elseif (Enum <= 36) then
						Stk[Inst[2]] = Inst[3];
					elseif (Enum == 37) then
						local FlatIdent_DFF4 = 0;
						local A;
						local K;
						local B;
						while true do
							if (FlatIdent_DFF4 == 0) then
								A = nil;
								K = nil;
								B = nil;
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_DFF4 = 1;
							end
							if (FlatIdent_DFF4 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								FlatIdent_DFF4 = 5;
							end
							if (FlatIdent_DFF4 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
								break;
							end
							if (FlatIdent_DFF4 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_DFF4 = 3;
							end
							if (FlatIdent_DFF4 == 3) then
								B = Inst[3];
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								FlatIdent_DFF4 = 4;
							end
							if (FlatIdent_DFF4 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_DFF4 = 2;
							end
						end
					else
						local B;
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						B = Stk[Inst[4]];
						if not B then
							VIP = VIP + 1;
						else
							Stk[Inst[2]] = B;
							VIP = Inst[3];
						end
					end
				elseif (Enum <= 57) then
					if (Enum <= 47) then
						if (Enum <= 42) then
							if (Enum <= 40) then
								if (Enum > 39) then
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								else
									do
										return;
									end
								end
							elseif (Enum == 41) then
								Stk[Inst[2]] = Stk[Inst[3]];
							else
								local DIP;
								local NStk;
								local Upv;
								local List;
								local Cls;
								local A;
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Cls = {};
								for Idx = 1, #Lupvals do
									local FlatIdent_1CA5D = 0;
									while true do
										if (FlatIdent_1CA5D == 0) then
											List = Lupvals[Idx];
											for Idz = 0, #List do
												Upv = List[Idz];
												NStk = Upv[1];
												DIP = Upv[2];
												if ((NStk == Stk) and (DIP >= A)) then
													Cls[DIP] = NStk[DIP];
													Upv[1] = Cls;
												end
											end
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								do
									return;
								end
							end
						elseif (Enum <= 44) then
							if (Enum > 43) then
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							else
								local NewProto = Proto[Inst[3]];
								local NewUvals;
								local Indexes = {};
								NewUvals = Setmetatable({}, {__index=function(_, Key)
									local Val = Indexes[Key];
									return Val[1][Val[2]];
								end,__newindex=function(_, Key, Value)
									local Val = Indexes[Key];
									Val[1][Val[2]] = Value;
								end});
								for Idx = 1, Inst[4] do
									VIP = VIP + 1;
									local Mvm = Instr[VIP];
									if (Mvm[1] == 41) then
										Indexes[Idx - 1] = {Stk,Mvm[3]};
									else
										Indexes[Idx - 1] = {Upvalues,Mvm[3]};
									end
									Lupvals[#Lupvals + 1] = Indexes;
								end
								Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
							end
						elseif (Enum <= 45) then
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						elseif (Enum == 46) then
							local FlatIdent_272FB = 0;
							local A;
							while true do
								if (FlatIdent_272FB == 4) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_272FB = 5;
								end
								if (FlatIdent_272FB == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_272FB = 3;
								end
								if (FlatIdent_272FB == 0) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_272FB = 1;
								end
								if (FlatIdent_272FB == 5) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_272FB == 1) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_272FB = 2;
								end
								if (FlatIdent_272FB == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_272FB = 4;
								end
							end
						else
							Stk[Inst[2]]();
						end
					elseif (Enum <= 52) then
						if (Enum <= 49) then
							if (Enum > 48) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								local Results = {Stk[A](Stk[A + 1])};
								local Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum <= 50) then
							local A;
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							do
								return;
							end
						elseif (Enum > 51) then
							local A = Inst[2];
							do
								return Unpack(Stk, A, Top);
							end
						else
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum <= 54) then
						if (Enum > 53) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						else
							local FlatIdent_68856 = 0;
							local A;
							while true do
								if (FlatIdent_68856 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_68856 = 3;
								end
								if (FlatIdent_68856 == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_68856 = 10;
								end
								if (FlatIdent_68856 == 5) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_68856 = 6;
								end
								if (FlatIdent_68856 == 1) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_68856 = 2;
								end
								if (FlatIdent_68856 == 10) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_68856 = 11;
								end
								if (FlatIdent_68856 == 0) then
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_68856 = 1;
								end
								if (11 == FlatIdent_68856) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_68856 = 12;
								end
								if (FlatIdent_68856 == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_68856 = 4;
								end
								if (FlatIdent_68856 == 7) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_68856 = 8;
								end
								if (FlatIdent_68856 == 8) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_68856 = 9;
								end
								if (FlatIdent_68856 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_68856 = 7;
								end
								if (4 == FlatIdent_68856) then
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_68856 = 5;
								end
								if (12 == FlatIdent_68856) then
									Stk[Inst[2]] = Inst[3];
									break;
								end
							end
						end
					elseif (Enum <= 55) then
						local FlatIdent_1468D = 0;
						local A;
						while true do
							if (FlatIdent_1468D == 0) then
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								break;
							end
						end
					elseif (Enum == 56) then
						local FlatIdent_651C5 = 0;
						local A;
						while true do
							if (2 == FlatIdent_651C5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_651C5 = 3;
							end
							if (FlatIdent_651C5 == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_651C5 = 1;
							end
							if (FlatIdent_651C5 == 1) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_651C5 = 2;
							end
							if (FlatIdent_651C5 == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_651C5 = 4;
							end
							if (6 == FlatIdent_651C5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_651C5 == 4) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_651C5 = 5;
							end
							if (FlatIdent_651C5 == 5) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_651C5 = 6;
							end
						end
					else
						local FlatIdent_55D83 = 0;
						local A;
						while true do
							if (FlatIdent_55D83 == 7) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_55D83 = 8;
							end
							if (FlatIdent_55D83 == 9) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (3 == FlatIdent_55D83) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_55D83 = 4;
							end
							if (FlatIdent_55D83 == 1) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_55D83 = 2;
							end
							if (FlatIdent_55D83 == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_55D83 = 1;
							end
							if (8 == FlatIdent_55D83) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_55D83 = 9;
							end
							if (4 == FlatIdent_55D83) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_55D83 = 5;
							end
							if (FlatIdent_55D83 == 2) then
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_55D83 = 3;
							end
							if (FlatIdent_55D83 == 5) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_55D83 = 6;
							end
							if (FlatIdent_55D83 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_55D83 = 7;
							end
						end
					end
				elseif (Enum <= 67) then
					if (Enum <= 62) then
						if (Enum <= 59) then
							if (Enum == 58) then
								Stk[Inst[2]] = Inst[3] ~= 0;
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 60) then
							Stk[Inst[2]] = Upvalues[Inst[3]];
						elseif (Enum > 61) then
							local B;
							local A;
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						else
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum <= 64) then
						if (Enum == 63) then
							local A = Inst[2];
							local C = Inst[4];
							local CB = A + 2;
							local Result = {Stk[A](Stk[A + 1], Stk[CB])};
							for Idx = 1, C do
								Stk[CB + Idx] = Result[Idx];
							end
							local R = Result[1];
							if R then
								local FlatIdent_56F59 = 0;
								while true do
									if (FlatIdent_56F59 == 0) then
										Stk[CB] = R;
										VIP = Inst[3];
										break;
									end
								end
							else
								VIP = VIP + 1;
							end
						else
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 65) then
						local FlatIdent_3121 = 0;
						local A;
						while true do
							if (FlatIdent_3121 == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_3121 = 4;
							end
							if (FlatIdent_3121 == 5) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (FlatIdent_3121 == 4) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_3121 = 5;
							end
							if (FlatIdent_3121 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_3121 = 3;
							end
							if (FlatIdent_3121 == 0) then
								A = nil;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_3121 = 1;
							end
							if (FlatIdent_3121 == 1) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_3121 = 2;
							end
						end
					elseif (Enum == 66) then
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						if Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						local FlatIdent_6066D = 0;
						local Results;
						local Edx;
						local Limit;
						local B;
						local A;
						while true do
							if (FlatIdent_6066D == 1) then
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_6066D = 2;
							end
							if (FlatIdent_6066D == 5) then
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (4 == FlatIdent_6066D) then
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								FlatIdent_6066D = 5;
							end
							if (FlatIdent_6066D == 2) then
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_6066D = 3;
							end
							if (FlatIdent_6066D == 0) then
								Results = nil;
								Edx = nil;
								Results, Limit = nil;
								B = nil;
								A = nil;
								A = Inst[2];
								FlatIdent_6066D = 1;
							end
							if (3 == FlatIdent_6066D) then
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_8A9D7 = 0;
									while true do
										if (FlatIdent_8A9D7 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								FlatIdent_6066D = 4;
							end
						end
					end
				elseif (Enum <= 72) then
					if (Enum <= 69) then
						if (Enum > 68) then
							Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
						else
							local A;
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 70) then
						local Edx;
						local Results, Limit;
						local B;
						local A;
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
						Top = (Limit + A) - 1;
						Edx = 0;
						for Idx = A, Top do
							Edx = Edx + 1;
							Stk[Idx] = Results[Edx];
						end
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Stk[A + 1]);
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					elseif (Enum > 71) then
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
					else
						local A;
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
					end
				elseif (Enum <= 74) then
					if (Enum == 73) then
						Stk[Inst[2]] = {};
					else
						local A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
					end
				elseif (Enum <= 75) then
					local A = Inst[2];
					local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
					local Edx = 0;
					for Idx = A, Inst[4] do
						local FlatIdent_14454 = 0;
						while true do
							if (FlatIdent_14454 == 0) then
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
								break;
							end
						end
					end
				elseif (Enum == 76) then
					local B;
					local A;
					Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Stk[A + 1]);
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Stk[Inst[3]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Stk[A + 1]);
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					VIP = Inst[3];
				else
					local A;
					Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Env[Inst[3]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!0E3O0003043O0067616D65030A3O004765745365727669636503073O00506C6179657273030A3O0052756E5365727669636503113O005265706C69636174656453746F72616765030C3O0054772O656E53657276696365030B3O00506C61796572412O64656403073O00436F2O6E65637403063O00697061697273030A3O00476574506C6179657273028O0003093O00436861726163746572026O00F03F030E3O00436861726163746572412O646564005A3O00122C3O00013O00206O000200122O000200038O0002000200122O000100013O00202O00010001000200122O000300046O00010003000200122O000200013O00202O000200020002001224000400054O002200020004000200122O000300013O00202O00030003000200122O000500066O00030005000200062B00043O000100022O00293O00014O00297O00022D000500013O00062B00060002000100012O00293O00013O00062B00070003000100022O00293O00034O00297O00062B00080004000100012O00293O00023O00022D000900053O00200F000A3O0007002015000A000A000800062B000C0006000100032O00293O00044O00293O00054O00293O00064O0043000A000C000100122O000A00093O00202O000B3O000A4O000B000C6O000A3O000C00044O00500001001224000F000B4O0048001000103O00260E000F002A0001000B00044O002A00010012240010000B3O00260E0010002D0001000B00044O002D000100200F0011000E000C0006310011004300013O00044O004300010012240011000B3O00260E001100390001000D00044O003900012O0029001200064O00290013000E4O003700120002000100044O0043000100260E001100330001000B00044O003300012O0029001200044O001E0013000E6O0012000200014O001200056O0013000E6O00120002000100122O0011000D3O00044O0033000100200F0011000E000E00201500110011000800062B00130007000100042O00293O00044O00293O000E4O00293O00054O00293O00064O000900110013000100044O004F000100044O002D000100044O004F000100044O002A00012O0010000D5O00063F000A00280001000200044O002800012O0029000A00074O002A000A000100014O000A00086O000A000100014O000A00096O000A000100019O006O00013O00083O00283O00028O00026O001440030A3O00546578745363616C65642O0103083O005465787453697A65026O00284003063O00506172656E74030D3O0052656E6465725374652O70656403073O00436F2O6E656374027O004003073O0041646F726E2O65030B3O005072696D6172795061727403083O00496E7374616E63652O033O006E6577030C3O0042692O6C626F61726447756903043O0053697A6503053O005544696D32025O00C06240026O003940026O000840026O001040026O00F03F03163O004261636B67726F756E645472616E73706172656E6379030A3O0054657874436F6C6F723303063O00436F6C6F723303163O00546578745374726F6B655472616E73706172656E6379026O00E03F030C3O005472616E73706172656E6379026O66E63F03063O005A496E646578026O002440030B3O00416C776179734F6E546F7003093O00546578744C6162656C03093O00436861726163746572030E3O00436861726163746572412O64656403043O0057616974030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F745061727403123O00426F7848616E646C6541646F726E6D656E74030E3O00476574457874656E747353697A65016A3O001224000100014O0048000200053O00260E000100100001000200044O0010000100302100050003000400301900050005000600102O0005000700044O00065O00202O00060006000800202O00060006000900062B00083O000100032O00293O00054O00293O00024O003C3O00014O000900060008000100044O0069000100260E000100230001000A00044O0023000100200F00060002000C0010350003000B000600102O00030007000200122O0006000D3O00202O00060006000E00122O0007000F6O0006000200024O000400063O00122O000600113O00202O00060006000E00122O000700013O00122O000800123O00122O000900013O00122O000A00136O0006000A000200102O00040010000600122O000100143O00260E000100370001001500044O0037000100120A000600113O00204D00060006000E00122O000700163O00122O000800013O00122O000900163O00122O000A00016O0006000A000200102O00050010000600302O00050017001600122O000600193O00202O00060006000E00122O000700163O00122O000800163O00122O000900166O00060009000200102O00050018000600302O0005001A001B00122O000100023O000E02001600440001000100044O0044000100120A000600193O00200100060006000E00122O000700163O00122O000800013O00122O000900016O00060009000200102O00030019000600302O0003001C001D00302O0003001E001F00302O00030020000400122O0001000A3O00260E000100500001001400044O0050000100200F00060002000C0010470004000B000600302O00040020000400102O00040007000200122O0006000D3O00202O00060006000E00122O000700216O0006000200024O000500063O00122O000100153O000E02000100020001000100044O0002000100200F00063O0022000616000200590001000600044O0059000100200F00063O00230020150006000600242O004A0006000200022O0029000200063O002015000600020025001224000800264O00080006000800020006040006005F0001000100044O005F00012O00273O00013O00120A0006000D3O00204C00060006000E00122O000700276O0006000200024O000300063O00202O0006000200284O00060002000200102O00030010000600122O000100163O00044O000200012O00273O00013O00013O000D3O00028O00026O00F03F03093O006D61676E697475646503043O005465787403063O00737472696E6703063O00666F726D617403103O00446973743A20252E3166207374756473030B3O005072696D6172795061727403083O00506F736974696F6E030B3O004C6F63616C506C6179657203093O0043686172616374657203073O00566563746F72332O033O006E657700263O0012243O00014O0048000100033O00260E3O000E0001000200044O000E00012O001100040001000200203B0003000400034O00045O00122O000500053O00202O00050005000600122O000600076O000700036O00050007000200102O00040004000500044O0025000100260E3O00020001000100044O000200012O003C000400013O00204200040004000800202O0001000400094O000400023O00202O00040004000A00202O00040004000B00062O0004001F00013O00044O001F00012O003C000400023O00202600040004000A00202O00040004000B00202O00040004000800202O00040004000900062O000200230001000400044O0023000100120A0004000C3O00200F00040004000D2O001A0004000100022O0029000200043O0012243O00023O00044O000200012O00273O00017O001D3O00028O00026O00F03F03063O00697061697273030B3O004765744368696C6472656E2O033O0049734103083O004261736550617274027O004003083O004C69666574696D65030B3O004E756D62657252616E67652O033O006E6577026O00E03F03043O0052617465026O004940026O00084003043O0053697A65030E3O004E756D62657253657175656E6365030C3O005472616E73706172656E637903053O0053702O656403063O00506172656E7403083O00496E7374616E6365030F3O005061727469636C65456D692O74657203053O00436F6C6F72030D3O00436F6C6F7253657175656E636503063O00436F6C6F723303093O00436861726163746572030E3O00436861726163746572412O64656403043O0057616974030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F7450617274015F3O001224000100014O0048000200023O00260E0001004D0001000200044O004D000100120A000300033O0020150004000200042O000D000400054O004B00033O000500044O004A0001002015000800070005001224000A00064O00080008000A00020006310008004A00013O00044O004A0001001224000800014O0048000900093O00260E000800190001000700044O0019000100120A000A00093O002018000A000A000A00122O000B000B6O000A0002000200102O00090008000A00302O0009000C000D00122O0008000E3O00260E000800260001000200044O0026000100120A000A00103O00203D000A000A000A00122O000B000B6O000A0002000200102O0009000F000A00122O000A00103O00202O000A000A000A00122O000B000B6O000A0002000200102O00090011000A00122O000800073O00260E0008002F0001000E00044O002F000100120A000A00093O002040000A000A000A00122O000B00076O000A0002000200102O00090012000A00102O00090013000700044O004A000100260E000800100001000100044O00100001001224000A00013O00260E000A00440001000100044O0044000100120A000B00143O002003000B000B000A00122O000C00156O000B000200024O0009000B3O00122O000B00173O00202O000B000B000A00122O000C00183O00202O000C000C000A00122O000D00023O00122O000E00013O00122O000F00016O000C000F6O000B3O000200102O00090016000B00122O000A00023O00260E000A00320001000200044O00320001001224000800023O00044O0010000100044O0032000100044O0010000100063F000300090001000200044O0009000100044O005E000100260E000100020001000100044O0002000100200F00033O0019000616000200560001000300044O0056000100200F00033O001A00201500030003001B2O004A0003000200022O0029000200033O00201500030002001C0012240005001D4O00080003000500020006040003005C0001000100044O005C00012O00273O00013O001224000100023O00044O000200012O00273O00017O001F3O00028O00026O00084003083O00496E7374616E63652O033O006E657703053O004672616D6503043O0053697A6503053O005544696D32026O00F03F03103O004261636B67726F756E64436F6C6F723303063O00436F6C6F723303063O00506172656E74026O001040027O0040026O33D33F030F3O00426F7264657253697A65506978656C030C3O0042692O6C626F617264477569025O00C06240026O00444003093O00436861726163746572030E3O00436861726163746572412O64656403043O0057616974030E3O0046696E6446697273744368696C6403043O004865616403103O0048756D616E6F6964522O6F745061727403153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F6964030D3O0052656E6465725374652O70656403073O00436F2O6E65637403073O0041646F726E2O65030B3O00416C776179734F6E546F703O01803O001224000100014O0048000200063O00260E0001001A0001000200044O001A000100120A000700033O00201D00070007000400122O000800056O0007000200024O000500073O00122O000700073O00202O00070007000400122O000800083O00122O000900013O00122O000A00083O00122O000B00016O0007000B000200102O00050006000700122O0007000A3O00202O00070007000400122O000800083O00122O000900013O00122O000A00016O0007000A000200102O00050009000700102O0005000B000400122O0001000C3O00260E0001002E0001000D00044O002E000100120A000700073O00202300070007000400122O000800083O00122O000900013O00122O000A000E3O00122O000B00016O0007000B000200102O00040006000700122O0007000A3O00202O00070007000400122O000800013O00122O000900013O00122O000A00016O0007000A000200102O00040009000700302O0004000F000100102O0004000B000300122O000100023O00260E0001005B0001000100044O005B0001001224000700013O00260E000700410001000800044O0041000100120A000800033O00203900080008000400122O000900106O0008000200024O000300083O00122O000800073O00202O00080008000400122O000900013O00122O000A00113O00122O000B00013O00122O000C00126O0008000C000200102O00030006000800122O0007000D3O000E02000D00450001000700044O00450001001224000100083O00044O005B000100260E000700310001000100044O0031000100200F00083O00130006160002004E0001000800044O004E000100200F00083O00140020150008000800152O004A0008000200022O0029000200083O002015000800020016001224000A00174O00080008000A0002000604000800590001000100044O00590001002015000800020016001224000A00184O00080008000A0002000604000800590001000100044O005900012O00273O00013O001224000700083O00044O00310001000E02000C006B0001000100044O006B00010020150007000200190012240009001A4O00080007000900022O0029000600073O0006310006007F00013O00044O007F00012O003C00075O00200F00070007001B00201500070007001C00062B00093O000100022O00293O00064O00293O00054O000900070009000100044O007F000100260E000100020001000800044O00020001002015000700020016001224000900174O0008000700090002000604000700750001000100044O00750001002015000700020016001224000900184O00080007000900020010140003001D00070030440003001E001F00102O0003000B000200122O000700033O00202O00070007000400122O000800056O0007000200024O000400073O00122O0001000D3O00044O000200012O00273O00013O00013O00073O00028O0003063O004865616C746803093O004D61784865616C746803043O0053697A6503053O005544696D322O033O006E6577026O00F03F00153O0012243O00014O0048000100013O00260E3O00020001000100044O000200012O003C00025O0020060002000200024O00035O00202O0003000300034O0001000200034O000200013O00122O000300053O00202O0003000300064O000400013O00122O000500013O00122O000600073O00122O000700016O00030007000200102O00020004000300044O0014000100044O000200012O00273O00017O002A3O00028O00027O0040030A3O00546578745363616C65642O0103063O00506172656E7403083O00496E7374616E63652O033O006E657703093O00546578744C6162656C03043O0053697A6503053O005544696D32025O00C07240026O00494003083O00506F736974696F6E026O00E03F025O00C062C0026O005440026O000840026O00104003043O007761697403063O0043726561746503093O0054772O656E496E666F026O00F03F03103O00546578745472616E73706172656E6379026O00144003163O004261636B67726F756E645472616E73706172656E6379030A3O0054657874436F6C6F723303063O00436F6C6F723303043O0054657874030B3O004C6F63616C506C6179657203043O004E616D6503163O00546578745374726F6B655472616E73706172656E637903083O005465787453697A65026O003840031F3O0057656C636F6D6520546F2046616B68726958696269722050565020542O6F6C026O00184003043O00506C617903093O00436F6D706C6574656403073O00436F2O6E656374026O00344003093O005363722O656E477569030C3O0057616974466F724368696C6403093O00506C6179657247756900D63O0012243O00014O0048000100073O000E020002001C00013O00044O001C000100302100020003000400103300020005000100122O000800063O00202O00080008000700122O000900086O0008000200024O000300083O00122O0008000A3O00202O00080008000700122O000900013O00122O000A000B3O00122O000B00013O00122O000C000C6O0008000C000200102O00030009000800122O0008000A3O00202O00080008000700122O0009000E3O00122O000A000F3O00122O000B00013O00122O000C00106O0008000C000200102O0003000D000800124O00113O00260E3O003A0001001200044O003A000100302100030003000400101C00030005000100122O000800133O00122O000900026O0008000200014O00085O00202O0008000800144O000A00023O00122O000B00153O00202O000B000B000700122O000C00166O000B000200024O000C3O000100302O000C001700014O0008000C00024O000400086O00085O00202O0008000800144O000A00023O00122O000B00153O00202O000B000B000700122O000C00166O000B000200024O000C3O000100302O000C001700164O0008000C00024O000500083O00124O00183O000E020011005600013O00044O00560001001224000800013O00260E000800480001000100044O004800010030210003001900160012410009001B3O00202O00090009000700122O000A00013O00122O000B00163O00122O000C00016O0009000C000200102O0003001A000900122O000800163O00260E000800500001000200044O005000012O003C000900013O00201300090009001D00202O00090009001E00102O0003001C000900124O00123O00044O0056000100260E0008003D0001001600044O003D00010030210003001F000E003021000300200021001224000800023O00044O003D000100260E3O006F0001001600044O006F0001001224000800013O00260E0008005E0001001600044O005E00010030210002001F000E003021000200200021001224000800023O00260E000800690001000100044O006900010030210002001900160012410009001B3O00202O00090009000700122O000A00163O00122O000B00163O00122O000C00166O0009000C000200102O0002001A000900122O000800163O00260E000800590001000200044O005900010030210002001C00220012243O00023O00044O006F000100044O0059000100260E3O007B0001002300044O007B00010020150008000500242O003E00080002000100202O0008000700244O00080002000100202O00080005002500202O00080008002600062B000A3O000100012O00293O00014O00090008000A000100044O00D5000100260E3O00A90001000100044O00A90001001224000800013O00260E0008008A0001000200044O008A000100120A0009000A3O00203800090009000700122O000A000E3O00122O000B000F3O00122O000C00013O00122O000D00276O0009000D000200102O0002000D000900124O00163O00044O00A90001000E02000100980001000800044O0098000100120A000900063O00201200090009000700122O000A00286O0009000200024O000100096O000900013O00202O00090009001D00202O00090009002900122O000B002A6O0009000B000200102O00010005000900122O000800163O00260E0008007E0001001600044O007E000100120A000900063O00203900090009000700122O000A00086O0009000200024O000200093O00122O0009000A3O00202O00090009000700122O000A00013O00122O000B000B3O00122O000C00013O00122O000D000C6O0009000D000200102O00020009000900122O000800023O00044O007E000100260E3O00020001001800044O00020001001224000800013O00260E000800B30001000200044O00B3000100120A000900133O001224000A00024O00370009000200010012243O00233O00044O0002000100260E000800CC0001000100044O00CC00012O003C00095O00201F0009000900144O000B00033O00122O000C00153O00202O000C000C000700122O000D00166O000C000200024O000D3O000100302O000D001700014O0009000D00024O000600096O00095O00202O0009000900144O000B00033O00122O000C00153O00202O000C000C000700122O000D00166O000C000200024O000D3O000100302O000D001700164O0009000D00024O000700093O00122O000800163O00260E000800AC0001001600044O00AC00010020150009000400242O001700090002000100202O0009000600244O00090002000100122O000800023O00044O00AC000100044O000200012O00273O00013O00013O00013O0003073O0044657374726F7900044O003C7O0020155O00012O00373O000200012O00273O00017O00053O00028O0003073O0072657175697265030C3O0057616974466F724368696C64030C3O005261636556334D6F64756C6503083O00416374697661746500103O0012243O00014O0048000100013O00260E3O00020001000100044O0002000100120A000200024O004600035O00202O00030003000300122O000500046O000300056O00023O00024O000100023O00202O0002000100054O00020002000100044O000F000100044O000200012O00273O00017O000F3O00028O00027O0040034D3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F70617261646F7868756276322F70617261646F786875622F6D61696E2F414E54494C4F434B56312E4C554103053O007063612O6C026O00F03F026O000840038C3O004O2067657467656E7628292E50726564696374696F6E203D20302E3136350A4O2067657467656E7628292E41696D50617274203D202248756D616E6F6964522O6F7450617274220A4O2067657467656E7628292E4B6579203D202271220A4O2067657467656E7628292E4175746F50726564696374696F6E203D20747275650A4O2003503O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F656C786F63617358442F547269702D4875622F6D61696E2F536372697074732F43616D2532304C6F636B2E6C7561030A3O006C6F6164737472696E6703013O000A03043O007761726E031E3O004661696C656420746F206C6F61642043616D6C6F636B207363726970742E03283O004661696C656420746F2066657463682043616D6C6F636B207363726970742066726F6D2055524C2E03283O004661696C656420746F206C6F616420612O646974696F6E616C2061696D626F74207363726970742E03323O004661696C656420746F20666574636820612O646974696F6E616C2061696D626F74207363726970742066726F6D2055524C2E00693O0012243O00014O0048000100053O00260E3O00140001000200044O00140001001224000600013O00260E0006000F0001000100044O000F0001001224000500033O00120A000700043O00062B00083O000100012O00293O00054O00300007000200082O0029000400084O0029000300073O001224000600053O00260E000600050001000500044O000500010012243O00063O00044O0014000100044O0005000100260E3O00210001000100044O00210001001224000600013O00260E0006001C0001000100044O001C0001001224000100073O001224000200083O001224000600053O00260E000600170001000500044O001700010012243O00053O00044O0021000100044O0017000100260E3O00490001000500044O00490001001224000600013O00260E000600440001000100044O0044000100120A000700043O00062B00080001000100012O00293O00024O00300007000200082O0029000400084O0029000300073O0006310003004000013O00044O004000010006310004004000013O00044O0040000100120A000700094O0025000800013O00122O0009000A6O000A00046O00080008000A4O00070002000200062O0007003C00013O00044O003C000100120A000800044O0029000900074O003700080002000100044O0043000100120A0008000B3O0012240009000C4O003700080002000100044O0043000100120A0007000B3O0012240008000D4O0037000700020001001224000600053O00260E000600240001000500044O002400010012243O00023O00044O0049000100044O0024000100260E3O00020001000600044O000200010006310003006300013O00044O006300010006310004006300013O00044O00630001001224000600014O0048000700073O00260E000600510001000100044O0051000100120A000800094O0029000900044O004A0008000200022O0029000700083O0006310007005D00013O00044O005D000100120A000800044O0029000900074O003700080002000100044O0068000100120A0008000B3O0012240009000E4O003700080002000100044O0068000100044O0051000100044O0068000100120A0006000B3O0012240007000F4O003700060002000100044O0068000100044O000200012O00273O00013O00023O00023O0003043O0067616D6503073O00482O747047657400073O0012053O00013O00206O00024O00028O000300018O00039O008O00017O00023O0003043O0067616D6503073O00482O747047657400073O0012053O00013O00206O00024O00028O000300018O00039O008O00017O00023O00030E3O00436861726163746572412O64656403073O00436F2O6E65637401093O00200F00013O000100201500010001000200062B00033O000100042O003C8O00298O003C3O00014O003C3O00024O00090001000300012O00273O00013O00017O00010A4O003200018O000200016O0001000200014O000100026O000200016O0001000200014O000100036O000200016O0001000200016O00017O00023O00028O00026O00F03F01183O001224000100014O0048000200023O00260E000100020001000100044O00020001001224000200013O00260E0002000E0001000100044O000E00012O003C00036O001B000400016O0003000200014O000300026O000400016O00030002000100122O000200023O00260E000200050001000200044O000500012O003C000300034O003C000400014O003700030002000100044O0017000100044O0005000100044O0017000100044O000200012O00273O00017O00", GetFEnv(), ...);