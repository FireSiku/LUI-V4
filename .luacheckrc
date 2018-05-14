max_line_length = 120

exclude_files = {
	"libs",
	"api\oUF",
    ".luacheckrc",
}

ignore = {
	"113", -- Accessing global variable. Placeholder while I fill the custom globals.
	"12.", -- ignore "Setting a read-only global variable/Setting a read-only field of a global variable."
	"43.", -- Shadowed upvalues happens often when writing scripts or trying to work with another module.
	"542", -- disable warnings for empty if branches. These are useful sometime and easy to notice otherwise.
	"611", -- disable "line contains only whitespace"
	"21./.*_", -- disable unused warnings for variables ending with _
	"211/L", -- Nice to have and declare even if a file isn't currently using localization.
	"212/self", -- Disable unused self arguments warnings.
	"213/[ikv]", -- Disable unused loop warnings for conventional loop vars: i, k, v. 
}

std = "+LUI+Ace+WoW"

--PrintTooltips

-- Globals set or defined by LUI. Most of these are for debug purposes and should be
-- either refactored or removed before the big release.
stds["LUI"] = {
	globals = {
		"LUI", "PrintTooltips", "GFind", "GFindValue", "GFindCTables", "GetMinimapShape", "oUF_LUI",
		"LUIBank", "LUIReagents", "LUIBags",
    }
}

-- Globals that comes from Ace or associated libraries
stds["Ace"] = {
	globals = {
		"LibStub", 
    }
}

-- Most of the FrameXML related globals
stds["WoW"] = {
	globals = {
		string = { fields = {
			"split",
		}},
		"StaticPopupDialogs", "MainMenuBarArtFrame", "MainMenuBar", "FriendsFrame",
    }
}