_cryptoCoins = {}

AddEventHandler("Crypto:Shared:DependencyUpdate", RetrieveCryptoComponents)
function RetrieveCryptoComponents()
	Fetch = exports["sandbox-base"]:FetchComponent("Fetch")
	Utils = exports["sandbox-base"]:FetchComponent("Utils")
	Execute = exports["sandbox-base"]:FetchComponent("Execute")
	Database = exports["sandbox-base"]:FetchComponent("Database")
	Middleware = exports["sandbox-base"]:FetchComponent("Middleware")
	Callbacks = exports["sandbox-base"]:FetchComponent("Callbacks")
	Chat = exports["sandbox-base"]:FetchComponent("Chat")
	Logger = exports["sandbox-base"]:FetchComponent("Logger")
	Generator = exports["sandbox-base"]:FetchComponent("Generator")
	Phone = exports["sandbox-base"]:FetchComponent("Phone")
	Crypto = exports["sandbox-base"]:FetchComponent("Crypto")
	Banking = exports["sandbox-base"]:FetchComponent("Banking")
	Billing = exports["sandbox-base"]:FetchComponent("Billing")
	Loans = exports["sandbox-base"]:FetchComponent("Loans")
	Wallet = exports["sandbox-base"]:FetchComponent("Wallet")
	Tasks = exports["sandbox-base"]:FetchComponent("Tasks")
	Jobs = exports["sandbox-base"]:FetchComponent("Jobs")
	Vehicles = exports["sandbox-base"]:FetchComponent("Vehicles")
	Inventory = exports["sandbox-base"]:FetchComponent("Inventory")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["sandbox-base"]:RequestDependencies("Crypto", {
		"Fetch",
		"Utils",
		"Execute",
		"Chat",
		"Database",
		"Middleware",
		"Callbacks",
		"Logger",
		"Generator",
		"Phone",
		"Wallet",
		"Banking",
		"Billing",
		"Loans",
		"Crypto",
		"Jobs",
		"Tasks",
		"Vehicles",
		"Inventory",
	}, function(error)
		if #error > 0 then
			exports["sandbox-base"]:FetchComponent("Logger"):Critical("Crypto", "Failed To Load All Dependencies")
			return
		end
		RetrieveCryptoComponents()
	end)
end)

