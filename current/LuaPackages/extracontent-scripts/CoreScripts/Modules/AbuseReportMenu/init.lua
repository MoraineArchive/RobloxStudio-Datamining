local LegacyAbuseReportMenu = require(script.Components.LegacyAbuseReportMenu)
local AbuseReportMenuV2 = require(script.V2.AbuseReportMenu)
local ReportAbuseAnalytics = require(script.Analytics.ReportAbuseAnalytics)

return {
	LegacyAbuseReportMenu = LegacyAbuseReportMenu,
	AbuseReportMenuV2 = AbuseReportMenuV2,
	ReportAbuseAnalytics = ReportAbuseAnalytics,
	["jest.config"] = script["jest.config"],
}
