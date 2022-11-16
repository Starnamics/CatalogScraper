--[[

	CatalogScraper - Scrape assets from the catalog with ease
	
	This module makes use of Roblox's catalog search API to
	scrape large amounts of assets from the catalog.
	It is fully typed and has support for all the functionality
	of the search API.
	
	As of the current release, this module does not support
	getting the data of an individual item or the ability to
	browse using cursors. I plan to add both of these in a 
	later update.
	
	Author: Starnamics
	Version: 1.0.0
	License: MIT License

--]]

--// Services

local HttpService = game:GetService("HttpService")

--// Constants

local CatalogSearchUrl = "https://catalog.roproxy.com/v1/search/items/details"

--// Types

export type Category = "Featured" | "All" | "Collectibles" | "Clothing" | "BodyParts" | "Gear" | "Accessories" | "AvatarAnimations" | "CommunityCreations"
export type CreatorName = string
export type CreatorTargetId = number
export type CreatorType = "User" | "Group"
export type Cursor = string
export type Genre = "TownAndCity" | "Medieval" | "SciFi" | "Fighting" | "Horror" | "Naval" | "Adventure" | "Sports" | "Comedy" | "Western" | "Military" | "Building" | "FPS" | "RPG"
export type Keyword = string
export type Limit = "10" | "28" | "30"
export type MaxPrice = number
export type MinPrice = number
export type SortAggregation = "PastDay" | "PastWeek" | "PastMonth" | "AllTime"
export type SortType = "Relevance" | "Favorited" | "Sales" | "Updated" | "PriceAsc" | "PriceDesc"
export type Subcategory = "Featured" | "All" | "Collectibles" | "Clothing" | "BodyParts" | "Gear" | "Hats" | "Faces" | "Shirts" | "TShirts" | "Pants" | "Heads" | "Accessories" | "HairAccessories" | "FaceAccessories" | "NeckAccessories" | "ShoulderAccessories" | "FrontAccessories" | "BackAccessories" | "WaistAccessories" | "AvatarAnimations" | "Bundles" | "AnimationBundles" | "EmoteAnimations" | "CommunityCreations" | "Melee" | "Ranged" | "Explosive" | "PowerUp" | "Navigation" | "Musical" | "Social" | "Building" | "Transport"

export type SearchParams = {
	["Category"]: Category | nil,
	["CreatorName"]: CreatorName | nil,
	["CreatorTargetId"]: CreatorTargetId | nil,
	["CreatorType"]: CreatorType | nil,
	["Cursor"]: Cursor | nil,
	["Genre"]: Genre | nil,
	["Keyword"]: Keyword | nil,
	["Limit"]: Limit | nil,
	["MaxPrice"]: MaxPrice | nil,
	["MinPrice"]: MinPrice | nil,
	["SortAggregation"]: SortAggregation | nil,
	["SortType"]: SortType | nil,
	["Subcategory"]: Subcategory | nil
}

export type AssetType = "T-Shirt" | "Hat" | "Shirt" | "Pants" | "Head" | "Face" | "Gear" | "Arms" | "Legs" | "Torso" | "RightArm" | "LeftArm" | "LeftLeg" | "RightLeg" | "HairAccessory" | "FaceAccessory" | "NeckAccessory" | "ShoulderAccessory" | "FrontAccessory" | "BackAccessory" | "WaistAccessory" | "ClimbAnimation" | "DeathAnimation" | "FallAnimation" | "IdleAnimation" | "JumpAnimation" | "RunAnimation" | "SwimAnimation" | "WalkAnimation" | "PoseAnimation" | "EmoteAnimation"
export type BundleType = "BodyParts" | "AvatarAnimations"
export type Description = string
export type FavoriteCount = number
export type Genres = {"All" | "Tutorial" | "Scary" | "TownAndCity" | "War" | "Funny" | "Fantasy" | "Adventure" | "SciFi" | "Pirate" | "FPS" | "RPG" | "Sports" | "Ninja" | "WildWest"}
export type AssetId = number
export type ItemRestrictions = {"ThirteenPlus" | "LimitedUnique" | "Limited" | "Rthro"}
export type ItemStatus = {"New" | "Sale" | "XboxExclusive" | "AmazonExclusive" | "GooglePlayExclusive" | "IosExclusive" | "SaleTimer"}
export type ItemType = "Asset" | "Bundle"
export type LowestPrice = number
export type Name = string
export type CreatorHasVerifiedBadge = boolean
export type Price = number
export type PriceStatus = "Free" | "OffSale" | "NoResellers"
export type PurchaseCount = number
export type UnitsAvailableForConsumption = number
export type ProductId = number

