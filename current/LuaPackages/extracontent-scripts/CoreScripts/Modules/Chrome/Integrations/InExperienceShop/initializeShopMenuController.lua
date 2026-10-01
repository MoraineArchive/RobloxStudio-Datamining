local SHOP_MENU_KEY = "in_experience_shop"

type BooleanSignal = {
	connect: (BooleanSignal, (boolean) -> ()) -> any,
}

-- Holds a `GuiService` menu key for as long as the Shop window is open. Registering a
-- menu key is what stops the engine from delivering input to the experience, so a
-- mouse-locked or first-person experience releases the cursor and clicks inside the Shop
-- can't reach a weapon script (experiences that never check `gameProcessedEvent` fire on
-- any click otherwise, and no amount of CoreGui-side input sinking can stop them).
--
-- Deliberately does NOT close the Shop on `GuiService.MenuOpened`: that signal is
-- reference-counted on the overall menu state, so registering the key below fires it for
-- the Shop's own window (which would close the Shop as it opened), and it stays silent
-- when the pause menu opens on top of an already-registered Shop. Chrome already keeps
-- the two from stacking by dropping the window host's `DisplayOrder` while the pause menu
-- is open (see `WindowHost`).
local function initializeShopMenuController(guiService: GuiService, isShopOpen: BooleanSignal)
	isShopOpen:connect(function(isOpen)
		guiService:SetMenuIsOpen(isOpen, SHOP_MENU_KEY)
	end)
end

return initializeShopMenuController
