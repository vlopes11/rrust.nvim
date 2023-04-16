# RRust

This is a helper tool to record the execution of a Rust test with `rr`, and replay it using `termdebug`. For more information, check `:h termdebug`.

## Requirements

Minimum version of neovim: 0.9.0

- https://github.com/nvim-treesitter/nvim-treesitter
- https://rr-project.org/
- https://www.rust-lang.org/
- https://stedolan.github.io/jq
- https://www.linux.org/ (this is not tested with Win, OSX, etc - it might work tho)

```vim
packadd termdebug
```

## Installation

```vim
Plug 'vlopes11/rrust.nvim'
```

## Usage

Position your cursor on a Rust test, and run:

```vim
:lua require('rrust').RustRRTestRecord()
```

It will call `rr` to record the execution of the test.

To debug the test, run:

```vim
:lua require('rrust').RustRRTestReplay()
```

## Etc

I created the following convenience setup:

```lua
local rrust = require('rrust')

vim.cmd('packadd termdebug')

vim.keymap.set("n", "<leader>ed", function()
    if rrust.RustRRTestRecord() then
        rrust.RustRRTestReplay()
        vim.cmd([[
            wincmd L
            wincmd h
            vertical resize 73
            wincmd l
            stopinsert
        ]])
    end
end)

vim.keymap.set('n', '<F4>', function() vim.cmd('Stop') end)
vim.keymap.set('n', '<F5>', function() vim.cmd('Continue') end)
vim.keymap.set('n', '<F6>', function() vim.cmd('Finish') end)
vim.keymap.set('n', '<F7>', function() vim.cmd('Step') end)
vim.keymap.set('n', '<F8>', function() vim.cmd('Over') end)
vim.keymap.set('n', '<F9>', function() vim.cmd('Break') end)
vim.keymap.set('n', '<F10>', function() vim.cmd('Evaluate') end)
```

![output](https://user-images.githubusercontent.com/8730839/231178300-5d999d5f-b0cd-48ad-a218-1836f0ac4521.gif)