export type Asset = {
	["AssetType"]: AssetType,
	["BundleType"]: BundleType,
	["Description"]: Description,
	["CreatorHasVerifiedBadge"]: CreatorHasVerifiedBadge,
	["CreatorName"]: CreatorName,
	["CreatorTargetId"]: CreatorTargetId,
	["CreatorType"]: CreatorType,
	["FavoriteCount"]: FavoriteCount,
	["Genres"]: Genres,
	["AssetId"]: AssetId,
	["ItemRestrictions"]: ItemRestrictions,
	["ItemStatus"]: ItemStatus,
	["ItemType"]: ItemType,
	["LowestPrice"]: LowestPrice | nil,
	["Name"]: Name,
	["Price"]: Price,
	["PriceStatus"]: PriceStatus,
	["PurchaseCount"]: PurchaseCount,
	["UnitsAvailableForConsumption"]: UnitsAvailableForConsumption | nil,
	["ProductId"]: ProductId,
}

--// Parsing Tables

local AssetTypes = {
	[2] = "T-Shirt",
	[8] = "Hat",
	[11] = "Shirt",
	[12] = "Pants",
	[17] = "Head",
	[18] = "Face",
	[19] = "Gear",
	[25] = "Arms",
	[26] = "Legs",
	[27] = "Torso",
	[28] = "RightArm",
	[29] = "LeftArm",
	[30] = "LeftLeg",
	[31] = "RightLeg",
	[41] = "HairAccessory",
	[42] = "FaceAccessory",
	[43] = "NeckAccessory",
	[44] = "ShoulderAccessory",
	[45] = "FrontAccessory",
	[46] = "BackAccessory",
	[47] = "WaistAccessory",
	[48] = "ClimbAnimation",
	[49] = "DeathAnimation",
	[50] = "FallAnimation",
	[51] = "IdleAnimation",
	[52] = "JumpAnimation",
	[53] = "RunAnimation",
	[54] = "SwimAnimation",
	[55] = "WalkAnimation",
	[56] = "PoseAnimation",
	[61] = "EmoteAnimation",
}

local Categories = {
	["Featured"] = 0,
	["All"] = 1,
	["Collectibles"] = 2,
	["Clothing"] = 3,
	["BodyParts"] = 4,
	["Gear"] = 5,
	["Accessories"] = 11,
	["AvatarAnimations"] = 12,
	["CommunityCreations"] = 13,
}

local CreatorTypes = {
	["User"] = 1,
	["Group"] = 2,
}

local Genres = {
	["TownAndCity"] = 1,
	["Medieval"] = 2,
	["SciFi"] = 3,
	["Fighting"] = 4,
	["Horror"] = 5,
	["Naval"] = 6,
	["Adventure"] = 7,
	["Sports"] = 8,
	["Comedy"] = 9,
	["Western"] = 10,
	["Military"] = 11,
	["Building"] = 13,
	["FPS"] = 14,
	["RPG"] = 15,
}

local SortAggregations = {
	["PastDay"] = 1,
	["PastWeek"] = 3,
	["PastMonth"] = 4,
	["AllTime"] = 5,
}

local SortTypes = {
	["Relevance"] = 0,
	["Favorited"] = 1,
	["Sales"] = 2,
	["Updated"] = 3,
	["PriceAsc"] = 4,
	["PriceDesc"] = 5,
}

