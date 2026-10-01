game:DefineFastFlag("VoiceDebugConsoleV2", false)

-- Deliberately the legacy getter form, not the preferred FFlagX value convention: many specs across
-- this component tree toggle this flag per-test via SetFastFlagForTesting and expect every call site
-- to observe the new value immediately, without re-requiring the module. A plain FFlagX value would
-- only be re-resolved via jest.resetModules(), which none of those specs do.
return function()
	return game:GetFastFlag("VoiceDebugConsoleV2")
end
