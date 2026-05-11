-- Init setters
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.undofile = true
vim.opt.wrap = false
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
--

-- Plugins
local Plug = vim.fn['plug#']
vim.call('plug#begin')
Plug 'micangl/cmp-vimtex'
Plug 'nvim-lua/plenary.nvim'
Plug 'lervag/vimtex'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'itchyny/lightline.vim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'ziglang/zig.vim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'numToStr/Comment.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
vim.call('plug#end')
--

-- Theme
require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
})
vim.o.background = "dark" 
vim.cmd([[colorscheme gruvbox]])
vim.o.showmode = false
vim.g.lightline = {
	colorscheme = 'wombat',
	active = {
		left = {
			{ 'mode', 'paste' },
			{ 'readonly', 'filename', 'modified' }
		},
		right = {
			{ 'lineinfo' },
			{ 'percent' },
			{ 'fileencoding', 'filetype' },
		},
	},
	component_function = {
		filename = 'LightlineFilename',
	},
}

function LightlineFilenameInLua(opts)
	if vim.fn.expand('%:t') == '' then
		return 'Sketch!'
	else
		return vim.fn.getreg('%')
	end
end


--  https://github.com/itchyny/lightline.vim/issues/657
vim.api.nvim_exec(
	[[
	function! g:LightlineFilename()
		return v:lua.LightlineFilenameInLua()
	endfunction
	]],
	true
)
--

-- Code shit
langs = {'rust', 'c', 'lua', 'zig', 'javascript', 'java', 'cpp', 'json', 'php', 'python', 'elixir', 'erlang', 'go','bash', 'fish', 'lua', 'vim', 'vimdoc'}
require'nvim-treesitter'.install(langs)

vim.api.nvim_create_autocmd('FileType', {
	pattern = langs,
	callback = function()
		vim.treesitter.start()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({
			select = true,
			behavior = cmp.ConfirmBehavior.Insert,
		}),
	}),

	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "vimtex" },
	}, {
			{ name = "path" },
			{ name = "buffer" },
		}),

	experimental = {
		ghost_text = true,
	},
})

cmp.setup.cmdline(":", {
	sources = cmp.config.sources({
		{ name = "path" }
	})
})

require('Comment').setup()
local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
vim.keymap.set('x', '<leader>\\', function()
    vim.api.nvim_feedkeys(esc, 'nx', false)
    require('Comment.api').toggle.linewise(vim.fn.visualmode())
end, { desc = 'Toggle comment for selection' })

vim.keymap.set('n', '<leader>\\', function()
    require('Comment.api').toggle.linewise.current()
end, { desc = 'Toggle comment for current line' })

vim.lsp.enable('ruff', {})
vim.lsp.enable('pyright', {})
vim.lsp.config('pyright', {
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic", -- or "strict"
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})
vim.lsp.enable('clangd', {})
vim.lsp.enable('rust_analyzer', {})
vim.lsp.config('rust_analyzer', {	
	settings = {
		["rust-analyzer"] = {
			cargo = {
				features = "all",
			},
			checkOnSave = {
				enable = true,
			},
			check = {
				command = "clippy",
			},
			imports = {
				group = {
					enable = false,
				},
			},
			completion = {
				postfix = {
					enable = false,
				},
			},
		},
	}
})


vim.g.rust_analyzer_on_save = true


local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vim.fn.exepath("vue-language-server"),
	languages = { "vue" },
	configNamespace = "typescript",
}

vim.lsp.config("vtsls", {
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},
	},
	filetypes = tsserver_filetypes,
})

vim.lsp.config("ts_ls", {
	init_options = {
		plugins = {
			vue_plugin,
		},
	},
	filetypes = tsserver_filetypes,
})

vim.lsp.enable({
	"ts_ls",
	"vue_ls",
})

