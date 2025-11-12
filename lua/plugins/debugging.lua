return {
  {
    'nvim-neotest/neotest',
    dependencies = { 'nvim-neotest/neotest-python' },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('neotest').setup {
        adapters = {
          require 'neotest-python',
        },
      }
    end,
    keys = {
      { '<leader>dtt', ":lua require'neotest'.run.run({strategy = 'dap'})<cr>", desc = '[t]est' },
      { '<leader>dts', ":lua require'neotest'.run.stop()<cr>", desc = '[s]top test' },
      { '<leader>dta', ":lua require'neotest'.run.attach()<cr>", desc = '[a]ttach test' },
      { '<leader>dtf', ":lua require'neotest'.run.run(vim.fn.expand('%'))<cr>", desc = 'test [f]ile' },
      { '<leader>dts', ":lua require'neotest'.summary.toggle()<cr>", desc = 'test [s]ummary' },
    },
  },

  -- debug adapter protocol
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'nvim-neotest/nvim-nio',
        'rcarriga/nvim-dap-ui',
        'mfussenegger/nvim-dap-python',
        'theHamsta/nvim-dap-virtual-text',
        -- nvim-dap-ui is too big for smaller termial
        -- {
        --   'igorlfs/nvim-dap-view',
        --   opts = {
        --     winbar = {
        --       show = true,
        --       sections = { 'watches', 'exceptions', 'breakpoints', 'threads', 'repl' },
        --       -- Must be one of the sections declared above
        --       default_section = 'watches',
        --     },
        --     windows = {
        --       height = 10,
        --       terminal = {
        --         -- 'left'|'right'|'above'|'below': Terminal position in layout
        --         position = 'left',
        --         -- List of debug adapters for which the terminal should be ALWAYS hidden
        --         hide = {},
        --         -- Hide the terminal when starting a new session
        --         start_hidden = false,
        --       },
        --     },
        --   },
        -- },
      },
    },
    config = function()
      vim.fn.sign_define('DapBreakpoint', { text = '🦆', texthl = '', linehl = '', numhl = '' })
      local dap = require 'dap'
      local ui = require 'dapui'
      -- https://github.com/rcarriga/nvim-dap-ui/issues/320
      local ui_config = {
        icons = { expanded = '📖', collapsed = '📕', current_frame = '👉' },
        controls = {
          icons = {
            pause = '⏸️',
            play = '⏯️',
            step_into = '↴',
            step_over = '↷',
            step_out = '↑',
            step_back = '↶',
            run_last = '🔁',
            terminate = '❌',
            disconnect = '🆘',
          },
        },
        layouts = {
          {
            elements = {
              {
                id = 'repl',
                size = 0.5,
              },
              {
                id = 'console',
                size = 0.5,
              },
            },
            position = 'bottom',
            size = 10,
          },
        },
      }

      require('dapui').setup(ui_config)
      -- require('dapui').setup()
      require('dap-python').setup()
      require('dap.ext.vscode').load_launchjs()

      require('nvim-dap-virtual-text').setup {
        -- Hides tokens, secrets, and other sensitive information
        -- From TJ DeVries' config
        -- Not necessary, but also can't hurt
        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match 'secret' or name:match 'api' or value:match 'secret' or value:match 'api' then
            return '*****'
          end

          if #variable.value > 15 then
            return ' ' .. string.sub(variable.value, 1, 15) .. '... '
          end

          return ' ' .. variable.value
        end,
      }

      -- require('nvim-dap-view').setup {
      --
      -- }
      -- dap.listeners.before.attach.dapui_config = function()
      --   ui.open()
      -- end
      -- dap.listeners.before.launch.dapui_config = function()
      --   ui.open()
      -- end
      -- dap.listeners.before.event_terminated.dapui_config = function()
      --   ui.close()
      -- end
      -- dap.listeners.before.event_exited.dapui_config = function()
      --   ui.close()
      -- end
    end,
    keys = {
      { '<leader>db', ":lua require'dap'.toggle_breakpoint()<cr>", desc = 'debug [b]reakpoint' },
      { '<leader>dc', ":lua require'dap'.continue()<cr>", desc = 'debug [c]ontinue' },
      { '<leader>do', ":lua require'dap'.step_over()<cr>", desc = 'debug [o]ver' },
      { '<leader>dO', ":lua require'dap'.step_out()<cr>", desc = 'debug [O]ut' },
      { '<leader>di', ":lua require'dap'.step_into()<cr>", desc = 'debug [i]nto' },
      { '<F5>', ":lua require'dap'.step_into()<cr>", desc = 'debug into' },
      { '<F6>', ":lua require'dap'.step_over()<cr>", desc = 'debug over' },
      { '<F7>', ":lua require'dap'.step_out()<cr>", desc = 'debug out' },
      { '<F8>', ":lua require'dap'.continue()<cr>", desc = 'debug continue' },
      -- { '<F9>', ":lua require'dap-view'.toggle()<cr>", desc = 'toogle dap-view ui' },
      { '<F9>', ":lua require'dapui'.toggle()<cr>", desc = 'toogle dap-view ui' },
      { '<F10>', ":lua require'dap'.toggle_breakpoint()<cr>", desc = 'debug breakpoint' },
      { '<leader>dr', ":lua require'dap'.repl_open()<cr>", desc = 'debug [r]epl' },
      { '<leader>du', ":lua require'dapui'.toggle()<cr>", desc = 'debug [u]i' },
      -- { 'ge', ":lua require'dap.ui.widgets'.hover()<cr>", desc = 'debug hov[e]r' },
      { 'ge', ":lua require'dapui'.eval()<cr>", desc = 'debug [e]val' },
      -- {
      --   'gp',
      --   ":lua require'dapui'.eval(require'dapui.util'.get_current_expr() .. '.shape')<cr>",
      --   desc = 'debug eval shape',
      -- },
      -- {
      --   'g1',
      --   ":lua require'dapui'.eval('cv2.imwrite(\"/dev/shm/' .. require'dapui.util'.get_current_expr() .. '.png\", ' .. require'dapui.util'.get_current_expr() .. ')')<cr>",
      --   desc = 'save image with opencv',
      -- },
    },
  },
}