_CRYPTO = {
	Coin = {
		Create = function(self, name, acronym, price, buyable, sellable)
			while Crypto == nil do
				Wait(1)
			end

			if not Crypto.Coin:Get(acronym) then
				table.insert(_cryptoCoins, {
					Name = name,
					Short = acronym,
					Price = price,
					Buyable = buyable,
					Sellable = sellable,
				})
			else
				for k, v in ipairs(_cryptoCoins) do
					if v.Short == acronym then
						_cryptoCoins[k] = {
							Name = name,
							Short = acronym,
							Price = price,
							Buyable = buyable,
							Sellable = sellable,
						}
						return
					end
				end
			end
		end,
		Get = function(self, acronym)
			for k, v in ipairs(_cryptoCoins) do
				if v.Short == acronym then
					return v
				end
			end

			return nil
		end,
		GetAll = function(self)
			return _cryptoCoins
		end,
	},
	Has = function(self, source, coin, amt)
		local char = Fetch:CharacterSource(source)
		if char ~= nil then
			local crypto = char:GetData("Crypto") or {}
			return crypto[coin] ~= nil and crypto[coin] >= amt
		else
			return false
		end
	end,
	Exchange = {
		IsListed = function(self, coin)
			for k, v in ipairs(_cryptoCoins) do
				if v.Short == coin then
					return true
				end
			end
			return false
		end,
		Buy = function(self, coin, target, amount)
			if Crypto.Exchange:IsListed(coin) then
				local char = Fetch:SID(target)
				if char ~= nil then
					local acc = Banking.Accounts:GetPersonal(char:GetData("SID"))
					local coinData = Crypto.Coin:Get(coin)
					if acc.Balance >= (coinData.Price * amount) then
						if
							Banking.Balance:Withdraw(acc.Account, (coinData.Price * amount), {
								type = "withdraw",
								title = "Crypto Purchase",
								description = string.format("Bought %s $%s", amount, coin),
								transactionAccount = false,
								data = {
									character = char:GetData("SID"),
								},
							})
						then
							Phone.Notification:Add(
								char:GetData("Source"),
								"Crypto Purchase",
								string.format("You Bought %s $%s", amount, coin),
								os.time(),
								6000,
								"crypto",
								{}
							)
							return Crypto.Exchange:Add(coin, char:GetData("CryptoWallet"), amount)
						else
							return false
						end
					else
						Phone.Notification:Add(
							char:GetData("Source"),
							"Crypto Purchase",
							"Insufficient Funds",
							os.time(),
							6000,
							"crypto",
							{}
						)
						return false
					end
				else
					return false
				end
			else
				return false
			end
		end,
		Sell = function(self, coin, target, amount)
			if Crypto.Exchange:IsListed(coin) then
				local char = Fetch:SID(target)
				if char ~= nil then
					local acc = Banking.Accounts:GetPersonal(char:GetData("SID"))
					local coinData = Crypto.Coin:Get(coin)

					if coinData.Sellable then
						if Crypto.Exchange:Remove(coin, char:GetData("CryptoWallet"), amount, true) then
							return Banking.Balance:Deposit(acc.Account, (coinData.Sellable * amount), {
								type = "deposit",
								title = "Crypto Sale",
								description = string.format("Sold %s $%s", amount, coin),
								transactionAccount = false,
								data = {
									character = char:GetData("SID"),
								},
							})
						else
							return false
						end
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
		end,
		Add = function(self, coin, target, amount, skipAlert)
			local char = Fetch:CharacterData("CryptoWallet", target)
			if char ~= nil then
				local crypto = char:GetData("Crypto") or {}
				if crypto[coin] == nil then
					crypto[coin] = 0
				end

				crypto[coin] = crypto[coin] + amount
				char:SetData("Crypto", crypto)

				if not skipAlert then
					Phone.Notification:Add(
						char:GetData("Source"),
						"Received Crypto",
						string.format("You Received %s $%s", amount, coin),
						os.time(),
						6000,
						"crypto",
						{}
					)
				end

				return true
			else
				local p = promise.new()
				Database.Game:updateOne({
					collection = "characters",
					query = {
						CryptoWallet = target,
					},
					update = {
						["$inc"] = {
							[string.format("Crypto.%s", coin)] = amount,
						},
					},
				}, function(success, res)
					p:resolve(success)
				end)

				return Citizen.Await(p)
			end
		end,
		Remove = function(self, coin, target, amount, skipAlert)
			local p = promise.new()
			local char = Fetch:CharacterData("CryptoWallet", target)
			if char ~= nil then
				local crypto = char:GetData("Crypto") or {}

				if crypto[coin] == nil then
					crypto[coin] = 0
				end

				if crypto[coin] >= amount then
					crypto[coin] = crypto[coin] - amount
					char:SetData("Crypto", crypto)

					if not skipAlert then
						Phone.Notification:Add(
							char:GetData("Source"),
							"Crypto Purchase",
							string.format("You Paid %s $%s", amount, coin),
							os.time(),
							6000,
							"crypto",
							{}
						)
					end

					p:resolve(true)
				else
					p:resolve(false)
				end
			else
				Database.Game:findOne({
					collection = "characters",
					query = {
						CryptoWallet = target,
					},
				}, function(success, res)
					if #res == 0 then
						p:resolve(false)
						return
					else
						if res[1].Crypto[coin] >= amount then
							Database.Game:updateOne({
								collection = "characters",
								query = {
									CryptoWallet = target,
								},
								update = {
									["$inc"] = {
										[string.format("Crypto.%s", coin)] = amount,
									},
								},
							}, function(success, res)
								p:resolve(success)
							end)
						else
							p:resolve(false)
							return
						end
					end
				end)
			end

			return Citizen.Await(p)
		end,
		Transfer = function(self, coin, sender, target, amount)
			local char = Fetch:SID(sender)
			if char then
				if char:GetData("CryptoWallet") ~= target then
					local tChar = Fetch:CharacterData("CryptoWallet", target)

					if tChar or DoesCryptoWalletExist(target) then
						if Crypto.Exchange:Remove(coin, char:GetData("CryptoWallet"), math.abs(amount), true) then
							Phone.Notification:Add(
								char:GetData("Source"),
								"Crypto Transfer",
								string.format("You Sent %s $%s", amount, coin),
								os.time(),
								6000,
								"crypto",
								{}
							)

							if Crypto.Exchange:Add(coin, target, math.abs(amount), true) then
								if tChar then
									Phone.Notification:Add(
										tChar:GetData("Source"),
										"Crypto Transfer",
										string.format("You Received %s $%s", amount, coin),
										os.time(),
										6000,
										"crypto",
										{}
									)
								end

								return true
							end
						end
					end
				end
			end
			return false
		end,
	},
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["sandbox-base"]:RegisterComponent("Crypto", _CRYPTO)
end)
