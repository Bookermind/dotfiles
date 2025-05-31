return {
    "echasnovski/mini.pairs",
    version = false,
    opts = {
        mappings = {
            ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]." },
			[">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
        },
    },
}
