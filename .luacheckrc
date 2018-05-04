max_line_length = 120

redefined = false -- Ignore local variables defined twice in the same scope.
--allow_defined_top = true -- Allow globals defined in the top scope of a file.

exclude_files = {
	"libs",
    ".luacheckrc",
}

ignore = {
	"113", -- Accessing global variable. Placeholder while I fill the custom globals.
	"12.", -- ignore "Setting a read-only global variable/Setting a read-only field of a global variable."
	"542", -- disable warnings for empty if branches. These are useful sometime and easy to notice otherwise.
	"611", -- disable "line contains only whitespace"
	"21./.*_", -- disable unused warnings for variables ending with _
	"212/self", -- Disable unused self warnings.
	"213/[ikv]", -- Disable unused loop warnings for conventional loop vars: i, k, v. 
}

std = "+LUI+Ace+WoW"

--PrintTooltips

-- Globals set or defined by LUI.
stds["LUI"] = {
	globals = {
		"LUI", "PrintTooltips",
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
    }
}