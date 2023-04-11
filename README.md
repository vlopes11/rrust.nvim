# RRust

This is a helper tool to record the execution of a Rust test with `rr`, and replay it using `termdebug`. For more information, check `:h termdebug`.

## Requirements

Minimum version of neovim: 0.9.0

- https://github.com/nvim-treesitter/nvim-treesitter
- https://rr-project.org/
- https://www.rust-lang.org/
- https://stedolan.github.io/jq
- https://www.linux.org/

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

![demo](https://user-images.githubusercontent.com/8730839/231110925-8f581b74-ef5c-46cb-aaca-54b8b9896254.gif)
