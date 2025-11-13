-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- opencv python related dap
local function eval_current_expr(fn, desc)
  local dapui = require("dapui")
  local util = require("dapui.util")

  local expr = util.get_current_expr()
  if not expr or expr == "" then
    vim.notify("No current expression", vim.log.levels.WARN)
    return
  end
  -- Build the Lua code to run
  local code = fn(expr)
  dapui.eval(code)
end

vim.keymap.set("n", "gp", function()
  eval_current_expr(function(expr)
    return expr .. ".shape"
  end, "debug eval shape")
end, { desc = "debug eval shape" })

vim.keymap.set("n", "g1", function()
  eval_current_expr(function(expr)
    local path = "/dev/shm/" .. expr .. ".png"
    return string.format('cv2.imwrite("%s", %s)', path, expr)
  end, "save image with opencv")
end, { desc = "save image with opencv" })