local Subcategories = {
	["Featured"] = 0,
	["All"] = 1,
	["Collectibles"] = 2,
	["Clothing"] = 3,
	["BodyParts"] = 4,
	["Gear"] = 5,
	["Hats"] = 9,
	["Faces"] = 10,
	["Shirts"] = 12,
	["TShirts"] = 13,
	["Pants"] = 14,
	["Heads"] = 15,
	["Accessories"] = 19,
	["HairAccessories"] = 20,
	["FaceAccessories"] = 21,
	["NeckAccessories"] = 22,
	["ShoulderAccessories"] = 23,
	["FrontAccessories"] = 24,
	["BackAccessories"] = 25,
	["WaistAccessories"] = 26,
	["AvatarAnimations"] = 27,
	["Bundles"] = 37,
	["AnimationBundles"] = 38,
	["EmoteAnimations"] = 39,
	["CommunityCreations"] = 40,
	["Melee"] = 41,
	["Ranged"] = 42,
	["Explosive"] = 43,
	["PowerUp"] = 44,
	["Navigation"] = 45,
	["Musical"] = 46,
	["Social"] = 47,
	["Building"] = 48,
	["Transport"] = 49,
}

--// Private Functions

function ParseParameters(Parameters: SearchParams)
	local ParsedParams: SearchParams = {
		Category = Categories[Parameters.Category],
		CreatorName = Parameters.CreatorName,
		CreatorType = CreatorTypes[Parameters.CreatorType],
		CreatorTargetId = Parameters.CreatorTargetId,
		Cursor = Parameters.Cursor,
		Genres = Parameters.Genre,
		Keyword = Parameters.Keyword,
		Limit = tonumber(Parameters.Limit),
		MaxPrice = Parameters.MaxPrice,
		MinPrice = Parameters.MinPrice,
		SortAggregation = SortAggregations[Parameters.SortAggregation],
		SortType = SortTypes[Parameters.SortType],
		Subcategory = Subcategories[Parameters.Subcategory],
	}
	return ParsedParams
end

function ConvertParamDictionaryToString(Parameters: SearchParams)
	local ParamString = ""
	for Param,Value in pairs(ParseParameters(Parameters)) do
		ParamString = ParamString..string.format("%s=%s&",Param,Value)
	end
	return ParamString
end

function ParseAssetData(Data: {[string]: any})
	local Asset: Asset = {
		AssetType = AssetTypes[Data["assetType"]],
		BundleType = Data["bundleType"],
		CreatorHasVerifiedBadge = Data["creatorHasVerifiedBadge"],
		CreatorName = Data["creatorName"],
		CreatorType = Data["creatorType"],
		CreatorTargetId = Data["creatorTargetId"],
		Description = Data["description"],
		FavoriteCount = Data["favoriteCount"],
		Genres = Data["genres"],
		AssetId = Data["id"],
		ItemRestrictions = Data["itemRestrictions"],
		ItemStatus = Data["itemStatus"],
		ItemType = Data["itemType"],
		Price = Data["price"],
		PriceStatus = Data["priceStatus"],
		LowestPrice = Data["lowestPrice"],
		Name = Data["name"],
		ProductId = Data["productId"],
		PurchaseCount = Data["purchaseCount"],
		UnitsAvailableForConsumption = Data["unitsAvailableForConsumption"]
	}
	return Asset
end

function ScrapeCatalogAssets(Parameters: SearchParams,Amount: number?,Assets: {any}?,LogOutput: boolean | nil)
	local Assets = Assets or {}
	local Amount = Amount or 0
	
	local Success,Response = pcall(function() 
		local response = game:GetService("HttpService"):GetAsync(CatalogSearchUrl.."?"..ConvertParamDictionaryToString(Parameters))
		return HttpService:JSONDecode(response)
	end)
	if not Success or not Response then warn("Failed to scrape:",Response) return end
	
	for _,v in pairs(Response["data"]) do
		table.insert(Assets,ParseAssetData(v))
	end
	
	if LogOutput then
		warn(#Assets,"assets scraped")
	end
	
	if Response["nextPageCursor"] and (Amount > #Assets or Amount == 0)  then
		Parameters.Cursor = Response["nextPageCursor"]
		return ScrapeCatalogAssets(Parameters,Amount,Assets,LogOutput)
	end
	
	return Assets
end

--// Main Module

local CatalogScraper = {ScrapeParams = {}}

--// Scraper Functions

function CatalogScraper:Scrape(Parameters: SearchParams,Amount: number | nil,LogOutput: boolean | nil)
	local Assets = ScrapeCatalogAssets(Parameters,Amount,nil,LogOutput)
	return Assets :: {[number]: Asset}
end

--// Helper Functions

function CatalogScraper.ScrapeParams.new() : SearchParams
	return {}
end

return CatalogScraper