local CorePackages = game:GetService("CorePackages")
local FFlagExperienceAgeRatingBadge =
	require(CorePackages.Workspace.Packages.InExperienceTopBar).Flags.FFlagExperienceAgeRatingBadge
local FFlagShowGameAgeRating = require(CorePackages.Workspace.Packages.SharedFlags).FFlagShowGameAgeRating

local function isEligible(
	showGameAgeRating: boolean?,
	chromeEnabled: boolean,
	leftAligned: boolean,
	spatial: boolean
): boolean
	return FFlagExperienceAgeRatingBadge
		and FFlagShowGameAgeRating
		and showGameAgeRating == true
		and chromeEnabled
		and leftAligned
		and not spatial
end

return {
	isEligible = isEligible,
	keepOutAreaId = "experience-age-rating",
}
