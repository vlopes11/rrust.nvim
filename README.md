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

I created the following convenience bindings:

```vim
function! NewRRDebug()
    lua require('rrust').RustRRTestRecord()
    lua require('rrust').RustRRTestReplay()
    wincmd L
    wincmd h
    vertical resize 73
    wincmd l
    stopinsert
endfunction

nnoremap <F4> :Stop<cr>
nnoremap <F5> :Continue<cr>
nnoremap <F6> :Finish<cr>
nnoremap <F7> :Step<cr>
nnoremap <F8> :Over<cr>
nnoremap <F9> :Break<cr>
nnoremap <F10> :Clear<cr>
nnoremap <leader>ed :call NewRRDebug()<cr>
```

![output](https://user-images.githubusercontent.com/8730839/231178300-5d999d5f-b0cd-48ad-a218-1836f0ac4521.gif)