vim.lsp.enable('zls', {})
vim.lsp.config('zls', {
	settings = {
		zls = {
			enable_build_on_save = true,
		},
	},
})
vim.lsp.enable('gopls', {})
vim.lsp.enable('phpactor', {})
vim.lsp.enable('elixirls', {})
vim.lsp.config('elixirls', {
	cmd = { "/usr/lib/elixir-ls/language_server.sh" },
})



vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)


vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'


		local opts = { buffer = ev.buf }
		vim.keymap.set('n', '<C-Space>', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'fi', vim.lsp.buf.implementation, opts)

		vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'fr', vim.lsp.buf.references, opts)

		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- format on save for Rust
		if client.server_capabilities.documentFormattingProvider then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("RustFormat", { clear = true }),
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})


vim.api.nvim_create_autocmd('BufWritePre',{
	pattern = {"*.zig", "*.zon"},
	callback = function(ev)
		vim.lsp.buf.code_action({
			context = { only = { "source.organizeImports" } },
			apply = true,
		})
	end
})


vim.g.vimtex_view_method = 'zathura'
--

-- Plugin settings
require('gitsigns').setup{
	current_line_blame = true,

	on_attach = function(bufnr)
		local gitsigns = require('gitsigns')
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map('n', 'gn', function()
			if vim.wo.diff then
				vim.cmd.normal({']c', bang = true})
			else
				gitsigns.nav_hunk('next')
			end
		end)

		map('n', 'gp', function()
			if vim.wo.diff then
				vim.cmd.normal({'[c', bang = true})
			else
				gitsigns.nav_hunk('prev')
			end
		end)

		-- Actions
		map('n', '<leader>gs', gitsigns.stage_hunk)
		map('n', '<leader>gr', gitsigns.reset_hunk)
		map('v', '<leader>gs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
		map('v', '<leader>gr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
		map('n', '<leader>gu', gitsigns.undo_stage_hunk)
		map('n', '<leader>gp', gitsigns.preview_hunk)
		map('n', '<leader>gb', function() gitsigns.blame_line{full=true} end)
		map('n', '<leader>gtb', gitsigns.toggle_current_line_blame)
		map('n', '<leader>gd', gitsigns.diffthis)
		map('n', '<leader>gD', function() gitsigns.diffthis('~') end)
	end
}
--

-- keymaps
vim.keymap.set('v', '<C-c>', '"+y', {noremap=true, silent=true})
vim.keymap.set('n', '<C-v>', '"+p', {noremap=true, silent=true})
vim.keymap.set('i', '<C-v>', '<Esc>"+pa', {noremap=true, silent=true})

vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>')
vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('i', '<C-q>', '<Esc>:q<CR>i')
vim.keymap.set('n', '<C-q>', ':q<CR>')

vim.keymap.set('i', '<C-z>', '<Esc>:u<CR>i')
vim.keymap.set('n', '<C-z>', ':u<CR>')
vim.keymap.set('i', '<C-y>', '<Esc>:redo<CR>i')
vim.keymap.set('n', '<C-y>', ':redo<CR>')

vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>')

vim.keymap.set('n', '<leader>n', ':nohlsearch<CR>', { silent = true })

local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set(
	'n',
	'<leader>fe',
	function()
		require('telescope.builtin').diagnostics({ bufnr = 0 })
	end,
	{ desc = 'Telescope LSP diagnostics (workspace)' }
)
--

-- AutoCmds
-- jump to last edit position on opening file
vim.api.nvim_create_autocmd(
	'BufReadPost',
	{
		pattern = '*',
		callback = function(ev)
			if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
				-- except for in git commit messages
				-- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
				if not vim.fn.expand('%:p'):find('.git', 1, true) then
					vim.cmd('exe "normal! g\'\\""')
				end
			end
		end
	}
)

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "latex", "tex", "markdown", "md" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    
    vim.opt_local.breakindent = true
    
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "pt", "en" }
  end,
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = {"latex", "tex"},
  callback = function()
		local cmp = require("cmp")
		cmp.setup({
			sources = cmp.config.sources({
				{ name = "vimtex" },
			}, {
				}),

		})
	end,
})
--

