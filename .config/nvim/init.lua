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
Plug 'tpope/vim-sensible'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'itchyny/lightline.vim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'ziglang/zig.vim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'numToStr/Comment.nvim'
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
  filters = {
    dotfiles = true,
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
require('Comment').setup()
vim.lsp.enable('pyright', {})
vim.lsp.enable('clangd', {})
vim.lsp.enable('rust_analyzer', {})
vim.lsp.config('rust_analyzer', {
settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
                extraArgs = {"--no-deps"},
            },
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
 								targetDir = "analyzer-target",
            },
        },
    },
})
vim.g.rust_analyzer_on_save = true
vim.lsp.enable('quick_lint_js', {})
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


require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  sync_install = false,
  auto_install = true,
  
  ignore_install = {"hoon", "teal", "t32", "jsonc", "fusion", "ipkg", "blueprint"},
  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  }
}

vim.api.nvim_create_autocmd('BufWritePre',{
  pattern = {"*.zig", "*.zon"},
  callback = function(ev)
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" } },
      apply = true,
    })
  end
})

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
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
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

vim.keymap.set('n', '<C-h>', function()
  vim.system({ 'kitty', '@', 'launch', '--type=tab', '--cwd=current' })
end, { noremap = true, silent = true, desc = "Open new Kitty tab" })

local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Telescope live grep' })
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
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
--

-- Troubleshotting
-- rust analyzer interrupts:
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end
