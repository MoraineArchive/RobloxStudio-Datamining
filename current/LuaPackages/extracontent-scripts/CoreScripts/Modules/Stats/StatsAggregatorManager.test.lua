--!nonstrict
local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local StatsAggregatorManagerClass = require(script.Parent.StatsAggregatorManager)
local StatsUtils = require(script.Parent.StatsUtils)

describe("StatsAggregatorManager", function()
	describe("__new", function()
		it("SHOULD create aggregators for all stat types", function()
			local manager = StatsAggregatorManagerClass.__new()

			for _, statType in ipairs(StatsUtils.AllStatTypes) do
				local aggregator = manager:GetAggregator(statType)
				expect(aggregator).never.toBeNil()
			end
		end)

		it("SHOULD NOT start listening on creation", function()
			local manager = StatsAggregatorManagerClass.__new()

			for _, statType in ipairs(StatsUtils.AllStatTypes) do
				local aggregator = manager:GetAggregator(statType)
				expect(aggregator._listening).never.toBe(true)
			end
		end)
	end)

	describe("GetAggregator", function()
		it("SHOULD return an aggregator for each known stat type", function()
			local manager = StatsAggregatorManagerClass.__new()

			expect(manager:GetAggregator(StatsUtils.StatType_Memory)).never.toBeNil()
			expect(manager:GetAggregator(StatsUtils.StatType_CPU)).never.toBeNil()
			expect(manager:GetAggregator(StatsUtils.StatType_GPU)).never.toBeNil()
			expect(manager:GetAggregator(StatsUtils.StatType_NetworkSent)).never.toBeNil()
			expect(manager:GetAggregator(StatsUtils.StatType_NetworkReceived)).never.toBeNil()
			expect(manager:GetAggregator(StatsUtils.StatType_Ping)).never.toBeNil()
		end)

		it("SHOULD return nil for unknown stat types", function()
			local manager = StatsAggregatorManagerClass.__new()
			expect(manager:GetAggregator("unknown_type")).toBeNil()
		end)
	end)

	describe("StopListening", function()
		it("SHOULD set listening to false on all aggregators", function()
			local manager = StatsAggregatorManagerClass.__new()
			manager:StopListening()

			for _, statType in ipairs(StatsUtils.AllStatTypes) do
				local aggregator = manager:GetAggregator(statType)
				expect(aggregator._listening).toBe(false)
			end
		end)
	end)

	describe("getSingleton", function()
		it("SHOULD return the same instance on multiple calls", function()
			local instance1 = StatsAggregatorManagerClass.getSingleton()
			local instance2 = StatsAggregatorManagerClass.getSingleton()
			expect(instance1).toBe(instance2)
		end)

		it("SHOULD have aggregators for all stat types", function()
			local instance = StatsAggregatorManagerClass.getSingleton()

			for _, statType in ipairs(StatsUtils.AllStatTypes) do
				expect(instance:GetAggregator(statType)).never.toBeNil()
			end
		end)
	end)
end)
