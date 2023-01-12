
-- simple alias for easier referencing
local ProfileTable = PROFILEMAN:GetMachineProfile():GetSaved()

function CreditTypeRow()
	local Names = { "Coins", "Tokens", "Swipe Card" }

	local type = ProfileTable.CreditType

	-- called on construction, must set exactly one list member true
	local function Load(self, list, pn)
		-- short-circuit to 'coin' if no option is set
		if not type then list[1] = true return end

		-- do any of the options match the given type?
		for i=1,3 do
			if type == string.lower(Names[i]) then list[i] = true return end
		end

		-- none of the above worked. fallback on coin
		list[1] = true
	end

	-- called as the screen destructs, to save the selected option in list
	local function Save(self, list, pn)
		for i=1,3 do
			if list[i] then
				ProfileTable.CreditType = string.lower(Names[i])
				PROFILEMAN:SaveMachineProfile()
				return
			end
		end
	end

	
	local Params = { Name = "CreditType" }

	return CreateOptionRow( Params, Names, Load, Save )
end

-- To be called wherever the LUA needs split
function GetCreditType()
	local type = ProfileTable.CreditType
	-- assume "coin" unless otherwise specified
	if not type then return "INSERT COIN" end
	if type == "tokens" then return "INSERT TOKEN"
	elseif type == "swipe card" then return "SWIPE CARD"
	else return "INSERT COIN" end
	return type
end


function Get2PlayerJoinMessage()
	if not GAMESTATE:PlayersCanJoin() then return "" end
	if GAMESTATE:GetCoinMode()==COIN_MODE_FREE then return "2 Player mode available" end
	
	local numSidesNotJoined = NUM_PLAYERS - GAMESTATE:GetNumSidesJoined()
	if GAMESTATE:GetPremium() == PREMIUM_JOINT then numSidesNotJoined = numSidesNotJoined - 1 end	
	local coinsRequiredToJoinRest = numSidesNotJoined * PREFSMAN:GetPreference("CoinsPerCredit")
	local remaining = coinsRequiredToJoinRest - GAMESTATE:GetCoins();
	local type = ProfileTable.CreditType
	
	if remaining <= 0 then return "2 Player mode available" end
	
	if type == "tokens" then
	local s = "For 2 Players, insert " .. remaining .. " more token"
	if remaining > 1 then s = s.."s" end		
	return s	
	end
	
	
	if type == "swipe card" then
		local s = "For 2 Players, swipe a card with credits"	
			return s
	end
	
	if type ~= "swipe card" and type ~= "tokens" then
	local s = "For 2 Players, insert " .. remaining .. " more coin"
	if remaining > 1 then s = s.."s" end
		return s
	end
end


