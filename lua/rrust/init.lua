local ts_utils = require('nvim-treesitter.ts_utils')
local parsers = require('nvim-treesitter.parsers')
local M = {}

local get_test_function_name = function()
    -- assert the language is Rust
    vim.treesitter.language.require_language("rust")
    if parsers.get_parser():lang() ~= "rust" then
        error("Expected Rust language")
    end

    -- fetch the current node
    local node = ts_utils.get_node_at_cursor()
    if node == nil then
        error("No Treesitter node available")
    end

    -- fetch the root of the node to halt backtrack
    local root = ts_utils.get_root_for_node(node)

    -- loop until find a function item; if hit root, abort
    while (node ~= nil and node ~= root) do

        -- find attribute item `test`
        if node:type() == "function_item" then

            -- scan for attribute sibling; halt on another function declaration
            -- this is a naive approach because other valid tokens might exist before the attribute
            local attribute_item = node:prev_named_sibling()
            while (attribute_item ~= nil) do

                -- another function has been found; halt
                if attribute_item:type() == "function_item" then
                    print("The Rust function is not a test")

                -- if attribute_item, scan for a test directive
                elseif attribute_item:type() == "attribute_item" then

                    -- fetch the attribute text and check if equals test
                    for attribute, _ in attribute_item:iter_children() do
                        if attribute:named() and attribute:type() == "attribute" then
                            if vim.treesitter.get_node_text(attribute, 0) == "test" then
                                return vim.treesitter.get_node_text(node:field("name")[1], 0)
                            end
                        end
                    end

                end

                -- not found yet; continue backtracking
                attribute_item = attribute_item:prev_named_sibling()
            end
        end

        -- keep backtracking
        node = node:parent()
    end

    return nil
end

local get_manifest_path = function()
    -- get full path of current buffer
    local buffer_path = vim.api.nvim_buf_get_name(0)

    -- move to parent dir
    local parent = vim.fn.fnamemodify(buffer_path, ":p:h")

    -- loop and try to find manifest file
    while (parent ~= nil and string.len(parent) > 0 and parent ~= "/") do
        -- not sure this works on windows, but ¯\_(ツ)_/¯
        local candidate = parent .. "/Cargo.toml"

        -- test if file exists
        local f = io.open(candidate, "r")
        if f ~= nil then
            io.close(f)
            return candidate
        end

        -- move to parent
        parent = vim.fn.fnamemodify(parent, ":h")
    end

    -- failed to find manifest file
    return nil
end

M.RustRRTestRecord = function(args, env)
    -- get the test function name
    local function_name = get_test_function_name()
    if function_name == nil then
        error("Not a test function")
    end

    -- get the manifest path
    local manifest_path = get_manifest_path()
    if manifest_path == nil then
        error("Couldn't find the manifest file")
    end

    -- arguments are optional
    if args == nil then
        args = ""
    end
    if env == nil then
        env = ""
    end

    -- pick a binary path
    local cmd = env .. "cargo test --no-run --message-format=json --manifest-path " .. manifest_path .. " -q " .. args .. " | jq -r 'select(.profile.test == true and .executable != null) | .executable'"
    local paths = {}
    for path in io.popen(cmd):lines() do
        if not string.match(path, "^%s*$") then
            table.insert(paths, path)
        end
    end
    local path
    if #paths > 1 then
        local choice = vim.fn.inputlist(paths)
        path = paths[choice]
    elseif #paths == 1 then
        path = paths[1]
    end
    if path == nil then
        error("No binary path available")
    end

    -- if the binary is not built, build/run the test
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
    else
        local cmd = env .. "cargo test --manifest-path " .. manifest_path .. " -q " .. args .. " " .. function_name
        os.execute(cmd)
        local f = io.open(path, "r")
        if f == nil then
            error("Could not find test binary path " .. path)
        end
        io.close(f)
    end

    -- run the rr debug
    local cmd = "rr record -n " .. path .. " " .. function_name
    local result = os.execute(cmd) == 0
    print("Recorded test `" .. function_name .. "` with result `" .. tostring(result) .."`")
end

M.RustRRTestReplay = function()
    -- store the current path and line
    local path = vim.api.nvim_buf_get_name(0)
    local pos = vim.api.nvim_win_get_cursor(0)

    -- open a new tab with the current file
    vim.api.nvim_command(":tabnew")

    -- use RR as TermDebug backend
    vim.g.termdebugger = {'rr', 'replay', '--'}

    -- invoke the interface
    vim.cmd("Termdebug")
    vim.cmd("Program")
    vim.cmd("hide")
    vim.cmd("stopinsert")
    vim.api.nvim_command("edit " .. path)
    vim.api.nvim_win_set_cursor(0, pos)
end

return M
